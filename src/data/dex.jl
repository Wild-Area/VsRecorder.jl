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


const PokeDexFile = datapath("dex", "pokedex.yaml")
const MoveDexFile = datapath("dex", "movedex.yaml")

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
                    dicttype = OrderedDict,
                    loading_dex = true
                )
            end
        end
    end |> esc
end

@_dex_func move_dex MoveDex MoveID DexMove
@_dex_func poke_dex PokeDex PokemonID DexPokemon

struct SimpleListDex{T}
    data::SimpleI18n.I18nData
end
@forward SimpleListDex.data Base.keys, Base.get, Base.haskey, Base.getindex, Base.setindex!
macro _list_dex_func(func_name, id_type, i18n_key)
    i18n_key = string(i18n_key)
    quote
        function $func_name(language = get_game_language())
            ctx = VsI18n.GlobalI18nContext[]
            lang = VsI18n.get_code(get_game_language(language))
            SimpleListDex{$id_type}(ctx.data[lang][$i18n_key])
        end
        $func_name(conf::VsConfig) = $func_name(conf.source.language)
        $func_name(ctx::PokemonContext) = $func_name(ctx.config)
        VsRecorderBase._parse(x, ::Type{$id_type}; loading_dex = false, kwargs...) = if loading_dex
            search_dex($func_name(VsI18n.EN), x) |> $id_type
        else
            $id_type(x)
        end
    end |> esc
end

@_list_dex_func nature_list Nature nature
@_list_dex_func ability_list AbilityID ability
@_list_dex_func item_list ItemID item
@_list_dex_func move_list MoveID move
@_list_dex_func poke_list PokemonID pokemon

function search_dex(dex::AbstractDict, name)
    for (id, value) in dex
        if value.name == name
            return id
        end
    end
end
function search_dex(dex::Union{SimpleListDex{T}, AbstractDict{T, String}}, name) where T
    for id in keys(dex)
        if dex[id] == name
            return T(id)
        end
    end
    T(name)
end
Base.getindex(data::SimpleI18n.I18nData, key::VsAbstractID) = data[string(key)]
Base.getindex(data::AbstractDict{T}, key::AbstractString) where T <: VsAbstractID = data[T(key)]
Base.getindex(data::SimpleI18n.I18nData, key::EnumIDTypes) = data[enum_to_string(key)]

VsRecorderBase._parse(
    dict::OrderedDict, ::Type{Vector{AbilityID}};
    _...
) = AbilityID[search_dex(ability_list(VsI18n.EN), x) for x in values(dict)]

function initialize_dex()
    move_dex()
    poke_dex()
    nothing
end
