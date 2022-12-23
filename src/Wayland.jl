module Wayland

using Reexport

include("LibWayland.jl")
@reexport using .LibWayland

using WindowAbstractions

include("handles.jl")
include("wrappers.jl")
include("interfaces.jl")
include("requests.jl")
include("server.jl")
include("client.jl")

function __init__()
  for ref in wayland_interface_refs
    push!(wayland_interface_ptrs, Base.unsafe_convert(Ptr{wl_interface}, ref))
  end
  wayland_interfaces[] = pointer(wayland_interface_ptrs)

  fill_interfaces!!(wayland_interface_refs, wayland_interface_structs)
end

export LibWayland,
  # Server-side functionality
  ServerDisplay, add_socket,

  # Client-side functionality
  Display

end
