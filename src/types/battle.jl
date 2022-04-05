# Using mutable to allow missing values
@missable mutable struct Player
    name::String
    rating::String
end

@missable mutable struct Stats
    hp::Int
    attack::Int
    defense::Int
    special_attack::Int
    special_defense::Int
    speed::Int
end

@missable mutable struct Pokemon
    id::PokemonID
    moves::Vector{MoveID} = MoveID[]
    gender::Gender
    level::Int64
    item::ItemID
    stats::Stats
    ability::AbilityID
    sent_out::Bool = false
    dynamaxed::Bool = false
end

@missable mutable struct Team
    name::String
    description::String
    pokemons::Vector{Pokemon} = Pokemon[]
end

function update_team!(team::Team, i, field, value)
    pokes = team.pokemons
    if length(pokes) ≡ 0
        for _ ∈ 1:6
            push!(pokes, Pokemon())
        end
    end
    poke = pokes[i]
    if field ≡ :moves
        moves = poke.moves
        if !contains(moves, value)
            push!(moves, value)
        end
    elseif field ∈ (:hp, :attack, :defense, :special_attack, :special_defense, :speed)
        if ismissing(poke.stats)
            poke.stats = Stats()
        end
        setfield!(poke.stats, field, value)
    else
        setfield!(poke, field, value)
    end
    team
end

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
