local Tooltip = {}
Tooltip.__index = Tooltip

local activeTooltip = nil
local tooltipTimer = 0
local tooltipDelay = 0.5
local tooltipAlpha = 0
local tooltipTarget = nil

local padding = 8
local cornerRadius = 4
local maxWidth = 250

function Tooltip.attach(element, text)
    element._tooltip = text
    local originalUpdate = element.update
    element.update = function(self, dt)
        originalUpdate(self, dt)
        if self.hovered and self._tooltip then
            if tooltipTarget ~= self then
                tooltipTarget = self
                tooltipTimer = 0
                tooltipAlpha = 0
            end
            tooltipTimer = tooltipTimer + dt
            if tooltipTimer >= tooltipDelay then
                activeTooltip = self._tooltip
                tooltipAlpha = math.min(1, tooltipAlpha + dt * 8)
            end
        elseif tooltipTarget == self then
            tooltipTarget = nil
            activeTooltip = nil
            tooltipAlpha = 0
        end
    end
    return element
end

function Tooltip.detach(element)
    element._tooltip = nil
    return element
end

function Tooltip.setDelay(delay)
    tooltipDelay = delay
end

function Tooltip.update(dt)
    if not tooltipTarget then
        tooltipAlpha = math.max(0, tooltipAlpha - dt * 8)
        if tooltipAlpha <= 0 then
            activeTooltip = nil
        end
    end
end

function Tooltip.draw()
    if not activeTooltip or tooltipAlpha <= 0 then return end
    local KuruUI = require("kuruui")
    local Theme = KuruUI.Theme
    local mx, my = love.mouse.getPosition()
    mx, my = KuruUI.toUICoords(mx, my)
    local font = love.graphics.getFont()
    local lines = {}
    local currentLine = ""
    for word in activeTooltip:gmatch("%S+") do
        local testLine = currentLine == "" and word or currentLine .. " " .. word
        if font:getWidth(testLine) > maxWidth - padding * 2 then
            if currentLine ~= "" then
                table.insert(lines, currentLine)
            end
            currentLine = word
        else
            currentLine = testLine
        end
    end
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    if #lines == 0 then
        lines = {activeTooltip}
    end
    local textHeight = #lines * font:getHeight()
    local textWidth = 0
    for _, line in ipairs(lines) do
        textWidth = math.max(textWidth, font:getWidth(line))
    end
    local w = textWidth + padding * 2
    local h = textHeight + padding * 2
    local x = mx + 15
    local y = my + 15
    local screenW, screenH = 800, 600
    if x + w > screenW then x = mx - w - 5 end
    if y + h > screenH then y = my - h - 5 end
    local bgColor = Theme.color("tooltip")
    local borderColor = Theme.color("tooltipBorder")
    local textColor = Theme.color("tooltipText")
    local radius = Theme.cornerRadius()
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] * tooltipAlpha)
    love.graphics.rectangle("fill", x, y, w, h, radius)
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] * tooltipAlpha)
    love.graphics.rectangle("line", x, y, w, h, radius)
    love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4] * tooltipAlpha)
    for i, line in ipairs(lines) do
        love.graphics.print(line, x + padding, y + padding + (i - 1) * font:getHeight())
    end
end

return Tooltip
