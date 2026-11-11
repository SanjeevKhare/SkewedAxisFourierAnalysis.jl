# Troubleshooting

## `UndefVarError` after loading the package

The package's functions are not exported. Use `import SkewedAxisFourierAnalysis as FA`, then call `FA.extract_dominant_harmonics(...)`.

## Extraction fails while choosing a cutoff

The amplitude heuristic needs a nonzero spectrum and at least one normalized amplitude increment larger than τ. All-zero data or an overly large τ can produce `nothing` where an index is expected. Inspect the input and lower the threshold. Handle a known constant field directly rather than forcing a sparse extraction.

## `KeyError: key (0, 0) not found`

The current principal-frequency helper expects a DC coefficient, but thresholding can remove it. This is especially likely for zero-mean data. A manually constructed harmonic list can include the missing mean explicitly:

```julia
# Only add this when you have established that the true mean is zero.
if !any(h -> h[1:2] == (0, 0), harmonics)
    push!(harmonics, (0, 0, 0.0 + 0.0im))
end
opdata = FA.filter_principal_frequencies_for_fft_of_real_data(harmonics)
```

If the mean is nonzero, recover it from the original data and preserve it rather than substituting zero.

## Image conversion gives a method error

The low-level mapper expects a `Matrix{RGB{T}}` and `Vector{RGB{T}}` with matching channel types, plus floating-point `Float64` limits. Convert explicitly:

```julia
using Images
img = RGB{Float64}.(img)
cb_line = RGB{Float64}.(cb_line)
data = FA.map_image_to_data(img, cb_line, -2.22, 1.05)
```

Remove transparent pixels or crop them before discarding alpha. Transparent padding carries no scalar measurement.

## The recovered values are upside down

The colorbar samples run from **upper** to **lower** value. Reverse the colorbar vector if the original file has its lower value at the top. A nonuniform numeric colorbar requires calibration beyond the mapper's current linear interpolation between limits.

## The reconstruction is rotated, mirrored, or sheared incorrectly

Check row/column order first, then the [coordinate convention](coordinates.md). θ is in degrees, phases are in radians, and the second direct-space basis vector is `(-cosd(θ), sind(θ))`. A shift of the image origin changes phases.

## A retained mode has the wrong amplitude

Non-DC coefficients are doubled by reconstruction. Keep one representative per ordinary conjugate pair, with magnitude equal to half the cosine amplitude. Avoid unverified Nyquist-edge modes, and keep DC last.

## A constant reconstruction cannot be color-mapped

`create_image_from_data` divides by the matrix range. For a constant field that range is zero. Plot constant values with a fixed external color scale instead.

## Report a reproducible problem

Open an [issue on GitHub](https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl/issues) with your Julia version, input dimensions and element type, a minimal example, and the expected result. Include image data only when you have permission to share it publicly.
