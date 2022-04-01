@enum TeamPreviewArea begin
    POKEMON_ICON
    ITEM_ICON
    GENDER_ICON
    LEVEL_TEXT
    HP_TEXT
end

const PokemonIconSheetRect = Rect((13, 1), (100, 132))
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
const TeamPreviewBoxHeight = 120
const TeamPreviewSelectingBoxHeight = 144

# (top, left), (height, width), (top_selecting, left_selecting), (height_selecting, width_selecting)
_get_team_preview_rect_starting(area_type, is_small_box) = if area_type ≡ POKEMON_ICON
    if is_small_box
        (64, 8), (100, 132)
    else
        (14, 2), (100, 132)
    end
elseif area_type ≡ ITEM_ICON
    if is_small_box
        (117, 355), (48, 48)
    else
        (11, 596), (48, 48)
    end
elseif area_type ≡ GENDER_ICON
    if is_small_box
        (116, 268), (50, 50)
    else
        (10, 419), (50, 50)
    end
elseif area_type ≡ LEVEL_TEXT
    if is_small_box
        (119, 143), (46, 120)
    else
        (73, 396), (56, 168)
    end
else # HP. Only available for large player box
    (78, 134), (40, 200)
end

function get_area(img, i, player, area_type::TeamPreviewArea)
    box = img[TeamPreviewPlayerBoxRects[player]]
    is_small_box = player ≠ 3
    (top, left), size = _get_team_preview_rect_starting(area_type, is_small_box)
    box_height = is_small_box ? TeamPreviewBoxHeight : TeamPreviewSelectingBoxHeight
    rect = Rect((top + (i - 1) * box_height, left), size, resolution = DesignResolution)
    box[rect]
end

struct TeamPreview <: AbstractPokemonScene
    frame_time::Float64
    team_a::Vector{PokemonID}
    uncertain::Int
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

function parse_pokemon_icon(img, i, player, pokemon_icons; σ = 0.5, preprocess=(player == 3))
    icon = get_area(img, i, player, POKEMON_ICON)
    uncertain = if preprocess
        h, w = size(icon)
        rect = icon.rect
        rh, rw = rect.height, rect.width
        icon = floodfill(icon, (1, 1), 1, 0.1)
        uncertain = Gray(icon[1, w]) < 0.02
        floodfill!(icon, (100 * h ÷ rh, 10 * w ÷ rw), 1, 0.1)
        floodfill!(icon, (1, w), 1, 0.1)
        uncertain
    else
        false
    end
    table_search(
        icon, pokemon_icons,
        rect = PokemonIconSheetRect,
        σ = σ
    ), uncertain
end

function parse_item(img, i, player, item_icons; σ = 0.0, preprocess=(player == 3))
    icon = get_area(img, i, player, ITEM_ICON)
    if preprocess
        icon = floodfill(icon, (1, 1), 1, 0.1)
    end
    table_search(
        icon, item_icons,
        σ = σ
    )
end

function parse_gender(img, i, player, gender_icons, selected=false)
    icon = get_area(img, i, player, GENDER_ICON)
    if selected
        icon = floodfill(icon, (1, 1), 1, 0.1)
    end
    r = table_search(
        icon, gender_icons,
        σ = 0.0
    )
    r === "null" ? nothing : r === "male"
end

function _parse_number(img, i, player, ctx, selected, area_type)
    text_area = get_area(img, i, player, area_type)
    if selected
        text_area = complement(text_area)
    end
    text = parse_text(text_area, ctx)
    m = match(r"\d+", text)
    isnothing(m) ? 0 : parse(Int, m.match)
end

parse_level(img, i, player, ctx, selected=false) =
    _parse_number(img, i, player, ctx, selected, LEVEL_TEXT)

parse_hp(img, i, ctx, selected=false) =
    _parse_number(img, i, 3, ctx, selected, HP_TEXT)

function initialize_scene!(ctx::PokemonContext, ::Type{TeamPreview})
    data = ctx.data
    gray = ctx.config.use_gray_image
    # Prepare sheets
    data.pokemon_icons = SpriteSheet(Data.PokemonIconSheet, gray = gray)
    data.item_icons = SpriteSheet(Data.ItemIconSheet, gray = gray)
    data.gender_icons = SpriteSheet(Data.GenderIconSheet, gray = gray)
end

# player == 1,2,3,4 for A,B,A-Selecting,B-Selecting
function parse_player(img, player, ctx)
    data = ctx.data
    gray = ctx.config.use_gray_image
    if isnothing(data.pokemon_icons)
        initialize_scene!(ctx, TeamPreview)
    end
    pokemon_icons = data.pokemon_icons
    item_icons = data.item_icons
    gender_icons = data.gender_icons

    team = Vector{PokemonID}(undef, 6)
    genders = Vector{Nullable{Bool}}(undef, 6)
    levels = Vector{Int64}(undef, 6)
    items = Vector{String}()
    hps = Vector{Int64}()
    uncertain = 0
    for i in 1:6
        team[i], u = parse_pokemon_icon(
            img, i, player,
            pokemon_icons,
            σ = gray ? 0.5 : 0.0
        )
        if u
            uncertain = i
        end
        genders[i] = parse_gender(img, i, player, gender_icons, u)
        levels[i] = parse_level(img, i, player, ctx, u)
        if player == 3
            push!(items, parse_item(img, i, player, item_icons))
            push!(hps, parse_hp(img, i, ctx, u))
        end
    end
    return team, uncertain, genders, levels, items, hps
end

function _parse_scene(::Type{TeamPreview}, frame::VsFrame, ctx::PokemonContext, a = 1, b = 2)
    img = image(frame)
    source = ctx.config.source
    team_a, uncertain, genders_a, levels_a, items_a, hps_a = if source.parse_player_a
        parse_player(img, a, ctx)
    else
        [], [], [], [], []
    end
    team_b, _, genders_b, levels_b, _, _ = parse_player(img, b, ctx)

    TeamPreview(
        frame.time,
        team_a, uncertain, team_b,
        genders_a, genders_b,
        levels_a, levels_b,
        items_a, hps_a
    )
end

_parse_scene(::Type{TeamPreviewSelecting}, frame::VsFrame, ctx::PokemonContext) =
    _parse_scene(TeamPreview, frame, ctx, 3, 4)

