local Element = {}
Element.__index = Element

function Element:new(x, y, w, h)
    local self = setmetatable({}, Element)
    self.x = x or 0
    self.y = y or 0
    self.w = w or 100
    self.h = h or 30
    self.visible = true
    self.hovered = false
    self.pressed = false
    self.enabled = true
    self.children = {}
    self.parent = nil
    self.alpha = 1
    self.scale = 1
    self.originX = 0
    self.originY = 0
    return self
end

function Element:contains(px, py)
    local ax, ay = self:getAbsolutePosition()
    local w, h = self.w * self.scale, self.h * self.scale
    return px >= ax and px <= ax + w and py >= ay and py <= ay + h
end

function Element:getAbsolutePosition()
    local x, y = self.x, self.y
    if self.parent then
        local px, py = self.parent:getAbsolutePosition()
        x, y = x + px, y + py
    end
    return x, y
end

function Element:addChild(child)
    child.parent = self
    table.insert(self.children, child)
    return child
end

function Element:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            return true
        end
    end
    return false
end

function Element:update(dt)
    if not self.visible or not self.enabled then return end
    local mx, my = love.mouse.getPosition()
    local KuruUI = require("kuruui")
    mx, my = KuruUI.toUICoords(mx, my)
    self.hovered = self:contains(mx, my)
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

function Element:draw()
    if not self.visible or self.alpha <= 0 then return end
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

function Element:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    for i = #self.children, 1, -1 do
        if self.children[i]:mousepressed(x, y, button) then
            return true
        end
    end
    if self:contains(x, y) then
        self.pressed = true
        return true
    end
    return false
end

function Element:mousereleased(x, y, button)
    if not self.visible or not self.enabled then return false end
    local wasPressed = self.pressed
    self.pressed = false
    for i = #self.children, 1, -1 do
        if self.children[i]:mousereleased(x, y, button) then
            return true
        end
    end
    if wasPressed and self:contains(x, y) then
        if self.onClick then self:onClick() end
        return true
    end
    return false
end

function Element:keypressed(key)
    for _, child in ipairs(self.children) do
        if child:keypressed(key) then return true end
    end
    return false
end

function Element:textinput(text)
    for _, child in ipairs(self.children) do
        if child:textinput(text) then return true end
    end
    return false
end

function Element:fadeIn(duration, easing)
    local Tween = require("kuruui.tween")
    self.alpha = 0
    self.visible = true
    return Tween.to(self, {alpha = 1}, duration or 0.3, easing or "outQuad")
end

function Element:fadeOut(duration, easing)
    local Tween = require("kuruui.tween")
    return Tween.to(self, {alpha = 0}, duration or 0.3, easing or "outQuad")
        :setOnComplete(function() self.visible = false end)
end

function Element:slideTo(x, y, duration, easing)
    local Tween = require("kuruui.tween")
    return Tween.to(self, {x = x, y = y}, duration or 0.3, easing or "outQuad")
end

function Element:scaleTo(s, duration, easing)
    local Tween = require("kuruui.tween")
    return Tween.to(self, {scale = s}, duration or 0.3, easing or "outBack")
end

function Element:pop(duration)
    local Tween = require("kuruui.tween")
    self.scale = 0.8
    return Tween.to(self, {scale = 1}, duration or 0.2, "outBack")
end

return Element
