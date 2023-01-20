include("vector.jl")
include("primitive.jl")
include("objects_structs.jl")
include("raytrace_math.jl")
include("camera.jl")

function write_color(im, pixel_color, samples_per_pixel)
    scale = 1.0 / samples_per_pixel
    r = 256 * clamp(sqrt(pixel_color.x * scale), 0.0, 0.999)
    g = 256 * clamp(sqrt(pixel_color.y * scale), 0.0, 0.999)
    b = 256 * clamp(sqrt(pixel_color.z * scale), 0.0, 0.999)

    write(im, "$r* $g $b\n")
end

function ray_color(ray::Ray, world::HittableList, depth::Int64)
    hit_record = Hit_record(0. , Vec3{Float64}(), Vec3{Float64}(), Lambertian(), false)
    
    # If we've exceeded the ray bounce limit, no more light is gathered.
    if depth <= 0
        return Vec3{Float64}()
    end

    if hit(world, ray, 0.001 , Base.Inf64, hit_record)
        scattered = Ray(Vec3{Float64}(), Vec3{Float64}())
        attenuation = Vec3{Float64}()
        if scatter(hit_record.material,ray, hit_record, attenuation, scattered)
            return attenuation * ray_color(scattered, world, depth - 1)
        end
        return Vec3{Float64}()
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
max_depth = 50;

# World
world = hittable_list{Hittable}()
material_ground = Lambertian(Vec3(0.8, 0.8, 0.0))
material_center = Lambertian(Vec3(0.7, 0.3, 0.3))
material_left = Metal(Vec3(0.8, 0.8, 0.8), 0.3)
material_right = Metal(Vec3(0.8, 0.6, 0.2), 1.0)

push!(world, Sphere(Vec3(0. , -100.5, -1. ), 100., material_ground))
push!(world, Sphere(Vec3(0. , 0. , -1. ), 0.5, material_center))
push!(world, Sphere(Vec3(-1. , 0. , -1. ), 0.5, material_left))
push!(world, Sphere(Vec3(1. , 0. , -1. ), 0.5, material_right))

# Camera
camera = Camera()

filename = "image_sphere_metal_fuzz.ppm"
touch(filename)
im = open(filename, "w")

write(im, "P3\n$image_w $image_h\n255\n")

for j in image_h:-1:1
    println("Scanlines remaining: $j")
    for i in 1:image_w
        pixel_color = Vec3{Float64}()
        for s in 1:samples_per_pixel
            u = (i + random_double()) / (image_w - 1)
            v = (j + random_double()) / (image_h - 1)
            r = get_ray(camera, u, v)
            pixel_color += ray_color(r, world, max_depth)
        end
        write_color(im, pixel_color, samples_per_pixel)
    end
end

println("Done!")
close(im)