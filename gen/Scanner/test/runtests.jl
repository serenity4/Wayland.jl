using Scanner, Test
using Scanner: construct, signature, construct_interfaces, null_indices, generate_opcodes, generate_enum, remove_linenums!

@testset "Scanner.jl" begin
  itf = Interface("wl_display")
  @test length(itf.enums) == 1
  @test length(itf.requests) == 2
  @test length(itf.events) == 2
  @test !isnothing(itf.description)
  @test itf.version == 1

  @test signature(Interface("wl_surface")["damage_buffer"]) == "4iiii"
  @test signature(Interface("wl_pointer")["set_cursor"]) == "u?oii"
  @test construct(Interface("wl_display")["sync"], 8) == :(Message("sync", "n", getptr(wayland_interfaces[], 8)))
  itf = Interface("wl_display")
  @test construct(itf, Dict(itf["sync"] => 0, itf["get_registry"] => 1, itf["error"] => 2, itf["delete_id"] => 5)) == :(Interface("wl_display", 1,
    Message[Message("sync", "n", getptr(wayland_interfaces[], 0)), Message("get_registry", "n", getptr(wayland_interfaces[], 1))],
    Message[Message("error", "ous", getptr(wayland_interfaces[], 2)), Message("delete_id", "u", getptr(wayland_interfaces[], 5))],
  ))

  itfs = Interface.(findall(".//interface", xroot[]))
  @test length(itfs) ≥ 22
  @test sum(itf -> length(itf.requests), itfs) ≥ 64
  @test sum(itf -> length(itf.events), itfs) ≥ 55
  @test sum(itf -> length(itf.enums), itfs) ≥ 25

  indices = null_indices(itfs)
  @test indices[1:5] == [4, 5, 6, 7, 9]

  ex = construct_interfaces(itfs)
  @test Meta.isexpr(ex, :function)

  opcodes = generate_opcodes(itfs)
  @test opcodes[117] == :(const WL_SUBSURFACE_PLACE_BELOW = 3)

  @test generate_enum(itfs[6]["error"], "wl_display") == remove_linenums!(:(@enum WlDisplayError::Int32 begin
      WL_DISPLAY_INVALID_FORMAT = 0
      WL_DISPLAY_INVALID_STRIDE = 1
      WL_DISPLAY_INVALID_FD = 2
  end))

  @test generate_enum(itfs[15]["capability"], "wl_seat") == remove_linenums!(:(@bitmask WlSeatCapability::UInt32 begin
      WL_SEAT_POINTER = 1
      WL_SEAT_KEYBOARD = 2
      WL_SEAT_TOUCH = 4
  end))
end;
