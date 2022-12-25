module Scanner

using Wayland_jll: artifact_dir
import Wayland_protocols_jll
using EzXML
using EzXML: Node
using MacroTools: prettify

const Optional{T} = Union{T,Nothing}

const protocols_path = joinpath(Wayland_protocols_jll.artifact_dir, "share", "wayland-protocols")

core_protocol() = readxml(joinpath(artifact_dir, "share", "wayland", "wayland.xml")).root
extension_protocol(path) = readxml(joinpath(protocols_path, path)).root

function stable_protocols()
  protocol_names = readdir(joinpath(protocols_path, "stable"); join = false)
  extension_protocol.(joinpath.(protocols_path, "stable", protocol_names, protocol_names .* ".xml"))
end

include("types.jl")
include("interfaces.jl")
include("functions.jl")
include("events.jl")
include("generate.jl")

export core_protocol,
  stable_protocols,
  extension_protocol,
  EnumValue,
  Enum,
  Argument,
  Request,
  Event,
  Interface,
  interfaces,
  generate

end # module Scanner
