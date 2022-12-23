abstract type Wrapper{T} end

unwrap(wrapper::Wrapper) = wrapper.data
Base.getindex(wrapper::Wrapper) = unwrap(wrapper)
Base.unsafe_convert(::Type{T}, x::Wrapper{T}) where {T} = x[]

unwrap_array(x::Ptr{Cvoid}) = x
unwrap_array(xs) = unwrap.(xs)
ptrlength(x::Ptr{Cvoid}) = 1
ptrlength(xs) = length(xs)
getptr(x) = pointer(x)
getptr(x::Ptr{Cvoid}) = x
getptr(ptr::Ptr{T}, i::Integer) where {T} = ptr + (i - 1) * sizeof(T)
