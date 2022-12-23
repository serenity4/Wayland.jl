mutable struct ServerDisplay <: Handle
  handle::Ptr{wl_display}
  function ServerDisplay()
    handle = wl_display_create()
    handle ≠ C_NULL || error("Could not create a display on the server")
    display = new(handle)
    finalizer(wl_display_destroy, display)
  end
end

function add_socket(display::ServerDisplay)
  socket = wl_display_add_socket_auto(display)
  socket ≠ C_NULL || error("Could not add a socket to the display")
  unsafe_string(socket)
end

function add_socket(display::ServerDisplay, name::AbstractString)
  ret = wl_display_add_socket(display, name)
  ret == 0 || error("A socket with name \"$name\" could not be added to the display")
  name
end

"""
    run(display; spawn = true)

Run the event loop of a [`ServerDisplay`](@ref).

This function is blocking at the C level, bypassing Julia's task system. The task which will receive it will freeze completely and the only way to unblock it is to call `wl_display_terminate(display)` from another thread which lets the foreign code terminate.

You should run the event loop *outside the main thread* to avoid blocking the process (unless that is the intention).
`Threads.@spawn` might still launch the task on the main thread, and is therefore unreliable as a non-blocking solution.
You can however use the lightweight [ThreadPools.jl](https://github.com/tro3/ThreadPools.jl) package and launch this function in a background thread.
"""
function Base.run(display::ServerDisplay)
  @debug "Running Wayland display on socket \"$(socket(display))\" (thread $(Threads.threadid()))"
  wl_display_run(display)
end
