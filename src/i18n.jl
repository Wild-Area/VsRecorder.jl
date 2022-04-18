module VsI18n

using SimpleI18n

using VsRecorderBase: download_ocr_language, enum_to_string
using ..VsRecorder: datapath

export GlobalI18nContext, GameLanguage
export get_i18n, download_all_ocr_languages, all_ocr_languages,
    get_game_language

const GlobalI18nContext = Ref{Union{Nothing, SimpleI18n.I18nContext}}(nothing)

function __init__()
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

function get_game_language(locale::AbstractString = SimpleI18n.get_system_language())
    lang = lowercase(locale)
    t = split(lang, '_', limit = 2)
    lang, region = if length(t) < 2
        t[1], ""
    else
        t
    end
    if lang ∈ ("zh", "chi")
        if region ∈ ("hk", "tw", "hant", "tra")
            ZHT
        else
            ZHS
        end
    elseif lang == "zht"
        ZHT
    elseif lang == "zhs"
        ZHS
    elseif lang ∈ ("ja", "jpn")
        JA
    elseif lang ∈ ("es", "spa")
        ES
    elseif lang ∈ ("fr", "fra")
        FR
    elseif lang ∈ ("de", "deu")
        DE
    elseif lang ∈ ("it", "ita")
        IT
    elseif lang ∈ ("ko", "kor")
        KO
    else  # defaultly fallback to EN
        EN
    end
end
get_game_language(x::GameLanguage) = x

get_code(lang::AbstractString) = SimpleI18n.parse_locale_name(lang)
get_code(lang::GameLanguage) = get_code(enum_to_string(lang))

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

end
