# Filtering & accuracy

A visually simple reconstruction can be useful, but its accuracy depends on what was discarded and how the input was calibrated.

## What the threshold actually does

The current implementation of `fft_power_analysis` follows these steps:

1. Compute the raw two-dimensional FFT, ``F``.
2. Sort ``a_k=2|F_k|`` in ascending order.
3. Form differences of the normalized cumulative sum. Apart from the skipped first entry, these are individual amplitude fractions.
4. Find the first increment strictly greater than the supplied threshold τ.
5. Use the corresponding sorted amplitude as a cutoff; retain entries strictly above it.

The factor of two cancels from the normalized amplitude fractions. The implementation does **not** select a prescribed cumulative fraction of spectral power, despite the historical function name. This description follows the current source; treat τ as an empirical amplitude-selection parameter.

## A controlled sensitivity check

```@raw html
<img src="../assets/figures/filtering.png" alt="Reconstruction error and model size versus amplitude threshold" loading="lazy">
```

In the [synthetic tutorial](../tutorials/synthetic.md), three cosine modes are present in the input: two desired modes and a weaker ripple. Increasing τ first removes the ripple, then removes useful structure. The figure reports error against the known field and the number of non-DC modes.

This is a deliberately separated-amplitude example. In experimental data, a weak Fourier component can contain real structure; calling it noise requires additional evidence.

## Measure power separately

For nonzero input, measure the fraction of squared FFT amplitude retained by the mask:

```julia
mask, F = FA.fft_power_analysis(data, 0.02)
retained_power = sum(abs2, F[mask]) / sum(abs2, F)
```

This diagnostic includes DC. For a field with a large mean, it can look close to one even when meaningful variations have been discarded. Compare the mean-subtracted signal separately if that is the quantity of interest.

## Check more than the color image

Compare numeric residuals and a common color scale, vary τ, and check sensitivity to crop and resizing. A raster image with different minimum and maximum can appear similar after independent color normalization.

The main error sources occur at different stages:

| Stage | What to check |
| --- | --- |
| Image calibration | Colorbar direction, range, ambiguity, compression |
| Geometry | Periodic crop, shear, row direction, angle convention |
| Sampling | Resize sensitivity, aliased features, repeated endpoints |
| Fourier selection | Missing mean, discarded weak modes, Nyquist edge |
| Rendering | Shared color limits and sufficient evaluation resolution |

## Current edge cases

All-zero input or a threshold above every amplitude increment can leave no valid cutoff. An excluded DC coefficient causes the principal-frequency helper to fail because it expects `(0, 0)` in its input. Uniform fields, Nyquist modes, and very small arrays also need special care. See [troubleshooting](troubleshooting.md) before choosing a workaround.
