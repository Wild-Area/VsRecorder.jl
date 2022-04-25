# All values will be English names so that the `yaml` files will be human-readable.
abstract type VsAbstractID{T} <: SimpleTypeWrapper{T} end
macro _id_type_wrapper(name, i18n_key)
    i18n_key = string(i18n_key)
    convert_functions = esc(quote
        $name(id::String) = $name(Symbol(id))
        Base.convert(::Type{$name}, id::String) = $name(id)
    end)
    i18n_function = esc(:(get_i18n_namespace(::Type{$name}) = $i18n_key))
    quote
        @type_wrapper $name Symbol nothing VsAbstractID
        $convert_functions
        $i18n_function
    end
end
@_id_type_wrapper PokemonID pokemon
@_id_type_wrapper ItemID item
@_id_type_wrapper MoveID move
@_id_type_wrapper AbilityID ability

SimpleI18n.i18n(id::VsAbstractID; language = nothing) = get_i18n(get_i18n_namespace(typeof(id)), id, lang = language)

@enum Gender begin
    GENDER_NULL
    GENDER_MALE
    GENDER_FEMALE
end
VsRecorderBase.enum_prefix(::Type{Gender}) = "GENDER_"

@enum PokemonType begin
    TYPE_BIRD = 0
    TYPE_NORMAL
    TYPE_FIGHTING
    TYPE_FLYING
    TYPE_POISON
    TYPE_GROUND
    TYPE_ROCK
    TYPE_BUG
    TYPE_GHOST
    TYPE_STEEL
    TYPE_FIRE
    TYPE_WATER
    TYPE_GRASS
    TYPE_ELECTRIC
    TYPE_PSYCHIC
    TYPE_ICE
    TYPE_DRAGON
    TYPE_DARK
    TYPE_FAIRY
end
VsRecorderBase.enum_prefix(::Type{PokemonType}) = "TYPE_"

const STATS_FIELDS = (:hp, :attack, :defense, :special_attack, :special_defense, :speed)
const DEX_STATS_FIELDS = (:hp, :atk, :def, :spa, :spd, :spe)

@enum Nature begin
    NATURE_HARDY = 0
    NATURE_LONELY
    NATURE_ADAMANT
    NATURE_NAUGHTY
    NATURE_BRAVE
    NATURE_BOLD
    NATURE_DOCILE
    NATURE_IMPISH
    NATURE_LAX
    NATURE_RELAXED
    NATURE_MODEST
    NATURE_MILD
    NATURE_BASHFUL
    NATURE_RASH
    NATURE_QUIET
    NATURE_CALM
    NATURE_GENTLE
    NATURE_CAREFUL
    NATURE_QUIRKY
    NATURE_SASSY
    NATURE_TIMID
    NATURE_HASTY
    NATURE_JOLLY
    NATURE_NAIVE
    NATURE_SERIOUS
end
VsRecorderBase.enum_prefix(::Type{Nature}) = "NATURE_"
Nature(s::AbstractString) = enum_from_string(s, Nature)
SimpleI18n.i18n(id::Nature; language = nothing) = get_i18n("nature", enum_to_string(id), lang = language)

const EnumIDTypes = Union{PokemonType, Nature}

const NATURE_NEUTURAL_DEFAULT = NATURE_HARDY
function get_nature_effect(nature::Nature)
    up, down = divrem(Int64(nature), 5)
    up ≡ down && return (nothing, nothing)
    (DEX_STATS_FIELDS[up + 1], DEX_STATS_FIELDS[down + 1])
end
get_nature_effect(::Missing) = (nothing, nothing)

function get_nature(up, down)
    a = findfirst(==(up), DEX_STATS_FIELDS)
    b = findfirst(==(down), DEX_STATS_FIELDS)
    a ≡ b && return NATURE_NEUTURAL_DEFAULT
    Nature((a - 1) * 5 + (b - 1))
end
