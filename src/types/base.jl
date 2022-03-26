abstract type AbstractPokemonScene <: AbstractVsScene end

const PokemonContext{T} = VsContext{T, PokemonBattle} where T <: AbstractVsStrategy

Base.@kwdef mutable struct BattleContext
    parsed_scenes::Dict{::Type{<:AbstractPokemonScene}, AbstractPokemonScene} = Dict()
    battle::Battle = Battle()
    parsed_battle::Battle = ParsedBattle()
end

Base.@kwdef mutable struct ParsingContext
    battles::Vector{Battle} = Battle[]
    parsed_battles::Vector{ParsedBattle} = ParsedBattle[]
    current::Union{BattleContext, Nothing} = nothing
end
