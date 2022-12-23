struct Message <: Wrapper{wl_message}
  data::wl_message
  deps::Vector{Any}
end

function Message(name::AbstractString, signature::AbstractString, types::Ptr{Ptr{wl_interface}})
  deps = Any[
    name,
    signature,
  ]
  x = wl_message(getptr(name), getptr(signature), Ptr{Ptr{Nothing}}(types))
  Message(x, deps)
end

struct Interface <: Wrapper{wl_interface}
  data::wl_interface
  deps::Vector{Any}
end

function Interface(name::String, version::Int, methods, events)
  _methods, _events = unwrap_array(methods), unwrap_array(events)
  deps = Any[
    name,
    methods,
    events,
    _methods,
    _events,
  ]
  x = wl_interface(getptr(name), version, ptrlength(methods), getptr(_methods), ptrlength(events), getptr(_events))
  Interface(x, deps)
end

function fill_interface!!(refs, structs, itf::Interface)
  push!(structs, itf)
  refs[1][] = itf[]
end

include("../lib/interfaces.jl")

const wayland_interface_refs = [Ref{wl_interface}() for _ in 1:n]
const wayland_interface_ptrs = Vector{Ptr{wl_interface}}()
const wayland_interface_structs = Interface[]
const wayland_interfaces = Ref{Ptr{Ptr{wl_interface}}}()
