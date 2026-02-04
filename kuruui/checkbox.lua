local Element = require("kuruui.element")

local Checkbox = setmetatable({}, {__index = Element})
Checkbox.__index = Checkbox

function Checkbox:new(x, y, text)
    local self = setmetatable(Element.new(self, x, y, 20, 20), Checkbox)
    self.text = text or ""
    self.checked = false
    self.checkScale = 0
    self.colors = {
        box = {0.3, 0.3, 0.3, 1},
        checked = {0.4, 0.6, 0.9, 1},
        check = {1, 1, 1, 1},
        text = {1, 1, 1, 1}
    }
    self.currentColor = {0.3, 0.3, 0.3, 1}
    return self
end

function Checkbox:update(dt)
    Element.update(self, dt)
    local target = self.checked and self.colors.checked or self.colors.box
    local targetCheck = self.checked and 1 or 0
    local speed = 12 * dt
    for i = 1, 4 do
        self.currentColor[i] = self.currentColor[i] + (target[i] - self.currentColor[i]) * speed
    end
    self.checkScale = self.checkScale + (targetCheck - self.checkScale) * speed
end

function Checkbox:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    love.graphics.setColor(self.currentColor[1], self.currentColor[2], self.currentColor[3], self.currentColor[4] * self.alpha)
    love.graphics.rectangle("fill", ax, ay, self.w, self.h, 4)
    if self.checkScale > 0.01 then
        love.graphics.setColor(self.colors.check[1], self.colors.check[2], self.colors.check[3], self.colors.check[4] * self.alpha)
        love.graphics.setLineWidth(2)
        local cx, cy = ax + self.w / 2, ay + self.h / 2
        local s = self.checkScale
        love.graphics.line(
            cx - 6 * s, cy,
            cx - 2 * s, cy + 4 * s,
            cx + 6 * s, cy - 4 * s
        )
        love.graphics.setLineWidth(1)
    end
    if self.text ~= "" then
        love.graphics.setColor(self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4] * self.alpha)
        love.graphics.print(self.text, ax + self.w + 8, ay + 2)
    end
    Element.draw(self)
end

function Checkbox:mousereleased(x, y, button)
    if not self.visible or not self.enabled then return false end
    if self.pressed and self:contains(x, y) then
        self.checked = not self.checked
        self.pressed = false
        if self.onChange then self:onChange(self.checked) end
        return true
    end
    self.pressed = false
    return Element.mousereleased(self, x, y, button)
end

return Checkbox
