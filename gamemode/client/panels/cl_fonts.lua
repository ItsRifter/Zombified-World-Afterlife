ZWA_Fonts = {}

function ZWA_Fonts:CreateFont(name, size, weight)
    surface.CreateFont("ZWA_Fonts." .. name, {
        font = "Roboto",
        size = size or 16,
        weight = weight or 500
    } )
end