"""
    PokemonBattle

Only works for double ranked battles right now.
"""
Base.@kwdef struct PokemonBattle <: AbstractVsSource
    language::GameLanguage
    double::Bool
    # (height, width)
    image_size::Tuple{Int, Int}
    parse_battle::Bool
    parse_player_a::Bool
end

const GlobalVsConfig = Ref{Union{
    Nothing,
    VsConfig{DefaultStrategy, PokemonBattle}
}}(nothing)

function VsRecorderBase.vs_setup(
    ::Type{PokemonBattle};
    language::GameLanguage = default_language(),
    double = true,
    num_skip_frames = 59,
    use_gray_image = false,
    feature_size = (360, 640),
    image_size = (960, 540),
    parse_battle = true,
    parse_player_a = false,
    match_threshold = 0.1,
    set_global = true,
    init_descriptors = true
)

set_language!(GlobalI18nContext[], lowercase(string(language)), String[])
ocr_language = OCR_LANGUAGES[language]
strategy = DefaultStrategy(
    match_threshold = match_threshold,
    height = feature_size[1],
    width = feature_size[2],
    init_descriptors = init_descriptors
)
source = PokemonBattle(
    language = language,
    double = double,
    image_size = image_size,
    parse_battle = parse_battle,
    parse_player_a = parse_player_a
)

config = VsConfig(
    num_skip_frames = num_skip_frames,
    use_gray_image = use_gray_image,
    ocr_language = ocr_language,
    strategy = strategy,
    source = source
)

if set_global
    GlobalVsConfig[] = config
end

config

end

default_config() = isnothing(GlobalVsConfig[]) ? vs_setup(
    PokemonBattle, parse_player_a = true, set_global = false,
    init_descriptors = false
) : GlobalVsConfig[]

default_context() = VsRecorderBase.initialize(default_config())
