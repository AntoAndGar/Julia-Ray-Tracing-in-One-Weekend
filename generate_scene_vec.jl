include("vector1.jl")
include("primitive1.jl")
include("objects_structs1.jl")
include("raytrace_math.jl")
include("camera_vec.jl")
#import Pkg 
#Pkg.add("Images")
using Images, SharedArrays

function write_color(im, pixel_color, samples_per_pixel)
    scale = 1.0 / samples_per_pixel

    # Replace NaN components with zero. See explanation in Ray Tracing: The Rest of Your Life.
    if isnan(pixel_color[1]) 
        pixel_color[1] = 0.0
    end
    if isnan(pixel_color[2]) 
        pixel_color[2] = 0.0
    end
    if isnan(pixel_color[3]) 
        pixel_color[3] = 0.0
    end

    r =  clamp((pixel_color[1] * scale)^0.45, 0.0, 0.999)
    g =  clamp((pixel_color[2] * scale)^0.45, 0.0, 0.999)
    b =  clamp((pixel_color[3] * scale)^0.45, 0.0, 0.999)

    return Array{Float64, 1}([r,g,b])
    #write(im, "$r $g $b\n")
end

function save_image(filename::String, image_::Array{Array{Float64, 1}})
    image = rotl90(image_)
    
    colored_image = zeros(RGB, size(image))
    Threads.@threads for i in 1:size(image)[1]
        for j in 1:size(image)[2]
            colored_image[i,j] = RGB(image[i,j][1], image[i,j][2], image[i,j][3])
        end
    end
    save(filename, colored_image)
  end

function ray_color(ray::Ray, world::HittableList, depth::Int64)
    hit_record = Hit_record(0. , vec(zeros(Float64, 1, 3)), vec(zeros(Float64, 1, 3)), Lambertian(), false)
    
    # If we've exceeded the ray bounce limit, no more light is gathered.
    if depth <= 0
        return vec(zeros(Float64, 1, 3))
    end

    if hit(world, ray, 0.001 , Base.Inf64, hit_record)
        scattered = Ray(vec(zeros(Float64, 1, 3)), vec(zeros(Float64, 1, 3)))
        attenuation = vec(zeros(Float64, 1, 3))
        if scatter(hit_record.material, ray, hit_record, attenuation, scattered)
            return attenuation * ray_color(scattered, world, depth - 1)
        end
        return vec(zeros(Float64, 1, 3))
    end

    unit_direction = unit_vector(ray.direction)
    t = 0.5 * (unit_direction[2] + 1.0)
    return (1.0 - t) * Array{Float64, 1}([1.0, 1.0, 1.0]) + t * Array{Float64, 1}([0.5, 0.7, 1.0])
end


function random_scene()
    world = hittable_list{Hittable}()
    push!(world, Sphere(Array{Float64, 1}([0., -1000., 0.]), 1000., Lambertian(Array{Float64, 1}([0.5, 0.5, 0.5]))))
    for a in -11:11
        for b in -11:11
            choose_mat = random_double()
            center = Array{Float64, 1}([a + 0.9 * random_double(), 0.2, b + 0.9 * random_double()])
            if norm(center - Array{Float64, 1}([4., 0.2, 0.])) > 0.9
                if choose_mat < 0.8
                    # diffuse
                    albedo = Array{Float64, 1}([random_double() * random_double(), random_double() * random_double(), random_double() * random_double()])
                    push!(world, Sphere(center, 0.2, Lambertian(albedo)))
                elseif choose_mat < 0.95
                    # metal
                    albedo = Array{Float64, 1}([random_double(0.5, 1.), random_double(0.5, 1.), random_double(0.5, 1.)])
                    fuzz = random_double(0., 0.5)
                    push!(world,Sphere(center, 0.2, Metal(albedo, fuzz)))
                else
                    # glass
                    push!(world, Sphere(center, 0.2, Dielectric(1.5)))
                end
            end
        end
    end

    push!(world, Sphere(Array{Float64, 1}([0., 1., 0.]), 1.0, Dielectric(1.5)))
    push!(world, Sphere(Array{Float64, 1}([-4., 1., 0.]), 1.0, Lambertian(Array{Float64, 1}([0.4, 0.2, 0.1]))))
    push!(world, Sphere(Array{Float64, 1}([4., 1., 0.]), 1.0, Metal(Array{Float64, 1}([0.7, 0.6, 0.5]), 0.0)))
    return world
end

function main()
    # Image
    aspect_ratio = 3.0 / 2.0
    image_w = 720
    image_h = trunc(Int64, image_w / aspect_ratio)
    samples_per_pixel = 100
    max_depth = 50

    # World
    world = random_scene()

    # Camera
    lookfrom = Array{Float64, 1}([13., 2., 3.])
    lookat = Array{Float64, 1}([0., 0., 0.])
    vup = Array{Float64, 1}([0., 1., 0.])
    aperture = 0.1
    dist_to_focus = 10.0

    camera = Camera(lookfrom, lookat, vup, 20.0, aspect_ratio, aperture, dist_to_focus)

    # filename = "image_scene_vec.ppm"
    # touch(filename)
    # im = open(filename, "w")

    #image = Array{Array{Float64, 1}}(undef, image_w, image_h)
    image = fill(vec(zeros(Float64, 1, 3)), image_w, image_h)

    #write(im, "P3\n$image_w $image_h\n255\n")

    Threads.@threads for i in 1:image_w
        println("Doing column: $i")
        for j in 1:image_h
            image[i,j] = vec(zeros(Float64, 1, 3))
            for s in 1:samples_per_pixel
                u = (i + random_double()) / (image_w - 1)
                v = (j + random_double()) / (image_h - 1)
                r = get_ray(camera, u, v)
                image[i,j] += ray_color(r, world, max_depth)
            end
            image[i,j] = write_color(im, image[i,j], samples_per_pixel)
        end
        #save_image("raytracing_vec1.png", image)
    end

    save_image("raytracing_vec1.png", image)
    println("Done!")
    #close(im)

end

main()