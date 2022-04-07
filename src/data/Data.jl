module Data

using Artifacts
using VsRecorderBase
using VsRecorderBase: OrderedDict

import SimpleI18n
using SimpleI18n: i18n
import ..VsRecorder
using ..VsRecorder: Stats, Pokemon, Team,
    VsAbstractID,
    PokemonID, ItemID, MoveID, AbilityID, NatureID,
    Gender, GENDER_NULL, GENDER_MALE, GENDER_FEMALE,
    PokemonBattle, PokemonContext,
    datapath
using ..VsI18n

include("utils.jl")

export PokemonType
export poke_dex, move_dex,
    item_list, ability_list, poke_list, move_list,
    search_dex
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
