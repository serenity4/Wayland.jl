using Clang.Generators
using Clang.Generators.JLLEnvs
using Wayland_jll

cd(@__DIR__)

# get include directory & wayland-client.h
WL_INCLUDE = joinpath(Wayland_jll.artifact_dir, "include")
WL_HEADERS = [joinpath(WL_INCLUDE, "wayland-client.h"), joinpath(WL_INCLUDE, "wayland-server.h")]

for target in JLLEnvs.JLL_ENV_TRIPLES
# for target in ["x86_64-linux-gnu"]
    @info "processing $target"

    # programmatically add options
    general = Dict{String,Any}()
    codegen = Dict{String,Any}()
    options = Dict{String,Any}(
        "general" => general,
        "codegen" => codegen,
        )
    general["library_name"] = "libwayland_client"
    general["library_names"] = Dict(
        "wayland-client.*.h" => "libwayland_client",
        "wayland-cursor.h" => "libwayland_cursor",
        "wayland-egl.*.h" => "libwayland_egl",
        "wayland-server.*.h" => "libwayland_server",
    )
    general["output_file_path"] = joinpath(dirname(@__DIR__), "lib", "$target.jl")
    general["use_deterministic_symbol"] = true
    general["print_using_CEnum"] = false
    general["extract_c_comment_style"] = "doxygen"
    general["struct_field_comment_style"] = "outofline"
    general["enumerator_comment_style"] = "outofline"
    codegen["add_record_constructors"] = true
    codegen["union_single_constructor"] = true
    codegen["opaque_as_mutable_struct"] = false

    # add compiler flags
    args = get_default_args(target)
    # avoid incompatible wayland-server definitions
    push!(args, "-DWL_HIDE_DEPRECATED", "-DWAYLAND_CLIENT_PROTOCOL_H", "-DWAYLAND_SERVER_PROTOCOL_H")
    ctx = create_context(WL_HEADERS, args, options)

    build!(ctx)
end
