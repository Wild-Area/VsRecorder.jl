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
    has_gender = length(gender_pos) > 0
    name_box = if has_gender
        @view line[:, 1:gender_pos[1] - 1]
    else
        line
    end
    name_box = prepare_text_for_ocr(name_box)
    name = ocr(name_box, ctx)
    PokemonID(name), 50
end

function parse_name_line(box, ctx::PokemonContext)
    # id, gender, level
    line = box[TeamViewNameRect]
    gender, gender_pos = parse_gender(line, ctx)
    id, level = parse_name_level(line, gender_pos, ctx)
    id, gender, level
end

function parse_pokemon_box(box, ctx::PokemonContext)
    poke = Pokemon()
    poke.id, poke.gender, poke.level = parse_name_line(box, ctx)
    poke
end

parse_pokemon_box(img, i, ctx::PokemonContext) = parse_pokemon_box(img[TeamViewPokemonBoxRects[i]], ctx)

function _parse_scene(::Type{TeamView}, frame::VsFrame, ctx::PokemonContext)
    img = image(frame)
    team = Team()
    for i in 1:6
        push!(team.pokemons, parse_pokemon_box(img, i, ctx))
    end
    TeamView(team)
end
