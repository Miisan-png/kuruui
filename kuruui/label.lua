local Element = require("kuruui.element")

local Label = setmetatable({}, {__index = Element})
Label.__index = Label

function Label:new(x, y, text)
    local self = setmetatable(Element.new(self, x, y, 0, 0), Label)
    self.text = text or ""
    self.color = {1, 1, 1, 1}
    self.align = "left"
    return self
end

function Label:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] * self.alpha)
    love.graphics.print(self.text, ax, ay, 0, self.scale, self.scale)
    Element.draw(self)
end

return Label
