using SkewedAxisFourierAnalysis
using Documenter

DocMeta.setdocmeta!(SkewedAxisFourierAnalysis, :DocTestSetup, :(using SkewedAxisFourierAnalysis); recursive=true)

makedocs(;
    modules=[SkewedAxisFourierAnalysis],
    authors="SanjeevKhare <90015656+SanjeevKhare@users.noreply.github.com> and contributors",
    sitename="SkewedAxisFourierAnalysis.jl",
    format=Documenter.HTML(;
        canonical="https://SanjeevKhare.github.io/SkewedAxisFourierAnalysis.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl",
    devbranch="main",
)
