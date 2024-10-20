# # [Introduction](@id introduction)
# We will use the package to analyze the sheared 
# axis crystal image.

# # [Tutorial](@id tutorial)
# This Tutorial will guide you through the process of using the package.
# - We will take sheared axis crystal image. Reshape it. Convert it into data. 
# - Extract the dominant harmonics. 
# - Filter the principal frequencies. 
# - Reconstruct the image from the data. 

using Images, ColorSchemes
import SkewedAxisFourierAnalysis as FA

## We are going to use this function to check the reconstruction of the image
function check_reconstruction(opdata, θ, custom_color_map)
    x, y = range(0, 4, length=600), range(0, 4, length=600)
    xx = ones(length(y)) * x'
    yy = repeat(y, 1, length(x))
    sol_data = FA.build_sheared_function_from_sinousoids(opdata, xx, yy, θ)
    return FA.create_image_from_data(sol_data, custom_color_map), sol_data
end

## Load the image and the colorbar
img_raw = load("../assets/CrCl3_sheared.png")
cb_path = "../assets/crcl3_cb.png"

## The file where the harmonics data will be stored
sine_filename = "CrCl3_sin_dict.txt"

# Transform image and crop the transparent border
warped_img = FA.shear_image(img_raw, 30)
cropped_img = FA.crop_transparent_border_of_image(warped_img)
mosaicview(img_raw, cropped_img, nrow=1, ncol=2)

# Now that image is in orthogonal coordinates, we can convert it to data. Since it is color image, we will have to approximate the perception of each pixel to a single value.

## Read and interpret the colorbar so that we can map colors to values
cb = load(cb_path);
if eltype(cb) == RGBA{N0f8}
    cb = FA.rgba_to_rgb(cb)
end

## Also create a custom color map based on the color bar, 
## if you want to recreate the image from data
cb_line = cb[:, div(size(cb, 2), 2)]
custom_color_map = ColorScheme(reverse(cb_line));

## Convert the image to data
img_jpg = imresize(FA.rgba_to_rgb(cropped_img), ratio=0.05)
image_data = FA.map_image_to_data(img_jpg, cb_line, -2.22, 1.05)
FA.create_image_from_data(image_data, custom_color_map)

## Extract Harmonics and package harmonics data to file
sinousoids = FA.extract_dominant_harmonics(image_data, 0.001)
opdata  = FA.filter_principal_frequencies_for_fft_of_real_data(sinousoids)
FA.write_opdata_to_file(opdata, sine_filename)

## See how the image is reconstructed   
sol_img, sol_data = check_reconstruction(opdata, 120, custom_color_map)
sol_img