struct BattleMain <: AbstractPokemonScene
    player_a_pokes::Vector{PokemonID}
    player_b_pokes::Vector{PokemonID}
end

feature_image_name(::Type{BattleMain}, ::PokemonBattle) = "battle-main"

function parse_pokemon_name(img, i, is_player_a, ctx::PokemonContext)
    rect = if is_player_a
        if i == 1
            Rect((914, 12), (64, 250), resolution = DesignResolution)
        else
            Rect((914, 516), (64, 250), resolution = DesignResolution)
        end
    else
        if i == 1
            Rect((38, 940), (50, 250), resolution = DesignResolution)
        else
            Rect((38, 1450), (50, 250), resolution = DesignResolution)
        end
    end
    area = img[rect]
    text, langs = ocr_multiple_lang(area, ctx)
    lists = [poke_list(lang) for lang in split(langs, '+')]
    pids = sort!([data_search_n(list, text, n = 1)[1] for list in lists])
    pids[1][2]
end

function _parse_scene(::Type{BattleMain}, frame::VsFrame, ctx::PokemonContext)
    img = image(frame)
    parse_type = ctx.config.source.parse_type
    player_a_pokes = parse_type ≡ PARSE_BOTH_PLAYERS ? [parse_pokemon_name(img, i, true, ctx) for i in 1:2] : PokemonID[]
    player_b_pokes = [parse_pokemon_name(img, i, false, ctx) for i in 1:2]
    BattleMain(player_a_pokes, player_b_pokes)
end
