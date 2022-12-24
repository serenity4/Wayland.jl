mutable struct Display <: Handle
  handle::Ptr{wl_display}
  function Display(socket = nothing)
    handle = wl_display_connect(something(socket, C_NULL))
    handle ≠ C_NULL || error("No connection could be established to a wayland display on", isnothing(socket) ? " the default socket" : " socket $socket")
    display = new(handle)
    finalizer(wl_display_disconnect, display)
  end
end

const GlobalID = UInt32

struct Global
  id::GlobalID
  name::String
  version::Int
end

function on_global(data, registry, name, interface, version)
  registry = unsafe_pointer_to_objref(data)
  id = name
  name = interface ≠ C_NULL ? unsafe_string(interface) : ""
  g = Global(id, name, version)
  registry.globals[id] = g
  nothing
end

function on_global_remove(data, registry, id)
  registry = unsafe_pointer_to_objref(data)
  haskey(registry.globals, id) && delete!(registry.globals, id)
  nothing
end

mutable struct Registry <: Handle
  handle::Ptr{wl_registry}
  globals::Dict{GlobalID, Global}
  function Registry(dpy::Display)
    handle = wl_display_get_registry(dpy, C_NULL)
    handle ≠ C_NULL || error("Failed to obtain the global registry")
    registry = new(handle, Dict{GlobalID, Global}())
    listener = wl_registry_listener(
      _global = @cfunction_wl_registry_global(on_global),
      global_remove = @cfunction_wl_registry_global_remove(on_global_remove),
    )
    wl_proxy_add_listener(registry, listener, pointer_from_objref(registry))
    wl_display_roundtrip(dpy)
    wl_display_sync(dpy, C_NULL)
    registry # make sure to keep it alive as long as the listener is active
  end
end
