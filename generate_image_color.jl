include("vector.jl")

function write_color(im, pixel_color)
    ir = trunc(255.999 * pixel_color.x)
    ig = trunc(255.999 * pixel_color.y)
    ib = trunc(255.999 * pixel_color.z)

    write(im, "$ir $ig $ib\n")
end

image_w = 256
image_h = 256

touch("image_color.ppm")
im = open("image_color.ppm", "w")

write(im, "P3\n$image_w $image_h\n255\n")

for j in image_h:-1:1
    for i in 1:image_w
        pixel_color = Vec3(i / (image_w), j / (image_h), 0.25)

        write_color(im, pixel_color)
    end
end

close(im)