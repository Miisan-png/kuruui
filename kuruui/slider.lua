local Element = require("kuruui.element")

local Slider = setmetatable({}, {__index = Element})
Slider.__index = Slider

function Slider:new(x, y, w, h)
    local self = setmetatable(Element.new(self, x, y, w, h or 20), Slider)
    self.value = 0.5
    self.displayValue = 0.5
    self.min = 0
    self.max = 1
    self.dragging = false
    self.colors = {
        track = {0.2, 0.2, 0.2, 1},
        fill = {0.4, 0.6, 0.9, 1},
        knob = {1, 1, 1, 1}
    }
    self.knobRadius = 8
    self.knobScale = 1
    self.animate = true
    return self
end

function Slider:getValue()
    return self.min + (self.max - self.min) * self.value
end

function Slider:setValue(v, animate)
    local newValue = math.max(0, math.min(1, (v - self.min) / (self.max - self.min)))
    if animate and self.animate then
        local Tween = require("kuruui.tween")
        Tween.to(self, {displayValue = newValue}, 0.2, "outQuad")
    else
        self.displayValue = newValue
    end
    self.value = newValue
end

function Slider:update(dt)
    Element.update(self, dt)
    if self.dragging then
        local mx = love.mouse.getPosition()
        local ax = self:getAbsolutePosition()
        self.value = math.max(0, math.min(1, (mx - ax) / self.w))
        self.displayValue = self.value
        if self.onChange then self:onChange(self:getValue()) end
    elseif self.animate then
        self.displayValue = self.displayValue + (self.value - self.displayValue) * 10 * dt
    end
    local targetKnobScale = (self.dragging or self.hovered) and 1.2 or 1
    self.knobScale = self.knobScale + (targetKnobScale - self.knobScale) * 10 * dt
end

function Slider:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    local cy = ay + self.h / 2
    love.graphics.setColor(self.colors.track[1], self.colors.track[2], self.colors.track[3], self.colors.track[4] * self.alpha)
    love.graphics.rectangle("fill", ax, cy - 3, self.w, 6, 3)
    love.graphics.setColor(self.colors.fill[1], self.colors.fill[2], self.colors.fill[3], self.colors.fill[4] * self.alpha)
    love.graphics.rectangle("fill", ax, cy - 3, self.w * self.displayValue, 6, 3)
    love.graphics.setColor(self.colors.knob[1], self.colors.knob[2], self.colors.knob[3], self.colors.knob[4] * self.alpha)
    love.graphics.circle("fill", ax + self.w * self.displayValue, cy, self.knobRadius * self.knobScale)
    Element.draw(self)
end

function Slider:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    if button == 1 and self:contains(x, y) then
        self.dragging = true
        local ax = self:getAbsolutePosition()
        self.value = math.max(0, math.min(1, (x - ax) / self.w))
        self.displayValue = self.value
        if self.onChange then self:onChange(self:getValue()) end
        return true
    end
    return Element.mousepressed(self, x, y, button)
end

function Slider:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = false
    end
    return Element.mousereleased(self, x, y, button)
end

return Slider
