@testset "Interfaces" begin
  @testset "Slot-based interface setup" begin
    interface_ptrs = Base.unsafe_wrap(Array, Wayland.interface_slots[], Wayland.n)
    @test count(==(C_NULL), interface_ptrs) > 50
    @test count(≠(C_NULL), interface_ptrs) > 45
    @test findfirst(==(C_NULL), interface_ptrs) == 4
    @test interface_ptrs[7] == C_NULL
    @test interface_ptrs[8] ≠ C_NULL
  end

  @testset "Listeners" begin
    l = wl_registry_listener(C_NULL, C_NULL)
    @test isa(l, wl_registry_listener)
  end

  @testset "Integrity of interfaces" begin
    i = findfirst(x -> unsafe_string(x[].name) == "wl_compositor", Wayland.interface_structs)
    itf_ref = Wayland.interface_structs[i]
    itf = unsafe_load(Wayland.interface_dict[:wl_compositor])
    @test itf == itf_ref[]
    @test itf.method_count == 2
    requests = unsafe_wrap(Array, itf.methods, itf.method_count)
    req = requests[1]
    name, sig, t = unsafe_string(req.name), unsafe_string(req.signature), unsafe_load(Ptr{Ptr{wl_interface}}(req.types))
    @test name == "create_surface"
    @test sig == "n"
    @test t != C_NULL && unsafe_string(unsafe_load(t).name) == "wl_surface"
  end
end;
