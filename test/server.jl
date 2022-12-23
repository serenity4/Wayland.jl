using ThreadPools

@testset "Wayland Server" begin
  dpy = ServerDisplay()
  sck = add_socket(dpy)
  @test isa(sck, String)
  sck2 = add_socket(dpy, "wayland-julia")
  @test sck2 == "wayland-julia"
  finalize(dpy)

  Threads.nthreads() > 1 || error("The emulation of both a server and a client requires a secondary thread in which to run the server.")
  sck = "wayland-julia"
  srv_dpy_ref = Ref{ServerDisplay}()
  task = @tspawnat 2 begin
    srv_dpy = ServerDisplay()
    add_socket(srv_dpy, sck)
    srv_dpy_ref[] = srv_dpy
    run(srv_dpy) # blocks until wl_display_terminate(srv_dpy_ref[]) is called from the outside.
    finalize(srv_dpy)
  end

  sleep(0.1)
  clt_dpy = Display(sck)
  finalize(clt_dpy)
  @test !istaskdone(task)
  wl_display_terminate(srv_dpy_ref[])
  sleep(0.01)
  @test istaskdone(task)
end;
