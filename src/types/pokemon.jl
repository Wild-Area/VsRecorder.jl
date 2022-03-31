# Using mutable to allow missing values

# All values will be English names so that the `yaml` files will be human-readable.
const PokemonID = String
const Gender = Union{Nothing, Bool}

@missable mutable struct Stats
    hp::Int
    attack::Int
    defense::Int
    special_attack::Int
    special_defense::Int
    speed::Int
end

@missable mutable struct Pokemon
    id::PokemonID
    moves::Vector{String} = String[]
    gender::Gender
    level::Int64
    item::String
    stats::Stats
    ability::String
    sent_out::Bool = false
    dynamaxed::Bool = false
end

const Team = Vector{Pokemon}

get_name(id::PokemonID) = i18n(GlobalI18nContext[], "pokemon.$(id)")
