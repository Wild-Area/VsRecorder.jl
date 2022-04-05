const DesignResolution = (1080, 1920)

frame_time(scene::AbstractPokemonScene) = scene.frame_time

function get_current_context!(ctx::PokemonContext)::BattleContext
    data = ctx.data
    parsing_context = data.context
    if isnothing(parsing_context.current)
        current = parsing_context.current = BattleContext()
        push!(parsing_context.battles, current.battle)
        if ctx.config.source.parse_type > PARSE_NONE
            current.parsed_battle = ParsedBattle()
            push!(parsing_context.parsed_battles, current.parsed_battle)
        end
    end
    parsing_context.current
end

VsRecorderBase.vs_tryparse_scene(
    T::Type{<:AbstractPokemonScene},
    frame::VsFrame,
    ctx::Union{PokemonContext, Nothing} = nothing;
    force::Bool = false
) = try
    if isnothing(ctx)
        ctx = default_context()
    end
    if ctx.current_frame ≢ frame
        ctx.current_frame = frame
    end
    ctx.data.force = force
    _parse_scene(T, frame, ctx)
catch e
    ctx.data.last_error = e
    rethrow(e)
    nothing
end

VsRecorderBase.vs_update!(ctx::PokemonContext, scene::AbstractPokemonScene) = _vs_update!(ctx, scene)