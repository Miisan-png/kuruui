local Element = require("kuruui.element")

local Tabs = setmetatable({}, {__index = Element})
Tabs.__index = Tabs

function Tabs:new(x, y, w, h)
    local self = setmetatable(Element.new(self, x, y, w, h), Tabs)
    self.tabs = {}
    self.activeIndex = 1
    self.tabHeight = 32
    self.indicatorX = 0
    self.indicatorWidth = 0
    self.contentAlpha = 1
    self.colors = {
        bar = {0.12, 0.12, 0.12, 1},
        tab = {0.18, 0.18, 0.18, 1},
        tabHover = {0.25, 0.25, 0.25, 1},
        tabActive = {0.20, 0.20, 0.20, 1},
        indicator = {0.40, 0.60, 0.90, 1},
        text = {0.70, 0.70, 0.70, 1},
        textActive = {1, 1, 1, 1},
        content = {0.15, 0.15, 0.15, 1}
    }
    self.hoveredTab = 0
    self.cornerRadius = 4
    return self
end

function Tabs:addTab(name)
    local tab = {
        name = name,
        children = {}
    }
    table.insert(self.tabs, tab)
    if #self.tabs == 1 then
        self:updateIndicator(true)
    end
    return tab
end

function Tabs:getTab(index)
    return self.tabs[index]
end

function Tabs:getActiveTab()
    return self.tabs[self.activeIndex]
end

function Tabs:addToTab(tabIndex, element)
    if self.tabs[tabIndex] then
        element.parent = self
        element._tabIndex = tabIndex
        table.insert(self.tabs[tabIndex].children, element)
    end
    return element
end

function Tabs:addToActiveTab(element)
    return self:addToTab(self.activeIndex, element)
end

function Tabs:getTabWidth()
    if #self.tabs == 0 then return 0 end
    return self.w / #self.tabs
end

function Tabs:updateIndicator(instant)
    local tabWidth = self:getTabWidth()
    local targetX = (self.activeIndex - 1) * tabWidth
    if instant then
        self.indicatorX = targetX
        self.indicatorWidth = tabWidth
    else
        local Tween = require("kuruui.tween")
        Tween.to(self, {indicatorX = targetX, indicatorWidth = tabWidth}, 0.25, "outCubic")
    end
end

function Tabs:setActive(index)
    if index < 1 or index > #self.tabs then return end
    if index == self.activeIndex then return end
    local Tween = require("kuruui.tween")
    Tween.to(self, {contentAlpha = 0}, 0.08, "outQuad"):setOnComplete(function()
        self.activeIndex = index
        self:updateIndicator()
        Tween.to(self, {contentAlpha = 1}, 0.12, "outQuad")
    end)
    if self.onChange then
        self:onChange(index, self.tabs[index].name)
    end
end

function Tabs:getContentBounds()
    local ax, ay = self:getAbsolutePosition()
    return ax, ay + self.tabHeight, self.w, self.h - self.tabHeight
end

function Tabs:update(dt)
    if not self.visible or not self.enabled then return end
    local mx, my = love.mouse.getPosition()
    local KuruUI = require("kuruui")
    mx, my = KuruUI.toUICoords(mx, my)
    local ax, ay = self:getAbsolutePosition()
    self.hovered = mx >= ax and mx <= ax + self.w and my >= ay and my <= ay + self.h
    self.hoveredTab = 0
    if my >= ay and my <= ay + self.tabHeight then
        local tabWidth = self:getTabWidth()
        for i = 1, #self.tabs do
            local tabX = ax + (i - 1) * tabWidth
            if mx >= tabX and mx < tabX + tabWidth then
                self.hoveredTab = i
                break
            end
        end
    end
    local tab = self:getActiveTab()
    if tab then
        local cx, cy = self:getContentBounds()
        local contentMx = mx - cx
        local contentMy = my - cy
        for _, child in ipairs(tab.children) do
            if child.update then
                child.hovered = contentMx >= child.x and contentMx <= child.x + child.w and
                               contentMy >= child.y and contentMy <= child.y + child.h
                if child.colors and child.currentColor then
                    local target = child.colors.normal
                    if child.pressed and child.colors.pressed then
                        target = child.colors.pressed
                    elseif child.hovered and child.colors.hovered then
                        target = child.colors.hovered
                    end
                    if target then
                        local speed = 12 * dt
                        for i = 1, 4 do
                            if child.currentColor[i] and target[i] then
                                child.currentColor[i] = child.currentColor[i] + (target[i] - child.currentColor[i]) * speed
                            end
                        end
                    end
                end
            end
        end
    end
end

function Tabs:drawElement(element, ox, oy)
    if not element.visible or (element.alpha and element.alpha <= 0) then return end
    local x = ox + element.x
    local y = oy + element.y
    local alpha = (element.alpha or 1) * self.contentAlpha * self.alpha
    if element.color and not element.currentColor then
        love.graphics.setColor(element.color[1], element.color[2], element.color[3], (element.color[4] or 1) * alpha)
        if element.w and element.h and element.w > 0 and element.h > 0 then
            love.graphics.rectangle("fill", x, y, element.w, element.h, element.cornerRadius or 0)
            if element.borderColor then
                love.graphics.setColor(element.borderColor[1], element.borderColor[2], element.borderColor[3], (element.borderColor[4] or 1) * alpha)
                love.graphics.rectangle("line", x, y, element.w, element.h, element.cornerRadius or 0)
            end
        end
    end
    if element.currentColor then
        love.graphics.setColor(element.currentColor[1], element.currentColor[2], element.currentColor[3], (element.currentColor[4] or 1) * alpha)
        love.graphics.rectangle("fill", x, y, element.w, element.h, element.cornerRadius or 0)
    end
    if element.text then
        local textColor = (element.colors and element.colors.text) or element.color or {1, 1, 1, 1}
        love.graphics.setColor(textColor[1], textColor[2], textColor[3], (textColor[4] or 1) * alpha)
        local font = love.graphics.getFont()
        local tw = font:getWidth(element.text)
        local th = font:getHeight()
        if element.w and element.h then
            love.graphics.print(element.text, x + (element.w - tw) / 2, y + (element.h - th) / 2)
        else
            love.graphics.print(element.text, x, y)
        end
    end
    if element.displayValue ~= nil and element.colors then
        love.graphics.setColor(element.colors.bg[1], element.colors.bg[2], element.colors.bg[3], (element.colors.bg[4] or 1) * alpha)
        love.graphics.rectangle("fill", x, y, element.w, element.h, element.cornerRadius or 0)
        if element.displayValue > 0 then
            love.graphics.setColor(element.colors.fill[1], element.colors.fill[2], element.colors.fill[3], (element.colors.fill[4] or 1) * alpha)
            love.graphics.rectangle("fill", x + 1, y + 1, (element.w - 2) * element.displayValue, element.h - 2, element.cornerRadius or 0)
        end
        if element.showText and element.textFormat then
            local text
            if type(element.textFormat) == "function" then
                text = element.textFormat(element)
            elseif element.textFormat == "percent" then
                text = math.floor(element.displayValue * 100) .. "%"
            end
            if text then
                love.graphics.setColor(element.colors.text[1], element.colors.text[2], element.colors.text[3], (element.colors.text[4] or 1) * alpha)
                local font = love.graphics.getFont()
                local tw = font:getWidth(text)
                local th = font:getHeight()
                love.graphics.print(text, x + (element.w - tw) / 2, y + (element.h - th) / 2)
            end
        end
    end
end

function Tabs:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    love.graphics.setColor(self.colors.bar[1], self.colors.bar[2], self.colors.bar[3], self.colors.bar[4] * self.alpha)
    love.graphics.rectangle("fill", ax, ay, self.w, self.tabHeight, self.cornerRadius, self.cornerRadius, 0, 0)
    local tabWidth = self:getTabWidth()
    local font = love.graphics.getFont()
    for i, tab in ipairs(self.tabs) do
        local tabX = ax + (i - 1) * tabWidth
        if self.hoveredTab == i and i ~= self.activeIndex then
            love.graphics.setColor(self.colors.tabHover[1], self.colors.tabHover[2], self.colors.tabHover[3], self.colors.tabHover[4] * self.alpha)
            love.graphics.rectangle("fill", tabX, ay, tabWidth, self.tabHeight)
        end
        local textColor = i == self.activeIndex and self.colors.textActive or self.colors.text
        love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4] * self.alpha)
        local tw = font:getWidth(tab.name)
        local th = font:getHeight()
        love.graphics.print(tab.name, tabX + (tabWidth - tw) / 2, ay + (self.tabHeight - th) / 2)
    end
    if #self.tabs > 0 then
        love.graphics.setColor(self.colors.indicator[1], self.colors.indicator[2], self.colors.indicator[3], self.colors.indicator[4] * self.alpha)
        love.graphics.rectangle("fill", ax + self.indicatorX, ay + self.tabHeight - 3, self.indicatorWidth, 3)
    end
    local cx, cy, cw, ch = self:getContentBounds()
    love.graphics.setColor(self.colors.content[1], self.colors.content[2], self.colors.content[3], self.colors.content[4] * self.alpha)
    love.graphics.rectangle("fill", cx, cy, cw, ch, 0, 0, self.cornerRadius, self.cornerRadius)
    local tab = self:getActiveTab()
    if tab and self.contentAlpha > 0 then
        local KuruUI = require("kuruui")
        local scale, scOffsetX, scOffsetY = KuruUI.getScale()
        love.graphics.setScissor(cx * scale + scOffsetX, cy * scale + scOffsetY, cw * scale, ch * scale)
        for _, child in ipairs(tab.children) do
            self:drawElement(child, cx, cy)
        end
        love.graphics.setScissor()
    end
end

function Tabs:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    local ax, ay = self:getAbsolutePosition()
    if y >= ay and y <= ay + self.tabHeight then
        local tabWidth = self:getTabWidth()
        for i = 1, #self.tabs do
            local tabX = ax + (i - 1) * tabWidth
            if x >= tabX and x < tabX + tabWidth then
                self:setActive(i)
                return true
            end
        end
    end
    local cx, cy, cw, ch = self:getContentBounds()
    if x >= cx and x < cx + cw and y >= cy and y < cy + ch then
        local tab = self:getActiveTab()
        if tab then
            local contentX = x - cx
            local contentY = y - cy
            for i = #tab.children, 1, -1 do
                local child = tab.children[i]
                if contentX >= child.x and contentX <= child.x + child.w and
                   contentY >= child.y and contentY <= child.y + child.h then
                    child.pressed = true
                    return true
                end
            end
        end
    end
    return false
end

function Tabs:mousereleased(x, y, button)
    if not self.visible or not self.enabled then return false end
    local cx, cy = self:getContentBounds()
    local tab = self:getActiveTab()
    if tab then
        local contentX = x - cx
        local contentY = y - cy
        for _, child in ipairs(tab.children) do
            local wasPressed = child.pressed
            child.pressed = false
            if wasPressed and contentX >= child.x and contentX <= child.x + child.w and
               contentY >= child.y and contentY <= child.y + child.h then
                if child.onClick then
                    child:onClick()
                end
                return true
            end
        end
    end
    return false
end

function Tabs:keypressed(key)
    local tab = self:getActiveTab()
    if tab then
        for _, child in ipairs(tab.children) do
            if child.keypressed and child:keypressed(key) then
                return true
            end
        end
    end
    return false
end

function Tabs:textinput(text)
    local tab = self:getActiveTab()
    if tab then
        for _, child in ipairs(tab.children) do
            if child.textinput and child:textinput(text) then
                return true
            end
        end
    end
    return false
end

function Tabs:applyTheme()
    local Theme = require("kuruui.theme")
    self.colors = {
        bar = Theme.color("panel"),
        tab = Theme.color("button"),
        tabHover = Theme.color("buttonHover"),
        tabActive = Theme.color("buttonPressed"),
        indicator = Theme.color("primary"),
        text = Theme.color("textMuted"),
        textActive = Theme.color("text"),
        content = Theme.color("scrollArea")
    }
    self.cornerRadius = Theme.cornerRadius()
end

return Tabs
