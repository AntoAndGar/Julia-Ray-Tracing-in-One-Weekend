include("vector.jl")

abstract type Material end

struct Lambertian <: Material
    albedo::Vec3

    Lambertian() = new(Vec3{Float64}())
    Lambertian(albedo) = new(albedo)
end

mutable struct Hit_record
    t::Float64
    p::Vec3
    normal::Vec3
    material::Material
    front_face::Bool

    Hit_record(t, p, n, m, f) = new(t,p,n,m,f)
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
    material::Material

    Sphere() = new(Vec3{Float64}(), 1., Lambertian())
    Sphere(center, radius, material) = new(center, radius, material)
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
    hit_record.material = sphere.material

    return true
end

function scatter(material::Material, ray_in::Ray, hit_record::Hit_record, attenuation::Vec3, scattered::Ray)
    return false
end

function scatter(material::Lambertian, ray_in::Ray, hit_record::Hit_record, attenuation::Vec3, scattered::Ray)
    scatter_direction  = hit_record.normal + random_unit_vector()
    
    if near_zero(scatter_direction)
        scatter_direction = hit_record.normal
    end
    
    #scattered = Ray(hit_record.p, scatter_direction)
    scattered.origin = hit_record.p
    scattered.direction = scatter_direction
    attenuation.x = material.albedo.x
    attenuation.y = material.albedo.y
    attenuation.z = material.albedo.z
    return true
end

struct Metal <: Material
    albedo::Vec3
    fuzz::Float64

    Metal() = new(Vec3{Float64}(), 0.)
    Metal(albedo, fuzz) = new(albedo, fuzz)
end

function scatter(material::Metal, ray_in::Ray, hit_record::Hit_record, attenuation::Vec3, scattered::Ray)
    reflected = reflect(unit_vector(ray_in.direction), hit_record.normal)
    #scattered = Ray(hit_record.p, reflected)
    scattered.origin = hit_record.p
    scattered.direction = reflected + material.fuzz * random_in_unit_sphere()
    attenuation.x = material.albedo.x
    attenuation.y = material.albedo.y
    attenuation.z = material.albedo.z
    return (dot(scattered.direction, hit_record.normal) > 0)
end

struct Dielectric <: Material
    ir::Float64 # Index of Refraction

    Dielectric(ir) = new(ir)
end

function scatter(material::Dielectric, ray_in::Ray, hit_record::Hit_record, attenuation::Vec3, scattered::Ray)
    attenuation.x = 1.0
    attenuation.y = 1.0
    attenuation.z = 1.0

    refraction_ratio = hit_record.front_face ? (1.0 / material.ir) : material.ir

    unit_direction = unit_vector(ray_in.direction)

    cos_theta = min(dot(-unit_direction, hit_record.normal), 1.0)
    sin_theta = sqrt(1.0 - cos_theta^2)

    cannot_refract = refraction_ratio * sin_theta > 1.0
    scattered.origin = hit_record.p
    if cannot_refract || reflectance(cos_theta, refraction_ratio) > random_double()
        # must reflect
        scattered.direction = reflect(unit_direction, hit_record.normal)
    else
        # can refract
        scattered.direction = refract(unit_direction, hit_record.normal, refraction_ratio)
    end
    return true
end

function reflectance(cosine::Float64, ref_idx::Float64)
    # Use Schlick's approximation for reflectance.
    r0 = (1-ref_idx) / (1+ref_idx)
    r0 = r0^2
    return r0 + (1-r0)*((1-cosine)^5)
end