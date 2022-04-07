using Test
using VsRecorder
using VsRecorder.VsRecorderBase


@testset "VsRecorder.jl" begin
    @test VsRecorder.download_all_ocr_languages()

    include("team_preview.jl")
    include("poke_pastes.jl")
end
