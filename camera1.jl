include("raytrace_math.jl")

struct Camera
    lookfrom::Vec3 # origin
    lookat::Vec3
    vup::Vec3
    vfov::Float64
    aspect_ratio::Float64
    origin::Vec3
    lower_left_corner::Vec3
    horizontal::Vec3
    vertical::Vec3

    # Image
    #aspect_ratio::Float64 = 16.0 / 9.0

    # Camera
    #focal_length::Float64 = 1.0
    # theta = degrees_to_radians(vfov)
    # h = tan(theta/2)
    # viewport_height = 2.0 * h
    # viewport_width = aspect_ratio * viewport_height

    # w = unit_vector(lookfrom - lookat)
    # u = unit_vector(cross(vup, w))
    # v = cross(w, u)

    Camera(lookfrom, lookat, vup, vfov, aspect_ratio) = new(lookfrom,
        lookat,
        vup,
        vfov, 
        aspect_ratio,
        lookfrom, # origin
        lookfrom - aspect_ratio * 2.0 * tan(deg2rad(vfov)/2.0) * unit_vector(cross(vup, unit_vector(lookfrom - lookat))) / 2.0 - 2.0 * tan(deg2rad(vfov)/2.0) * cross(unit_vector(lookfrom - lookat), unit_vector(cross(vup, unit_vector(lookfrom - lookat)))) / 2.0 - unit_vector(lookfrom - lookat),  # lower_left_corner
        aspect_ratio * 2.0 * tan(deg2rad(vfov)/2.0) * unit_vector(cross(vup, unit_vector(lookfrom - lookat))),  # horizontal
        2.0 * tan(deg2rad(vfov)/2.0) * cross(unit_vector(lookfrom - lookat), unit_vector(cross(vup, unit_vector(lookfrom - lookat)))) # vertical
        )
end

function get_ray(camera::Camera, s::Float64, t::Float64)
    return Ray(camera.origin, camera.lower_left_corner + s*camera.horizontal + t*camera.vertical - camera.origin)
end