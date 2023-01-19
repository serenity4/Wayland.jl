abstract type Handle end

Base.getindex(h::Handle) = Base.unsafe_convert(Ptr{Cvoid}, h)
Base.cconvert(::Type{Ptr{Cvoid}}, h::Handle) = h
Base.unsafe_convert(T::Type{Ptr{Cvoid}}, h::Handle) = Base.unsafe_convert(T, h.handle)

LibWayland.Listener(proxy::Handle, callbacks::ListenerCallbacks, data = nothing) = Listener(proxy[], callbacks, data)

mutable struct RefCounter
  @atomic val::UInt
end

RefCounter() = RefCounter(1)

increment!(rc::RefCounter) = (@atomic rc.val += 1)
decrement!(rc::RefCounter) = (@atomic rc.val -= 1)
Base.iszero(rc::RefCounter) = iszero(@atomic rc.val)

"""
Handle type which uses a reference counting system to prevent parent handles to be freed before their children.
"""
mutable struct RefcountHandle <: Handle
  handle::Ptr{Cvoid}
  refcount::RefCounter
  parent::Optional{RefcountHandle}
  destructor::Any
  function RefcountHandle(handle::Ptr{Cvoid}, destructor::Optional{Function}, parent::Optional{RefcountHandle} = nothing)
    rh = new(handle, RefCounter(), parent)
    rh.destructor = () -> try_destroy(destructor, rh)
    !isnothing(parent) && increment_refcount!(parent)
    finalizer(x -> x.destructor(), rh)
  end
end
RefcountHandle(handle::Ptr{Cvoid}, destructor::Optional{Function}, parent::Handle) = RefcountHandle(handle, destructor, parent.handle)

Base.show(io::IO, rh::RefcountHandle) = print(io, RefcountHandle, "(@", rh[], ", ", Int(@atomic(rh.refcount.val)), " reference(s))")

function increment_refcount!(handle::RefcountHandle)
  @pref_log_refcount increment!(handle.refcount)
end

function decrement_refcount!(handle::RefcountHandle)
  @pref_log_refcount decrement!(handle.refcount)
end

function destroy(f::Optional{Function}, handle::RefcountHandle)
  isnothing(f) && return false
  f(handle[])
  true
end

function try_destroy(f::Optional{Function}, handle::RefcountHandle)
  decrement_refcount!(handle)
  iszero(handle.refcount) || return
  @pref_log_destruction handle destroy(f, handle)
  !isnothing(handle.parent) && handle.parent.destructor()
end
