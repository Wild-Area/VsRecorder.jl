const TeamPreviewIconSheetRect = ((14, 1), (43, 68))


struct TeamPreview <: AbstractPokemonScene
    frame_time::Float64
    team_a::Vector{PokemonID}
    team_b::Vector{PokemonID}
    genders_a::Vector{Union{Nothing, Bool}}
    genders_b::Vector{Union{Nothing, Bool}}
    levels_a::Vector{Int64}
    levels_b::Vector{Int64}
    items_a::Vector{PokemonID}
end

struct TeamPreviewSelecting <: AbstractPokemonScene
    frame_time::Float64
    team::Vector{PokemonID}
    genders::Vector{Union{Nothing, Bool}}
    levels::Vector{Int64}
    items::Vector{PokemonID}
    hps::Vector{PokemonID}
end

feature_image_name(::Type{TeamPreview}, ::PokemonBattle) = "team-preview"
feature_image_name(::Type{TeamPreviewSelecting}, ::PokemonBattle) = "team-preview-selecting"

still_available(::Union{TeamPreview, TeamPreviewSelecting}, ::PokemonContext) = true

function parse_pokemon_icon(img, i, player, pokemon_icons)
    # TODO
    i = table_search(
        template, pokemon_icons.image,
        block_size = pokemon_icons.block_size,
        rect = TeamPreviewIconSheetRect,
        range = 1:length(pokemon_icons),
        σ = 0.0
    )
    pokemon_icons[i]
end

# player == 1,2,3 for A,B,A(Selecting)
function parse_player(img, player, ctx)
    data = ctx.data
    if isnothing(data.pokemon_icons)
        data.pokemon_icons = SpriteSheet(Data.PokemonIconSheet, gray = ctx.config.use_gray_image)
    end
    pokemon_icons = data.pokemon_icons
    team = [parse_pokemon_icon(img, i, player, pokemon_icons) for i in 1:6]
    return team, [], [], []
end

function _parse_scene(::Type{TeamPreview}, frame::VsFrame, ctx::PokemonContext)
    img = image(frame)
    source = ctx.config.source
    team_a, genders_a, levels_a, items_a = if source.parse_player_a
        parse_player(img, 1, ctx)
    else
        [], [], [], []
    end
    team_b, genders_b, levels_b, _ = parse_player(img, 2, ctx)

    TeamPreview(
        frame.time,
        team_a, team_b,
        genders_a, genders_b,
        levels_a, levels_b,
        items_a
    )
end
