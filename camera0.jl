include("raytrace_math.jl")

struct Camera
    origin::Vec3
    lower_left_corner::Vec3
    horizontal::Vec3
    vertical::Vec3

    # Image
    #aspect_ratio::Float64 = 16.0 / 9.0

    # Camera
    #viewport_height::Float64 = 2.0
    #viewport_width::Float64 = aspect_ratio * viewport_height
    #focal_length::Float64 = 1.0

    Camera() = new( Vec3(0.0, 0.0, 0.0), # origin
        Vec3(0.0, 0.0, 0.0) - Vec3(16.0 / 9.0 * 2.0, 0.0, 0.0) / 2.0 - Vec3(0.0, 2.0, 0.0) / 2.0 - Vec3(0.0, 0.0, 1.0),  # lower_left_corner
        Vec3(16.0 / 9.0 * 2.0, 0.0, 0.0),  # horizontal
        Vec3(0.0, 2.0, 0.0) # vertical
        )
end

function get_ray(camera::Camera, u::Float64, v::Float64)
    return Ray(camera.origin, camera.lower_left_corner + u*camera.horizontal + v*camera.vertical - camera.origin)
end