module Scanner

using Wayland_jll: artifact_dir
using EzXML
using EzXML: Node

const Optional{T} = Union{T,Nothing}
const xroot = Ref{EzXML.Node}()

function __init__()
  xdoc = readxml(joinpath(artifact_dir, "share", "wayland", "wayland.xml"))
  xroot[] = xdoc.root
end

include("types.jl")
include("interfaces.jl")

export xroot,
  EnumValue,
  Enum,
  Argument,
  Request,
  Event,
  Interface

end # module Scanner
