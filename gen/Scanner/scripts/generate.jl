cd(dirname(@__DIR__))
using Pkg; Pkg.activate(".")
using Scanner: Scanner, Interface, xroot, SlotInfos, construct_interfaces, generate_enums, generate_functions

itfs = Interface.(findall(".//interface", xroot[]))
slot_infos = SlotInfos(itfs)
libdir = joinpath(dirname(dirname(pkgdir(Scanner))), "lib")

function construct_protocol_interfaces(itfs, slot_infos)
  n = maximum(last, slot_infos.offsets) + 1
  target = joinpath(libdir, "interfaces.jl")
  open(target, "w+") do io
    println(io, :(const n = $n))
    println(io, construct_interfaces(itfs, slot_infos))
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

construct_protocol_interfaces(itfs, slot_infos)
construct_enums(itfs)
construct_functions(itfs, slot_infos)
