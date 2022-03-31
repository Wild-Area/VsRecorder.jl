const DesignResolution = (1080, 1920)

frame_time(scene::AbstractPokemonScene) = scene.frame_time

function get_current_context!(ctx::PokemonContext)::BattleContext
    data = ctx.data
    parsing_context = data.context
    if isnothing(parsing_context.current)
        current = parsing_context.current = BattleContext()
        push!(parsing_context.battles, current.battle)
        push!(parsing_context.parsed_battles, current.parsed_battle)
    end
    parsing_context.current
end

still_available(::Nothing, ::PokemonContext) = false
still_available(scene::AbstractPokemonScene, ::PokemonContext) = false

VsRecorderBase.vs_tryparse_scene(
    T::Type{<:AbstractPokemonScene},
    frame::VsFrame,
    ctx::PokemonContext = default_context()
) = try
    if ctx.current_frame != frame
        ctx.current_frame = frame
    end
    current = get_current_context!(ctx)
    previous = get(current.parsed_scenes, T, nothing)
    still_available(previous, ctx) && return previous
    current.parsed_scenes[T] = _parse_scene(T, frame, ctx)
catch e
    ctx.data.last_error = e
    rethrow(e)
    nothing
end
