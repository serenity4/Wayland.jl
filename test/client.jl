@testset "Wayland Client" begin
  @test_throws "No connection could be established" Display("no-display")
  dpy = Display()
  registry = Registry(dpy)
  @test !isempty(registry.globals)
  @test haskey(registry.globals, :wl_compositor)
  compositor = Compositor(registry)
  surface = Surface(compositor)
  width = 1920
  height = 1080
  pixel_size = 32 # 4 8-bit RGBA values
  buffering = 2 # double buffering
  size = width * height * pixel_size * buffering
  shm = SharedMemory(registry, size)
  # These two formats are required to be supported.
  @test issubset([WL_SHM_ARGB8888, WL_SHM_XRGB8888], shm.supported_formats)
  stride = width * pixel_size * buffering
  format = WL_SHM_XRGB8888
  buffer = Buffer(shm, 0, width, height, stride, format)
  attach(buffer, surface)
  write(buffer, fill(0xffbb00ff, size))
  commit(damage(surface))
  finalize(shm.pool)
  finalize(buffer)
  finalize(dpy)
end;
