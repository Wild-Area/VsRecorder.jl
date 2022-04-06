# All values will be English names so that the `yaml` files will be human-readable.
@type_wrapper PokemonID String
@type_wrapper ItemID String
@type_wrapper MoveID String
@type_wrapper AbilityID String
@type_wrapper Gender Union{Nothing, Bool}

SimpleI18n.i18n(id::PokemonID; language = nothing) = get_i18n("pokemon", id, lang = language)
SimpleI18n.i18n(id::ItemID; language = nothing) = get_i18n("item", id, lang = language)
SimpleI18n.i18n(id::MoveID; language = nothing) = get_i18n("move", id, lang = language)
SimpleI18n.i18n(id::AbilityID; language = nothing) = get_i18n("ability", id, lang = language)

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
    shiny::Bool
    sent_out::Bool = false
    dynamaxed::Bool = false
end

@missable mutable struct Team
    title::String
    author::String
    notes::String
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
