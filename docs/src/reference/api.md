```@meta
CurrentModule = SkewedAxisFourierAnalysis
```

# Julia API

Use `import SkewedAxisFourierAnalysis as FA` and qualify function calls with `FA.`. The package currently does not export its functions.

## Common calls

| Task | Call |
| --- | --- |
| Shear an image | `FA.shear_image(img, θ)` |
| Crop transparent borders | `FA.crop_transparent_border_of_image(img)` |
| Digitize RGB pixels | `FA.map_image_to_data(img, cb_line, lower, upper)` |
| Inspect a Fourier mask | `FA.fft_power_analysis(data, τ)` |
| Extract coefficients | `FA.extract_dominant_harmonics(data, τ)` |
| Reduce conjugate pairs | `FA.filter_principal_frequencies_for_fft_of_real_data(harmonics)` |
| Save coefficients | `FA.write_opdata_to_file(opdata, filename)` |
| Evaluate a skewed model | `FA.build_sheared_function_from_sinousoids(opdata, X, Y, θ)` |
| Color a nonconstant field | `FA.create_image_from_data(field, color_scheme)` |

The historical spelling **`sinousoids`** is part of the actual function name. The reconstruction angle is in degrees; stored phases are in radians. Its final tuple must be DC. See [coordinates](../guide/coordinates.md) and [filtering](../guide/filtering.md) for detailed interpretation and edge cases.

## Source docstrings

The entries below are generated directly from the package docstrings. Their source links lead to the implementation on GitHub.

```@autodocs
Modules = [SkewedAxisFourierAnalysis]
Order = [:function]
Private = true
```
