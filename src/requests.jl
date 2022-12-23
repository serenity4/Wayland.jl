mutable struct Proxy <: Handle
  handle::Ptr{Cvoid}
  function Proxy(interface)
    handle = Ref{Ptr{Cvoid}}()
    wl_proxy_create(handle, interface)
    proxy = new(handle[])
    finalize(wl_proxy_destroy, proxy)
  end
end
