mutable struct Surface <: Handle
  handle::RefcountHandle # Ptr{wl_surface}
  compositor::Compositor
  function Surface(compositor::Compositor)
    h = wl_compositor_create_surface(compositor)
    new(RefcountHandle(h, wl_surface_destroy, compositor), compositor)
  end
end

Base.parent(x::Surface) = x.compositor

function attach(buffer::Buffer, surface::Surface, offset = (0, 0))
  wl_surface_attach(surface, buffer, offset...)
  surface
end
function damage(surface::Surface, offset = (0, 0), extent = (nothing, nothing))
  wl_surface_damage(surface, offset..., something.(extent, typemax(UInt16))...)
  surface
end
function commit(surface::Surface)
  wl_surface_commit(surface)
  surface
end

@enum XdgRole begin
  XDG_ROLE_TOPLEVEL = 1
  XDG_ROLE_POPUP = 2
end

mutable struct XdgSurface <: Handle
  handle::RefcountHandle # Ptr{xdg_surface}
  surface::Surface
  surface_listener::Listener
  role::XdgRole
  role_handle::RefcountHandle # Ptr{xdg_popup} / Ptr{xdg_toplevel}
  role_listener::Listener
  children::Vector{XdgSurface}
  cfunc::Base.CFunction
  function XdgSurface(configure, xdg_base #= ::XdgIntegration =#, surface::Surface, role::XdgRole, parent = nothing; positioner = nothing)
    h = xdg_wm_base_get_xdg_surface(xdg_base, surface)
    cfunc = @cfunction_xdg_surface_configure($configure)
    fptr = unsafe_convert(Ptr{Cvoid}, cfunc)
    if role == XDG_ROLE_TOPLEVEL
      role_handle = xdg_surface_get_toplevel(h)
      role_listener = Listener(role_handle, xdg_toplevel_listener(
        @cfunction_xdg_toplevel_configure((data, h, width, height, states) -> nothing),
        @cfunction_xdg_toplevel_close((data, h) -> nothing),
        @cfunction_xdg_toplevel_configure_bounds((data, h, width, height) -> nothing),
      ))
    elseif role == XDG_ROLE_POPUP
      role_handle = xdg_surface_get_popup(h, something(parent::Optional{XdgSurface}, C_NULL), positioner::Ptr{Cvoid})
      role_listener = Listener(role_handle, xdg_popup_listener(
        @cfunction_xdg_popup_configure((data, h, x, y, width, height) -> nothing),
        @cfunction_xdg_popup_popup_done((data, h) -> nothing),
        @cfunction_xdg_popup_repositioned((data, h, token) -> nothing),
      ))
    end
    xdg_surface = new(RefcountHandle(h, xdg_surface_destroy, xdg_base), surface)
    surface_listener = Listener(h, xdg_surface_listener(fptr), xdg_surface)
    xdg_surface.surface_listener = surface_listener
    xdg_surface.role = role
    xdg_surface.role_handle = RefcountHandle(role_handle, role == XDG_ROLE_TOPLEVEL ? xdg_toplevel_destroy : xdg_popup_destroy, xdg_surface)
    xdg_surface.role_listener = role_listener
    xdg_surface.children = XdgSurface[]
    xdg_surface.cfunc = cfunc
    register(surface_listener; keep_alive = false)
    register(role_listener; keep_alive = false)
    xdg_surface
  end
end

mutable struct XdgIntegration <: Handle
  handle::RefcountHandle # Ptr{xdg_wm_base}
  registry::Registry
  toplevel_surfaces::Vector{XdgSurface}
  function XdgIntegration(registry::Registry, version = nothing)
    h = bind(registry, :xdg_wm_base, version)
    listen(h, xdg_wm_base_listener(@cfunction_xdg_wm_base_ping((_, h, serial) -> (xdg_wm_base_pong(h, serial); nothing))))
    new(RefcountHandle(h, nothing, registry), registry, XdgSurface[])
  end
end

function create_surface!(xdg::XdgIntegration, surface::Surface, role::XdgRole, configure)
  role == XDG_ROLE_TOPLEVEL || error("Only top-level surfaces (i.e. with a role fo `XDG_ROLE_TOPLEVEL`) can be created without parent.")
  surface = XdgSurface(configure, xdg, surface, role)
  push!(xdg.toplevel_surfaces, surface)
  surface
end
