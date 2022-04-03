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

function default_language(locale = SimpleI18n.get_system_language())
    lang = lowercase(locale)
    lang, region = split(lang, '_', limit = 2)
    if lang == "zh"
        if region ∈ ("hk", "tw")
            ZHT
        else
            ZHS
        end
    elseif lang == "ja"
        JA
    elseif lang == "es"
        ES
    elseif lang == "fr"
        FR
    elseif lang == "de"
        DE
    elseif lang == "it"
        IT
    elseif lang == "ko"
        KO
    else  # defaultly fallback to EN
        EN
    end
end

# The order of languages matters.
all_ocr_languages() = "chi_sim+chi_tra+jpn+kor+fra+deu+spa+ita+eng"

function download_all_ocr_languages()
    dl = VsRecorderBase.Tesseract.download_languages
    for lang in values(OCR_LANGUAGES)
        dl(lang) || return false
        if lang ∈ ("chi_sim", "chi_tra", "jpn")
            dl("$(lang)_vert") || return false
        end
    end
    true
end
