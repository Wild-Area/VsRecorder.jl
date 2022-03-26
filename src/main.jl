import VsRecorderBase: vs_tryparse_scene, vs_result
import VsRecorderBase.DefaultStrategyModule: feature_image_and_masks

function VsRecorderBase.vs_init!(ctx::PokemonBattleContext{DefaultStrategy})
    invoke(vs_init!, ctx, VsContext{DefaultStrategy})
    data = ctx.data
    # TODO
    data.battles = Battle[]
    data.parsed_battles = ParsedBattle[]
    data.current_battle = nothing
    data.current_parsed_battle = nothing
end

const AvailableScenes = Type[
    SearchingScene
]

function feature_image_and_masks(source::PokemonBattle, ctx::VsContext)
    language = source.language

    scene_types = Type[]
    # TODO
    append!(scene_types, AvailableScenes)

    map(scene_types) do scene_type
        name = feature_image_name(scene_type, source)
        filename = "$name.png"
        img = load_data("scenes", language, filename)
        mask = load_data("scenes", "mask", filename)
        (scene_type, img, mask)
    end
end

function vs_result(ctx::PokemonBattleContext)
    data = ctx.data
    battles = data.battles
    parsed_battles = data.parsed_battles
    PokemonBattleResult(
        battles = battles,
        parsed_battles = parsed_battles
    )
end
