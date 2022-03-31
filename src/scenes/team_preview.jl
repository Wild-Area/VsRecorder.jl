const TeamPreviewIconSheetRect = Rect((13, 1), (100, 136))
const TeamPreviewPlayerBoxRects = [
    # Team A
    Rect((125, 301), (784, 422), resolution = DesignResolution),
    # Team B
    Rect((125, 1201), (784, 422), resolution = DesignResolution),
    # Team A when selecting
    Rect((45, 656), (848, 650), resolution = DesignResolution),
    # Team B when selecting
    Rect((191, 103), (784, 422), resolution = DesignResolution),
]
const TeamPreviewPokemonIconRects = [
    Rect((64 + 120 * (i - 1), 8), (100, 136), resolution = DesignResolution)
    for i in 1:6
]
const TeamPreviewSelectingPokemonIconRects = [
    Rect((14 + 144 * (i - 1), 2), (100, 136), resolution = DesignResolution)
    for i in 1:6
]

struct TeamPreview <: AbstractPokemonScene
    frame_time::Float64
    team_a::Vector{PokemonID}
    team_b::Vector{PokemonID}
    genders_a::Vector{Gender}
    genders_b::Vector{Gender}
    levels_a::Vector{Int64}
    levels_b::Vector{Int64}
    items_a::Vector{String}
    hps_a::Vector{Int}
end

struct TeamPreviewSelecting <: AbstractPokemonScene
    # Parse this will return a `TeamPreview` struct.
end

feature_image_name(::Type{TeamPreview}, ::PokemonBattle) = "team-preview"
feature_image_name(::Type{TeamPreviewSelecting}, ::PokemonBattle) = "team-preview-selecting"

still_available(::Union{TeamPreview, TeamPreviewSelecting}, ::PokemonContext) = true

function get_pokemon_icon(img, i, player)
    box = img[TeamPreviewPlayerBoxRects[player]]
    box[
        (player == 3 ? TeamPreviewSelectingPokemonIconRects : TeamPreviewPokemonIconRects)[i]
    ]
end

function parse_pokemon_icon(img, i, player, pokemon_icons, σ = 0.5)
    template = get_pokemon_icon(img, i, player)
    table_search(
        template, pokemon_icons,
        rect = TeamPreviewIconSheetRect,
        σ = σ
    )
end

# player == 1,2,3,4 for A,B,A-Selecting,B-Selecting
function parse_player(img, player, ctx)
    data = ctx.data
    gray = ctx.config.use_gray_image
    if isnothing(data.pokemon_icons)
        data.pokemon_icons = SpriteSheet(Data.PokemonIconSheet, gray = gray)
    end
    pokemon_icons = data.pokemon_icons
    team = [
        parse_pokemon_icon(
            img, i, player,
            pokemon_icons,
            gray ? 0.5 : 0.0
        ) for i in 1:6
    ]
    return team, [], [], [], []
end

function _parse_scene(::Type{TeamPreview}, frame::VsFrame, ctx::PokemonContext, a = 1, b = 2)
    img = image(frame)
    source = ctx.config.source
    team_a, genders_a, levels_a, items_a, hps_a = if source.parse_player_a
        parse_player(img, a, ctx)
    else
        [], [], [], [], []
    end
    team_b, genders_b, levels_b, _, _ = parse_player(img, b, ctx)

    TeamPreview(
        frame.time,
        team_a, team_b,
        genders_a, genders_b,
        levels_a, levels_b,
        items_a, hps_a
    )
end

_parse_scene(::Type{TeamPreviewSelecting}, frame::VsFrame, ctx::PokemonContext) =
    _parse_scene(TeamPreview, frame, ctx, 3, 4)

