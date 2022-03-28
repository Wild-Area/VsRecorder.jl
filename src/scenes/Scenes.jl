module Scenes

using VsRecorderBase
using ..VsRecorder: AbstractPokemonScene,
    PokemonBattle, PokemonContext, BattleContext, PokemonID,
    Battle, ParsedBattle
using ..Data

include("common.jl")
include("searching.jl")
include("team_preview.jl")

const AvailableScenes = Type[
    Searching,
    TeamPreview, TeamPreviewSelecting
]

end
