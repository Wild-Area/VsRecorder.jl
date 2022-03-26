struct Searching <: AbstractPokemonScene
    frame_time::Float64
end
feature_image_name(::Type{Searching}, ::PokemonBattle) = "searching"
