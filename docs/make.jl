cd(@__DIR__)
using Pkg
Pkg.activate(@__DIR__)
using SkewedAxisFourierAnalysis
using Documenter
using Literate


# DocMeta.setdocmeta!(SkewedAxisFourierAnalysis, :DocTestSetup, :(using SkewedAxisFourierAnalysis); recursive=true)

threshold = 3_000_000

Literate.markdown("./src/tutorial.jl", "./src")

makedocs(;
    modules=[SkewedAxisFourierAnalysis],
    authors="SanjeevKhare <90015656+SanjeevKhare@users.noreply.github.com> and contributors",
    sitename="SkewedAxisFourierAnalysis.jl",
    format=Documenter.HTML(;
        canonical="https://SanjeevKhare.github.io/SkewedAxisFourierAnalysis.jl",
        edit_link="main",
        assets=String[],
        example_size_threshold=threshold,
        size_threshold=threshold,
        size_threshold_warn=threshold
    ),
    pages=[
        "Home" => "index.md",
        "Tutotial" => "tutorial.md",
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl",
    devbranch="main",
)
