module Data

using Artifacts
using VsRecorderBase: deserialize, OrderedDict
import ..VsRecorder
using ..VsRecorder: PokemonID, DexPokemon

const PokemonIconSheet = joinpath(artifact"data", "sprites", "swsh-pokemon-icons.png")
const ItemIconSheet = joinpath(artifact"data", "sprites", "swsh-item-icons.png")
const GenderIconSheet = joinpath(artifact"data", "sprites", "gender-icons.png")
const PokeDexFile = joinpath(artifact"data", "dex", "pokedex.yaml")

const Dex = VsRecorder.Dex()

function initialize_dex(force = false)
    if !force && length(Dex.poke_dex) > 0
        return Dex
    end
    empty!(Dex.poke_dex)
    poke_dex = open(PokeDexFile) do fi
        deserialize(fi, OrderedDict{PokemonID, DexPokemon}, other_key = :other_data)
    end
    merge!(Dex.poke_dex, poke_dex)
    Dex
end

end
