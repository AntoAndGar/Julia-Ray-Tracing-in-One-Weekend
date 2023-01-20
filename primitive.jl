include("vector.jl")

mutable struct Ray{T}
    origin::T
    direction::T

    Ray{T}(origin, direction) where {T<:Vec3} = new(origin, direction)
end

Ray(origin::T, direction::T) where {T<:Vec3} = Ray{Vec3}(origin, direction)

function at(ray::Ray, t::Real)
    return ray.origin + t * ray.direction
end

function hit_sphere(center::Vec3, radius::Real, ray::Ray)
    oc = ray.origin - center
    a = length_squared(ray.direction)
    half_b = dot(oc, ray.direction)
    c = length_squared(oc) - radius^2
    discriminant = half_b^2 - a * c
    if discriminant < 0
        return -1.0
    else
        return (-half_b - sqrt(discriminant)) / a
    end
end

function ray_color(ray::Ray)
    t = hit_sphere(Vec3(0.0, 0.0, -1.0), 0.5, ray)
    if t > 0.0
        N = unit_vector(at(ray, t) - Vec3(0.0, 0.0, -1.0))
        return 0.5 * Vec3(N.x + 1, N.y + 1, N.z + 1)
    end
    unit_direction = unit_vector(ray.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - t) * Vec3(1.0, 1.0, 1.0) + t * Vec3(0.5, 0.7, 1.0)
end