using Wayland, Test
const WL = Wayland

ENV["JULIA_DEBUG"] = "Wayland"
ENV["JULIA_DEBUG"] = ""

# ENV["WAYLAND_DISPLAY"] = "wayland-1"

@testset "Wayland.jl" begin
  include("interfaces.jl")
  include("server.jl")
  include("client.jl") # make sure that a server is running somewhere.
end;
