# The analysis workflow

The image processing and Fourier analysis steps solve different problems. Inspect the output of each before moving on.

## 1. Prepare a periodic region

Start with one cell or an integer number of repeated cells. Remove text, axes, borders, and colorbar ticks. An FFT periodically repeats the whole input rectangle; a mismatch across its edges introduces additional frequencies.

For a sheared image, `FA.shear_image(img, θ)` applies an image warp and `FA.crop_transparent_border_of_image` crops its transparent borders using center-line scans. This helper is designed for the supplied image workflow, rather than arbitrary segmentation. Inspect the crop before treating it as a periodic cell.

## 2. Recover scalar values

Pass an RGB image, a top-to-bottom colorbar column, and the colorbar's numeric limits to `FA.map_image_to_data`. It compares each pixel with the colorbar using `colordiff` and assigns the value of the nearest color.

Digitization is approximate. Compression, antialiasing, illumination, a nonlinear colorbar, or a color map that repeats colors can change or invalidate the inferred values. Keep the original image and calibration with your result.

## 3. Inspect the spectrum

`FA.fft_power_analysis(data, τ)` returns a Boolean mask and the raw FFT. Despite its historical name, the selection heuristic uses Fourier **amplitudes**, not squared amplitudes. See [filtering & accuracy](filtering.md).

```julia
mask, F = FA.fft_power_analysis(data, 0.02)
retained_fraction = sum(abs2, F[mask]) / sum(abs2, F)
```

The fraction above is a separate diagnostic for a nonzero input; it is not the meaning of `τ`.

## 4. Store a compact real-valued model

```julia
harmonics = FA.extract_dominant_harmonics(data, 0.02)
opdata = FA.filter_principal_frequencies_for_fft_of_real_data(harmonics)
FA.write_opdata_to_file(opdata, "harmonics.txt")
```

Extraction normalizes FFT coefficients by the total number of samples. Principal-frequency filtering keeps one member of each ordinary conjugate pair and puts the DC term last. The current reconstruction convention assumes that final DC tuple exists.

## 5. Evaluate and compare

Use `FA.build_sheared_function_from_sinousoids(opdata, X, Y, θ)` to evaluate the model on arrays of Cartesian coordinates. `X` and `Y` should have the same shape and floating-point element type as the mode magnitudes.

Measure error on numeric values before applying a color map. `FA.create_image_from_data` independently rescales a nonconstant matrix to its own minimum and maximum, which can hide amplitude differences between reconstructions.

## What this workflow establishes

The tutorials test synthetic mode recovery, a synthetic colorbar calibration, and the implemented coordinate transform. They do not certify experimental image fidelity or the physical interpretation of a particular material's harmonic coefficients.
