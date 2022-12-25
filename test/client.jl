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
  @test haskey(registry.globals, :wl_shm)
  shm = SharedMemory(registry, size)
  # These two formats are required to be supported.
  @test issubset([WL_SHM_ARGB8888, WL_SHM_XRGB8888], shm.supported_formats)
  stride = width * pixel_size * buffering
  format = WL_SHM_XRGB8888
  buffer = Buffer(shm, 0, width, height, stride, format)
  attach(buffer, surface)
  function configure(data, _, serial)
    xdg_surface = unsafe_pointer_to_objref(data)::XdgSurface
    @show "hello"
    sleep(0.1)
    xdg_surface_ack_configure(xdg_surface, serial)
    seekstart(buffer.memory.pool.memory)
    write(buffer, rand((0xffbb00ff, 0x00000011), size))
    commit(damage(xdg_surface.surface))
  end
  @test haskey(registry.globals, :xdg_wm_base)
  xdg = XdgIntegration(registry, 4)
  xdg_surface = create_surface!(xdg, surface, XDG_ROLE_TOPLEVEL, configure)
  xdg_toplevel_set_title(xdg_surface.role_handle, "Example client")
  commit(surface)
  t0 = time()
  while time() < t0 + 2 yield() end
  synchronize(dpy)
  finalize(shm.pool)
  finalize(buffer)
  finalize(dpy)
end;
