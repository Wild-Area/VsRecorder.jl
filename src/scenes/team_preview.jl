struct TeamPreview <: AbstractPokemonScene
    frame_time::Float64
    team_a::Vector{PokemonID}
    team_b::Vector{PokemonID}
    genders_a::Vector{Union{Nothing, Bool}}
    genders_b::Vector{Union{Nothing, Bool}}
    levels_a::Vector{Int64}
    levels_b::Vector{Int64}
    items_a::Vector{PokemonID}
end

struct TeamPreviewSelecting <: AbstractPokemonScene
    frame_time::Float64
    team::Vector{PokemonID}
    genders::Vector{Union{Nothing, Bool}}
    levels::Vector{Int64}
    items::Vector{PokemonID}
    hps::Vector{PokemonID}
end

feature_image_name(::Type{TeamPreview}, ::PokemonBattle) = "team-preview"
feature_image_name(::Type{TeamPreviewSelecting}, ::PokemonBattle) = "team-preview-selecting"

still_available(::Union{TeamPreview, TeamPreviewSelecting}, ::PokemonContext) = true

function _parse_scene(::Type{TeamPreview}, frame::VsFrame, ctx::PokemonContext)

end
