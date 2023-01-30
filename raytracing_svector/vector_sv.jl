import Base
include("../raytrace_math.jl")
# import Pkg
# Pkg.add("StaticArrays")
using StaticArrays

const Vec3 = SVector{3, Float32}

# useless function since instance[1]/[2]/[3] access the value that we want (and resemble a method)
# function x(vec::Vec3)
#     return Vec3[1]
# end

# function y(vec::Vec3)
#     return Vec3[2]
# end

# function z(vec::Vec3)
#     return Vec3[3]
# end

function Base.:-(vec::Vec3)
    return Vec3(-vec[1], -vec[2], -vec[3])
end

function Base.:+(vec1::Vec3, vec2::Vec3)
    return Vec3(vec1[1] + vec2[1], vec1[2] + vec2[2], vec1[3] + vec2[3])
end

function Base.:-(vec1::Vec3, vec2::Vec3)
    return vec1 + (-vec2)
end

function Base.:*(vec1::Vec3, vec2::Vec3)
    return Vec3(vec1[1] * vec2[1], vec1[2] * vec2[2], vec1[3] * vec2[3])
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
    return Vec3(vec[1] / scalar, vec[2] / scalar, vec[3] / scalar)
end

function Base.:/(scalar::Number, vec::Vec3)
    return Vec3(scalar / vec[1], scalar / vec[2], scalar / vec[3])
end

function dot(vec1::Vec3, vec2::Vec3)
    return vec1[1] * vec2[1] + vec1[2] * vec2[2] + vec1[3] * vec2[3]
end

function cross(vec1::Vec3, vec2::Vec3)
    return Vec3(vec1[2] * vec2[3] - vec1[3] * vec2[2], vec1[3] * vec2[1] - vec1[1] * vec2[3], vec1[1] * vec2[2] - vec1[2] * vec2[1])
end

function unit_vector(vec::Vec3)
    return vec / norm(vec)
end

function length_squared(vec::Vec3)
    return dot(vec, vec)
end

function norm(vec::Vec3)
    return sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)
end

function norm1(vec::Vec3)
    return sqrt(vec[1]*vec[1] + vec[2]*vec[2] + vec[3]*vec[3])
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
    return (abs(vec[1]) < s) && (abs(vec[2]) < s) && (abs(vec[3]) < s)
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

function random_in_unit_disk()
    while true
        p = Vec3(random_double(-1.,1.), random_double(-1.,1.), 0.)
        if length_squared(p) >= 1.
            continue
        end
        return p
    end
end


# v = Vec3(1,2,3)
# v1 = Vec3([1,2,3])
# println(v1)

# v2 = v + v1
# println(v2)

# v3 = Vec3(zeros(Float64, 1, 3))
# println(v3)

# v4 = v3 + v2
# println(v4)
    
#v = Vec3(1,2,3)
#println(@elapsed(norm1(v)))
#println(@elapsed(norm(v)))
# only for shit and jiggle but actually they differ in terms of comupte time
# but I think is only optimization of compiler, it understand that is the same computation
# and propose the same result trowing away the computation, because if we switch the order
# of the elapsed function we get opposite result
