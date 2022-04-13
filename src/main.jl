import VsRecorderBase: vs_tryparse_scene, vs_result
import VsRecorderBase.DefaultStrategyModule: feature_image_and_masks
using VsRecorder.Scenes: feature_image_name

function VsRecorderBase.vs_init!(ctx::PokemonContext{DefaultStrategy})
    invoke(vs_init!, Tuple{VsContext{DefaultStrategy}}, ctx)
    tessdata_path = datapath("tessdata")
    ocr_language = ctx.config.ocr_language
    if isfile(tessdata_path, "$ocr_language.traineddata")
        # Load specialized OCR trained data.
        Tesseract.tess_init(
            ctx.ocr_instances[ocr_language],
            ocr_language,
            tessdata_path
        )
    end
    init_multiple_ocr!(ctx, ["chi_sim+chi_tra", "jpn", "kor", "fra+deu+spa+ita+eng"])
    data = ctx.data
    data.context = ParsingContext()
    Data.initialize_icons()
    ctx
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
        mask = try
            load_data("scenes", "mask", filename)
        catch
            ones(Float32, size(img))
        end
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
