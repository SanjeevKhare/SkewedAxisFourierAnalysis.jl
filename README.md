# SkewedAxisFourierAnalysis

[![Documentation](https://img.shields.io/badge/docs-public-5145b8.svg)](https://sanjeevkhare.github.io/SkewedAxisFourierAnalysis.jl/dev/)
[![Build Status](https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl/actions/workflows/CI.yml?query=branch%3Amain)

Fourier analysis of real, two-dimensional lattice data on skewed axes. Digitize
scientific images against a supplied colorbar, extract a compact set of Fourier
coefficients, and evaluate the resulting cosine model on a chosen coordinate grid.

**[Read the documentation](https://sanjeevkhare.github.io/SkewedAxisFourierAnalysis.jl/dev/)** ·
[Get started](https://sanjeevkhare.github.io/SkewedAxisFourierAnalysis.jl/dev/guide/getting-started.html) ·
[Visual tutorials](https://sanjeevkhare.github.io/SkewedAxisFourierAnalysis.jl/dev/tutorials/synthetic.html) ·
[API reference](https://sanjeevkhare.github.io/SkewedAxisFourierAnalysis.jl/dev/reference/api.html)

```julia
using Pkg
Pkg.add(url = "https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl")
import SkewedAxisFourierAnalysis as FA
```

Use Julia 1.11 or newer for the documented workflow. The tutorials cover known-mode
recovery, colorbar digitization, and skewed-coordinate reconstruction, with figures
and numerical assertions generated from the displayed Julia code.

The current Fourier filter uses an amplitude-threshold heuristic; its threshold
is not a guaranteed retained-power fraction. Image digitization is approximate
and depends on the colorbar, crop, and image quality. See the documentation for
coordinate conventions and current edge cases.

To build the website locally:

```sh
julia --project=docs -e 'using Pkg; Pkg.develop(path=pwd()); Pkg.instantiate()'
julia --project=docs docs/make.jl
```
