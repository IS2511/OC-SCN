--[[
    OC Double Buffering Library

    Create a buffer with doublebuffer.newBuffer(x, y, width, height) which you
    can use (almost) just like the gpu component API.

    Credits go to https://www.github.com/IgorTimofeev for his double buffering library
    from which I found a solution for minimal RAM usage.

~Overflwn
]]

local component = require("component")
--get the first gpu found
local gpu = component.proxy(component.list("gpu")())
local doublebuffer = {}

function doublebuffer.toTableCoord(x, y, width)
    --Convert a coordinate to a number used to index the buffer
    return (y*width)-width+x
end

function doublebuffer.toPixelCoord(num, width)
    --Convert a number used to index the buffer to a coordinate
    y = math.floor(num/width)+1
    x = num%width
    return x, y
end

function doublebuffer.newBuffer(x, y, width, height)
    local x = x
    local y = y
    local width = width
    local height = height
    local bufferFG = {}
    local bufferBG = {}
    local bufferChar = {}
    local buf = {}
    local currentbg = 0x000000
    local currentfg = 0xffffff

    for i=1, width*height do
        bufferFG[i] = currentfg
        bufferBG[i] = currentbg
        bufferChar[i] = " "
    end

    function buf.getPos()
        return x, y
    end

    function buf.setPos(nx, ny)
        x = nx
        y = ny
    end

    function buf.getSize()
        return width, height
    end

    function buf.setSize(w, h)
        if w > width then
            local diff = w-width
            for i=1, height do
                for k=diff-1, 0, -1 do
                    --[[table.insert(buffer, i*w-k, {
                        bg = 0x000000,
                        fg = 0xffffff,
                        char = " "
                    })]]
                    table.insert(bufferFG, i*w-k, currentfg)
                    table.insert(bufferBG, i*w-k, currentbg)
                    table.insert(bufferChar, i*w-k, " ")
                end
            end
            width = w
        elseif w < width then
            local diff = width-w
            for i=1, height do
                for k=1, diff do
                    table.remove(bufferFG, i*w+1)
                    table.remove(bufferBG, i*w+1)
                    table.remove(bufferChar, i*w+1)
                end
            end
            width = w
        end

        if h > height then
            local diff = h-height
            for i=0, diff-1 do
                for j=1, width do
                    --[[table.insert(buffer, height*width+(i*width)+j, {
                        bg = 0x000000,
                        fg = 0xffffff,
                        char = " "
                    })]]
                    table.insert(bufferBG, height*width+(i*width)+j, currentbg)
                    table.insert(bufferFG, height*width+(i*width)+j, currentfg)
                    table.insert(bufferChar, height*width+(i*width)+j, " ")
                end
            end
            height = h
        elseif h < height then
            local diff = height-h
            local max = width*height
            for i=1, diff do
                for k=0, width-1 do
                    table.remove(bufferFG, (max-(i*width))+width-k)
                    table.remove(bufferBG, (max-(i*width))+width-k)
                    table.remove(bufferChar, (max-(i*width))+width-k)
                end
            end
            height = h
        end
    end

    local function getParts()
        local used = {}
        for i=1, height do
            used[i] = {}
            for k=1, width do
                used[i][k] = false
            end
        end

        local function setUsed(x, y)
            used[y][x] = true
        end

        local function isUsed(x, y)
            return used[y][x]
        end

        local parts = {}

        for cy=1, height do
            for cx=1, width do
                if not isUsed(cx, cy) then
                    local currentpart = {
                        x = cx,
                        y = cy,
                        txt = " ",
                        bg = currentbg,
                        fg = currentfg,
                        vertical = false
                    }

                    local length_hor = 1
                    local length_ver = 1
                    local pixbg, pixfg, pixchar = buf.getPixel(cx, cy)
                    --get same pixels horizontally
                    for nx=cx+1, width do
                        if not isUsed(nx, cy) then
                            local npixbg, npixfg, npixchar = buf.getPixel(nx, cy)
                            if npixbg == pixbg and (npixfg == pixfg or npixchar == " ") then
                                length_hor = length_hor+1
                            else
                                break
                            end
                        else
                            break
                        end
                    end

                    --get same pixels vertically
                    for ny=cy+1, height do
                        if not isUsed(cx, ny) then
                            local npixbg, npixfg, npixchar = buf.getPixel(cx, ny)
                            if npixbg == pixbg and (npixfg == pixfg or npixchar == " ") then
                                length_ver = length_ver+1
                            else
                                break
                            end
                        else
                            break
                        end
                    end
                    if length_ver > length_hor then
                        currentpart.txt = pixchar
                        currentpart.bg = pixbg
                        currentpart.fg = pixfg
                        currentpart.vertical = true
                        setUsed(cx, cy)
                        for i=1, length_ver-1 do
                            local npixbg, npixfg, npixchar = buf.getPixel(cx, cy+i)
                            currentpart.txt = currentpart.txt..npixchar
                            setUsed(cx, cy+i)
                        end
                    else
                        currentpart.txt = pixchar
                        currentpart.bg = pixbg
                        currentpart.fg = pixfg
                        setUsed(cx, cy)
                        for i=1, length_hor-1 do
                            local npixbg, npixfg, npixchar = buf.getPixel(cx+i, cy)
                            currentpart.txt = currentpart.txt..npixchar
                            setUsed(cx+i, cy)
                        end
                    end

                    table.insert(parts, currentpart)
                end
            end
        end

        return parts
    end

    function buf.draw()
        local parts = getParts()
        local cbg = gpu.getBackground()
        local cfg = gpu.getForeground()

        for each, part in ipairs(parts) do
            if cbg ~= part.bg then
                gpu.setBackground(part.bg)
                cbg = part.bg
            end

            if cfg ~= part.fg then
                gpu.setForeground(part.fg)
                cfg = part.fg
            end

            gpu.set(x+part.x-1, y+part.y-1, part.txt, part.vertical)
        end

    end

    function buf.set(nx, ny, text, vertical)
        if not vertical then
            if nx+#text-1 > width then
                local diff = nx+#text-1-width
                text = string.sub(text, 1, diff)
            end

            for i=1, #text do
                local num = doublebuffer.toTableCoord(nx+i-1, ny, width)
                bufferBG[num] = currentbg
                bufferFG[num] = currentfg
                bufferChar[num] = string.sub(text, i, i)
            end
        else
            if ny+#text-1 > height then
                local diff = ny+#text-1-height
                text = string.sub(text, 1, diff)
            end

            for i=1, #text do
                local num = doublebuffer.toTableCoord(nx, ny+i-1, width)
                bufferBG[num] = currentbg
                bufferFG[num] = currentfg
                bufferChar[num] = string.sub(text, i, i)
            end
        end
    end

    function buf.fill(nx, ny, nw, nh, char)
        for j=ny, ny+nh-1 do
            for i=nx, nx+nw-1 do
                if buf.getPixel(i, j) then
                    local num = doublebuffer.toTableCoord(i, j, width)
                    bufferBG[num] = currentbg
                    bufferFG[num] = currentfg
                    bufferChar[num] = char
                end
            end
        end
    end

    function buf.getPixel(x, y)
        --return buffer[doublebuffer.toTableCoord(x, y, width)]
        local num = doublebuffer.toTableCoord(x, y, width)
        return bufferBG[num], bufferFG[num], bufferChar[num]
    end

    buf.get = buf.getPixel
    buf.getResolution = buf.getSize
    buf.setResolution = buf.setSize
    buf.setDepth = gpu.setDepth
    buf.getDepth = gpu.getDepth
    buf.maxDepth = gpu.maxDepth
    buf.getPaletteColor = gpu.getPaletteColor
    buf.setPaletteColor = gpu.setPaletteColor

    function buf.getForeground()
        return currentfg
    end

    function buf.setForeground(col)
        local old = currentfg
        currentfg = col
        return old
    end

    function buf.getBackground()
        return currentbg
    end

    function buf.setBackground(col)
        local old = currentbg
        currentbg = col
        return old
    end

    buf.gpu = gpu

    function buf.copy(x, y, w, h, offx, offy)
        local cbufBG = {}
        local cbufFG = {}
        local cbufChar = {}

        for i=0, h-1 do
            for j=0, w-1 do
                local numa = (i*w)+j+1
                local numb = (y+i-1)*width + (x+j)
                if numb > 0 and numb <= width*height then
                    cbufBG[numa] = bufferBG[num]
                    cbufFG[numa] = bufferFG[num]
                    cbufChar[numa] = bufferChar[num]
                end
            end
        end

        for i=0, h-1 do
            for j=0, w-1 do
                local numa = (i*w)+j+1
                local numb = (y+i-1+offy)*width + (x+j+offx)
                if numb > 0 and numb <= width*height then
                    bufferBG[numb] = cbufBG[numa]
                    bufferFG[numb] = cbufFG[numa]
                    bufferChar[numb] = cbufChar[numa]
                end
            end
        end
    end

    return setmetatable(buf, {
        __newindex = function(table, key, e)
            error("attempt to change read-only table")
        end,
    })

end

return doublebuffer
