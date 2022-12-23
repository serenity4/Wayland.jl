@testset "Wayland Client" begin
  @test_throws "No connection could be established" Display("no-display")
  dpy = Display()
  finalize(dpy)
end
