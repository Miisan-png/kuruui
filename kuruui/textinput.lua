local Element = require("kuruui.element")

local TextInput = setmetatable({}, {__index = Element})
TextInput.__index = TextInput

function TextInput:new(x, y, w, h)
    local self = setmetatable(Element.new(self, x, y, w, h or 30), TextInput)
    self.text = ""
    self.placeholder = ""
    self.focused = false
    self.cursorPos = 0
    self.cursorBlink = 0
    self.colors = {
        bg = {0.15, 0.15, 0.15, 1},
        border = {0.3, 0.3, 0.3, 1},
        focused = {0.4, 0.6, 0.9, 1},
        text = {1, 1, 1, 1},
        placeholder = {0.5, 0.5, 0.5, 1},
        cursor = {1, 1, 1, 1}
    }
    self.borderColor = {0.3, 0.3, 0.3, 1}
    return self
end

function TextInput:update(dt)
    Element.update(self, dt)
    if self.focused then
        self.cursorBlink = (self.cursorBlink + dt * 2) % 1
    end
    local target = self.focused and self.colors.focused or self.colors.border
    local speed = 12 * dt
    for i = 1, 4 do
        self.borderColor[i] = self.borderColor[i] + (target[i] - self.borderColor[i]) * speed
    end
end

function TextInput:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    love.graphics.setColor(self.colors.bg[1], self.colors.bg[2], self.colors.bg[3], self.colors.bg[4] * self.alpha)
    love.graphics.rectangle("fill", ax, ay, self.w, self.h, 4)
    love.graphics.setColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4] * self.alpha)
    love.graphics.setLineWidth(self.focused and 2 or 1)
    love.graphics.rectangle("line", ax, ay, self.w, self.h, 4)
    love.graphics.setLineWidth(1)
    local displayText = self.text
    local textColor = self.colors.text
    if displayText == "" and not self.focused then
        displayText = self.placeholder
        textColor = self.colors.placeholder
    end
    love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4] * self.alpha)
    local font = love.graphics.getFont()
    local th = font:getHeight()
    love.graphics.setScissor(ax + 4, ay, self.w - 8, self.h)
    love.graphics.print(displayText, ax + 8, ay + (self.h - th) / 2)
    love.graphics.setScissor()
    if self.focused and self.cursorBlink < 0.5 then
        local cursorX = ax + 8 + font:getWidth(self.text:sub(1, self.cursorPos))
        love.graphics.setColor(self.colors.cursor[1], self.colors.cursor[2], self.colors.cursor[3], self.colors.cursor[4] * self.alpha)
        love.graphics.rectangle("fill", cursorX, ay + 6, 2, self.h - 12)
    end
    Element.draw(self)
end

function TextInput:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    local wasFocused = self.focused
    self.focused = self:contains(x, y)
    if self.focused and not wasFocused then
        self.cursorPos = #self.text
        self.cursorBlink = 0
    end
    return Element.mousepressed(self, x, y, button)
end

function TextInput:keypressed(key)
    if not self.focused then return false end
    if key == "backspace" then
        if self.cursorPos > 0 then
            self.text = self.text:sub(1, self.cursorPos - 1) .. self.text:sub(self.cursorPos + 1)
            self.cursorPos = self.cursorPos - 1
            if self.onChange then self:onChange(self.text) end
        end
    elseif key == "delete" then
        if self.cursorPos < #self.text then
            self.text = self.text:sub(1, self.cursorPos) .. self.text:sub(self.cursorPos + 2)
            if self.onChange then self:onChange(self.text) end
        end
    elseif key == "left" then
        self.cursorPos = math.max(0, self.cursorPos - 1)
    elseif key == "right" then
        self.cursorPos = math.min(#self.text, self.cursorPos + 1)
    elseif key == "home" then
        self.cursorPos = 0
    elseif key == "end" then
        self.cursorPos = #self.text
    elseif key == "return" then
        if self.onSubmit then self:onSubmit(self.text) end
    end
    self.cursorBlink = 0
    return true
end

function TextInput:textinput(text)
    if not self.focused then return false end
    self.text = self.text:sub(1, self.cursorPos) .. text .. self.text:sub(self.cursorPos + 1)
    self.cursorPos = self.cursorPos + #text
    self.cursorBlink = 0
    if self.onChange then self:onChange(self.text) end
    return true
end

return TextInput
