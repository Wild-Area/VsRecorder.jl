"""
    ParseType

- PARSE_NONE: Only collect information
- PARSE_MINIMAL: Parse only useful information.
- PARSE_OPPONENT: Parse all information of the opponent
- PARSE_BOTH_PLAYERS: Parse all information for both players.
"""
@enum ParseType begin
    PARSE_NONE = 0
    PARSE_MINIMAL = 1
    PARSE_OPPONENT = 2
    PARSE_BOTH_PLAYERS = 3
end
VsRecorderBase.enum_prefix(::Type{ParseType}) = "PARSE_"

"""
    PokemonBattle

Only works for double ranked battles right now.
"""
Base.@kwdef struct PokemonBattle <: AbstractVsSource
    language::GameLanguage
    double::Bool
    # (height, width)
    image_size::Tuple{Int, Int}
    parse_type::ParseType
end

const GlobalVsConfig = Ref{Nullable{
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
    parse_type::ParseType = PARSE_MINIMAL,
    match_threshold = 0.1,
    set_global = true,
    init_descriptors = true
)

if use_gray_image
    @warn "Using gray image is not recommended for its low accuracy."
end

set_language!(GlobalI18nContext[], enum_to_string(language), String[])
ocr_language = VsI18n.OCR_LANGUAGES[language]
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
    parse_type = parse_type
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
    PokemonBattle, parse_type = PARSE_BOTH_PLAYERS,
    set_global = false,
    init_descriptors = false
) : GlobalVsConfig[]

default_context() = VsRecorderBase.initialize(default_config())
