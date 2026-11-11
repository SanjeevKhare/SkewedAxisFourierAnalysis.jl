using Documenter
using DocumenterVitepress
using Literate
using SkewedAxisFourierAnalysis

const DOCS = @__DIR__
const FIGURES = mkpath(joinpath(DOCS, "src", "assets", "figures"))
const DOWNLOADS = mkpath(joinpath(DOCS, "src", "public", "downloads"))
include(joinpath(DOCS, "illustrations.jl"))

# Published listings are the same scripts executed to make the figures.
for tutorial in ("synthetic", "digitization", "reconstruction")
    script = joinpath(DOCS, "examples", tutorial * ".jl")
    Base.include(Module(Symbol("Tutorial_", tutorial)), script)
    Literate.markdown(script, joinpath(DOCS, "src", "tutorials");
        flavor = Literate.DocumenterFlavor(), codefence = ("```julia" => "```"), credit = false)
    cp(script, joinpath(DOWNLOADS, tutorial * ".jl"); force = true)
end

cp(joinpath(FIGURES, "synthetic-harmonics.txt"),
    joinpath(DOWNLOADS, "synthetic-harmonics.txt"); force = true)

makedocs(;
    modules = [SkewedAxisFourierAnalysis],
    sitename = "SkewedAxisFourierAnalysis.jl",
    authors = "Sanjeev Khare and contributors",
    format = DocumenterVitepress.MarkdownVitepress(;
        repo = "github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl",
        devbranch = "main",
        deploy_url = "https://sanjeevkhare.github.io/SkewedAxisFourierAnalysis.jl/",
        deploy_decision = Documenter.DeployDecision(all_ok = true, subfolder = "dev"),
        description = "From skewed lattice images to compact Fourier models. Reproducible Julia tutorials, coordinate conventions, and API reference.",
        noindex_non_stable = false,
    ),
    pages = [
        "Home" => "index.md",
        "Start here" => [
            "Installation & first steps" => "guide/getting-started.md",
            "The analysis workflow" => "guide/workflow.md",
        ],
        "Tutorials" => [
            "01 · Find the harmonics" => "tutorials/synthetic.md",
            "02 · Digitize an image" => "tutorials/digitization.md",
            "03 · Reconstruct on skewed axes" => "tutorials/reconstruction.md",
        ],
        "Understand the method" => [
            "Coordinates & Fourier conventions" => "guide/coordinates.md",
            "Filtering & accuracy" => "guide/filtering.md",
            "Troubleshooting" => "guide/troubleshooting.md",
        ],
        "Reference" => [
            "Julia API" => "reference/api.md",
            "Reproduce the documentation" => "reference/reproducibility.md",
        ],
    ],
    checkdocs = :all,
)

if get(ENV, "DOCS_DEPLOY", "false") == "true"
    DocumenterVitepress.deploydocs(;
        repo = "github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl",
        devbranch = "main",
        push_preview = false,
    )
end
