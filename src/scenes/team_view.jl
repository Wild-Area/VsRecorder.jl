struct TeamView <: AbstractPokemonScene
    team::Team
end

feature_image_name(::Type{TeamView}, ::PokemonBattle) = "team-view"

should_include(::Type{TeamView}, ctx::PokemonContext) =
    !isnothing(ctx.data.context)  # should not be included when in a battle

function _parse_scene(::Type{TeamView}, frame::VsFrame, ctx::PokemonContext)
    team = Team()

    TeamView(team)
end
