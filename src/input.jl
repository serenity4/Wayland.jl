mutable struct Keyboard <: Handle
  handle::RefcountHandle # Ptr{wl_keyboard}
  Keyboard(seat) = new(RefcountHandle(wl_seat_get_keyboard(seat), wl_keyboard_release, seat))
end

mutable struct Pointer <: Handle
  handle::RefcountHandle # Ptr{wl_pointer}
  Pointer(seat) = new(RefcountHandle(wl_seat_get_pointer(seat), wl_pointer_release, seat))
end

mutable struct Touch <: Handle
  handle::RefcountHandle # Ptr{wl_touch}
  Touch(seat) = new(RefcountHandle(wl_seat_get_touch(seat), wl_touch_release, seat))
end

mutable struct Seat <: Handle
  handle::RefcountHandle # Ptr{wl_seat}
  registry::Registry
  capabilities::WlSeatCapability
  name::String
  keyboard::Keyboard
  pointer::Pointer
  touch::Touch
  function Seat(registry::Registry)
    h = RefcountHandle(bind(registry, :wl_seat), wl_seat_release, registry)
    seat = new(h, registry)
    on_capabilities = @cfunction_wl_seat_capabilities (data, _, capabilities) -> (retrieve_data(data, Seat).capabilities = capabilities; nothing)
    on_name = @cfunction_wl_seat_name (data, _, name) -> (retrieve_data(data, Seat).name = unsafe_string(name); nothing)
    listen(h, wl_seat_listener(on_capabilities, on_name), seat; keep_listener_alive = false)
    synchronize(registry)
    in(WL_SEAT_KEYBOARD, seat.capabilities) && (seat.keyboard = Keyboard(seat))
    in(WL_SEAT_POINTER, seat.capabilities) && (seat.pointer = Pointer(seat))
    in(WL_SEAT_TOUCH, seat.capabilities) && (seat.touch = Touch(seat))
    seat
  end
end
