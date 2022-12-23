module LibWayland

# using Wayland_jll: libwayland_client, libwayland_cursor, libwayland_egl, libwayland_server
using CEnum
using BitMasks

const libwayland_client = Symbol("libwayland-client")
const libwayland_cursor = Symbol("libwayland-cursor")
const libwayland_egl = Symbol("libwayland-egl")
const libwayland_server = Symbol("libwayland-server")

const IS_LIBC_MUSL = occursin("musl", Base.BUILD_TRIPLET)

const wl_object = Cvoid

# We don't include the protocol headers generated by wayland-scanner,
# so we need to include these opaque types manually.
# They can be copy-pasted from the struct definitions at `$(Wayland_jll.artifact_dir)/include/wayland-client-protocol.h`.
const wl_buffer = Cvoid
const wl_callback = Cvoid
const wl_compositor = Cvoid
const wl_data_device = Cvoid
const wl_data_device_manager = Cvoid
const wl_data_offer = Cvoid
const wl_data_source = Cvoid
const wl_display = Cvoid
const wl_keyboard = Cvoid
const wl_output = Cvoid
const wl_pointer = Cvoid
const wl_region = Cvoid
const wl_registry = Cvoid
const wl_seat = Cvoid
const wl_shell = Cvoid
const wl_shell_surface = Cvoid
const wl_shm = Cvoid
const wl_shm_pool = Cvoid
const wl_subcompositor = Cvoid
const wl_subsurface = Cvoid
const wl_surface = Cvoid
const wl_touch = Cvoid

if Sys.isapple() && Sys.ARCH === :aarch64
    include("../lib/aarch64-apple-darwin20.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && !IS_LIBC_MUSL
    include("../lib/aarch64-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && IS_LIBC_MUSL
    include("../lib/aarch64-linux-musl.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && !IS_LIBC_MUSL
    include("../lib/armv7l-linux-gnueabihf.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && IS_LIBC_MUSL
    include("../lib/armv7l-linux-musleabihf.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && !IS_LIBC_MUSL
    include("../lib/i686-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && IS_LIBC_MUSL
    include("../lib/i686-linux-musl.jl")
elseif Sys.iswindows() && Sys.ARCH === :i686
    include("../lib/i686-w64-mingw32.jl")
elseif Sys.islinux() && Sys.ARCH === :powerpc64le
    include("../lib/powerpc64le-linux-gnu.jl")
elseif Sys.isapple() && Sys.ARCH === :x86_64
    include("../lib/x86_64-apple-darwin14.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && !IS_LIBC_MUSL
    include("../lib/x86_64-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && IS_LIBC_MUSL
    include("../lib/x86_64-linux-musl.jl")
elseif Sys.isbsd() && !Sys.isapple()
    include("../lib/x86_64-unknown-freebsd11.1.jl")
elseif Sys.iswindows() && Sys.ARCH === :x86_64
    include("../lib/x86_64-w64-mingw32.jl")
else
    error("Unknown platform: $(Base.BUILD_TRIPLET)")
end

include("../lib/enums.jl")

# exports
const PREFIXES = ["WL_", "wl", "Wl"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end
