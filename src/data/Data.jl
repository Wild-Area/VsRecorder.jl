module Data

using Artifacts
using VsRecorderBase
using VsRecorderBase: OrderedDict

import SimpleI18n
import ..VsRecorder
using ..VsRecorder: Stats, Pokemon, Team,
    PokemonID, ItemID, MoveID, AbilityID, Gender
    
include("utils.jl")

export PokemonType
export poke_dex, move_dex, item_dex, ability_dex
include("dex.jl")

export pokemon_icons, item_icons, gender_icons
include("icon_sheets.jl")

export import_team, export_team
include("poke_pastes.jl")

function __init__()
    initialize_dex()
    nothing
end

end
