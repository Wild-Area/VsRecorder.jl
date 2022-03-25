Base.@kwdef mutable struct MoveSet
    move1::Misssable{Int}
end

# Using mutable to allow missing values
Base.@kwdef mutable struct Pokemon
    id::Int
    moves::MoveSet
end

