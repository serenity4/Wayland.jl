module Wayland

using Reexport

include("LibWayland.jl")
@reexport using .LibWayland

abstract type Handle end

Base.cconvert(::Type{Ptr{Cvoid}}, h::Handle) = h.handle

include("server.jl")
include("client.jl")

using WindowAbstractions

export LibWayland,
  # Server-side functionality
  ServerDisplay, add_socket,

  # Client-side functionality
  Display

end
