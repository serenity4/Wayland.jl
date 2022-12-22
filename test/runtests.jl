using Wayland, Test

ENV["JULIA_DEBUG"] = "Wayland"
ENV["JULIA_DEBUG"] = ""

@testset "Wayland.jl" begin
    @test true
end;
