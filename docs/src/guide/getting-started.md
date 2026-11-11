# Installation & first steps

SkewedAxisFourierAnalysis.jl turns real, two-dimensional periodic data into a cosine model that can be evaluated on skewed axes. If you already have a numeric matrix, you can skip image digitization entirely.

## Install from GitHub

Use Julia **1.11 or newer** for the documented workflow. Although the package's Julia compatibility entry is broader, its standard-library requirements and CI configuration target Julia 1.11 or newer.

```julia
using Pkg
Pkg.activate("fourier-example"; shared = false)
Pkg.add(url = "https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl")
```

The package currently exposes functions through its module rather than exporting them. Use a short module alias:

```julia
import SkewedAxisFourierAnalysis as FA
```

## Your first harmonic model

This field has a nonzero mean and two cosine modes. Sample one periodic cell without duplicating its endpoint.

```julia
N = 64
u = collect(0:N-1) ./ N
U = repeat(u', N, 1)
V = repeat(u, 1, N)
data = @. 0.8 + 0.65cos(2π * (2U + V) + 0.4) +
    0.30cos(2π * (-U + 3V) - 0.6)

harmonics = FA.extract_dominant_harmonics(data, 0.02)
opdata = FA.filter_principal_frequencies_for_fft_of_real_data(harmonics)
result = FA.build_sheared_function_from_sinousoids(opdata, U, V, 90.0)
@assert maximum(abs, result - data) < 1e-12
```

The final model contains two non-DC tuples and one DC tuple. Their order, before the final DC entry, is not guaranteed because the implementation uses a dictionary.

## Choose your next step

| Your input or question | Start here |
| --- | --- |
| A numeric matrix | [Find the harmonics](../tutorials/synthetic.md) |
| A color image with a colorbar | [Give pixels a scale](../tutorials/digitization.md) |
| A saved harmonic model | [Change your perspective](../tutorials/reconstruction.md) |
| Which angle or units to use | [Coordinates & Fourier conventions](coordinates.md) |
| A failed extraction or unexpected result | [Troubleshooting](troubleshooting.md) |

## Run the visual tutorials

The plotted examples use CairoMakie and other dependencies in the repository's documentation environment:

```sh
git clone https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl.git
cd SkewedAxisFourierAnalysis.jl
julia --project=docs -e 'using Pkg; Pkg.develop(path=pwd()); Pkg.instantiate()'
julia --project=docs docs/examples/synthetic.jl
```

See [reproducibility](../reference/reproducibility.md) to regenerate the whole site.
