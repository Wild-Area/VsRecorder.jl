using Test
using VsRecorder
using VsRecorder.VsRecorderBase


@testset "VsRecorder.jl" begin
    @test VsRecorder.download_all_ocr_languages()

    include("poke_pastes.jl")
    include("team_preview.jl")
    include("battle_main.jl")
    include("team_view.jl")
end
