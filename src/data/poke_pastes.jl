# https://github.com/felixphew/pokepaste/blob/v3/syntax.go

const STATS_FIELDS = (:hp, :attack, :defense, :special_attack, :special_defense, :speed)
const DEX_STATS_FIELDS = (:hp, :atk, :def, :spa, :spd, :spe)


function _parse_stats!(stats, text)
    m = match(
        r"^((\d+) HP)?( / )?((\d+) Atk)?( / )?((\d+) Def)?( / )?((\d+) SpA)?( / )?((\d+) SpD)?( / )?((\d+) Spe)?( *)$",
        text
    )
    for (i, field) in enumerate(STATS_FIELDS)
        t = i * 3 - 1
        if !isnothing(m.captures[t])
            setfield!(stats, field, parse(Int, m.captures[t]))
        end
    end
    stats
end

function calculate_stats(poke::DexPokemon, level::Int64, evs::Stats, ivs::Stats, nature::Missable{NatureID})
    stats = Stats()
    up, down = get_nature_effect(nature)
    for (field, dex_field) in zip(STATS_FIELDS, DEX_STATS_FIELDS)
        base = getfield(poke.base_stats, dex_field)
        ev = getfield(evs, field)
        if ismissing(ev)
            ev = 0
        end
        iv = getfield(ivs, field)
        if ismissing(iv)
            iv = 31
        end
        value = if base == 1
            1
        elseif dex_field == :hp
            (base * 2 + iv + ev ÷ 4) * level ÷ 100 + 10 + level
        else
            (base * 2 + iv + ev ÷ 4) * level ÷ 100 + 5
        end
        if dex_field == up
            value = value * 11 ÷ 10
        elseif dex_field == down
            value = value * 9 ÷ 10
        end
        setfield!(stats, field, value)
    end
    stats
end

function import_poke(input::AbstractString)
    input = strip(input)
    lines = split(input, r"[\r\n]", keepempty = false)
    head = match(
        r"^(?:(.* \()([A-Z][a-z0-9:']+\.?(?:[- ][A-Za-z][a-z0-9:']*\.?)*)(\))|([A-Z][a-z0-9:']+\.?(?:[- ][A-Za-z][a-z0-9:']*\.?)*))(?:( \()([MF])(\)))?(?:( @ )([A-Z][a-z0-9:']*(?:[- ][A-Z][a-z0-9:']*)*))?( *)$",
        lines[1]
    )
    @assert !isnothing(head)
    poke = Pokemon(level = 100)  # PokePaste's default level is 100
    pdex = poke_dex()
    if !isnothing(head.captures[2])
        pid = head.captures[2]
        poke.id = search_dex(pdex, pid)
        poke.name = split(head.captures[1], '-')[1] |> strip
    elseif !isnothing(head.captures[4])
        pid = head.captures[4]
        poke.id = search_dex(pdex, pid)
    end
    dex_poke = pdex[poke.id]
    poke.ability = dex_poke.abilities[1]
    if !isnothing(head.captures[6])
        gender = head.captures[6]
        poke.gender = gender == "M" ? true : gender == "F" ? false : nothing
    end
    if !isnothing(head.captures[9])
        iid = head.captures[9]
        poke.item = search_dex(item_dex(), iid)
    end
    mdex = move_dex()
    adex = ability_dex()
    evs = Stats()
    ivs = Stats()
    for line in lines[2:end]
        m = match(
            r"^(-)( ([A-Z][a-z\']*(?:[- ][A-Za-z][a-z\']*)*)(?: \[([A-Z][a-z]+)\])?(?: / [A-Z][a-z\']*(?:[- ][A-Za-z][a-z\']*)*)* *)$",
            line
        )
        if !isnothing(m)
            mid = m.captures[3]
            push!(poke.moves, search_dex(mdex, mid))
            break
        end
        m = match(
            r"^(.+) Nature.*$",
            line
        )
        if !isnothing(m)
            poke.nature = search_dex(nature_dex(), strip(m.captures[1]))
            break
        end
        tmp = split(line, ':', limit = 2)
        length(tmp) == 2 || continue
        key, values = tmp
        values = strip(values)
        if key == "EVs"
            _parse_stats!(evs, values)
        elseif key == "IVs"
            _parse_stats!(ivs, values)
        elseif key == "Ability"
            for id in dex_poke.abilities
                if adex[id] == values
                    poke.ability = id
                    break
                end
            end
        elseif key == "Level"
            poke.level = parse(Int, values)
        elseif key == "Shiny"
            poke.shiny = values == "Yes"
        else
        end
    end
    poke.stats = calculate_stats(dex_poke, poke.level, evs, ivs, poke.nature)
    poke
end

"""
    import_team(pokepaste_input) -> Team

Import a string formatted in PokePaste syntax as a team. Only support English.
"""
function import_team(
    input::AbstractString;
    title = "",
    author = missing,
    notes = ""
)
    team = Team(title = title, author = author, notes = notes)
    for poke in split(input, r"\r?\n\r?\n", keepempty = false)
        push!(team.pokemons, import_poke(poke))
    end
    team
end

function inv_calculate_stats(poke::Pokemon, level::Int64)
    dex_poke = poke_dex()[poke.id]
    base_stats = dex_poke.base_stats
    stats = poke.stats
    ivs = Stats()
    evs = Stats()
    ismissing(stats) && return poke.nature, missing, missing
    ivs.hp, evs.hp = if !ismissing(stats.hp)
        base = base_stats.hp
        t = ceil((stats.hp - level - 10) * 100 / level) - base * 2
        if t < 31
            t, missing
        elseif t == 31
            missing, missing
        else
            missing, (t - 31) * 4
        end
    end
    
end

function _print_stats(io::IO, prefix, stats::Stats)
    tio = IOBuffer()
    printed = false
    for field in STATS_FIELDS
        v = getfield(stats, field)
        ismissing(v) && continue
        print(
            tio, printed ? " / " : "", v, ' ',
            if field == :hp
                "HP"
            elseif field == :atk
                "Atk"
            elseif field == :def
                "Def"
            elseif field == :spa
                "SpA"
            elseif field == :spd
                "SpD"
            elseif field == :spe
                "Spe"
            end
        )
        printed = true
    end
    if printed
        println(io, prefix, String(take!(tio)))
    end
end

function export_poke(poke::Pokemon; language = "en")
    if !(language isa VsRecorder.GameLanguage)
        language = VsRecorder.default_language(language)
    end
    lang = lowercase(string(language))
    io = IOBuffer()
    if !ismissing(poke.name)
        print(io, poke.name)
        print(io, " (", i18n(poke.id, language = lang), ')')
    else
        print(io, i18n(poke.id, language = lang))
    end
    if !ismissing(poke.gender) && !isnothing(poke.gender.value)
        print(io, " (", poke.gender.value ? 'M' : 'F', ')')
    end
    if !ismissing(poke.item)
        print(io, " @ ", i18n(poke.item, language = lang))
    end
    println(io)
    if !ismissing(poke.shiny)
        println(io, "Shiny: ", poke.shiny ? "Yes" : "No")
    end
    if !ismissing(poke.ability)
        println(io, "Ability: ", i18n(poke.ability, language = lang))
    end
    level = ismissing(poke.level) ? 50 : poke.level
    println(io, "Level: ", level)
    nature, evs, ivs = inv_calculate_stats(poke, level)
    _print_stats(io, "EVs: ", evs)
    _print_stats(io, "IVs: ", ivs)
    println(io, i18n(nature, language = lang), " Nature")
    for move in poke.moves
        println(io, "- ", i18n(move, language = lang))
    end
    String(take!(io))
end

"""
    export_team(team; language = "en") -> String

Export a team to a string formatted in PokePaste syntax.
"""
function export_team(team::Team; language = "en")
    if !(language isa VsRecorder.GameLanguage)
        language = VsRecorder.default_language(language)
    end
    join(
        (export_poke(poke; language = language) for poke in team),
        "\n\n"
    )
end
