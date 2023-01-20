import Base
include("raytrace_math.jl")

mutable struct Vec3{T <: Real}
    x::T
    y::T
    z::T

    Vec3{T}() where {T<:Real} = new(0.,0.,0.)
    Vec3{T}(x,y,z) where {T<:Real} = new(x,y,z)
end

Vec3(x::T,y::T,z::T) where {T<:Real} = Vec3{T}(x,y,z)

# useless function since instance.x/.y/.z access the value that we want (and resemble a method)
# function x(vec::Vec3)
#     return Vec3.x
# end

# function y(vec::Vec3)
#     return Vec3.y
# end

# function z(vec::Vec3)
#     return Vec3.z
# end

function Base.:-(vec::Vec3)
    return Vec3(-vec.x, -vec.y, -vec.z)
end

function Base.:+(vec1::Vec3, vec2::Vec3)
    return Vec3(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z)
end

function Base.:-(vec1::Vec3, vec2::Vec3)
    return vec1 + (-vec2)
end

function Base.:*(vec1::Vec3, vec2::Vec3)
    return Vec3(vec1.x * vec2.x, vec1.y * vec2.y, vec1.z * vec2.z)
end

# how this shitty code can be refactored?
function Base.:*(vec::Vec3, scalar::Number)
    return vec * Vec3(scalar, scalar, scalar)
end

function Base.:*(scalar::Number, vec::Vec3)
    return vec * scalar
end
###

function Base.:/(vec::Vec3, scalar::Number)
    return Vec3(vec.x / scalar, vec.y / scalar, vec.z / scalar)
end

function Base.:/(scalar::Number, vec::Vec3)
    return Vec3(scalar / vec.x, scalar / vec.y, scalar / vec.z)
end

function dot(vec1::Vec3, vec2::Vec3)
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

function cross(vec1::Vec3, vec2::Vec3)
    return Vec3(vec1.y * vec2.z - vec1.z * vec2.y, vec1.z * vec2.x - vec1.x * vec2.z, vec1.x * vec2.y - vec1.y * vec2.x)
end

function unit_vector(vec::Vec3)
    return vec / norm(vec)
end

function length_squared(vec::Vec3)
    return dot(vec, vec)
end

function norm(vec::Vec3)
    return sqrt(vec.x^2 + vec.y^2 + vec.z^2)
end

function norm1(vec::Vec3)
    return sqrt(vec.x*vec.x + vec.y*vec.y + vec.z*vec.z)
end

function norm2(vec::Vec3)
    return sqrt(length_squared(vec))
end

function random_vec3()
    return Vec3(random_double(),random_double(),random_double())
end

function random_vec3(min::Number, max::Number)
    return Vec3(random_double(min,max),random_double(min,max),random_double(min,max))
end

function random_in_unit_sphere()
    while true
        p = random_vec3(-1.0,1.0)
        if length_squared(p) >= 1
            continue
        end
        return p
    end
end

function random_unit_vector()
    return unit_vector(random_in_unit_sphere())
end

function random_in_hemisphere(normal::Vec3)
    in_unit_sphere = random_in_unit_sphere()
    if dot(in_unit_sphere, normal) > 0.0 # In the same hemisphere as the normal
        return in_unit_sphere
    else
        return -in_unit_sphere
    end
end

function near_zero(vec::Vec3)
    s = 1e-8
    return (abs(vec.x) < s) && (abs(vec.y) < s) && (abs(vec.z) < s)
end

function reflect(v::Vec3, n::Vec3)
    return v - 2 * dot(v,n) * n
end

function refract(uv::Vec3, n::Vec3, etai_over_etat::Number)
    cos_theta = min(dot(-uv, n), 1.0)
    r_out_perp = etai_over_etat * (uv + cos_theta * n)
    r_out_parallel = -sqrt(abs(1.0 - length_squared(r_out_perp))) * n
    return r_out_perp + r_out_parallel
end

    
#v = Vec3(1,2,3)
#println(@elapsed(norm1(v)))
#println(@elapsed(norm(v)))
# only for shit and jiggle but actually they differ in terms of comupte time
# but I think is only optimization of compiler, it understand that is the same computation
# and propose the same result trowing away the computation, because if we switch the order
# of the elapsed function we get opposite result
