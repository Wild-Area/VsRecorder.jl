"""
    PokemonBattle

Only works for double ranked battles right now.
"""
Base.@kwdef struct PokemonBattle <: AbstractVsSource
    language::String
    double::Bool = true
    # (height, width)
    image_size = (720, 1280)
end

const GlobalVsConfig = Ref{Union{
    Nothing,
    VsConfig{DefaultStrategy, PokemonBattle}
}}(nothing)

function VsRecorderBase.vs_setup(
    ::Type{PokemonBattle};
    language = "en",
    double = true,
    num_skip_frames = 59,
    use_gray_image = true,
    gaussian_filter_σ = 0.5,
    match_threshold = 0.05
)

if !haskey(LANGUAGES, language)
    error(string(
        "Unsupported language \`$language\`. Select one of the followings:\n[",
        join(", ", sort(keys(LANGUAGES))),
        "]"
    ))
end

set_language!(GlobalI18nContext, language, String[])
ocr_language = OCR_LANGUAGES[language]
strategy = DefaultStrategy(match_threshold = match_threshold)
source = PokemonBattle(
    language = language,
    double = double
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