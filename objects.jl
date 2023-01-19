include("vector.jl")

mutable struct Hit_record
    t::Float64
    p::Vec3
    normal::Vec3
    front_face::Bool

    Hit_record(t, p, n, f) = new(t,p,n,f)
end

abstract type Hittable end

function hit(object::Hittable, ray::Ray, t_min::Float64, t_max::Float64, hit_record::Hit_record)::Bool
    return false
end

function set_face_normal(hit_record::Hit_record, ray::Ray, outward_normal::Vec3)
    hit_record.front_face = dot(ray.direction, outward_normal) <0
    hit_record.normal = hit_record.front_face ? outward_normal : -outward_normal
end


struct Sphere <: Hittable
    center::Vec3
    radius::Float64
end

function hit(sphere::Sphere, ray::Ray, t_min::Float64, t_max::Float64, hit_record::Hit_record)::Bool
    oc = ray.origin - sphere.center
    a = dot(ray.direction, ray.direction)
    half_b = dot(oc, ray.direction)
    c = length_squared(oc) - sphere.radius^2
    
    discriminant = half_b^2 - a*c
    if discriminant < 0
        return false
    end
    sqrtd = sqrt(discriminant)
    root = (-half_b - sqrtd) / a # 1st solution with -
    if root < t_min || root > t_max  
        root = (-half_b + sqrtd) / a # 2nd solution with +
        if root < t_min || root > t_max
            return false
        end
    end
    hit_record.t = root
    hit_record.p = at(ray, hit_record.t)
    outward_normal = (hit_record.p - sphere.center) / sphere.radius
    set_face_normal(hit_record, ray, outward_normal)

    return true
end

# TODO: make the same with triangles and meshes