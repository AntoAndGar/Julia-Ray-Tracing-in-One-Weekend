include("vector.jl")
include("ray.jl")

function write_color(im, pixel_color)
    ir = trunc(255.999 * pixel_color.x)
    ig = trunc(255.999 * pixel_color.y)
    ib = trunc(255.999 * pixel_color.z)

    write(im, "$ir $ig $ib\n")
end

aspect_ratio = 16.0 / 9.0
image_w = 400
image_h = trunc(image_w / aspect_ratio)

viewport_height = 2.0
viewport_width = aspect_ratio * viewport_height
focal_length = 1.0

origin = Vec3(0.0,0.0,0.0)
horizontal = Vec3(viewport_width,0.0,0.0)
vertical = Vec3(0.0,viewport_height,0.0)
lower_left_corner = origin - horizontal/2 - vertical/2 - Vec3(0.0,0.0,focal_length)

filename = "image_ray.ppm"
touch(filename)
im = open(filename, "w")

write(im, "P3\n$image_w $image_h\n255\n")

for j in image_h:-1:1
    for i in 1:image_w
        u = i / (image_w - 1)
        v = j / (image_h - 1)
        r = Ray(origin, lower_left_corner + u*horizontal + v*vertical - origin)
        pixel_color = ray_color(r)

        write_color(im, pixel_color)
    end
end

close(im)