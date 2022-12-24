@testset "Wayland Client" begin
  @test_throws "No connection could be established" Display("no-display")
  dpy = Display()
  registry = Registry(dpy)
  @test !isempty(registry.globals)
  @test haskey(registry.globals, :wl_compositor)
  compositor = Compositor(registry)
  synchronize(dpy)
  shm = SharedMemory(registry)
  # These two formats are required to be supported.
  @test issubset([WL_SHM_ARGB8888, WL_SHM_XRGB8888], shm.supported_formats)
  finalize(dpy)
end;
