const TeamViewPokemonBoxRects = [
    Rect(
        (29 + 280 * (y - 1), 121 + 880 * (x - 1)),
        (264, 800),
        resolution = DesignResolution
    )
    for x in 1:2 for y in 1:3
]
const TeamViewLineHeight = 50
const TeamViewNameRect = Rect((108, 1), (TeamViewLineHeight, 410), resolution = DesignResolution)
const TeamViewAbilityRect = Rect((158, 1), (TeamViewLineHeight, 410), resolution = DesignResolution)
const TeamViewItemRect = Rect((208, 1), (TeamViewLineHeight, 410), resolution = DesignResolution)
const TeamViewMoveRects = [
    Rect((13 + 64 * (i - 1), 476), (TeamViewLineHeight, 320), resolution = DesignResolution)
    for i in 1:4
]


struct TeamView <: AbstractPokemonScene
    team::Team
end

feature_image_name(::Type{TeamView}, ::PokemonBattle) = "team-view"

should_include(::Type{TeamView}, ctx::PokemonContext) =
    !isnothing(ctx.data.context)  # should not be included when in a battle

function parse_pokemon_box(box, ctx::PokemonContext)
    poke = Pokemon()
end

parse_pokemon_box(img, i, ctx::PokemonContext) = parse_pokemon_box(img[TeamViewPokemonBoxRect[i]], ctx)

function _parse_scene(::Type{TeamView}, frame::VsFrame, ctx::PokemonContext)
    team = Team()
    for i in 1:6
        push!(team.pokemons, parse_pokemon_box(img, i, ctx))
    end
    TeamView(team)
end
