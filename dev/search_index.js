var documenterSearchIndex = {"docs":
[{"location":"reference/api/#API-Reference","page":"API","title":"API Reference","text":"","category":"section"},{"location":"reference/api/#Wayland-C-bindings","page":"API","title":"Wayland C bindings","text":"","category":"section"},{"location":"reference/api/","page":"API","title":"API","text":"Modules = [LibWayland]","category":"page"},{"location":"reference/api/#Wayland.LibWayland.wl_argument","page":"API","title":"Wayland.LibWayland.wl_argument","text":"wl_argument\n\nProtocol message argument data types\n\nThis union represents all of the argument types in the Wayland protocol wire format. The protocol implementation uses wl_argument within its marshalling machinery for dispatching messages between a client and a compositor.\n\nSee also\n\nwl_message, wl_interface, <a href=\"https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-wire-Format\">Wire Format</a>\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_array","page":"API","title":"Wayland.LibWayland.wl_array","text":"wl_array\n\nwl_array\n\nDynamic array\n\nA wl_array is a dynamic array that can only grow until released. It is intended for relatively small allocations whose size is variable or not known in advance. While construction of a wl_array does not require all elements to be of the same size, wl_array_for_each() does require all elements to have the same type and size.\n\nField Note\nsize Array size\nalloc Allocated space\ndata Array data\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_dispatcher_func_t","page":"API","title":"Wayland.LibWayland.wl_dispatcher_func_t","text":"Dispatcher function type alias\n\nA dispatcher is a function that handles the emitting of callbacks in client code. For programs directly using the C library, this is done by using libffi to call function pointers. When binding to languages other than C, dispatchers provide a way to abstract the function calling process to be friendlier to other function calling systems.\n\nA dispatcher takes five arguments: The first is the dispatcher-specific implementation associated with the target object. The second is the object upon which the callback is being invoked (either wl_proxy or wl_resource). The third and fourth arguments are the opcode and the wl_message corresponding to the callback. The final argument is an array of arguments received from the other process via the wire protocol.\n\nParameters\n\n\"const: void *\" Dispatcher-specific implementation data\n\"void: *\" Callback invocation target (wl_proxy or wl_resource)\nuint32_t: Callback opcode\n\"const: struct wl_message *\" Callback message signature\n\"union: wl_argument *\" Array of received arguments\n\nReturns\n\n0 on success, or -1 on failure\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_display","page":"API","title":"Wayland.LibWayland.wl_display","text":"wl_display\n\nRepresents a connection to the compositor and acts as a proxy to the wl_display singleton object.\n\nA wl_display object represents a client connection to a Wayland compositor. It is created with either wldisplayconnect() or wldisplayconnecttofd(). A connection is terminated using wldisplaydisconnect().\n\nA wl_display is also used as the wlproxy for the [`wldisplay`](@ref) singleton object on the compositor side.\n\nA wl_display object handles all the data sent from and to the compositor. When a wlproxy marshals a request, it will write its wire representation to the display's write buffer. The data is sent to the compositor when the client calls wldisplay_flush().\n\nIncoming data is handled in two steps: queueing and dispatching. In the queue step, the data coming from the display fd is interpreted and added to a queue. On the dispatch step, the handler for the incoming event set by the client on the corresponding wl_proxy is called.\n\nA wl_display has at least one event queue, called the <em>default queue</em>. Clients can create additional event queues with wldisplaycreatequeue() and assign wlproxy's to it. Events occurring in a particular proxy are always queued in its assigned queue. A client can ensure that a certain assumption, such as holding a lock or running from a given thread, is true when a proxy event handler is called by assigning that proxy to an event queue and making sure that this queue is only dispatched when the assumption holds.\n\nThe default queue is dispatched by calling wldisplaydispatch(). This will dispatch any events queued on the default queue and attempt to read from the display fd if it's empty. Events read are then queued on the appropriate queues according to the proxy assignment.\n\nA user created queue is dispatched with wldisplaydispatchqueue(). This function behaves exactly the same as [`wldisplay_dispatch`](@ref)() but it dispatches given queue instead of the default queue.\n\nA real world example of event queue usage is Mesa's implementation of eglSwapBuffers() for the Wayland platform. This function might need to block until a frame callback is received, but dispatching the default queue could cause an event handler on the client to start drawing again. This problem is solved using another event queue, so that only the events handled by the EGL code are dispatched during the block.\n\nThis creates a problem where a thread dispatches a non-default queue, reading all the data from the display fd. If the application would call poll(2) after that it would block, even though there might be events queued on the default queue. Those events should be dispatched with wldisplaydispatchpending() or wldisplaydispatchqueue_pending() before flushing and blocking.\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_display_global_filter_func_t","page":"API","title":"Wayland.LibWayland.wl_display_global_filter_func_t","text":"A filter function for wl_global objects\n\nA filter function enables the server to decide which globals to advertise to each client.\n\nWhen a wl_global filter is set, the given callback function will be called during wl_global advertisement and binding.\n\nThis function should return true if the global object should be made visible to the client or false otherwise.\n\nParameters\n\nclient: The client object\nglobal: The global object to show or hide\ndata: The user data pointer\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_event_loop_fd_func_t","page":"API","title":"Wayland.LibWayland.wl_event_loop_fd_func_t","text":"File descriptor dispatch function type\n\nFunctions of this type are used as callbacks for file descriptor events.\n\nParameters\n\nfd: The file descriptor delivering the event.\nmask: Describes the kind of the event as a bitwise-or of: WL_EVENT_READABLE, WL_EVENT_WRITABLE, WL_EVENT_HANGUP, WL_EVENT_ERROR.\ndata: The user data argument of the related wl_event_loop_add_fd() call.\n\nReturns\n\nIf the event source is registered for re-check with wl_event_source_check(): 0 for all done, 1 for needing a re-check. If not registered, the return value is ignored and should be zero.\n\nSee also\n\nwl_event_loop_add_fd()  wl_event_source\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_event_loop_idle_func_t","page":"API","title":"Wayland.LibWayland.wl_event_loop_idle_func_t","text":"Idle task function type\n\nFunctions of this type are used as callbacks before blocking in wl_event_loop_dispatch().\n\nParameters\n\ndata: The user data argument of the related wl_event_loop_add_idle() call.\n\nSee also\n\nwl_event_loop_add_idle() wl_event_loop_dispatch()  wl_event_source\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_event_loop_signal_func_t","page":"API","title":"Wayland.LibWayland.wl_event_loop_signal_func_t","text":"Signal dispatch function type\n\nFunctions of this type are used as callbacks for (POSIX) signals.\n\nParameters\n\nsignal_number:\ndata: The user data argument of the related wl_event_loop_add_signal() call.\n\nReturns\n\nIf the event source is registered for re-check with wl_event_source_check(): 0 for all done, 1 for needing a re-check. If not registered, the return value is ignored and should be zero.\n\nSee also\n\nwl_event_loop_add_signal()  wl_event_source\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_event_loop_timer_func_t","page":"API","title":"Wayland.LibWayland.wl_event_loop_timer_func_t","text":"Timer dispatch function type\n\nFunctions of this type are used as callbacks for timer expiry.\n\nParameters\n\ndata: The user data argument of the related wl_event_loop_add_timer() call.\n\nReturns\n\nIf the event source is registered for re-check with wl_event_source_check(): 0 for all done, 1 for needing a re-check. If not registered, the return value is ignored and should be zero.\n\nSee also\n\nwl_event_loop_add_timer()  wl_event_source\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_event_queue","page":"API","title":"Wayland.LibWayland.wl_event_queue","text":"wl_event_queue\n\nA queue for wl_proxy object events.\n\nEvent queues allows the events on a display to be handled in a thread-safe manner. See wl_display for details.\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_fixed_t","page":"API","title":"Wayland.LibWayland.wl_fixed_t","text":"Fixed-point number\n\nA wl_fixed_t is a 24.8 signed fixed-point number with a sign bit, 23 bits of integer precision and 8 bits of decimal precision. Consider wl_fixed_t as an opaque struct with methods that facilitate conversion to and from double and int types.\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_interface","page":"API","title":"Wayland.LibWayland.wl_interface","text":"wl_interface\n\nProtocol object interface\n\nA wl_interface describes the API of a protocol object defined in the Wayland protocol specification. The protocol implementation uses a wl_interface within its marshalling machinery for encoding client requests.\n\nThe name of a wl_interface is the name of the corresponding protocol interface, and version represents the version of the interface. The members method_count and event_count represent the number of methods (requests) and events in the respective wl_message members.\n\nFor example, consider a protocol interface foo, marked as version 1, with two requests and one event.\n\n <interface name=\"foo\" version=\"1\">\n   <request name=\"a\"></request>\n   <request name=\"b\"></request>\n   <event name=\"c\"></event>\n </interface>\n\nGiven two wl_message arrays foo_requests and foo_events, a wl_interface for foo might be:\n\n struct wl_interface foo_interface = {\n         \"foo\", 1,\n         2, foo_requests,\n         1, foo_events\n };\n\nnote: Note\nThe server side of the protocol may define interface <em>implementation types</em> that incorporate the term interface in their name. Take care to not confuse these server-side structs with a wl_interface variable whose name also ends in interface. For example, while the server may define a type struct wl\\_foo\\_interface, the client may define a struct [wlinterface`](@ref) wl\\foo_interface`.\n\nField Note\nname Interface name\nversion Interface version\nmethod_count Number of methods (requests)\nmethods Method (request) signatures\nevent_count Number of events\nevents Event signatures\n\nSee also\n\nwl_message, wl_proxy, <a href=\"https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-Interfaces\">Interfaces</a>, <a href=\"https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-Versioning\">Versioning</a>\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_iterator_result","page":"API","title":"Wayland.LibWayland.wl_iterator_result","text":"wl_iterator_result\n\nReturn value of an iterator function\n\nEnumerator Note\nWL_ITERATOR_STOP Stop the iteration\nWL_ITERATOR_CONTINUE Continue the iteration\n\nSee also\n\nwl_client_for_each_resource_iterator_func_t, wl_client_for_each_resource\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_list","page":"API","title":"Wayland.LibWayland.wl_list","text":"wl_list\n\nwl_list\n\nDoubly-linked list\n\nOn its own, an instance of struct [wllist](@ref) represents the sentinel head of a doubly-linked list, and must be initialized using [`wllist_init](@ref)(). When empty, the list head'snextandprevmembers point to the list head itself, otherwisenextreferences the first element in the list, andprev` refers to the last element in the list.\n\nUse the struct [wllist](@ref) type to represent both the list head and the links between elements within the list. Use [`wllist_empty`](@ref)() to determine if the list is empty in O(1).\n\nAll elements in the list must be of the same type. The element type must have a struct [wllist](@ref) member, often named link by convention. Prior to insertion, there is no need to initialize an element's link - invoking [`wllistinit](@ref)() on an individual list element'sstruct [`wllist](@ref) member is unnecessary if the very next operation is wl_list_insert(). However, a common idiom is to initialize an element's link prior to removal - ensure safety by invoking wl_list_init() before wl_list_remove().\n\nConsider a list reference struct [wllist`](@ref) foo\\list, an element type asstruct element, and an element's link member asstruct wl_list link`.\n\nThe following code initializes a list and adds three elements to it.\n\n struct wl_list foo_list;\n struct element {\n         int foo;\n         struct wl_list link;\n };\n struct element e1, e2, e3;\n wl_list_init(&foo_list);\n wl_list_insert(&foo_list, &e1.link);   // e1 is the first element\n wl_list_insert(&foo_list, &e2.link);   // e2 is now the first element\n wl_list_insert(&e2.link, &e3.link); // insert e3 after e2\n\nThe list now looks like <em>[e2, e3, e1]</em>.\n\nThe wl_list API provides some iterator macros. For example, to iterate a list in ascending order:\n\n struct element *e;\n wl_list_for_each(e, foo_list, link) {\n         do_something_with_element(e);\n }\n\nSee the documentation of each iterator for details.\n\nField Note\nprev Previous list element\nnext Next list element\n\nSee also\n\nhttp://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_listener","page":"API","title":"Wayland.LibWayland.wl_listener","text":"wl_listener\n\nwl_listener\n\nA single listener for Wayland signals\n\nwl_listener provides the means to listen for wl_signal notifications. Many Wayland objects use wl_listener for notification of significant events like object destruction.\n\nClients should create wl_listener objects manually and can register them as listeners to signals using #wl_signal_add, assuming the signal is directly accessible. For opaque structs like wl_event_loop, adding a listener should be done through provided accessor methods. A listener can only listen to one signal at a time.\n\n struct wl_listener your_listener;\n your_listener.notify = your_callback_method;\n // Direct access\n wl_signal_add(&some_object->destroy_signal, &your_listener);\n // Accessor access\n wl_event_loop *loop = ...;\n wl_event_loop_add_destroy_listener(loop, &your_listener);\n\nIf the listener is part of a larger struct, #wl_container_of can be used to retrieve a pointer to it:\n\n void your_listener(struct wl_listener *listener, void *data)\n {\n \tstruct your_data *data;\n \tyour_data = wl_container_of(listener, data, your_member_name);\n }\n\nIf you need to remove a listener from a signal, use wl_list_remove().\n\n wl_list_remove(&your_listener.link);\n\nSee also\n\nwl_signal\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_log_func_t","page":"API","title":"Wayland.LibWayland.wl_log_func_t","text":"Log function type alias\n\nThe C implementation of the Wayland protocol abstracts the details of logging. Users may customize the logging behavior, with a function conforming to the wl_log_func_t type, via wl_log_set_handler_client and wl_log_set_handler_server.\n\nA wl_log_func_t must conform to the expectations of vprintf, and expects two arguments: a string to write and a corresponding variable argument list. While the string to write may contain format specifiers and use values in the variable argument list, the behavior of any wl_log_func_t depends on the implementation.\n\nnote: Note\nTake care to not confuse this with wl_protocol_logger_func_t, which is a specific server-side logger for requests and events.\n\nParameters\n\n\"const: char *\" String to write to the log, containing optional format specifiers\n\"va_list\": Variable argument list\n\nSee also\n\nwl_log_set_handler_client, wl_log_set_handler_server\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_message","page":"API","title":"Wayland.LibWayland.wl_message","text":"wl_message\n\nProtocol message signature\n\nA wl_message describes the signature of an actual protocol message, such as a request or event, that adheres to the Wayland protocol wire format. The protocol implementation uses a wl_message within its demarshal machinery for decoding messages between a compositor and its clients. In a sense, a wl_message is to a protocol message like a class is to an object.\n\nThe name of a wl_message is the name of the corresponding protocol message.\n\nThe signature is an ordered list of symbols representing the data types of message arguments and, optionally, a protocol version and indicators for nullability. A leading integer in the signature indicates the _since_ version of the protocol message. A ? preceding a data type symbol indicates that the following argument type is nullable. While it is a protocol violation to send messages with non-nullable arguments set to NULL, event handlers in clients might still get called with non-nullable object arguments set to NULL. This can happen when the client destroyed the object being used as argument on its side and an event referencing that object was sent before the server knew about its destruction. As this race cannot be prevented, clients should - as a general rule - program their event handlers such that they can handle object arguments declared non-nullable being NULL gracefully.\n\nWhen no arguments accompany a message, signature is an empty string.\n\nSymbols:\n\ni: int * u: uint * f: fixed * s: string * o: object * n: new_id * a: array * h: fd * ?: following argument is nullable\n\nWhile demarshaling primitive arguments is straightforward, when demarshaling messages containing object or new_id arguments, the protocol implementation often must determine the type of the object. The types of a wl_message is an array of wl_interface references that correspond to o and n arguments in signature, with NULL placeholders for arguments with non-object types.\n\nConsider the protocol event wl_display delete_id that has a single uint argument. The wl_message is:\n\n { \"delete_id\", \"u\", [NULL] }\n\nHere, the message name is \"delete\\_id\", the signature is \"u\", and the argument types is [NULL], indicating that the uint argument has no corresponding wl_interface since it is a primitive argument.\n\nIn contrast, consider a wl_foo interface supporting protocol request bar that has existed since version 2, and has two arguments: a uint and an object of type wl_baz_interface that may be NULL. Such a wl_message might be:\n\n { \"bar\", \"2u?o\", [NULL, &wl_baz_interface] }\n\nHere, the message name is \"bar\", and the signature is \"2u?o\". Notice how the 2 indicates the protocol version, the u indicates the first argument type is uint, and the ?o indicates that the second argument is an object that may be NULL. Lastly, the argument types array indicates that no wl_interface corresponds to the first argument, while the type wl_baz_interface corresponds to the second argument.\n\nField Note\nname Message name\nsignature Message signature\ntypes Object argument interfaces\n\nSee also\n\nwl_argument, wl_interface, <a href=\"https://wayland.freedesktop.org/docs/html/ch04.html#sect-Protocol-Wire-Format\">Wire Format</a>\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_object","page":"API","title":"Wayland.LibWayland.wl_object","text":"wl_object\n\nA protocol object.\n\nA wl_object is an opaque struct identifying the protocol object underlying a wl_proxy or wl_resource.\n\nnote: Note\nFunctions accessing a wl_object are not normally used by client code. Clients should normally use the higher level interface generated by the scanner to interact with compositor objects.\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_proxy","page":"API","title":"Wayland.LibWayland.wl_proxy","text":"wl_proxy\n\nRepresents a protocol object on the client side.\n\nA wl_proxy acts as a client side proxy to an object existing in the compositor. The proxy is responsible for converting requests made by the clients with wlproxymarshal() into Wayland's wire format. Events coming from the compositor are also handled by the proxy, which will in turn call the handler set with wlproxyadd_listener().\n\nnote: Note\nWith the exception of function wlproxysetqueue(), functions accessing a [`wlproxy`](@ref) are not normally used by client code. Clients should normally use the higher level interface generated by the scanner to interact with compositor objects.\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_signal","page":"API","title":"Wayland.LibWayland.wl_signal","text":"wl_signal\n\nwl_signal\n\nA source of a type of observable event\n\nSignals are recognized points where significant events can be observed. Compositors as well as the server can provide signals. Observers are wl_listener's that are added through #wl_signal_add. Signals are emitted using #wl_signal_emit, which will invoke all listeners until that listener is removed by wl_list_remove() (or whenever the signal is destroyed).\n\nSee also\n\nwl_listener for more information on using wl_signal\n\n\n\n\n\n","category":"type"},{"location":"reference/api/#Wayland.LibWayland.wl_array_add-Tuple{Any, Any}","page":"API","title":"Wayland.LibWayland.wl_array_add","text":"wl_array_add(array, size)\n\nIncreases the size of the array by size bytes.\n\nwl_array\n\nParameters\n\narray: Array whose size is to be increased\nsize: Number of bytes to increase the size of the array by\n\nReturns\n\nA pointer to the beginning of the newly appended space, or NULL when resizing fails.\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_array_copy-Tuple{Any, Any}","page":"API","title":"Wayland.LibWayland.wl_array_copy","text":"wl_array_copy(array, source)\n\nCopies the contents of source to array.\n\nwl_array\n\nParameters\n\narray: Destination array to copy to\nsource: Source array to copy from\n\nReturns\n\n0 on success, or -1 on failure\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_array_init-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_array_init","text":"wl_array_init(array)\n\nInitializes the array.\n\nwl_array\n\nParameters\n\narray: Array to initialize\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_array_release-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_array_release","text":"wl_array_release(array)\n\nReleases the array data.\n\nnote: Note\nLeaves the array in an invalid state.\n\nwl_array\n\nParameters\n\narray: Array whose data is to be released\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_event_loop_create-Tuple{}","page":"API","title":"Wayland.LibWayland.wl_event_loop_create","text":"wl_event_loop_create()\n\nwl_event_source\n\nAn abstract event source\n\nThis is the generic type for fd, timer, signal, and idle sources. Functions that operate on specific source types must not be used with a different type, even if the function signature allows it.\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_fixed_from_double-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_fixed_from_double","text":"wl_fixed_from_double(d)\n\nConverts a floating-point number to a fixed-point number.\n\nParameters\n\nd: Floating-point number to convert\n\nReturns\n\nFixed-point representation of the floating-point argument\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_fixed_from_int-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_fixed_from_int","text":"wl_fixed_from_int(i)\n\nConverts an integer to a fixed-point number.\n\nParameters\n\ni: Integer to convert\n\nReturns\n\nFixed-point representation of the integer argument\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_fixed_to_double-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_fixed_to_double","text":"wl_fixed_to_double(f)\n\nConverts a fixed-point number to a floating-point number.\n\nParameters\n\nf: Fixed-point number to convert\n\nReturns\n\nFloating-point representation of the fixed-point argument\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_fixed_to_int-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_fixed_to_int","text":"wl_fixed_to_int(f)\n\nConverts a fixed-point number to an integer.\n\nParameters\n\nf: Fixed-point number to convert\n\nReturns\n\nInteger component of the fixed-point argument\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_list_empty-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_list_empty","text":"wl_list_empty(list)\n\nDetermines if the list is empty.\n\nwl_list\n\nParameters\n\nlist: List whose emptiness is to be determined\n\nReturns\n\n1 if empty, or 0 if not empty\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_list_init-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_list_init","text":"wl_list_init(list)\n\nInitializes the list.\n\nwl_list\n\nParameters\n\nlist: List to initialize\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_list_insert-Tuple{Any, Any}","page":"API","title":"Wayland.LibWayland.wl_list_insert","text":"wl_list_insert(list, elm)\n\nInserts an element into the list, after the element represented by list. When list is a reference to the list itself (the head), set the containing struct of elm as the first element in the list.\n\nnote: Note\nIf elm is already part of a list, inserting it again will lead to list corruption.\n\nwl_list\n\nParameters\n\nlist: List element after which the new element is inserted\nelm: Link of the containing struct to insert into the list\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_list_insert_list-Tuple{Any, Any}","page":"API","title":"Wayland.LibWayland.wl_list_insert_list","text":"wl_list_insert_list(list, other)\n\nInserts all of the elements of one list into another, after the element represented by list.\n\nnote: Note\nThis leaves other in an invalid state.\n\nwl_list\n\nParameters\n\nlist: List element after which the other list elements will be inserted\nother: List of elements to insert\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_list_length-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_list_length","text":"wl_list_length(list)\n\nDetermines the length of the list.\n\nnote: Note\nThis is an O(n) operation.\n\nwl_list\n\nParameters\n\nlist: List whose length is to be determined\n\nReturns\n\nNumber of elements in the list\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_list_remove-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_list_remove","text":"wl_list_remove(elm)\n\nRemoves an element from the list.\n\nnote: Note\nThis operation leaves elm in an invalid state.\n\nwl_list\n\nParameters\n\nelm: Link of the containing struct to remove from the list\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_signal_add-Tuple{Any, Any}","page":"API","title":"Wayland.LibWayland.wl_signal_add","text":"wl_signal_add(signal, listener)\n\nAdd the specified listener to this signal.\n\nwl_signal\n\nParameters\n\nsignal: The signal that will emit events to the listener\nlistener: The listener to add\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_signal_emit-Tuple{Any, Any}","page":"API","title":"Wayland.LibWayland.wl_signal_emit","text":"wl_signal_emit(signal, data)\n\nEmits this signal, notifying all registered listeners.\n\nwl_signal\n\nParameters\n\nsignal: The signal object that will emit the signal\ndata: The data that will be emitted with the signal\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_signal_get-Tuple{Any, Any}","page":"API","title":"Wayland.LibWayland.wl_signal_get","text":"wl_signal_get(signal, notify)\n\nGets the listener struct for the specified callback.\n\nwl_signal\n\nParameters\n\nsignal: The signal that contains the specified listener\nnotify: The listener that is the target of this search\n\nReturns\n\nthe list item that corresponds to the specified listener, or NULL if none was found\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#Wayland.LibWayland.wl_signal_init-Tuple{Any}","page":"API","title":"Wayland.LibWayland.wl_signal_init","text":"wl_signal_init(signal)\n\nInitialize a new wl_signal for use.\n\nwl_signal\n\nParameters\n\nsignal: The signal that will be initialized\n\n\n\n\n\n","category":"method"},{"location":"#Wayland.jl","page":"Home","title":"Wayland.jl","text":"","category":"section"},{"location":"#Status","page":"Home","title":"Status","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is currently in development. The source code and public API may change at any moment. Use at your own risk.","category":"page"},{"location":"#Wrapping-libwayland-vs-reimplementing-the-protocol","page":"Home","title":"Wrapping libwayland vs reimplementing the protocol","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The reason we wrap the C implementation libwayland instead of providing our own implementation of the Wayland protocol is driver compatibility. Unfortunately, in the current state of affairs graphics drivers such as Mesa for OpenGL or other proprietary drivers are likely to rely on linking with libwayland-client and calling it with C pointers, which expect to be ABI-compatible with the C implementation. See for example the Vulkan integration with Wayland which requires struct wl_display *display and struct wl_surface *surface pointers.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Reimplementing the protocol in Julia with full interoperability would mean requiring data structures compatible with the C ABI, which would defeat the purpose of a pure Julia implementation of the protocol.","category":"page"}]
}