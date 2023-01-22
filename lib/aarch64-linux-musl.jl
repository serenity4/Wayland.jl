const pid_t = Cint

const uid_t = Cuint

const gid_t = Cuint

"""
    wl_message

Protocol message signature

A [`wl_message`](@ref) describes the signature of an actual protocol message, such as a request or event, that adheres to the Wayland protocol wire format. The protocol implementation uses a [`wl_message`](@ref) within its demarshal machinery for decoding messages between a compositor and its clients. In a sense, a [`wl_message`](@ref) is to a protocol message like a class is to an object.

The `name` of a [`wl_message`](@ref) is the name of the corresponding protocol message.

The `signature` is an ordered list of symbols representing the data types of message arguments and, optionally, a protocol version and indicators for nullability. A leading integer in the `signature` indicates the \\_since\\_ version of the protocol message. A `?` preceding a data type symbol indicates that the following argument type is nullable. While it is a protocol violation to send messages with non-nullable arguments set to `NULL`, event handlers in clients might still get called with non-nullable object arguments set to `NULL`. This can happen when the client destroyed the object being used as argument on its side and an event referencing that object was sent before the server knew about its destruction. As this race cannot be prevented, clients should - as a general rule - program their event handlers such that they can handle object arguments declared non-nullable being `NULL` gracefully.

When no arguments accompany a message, `signature` is an empty string.

Symbols:

* `i`: int * `u`: uint * `f`: fixed * `s`: string * `o`: object * `n`: new\\_id * `a`: array * `h`: fd * `?`: following argument is nullable

While demarshaling primitive arguments is straightforward, when demarshaling messages containing `object` or `new_id` arguments, the protocol implementation often must determine the type of the object. The `types` of a [`wl_message`](@ref) is an array of [`wl_interface`](@ref) references that correspond to `o` and `n` arguments in `signature`, with `NULL` placeholders for arguments with non-object types.

Consider the protocol event [`wl_display`](@ref) `delete_id` that has a single `uint` argument. The [`wl_message`](@ref) is:

```c++
 { "delete_id", "u", [NULL] }
```

Here, the message `name` is `"delete\\_id"`, the `signature` is `"u"`, and the argument `types` is `[NULL]`, indicating that the `uint` argument has no corresponding [`wl_interface`](@ref) since it is a primitive argument.

In contrast, consider a `wl_foo` interface supporting protocol request `bar` that has existed since version 2, and has two arguments: a `uint` and an object of type `wl_baz_interface` that may be `NULL`. Such a [`wl_message`](@ref) might be:

```c++
 { "bar", "2u?o", [NULL, &wl_baz_interface] }
```

Here, the message `name` is `"bar"`, and the `signature` is `"2u?o"`. Notice how the `2` indicates the protocol version, the `u` indicates the first argument type is `uint`, and the `?o` indicates that the second argument is an object that may be `NULL`. Lastly, the argument `types` array indicates that no [`wl_interface`](@ref) corresponds to the first argument, while the type `wl_baz_interface` corresponds to the second argument.

| Field     | Note                        |
| :-------- | :-------------------------- |
| name      | Message name                |
| signature | Message signature           |
| types     | Object argument interfaces  |
### See also
[`wl_argument`](@ref), [`wl_interface`](@ref), <a href="https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-Wire-Format">Wire Format</a>
"""
struct wl_message
    name::Ptr{Cchar}
    signature::Ptr{Cchar}
    types::Ptr{Ptr{Cvoid}} # types::Ptr{Ptr{wl_interface}}
end

function Base.getproperty(x::wl_message, f::Symbol)
    f === :types && return Ptr{Ptr{wl_interface}}(getfield(x, f))
    return getfield(x, f)
end

"""
    wl_interface

Protocol object interface

A [`wl_interface`](@ref) describes the API of a protocol object defined in the Wayland protocol specification. The protocol implementation uses a [`wl_interface`](@ref) within its marshalling machinery for encoding client requests.

The `name` of a [`wl_interface`](@ref) is the name of the corresponding protocol interface, and `version` represents the version of the interface. The members `method_count` and `event_count` represent the number of `methods` (requests) and `events` in the respective [`wl_message`](@ref) members.

For example, consider a protocol interface `foo`, marked as version `1`, with two requests and one event.

```c++
{.xml}
 <interface name="foo" version="1">
   <request name="a"></request>
   <request name="b"></request>
   <event name="c"></event>
 </interface>
```

Given two [`wl_message`](@ref) arrays `foo_requests` and `foo_events`, a [`wl_interface`](@ref) for `foo` might be:

```c++
 struct wl_interface foo_interface = {
         "foo", 1,
         2, foo_requests,
         1, foo_events
 };
```

!!! note

    The server side of the protocol may define interface <em>implementation types</em> that incorporate the term `interface` in their name. Take care to not confuse these server-side `struct`s with a [`wl_interface`](@ref) variable whose name also ends in `interface`. For example, while the server may define a type `struct wl\\_foo\\_interface`, the client may define a `struct [`wl_interface`](@ref) wl\\_foo\\_interface`.

| Field          | Note                          |
| :------------- | :---------------------------- |
| name           | Interface name                |
| version        | Interface version             |
| method\\_count | Number of methods (requests)  |
| methods        | Method (request) signatures   |
| event\\_count  | Number of events              |
| events         | Event signatures              |
### See also
[`wl_message`](@ref), [`wl_proxy`](@ref), <a href="https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-Interfaces">Interfaces</a>, <a href="https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-Versioning">Versioning</a>
"""
struct wl_interface
    name::Ptr{Cchar}
    version::Cint
    method_count::Cint
    methods::Ptr{wl_message}
    event_count::Cint
    events::Ptr{wl_message}
end

"""
    wl_list

` wl_list`

Doubly-linked list

On its own, an instance of `struct [`wl_list`](@ref)` represents the sentinel head of a doubly-linked list, and must be initialized using [`wl_list_init`](@ref)(). When empty, the list head's `next` and `prev` members point to the list head itself, otherwise `next` references the first element in the list, and `prev` refers to the last element in the list.

Use the `struct [`wl_list`](@ref)` type to represent both the list head and the links between elements within the list. Use [`wl_list_empty`](@ref)() to determine if the list is empty in O(1).

All elements in the list must be of the same type. The element type must have a `struct [`wl_list`](@ref)` member, often named `link` by convention. Prior to insertion, there is no need to initialize an element's `link` - invoking [`wl_list_init`](@ref)() on an individual list element's `struct [`wl_list`](@ref)` member is unnecessary if the very next operation is [`wl_list_insert`](@ref)(). However, a common idiom is to initialize an element's `link` prior to removal - ensure safety by invoking [`wl_list_init`](@ref)() before [`wl_list_remove`](@ref)().

Consider a list reference `struct [`wl_list`](@ref) foo\\_list`, an element type as `struct element`, and an element's link member as `struct [`wl_list`](@ref) link`.

The following code initializes a list and adds three elements to it.

```c++
 struct wl_list foo_list;
 struct element {
         int foo;
         struct wl_list link;
 };
 struct element e1, e2, e3;
 wl_list_init(&foo_list);
 wl_list_insert(&foo_list, &e1.link);   // e1 is the first element
 wl_list_insert(&foo_list, &e2.link);   // e2 is now the first element
 wl_list_insert(&e2.link, &e3.link); // insert e3 after e2
```

The list now looks like <em>[e2, e3, e1]</em>.

The [`wl_list`](@ref) API provides some iterator macros. For example, to iterate a list in ascending order:

```c++
 struct element *e;
 wl_list_for_each(e, foo_list, link) {
         do_something_with_element(e);
 }
```

See the documentation of each iterator for details.

| Field | Note                   |
| :---- | :--------------------- |
| prev  | Previous list element  |
| next  | Next list element      |
### See also
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h
"""
struct wl_list
    prev::Ptr{wl_list}
    next::Ptr{wl_list}
end

"""
    wl_list_init(list)

Initializes the list.

wl_list

### Parameters
* `list`: List to initialize
"""
function wl_list_init(list)
    ccall((:wl_list_init, libwayland_client), Cvoid, (Ptr{wl_list},), list)
end

"""
    wl_list_insert(list, elm)

Inserts an element into the list, after the element represented by `list`. When `list` is a reference to the list itself (the head), set the containing struct of `elm` as the first element in the list.

!!! note

    If `elm` is already part of a list, inserting it again will lead to list corruption.

wl_list

### Parameters
* `list`: List element after which the new element is inserted
* `elm`: Link of the containing struct to insert into the list
"""
function wl_list_insert(list, elm)
    ccall((:wl_list_insert, libwayland_client), Cvoid, (Ptr{wl_list}, Ptr{wl_list}), list, elm)
end

"""
    wl_list_remove(elm)

Removes an element from the list.

!!! note

    This operation leaves `elm` in an invalid state.

wl_list

### Parameters
* `elm`: Link of the containing struct to remove from the list
"""
function wl_list_remove(elm)
    ccall((:wl_list_remove, libwayland_client), Cvoid, (Ptr{wl_list},), elm)
end

"""
    wl_list_length(list)

Determines the length of the list.

!!! note

    This is an O(n) operation.

wl_list

### Parameters
* `list`: List whose length is to be determined
### Returns
Number of elements in the list
"""
function wl_list_length(list)
    ccall((:wl_list_length, libwayland_client), Cint, (Ptr{wl_list},), list)
end

"""
    wl_list_empty(list)

Determines if the list is empty.

wl_list

### Parameters
* `list`: List whose emptiness is to be determined
### Returns
1 if empty, or 0 if not empty
"""
function wl_list_empty(list)
    ccall((:wl_list_empty, libwayland_client), Cint, (Ptr{wl_list},), list)
end

"""
    wl_list_insert_list(list, other)

Inserts all of the elements of one list into another, after the element represented by `list`.

!!! note

    This leaves `other` in an invalid state.

wl_list

### Parameters
* `list`: List element after which the other list elements will be inserted
* `other`: List of elements to insert
"""
function wl_list_insert_list(list, other)
    ccall((:wl_list_insert_list, libwayland_client), Cvoid, (Ptr{wl_list}, Ptr{wl_list}), list, other)
end

"""
    wl_array

` wl_array`

Dynamic array

A [`wl_array`](@ref) is a dynamic array that can only grow until released. It is intended for relatively small allocations whose size is variable or not known in advance. While construction of a [`wl_array`](@ref) does not require all elements to be of the same size, [`wl_array_for_each`](@ref)() does require all elements to have the same type and size.

| Field | Note             |
| :---- | :--------------- |
| size  | Array size       |
| alloc | Allocated space  |
| data  | Array data       |
"""
struct wl_array
    size::Csize_t
    alloc::Csize_t
    data::Ptr{Cvoid}
end

"""
    wl_array_init(array)

Initializes the array.

wl_array

### Parameters
* `array`: Array to initialize
"""
function wl_array_init(array)
    ccall((:wl_array_init, libwayland_client), Cvoid, (Ptr{wl_array},), array)
end

"""
    wl_array_release(array)

Releases the array data.

!!! note

    Leaves the array in an invalid state.

wl_array

### Parameters
* `array`: Array whose data is to be released
"""
function wl_array_release(array)
    ccall((:wl_array_release, libwayland_client), Cvoid, (Ptr{wl_array},), array)
end

"""
    wl_array_add(array, size)

Increases the size of the array by `size` bytes.

wl_array

### Parameters
* `array`: Array whose size is to be increased
* `size`: Number of bytes to increase the size of the array by
### Returns
A pointer to the beginning of the newly appended space, or NULL when resizing fails.
"""
function wl_array_add(array, size)
    ccall((:wl_array_add, libwayland_client), Ptr{Cvoid}, (Ptr{wl_array}, Csize_t), array, size)
end

"""
    wl_array_copy(array, source)

Copies the contents of `source` to `array`.

wl_array

### Parameters
* `array`: Destination array to copy to
* `source`: Source array to copy from
### Returns
0 on success, or -1 on failure
"""
function wl_array_copy(array, source)
    ccall((:wl_array_copy, libwayland_client), Cint, (Ptr{wl_array}, Ptr{wl_array}), array, source)
end

"""
Fixed-point number

A [`wl_fixed_t`](@ref) is a 24.8 signed fixed-point number with a sign bit, 23 bits of integer precision and 8 bits of decimal precision. Consider [`wl_fixed_t`](@ref) as an opaque struct with methods that facilitate conversion to and from `double` and `int` types.
"""
const wl_fixed_t = Int32

"""
    wl_fixed_to_double(f)

Converts a fixed-point number to a floating-point number.

### Parameters
* `f`: Fixed-point number to convert
### Returns
Floating-point representation of the fixed-point argument
"""
function wl_fixed_to_double(f)
    ccall((:wl_fixed_to_double, libwayland_client), Cdouble, (wl_fixed_t,), f)
end

"""
    wl_fixed_from_double(d)

Converts a floating-point number to a fixed-point number.

### Parameters
* `d`: Floating-point number to convert
### Returns
Fixed-point representation of the floating-point argument
"""
function wl_fixed_from_double(d)
    ccall((:wl_fixed_from_double, libwayland_client), wl_fixed_t, (Cdouble,), d)
end

"""
    wl_fixed_to_int(f)

Converts a fixed-point number to an integer.

### Parameters
* `f`: Fixed-point number to convert
### Returns
Integer component of the fixed-point argument
"""
function wl_fixed_to_int(f)
    ccall((:wl_fixed_to_int, libwayland_client), Cint, (wl_fixed_t,), f)
end

"""
    wl_fixed_from_int(i)

Converts an integer to a fixed-point number.

### Parameters
* `i`: Integer to convert
### Returns
Fixed-point representation of the integer argument
"""
function wl_fixed_from_int(i)
    ccall((:wl_fixed_from_int, libwayland_client), wl_fixed_t, (Cint,), i)
end

"""
    wl_argument

Protocol message argument data types

This union represents all of the argument types in the Wayland protocol wire format. The protocol implementation uses [`wl_argument`](@ref) within its marshalling machinery for dispatching messages between a client and a compositor.

### See also
[`wl_message`](@ref), [`wl_interface`](@ref), <a href="https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-wire-Format">Wire Format</a>
"""
struct wl_argument
    data::NTuple{8, UInt8}
end

function Base.getproperty(x::Ptr{wl_argument}, f::Symbol)
    f === :i && return Ptr{Int32}(x + 0)
    f === :u && return Ptr{UInt32}(x + 0)
    f === :f && return Ptr{wl_fixed_t}(x + 0)
    f === :s && return Ptr{Ptr{Cchar}}(x + 0)
    f === :o && return Ptr{Ptr{wl_object}}(x + 0)
    f === :n && return Ptr{UInt32}(x + 0)
    f === :a && return Ptr{Ptr{wl_array}}(x + 0)
    f === :h && return Ptr{Int32}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::wl_argument, f::Symbol)
    r = Ref{wl_argument}(x)
    ptr = Base.unsafe_convert(Ptr{wl_argument}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{wl_argument}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const __U_wl_argument = Union{Int32, UInt32, wl_fixed_t, Ptr{Cchar}, Ptr{wl_object}, UInt32, Ptr{wl_array}, Int32}

function wl_argument(val::__U_wl_argument)
    ref = Ref{wl_argument}()
    ptr = Base.unsafe_convert(Ptr{wl_argument}, ref)
    if val isa Int32
        ptr.i = val
    elseif val isa UInt32
        ptr.u = val
    elseif val isa wl_fixed_t
        ptr.f = val
    elseif val isa Ptr{Cchar}
        ptr.s = val
    elseif val isa Ptr{wl_object}
        ptr.o = val
    elseif val isa UInt32
        ptr.n = val
    elseif val isa Ptr{wl_array}
        ptr.a = val
    elseif val isa Int32
        ptr.h = val
    end
    ref[]
end

# typedef int ( * wl_dispatcher_func_t ) ( const void * , void * , uint32_t , const struct wl_message * , union wl_argument * )
"""
Dispatcher function type alias

A dispatcher is a function that handles the emitting of callbacks in client code. For programs directly using the C library, this is done by using libffi to call function pointers. When binding to languages other than C, dispatchers provide a way to abstract the function calling process to be friendlier to other function calling systems.

A dispatcher takes five arguments: The first is the dispatcher-specific implementation associated with the target object. The second is the object upon which the callback is being invoked (either [`wl_proxy`](@ref) or [`wl_resource`](@ref)). The third and fourth arguments are the opcode and the [`wl_message`](@ref) corresponding to the callback. The final argument is an array of arguments received from the other process via the wire protocol.

### Parameters
* `"const`: void *" Dispatcher-specific implementation data
* `"void`: *" Callback invocation target ([`wl_proxy`](@ref) or [`wl_resource`](@ref))
* `uint32_t`: Callback opcode
* `"const`: struct [`wl_message`](@ref) *" Callback message signature
* `"union`: [`wl_argument`](@ref) *" Array of received arguments
### Returns
0 on success, or -1 on failure
"""
const wl_dispatcher_func_t = Ptr{Cvoid}

# typedef void ( * wl_log_func_t ) ( const char * , va_list )
"""
Log function type alias

The C implementation of the Wayland protocol abstracts the details of logging. Users may customize the logging behavior, with a function conforming to the [`wl_log_func_t`](@ref) type, via [`wl_log_set_handler_client`](@ref) and [`wl_log_set_handler_server`](@ref).

A [`wl_log_func_t`](@ref) must conform to the expectations of `vprintf`, and expects two arguments: a string to write and a corresponding variable argument list. While the string to write may contain format specifiers and use values in the variable argument list, the behavior of any [`wl_log_func_t`](@ref) depends on the implementation.

!!! note

    Take care to not confuse this with [`wl_protocol_logger_func_t`](@ref), which is a specific server-side logger for requests and events.

### Parameters
* `"const`: char *" String to write to the log, containing optional format specifiers
* `"va_list"`: Variable argument list
### See also
[`wl_log_set_handler_client`](@ref), [`wl_log_set_handler_server`](@ref)
"""
const wl_log_func_t = Ptr{Cvoid}

"""
    wl_iterator_result

Return value of an iterator function

| Enumerator               | Note                    |
| :----------------------- | :---------------------- |
| WL\\_ITERATOR\\_STOP     | Stop the iteration      |
| WL\\_ITERATOR\\_CONTINUE | Continue the iteration  |
### See also
[`wl_client_for_each_resource_iterator_func_t`](@ref), [`wl_client_for_each_resource`](@ref)
"""
@cenum wl_iterator_result::UInt32 begin
    WL_ITERATOR_STOP = 0
    WL_ITERATOR_CONTINUE = 1
end

"""
` wl_proxy`

Represents a protocol object on the client side.

A [`wl_proxy`](@ref) acts as a client side proxy to an object existing in the compositor. The proxy is responsible for converting requests made by the clients with wl_proxy_marshal() into Wayland's wire format. Events coming from the compositor are also handled by the proxy, which will in turn call the handler set with wl_proxy_add_listener().

!!! note

    With the exception of function wl_proxy_set_queue(), functions accessing a [`wl_proxy`](@ref) are not normally used by client code. Clients should normally use the higher level interface generated by the scanner to interact with compositor objects.
"""
const wl_proxy = Cvoid

"""
` wl_display`

Represents a connection to the compositor and acts as a proxy to the [`wl_display`](@ref) singleton object.

A [`wl_display`](@ref) object represents a client connection to a Wayland compositor. It is created with either wl_display_connect() or wl_display_connect_to_fd(). A connection is terminated using wl_display_disconnect().

A [`wl_display`](@ref) is also used as the wl_proxy for the [`wl_display`](@ref) singleton object on the compositor side.

A [`wl_display`](@ref) object handles all the data sent from and to the compositor. When a wl_proxy marshals a request, it will write its wire representation to the display's write buffer. The data is sent to the compositor when the client calls wl_display_flush().

Incoming data is handled in two steps: queueing and dispatching. In the queue step, the data coming from the display fd is interpreted and added to a queue. On the dispatch step, the handler for the incoming event set by the client on the corresponding wl_proxy is called.

A [`wl_display`](@ref) has at least one event queue, called the <em>default queue</em>. Clients can create additional event queues with wl_display_create_queue() and assign wl_proxy's to it. Events occurring in a particular proxy are always queued in its assigned queue. A client can ensure that a certain assumption, such as holding a lock or running from a given thread, is true when a proxy event handler is called by assigning that proxy to an event queue and making sure that this queue is only dispatched when the assumption holds.

The default queue is dispatched by calling wl_display_dispatch(). This will dispatch any events queued on the default queue and attempt to read from the display fd if it's empty. Events read are then queued on the appropriate queues according to the proxy assignment.

A user created queue is dispatched with wl_display_dispatch_queue(). This function behaves exactly the same as [`wl_display_dispatch`](@ref)() but it dispatches given queue instead of the default queue.

A real world example of event queue usage is Mesa's implementation of eglSwapBuffers() for the Wayland platform. This function might need to block until a frame callback is received, but dispatching the default queue could cause an event handler on the client to start drawing again. This problem is solved using another event queue, so that only the events handled by the EGL code are dispatched during the block.

This creates a problem where a thread dispatches a non-default queue, reading all the data from the display fd. If the application would call *poll*(2) after that it would block, even though there might be events queued on the default queue. Those events should be dispatched with wl_display_dispatch_pending() or wl_display_dispatch_queue_pending() before flushing and blocking.
"""
const wl_display = Cvoid

"""
` wl_event_queue`

A queue for wl_proxy object events.

Event queues allows the events on a display to be handled in a thread-safe manner. See wl_display for details.
"""
const wl_event_queue = Cvoid

function wl_event_queue_destroy(queue)
    ccall((:wl_event_queue_destroy, libwayland_client), Cvoid, (Ptr{wl_event_queue},), queue)
end

function wl_proxy_marshal_array_flags(proxy, opcode, interface, version, flags, args)
    ccall((:wl_proxy_marshal_array_flags, libwayland_client), Ptr{wl_proxy}, (Ptr{wl_proxy}, UInt32, Ptr{wl_interface}, UInt32, UInt32, Ptr{wl_argument}), proxy, opcode, interface, version, flags, args)
end

function wl_proxy_marshal_array(p, opcode, args)
    ccall((:wl_proxy_marshal_array, libwayland_client), Cvoid, (Ptr{wl_proxy}, UInt32, Ptr{wl_argument}), p, opcode, args)
end

function wl_proxy_create(factory, interface)
    ccall((:wl_proxy_create, libwayland_client), Ptr{wl_proxy}, (Ptr{wl_proxy}, Ptr{wl_interface}), factory, interface)
end

function wl_proxy_create_wrapper(proxy)
    ccall((:wl_proxy_create_wrapper, libwayland_client), Ptr{Cvoid}, (Ptr{Cvoid},), proxy)
end

function wl_proxy_wrapper_destroy(proxy_wrapper)
    ccall((:wl_proxy_wrapper_destroy, libwayland_client), Cvoid, (Ptr{Cvoid},), proxy_wrapper)
end

function wl_proxy_marshal_array_constructor(proxy, opcode, args, interface)
    ccall((:wl_proxy_marshal_array_constructor, libwayland_client), Ptr{wl_proxy}, (Ptr{wl_proxy}, UInt32, Ptr{wl_argument}, Ptr{wl_interface}), proxy, opcode, args, interface)
end

function wl_proxy_marshal_array_constructor_versioned(proxy, opcode, args, interface, version)
    ccall((:wl_proxy_marshal_array_constructor_versioned, libwayland_client), Ptr{wl_proxy}, (Ptr{wl_proxy}, UInt32, Ptr{wl_argument}, Ptr{wl_interface}, UInt32), proxy, opcode, args, interface, version)
end

function wl_proxy_destroy(proxy)
    ccall((:wl_proxy_destroy, libwayland_client), Cvoid, (Ptr{wl_proxy},), proxy)
end

function wl_proxy_add_listener(proxy, implementation, data)
    ccall((:wl_proxy_add_listener, libwayland_client), Cint, (Ptr{wl_proxy}, Ptr{Ptr{Cvoid}}, Ptr{Cvoid}), proxy, implementation, data)
end

function wl_proxy_get_listener(proxy)
    ccall((:wl_proxy_get_listener, libwayland_client), Ptr{Cvoid}, (Ptr{wl_proxy},), proxy)
end

function wl_proxy_add_dispatcher(proxy, dispatcher_func, dispatcher_data, data)
    ccall((:wl_proxy_add_dispatcher, libwayland_client), Cint, (Ptr{wl_proxy}, wl_dispatcher_func_t, Ptr{Cvoid}, Ptr{Cvoid}), proxy, dispatcher_func, dispatcher_data, data)
end

function wl_proxy_set_user_data(proxy, user_data)
    ccall((:wl_proxy_set_user_data, libwayland_client), Cvoid, (Ptr{wl_proxy}, Ptr{Cvoid}), proxy, user_data)
end

function wl_proxy_get_user_data(proxy)
    ccall((:wl_proxy_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_proxy},), proxy)
end

function wl_proxy_get_version(proxy)
    ccall((:wl_proxy_get_version, libwayland_client), UInt32, (Ptr{wl_proxy},), proxy)
end

function wl_proxy_get_id(proxy)
    ccall((:wl_proxy_get_id, libwayland_client), UInt32, (Ptr{wl_proxy},), proxy)
end

function wl_proxy_set_tag(proxy, tag)
    ccall((:wl_proxy_set_tag, libwayland_client), Cvoid, (Ptr{wl_proxy}, Ptr{Ptr{Cchar}}), proxy, tag)
end

function wl_proxy_get_tag(proxy)
    ccall((:wl_proxy_get_tag, libwayland_client), Ptr{Ptr{Cchar}}, (Ptr{wl_proxy},), proxy)
end

function wl_proxy_get_class(proxy)
    ccall((:wl_proxy_get_class, libwayland_client), Ptr{Cchar}, (Ptr{wl_proxy},), proxy)
end

function wl_proxy_set_queue(proxy, queue)
    ccall((:wl_proxy_set_queue, libwayland_client), Cvoid, (Ptr{wl_proxy}, Ptr{wl_event_queue}), proxy, queue)
end

function wl_display_connect(name)
    ccall((:wl_display_connect, libwayland_client), Ptr{wl_display}, (Ptr{Cchar},), name)
end

function wl_display_connect_to_fd(fd)
    ccall((:wl_display_connect_to_fd, libwayland_client), Ptr{wl_display}, (Cint,), fd)
end

function wl_display_disconnect(display)
    ccall((:wl_display_disconnect, libwayland_client), Cvoid, (Ptr{wl_display},), display)
end

function wl_display_get_fd(display)
    ccall((:wl_display_get_fd, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_display_dispatch(display)
    ccall((:wl_display_dispatch, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_display_dispatch_queue(display, queue)
    ccall((:wl_display_dispatch_queue, libwayland_client), Cint, (Ptr{wl_display}, Ptr{wl_event_queue}), display, queue)
end

function wl_display_dispatch_queue_pending(display, queue)
    ccall((:wl_display_dispatch_queue_pending, libwayland_client), Cint, (Ptr{wl_display}, Ptr{wl_event_queue}), display, queue)
end

function wl_display_dispatch_pending(display)
    ccall((:wl_display_dispatch_pending, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_display_get_error(display)
    ccall((:wl_display_get_error, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_display_get_protocol_error(display, interface, id)
    ccall((:wl_display_get_protocol_error, libwayland_client), UInt32, (Ptr{wl_display}, Ptr{Ptr{wl_interface}}, Ptr{UInt32}), display, interface, id)
end

function wl_display_flush(display)
    ccall((:wl_display_flush, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_display_roundtrip_queue(display, queue)
    ccall((:wl_display_roundtrip_queue, libwayland_client), Cint, (Ptr{wl_display}, Ptr{wl_event_queue}), display, queue)
end

function wl_display_roundtrip(display)
    ccall((:wl_display_roundtrip, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_display_create_queue(display)
    ccall((:wl_display_create_queue, libwayland_client), Ptr{wl_event_queue}, (Ptr{wl_display},), display)
end

function wl_display_prepare_read_queue(display, queue)
    ccall((:wl_display_prepare_read_queue, libwayland_client), Cint, (Ptr{wl_display}, Ptr{wl_event_queue}), display, queue)
end

function wl_display_prepare_read(display)
    ccall((:wl_display_prepare_read, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_display_cancel_read(display)
    ccall((:wl_display_cancel_read, libwayland_client), Cvoid, (Ptr{wl_display},), display)
end

function wl_display_read_events(display)
    ccall((:wl_display_read_events, libwayland_client), Cint, (Ptr{wl_display},), display)
end

function wl_log_set_handler_client(handler)
    ccall((:wl_log_set_handler_client, libwayland_client), Cvoid, (wl_log_func_t,), handler)
end

const wl_client = Cvoid

function wl_client_from_link(link)
    ccall((:wl_client_from_link, libwayland_server), Ptr{wl_client}, (Ptr{wl_list},), link)
end

function wl_client_get_link(client)
    ccall((:wl_client_get_link, libwayland_server), Ptr{wl_list}, (Ptr{wl_client},), client)
end

const wl_resource = Cvoid

function wl_resource_from_link(resource)
    ccall((:wl_resource_from_link, libwayland_server), Ptr{wl_resource}, (Ptr{wl_list},), resource)
end

function wl_resource_get_link(resource)
    ccall((:wl_resource_get_link, libwayland_server), Ptr{wl_list}, (Ptr{wl_resource},), resource)
end

@cenum __JL_Ctag_15::UInt32 begin
    WL_EVENT_READABLE = 1
    WL_EVENT_WRITABLE = 2
    WL_EVENT_HANGUP = 4
    WL_EVENT_ERROR = 8
end

# typedef int ( * wl_event_loop_fd_func_t ) ( int fd , uint32_t mask , void * data )
"""
File descriptor dispatch function type

Functions of this type are used as callbacks for file descriptor events.

### Parameters
* `fd`: The file descriptor delivering the event.
* `mask`: Describes the kind of the event as a bitwise-or of: `WL_EVENT_READABLE`, `WL_EVENT_WRITABLE`, `WL_EVENT_HANGUP`, `WL_EVENT_ERROR`.
* `data`: The user data argument of the related [`wl_event_loop_add_fd`](@ref)() call.
### Returns
If the event source is registered for re-check with [`wl_event_source_check`](@ref)(): 0 for all done, 1 for needing a re-check. If not registered, the return value is ignored and should be zero.
### See also
[`wl_event_loop_add_fd`](@ref)() wl_event_source
"""
const wl_event_loop_fd_func_t = Ptr{Cvoid}

# typedef int ( * wl_event_loop_timer_func_t ) ( void * data )
"""
Timer dispatch function type

Functions of this type are used as callbacks for timer expiry.

### Parameters
* `data`: The user data argument of the related [`wl_event_loop_add_timer`](@ref)() call.
### Returns
If the event source is registered for re-check with [`wl_event_source_check`](@ref)(): 0 for all done, 1 for needing a re-check. If not registered, the return value is ignored and should be zero.
### See also
[`wl_event_loop_add_timer`](@ref)() wl_event_source
"""
const wl_event_loop_timer_func_t = Ptr{Cvoid}

# typedef int ( * wl_event_loop_signal_func_t ) ( int signal_number , void * data )
"""
Signal dispatch function type

Functions of this type are used as callbacks for (POSIX) signals.

### Parameters
* `signal_number`:
* `data`: The user data argument of the related [`wl_event_loop_add_signal`](@ref)() call.
### Returns
If the event source is registered for re-check with [`wl_event_source_check`](@ref)(): 0 for all done, 1 for needing a re-check. If not registered, the return value is ignored and should be zero.
### See also
[`wl_event_loop_add_signal`](@ref)() wl_event_source
"""
const wl_event_loop_signal_func_t = Ptr{Cvoid}

# typedef void ( * wl_event_loop_idle_func_t ) ( void * data )
"""
Idle task function type

Functions of this type are used as callbacks before blocking in [`wl_event_loop_dispatch`](@ref)().

### Parameters
* `data`: The user data argument of the related [`wl_event_loop_add_idle`](@ref)() call.
### See also
[`wl_event_loop_add_idle`](@ref)() [`wl_event_loop_dispatch`](@ref)() wl_event_source
"""
const wl_event_loop_idle_func_t = Ptr{Cvoid}

const wl_event_loop = Cvoid

"""
    wl_event_loop_create()

` wl_event_source`

An abstract event source

This is the generic type for fd, timer, signal, and idle sources. Functions that operate on specific source types must not be used with a different type, even if the function signature allows it.
"""
function wl_event_loop_create()
    ccall((:wl_event_loop_create, libwayland_server), Ptr{wl_event_loop}, ())
end

function wl_event_loop_destroy(loop)
    ccall((:wl_event_loop_destroy, libwayland_server), Cvoid, (Ptr{wl_event_loop},), loop)
end

const wl_event_source = Cvoid

function wl_event_loop_add_fd(loop, fd, mask, func, data)
    ccall((:wl_event_loop_add_fd, libwayland_server), Ptr{wl_event_source}, (Ptr{wl_event_loop}, Cint, UInt32, wl_event_loop_fd_func_t, Ptr{Cvoid}), loop, fd, mask, func, data)
end

function wl_event_source_fd_update(source, mask)
    ccall((:wl_event_source_fd_update, libwayland_server), Cint, (Ptr{wl_event_source}, UInt32), source, mask)
end

function wl_event_loop_add_timer(loop, func, data)
    ccall((:wl_event_loop_add_timer, libwayland_server), Ptr{wl_event_source}, (Ptr{wl_event_loop}, wl_event_loop_timer_func_t, Ptr{Cvoid}), loop, func, data)
end

function wl_event_loop_add_signal(loop, signal_number, func, data)
    ccall((:wl_event_loop_add_signal, libwayland_server), Ptr{wl_event_source}, (Ptr{wl_event_loop}, Cint, wl_event_loop_signal_func_t, Ptr{Cvoid}), loop, signal_number, func, data)
end

function wl_event_source_timer_update(source, ms_delay)
    ccall((:wl_event_source_timer_update, libwayland_server), Cint, (Ptr{wl_event_source}, Cint), source, ms_delay)
end

function wl_event_source_remove(source)
    ccall((:wl_event_source_remove, libwayland_server), Cint, (Ptr{wl_event_source},), source)
end

function wl_event_source_check(source)
    ccall((:wl_event_source_check, libwayland_server), Cvoid, (Ptr{wl_event_source},), source)
end

function wl_event_loop_dispatch(loop, timeout)
    ccall((:wl_event_loop_dispatch, libwayland_server), Cint, (Ptr{wl_event_loop}, Cint), loop, timeout)
end

function wl_event_loop_dispatch_idle(loop)
    ccall((:wl_event_loop_dispatch_idle, libwayland_server), Cvoid, (Ptr{wl_event_loop},), loop)
end

function wl_event_loop_add_idle(loop, func, data)
    ccall((:wl_event_loop_add_idle, libwayland_server), Ptr{wl_event_source}, (Ptr{wl_event_loop}, wl_event_loop_idle_func_t, Ptr{Cvoid}), loop, func, data)
end

function wl_event_loop_get_fd(loop)
    ccall((:wl_event_loop_get_fd, libwayland_server), Cint, (Ptr{wl_event_loop},), loop)
end

# typedef void ( * wl_notify_func_t ) ( struct wl_listener * listener , void * data )
const wl_notify_func_t = Ptr{Cvoid}

"""
    wl_listener

` wl_listener`

A single listener for Wayland signals

[`wl_listener`](@ref) provides the means to listen for [`wl_signal`](@ref) notifications. Many Wayland objects use [`wl_listener`](@ref) for notification of significant events like object destruction.

Clients should create [`wl_listener`](@ref) objects manually and can register them as listeners to signals using #[`wl_signal_add`](@ref), assuming the signal is directly accessible. For opaque structs like [`wl_event_loop`](@ref), adding a listener should be done through provided accessor methods. A listener can only listen to one signal at a time.

```c++
 struct wl_listener your_listener;
 your_listener.notify = your_callback_method;
 // Direct access
 wl_signal_add(&some_object->destroy_signal, &your_listener);
 // Accessor access
 wl_event_loop *loop = ...;
 wl_event_loop_add_destroy_listener(loop, &your_listener);
```

If the listener is part of a larger struct, #[`wl_container_of`](@ref) can be used to retrieve a pointer to it:

```c++
 void your_listener(struct wl_listener *listener, void *data)
 {
 	struct your_data *data;
 	your_data = wl_container_of(listener, data, your_member_name);
 }
```

If you need to remove a listener from a signal, use [`wl_list_remove`](@ref)().

```c++
 wl_list_remove(&your_listener.link);
```

### See also
[`wl_signal`](@ref)
"""
struct wl_listener
    link::wl_list
    notify::wl_notify_func_t
end

function wl_event_loop_add_destroy_listener(loop, listener)
    ccall((:wl_event_loop_add_destroy_listener, libwayland_server), Cvoid, (Ptr{wl_event_loop}, Ptr{wl_listener}), loop, listener)
end

function wl_event_loop_get_destroy_listener(loop, notify)
    ccall((:wl_event_loop_get_destroy_listener, libwayland_server), Ptr{wl_listener}, (Ptr{wl_event_loop}, wl_notify_func_t), loop, notify)
end

function wl_display_create()
    ccall((:wl_display_create, libwayland_server), Ptr{wl_display}, ())
end

function wl_display_destroy(display)
    ccall((:wl_display_destroy, libwayland_server), Cvoid, (Ptr{wl_display},), display)
end

function wl_display_get_event_loop(display)
    ccall((:wl_display_get_event_loop, libwayland_server), Ptr{wl_event_loop}, (Ptr{wl_display},), display)
end

function wl_display_add_socket(display, name)
    ccall((:wl_display_add_socket, libwayland_server), Cint, (Ptr{wl_display}, Ptr{Cchar}), display, name)
end

function wl_display_add_socket_auto(display)
    ccall((:wl_display_add_socket_auto, libwayland_server), Ptr{Cchar}, (Ptr{wl_display},), display)
end

function wl_display_add_socket_fd(display, sock_fd)
    ccall((:wl_display_add_socket_fd, libwayland_server), Cint, (Ptr{wl_display}, Cint), display, sock_fd)
end

function wl_display_terminate(display)
    ccall((:wl_display_terminate, libwayland_server), Cvoid, (Ptr{wl_display},), display)
end

function wl_display_run(display)
    ccall((:wl_display_run, libwayland_server), Cvoid, (Ptr{wl_display},), display)
end

function wl_display_flush_clients(display)
    ccall((:wl_display_flush_clients, libwayland_server), Cvoid, (Ptr{wl_display},), display)
end

function wl_display_destroy_clients(display)
    ccall((:wl_display_destroy_clients, libwayland_server), Cvoid, (Ptr{wl_display},), display)
end

# typedef void ( * wl_global_bind_func_t ) ( struct wl_client * client , void * data , uint32_t version , uint32_t id )
const wl_global_bind_func_t = Ptr{Cvoid}

function wl_display_get_serial(display)
    ccall((:wl_display_get_serial, libwayland_server), UInt32, (Ptr{wl_display},), display)
end

function wl_display_next_serial(display)
    ccall((:wl_display_next_serial, libwayland_server), UInt32, (Ptr{wl_display},), display)
end

function wl_display_add_destroy_listener(display, listener)
    ccall((:wl_display_add_destroy_listener, libwayland_server), Cvoid, (Ptr{wl_display}, Ptr{wl_listener}), display, listener)
end

function wl_display_add_client_created_listener(display, listener)
    ccall((:wl_display_add_client_created_listener, libwayland_server), Cvoid, (Ptr{wl_display}, Ptr{wl_listener}), display, listener)
end

function wl_display_get_destroy_listener(display, notify)
    ccall((:wl_display_get_destroy_listener, libwayland_server), Ptr{wl_listener}, (Ptr{wl_display}, wl_notify_func_t), display, notify)
end

const wl_global = Cvoid

function wl_global_create(display, interface, version, data, bind)
    ccall((:wl_global_create, libwayland_server), Ptr{wl_global}, (Ptr{wl_display}, Ptr{wl_interface}, Cint, Ptr{Cvoid}, wl_global_bind_func_t), display, interface, version, data, bind)
end

function wl_global_remove(_global)
    ccall((:wl_global_remove, libwayland_server), Cvoid, (Ptr{wl_global},), _global)
end

function wl_global_destroy(_global)
    ccall((:wl_global_destroy, libwayland_server), Cvoid, (Ptr{wl_global},), _global)
end

# typedef bool ( * wl_display_global_filter_func_t ) ( const struct wl_client * client , const struct wl_global * global , void * data )
"""
A filter function for [`wl_global`](@ref) objects

A filter function enables the server to decide which globals to advertise to each client.

When a [`wl_global`](@ref) filter is set, the given callback function will be called during [`wl_global`](@ref) advertisement and binding.

This function should return true if the global object should be made visible to the client or false otherwise.

### Parameters
* `client`: The client object
* `global`: The global object to show or hide
* `data`: The user data pointer
"""
const wl_display_global_filter_func_t = Ptr{Cvoid}

function wl_display_set_global_filter(display, filter, data)
    ccall((:wl_display_set_global_filter, libwayland_server), Cvoid, (Ptr{wl_display}, wl_display_global_filter_func_t, Ptr{Cvoid}), display, filter, data)
end

function wl_global_get_interface(_global)
    ccall((:wl_global_get_interface, libwayland_server), Ptr{wl_interface}, (Ptr{wl_global},), _global)
end

function wl_global_get_version(_global)
    ccall((:wl_global_get_version, libwayland_server), UInt32, (Ptr{wl_global},), _global)
end

function wl_global_get_display(_global)
    ccall((:wl_global_get_display, libwayland_server), Ptr{wl_display}, (Ptr{wl_global},), _global)
end

function wl_global_get_user_data(_global)
    ccall((:wl_global_get_user_data, libwayland_server), Ptr{Cvoid}, (Ptr{wl_global},), _global)
end

function wl_global_set_user_data(_global, data)
    ccall((:wl_global_set_user_data, libwayland_server), Cvoid, (Ptr{wl_global}, Ptr{Cvoid}), _global, data)
end

function wl_client_create(display, fd)
    ccall((:wl_client_create, libwayland_server), Ptr{wl_client}, (Ptr{wl_display}, Cint), display, fd)
end

function wl_display_get_client_list(display)
    ccall((:wl_display_get_client_list, libwayland_server), Ptr{wl_list}, (Ptr{wl_display},), display)
end

function wl_client_destroy(client)
    ccall((:wl_client_destroy, libwayland_server), Cvoid, (Ptr{wl_client},), client)
end

function wl_client_flush(client)
    ccall((:wl_client_flush, libwayland_server), Cvoid, (Ptr{wl_client},), client)
end

function wl_client_get_credentials(client, pid, uid, gid)
    ccall((:wl_client_get_credentials, libwayland_server), Cvoid, (Ptr{wl_client}, Ptr{pid_t}, Ptr{uid_t}, Ptr{gid_t}), client, pid, uid, gid)
end

function wl_client_get_fd(client)
    ccall((:wl_client_get_fd, libwayland_server), Cint, (Ptr{wl_client},), client)
end

function wl_client_add_destroy_listener(client, listener)
    ccall((:wl_client_add_destroy_listener, libwayland_server), Cvoid, (Ptr{wl_client}, Ptr{wl_listener}), client, listener)
end

function wl_client_get_destroy_listener(client, notify)
    ccall((:wl_client_get_destroy_listener, libwayland_server), Ptr{wl_listener}, (Ptr{wl_client}, wl_notify_func_t), client, notify)
end

function wl_client_get_object(client, id)
    ccall((:wl_client_get_object, libwayland_server), Ptr{wl_resource}, (Ptr{wl_client}, UInt32), client, id)
end

function wl_client_post_no_memory(client)
    ccall((:wl_client_post_no_memory, libwayland_server), Cvoid, (Ptr{wl_client},), client)
end

function wl_client_add_resource_created_listener(client, listener)
    ccall((:wl_client_add_resource_created_listener, libwayland_server), Cvoid, (Ptr{wl_client}, Ptr{wl_listener}), client, listener)
end

# typedef enum wl_iterator_result ( * wl_client_for_each_resource_iterator_func_t ) ( struct wl_resource * resource , void * user_data )
const wl_client_for_each_resource_iterator_func_t = Ptr{Cvoid}

function wl_client_for_each_resource(client, iterator, user_data)
    ccall((:wl_client_for_each_resource, libwayland_server), Cvoid, (Ptr{wl_client}, wl_client_for_each_resource_iterator_func_t, Ptr{Cvoid}), client, iterator, user_data)
end

"""
    wl_signal

` wl_signal`

A source of a type of observable event

Signals are recognized points where significant events can be observed. Compositors as well as the server can provide signals. Observers are [`wl_listener`](@ref)'s that are added through #[`wl_signal_add`](@ref). Signals are emitted using #[`wl_signal_emit`](@ref), which will invoke all listeners until that listener is removed by [`wl_list_remove`](@ref)() (or whenever the signal is destroyed).

### See also
[`wl_listener`](@ref) for more information on using [`wl_signal`](@ref)
"""
struct wl_signal
    listener_list::wl_list
end

"""
    wl_signal_init(signal)

Initialize a new wl_signal for use.

wl_signal

### Parameters
* `signal`: The signal that will be initialized
"""
function wl_signal_init(signal)
    ccall((:wl_signal_init, libwayland_server), Cvoid, (Ptr{wl_signal},), signal)
end

"""
    wl_signal_add(signal, listener)

Add the specified listener to this signal.

wl_signal

### Parameters
* `signal`: The signal that will emit events to the listener
* `listener`: The listener to add
"""
function wl_signal_add(signal, listener)
    ccall((:wl_signal_add, libwayland_server), Cvoid, (Ptr{wl_signal}, Ptr{wl_listener}), signal, listener)
end

"""
    wl_signal_get(signal, notify)

Gets the listener struct for the specified callback.

wl_signal

### Parameters
* `signal`: The signal that contains the specified listener
* `notify`: The listener that is the target of this search
### Returns
the list item that corresponds to the specified listener, or NULL if none was found
"""
function wl_signal_get(signal, notify)
    ccall((:wl_signal_get, libwayland_server), Ptr{wl_listener}, (Ptr{wl_signal}, wl_notify_func_t), signal, notify)
end

"""
    wl_signal_emit(signal, data)

Emits this signal, notifying all registered listeners.

wl_signal

### Parameters
* `signal`: The signal object that will emit the signal
* `data`: The data that will be emitted with the signal
"""
function wl_signal_emit(signal, data)
    ccall((:wl_signal_emit, libwayland_server), Cvoid, (Ptr{wl_signal}, Ptr{Cvoid}), signal, data)
end

function wl_signal_emit_mutable(signal, data)
    ccall((:wl_signal_emit_mutable, libwayland_server), Cvoid, (Ptr{wl_signal}, Ptr{Cvoid}), signal, data)
end

# typedef void ( * wl_resource_destroy_func_t ) ( struct wl_resource * resource )
const wl_resource_destroy_func_t = Ptr{Cvoid}

function wl_resource_post_event_array(resource, opcode, args)
    ccall((:wl_resource_post_event_array, libwayland_server), Cvoid, (Ptr{wl_resource}, UInt32, Ptr{wl_argument}), resource, opcode, args)
end

function wl_resource_queue_event_array(resource, opcode, args)
    ccall((:wl_resource_queue_event_array, libwayland_server), Cvoid, (Ptr{wl_resource}, UInt32, Ptr{wl_argument}), resource, opcode, args)
end

function wl_resource_post_no_memory(resource)
    ccall((:wl_resource_post_no_memory, libwayland_server), Cvoid, (Ptr{wl_resource},), resource)
end

function wl_client_get_display(client)
    ccall((:wl_client_get_display, libwayland_server), Ptr{wl_display}, (Ptr{wl_client},), client)
end

function wl_resource_create(client, interface, version, id)
    ccall((:wl_resource_create, libwayland_server), Ptr{wl_resource}, (Ptr{wl_client}, Ptr{wl_interface}, Cint, UInt32), client, interface, version, id)
end

function wl_resource_set_implementation(resource, implementation, data, destroy)
    ccall((:wl_resource_set_implementation, libwayland_server), Cvoid, (Ptr{wl_resource}, Ptr{Cvoid}, Ptr{Cvoid}, wl_resource_destroy_func_t), resource, implementation, data, destroy)
end

function wl_resource_set_dispatcher(resource, dispatcher, implementation, data, destroy)
    ccall((:wl_resource_set_dispatcher, libwayland_server), Cvoid, (Ptr{wl_resource}, wl_dispatcher_func_t, Ptr{Cvoid}, Ptr{Cvoid}, wl_resource_destroy_func_t), resource, dispatcher, implementation, data, destroy)
end

function wl_resource_destroy(resource)
    ccall((:wl_resource_destroy, libwayland_server), Cvoid, (Ptr{wl_resource},), resource)
end

function wl_resource_get_id(resource)
    ccall((:wl_resource_get_id, libwayland_server), UInt32, (Ptr{wl_resource},), resource)
end

function wl_resource_find_for_client(list, client)
    ccall((:wl_resource_find_for_client, libwayland_server), Ptr{wl_resource}, (Ptr{wl_list}, Ptr{wl_client}), list, client)
end

function wl_resource_get_client(resource)
    ccall((:wl_resource_get_client, libwayland_server), Ptr{wl_client}, (Ptr{wl_resource},), resource)
end

function wl_resource_set_user_data(resource, data)
    ccall((:wl_resource_set_user_data, libwayland_server), Cvoid, (Ptr{wl_resource}, Ptr{Cvoid}), resource, data)
end

function wl_resource_get_user_data(resource)
    ccall((:wl_resource_get_user_data, libwayland_server), Ptr{Cvoid}, (Ptr{wl_resource},), resource)
end

function wl_resource_get_version(resource)
    ccall((:wl_resource_get_version, libwayland_server), Cint, (Ptr{wl_resource},), resource)
end

function wl_resource_set_destructor(resource, destroy)
    ccall((:wl_resource_set_destructor, libwayland_server), Cvoid, (Ptr{wl_resource}, wl_resource_destroy_func_t), resource, destroy)
end

function wl_resource_instance_of(resource, interface, implementation)
    ccall((:wl_resource_instance_of, libwayland_server), Cint, (Ptr{wl_resource}, Ptr{wl_interface}, Ptr{Cvoid}), resource, interface, implementation)
end

function wl_resource_get_class(resource)
    ccall((:wl_resource_get_class, libwayland_server), Ptr{Cchar}, (Ptr{wl_resource},), resource)
end

function wl_resource_add_destroy_listener(resource, listener)
    ccall((:wl_resource_add_destroy_listener, libwayland_server), Cvoid, (Ptr{wl_resource}, Ptr{wl_listener}), resource, listener)
end

function wl_resource_get_destroy_listener(resource, notify)
    ccall((:wl_resource_get_destroy_listener, libwayland_server), Ptr{wl_listener}, (Ptr{wl_resource}, wl_notify_func_t), resource, notify)
end

const wl_shm_buffer = Cvoid

function wl_shm_buffer_get(resource)
    ccall((:wl_shm_buffer_get, libwayland_server), Ptr{wl_shm_buffer}, (Ptr{wl_resource},), resource)
end

function wl_shm_buffer_begin_access(buffer)
    ccall((:wl_shm_buffer_begin_access, libwayland_server), Cvoid, (Ptr{wl_shm_buffer},), buffer)
end

function wl_shm_buffer_end_access(buffer)
    ccall((:wl_shm_buffer_end_access, libwayland_server), Cvoid, (Ptr{wl_shm_buffer},), buffer)
end

function wl_shm_buffer_get_data(buffer)
    ccall((:wl_shm_buffer_get_data, libwayland_server), Ptr{Cvoid}, (Ptr{wl_shm_buffer},), buffer)
end

function wl_shm_buffer_get_stride(buffer)
    ccall((:wl_shm_buffer_get_stride, libwayland_server), Int32, (Ptr{wl_shm_buffer},), buffer)
end

function wl_shm_buffer_get_format(buffer)
    ccall((:wl_shm_buffer_get_format, libwayland_server), UInt32, (Ptr{wl_shm_buffer},), buffer)
end

function wl_shm_buffer_get_width(buffer)
    ccall((:wl_shm_buffer_get_width, libwayland_server), Int32, (Ptr{wl_shm_buffer},), buffer)
end

function wl_shm_buffer_get_height(buffer)
    ccall((:wl_shm_buffer_get_height, libwayland_server), Int32, (Ptr{wl_shm_buffer},), buffer)
end

const wl_shm_pool = Cvoid

function wl_shm_buffer_ref_pool(buffer)
    ccall((:wl_shm_buffer_ref_pool, libwayland_server), Ptr{wl_shm_pool}, (Ptr{wl_shm_buffer},), buffer)
end

function wl_shm_pool_unref(pool)
    ccall((:wl_shm_pool_unref, libwayland_server), Cvoid, (Ptr{wl_shm_pool},), pool)
end

function wl_display_init_shm(display)
    ccall((:wl_display_init_shm, libwayland_server), Cint, (Ptr{wl_display},), display)
end

function wl_display_add_shm_format(display, format)
    ccall((:wl_display_add_shm_format, libwayland_server), Ptr{UInt32}, (Ptr{wl_display}, UInt32), display, format)
end

function wl_shm_buffer_create(client, id, width, height, stride, format)
    ccall((:wl_shm_buffer_create, libwayland_server), Ptr{wl_shm_buffer}, (Ptr{wl_client}, UInt32, Int32, Int32, Int32, UInt32), client, id, width, height, stride, format)
end

function wl_log_set_handler_server(handler)
    ccall((:wl_log_set_handler_server, libwayland_server), Cvoid, (wl_log_func_t,), handler)
end

@cenum wl_protocol_logger_type::UInt32 begin
    WL_PROTOCOL_LOGGER_REQUEST = 0
    WL_PROTOCOL_LOGGER_EVENT = 1
end

struct wl_protocol_logger_message
    resource::Ptr{wl_resource}
    message_opcode::Cint
    message::Ptr{wl_message}
    arguments_count::Cint
    arguments::Ptr{wl_argument}
end

# typedef void ( * wl_protocol_logger_func_t ) ( void * user_data , enum wl_protocol_logger_type direction , const struct wl_protocol_logger_message * message )
const wl_protocol_logger_func_t = Ptr{Cvoid}

const wl_protocol_logger = Cvoid

function wl_display_add_protocol_logger(display, arg2, user_data)
    ccall((:wl_display_add_protocol_logger, libwayland_server), Ptr{wl_protocol_logger}, (Ptr{wl_display}, wl_protocol_logger_func_t, Ptr{Cvoid}), display, arg2, user_data)
end

function wl_protocol_logger_destroy(logger)
    ccall((:wl_protocol_logger_destroy, libwayland_server), Cvoid, (Ptr{wl_protocol_logger},), logger)
end

"""
` wl_object`

A protocol object.

A [`wl_object`](@ref) is an opaque struct identifying the protocol object underlying a [`wl_proxy`](@ref) or [`wl_resource`](@ref).

!!! note

    Functions accessing a [`wl_object`](@ref) are not normally used by client code. Clients should normally use the higher level interface generated by the scanner to interact with compositor objects.
"""
const wl_object = Cvoid

# Skipping MacroDefinition: WL_EXPORT __attribute__ ( ( visibility ( "default" ) ) )

# Skipping MacroDefinition: WL_DEPRECATED __attribute__ ( ( deprecated ) )

const WAYLAND_VERSION_MAJOR = 1

const WAYLAND_VERSION_MINOR = 21

const WAYLAND_VERSION_MICRO = 0

const WAYLAND_VERSION = "1.21.0"

const WL_MARSHAL_FLAG_DESTROY = 1 << 0

