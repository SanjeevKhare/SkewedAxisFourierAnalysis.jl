# # Give pixels a scale
#
# A scientific image is a color encoding of a scalar field. Recover values by
# comparing its pixels with the colors in a calibrated colorbar.
#
# First use a synthetic image whose values are known. The existing CrCl₃ image
# workflow follows below, with its original calibration made explicit.
#
# ```@raw html
# <p><a href="../downloads/digitization.jl" download>Download this Julia script</a></p>
# ```

using CairoMakie
using ColorSchemes
using Images: RGB, load, imresize
using LinearAlgebra
import SkewedAxisFourierAnalysis as FA

# ## Construct a calibrated image
#
# The mapper expects the first colorbar entry to represent the upper limit.
# Supply a single column sampled from top to bottom. Both image and colorbar
# must have the same `RGB` channel type; limits must be `Float64`.

N = 48
u = collect(0:N-1) ./ N
U = repeat(u', N, 1)
V = repeat(u, 1, N)
truth = @. 0.5 + 0.25cos(2π * (2U + V)) + 0.20sin(2π * (U - V))
img = RGB{Float64}.(get(ColorSchemes.viridis, truth))
cb_line = RGB{Float64}.(get(ColorSchemes.viridis, range(1.0, 0.0; length = 257)))
recovered = FA.map_image_to_data(img, cb_line, 0.0, 1.0)
rmse = sqrt(sum(abs2, recovered - truth) / length(truth))
@assert rmse < 0.01
println("Synthetic colorbar digitization RMSE: ", rmse)

# The current mapper uses every other colorbar sample. A denser colorbar can
# reduce quantization error, but JPEG artifacts, labels, and ambiguous colors
# can dominate on real images. This check establishes only synthetic accuracy.

output = mkpath(joinpath(@__DIR__, "..", "src", "assets", "figures"))
set_theme!(Theme(fontsize = 15, font = "TeX Gyre Heros"))
fig = Figure(size = (1080, 370), backgroundcolor = :white)
for (k, values, title) in ((1, truth, "Known scalar field"),
        (2, recovered, "Recovered from RGB"))
    ax = Axis(fig[1, k], title = title, xlabel = "u", ylabel = "v", aspect = 1)
    heatmap!(ax, u, u, values'; colormap = :viridis, colorrange = (0, 1))
end
ax = Axis(fig[1, 3], title = "Digitization error", xlabel = "u", ylabel = "v", aspect = 1)
hm = heatmap!(ax, u, u, (recovered - truth)'; colormap = :balance,
    colorrange = (-0.01, 0.01))
Colorbar(fig[1, 4], hm; label = "Recovered − known")
save(joinpath(output, "digitization.png"), fig; px_per_unit = 2)
save(joinpath(output, "digitization.svg"), fig)

# ```@raw html
# <img src="../assets/figures/digitization.png" alt="Known scalar field, RGB-digitized field, and digitization error" loading="lazy">
# ```
#
# ## Work with the repository's image
#
# The original tutorial includes a sheared CrCl₃ image and its colorbar. These
# are illustrative repository inputs; the values below reproduce the original
# example, rather than independently establishing a material calibration.
#
# Here `shear_image` takes a shear parameter of 30°, whereas reconstruction in
# the original example uses an axis angle of 120°. They are different parameters.

assets = joinpath(@__DIR__, "..", "assets")
img_raw = load(joinpath(assets, "CrCl3_sheared.png"))
cb = load(joinpath(assets, "crcl3_cb.png"))
warped = FA.shear_image(img_raw, 30.0)
cropped = FA.crop_transparent_border_of_image(Matrix(warped))
small = imresize(RGB{Float64}.(cropped); ratio = 0.05)
bar = RGB{Float64}.(cb[:, max(1, size(cb, 2) ÷ 2)])
image_data = FA.map_image_to_data(small, bar, -2.22, 1.05)
@assert all(isfinite, image_data)
println("Repository image digitized: ", size(image_data))

# Display with a common color scale and a colorbar. Digitization does not
# determine physical units; obtain those from the original image and metadata.

fig = Figure(size = (960, 400), backgroundcolor = :white)
ax = Axis(fig[1, 1], title = "Repository input", aspect = DataAspect(), yreversed = true)
image!(ax, rotr90(img_raw))
hidedecorations!(ax)
ax = Axis(fig[1, 2], title = "After shear, crop & digitization",
    xlabel = "Column", ylabel = "Row", yreversed = true, aspect = DataAspect())
hm = heatmap!(ax, image_data'; colormap = :viridis, colorrange = (-2.22, 1.05))
Colorbar(fig[1, 3], hm; label = "Original example scale")
save(joinpath(output, "repository-image.png"), fig; px_per_unit = 2)

# ```@raw html
# <img src="../assets/figures/repository-image.png" alt="Original repository image and digitized values after shear and crop" loading="lazy">
# ```
#
# ## Before trusting a real image
#
# Crop labels, axes, borders, and colorbar ticks from the image. Check that the
# colorbar varies monotonically with value and runs from high to low. Compare
# a few known colors against their expected values, and vary the resize ratio.
# Nearest-color matching cannot recover information lost to compression or a
# non-injective color map.
#
# Next: [evaluate a model on skewed axes](reconstruction.md).
