const GlobalI18nContext = Ref{Union{Nothing, SimpleI18n.I18nContext}}(nothing)

function initialize_i18n()
    GlobalI18nContext[] = SimpleI18n.setup(
        datapath("locales"),
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
    t = split(lang, '_', limit = 2)
    lang, region = if length(t) < 2
        t[1], ""
    else
        t
    end
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
    for lang in values(OCR_LANGUAGES)
        download_ocr_language(lang) || return false
        if lang ∈ ("chi_sim", "chi_tra", "jpn")
            download_ocr_language(lang * "_vert") || return false
        end
    end
    true
end

function get_i18n(path...; lang = nothing)
    key = join(path, '.')
    i18n(GlobalI18nContext[], key; language = lang)
end
