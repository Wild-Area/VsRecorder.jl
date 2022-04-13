
function boot_up(;verbose = false)
    if verbose
        @info "Booting up..."
    end
    img = rand(RGB{N0f8}, (72, 128))
    frame = VsFrame(image = img)
    config = vs_setup(PokemonBattle, init_descriptors = false, set_global = false)
    ctx = VsRecorderBase.initialize(config)
    for T in VsRecorder.Scenes.AvailableScenes
        if verbose
            @info "Compiling for $T..."
        end
        vs_tryparse_scene(T, frame, ctx, force = true)
    end
    if verbose
        @info "Booted."
    end
    nothing
end
