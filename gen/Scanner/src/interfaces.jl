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
    push!(request_exs.args, construct(request, get(offsets, request, 0)))
  end
  for event in itf.events
    push!(event_exs.args, construct(event, get(offsets, event, 0)))
  end
  Expr(:call, :Interface, itf.name, itf.version, request_exs, event_exs)
end

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
  t === ARGUMENT_TYPE_STRING && return "s"
  t === ARGUMENT_TYPE_ARRAY && return "a"
  t === ARGUMENT_TYPE_FD && return "h"
end

ptr_from_offset(offset) = :(getptr(wayland_interfaces[], $offset))

function null_indices(itfs)
  indices = Int[]
  offset = 0
  for itf in itfs
    for field in (:requests, :events)
      for msg in getproperty(itf, field)
        isempty(msg.args) && continue
        for arg in msg.args
          if !contains(signature(arg), r"[on]")
            push!(indices, offset)
            offset += 1
          end
        end
      end
    end
  end
  indices
end

function nullify_interfaces(itfs)
  indices = null_indices(itfs)
  :(for i in $indices
      Base.unsafe_store!(wayland_interfaces[], Ptr{Ptr{wl_interface}}(C_NULL), i)
  end)
end

function construct_interfaces(itfs, offsets = compute_offsets(itfs))
  ex = :(function fill_interfaces!!(refs::Vector{Base.RefValue{wl_interface}}, structs::Vector{Interface})
    _fill_interface!!(itf) = fill_interface!!(refs, structs, itf)
  end)
  body = ex.args[2]
  push!(body.args, nullify_interfaces(itfs))
  for itf in itfs
    push!(body.args, Expr(:call, :_fill_interface!!, construct(itf, offsets)))
  end
  ex
end
