using VsRecorder.Scenes: TeamPreview, TeamPreviewSelecting


function test_result(parsed::TeamPreview, expected::TeamPreview)
    for field ∈ fieldnames(TeamPreview)
        a = getfield(parsed, field)
        b = getfield(expected, field)
        if field ≡ :team_a
            a = [a[i] for i ∈ 1:6 if i != expected.uncertain]
            b = [b[i] for i ∈ 1:6 if i != expected.uncertain]
        end
        @test a == b
    end
end

@testset "Team Preview" begin
    ctx = VsRecorder.default_context()

    expected1 = TeamPreview(
        0.0,
        ["corviknight", "dragapult", "arcanine", "tyranitar-old", "gastrodon-east", "grimmsnarl"],
        0,
        ["charizard", "sableye", "rhyperior", "torkoal", "gastrodon-east", "heliolisk"],
        [false, false, true, true, false, true],
        [true, true, true, false, false, true],
        [50, 50, 50, 50, 50, 50],
        [50, 50, 50, 50, 50, 50],
        ["leftovers", "life-orb", "mago-berry", "weakness-policy", "sitrus-berry", "iapapa-berry"],
        [],
        "露 露", "Zoe"
    )
    frame1 = VsFrame(image = VsRecorder.load_data("scenes", "zhs", "team-preview.png"))
    parsed1 = vs_tryparse_scene(TeamPreview, frame1, ctx)
    test_result(parsed1, expected1)

    expected2 = TeamPreview(
        0.0,
        # The first pokemon is expected to be wrong.
        ["wishiwashi", "kingdra", "shedinja", "zacian", "indeedee-f", "landorus-therian"],
        1,
        ["mamoswine", "indeedee-f", "zamazenta", "ho-oh", "landorus-therian", "gastrodon-east"],
        [nothing, false, nothing, nothing, false, true],
        [true, false, nothing, nothing, true, true],
        [50, 50, 50, 50, 50, 50],
        [50, 50, 50, 50, 50, 50],
        ["choice-scarf", "life-orb", "focus-sash", "rusted-sword", "psychic-seed", "white-herb"],
        [175, 151, 1, 189, 177, 165],
        "", "あか つき"
    )
    frame2 = VsFrame(image = VsRecorder.load_data("scenes", "zhs", "team-preview-selecting.png"))
    parsed2 = vs_tryparse_scene(TeamPreviewSelecting, frame2, ctx)
    @test typeof(parsed2) ≡ TeamPreview
    test_result(parsed2, expected2)
end
