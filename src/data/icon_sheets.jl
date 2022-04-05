const PokemonIconSheetFile = joinpath(artifact"data", "sprites", "swsh-pokemon-icons.png")
const ItemIconSheetFile = joinpath(artifact"data", "sprites", "swsh-item-icons.png")
const GenderIconSheetFile = joinpath(artifact"data", "sprites", "gender-icons.png")

macro _sheet_func(func_name, sheet_name, has_mask = false)
    gray_name = Symbol(sheet_name, :Gray)
    file_name = Symbol(sheet_name, :File)
    TMask = has_mask ? Matrix{Float32} : Nothing
    TRGB = :(Nullable{SpriteSheet{RGB{Float32}, $TMask}})
    TGray = :(Nullable{SpriteSheet{Gray{Float32}, $TMask}})
    quote
        const $sheet_name = Ref{$TRGB}(nothing)
        const $gray_name = Ref{$TGray}(nothing)
        function $func_name(; force = false, gray = false)
            if gray
                @_load_data $gray_name force SpriteSheet($file_name, gray = true)
            else
                @_load_data $sheet_name force SpriteSheet($file_name, gray = false)
            end
        end
    end |> esc
end

@_sheet_func pokemon_icons PokemonIconSheet
@_sheet_func item_icons ItemIconSheet
@_sheet_func gender_icons GenderIconSheet true
