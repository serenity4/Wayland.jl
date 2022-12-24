cd(dirname(@__DIR__))
using Pkg: Pkg; Pkg.activate(".")
using Scanner: Scanner, Interface, xroot, SlotInfos, construct_interfaces, generate_enums, generate_functions, generate_cfunction_wrappers, generate_listeners, max_slotindex
using MacroTools: prettify

itfs = Interface.(findall(".//interface", xroot[]))
slot_infos = SlotInfos(itfs)
libdir = joinpath(dirname(dirname(pkgdir(Scanner))), "lib")

function construct_protocol_interfaces(itfs, slot_infos)
  n = max_slotindex(slot_infos)
  target = joinpath(libdir, "interfaces.jl")
  open(target, "w+") do io
    println(io, :(const n = $n))
    println(io)
    println(io, construct_interfaces(itfs, slot_infos))
    println(io)
    pairs = map(itf -> :($(QuoteNode(Symbol(itf.name))) => interface_ptrs[$(first(slot_infos.slots[itf]))]), filter(itf -> haskey(slot_infos.slots, itf), itfs))
    println(io, prettify(:(function fill_interface_dict!(dict, interface_ptrs)
      merge!(dict, Dict{Symbol,Ptr{wl_interface}}(($(pairs...))))
    end)))
  end
  @info "Protocol interfaces successfully written at $target"
end

function construct_enums(itfs)
  target = joinpath(libdir, "enums.jl")
  open(target, "w+") do io
    for ex in generate_enums(itfs)
      println(io, ex)
      println(io)
    end
  end
  @info "Enum definitions successfully written at $target"
end

function construct_functions(itfs, slot_infos)
  target = joinpath(libdir, "functions.jl")
  open(target, "w+") do io
    for ex in generate_functions(itfs)
      println(io, ex)
      !Meta.isexpr(ex, :const) && println(io)
    end
  end
  @info "Function definitions successfully written at $target"
end

function construct_listeners(itfs)
  target = joinpath(libdir, "listeners.jl")
  open(target, "w+") do io
    for ex in generate_cfunction_wrappers(itfs)
      println(io, ex)
    end
    println(io)
    for ex in generate_listeners(itfs)
      println(io, ex)
      println(io)
    end
  end
  @info "Function definitions successfully written at $target"
end

construct_protocol_interfaces(itfs, slot_infos)
construct_enums(itfs)
construct_functions(itfs, slot_infos)
construct_listeners(itfs)
