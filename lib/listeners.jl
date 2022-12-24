Base.@kwdef struct wl_display_listener
        error::FPtr = @cfunction(((display, object_id, code, message)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, UInt32, Ptr{Cchar}))
        delete_id::FPtr = @cfunction(((display, id)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
    end

Base.@kwdef struct wl_registry_listener
        _global::FPtr = @cfunction(((registry, name, interface, version)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cchar}, UInt32))
        global_remove::FPtr = @cfunction(((registry, name)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
    end

Base.@kwdef struct wl_callback_listener
        done::FPtr = @cfunction(((callback, callback_data)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
    end

Base.@kwdef struct wl_shm_listener
        format::FPtr = @cfunction(((shm, format)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
    end

Base.@kwdef struct wl_buffer_listener
        release::FPtr = @cfunction((buffer->nothing), Cvoid, (Ptr{Cvoid},))
    end

Base.@kwdef struct wl_data_offer_listener
        offer::FPtr = @cfunction(((data_offer, mime_type)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cchar}))
        source_actions::FPtr = @cfunction(((data_offer, source_actions)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
        action::FPtr = @cfunction(((data_offer, dnd_action)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
    end

Base.@kwdef struct wl_data_source_listener
        target::FPtr = @cfunction(((data_source, mime_type)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cchar}))
        send::FPtr = @cfunction(((data_source, mime_type, fd)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Int32))
        cancelled::FPtr = @cfunction((data_source->nothing), Cvoid, (Ptr{Cvoid},))
        dnd_drop_performed::FPtr = @cfunction((data_source->nothing), Cvoid, (Ptr{Cvoid},))
        dnd_finished::FPtr = @cfunction((data_source->nothing), Cvoid, (Ptr{Cvoid},))
        action::FPtr = @cfunction(((data_source, dnd_action)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
    end

Base.@kwdef struct wl_data_device_listener
        data_offer::FPtr = @cfunction(((data_device, id)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))
        enter::FPtr = @cfunction(((data_device, serial, surface, x, y, id)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t, Ptr{Cvoid}))
        leave::FPtr = @cfunction((data_device->nothing), Cvoid, (Ptr{Cvoid},))
        motion::FPtr = @cfunction(((data_device, time, x, y)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t))
        drop::FPtr = @cfunction((data_device->nothing), Cvoid, (Ptr{Cvoid},))
        selection::FPtr = @cfunction(((data_device, id)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))
    end

Base.@kwdef struct wl_shell_surface_listener
        ping::FPtr = @cfunction(((shell_surface, serial)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
        configure::FPtr = @cfunction(((shell_surface, edges, width, height)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Int32, Int32))
        popup_done::FPtr = @cfunction((shell_surface->nothing), Cvoid, (Ptr{Cvoid},))
    end

Base.@kwdef struct wl_surface_listener
        enter::FPtr = @cfunction(((surface, output)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))
        leave::FPtr = @cfunction(((surface, output)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}))
    end

Base.@kwdef struct wl_seat_listener
        capabilities::FPtr = @cfunction(((seat, capabilities)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
        name::FPtr = @cfunction(((seat, name)->nothing), Cvoid, (Ptr{Cvoid}, Ptr{Cchar}))
    end

Base.@kwdef struct wl_pointer_listener
        enter::FPtr = @cfunction(((pointer, serial, surface, surface_x, surface_y)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}, wl_fixed_t, wl_fixed_t))
        leave::FPtr = @cfunction(((pointer, serial, surface)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}))
        motion::FPtr = @cfunction(((pointer, time, surface_x, surface_y)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, wl_fixed_t, wl_fixed_t))
        button::FPtr = @cfunction(((pointer, serial, time, button, state)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32))
        axis::FPtr = @cfunction(((pointer, time, axis, value)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, UInt32, wl_fixed_t))
        frame::FPtr = @cfunction((pointer->nothing), Cvoid, (Ptr{Cvoid},))
        axis_source::FPtr = @cfunction(((pointer, axis_source)->nothing), Cvoid, (Ptr{Cvoid}, UInt32))
        axis_stop::FPtr = @cfunction(((pointer, time, axis)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, UInt32))
        axis_discrete::FPtr = @cfunction(((pointer, axis, discrete)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Int32))
    end

Base.@kwdef struct wl_keyboard_listener
        keymap::FPtr = @cfunction(((keyboard, format, fd, size)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Int32, UInt32))
        enter::FPtr = @cfunction(((keyboard, serial, surface, keys)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}, Ptr{wl_array}))
        leave::FPtr = @cfunction(((keyboard, serial, surface)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Ptr{Cvoid}))
        key::FPtr = @cfunction(((keyboard, serial, time, key, state)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32))
        modifiers::FPtr = @cfunction(((keyboard, serial, mods_depressed, mods_latched, mods_locked, group)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, UInt32, UInt32, UInt32, UInt32))
        repeat_info::FPtr = @cfunction(((keyboard, rate, delay)->nothing), Cvoid, (Ptr{Cvoid}, Int32, Int32))
    end

Base.@kwdef struct wl_touch_listener
        down::FPtr = @cfunction(((touch, serial, time, surface, id, x, y)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, UInt32, Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t))
        up::FPtr = @cfunction(((touch, serial, time, id)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, UInt32, Int32))
        motion::FPtr = @cfunction(((touch, time, id, x, y)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Int32, wl_fixed_t, wl_fixed_t))
        frame::FPtr = @cfunction((touch->nothing), Cvoid, (Ptr{Cvoid},))
        cancel::FPtr = @cfunction((touch->nothing), Cvoid, (Ptr{Cvoid},))
        shape::FPtr = @cfunction(((touch, id, major, minor)->nothing), Cvoid, (Ptr{Cvoid}, Int32, wl_fixed_t, wl_fixed_t))
        orientation::FPtr = @cfunction(((touch, id, orientation)->nothing), Cvoid, (Ptr{Cvoid}, Int32, wl_fixed_t))
    end

Base.@kwdef struct wl_output_listener
        geometry::FPtr = @cfunction(((output, x, y, physical_width, physical_height, subpixel, make, model, transform)->nothing), Cvoid, (Ptr{Cvoid}, Int32, Int32, Int32, Int32, Int32, Ptr{Cchar}, Ptr{Cchar}, Int32))
        mode::FPtr = @cfunction(((output, flags, width, height, refresh)->nothing), Cvoid, (Ptr{Cvoid}, UInt32, Int32, Int32, Int32))
        done::FPtr = @cfunction((output->nothing), Cvoid, (Ptr{Cvoid},))
        scale::FPtr = @cfunction(((output, factor)->nothing), Cvoid, (Ptr{Cvoid}, Int32))
    end

