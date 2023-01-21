struct Display <: Handle
  handle::RefcountHandle # Ptr{wl_display}
  function Display(socket = nothing)
    handle = wl_display_connect(something(socket, C_NULL))
    handle ≠ C_NULL || error("No connection could be established to a wayland display on", isnothing(socket) ? " the default socket" : " socket $socket")
    new(RefcountHandle(handle, wl_display_disconnect))
  end
end

getdisplay(x::Display) = x
getdisplay(x::Handle) = getdisplay(parent(x))

function synchronize(dpy::Display)
  n = wl_display_roundtrip(dpy)
  n == -1 && error("An error occurred while synchronizing with the server.")
  !iszero(n) && @debug "$n events were dispatched by the server during the synchronization."
  dpy
end

function barrier(dpy::Display)
  wl_display_sync(dpy)
  dpy
end

function synchronize(x)
  synchronize(getdisplay(x))
  x
end

function barrier(x)
  barrier(getdisplay(x))
  x
end

const GlobalID = UInt32

struct Global
  id::GlobalID
  name::Symbol
  version::Int
end

function on_global(data, registry, name, interface, version)
  registry = retrieve_data(data, Registry)
  interface == C_NULL && return
  id = name
  name = Symbol(unsafe_string(interface))
  g = Global(id, name, version)
  registry.globals[name] = g
  nothing
end

function on_global_remove(data, registry, id)
  registry = retrieve_data(data, Registry)
  for (k, v) in registry.globals
    if v.id == id
      delete!(registry.globals, k)
      return
    end
  end
end

mutable struct Registry <: Handle
  handle::RefcountHandle # Ptr{wl_registry}
  dpy::Display
  globals::Dict{Symbol, Global}
  function Registry(dpy::Display)
    handle = wl_display_get_registry(dpy)
    handle ≠ C_NULL || error("Failed to obtain the global registry")
    registry = new(RefcountHandle(handle, nothing, dpy), dpy, Dict{Symbol, Global}())
    listener = Listener(registry, wl_registry_listener(
      @cfunction_wl_registry_global(on_global),
      @cfunction_wl_registry_global_remove(on_global_remove),
    ), registry)
    register(listener; keep_alive = false)
    # Wait for globals to be filled in.
    # Make sure to keep it alive as long as the listener is active.
    synchronize(registry)
    finalize(listener)
    registry
  end
end

Base.parent(x::Registry) = x.dpy

function Base.bind(registry::Registry, gname::Symbol, version = nothing)
  g = get(registry.globals, gname, nothing)
  isnothing(g) && return error("The global named \"$gname\" is not available")
  wl_registry_bind(registry, g.id, interface_dict[gname], something(version, g.version))
end

mutable struct Compositor <: Handle
  handle::RefcountHandle # Ptr{wl_compositor}
  registry::Registry
  Compositor(registry::Registry, version = nothing) = new(RefcountHandle(bind(registry, :wl_compositor, version), nothing, registry), registry)
end

Base.parent(x::Compositor) = x.registry

mutable struct Surface <: Handle
  handle::RefcountHandle # Ptr{wl_surface}
  compositor::Compositor
  function Surface(compositor::Compositor)
    h = wl_compositor_create_surface(compositor)
    new(RefcountHandle(h, wl_surface_destroy, compositor), compositor)
  end
end

Base.parent(x::Surface) = x.compositor

function on_format(data, shm, format)
  shm = retrieve_data(data, SharedMemory)
  try
    # Guard against future additions of enumerated values.
    # The µs-scale slowness of `try/catch` on failure should be alright for this case.
    push!(shm.supported_formats, WlShmFormat(format))
  catch
  end
  nothing
end

"""
Allocate a shared memory file descriptor bound to a memory segment of `size` bytes.
"""
function allocate_shm_fd(size)
  for i in 1:100
    name = '/' * basename(tempname())
    flags = JL_O_RDWR | JL_O_CREAT | JL_O_EXCL
    permissions = S_IRUSR | S_IWUSR
    fd = @ccall shm_open(name::Cstring, flags::UInt16, permissions::UInt16)::Int32
    if fd ≥ 0
      fd = RawFD(fd)
      # Unlink the name from the memory segment for automatic clean-up after
      # process termination and to prevent unwanted access.
      ret = @ccall shm_unlink(name::Cstring)::Int32
      ret ≠ 0 && @debug "Could not unlink the shared memory file at $name (errno: $(errno()))"
      Filesystem.truncate(File(fd), size)
      return fd
    end
    err = errno()
    err == Libc.EEXIST || error("Could not create a shared memory file at $name (errno: $err)")
  end
  error("Failed to allocate a shared memory file")
end

mutable struct SharedMemoryPool <: Handle
  handle::RefcountHandle # Ptr{wl_shm_pool}
  shm
  memory::IOStream
  function SharedMemoryPool(shm, size::Integer)
    fd = allocate_shm_fd(size)
    h = wl_shm_create_pool(shm::SharedMemory, fd, size)
    io = fdio(Base.cconvert(Cint, fd))
    new(RefcountHandle(h, wl_shm_pool_destroy, shm), shm, io)
  end
end

function Base.getproperty(pool::SharedMemoryPool, name::Symbol)
  name === :shm && return getfield(pool, :shm)::SharedMemory
  getfield(pool, name)
end

Base.parent(x::SharedMemoryPool) = x.shm

mutable struct SharedMemory <: Handle
  handle::RefcountHandle # Ptr{wl_shm}
  registry::Registry
  supported_formats::Vector{WlShmFormat}
  pool::SharedMemoryPool
  function SharedMemory(registry::Registry, size::Integer, version = nothing)
    shm = new()
    shm.handle = RefcountHandle(bind(registry, :wl_shm, version), nothing, registry)
    shm.registry = registry
    shm.supported_formats = WlShmFormat[]
    shm.pool = SharedMemoryPool(shm, size)
    listener = Listener(shm, wl_shm_listener(@cfunction_wl_shm_format(on_format)), shm)
    register(listener; keep_alive = false)
    # Wait for formats to be filled in.
    synchronize(shm)
    finalize(listener)
    shm
  end
end

Base.parent(x::SharedMemory) = x.registry

Base.write(shm::SharedMemory, args...) = write(shm.pool.memory, args...)
Base.read(shm::SharedMemory, args...) = read(shm.pool.memory, args...)

function finalize_buffer(data, _)
  buffer = retrieve_data(data, Buffer)
  finalize(buffer.listener)
  nothing
end

mutable struct Buffer{T} <: Handle
  handle::RefcountHandle # Ptr{wl_buffer}
  memory::T
  listener::Listener
  function Buffer(shm::SharedMemory, offset, width, height, stride, format::WlShmFormat)
    h = wl_shm_pool_create_buffer(shm.pool, offset, width, height, stride, format)
    buffer = new{SharedMemory}(RefcountHandle(h, wl_buffer_destroy, shm), shm)
    listener = Listener(h, wl_buffer_listener(@cfunction_wl_buffer_release(finalize_buffer)), buffer)
    register(listener; keep_alive = false)
    buffer.listener = listener
    buffer
  end
end

Base.parent(x::Buffer) = x.memory

Base.write(buffer::Buffer, args...) = write(buffer.memory, args...)
Base.read(buffer::Buffer, args...) = read(buffer.memory, args...)

function attach(buffer::Buffer, surface::Surface, offset = (0, 0))
  wl_surface_attach(surface, buffer, offset...)
  surface
end
function damage(surface::Surface, offset = (0, 0), extent = (nothing, nothing))
  wl_surface_damage(surface, offset..., something.(extent, typemax(UInt16))...)
  surface
end
function commit(surface::Surface)
  wl_surface_commit(surface)
  surface
end

@enum XdgRole begin
  XDG_ROLE_TOPLEVEL = 1
  XDG_ROLE_POPUP = 2
end

mutable struct XdgSurface <: Handle
  handle::RefcountHandle # Ptr{xdg_surface}
  surface::Surface
  surface_listener::Listener
  role::XdgRole
  role_handle::RefcountHandle # Ptr{xdg_popup} / Ptr{xdg_toplevel}
  role_listener::Listener
  children::Vector{XdgSurface}
  cfunc::Base.CFunction
  function XdgSurface(configure, xdg_base #= ::XdgIntegration =#, surface::Surface, role::XdgRole, parent = nothing; positioner = nothing)
    h = xdg_wm_base_get_xdg_surface(xdg_base, surface)
    cfunc = @cfunction_xdg_surface_configure($configure)
    fptr = unsafe_convert(Ptr{Cvoid}, cfunc)
    if role == XDG_ROLE_TOPLEVEL
      role_handle = xdg_surface_get_toplevel(h)
      role_listener = Listener(role_handle, xdg_toplevel_listener(
        @cfunction_xdg_toplevel_configure((data, h, width, height, states) -> nothing),
        @cfunction_xdg_toplevel_close((data, h) -> nothing),
        @cfunction_xdg_toplevel_configure_bounds((data, h, width, height) -> nothing),
      ))
    elseif role == XDG_ROLE_POPUP
      role_handle = xdg_surface_get_popup(h, something(parent::Optional{XdgSurface}, C_NULL), positioner::Ptr{Cvoid})
      role_listener = Listener(role_handle, xdg_popup_listener(
        @cfunction_xdg_popup_configure((data, h, x, y, width, height) -> nothing),
        @cfunction_xdg_popup_popup_done((data, h) -> nothing),
        @cfunction_xdg_popup_repositioned((data, h, token) -> nothing),
      ))
    end
    xdg_surface = new(RefcountHandle(h, xdg_surface_destroy, xdg_base), surface)
    surface_listener = Listener(h, xdg_surface_listener(fptr), xdg_surface)
    xdg_surface.surface_listener = surface_listener
    xdg_surface.role = role
    xdg_surface.role_handle = RefcountHandle(role_handle, role == XDG_ROLE_TOPLEVEL ? xdg_toplevel_destroy : xdg_popup_destroy, xdg_surface)
    xdg_surface.role_listener = role_listener
    xdg_surface.children = XdgSurface[]
    xdg_surface.cfunc = cfunc
    register(surface_listener; keep_alive = false)
    register(role_listener; keep_alive = false)
    xdg_surface
  end
end

mutable struct XdgIntegration <: Handle
  handle::RefcountHandle # Ptr{xdg_wm_base}
  registry::Registry
  toplevel_surfaces::Vector{XdgSurface}
  function XdgIntegration(registry::Registry, version = nothing)
    h = bind(registry, :xdg_wm_base, version)
    listen(h, xdg_wm_base_listener(@cfunction_xdg_wm_base_ping((_, h, serial) -> (xdg_wm_base_pong(h, serial); nothing))))
    new(RefcountHandle(h, nothing, registry), registry, XdgSurface[])
  end
end

function create_surface!(xdg::XdgIntegration, surface::Surface, role::XdgRole, configure)
  role == XDG_ROLE_TOPLEVEL || error("Only top-level surfaces (i.e. with a role fo `XDG_ROLE_TOPLEVEL`) can be created without parent.")
  surface = XdgSurface(configure, xdg, surface, role)
  push!(xdg.toplevel_surfaces, surface)
  surface
end

mutable struct Keyboard <: Handle
  handle::RefcountHandle # Ptr{wl_keyboard}
  Keyboard(seat) = new(RefcountHandle(wl_seat_get_keyboard(seat), wl_keyboard_release, seat))
end

mutable struct Pointer <: Handle
  handle::RefcountHandle # Ptr{wl_pointer}
  Pointer(seat) = new(RefcountHandle(wl_seat_get_pointer(seat), wl_pointer_release, seat))
end

mutable struct Touch <: Handle
  handle::RefcountHandle # Ptr{wl_touch}
  Touch(seat) = new(RefcountHandle(wl_seat_get_touch(seat), wl_touch_release, seat))
end

mutable struct Seat <: Handle
  handle::RefcountHandle # Ptr{wl_seat}
  registry::Registry
  capabilities::WlSeatCapability
  name::String
  keyboard::Keyboard
  pointer::Pointer
  touch::Touch
  function Seat(registry::Registry)
    h = RefcountHandle(bind(registry, :wl_seat), wl_seat_release, registry)
    seat = new(h, registry)
    on_capabilities = @cfunction_wl_seat_capabilities (data, _, capabilities) -> (retrieve_data(data, Seat).capabilities = capabilities; nothing)
    on_name = @cfunction_wl_seat_name (data, _, name) -> (retrieve_data(data, Seat).name = unsafe_string(name); nothing)
    listen(h, wl_seat_listener(on_capabilities, on_name), seat; keep_listener_alive = false)
    synchronize(registry)
    in(WL_SEAT_KEYBOARD, seat.capabilities) && (seat.keyboard = Keyboard(seat))
    in(WL_SEAT_POINTER, seat.capabilities) && (seat.pointer = Pointer(seat))
    in(WL_SEAT_TOUCH, seat.capabilities) && (seat.touch = Touch(seat))
    seat
  end
end
