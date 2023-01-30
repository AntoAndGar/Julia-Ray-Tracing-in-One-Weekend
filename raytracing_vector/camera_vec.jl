include("../raytrace_math.jl")

struct Camera
    lookfrom::Array{Float64, 1} # origin
    lookat::Array{Float64, 1}
    vup::Array{Float64, 1}
    vfov::Float64
    aspect_ratio::Float64
    aperture::Float64
    focus_dist::Float64
    origin::Array{Float64, 1}
    lower_left_corner::Array{Float64, 1}
    horizontal::Array{Float64, 1}
    vertical::Array{Float64, 1}
    u::Array{Float64, 1}
    v::Array{Float64, 1}
    w::Array{Float64, 1}
    lens_radius::Float64

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

    Camera(lookfrom, lookat, vup, vfov, aspect_ratio, aperture, focus_dist) = new(lookfrom,
        lookat,
        vup,
        vfov, 
        aspect_ratio,
        aperture, 
        focus_dist,
        lookfrom, # origin
        lookfrom - focus_dist * aspect_ratio * 2.0 * tan(deg2rad(vfov)/2.0) * unit_vector(cross(vup, unit_vector(lookfrom - lookat))) / 2.0 - focus_dist * 2.0 * tan(deg2rad(vfov)/2.0) * cross(unit_vector(lookfrom - lookat), unit_vector(cross(vup, unit_vector(lookfrom - lookat)))) / 2.0 - focus_dist * unit_vector(lookfrom - lookat),  # lower_left_corner
        focus_dist * aspect_ratio * 2.0 * tan(deg2rad(vfov)/2.0) * unit_vector(cross(vup, unit_vector(lookfrom - lookat))),  # horizontal
        focus_dist * 2.0 * tan(deg2rad(vfov)/2.0) * cross(unit_vector(lookfrom - lookat), unit_vector(cross(vup, unit_vector(lookfrom - lookat)))), # vertical
        unit_vector(cross(vup, unit_vector(lookfrom - lookat))), # u
        cross(unit_vector(lookfrom - lookat), unit_vector(cross(vup, unit_vector(lookfrom - lookat)))), # v
        unit_vector(lookfrom - lookat), # w
        aperture / 2.0 # lens_radius 
        )
end

function get_ray(camera::Camera, s::Float64, t::Float64)
    rd = camera.lens_radius * random_in_unit_disk()
    offset = camera.u * rd[1] + camera.v * rd[2]

    return Ray(
        camera.origin + offset, 
        camera.lower_left_corner + s * camera.horizontal + t * camera.vertical - camera.origin - offset
        )
end