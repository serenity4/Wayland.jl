listener_name(itf::Interface) = Symbol(join((itf.name, "listener"), '_'))

function unalias(name)
  in(name, (:global,)) && return Symbol(:_, name)
  name
end

function default_listener(itf::Interface, ev::Event)
  args = extract_arguments(itf, ev)
  argnames = argument_names(args)
  argdecls = length(argnames) == 1 ? argnames[1] : Expr(:tuple, argnames...)
  f = :($argdecls -> nothing)
  argtypes = map(x -> x === :Fixed ? :wl_fixed_t : x, julia_type.(args))
  ex = :(@cfunction $f Cvoid $(Expr(:tuple, argtypes...)))
  prettify(ex)
end

function generate_listener(itf::Interface)
  tname = listener_name(itf)
  fields = map(itf.events) do ev
    evname = unalias(Symbol(ev.name))
    default = default_listener(itf, ev)
    :($evname::FPtr = $default)
  end
  ex = :(Base.@kwdef struct $tname
    $(fields...)
  end)
  prettify(ex)
end

generate_listeners(itfs) = map(generate_listener, filter(itf -> !isempty(itf.events), itfs))
