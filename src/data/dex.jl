# All values will be English names so that the `yaml` files will be human-readable.
@type_wrapper PokemonID String
@type_wrapper ItemID String
@type_wrapper MoveID String
@type_wrapper AbilityID String
@type_wrapper Gender Union{Nothing, Bool}

@enum PokemonType begin
    DARK
    ROCK
    ELECTRIC
    BUG
    STEEL
    NORMAL
    WATER
    GROUND
    POISON
    GHOST
    FAIRY
    FLYING
    PSYCHIC
    GRASS
    ICE
    FIGHTING
    FIRE
    DRAGON

    BIRD
end

Base.@kwdef struct DexStats
    hp::Int
    atk::Int
    def::Int
    spa::Int
    spd::Int
    spe::Int
end

Base.@kwdef struct DexPokemon
    num::Int64
    name::String
    types::Vector{PokemonType}
    weightkg::Float64
    heightm::Float64
    abilities::Vector{AbilityID}
    base_stats::DexStats

    forme::Nullable{String} = nothing
    base_forme::Nullable{String} = nothing
    base_species::Nullable{String} = nothing
    other_formes::Nullable{Vector{String}} = nothing

    other_data::Dict{String, Any} = Dict()
end


const PokeDexFile = joinpath(artifact"data", "dex", "pokedex.yaml")
const PokeDex = Ref{Nullable{OrderedDict{PokemonID, DexPokemon}}}(nothing)

function poke_dex(force = false)
    if !force && !isnothing(PokeDex[])
        return PokeDex[]
    end
    PokeDex[] = open(PokeDexFile) do fi
        deserialize(fi, OrderedDict{PokemonID, DexPokemon}, other_key = :other_data)
    end
end
