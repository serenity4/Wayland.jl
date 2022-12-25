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
  wl_display_sync(dpy, C_NULL)
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
    handle = wl_display_get_registry(dpy, C_NULL)
    handle ≠ C_NULL || error("Failed to obtain the global registry")
    registry = new(handle, dpy, Dict{Symbol, Global}())
    listener = wl_registry_listener(
      _global = @cfunction_wl_registry_global(on_global),
      global_remove = @cfunction_wl_registry_global_remove(on_global_remove),
    )
    wl_proxy_add_listener(registry, listener, pointer_from_objref(registry))
    # Wait for globals to be filled in.
    # Make sure to keep it alive as long as the listener is active.
    synchronize(registry)
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
    h = wl_compositor_create_surface(compositor, C_NULL)
    new(h, compositor)
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
    h = wl_shm_create_pool(shm::SharedMemory, C_NULL, fd, size)
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
    wl_proxy_add_listener(shm, wl_shm_listener(format = @cfunction_wl_shm_format(on_format)), pointer_from_objref(shm))
    # Wait for formats to be filled in.
    synchronize(shm)
  end
end

Base.parent(x::SharedMemory) = x.registry

Base.write(shm::SharedMemory, args...) = write(shm.pool.memory, args...)
Base.read(shm::SharedMemory, args...) = read(shm.pool.memory, args...)

mutable struct Buffer{T} <: Handle
  handle::Ptr{wl_buffer}
  memory::T
  function Buffer(shm::SharedMemory, offset, width, height, stride, format::WlShmFormat)
    h = wl_shm_pool_create_buffer(shm.pool, C_NULL, offset, width, height, stride, format)
    buffer = new{SharedMemory}(h, shm)
    finalizer(wl_buffer_destroy, buffer)
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
  wl_surface_damage(surface, offset..., something.(extent, typemax(Int32))...)
  surface
end
function commit(surface::Surface)
  wl_surface_commit(surface)
  surface
end
