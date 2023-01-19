abstract type Handle end

Base.getindex(h::Handle) = h.handle
Base.cconvert(::Type{Ptr{Cvoid}}, h::Handle) = h
Base.unsafe_convert(::Type{Ptr{Cvoid}}, h::Handle) = h[]

LibWayland.Listener(proxy::Handle, callbacks::ListenerCallbacks) = Listener(proxy[], callbacks)
