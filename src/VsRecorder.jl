module VsRecorder

using Artifacts, Dates

using SimpleI18n
using VsRecorderBase

include("i18n.jl")

include("config.jl")
include("types/base.jl")
include("types/player.jl")
include("types/pokemon.jl")
include("types/battle.jl")
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
