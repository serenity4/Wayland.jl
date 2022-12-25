macro cfunction_wl_display_error(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cchar}))))
end
macro cfunction_wl_display_delete_id(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_registry_global(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cchar}, UInt32))))
end
macro cfunction_wl_registry_global_remove(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_callback_done(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_shm_format(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_buffer_release(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_data_offer_offer(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar}))))
end
macro cfunction_wl_data_offer_source_actions(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_data_offer_action(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_data_source_target(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar}))))
end
macro cfunction_wl_data_source_send(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar}, Int32))))
end
macro cfunction_wl_data_source_cancelled(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_data_source_dnd_drop_performed(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_data_source_dnd_finished(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_data_source_action(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_data_device_data_offer(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_data_device_enter(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t, Ptr{Cvoid}))))
end
macro cfunction_wl_data_device_leave(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_data_device_motion(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t))))
end
macro cfunction_wl_data_device_drop(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_data_device_selection(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_shell_surface_ping(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_shell_surface_configure(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, Int32))))
end
macro cfunction_wl_shell_surface_popup_done(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_surface_enter(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_surface_leave(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_seat_capabilities(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_seat_name(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar}))))
end
macro cfunction_wl_pointer_enter(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t))))
end
macro cfunction_wl_pointer_leave(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}))))
end
macro cfunction_wl_pointer_motion(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t))))
end
macro cfunction_wl_pointer_button(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32))))
end
macro cfunction_wl_pointer_axis(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, wl_fixed_t))))
end
macro cfunction_wl_pointer_frame(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_pointer_axis_source(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wl_pointer_axis_stop(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32))))
end
macro cfunction_wl_pointer_axis_discrete(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32))))
end
macro cfunction_wl_keyboard_keymap(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, UInt32))))
end
macro cfunction_wl_keyboard_enter(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, Ptr{wl_array}))))
end
macro cfunction_wl_keyboard_leave(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}))))
end
macro cfunction_wl_keyboard_key(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32))))
end
macro cfunction_wl_keyboard_modifiers(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32, UInt32))))
end
macro cfunction_wl_keyboard_repeat_info(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, Int32))))
end
macro cfunction_wl_touch_down(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t))))
end
macro cfunction_wl_touch_up(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, Int32))))
end
macro cfunction_wl_touch_motion(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, wl_fixed_t, wl_fixed_t))))
end
macro cfunction_wl_touch_frame(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_touch_cancel(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_touch_shape(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t))))
end
macro cfunction_wl_touch_orientation(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, wl_fixed_t))))
end
macro cfunction_wl_output_geometry(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, Int32, Int32, Int32, Int32, Ptr{Cchar}, Ptr{Cchar}, Int32))))
end
macro cfunction_wl_output_mode(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, Int32, Int32))))
end
macro cfunction_wl_output_done(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wl_output_scale(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32))))
end
macro cfunction_wp_presentation_clock_id(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_wp_presentation_feedback_sync_output(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_wp_presentation_feedback_presented(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32))))
end
macro cfunction_wp_presentation_feedback_discarded(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_xdg_wm_base_ping(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_xdg_surface_configure(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end
macro cfunction_xdg_toplevel_configure(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, Int32, Ptr{wl_array}))))
end
macro cfunction_xdg_toplevel_close(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_xdg_toplevel_configure_bounds(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, Int32))))
end
macro cfunction_xdg_popup_configure(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, Int32, Int32, Int32))))
end
macro cfunction_xdg_popup_popup_done(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))))
end
macro cfunction_xdg_popup_repositioned(f)
    esc(:(Base.@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32))))
end

struct wl_display_listener <: Listener
    error::FPtr
    delete_id::FPtr
end

struct wl_registry_listener <: Listener
    _global::FPtr
    global_remove::FPtr
end

struct wl_callback_listener <: Listener
    done::FPtr
end

struct wl_shm_listener <: Listener
    format::FPtr
end

struct wl_buffer_listener <: Listener
    release::FPtr
end

struct wl_data_offer_listener <: Listener
    offer::FPtr
    source_actions::FPtr
    action::FPtr
end

struct wl_data_source_listener <: Listener
    target::FPtr
    send::FPtr
    cancelled::FPtr
    dnd_drop_performed::FPtr
    dnd_finished::FPtr
    action::FPtr
end

struct wl_data_device_listener <: Listener
    data_offer::FPtr
    enter::FPtr
    leave::FPtr
    motion::FPtr
    drop::FPtr
    selection::FPtr
end

struct wl_shell_surface_listener <: Listener
    ping::FPtr
    configure::FPtr
    popup_done::FPtr
end

struct wl_surface_listener <: Listener
    enter::FPtr
    leave::FPtr
end

struct wl_seat_listener <: Listener
    capabilities::FPtr
    name::FPtr
end

struct wl_pointer_listener <: Listener
    enter::FPtr
    leave::FPtr
    motion::FPtr
    button::FPtr
    axis::FPtr
    frame::FPtr
    axis_source::FPtr
    axis_stop::FPtr
    axis_discrete::FPtr
end

struct wl_keyboard_listener <: Listener
    keymap::FPtr
    enter::FPtr
    leave::FPtr
    key::FPtr
    modifiers::FPtr
    repeat_info::FPtr
end

struct wl_touch_listener <: Listener
    down::FPtr
    up::FPtr
    motion::FPtr
    frame::FPtr
    cancel::FPtr
    shape::FPtr
    orientation::FPtr
end

struct wl_output_listener <: Listener
    geometry::FPtr
    mode::FPtr
    done::FPtr
    scale::FPtr
end

struct wp_presentation_listener <: Listener
    clock_id::FPtr
end

struct wp_presentation_feedback_listener <: Listener
    sync_output::FPtr
    presented::FPtr
    discarded::FPtr
end

struct xdg_wm_base_listener <: Listener
    ping::FPtr
end

struct xdg_surface_listener <: Listener
    configure::FPtr
end

struct xdg_toplevel_listener <: Listener
    configure::FPtr
    close::FPtr
    configure_bounds::FPtr
end

struct xdg_popup_listener <: Listener
    configure::FPtr
    popup_done::FPtr
    repositioned::FPtr
end

