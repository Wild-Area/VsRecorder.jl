"""
    PokemonBattle

Only works for double ranked battles right now.
"""
Base.@kwdef struct PokemonBattle <: AbstractVsSource
    language::GameLanguage
    double::Bool = true
    # (height, width)
    image_size = (720, 1280)
    parse_battle = true
    parse_player_A = false
end

const GlobalVsConfig = Ref{Union{
    Nothing,
    VsConfig{DefaultStrategy, PokemonBattle}
}}(nothing)

function VsRecorderBase.vs_setup(
    ::Type{PokemonBattle};
    language::GameLanguage = EN,
    double = true,
    num_skip_frames = 59,
    use_gray_image = true,
    image_size = (720, 1280),
    parse_battle = false,
    parse_player_A = true,
    gaussian_filter_σ = 0.5,
    match_threshold = 0.05
)

set_language!(GlobalI18nContext, lowercase(string(language)), String[])
ocr_language = OCR_LANGUAGES[language]
strategy = DefaultStrategy(match_threshold = match_threshold)
source = PokemonBattle(
    language = language,
    double = double,
    image_size = image_size,
    parse_battle = parse_battle,
    parse_player_A = parse_player_A
)

config = VsConfig(
    num_skip_frames = num_skip_frames,
    use_gray_image = use_gray_image,
    ocr_language = ocr_language,
    gaussian_filter_σ = gaussian_filter_σ,
    strategy = strategy,
    source = source
)

if set_global
    GlobalVsConfig[] = config
end

config

end