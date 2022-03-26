# Using mutable to allow missing values

# All values will be English names so that the `yaml` files will be human-readable.
@missable mutable struct Pokemon
    id::String
    moves::Vector{String} = String[]
    gender::Union{Nothing, Bool}
    item::String
    stats::Stats
    ability::String
end
