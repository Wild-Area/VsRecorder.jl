# All values will be English names so that the `yaml` files will be human-readable.
@type_wrapper PokemonID String
@type_wrapper ItemID String
@type_wrapper MoveID String
@type_wrapper AbilityID String
@type_wrapper NatureID String
@type_wrapper Gender Union{Nothing, Bool}

SimpleI18n.i18n(id::PokemonID; language = nothing) = get_i18n("pokemon", id, lang = language)
SimpleI18n.i18n(id::ItemID; language = nothing) = get_i18n("item", id, lang = language)
SimpleI18n.i18n(id::MoveID; language = nothing) = get_i18n("move", id, lang = language)
SimpleI18n.i18n(id::AbilityID; language = nothing) = get_i18n("ability", id, lang = language)
SimpleI18n.i18n(id::NatureID; language = nothing) = get_i18n("nature", id, lang = language)

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
    nature = string(nature)
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

