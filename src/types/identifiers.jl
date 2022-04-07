# All values will be English names so that the `yaml` files will be human-readable.
abstract type VsAbstractID{T} <: SimpleTypeWrapper{T} end
macro _id_type_wrapper(name, type, i18n_key)
    i18n_key = string(i18n_key)
    i18n_function = esc(:(get_i18n_namespace(::Type{$name}) = $i18n_key))
    quote
        @type_wrapper $name $type nothing VsAbstractID
        $i18n_function
    end
end
@_id_type_wrapper PokemonID String pokemon
@_id_type_wrapper ItemID String item
@_id_type_wrapper MoveID String move
@_id_type_wrapper AbilityID String ability
@_id_type_wrapper NatureID String nature

SimpleI18n.i18n(id::VsAbstractID; language = nothing) = get_i18n(get_i18n_namespace(typeof(id)), id, lang = language)

@enum Gender begin
    GENDER_NULL
    GENDER_MALE
    GENDER_FEMALE
end
VsRecorderBase.enum_prefix(::Type{Gender}) = "GENDER_"

const NATURE_NEUTURAL_DEFAULT = NatureID("hardy")
const NATURE_EFFECTs = Dict{String, Tuple{Symbol, Symbol}}(
    "adamant" => (:atk, :spa),
    "bold" => (:def, :atk),
    "brave" => (:atk, :spe),
    "calm" => (:spd, :atk),
    "careful" => (:spd, :spa),
    "gentle" => (:spd, :def),
    "hasty" => (:spe, :def),
    "impish" => (:def, :spa),
    "jolly" => (:spe, :spa),
    "lax" => (:def, :spd),
    "lonely" => (:atk, :def),
    "mild" => (:spa, :def),
    "modest" => (:spa, :atk),
    "naive" => (:spe, :spd),
    "naughty" => (:atk, :spd),
    "quiet" => (:spa, :spe),
    "rash" => (:spa, :spd),
    "relaxed" => (:def, :spe),
    "sassy" => (:spd, :spe),
    "timid" => (:spe, :atk),
)

function get_nature_effect(nature)
    (isnothing(nature) || ismissing(nature)) && return (nothing, nothing)
    nature = lowercase(string(nature))
    get(NATURE_EFFECTs, nature, (nothing, nothing))
end

function get_nature(up, down)
    for (k, v) in NATURE_EFFECTs
        if v == (up, down)
            return NatureID(k)
        end
    end
    NATURE_NEUTURAL_DEFAULT
end

