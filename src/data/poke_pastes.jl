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

function get_nature(nature)
    if nature == "Adamant"
        :atk, :spa
    elseif nature == "Bold"
        :def, :atk
    elseif nature == "brave"
        :atk, :spe
    elseif nature == "Calm"
        :spd, :atk
    elseif nature == "Careful"
        :spd, :spa
    elseif nature == "Gentle"
        :spd, :def
    elseif nature == "Hasty"
        :spe, :def
    elseif nature == "Impish"
        :def, :spa
    elseif nature == "Jolly"
        :spe, :spa
    elseif nature == "Lax"
        :def, :spd
    elseif nature == "Lonely"
        :atk, :def
    elseif nature == "Mild"
        :spa, :def
    elseif nature == "Modest"
        :spa, :atk
    elseif nature == "Naive"
        :spe, :spd
    elseif nature == "Naughty"
        :atk, :spd
    elseif nature == "Quiet"
        :spa, :spe
    elseif nature == "Rash"
        :spa, :spd
    elseif nature == "Relaxed"
        :def, :spe
    elseif nature == "Sassy"
        :spd, :spe
    elseif nature == "Timid"
        :spe, :atk
    else
        nothing, nothing
    end
end

function calculate_stats(poke::DexPokemon, level::Int64, evs::Stats, ivs::Stats, nature::Nullable{AbstractString})
    stats = Stats()
    up, down = get_nature(nature)
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
    nature = nothing
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
            nature = strip(m.captures[1])
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
    poke.stats = calculate_stats(dex_poke, poke.level, evs, ivs, nature)
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
    nature, evs, ivs = inv_calculate_stats(poke.stats)
    print_stats(io, evs)
    print_stats(io, ivs)
    println(io, nature, " Nature")
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
