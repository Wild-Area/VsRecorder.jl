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
const TeamViewAuthorRect = Rect((877, 512), (64, 334), resolution = DesignResolution)
const TeamViewTitleRect = Rect((877, 875), (64, 535), resolution = DesignResolution)
const TeamViewRentalCodeRect = Rect((941, 820), (64, 560), resolution = DesignResolution)
const TeamViewMoveTypeRects = [
    Rect((5 + 64 * (i - 1), 414), (64, 64), resolution = DesignResolution)
    for i in 1:4
]
const TypeIconSheetRect = Rect((8, 8), (49, 49))


struct TeamView <: AbstractPokemonScene
    team::Team
end

feature_image_name(::Type{TeamView}, ::PokemonBattle) = "team-view"

should_include(::Type{TeamView}, ctx::PokemonContext) =
    !isnothing(ctx.data.context)  # should not be included when in a battle

function _get_resized_gender_icons(ctx, height)
    data = ctx.data
    icons, icon_masks = if !isnothing(data.resized_gender_icons)
        data.resized_gender_icons, data.resized_gender_icon_masks
    else
        sheet = gender_icons()
        icons = [block(sheet, i) for i in 2:3]
        icon_masks = [block(sheet.mask, i, sheet.table_size, sheet.block_size) for i in 2:3]
        icons, icon_masks
    end
    h, w = size(icons[1])  # (50, 50)
    if h != height
        new_size = height, w * line_h ÷ h
        icons = [imresize(icon, new_size) for icon in icons]
        icon_masks = [imresize(mask, new_size) for mask in icon_masks]
        data.resized_gender_icons = icons
        data.resized_gender_icon_masks = icon_masks
    end
    icons, icon_masks
end

function parse_gender(line, ctx::PokemonContext)
    line_h, line_w = size(line)
    icons, icon_masks = _get_resized_gender_icons(ctx, line_h)
    ch = line_h ÷ 2
    indices = (ch:ch, 1:line_w)
    (female_pos, female_dist), (male_pos, male_dist) = (
        template_match(
            icon, line;
            indices = indices,
            σ = 0,
            mask = mask
        )
        for (icon, mask) in zip(icons, icon_masks)
    )
    r = female_dist / male_dist  # Use the ratio to determine if one is dominant.
    w = size(icons[1], 2)
    if r > 10
        GENDER_MALE, male_pos ± w ÷ 2
    elseif r < 0.1
        GENDER_FEMALE, female_pos ± w ÷ 2
    else
        GENDER_NULL, 0:0
    end
end

function parse_name_level(line, gender_pos, ctx::PokemonContext)
    plist = poke_list(ctx)
    pid, level = if length(gender_pos) > 0  # has gender
        len = length(gender_pos)
        gender_start, gender_end = first(gender_pos) + len ÷ 10, last(gender_pos) - len ÷ 10
        name_box = prepare_text_for_ocr(@view line[:, 1:gender_start - 1])
        level_box = prepare_text_for_ocr(@view line[:, gender_end + 1:end])
        # TODO: Check if these are needed
        # pids = data_search_n(plist, name; n = 5)
        # dist1, id1 = pids[1]
        # dist1 < 2 && return id1, 50
        name = ocr(name_box, ctx)
        level = ocr(Int, level_box, ctx; language = "eng")
        data_search(plist, name), level
    else
        name_box = prepare_text_for_ocr(line)
        name = ocr(name_box, ctx)
        m = match(r"^(.+)Lv(.+)$", name)
        name, level_string = if isnothing(m)
            name, name
        else
            m.captures[1], m.captures[2]
        end
        data_search(plist, name), parse_int(level_string)
    end
    PokemonID(pid), level
end

function parse_name_line(box, ctx::PokemonContext)
    # id, gender, level
    line = box[TeamViewNameRect]
    gender, gender_pos = parse_gender(line, ctx)
    id, level = parse_name_level(line, gender_pos, ctx)
    id, gender, level
end

function _parse_simple_line(::Type{T}, line, dex, ctx) where T
    line = prepare_text_for_ocr(line)
    text = ocr(line, ctx)
    data_search(dex, text) |> T
end

function parse_ability_line(box, ctx::PokemonContext; poke_id = missing)
    alist = ability_list(ctx)
    if !ismissing(poke_id)
        dex = poke_dex()
        dex_poke = dex[poke_id]
        abilities = dex_poke.abilities
        length(abilities) == 1 && return abilities[1]
        alist = Dict{AbilityID, String}(
            ability => alist[ability]
            for ability in abilities
        )
    end
    _parse_simple_line(AbilityID, box[TeamViewAbilityRect], alist, ctx)
end

parse_item_line(box, ctx::PokemonContext) =
    _parse_simple_line(ItemID, box[TeamViewItemRect], item_list(ctx), ctx)

function get_move_with_type(moves, box, i, ctx::PokemonContext)
    moves = MoveID.(moves)
    icons = type_icons()
    icon = box[TeamViewMoveTypeRects[i]]
    t = table_search(
        icon, icons,
        rect = TypeIconSheetRect
    )
    t = enum_from_string(t, PokemonType)
    mdex = move_dex()
    for move in moves
        mdex[move].type == t && return move
    end
    moves[1]
end

function parse_move_line(box, i, ctx::PokemonContext)
    line = box[TeamViewMoveRects[i]]
    line = Gray.(line)
    # TODO: check if this threshold is OK
    Float32(stdmult(⊙, line)) < 0.05f0 && return missing
    mlist = move_list(ctx)
    text = ocr(line, ctx)
    dists = data_search_n(mlist, text, n = 5)
    dists = [x for x in dists if x[1] == dists[1][1]]
    move = if length(dists) == 1
        MoveID(dists[1][2])
    else
        moves = [x[2] for x in dists]
        get_move_with_type(moves, box, i, ctx::PokemonContext)
    end
end

function parse_moves(box, ctx::PokemonContext)
    moves = MoveID[]
    for i in 1:4
        move = parse_move_line(box, i, ctx)
        ismissing(move) && break
        push!(moves, move)
    end
    moves
end

function parse_pokemon_box(box, ctx::PokemonContext)
    poke = Pokemon()
    poke.id, poke.gender, poke.level = parse_name_line(box, ctx)
    poke.ability = parse_ability_line(box, ctx; poke_id = poke.id)
    poke.item = parse_item_line(box, ctx)
    poke.moves = parse_moves(box, ctx)
    poke
end

parse_pokemon_box(img, i, ctx::PokemonContext) = parse_pokemon_box(img[TeamViewPokemonBoxRects[i]], ctx)

parse_author(img, ctx::PokemonContext) = ocr_multiple_lang(prepare_text_for_ocr(img[TeamViewAuthorRect]), ctx)
parse_title(img, ctx::PokemonContext) = ocr_multiple_lang(prepare_text_for_ocr(img[TeamViewTitleRect]), ctx)
function parse_rental_code(img, ctx::PokemonContext)
    text = ocr(img[TeamViewRentalCodeRect], ctx; language = "eng") |> remove_spaces
    if length(text) == 14
        text = "$(text[1:4]) $(text[5:8]) $(text[9:12]) $(text[13:14])"
    end
    text
end

function _parse_scene(::Type{TeamView}, frame::VsFrame, ctx::PokemonContext)
    img = image(frame)
    team = Team()
    for i in 1:6
        push!(team.pokemons, parse_pokemon_box(img, i, ctx))
    end
    team.author = parse_author(img, ctx)
    team.title = parse_title(img, ctx)
    team.rental_code = parse_rental_code(img, ctx)
    TeamView(team)
end
