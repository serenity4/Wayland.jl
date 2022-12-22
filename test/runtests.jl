using Wayland, Test
const WL = Wayland

ENV["JULIA_DEBUG"] = "Wayland"
ENV["JULIA_DEBUG"] = ""

# ENV["WAYLAND_DISPLAY"] = "wayland-1"

@testset "Wayland.jl" begin
    @test isa(WL.LibWayland, Module)
    display = wl_display_connect(C_NULL)
    if display == C_NULL
        @error "Could not connect to a Wayland display"
    else
        @test_broken registry = wl_display_get_registry(display)
    end
end;
