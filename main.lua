local KuruUI = require("kuruui")
local Theme = KuruUI.Theme

local demos = {
    {name = "Menu", module = nil, path = "demos.menu"},
    {name = "Showcase", module = nil, path = "demos.showcase"},
}

local currentDemo = nil
local currentIndex = 0
local font
local switchLabel

function love.load()
    font = love.graphics.newFont("pixel.ttf", 13)
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    KuruUI.enableScaling(800, 600)

    for i, demo in ipairs(demos) do
        demo.module = require(demo.path)
    end

    switchDemo(1)
end

function switchDemo(index)
    if currentDemo then
        currentDemo.unload()
    end
    currentIndex = index
    currentDemo = demos[index].module
    currentDemo.load(font)
    love.graphics.setBackgroundColor(Theme.color("background"))
end

function love.update(dt)
    if currentDemo then
        currentDemo.update(dt)
    end
end

function love.draw()
    if currentDemo then
        currentDemo.draw()
    end

    local s, ox, oy = KuruUI.getScale()
    love.graphics.push()
    love.graphics.translate(ox, oy)
    love.graphics.scale(s, s)
    love.graphics.setColor(1, 1, 1, 0.3)
    local hint = "[Tab] " .. demos[currentIndex].name
    local hw = font:getWidth(hint)
    love.graphics.print(hint, 400 - hw / 2, 8)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function love.mousepressed(x, y, button)
    if currentDemo then
        currentDemo.mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if currentDemo then
        currentDemo.mousereleased(x, y, button)
    end
end

function love.wheelmoved(x, y)
    if currentDemo then
        currentDemo.wheelmoved(x, y)
    end
end

function love.keypressed(key)
    if key == "tab" then
        local next = (currentIndex % #demos) + 1
        switchDemo(next)
        return
    end
    if key == "escape" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            KuruUI.updateScale()
        else
            love.event.quit()
        end
        return
    end
    if currentDemo then
        currentDemo.keypressed(key)
    end
end

function love.textinput(text)
    if currentDemo then
        currentDemo.textinput(text)
    end
end

function love.resize(w, h)
    KuruUI.resize(w, h)
end
