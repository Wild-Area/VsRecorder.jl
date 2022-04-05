const PokemonIconSheetFile = joinpath(artifact"data", "sprites", "swsh-pokemon-icons.png")
const ItemIconSheetFile = joinpath(artifact"data", "sprites", "swsh-item-icons.png")
const GenderIconSheetFile = joinpath(artifact"data", "sprites", "gender-icons.png")

const PokemonIconSheet = Ref{Nullable{SpriteSheet{RGB{Float32}, Nothing}}}(nothing)
const ItemIconSheet = Ref{Nullable{SpriteSheet{RGB{Float32}, Nothing}}}(nothing)
const GenderIconSheet = Ref{Nullable{SpriteSheet{RGB{Float32}, Matrix{Float32}}}}(nothing)

function pokemon_icons(force = false)
    if !force && !isnothing(PokemonIconSheet[])
        return PokemonIconSheet[]
    end
    PokemonIconSheet[] = SpriteSheet(PokemonIconSheetFile, gray = false)
end

function item_icons(force = false)
    if !force && !isnothing(ItemIconSheet[])
        return ItemIconSheet[]
    end
    sheet = ItemIconSheet[] = SpriteSheet(ItemIconSheetFile, gray = false)
    sheet.image .= blur(sheet.image, 1f0)
    sheet
end

function gender_icons(force = false)
    if !force && !isnothing(GenderIconSheet[])
        return GenderIconSheet[]
    end
    GenderIconSheet[] = SpriteSheet(GenderIconSheetFile, gray = false)
end
