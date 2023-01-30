include("vector1.jl")

mutable struct Ray{T, N}
    origin::T
    direction::N

    Ray{T, N}(origin, direction) where {T<:Array{Float64, 1}, N<:Array{Float64, 1}} = new(origin, direction)
end

Ray(origin::T, direction::N) where {T<:Array{Float64, 1}, N<:Array{Float64, 1}} = Ray{Array{Float64, 1}, Array{Float64, 1}}(origin, direction)

function at(ray::Ray, t::Real)
    return ray.origin + t * ray.direction
end

function hit_sphere(center::Array{Float64, 1}, radius::Real, ray::Ray)
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
    t = hit_sphere(Array{Float64, 1}([0.0, 0.0, -1.0]), 0.5, ray)
    if t > 0.0
        N = unit_vector(at(ray, t) - Array{Float64, 1}([0.0, 0.0, -1.0]))
        return 0.5 * Array{Float64, 1}([N[1] + 1, N[2] + 1, N[3] + 1])
    end
    unit_direction = unit_vector(ray.direction)
    t = 0.5 * (unit_direction[2] + 1.0)
    return (1.0 - t) * Array{Float64, 1}([1.0, 1.0, 1.0]) + t * Array{Float64, 1}([0.5, 0.7, 1.0])
end