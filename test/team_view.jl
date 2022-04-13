using VsRecorder
using VsRecorder.Scenes: TeamView

@testset "Team View" begin
    config = vs_setup(PokemonBattle, language = VsI18n.ZHS, init_descriptors = false)
    ctx = VsRecorderBase.initialize(config)

    expected = """Dragapult (F) @ Life Orb
Ability: Clear Body
Level: 60
- Protect
- Draco Meteor
- Thunderbolt
- Shadow Ball

Tyranitar (M) @ Weakness Policy
Ability: Sand Stream
Level: 55
- Rock Slide
- Crunch
- High Horsepower
- Protect

Grimmsnarl (M) @ Iapapa Berry
Ability: Prankster
Level: 100
- Play Rough
- Sucker Punch
- Fake Out
- Power Swap

Arcanine (M) @ Mago Berry
Ability: Intimidate
Level: 50
- Snarl
- Flamethrower
- Safeguard
- Protect

Gastrodon (F) @ Sitrus Berry
Ability: Storm Drain
Level: 50
- Muddy Water
- Earth Power
- Yawn
- Recover

Corviknight (F) @ Leftovers
Ability: Mirror Armor
Level: 50
- Roost
- Bulk Up
- Brave Bird
- Body Press
"""
    frame = VsFrame(image = VsRecorder.load_data("scenes", "zhs", "team-view.png"))
    parsed = vs_tryparse_scene(TeamView, frame, ctx)
    team = parsed.team
    # Tesseract has slightly different behaviours on different platforms
    @test team.title ∈ ("达拉斯R赛", "達拉斯R賽")
    @test team.author == "露露"
    @test team.rental_code == "0000 0008 53NO V8"
    @test export_team(team) == expected
end
