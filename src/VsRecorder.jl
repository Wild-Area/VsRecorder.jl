module VsRecorder

using Artifacts, Dates

using SimpleI18n
using VsRecorderBase
import Tesseract

include("io.jl")
export VsI18n
include("i18n.jl")
using .VsI18n

export PokemonBattle,
    PARSE_NONE, PARSE_MINIMAL, PARSE_OPPONENT, PARSE_BOTH_PLAYERS
include("config.jl")
include("types/base.jl")

export PokemonID, ItemID, MoveID, AbilityID, Nature,
    PokemonType,
    Gender, GENDER_NULL, GENDER_MALE, GENDER_FEMALE
include("types/identifiers.jl")
export Player, Stats, Pokemon, Team
include("types/pokemon.jl")

export poke_dex, move_dex,
    item_list, ability_list, poke_list, move_list,
    import_team, export_team
include("data/Data.jl")
using .Data

export BattleEnums, Battle, ParsedBattle
include("types/battle.jl")
include("types/context.jl")
include("types/result.jl")

include("scenes/Scenes.jl")

include("main.jl")

using Reexport: @reexport
@reexport using VsRecorderBase.API

end # module
