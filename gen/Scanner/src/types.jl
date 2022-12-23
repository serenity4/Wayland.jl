@enum ArgumentType begin
  ARGUMENT_TYPE_INT
  ARGUMENT_TYPE_UINT
  ARGUMENT_TYPE_FIXED
  ARGUMENT_TYPE_OBJECT
  ARGUMENT_TYPE_NEW_ID
  ARGUMENT_TYPE_STRING
  ARGUMENT_TYPE_ARRAY
  ARGUMENT_TYPE_FD
  ARGUMENT_TYPE_ENUM
end

@enum RequestType begin
  REQUEST_TYPE_DESTRUCTOR
end

@enum EventType begin
  EVENT_TYPE_DESTRUCTOR
end

ArgumentType(type::String) = getproperty(@__MODULE__, Symbol(:ARGUMENT_TYPE_, uppercase(type)))::ArgumentType
RequestType(type::String) = getproperty(@__MODULE__, Symbol(:REQUEST_TYPE_, uppercase(type)))::RequestType
EventType(type::String) = getproperty(@__MODULE__, Symbol(:EVENT_TYPE_, uppercase(type)))::EventType

get_event_type(node::Node) = haskey(node, "type") ? EventType(node["type"]) : nothing
get_request_type(node::Node) = haskey(node, "type") ? RequestType(node["type"]) : nothing
get_interface(node::Node) = haskey(node, "interface") ? node["interface"] : nothing
function get_description(node::Node)
  node = findfirst(".//description", node)
  isnothing(node) && return
  node.content
end

struct EnumValue
  name::String
  value::Int
  description::Optional{String}
end

EnumValue(node::Node) = EnumValue(node["name"], parse(UInt, node["value"]), get_description(node))

struct Enum
  name::String
  description::Optional{String}
  values::Vector{EnumValue}
  bitfield::Bool
end

Enum(node::Node) = Enum(node["name"], get_description(node), EnumValue.(findall(".//entry", node)), haskey(node, "bitfield") ? node["bitfield"] = true : false)

struct Argument
  name::String
  type::ArgumentType
  interface::Optional{String}
  description::Optional{String}
end

Argument(node::Node) = Argument(node["name"], ArgumentType(node["type"]), get_interface(node), get_description(node))

struct Request
  name::String
  args::Vector{Argument}
  type::Optional{RequestType}
  description::Optional{String}
end

Request(node::Node) = Request(node["name"], Argument.(findall(".//arg", node)), get_request_type(node), get_description(node))

struct Event
  name::String
  args::Vector{Argument}
  type::Optional{EventType}
  description::Optional{String}
end

Event(node::Node) = Event(node["name"], Argument.(findall(".//arg", node)), get_event_type(node), get_description(node))

struct Interface
  name::String
  version::VersionNumber
  requests::Vector{Request}
  events::Vector{Event}
  enums::Vector{Enum}
  description::Optional{String}
end

function Interface(node::Node)
  requests = Request[]
  events = Event[]
  enums = Enum[]
  for rnode in findall(".//request", node)
    push!(requests, Request(rnode))
  end
  for evnode in findall(".//event", node)
    push!(events, Event(evnode))
  end
  for enode in findall(".//enum", node)
    push!(enums, Enum(enode))
  end
  Interface(node["name"], parse(VersionNumber, node["version"]), requests, events, enums, get_description(node))
end
