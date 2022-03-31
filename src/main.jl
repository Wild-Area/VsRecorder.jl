import VsRecorderBase: vs_tryparse_scene, vs_result
import VsRecorderBase.DefaultStrategyModule: feature_image_and_masks
using VsRecorder.Scenes: feature_image_name

function VsRecorderBase.vs_init!(ctx::PokemonContext{DefaultStrategy})
    invoke(vs_init!, Tuple{VsContext{DefaultStrategy}}, ctx)
    data = ctx.data
    # TODO
    data.context = ParsingContext()
end

function feature_image_and_masks(source::PokemonBattle, ctx::VsContext)
    language = lowercase(string(source.language))

    scene_types = Type[]
    # TODO
    append!(scene_types, Scenes.AvailableScenes)

    map(scene_types) do scene_type
        name = feature_image_name(scene_type, source)
        filename = "$name.png"
        img = load_data("scenes", language, filename)
        mask = load_data("scenes", "mask", filename)
        (scene_type, img, mask)
    end
end

function vs_result(ctx::PokemonContext)
    data = ctx.data
    battles = data.battles
    parsed_battles = data.parsed_battles
    PokemonBattleResult(
        battles = battles,
        parsed_battles = parsed_battles
    )
end
