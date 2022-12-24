get_interfaces() = Interface.(findall(".//interface", xroot[]))

struct SlotInfos
  "0-based offset to apply to the pointer to get the required slot range for a given message."
  offsets::Dict{Message,Int}
  "1-based indices from interfaces to a set of slots which represent them."
  slots::Dict{Interface,Vector{Int}}
  "1-based indices of slots that should be C_NULL."
  nulls::Vector{Int}
end

Base.show(io::IO, ::MIME"text/plain", info::SlotInfos) = print(io, SlotInfos, "(...)")

function SlotInfos(itfs)
  slot_infos = SlotInfos(Dict{Message,Int}(), Dict{Interface,Vector{Int}}(), Int[])
  offset = 0
  for itf in itfs
    for field in (:requests, :events)
      for msg in getproperty(itf, field)
        isempty(msg.args) && continue
        slot_infos.offsets[msg] = offset
        for arg in msg.args
          i = offset + 1
          if !contains(signature(arg), r"[on]")
            push!(slot_infos.nulls, i)
          end
          if !isnothing(arg.interface)
            used_itf = itfs[findfirst(==(arg.interface) ∘ name, itfs)::Int]
            push!(get!(Vector{Int}, slot_infos.slots, used_itf), i)
          end
          offset += 1
        end
      end
    end
  end
  for itf in itfs
    if !haskey(slot_infos.slots, itf)
      slot_infos.slots[itf] = [offset += 1]
    end
  end
  slot_infos
end

max_slotindex(slot_infos::SlotInfos) = maximum(maximum, values(slot_infos.slots))

function construct(itf::Interface, slot_infos::SlotInfos)
  implicit_arg = Symbol(varname(itf.name))
  request_exs = Expr(:ref, :Message)
  event_exs = Expr(:ref, :Message)
  for request in itf.requests
    push!(request_exs.args, construct(request, get(slot_infos.offsets, request, 0)))
  end
  for event in itf.events
    push!(event_exs.args, construct(event, get(slot_infos.offsets, event, 0)))
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
  # There are two implicit arguments for "new id" argument types that don't have an associated interface.
  # These two arguments are the (string) name of the inteface and the version of the interface.
  isnothing(t.interface) && t.type == ARGUMENT_TYPE_NEW_ID && (str = "su" * str)
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

ptr_from_offset(offset) = :(getptr(interface_slots[], $(offset + 1)))

function nullify_slots(slot_infos::SlotInfos)
  :(for i in $(slot_infos.nulls)
      Base.unsafe_store!(interface_slots[], Ptr{Ptr{wl_interface}}(C_NULL), i)
  end)
end

function construct_interfaces(itfs, slot_infos = SlotInfos(itfs))
  ex = :(function fill_interfaces!!(refs::Vector{Base.RefValue{wl_interface}}, structs::Vector{Interface})
    _fill_interface!!(itf, slots) = fill_interface!!(refs, structs, itf, slots)
  end)
  body = ex.args[2]
  push!(body.args, nullify_slots(slot_infos))
  for itf in itfs
    push!(body.args, Expr(:call, :_fill_interface!!, construct(itf, slot_infos), Expr(:ref, :Int, get(Vector{Int}, slot_infos.slots, itf)...)))
  end
  prettify(ex)
end
