# Using mutable to allow missing values

# All values will be English names so that the `yaml` files will be human-readable.
@type_wrapper PokemonID String
@type_wrapper ItemID String
@type_wrapper MoveID String
@type_wrapper AbilityID String
const Gender = Union{Nothing, Bool}

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

get_name(id::PokemonID) = i18n(GlobalI18nContext[], "pokemon.$(id)")

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
