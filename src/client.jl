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
