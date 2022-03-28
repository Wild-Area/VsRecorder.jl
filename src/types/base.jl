abstract type AbstractPokemonScene <: AbstractVsScene end

const PokemonContext{T} = VsContext{T, PokemonBattle} where T <: AbstractVsStrategy
