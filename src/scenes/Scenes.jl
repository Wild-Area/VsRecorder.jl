module Scenes

using VsRecorderBase
using ..VsRecorder
using ..VsRecorder: AbstractPokemonScene,
    PokemonContext, BattleContext,
    update_team!,
    default_context,
    ParseType,
    PARSE_NONE, PARSE_MINIMAL, PARSE_OPPONENT, PARSE_BOTH_PLAYERS
using ..Data

include("common.jl")
include("searching.jl")
include("team_preview.jl")
include("battle_main.jl")
include("team_view.jl")

const AvailableScenes = Type[
    Searching,
    TeamPreview, TeamPreviewSelecting,
    BattleMain,
    TeamView,
]

end
