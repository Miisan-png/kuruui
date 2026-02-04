local Element = require("kuruui.element")

local ProgressBar = setmetatable({}, {__index = Element})
ProgressBar.__index = ProgressBar

function ProgressBar:new(x, y, w, h)
    local self = setmetatable(Element.new(self, x, y, w, h or 20), ProgressBar)
    self.value = 1
    self.displayValue = 1
    self.min = 0
    self.max = 1
    self.colors = {
        bg = {0.15, 0.15, 0.15, 1},
        fill = {0.4, 0.6, 0.9, 1},
        border = {0.3, 0.3, 0.3, 1},
        text = {1, 1, 1, 1}
    }
    self.cornerRadius = 4
    self.border = true
    self.showText = false
    self.textFormat = "percent"
    self.animate = true
    self.animationSpeed = 8
    self.segments = 0
    self.glow = false
    self.glowAmount = 0
    self.pulseOnLow = false
    self.pulseThreshold = 0.25
    self.pulseTime = 0
    return self
end

function ProgressBar:getValue()
    return self.min + (self.max - self.min) * self.value
end

function ProgressBar:getNormalized()
    return self.value
end

function ProgressBar:setValue(v, instant)
    self.value = math.max(0, math.min(1, (v - self.min) / (self.max - self.min)))
    if instant then
        self.displayValue = self.value
    end
end

function ProgressBar:setValueNormalized(v, instant)
    self.value = math.max(0, math.min(1, v))
    if instant then
        self.displayValue = self.value
    end
end

function ProgressBar:tweenTo(v, duration, easing)
    local Tween = require("kuruui.tween")
    local normalized = math.max(0, math.min(1, (v - self.min) / (self.max - self.min)))
    self.value = normalized
    return Tween.to(self, {displayValue = normalized}, duration or 0.3, easing or "outQuad")
end

function ProgressBar:update(dt)
    Element.update(self, dt)
    if self.animate then
        local diff = self.value - self.displayValue
        self.displayValue = self.displayValue + diff * self.animationSpeed * dt
        if math.abs(diff) < 0.001 then
            self.displayValue = self.value
        end
    else
        self.displayValue = self.value
    end
    if self.glow then
        self.glowAmount = (math.sin(love.timer.getTime() * 3) + 1) / 2 * 0.3
    end
    if self.pulseOnLow and self.value <= self.pulseThreshold then
        self.pulseTime = self.pulseTime + dt * 4
    else
        self.pulseTime = 0
    end
end

function ProgressBar:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    local pulseAlpha = 1
    if self.pulseOnLow and self.value <= self.pulseThreshold then
        pulseAlpha = 0.6 + math.sin(self.pulseTime) * 0.4
    end
    love.graphics.setColor(
        self.colors.bg[1],
        self.colors.bg[2],
        self.colors.bg[3],
        self.colors.bg[4] * self.alpha
    )
    love.graphics.rectangle("fill", ax, ay, self.w, self.h, self.cornerRadius)
    local fillWidth = self.w * self.displayValue
    if fillWidth > 0 then
        if self.glow then
            love.graphics.setColor(
                self.colors.fill[1],
                self.colors.fill[2],
                self.colors.fill[3],
                self.glowAmount * self.alpha * pulseAlpha
            )
            love.graphics.rectangle("fill", ax - 2, ay - 2, fillWidth + 4, self.h + 4, self.cornerRadius + 2)
        end
        love.graphics.setColor(
            self.colors.fill[1],
            self.colors.fill[2],
            self.colors.fill[3],
            self.colors.fill[4] * self.alpha * pulseAlpha
        )
        if self.segments > 0 then
            local segWidth = self.w / self.segments
            local gap = 2
            for i = 0, self.segments - 1 do
                local segStart = i * segWidth
                local segEnd = segStart + segWidth - gap
                if segStart < fillWidth then
                    local drawWidth = math.min(segEnd, fillWidth) - segStart
                    if drawWidth > 0 then
                        love.graphics.rectangle("fill", ax + segStart + 1, ay + 1, drawWidth - 1, self.h - 2, self.cornerRadius - 1)
                    end
                end
            end
        else
            love.graphics.rectangle("fill", ax + 1, ay + 1, fillWidth - 2, self.h - 2, self.cornerRadius - 1)
        end
    end
    if self.border then
        love.graphics.setColor(
            self.colors.border[1],
            self.colors.border[2],
            self.colors.border[3],
            self.colors.border[4] * self.alpha
        )
        love.graphics.rectangle("line", ax, ay, self.w, self.h, self.cornerRadius)
    end
    if self.showText then
        local text
        if self.textFormat == "percent" then
            text = math.floor(self.displayValue * 100) .. "%"
        elseif self.textFormat == "value" then
            text = math.floor(self:getValue())
        elseif self.textFormat == "fraction" then
            text = math.floor(self:getValue()) .. "/" .. math.floor(self.max)
        elseif type(self.textFormat) == "function" then
            text = self.textFormat(self)
        else
            text = tostring(self.textFormat)
        end
        love.graphics.setColor(
            self.colors.text[1],
            self.colors.text[2],
            self.colors.text[3],
            self.colors.text[4] * self.alpha
        )
        local font = love.graphics.getFont()
        local tw = font:getWidth(text)
        local th = font:getHeight()
        love.graphics.print(text, ax + (self.w - tw) / 2, ay + (self.h - th) / 2)
    end
    Element.draw(self)
end

function ProgressBar:setColorByValue()
    if self.value > 0.6 then
        self.colors.fill = {0.3, 0.7, 0.4, 1}
    elseif self.value > 0.3 then
        self.colors.fill = {0.8, 0.7, 0.2, 1}
    else
        self.colors.fill = {0.8, 0.3, 0.3, 1}
    end
end

return ProgressBar
