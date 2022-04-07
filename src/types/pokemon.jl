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
    name::String
    moves::Vector{MoveID} = MoveID[]
    gender::Gender
    level::Int64
    item::ItemID
    stats::Stats
    ability::AbilityID
    nature::NatureID
    shiny::Bool
    sent_out::Bool = false
    dynamaxed::Bool = false
end

@missable mutable struct Team
    title::String
    author::String
    notes::String
    rental_code::String
    pokemons::Vector{Pokemon} = Pokemon[]
end

function update_team!(team::Team, i, field, value)
    pokes = team.pokemons
    if length(pokes) ≡ 0
        for _ in 1:6
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
