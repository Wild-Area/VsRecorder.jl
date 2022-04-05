module Data

using Artifacts
using VsRecorderBase
using VsRecorderBase: OrderedDict

import SimpleI18n
import ..VsRecorder: get_i18n

include("utils.jl")

export PokemonID, ItemID, MoveID, AbilityID, Gender, PokemonType
export poke_dex, move_dex
include("dex.jl")

export pokemon_icons, item_icons, gender_icons
include("icon_sheets.jl")

function __init__()
    poke_dex()
    move_dex()
    pokemon_icons()
    item_icons()
    gender_icons()
    nothing
end

end
