macro cfunction_wl_display_error(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cchar})))
end
macro cfunction_wl_display_delete_id(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_registry_global(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cchar}, UInt32)))
end
macro cfunction_wl_registry_global_remove(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_callback_done(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_shm_format(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_buffer_release(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_offer_offer(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar})))
end
macro cfunction_wl_data_offer_source_actions(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_data_offer_action(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_data_source_target(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar})))
end
macro cfunction_wl_data_source_send(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar}, Int32)))
end
macro cfunction_wl_data_source_cancelled(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_source_dnd_drop_performed(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_source_dnd_finished(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_source_action(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_data_device_data_offer(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_device_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t, Ptr{Cvoid})))
end
macro cfunction_wl_data_device_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_device_motion(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_data_device_drop(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_data_device_selection(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_shell_surface_ping(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_shell_surface_configure(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, Int32)))
end
macro cfunction_wl_shell_surface_popup_done(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_surface_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_surface_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_seat_capabilities(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_seat_name(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cchar})))
end
macro cfunction_wl_pointer_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_pointer_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid})))
end
macro cfunction_wl_pointer_motion(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_pointer_button(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32)))
end
macro cfunction_wl_pointer_axis(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, wl_fixed_t)))
end
macro cfunction_wl_pointer_frame(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_pointer_axis_source(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32)))
end
macro cfunction_wl_pointer_axis_stop(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32)))
end
macro cfunction_wl_pointer_axis_discrete(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32)))
end
macro cfunction_wl_keyboard_keymap(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, UInt32)))
end
macro cfunction_wl_keyboard_enter(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid}, Ptr{wl_array})))
end
macro cfunction_wl_keyboard_leave(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cvoid})))
end
macro cfunction_wl_keyboard_key(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32)))
end
macro cfunction_wl_keyboard_modifiers(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32, UInt32)))
end
macro cfunction_wl_keyboard_repeat_info(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, Int32)))
end
macro cfunction_wl_touch_down(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_touch_up(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, UInt32, Int32)))
end
macro cfunction_wl_touch_motion(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_touch_frame(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_touch_cancel(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_touch_shape(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t)))
end
macro cfunction_wl_touch_orientation(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, wl_fixed_t)))
end
macro cfunction_wl_output_geometry(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32, Int32, Int32, Int32, Int32, Ptr{Cchar}, Ptr{Cchar}, Int32)))
end
macro cfunction_wl_output_mode(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Int32, Int32, Int32)))
end
macro cfunction_wl_output_done(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})))
end
macro cfunction_wl_output_scale(f)
    :(@cfunction($f, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int32)))
end

Base.@kwdef struct wl_display_listener <: Listener
        error::FPtr = C_NULL
        delete_id::FPtr = C_NULL
    end

Base.@kwdef struct wl_registry_listener <: Listener
        _global::FPtr = C_NULL
        global_remove::FPtr = C_NULL
    end

Base.@kwdef struct wl_callback_listener <: Listener
        done::FPtr = C_NULL
    end

Base.@kwdef struct wl_shm_listener <: Listener
        format::FPtr = C_NULL
    end

Base.@kwdef struct wl_buffer_listener <: Listener
        release::FPtr = C_NULL
    end

Base.@kwdef struct wl_data_offer_listener <: Listener
        offer::FPtr = C_NULL
        source_actions::FPtr = C_NULL
        action::FPtr = C_NULL
    end

Base.@kwdef struct wl_data_source_listener <: Listener
        target::FPtr = C_NULL
        send::FPtr = C_NULL
        cancelled::FPtr = C_NULL
        dnd_drop_performed::FPtr = C_NULL
        dnd_finished::FPtr = C_NULL
        action::FPtr = C_NULL
    end

Base.@kwdef struct wl_data_device_listener <: Listener
        data_offer::FPtr = C_NULL
        enter::FPtr = C_NULL
        leave::FPtr = C_NULL
        motion::FPtr = C_NULL
        drop::FPtr = C_NULL
        selection::FPtr = C_NULL
    end

Base.@kwdef struct wl_shell_surface_listener <: Listener
        ping::FPtr = C_NULL
        configure::FPtr = C_NULL
        popup_done::FPtr = C_NULL
    end

Base.@kwdef struct wl_surface_listener <: Listener
        enter::FPtr = C_NULL
        leave::FPtr = C_NULL
    end

Base.@kwdef struct wl_seat_listener <: Listener
        capabilities::FPtr = C_NULL
        name::FPtr = C_NULL
    end

Base.@kwdef struct wl_pointer_listener <: Listener
        enter::FPtr = C_NULL
        leave::FPtr = C_NULL
        motion::FPtr = C_NULL
        button::FPtr = C_NULL
        axis::FPtr = C_NULL
        frame::FPtr = C_NULL
        axis_source::FPtr = C_NULL
        axis_stop::FPtr = C_NULL
        axis_discrete::FPtr = C_NULL
    end

Base.@kwdef struct wl_keyboard_listener <: Listener
        keymap::FPtr = C_NULL
        enter::FPtr = C_NULL
        leave::FPtr = C_NULL
        key::FPtr = C_NULL
        modifiers::FPtr = C_NULL
        repeat_info::FPtr = C_NULL
    end

Base.@kwdef struct wl_touch_listener <: Listener
        down::FPtr = C_NULL
        up::FPtr = C_NULL
        motion::FPtr = C_NULL
        frame::FPtr = C_NULL
        cancel::FPtr = C_NULL
        shape::FPtr = C_NULL
        orientation::FPtr = C_NULL
    end

Base.@kwdef struct wl_output_listener <: Listener
        geometry::FPtr = C_NULL
        mode::FPtr = C_NULL
        done::FPtr = C_NULL
        scale::FPtr = C_NULL
    end

