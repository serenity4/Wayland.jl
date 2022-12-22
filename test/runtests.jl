using Wayland, Test
const WL = Wayland

ENV["JULIA_DEBUG"] = "Wayland"
ENV["JULIA_DEBUG"] = ""

@testset "Wayland.jl" begin
    @test isa(WL.LibWayland, Module)
end;
