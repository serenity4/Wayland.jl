using Scanner: Scanner, Interface, xroot, compute_offsets, construct_interfaces

cd(dirname(@__DIR__))
using Pkg; Pkg.activate(".")

itfs = Interface.(findall(".//interface", xroot[]))

function construct_protocol_interfaces(itfs)
  offsets = compute_offsets(itfs)
  n = maximum(last, offsets) - 1
  target = joinpath(dirname(dirname(pkgdir(Scanner))), "lib", "interfaces.jl")
  open(target, "w+") do io
    println(io, :(const n = $n))
    println(io, Base.remove_linenums!(construct_interfaces(itfs, offsets)))
  end
  @info "Protocol interfaces successfully written at $target"
end

construct_protocol_interfaces(itfs)
