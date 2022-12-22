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

[`wl_list`](@ref)

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

[`wl_list`](@ref)

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

[`wl_list`](@ref)

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

[`wl_list`](@ref)

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

[`wl_list`](@ref)

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

[`wl_list`](@ref)

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

[`wl_array`](@ref)

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

[`wl_array`](@ref)

### Parameters
* `array`: Array whose data is to be released
"""
function wl_array_release(array)
    ccall((:wl_array_release, libwayland_client), Cvoid, (Ptr{wl_array},), array)
end

"""
    wl_array_add(array, size)

Increases the size of the array by `size` bytes.

[`wl_array`](@ref)

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

[`wl_array`](@ref)

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

A dispatcher takes five arguments: The first is the dispatcher-specific implementation associated with the target object. The second is the object upon which the callback is being invoked (either [`wl_proxy`](@ref) or wl\\_resource). The third and fourth arguments are the opcode and the [`wl_message`](@ref) corresponding to the callback. The final argument is an array of arguments received from the other process via the wire protocol.

### Parameters
* `"const`: void *" Dispatcher-specific implementation data
* `"void`: *" Callback invocation target ([`wl_proxy`](@ref) or `wl_resource`)
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

The C implementation of the Wayland protocol abstracts the details of logging. Users may customize the logging behavior, with a function conforming to the [`wl_log_func_t`](@ref) type, via [`wl_log_set_handler_client`](@ref) and `wl_log_set_handler_server`.

A [`wl_log_func_t`](@ref) must conform to the expectations of `vprintf`, and expects two arguments: a string to write and a corresponding variable argument list. While the string to write may contain format specifiers and use values in the variable argument list, the behavior of any [`wl_log_func_t`](@ref) depends on the implementation.

!!! note

    Take care to not confuse this with `wl_protocol_logger_func_t`, which is a specific server-side logger for requests and events.

### Parameters
* `"const`: char *" String to write to the log, containing optional format specifiers
* `"va_list"`: Variable argument list
### See also
[`wl_log_set_handler_client`](@ref), wl\\_log\\_set\\_handler\\_server
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
wl\\_client\\_for\\_each\\_resource\\_iterator\\_func\\_t, wl\\_client\\_for\\_each\\_resource
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

"""
page\\_wayland The wayland protocol

` page_ifaces_wayland Interfaces`

-

` page_iface_wl_display - core global object`

-

` page_iface_wl_registry - global registry object`

-

` page_iface_wl_callback - callback object`

-

` page_iface_wl_compositor - the compositor singleton`

-

` page_iface_wl_shm_pool - a shared memory pool`

-

` page_iface_wl_shm - shared memory support`

-

` page_iface_wl_buffer - content for a wl_surface`

-

` page_iface_wl_data_offer - offer to transfer data`

-

` page_iface_wl_data_source - offer to transfer data`

-

` page_iface_wl_data_device - data transfer device`

-

` page_iface_wl_data_device_manager - data transfer interface`

-

` page_iface_wl_shell - create desktop-style surfaces`

-

` page_iface_wl_shell_surface - desktop-style metadata interface`

-

` page_iface_wl_surface - an onscreen surface`

-

` page_iface_wl_seat - group of input devices`

-

` page_iface_wl_pointer - pointer input device`

-

` page_iface_wl_keyboard - keyboard input device`

-

` page_iface_wl_touch - touchscreen input device`

-

` page_iface_wl_output - compositor output region`

-

` page_iface_wl_region - region interface`

-

` page_iface_wl_subcompositor - sub-surface compositing`

-

` page_iface_wl_subsurface - sub-surface interface to a wl_surface`

` page_copyright_wayland Copyright`

<pre>

Copyright © 2008-2011 Kristian Høgsberg Copyright © 2010-2011 Intel Corporation Copyright © 2012-2013 Collabora, Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. </pre>
"""
const wl_buffer = Cvoid

const wl_callback = Cvoid

const wl_compositor = Cvoid

const wl_data_device = Cvoid

const wl_data_device_manager = Cvoid

const wl_data_offer = Cvoid

const wl_data_source = Cvoid

const wl_keyboard = Cvoid

const wl_output = Cvoid

const wl_pointer = Cvoid

const wl_region = Cvoid

const wl_registry = Cvoid

const wl_seat = Cvoid

const wl_shell = Cvoid

const wl_shell_surface = Cvoid

const wl_shm = Cvoid

const wl_shm_pool = Cvoid

const wl_subcompositor = Cvoid

const wl_subsurface = Cvoid

const wl_surface = Cvoid

const wl_touch = Cvoid

"""
    wl_display_error

` iface_wl_display`

global error values

These errors are global and can be emitted in response to any server request.

| Enumerator                              | Note                                                                  |
| :-------------------------------------- | :-------------------------------------------------------------------- |
| WL\\_DISPLAY\\_ERROR\\_INVALID\\_OBJECT | server couldn't find object                                           |
| WL\\_DISPLAY\\_ERROR\\_INVALID\\_METHOD | method doesn't exist on the specified interface or malformed request  |
| WL\\_DISPLAY\\_ERROR\\_NO\\_MEMORY      | server is out of memory                                               |
| WL\\_DISPLAY\\_ERROR\\_IMPLEMENTATION   | implementation error in compositor                                    |
"""
@cenum wl_display_error::UInt32 begin
    WL_DISPLAY_ERROR_INVALID_OBJECT = 0
    WL_DISPLAY_ERROR_INVALID_METHOD = 1
    WL_DISPLAY_ERROR_NO_MEMORY = 2
    WL_DISPLAY_ERROR_IMPLEMENTATION = 3
end

"""
    wl_display_listener

` iface_wl_display`

` wl_display_listener`

| Field       | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| :---------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| error       | fatal error event  The error event is sent out when a fatal (non-recoverable) error has occurred. The object\\_id argument is the object where the error occurred, most often in response to a request to that object. The code identifies the error and is defined by the object interface. As such, each interface defines its own set of error codes. The message is a brief description of the error, for (debugging) convenience.  ### Parameters * `object_id`: object where the error occurred * `code`: error code * `message`: error description |
| delete\\_id | acknowledge object ID deletion  This event is used internally by the object ID management logic. When a client deletes an object that it had created, the server will send this event to acknowledge that it has seen the delete request. When the client receives this event, it will know that it can safely reuse the object ID.  ### Parameters * `id`: deleted object ID                                                                                                                                                                             |
"""
struct wl_display_listener
    error::Ptr{Cvoid}
    delete_id::Ptr{Cvoid}
end

"""
    wl_display_add_listener(wl_display_, listener, data)

` iface_wl_display`
"""
function wl_display_add_listener(wl_display_, listener, data)
    ccall((:wl_display_add_listener, libwayland_client), Cint, (Ptr{wl_display}, Ptr{wl_display_listener}, Ptr{Cvoid}), wl_display_, listener, data)
end

"""
    wl_display_set_user_data(wl_display_, user_data)

` iface_wl_display `
"""
function wl_display_set_user_data(wl_display_, user_data)
    ccall((:wl_display_set_user_data, libwayland_client), Cvoid, (Ptr{wl_display}, Ptr{Cvoid}), wl_display_, user_data)
end

"""
    wl_display_get_user_data(wl_display_)

` iface_wl_display `
"""
function wl_display_get_user_data(wl_display_)
    ccall((:wl_display_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_display},), wl_display_)
end

function wl_display_get_version(wl_display_)
    ccall((:wl_display_get_version, libwayland_client), UInt32, (Ptr{wl_display},), wl_display_)
end

"""
    wl_display_sync(wl_display_)

` iface_wl_display`

The sync request asks the server to emit the 'done' event on the returned [`wl_callback`](@ref) object. Since requests are handled in-order and events are delivered in-order, this can be used as a barrier to ensure all previous requests and the resulting events have been handled.

The object returned by this request will be destroyed by the compositor after the callback is fired and as such the client must not attempt to use it after that point.

The callback\\_data passed in the callback is the event serial.
"""
function wl_display_sync(wl_display_)
    ccall((:wl_display_sync, libwayland_client), Ptr{wl_callback}, (Ptr{wl_display},), wl_display_)
end

"""
    wl_display_get_registry(wl_display_)

` iface_wl_display`

This request creates a registry object that allows the client to list and bind the global objects available from the compositor.

It should be noted that the server side resources consumed in response to a get\\_registry request can only be released when the client disconnects, not when the client side proxy is destroyed. Therefore, clients should invoke get\\_registry as infrequently as possible to avoid wasting memory.
"""
function wl_display_get_registry(wl_display_)
    ccall((:wl_display_get_registry, libwayland_client), Ptr{wl_registry}, (Ptr{wl_display},), wl_display_)
end

"""
    wl_registry_listener

` iface_wl_registry`

` wl_registry_listener`

| Field           | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| :-------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| global          | announce global object  Notify the client of global objects.  The event notifies the client that a global object with the given name is now available, and it implements the given version of the given interface.  ### Parameters * `name`: numeric name of the global object * `interface`: interface implemented by the object * `version`: interface version                                                                                                                                                                  |
| global\\_remove | announce removal of global object  Notify the client of removed global objects.  This event notifies the client that the global identified by name is no longer available. If the client bound to the global using the bind request, the client should now destroy that object.  The object remains valid and requests to the object will be ignored until the client destroys it, to avoid races between the global going away and a client sending a request to it.  ### Parameters * `name`: numeric name of the global object |
"""
struct wl_registry_listener
    _global::Ptr{Cvoid}
    global_remove::Ptr{Cvoid}
end

"""
    wl_registry_add_listener(wl_registry_, listener, data)

` iface_wl_registry`
"""
function wl_registry_add_listener(wl_registry_, listener, data)
    ccall((:wl_registry_add_listener, libwayland_client), Cint, (Ptr{wl_registry}, Ptr{wl_registry_listener}, Ptr{Cvoid}), wl_registry_, listener, data)
end

"""
    wl_registry_set_user_data(wl_registry_, user_data)

` iface_wl_registry `
"""
function wl_registry_set_user_data(wl_registry_, user_data)
    ccall((:wl_registry_set_user_data, libwayland_client), Cvoid, (Ptr{wl_registry}, Ptr{Cvoid}), wl_registry_, user_data)
end

"""
    wl_registry_get_user_data(wl_registry_)

` iface_wl_registry `
"""
function wl_registry_get_user_data(wl_registry_)
    ccall((:wl_registry_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_registry},), wl_registry_)
end

function wl_registry_get_version(wl_registry_)
    ccall((:wl_registry_get_version, libwayland_client), UInt32, (Ptr{wl_registry},), wl_registry_)
end

"""
    wl_registry_destroy(wl_registry_)

` iface_wl_registry `
"""
function wl_registry_destroy(wl_registry_)
    ccall((:wl_registry_destroy, libwayland_client), Cvoid, (Ptr{wl_registry},), wl_registry_)
end

"""
    wl_registry_bind(wl_registry_, name, interface, version)

` iface_wl_registry`

Binds a new, client-created object to the server using the specified name as the identifier.
"""
function wl_registry_bind(wl_registry_, name, interface, version)
    ccall((:wl_registry_bind, libwayland_client), Ptr{Cvoid}, (Ptr{wl_registry}, UInt32, Ptr{wl_interface}, UInt32), wl_registry_, name, interface, version)
end

"""
    wl_callback_listener

` iface_wl_callback`

` wl_callback_listener`

| Field | Note                                                                                                                                      |
| :---- | :---------------------------------------------------------------------------------------------------------------------------------------- |
| done  | done event  Notify the client when the related request is done.  ### Parameters * `callback_data`: request-specific data for the callback |
"""
struct wl_callback_listener
    done::Ptr{Cvoid}
end

"""
    wl_callback_add_listener(wl_callback_, listener, data)

` iface_wl_callback`
"""
function wl_callback_add_listener(wl_callback_, listener, data)
    ccall((:wl_callback_add_listener, libwayland_client), Cint, (Ptr{wl_callback}, Ptr{wl_callback_listener}, Ptr{Cvoid}), wl_callback_, listener, data)
end

"""
    wl_callback_set_user_data(wl_callback_, user_data)

` iface_wl_callback `
"""
function wl_callback_set_user_data(wl_callback_, user_data)
    ccall((:wl_callback_set_user_data, libwayland_client), Cvoid, (Ptr{wl_callback}, Ptr{Cvoid}), wl_callback_, user_data)
end

"""
    wl_callback_get_user_data(wl_callback_)

` iface_wl_callback `
"""
function wl_callback_get_user_data(wl_callback_)
    ccall((:wl_callback_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_callback},), wl_callback_)
end

function wl_callback_get_version(wl_callback_)
    ccall((:wl_callback_get_version, libwayland_client), UInt32, (Ptr{wl_callback},), wl_callback_)
end

"""
    wl_callback_destroy(wl_callback_)

` iface_wl_callback `
"""
function wl_callback_destroy(wl_callback_)
    ccall((:wl_callback_destroy, libwayland_client), Cvoid, (Ptr{wl_callback},), wl_callback_)
end

"""
    wl_compositor_set_user_data(wl_compositor_, user_data)

` iface_wl_compositor `
"""
function wl_compositor_set_user_data(wl_compositor_, user_data)
    ccall((:wl_compositor_set_user_data, libwayland_client), Cvoid, (Ptr{wl_compositor}, Ptr{Cvoid}), wl_compositor_, user_data)
end

"""
    wl_compositor_get_user_data(wl_compositor_)

` iface_wl_compositor `
"""
function wl_compositor_get_user_data(wl_compositor_)
    ccall((:wl_compositor_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_compositor},), wl_compositor_)
end

function wl_compositor_get_version(wl_compositor_)
    ccall((:wl_compositor_get_version, libwayland_client), UInt32, (Ptr{wl_compositor},), wl_compositor_)
end

"""
    wl_compositor_destroy(wl_compositor_)

` iface_wl_compositor `
"""
function wl_compositor_destroy(wl_compositor_)
    ccall((:wl_compositor_destroy, libwayland_client), Cvoid, (Ptr{wl_compositor},), wl_compositor_)
end

"""
    wl_compositor_create_surface(wl_compositor_)

` iface_wl_compositor`

Ask the compositor to create a new surface.
"""
function wl_compositor_create_surface(wl_compositor_)
    ccall((:wl_compositor_create_surface, libwayland_client), Ptr{wl_surface}, (Ptr{wl_compositor},), wl_compositor_)
end

"""
    wl_compositor_create_region(wl_compositor_)

` iface_wl_compositor`

Ask the compositor to create a new region.
"""
function wl_compositor_create_region(wl_compositor_)
    ccall((:wl_compositor_create_region, libwayland_client), Ptr{wl_region}, (Ptr{wl_compositor},), wl_compositor_)
end

"""
    wl_shm_pool_set_user_data(wl_shm_pool_, user_data)

` iface_wl_shm_pool `
"""
function wl_shm_pool_set_user_data(wl_shm_pool_, user_data)
    ccall((:wl_shm_pool_set_user_data, libwayland_client), Cvoid, (Ptr{wl_shm_pool}, Ptr{Cvoid}), wl_shm_pool_, user_data)
end

"""
    wl_shm_pool_get_user_data(wl_shm_pool_)

` iface_wl_shm_pool `
"""
function wl_shm_pool_get_user_data(wl_shm_pool_)
    ccall((:wl_shm_pool_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_shm_pool},), wl_shm_pool_)
end

function wl_shm_pool_get_version(wl_shm_pool_)
    ccall((:wl_shm_pool_get_version, libwayland_client), UInt32, (Ptr{wl_shm_pool},), wl_shm_pool_)
end

"""
    wl_shm_pool_create_buffer(wl_shm_pool_, offset, width, height, stride, format)

` iface_wl_shm_pool`

Create a [`wl_buffer`](@ref) object from the pool.

The buffer is created offset bytes into the pool and has width and height as specified. The stride argument specifies the number of bytes from the beginning of one row to the beginning of the next. The format is the pixel format of the buffer and must be one of those advertised through the [`wl_shm`](@ref).format event.

A buffer will keep a reference to the pool it was created from so it is valid to destroy the pool immediately after creating a buffer from it.
"""
function wl_shm_pool_create_buffer(wl_shm_pool_, offset, width, height, stride, format)
    ccall((:wl_shm_pool_create_buffer, libwayland_client), Ptr{wl_buffer}, (Ptr{wl_shm_pool}, Int32, Int32, Int32, Int32, UInt32), wl_shm_pool_, offset, width, height, stride, format)
end

"""
    wl_shm_pool_destroy(wl_shm_pool_)

` iface_wl_shm_pool`

Destroy the shared memory pool.

The mmapped memory will be released when all buffers that have been created from this pool are gone.
"""
function wl_shm_pool_destroy(wl_shm_pool_)
    ccall((:wl_shm_pool_destroy, libwayland_client), Cvoid, (Ptr{wl_shm_pool},), wl_shm_pool_)
end

"""
    wl_shm_pool_resize(wl_shm_pool_, size)

` iface_wl_shm_pool`

This request will cause the server to remap the backing memory for the pool from the file descriptor passed when the pool was created, but using the new size. This request can only be used to make the pool bigger.
"""
function wl_shm_pool_resize(wl_shm_pool_, size)
    ccall((:wl_shm_pool_resize, libwayland_client), Cvoid, (Ptr{wl_shm_pool}, Int32), wl_shm_pool_, size)
end

"""
    wl_shm_error

` iface_wl_shm`

[`wl_shm`](@ref) error values

These errors can be emitted in response to [`wl_shm`](@ref) requests.

| Enumerator                          | Note                                                   |
| :---------------------------------- | :----------------------------------------------------- |
| WL\\_SHM\\_ERROR\\_INVALID\\_FORMAT | buffer format is not known                             |
| WL\\_SHM\\_ERROR\\_INVALID\\_STRIDE | invalid size or stride during pool or buffer creation  |
| WL\\_SHM\\_ERROR\\_INVALID\\_FD     | mmapping the file descriptor failed                    |
"""
@cenum wl_shm_error::UInt32 begin
    WL_SHM_ERROR_INVALID_FORMAT = 0
    WL_SHM_ERROR_INVALID_STRIDE = 1
    WL_SHM_ERROR_INVALID_FD = 2
end

"""
    wl_shm_format

` iface_wl_shm`

pixel formats

This describes the memory layout of an individual pixel.

All renderers should support argb8888 and xrgb8888 but any other formats are optional and may not be supported by the particular renderer in use.

The drm format codes match the macros defined in drm\\_fourcc.h, except argb8888 and xrgb8888. The formats actually supported by the compositor will be reported by the format event.

| Enumerator                               | Note                                                                                              |
| :--------------------------------------- | :------------------------------------------------------------------------------------------------ |
| WL\\_SHM\\_FORMAT\\_ARGB8888             | 32-bit ARGB format, [31:0] A:R:G:B 8:8:8:8 little endian                                          |
| WL\\_SHM\\_FORMAT\\_XRGB8888             | 32-bit RGB format, [31:0] x:R:G:B 8:8:8:8 little endian                                           |
| WL\\_SHM\\_FORMAT\\_C8                   | 8-bit color index format, [7:0] C                                                                 |
| WL\\_SHM\\_FORMAT\\_RGB332               | 8-bit RGB format, [7:0] R:G:B 3:3:2                                                               |
| WL\\_SHM\\_FORMAT\\_BGR233               | 8-bit BGR format, [7:0] B:G:R 2:3:3                                                               |
| WL\\_SHM\\_FORMAT\\_XRGB4444             | 16-bit xRGB format, [15:0] x:R:G:B 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_XBGR4444             | 16-bit xBGR format, [15:0] x:B:G:R 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_RGBX4444             | 16-bit RGBx format, [15:0] R:G:B:x 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_BGRX4444             | 16-bit BGRx format, [15:0] B:G:R:x 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_ARGB4444             | 16-bit ARGB format, [15:0] A:R:G:B 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_ABGR4444             | 16-bit ABGR format, [15:0] A:B:G:R 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_RGBA4444             | 16-bit RBGA format, [15:0] R:G:B:A 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_BGRA4444             | 16-bit BGRA format, [15:0] B:G:R:A 4:4:4:4 little endian                                          |
| WL\\_SHM\\_FORMAT\\_XRGB1555             | 16-bit xRGB format, [15:0] x:R:G:B 1:5:5:5 little endian                                          |
| WL\\_SHM\\_FORMAT\\_XBGR1555             | 16-bit xBGR 1555 format, [15:0] x:B:G:R 1:5:5:5 little endian                                     |
| WL\\_SHM\\_FORMAT\\_RGBX5551             | 16-bit RGBx 5551 format, [15:0] R:G:B:x 5:5:5:1 little endian                                     |
| WL\\_SHM\\_FORMAT\\_BGRX5551             | 16-bit BGRx 5551 format, [15:0] B:G:R:x 5:5:5:1 little endian                                     |
| WL\\_SHM\\_FORMAT\\_ARGB1555             | 16-bit ARGB 1555 format, [15:0] A:R:G:B 1:5:5:5 little endian                                     |
| WL\\_SHM\\_FORMAT\\_ABGR1555             | 16-bit ABGR 1555 format, [15:0] A:B:G:R 1:5:5:5 little endian                                     |
| WL\\_SHM\\_FORMAT\\_RGBA5551             | 16-bit RGBA 5551 format, [15:0] R:G:B:A 5:5:5:1 little endian                                     |
| WL\\_SHM\\_FORMAT\\_BGRA5551             | 16-bit BGRA 5551 format, [15:0] B:G:R:A 5:5:5:1 little endian                                     |
| WL\\_SHM\\_FORMAT\\_RGB565               | 16-bit RGB 565 format, [15:0] R:G:B 5:6:5 little endian                                           |
| WL\\_SHM\\_FORMAT\\_BGR565               | 16-bit BGR 565 format, [15:0] B:G:R 5:6:5 little endian                                           |
| WL\\_SHM\\_FORMAT\\_RGB888               | 24-bit RGB format, [23:0] R:G:B little endian                                                     |
| WL\\_SHM\\_FORMAT\\_BGR888               | 24-bit BGR format, [23:0] B:G:R little endian                                                     |
| WL\\_SHM\\_FORMAT\\_XBGR8888             | 32-bit xBGR format, [31:0] x:B:G:R 8:8:8:8 little endian                                          |
| WL\\_SHM\\_FORMAT\\_RGBX8888             | 32-bit RGBx format, [31:0] R:G:B:x 8:8:8:8 little endian                                          |
| WL\\_SHM\\_FORMAT\\_BGRX8888             | 32-bit BGRx format, [31:0] B:G:R:x 8:8:8:8 little endian                                          |
| WL\\_SHM\\_FORMAT\\_ABGR8888             | 32-bit ABGR format, [31:0] A:B:G:R 8:8:8:8 little endian                                          |
| WL\\_SHM\\_FORMAT\\_RGBA8888             | 32-bit RGBA format, [31:0] R:G:B:A 8:8:8:8 little endian                                          |
| WL\\_SHM\\_FORMAT\\_BGRA8888             | 32-bit BGRA format, [31:0] B:G:R:A 8:8:8:8 little endian                                          |
| WL\\_SHM\\_FORMAT\\_XRGB2101010          | 32-bit xRGB format, [31:0] x:R:G:B 2:10:10:10 little endian                                       |
| WL\\_SHM\\_FORMAT\\_XBGR2101010          | 32-bit xBGR format, [31:0] x:B:G:R 2:10:10:10 little endian                                       |
| WL\\_SHM\\_FORMAT\\_RGBX1010102          | 32-bit RGBx format, [31:0] R:G:B:x 10:10:10:2 little endian                                       |
| WL\\_SHM\\_FORMAT\\_BGRX1010102          | 32-bit BGRx format, [31:0] B:G:R:x 10:10:10:2 little endian                                       |
| WL\\_SHM\\_FORMAT\\_ARGB2101010          | 32-bit ARGB format, [31:0] A:R:G:B 2:10:10:10 little endian                                       |
| WL\\_SHM\\_FORMAT\\_ABGR2101010          | 32-bit ABGR format, [31:0] A:B:G:R 2:10:10:10 little endian                                       |
| WL\\_SHM\\_FORMAT\\_RGBA1010102          | 32-bit RGBA format, [31:0] R:G:B:A 10:10:10:2 little endian                                       |
| WL\\_SHM\\_FORMAT\\_BGRA1010102          | 32-bit BGRA format, [31:0] B:G:R:A 10:10:10:2 little endian                                       |
| WL\\_SHM\\_FORMAT\\_YUYV                 | packed YCbCr format, [31:0] Cr0:Y1:Cb0:Y0 8:8:8:8 little endian                                   |
| WL\\_SHM\\_FORMAT\\_YVYU                 | packed YCbCr format, [31:0] Cb0:Y1:Cr0:Y0 8:8:8:8 little endian                                   |
| WL\\_SHM\\_FORMAT\\_UYVY                 | packed YCbCr format, [31:0] Y1:Cr0:Y0:Cb0 8:8:8:8 little endian                                   |
| WL\\_SHM\\_FORMAT\\_VYUY                 | packed YCbCr format, [31:0] Y1:Cb0:Y0:Cr0 8:8:8:8 little endian                                   |
| WL\\_SHM\\_FORMAT\\_AYUV                 | packed AYCbCr format, [31:0] A:Y:Cb:Cr 8:8:8:8 little endian                                      |
| WL\\_SHM\\_FORMAT\\_NV12                 | 2 plane YCbCr Cr:Cb format, 2x2 subsampled Cr:Cb plane                                            |
| WL\\_SHM\\_FORMAT\\_NV21                 | 2 plane YCbCr Cb:Cr format, 2x2 subsampled Cb:Cr plane                                            |
| WL\\_SHM\\_FORMAT\\_NV16                 | 2 plane YCbCr Cr:Cb format, 2x1 subsampled Cr:Cb plane                                            |
| WL\\_SHM\\_FORMAT\\_NV61                 | 2 plane YCbCr Cb:Cr format, 2x1 subsampled Cb:Cr plane                                            |
| WL\\_SHM\\_FORMAT\\_YUV410               | 3 plane YCbCr format, 4x4 subsampled Cb (1) and Cr (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YVU410               | 3 plane YCbCr format, 4x4 subsampled Cr (1) and Cb (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YUV411               | 3 plane YCbCr format, 4x1 subsampled Cb (1) and Cr (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YVU411               | 3 plane YCbCr format, 4x1 subsampled Cr (1) and Cb (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YUV420               | 3 plane YCbCr format, 2x2 subsampled Cb (1) and Cr (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YVU420               | 3 plane YCbCr format, 2x2 subsampled Cr (1) and Cb (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YUV422               | 3 plane YCbCr format, 2x1 subsampled Cb (1) and Cr (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YVU422               | 3 plane YCbCr format, 2x1 subsampled Cr (1) and Cb (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YUV444               | 3 plane YCbCr format, non-subsampled Cb (1) and Cr (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_YVU444               | 3 plane YCbCr format, non-subsampled Cr (1) and Cb (2) planes                                     |
| WL\\_SHM\\_FORMAT\\_R8                   | [7:0] R                                                                                           |
| WL\\_SHM\\_FORMAT\\_R16                  | [15:0] R little endian                                                                            |
| WL\\_SHM\\_FORMAT\\_RG88                 | [15:0] R:G 8:8 little endian                                                                      |
| WL\\_SHM\\_FORMAT\\_GR88                 | [15:0] G:R 8:8 little endian                                                                      |
| WL\\_SHM\\_FORMAT\\_RG1616               | [31:0] R:G 16:16 little endian                                                                    |
| WL\\_SHM\\_FORMAT\\_GR1616               | [31:0] G:R 16:16 little endian                                                                    |
| WL\\_SHM\\_FORMAT\\_XRGB16161616F        | [63:0] x:R:G:B 16:16:16:16 little endian                                                          |
| WL\\_SHM\\_FORMAT\\_XBGR16161616F        | [63:0] x:B:G:R 16:16:16:16 little endian                                                          |
| WL\\_SHM\\_FORMAT\\_ARGB16161616F        | [63:0] A:R:G:B 16:16:16:16 little endian                                                          |
| WL\\_SHM\\_FORMAT\\_ABGR16161616F        | [63:0] A:B:G:R 16:16:16:16 little endian                                                          |
| WL\\_SHM\\_FORMAT\\_XYUV8888             | [31:0] X:Y:Cb:Cr 8:8:8:8 little endian                                                            |
| WL\\_SHM\\_FORMAT\\_VUY888               | [23:0] Cr:Cb:Y 8:8:8 little endian                                                                |
| WL\\_SHM\\_FORMAT\\_VUY101010            | Y followed by U then V, 10:10:10. Non-linear modifier only                                        |
| WL\\_SHM\\_FORMAT\\_Y210                 | [63:0] Cr0:0:Y1:0:Cb0:0:Y0:0 10:6:10:6:10:6:10:6 little endian per 2 Y pixels                     |
| WL\\_SHM\\_FORMAT\\_Y212                 | [63:0] Cr0:0:Y1:0:Cb0:0:Y0:0 12:4:12:4:12:4:12:4 little endian per 2 Y pixels                     |
| WL\\_SHM\\_FORMAT\\_Y216                 | [63:0] Cr0:Y1:Cb0:Y0 16:16:16:16 little endian per 2 Y pixels                                     |
| WL\\_SHM\\_FORMAT\\_Y410                 | [31:0] A:Cr:Y:Cb 2:10:10:10 little endian                                                         |
| WL\\_SHM\\_FORMAT\\_Y412                 | [63:0] A:0:Cr:0:Y:0:Cb:0 12:4:12:4:12:4:12:4 little endian                                        |
| WL\\_SHM\\_FORMAT\\_Y416                 | [63:0] A:Cr:Y:Cb 16:16:16:16 little endian                                                        |
| WL\\_SHM\\_FORMAT\\_XVYU2101010          | [31:0] X:Cr:Y:Cb 2:10:10:10 little endian                                                         |
| WL\\_SHM\\_FORMAT\\_XVYU12\\_16161616    | [63:0] X:0:Cr:0:Y:0:Cb:0 12:4:12:4:12:4:12:4 little endian                                        |
| WL\\_SHM\\_FORMAT\\_XVYU16161616         | [63:0] X:Cr:Y:Cb 16:16:16:16 little endian                                                        |
| WL\\_SHM\\_FORMAT\\_Y0L0                 | [63:0] A3:A2:Y3:0:Cr0:0:Y2:0:A1:A0:Y1:0:Cb0:0:Y0:0 1:1:8:2:8:2:8:2:1:1:8:2:8:2:8:2 little endian  |
| WL\\_SHM\\_FORMAT\\_X0L0                 | [63:0] X3:X2:Y3:0:Cr0:0:Y2:0:X1:X0:Y1:0:Cb0:0:Y0:0 1:1:8:2:8:2:8:2:1:1:8:2:8:2:8:2 little endian  |
| WL\\_SHM\\_FORMAT\\_Y0L2                 | [63:0] A3:A2:Y3:Cr0:Y2:A1:A0:Y1:Cb0:Y0 1:1:10:10:10:1:1:10:10:10 little endian                    |
| WL\\_SHM\\_FORMAT\\_X0L2                 | [63:0] X3:X2:Y3:Cr0:Y2:X1:X0:Y1:Cb0:Y0 1:1:10:10:10:1:1:10:10:10 little endian                    |
| WL\\_SHM\\_FORMAT\\_YUV420\\_8BIT        |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_YUV420\\_10BIT       |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_XRGB8888\\_A8        |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_XBGR8888\\_A8        |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_RGBX8888\\_A8        |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_BGRX8888\\_A8        |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_RGB888\\_A8          |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_BGR888\\_A8          |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_RGB565\\_A8          |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_BGR565\\_A8          |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_NV24                 | non-subsampled Cr:Cb plane                                                                        |
| WL\\_SHM\\_FORMAT\\_NV42                 | non-subsampled Cb:Cr plane                                                                        |
| WL\\_SHM\\_FORMAT\\_P210                 | 2x1 subsampled Cr:Cb plane, 10 bit per channel                                                    |
| WL\\_SHM\\_FORMAT\\_P010                 | 2x2 subsampled Cr:Cb plane 10 bits per channel                                                    |
| WL\\_SHM\\_FORMAT\\_P012                 | 2x2 subsampled Cr:Cb plane 12 bits per channel                                                    |
| WL\\_SHM\\_FORMAT\\_P016                 | 2x2 subsampled Cr:Cb plane 16 bits per channel                                                    |
| WL\\_SHM\\_FORMAT\\_AXBXGXRX106106106106 | [63:0] A:x:B:x:G:x:R:x 10:6:10:6:10:6:10:6 little endian                                          |
| WL\\_SHM\\_FORMAT\\_NV15                 | 2x2 subsampled Cr:Cb plane                                                                        |
| WL\\_SHM\\_FORMAT\\_Q410                 |                                                                                                   |
| WL\\_SHM\\_FORMAT\\_Q401                 |                                                                                                   |
"""
@cenum wl_shm_format::UInt32 begin
    WL_SHM_FORMAT_ARGB8888 = 0
    WL_SHM_FORMAT_XRGB8888 = 1
    WL_SHM_FORMAT_C8 = 538982467
    WL_SHM_FORMAT_RGB332 = 943867730
    WL_SHM_FORMAT_BGR233 = 944916290
    WL_SHM_FORMAT_XRGB4444 = 842093144
    WL_SHM_FORMAT_XBGR4444 = 842089048
    WL_SHM_FORMAT_RGBX4444 = 842094674
    WL_SHM_FORMAT_BGRX4444 = 842094658
    WL_SHM_FORMAT_ARGB4444 = 842093121
    WL_SHM_FORMAT_ABGR4444 = 842089025
    WL_SHM_FORMAT_RGBA4444 = 842088786
    WL_SHM_FORMAT_BGRA4444 = 842088770
    WL_SHM_FORMAT_XRGB1555 = 892424792
    WL_SHM_FORMAT_XBGR1555 = 892420696
    WL_SHM_FORMAT_RGBX5551 = 892426322
    WL_SHM_FORMAT_BGRX5551 = 892426306
    WL_SHM_FORMAT_ARGB1555 = 892424769
    WL_SHM_FORMAT_ABGR1555 = 892420673
    WL_SHM_FORMAT_RGBA5551 = 892420434
    WL_SHM_FORMAT_BGRA5551 = 892420418
    WL_SHM_FORMAT_RGB565 = 909199186
    WL_SHM_FORMAT_BGR565 = 909199170
    WL_SHM_FORMAT_RGB888 = 875710290
    WL_SHM_FORMAT_BGR888 = 875710274
    WL_SHM_FORMAT_XBGR8888 = 875709016
    WL_SHM_FORMAT_RGBX8888 = 875714642
    WL_SHM_FORMAT_BGRX8888 = 875714626
    WL_SHM_FORMAT_ABGR8888 = 875708993
    WL_SHM_FORMAT_RGBA8888 = 875708754
    WL_SHM_FORMAT_BGRA8888 = 875708738
    WL_SHM_FORMAT_XRGB2101010 = 808669784
    WL_SHM_FORMAT_XBGR2101010 = 808665688
    WL_SHM_FORMAT_RGBX1010102 = 808671314
    WL_SHM_FORMAT_BGRX1010102 = 808671298
    WL_SHM_FORMAT_ARGB2101010 = 808669761
    WL_SHM_FORMAT_ABGR2101010 = 808665665
    WL_SHM_FORMAT_RGBA1010102 = 808665426
    WL_SHM_FORMAT_BGRA1010102 = 808665410
    WL_SHM_FORMAT_YUYV = 1448695129
    WL_SHM_FORMAT_YVYU = 1431918169
    WL_SHM_FORMAT_UYVY = 1498831189
    WL_SHM_FORMAT_VYUY = 1498765654
    WL_SHM_FORMAT_AYUV = 1448433985
    WL_SHM_FORMAT_NV12 = 842094158
    WL_SHM_FORMAT_NV21 = 825382478
    WL_SHM_FORMAT_NV16 = 909203022
    WL_SHM_FORMAT_NV61 = 825644622
    WL_SHM_FORMAT_YUV410 = 961959257
    WL_SHM_FORMAT_YVU410 = 961893977
    WL_SHM_FORMAT_YUV411 = 825316697
    WL_SHM_FORMAT_YVU411 = 825316953
    WL_SHM_FORMAT_YUV420 = 842093913
    WL_SHM_FORMAT_YVU420 = 842094169
    WL_SHM_FORMAT_YUV422 = 909202777
    WL_SHM_FORMAT_YVU422 = 909203033
    WL_SHM_FORMAT_YUV444 = 875713881
    WL_SHM_FORMAT_YVU444 = 875714137
    WL_SHM_FORMAT_R8 = 538982482
    WL_SHM_FORMAT_R16 = 540422482
    WL_SHM_FORMAT_RG88 = 943212370
    WL_SHM_FORMAT_GR88 = 943215175
    WL_SHM_FORMAT_RG1616 = 842221394
    WL_SHM_FORMAT_GR1616 = 842224199
    WL_SHM_FORMAT_XRGB16161616F = 1211388504
    WL_SHM_FORMAT_XBGR16161616F = 1211384408
    WL_SHM_FORMAT_ARGB16161616F = 1211388481
    WL_SHM_FORMAT_ABGR16161616F = 1211384385
    WL_SHM_FORMAT_XYUV8888 = 1448434008
    WL_SHM_FORMAT_VUY888 = 875713878
    WL_SHM_FORMAT_VUY101010 = 808670550
    WL_SHM_FORMAT_Y210 = 808530521
    WL_SHM_FORMAT_Y212 = 842084953
    WL_SHM_FORMAT_Y216 = 909193817
    WL_SHM_FORMAT_Y410 = 808531033
    WL_SHM_FORMAT_Y412 = 842085465
    WL_SHM_FORMAT_Y416 = 909194329
    WL_SHM_FORMAT_XVYU2101010 = 808670808
    WL_SHM_FORMAT_XVYU12_16161616 = 909334104
    WL_SHM_FORMAT_XVYU16161616 = 942954072
    WL_SHM_FORMAT_Y0L0 = 810299481
    WL_SHM_FORMAT_X0L0 = 810299480
    WL_SHM_FORMAT_Y0L2 = 843853913
    WL_SHM_FORMAT_X0L2 = 843853912
    WL_SHM_FORMAT_YUV420_8BIT = 942691673
    WL_SHM_FORMAT_YUV420_10BIT = 808539481
    WL_SHM_FORMAT_XRGB8888_A8 = 943805016
    WL_SHM_FORMAT_XBGR8888_A8 = 943800920
    WL_SHM_FORMAT_RGBX8888_A8 = 943806546
    WL_SHM_FORMAT_BGRX8888_A8 = 943806530
    WL_SHM_FORMAT_RGB888_A8 = 943798354
    WL_SHM_FORMAT_BGR888_A8 = 943798338
    WL_SHM_FORMAT_RGB565_A8 = 943797586
    WL_SHM_FORMAT_BGR565_A8 = 943797570
    WL_SHM_FORMAT_NV24 = 875714126
    WL_SHM_FORMAT_NV42 = 842290766
    WL_SHM_FORMAT_P210 = 808530512
    WL_SHM_FORMAT_P010 = 808530000
    WL_SHM_FORMAT_P012 = 842084432
    WL_SHM_FORMAT_P016 = 909193296
    WL_SHM_FORMAT_AXBXGXRX106106106106 = 808534593
    WL_SHM_FORMAT_NV15 = 892425806
    WL_SHM_FORMAT_Q410 = 808531025
    WL_SHM_FORMAT_Q401 = 825242705
end

"""
    wl_shm_listener

` iface_wl_shm`

` wl_shm_listener`

| Field  | Note                                                                                                                                                                                               |
| :----- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| format | pixel format description  Informs the client about a valid pixel format that can be used for buffers. Known formats include argb8888 and xrgb8888.  ### Parameters * `format`: buffer pixel format |
"""
struct wl_shm_listener
    format::Ptr{Cvoid}
end

"""
    wl_shm_add_listener(wl_shm_, listener, data)

` iface_wl_shm`
"""
function wl_shm_add_listener(wl_shm_, listener, data)
    ccall((:wl_shm_add_listener, libwayland_client), Cint, (Ptr{wl_shm}, Ptr{wl_shm_listener}, Ptr{Cvoid}), wl_shm_, listener, data)
end

"""
    wl_shm_set_user_data(wl_shm_, user_data)

` iface_wl_shm `
"""
function wl_shm_set_user_data(wl_shm_, user_data)
    ccall((:wl_shm_set_user_data, libwayland_client), Cvoid, (Ptr{wl_shm}, Ptr{Cvoid}), wl_shm_, user_data)
end

"""
    wl_shm_get_user_data(wl_shm_)

` iface_wl_shm `
"""
function wl_shm_get_user_data(wl_shm_)
    ccall((:wl_shm_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_shm},), wl_shm_)
end

function wl_shm_get_version(wl_shm_)
    ccall((:wl_shm_get_version, libwayland_client), UInt32, (Ptr{wl_shm},), wl_shm_)
end

"""
    wl_shm_destroy(wl_shm_)

` iface_wl_shm `
"""
function wl_shm_destroy(wl_shm_)
    ccall((:wl_shm_destroy, libwayland_client), Cvoid, (Ptr{wl_shm},), wl_shm_)
end

"""
    wl_shm_create_pool(wl_shm_, fd, size)

` iface_wl_shm`

Create a new [`wl_shm_pool`](@ref) object.

The pool can be used to create shared memory based buffer objects. The server will mmap size bytes of the passed file descriptor, to use as backing memory for the pool.
"""
function wl_shm_create_pool(wl_shm_, fd, size)
    ccall((:wl_shm_create_pool, libwayland_client), Ptr{wl_shm_pool}, (Ptr{wl_shm}, Int32, Int32), wl_shm_, fd, size)
end

"""
    wl_buffer_listener

` iface_wl_buffer`

` wl_buffer_listener`

| Field   | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| :------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| release | compositor releases buffer  Sent when this [`wl_buffer`](@ref) is no longer used by the compositor. The client is now free to reuse or destroy this buffer and its backing storage.  If a client receives a release event before the frame callback requested in the same [`wl_surface`](@ref).commit that attaches this [`wl_buffer`](@ref) to a surface, then the client is immediately free to reuse the buffer and its backing storage, and does not need a second buffer for the next surface content update. Typically this is possible, when the compositor maintains a copy of the [`wl_surface`](@ref) contents, e.g. as a GL texture. This is an important optimization for GL(ES) compositors with [`wl_shm`](@ref) clients.  |
"""
struct wl_buffer_listener
    release::Ptr{Cvoid}
end

"""
    wl_buffer_add_listener(wl_buffer_, listener, data)

` iface_wl_buffer`
"""
function wl_buffer_add_listener(wl_buffer_, listener, data)
    ccall((:wl_buffer_add_listener, libwayland_client), Cint, (Ptr{wl_buffer}, Ptr{wl_buffer_listener}, Ptr{Cvoid}), wl_buffer_, listener, data)
end

"""
    wl_buffer_set_user_data(wl_buffer_, user_data)

` iface_wl_buffer `
"""
function wl_buffer_set_user_data(wl_buffer_, user_data)
    ccall((:wl_buffer_set_user_data, libwayland_client), Cvoid, (Ptr{wl_buffer}, Ptr{Cvoid}), wl_buffer_, user_data)
end

"""
    wl_buffer_get_user_data(wl_buffer_)

` iface_wl_buffer `
"""
function wl_buffer_get_user_data(wl_buffer_)
    ccall((:wl_buffer_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_buffer},), wl_buffer_)
end

function wl_buffer_get_version(wl_buffer_)
    ccall((:wl_buffer_get_version, libwayland_client), UInt32, (Ptr{wl_buffer},), wl_buffer_)
end

"""
    wl_buffer_destroy(wl_buffer_)

` iface_wl_buffer`

Destroy a buffer. If and how you need to release the backing storage is defined by the buffer factory interface.

For possible side-effects to a surface, see [`wl_surface`](@ref).attach.
"""
function wl_buffer_destroy(wl_buffer_)
    ccall((:wl_buffer_destroy, libwayland_client), Cvoid, (Ptr{wl_buffer},), wl_buffer_)
end

"""
    wl_data_offer_error

| Enumerator                                          | Note                                  |
| :-------------------------------------------------- | :------------------------------------ |
| WL\\_DATA\\_OFFER\\_ERROR\\_INVALID\\_FINISH        | finish request was called untimely    |
| WL\\_DATA\\_OFFER\\_ERROR\\_INVALID\\_ACTION\\_MASK | action mask contains invalid values   |
| WL\\_DATA\\_OFFER\\_ERROR\\_INVALID\\_ACTION        | action argument has an invalid value  |
| WL\\_DATA\\_OFFER\\_ERROR\\_INVALID\\_OFFER         | offer doesn't accept this request     |
"""
@cenum wl_data_offer_error::UInt32 begin
    WL_DATA_OFFER_ERROR_INVALID_FINISH = 0
    WL_DATA_OFFER_ERROR_INVALID_ACTION_MASK = 1
    WL_DATA_OFFER_ERROR_INVALID_ACTION = 2
    WL_DATA_OFFER_ERROR_INVALID_OFFER = 3
end

"""
    wl_data_offer_listener

` iface_wl_data_offer`

` wl_data_offer_listener`

| Field            | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| :--------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| offer            | advertise offered mime type  Sent immediately after creating the [`wl_data_offer`](@ref) object. One event per offered mime type.  ### Parameters * `mime_type`: offered mime type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| source\\_actions | notify the source-side available actions  This event indicates the actions offered by the data source. It will be sent right after [`wl_data_device`](@ref).enter, or anytime the source side changes its offered actions through [`wl_data_source`](@ref).set\\_actions.  \\since 3  ### Parameters * `source_actions`: actions offered by the data source                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| action           | notify the selected action  This event indicates the action selected by the compositor after matching the source/destination side actions. Only one action (or none) will be offered here.  This event can be emitted multiple times during the drag-and-drop operation in response to destination side action changes through [`wl_data_offer`](@ref).set\\_actions.  This event will no longer be emitted after [`wl_data_device`](@ref).drop happened on the drag-and-drop destination, the client must honor the last action received, or the last preferred one set through [`wl_data_offer`](@ref).set\\_actions when handling an "ask" action.  Compositors may also change the selected action on the fly, mainly in response to keyboard modifier changes during the drag-and-drop operation.  The most recent action received is always the valid one. Prior to receiving [`wl_data_device`](@ref).drop, the chosen action may change (e.g. due to keyboard modifiers being pressed). At the time of receiving [`wl_data_device`](@ref).drop the drag-and-drop destination must honor the last action received.  Action changes may still happen after [`wl_data_device`](@ref).drop, especially on "ask" actions, where the drag-and-drop destination may choose another action afterwards. Action changes happening at this stage are always the result of inter-client negotiation, the compositor shall no longer be able to induce a different action.  Upon "ask" actions, it is expected that the drag-and-drop destination may potentially choose a different action and/or mime type, based on [`wl_data_offer`](@ref).source\\_actions and finally chosen by the user (e.g. popping up a menu with the available options). The final [`wl_data_offer`](@ref).set\\_actions and [`wl_data_offer`](@ref).accept requests must happen before the call to [`wl_data_offer`](@ref).finish.  \\since 3  ### Parameters * `dnd_action`: action selected by the compositor |
"""
struct wl_data_offer_listener
    offer::Ptr{Cvoid}
    source_actions::Ptr{Cvoid}
    action::Ptr{Cvoid}
end

"""
    wl_data_offer_add_listener(wl_data_offer_, listener, data)

` iface_wl_data_offer`
"""
function wl_data_offer_add_listener(wl_data_offer_, listener, data)
    ccall((:wl_data_offer_add_listener, libwayland_client), Cint, (Ptr{wl_data_offer}, Ptr{wl_data_offer_listener}, Ptr{Cvoid}), wl_data_offer_, listener, data)
end

"""
    wl_data_offer_set_user_data(wl_data_offer_, user_data)

` iface_wl_data_offer `
"""
function wl_data_offer_set_user_data(wl_data_offer_, user_data)
    ccall((:wl_data_offer_set_user_data, libwayland_client), Cvoid, (Ptr{wl_data_offer}, Ptr{Cvoid}), wl_data_offer_, user_data)
end

"""
    wl_data_offer_get_user_data(wl_data_offer_)

` iface_wl_data_offer `
"""
function wl_data_offer_get_user_data(wl_data_offer_)
    ccall((:wl_data_offer_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_data_offer},), wl_data_offer_)
end

function wl_data_offer_get_version(wl_data_offer_)
    ccall((:wl_data_offer_get_version, libwayland_client), UInt32, (Ptr{wl_data_offer},), wl_data_offer_)
end

"""
    wl_data_offer_accept(wl_data_offer_, serial, mime_type)

` iface_wl_data_offer`

Indicate that the client can accept the given mime type, or NULL for not accepted.

For objects of version 2 or older, this request is used by the client to give feedback whether the client can receive the given mime type, or NULL if none is accepted; the feedback does not determine whether the drag-and-drop operation succeeds or not.

For objects of version 3 or newer, this request determines the final result of the drag-and-drop operation. If the end result is that no mime types were accepted, the drag-and-drop operation will be cancelled and the corresponding drag source will receive [`wl_data_source`](@ref).cancelled. Clients may still use this event in conjunction with [`wl_data_source`](@ref).action for feedback.
"""
function wl_data_offer_accept(wl_data_offer_, serial, mime_type)
    ccall((:wl_data_offer_accept, libwayland_client), Cvoid, (Ptr{wl_data_offer}, UInt32, Ptr{Cchar}), wl_data_offer_, serial, mime_type)
end

"""
    wl_data_offer_receive(wl_data_offer_, mime_type, fd)

` iface_wl_data_offer`

To transfer the offered data, the client issues this request and indicates the mime type it wants to receive. The transfer happens through the passed file descriptor (typically created with the pipe system call). The source client writes the data in the mime type representation requested and then closes the file descriptor.

The receiving client reads from the read end of the pipe until EOF and then closes its end, at which point the transfer is complete.

This request may happen multiple times for different mime types, both before and after [`wl_data_device`](@ref).drop. Drag-and-drop destination clients may preemptively fetch data or examine it more closely to determine acceptance.
"""
function wl_data_offer_receive(wl_data_offer_, mime_type, fd)
    ccall((:wl_data_offer_receive, libwayland_client), Cvoid, (Ptr{wl_data_offer}, Ptr{Cchar}, Int32), wl_data_offer_, mime_type, fd)
end

"""
    wl_data_offer_destroy(wl_data_offer_)

` iface_wl_data_offer`

Destroy the data offer.
"""
function wl_data_offer_destroy(wl_data_offer_)
    ccall((:wl_data_offer_destroy, libwayland_client), Cvoid, (Ptr{wl_data_offer},), wl_data_offer_)
end

"""
    wl_data_offer_finish(wl_data_offer_)

` iface_wl_data_offer`

Notifies the compositor that the drag destination successfully finished the drag-and-drop operation.

Upon receiving this request, the compositor will emit [`wl_data_source`](@ref).dnd\\_finished on the drag source client.

It is a client error to perform other requests than [`wl_data_offer`](@ref).destroy after this one. It is also an error to perform this request after a NULL mime type has been set in [`wl_data_offer`](@ref).accept or no action was received through [`wl_data_offer`](@ref).action.

If [`wl_data_offer`](@ref).finish request is received for a non drag and drop operation, the invalid\\_finish protocol error is raised.
"""
function wl_data_offer_finish(wl_data_offer_)
    ccall((:wl_data_offer_finish, libwayland_client), Cvoid, (Ptr{wl_data_offer},), wl_data_offer_)
end

"""
    wl_data_offer_set_actions(wl_data_offer_, dnd_actions, preferred_action)

` iface_wl_data_offer`

Sets the actions that the destination side client supports for this operation. This request may trigger the emission of [`wl_data_source`](@ref).action and [`wl_data_offer`](@ref).action events if the compositor needs to change the selected action.

This request can be called multiple times throughout the drag-and-drop operation, typically in response to [`wl_data_device`](@ref).enter or [`wl_data_device`](@ref).motion events.

This request determines the final result of the drag-and-drop operation. If the end result is that no action is accepted, the drag source will receive [`wl_data_source`](@ref).cancelled.

The dnd\\_actions argument must contain only values expressed in the [`wl_data_device_manager`](@ref).dnd\\_actions enum, and the preferred\\_action argument must only contain one of those values set, otherwise it will result in a protocol error.

While managing an "ask" action, the destination drag-and-drop client may perform further [`wl_data_offer`](@ref).receive requests, and is expected to perform one last [`wl_data_offer`](@ref).set\\_actions request with a preferred action other than "ask" (and optionally [`wl_data_offer`](@ref).accept) before requesting [`wl_data_offer`](@ref).finish, in order to convey the action selected by the user. If the preferred action is not in the [`wl_data_offer`](@ref).source\\_actions mask, an error will be raised.

If the "ask" action is dismissed (e.g. user cancellation), the client is expected to perform [`wl_data_offer`](@ref).destroy right away.

This request can only be made on drag-and-drop offers, a protocol error will be raised otherwise.
"""
function wl_data_offer_set_actions(wl_data_offer_, dnd_actions, preferred_action)
    ccall((:wl_data_offer_set_actions, libwayland_client), Cvoid, (Ptr{wl_data_offer}, UInt32, UInt32), wl_data_offer_, dnd_actions, preferred_action)
end

"""
    wl_data_source_error

| Enumerator                                           | Note                                 |
| :--------------------------------------------------- | :----------------------------------- |
| WL\\_DATA\\_SOURCE\\_ERROR\\_INVALID\\_ACTION\\_MASK | action mask contains invalid values  |
| WL\\_DATA\\_SOURCE\\_ERROR\\_INVALID\\_SOURCE        | source doesn't accept this request   |
"""
@cenum wl_data_source_error::UInt32 begin
    WL_DATA_SOURCE_ERROR_INVALID_ACTION_MASK = 0
    WL_DATA_SOURCE_ERROR_INVALID_SOURCE = 1
end

"""
    wl_data_source_listener

` iface_wl_data_source`

` wl_data_source_listener`

| Field                  | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| :--------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| target                 | a target accepts an offered mime type  Sent when a target accepts pointer\\_focus or motion events. If a target does not accept any of the offered types, type is NULL.  Used for feedback during drag-and-drop.  ### Parameters * `mime_type`: mime type accepted by the target                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| send                   | send the data  Request for data from the client. Send the data as the specified mime type over the passed file descriptor, then close it.  ### Parameters * `mime_type`: mime type for the data * `fd`: file descriptor for the data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| cancelled              | selection was cancelled  This data source is no longer valid. There are several reasons why this could happen:  - The data source has been replaced by another data source. - The drag-and-drop operation was performed, but the drop destination did not accept any of the mime types offered through [`wl_data_source`](@ref).target. - The drag-and-drop operation was performed, but the drop destination did not select any of the actions present in the mask offered through [`wl_data_source`](@ref).action. - The drag-and-drop operation was performed but didn't happen over a surface. - The compositor cancelled the drag-and-drop operation (e.g. compositor dependent timeouts to avoid stale drag-and-drop transfers).  The client should clean up and destroy this data source.  For objects of version 2 or older, [`wl_data_source`](@ref).cancelled will only be emitted if the data source was replaced by another data source.                                                                                                                                                                                                                                                                                                                                                                            |
| dnd\\_drop\\_performed | the drag-and-drop operation physically finished  The user performed the drop action. This event does not indicate acceptance, [`wl_data_source`](@ref).cancelled may still be emitted afterwards if the drop destination does not accept any mime type.  However, this event might however not be received if the compositor cancelled the drag-and-drop operation before this event could happen.  Note that the data\\_source may still be used in the future and should not be destroyed here.  \\since 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| dnd\\_finished         | the drag-and-drop operation concluded  The drop destination finished interoperating with this data source, so the client is now free to destroy this data source and free all associated data.  If the action used to perform the operation was "move", the source can now delete the transferred data.  \\since 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| action                 | notify the selected action  This event indicates the action selected by the compositor after matching the source/destination side actions. Only one action (or none) will be offered here.  This event can be emitted multiple times during the drag-and-drop operation, mainly in response to destination side changes through [`wl_data_offer`](@ref).set\\_actions, and as the data device enters/leaves surfaces.  It is only possible to receive this event after [`wl_data_source`](@ref).dnd\\_drop\\_performed if the drag-and-drop operation ended in an "ask" action, in which case the final [`wl_data_source`](@ref).action event will happen immediately before [`wl_data_source`](@ref).dnd\\_finished.  Compositors may also change the selected action on the fly, mainly in response to keyboard modifier changes during the drag-and-drop operation.  The most recent action received is always the valid one. The chosen action may change alongside negotiation (e.g. an "ask" action can turn into a "move" operation), so the effects of the final action must always be applied in [`wl_data_offer`](@ref).dnd\\_finished.  Clients can trigger cursor surface changes from this point, so they reflect the current action.  \\since 3  ### Parameters * `dnd_action`: action selected by the compositor |
"""
struct wl_data_source_listener
    target::Ptr{Cvoid}
    send::Ptr{Cvoid}
    cancelled::Ptr{Cvoid}
    dnd_drop_performed::Ptr{Cvoid}
    dnd_finished::Ptr{Cvoid}
    action::Ptr{Cvoid}
end

"""
    wl_data_source_add_listener(wl_data_source_, listener, data)

` iface_wl_data_source`
"""
function wl_data_source_add_listener(wl_data_source_, listener, data)
    ccall((:wl_data_source_add_listener, libwayland_client), Cint, (Ptr{wl_data_source}, Ptr{wl_data_source_listener}, Ptr{Cvoid}), wl_data_source_, listener, data)
end

"""
    wl_data_source_set_user_data(wl_data_source_, user_data)

` iface_wl_data_source `
"""
function wl_data_source_set_user_data(wl_data_source_, user_data)
    ccall((:wl_data_source_set_user_data, libwayland_client), Cvoid, (Ptr{wl_data_source}, Ptr{Cvoid}), wl_data_source_, user_data)
end

"""
    wl_data_source_get_user_data(wl_data_source_)

` iface_wl_data_source `
"""
function wl_data_source_get_user_data(wl_data_source_)
    ccall((:wl_data_source_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_data_source},), wl_data_source_)
end

function wl_data_source_get_version(wl_data_source_)
    ccall((:wl_data_source_get_version, libwayland_client), UInt32, (Ptr{wl_data_source},), wl_data_source_)
end

"""
    wl_data_source_offer(wl_data_source_, mime_type)

` iface_wl_data_source`

This request adds a mime type to the set of mime types advertised to targets. Can be called several times to offer multiple types.
"""
function wl_data_source_offer(wl_data_source_, mime_type)
    ccall((:wl_data_source_offer, libwayland_client), Cvoid, (Ptr{wl_data_source}, Ptr{Cchar}), wl_data_source_, mime_type)
end

"""
    wl_data_source_destroy(wl_data_source_)

` iface_wl_data_source`

Destroy the data source.
"""
function wl_data_source_destroy(wl_data_source_)
    ccall((:wl_data_source_destroy, libwayland_client), Cvoid, (Ptr{wl_data_source},), wl_data_source_)
end

"""
    wl_data_source_set_actions(wl_data_source_, dnd_actions)

` iface_wl_data_source`

Sets the actions that the source side client supports for this operation. This request may trigger [`wl_data_source`](@ref).action and [`wl_data_offer`](@ref).action events if the compositor needs to change the selected action.

The dnd\\_actions argument must contain only values expressed in the [`wl_data_device_manager`](@ref).dnd\\_actions enum, otherwise it will result in a protocol error.

This request must be made once only, and can only be made on sources used in drag-and-drop, so it must be performed before [`wl_data_device`](@ref).start\\_drag. Attempting to use the source other than for drag-and-drop will raise a protocol error.
"""
function wl_data_source_set_actions(wl_data_source_, dnd_actions)
    ccall((:wl_data_source_set_actions, libwayland_client), Cvoid, (Ptr{wl_data_source}, UInt32), wl_data_source_, dnd_actions)
end

"""
    wl_data_device_error

| Enumerator                        | Note                                         |
| :-------------------------------- | :------------------------------------------- |
| WL\\_DATA\\_DEVICE\\_ERROR\\_ROLE | given [`wl_surface`](@ref) has another role  |
"""
@cenum wl_data_device_error::UInt32 begin
    WL_DATA_DEVICE_ERROR_ROLE = 0
end

"""
    wl_data_device_listener

` iface_wl_data_device`

` wl_data_device_listener`

| Field        | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| :----------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| data\\_offer | introduce a new [`wl_data_offer`](@ref)  The data\\_offer event introduces a new [`wl_data_offer`](@ref) object, which will subsequently be used in either the data\\_device.enter event (for drag-and-drop) or the data\\_device.selection event (for selections). Immediately following the data\\_device\\_data\\_offer event, the new data\\_offer object will send out data\\_offer.offer events to describe the mime types it offers.  ### Parameters * `id`: the new data\\_offer object                                                                                                                                                                                                                                          |
| enter        | initiate drag-and-drop session  This event is sent when an active drag-and-drop pointer enters a surface owned by the client. The position of the pointer at enter time is provided by the x and y arguments, in surface-local coordinates.  ### Parameters * `serial`: serial number of the enter event * `surface`: client surface entered * `x`: surface-local x coordinate * `y`: surface-local y coordinate * `id`: source data\\_offer object                                                                                                                                                                                                                                                                                      |
| leave        | end drag-and-drop session  This event is sent when the drag-and-drop pointer leaves the surface and the session ends. The client must destroy the [`wl_data_offer`](@ref) introduced at enter time at this point.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| motion       | drag-and-drop session motion  This event is sent when the drag-and-drop pointer moves within the currently focused surface. The new position of the pointer is provided by the x and y arguments, in surface-local coordinates.  ### Parameters * `time`: timestamp with millisecond granularity * `x`: surface-local x coordinate * `y`: surface-local y coordinate                                                                                                                                                                                                                                                                                                                                                                     |
| drop         | end drag-and-drop session successfully  The event is sent when a drag-and-drop operation is ended because the implicit grab is removed.  The drag-and-drop destination is expected to honor the last action received through [`wl_data_offer`](@ref).action, if the resulting action is "copy" or "move", the destination can still perform [`wl_data_offer`](@ref).receive requests, and is expected to end all transfers with a [`wl_data_offer`](@ref).finish request.  If the resulting action is "ask", the action will not be considered final. The drag-and-drop destination is expected to perform one last [`wl_data_offer`](@ref).set\\_actions request, or [`wl_data_offer`](@ref).destroy in order to cancel the operation.  |
| selection    | advertise new selection  The selection event is sent out to notify the client of a new [`wl_data_offer`](@ref) for the selection for this device. The data\\_device.data\\_offer and the data\\_offer.offer events are sent out immediately before this event to introduce the data offer object. The selection event is sent to a client immediately before receiving keyboard focus and when a new selection is set while the client has keyboard focus. The data\\_offer is valid until a new data\\_offer or NULL is received or until the client loses keyboard focus. The client must destroy the previous selection data\\_offer, if any, upon receiving this event.  ### Parameters * `id`: selection data\\_offer object        |
"""
struct wl_data_device_listener
    data_offer::Ptr{Cvoid}
    enter::Ptr{Cvoid}
    leave::Ptr{Cvoid}
    motion::Ptr{Cvoid}
    drop::Ptr{Cvoid}
    selection::Ptr{Cvoid}
end

"""
    wl_data_device_add_listener(wl_data_device_, listener, data)

` iface_wl_data_device`
"""
function wl_data_device_add_listener(wl_data_device_, listener, data)
    ccall((:wl_data_device_add_listener, libwayland_client), Cint, (Ptr{wl_data_device}, Ptr{wl_data_device_listener}, Ptr{Cvoid}), wl_data_device_, listener, data)
end

"""
    wl_data_device_set_user_data(wl_data_device_, user_data)

` iface_wl_data_device `
"""
function wl_data_device_set_user_data(wl_data_device_, user_data)
    ccall((:wl_data_device_set_user_data, libwayland_client), Cvoid, (Ptr{wl_data_device}, Ptr{Cvoid}), wl_data_device_, user_data)
end

"""
    wl_data_device_get_user_data(wl_data_device_)

` iface_wl_data_device `
"""
function wl_data_device_get_user_data(wl_data_device_)
    ccall((:wl_data_device_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_data_device},), wl_data_device_)
end

function wl_data_device_get_version(wl_data_device_)
    ccall((:wl_data_device_get_version, libwayland_client), UInt32, (Ptr{wl_data_device},), wl_data_device_)
end

"""
    wl_data_device_destroy(wl_data_device_)

` iface_wl_data_device `
"""
function wl_data_device_destroy(wl_data_device_)
    ccall((:wl_data_device_destroy, libwayland_client), Cvoid, (Ptr{wl_data_device},), wl_data_device_)
end

"""
    wl_data_device_start_drag(wl_data_device_, source, origin, icon, serial)

` iface_wl_data_device`

This request asks the compositor to start a drag-and-drop operation on behalf of the client.

The source argument is the data source that provides the data for the eventual data transfer. If source is NULL, enter, leave and motion events are sent only to the client that initiated the drag and the client is expected to handle the data passing internally. If source is destroyed, the drag-and-drop session will be cancelled.

The origin surface is the surface where the drag originates and the client must have an active implicit grab that matches the serial.

The icon surface is an optional (can be NULL) surface that provides an icon to be moved around with the cursor. Initially, the top-left corner of the icon surface is placed at the cursor hotspot, but subsequent [`wl_surface`](@ref).attach request can move the relative position. Attach requests must be confirmed with [`wl_surface`](@ref).commit as usual. The icon surface is given the role of a drag-and-drop icon. If the icon surface already has another role, it raises a protocol error.

The current and pending input regions of the icon [`wl_surface`](@ref) are cleared, and [`wl_surface`](@ref).set\\_input\\_region is ignored until the [`wl_surface`](@ref) is no longer used as the icon surface. When the use as an icon ends, the current and pending input regions become undefined, and the [`wl_surface`](@ref) is unmapped.
"""
function wl_data_device_start_drag(wl_data_device_, source, origin, icon, serial)
    ccall((:wl_data_device_start_drag, libwayland_client), Cvoid, (Ptr{wl_data_device}, Ptr{wl_data_source}, Ptr{wl_surface}, Ptr{wl_surface}, UInt32), wl_data_device_, source, origin, icon, serial)
end

"""
    wl_data_device_set_selection(wl_data_device_, source, serial)

` iface_wl_data_device`

This request asks the compositor to set the selection to the data from the source on behalf of the client.

To unset the selection, set the source to NULL.
"""
function wl_data_device_set_selection(wl_data_device_, source, serial)
    ccall((:wl_data_device_set_selection, libwayland_client), Cvoid, (Ptr{wl_data_device}, Ptr{wl_data_source}, UInt32), wl_data_device_, source, serial)
end

"""
    wl_data_device_release(wl_data_device_)

` iface_wl_data_device`

This request destroys the data device.
"""
function wl_data_device_release(wl_data_device_)
    ccall((:wl_data_device_release, libwayland_client), Cvoid, (Ptr{wl_data_device},), wl_data_device_)
end

"""
    wl_data_device_manager_dnd_action

` iface_wl_data_device_manager`

drag and drop actions

This is a bitmask of the available/preferred actions in a drag-and-drop operation.

In the compositor, the selected action is a result of matching the actions offered by the source and destination sides. "action" events with a "none" action will be sent to both source and destination if there is no match. All further checks will effectively happen on (source actions ∩ destination actions).

In addition, compositors may also pick different actions in reaction to key modifiers being pressed. One common design that is used in major toolkits (and the behavior recommended for compositors) is:

- If no modifiers are pressed, the first match (in bit order) will be used. - Pressing Shift selects "move", if enabled in the mask. - Pressing Control selects "copy", if enabled in the mask.

Behavior beyond that is considered implementation-dependent. Compositors may for example bind other modifiers (like Alt/Meta) or drags initiated with other buttons than BTN\\_LEFT to specific actions (e.g. "ask").

| Enumerator                                         | Note         |
| :------------------------------------------------- | :----------- |
| WL\\_DATA\\_DEVICE\\_MANAGER\\_DND\\_ACTION\\_NONE | no action    |
| WL\\_DATA\\_DEVICE\\_MANAGER\\_DND\\_ACTION\\_COPY | copy action  |
| WL\\_DATA\\_DEVICE\\_MANAGER\\_DND\\_ACTION\\_MOVE | move action  |
| WL\\_DATA\\_DEVICE\\_MANAGER\\_DND\\_ACTION\\_ASK  | ask action   |
"""
@cenum wl_data_device_manager_dnd_action::UInt32 begin
    WL_DATA_DEVICE_MANAGER_DND_ACTION_NONE = 0
    WL_DATA_DEVICE_MANAGER_DND_ACTION_COPY = 1
    WL_DATA_DEVICE_MANAGER_DND_ACTION_MOVE = 2
    WL_DATA_DEVICE_MANAGER_DND_ACTION_ASK = 4
end

"""
    wl_data_device_manager_set_user_data(wl_data_device_manager_, user_data)

` iface_wl_data_device_manager `
"""
function wl_data_device_manager_set_user_data(wl_data_device_manager_, user_data)
    ccall((:wl_data_device_manager_set_user_data, libwayland_client), Cvoid, (Ptr{wl_data_device_manager}, Ptr{Cvoid}), wl_data_device_manager_, user_data)
end

"""
    wl_data_device_manager_get_user_data(wl_data_device_manager_)

` iface_wl_data_device_manager `
"""
function wl_data_device_manager_get_user_data(wl_data_device_manager_)
    ccall((:wl_data_device_manager_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_data_device_manager},), wl_data_device_manager_)
end

function wl_data_device_manager_get_version(wl_data_device_manager_)
    ccall((:wl_data_device_manager_get_version, libwayland_client), UInt32, (Ptr{wl_data_device_manager},), wl_data_device_manager_)
end

"""
    wl_data_device_manager_destroy(wl_data_device_manager_)

` iface_wl_data_device_manager `
"""
function wl_data_device_manager_destroy(wl_data_device_manager_)
    ccall((:wl_data_device_manager_destroy, libwayland_client), Cvoid, (Ptr{wl_data_device_manager},), wl_data_device_manager_)
end

"""
    wl_data_device_manager_create_data_source(wl_data_device_manager_)

` iface_wl_data_device_manager`

Create a new data source.
"""
function wl_data_device_manager_create_data_source(wl_data_device_manager_)
    ccall((:wl_data_device_manager_create_data_source, libwayland_client), Ptr{wl_data_source}, (Ptr{wl_data_device_manager},), wl_data_device_manager_)
end

"""
    wl_data_device_manager_get_data_device(wl_data_device_manager_, seat)

` iface_wl_data_device_manager`

Create a new data device for a given seat.
"""
function wl_data_device_manager_get_data_device(wl_data_device_manager_, seat)
    ccall((:wl_data_device_manager_get_data_device, libwayland_client), Ptr{wl_data_device}, (Ptr{wl_data_device_manager}, Ptr{wl_seat}), wl_data_device_manager_, seat)
end

"""
    wl_shell_error

| Enumerator                | Note                                         |
| :------------------------ | :------------------------------------------- |
| WL\\_SHELL\\_ERROR\\_ROLE | given [`wl_surface`](@ref) has another role  |
"""
@cenum wl_shell_error::UInt32 begin
    WL_SHELL_ERROR_ROLE = 0
end

"""
    wl_shell_set_user_data(wl_shell_, user_data)

` iface_wl_shell `
"""
function wl_shell_set_user_data(wl_shell_, user_data)
    ccall((:wl_shell_set_user_data, libwayland_client), Cvoid, (Ptr{wl_shell}, Ptr{Cvoid}), wl_shell_, user_data)
end

"""
    wl_shell_get_user_data(wl_shell_)

` iface_wl_shell `
"""
function wl_shell_get_user_data(wl_shell_)
    ccall((:wl_shell_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_shell},), wl_shell_)
end

function wl_shell_get_version(wl_shell_)
    ccall((:wl_shell_get_version, libwayland_client), UInt32, (Ptr{wl_shell},), wl_shell_)
end

"""
    wl_shell_destroy(wl_shell_)

` iface_wl_shell `
"""
function wl_shell_destroy(wl_shell_)
    ccall((:wl_shell_destroy, libwayland_client), Cvoid, (Ptr{wl_shell},), wl_shell_)
end

"""
    wl_shell_get_shell_surface(wl_shell_, surface)

` iface_wl_shell`

Create a shell surface for an existing surface. This gives the [`wl_surface`](@ref) the role of a shell surface. If the [`wl_surface`](@ref) already has another role, it raises a protocol error.

Only one shell surface can be associated with a given surface.
"""
function wl_shell_get_shell_surface(wl_shell_, surface)
    ccall((:wl_shell_get_shell_surface, libwayland_client), Ptr{wl_shell_surface}, (Ptr{wl_shell}, Ptr{wl_surface}), wl_shell_, surface)
end

"""
    wl_shell_surface_resize

` iface_wl_shell_surface`

edge values for resizing

These values are used to indicate which edge of a surface is being dragged in a resize operation. The server may use this information to adapt its behavior, e.g. choose an appropriate cursor image.

| Enumerator                                     | Note                    |
| :--------------------------------------------- | :---------------------- |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_NONE           | no edge                 |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_TOP            | top edge                |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_BOTTOM         | bottom edge             |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_LEFT           | left edge               |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_TOP\\_LEFT     | top and left edges      |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_BOTTOM\\_LEFT  | bottom and left edges   |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_RIGHT          | right edge              |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_TOP\\_RIGHT    | top and right edges     |
| WL\\_SHELL\\_SURFACE\\_RESIZE\\_BOTTOM\\_RIGHT | bottom and right edges  |
"""
@cenum wl_shell_surface_resize::UInt32 begin
    WL_SHELL_SURFACE_RESIZE_NONE = 0
    WL_SHELL_SURFACE_RESIZE_TOP = 1
    WL_SHELL_SURFACE_RESIZE_BOTTOM = 2
    WL_SHELL_SURFACE_RESIZE_LEFT = 4
    WL_SHELL_SURFACE_RESIZE_TOP_LEFT = 5
    WL_SHELL_SURFACE_RESIZE_BOTTOM_LEFT = 6
    WL_SHELL_SURFACE_RESIZE_RIGHT = 8
    WL_SHELL_SURFACE_RESIZE_TOP_RIGHT = 9
    WL_SHELL_SURFACE_RESIZE_BOTTOM_RIGHT = 10
end

"""
    wl_shell_surface_transient

` iface_wl_shell_surface`

details of transient behaviour

These flags specify details of the expected behaviour of transient surfaces. Used in the set\\_transient request.

| Enumerator                                  | Note                       |
| :------------------------------------------ | :------------------------- |
| WL\\_SHELL\\_SURFACE\\_TRANSIENT\\_INACTIVE | do not set keyboard focus  |
"""
@cenum wl_shell_surface_transient::UInt32 begin
    WL_SHELL_SURFACE_TRANSIENT_INACTIVE = 1
end

"""
    wl_shell_surface_fullscreen_method

` iface_wl_shell_surface`

different method to set the surface fullscreen

Hints to indicate to the compositor how to deal with a conflict between the dimensions of the surface and the dimensions of the output. The compositor is free to ignore this parameter.

| Enumerator                                           | Note                                                                                                             |
| :--------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| WL\\_SHELL\\_SURFACE\\_FULLSCREEN\\_METHOD\\_DEFAULT | no preference, apply default policy                                                                              |
| WL\\_SHELL\\_SURFACE\\_FULLSCREEN\\_METHOD\\_SCALE   | scale, preserve the surface's aspect ratio and center on output                                                  |
| WL\\_SHELL\\_SURFACE\\_FULLSCREEN\\_METHOD\\_DRIVER  | switch output mode to the smallest mode that can fit the surface, add black borders to compensate size mismatch  |
| WL\\_SHELL\\_SURFACE\\_FULLSCREEN\\_METHOD\\_FILL    | no upscaling, center on output and add black borders to compensate size mismatch                                 |
"""
@cenum wl_shell_surface_fullscreen_method::UInt32 begin
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_DEFAULT = 0
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_SCALE = 1
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_DRIVER = 2
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_FILL = 3
end

"""
    wl_shell_surface_listener

` iface_wl_shell_surface`

` wl_shell_surface_listener`

| Field        | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| :----------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ping         | ping client  Ping a client to check if it is receiving events and sending requests. A client is expected to reply with a pong request.  ### Parameters * `serial`: serial number of the ping                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| configure    | suggest resize  The configure event asks the client to resize its surface.  The size is a hint, in the sense that the client is free to ignore it if it doesn't resize, pick a smaller size (to satisfy aspect ratio or resize in steps of NxM pixels).  The edges parameter provides a hint about how the surface was resized. The client may use this information to decide how to adjust its content to the new size (e.g. a scrolling area might adjust its content position to leave the viewable content unmoved).  The client is free to dismiss all but the last configure event it received.  The width and height arguments specify the size of the window in surface-local coordinates.  ### Parameters * `edges`: how the surface was resized * `width`: new width of the surface * `height`: new height of the surface |
| popup\\_done | popup interaction is done  The popup\\_done event is sent out when a popup grab is broken, that is, when the user clicks a surface that doesn't belong to the client owning the popup surface.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
"""
struct wl_shell_surface_listener
    ping::Ptr{Cvoid}
    configure::Ptr{Cvoid}
    popup_done::Ptr{Cvoid}
end

"""
    wl_shell_surface_add_listener(wl_shell_surface_, listener, data)

` iface_wl_shell_surface`
"""
function wl_shell_surface_add_listener(wl_shell_surface_, listener, data)
    ccall((:wl_shell_surface_add_listener, libwayland_client), Cint, (Ptr{wl_shell_surface}, Ptr{wl_shell_surface_listener}, Ptr{Cvoid}), wl_shell_surface_, listener, data)
end

"""
    wl_shell_surface_set_user_data(wl_shell_surface_, user_data)

` iface_wl_shell_surface `
"""
function wl_shell_surface_set_user_data(wl_shell_surface_, user_data)
    ccall((:wl_shell_surface_set_user_data, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{Cvoid}), wl_shell_surface_, user_data)
end

"""
    wl_shell_surface_get_user_data(wl_shell_surface_)

` iface_wl_shell_surface `
"""
function wl_shell_surface_get_user_data(wl_shell_surface_)
    ccall((:wl_shell_surface_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_shell_surface},), wl_shell_surface_)
end

function wl_shell_surface_get_version(wl_shell_surface_)
    ccall((:wl_shell_surface_get_version, libwayland_client), UInt32, (Ptr{wl_shell_surface},), wl_shell_surface_)
end

"""
    wl_shell_surface_destroy(wl_shell_surface_)

` iface_wl_shell_surface `
"""
function wl_shell_surface_destroy(wl_shell_surface_)
    ccall((:wl_shell_surface_destroy, libwayland_client), Cvoid, (Ptr{wl_shell_surface},), wl_shell_surface_)
end

"""
    wl_shell_surface_pong(wl_shell_surface_, serial)

` iface_wl_shell_surface`

A client must respond to a ping event with a pong request or the client may be deemed unresponsive.
"""
function wl_shell_surface_pong(wl_shell_surface_, serial)
    ccall((:wl_shell_surface_pong, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, UInt32), wl_shell_surface_, serial)
end

"""
    wl_shell_surface_move(wl_shell_surface_, seat, serial)

` iface_wl_shell_surface`

Start a pointer-driven move of the surface.

This request must be used in response to a button press event. The server may ignore move requests depending on the state of the surface (e.g. fullscreen or maximized).
"""
function wl_shell_surface_move(wl_shell_surface_, seat, serial)
    ccall((:wl_shell_surface_move, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{wl_seat}, UInt32), wl_shell_surface_, seat, serial)
end

"""
    wl_shell_surface_resize(wl_shell_surface_, seat, serial, edges)

` iface_wl_shell_surface`

Start a pointer-driven resizing of the surface.

This request must be used in response to a button press event. The server may ignore resize requests depending on the state of the surface (e.g. fullscreen or maximized).
"""
function wl_shell_surface_resize(wl_shell_surface_, seat, serial, edges)
    ccall((:wl_shell_surface_resize, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{wl_seat}, UInt32, UInt32), wl_shell_surface_, seat, serial, edges)
end

"""
    wl_shell_surface_set_toplevel(wl_shell_surface_)

` iface_wl_shell_surface`

Map the surface as a toplevel surface.

A toplevel surface is not fullscreen, maximized or transient.
"""
function wl_shell_surface_set_toplevel(wl_shell_surface_)
    ccall((:wl_shell_surface_set_toplevel, libwayland_client), Cvoid, (Ptr{wl_shell_surface},), wl_shell_surface_)
end

"""
    wl_shell_surface_set_transient(wl_shell_surface_, parent, x, y, flags)

` iface_wl_shell_surface`

Map the surface relative to an existing surface.

The x and y arguments specify the location of the upper left corner of the surface relative to the upper left corner of the parent surface, in surface-local coordinates.

The flags argument controls details of the transient behaviour.
"""
function wl_shell_surface_set_transient(wl_shell_surface_, parent, x, y, flags)
    ccall((:wl_shell_surface_set_transient, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{wl_surface}, Int32, Int32, UInt32), wl_shell_surface_, parent, x, y, flags)
end

"""
    wl_shell_surface_set_fullscreen(wl_shell_surface_, method, framerate, output)

` iface_wl_shell_surface`

Map the surface as a fullscreen surface.

If an output parameter is given then the surface will be made fullscreen on that output. If the client does not specify the output then the compositor will apply its policy - usually choosing the output on which the surface has the biggest surface area.

The client may specify a method to resolve a size conflict between the output size and the surface size - this is provided through the method parameter.

The framerate parameter is used only when the method is set to "driver", to indicate the preferred framerate. A value of 0 indicates that the client does not care about framerate. The framerate is specified in mHz, that is framerate of 60000 is 60Hz.

A method of "scale" or "driver" implies a scaling operation of the surface, either via a direct scaling operation or a change of the output mode. This will override any kind of output scaling, so that mapping a surface with a buffer size equal to the mode can fill the screen independent of buffer\\_scale.

A method of "fill" means we don't scale up the buffer, however any output scale is applied. This means that you may run into an edge case where the application maps a buffer with the same size of the output mode but buffer\\_scale 1 (thus making a surface larger than the output). In this case it is allowed to downscale the results to fit the screen.

The compositor must reply to this request with a configure event with the dimensions for the output on which the surface will be made fullscreen.
"""
function wl_shell_surface_set_fullscreen(wl_shell_surface_, method, framerate, output)
    ccall((:wl_shell_surface_set_fullscreen, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, UInt32, UInt32, Ptr{wl_output}), wl_shell_surface_, method, framerate, output)
end

"""
    wl_shell_surface_set_popup(wl_shell_surface_, seat, serial, parent, x, y, flags)

` iface_wl_shell_surface`

Map the surface as a popup.

A popup surface is a transient surface with an added pointer grab.

An existing implicit grab will be changed to owner-events mode, and the popup grab will continue after the implicit grab ends (i.e. releasing the mouse button does not cause the popup to be unmapped).

The popup grab continues until the window is destroyed or a mouse button is pressed in any other client's window. A click in any of the client's surfaces is reported as normal, however, clicks in other clients' surfaces will be discarded and trigger the callback.

The x and y arguments specify the location of the upper left corner of the surface relative to the upper left corner of the parent surface, in surface-local coordinates.
"""
function wl_shell_surface_set_popup(wl_shell_surface_, seat, serial, parent, x, y, flags)
    ccall((:wl_shell_surface_set_popup, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{wl_seat}, UInt32, Ptr{wl_surface}, Int32, Int32, UInt32), wl_shell_surface_, seat, serial, parent, x, y, flags)
end

"""
    wl_shell_surface_set_maximized(wl_shell_surface_, output)

` iface_wl_shell_surface`

Map the surface as a maximized surface.

If an output parameter is given then the surface will be maximized on that output. If the client does not specify the output then the compositor will apply its policy - usually choosing the output on which the surface has the biggest surface area.

The compositor will reply with a configure event telling the expected new surface size. The operation is completed on the next buffer attach to this surface.

A maximized surface typically fills the entire output it is bound to, except for desktop elements such as panels. This is the main difference between a maximized shell surface and a fullscreen shell surface.

The details depend on the compositor implementation.
"""
function wl_shell_surface_set_maximized(wl_shell_surface_, output)
    ccall((:wl_shell_surface_set_maximized, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{wl_output}), wl_shell_surface_, output)
end

"""
    wl_shell_surface_set_title(wl_shell_surface_, title)

` iface_wl_shell_surface`

Set a short title for the surface.

This string may be used to identify the surface in a task bar, window list, or other user interface elements provided by the compositor.

The string must be encoded in UTF-8.
"""
function wl_shell_surface_set_title(wl_shell_surface_, title)
    ccall((:wl_shell_surface_set_title, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{Cchar}), wl_shell_surface_, title)
end

"""
    wl_shell_surface_set_class(wl_shell_surface_, class_)

` iface_wl_shell_surface`

Set a class for the surface.

The surface class identifies the general class of applications to which the surface belongs. A common convention is to use the file name (or the full path if it is a non-standard location) of the application's .desktop file as the class.
"""
function wl_shell_surface_set_class(wl_shell_surface_, class_)
    ccall((:wl_shell_surface_set_class, libwayland_client), Cvoid, (Ptr{wl_shell_surface}, Ptr{Cchar}), wl_shell_surface_, class_)
end

"""
    wl_surface_error

` iface_wl_surface`

[`wl_surface`](@ref) error values

These errors can be emitted in response to [`wl_surface`](@ref) requests.

| Enumerator                                 | Note                               |
| :----------------------------------------- | :--------------------------------- |
| WL\\_SURFACE\\_ERROR\\_INVALID\\_SCALE     | buffer scale value is invalid      |
| WL\\_SURFACE\\_ERROR\\_INVALID\\_TRANSFORM | buffer transform value is invalid  |
| WL\\_SURFACE\\_ERROR\\_INVALID\\_SIZE      | buffer size is invalid             |
"""
@cenum wl_surface_error::UInt32 begin
    WL_SURFACE_ERROR_INVALID_SCALE = 0
    WL_SURFACE_ERROR_INVALID_TRANSFORM = 1
    WL_SURFACE_ERROR_INVALID_SIZE = 2
end

"""
    wl_surface_listener

` iface_wl_surface`

` wl_surface_listener`

| Field | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| :---- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| enter | surface enters an output  This is emitted whenever a surface's creation, movement, or resizing results in some part of it being within the scanout region of an output.  Note that a surface may be overlapping with zero or more outputs.  ### Parameters * `output`: output entered by the surface                                                                                                                                                                                                                                                   |
| leave | surface leaves an output  This is emitted whenever a surface's creation, movement, or resizing results in it no longer having any part of it within the scanout region of an output.  Clients should not use the number of outputs the surface is on for frame throttling purposes. The surface might be hidden even if no leave event has been sent, and the compositor might expect new surface content updates even if no enter event has been sent. The frame event should be used instead.  ### Parameters * `output`: output left by the surface |
"""
struct wl_surface_listener
    enter::Ptr{Cvoid}
    leave::Ptr{Cvoid}
end

"""
    wl_surface_add_listener(wl_surface_, listener, data)

` iface_wl_surface`
"""
function wl_surface_add_listener(wl_surface_, listener, data)
    ccall((:wl_surface_add_listener, libwayland_client), Cint, (Ptr{wl_surface}, Ptr{wl_surface_listener}, Ptr{Cvoid}), wl_surface_, listener, data)
end

"""
    wl_surface_set_user_data(wl_surface_, user_data)

` iface_wl_surface `
"""
function wl_surface_set_user_data(wl_surface_, user_data)
    ccall((:wl_surface_set_user_data, libwayland_client), Cvoid, (Ptr{wl_surface}, Ptr{Cvoid}), wl_surface_, user_data)
end

"""
    wl_surface_get_user_data(wl_surface_)

` iface_wl_surface `
"""
function wl_surface_get_user_data(wl_surface_)
    ccall((:wl_surface_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_surface},), wl_surface_)
end

function wl_surface_get_version(wl_surface_)
    ccall((:wl_surface_get_version, libwayland_client), UInt32, (Ptr{wl_surface},), wl_surface_)
end

"""
    wl_surface_destroy(wl_surface_)

` iface_wl_surface`

Deletes the surface and invalidates its object ID.
"""
function wl_surface_destroy(wl_surface_)
    ccall((:wl_surface_destroy, libwayland_client), Cvoid, (Ptr{wl_surface},), wl_surface_)
end

"""
    wl_surface_attach(wl_surface_, buffer, x, y)

` iface_wl_surface`

Set a buffer as the content of this surface.

The new size of the surface is calculated based on the buffer size transformed by the inverse buffer\\_transform and the inverse buffer\\_scale. This means that at commit time the supplied buffer size must be an integer multiple of the buffer\\_scale. If that's not the case, an invalid\\_size error is sent.

The x and y arguments specify the location of the new pending buffer's upper left corner, relative to the current buffer's upper left corner, in surface-local coordinates. In other words, the x and y, combined with the new surface size define in which directions the surface's size changes.

Surface contents are double-buffered state, see [`wl_surface`](@ref).commit.

The initial surface contents are void; there is no content. [`wl_surface`](@ref).attach assigns the given [`wl_buffer`](@ref) as the pending [`wl_buffer`](@ref). [`wl_surface`](@ref).commit makes the pending [`wl_buffer`](@ref) the new surface contents, and the size of the surface becomes the size calculated from the [`wl_buffer`](@ref), as described above. After commit, there is no pending buffer until the next attach.

Committing a pending [`wl_buffer`](@ref) allows the compositor to read the pixels in the [`wl_buffer`](@ref). The compositor may access the pixels at any time after the [`wl_surface`](@ref).commit request. When the compositor will not access the pixels anymore, it will send the [`wl_buffer`](@ref).release event. Only after receiving [`wl_buffer`](@ref).release, the client may reuse the [`wl_buffer`](@ref). A [`wl_buffer`](@ref) that has been attached and then replaced by another attach instead of committed will not receive a release event, and is not used by the compositor.

If a pending [`wl_buffer`](@ref) has been committed to more than one [`wl_surface`](@ref), the delivery of [`wl_buffer`](@ref).release events becomes undefined. A well behaved client should not rely on [`wl_buffer`](@ref).release events in this case. Alternatively, a client could create multiple [`wl_buffer`](@ref) objects from the same backing storage or use wp\\_linux\\_buffer\\_release.

Destroying the [`wl_buffer`](@ref) after [`wl_buffer`](@ref).release does not change the surface contents. However, if the client destroys the [`wl_buffer`](@ref) before receiving the [`wl_buffer`](@ref).release event, the surface contents become undefined immediately.

If [`wl_surface`](@ref).attach is sent with a NULL [`wl_buffer`](@ref), the following [`wl_surface`](@ref).commit will remove the surface content.
"""
function wl_surface_attach(wl_surface_, buffer, x, y)
    ccall((:wl_surface_attach, libwayland_client), Cvoid, (Ptr{wl_surface}, Ptr{wl_buffer}, Int32, Int32), wl_surface_, buffer, x, y)
end

"""
    wl_surface_damage(wl_surface_, x, y, width, height)

` iface_wl_surface`

This request is used to describe the regions where the pending buffer is different from the current surface contents, and where the surface therefore needs to be repainted. The compositor ignores the parts of the damage that fall outside of the surface.

Damage is double-buffered state, see [`wl_surface`](@ref).commit.

The damage rectangle is specified in surface-local coordinates, where x and y specify the upper left corner of the damage rectangle.

The initial value for pending damage is empty: no damage. [`wl_surface`](@ref).damage adds pending damage: the new pending damage is the union of old pending damage and the given rectangle.

[`wl_surface`](@ref).commit assigns pending damage as the current damage, and clears pending damage. The server will clear the current damage as it repaints the surface.

Note! New clients should not use this request. Instead damage can be posted with [`wl_surface`](@ref).damage\\_buffer which uses buffer coordinates instead of surface coordinates.
"""
function wl_surface_damage(wl_surface_, x, y, width, height)
    ccall((:wl_surface_damage, libwayland_client), Cvoid, (Ptr{wl_surface}, Int32, Int32, Int32, Int32), wl_surface_, x, y, width, height)
end

"""
    wl_surface_frame(wl_surface_)

` iface_wl_surface`

Request a notification when it is a good time to start drawing a new frame, by creating a frame callback. This is useful for throttling redrawing operations, and driving animations.

When a client is animating on a [`wl_surface`](@ref), it can use the 'frame' request to get notified when it is a good time to draw and commit the next frame of animation. If the client commits an update earlier than that, it is likely that some updates will not make it to the display, and the client is wasting resources by drawing too often.

The frame request will take effect on the next [`wl_surface`](@ref).commit. The notification will only be posted for one frame unless requested again. For a [`wl_surface`](@ref), the notifications are posted in the order the frame requests were committed.

The server must send the notifications so that a client will not send excessive updates, while still allowing the highest possible update rate for clients that wait for the reply before drawing again. The server should give some time for the client to draw and commit after sending the frame callback events to let it hit the next output refresh.

A server should avoid signaling the frame callbacks if the surface is not visible in any way, e.g. the surface is off-screen, or completely obscured by other opaque surfaces.

The object returned by this request will be destroyed by the compositor after the callback is fired and as such the client must not attempt to use it after that point.

The callback\\_data passed in the callback is the current time, in milliseconds, with an undefined base.
"""
function wl_surface_frame(wl_surface_)
    ccall((:wl_surface_frame, libwayland_client), Ptr{wl_callback}, (Ptr{wl_surface},), wl_surface_)
end

"""
    wl_surface_set_opaque_region(wl_surface_, region)

` iface_wl_surface`

This request sets the region of the surface that contains opaque content.

The opaque region is an optimization hint for the compositor that lets it optimize the redrawing of content behind opaque regions. Setting an opaque region is not required for correct behaviour, but marking transparent content as opaque will result in repaint artifacts.

The opaque region is specified in surface-local coordinates.

The compositor ignores the parts of the opaque region that fall outside of the surface.

Opaque region is double-buffered state, see [`wl_surface`](@ref).commit.

[`wl_surface`](@ref).set\\_opaque\\_region changes the pending opaque region. [`wl_surface`](@ref).commit copies the pending region to the current region. Otherwise, the pending and current regions are never changed.

The initial value for an opaque region is empty. Setting the pending opaque region has copy semantics, and the [`wl_region`](@ref) object can be destroyed immediately. A NULL [`wl_region`](@ref) causes the pending opaque region to be set to empty.
"""
function wl_surface_set_opaque_region(wl_surface_, region)
    ccall((:wl_surface_set_opaque_region, libwayland_client), Cvoid, (Ptr{wl_surface}, Ptr{wl_region}), wl_surface_, region)
end

"""
    wl_surface_set_input_region(wl_surface_, region)

` iface_wl_surface`

This request sets the region of the surface that can receive pointer and touch events.

Input events happening outside of this region will try the next surface in the server surface stack. The compositor ignores the parts of the input region that fall outside of the surface.

The input region is specified in surface-local coordinates.

Input region is double-buffered state, see [`wl_surface`](@ref).commit.

[`wl_surface`](@ref).set\\_input\\_region changes the pending input region. [`wl_surface`](@ref).commit copies the pending region to the current region. Otherwise the pending and current regions are never changed, except cursor and icon surfaces are special cases, see [`wl_pointer`](@ref).set\\_cursor and [`wl_data_device`](@ref).start\\_drag.

The initial value for an input region is infinite. That means the whole surface will accept input. Setting the pending input region has copy semantics, and the [`wl_region`](@ref) object can be destroyed immediately. A NULL [`wl_region`](@ref) causes the input region to be set to infinite.
"""
function wl_surface_set_input_region(wl_surface_, region)
    ccall((:wl_surface_set_input_region, libwayland_client), Cvoid, (Ptr{wl_surface}, Ptr{wl_region}), wl_surface_, region)
end

"""
    wl_surface_commit(wl_surface_)

` iface_wl_surface`

Surface state (input, opaque, and damage regions, attached buffers, etc.) is double-buffered. Protocol requests modify the pending state, as opposed to the current state in use by the compositor. A commit request atomically applies all pending state, replacing the current state. After commit, the new pending state is as documented for each related request.

On commit, a pending [`wl_buffer`](@ref) is applied first, and all other state second. This means that all coordinates in double-buffered state are relative to the new [`wl_buffer`](@ref) coming into use, except for [`wl_surface`](@ref).attach itself. If there is no pending [`wl_buffer`](@ref), the coordinates are relative to the current surface contents.

All requests that need a commit to become effective are documented to affect double-buffered state.

Other interfaces may add further double-buffered surface state.
"""
function wl_surface_commit(wl_surface_)
    ccall((:wl_surface_commit, libwayland_client), Cvoid, (Ptr{wl_surface},), wl_surface_)
end

"""
    wl_surface_set_buffer_transform(wl_surface_, transform)

` iface_wl_surface`

This request sets an optional transformation on how the compositor interprets the contents of the buffer attached to the surface. The accepted values for the transform parameter are the values for [`wl_output`](@ref).transform.

Buffer transform is double-buffered state, see [`wl_surface`](@ref).commit.

A newly created surface has its buffer transformation set to normal.

[`wl_surface`](@ref).set\\_buffer\\_transform changes the pending buffer transformation. [`wl_surface`](@ref).commit copies the pending buffer transformation to the current one. Otherwise, the pending and current values are never changed.

The purpose of this request is to allow clients to render content according to the output transform, thus permitting the compositor to use certain optimizations even if the display is rotated. Using hardware overlays and scanning out a client buffer for fullscreen surfaces are examples of such optimizations. Those optimizations are highly dependent on the compositor implementation, so the use of this request should be considered on a case-by-case basis.

Note that if the transform value includes 90 or 270 degree rotation, the width of the buffer will become the surface height and the height of the buffer will become the surface width.

If transform is not one of the values from the [`wl_output`](@ref).transform enum the invalid\\_transform protocol error is raised.
"""
function wl_surface_set_buffer_transform(wl_surface_, transform)
    ccall((:wl_surface_set_buffer_transform, libwayland_client), Cvoid, (Ptr{wl_surface}, Int32), wl_surface_, transform)
end

"""
    wl_surface_set_buffer_scale(wl_surface_, scale)

` iface_wl_surface`

This request sets an optional scaling factor on how the compositor interprets the contents of the buffer attached to the window.

Buffer scale is double-buffered state, see [`wl_surface`](@ref).commit.

A newly created surface has its buffer scale set to 1.

[`wl_surface`](@ref).set\\_buffer\\_scale changes the pending buffer scale. [`wl_surface`](@ref).commit copies the pending buffer scale to the current one. Otherwise, the pending and current values are never changed.

The purpose of this request is to allow clients to supply higher resolution buffer data for use on high resolution outputs. It is intended that you pick the same buffer scale as the scale of the output that the surface is displayed on. This means the compositor can avoid scaling when rendering the surface on that output.

Note that if the scale is larger than 1, then you have to attach a buffer that is larger (by a factor of scale in each dimension) than the desired surface size.

If scale is not positive the invalid\\_scale protocol error is raised.
"""
function wl_surface_set_buffer_scale(wl_surface_, scale)
    ccall((:wl_surface_set_buffer_scale, libwayland_client), Cvoid, (Ptr{wl_surface}, Int32), wl_surface_, scale)
end

"""
    wl_surface_damage_buffer(wl_surface_, x, y, width, height)

` iface_wl_surface`

This request is used to describe the regions where the pending buffer is different from the current surface contents, and where the surface therefore needs to be repainted. The compositor ignores the parts of the damage that fall outside of the surface.

Damage is double-buffered state, see [`wl_surface`](@ref).commit.

The damage rectangle is specified in buffer coordinates, where x and y specify the upper left corner of the damage rectangle.

The initial value for pending damage is empty: no damage. [`wl_surface`](@ref).damage\\_buffer adds pending damage: the new pending damage is the union of old pending damage and the given rectangle.

[`wl_surface`](@ref).commit assigns pending damage as the current damage, and clears pending damage. The server will clear the current damage as it repaints the surface.

This request differs from [`wl_surface`](@ref).damage in only one way - it takes damage in buffer coordinates instead of surface-local coordinates. While this generally is more intuitive than surface coordinates, it is especially desirable when using wp\\_viewport or when a drawing library (like EGL) is unaware of buffer scale and buffer transform.

Note: Because buffer transformation changes and damage requests may be interleaved in the protocol stream, it is impossible to determine the actual mapping between surface and buffer damage until [`wl_surface`](@ref).commit time. Therefore, compositors wishing to take both kinds of damage into account will have to accumulate damage from the two requests separately and only transform from one to the other after receiving the [`wl_surface`](@ref).commit.
"""
function wl_surface_damage_buffer(wl_surface_, x, y, width, height)
    ccall((:wl_surface_damage_buffer, libwayland_client), Cvoid, (Ptr{wl_surface}, Int32, Int32, Int32, Int32), wl_surface_, x, y, width, height)
end

"""
    wl_seat_capability

` iface_wl_seat`

seat capability bitmask

This is a bitmask of capabilities this seat has; if a member is set, then it is present on the seat.

| Enumerator                        | Note                                |
| :-------------------------------- | :---------------------------------- |
| WL\\_SEAT\\_CAPABILITY\\_POINTER  | the seat has pointer devices        |
| WL\\_SEAT\\_CAPABILITY\\_KEYBOARD | the seat has one or more keyboards  |
| WL\\_SEAT\\_CAPABILITY\\_TOUCH    | the seat has touch devices          |
"""
@cenum wl_seat_capability::UInt32 begin
    WL_SEAT_CAPABILITY_POINTER = 1
    WL_SEAT_CAPABILITY_KEYBOARD = 2
    WL_SEAT_CAPABILITY_TOUCH = 4
end

"""
    wl_seat_error

` iface_wl_seat`

[`wl_seat`](@ref) error values

These errors can be emitted in response to [`wl_seat`](@ref) requests.

| Enumerator                               | Note                                                                                         |
| :--------------------------------------- | :------------------------------------------------------------------------------------------- |
| WL\\_SEAT\\_ERROR\\_MISSING\\_CAPABILITY | get\\_pointer, get\\_keyboard or get\\_touch called on seat without the matching capability  |
"""
@cenum wl_seat_error::UInt32 begin
    WL_SEAT_ERROR_MISSING_CAPABILITY = 0
end

"""
    wl_seat_listener

` iface_wl_seat`

` wl_seat_listener`

| Field        | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| :----------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| capabilities | seat capabilities changed  This is emitted whenever a seat gains or loses the pointer, keyboard or touch capabilities. The argument is a capability enum containing the complete set of capabilities this seat has.  When the pointer capability is added, a client may create a [`wl_pointer`](@ref) object using the [`wl_seat`](@ref).get\\_pointer request. This object will receive pointer events until the capability is removed in the future.  When the pointer capability is removed, a client should destroy the [`wl_pointer`](@ref) objects associated with the seat where the capability was removed, using the [`wl_pointer`](@ref).release request. No further pointer events will be received on these objects.  In some compositors, if a seat regains the pointer capability and a client has a previously obtained [`wl_pointer`](@ref) object of version 4 or less, that object may start sending pointer events again. This behavior is considered a misinterpretation of the intended behavior and must not be relied upon by the client. [`wl_pointer`](@ref) objects of version 5 or later must not send events if created before the most recent event notifying the client of an added pointer capability.  The above behavior also applies to [`wl_keyboard`](@ref) and [`wl_touch`](@ref) with the keyboard and touch capabilities, respectively.  ### Parameters * `capabilities`: capabilities of the seat |
| name         | unique identifier for this seat  In a multiseat configuration this can be used by the client to help identify which physical devices the seat represents. Based on the seat configuration used by the compositor.  \\since 2  ### Parameters * `name`: seat identifier                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
"""
struct wl_seat_listener
    capabilities::Ptr{Cvoid}
    name::Ptr{Cvoid}
end

"""
    wl_seat_add_listener(wl_seat_, listener, data)

` iface_wl_seat`
"""
function wl_seat_add_listener(wl_seat_, listener, data)
    ccall((:wl_seat_add_listener, libwayland_client), Cint, (Ptr{wl_seat}, Ptr{wl_seat_listener}, Ptr{Cvoid}), wl_seat_, listener, data)
end

"""
    wl_seat_set_user_data(wl_seat_, user_data)

` iface_wl_seat `
"""
function wl_seat_set_user_data(wl_seat_, user_data)
    ccall((:wl_seat_set_user_data, libwayland_client), Cvoid, (Ptr{wl_seat}, Ptr{Cvoid}), wl_seat_, user_data)
end

"""
    wl_seat_get_user_data(wl_seat_)

` iface_wl_seat `
"""
function wl_seat_get_user_data(wl_seat_)
    ccall((:wl_seat_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_seat},), wl_seat_)
end

function wl_seat_get_version(wl_seat_)
    ccall((:wl_seat_get_version, libwayland_client), UInt32, (Ptr{wl_seat},), wl_seat_)
end

"""
    wl_seat_destroy(wl_seat_)

` iface_wl_seat `
"""
function wl_seat_destroy(wl_seat_)
    ccall((:wl_seat_destroy, libwayland_client), Cvoid, (Ptr{wl_seat},), wl_seat_)
end

"""
    wl_seat_get_pointer(wl_seat_)

` iface_wl_seat`

The ID provided will be initialized to the [`wl_pointer`](@ref) interface for this seat.

This request only takes effect if the seat has the pointer capability, or has had the pointer capability in the past. It is a protocol violation to issue this request on a seat that has never had the pointer capability. The missing\\_capability error will be sent in this case.
"""
function wl_seat_get_pointer(wl_seat_)
    ccall((:wl_seat_get_pointer, libwayland_client), Ptr{wl_pointer}, (Ptr{wl_seat},), wl_seat_)
end

"""
    wl_seat_get_keyboard(wl_seat_)

` iface_wl_seat`

The ID provided will be initialized to the [`wl_keyboard`](@ref) interface for this seat.

This request only takes effect if the seat has the keyboard capability, or has had the keyboard capability in the past. It is a protocol violation to issue this request on a seat that has never had the keyboard capability. The missing\\_capability error will be sent in this case.
"""
function wl_seat_get_keyboard(wl_seat_)
    ccall((:wl_seat_get_keyboard, libwayland_client), Ptr{wl_keyboard}, (Ptr{wl_seat},), wl_seat_)
end

"""
    wl_seat_get_touch(wl_seat_)

` iface_wl_seat`

The ID provided will be initialized to the [`wl_touch`](@ref) interface for this seat.

This request only takes effect if the seat has the touch capability, or has had the touch capability in the past. It is a protocol violation to issue this request on a seat that has never had the touch capability. The missing\\_capability error will be sent in this case.
"""
function wl_seat_get_touch(wl_seat_)
    ccall((:wl_seat_get_touch, libwayland_client), Ptr{wl_touch}, (Ptr{wl_seat},), wl_seat_)
end

"""
    wl_seat_release(wl_seat_)

` iface_wl_seat`

Using this request a client can tell the server that it is not going to use the seat object anymore.
"""
function wl_seat_release(wl_seat_)
    ccall((:wl_seat_release, libwayland_client), Cvoid, (Ptr{wl_seat},), wl_seat_)
end

"""
    wl_pointer_error

| Enumerator                  | Note                                         |
| :-------------------------- | :------------------------------------------- |
| WL\\_POINTER\\_ERROR\\_ROLE | given [`wl_surface`](@ref) has another role  |
"""
@cenum wl_pointer_error::UInt32 begin
    WL_POINTER_ERROR_ROLE = 0
end

"""
    wl_pointer_button_state

` iface_wl_pointer`

physical button state

Describes the physical state of a button that produced the button event.

| Enumerator                               | Note                       |
| :--------------------------------------- | :------------------------- |
| WL\\_POINTER\\_BUTTON\\_STATE\\_RELEASED | the button is not pressed  |
| WL\\_POINTER\\_BUTTON\\_STATE\\_PRESSED  | the button is pressed      |
"""
@cenum wl_pointer_button_state::UInt32 begin
    WL_POINTER_BUTTON_STATE_RELEASED = 0
    WL_POINTER_BUTTON_STATE_PRESSED = 1
end

"""
    wl_pointer_axis

` iface_wl_pointer`

axis types

Describes the axis types of scroll events.

| Enumerator                                | Note             |
| :---------------------------------------- | :--------------- |
| WL\\_POINTER\\_AXIS\\_VERTICAL\\_SCROLL   | vertical axis    |
| WL\\_POINTER\\_AXIS\\_HORIZONTAL\\_SCROLL | horizontal axis  |
"""
@cenum wl_pointer_axis::UInt32 begin
    WL_POINTER_AXIS_VERTICAL_SCROLL = 0
    WL_POINTER_AXIS_HORIZONTAL_SCROLL = 1
end

"""
    wl_pointer_axis_source

` iface_wl_pointer`

axis source types

Describes the source types for axis events. This indicates to the client how an axis event was physically generated; a client may adjust the user interface accordingly. For example, scroll events from a "finger" source may be in a smooth coordinate space with kinetic scrolling whereas a "wheel" source may be in discrete steps of a number of lines.

The "continuous" axis source is a device generating events in a continuous coordinate space, but using something other than a finger. One example for this source is button-based scrolling where the vertical motion of a device is converted to scroll events while a button is held down.

The "wheel tilt" axis source indicates that the actual device is a wheel but the scroll event is not caused by a rotation but a (usually sideways) tilt of the wheel.

| Enumerator                                  | Note                              |
| :------------------------------------------ | :-------------------------------- |
| WL\\_POINTER\\_AXIS\\_SOURCE\\_WHEEL        | a physical wheel rotation         |
| WL\\_POINTER\\_AXIS\\_SOURCE\\_FINGER       | finger on a touch surface         |
| WL\\_POINTER\\_AXIS\\_SOURCE\\_CONTINUOUS   | continuous coordinate space       |
| WL\\_POINTER\\_AXIS\\_SOURCE\\_WHEEL\\_TILT | a physical wheel tilt  \\since 6  |
"""
@cenum wl_pointer_axis_source::UInt32 begin
    WL_POINTER_AXIS_SOURCE_WHEEL = 0
    WL_POINTER_AXIS_SOURCE_FINGER = 1
    WL_POINTER_AXIS_SOURCE_CONTINUOUS = 2
    WL_POINTER_AXIS_SOURCE_WHEEL_TILT = 3
end

"""
    wl_pointer_listener

` iface_wl_pointer`

` wl_pointer_listener`

| Field           | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| :-------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| enter           | enter event  Notification that this seat's pointer is focused on a certain surface.  When a seat's focus enters a surface, the pointer image is undefined and a client should respond to this event by setting an appropriate pointer image with the set\\_cursor request.  ### Parameters * `serial`: serial number of the enter event * `surface`: surface entered by the pointer * `surface_x`: surface-local x coordinate * `surface_y`: surface-local y coordinate                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| leave           | leave event  Notification that this seat's pointer is no longer focused on a certain surface.  The leave notification is sent before the enter notification for the new focus.  ### Parameters * `serial`: serial number of the leave event * `surface`: surface left by the pointer                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| motion          | pointer motion event  Notification of pointer location change. The arguments surface\\_x and surface\\_y are the location relative to the focused surface.  ### Parameters * `time`: timestamp with millisecond granularity * `surface_x`: surface-local x coordinate * `surface_y`: surface-local y coordinate                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| button          | pointer button event  Mouse button click and release notifications.  The location of the click is given by the last motion or enter event. The time argument is a timestamp with millisecond granularity, with an undefined base.  The button is a button code as defined in the Linux kernel's linux/input-event-codes.h header file, e.g. BTN\\_LEFT.  Any 16-bit button code value is reserved for future additions to the kernel's event code list. All other button codes above 0xFFFF are currently undefined but may be used in future versions of this protocol.  ### Parameters * `serial`: serial number of the button event * `time`: timestamp with millisecond granularity * `button`: button that produced the event * `state`: physical state of the button                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| axis            | axis event  Scroll and other axis notifications.  For scroll events (vertical and horizontal scroll axes), the value parameter is the length of a vector along the specified axis in a coordinate space identical to those of motion events, representing a relative movement along the specified axis.  For devices that support movements non-parallel to axes multiple axis events will be emitted.  When applicable, for example for touch pads, the server can choose to emit scroll events where the motion vector is equivalent to a motion event vector.  When applicable, a client can transform its content relative to the scroll distance.  ### Parameters * `time`: timestamp with millisecond granularity * `axis`: axis type * `value`: length of vector in surface-local coordinate space                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| frame           | end of a pointer event sequence  Indicates the end of a set of events that logically belong together. A client is expected to accumulate the data in all events within the frame before proceeding.  All [`wl_pointer`](@ref) events before a [`wl_pointer`](@ref).frame event belong logically together. For example, in a diagonal scroll motion the compositor will send an optional [`wl_pointer`](@ref).axis\\_source event, two [`wl_pointer`](@ref).axis events (horizontal and vertical) and finally a [`wl_pointer`](@ref).frame event. The client may use this information to calculate a diagonal vector for scrolling.  When multiple [`wl_pointer`](@ref).axis events occur within the same frame, the motion vector is the combined motion of all events. When a [`wl_pointer`](@ref).axis and a [`wl_pointer`](@ref).axis\\_stop event occur within the same frame, this indicates that axis movement in one axis has stopped but continues in the other axis. When multiple [`wl_pointer`](@ref).axis\\_stop events occur within the same frame, this indicates that these axes stopped in the same instance.  A [`wl_pointer`](@ref).frame event is sent for every logical event group, even if the group only contains a single [`wl_pointer`](@ref) event. Specifically, a client may get a sequence: motion, frame, button, frame, axis, frame, axis\\_stop, frame.  The [`wl_pointer`](@ref).enter and [`wl_pointer`](@ref).leave events are logical events generated by the compositor and not the hardware. These events are also grouped by a [`wl_pointer`](@ref).frame. When a pointer moves from one surface to another, a compositor should group the [`wl_pointer`](@ref).leave event within the same [`wl_pointer`](@ref).frame. However, a client must not rely on [`wl_pointer`](@ref).leave and [`wl_pointer`](@ref).enter being in the same [`wl_pointer`](@ref).frame. Compositor-specific policies may require the [`wl_pointer`](@ref).leave and [`wl_pointer`](@ref).enter event being split across multiple [`wl_pointer`](@ref).frame groups.  \\since 5  |
| axis\\_source   | axis source event  Source information for scroll and other axes.  This event does not occur on its own. It is sent before a [`wl_pointer`](@ref).frame event and carries the source information for all events within that frame.  The source specifies how this event was generated. If the source is [`wl_pointer`](@ref).axis\\_source.finger, a [`wl_pointer`](@ref).axis\\_stop event will be sent when the user lifts the finger off the device.  If the source is [`wl_pointer`](@ref).axis\\_source.wheel, [`wl_pointer`](@ref).axis\\_source.wheel\\_tilt or [`wl_pointer`](@ref).axis\\_source.continuous, a [`wl_pointer`](@ref).axis\\_stop event may or may not be sent. Whether a compositor sends an axis\\_stop event for these sources is hardware-specific and implementation-dependent; clients must not rely on receiving an axis\\_stop event for these scroll sources and should treat scroll sequences from these scroll sources as unterminated by default.  This event is optional. If the source is unknown for a particular axis event sequence, no event is sent. Only one [`wl_pointer`](@ref).axis\\_source event is permitted per frame.  The order of [`wl_pointer`](@ref).axis\\_discrete and [`wl_pointer`](@ref).axis\\_source is not guaranteed.  \\since 5  ### Parameters * `axis_source`: source of the axis event                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| axis\\_stop     | axis stop event  Stop notification for scroll and other axes.  For some [`wl_pointer`](@ref).axis\\_source types, a [`wl_pointer`](@ref).axis\\_stop event is sent to notify a client that the axis sequence has terminated. This enables the client to implement kinetic scrolling. See the [`wl_pointer`](@ref).axis\\_source documentation for information on when this event may be generated.  Any [`wl_pointer`](@ref).axis events with the same axis\\_source after this event should be considered as the start of a new axis motion.  The timestamp is to be interpreted identical to the timestamp in the [`wl_pointer`](@ref).axis event. The timestamp value may be the same as a preceding [`wl_pointer`](@ref).axis event.  \\since 5  ### Parameters * `time`: timestamp with millisecond granularity * `axis`: the axis stopped with this event                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| axis\\_discrete | axis click event  Discrete step information for scroll and other axes.  This event carries the axis value of the [`wl_pointer`](@ref).axis event in discrete steps (e.g. mouse wheel clicks).  This event does not occur on its own, it is coupled with a [`wl_pointer`](@ref).axis event that represents this axis value on a continuous scale. The protocol guarantees that each axis\\_discrete event is always followed by exactly one axis event with the same axis number within the same [`wl_pointer`](@ref).frame. Note that the protocol allows for other events to occur between the axis\\_discrete and its coupled axis event, including other axis\\_discrete or axis events.  This event is optional; continuous scrolling devices like two-finger scrolling on touchpads do not have discrete steps and do not generate this event.  The discrete value carries the directional information. e.g. a value of -2 is two steps towards the negative direction of this axis.  The axis number is identical to the axis number in the associated axis event.  The order of [`wl_pointer`](@ref).axis\\_discrete and [`wl_pointer`](@ref).axis\\_source is not guaranteed.  \\since 5  ### Parameters * `axis`: axis type * `discrete`: number of steps                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
"""
struct wl_pointer_listener
    enter::Ptr{Cvoid}
    leave::Ptr{Cvoid}
    motion::Ptr{Cvoid}
    button::Ptr{Cvoid}
    axis::Ptr{Cvoid}
    frame::Ptr{Cvoid}
    axis_source::Ptr{Cvoid}
    axis_stop::Ptr{Cvoid}
    axis_discrete::Ptr{Cvoid}
end

"""
    wl_pointer_add_listener(wl_pointer_, listener, data)

` iface_wl_pointer`
"""
function wl_pointer_add_listener(wl_pointer_, listener, data)
    ccall((:wl_pointer_add_listener, libwayland_client), Cint, (Ptr{wl_pointer}, Ptr{wl_pointer_listener}, Ptr{Cvoid}), wl_pointer_, listener, data)
end

"""
    wl_pointer_set_user_data(wl_pointer_, user_data)

` iface_wl_pointer `
"""
function wl_pointer_set_user_data(wl_pointer_, user_data)
    ccall((:wl_pointer_set_user_data, libwayland_client), Cvoid, (Ptr{wl_pointer}, Ptr{Cvoid}), wl_pointer_, user_data)
end

"""
    wl_pointer_get_user_data(wl_pointer_)

` iface_wl_pointer `
"""
function wl_pointer_get_user_data(wl_pointer_)
    ccall((:wl_pointer_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_pointer},), wl_pointer_)
end

function wl_pointer_get_version(wl_pointer_)
    ccall((:wl_pointer_get_version, libwayland_client), UInt32, (Ptr{wl_pointer},), wl_pointer_)
end

"""
    wl_pointer_destroy(wl_pointer_)

` iface_wl_pointer `
"""
function wl_pointer_destroy(wl_pointer_)
    ccall((:wl_pointer_destroy, libwayland_client), Cvoid, (Ptr{wl_pointer},), wl_pointer_)
end

"""
    wl_pointer_set_cursor(wl_pointer_, serial, surface, hotspot_x, hotspot_y)

` iface_wl_pointer`

Set the pointer surface, i.e., the surface that contains the pointer image (cursor). This request gives the surface the role of a cursor. If the surface already has another role, it raises a protocol error.

The cursor actually changes only if the pointer focus for this device is one of the requesting client's surfaces or the surface parameter is the current pointer surface. If there was a previous surface set with this request it is replaced. If surface is NULL, the pointer image is hidden.

The parameters hotspot\\_x and hotspot\\_y define the position of the pointer surface relative to the pointer location. Its top-left corner is always at (x, y) - (hotspot\\_x, hotspot\\_y), where (x, y) are the coordinates of the pointer location, in surface-local coordinates.

On surface.attach requests to the pointer surface, hotspot\\_x and hotspot\\_y are decremented by the x and y parameters passed to the request. Attach must be confirmed by [`wl_surface`](@ref).commit as usual.

The hotspot can also be updated by passing the currently set pointer surface to this request with new values for hotspot\\_x and hotspot\\_y.

The current and pending input regions of the [`wl_surface`](@ref) are cleared, and [`wl_surface`](@ref).set\\_input\\_region is ignored until the [`wl_surface`](@ref) is no longer used as the cursor. When the use as a cursor ends, the current and pending input regions become undefined, and the [`wl_surface`](@ref) is unmapped.
"""
function wl_pointer_set_cursor(wl_pointer_, serial, surface, hotspot_x, hotspot_y)
    ccall((:wl_pointer_set_cursor, libwayland_client), Cvoid, (Ptr{wl_pointer}, UInt32, Ptr{wl_surface}, Int32, Int32), wl_pointer_, serial, surface, hotspot_x, hotspot_y)
end

"""
    wl_pointer_release(wl_pointer_)

` iface_wl_pointer`

Using this request a client can tell the server that it is not going to use the pointer object anymore.

This request destroys the pointer proxy object, so clients must not call [`wl_pointer_destroy`](@ref)() after using this request.
"""
function wl_pointer_release(wl_pointer_)
    ccall((:wl_pointer_release, libwayland_client), Cvoid, (Ptr{wl_pointer},), wl_pointer_)
end

"""
    wl_keyboard_keymap_format

` iface_wl_keyboard`

keyboard mapping format

This specifies the format of the keymap provided to the client with the [`wl_keyboard`](@ref).keymap event.

| Enumerator                                    | Note                                                                                                |
| :-------------------------------------------- | :-------------------------------------------------------------------------------------------------- |
| WL\\_KEYBOARD\\_KEYMAP\\_FORMAT\\_NO\\_KEYMAP | no keymap; client must understand how to interpret the raw keycode                                  |
| WL\\_KEYBOARD\\_KEYMAP\\_FORMAT\\_XKB\\_V1    | libxkbcommon compatible; to determine the xkb keycode, clients must add 8 to the key event keycode  |
"""
@cenum wl_keyboard_keymap_format::UInt32 begin
    WL_KEYBOARD_KEYMAP_FORMAT_NO_KEYMAP = 0
    WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1 = 1
end

"""
    wl_keyboard_key_state

` iface_wl_keyboard`

physical key state

Describes the physical state of a key that produced the key event.

| Enumerator                             | Note                |
| :------------------------------------- | :------------------ |
| WL\\_KEYBOARD\\_KEY\\_STATE\\_RELEASED | key is not pressed  |
| WL\\_KEYBOARD\\_KEY\\_STATE\\_PRESSED  | key is pressed      |
"""
@cenum wl_keyboard_key_state::UInt32 begin
    WL_KEYBOARD_KEY_STATE_RELEASED = 0
    WL_KEYBOARD_KEY_STATE_PRESSED = 1
end

"""
    wl_keyboard_listener

` iface_wl_keyboard`

` wl_keyboard_listener`

| Field         | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| :------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| keymap        | keyboard mapping  This event provides a file descriptor to the client which can be memory-mapped to provide a keyboard mapping description.  From version 7 onwards, the fd must be mapped with MAP\\_PRIVATE by the recipient, as MAP\\_SHARED may fail.  ### Parameters * `format`: keymap format * `fd`: keymap file descriptor * `size`: keymap size, in bytes                                                                                                                                                                                                                                                                                                                                                             |
| enter         | enter event  Notification that this seat's keyboard focus is on a certain surface.  The compositor must send the [`wl_keyboard`](@ref).modifiers event after this event.  ### Parameters * `serial`: serial number of the enter event * `surface`: surface gaining keyboard focus * `keys`: the currently pressed keys                                                                                                                                                                                                                                                                                                                                                                                                         |
| leave         | leave event  Notification that this seat's keyboard focus is no longer on a certain surface.  The leave notification is sent before the enter notification for the new focus.  After this event client must assume that all keys, including modifiers, are lifted and also it must stop key repeating if there's some going on.  ### Parameters * `serial`: serial number of the leave event * `surface`: surface that lost keyboard focus                                                                                                                                                                                                                                                                                     |
| key           | key event  A key was pressed or released. The time argument is a timestamp with millisecond granularity, with an undefined base.  The key is a platform-specific key code that can be interpreted by feeding it to the keyboard mapping (see the keymap event).  If this event produces a change in modifiers, then the resulting [`wl_keyboard`](@ref).modifiers event must be sent after this event.  ### Parameters * `serial`: serial number of the key event * `time`: timestamp with millisecond granularity * `key`: key that produced the event * `state`: physical state of the key                                                                                                                                   |
| modifiers     | modifier and group state  Notifies clients that the modifier and/or group state has changed, and it should update its local state.  ### Parameters * `serial`: serial number of the modifiers event * `mods_depressed`: depressed modifiers * `mods_latched`: latched modifiers * `mods_locked`: locked modifiers * `group`: keyboard layout                                                                                                                                                                                                                                                                                                                                                                                   |
| repeat\\_info | repeat rate and delay  Informs the client about the keyboard's repeat rate and delay.  This event is sent as soon as the [`wl_keyboard`](@ref) object has been created, and is guaranteed to be received by the client before any key press event.  Negative values for either rate or delay are illegal. A rate of zero will disable any repeating (regardless of the value of delay).  This event can be sent later on as well with a new value if necessary, so clients should continue listening for the event past the creation of [`wl_keyboard`](@ref).  \\since 4  ### Parameters * `rate`: the rate of repeating keys in characters per second * `delay`: delay in milliseconds since key down until repeating starts |
"""
struct wl_keyboard_listener
    keymap::Ptr{Cvoid}
    enter::Ptr{Cvoid}
    leave::Ptr{Cvoid}
    key::Ptr{Cvoid}
    modifiers::Ptr{Cvoid}
    repeat_info::Ptr{Cvoid}
end

"""
    wl_keyboard_add_listener(wl_keyboard_, listener, data)

` iface_wl_keyboard`
"""
function wl_keyboard_add_listener(wl_keyboard_, listener, data)
    ccall((:wl_keyboard_add_listener, libwayland_client), Cint, (Ptr{wl_keyboard}, Ptr{wl_keyboard_listener}, Ptr{Cvoid}), wl_keyboard_, listener, data)
end

"""
    wl_keyboard_set_user_data(wl_keyboard_, user_data)

` iface_wl_keyboard `
"""
function wl_keyboard_set_user_data(wl_keyboard_, user_data)
    ccall((:wl_keyboard_set_user_data, libwayland_client), Cvoid, (Ptr{wl_keyboard}, Ptr{Cvoid}), wl_keyboard_, user_data)
end

"""
    wl_keyboard_get_user_data(wl_keyboard_)

` iface_wl_keyboard `
"""
function wl_keyboard_get_user_data(wl_keyboard_)
    ccall((:wl_keyboard_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_keyboard},), wl_keyboard_)
end

function wl_keyboard_get_version(wl_keyboard_)
    ccall((:wl_keyboard_get_version, libwayland_client), UInt32, (Ptr{wl_keyboard},), wl_keyboard_)
end

"""
    wl_keyboard_destroy(wl_keyboard_)

` iface_wl_keyboard `
"""
function wl_keyboard_destroy(wl_keyboard_)
    ccall((:wl_keyboard_destroy, libwayland_client), Cvoid, (Ptr{wl_keyboard},), wl_keyboard_)
end

"""
    wl_keyboard_release(wl_keyboard_)

` iface_wl_keyboard`
"""
function wl_keyboard_release(wl_keyboard_)
    ccall((:wl_keyboard_release, libwayland_client), Cvoid, (Ptr{wl_keyboard},), wl_keyboard_)
end

"""
    wl_touch_listener

` iface_wl_touch`

` wl_touch_listener`

| Field       | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| down        | touch down event and beginning of a touch sequence  A new touch point has appeared on the surface. This touch point is assigned a unique ID. Future events from this touch point reference this ID. The ID ceases to be valid after a touch up event and may be reused in the future.  ### Parameters * `serial`: serial number of the touch down event * `time`: timestamp with millisecond granularity * `surface`: surface touched * `id`: the unique ID of this touch point * `x`: surface-local x coordinate * `y`: surface-local y coordinate                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| up          | end of a touch event sequence  The touch point has disappeared. No further events will be sent for this touch point and the touch point's ID is released and may be reused in a future touch down event.  ### Parameters * `serial`: serial number of the touch up event * `time`: timestamp with millisecond granularity * `id`: the unique ID of this touch point                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| motion      | update of touch point coordinates  A touch point has changed coordinates.  ### Parameters * `time`: timestamp with millisecond granularity * `id`: the unique ID of this touch point * `x`: surface-local x coordinate * `y`: surface-local y coordinate                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| frame       | end of touch frame event  Indicates the end of a set of events that logically belong together. A client is expected to accumulate the data in all events within the frame before proceeding.  A [`wl_touch`](@ref).frame terminates at least one event but otherwise no guarantee is provided about the set of events within a frame. A client must assume that any state not updated in a frame is unchanged from the previously known state.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| cancel      | touch session cancelled  Sent if the compositor decides the touch stream is a global gesture. No further events are sent to the clients from that particular gesture. Touch cancellation applies to all touch points currently active on this client's surface. The client is responsible for finalizing the touch points, future touch points on this surface may reuse the touch point ID.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| shape       | update shape of touch point  Sent when a touchpoint has changed its shape.  This event does not occur on its own. It is sent before a [`wl_touch`](@ref).frame event and carries the new shape information for any previously reported, or new touch points of that frame.  Other events describing the touch point such as [`wl_touch`](@ref).down, [`wl_touch`](@ref).motion or [`wl_touch`](@ref).orientation may be sent within the same [`wl_touch`](@ref).frame. A client should treat these events as a single logical touch point update. The order of [`wl_touch`](@ref).shape, [`wl_touch`](@ref).orientation and [`wl_touch`](@ref).motion is not guaranteed. A [`wl_touch`](@ref).down event is guaranteed to occur before the first [`wl_touch`](@ref).shape event for this touch ID but both events may occur within the same [`wl_touch`](@ref).frame.  A touchpoint shape is approximated by an ellipse through the major and minor axis length. The major axis length describes the longer diameter of the ellipse, while the minor axis length describes the shorter diameter. Major and minor are orthogonal and both are specified in surface-local coordinates. The center of the ellipse is always at the touchpoint location as reported by [`wl_touch`](@ref).down or [`wl_touch`](@ref).move.  This event is only sent by the compositor if the touch device supports shape reports. The client has to make reasonable assumptions about the shape if it did not receive this event.  \\since 6  ### Parameters * `id`: the unique ID of this touch point * `major`: length of the major axis in surface-local coordinates * `minor`: length of the minor axis in surface-local coordinates |
| orientation | update orientation of touch point  Sent when a touchpoint has changed its orientation.  This event does not occur on its own. It is sent before a [`wl_touch`](@ref).frame event and carries the new shape information for any previously reported, or new touch points of that frame.  Other events describing the touch point such as [`wl_touch`](@ref).down, [`wl_touch`](@ref).motion or [`wl_touch`](@ref).shape may be sent within the same [`wl_touch`](@ref).frame. A client should treat these events as a single logical touch point update. The order of [`wl_touch`](@ref).shape, [`wl_touch`](@ref).orientation and [`wl_touch`](@ref).motion is not guaranteed. A [`wl_touch`](@ref).down event is guaranteed to occur before the first [`wl_touch`](@ref).orientation event for this touch ID but both events may occur within the same [`wl_touch`](@ref).frame.  The orientation describes the clockwise angle of a touchpoint's major axis to the positive surface y-axis and is normalized to the -180 to +180 degree range. The granularity of orientation depends on the touch device, some devices only support binary rotation values between 0 and 90 degrees.  This event is only sent by the compositor if the touch device supports orientation reports.  \\since 6  ### Parameters * `id`: the unique ID of this touch point * `orientation`: angle between major axis and positive surface y-axis in degrees                                                                                                                                                                                                                                                                           |
"""
struct wl_touch_listener
    down::Ptr{Cvoid}
    up::Ptr{Cvoid}
    motion::Ptr{Cvoid}
    frame::Ptr{Cvoid}
    cancel::Ptr{Cvoid}
    shape::Ptr{Cvoid}
    orientation::Ptr{Cvoid}
end

"""
    wl_touch_add_listener(wl_touch_, listener, data)

` iface_wl_touch`
"""
function wl_touch_add_listener(wl_touch_, listener, data)
    ccall((:wl_touch_add_listener, libwayland_client), Cint, (Ptr{wl_touch}, Ptr{wl_touch_listener}, Ptr{Cvoid}), wl_touch_, listener, data)
end

"""
    wl_touch_set_user_data(wl_touch_, user_data)

` iface_wl_touch `
"""
function wl_touch_set_user_data(wl_touch_, user_data)
    ccall((:wl_touch_set_user_data, libwayland_client), Cvoid, (Ptr{wl_touch}, Ptr{Cvoid}), wl_touch_, user_data)
end

"""
    wl_touch_get_user_data(wl_touch_)

` iface_wl_touch `
"""
function wl_touch_get_user_data(wl_touch_)
    ccall((:wl_touch_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_touch},), wl_touch_)
end

function wl_touch_get_version(wl_touch_)
    ccall((:wl_touch_get_version, libwayland_client), UInt32, (Ptr{wl_touch},), wl_touch_)
end

"""
    wl_touch_destroy(wl_touch_)

` iface_wl_touch `
"""
function wl_touch_destroy(wl_touch_)
    ccall((:wl_touch_destroy, libwayland_client), Cvoid, (Ptr{wl_touch},), wl_touch_)
end

"""
    wl_touch_release(wl_touch_)

` iface_wl_touch`
"""
function wl_touch_release(wl_touch_)
    ccall((:wl_touch_release, libwayland_client), Cvoid, (Ptr{wl_touch},), wl_touch_)
end

"""
    wl_output_subpixel

` iface_wl_output`

subpixel geometry information

This enumeration describes how the physical pixels on an output are laid out.

| Enumerator                                | Note              |
| :---------------------------------------- | :---------------- |
| WL\\_OUTPUT\\_SUBPIXEL\\_UNKNOWN          | unknown geometry  |
| WL\\_OUTPUT\\_SUBPIXEL\\_NONE             | no geometry       |
| WL\\_OUTPUT\\_SUBPIXEL\\_HORIZONTAL\\_RGB | horizontal RGB    |
| WL\\_OUTPUT\\_SUBPIXEL\\_HORIZONTAL\\_BGR | horizontal BGR    |
| WL\\_OUTPUT\\_SUBPIXEL\\_VERTICAL\\_RGB   | vertical RGB      |
| WL\\_OUTPUT\\_SUBPIXEL\\_VERTICAL\\_BGR   | vertical BGR      |
"""
@cenum wl_output_subpixel::UInt32 begin
    WL_OUTPUT_SUBPIXEL_UNKNOWN = 0
    WL_OUTPUT_SUBPIXEL_NONE = 1
    WL_OUTPUT_SUBPIXEL_HORIZONTAL_RGB = 2
    WL_OUTPUT_SUBPIXEL_HORIZONTAL_BGR = 3
    WL_OUTPUT_SUBPIXEL_VERTICAL_RGB = 4
    WL_OUTPUT_SUBPIXEL_VERTICAL_BGR = 5
end

"""
    wl_output_transform

` iface_wl_output`

transform from framebuffer to output

This describes the transform that a compositor will apply to a surface to compensate for the rotation or mirroring of an output device.

The flipped values correspond to an initial flip around a vertical axis followed by rotation.

The purpose is mainly to allow clients to render accordingly and tell the compositor, so that for fullscreen surfaces, the compositor will still be able to scan out directly from client surfaces.

| Enumerator                              | Note                                           |
| :-------------------------------------- | :--------------------------------------------- |
| WL\\_OUTPUT\\_TRANSFORM\\_NORMAL        | no transform                                   |
| WL\\_OUTPUT\\_TRANSFORM\\_90            | 90 degrees counter-clockwise                   |
| WL\\_OUTPUT\\_TRANSFORM\\_180           | 180 degrees counter-clockwise                  |
| WL\\_OUTPUT\\_TRANSFORM\\_270           | 270 degrees counter-clockwise                  |
| WL\\_OUTPUT\\_TRANSFORM\\_FLIPPED       | 180 degree flip around a vertical axis         |
| WL\\_OUTPUT\\_TRANSFORM\\_FLIPPED\\_90  | flip and rotate 90 degrees counter-clockwise   |
| WL\\_OUTPUT\\_TRANSFORM\\_FLIPPED\\_180 | flip and rotate 180 degrees counter-clockwise  |
| WL\\_OUTPUT\\_TRANSFORM\\_FLIPPED\\_270 | flip and rotate 270 degrees counter-clockwise  |
"""
@cenum wl_output_transform::UInt32 begin
    WL_OUTPUT_TRANSFORM_NORMAL = 0
    WL_OUTPUT_TRANSFORM_90 = 1
    WL_OUTPUT_TRANSFORM_180 = 2
    WL_OUTPUT_TRANSFORM_270 = 3
    WL_OUTPUT_TRANSFORM_FLIPPED = 4
    WL_OUTPUT_TRANSFORM_FLIPPED_90 = 5
    WL_OUTPUT_TRANSFORM_FLIPPED_180 = 6
    WL_OUTPUT_TRANSFORM_FLIPPED_270 = 7
end

"""
    wl_output_mode

` iface_wl_output`

mode information

These flags describe properties of an output mode. They are used in the flags bitfield of the mode event.

| Enumerator                     | Note                                  |
| :----------------------------- | :------------------------------------ |
| WL\\_OUTPUT\\_MODE\\_CURRENT   | indicates this is the current mode    |
| WL\\_OUTPUT\\_MODE\\_PREFERRED | indicates this is the preferred mode  |
"""
@cenum wl_output_mode::UInt32 begin
    WL_OUTPUT_MODE_CURRENT = 1
    WL_OUTPUT_MODE_PREFERRED = 2
end

"""
    wl_output_listener

` iface_wl_output`

` wl_output_listener`

| Field    | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| :------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| geometry | properties of the output  The geometry event describes geometric properties of the output. The event is sent when binding to the output object and whenever any of the properties change.  The physical size can be set to zero if it doesn't make sense for this output (e.g. for projectors or virtual outputs).  Note: [`wl_output`](@ref) only advertises partial information about the output position and identification. Some compositors, for instance those not implementing a desktop-style output layout or those exposing virtual outputs, might fake this information. Instead of using x and y, clients should use xdg\\_output.logical\\_position. Instead of using make and model, clients should use xdg\\_output.name and xdg\\_output.description.  ### Parameters * `x`: x position within the global compositor space * `y`: y position within the global compositor space * `physical_width`: width in millimeters of the output * `physical_height`: height in millimeters of the output * `subpixel`: subpixel orientation of the output * `make`: textual description of the manufacturer * `model`: textual description of the model * `transform`: transform that maps framebuffer to output                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| mode     | advertise available modes for the output  The mode event describes an available mode for the output.  The event is sent when binding to the output object and there will always be one mode, the current mode. The event is sent again if an output changes mode, for the mode that is now current. In other words, the current mode is always the last mode that was received with the current flag set.  Non-current modes are deprecated. A compositor can decide to only advertise the current mode and never send other modes. Clients should not rely on non-current modes.  The size of a mode is given in physical hardware units of the output device. This is not necessarily the same as the output size in the global compositor space. For instance, the output may be scaled, as described in [`wl_output`](@ref).scale, or transformed, as described in [`wl_output`](@ref).transform. Clients willing to retrieve the output size in the global compositor space should use xdg\\_output.logical\\_size instead.  The vertical refresh rate can be set to zero if it doesn't make sense for this output (e.g. for virtual outputs).  Clients should not use the refresh rate to schedule frames. Instead, they should use the [`wl_surface`](@ref).frame event or the presentation-time protocol.  Note: this information is not always meaningful for all outputs. Some compositors, such as those exposing virtual outputs, might fake the refresh rate or the size.  ### Parameters * `flags`: bitfield of mode flags * `width`: width of the mode in hardware units * `height`: height of the mode in hardware units * `refresh`: vertical refresh rate in mHz |
| done     | sent all information about output  This event is sent after all other properties have been sent after binding to the output object and after any other property changes done after that. This allows changes to the output properties to be seen as atomic, even if they happen via multiple events.  \\since 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| scale    | output scaling properties  This event contains scaling geometry information that is not in the geometry event. It may be sent after binding the output object or if the output scale changes later. If it is not sent, the client should assume a scale of 1.  A scale larger than 1 means that the compositor will automatically scale surface buffers by this amount when rendering. This is used for very high resolution displays where applications rendering at the native resolution would be too small to be legible.  It is intended that scaling aware clients track the current output of a surface, and if it is on a scaled output it should use [`wl_surface`](@ref).set\\_buffer\\_scale with the scale of the output. That way the compositor can avoid scaling the surface, and the client can supply a higher detail image.  \\since 2  ### Parameters * `factor`: scaling factor of output                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
"""
struct wl_output_listener
    geometry::Ptr{Cvoid}
    mode::Ptr{Cvoid}
    done::Ptr{Cvoid}
    scale::Ptr{Cvoid}
end

"""
    wl_output_add_listener(wl_output_, listener, data)

` iface_wl_output`
"""
function wl_output_add_listener(wl_output_, listener, data)
    ccall((:wl_output_add_listener, libwayland_client), Cint, (Ptr{wl_output}, Ptr{wl_output_listener}, Ptr{Cvoid}), wl_output_, listener, data)
end

"""
    wl_output_set_user_data(wl_output_, user_data)

` iface_wl_output `
"""
function wl_output_set_user_data(wl_output_, user_data)
    ccall((:wl_output_set_user_data, libwayland_client), Cvoid, (Ptr{wl_output}, Ptr{Cvoid}), wl_output_, user_data)
end

"""
    wl_output_get_user_data(wl_output_)

` iface_wl_output `
"""
function wl_output_get_user_data(wl_output_)
    ccall((:wl_output_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_output},), wl_output_)
end

function wl_output_get_version(wl_output_)
    ccall((:wl_output_get_version, libwayland_client), UInt32, (Ptr{wl_output},), wl_output_)
end

"""
    wl_output_destroy(wl_output_)

` iface_wl_output `
"""
function wl_output_destroy(wl_output_)
    ccall((:wl_output_destroy, libwayland_client), Cvoid, (Ptr{wl_output},), wl_output_)
end

"""
    wl_output_release(wl_output_)

` iface_wl_output`

Using this request a client can tell the server that it is not going to use the output object anymore.
"""
function wl_output_release(wl_output_)
    ccall((:wl_output_release, libwayland_client), Cvoid, (Ptr{wl_output},), wl_output_)
end

"""
    wl_region_set_user_data(wl_region_, user_data)

` iface_wl_region `
"""
function wl_region_set_user_data(wl_region_, user_data)
    ccall((:wl_region_set_user_data, libwayland_client), Cvoid, (Ptr{wl_region}, Ptr{Cvoid}), wl_region_, user_data)
end

"""
    wl_region_get_user_data(wl_region_)

` iface_wl_region `
"""
function wl_region_get_user_data(wl_region_)
    ccall((:wl_region_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_region},), wl_region_)
end

function wl_region_get_version(wl_region_)
    ccall((:wl_region_get_version, libwayland_client), UInt32, (Ptr{wl_region},), wl_region_)
end

"""
    wl_region_destroy(wl_region_)

` iface_wl_region`

Destroy the region. This will invalidate the object ID.
"""
function wl_region_destroy(wl_region_)
    ccall((:wl_region_destroy, libwayland_client), Cvoid, (Ptr{wl_region},), wl_region_)
end

"""
    wl_region_add(wl_region_, x, y, width, height)

` iface_wl_region`

Add the specified rectangle to the region.
"""
function wl_region_add(wl_region_, x, y, width, height)
    ccall((:wl_region_add, libwayland_client), Cvoid, (Ptr{wl_region}, Int32, Int32, Int32, Int32), wl_region_, x, y, width, height)
end

"""
    wl_region_subtract(wl_region_, x, y, width, height)

` iface_wl_region`

Subtract the specified rectangle from the region.
"""
function wl_region_subtract(wl_region_, x, y, width, height)
    ccall((:wl_region_subtract, libwayland_client), Cvoid, (Ptr{wl_region}, Int32, Int32, Int32, Int32), wl_region_, x, y, width, height)
end

"""
    wl_subcompositor_error

| Enumerator                                 | Note                              |
| :----------------------------------------- | :-------------------------------- |
| WL\\_SUBCOMPOSITOR\\_ERROR\\_BAD\\_SURFACE | the to-be sub-surface is invalid  |
"""
@cenum wl_subcompositor_error::UInt32 begin
    WL_SUBCOMPOSITOR_ERROR_BAD_SURFACE = 0
end

"""
    wl_subcompositor_set_user_data(wl_subcompositor_, user_data)

` iface_wl_subcompositor `
"""
function wl_subcompositor_set_user_data(wl_subcompositor_, user_data)
    ccall((:wl_subcompositor_set_user_data, libwayland_client), Cvoid, (Ptr{wl_subcompositor}, Ptr{Cvoid}), wl_subcompositor_, user_data)
end

"""
    wl_subcompositor_get_user_data(wl_subcompositor_)

` iface_wl_subcompositor `
"""
function wl_subcompositor_get_user_data(wl_subcompositor_)
    ccall((:wl_subcompositor_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_subcompositor},), wl_subcompositor_)
end

function wl_subcompositor_get_version(wl_subcompositor_)
    ccall((:wl_subcompositor_get_version, libwayland_client), UInt32, (Ptr{wl_subcompositor},), wl_subcompositor_)
end

"""
    wl_subcompositor_destroy(wl_subcompositor_)

` iface_wl_subcompositor`

Informs the server that the client will not be using this protocol object anymore. This does not affect any other objects, [`wl_subsurface`](@ref) objects included.
"""
function wl_subcompositor_destroy(wl_subcompositor_)
    ccall((:wl_subcompositor_destroy, libwayland_client), Cvoid, (Ptr{wl_subcompositor},), wl_subcompositor_)
end

"""
    wl_subcompositor_get_subsurface(wl_subcompositor_, surface, parent)

` iface_wl_subcompositor`

Create a sub-surface interface for the given surface, and associate it with the given parent surface. This turns a plain [`wl_surface`](@ref) into a sub-surface.

The to-be sub-surface must not already have another role, and it must not have an existing [`wl_subsurface`](@ref) object. Otherwise a protocol error is raised.

Adding sub-surfaces to a parent is a double-buffered operation on the parent (see [`wl_surface`](@ref).commit). The effect of adding a sub-surface becomes visible on the next time the state of the parent surface is applied.

This request modifies the behaviour of [`wl_surface`](@ref).commit request on the sub-surface, see the documentation on [`wl_subsurface`](@ref) interface.
"""
function wl_subcompositor_get_subsurface(wl_subcompositor_, surface, parent)
    ccall((:wl_subcompositor_get_subsurface, libwayland_client), Ptr{wl_subsurface}, (Ptr{wl_subcompositor}, Ptr{wl_surface}, Ptr{wl_surface}), wl_subcompositor_, surface, parent)
end

"""
    wl_subsurface_error

| Enumerator                              | Note                                                 |
| :-------------------------------------- | :--------------------------------------------------- |
| WL\\_SUBSURFACE\\_ERROR\\_BAD\\_SURFACE | [`wl_surface`](@ref) is not a sibling or the parent  |
"""
@cenum wl_subsurface_error::UInt32 begin
    WL_SUBSURFACE_ERROR_BAD_SURFACE = 0
end

"""
    wl_subsurface_set_user_data(wl_subsurface_, user_data)

` iface_wl_subsurface `
"""
function wl_subsurface_set_user_data(wl_subsurface_, user_data)
    ccall((:wl_subsurface_set_user_data, libwayland_client), Cvoid, (Ptr{wl_subsurface}, Ptr{Cvoid}), wl_subsurface_, user_data)
end

"""
    wl_subsurface_get_user_data(wl_subsurface_)

` iface_wl_subsurface `
"""
function wl_subsurface_get_user_data(wl_subsurface_)
    ccall((:wl_subsurface_get_user_data, libwayland_client), Ptr{Cvoid}, (Ptr{wl_subsurface},), wl_subsurface_)
end

function wl_subsurface_get_version(wl_subsurface_)
    ccall((:wl_subsurface_get_version, libwayland_client), UInt32, (Ptr{wl_subsurface},), wl_subsurface_)
end

"""
    wl_subsurface_destroy(wl_subsurface_)

` iface_wl_subsurface`

The sub-surface interface is removed from the [`wl_surface`](@ref) object that was turned into a sub-surface with a [`wl_subcompositor`](@ref).get\\_subsurface request. The [`wl_surface`](@ref)'s association to the parent is deleted, and the [`wl_surface`](@ref) loses its role as a sub-surface. The [`wl_surface`](@ref) is unmapped immediately.
"""
function wl_subsurface_destroy(wl_subsurface_)
    ccall((:wl_subsurface_destroy, libwayland_client), Cvoid, (Ptr{wl_subsurface},), wl_subsurface_)
end

"""
    wl_subsurface_set_position(wl_subsurface_, x, y)

` iface_wl_subsurface`

This schedules a sub-surface position change. The sub-surface will be moved so that its origin (top left corner pixel) will be at the location x, y of the parent surface coordinate system. The coordinates are not restricted to the parent surface area. Negative values are allowed.

The scheduled coordinates will take effect whenever the state of the parent surface is applied. When this happens depends on whether the parent surface is in synchronized mode or not. See [`wl_subsurface`](@ref).set\\_sync and [`wl_subsurface`](@ref).set\\_desync for details.

If more than one set\\_position request is invoked by the client before the commit of the parent surface, the position of a new request always replaces the scheduled position from any previous request.

The initial position is 0, 0.
"""
function wl_subsurface_set_position(wl_subsurface_, x, y)
    ccall((:wl_subsurface_set_position, libwayland_client), Cvoid, (Ptr{wl_subsurface}, Int32, Int32), wl_subsurface_, x, y)
end

"""
    wl_subsurface_place_above(wl_subsurface_, sibling)

` iface_wl_subsurface`

This sub-surface is taken from the stack, and put back just above the reference surface, changing the z-order of the sub-surfaces. The reference surface must be one of the sibling surfaces, or the parent surface. Using any other surface, including this sub-surface, will cause a protocol error.

The z-order is double-buffered. Requests are handled in order and applied immediately to a pending state. The final pending state is copied to the active state the next time the state of the parent surface is applied. When this happens depends on whether the parent surface is in synchronized mode or not. See [`wl_subsurface`](@ref).set\\_sync and [`wl_subsurface`](@ref).set\\_desync for details.

A new sub-surface is initially added as the top-most in the stack of its siblings and parent.
"""
function wl_subsurface_place_above(wl_subsurface_, sibling)
    ccall((:wl_subsurface_place_above, libwayland_client), Cvoid, (Ptr{wl_subsurface}, Ptr{wl_surface}), wl_subsurface_, sibling)
end

"""
    wl_subsurface_place_below(wl_subsurface_, sibling)

` iface_wl_subsurface`

The sub-surface is placed just below the reference surface. See [`wl_subsurface`](@ref).place\\_above.
"""
function wl_subsurface_place_below(wl_subsurface_, sibling)
    ccall((:wl_subsurface_place_below, libwayland_client), Cvoid, (Ptr{wl_subsurface}, Ptr{wl_surface}), wl_subsurface_, sibling)
end

"""
    wl_subsurface_set_sync(wl_subsurface_)

` iface_wl_subsurface`

Change the commit behaviour of the sub-surface to synchronized mode, also described as the parent dependent mode.

In synchronized mode, [`wl_surface`](@ref).commit on a sub-surface will accumulate the committed state in a cache, but the state will not be applied and hence will not change the compositor output. The cached state is applied to the sub-surface immediately after the parent surface's state is applied. This ensures atomic updates of the parent and all its synchronized sub-surfaces. Applying the cached state will invalidate the cache, so further parent surface commits do not (re-)apply old state.

See [`wl_subsurface`](@ref) for the recursive effect of this mode.
"""
function wl_subsurface_set_sync(wl_subsurface_)
    ccall((:wl_subsurface_set_sync, libwayland_client), Cvoid, (Ptr{wl_subsurface},), wl_subsurface_)
end

"""
    wl_subsurface_set_desync(wl_subsurface_)

` iface_wl_subsurface`

Change the commit behaviour of the sub-surface to desynchronized mode, also described as independent or freely running mode.

In desynchronized mode, [`wl_surface`](@ref).commit on a sub-surface will apply the pending state directly, without caching, as happens normally with a [`wl_surface`](@ref). Calling [`wl_surface`](@ref).commit on the parent surface has no effect on the sub-surface's [`wl_surface`](@ref) state. This mode allows a sub-surface to be updated on its own.

If cached state exists when [`wl_surface`](@ref).commit is called in desynchronized mode, the pending state is added to the cached state, and applied as a whole. This invalidates the cache.

Note: even if a sub-surface is set to desynchronized, a parent sub-surface may override it to behave as synchronized. For details, see [`wl_subsurface`](@ref).

If a surface's parent surface behaves as desynchronized, then the cached state is applied on set\\_desync.
"""
function wl_subsurface_set_desync(wl_subsurface_)
    ccall((:wl_subsurface_set_desync, libwayland_client), Cvoid, (Ptr{wl_subsurface},), wl_subsurface_)
end

"""
` wl_object`

A protocol object.

A [`wl_object`](@ref) is an opaque struct identifying the protocol object underlying a [`wl_proxy`](@ref) or `wl_resource`.

!!! note

    Functions accessing a [`wl_object`](@ref) are not normally used by client code. Clients should normally use the higher level interface generated by the scanner to interact with compositor objects.
"""
const wl_object = Cvoid

# Skipping MacroDefinition: WL_EXPORT __attribute__ ( ( visibility ( "default" ) ) )

# Skipping MacroDefinition: WL_DEPRECATED __attribute__ ( ( deprecated ) )

const WAYLAND_VERSION_MAJOR = 1

const WAYLAND_VERSION_MINOR = 19

const WAYLAND_VERSION_MICRO = 0

const WAYLAND_VERSION = "1.19.0"

const WL_DISPLAY_SYNC = 0

const WL_DISPLAY_GET_REGISTRY = 1

const WL_DISPLAY_ERROR_SINCE_VERSION = 1

const WL_DISPLAY_DELETE_ID_SINCE_VERSION = 1

const WL_DISPLAY_SYNC_SINCE_VERSION = 1

const WL_DISPLAY_GET_REGISTRY_SINCE_VERSION = 1

const WL_REGISTRY_BIND = 0

const WL_REGISTRY_GLOBAL_SINCE_VERSION = 1

const WL_REGISTRY_GLOBAL_REMOVE_SINCE_VERSION = 1

const WL_REGISTRY_BIND_SINCE_VERSION = 1

const WL_CALLBACK_DONE_SINCE_VERSION = 1

const WL_COMPOSITOR_CREATE_SURFACE = 0

const WL_COMPOSITOR_CREATE_REGION = 1

const WL_COMPOSITOR_CREATE_SURFACE_SINCE_VERSION = 1

const WL_COMPOSITOR_CREATE_REGION_SINCE_VERSION = 1

const WL_SHM_POOL_CREATE_BUFFER = 0

const WL_SHM_POOL_DESTROY = 1

const WL_SHM_POOL_RESIZE = 2

const WL_SHM_POOL_CREATE_BUFFER_SINCE_VERSION = 1

const WL_SHM_POOL_DESTROY_SINCE_VERSION = 1

const WL_SHM_POOL_RESIZE_SINCE_VERSION = 1

const WL_SHM_CREATE_POOL = 0

const WL_SHM_FORMAT_SINCE_VERSION = 1

const WL_SHM_CREATE_POOL_SINCE_VERSION = 1

const WL_BUFFER_DESTROY = 0

const WL_BUFFER_RELEASE_SINCE_VERSION = 1

const WL_BUFFER_DESTROY_SINCE_VERSION = 1

const WL_DATA_OFFER_ACCEPT = 0

const WL_DATA_OFFER_RECEIVE = 1

const WL_DATA_OFFER_DESTROY = 2

const WL_DATA_OFFER_FINISH = 3

const WL_DATA_OFFER_SET_ACTIONS = 4

const WL_DATA_OFFER_OFFER_SINCE_VERSION = 1

const WL_DATA_OFFER_SOURCE_ACTIONS_SINCE_VERSION = 3

const WL_DATA_OFFER_ACTION_SINCE_VERSION = 3

const WL_DATA_OFFER_ACCEPT_SINCE_VERSION = 1

const WL_DATA_OFFER_RECEIVE_SINCE_VERSION = 1

const WL_DATA_OFFER_DESTROY_SINCE_VERSION = 1

const WL_DATA_OFFER_FINISH_SINCE_VERSION = 3

const WL_DATA_OFFER_SET_ACTIONS_SINCE_VERSION = 3

const WL_DATA_SOURCE_OFFER = 0

const WL_DATA_SOURCE_DESTROY = 1

const WL_DATA_SOURCE_SET_ACTIONS = 2

const WL_DATA_SOURCE_TARGET_SINCE_VERSION = 1

const WL_DATA_SOURCE_SEND_SINCE_VERSION = 1

const WL_DATA_SOURCE_CANCELLED_SINCE_VERSION = 1

const WL_DATA_SOURCE_DND_DROP_PERFORMED_SINCE_VERSION = 3

const WL_DATA_SOURCE_DND_FINISHED_SINCE_VERSION = 3

const WL_DATA_SOURCE_ACTION_SINCE_VERSION = 3

const WL_DATA_SOURCE_OFFER_SINCE_VERSION = 1

const WL_DATA_SOURCE_DESTROY_SINCE_VERSION = 1

const WL_DATA_SOURCE_SET_ACTIONS_SINCE_VERSION = 3

const WL_DATA_DEVICE_START_DRAG = 0

const WL_DATA_DEVICE_SET_SELECTION = 1

const WL_DATA_DEVICE_RELEASE = 2

const WL_DATA_DEVICE_DATA_OFFER_SINCE_VERSION = 1

const WL_DATA_DEVICE_ENTER_SINCE_VERSION = 1

const WL_DATA_DEVICE_LEAVE_SINCE_VERSION = 1

const WL_DATA_DEVICE_MOTION_SINCE_VERSION = 1

const WL_DATA_DEVICE_DROP_SINCE_VERSION = 1

const WL_DATA_DEVICE_SELECTION_SINCE_VERSION = 1

const WL_DATA_DEVICE_START_DRAG_SINCE_VERSION = 1

const WL_DATA_DEVICE_SET_SELECTION_SINCE_VERSION = 1

const WL_DATA_DEVICE_RELEASE_SINCE_VERSION = 2

const WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE = 0

const WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE = 1

const WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE_SINCE_VERSION = 1

const WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE_SINCE_VERSION = 1

const WL_SHELL_GET_SHELL_SURFACE = 0

const WL_SHELL_GET_SHELL_SURFACE_SINCE_VERSION = 1

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

const WL_SHELL_SURFACE_PING_SINCE_VERSION = 1

const WL_SHELL_SURFACE_CONFIGURE_SINCE_VERSION = 1

const WL_SHELL_SURFACE_POPUP_DONE_SINCE_VERSION = 1

const WL_SHELL_SURFACE_PONG_SINCE_VERSION = 1

const WL_SHELL_SURFACE_MOVE_SINCE_VERSION = 1

const WL_SHELL_SURFACE_RESIZE_SINCE_VERSION = 1

const WL_SHELL_SURFACE_SET_TOPLEVEL_SINCE_VERSION = 1

const WL_SHELL_SURFACE_SET_TRANSIENT_SINCE_VERSION = 1

const WL_SHELL_SURFACE_SET_FULLSCREEN_SINCE_VERSION = 1

const WL_SHELL_SURFACE_SET_POPUP_SINCE_VERSION = 1

const WL_SHELL_SURFACE_SET_MAXIMIZED_SINCE_VERSION = 1

const WL_SHELL_SURFACE_SET_TITLE_SINCE_VERSION = 1

const WL_SHELL_SURFACE_SET_CLASS_SINCE_VERSION = 1

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

const WL_SURFACE_ENTER_SINCE_VERSION = 1

const WL_SURFACE_LEAVE_SINCE_VERSION = 1

const WL_SURFACE_DESTROY_SINCE_VERSION = 1

const WL_SURFACE_ATTACH_SINCE_VERSION = 1

const WL_SURFACE_DAMAGE_SINCE_VERSION = 1

const WL_SURFACE_FRAME_SINCE_VERSION = 1

const WL_SURFACE_SET_OPAQUE_REGION_SINCE_VERSION = 1

const WL_SURFACE_SET_INPUT_REGION_SINCE_VERSION = 1

const WL_SURFACE_COMMIT_SINCE_VERSION = 1

const WL_SURFACE_SET_BUFFER_TRANSFORM_SINCE_VERSION = 2

const WL_SURFACE_SET_BUFFER_SCALE_SINCE_VERSION = 3

const WL_SURFACE_DAMAGE_BUFFER_SINCE_VERSION = 4

const WL_SEAT_GET_POINTER = 0

const WL_SEAT_GET_KEYBOARD = 1

const WL_SEAT_GET_TOUCH = 2

const WL_SEAT_RELEASE = 3

const WL_SEAT_CAPABILITIES_SINCE_VERSION = 1

const WL_SEAT_NAME_SINCE_VERSION = 2

const WL_SEAT_GET_POINTER_SINCE_VERSION = 1

const WL_SEAT_GET_KEYBOARD_SINCE_VERSION = 1

const WL_SEAT_GET_TOUCH_SINCE_VERSION = 1

const WL_SEAT_RELEASE_SINCE_VERSION = 5

const WL_POINTER_AXIS_SOURCE_WHEEL_TILT_SINCE_VERSION = 6

const WL_POINTER_SET_CURSOR = 0

const WL_POINTER_RELEASE = 1

const WL_POINTER_ENTER_SINCE_VERSION = 1

const WL_POINTER_LEAVE_SINCE_VERSION = 1

const WL_POINTER_MOTION_SINCE_VERSION = 1

const WL_POINTER_BUTTON_SINCE_VERSION = 1

const WL_POINTER_AXIS_SINCE_VERSION = 1

const WL_POINTER_FRAME_SINCE_VERSION = 5

const WL_POINTER_AXIS_SOURCE_SINCE_VERSION = 5

const WL_POINTER_AXIS_STOP_SINCE_VERSION = 5

const WL_POINTER_AXIS_DISCRETE_SINCE_VERSION = 5

const WL_POINTER_SET_CURSOR_SINCE_VERSION = 1

const WL_POINTER_RELEASE_SINCE_VERSION = 3

const WL_KEYBOARD_RELEASE = 0

const WL_KEYBOARD_KEYMAP_SINCE_VERSION = 1

const WL_KEYBOARD_ENTER_SINCE_VERSION = 1

const WL_KEYBOARD_LEAVE_SINCE_VERSION = 1

const WL_KEYBOARD_KEY_SINCE_VERSION = 1

const WL_KEYBOARD_MODIFIERS_SINCE_VERSION = 1

const WL_KEYBOARD_REPEAT_INFO_SINCE_VERSION = 4

const WL_KEYBOARD_RELEASE_SINCE_VERSION = 3

const WL_TOUCH_RELEASE = 0

const WL_TOUCH_DOWN_SINCE_VERSION = 1

const WL_TOUCH_UP_SINCE_VERSION = 1

const WL_TOUCH_MOTION_SINCE_VERSION = 1

const WL_TOUCH_FRAME_SINCE_VERSION = 1

const WL_TOUCH_CANCEL_SINCE_VERSION = 1

const WL_TOUCH_SHAPE_SINCE_VERSION = 6

const WL_TOUCH_ORIENTATION_SINCE_VERSION = 6

const WL_TOUCH_RELEASE_SINCE_VERSION = 3

const WL_OUTPUT_RELEASE = 0

const WL_OUTPUT_GEOMETRY_SINCE_VERSION = 1

const WL_OUTPUT_MODE_SINCE_VERSION = 1

const WL_OUTPUT_DONE_SINCE_VERSION = 2

const WL_OUTPUT_SCALE_SINCE_VERSION = 2

const WL_OUTPUT_RELEASE_SINCE_VERSION = 3

const WL_REGION_DESTROY = 0

const WL_REGION_ADD = 1

const WL_REGION_SUBTRACT = 2

const WL_REGION_DESTROY_SINCE_VERSION = 1

const WL_REGION_ADD_SINCE_VERSION = 1

const WL_REGION_SUBTRACT_SINCE_VERSION = 1

const WL_SUBCOMPOSITOR_DESTROY = 0

const WL_SUBCOMPOSITOR_GET_SUBSURFACE = 1

const WL_SUBCOMPOSITOR_DESTROY_SINCE_VERSION = 1

const WL_SUBCOMPOSITOR_GET_SUBSURFACE_SINCE_VERSION = 1

const WL_SUBSURFACE_DESTROY = 0

const WL_SUBSURFACE_SET_POSITION = 1

const WL_SUBSURFACE_PLACE_ABOVE = 2

const WL_SUBSURFACE_PLACE_BELOW = 3

const WL_SUBSURFACE_SET_SYNC = 4

const WL_SUBSURFACE_SET_DESYNC = 5

const WL_SUBSURFACE_DESTROY_SINCE_VERSION = 1

const WL_SUBSURFACE_SET_POSITION_SINCE_VERSION = 1

const WL_SUBSURFACE_PLACE_ABOVE_SINCE_VERSION = 1

const WL_SUBSURFACE_PLACE_BELOW_SINCE_VERSION = 1

const WL_SUBSURFACE_SET_SYNC_SINCE_VERSION = 1

const WL_SUBSURFACE_SET_DESYNC_SINCE_VERSION = 1

