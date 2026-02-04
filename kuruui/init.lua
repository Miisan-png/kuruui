local KuruUI = {
    _VERSION = "0.3.2",
    _NAME = "KuruUI"
}

KuruUI.Element = require("kuruui.element")
KuruUI.Button = require("kuruui.button")
KuruUI.Label = require("kuruui.label")
KuruUI.Panel = require("kuruui.panel")
KuruUI.Slider = require("kuruui.slider")
KuruUI.Checkbox = require("kuruui.checkbox")
KuruUI.TextInput = require("kuruui.textinput")
KuruUI.ProgressBar = require("kuruui.progressbar")
KuruUI.Toggle = require("kuruui.toggle")
KuruUI.Dropdown = require("kuruui.dropdown")
KuruUI.Tooltip = require("kuruui.tooltip")
KuruUI.ScrollArea = require("kuruui.scrollarea")
KuruUI.Tween = require("kuruui.tween")
KuruUI.Theme = require("kuruui.theme")
KuruUI.Tabs = require("kuruui.tabs")
KuruUI.Juice = require("kuruui.juice")

local root = KuruUI.Element:new(0, 0, 0, 0)

local scale = 1
local baseWidth = 800
local baseHeight = 600
local offsetX = 0
local offsetY = 0
local scalingEnabled = false

function KuruUI.enableScaling(width, height)
    baseWidth = width or 800
    baseHeight = height or 600
    scalingEnabled = true
    KuruUI.updateScale()
end

function KuruUI.disableScaling()
    scalingEnabled = false
    scale = 1
    offsetX = 0
    offsetY = 0
end

function KuruUI.updateScale()
    if not scalingEnabled then return end
    local windowW, windowH = love.graphics.getDimensions()
    local scaleX = windowW / baseWidth
    local scaleY = windowH / baseHeight
    scale = math.min(scaleX, scaleY)
    offsetX = (windowW - baseWidth * scale) / 2
    offsetY = (windowH - baseHeight * scale) / 2
end

function KuruUI.getScale()
    return scale, offsetX, offsetY
end

function KuruUI.getBaseSize()
    return baseWidth, baseHeight
end

function KuruUI.toUICoords(x, y)
    if not scalingEnabled then return x, y end
    return (x - offsetX) / scale, (y - offsetY) / scale
end

function KuruUI.toScreenCoords(x, y)
    if not scalingEnabled then return x, y end
    return x * scale + offsetX, y * scale + offsetY
end

function KuruUI.add(element)
    return root:addChild(element)
end

function KuruUI.remove(element)
    return root:removeChild(element)
end

function KuruUI.update(dt)
    KuruUI.Tween.update(dt)
    KuruUI.Tooltip.update(dt)
    root:update(dt)
end

function KuruUI.draw()
    if scalingEnabled then
        love.graphics.push()
        love.graphics.translate(offsetX, offsetY)
        love.graphics.scale(scale, scale)
    end
    root:draw()
    KuruUI.Dropdown.drawAllLists()
    KuruUI.Tooltip.draw()
    if scalingEnabled then
        love.graphics.pop()
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function KuruUI.mousepressed(x, y, button)
    local ux, uy = KuruUI.toUICoords(x, y)
    if KuruUI.Dropdown.handleListClick(ux, uy, button) then
        return true
    end
    return root:mousepressed(ux, uy, button)
end

function KuruUI.mousereleased(x, y, button)
    local ux, uy = KuruUI.toUICoords(x, y)
    return root:mousereleased(ux, uy, button)
end

function KuruUI.wheelmoved(x, y)
    local function propagateWheel(element)
        if element.wheelmoved and element:wheelmoved(x, y) then
            return true
        end
        for _, child in ipairs(element.children) do
            if propagateWheel(child) then
                return true
            end
        end
        return false
    end
    return propagateWheel(root)
end

function KuruUI.keypressed(key)
    return root:keypressed(key)
end

function KuruUI.textinput(text)
    return root:textinput(text)
end

function KuruUI.resize(w, h)
    KuruUI.updateScale()
end

function KuruUI.clear()
    root.children = {}
    KuruUI.Tween.cancelAll()
    KuruUI.Dropdown.closeAll()
    KuruUI.Dropdown.clearAll()
end

function KuruUI.tween(target, props, duration, easing)
    return KuruUI.Tween.to(target, props, duration, easing)
end

function KuruUI.tooltip(element, text)
    return KuruUI.Tooltip.attach(element, text)
end

return KuruUI
