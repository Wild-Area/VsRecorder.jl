# All values will be English names so that the `yaml` files will be human-readable.
@type_wrapper PokemonID String
@type_wrapper ItemID String
@type_wrapper MoveID String
@type_wrapper AbilityID String
@type_wrapper Gender Union{Nothing, Bool}

get_i18n(id::PokemonID, lang = nothing) = get_i18n("pokemon", id, lang = lang)
get_i18n(id::ItemID, lang = nothing) = get_i18n("item", id, lang = lang)
get_i18n(id::MoveID, lang = nothing) = get_i18n("move", id, lang = lang)
get_i18n(id::AbilityID, lang = nothing) = get_i18n("ability", id, lang = lang)

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

@enum MoveCategory begin
    PHYSICAL
    SPECIAL
    STATUS
end

@enum NonstandardMoveType begin
    NONSTANDARD_NONE
    NONSTANDARD_PAST
    NONSTANDARD_GIGANTAMAX
    NONSTANDARD_LGPE
end
VsRecorderBase.enum_prefix(::Type{NonstandardMoveType}) = "NONSTANDARD_"

@enum MoveTarget begin
    TARGET_NORMAL
    TARGET_ADJACENT_FOE
    TARGET_ANY
    TARGET_ADJACENT_ALLY
    TARGET_FOE_SIDE
    TARGET_RANDOM_NORMAL
    TARGET_ADJACENT_ALLY_OR_SELF
    TARGET_ALLY_TEAM
    TARGET_SCRIPTED
    TARGET_ALL_ADJACENT
    TARGET_SELF
    TARGET_ALL
    TARGET_ALLIES
    TARGET_ALLY_SIDE
    TARGET_ALL_ADJACENT_FOES
end
VsRecorderBase.enum_prefix(::Type{MoveTarget}) = "TARGET_"

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

    other_data::Dict{Symbol, Any} = Dict()
end


Base.@kwdef struct DexMove
    num::Int64
    accuracy::Union{Int64, Bool}
    base_power::Int64
    category::MoveCategory
    is_nonstandard::NonstandardMoveType = NONSTANDARD_NONE
    name::String
    pp::Int64
    priority::Int64
    target::MoveTarget = TARGET_NORMAL
    type::PokemonType

    other_data::Dict{Symbol, Any} = Dict()
end


const PokeDexFile = joinpath(artifact"data", "dex", "pokedex.yaml")
const MoveDexFile = joinpath(artifact"data", "dex", "movedex.yaml")
const PokeDex = Ref{Nullable{OrderedDict{PokemonID, DexPokemon}}}(nothing)
const MoveDex = Ref{Nullable{OrderedDict{MoveID, DexMove}}}(nothing)

function poke_dex(force = false)
    if !force && !isnothing(PokeDex[])
        return PokeDex[]
    end
    PokeDex[] = open(PokeDexFile) do fi
        deserialize(
            fi,
            OrderedDict{PokemonID, DexPokemon},
            other_key = :other_data,
            dicttype = OrderedDict
        )
    end
end

function move_dex(force = false)
    if !force && !isnothing(MoveDex[])
        return MoveDex[]
    end
    MoveDex[] = open(MoveDexFile) do fi
        deserialize(
            fi,
            OrderedDict{MoveID, DexMove},
            other_key = :other_data,
            dicttype = OrderedDict
        )
    end
end
