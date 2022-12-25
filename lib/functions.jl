const WL_DISPLAY_SYNC = 0
const WL_DISPLAY_GET_REGISTRY = 1
const WL_DISPLAY_ERROR = 2
const WL_DISPLAY_DELETE_ID = 3
function wl_display_sync(display)
    @ccall libwayland_client.wl_proxy_marshal_constructor(display::Ptr{Cvoid}, WL_DISPLAY_SYNC::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_display_get_registry(display)
    @ccall libwayland_client.wl_proxy_marshal_constructor(display::Ptr{Cvoid}, WL_DISPLAY_GET_REGISTRY::UInt32, Wayland.interface_ptrs[2]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_REGISTRY_BIND = 0
const WL_REGISTRY_GLOBAL = 1
const WL_REGISTRY_GLOBAL_REMOVE = 2
const WL_CALLBACK_DONE = 0
const WL_COMPOSITOR_CREATE_SURFACE = 0
const WL_COMPOSITOR_CREATE_REGION = 1
function wl_compositor_create_surface(compositor)
    @ccall libwayland_client.wl_proxy_marshal_constructor(compositor::Ptr{Cvoid}, WL_COMPOSITOR_CREATE_SURFACE::UInt32, Wayland.interface_ptrs[14]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_compositor_create_region(compositor)
    @ccall libwayland_client.wl_proxy_marshal_constructor(compositor::Ptr{Cvoid}, WL_COMPOSITOR_CREATE_REGION::UInt32, Wayland.interface_ptrs[15]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_SHM_POOL_CREATE_BUFFER = 0
const WL_SHM_POOL_DESTROY = 1
const WL_SHM_POOL_RESIZE = 2
function wl_shm_pool_create_buffer(shm_pool, offset, width, height, stride, format)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm_pool::Ptr{Cvoid}, WL_SHM_POOL_CREATE_BUFFER::UInt32, Wayland.interface_ptrs[16]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, offset::Int32, width::Int32, height::Int32, stride::Int32, format::UInt32)::Ptr{Cvoid}
end

function wl_shm_pool_destroy(shm_pool)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm_pool::Ptr{Cvoid}, WL_SHM_POOL_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_shm_pool_resize(shm_pool, size)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm_pool::Ptr{Cvoid}, WL_SHM_POOL_RESIZE::UInt32, Wayland.interface_ptrs[22]::Ptr{wl_interface}; size::Int32)::Ptr{Cvoid}
end

const WL_SHM_CREATE_POOL = 0
const WL_SHM_FORMAT = 1
function wl_shm_create_pool(shm, fd, size)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shm::Ptr{Cvoid}, WL_SHM_CREATE_POOL::UInt32, Wayland.interface_ptrs[23]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, fd::Int32, size::Int32)::Ptr{Cvoid}
end

const WL_BUFFER_DESTROY = 0
const WL_BUFFER_RELEASE = 1
function wl_buffer_destroy(buffer)
    @ccall libwayland_client.wl_proxy_marshal_constructor(buffer::Ptr{Cvoid}, WL_BUFFER_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
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
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_ACCEPT::UInt32, Wayland.interface_ptrs[27]::Ptr{wl_interface}; serial::UInt32, mime_type::Ptr{Cchar})::Ptr{Cvoid}
end

function wl_data_offer_receive(data_offer, mime_type, fd)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_RECEIVE::UInt32, Wayland.interface_ptrs[29]::Ptr{wl_interface}; mime_type::Ptr{Cchar}, fd::Int32)::Ptr{Cvoid}
end

function wl_data_offer_destroy(data_offer)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_data_offer_finish(data_offer)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_FINISH::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_data_offer_set_actions(data_offer, dnd_actions, preferred_action)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_offer::Ptr{Cvoid}, WL_DATA_OFFER_SET_ACTIONS::UInt32, Wayland.interface_ptrs[31]::Ptr{wl_interface}; dnd_actions::UInt32, preferred_action::UInt32)::Ptr{Cvoid}
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
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_source::Ptr{Cvoid}, WL_DATA_SOURCE_OFFER::UInt32, Wayland.interface_ptrs[36]::Ptr{wl_interface}; mime_type::Ptr{Cchar})::Ptr{Cvoid}
end

function wl_data_source_destroy(data_source)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_source::Ptr{Cvoid}, WL_DATA_SOURCE_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_data_source_set_actions(data_source, dnd_actions)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_source::Ptr{Cvoid}, WL_DATA_SOURCE_SET_ACTIONS::UInt32, Wayland.interface_ptrs[37]::Ptr{wl_interface}; dnd_actions::UInt32)::Ptr{Cvoid}
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
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device::Ptr{Cvoid}, WL_DATA_DEVICE_START_DRAG::UInt32, Wayland.interface_ptrs[42]::Ptr{wl_interface}; source::Ptr{Cvoid}, origin::Ptr{Cvoid}, icon::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function wl_data_device_set_selection(data_device, source, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device::Ptr{Cvoid}, WL_DATA_DEVICE_SET_SELECTION::UInt32, Wayland.interface_ptrs[46]::Ptr{wl_interface}; source::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function wl_data_device_release(data_device)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device::Ptr{Cvoid}, WL_DATA_DEVICE_RELEASE::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

const WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE = 0
const WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE = 1
function wl_data_device_manager_create_data_source(data_device_manager)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device_manager::Ptr{Cvoid}, WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE::UInt32, Wayland.interface_ptrs[58]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_data_device_manager_get_data_device(data_device_manager, seat)
    @ccall libwayland_client.wl_proxy_marshal_constructor(data_device_manager::Ptr{Cvoid}, WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE::UInt32, Wayland.interface_ptrs[59]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, seat::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_SHELL_GET_SHELL_SURFACE = 0
function wl_shell_get_shell_surface(shell, surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell::Ptr{Cvoid}, WL_SHELL_GET_SHELL_SURFACE::UInt32, Wayland.interface_ptrs[61]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, surface::Ptr{Cvoid})::Ptr{Cvoid}
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
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_PONG::UInt32, Wayland.interface_ptrs[63]::Ptr{wl_interface}; serial::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_move(shell_surface, seat, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_MOVE::UInt32, Wayland.interface_ptrs[64]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_resize(shell_surface, seat, serial, edges)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_RESIZE::UInt32, Wayland.interface_ptrs[66]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32, edges::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_set_toplevel(shell_surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_TOPLEVEL::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_shell_surface_set_transient(shell_surface, parent, x, y, flags)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_TRANSIENT::UInt32, Wayland.interface_ptrs[69]::Ptr{wl_interface}; parent::Ptr{Cvoid}, x::Int32, y::Int32, flags::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_set_fullscreen(shell_surface, method, framerate, output)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_FULLSCREEN::UInt32, Wayland.interface_ptrs[73]::Ptr{wl_interface}; method::UInt32, framerate::UInt32, output::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_shell_surface_set_popup(shell_surface, seat, serial, parent, x, y, flags)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_POPUP::UInt32, Wayland.interface_ptrs[76]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32, parent::Ptr{Cvoid}, x::Int32, y::Int32, flags::UInt32)::Ptr{Cvoid}
end

function wl_shell_surface_set_maximized(shell_surface, output)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_MAXIMIZED::UInt32, Wayland.interface_ptrs[82]::Ptr{wl_interface}; output::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_shell_surface_set_title(shell_surface, title)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_TITLE::UInt32, Wayland.interface_ptrs[83]::Ptr{wl_interface}; title::Ptr{Cchar})::Ptr{Cvoid}
end

function wl_shell_surface_set_class(shell_surface, class_)
    @ccall libwayland_client.wl_proxy_marshal_constructor(shell_surface::Ptr{Cvoid}, WL_SHELL_SURFACE_SET_CLASS::UInt32, Wayland.interface_ptrs[84]::Ptr{wl_interface}; class_::Ptr{Cchar})::Ptr{Cvoid}
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
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_surface_attach(surface, buffer, x, y)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_ATTACH::UInt32, Wayland.interface_ptrs[89]::Ptr{wl_interface}; buffer::Ptr{Cvoid}, x::Int32, y::Int32)::Ptr{Cvoid}
end

function wl_surface_damage(surface, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_DAMAGE::UInt32, Wayland.interface_ptrs[92]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

function wl_surface_frame(surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_FRAME::UInt32, Wayland.interface_ptrs[96]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_surface_set_opaque_region(surface, region)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_SET_OPAQUE_REGION::UInt32, Wayland.interface_ptrs[97]::Ptr{wl_interface}; region::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_surface_set_input_region(surface, region)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_SET_INPUT_REGION::UInt32, Wayland.interface_ptrs[98]::Ptr{wl_interface}; region::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_surface_commit(surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_COMMIT::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_surface_set_buffer_transform(surface, transform)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_SET_BUFFER_TRANSFORM::UInt32, Wayland.interface_ptrs[99]::Ptr{wl_interface}; transform::Int32)::Ptr{Cvoid}
end

function wl_surface_set_buffer_scale(surface, scale)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_SET_BUFFER_SCALE::UInt32, Wayland.interface_ptrs[100]::Ptr{wl_interface}; scale::Int32)::Ptr{Cvoid}
end

function wl_surface_damage_buffer(surface, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(surface::Ptr{Cvoid}, WL_SURFACE_DAMAGE_BUFFER::UInt32, Wayland.interface_ptrs[101]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

const WL_SEAT_GET_POINTER = 0
const WL_SEAT_GET_KEYBOARD = 1
const WL_SEAT_GET_TOUCH = 2
const WL_SEAT_RELEASE = 3
const WL_SEAT_CAPABILITIES = 4
const WL_SEAT_NAME = 5
function wl_seat_get_pointer(seat)
    @ccall libwayland_client.wl_proxy_marshal_constructor(seat::Ptr{Cvoid}, WL_SEAT_GET_POINTER::UInt32, Wayland.interface_ptrs[107]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_seat_get_keyboard(seat)
    @ccall libwayland_client.wl_proxy_marshal_constructor(seat::Ptr{Cvoid}, WL_SEAT_GET_KEYBOARD::UInt32, Wayland.interface_ptrs[108]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_seat_get_touch(seat)
    @ccall libwayland_client.wl_proxy_marshal_constructor(seat::Ptr{Cvoid}, WL_SEAT_GET_TOUCH::UInt32, Wayland.interface_ptrs[109]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_seat_release(seat)
    @ccall libwayland_client.wl_proxy_marshal_constructor(seat::Ptr{Cvoid}, WL_SEAT_RELEASE::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
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
    @ccall libwayland_client.wl_proxy_marshal_constructor(pointer::Ptr{Cvoid}, WL_POINTER_SET_CURSOR::UInt32, Wayland.interface_ptrs[112]::Ptr{wl_interface}; serial::UInt32, surface::Ptr{Cvoid}, hotspot_x::Int32, hotspot_y::Int32)::Ptr{Cvoid}
end

function wl_pointer_release(pointer)
    @ccall libwayland_client.wl_proxy_marshal_constructor(pointer::Ptr{Cvoid}, WL_POINTER_RELEASE::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

const WL_KEYBOARD_RELEASE = 0
const WL_KEYBOARD_KEYMAP = 1
const WL_KEYBOARD_ENTER = 2
const WL_KEYBOARD_LEAVE = 3
const WL_KEYBOARD_KEY = 4
const WL_KEYBOARD_MODIFIERS = 5
const WL_KEYBOARD_REPEAT_INFO = 6
function wl_keyboard_release(keyboard)
    @ccall libwayland_client.wl_proxy_marshal_constructor(keyboard::Ptr{Cvoid}, WL_KEYBOARD_RELEASE::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
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
    @ccall libwayland_client.wl_proxy_marshal_constructor(touch::Ptr{Cvoid}, WL_TOUCH_RELEASE::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

const WL_OUTPUT_RELEASE = 0
const WL_OUTPUT_GEOMETRY = 1
const WL_OUTPUT_MODE = 2
const WL_OUTPUT_DONE = 3
const WL_OUTPUT_SCALE = 4
function wl_output_release(output)
    @ccall libwayland_client.wl_proxy_marshal_constructor(output::Ptr{Cvoid}, WL_OUTPUT_RELEASE::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

const WL_REGION_DESTROY = 0
const WL_REGION_ADD = 1
const WL_REGION_SUBTRACT = 2
function wl_region_destroy(region)
    @ccall libwayland_client.wl_proxy_marshal_constructor(region::Ptr{Cvoid}, WL_REGION_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_region_add(region, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(region::Ptr{Cvoid}, WL_REGION_ADD::UInt32, Wayland.interface_ptrs[187]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

function wl_region_subtract(region, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(region::Ptr{Cvoid}, WL_REGION_SUBTRACT::UInt32, Wayland.interface_ptrs[191]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

const WL_SUBCOMPOSITOR_DESTROY = 0
const WL_SUBCOMPOSITOR_GET_SUBSURFACE = 1
function wl_subcompositor_destroy(subcompositor)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subcompositor::Ptr{Cvoid}, WL_SUBCOMPOSITOR_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_subcompositor_get_subsurface(subcompositor, surface, parent)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subcompositor::Ptr{Cvoid}, WL_SUBCOMPOSITOR_GET_SUBSURFACE::UInt32, Wayland.interface_ptrs[195]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, surface::Ptr{Cvoid}, parent::Ptr{Cvoid})::Ptr{Cvoid}
end

const WL_SUBSURFACE_DESTROY = 0
const WL_SUBSURFACE_SET_POSITION = 1
const WL_SUBSURFACE_PLACE_ABOVE = 2
const WL_SUBSURFACE_PLACE_BELOW = 3
const WL_SUBSURFACE_SET_SYNC = 4
const WL_SUBSURFACE_SET_DESYNC = 5
function wl_subsurface_destroy(subsurface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_subsurface_set_position(subsurface, x, y)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_SET_POSITION::UInt32, Wayland.interface_ptrs[198]::Ptr{wl_interface}; x::Int32, y::Int32)::Ptr{Cvoid}
end

function wl_subsurface_place_above(subsurface, sibling)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_PLACE_ABOVE::UInt32, Wayland.interface_ptrs[200]::Ptr{wl_interface}; sibling::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_subsurface_place_below(subsurface, sibling)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_PLACE_BELOW::UInt32, Wayland.interface_ptrs[201]::Ptr{wl_interface}; sibling::Ptr{Cvoid})::Ptr{Cvoid}
end

function wl_subsurface_set_sync(subsurface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_SET_SYNC::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wl_subsurface_set_desync(subsurface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(subsurface::Ptr{Cvoid}, WL_SUBSURFACE_SET_DESYNC::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

const WP_PRESENTATION_DESTROY = 0
const WP_PRESENTATION_FEEDBACK = 1
const WP_PRESENTATION_CLOCK_ID = 2
function wp_presentation_destroy(wp_presentation)
    @ccall libwayland_client.wl_proxy_marshal_constructor(wp_presentation::Ptr{Cvoid}, WP_PRESENTATION_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wp_presentation_feedback(wp_presentation, surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(wp_presentation::Ptr{Cvoid}, WP_PRESENTATION_FEEDBACK::UInt32, Wayland.interface_ptrs[202]::Ptr{wl_interface}; surface::Ptr{Cvoid}, C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

const WP_PRESENTATION_FEEDBACK_SYNC_OUTPUT = 0
const WP_PRESENTATION_FEEDBACK_PRESENTED = 1
const WP_PRESENTATION_FEEDBACK_DISCARDED = 2
const WP_VIEWPORTER_DESTROY = 0
const WP_VIEWPORTER_GET_VIEWPORT = 1
function wp_viewporter_destroy(wp_viewporter)
    @ccall libwayland_client.wl_proxy_marshal_constructor(wp_viewporter::Ptr{Cvoid}, WP_VIEWPORTER_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wp_viewporter_get_viewport(wp_viewporter, surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(wp_viewporter::Ptr{Cvoid}, WP_VIEWPORTER_GET_VIEWPORT::UInt32, Wayland.interface_ptrs[213]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, surface::Ptr{Cvoid})::Ptr{Cvoid}
end

const WP_VIEWPORT_DESTROY = 0
const WP_VIEWPORT_SET_SOURCE = 1
const WP_VIEWPORT_SET_DESTINATION = 2
function wp_viewport_destroy(wp_viewport)
    @ccall libwayland_client.wl_proxy_marshal_constructor(wp_viewport::Ptr{Cvoid}, WP_VIEWPORT_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function wp_viewport_set_source(wp_viewport, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(wp_viewport::Ptr{Cvoid}, WP_VIEWPORT_SET_SOURCE::UInt32, Wayland.interface_ptrs[215]::Ptr{wl_interface}; convert(Fixed, x)::wl_fixed_t, convert(Fixed, y)::wl_fixed_t, convert(Fixed, width)::wl_fixed_t, convert(Fixed, height)::wl_fixed_t)::Ptr{Cvoid}
end

function wp_viewport_set_destination(wp_viewport, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(wp_viewport::Ptr{Cvoid}, WP_VIEWPORT_SET_DESTINATION::UInt32, Wayland.interface_ptrs[219]::Ptr{wl_interface}; width::Int32, height::Int32)::Ptr{Cvoid}
end

const XDG_WM_BASE_DESTROY = 0
const XDG_WM_BASE_CREATE_POSITIONER = 1
const XDG_WM_BASE_GET_XDG_SURFACE = 2
const XDG_WM_BASE_PONG = 3
const XDG_WM_BASE_PING = 4
function xdg_wm_base_destroy(xdg_wm_base)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_wm_base::Ptr{Cvoid}, XDG_WM_BASE_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_wm_base_create_positioner(xdg_wm_base)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_wm_base::Ptr{Cvoid}, XDG_WM_BASE_CREATE_POSITIONER::UInt32, Wayland.interface_ptrs[221]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function xdg_wm_base_get_xdg_surface(xdg_wm_base, surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_wm_base::Ptr{Cvoid}, XDG_WM_BASE_GET_XDG_SURFACE::UInt32, Wayland.interface_ptrs[222]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, surface::Ptr{Cvoid})::Ptr{Cvoid}
end

function xdg_wm_base_pong(xdg_wm_base, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_wm_base::Ptr{Cvoid}, XDG_WM_BASE_PONG::UInt32, Wayland.interface_ptrs[224]::Ptr{wl_interface}; serial::UInt32)::Ptr{Cvoid}
end

const XDG_POSITIONER_DESTROY = 0
const XDG_POSITIONER_SET_SIZE = 1
const XDG_POSITIONER_SET_ANCHOR_RECT = 2
const XDG_POSITIONER_SET_ANCHOR = 3
const XDG_POSITIONER_SET_GRAVITY = 4
const XDG_POSITIONER_SET_CONSTRAINT_ADJUSTMENT = 5
const XDG_POSITIONER_SET_OFFSET = 6
const XDG_POSITIONER_SET_REACTIVE = 7
const XDG_POSITIONER_SET_PARENT_SIZE = 8
const XDG_POSITIONER_SET_PARENT_CONFIGURE = 9
function xdg_positioner_destroy(xdg_positioner)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_positioner_set_size(xdg_positioner, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_SIZE::UInt32, Wayland.interface_ptrs[226]::Ptr{wl_interface}; width::Int32, height::Int32)::Ptr{Cvoid}
end

function xdg_positioner_set_anchor_rect(xdg_positioner, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_ANCHOR_RECT::UInt32, Wayland.interface_ptrs[228]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

function xdg_positioner_set_anchor(xdg_positioner, anchor)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_ANCHOR::UInt32, Wayland.interface_ptrs[232]::Ptr{wl_interface}; anchor::UInt32)::Ptr{Cvoid}
end

function xdg_positioner_set_gravity(xdg_positioner, gravity)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_GRAVITY::UInt32, Wayland.interface_ptrs[233]::Ptr{wl_interface}; gravity::UInt32)::Ptr{Cvoid}
end

function xdg_positioner_set_constraint_adjustment(xdg_positioner, constraint_adjustment)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_CONSTRAINT_ADJUSTMENT::UInt32, Wayland.interface_ptrs[234]::Ptr{wl_interface}; constraint_adjustment::UInt32)::Ptr{Cvoid}
end

function xdg_positioner_set_offset(xdg_positioner, x, y)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_OFFSET::UInt32, Wayland.interface_ptrs[235]::Ptr{wl_interface}; x::Int32, y::Int32)::Ptr{Cvoid}
end

function xdg_positioner_set_reactive(xdg_positioner)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_REACTIVE::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_positioner_set_parent_size(xdg_positioner, parent_width, parent_height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_PARENT_SIZE::UInt32, Wayland.interface_ptrs[237]::Ptr{wl_interface}; parent_width::Int32, parent_height::Int32)::Ptr{Cvoid}
end

function xdg_positioner_set_parent_configure(xdg_positioner, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_positioner::Ptr{Cvoid}, XDG_POSITIONER_SET_PARENT_CONFIGURE::UInt32, Wayland.interface_ptrs[239]::Ptr{wl_interface}; serial::UInt32)::Ptr{Cvoid}
end

const XDG_SURFACE_DESTROY = 0
const XDG_SURFACE_GET_TOPLEVEL = 1
const XDG_SURFACE_GET_POPUP = 2
const XDG_SURFACE_SET_WINDOW_GEOMETRY = 3
const XDG_SURFACE_ACK_CONFIGURE = 4
const XDG_SURFACE_CONFIGURE = 5
function xdg_surface_destroy(xdg_surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_surface::Ptr{Cvoid}, XDG_SURFACE_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_surface_get_toplevel(xdg_surface)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_surface::Ptr{Cvoid}, XDG_SURFACE_GET_TOPLEVEL::UInt32, Wayland.interface_ptrs[240]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid})::Ptr{Cvoid}
end

function xdg_surface_get_popup(xdg_surface, parent, positioner)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_surface::Ptr{Cvoid}, XDG_SURFACE_GET_POPUP::UInt32, Wayland.interface_ptrs[241]::Ptr{wl_interface}; C_NULL::Ptr{Cvoid}, parent::Ptr{Cvoid}, positioner::Ptr{Cvoid})::Ptr{Cvoid}
end

function xdg_surface_set_window_geometry(xdg_surface, x, y, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_surface::Ptr{Cvoid}, XDG_SURFACE_SET_WINDOW_GEOMETRY::UInt32, Wayland.interface_ptrs[244]::Ptr{wl_interface}; x::Int32, y::Int32, width::Int32, height::Int32)::Ptr{Cvoid}
end

function xdg_surface_ack_configure(xdg_surface, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_surface::Ptr{Cvoid}, XDG_SURFACE_ACK_CONFIGURE::UInt32, Wayland.interface_ptrs[248]::Ptr{wl_interface}; serial::UInt32)::Ptr{Cvoid}
end

const XDG_TOPLEVEL_DESTROY = 0
const XDG_TOPLEVEL_SET_PARENT = 1
const XDG_TOPLEVEL_SET_TITLE = 2
const XDG_TOPLEVEL_SET_APP_ID = 3
const XDG_TOPLEVEL_SHOW_WINDOW_MENU = 4
const XDG_TOPLEVEL_MOVE = 5
const XDG_TOPLEVEL_RESIZE = 6
const XDG_TOPLEVEL_SET_MAX_SIZE = 7
const XDG_TOPLEVEL_SET_MIN_SIZE = 8
const XDG_TOPLEVEL_SET_MAXIMIZED = 9
const XDG_TOPLEVEL_UNSET_MAXIMIZED = 10
const XDG_TOPLEVEL_SET_FULLSCREEN = 11
const XDG_TOPLEVEL_UNSET_FULLSCREEN = 12
const XDG_TOPLEVEL_SET_MINIMIZED = 13
const XDG_TOPLEVEL_CONFIGURE = 14
const XDG_TOPLEVEL_CLOSE = 15
const XDG_TOPLEVEL_CONFIGURE_BOUNDS = 16
function xdg_toplevel_destroy(xdg_toplevel)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_toplevel_set_parent(xdg_toplevel, parent)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_PARENT::UInt32, Wayland.interface_ptrs[250]::Ptr{wl_interface}; parent::Ptr{Cvoid})::Ptr{Cvoid}
end

function xdg_toplevel_set_title(xdg_toplevel, title)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_TITLE::UInt32, Wayland.interface_ptrs[251]::Ptr{wl_interface}; title::Ptr{Cchar})::Ptr{Cvoid}
end

function xdg_toplevel_set_app_id(xdg_toplevel, app_id)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_APP_ID::UInt32, Wayland.interface_ptrs[252]::Ptr{wl_interface}; app_id::Ptr{Cchar})::Ptr{Cvoid}
end

function xdg_toplevel_show_window_menu(xdg_toplevel, seat, serial, x, y)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SHOW_WINDOW_MENU::UInt32, Wayland.interface_ptrs[253]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32, x::Int32, y::Int32)::Ptr{Cvoid}
end

function xdg_toplevel_move(xdg_toplevel, seat, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_MOVE::UInt32, Wayland.interface_ptrs[257]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function xdg_toplevel_resize(xdg_toplevel, seat, serial, edges)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_RESIZE::UInt32, Wayland.interface_ptrs[259]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32, edges::UInt32)::Ptr{Cvoid}
end

function xdg_toplevel_set_max_size(xdg_toplevel, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_MAX_SIZE::UInt32, Wayland.interface_ptrs[262]::Ptr{wl_interface}; width::Int32, height::Int32)::Ptr{Cvoid}
end

function xdg_toplevel_set_min_size(xdg_toplevel, width, height)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_MIN_SIZE::UInt32, Wayland.interface_ptrs[264]::Ptr{wl_interface}; width::Int32, height::Int32)::Ptr{Cvoid}
end

function xdg_toplevel_set_maximized(xdg_toplevel)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_MAXIMIZED::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_toplevel_unset_maximized(xdg_toplevel)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_UNSET_MAXIMIZED::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_toplevel_set_fullscreen(xdg_toplevel, output)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_FULLSCREEN::UInt32, Wayland.interface_ptrs[266]::Ptr{wl_interface}; output::Ptr{Cvoid})::Ptr{Cvoid}
end

function xdg_toplevel_unset_fullscreen(xdg_toplevel)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_UNSET_FULLSCREEN::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_toplevel_set_minimized(xdg_toplevel)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_toplevel::Ptr{Cvoid}, XDG_TOPLEVEL_SET_MINIMIZED::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

const XDG_POPUP_DESTROY = 0
const XDG_POPUP_GRAB = 1
const XDG_POPUP_REPOSITION = 2
const XDG_POPUP_CONFIGURE = 3
const XDG_POPUP_POPUP_DONE = 4
const XDG_POPUP_REPOSITIONED = 5
function xdg_popup_destroy(xdg_popup)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_popup::Ptr{Cvoid}, XDG_POPUP_DESTROY::UInt32, Wayland.interface_ptrs[1]::Ptr{wl_interface})::Ptr{Cvoid}
end

function xdg_popup_grab(xdg_popup, seat, serial)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_popup::Ptr{Cvoid}, XDG_POPUP_GRAB::UInt32, Wayland.interface_ptrs[272]::Ptr{wl_interface}; seat::Ptr{Cvoid}, serial::UInt32)::Ptr{Cvoid}
end

function xdg_popup_reposition(xdg_popup, positioner, token)
    @ccall libwayland_client.wl_proxy_marshal_constructor(xdg_popup::Ptr{Cvoid}, XDG_POPUP_REPOSITION::UInt32, Wayland.interface_ptrs[274]::Ptr{wl_interface}; positioner::Ptr{Cvoid}, token::UInt32)::Ptr{Cvoid}
end

