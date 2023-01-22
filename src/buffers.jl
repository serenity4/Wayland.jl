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
