using VsRecorder
using VsRecorder.Scenes: BattleMain

@testset "Battle Main" begin
    config = vs_setup(
        PokemonBattle,
        language = VsI18n.ZHS,
        init_descriptors = false,
        parse_type = PARSE_BOTH_PLAYERS
    )
    ctx = VsRecorderBase.initialize(config)

    frame = VsFrame(image = VsRecorder.load_data("scenes", "zhs", "battle-main.png"))
    parsed = vs_tryparse_scene(BattleMain, frame, ctx)
    @test parsed.player_a_pokes == PokemonID["incineroar", "grimmsnarl"]
    @test parsed.player_b_pokes == PokemonID["zacian", "regieleki"]
end
