cd(dirname(@__DIR__))
using Pkg; Pkg.activate(".")
using Scanner: Scanner, Interface, xroot, compute_offsets, construct_interfaces, generate_enums

itfs = Interface.(findall(".//interface", xroot[]))
libdir = joinpath(dirname(dirname(pkgdir(Scanner))), "lib")

function construct_protocol_interfaces(itfs)
  offsets = compute_offsets(itfs)
  n = maximum(last, offsets) - 1
  target = joinpath(libdir, "interfaces.jl")
  open(target, "w+") do io
    println(io, :(const n = $n))
    println(io, Base.remove_linenums!(construct_interfaces(itfs, offsets)))
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

construct_protocol_interfaces(itfs)
construct_enums(itfs)
