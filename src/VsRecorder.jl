module VsRecorder

using Artifacts, Dates

using SimpleI18n
using VsRecorderBase
using VsRecorderBase: OrderedDict

include("i18n.jl")
export PokemonID, ItemID, MoveID, AbilityID, Gender,
    poke_dex, move_dex
include("data/Data.jl")
using .Data
include("io.jl")

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
