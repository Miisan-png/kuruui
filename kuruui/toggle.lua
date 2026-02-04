local Element = require("kuruui.element")

local Toggle = setmetatable({}, {__index = Element})
Toggle.__index = Toggle

function Toggle:new(x, y, text)
    local self = setmetatable(Element.new(self, x, y, 50, 26), Toggle)
    self.text = text or ""
    self.on = false
    self.knobX = 3
    self.colors = {
        off = {0.3, 0.3, 0.3, 1},
        on = {0.4, 0.6, 0.9, 1},
        knob = {1, 1, 1, 1},
        text = {1, 1, 1, 1}
    }
    self.currentColor = {0.3, 0.3, 0.3, 1}
    return self
end

function Toggle:update(dt)
    Element.update(self, dt)
    local target = self.on and self.colors.on or self.colors.off
    local targetX = self.on and (self.w - self.h + 3) or 3
    local speed = 12 * dt
    for i = 1, 4 do
        self.currentColor[i] = self.currentColor[i] + (target[i] - self.currentColor[i]) * speed
    end
    self.knobX = self.knobX + (targetX - self.knobX) * speed
end

function Toggle:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    love.graphics.setColor(self.currentColor[1], self.currentColor[2], self.currentColor[3], self.currentColor[4] * self.alpha)
    love.graphics.rectangle("fill", ax, ay, self.w, self.h, self.h / 2)
    love.graphics.setColor(self.colors.knob[1], self.colors.knob[2], self.colors.knob[3], self.colors.knob[4] * self.alpha)
    love.graphics.circle("fill", ax + self.knobX + (self.h - 6) / 2, ay + self.h / 2, (self.h - 6) / 2)
    if self.text ~= "" then
        love.graphics.setColor(self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4] * self.alpha)
        love.graphics.print(self.text, ax + self.w + 10, ay + 4)
    end
    Element.draw(self)
end

function Toggle:mousereleased(x, y, button)
    if not self.visible or not self.enabled then return false end
    if self.pressed and self:contains(x, y) then
        self.on = not self.on
        self.pressed = false
        if self.onChange then self:onChange(self.on) end
        return true
    end
    self.pressed = false
    return Element.mousereleased(self, x, y, button)
end

return Toggle
