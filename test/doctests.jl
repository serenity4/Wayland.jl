using Documenter

DocMeta.setdocmeta!(Wayland, :DocTestSetup, quote
    using Wayland
end)

doctest(Wayland)
