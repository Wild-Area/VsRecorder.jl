module BattleEnums

@enum BattleFormat begin
    Single
    Double
    # TODO: Including different rules?
end

@enum BattleEvent begin
    Beginning

    Switch              # [true/false for in/out, pokemon]
    Ability             # [pokemon, ability]
    AbilityEffect       # [effect]
    StatsChange         # [stat_type, value]
    UseMove             # [pokemon, move]
    CheckEffective      # [0/1/2/3 for no/not very/neutral/very effective]
    HPChange            # [pokemon, old, new]
    Miss                # [pokemon]
    CriticalHit         # no arg
    MoveEffect          # [effect]
    Faint               # [pokemon]
    EnvironmentEffect   # [effect]
    Dynamax             # [pokemon]
    Forfeit             # [true/false for player/opponent]

    Ending              # [0/1/2 for win/tie/loss]
end

end

@missable mutable struct Event
    id::Int64
    turn::Int64
    type::BattleEnums.BasttleEvent
    arg::Any
end

@missable mutable struct Battle
    format::BattleEnums.BattleFormat
    opponent::Player
    opponent_team::Team
    events::Vector{Event} = Event[]
end
