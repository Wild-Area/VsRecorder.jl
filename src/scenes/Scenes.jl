module Scenes

using VsRecorderBase
using VsRecorderBase: @forward
using ..VsRecorder: AbstractPokemonScene,
    PokemonBattle, PokemonContext, BattleContext,
    PokemonID, Gender,
    Player,
    update_team!,
    BattleEnums, Battle, ParsedBattle,
    default_context,
    PARSE_NONE, PARSE_MINIMAL, PARSE_OPPONENT, PARSE_BOTH_PLAYERS
using ..Data

include("common.jl")
include("searching.jl")
include("team_preview.jl")

const AvailableScenes = Type[
    Searching,
    TeamPreview, TeamPreviewSelecting
]

end
