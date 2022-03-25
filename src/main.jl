import VsRecorderBase: vs_tryparse_scene
import VsRecorderBase.DefaultStrategyModule: feature_image_and_masks

function VsRecorderBase.vs_init!(ctx::VsContext{DefaultStrategy, PokemonBattle})
    invoke(vs_init!, ctx, VsContext{DefaultStrategy})
    # data = ctx.data
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
