module Wayland

using Base: unsafe_convert
using Reexport

include("LibWayland.jl")
@reexport using .LibWayland

using WindowAbstractions

include("handles.jl")
include("wrappers.jl")
include("interfaces.jl")
include("proxy.jl")
include("requests.jl")
include("client.jl")

function __init__()
  for ref in interface_refs
    push!(interface_ptrs, unsafe_convert(Ptr{wl_interface}, ref))
  end
  interface_slots[] = unsafe_convert(Ptr{Ptr{wl_interface}}, interface_ptrs)

  fill_interfaces!!(interface_refs, interface_structs)
  empty!(interface_ptrs)
  append!(interface_ptrs, unsafe_wrap(Array, interface_slots[], n))
  fill_interface_dict!(interface_dict, interface_ptrs)
end

export LibWayland,
  Display,
  synchronize,
  Registry,
  Compositor,
  SharedMemory

end
