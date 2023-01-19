mutable struct Display <: Handle
  handle::Ptr{wl_display}
  function Display(socket = nothing)
    handle = wl_display_connect(something(socket, C_NULL))
    handle ≠ C_NULL || error("No connection could be established to a wayland display on", isnothing(socket) ? " the default socket" : " socket $socket")
    display = new(handle)
    finalizer(wl_display_disconnect, display)
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
  registry = unsafe_pointer_to_objref(data)
  interface == C_NULL && return
  id = name
  name = Symbol(unsafe_string(interface))
  g = Global(id, name, version)
  registry.globals[name] = g
  nothing
end

function on_global_remove(data, registry, id)
  registry = unsafe_pointer_to_objref(data)::Registry
  for (k, v) in registry.globals
    if v.id == id
      delete!(registry.globals, k)
      return
    end
  end
end

mutable struct Registry <: Handle
  handle::Ptr{wl_registry}
  dpy::Display
  globals::Dict{Symbol, Global}
  function Registry(dpy::Display)
    handle = wl_display_get_registry(dpy)
    handle ≠ C_NULL || error("Failed to obtain the global registry")
    registry = new(handle, dpy, Dict{Symbol, Global}())
    listener = Listener(registry, wl_registry_listener(
      @cfunction_wl_registry_global(on_global),
      @cfunction_wl_registry_global_remove(on_global_remove),
    ))
    register(listener, pointer_from_objref(registry); keep_alive = false)
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
  handle::Ptr{wl_compositor}
  registry::Registry
  Compositor(registry::Registry, version = nothing) = new(bind(registry, :wl_compositor, version), registry)
end

Base.parent(x::Compositor) = x.registry

mutable struct Surface <: Handle
  handle::Ptr{wl_surface}
  compositor::Compositor
  function Surface(compositor::Compositor)
    h = wl_compositor_create_surface(compositor)
    finalizer(wl_surface_destroy, new(h, compositor))
  end
end

Base.parent(x::Surface) = x.compositor

function on_format(data, shm, format)
  shm = unsafe_pointer_to_objref(data)::SharedMemory
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
  handle::Ptr{wl_shm_pool}
  shm
  memory::IOStream
  function SharedMemoryPool(shm, size::Integer)
    fd = allocate_shm_fd(size)
    h = wl_shm_create_pool(shm::SharedMemory, fd, size)
    io = fdio(Base.cconvert(Cint, fd))
    pool = new(h, shm, io)
    finalizer(wl_shm_pool_destroy, pool)
  end
end

function Base.getproperty(pool::SharedMemoryPool, name::Symbol)
  name === :shm && return getfield(pool, :shm)::SharedMemory
  getfield(pool, name)
end

Base.parent(x::SharedMemoryPool) = x.shm

mutable struct SharedMemory <: Handle
  handle::Ptr{wl_shm}
  registry::Registry
  supported_formats::Vector{WlShmFormat}
  pool::SharedMemoryPool
  function SharedMemory(registry::Registry, size::Integer, version = nothing)
    shm = new()
    shm.handle = bind(registry, :wl_shm, version)
    shm.registry = registry
    shm.supported_formats = WlShmFormat[]
    shm.pool = SharedMemoryPool(shm, size)
    listener = Listener(shm, wl_shm_listener(@cfunction_wl_shm_format(on_format)))
    register(listener, pointer_from_objref(shm); keep_alive = false)
    # Wait for formats to be filled in.
    synchronize(shm)
    finalize(listener)
    shm
  end
end

Base.parent(x::SharedMemory) = x.registry

Base.write(shm::SharedMemory, args...) = write(shm.pool.memory, args...)
Base.read(shm::SharedMemory, args...) = read(shm.pool.memory, args...)

function finalize_buffer(data, buffer)
  wl_buffer_destroy(buffer)
  nothing
end

mutable struct Buffer{T} <: Handle
  handle::Ptr{wl_buffer}
  memory::T
  listener::Listener
  function Buffer(shm::SharedMemory, offset, width, height, stride, format::WlShmFormat)
    h = wl_shm_pool_create_buffer(shm.pool, offset, width, height, stride, format)
    listener = Listener(h, wl_buffer_listener(@cfunction_wl_buffer_release(finalize_buffer)))
    buffer = new{SharedMemory}(h, shm, listener)
    register(listener; keep_alive = false)
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
  handle::Ptr{Cvoid}
  surface::Surface
  surface_listener::Listener
  xdg_base::Ptr{Cvoid}
  role::XdgRole
  role_handle::Ptr{Cvoid}
  role_listener::Listener
  children::Vector{XdgSurface}
  cfunc::Base.CFunction
  function XdgSurface(configure, xdg_base, surface::Surface, role::XdgRole, parent = nothing; positioner = nothing)
    h = xdg_wm_base_get_xdg_surface(xdg_base, surface)
    cfunc = @cfunction_xdg_surface_configure($configure)
    fptr = unsafe_convert(Ptr{Cvoid}, cfunc)
    surface_listener = Listener(h, xdg_surface_listener(fptr))
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
    xdg_surface = new(h, surface, surface_listener, xdg_base, role, role_handle, role_listener, XdgSurface[], cfunc)
    register(surface_listener, pointer_from_objref(xdg_surface); keep_alive = false)
    register(role_listener; keep_alive = false)
    finalizer(xdg_surface) do x
      x.role == XDG_ROLE_TOPLEVEL && (xdg_toplevel_destroy(x.role_handle))
      x.role == XDG_ROLE_POPUP && (xdg_popup_destroy(x.role_handle))
      xdg_surface_destroy(x)
      finalize(x.surface)
    end
  end
end

mutable struct XdgIntegration <: Handle
  handle::Ptr{Cvoid}
  registry::Registry
  toplevel_surfaces::Vector{XdgSurface}
  function XdgIntegration(registry::Registry, version = nothing)
    h = bind(registry, :xdg_wm_base, version)
    listen(h, xdg_wm_base_listener(@cfunction_xdg_wm_base_ping((_, h, serial) -> (xdg_wm_base_pong(h, serial); nothing))))
    new(h, registry, XdgSurface[])
  end
end

function create_surface!(xdg::XdgIntegration, surface::Surface, role::XdgRole, configure)
  role == XDG_ROLE_TOPLEVEL || error("Only top-level surfaces (i.e. with a role fo `XDG_ROLE_TOPLEVEL`) can be created without parent.")
  surface = XdgSurface(configure, xdg[], surface, role)
  push!(xdg.toplevel_surfaces, surface)
  surface
end
