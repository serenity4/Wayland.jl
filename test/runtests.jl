using Wayland, Test
using Wayland: Buffer
const WL = Wayland

ENV["JULIA_DEBUG"] = "Wayland,Main"
ENV["JULIA_DEBUG"] = ""
# ENV["WAYLAND_DEBUG"] = "1"

@testset "Wayland.jl" begin
  include("interfaces.jl");
  include("client.jl"); # make sure that a server is running somewhere.
end;
