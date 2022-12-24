const WL_DISPLAY_SYNC = 0
const WL_DISPLAY_GET_REGISTRY = 1
const WL_DISPLAY_ERROR = 2
const WL_DISPLAY_DELETE_ID = 3
function wl_display_sync(display, callback)
    @ccall libwayland_client.wl_proxy_marshal_constructor(display::Ptr{Cvoid}, WL_DISPLAY_SYNC::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}; callback::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_display_get_registry(display, registry)
    @ccall libwayland_client.wl_proxy_marshal_constructor(display::Ptr{Cvoid}, WL_DISPLAY_GET_REGISTRY::UInt32, Wayland.wayland_interface_ptrs[2]::Ptr{wl_interface}; registry::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_REGISTRY_BIND = 0
const WL_REGISTRY_GLOBAL = 1
const WL_REGISTRY_GLOBAL_REMOVE = 2
function wl_registry_bind(registry, name, id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(registry::Ptr{Cvoid}, WL_REGISTRY_BIND::UInt32, Wayland.wayland_interface_ptrs[7]::Ptr{wl_interface}; name::UInt32, id::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_CALLBACK_DONE = 0
const WL_COMPOSITOR_CREATE_SURFACE = 0
const WL_COMPOSITOR_CREATE_REGION = 1
function wl_compositor_create_surface(compositor, id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(compositor::Ptr{Cvoid}, WL_COMPOSITOR_CREATE_SURFACE::UInt32, Wayland.wayland_interface_ptrs[14]::Ptr{wl_interface}; id::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_compositor_create_region(compositor, id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(compositor::Ptr{Cvoid}, WL_COMPOSITOR_CREATE_REGION::UInt32, Wayland.wayland_interface_ptrs[15]::Ptr{wl_interface}; id::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_SHM_POOL_CREATE_BUFFER = 0
const WL_SHM_POOL_DESTROY = 1
const WL_SHM_POOL_RESIZE = 2
function wl_shm_pool_create_buffer(shm_pool, id, offset, width, height, stride, format)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm_pool::Ptr{Cvoid}, WL_SHM_POOL_CREATE_BUFFER::UInt32, Wayland.wayland_interface_ptrs[16]::Ptr{wl_interface}; id::Ptr{Cvoid}, offset::Int32, width::Int32, height::Int32, stride::Int32, format::UInt32)::Ptr{Cvoid}
end

function wl_shm_pool_destroy(shm_pool)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm_pool::Ptr{Cvoid}, WL_SHM_POOL_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_shm_pool_resize(shm_pool, size)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm_pool::Ptr{Cvoid}, WL_SHM_POOL_RESIZE::UInt32, Wayland.wayland_interface_ptrs[22]::Ptr{wl_interface}; size::Int32)::Ptr{Cvoid}
end

const WL_SHM_CREATE_POOL = 0
const WL_SHM_FORMAT = 1
function wl_shm_create_pool(shm, id, fd, size)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm::Ptr{Cvoid}, WL_SHM_CREATE_POOL::UInt32, Wayland.wayland_interface_ptrs[23]::Ptr{wl_interface}; id::Ptr{Cvoid}, fd::Int32, size::Int32)::Ptr{Cvoid}
end

const WL_BUFFER_DESTROY = 0
const WL_BUFFER_RELEASE = 1
function wl_buffer_destroy(buffer)
    @ccall libwayland_client.wl_proxy_marshal_constructor(buffer::Ptr{Cvoid}, WL_BUFFER_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

const WL_DATA_OFFER_ACCEPT = 0
const WL_DATA_OFFER_RECEIVE = 1
const WL_DATA_OFFER_DESTROY = 2
const WL_DATA_OFFER_FINISH = 3
const WL_DATA_OFFER_SET_ACTIONS = 4
const WL_DATA_OFFER_OFFER = 5
const WL_DATA_OFFER_SOURCE_ACTIONS = 6
const WL_DATA_OFFER_ACTION = 7
function wl_data_offer_accept(data_offer, serial, mime_type)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_ACCEPT::UInt32, Wayland.wayland_interface_ptrs[27]::Ptr{wl_interface}; serial::UInt32, mime_type::Ptr{Cchar})::Ptr{Cvoid}
end

function wl_data_offer_receive(data_offer, mime_type, fd)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_RECEIVE::UInt32, Wayland.wayland_interface_ptrs[29]::Ptr{wl_interface}; mime_type::Ptr{Cchar}, fd::Int32)::Ptr{Cvoid}
end

function wl_data_offer_destroy(data_offer)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_data_offer_finish(data_offer)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_FINISH::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}, 0x00000003::UInt32)::Ptr{Cvoid}
end

function wl_data_offer_set_actions(data_offer, dnd_actions, preferred_action)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_SET_ACTIONS::UInt32, Wayland.wayland_interface_ptrs[31]::Ptr{wl_interface}, 0x00000003::UInt32; dnd_actions::UInt32, preferred_action::UInt32)::Ptr{Cvoid}
end

const WL_DATA_SOURCE_OFFER = 0
const WL_DATA_SOURCE_DESTROY = 1
const WL_DATA_SOURCE_SET_ACTIONS = 2
const WL_DATA_SOURCE_TARGET = 3
const WL_DATA_SOURCE_SEND = 4
const WL_DATA_SOURCE_CANCELLED = 5
const WL_DATA_SOURCE_DND_DROP_PERFORMED = 6
const WL_DATA_SOURCE_DND_FINISHED = 7
const WL_DATA_SOURCE_ACTION = 8
function wl_data_source_offer(data_source, mime_type)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_source::Ptr{Cvoid}, WL_DATA_SOURCE_OFFER::UInt32, Wayland.wayland_interface_ptrs[36]::Ptr{wl_interface}; mime_type::Ptr{Cchar})::Ptr{Cvoid}
end

function wl_data_source_destroy(data_source)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_source::Ptr{Cvoid}, WL_DATA_SOURCE_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_data_source_set_actions(data_source, dnd_actions)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(data_source::Ptr{Cvoid}, WL_DATA_SOURCE_SET_ACTIONS::UInt32, Wayland.wayland_interface_ptrs[37]::Ptr{wl_interface}, 0x00000003::UInt32; dnd_actions::UInt32)::Ptr{Cvoid}
end

const WL_DATA_DEVICE_START_DRAG = 0
const WL_DATA_DEVICE_SET_SELECTION = 1
const WL_DATA_DEVICE_RELEASE = 2
const WL_DATA_DEVICE_DATA_OFFER = 3
const WL_DATA_DEVICE_ENTER = 4
const WL_DATA_DEVICE_LEAVE = 5
const WL_DATA_DEVICE_MOTION = 6
const WL_DATA_DEVICE_DROP = 7
const WL_DATA_DEVICE_SELECTION = 8
function wl_data_device_start_drag(data_device, source, origin, icon, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device::Ptr{Cvoid}, WL_DATA_DEVICE_START_DRAG::UInt32, Wayland.wayland_interface_ptrs[42]::Ptr{wl_interface}; source::Ptr{Cvoid}, origin::Ptr{Cvoid}, icon::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function wl_data_device_set_selection(data_device, source, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device::Ptr{Cvoid}, WL_DATA_DEVICE_SET_SELECTION::UInt32, Wayland.wayland_interface_ptrs[46]::Ptr{wl_interface}; source::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function wl_data_device_release(data_device)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(data_device::Ptr{Cvoid}, WL_DATA_DEVICE_RELEASE::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}, 0x00000002::UInt32)::Ptr{Cvoid}
end

const WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE = 0
const WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE = 1
function wl_data_device_manager_create_data_source(data_device_manager, id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device_manager::Ptr{Cvoid}, WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE::UInt32, Wayland.wayland_interface_ptrs[58]::Ptr{wl_interface}; id::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_data_device_manager_get_data_device(data_device_manager, id, seat)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device_manager::Ptr{Cvoid}, WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE::UInt32, Wayland.wayland_interface_ptrs[59]::Ptr{wl_interface}; id::Ptr{Cvoid}, seat::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_SHELL_GET_SHELL_SURFACE = 0
function wl_shell_get_shell_surface(shell, id, surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell::Ptr{Cvoid}, WL_SHELL_GET_SHELL_SURFACE::UInt32, Wayland.wayland_interface_ptrs[61]::Ptr{wl_interface}; id::Ptr{Cvoid}, surface::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_SHELL_SURFACE_PONG = 0
const WL_SHELL_SURFACE_MOVE = 1
const WL_SHELL_SURFACE_RESIZE = 2
const WL_SHELL_SURFACE_SET_TOPLEVEL = 3
const WL_SHELL_SURFACE_SET_TRANSIENT = 4
const WL_SHELL_SURFACE_SET_FULLSCREEN = 5
const WL_SHELL_SURFACE_SET_POPUP = 6
const WL_SHELL_SURFACE_SET_MAXIMIZED = 7
const WL_SHELL_SURFACE_SET_TITLE = 8
const WL_SHELL_SURFACE_SET_CLASS = 9
const WL_SHELL_SURFACE_PING = 10
const WL_SHELL_SURFACE_CONFIGURE = 11
const WL_SHELL_SURFACE_POPUP_DONE = 12
function wl_shell_surface_pong(shell_surface, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_PONG::UInt32, Wayland.wayland_interface_ptrs[63]::Ptr{wl_interface}; serial::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_move(shell_surface, seat, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_MOVE::UInt32, Wayland.wayland_interface_ptrs[64]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_resize(shell_surface, seat, serial, edges)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_RESIZE::UInt32, Wayland.wayland_interface_ptrs[66]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32, edges::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_set_toplevel(shell_surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_TOPLEVEL::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_shell_surface_set_transient(shell_surface, parent, x, y, flags)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_TRANSIENT::UInt32, Wayland.wayland_interface_ptrs[69]::Ptr{wl_interface}; parent::Ptr{Cvoid}, x::Int32, y::Int32, flags::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_set_fullscreen(shell_surface, method, framerate, output)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_FULLSCREEN::UInt32, Wayland.wayland_interface_ptrs[73]::Ptr{wl_interface}; method::UInt32, framerate::UInt32, output::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_shell_surface_set_popup(shell_surface, seat, serial, parent, x, y, flags)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_POPUP::UInt32, Wayland.wayland_interface_ptrs[76]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32, parent::Ptr{Cvoid}, x::Int32, y::Int32, flags::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_set_maximized(shell_surface, output)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_MAXIMIZED::UInt32, Wayland.wayland_interface_ptrs[82]::Ptr{wl_interface}; output::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_shell_surface_set_title(shell_surface, title)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_TITLE::UInt32, Wayland.wayland_interface_ptrs[83]::Ptr{wl_interface}; title::Ptr{Cchar})::Ptr{Cvoid}
end

function wl_shell_surface_set_class(shell_surface, class_)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_CLASS::UInt32, Wayland.wayland_interface_ptrs[84]::Ptr{wl_interface}; class_::Ptr{Cchar})::Ptr{Cvoid}
end

const WL_SURFACE_DESTROY = 0
const WL_SURFACE_ATTACH = 1
const WL_SURFACE_DAMAGE = 2
const WL_SURFACE_FRAME = 3
const WL_SURFACE_SET_OPAQUE_REGION = 4
const WL_SURFACE_SET_INPUT_REGION = 5
const WL_SURFACE_COMMIT = 6
const WL_SURFACE_SET_BUFFER_TRANSFORM = 7
const WL_SURFACE_SET_BUFFER_SCALE = 8
const WL_SURFACE_DAMAGE_BUFFER = 9
const WL_SURFACE_ENTER = 10
const WL_SURFACE_LEAVE = 11
function wl_surface_destroy(surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_surface_attach(surface, buffer, x, y)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_ATTACH::UInt32, Wayland.wayland_interface_ptrs[89]::Ptr{wl_interface}; buffer::Ptr{Cvoid}, x::Int32, y::Int32)::Ptr{Cvoid}
end

function wl_surface_damage(surface, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_DAMAGE::UInt32, Wayland.wayland_interface_ptrs[92]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

function wl_surface_frame(surface, callback)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_FRAME::UInt32, Wayland.wayland_interface_ptrs[96]::Ptr{wl_interface}; callback::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_surface_set_opaque_region(surface, region)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_SET_OPAQUE_REGION::UInt32, Wayland.wayland_interface_ptrs[97]::Ptr{wl_interface}; region::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_surface_set_input_region(surface, region)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_SET_INPUT_REGION::UInt32, Wayland.wayland_interface_ptrs[98]::Ptr{wl_interface}; region::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_surface_commit(surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_COMMIT::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_surface_set_buffer_transform(surface, transform)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(surface::Ptr{Cvoid}, WL_SURFACE_SET_BUFFER_TRANSFORM::UInt32, Wayland.wayland_interface_ptrs[99]::Ptr{wl_interface}, 0x00000002::UInt32; transform::Int32)::Ptr{Cvoid}
end

function wl_surface_set_buffer_scale(surface, scale)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(surface::Ptr{Cvoid}, WL_SURFACE_SET_BUFFER_SCALE::UInt32, Wayland.wayland_interface_ptrs[100]::Ptr{wl_interface}, 0x00000003::UInt32; scale::Int32)::Ptr{Cvoid}
end

function wl_surface_damage_buffer(surface, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(surface::Ptr{Cvoid}, WL_SURFACE_DAMAGE_BUFFER::UInt32, Wayland.wayland_interface_ptrs[101]::Ptr{wl_interface}, 0x00000004::UInt32; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

const WL_SEAT_GET_POINTER = 0
const WL_SEAT_GET_KEYBOARD = 1
const WL_SEAT_GET_TOUCH = 2
const WL_SEAT_RELEASE = 3
const WL_SEAT_CAPABILITIES = 4
const WL_SEAT_NAME = 5
function wl_seat_get_pointer(seat, id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(seat::Ptr{Cvoid}, WL_SEAT_GET_POINTER::UInt32, Wayland.wayland_interface_ptrs[107]::Ptr{wl_interface}; id::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_seat_get_keyboard(seat, id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(seat::Ptr{Cvoid}, WL_SEAT_GET_KEYBOARD::UInt32, Wayland.wayland_interface_ptrs[108]::Ptr{wl_interface}; id::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_seat_get_touch(seat, id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(seat::Ptr{Cvoid}, WL_SEAT_GET_TOUCH::UInt32, Wayland.wayland_interface_ptrs[109]::Ptr{wl_interface}; id::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_seat_release(seat)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(seat::Ptr{Cvoid}, WL_SEAT_RELEASE::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}, 0x00000005::UInt32)::Ptr{Cvoid}
end

const WL_POINTER_SET_CURSOR = 0
const WL_POINTER_RELEASE = 1
const WL_POINTER_ENTER = 2
const WL_POINTER_LEAVE = 3
const WL_POINTER_MOTION = 4
const WL_POINTER_BUTTON = 5
const WL_POINTER_AXIS = 6
const WL_POINTER_FRAME = 7
const WL_POINTER_AXIS_SOURCE = 8
const WL_POINTER_AXIS_STOP = 9
const WL_POINTER_AXIS_DISCRETE = 10
function wl_pointer_set_cursor(pointer, serial, surface, hotspot_x, hotspot_y)
    @ccall libwayland_client.wl_proxy_marshal_constructor(pointer::Ptr{Cvoid}, WL_POINTER_SET_CURSOR::UInt32, Wayland.wayland_interface_ptrs[112]::Ptr{wl_interface}; serial::UInt32, surface::Ptr{Cvoid}, hotspot_x::Int32, hotspot_y::Int32)::Ptr{Cvoid}
end

function wl_pointer_release(pointer)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(pointer::Ptr{Cvoid}, WL_POINTER_RELEASE::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}, 0x00000003::UInt32)::Ptr{Cvoid}
end

const WL_KEYBOARD_RELEASE = 0
const WL_KEYBOARD_KEYMAP = 1
const WL_KEYBOARD_ENTER = 2
const WL_KEYBOARD_LEAVE = 3
const WL_KEYBOARD_KEY = 4
const WL_KEYBOARD_MODIFIERS = 5
const WL_KEYBOARD_REPEAT_INFO = 6
function wl_keyboard_release(keyboard)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(keyboard::Ptr{Cvoid}, WL_KEYBOARD_RELEASE::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}, 0x00000003::UInt32)::Ptr{Cvoid}
end

const WL_TOUCH_RELEASE = 0
const WL_TOUCH_DOWN = 1
const WL_TOUCH_UP = 2
const WL_TOUCH_MOTION = 3
const WL_TOUCH_FRAME = 4
const WL_TOUCH_CANCEL = 5
const WL_TOUCH_SHAPE = 6
const WL_TOUCH_ORIENTATION = 7
function wl_touch_release(touch)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(touch::Ptr{Cvoid}, WL_TOUCH_RELEASE::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}, 0x00000003::UInt32)::Ptr{Cvoid}
end

const WL_OUTPUT_RELEASE = 0
const WL_OUTPUT_GEOMETRY = 1
const WL_OUTPUT_MODE = 2
const WL_OUTPUT_DONE = 3
const WL_OUTPUT_SCALE = 4
function wl_output_release(output)
    @ccall libwayland_client.wl_proxy_marshal_constructor_versioned(output::Ptr{Cvoid}, WL_OUTPUT_RELEASE::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface}, 0x00000003::UInt32)::Ptr{Cvoid}
end

const WL_REGION_DESTROY = 0
const WL_REGION_ADD = 1
const WL_REGION_SUBTRACT = 2
function wl_region_destroy(region)
    @ccall libwayland_client.wl_proxy_marshal_constructor(region::Ptr{Cvoid}, WL_REGION_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_region_add(region, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(region::Ptr{Cvoid}, WL_REGION_ADD::UInt32, Wayland.wayland_interface_ptrs[187]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

function wl_region_subtract(region, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(region::Ptr{Cvoid}, WL_REGION_SUBTRACT::UInt32, Wayland.wayland_interface_ptrs[191]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

const WL_SUBCOMPOSITOR_DESTROY = 0
const WL_SUBCOMPOSITOR_GET_SUBSURFACE = 1
function wl_subcompositor_destroy(subcompositor)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subcompositor::Ptr{Cvoid}, WL_SUBCOMPOSITOR_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_subcompositor_get_subsurface(subcompositor, id, surface, parent)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subcompositor::Ptr{Cvoid}, WL_SUBCOMPOSITOR_GET_SUBSURFACE::UInt32, Wayland.wayland_interface_ptrs[195]::Ptr{wl_interface}; id::Ptr{Cvoid}, surface::Ptr{Cvoid}, parent::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_SUBSURFACE_DESTROY = 0
const WL_SUBSURFACE_SET_POSITION = 1
const WL_SUBSURFACE_PLACE_ABOVE = 2
const WL_SUBSURFACE_PLACE_BELOW = 3
const WL_SUBSURFACE_SET_SYNC = 4
const WL_SUBSURFACE_SET_DESYNC = 5
function wl_subsurface_destroy(subsurface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_DESTROY::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_subsurface_set_position(subsurface, x, y)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_SET_POSITION::UInt32, Wayland.wayland_interface_ptrs[198]::Ptr{wl_interface}; x::Int32, y::Int32)::Ptr{Cvoid}
end

function wl_subsurface_place_above(subsurface, sibling)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_PLACE_ABOVE::UInt32, Wayland.wayland_interface_ptrs[200]::Ptr{wl_interface}; sibling::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_subsurface_place_below(subsurface, sibling)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_PLACE_BELOW::UInt32, Wayland.wayland_interface_ptrs[201]::Ptr{wl_interface}; sibling::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_subsurface_set_sync(subsurface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_SET_SYNC::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_subsurface_set_desync(subsurface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_SET_DESYNC::UInt32, Wayland.wayland_interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

