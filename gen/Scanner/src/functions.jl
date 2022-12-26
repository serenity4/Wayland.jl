function snake_case_to_pascal_case(x)
  groups = split(x, '_')
  join(uppercasefirst.(groups))
end

enum_value_name(basename, val::EnumValue) = Symbol(uppercase(join((basename, val.name), '_')))

function generate_enum(enum::Enum, basename::String)
  basename == "xdg_positioner" && (basename *= enum.name)
  T = Symbol(join(snake_case_to_pascal_case.((basename, enum.name))))
  args = map(enum.values) do val
    lhs = enum_value_name(basename, val)
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

generate_functions(itf::Interface, slot_infos::SlotInfos) = generate_function.(itf.requests, itf, Ref(slot_infos))

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
  arg.type == ARGUMENT_TYPE_NEW_ID && return :C_NULL
  argname
end

function extract_arguments(itf::Interface, msg::Message)
  (; args) = msg
  implicit_arg = Argument(itf.name, ARGUMENT_TYPE_OBJECT, nothing, nothing, false, nothing)
  [implicit_arg; args]
end

function julia_type_c(t::Argument)
  jtype = julia_type(t)
  jtype == :Fixed && return :wl_fixed_t
  jtype
end

argument_name(arg) = Symbol(varname(name(arg)))

function generate_function(request::Request, itf::Interface, slot_infos::SlotInfos)
  fname = Symbol(join((itf.name, request.name), '_'))
  args = extract_arguments(itf, request)
  fargsdecl = Symbol[]
  libfname = :wl_proxy_marshal
  libfargs = []
  libfargs_variadic = []
  ret = nothing
  for (i, arg) in enumerate(args)
    argname = argument_name(arg)
    if arg.type == ARGUMENT_TYPE_NEW_ID
      @assert isnothing(ret)
      ret = arg
    else
      push!(fargsdecl, argname)
    end
    argex = argexpr(arg, argname)
    argex_typed = Expr(:(::), argex, julia_type_c(arg))
    if i == 1
      push!(libfargs, argex_typed)
      push!(libfargs, Expr(:(::), opcode(itf.name, request), :UInt32))
    else
      if arg === ret
        if isnothing(ret.interface)
          push!(fargsdecl, :interface, :version)
          push!(libfargs, :(interface::Ptr{wl_interface}), :(version::UInt32))
          push!(libfargs_variadic, :(unsafe_load(Ptr{wl_interface}(interface)).name::Ptr{Cchar}), :(version::UInt32))
        else
          offset = get(slot_infos.offsets, request, 0)
          interface = :(Wayland.interface_ptrs[$(offset + 1)])
          push!(libfargs, :($interface::Ptr{wl_interface}))
        end
      end
      push!(libfargs_variadic, argex_typed)
    end
  end
  isnothing(ret) && push!(libfargs, :(C_NULL::Ptr{wl_interface}))
  (isnothing(ret) || !isnothing(ret.interface)) && push!(libfargs, :(wl_proxy_get_version($(argument_name(args[1])))::UInt32))
  push!(libfargs, :(0::UInt32))

  libfcall = :(libwayland_client.wl_proxy_marshal_flags(
    $(libfargs...);
    $(libfargs_variadic...),
  ))
  isempty(libfargs_variadic) && deleteat!(libfcall.args, 2)
  prettify(Expr(:function, Expr(:call, fname, fargsdecl...), :(@ccall $libfcall::Ptr{Cvoid})))
end

function varname(name::String)
  startswith(name, "wl_") && return name[4:end]
  name
end
