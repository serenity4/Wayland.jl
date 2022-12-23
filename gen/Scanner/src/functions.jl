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
  remove_linenums!(ex)
end

generate_enums(itfs) = foldl(vcat, map(generate_enums, itfs); init = Expr[])
generate_enums(itf::Interface) = map(x -> generate_enum(x, itf.name), itf.enums)

function generate_functions(itfs)
  exs = Expr[]
  enums = Expr[]
  funcs = Expr[]
  for itf in itfs
    push!(exs, generate_opcodes(itf))
    for enum in itf.enums
      push!(enums, )
    end
    append!(funcs, generate_functions(itf))
  end
  funcs
end

generate_opcodes(itfs) = foldl(vcat, map(generate_opcodes, itfs); init = Expr[])

function generate_opcodes(itf::Interface)
  i = 0
  defs = Expr[]
  for field in (:requests, :events)
    for msg in getproperty(itf, field)
      name = Symbol(uppercase(join((itf.name, msg.name), '_')))
      push!(defs, :(const $name = $i))
      i += 1
    end
  end
  defs
end

generate_functions(itf::Interface) = [generate_function.(itf.requests); generate_function.(itf.events)]

function generate_function(request::Request)
  ex = Expr(:function)
  # TODO
end

# function wl_display_get_registry(display)
#   proxy = wl_proxy_marshal_array_constructor(Base.unsafe_convert(Ptr{wl_display}, display), WL_DISPLAY_GET_REGISTRY, getptr(wayland_interface_ptrs, 2), NULL)
#   Ptr{wl_registry}(proxy)
# end
