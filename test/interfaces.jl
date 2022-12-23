@testset "Interfaces" begin
  interface_ptrs = Base.unsafe_wrap(Array, Wayland.wayland_interfaces[], Wayland.n)
  @test count(==(C_NULL), interface_ptrs) > 50
  @test count(≠(C_NULL), interface_ptrs) > 45
end;
