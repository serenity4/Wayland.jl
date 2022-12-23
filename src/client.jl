mutable struct Display <: Handle
  handle::Ptr{wl_display}
  function Display(socket = nothing)
    handle = wl_display_connect(something(socket, C_NULL))
    handle ≠ C_NULL || error("No connection could be established to a wayland display on", isnothing(socket) ? " the default socket" : " socket $socket")
    display = new(handle)
    finalizer(wl_display_disconnect, display)
  end
end
