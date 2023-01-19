listener_name(itf::Interface) = Symbol(join((itf.name, "listener"), '_'))

function unalias(name)
  in(name, (:global,)) && return Symbol(:_, name)
  name
end

cfunction_macro_name(itf, msg; with_at = true) = Symbol(join(("$(with_at ? '@' : "")cfunction", itf.name, msg.name), '_'))

generate_cfunction_wrappers(itf::Interface) = generate_cfunction_wrapper.(itf, itf.events)
generate_cfunction_wrappers(itfs) = [generate_cfunction_wrappers.(itfs)...;]

function generate_cfunction_wrapper(itf::Interface, msg::Message)
  macro_name = cfunction_macro_name(itf, msg; with_at = false)
  args = extract_arguments(itf, msg)
  # There is an implicit `void *data` argument inserted at the start of the signature.
  pushfirst!(args, Argument("data", ARGUMENT_TYPE_OBJECT, nothing, nothing, false, nothing))
  argtypes = map(x -> x === :Fixed ? :wl_fixed_t : x, julia_type.(args))
  ex = :(macro $macro_name(f) esc($(Expr(:quote, :(Base.@cfunction $(Expr(:$, :f)) Cvoid $(Expr(:tuple, argtypes...)))))) end)
  prettify(ex)
end

function generate_listener(itf::Interface)
  tname = listener_name(itf)
  fields = map(itf.events) do ev
    evname = unalias(Symbol(ev.name))
    :($evname::FPtr)
  end
  ex = :(struct $tname <: ListenerCallbacks
    $(fields...)
  end)
  prettify(ex)
end

generate_listeners(itfs) = map(generate_listener, filter(itf -> !isempty(itf.events), itfs))
