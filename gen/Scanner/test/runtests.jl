using Scanner, Test
using MacroTools: prettify
using Scanner: construct, interfaces, signature, construct_interfaces, generate_opcodes, generate_enum, generate_function, SlotInfos, generate_listener, generate_cfunction_wrapper, max_slotindex

@testset "Scanner.jl" begin
  itf = Interface("wl_display")
  @test length(itf.enums) == 1
  @test length(itf.requests) == 2
  @test length(itf.events) == 2
  @test !isnothing(itf.description)
  @test itf.version == 1

  @test signature(Interface("wl_surface")["damage_buffer"]) == "4iiii"
  @test signature(Interface("wl_pointer")["set_cursor"]) == "u?oii"
  @test signature(Interface("wl_registry")["bind"]) == "usun"

  itfs = interfaces(core_protocol())
  @test length(itfs) ≥ 22
  @test sum(itf -> length(itf.requests), itfs) ≥ 64
  @test sum(itf -> length(itf.events), itfs) ≥ 55
  @test sum(itf -> length(itf.enums), itfs) ≥ 25

  slot_infos = SlotInfos(itfs)
  @test !isempty(slot_infos.offsets)
  @test !isempty(slot_infos.slots)
  @test !isempty(slot_infos.nulls)
  @test slot_infos.nulls[1:5] == [4, 5, 6, 7, 9]
  @test haskey(slot_infos.slots, itfs[4]) # "wl_compositor"
  @test max_slotindex(slot_infos) > maximum(last, slot_infos.offsets) + 1

  @test construct(Interface("wl_display")["sync"], 8) == :(Message("sync", "n", getptr(interface_slots[], 9)))
  @test construct(itfs[1], slot_infos) == :(Interface("wl_display", 1,
    Message[Message("sync", "n", getptr(interface_slots[], 1)), Message("get_registry", "n", getptr(interface_slots[], 2))],
    Message[Message("error", "ous", getptr(interface_slots[], 3)), Message("delete_id", "u", getptr(interface_slots[], 6))],
  ))

  ex = construct_interfaces(itfs)
  @test Meta.isexpr(ex, :function)

  opcodes = generate_opcodes(itfs)
  @test opcodes[117] == :(const WL_SUBSURFACE_PLACE_BELOW = 3)

  @test generate_enum(itfs[6]["error"], "wl_display") == prettify(:(@enum WlDisplayError::Int32 begin
      WL_DISPLAY_INVALID_FORMAT = 0
      WL_DISPLAY_INVALID_STRIDE = 1
      WL_DISPLAY_INVALID_FD = 2
  end))

  @test generate_enum(itfs[15]["capability"], "wl_seat") == prettify(:(@bitmask WlSeatCapability::UInt32 begin
      WL_SEAT_POINTER = 1
      WL_SEAT_KEYBOARD = 2
      WL_SEAT_TOUCH = 4
  end))

  @test generate_function(Interface("wl_display")["sync"], Interface("wl_display"), slot_infos) == prettify(:(function wl_display_sync(display)
    @ccall libwayland_client.wl_proxy_marshal_constructor(display::Ptr{Cvoid}, WL_DISPLAY_SYNC::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
  end))

  @test generate_cfunction_wrapper(Interface("wl_registry"), Interface("wl_registry")["global"]) == prettify(:(
    macro cfunction_wl_registry_global(f) :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cchar}, UInt32))) end
  ))

  @test generate_listener(Interface("wl_registry")) == prettify(:(
    Base.@kwdef struct wl_registry_listener <: Listener
      _global::FPtr = C_NULL
      global_remove::FPtr = C_NULL
    end
  ))

  @test length(interfaces(extension_protocol("stable/presentation-time/presentation-time.xml"))) ≥ 2
  @test length(interfaces(extension_protocol("stable/xdg-shell/xdg-shell.xml"))) ≥ 5
end;
