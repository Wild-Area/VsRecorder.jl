@nullable mutable struct BattleContext
    battle::Battle = Battle()
    parsed_battle::ParsedBattle
    data::VsContextData = VsContextData()
end

@nullable mutable struct ParsingContext
    battles::Vector{Battle} = Battle[]
    parsed_battles::Vector{ParsedBattle} = ParsedBattle[]
    current::BattleContext
end