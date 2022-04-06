module VsRecorder

using Artifacts, Dates

using SimpleI18n
using VsRecorderBase
using VsRecorderBase: OrderedDict

include("i18n.jl")
include("io.jl")

export PokemonID, ItemID, MoveID, AbilityID, NatureID, Gender
include("types/identifiers.jl")
include("types/pokemon.jl")

export poke_dex, move_dex,
    import_team, export_team
include("data/Data.jl")
using .Data

export PokemonBattle
include("config.jl")
include("types/base.jl")
include("types/battle.jl")
include("types/context.jl")
include("types/result.jl")

include("scenes/Scenes.jl")

include("main.jl")

using Reexport: @reexport
@reexport using VsRecorderBase.API

function __init__()
    initialize_i18n()
    nothing
end

end # module
