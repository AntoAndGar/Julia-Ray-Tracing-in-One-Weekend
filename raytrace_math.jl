using Random

function deg2rad(degrees::Float64)
    return degrees * Base.pi / 180
end

function random_double() 
    return rand(Float64, 1)[1]
end

function random_double(min::Float64, max::Float64) 
    return min + (max-min) * random_double()
end

function clamp(x::Float64, min::Float64, max::Float64)
    if x < min
        return min
    elseif x > max
        return max
    end
    return x
end


