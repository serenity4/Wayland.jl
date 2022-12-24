function snake_case_to_pascal_case(x)
  groups = split(x, '_')
  join(uppercasefirst.(groups))
end

function generate_enum(enum::Enum, basename::String)
  T = Symbol(join(snake_case_to_pascal_case.((basename, enum.name))))
  args = map(enum.values) do val
    lhs = Symbol(uppercase(join((basename, val.name), '_')))
    :($lhs = $(Int32(val.value)))
  end
  (m, ET) = enum.bitfield ? (Symbol("@bitmask"), :UInt32) : (Symbol("@enum"), :Int32)
  ex = Expr(:macrocall, m, nothing, :($T::$ET), Expr(:block, args...))
  prettify(ex)
end

generate_enums(itfs) = foldl(vcat, map(generate_enums, itfs); init = Expr[])
generate_enums(itf::Interface) = map(x -> generate_enum(x, itf.name), itf.enums)

function generate_functions(itfs, slot_infos = SlotInfos(itfs))
  exs = Expr[]
  for itf in itfs
    append!(exs, generate_opcodes(itf))
    append!(exs, generate_functions(itf, slot_infos))
  end
  exs
end

generate_opcodes(itfs) = foldl(vcat, map(generate_opcodes, itfs); init = Expr[])

opcode(basename, msg::Message) = Symbol(uppercase(join((basename, msg.name), '_')))

function generate_opcodes(itf::Interface)
  i = 0
  defs = Expr[]
  for field in (:requests, :events)
    for msg in getproperty(itf, field)
      name = opcode(itf.name, msg)
      push!(defs, :(const $name = $i))
      i += 1
    end
  end
  defs
end

generate_functions(itf::Interface, slot_infos::SlotInfos) = generate_function.(itf.requests, itf, Ref(slot_infos)) #; generate_function.(itf.events)]

julia_type(arg::Argument) = julia_type(arg.type)
function julia_type(t::ArgumentType)
  t === ARGUMENT_TYPE_INT && return :Int32
  t === ARGUMENT_TYPE_UINT && return :UInt32
  t === ARGUMENT_TYPE_FIXED && return :Fixed
  t === ARGUMENT_TYPE_OBJECT && return :(Ptr{Cvoid})
  t === ARGUMENT_TYPE_NEW_ID && return :(Ptr{Cvoid})
  t === ARGUMENT_TYPE_STRING && return :(Ptr{Cchar})
  t === ARGUMENT_TYPE_ARRAY && return :(Ptr{wl_array})
  t === ARGUMENT_TYPE_FD && return :Int32
  t === ARGUMENT_TYPE_ENUM && return :Int32
end

function argexpr(arg::Argument, argname)
  arg.type == ARGUMENT_TYPE_FIXED && return :(convert(Fixed, $argname))
  argname
end

function extract_arguments(itf::Interface, msg::Message)
  (; args) = msg
  implicit_arg = Argument(itf.name, ARGUMENT_TYPE_OBJECT, nothing, nothing, false, nothing)
  [implicit_arg; args]
end

argument_names(args) = Symbol.(varname.(name.(args)))

function generate_function(request::Request, itf::Interface, slot_infos::SlotInfos)
  args = extract_arguments(itf, request)
  argnames = argument_names(args)
  argexs = argexpr.(args, argnames)
  argexs_typed = Expr.(:(::), argexs, julia_type.(args))
  fname = Symbol(join((itf.name, request.name), '_'))
  (; args) = request
  implicit_arg = Argument(itf.name, ARGUMENT_TYPE_OBJECT, nothing, nothing, false, nothing)
  args = [implicit_arg; args]
  argnames = Symbol.(varname.(name.(args)))
  argexs = argexpr.(args, argnames)
  argexs_typed = Expr.(:(::), argexs, julia_type.(args))
  offset = get(slot_infos.offsets, request, 0)
  interface = :(Wayland.wayland_interface_ptrs[$(offset + 1)])
  constructor, extras = (:wl_proxy_marshal_constructor, ())
  !isnothing(request.since) && ((constructor, extras) = (:wl_proxy_marshal_constructor_versioned, (Expr(:(::), UInt32(request.since), :UInt32),)))
  constructor_call = :(libwayland_client.$constructor(
    $(argexs_typed[1]),
    $(opcode(itf.name, request))::UInt32,
    $interface::Ptr{wl_interface},
    $(extras...);
    $(argexs_typed[2:end]...),
  ))
  parameters = constructor_call.args[2].args
  isempty(parameters) && deleteat!(constructor_call.args, 2)
  prettify(Expr(:function, Expr(:call, fname, argnames...), :(@ccall $constructor_call::Ptr{Cvoid})))
end

function varname(name::String)
  startswith(name, "wl_") && return name[4:end]
  name
end
