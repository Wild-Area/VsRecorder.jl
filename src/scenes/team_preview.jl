@enum TeamPreviewArea begin
    POKEMON_ICON
    ITEM_ICON
    GENDER_ICON
    LEVEL_TEXT
    HP_TEXT
    PLAYER_NAME
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
elseif area_type ≡ HP_TEXT  # Only available for large player box
    (78, 134), (40, 200)
else  # NAME
    (1, 7), (56, 408)
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
    team_a::Vector{String}
    uncertain::Int
    team_b::Vector{String}
    genders_a::Vector{Gender}
    genders_b::Vector{Gender}
    levels_a::Vector{Int64}
    levels_b::Vector{Int64}
    items_a::Vector{String}
    hps_a::Vector{Int}
    name_a::String
    name_b::String
end

struct TeamPreviewSelecting <: AbstractPokemonScene
    # Parse this will return a `TeamPreview` struct.
end

feature_image_name(::Type{TeamPreview}, ::PokemonBattle) = "team-preview"
feature_image_name(::Type{TeamPreviewSelecting}, ::PokemonBattle) = "team-preview-selecting"

function parse_pokemon_icon(img, i, player; preprocess=(player == 3))
    icons = pokemon_icons()
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
        icon, icons,
        rect = PokemonIconSheetRect
    ), uncertain
end

function parse_item(img, i, player; preprocess=true)
    icons = item_icons()
    icon = get_area(img, i, player, ITEM_ICON)
    if preprocess
        icon = floodfill(icon, (1, 1), 1, 0.1)
    end
    table_search(
        icon, icons
    )
end

function parse_gender(img, i, player, selected=false)
    icons = gender_icons()
    icon = get_area(img, i, player, GENDER_ICON)
    if selected
        icon = floodfill(icon, (1, 1), 1, 0.1)
    end
    r = table_search(
        icon, icons
    )
    r == "null" ? GENDER_NULL : r == "male" ? GENDER_MALE : GENDER_FEMALE
end

function _parse_number(img, i, player, ctx, selected, area_type)
    text_area = get_area(img, i, player, area_type)
    if selected
        text_area = complement.(text_area)
    end
    ocr(Int, text_area, ctx; language = "eng")
end

parse_level(img, i, player, ctx, selected=false) =
    _parse_number(img, i, player, ctx, selected, LEVEL_TEXT)

parse_hp(img, i, ctx, selected=false) =
    _parse_number(img, i, 3, ctx, selected, HP_TEXT)

function parse_name(img, player, ctx; threshold = 0.35f0)
    player == 3 && return ""
    text_area = get_area(img, 1, player, PLAYER_NAME)
    text_area = prepare_text_for_ocr(text_area; threshold = threshold)
    ocr_multiple_lang(text_area, ctx)
end

# player == 1,2,3,4 for A,B,A-Selecting,B-Selecting
function parse_player(img, player, ctx)
    config = ctx.config

    parse_type = config.source.parse_type
    is_player_a = player == 1 || player == 3
    if is_player_a && parse_type ≢ PARSE_BOTH_PLAYERS
        return String[], 0, Gender[], Int64[], String[], Int64[], ""
    end

    team = Vector{String}(undef, 6)
    uncertain = Threads.Atomic{Int64}(0)
    genders = parse_type > PARSE_MINIMAL ? Vector{Gender}(undef, 6) : Gender[]
    items = is_player_a ? Vector{String}(undef, 6) : String[]
    name = ""

    Threads.@threads for i in 1:6
        poke, u = parse_pokemon_icon(img, i, player)
        if u
            uncertain[] = i
        end
        team[i] = poke
        if parse_type > PARSE_MINIMAL
            genders[i] = parse_gender(img, i, player, u)
        end
        if is_player_a
            items[i] = parse_item(img, i, player)
        end
    end
    levels = if parse_type > PARSE_MINIMAL
        Int64[
            parse_level(img, i, player, ctx, uncertain[] ≡ i)
            for i in 1:6
        ]
    else
        Int64[]
    end
    hps = if player == 3
        Int64[
            parse_hp(img, i, ctx, uncertain[] ≡ i)
            for i in 1:6
        ]
    else
        Int64[]
    end
    name = parse_name(img, player, ctx)
    return team, uncertain[], genders, levels, items, hps, name
end

function _parse_scene(::Type{TeamPreview}, frame::VsFrame, ctx::PokemonContext, a = 1, b = 2)
    data = get_current_context!(ctx).data
    if !ctx.data.force && !isnothing(data.team_preview)
        parse_type = ctx.config.source.parse_type
        if parse_type ≢ PARSE_BOTH_PLAYERS || a == 1 || data.uncertain_poke == 0
            # Already parsed everything we need
            return nothing
        end
    end
    img = image(frame)
    team_a, uncertain, genders_a, levels_a, items_a, hps_a, name_a = parse_player(img, a, ctx)
    team_b, _, genders_b, levels_b, _, _, name_b = parse_player(img, b, ctx)

    data.team_preview = true
    TeamPreview(
        frame.time,
        team_a, uncertain, team_b,
        genders_a, genders_b,
        levels_a, levels_b,
        items_a, hps_a,
        name_a, name_b
    )
end

_parse_scene(::Type{TeamPreviewSelecting}, frame::VsFrame, ctx::PokemonContext) =
    _parse_scene(TeamPreview, frame, ctx, 3, 4)

function _vs_update!(ctx::PokemonContext, scene::TeamPreview)
    parsing = get_current_context!(ctx)
    battle = parsing.battle
    parsed_battle = parsing.parsed_battle
    parse_type = ctx.config.source.parse_type

    data = parsing.data
    if parse_type ≡ PARSE_BOTH_PLAYERS
        # TODO: set uncertain
        if isnothing(data.uncertain_poke) && scene.uncertain > 0
            data.uncertain_poke = scene.uncertain
        elseif data.uncertain_poke != scene.uncertain
            data.uncertain_poke = 0
        end
        if scene.name_a != ""
            battle.player.name = scene.name_a
        end
        for (i, value) in enumerate(scene.team_a)
            i == scene.uncertain && continue
            update_team!(parsed_battle, true, i, :id, value)
        end
        for (i, value) in enumerate(scene.genders_a)
            update_team!(parsed_battle, true, i, :gender, value)
        end
        for (i, value) in enumerate(scene.levels_a)
            update_team!(parsed_battle, true, i, :level, value)
        end
        for (i, value) in enumerate(scene.items_a)
            update_team!(parsed_battle, true, i, :item, value)
        end
        for (i, value) in enumerate(scene.hps_a)
            update_team!(parsed_battle, true, i, :hp, value)
        end
    end
    if scene.name_b != ""
        battle.opponent.name = scene.name_b
    end
    battle.opponent_team = [PokemonID(x) for x in scene.team_b]
    for (i, value) in enumerate(scene.team_b)
        update_team!(parsed_battle, false, i, :id, value)
    end
    for (i, value) in enumerate(scene.genders_b)
        update_team!(parsed_battle, false, i, :gender, value)
    end
    for (i, value) in enumerate(scene.levels_b)
        update_team!(parsed_battle, false, i, :level, value)
    end
    ctx
end
