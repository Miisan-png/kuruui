local Element = require("kuruui.element")

local Panel = setmetatable({}, {__index = Element})
Panel.__index = Panel

function Panel:new(x, y, w, h)
    local self = setmetatable(Element.new(self, x, y, w, h), Panel)
    self.color = {0.15, 0.15, 0.15, 0.95}
    self.borderColor = {0.3, 0.3, 0.3, 1}
    self.cornerRadius = 6
    self.border = true
    return self
end

function Panel:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    local w, h = self.w * self.scale, self.h * self.scale
    local ox = (self.w - w) / 2
    local oy = (self.h - h) / 2
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] * self.alpha)
    love.graphics.rectangle("fill", ax + ox, ay + oy, w, h, self.cornerRadius * self.scale)
    if self.border then
        love.graphics.setColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4] * self.alpha)
        love.graphics.rectangle("line", ax + ox, ay + oy, w, h, self.cornerRadius * self.scale)
    end
    Element.draw(self)
end

function Panel:slideIn(from, duration, easing)
    local Tween = require("kuruui.tween")
    local targetX, targetY = self.x, self.y
    if from == "left" then
        self.x = -self.w
    elseif from == "right" then
        self.x = love.graphics.getWidth()
    elseif from == "top" then
        self.y = -self.h
    elseif from == "bottom" then
        self.y = love.graphics.getHeight()
    end
    self.visible = true
    return Tween.to(self, {x = targetX, y = targetY}, duration or 0.4, easing or "outCubic")
end

function Panel:slideOut(to, duration, easing)
    local Tween = require("kuruui.tween")
    local targetX, targetY = self.x, self.y
    if to == "left" then
        targetX = -self.w
    elseif to == "right" then
        targetX = love.graphics.getWidth()
    elseif to == "top" then
        targetY = -self.h
    elseif to == "bottom" then
        targetY = love.graphics.getHeight()
    end
    return Tween.to(self, {x = targetX, y = targetY}, duration or 0.4, easing or "inCubic")
        :setOnComplete(function() self.visible = false end)
end

return Panel
