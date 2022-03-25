module VsRecorder

using Artifacts

using SimpleI18n
using VsRecorderBase

include("i18n.jl")

include("config.jl")
include("types/base.jl")
include("types/pokemon.jl")
include("types/result.jl")

include("scenes/searching.jl")

include("main.jl")

using Reexport: @reexport
@reexport using VsRecorderBase.API

function __init__()
    initialize_i18n()
    nothing
end

end # module
