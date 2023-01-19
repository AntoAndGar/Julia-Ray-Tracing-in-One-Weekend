include("vector.jl")
include("primitive.jl")
include("objects_structs.jl")
include("raytrace_math.jl")
include("camera.jl")

function write_color(im, pixel_color, samples_per_pixel)
    scale = 1.0 / samples_per_pixel
    r = 256 * clamp(pixel_color.x * scale, 0.0, 0.999)
    g = 256 * clamp(pixel_color.y * scale, 0.0, 0.999)
    b = 256 * clamp(pixel_color.z * scale, 0.0, 0.999)

    write(im, "$r* $g $b\n")
end

function ray_color(ray::Ray, world::HittableList)
    hit_record = Hit_record(0. , Vec3(0. ,0. , 0.), Vec3(0. ,0. ,0. ), false)
    if hit(world, ray, 0. , Base.Inf64, hit_record)
        #println("normal: ", hit_record.normal)
        return 0.5 * (hit_record.normal + Vec3(1. ,1. ,1. ))
    end
    unit_direction = unit_vector(ray.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - t) * Vec3(1.0, 1.0, 1.0) + t * Vec3(0.5, 0.7, 1.0)
end

# Image
aspect_ratio = 16.0 / 9.0
image_w = 400
image_h = trunc(image_w / aspect_ratio)
samples_per_pixel = 100

# World
world = hittable_list{Hittable}()
push!(world, Sphere(Vec3(0. , 0. , -1. ), 0.5))
push!(world, Sphere(Vec3(0. , -100.5, -1. ), 100.))

# Camera
camera = Camera()

filename = "image_sphere_unaliased.ppm"
touch(filename)
im = open(filename, "w")

write(im, "P3\n$image_w $image_h\n255\n")

for j in image_h:-1:1
    for i in 1:image_w
        pixel_color = Vec3(0. , 0. , 0.)
        for s in 1:samples_per_pixel
            u = (i + random_double()) / (image_w - 1)
            v = (j + random_double()) / (image_h - 1)
            r = get_ray(camera, u, v)
            pixel_color += ray_color(r, world)
        end
        write_color(im, pixel_color, samples_per_pixel)
    end
end

println("Done!")
close(im)