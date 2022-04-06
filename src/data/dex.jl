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
# Use English names for the ability/item dexes. (for now?)
const AbilityDexFile = joinpath(artifact"data", "locales", "en", "ability.yaml")
const ItemDexFile = joinpath(artifact"data", "locales", "en", "item.yaml")

macro _dex_func(func_name, dex_name, id_type, dex_type)
    file_name = Symbol(dex_name, :File)
    T = :(OrderedDict{$id_type, $dex_type})
    quote
        const $dex_name = Ref{Nullable{$T}}(nothing)
        function $func_name(; force = false)
            @_load_data $dex_name force open($file_name) do fi
                deserialize(
                    fi,
                    $T,
                    other_key = :other_data,
                    dicttype = OrderedDict
                )
            end
        end
    end |> esc
end

@_dex_func ability_dex AbilityDex AbilityID String
@_dex_func item_dex ItemDex ItemID String
@_dex_func move_dex MoveDex MoveID DexMove
@_dex_func poke_dex PokeDex PokemonID DexPokemon

function search_dex(dex::AbstractDict, name)
    for (id, value) in dex
        if value.name == name
            return id
        end
    end
    name
end

function search_dex(dex::AbstractDict{T, String}, name) where T
    for (id, value) in dex
        if value == name
            return id
        end
    end
    name
end

VsRecorderBase._parse(
    dict::OrderedDict, ::Type{Vector{AbilityID}};
    _...
) = AbilityID[search_dex(ability_dex(), x) for x in values(dict)]

function initialize_dex()
    ability_dex()
    item_dex()
    move_dex()
    poke_dex()
end
