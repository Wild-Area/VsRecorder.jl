Base.@kwdef struct PokemonBattleResult
    battles::Vector{Battle}
    parsed_battles::Vector{ParsedBattle}
end
