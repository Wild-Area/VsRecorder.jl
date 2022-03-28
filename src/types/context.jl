@nullable mutable struct BattleContext
    parsed_scenes::Dict{Type{<:AbstractPokemonScene}, AbstractPokemonScene} = Dict()
    battle::Battle = Battle()
    parsed_battle::Battle = ParsedBattle()
end

@nullable mutable struct ParsingContext
    battles::Vector{Battle} = Battle[]
    parsed_battles::Vector{ParsedBattle} = ParsedBattle[]
    current::BattleContext
end