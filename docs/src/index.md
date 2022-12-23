# Wayland.jl

## Status

This package is currently in development. The source code and public API may change at any moment. Use at your own risk.

## Wrapping `libwayland` vs reimplementing the protocol

The reason we wrap the C implementation `libwayland` instead of providing our own implementation of the Wayland protocol is driver compatibility. Unfortunately, in the current state of affairs graphics drivers such as Mesa for OpenGL or other proprietary drivers are likely to rely on linking with `libwayland-client` and calling it with C pointers, which expect to be ABI-compatible with the C implementation. See for example the [Vulkan integration with Wayland](https://registry.khronos.org/vulkan/specs/1.3-extensions/html/vkspec.html#platformCreateSurface_wayland) which requires `struct wl_display *display` and `struct wl_surface *surface` pointers.

Reimplementing the protocol in Julia with full interoperability would mean requiring data structures compatible with the C ABI, which would defeat the purpose of a pure Julia implementation of the protocol.
