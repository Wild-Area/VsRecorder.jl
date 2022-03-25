const GlobalI18nContext = []

function initialize_i18n()
    GlobalI18nContext[] = SimpleI18n.setup(
        joinpath(artifact"data", "locales"),
        "en"
    )
end

const OCR_LANGUAGES = Dict(
    "en" => "eng",
    "zh-Hans" => "chi_sim",
    "zh-Hant" => "chi_tra",
    "ja" => "jpn",
    "es" => "spa",
    "fr" => "fra",
    "de" => "deu",
    "it" => "ita",
    "ko" => "kor",
)
