local Element = require("kuruui.element")

local Button = setmetatable({}, {__index = Element})
Button.__index = Button

function Button:new(x, y, w, h, text)
    local self = setmetatable(Element.new(self, x, y, w, h), Button)
    self.text = text or "Button"
    self.colors = {
        normal = {0.3, 0.3, 0.3, 1},
        hovered = {0.4, 0.4, 0.4, 1},
        pressed = {0.2, 0.2, 0.2, 1},
        text = {1, 1, 1, 1}
    }
    self.currentColor = {0.3, 0.3, 0.3, 1}
    self.cornerRadius = 4
    self.animateHover = true
    self.animateClick = true
    return self
end

function Button:update(dt)
    Element.update(self, dt)
    if not self.animateHover then return end
    local target = self.colors.normal
    if self.pressed then
        target = self.colors.pressed
    elseif self.hovered then
        target = self.colors.hovered
    end
    local speed = 12 * dt
    for i = 1, 4 do
        self.currentColor[i] = self.currentColor[i] + (target[i] - self.currentColor[i]) * speed
    end
end

function Button:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    local w, h = self.w * self.scale, self.h * self.scale
    local ox = (self.w - w) / 2
    local oy = (self.h - h) / 2
    love.graphics.setColor(self.currentColor[1], self.currentColor[2], self.currentColor[3], self.currentColor[4] * self.alpha)
    love.graphics.rectangle("fill", ax + ox, ay + oy, w, h, self.cornerRadius * self.scale)
    love.graphics.setColor(self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4] * self.alpha)
    local font = love.graphics.getFont()
    local tw = font:getWidth(self.text)
    local th = font:getHeight()
    love.graphics.print(self.text, ax + (self.w - tw) / 2, ay + (self.h - th) / 2)
    Element.draw(self)
end

function Button:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    if self:contains(x, y) and button == 1 then
        self.pressed = true
        if self.animateClick then
            local Tween = require("kuruui.tween")
            Tween.cancel(self)
            Tween.to(self, {scale = 0.95}, 0.1, "outQuad")
        end
        return true
    end
    return Element.mousepressed(self, x, y, button)
end

function Button:mousereleased(x, y, button)
    if not self.visible or not self.enabled then return false end
    local wasPressed = self.pressed
    self.pressed = false
    if self.animateClick then
        local Tween = require("kuruui.tween")
        Tween.cancel(self)
        Tween.to(self, {scale = 1}, 0.2, "outBack")
    end
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

return Button
