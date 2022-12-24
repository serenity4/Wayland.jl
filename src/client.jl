mutable struct Display <: Handle
  handle::Ptr{wl_display}
  function Display(socket = nothing)
    handle = wl_display_connect(something(socket, C_NULL))
    handle ≠ C_NULL || error("No connection could be established to a wayland display on", isnothing(socket) ? " the default socket" : " socket $socket")
    display = new(handle)
    finalizer(wl_display_disconnect, display)
  end
end

function synchronize(dpy::Display)
  n = wl_display_roundtrip(dpy)
  n == -1 && error("An error occurred while synchronizing with the server.")
  !iszero(n) && @debug "$n events were dispatched by the server during the synchronization."
  n
end

function barrier(dpy::Display)
  wl_display_sync(dpy, C_NULL)
  nothing
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
  globals::Dict{Symbol, Global}
  dpy::Display
  function Registry(dpy::Display)
    handle = wl_display_get_registry(dpy, C_NULL)
    handle ≠ C_NULL || error("Failed to obtain the global registry")
    registry = new(handle, Dict{Symbol, Global}(), dpy)
    listener = wl_registry_listener(
      _global = @cfunction_wl_registry_global(on_global),
      global_remove = @cfunction_wl_registry_global_remove(on_global_remove),
    )
    wl_proxy_add_listener(registry, listener, pointer_from_objref(registry))
    synchronize(dpy) # wait for globals to be filled in
    registry # make sure to keep it alive as long as the listener is active
  end
end

function Base.bind(registry::Registry, gname::Symbol, version = nothing)
  g = get(registry.globals, gname, nothing)
  isnothing(g) && return error("The global named \"$gname\" is not available")
  wl_registry_bind(registry, g.id, interface_dict[gname], something(version, g.version))
end

mutable struct Compositor <: Handle
  handle::Ptr{wl_compositor}
  Compositor(registry::Registry, version = nothing) = new(bind(registry, :wl_compositor, version))
end

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

mutable struct SharedMemory <: Handle
  handle::Ptr{wl_shm}
  supported_formats::Vector{WlShmFormat}
  function SharedMemory(registry::Registry, version = nothing)
    shm = new(bind(registry, :wl_shm, version), WlShmFormat[])
    wl_proxy_add_listener(shm, wl_shm_listener(format = @cfunction_wl_shm_format(on_format)), pointer_from_objref(shm))
    synchronize(registry.dpy) # wait for formats to be filled in
    shm
  end
end
