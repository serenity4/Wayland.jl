@testset "Wayland Client" begin
  @test_throws "No connection could be established" Display("no-display")
  dpy = Display()
  registry = Registry(dpy)
  @test !isempty(registry.globals)
  @test haskey(registry.globals, :wl_compositor)
  compositor = Compositor(registry)
  surface = Surface(compositor)
  width = 512
  height = 512
  pixel_size = 4 # 4 8-bit RGBA values
  buffering = 2 # double buffering
  size = width * height * pixel_size * buffering
  @test haskey(registry.globals, :wl_shm)
  shm = SharedMemory(registry, size)
  # These two formats are required to be supported.
  @test issubset([WL_SHM_ARGB8888, WL_SHM_XRGB8888], shm.supported_formats)
  stride = width * pixel_size * buffering
  format = WL_SHM_XRGB8888
  buffer = Buffer(shm, 0, width, height, stride, format)
  function configure(data, _, serial)
    xdg_surface = unsafe_pointer_to_objref(data)::XdgSurface
    xdg_surface_ack_configure(xdg_surface, serial)
    seekstart(buffer.memory.pool.memory)
    write(buffer, rand((0xff0000ff, 0x00ff00ff, 0x0000ffff), size))
    commit(damage(xdg_surface.surface))
    nothing
  end
  @test haskey(registry.globals, :xdg_wm_base)
  xdg = XdgIntegration(registry, 4)
  xdg_surface = create_surface!(xdg, surface, XDG_ROLE_TOPLEVEL, configure)
  xdg_toplevel_set_title(xdg_surface.role_handle, "Example client")
  commit(surface)
  synchronize(surface)
  attach(buffer, surface)
  commit(surface)
  t0 = time()
  wl_display_dispatch(dpy)
  while time() < t0 + 1 yield() end
  finalize(shm.pool)
  finalize(buffer)
  finalize(xdg_surface)
  finalize(xdg)
  finalize(dpy)
end;
