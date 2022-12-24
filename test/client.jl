function on_advertised_global(data, registry, name, interface::Ptr{Cchar}, version)
  interface = interface ≠ C_NULL ? unsafe_string(interface) : nothing
  @debug "Interface: $interface, version: $version, name: $name"
end

@testset "Wayland Client" begin
  @test_throws "No connection could be established" Display("no-display")
  dpy = Display()
  registry = wl_display_get_registry(dpy, C_NULL)
  @test registry ≠ C_NULL
  wl_proxy_add_listener(registry, wl_registry_listener(_global = @cfunction_wl_registry_global(on_advertised_global)), C_NULL)
  wl_display_roundtrip(dpy)
  finalize(dpy)
end;
