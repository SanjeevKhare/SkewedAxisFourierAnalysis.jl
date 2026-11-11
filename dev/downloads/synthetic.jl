# # Find the harmonics
#
# Begin with a known periodic field, so reconstruction can be checked against
# an exact answer. This tutorial needs no image files.
#
# ```@raw html
# <p><a href="../downloads/synthetic.jl" download>Download this Julia script</a></p>
# ```
# Run it in a checkout with `julia --project=docs docs/examples/synthetic.jl`.

using CairoMakie
using FFTW
using LinearAlgebra
import SkewedAxisFourierAnalysis as FA

# ## Sample one periodic cell
#
# Rows represent the second coordinate, columns the first. Exclude the repeated
# endpoint at 1: the FFT assumes a periodic continuation of these samples.

N = 96
u = collect(0:N-1) ./ N
v = copy(u)
U = repeat(u', N, 1)
V = repeat(v, 1, N)
reference = @. 0.8 + 0.65cos(2π * (2U + V) + 0.4) +
    0.30cos(2π * (-U + 3V) - 0.6)
ripple = @. 0.07cos(2π * (11U - 9V))
data = reference + ripple

# ## Extract a compact model
#
# The threshold is an amplitude-based heuristic, not a retained-power fraction.
# Here `0.02` removes the deliberately weak ripple. The nonzero mean ensures
# the DC coefficient is retained by the current implementation.

τ = 0.02
harmonics = FA.extract_dominant_harmonics(data, τ)
opdata = FA.filter_principal_frequencies_for_fft_of_real_data(harmonics)
@assert opdata[end][1:2] == (0, 0)
@assert length(opdata) == 3  # Two cosine modes and a DC term.

# ## Reconstruct and check the answer
#
# At 90°, the evaluation coordinates are orthogonal. The factor of two for each
# non-DC mode is applied inside the package's reconstruction function.

reconstructed = FA.build_sheared_function_from_sinousoids(opdata, U, V, 90.0)
relative_error = norm(reconstructed - reference) / norm(reference)
@assert relative_error < 1e-12
@assert norm(reconstructed - reference) < norm(data - reference)
println("Synthetic reconstruction relative error: ", relative_error)

# Save the compact model. Its lines are `i, j, magnitude, phase`; phase is in
# radians and the last line is DC. The historical `sinousoids` spelling in the
# API is intentional in these examples.

output = mkpath(joinpath(@__DIR__, "..", "src", "assets", "figures"))
FA.write_opdata_to_file(opdata, joinpath(output, "synthetic-harmonics.txt"))

# ## Inspect the field and its spectrum
#
# This display uses log-amplitude, explicitly labeled. It is not a power-density
# plot. Transposing the field when plotting keeps columns along the horizontal axis.

set_theme!(Theme(fontsize = 15, font = "TeX Gyre Heros",
    Axis = (xgridvisible = false, ygridvisible = false,
        topspinevisible = false, rightspinevisible = false)))
fig = Figure(size = (1080, 360), backgroundcolor = :white)
for (k, values, title) in ((1, data, "Input + weak ripple"),
        (3, reconstructed, "Two modes + mean"))
    ax = Axis(fig[1, k], title = title, xlabel = "u", ylabel = "v", aspect = 1)
    heatmap!(ax, u, v, values'; colormap = :viridis, colorrange = (-0.2, 1.8))
end
ax = Axis(fig[1, 2], title = "Fourier log-amplitude", xlabel = "Column index j",
    ylabel = "Row index i", aspect = 1)
spectrum = log10.(abs.(fftshift(fft(data))) ./ length(data) .+ 1e-15)
heatmap!(ax, -N÷2:N÷2-1, -N÷2:N÷2-1, spectrum';
    colormap = :magma, colorrange = (-5, 0))
xlims!(ax, -14, 14)
ylims!(ax, -14, 14)
save(joinpath(output, "synthetic.png"), fig; px_per_unit = 2)
save(joinpath(output, "synthetic.svg"), fig)

# ```@raw html
# <img src="../assets/figures/synthetic.png" alt="Input field, Fourier spectrum, and reconstructed field" loading="lazy">
# ```
#
# ```@raw html
# <p><a href="../downloads/synthetic-harmonics.txt" download>Download the harmonic coefficients</a></p>
# ```
#
# ## Vary the threshold
#
# Compare error against the ripple-free reference, including the input error as
# a baseline. A larger threshold eventually removes useful structure as well.

thresholds = [0.005, 0.02, 0.10, 0.30]
errors = Float64[]
counts = Int[]
for τ in thresholds
    modes = FA.extract_dominant_harmonics(data, τ)
    model = FA.filter_principal_frequencies_for_fft_of_real_data(modes)
    field = FA.build_sheared_function_from_sinousoids(model, U, V, 90.0)
    push!(errors, norm(field - reference) / norm(reference))
    push!(counts, length(model) - 1)
end
@assert counts == [3, 2, 1, 0]
fig = Figure(size = (840, 340), backgroundcolor = :white)
ax = Axis(fig[1, 1], xlabel = "Threshold τ", ylabel = "Relative L₂ error",
    title = "Error against the ripple-free field")
scatterlines!(ax, thresholds, errors; color = "#5145b8", linewidth = 2, markersize = 10)
hlines!(ax, [norm(data - reference) / norm(reference)]; color = "#0b807b",
    linestyle = :dash, label = "Input error")
axislegend(ax; position = :lt)
ax = Axis(fig[1, 2], xlabel = "Threshold τ", ylabel = "Cosine modes (DC excluded)",
    title = "Model size", yticks = 0:3)
scatterlines!(ax, thresholds, counts; color = "#0b807b", linewidth = 2, markersize = 10)
save(joinpath(output, "filtering.png"), fig; px_per_unit = 2)
save(joinpath(output, "filtering.svg"), fig)

# ```@raw html
# <img src="../assets/figures/filtering.png" alt="Error and retained cosine modes as the amplitude threshold changes" loading="lazy">
# ```
#
# The best threshold here follows from the deliberately separated amplitudes.
# Real data requires a sensitivity check; a compact model alone is not evidence
# of faithful digitization or correct physical calibration.
#
# Next: [digitize a scientific image](digitization.md).
