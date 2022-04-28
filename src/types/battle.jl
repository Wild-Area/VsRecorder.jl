module BattleEnums

@enum BattleFormat begin
    SINGLE
    DOUBLE
    # TODO: Include different rules?
end

@enum BattleResult begin
    WIN
    LOSE
    TIE
end

end

@missable mutable struct Event
    id::Int64
    turn::Int64
    # types are defined in `battle.yaml`
    type::String
    args::Vector{String}
end

@missable mutable struct Battle
    format::BattleEnums.BattleFormat
    player::Player = Player()
    opponent::Player = Player()
    opponent_team::Vector{PokemonID}
    events::Vector{Event} = Event[]
end

# Parsed Data from events
@missable mutable struct ParsedBattle
    result::BattleEnums.BattleResult
    team_a::Team
    team_b::Team
end

update_team!(::Missing, _...) = missing
function update_team!(battle::ParsedBattle, is_team_a::Bool, args...)
    if is_team_a
        if ismissing(battle.team_a)
            battle.team_a = Team()
        end
        update_team!(battle.team_a, args...)
    else
        if ismissing(battle.team_b)
            battle.team_b = Team()
        end
        update_team!(battle.team_b, args...)
    end
    battle
end
