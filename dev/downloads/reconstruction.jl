# # Change your perspective
#
# Evaluate the same compact model at 60°, 90°, and 120°. This isolates the
# reconstruction geometry from FFT selection and image preprocessing.
#
# ```@raw html
# <p><a href="../downloads/reconstruction.jl" download>Download this Julia script</a></p>
# ```

using CairoMakie
import SkewedAxisFourierAnalysis as FA

# ## Define a readable harmonic model
#
# Each tuple is `(i, j, magnitude, phase)`. Non-DC magnitudes are half the cosine
# amplitude because the real-valued reconstruction combines conjugate pairs.
# The final tuple must be the DC term, even if its magnitude is zero.

opdata = [(1, 2, 0.325, 0.4), (3, -1, 0.150, -0.6), (0, 0, 0.8, 0.0)]

# ## Evaluate in Cartesian space
#
# The implementation evaluates `U = x + y*cot(θ)` and `V = y*csc(θ)`.
# Angles are in degrees. Avoid angles where `sin(θ) = 0`.

x = collect(range(-0.5, 1.5; length = 220))
y = collect(range(0.0, 1.5; length = 190))
X = repeat(x', length(y), 1)
Y = repeat(y, 1, length(x))
angles = [60.0, 90.0, 120.0]
fields = [FA.build_sheared_function_from_sinousoids(opdata, X, Y, θ) for θ in angles]

# ## Check the coordinate transform
#
# Inverting the implemented transform gives `x = U - V*cos(θ)` and
# `y = V*sin(θ)`. Thus the second direct-space basis vector is
# `(-cos(θ), sin(θ))`: its included angle with the first is `180° - θ`
# for `0 < θ < 180°`. Keep this convention explicit when reading a lattice image.

u = collect(0:63) ./ 64
U = repeat(u', 64, 1)
V = repeat(u, 1, 64)
reference = @. 0.8 + 0.65cos(2π * (2U + V) + 0.4) +
    0.30cos(2π * (-U + 3V) - 0.6)
for θ in angles
    XX = U .- V .* cosd(θ)
    YY = V .* sind(θ)
    result = FA.build_sheared_function_from_sinousoids(opdata, XX, YY, θ)
    @assert maximum(abs, result - reference) < 1e-12
end
println("Coordinate-transform checks passed at ", angles)

# ## Compare angles on the same grid
#
# The outlined parallelogram is one period in each transformed coordinate.
# Every panel uses the same color scale and Cartesian viewport.

output = mkpath(joinpath(@__DIR__, "..", "src", "assets", "figures"))
set_theme!(Theme(fontsize = 15, font = "TeX Gyre Heros"))
fig = Figure(size = (1080, 400), backgroundcolor = :white)
for (k, θ) in enumerate(angles)
    ax = Axis(fig[1, k], title = "θ = $(Int(θ))°", xlabel = "x", ylabel = "y",
        aspect = DataAspect())
    heatmap!(ax, x, y, fields[k]'; colormap = :viridis, colorrange = (-0.2, 1.8))
    lines!(ax, [0, 1, 1-cosd(θ), -cosd(θ), 0],
        [0, 0, sind(θ), sind(θ), 0]; color = :white, linewidth = 2)
    xlims!(ax, -0.5, 1.5)
    ylims!(ax, 0, 1.5)
end
save(joinpath(output, "reconstruction.png"), fig; px_per_unit = 2)
save(joinpath(output, "reconstruction.svg"), fig)

# ```@raw html
# <img src="../assets/figures/reconstruction.png" alt="One harmonic model evaluated at three skew angles with its unit cell outlined" loading="lazy">
# ```
#
# Increasing the sampling resolution produces a smoother rendering; it does not
# add Fourier modes or establish that a fit to an experimental image is accurate.
# `create_image_from_data` can color a nonconstant field, but rescales each image
# independently. Use a shared `colorrange` as above for quantitative comparisons.
#
# Continue with [coordinates and Fourier conventions](../guide/coordinates.md)
# or the [Julia API](../reference/api.md).
