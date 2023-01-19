include("vector.jl")
    
struct Ray{T}
    origin::T
    direction::T

    Ray{T}(origin,direction) where {T<:Vec3} = new(origin, direction)
end

Ray(origin::T,direction::T) where {T<:Vec3} = Ray{Vec3}(origin,direction)

function at(ray::Ray,t::Real)
    return ray.origin + t*ray.direction
end

function ray_color(ray::Ray)
    unit_direction = unit_vector(ray.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - t) * Vec3(1.0, 1.0, 1.0) + t * Vec3(0.5, 0.7, 1.0)
end