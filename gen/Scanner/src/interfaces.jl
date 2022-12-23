get_interfaces() = Interface.(findall(".//interface", xroot[]))

function varname(name::String)
  startswith(name, "wl_") && return name[4:end]
  name
end

function compute_offsets(itfs)
  offsets = Dict{Message,Int}()
  offset = 0
  for itf in itfs
    for field in (:requests, :events)
      for msg in getproperty(itf, field)
        isempty(msg.args) && continue
        offsets[msg] = offset
        offset += length(msg.args)
      end
    end
  end
  offsets
end

function generate_function(itf::Interface)
  fname = Symbol(request.name)
  args = [varname(arg.name) for arg in request.args]
  push!(funcs, Expr(:function, Expr(:call, fname, implicit_arg, args...)))
end

function construct(itf::Interface, offsets)
  implicit_arg = Symbol(varname(itf.name))
  request_exs = Expr(:ref, :Message)
  event_exs = Expr(:ref, :Message)
  for request in itf.requests
    push!(request_exs.args, construct(request, offsets[request]))
  end
  for event in itf.events
    push!(event_exs.args, construct(event, offsets[event]))
  end
  Expr(:call, :Interface, itf.name, itf.version, request_exs, event_exs)
end

ptr_from_offset(offset) = :(getptr(wayland_interfaces[], $offset))

construct(msg::Message, offset) = Expr(:call, :Message, msg.name, signature(msg), ptr_from_offset(offset))

function signature(msg::Message)
  prefix = ""
  !isnothing(msg.since) && (prefix *= string(msg.since))
  foldl(*, signature.(msg.args); init = prefix)
end

function signature(t::Argument)
  str = signature(t.type)
  t.isnullable && (str = '?' * str)
  str
end

function signature(t::ArgumentType)
  t === ARGUMENT_TYPE_INT && return "i"
  t === ARGUMENT_TYPE_UINT && return "u"
  t === ARGUMENT_TYPE_FIXED && return "f"
  t === ARGUMENT_TYPE_OBJECT && return "o"
  t === ARGUMENT_TYPE_NEW_ID && return "n"
  t === ARGUMENT_signatureING && return "s"
  t === ARGUMENT_TYPE_ARRAY && return "a"
  t === ARGUMENT_TYPE_FD && return "h"
end
