-- Mostly taken from https://love2d.org/forums/viewtopic.php?p=211460&sid=0837416402b7c478107097dd083f7f90#p211460 - thanks!
local paletteShader = {}

local sh_swap_colors = love.filesystem.read("shaders/paletteShader.glsl")

local shader = love.graphics.newShader(sh_swap_colors)

function paletteShader.on(imgPalette, newPalette)
    if imgPalette then
        shader:send("n", #imgPalette)
        shader:sendColor("oldColors", unpack(imgPalette))
        shader:sendColor("newColors", unpack(newPalette))
    end

    love.graphics.setShader(shader)
end

function paletteShader.off()
    love.graphics.setShader()
end

return paletteShader