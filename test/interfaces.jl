@testset "Interfaces" begin
  @testset "Slot-based interface setup" begin
    interface_ptrs = Base.unsafe_wrap(Array, Wayland.wayland_interfaces[], Wayland.n)
    @test count(==(C_NULL), interface_ptrs) > 50
    @test count(≠(C_NULL), interface_ptrs) > 45
    @test findfirst(==(C_NULL), interface_ptrs) == 4
    @test interface_ptrs[7] == C_NULL
    @test interface_ptrs[8] ≠ C_NULL
  end

  @testset "Listeners" begin
    l = wl_registry_listener()
    @test isa(l, wl_registry_listener)
  end
end;
