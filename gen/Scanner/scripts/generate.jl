cd(dirname(@__DIR__))
using Pkg: Pkg; Pkg.activate(".")
using Scanner

generate()
