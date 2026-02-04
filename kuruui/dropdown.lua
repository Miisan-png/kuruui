local Element = require("kuruui.element")

local Dropdown = setmetatable({}, {__index = Element})
Dropdown.__index = Dropdown

local openDropdowns = {}

function Dropdown:new(x, y, w, h)
    local self = setmetatable(Element.new(self, x, y, w, h or 32), Dropdown)
    self.options = {}
    self.selected = nil
    self.selectedIndex = 0
    self.open = false
    self.hoveredIndex = 0
    self.placeholder = "Select..."
    self.maxVisible = 5
    self.scrollOffset = 0
    self.optionHeight = h or 32
    self.colors = {
        bg = {0.2, 0.2, 0.2, 1},
        hover = {0.3, 0.3, 0.3, 1},
        selected = {0.4, 0.6, 0.9, 1},
        border = {0.4, 0.4, 0.4, 1},
        text = {1, 1, 1, 1},
        placeholder = {0.6, 0.6, 0.6, 1},
        dropdown = {0.18, 0.18, 0.18, 0.98}
    }
    self.cornerRadius = 4
    self.dropdownAlpha = 0
    return self
end

function Dropdown:setOptions(options)
    self.options = options
    return self
end

function Dropdown:select(index)
    if index >= 1 and index <= #self.options then
        self.selectedIndex = index
        self.selected = self.options[index]
        if self.onChange then self:onChange(self.selected, index) end
    end
    return self
end

function Dropdown:setOpen(state)
    self.open = state
    if state then
        self.dropdownAlpha = 1
        for i = #openDropdowns, 1, -1 do
            if openDropdowns[i] ~= self then
                openDropdowns[i].open = false
            end
        end
        local found = false
        for _, d in ipairs(openDropdowns) do
            if d == self then found = true break end
        end
        if not found then
            table.insert(openDropdowns, self)
        end
    end
end

function Dropdown:getListBounds()
    local ax, ay = self:getAbsolutePosition()
    local listY = ay + self.h + 4
    local visibleCount = math.min(#self.options, self.maxVisible)
    local listHeight = visibleCount * self.optionHeight
    return ax, listY, self.w, listHeight, visibleCount
end

function Dropdown:update(dt)
    Element.update(self, dt)
    local targetAlpha = self.open and 1 or 0
    self.dropdownAlpha = self.dropdownAlpha + (targetAlpha - self.dropdownAlpha) * 15 * dt
    if self.open then
        local mx, my = love.mouse.getPosition()
        local KuruUI = require("kuruui")
        mx, my = KuruUI.toUICoords(mx, my)
        local ax, listY, w, listHeight, visibleCount = self:getListBounds()
        if mx >= ax and mx <= ax + w and my >= listY and my <= listY + listHeight then
            self.hoveredIndex = math.floor((my - listY) / self.optionHeight) + 1 + self.scrollOffset
        else
            self.hoveredIndex = 0
        end
    end
end

function Dropdown:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    love.graphics.setColor(self.colors.bg[1], self.colors.bg[2], self.colors.bg[3], self.colors.bg[4] * self.alpha)
    love.graphics.rectangle("fill", ax, ay, self.w, self.h, self.cornerRadius)
    love.graphics.setColor(self.colors.border[1], self.colors.border[2], self.colors.border[3], self.colors.border[4] * self.alpha)
    love.graphics.rectangle("line", ax, ay, self.w, self.h, self.cornerRadius)
    local displayText = self.selected or self.placeholder
    local textColor = self.selected and self.colors.text or self.colors.placeholder
    love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4] * self.alpha)
    local font = love.graphics.getFont()
    local th = font:getHeight()
    love.graphics.print(displayText, ax + 10, ay + (self.h - th) / 2)
    love.graphics.setColor(self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4] * self.alpha)
    local arrowX = ax + self.w - 20
    local arrowY = ay + self.h / 2
    if self.open then
        love.graphics.polygon("fill", arrowX, arrowY + 3, arrowX + 8, arrowY + 3, arrowX + 4, arrowY - 3)
    else
        love.graphics.polygon("fill", arrowX, arrowY - 3, arrowX + 8, arrowY - 3, arrowX + 4, arrowY + 3)
    end
    Element.draw(self)
end

function Dropdown:drawList()
    if not self.visible or self.alpha <= 0 then return end
    if #self.options == 0 then return end
    if not self.open and self.dropdownAlpha <= 0.01 then return end
    local ax, listY, w, listHeight, visibleCount = self:getListBounds()
    local font = love.graphics.getFont()
    local th = font:getHeight()
    local alpha = self.dropdownAlpha * self.alpha
    love.graphics.setColor(self.colors.dropdown[1], self.colors.dropdown[2], self.colors.dropdown[3], self.colors.dropdown[4] * alpha)
    love.graphics.rectangle("fill", ax, listY, w, listHeight, self.cornerRadius)
    love.graphics.setColor(self.colors.border[1], self.colors.border[2], self.colors.border[3], self.colors.border[4] * alpha)
    love.graphics.rectangle("line", ax, listY, w, listHeight, self.cornerRadius)
    for i = 1, visibleCount do
        local optIndex = i + self.scrollOffset
        if optIndex <= #self.options then
            local optY = listY + (i - 1) * self.optionHeight
            if optIndex == self.hoveredIndex then
                love.graphics.setColor(self.colors.hover[1], self.colors.hover[2], self.colors.hover[3], self.colors.hover[4] * alpha)
                love.graphics.rectangle("fill", ax + 2, optY + 2, w - 4, self.optionHeight - 4, self.cornerRadius - 2)
            elseif optIndex == self.selectedIndex then
                love.graphics.setColor(self.colors.selected[1], self.colors.selected[2], self.colors.selected[3], 0.3 * alpha)
                love.graphics.rectangle("fill", ax + 2, optY + 2, w - 4, self.optionHeight - 4, self.cornerRadius - 2)
            end
            love.graphics.setColor(self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4] * alpha)
            love.graphics.print(self.options[optIndex], ax + 10, optY + (self.optionHeight - th) / 2)
        end
    end
    if #self.options > self.maxVisible then
        local scrollHeight = listHeight * (visibleCount / #self.options)
        local scrollY = listY + (self.scrollOffset / (#self.options - visibleCount)) * (listHeight - scrollHeight)
        love.graphics.setColor(0.4, 0.4, 0.4, 0.5 * alpha)
        love.graphics.rectangle("fill", ax + w - 6, scrollY, 4, scrollHeight, 2)
    end
end

function Dropdown:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    if self:contains(x, y) then
        self:setOpen(not self.open)
        self.pressed = true
        return true
    end
    return Element.mousepressed(self, x, y, button)
end

function Dropdown:wheelmoved(x, y)
    if not self.open then return false end
    local mx, my = love.mouse.getPosition()
    local KuruUI = require("kuruui")
    mx, my = KuruUI.toUICoords(mx, my)
    local ax, listY, w, listHeight, visibleCount = self:getListBounds()
    if mx >= ax and mx <= ax + w and my >= listY and my <= listY + listHeight then
        self.scrollOffset = math.max(0, math.min(#self.options - visibleCount, self.scrollOffset - y))
        return true
    end
    return false
end

function Dropdown.handleListClick(x, y, button)
    for _, dropdown in ipairs(openDropdowns) do
        if dropdown.open and dropdown.visible and dropdown.enabled then
            local ax, listY, w, listHeight, visibleCount = dropdown:getListBounds()
            if x >= ax and x <= ax + w and y >= listY and y <= listY + listHeight then
                local clickedIndex = math.floor((y - listY) / dropdown.optionHeight) + 1 + dropdown.scrollOffset
                if clickedIndex >= 1 and clickedIndex <= #dropdown.options then
                    dropdown:select(clickedIndex)
                    dropdown:setOpen(false)
                    return true
                end
            end
            if not dropdown:contains(x, y) then
                dropdown:setOpen(false)
            end
        end
    end
    return false
end

function Dropdown.drawAllLists()
    for _, dropdown in ipairs(openDropdowns) do
        if dropdown.open or dropdown.dropdownAlpha > 0.01 then
            dropdown:drawList()
        end
    end
end

function Dropdown.closeAll()
    for _, dropdown in ipairs(openDropdowns) do
        dropdown.open = false
    end
end

function Dropdown.clearAll()
    openDropdowns = {}
end

return Dropdown
