@testset "Wayland Client" begin
  @test_throws "No connection could be established" Display("no-display")
  dpy = Display()
  registry = wl_display_get_registry(dpy, C_NULL)
  @test registry ≠ C_NULL
  finalize(dpy)
end
