using Documenter, Wayland

analytics_asset = Documenter.Writers.HTMLWriter.HTMLAsset(
    :js,
    "https://plausible.io/js/script.js",
    false,
    Dict(:defer => "", Symbol("data-domain") => "serenity4.github.io"),
)

makedocs(;
    modules = [Wayland],
    format = Documenter.HTML(
        prettyurls = true,
        assets = [analytics_asset],
        canonical = "https://serenity4.github.io/Wayland.jl/stable/",
    ),
    pages = [
        "Home" => "index.md",
        "API" => "reference/api.md",
    ],
    repo = "https://github.com/serenity4/Wayland.jl/blob/{commit}{path}#L{line}",
    sitename = "Wayland.jl",
    authors = "serenity4 <cedric.bel@hotmail.fr>",
    strict = true,
    doctest = false,
    checkdocs = :exports,
)

deploydocs(
    repo = "github.com/serenity4/Wayland.jl.git",
)
