abstract type AbstractPokemonScene <: AbstractVsScene end

const PokemonBattleContext{T} = VsContext{T, PokemonBattle} where T <: AbstractVsStrategy
