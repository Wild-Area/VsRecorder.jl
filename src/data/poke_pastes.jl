# https://github.com/felixphew/pokepaste/blob/v3/syntax.go

const STATS_NAMES = ("HP", "Atk", "Def", "SpA", "SpD", "Spe")

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

_stats_from_iv_ev_hp(iv, ev, base, level) = if base == 1
    1
else
    (2base + iv + ev ÷ 4) * level ÷ 100 + 10 + level
end
function _stats_from_iv_ev(
    iv::Int64, ev::Int64, base::Int64, level::Int64,
    dex_field = nothing, up = nothing, down = nothing
)
    dex_field == :hp && return _stats_from_iv_ev_hp(iv, ev, base, level)
    value = (2base + iv + ev ÷ 4) * level ÷ 100 + 5
    if dex_field ≡ up
        value = value * 11 ÷ 10
    elseif dex_field ≡ down
        value = value * 9 ÷ 10
    end
    value
end

function calculate_stats(poke::DexPokemon, level::Int64, evs::Stats, ivs::Stats, nature::Missable{Nature})
    stats = Stats()
    up, down = VsRecorder.get_nature_effect(nature)
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
        value = _stats_from_iv_ev(iv, ev, base, level, dex_field, up, down)
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
        poke.gender = gender == "M" ? GENDER_MALE : gender == "F" ? GENDER_FEMALE : GENDER_NULL
    end
    if !isnothing(head.captures[9])
        iid = head.captures[9]
        poke.item = search_dex(item_list(VsI18n.EN), iid)
    end
    mdex = move_dex()
    adex = ability_list(VsI18n.EN)
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
            continue
        end
        m = match(
            r"^(.+) Nature.*$",
            line
        )
        if !isnothing(m)
            poke.nature = search_dex(nature_list(VsI18n.EN), strip(m.captures[1]))
            continue
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
            if length(dex_poke.abilities) == 1
                poke.ability = dex_poke.abilities[1]
                continue
            end
            for id in dex_poke.abilities
                if adex[id] == values
                    poke.ability = id
                    continue
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

function _stats_to_iv_ev_hp(value, base, level)
    if _stats_from_iv_ev_hp(31, 0, base, level) == value
        return 31, 0
    end
    t = cld((value - level - 10) * 100, level) - 2base
    if t ≤ 31
        t, 0
    else
        31, (t - 31) * 4
    end
end
function _stats_to_iv_ev(
    value::Int64, base::Int64, level::Int64,
    dex_field = nothing, up = nothing, down = nothing
)
    dex_field == :hp && return _stats_to_iv_ev_hp(value, base, level)
    if _stats_from_iv_ev(31, 0, base, level, dex_field, up, down) == value
        return 31, 0
    end
    if dex_field ≡ up
        value = cld(value * 10, 11)
    elseif dex_field ≡ down
        value = cld(value * 10, 9)
    end
    t = cld((value - 5) * 100, level) - 2base
    if t ≤ 31
        t, 0
    else
        31, (t - 31) * 4
    end
end

_get_total_evs(evs::Stats) = sum(getfield(evs, field) for field in STATS_FIELDS)

function _try_natures(poke::Pokemon, level::Int64, up = nothing, down = nothing)
    if isnothing(up) ≠ isnothing(down)
        first = isnothing(up) ? down : up
        for second in DEX_STATS_FIELDS
            first == second && continue
            nature = VsRecorder.get_nature(
                isnothing(up) ? second : first,
                isnothing(up) ? first : second
            )
            nature, ivs, evs = inv_calculate_stats(poke, level, nature)
            _get_total_evs(evs) ≤ 510 && return nature, ivs, evs
        end
    end
    for up in DEX_STATS_FIELDS
        for down in DEX_STATS_FIELDS
            up == down && continue
            nature = VsRecorder.get_nature(up, down)
            nature, ivs, evs = inv_calculate_stats(poke, level, nature)
            _get_total_evs(evs) ≤ 510 && return nature, ivs, evs
        end
    end
    @warn "No valid nature found for $(poke.id)"
    inv_calculate_stats(poke, level, VsRecorder.NATURE_NEUTURAL_DEFAULT)
end

function inv_calculate_stats(poke::Pokemon, level::Int64, nature = poke.nature)
    dex_poke = poke_dex()[poke.id]
    base_stats = dex_poke.base_stats
    stats = poke.stats
    ivs = Stats()
    evs = Stats()
    ismissing(stats) && return nature, ivs, evs
    if !ismissing(stats.hp)
        ivs.hp, evs.hp = _stats_to_iv_ev(stats.hp, base_stats.hp, level, :hp)
    end
    up, down = VsRecorder.get_nature_effect(nature)
    for (field, dex_field) in zip(STATS_FIELDS, DEX_STATS_FIELDS)
        v = getfield(stats, field)
        ismissing(v) && continue
        base = getfield(base_stats, dex_field)
        iv, ev = _stats_to_iv_ev(v, base, level, dex_field, up, down)
        if ismissing(nature)
            if iv < 0
                down = dex_field
                iv, ev = _stats_to_iv_ev(v, base, level, dex_field, up, down)
            elseif ev > 252
                up = dex_field
                iv, ev = _stats_to_iv_ev(v, base, level, dex_field, up, down)
            end
        end
        setfield!.((ivs, evs), (field,), (iv, ev))
    end
    if isnothing(up) ≠ isnothing(down) || ismissing(nature) && _get_total_evs(evs) > 510
        # Just brute force it
        return _try_natures(poke, level, up, down)
    end
    nature = VsRecorder.get_nature(up, down)
    nature, ivs, evs
end

function _print_stats(io::IO, prefix, stats::Stats, default)
    tio = IOBuffer()
    printed = false
    for (i, field) in enumerate(STATS_FIELDS)
        v = getfield(stats, field)
        (ismissing(v) || v == default) && continue
        print(
            tio, printed ? " / " : "", v, ' ',
            STATS_NAMES[i]
        )
        printed = true
    end
    if printed
        println(io, prefix, String(take!(tio)))
    end
end

function export_poke(poke::Pokemon; language = "en")
    if !(language isa VsRecorder.GameLanguage)
        language = VsRecorder.get_game_language(language)
    end
    lang = lowercase(string(language))
    io = IOBuffer()
    if !ismissing(poke.name)
        print(io, poke.name)
        print(io, " (", i18n(poke.id, language = lang), ')')
    else
        print(io, i18n(poke.id, language = lang))
    end
    if !ismissing(poke.gender) && poke.gender ≢ GENDER_NULL
        print(io, " (", poke.gender ≡ GENDER_MALE ? 'M' : 'F', ')')
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
    nature, ivs, evs = inv_calculate_stats(poke, level)
    _print_stats(io, "EVs: ", evs, 0)
    if !ismissing(nature)
        println(io, i18n(nature, language = lang), " Nature")
    end
    _print_stats(io, "IVs: ", ivs, 31)
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
        language = VsRecorder.get_game_language(language)
    end
    join(
        (export_poke(poke; language = language) for poke in team.pokemons),
        '\n'
    )
end
