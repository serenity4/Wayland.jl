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
get_since(node::Node) = haskey(node, "since") ? parse(Int, node["since"]) : nothing
get_interface(node::Node) = haskey(node, "interface") ? node["interface"] : nothing
get_summary(node::Node) = haskey(node, "summary") ? node["summary"] : nothing
function get_description(node::Node)
  node = findfirst(".//description", node)
  isnothing(node) && return
  Description(node)
end

struct Description
  text::String
  summary::Optional{String}
end

Description(node::Node) = Description(node.content, get_summary(node))

struct EnumValue
  name::String
  value::Int
  summary::Optional{String}
  description::Optional{Description}
end

EnumValue(node::Node) = EnumValue(node["name"], parse(UInt, node["value"]), get_summary(node), get_description(node))

struct Enum
  name::String
  values::Vector{EnumValue}
  bitfield::Bool
  since::Optional{Int}
  description::Optional{Description}
end

Enum(node::Node) = Enum(node["name"], EnumValue.(findall(".//entry", node)), haskey(node, "bitfield") ? node["bitfield"] = true : false, get_since(node), get_description(node))

struct Argument
  name::String
  type::ArgumentType
  summary::Optional{String}
  interface::Optional{String}
  isnullable::Bool
  description::Optional{Description}
end

Argument(node::Node) = Argument(node["name"], ArgumentType(node["type"]), get_summary(node), get_interface(node), haskey(node, "allow-null"), get_description(node))

abstract type Message end

struct Request <: Message
  name::String
  args::Vector{Argument}
  type::Optional{RequestType}
  since::Optional{Int}
  description::Optional{Description}
end

Request(node::Node) = Request(node["name"], Argument.(findall(".//arg", node)), get_request_type(node), get_since(node), get_description(node))

struct Event <: Message
  name::String
  args::Vector{Argument}
  type::Optional{EventType}
  since::Optional{Int}
  description::Optional{Description}
end

Event(node::Node) = Event(node["name"], Argument.(findall(".//arg", node)), get_event_type(node), get_since(node), get_description(node))

struct Interface
  name::String
  version::Int
  requests::Vector{Request}
  events::Vector{Event}
  enums::Vector{Enum}
  description::Optional{Description}
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
  Interface(node["name"], parse(Int, node["version"]), requests, events, enums, get_description(node))
end

Interface(name::AbstractString, protocol = core_protocol()) = Interface(findfirst(".//interface[@name = \"$name\"]", protocol))
interfaces(protocol::Node) = map(Interface, findall(".//interface", protocol))

function find(f, vec)
  i = findfirst(f, vec)
  isnothing(i) && return
  vec[i]
end

name(x) = x.name

function Base.getindex(itf::Interface, str::AbstractString)
  f = ==(str) ∘ name
  @something(find(f, itf.requests), find(f, itf.events), find(f, itf.enums), throw(KeyError(str)))
end

Base.broadcastable(itf::Interface) = Ref(itf)
