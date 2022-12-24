macro cfunction_wl_display_error(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cchar})))
end
macro cfunction_wl_display_delete_id(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_registry_global(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cchar}, UInt32)))
end
macro cfunction_wl_registry_global_remove(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_callback_done(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_shm_format(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_buffer_release(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_data_offer_offer(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cchar})))
end
macro cfunction_wl_data_offer_source_actions(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_data_offer_action(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_data_source_target(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cchar})))
end
macro cfunction_wl_data_source_send(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Int32)))
end
macro cfunction_wl_data_source_cancelled(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_data_source_dnd_drop_performed(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_data_source_dnd_finished(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_data_source_action(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_data_device_data_offer(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_device_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t, Ptr{Cvoid})))
end
macro cfunction_wl_data_device_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_data_device_motion(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_data_device_drop(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_data_device_selection(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_shell_surface_ping(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_shell_surface_configure(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Int32, Int32)))
end
macro cfunction_wl_shell_surface_popup_done(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_surface_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_surface_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_seat_capabilities(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_seat_name(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cchar})))
end
macro cfunction_wl_pointer_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_pointer_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid})))
end
macro cfunction_wl_pointer_motion(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_pointer_button(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32)))
end
macro cfunction_wl_pointer_axis(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, UInt32, wl_fixed_t)))
end
macro cfunction_wl_pointer_frame(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_pointer_axis_source(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_pointer_axis_stop(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, UInt32)))
end
macro cfunction_wl_pointer_axis_discrete(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Int32)))
end
macro cfunction_wl_keyboard_keymap(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Int32, UInt32)))
end
macro cfunction_wl_keyboard_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}, Ptr{wl_array})))
end
macro cfunction_wl_keyboard_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid})))
end
macro cfunction_wl_keyboard_key(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32)))
end
macro cfunction_wl_keyboard_modifiers(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32, UInt32)))
end
macro cfunction_wl_keyboard_repeat_info(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Int32, Int32)))
end
macro cfunction_wl_touch_down(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, UInt32, Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_touch_up(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, UInt32, Int32)))
end
macro cfunction_wl_touch_motion(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Int32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_touch_frame(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_touch_cancel(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_touch_shape(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_touch_orientation(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Int32, wl_fixed_t)))
end
macro cfunction_wl_output_geometry(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Int32, Int32, Int32, Int32, Int32, Ptr{Cchar}, Ptr{Cchar}, Int32)))
end
macro cfunction_wl_output_mode(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, UInt32, Int32, Int32, Int32)))
end
macro cfunction_wl_output_done(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid},)))
end
macro cfunction_wl_output_scale(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Int32)))
end

Base.@kwdef struct wl_display_listener
        error::FPtr = @cfunction_wl_display_error(((display, object_id, code, message)->nothing))
        delete_id::FPtr = @cfunction_wl_display_delete_id(((display, id)->nothing))
    end

Base.@kwdef struct wl_registry_listener
        _global::FPtr = @cfunction_wl_registry_global(((registry, name, interface, version)->nothing))
        global_remove::FPtr = @cfunction_wl_registry_global_remove(((registry, name)->nothing))
    end

Base.@kwdef struct wl_callback_listener
        done::FPtr = @cfunction_wl_callback_done(((callback, callback_data)->nothing))
    end

Base.@kwdef struct wl_shm_listener
        format::FPtr = @cfunction_wl_shm_format(((shm, format)->nothing))
    end

Base.@kwdef struct wl_buffer_listener
        release::FPtr = @cfunction_wl_buffer_release((buffer->nothing))
    end

Base.@kwdef struct wl_data_offer_listener
        offer::FPtr = @cfunction_wl_data_offer_offer(((data_offer, mime_type)->nothing))
        source_actions::FPtr = @cfunction_wl_data_offer_source_actions(((data_offer, source_actions)->nothing))
        action::FPtr = @cfunction_wl_data_offer_action(((data_offer, dnd_action)->nothing))
    end

Base.@kwdef struct wl_data_source_listener
        target::FPtr = @cfunction_wl_data_source_target(((data_source, mime_type)->nothing))
        send::FPtr = @cfunction_wl_data_source_send(((data_source, mime_type, fd)->nothing))
        cancelled::FPtr = @cfunction_wl_data_source_cancelled((data_source->nothing))
        dnd_drop_performed::FPtr = @cfunction_wl_data_source_dnd_drop_performed((data_source->nothing))
        dnd_finished::FPtr = @cfunction_wl_data_source_dnd_finished((data_source->nothing))
        action::FPtr = @cfunction_wl_data_source_action(((data_source, dnd_action)->nothing))
    end

Base.@kwdef struct wl_data_device_listener
        data_offer::FPtr = @cfunction_wl_data_device_data_offer(((data_device, id)->nothing))
        enter::FPtr = @cfunction_wl_data_device_enter(((data_device, serial, surface, x, y, id)->nothing))
        leave::FPtr = @cfunction_wl_data_device_leave((data_device->nothing))
        motion::FPtr = @cfunction_wl_data_device_motion(((data_device, time, x, y)->nothing))
        drop::FPtr = @cfunction_wl_data_device_drop((data_device->nothing))
        selection::FPtr = @cfunction_wl_data_device_selection(((data_device, id)->nothing))
    end

Base.@kwdef struct wl_shell_surface_listener
        ping::FPtr = @cfunction_wl_shell_surface_ping(((shell_surface, serial)->nothing))
        configure::FPtr = @cfunction_wl_shell_surface_configure(((shell_surface, edges, width, height)->nothing))
        popup_done::FPtr = @cfunction_wl_shell_surface_popup_done((shell_surface->nothing))
    end

Base.@kwdef struct wl_surface_listener
        enter::FPtr = @cfunction_wl_surface_enter(((surface, output)->nothing))
        leave::FPtr = @cfunction_wl_surface_leave(((surface, output)->nothing))
    end

Base.@kwdef struct wl_seat_listener
        capabilities::FPtr = @cfunction_wl_seat_capabilities(((seat, capabilities)->nothing))
        name::FPtr = @cfunction_wl_seat_name(((seat, name)->nothing))
    end

Base.@kwdef struct wl_pointer_listener
        enter::FPtr = @cfunction_wl_pointer_enter(((pointer, serial, surface, surface_x, surface_y)->nothing))
        leave::FPtr = @cfunction_wl_pointer_leave(((pointer, serial, surface)->nothing))
        motion::FPtr = @cfunction_wl_pointer_motion(((pointer, time, surface_x, surface_y)->nothing))
        button::FPtr = @cfunction_wl_pointer_button(((pointer, serial, time, button, state)->nothing))
        axis::FPtr = @cfunction_wl_pointer_axis(((pointer, time, axis, value)->nothing))
        frame::FPtr = @cfunction_wl_pointer_frame((pointer->nothing))
        axis_source::FPtr = @cfunction_wl_pointer_axis_source(((pointer, axis_source)->nothing))
        axis_stop::FPtr = @cfunction_wl_pointer_axis_stop(((pointer, time, axis)->nothing))
        axis_discrete::FPtr = @cfunction_wl_pointer_axis_discrete(((pointer, axis, discrete)->nothing))
    end

Base.@kwdef struct wl_keyboard_listener
        keymap::FPtr = @cfunction_wl_keyboard_keymap(((keyboard, format, fd, size)->nothing))
        enter::FPtr = @cfunction_wl_keyboard_enter(((keyboard, serial, surface, keys)->nothing))
        leave::FPtr = @cfunction_wl_keyboard_leave(((keyboard, serial, surface)->nothing))
        key::FPtr = @cfunction_wl_keyboard_key(((keyboard, serial, time, key, state)->nothing))
        modifiers::FPtr = @cfunction_wl_keyboard_modifiers(((keyboard, serial, mods_depressed, mods_latched, mods_locked, group)->nothing))
        repeat_info::FPtr = @cfunction_wl_keyboard_repeat_info(((keyboard, rate, delay)->nothing))
    end

Base.@kwdef struct wl_touch_listener
        down::FPtr = @cfunction_wl_touch_down(((touch, serial, time, surface, id, x, y)->nothing))
        up::FPtr = @cfunction_wl_touch_up(((touch, serial, time, id)->nothing))
        motion::FPtr = @cfunction_wl_touch_motion(((touch, time, id, x, y)->nothing))
        frame::FPtr = @cfunction_wl_touch_frame((touch->nothing))
        cancel::FPtr = @cfunction_wl_touch_cancel((touch->nothing))
        shape::FPtr = @cfunction_wl_touch_shape(((touch, id, major, minor)->nothing))
        orientation::FPtr = @cfunction_wl_touch_orientation(((touch, id, orientation)->nothing))
    end

Base.@kwdef struct wl_output_listener
        geometry::FPtr = @cfunction_wl_output_geometry(((output, x, y, physical_width, physical_height, subpixel, make, model, transform)->nothing))
        mode::FPtr = @cfunction_wl_output_mode(((output, flags, width, height, refresh)->nothing))
        done::FPtr = @cfunction_wl_output_done((output->nothing))
        scale::FPtr = @cfunction_wl_output_scale(((output, factor)->nothing))
    end

