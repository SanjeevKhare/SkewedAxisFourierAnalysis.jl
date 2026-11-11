module SkewedAxisFourierAnalysis

using ColorSchemes
using CoordinateTransformations
using FFTW
using ImageTransformations 
using Images 
using LinearAlgebra
using OffsetArrays
using Printf
using ProgressMeter
using StaticArrays 

"""
    shear_image(img, θ)
Shear the image at an angle θ.

# Arguments
- `img`: The image to be sheared.
- `θ`: The angle in degrees at which the image is to be sheared.
"""
function shear_image(img, θ)
    tfm_mat = @SMatrix ([1 0; tand(θ) 1])
    translation_vec = @SVector [0.0, 0.0]
    tfm = AffineMap(tfm_mat, translation_vec)
    warped_img = OffsetArrays.no_offset_view(warp(img, tfm))
    return warped_img 
end

"""
    build_sheared_function_from_sinousoids(opdata, xx, yy, θ)

Evaluate a real cosine model on Cartesian coordinate arrays `xx` and `yy`.
The angle `θ` is in degrees. The implemented transform is
`U = xx + yy*cotd(θ)`, `V = yy*cscd(θ)`; its second direct-space basis vector
is `(-cosd(θ), sind(θ))`. Avoid angles with zero sine.

Each tuple in `opdata` is `(i, j, magnitude, phase)`, with row index `i`,
column index `j`, and phase in radians. Ordinary non-DC modes contribute
`2*magnitude*cos(2π*(j*U + i*V) + phase)`. The final tuple must be DC;
it contributes `magnitude*cos(phase)` without doubling. Coordinate arrays
must have the same shape and the same real element type as the magnitudes.
"""
function build_sheared_function_from_sinousoids(opdata::AbstractArray{Tuple{T, T, T1, T1}}, xx::AbstractArray{T1}, yy::AbstractArray{T1}, θ::T2) where {T, T1<:Real, T2<:Real}
    XX, YY = xx .+ yy / tand(θ), yy / sind(θ)
    sol_data = zeros(size(xx))
    fill!(sol_data, opdata[end][3] * cos(opdata[end][4]))
    for (i, j, mag, ang) in opdata[1:end-1]
        @. sol_data += 2 * mag * cos(2π * j * XX + 2π * i * YY + ang)
    end
    return sol_data
end

"""
    create_image_from_data(fval, custom_color_map)

Create an image from 2D data `fval` using the custom color map `custom_color_map`.
"""
function create_image_from_data(fval::AbstractMatrix{T}, custom_color_map) where {T<:Real}
    matrix_norm = (fval .- minimum(fval)) ./ (maximum(fval) - minimum(fval))
    cmap_recond = get(custom_color_map, matrix_norm)
end

"""
    filter_principal_frequencies_for_fft_of_real_data(sinousoids)

Filter the principal frequencies for the FFT of real data.
As FFT of real data have the property 
    `` F(\\omega) = conj(F(-\\omega)) ``
We can filter the principal frequencies for the FFT of real data and still fully
reconstruct the image.
"""
function filter_principal_frequencies_for_fft_of_real_data(sinousoids::Vector{Tuple{Int64,Int64,ComplexF64}})
    sin_dict = Dict((i, j) => v for (i, j, v) in sinousoids)
    yp_xp_keys = [k for k in keys(sin_dict) if (k[1] >= 0 && k[2] >= 0)]
    yp_xm_keys = [k for k in keys(sin_dict) if (k[1] > 0 && k[2] < 0)]
    master_keys = [yp_xm_keys; yp_xp_keys]
    filter!(k -> k != (0, 0), master_keys)
    opdata = [(k[1], k[2], abs(sin_dict[k]), angle(sin_dict[k])) for k in master_keys]
    k = (0, 0)
    push!(opdata, (k[1], k[2], abs(sin_dict[k]), angle(sin_dict[k])))
    return opdata
end

"""
    write_opdata_to_file(opdata, sine_filename)

Write the opdata to a file with the format i, j, mag, ang. The last line is the DC component.
""" 
function write_opdata_to_file(opdata, sine_filename)
    open(sine_filename, "w") do io
        for (i, j, mag, ang) in opdata
            println(io, "$i, $j, $mag, $ang")
        end
    end
end

"""
    crop_transparent_border_of_image(warped_img)

Crop the transparent border of the image.
"""
function crop_transparent_border_of_image(warped_img::Matrix{RGBA{T}}) where {T<:Number}
    ny_img, nx_img = size(warped_img)
    ix_start = findfirst(!iszero, alpha.(warped_img[div(ny_img,2), :]))
    ix_stop =  findfirst(!iszero, alpha.(reverse(warped_img[div(ny_img,2), :])))
    iy_start = findfirst(!iszero, alpha.(warped_img[:, div(nx_img, 2)]))
    iy_stop = ny_img + 1 - findfirst(!iszero, alpha.(reverse(warped_img[:, div(nx_img, 2)])))
    cropped_img = warped_img[iy_start:iy_stop, ix_start:end-ix_stop]
end

"""
    findnearest_value_index(f::F, x::AbstractArray{T}, x1::T) where {T,F<:Function}

Find the index of the nearest value in the array `x` to the value `x1` using the function `f` to measure the distance between these two points.
"""
function findnearest_value_index(f::F, x::AbstractArray{T}, x1::T) where {T,F<:Function}
    minval = typemax(Float64)
    minidx = 0
    for i in eachindex(x)
        val = f(x[i], x1)
        if val < minval
            minval = val
            minidx = i
        end
    end
    return minval, minidx
end

"""
    rgb_to_rgba(img::Array{RGB{T},2}) where {T<:Number}

Convert an RGB image to an RGBA image.
"""
function rgb_to_rgba(img::Array{RGB{T},2}) where {T<:Number}
    rgba_img = similar(img, RGBA{T})
    for i in eachindex(img)
        rgba_img[i] = RGBA{T}(red(img[i]), green(img[i]), blue(img[i]), 1.0)
    end
    return rgba_img
end

"""
    rgba_to_rgb(img::Array{RGBA{T},2}) where {T<:Number}

Convert an RGBA image to an RGB image.
"""
function rgba_to_rgb(img::Array{RGBA{T},2}) where {T<:Number}
    rgb_img = similar(img, RGB{T})
    for i in eachindex(img)
        rgb_img[i] = RGB{T}(red(img[i]), green(img[i]), blue(img[i]))
    end
    return rgb_img
end

"""
    map_image_to_data(img::Matrix{RGB{T}}, cb_line::Vector{RGB{T}}, lowerlimit, upperlimit) 

Map a scientific image to a data array using a colorbar line, and lower and upper limits of the colorbar.

# Arguments
- `img::Matrix{RGB{T}}`: The scientific image to be mapped to data. Element type is `RGB{T}`.
- `cb_line::Vector{RGB{T}}`: The colorbar line. Element type is `RGB{T}`.
- `lowerlimit`: The lower limit of the colorbar.
- `upperlimit`: The upper limit of the colorbar.

The colorbar vector runs from the upper limit to the lower limit. The current
implementation uses every other sample and perceptual `colordiff` matching.
Supply matching RGB channel types and `Float64` limits.
"""
function map_image_to_data(img::Matrix{RGB{T}}, cb_line::Vector{RGB{T}}, lowerlimit::T1, upperlimit::T1) where {T,T1<:Float64}
    image_data = zeros(Float64, size(img))
    cb_line = cb_line[1:2:end]
    values = range(upperlimit, lowerlimit, length=size(cb_line, 1)) |> collect
    scalar_difference = zeros(Float64, size(cb_line, 1))
    @showprogress for i in eachindex(img)
        min_index = (findnearest_value_index(colordiff, cb_line, img[i]))[2]
        image_data[i] = values[min_index]
    end
    return image_data
end

"""
    fft_power_analysis(image_data, threshold=0.005)

Return `(high_power_mask, image_fft_raw)` for real two-dimensional data.
The raw transform is unnormalized. The mask uses a historical amplitude
heuristic: sort `2*abs.(image_fft_raw)` in ascending order, find the first
increment of its normalized cumulative sum strictly above `threshold`,
and retain amplitudes strictly above the corresponding cutoff.

`threshold` is not a cumulative retained-power fraction. All-zero input
or a threshold above every increment has no valid cutoff and is unsupported.
DC is not automatically preserved. Inspect the mask and compare numeric
reconstruction errors when choosing a threshold.
"""
function fft_power_analysis(image_data::AbstractMatrix{T}, threshold=0.005) where {T<:Real}
    image_fft_raw = FFTW.fft(image_data)
    power_spectrum = abs.(image_fft_raw) .* 2
    spectrum_vals = sort(power_spectrum[:])
    spectrum_power_increase = diff(cumsum(spectrum_vals) / sum(spectrum_vals))

    # Find the threshold for high power
    high_power_threshold_index = findfirst(i -> i > threshold, spectrum_power_increase)

    high_power_threshold = spectrum_vals[high_power_threshold_index]

    low_power_mask = power_spectrum .<= high_power_threshold
    high_power_mask = power_spectrum .> high_power_threshold
    return high_power_mask, image_fft_raw
end

"""
    extract_dominant_harmonics(image_data, threshold=0.005)

Apply [`fft_power_analysis`](@ref) and return selected tuples
`(i, j, coefficient)`. Here `i` is the signed row-frequency index, `j` is
the signed column-frequency index, and each complex coefficient is normalized
by the total number of input samples. Use ordinary low-frequency modes;
verify Nyquist-edge modes separately before cosine reconstruction.

The threshold follows the amplitude heuristic described by
[`fft_power_analysis`](@ref), rather than a retained-power percentage.
"""
function extract_dominant_harmonics(image_data::AbstractMatrix{T}, threshold=0.005) where {T<:Real}
    high_power_mask, image_fft_raw = fft_power_analysis(image_data, threshold)
    @show size(image_fft_raw)
    sinousoids = Vector{Tuple{Int64,Int64,ComplexF64}}()
    for c in findall(high_power_mask)
        i, j = c.I
        if i > size(image_fft_raw, 1) / 2
            i = i - size(image_fft_raw, 1)
        end
        if j > size(image_fft_raw, 2) / 2
            j = j - size(image_fft_raw, 2)
        end
        push!(sinousoids, (i - 1, j - 1, image_fft_raw[c] / length(image_fft_raw)))
    end
    return sinousoids
end

"""
    convert_image_to_data(img, cb, decimation_factor, lowerlimit, upperlimit)
"""
function convert_image_to_data(img::AbstractArray{T}, cb::AbstractArray{T2}, decimation_factor::Float64, lowerlimit::Float64, upperlimit::Float64) where {T, T2}
    if eltype(img) == RGBA{N0f8}
        img = rgba_to_rgb(img)
    end

    img = imresize(img, ratio=decimation_factor)

    if eltype(cb) == RGBA{N0f8}
        cb = rgba_to_rgb(cb)
    end

    cb_line = cb[:, div(size(cb, 2), 2)]
    texec = @elapsed image_data = map_image_to_data(img, cb_line, lowerlimit, upperlimit)
    println("Time to convert: $(@sprintf("%.2f", texec)) seconds")
    return image_data
end
end # SkewedAxisFourierAnalysis