module BattleEnums

@enum BattleFormat begin
    SINGLE
    DOUBLE
    # TODO: Including different rules?
end

@enum BattleEvent begin
    BEGINNING

    SWITCH              # [true/false for in/out, pokemon]
    ABILITY             # [pokemon, ability]
    ABILITY_EFFECT      # [effect]
    STATS_CHANGE        # [stat_type, value]
    USE_MOVE            # [pokemon, move]
    CHECK_EFFECTIVE     # [0/1/2/3 for no/not very/neutral/very effective]
    HP_CHANGE           # [pokemon, old, new] Note that old/new can be percentages (in float numbers).
    MISS                # [pokemon]
    CRITICAL_HIT        # no arg
    MOVE_EFFECT         # [effect]
    FAINT               # [pokemon]
    ENVIRONMENT_EFFECT  # [effect]
    DYNAMAX             # [pokemon]
    FORFEIT             # [true/false for player/opponent]

    UNKNOWN             # [raw_text]

    ENDING              # [0/1/2 for win/tie/loss]
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
    type::BattleEnums.BattleEvent = BattleEnums.UNKNOWN
    arg::Any
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
