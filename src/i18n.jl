const GlobalI18nContext = Ref{Union{Nothing, SimpleI18n.I18nContext}}(nothing)

function initialize_i18n()
    GlobalI18nContext[] = SimpleI18n.setup(
        joinpath(artifact"data", "locales"),
        "en"
    )
end

@enum GameLanguage begin
    EN
    ZHS
    ZHT
    JA
    KO
    ES
    FR
    DE
    IT
end

const OCR_LANGUAGES = Dict(
    EN => "eng",
    ZHS => "chi_sim",
    ZHT => "chi_tra",
    JA => "jpn",
    ES => "spa",
    FR => "fra",
    DE => "deu",
    IT => "ita",
    KO => "kor",
)
