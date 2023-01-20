include("objects.jl")

abstract type HittableList end

struct hittable_list{T} <: HittableList
    hittable_l::Vector{T}

    # construct a list with no elements
    hittable_list{T}() where {T<:Hittable} = new{T}(Vector{T}())
    # construct a list with one element
    hittable_list{T}(hittable::T) where {T<:Hittable} = new{T}(Vector{T}([hittable]))

end

function Base.push!(hittable_list::HittableList, hittable::Hittable)
    push!(hittable_list.hittable_l, hittable)
end

function hit(list::hittable_list{Hittable}, ray::Ray, t_min::Float64, t_max::Float64, hit_record::Hit_record)::Bool
    temp_hit_record = Hit_record(0, Vec3{Float64}(), Vec3{Float64}(),Lambertian(), false)
    hit_anything = false
    closest_so_far = t_max

    for object in list.hittable_l
        if hit(object, ray, t_min, closest_so_far, temp_hit_record)
            hit_anything = true
            closest_so_far = temp_hit_record.t
            hit_record.t = temp_hit_record.t
            hit_record.p = temp_hit_record.p
            hit_record.normal = temp_hit_record.normal
            hit_record.front_face = temp_hit_record.front_face
            hit_record.material = temp_hit_record.material
        end
    end
    return hit_anything
end