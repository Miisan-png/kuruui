local Element = require("kuruui.element")

local ScrollArea = setmetatable({}, {__index = Element})
ScrollArea.__index = ScrollArea

function ScrollArea:new(x, y, w, h)
    local self = setmetatable(Element.new(self, x, y, w, h), ScrollArea)
    self.scrollX = 0
    self.scrollY = 0
    self.contentWidth = w
    self.contentHeight = h
    self.scrollSpeed = 30
    self.showScrollbarV = true
    self.showScrollbarH = false
    self.scrollbarWidth = 8
    self.draggingV = false
    self.draggingH = false
    self.dragOffset = 0
    self.colors = {
        bg = {0.12, 0.12, 0.12, 1},
        scrollbar = {0.3, 0.3, 0.3, 1},
        scrollbarHover = {0.4, 0.4, 0.4, 1},
        scrollbarDrag = {0.5, 0.5, 0.5, 1}
    }
    self.scrollbarAlpha = 0
    self.hoveringScrollbar = false
    return self
end

function ScrollArea:setContentSize(w, h)
    self.contentWidth = w or self.contentWidth
    self.contentHeight = h or self.contentHeight
    self:clampScroll()
    return self
end

function ScrollArea:clampScroll()
    local maxScrollX = math.max(0, self.contentWidth - self.w + (self.showScrollbarV and self.scrollbarWidth or 0))
    local maxScrollY = math.max(0, self.contentHeight - self.h + (self.showScrollbarH and self.scrollbarWidth or 0))
    self.scrollX = math.max(0, math.min(maxScrollX, self.scrollX))
    self.scrollY = math.max(0, math.min(maxScrollY, self.scrollY))
end

function ScrollArea:scrollTo(x, y, animate)
    if animate then
        local Tween = require("kuruui.tween")
        if x then Tween.to(self, {scrollX = x}, 0.3, "outQuad") end
        if y then Tween.to(self, {scrollY = y}, 0.3, "outQuad") end
    else
        if x then self.scrollX = x end
        if y then self.scrollY = y end
    end
    self:clampScroll()
    return self
end

function ScrollArea:update(dt)
    if not self.visible or not self.enabled then return end
    local mx, my = love.mouse.getPosition()
    local KuruUI = require("kuruui")
    mx, my = KuruUI.toUICoords(mx, my)
    local ax, ay = self:getAbsolutePosition()
    self.hovered = mx >= ax and mx <= ax + self.w and my >= ay and my <= ay + self.h
    local scrollbarX = ax + self.w - self.scrollbarWidth
    self.hoveringScrollbar = self.hovered and mx >= scrollbarX
    if self.hovered or self.draggingV or self.draggingH then
        self.scrollbarAlpha = math.min(1, self.scrollbarAlpha + dt * 8)
    else
        self.scrollbarAlpha = math.max(0, self.scrollbarAlpha - dt * 4)
    end
    if self.draggingV then
        local maxScrollY = math.max(1, self.contentHeight - self.h)
        local trackHeight = self.h - (self.showScrollbarH and self.scrollbarWidth or 0)
        local handleHeight = math.max(30, trackHeight * (self.h / self.contentHeight))
        local trackSpace = trackHeight - handleHeight
        local relativeY = my - ay - self.dragOffset
        if trackSpace > 0 then
            self.scrollY = (relativeY / trackSpace) * maxScrollY
        end
        self:clampScroll()
    end
    local contentMx = mx - ax + self.scrollX
    local contentMy = my - ay + self.scrollY
    local contentW = self.w - (self.showScrollbarV and self.scrollbarWidth or 0)
    local contentH = self.h
    local mouseInContent = mx >= ax and mx < ax + contentW and my >= ay and my < ay + contentH
    for _, child in ipairs(self.children) do
        if mouseInContent then
            child.hovered = contentMx >= child.x and contentMx <= child.x + child.w and
                           contentMy >= child.y and contentMy <= child.y + child.h
        else
            child.hovered = false
        end
        if child.currentColor and child.colors then
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

function ScrollArea:drawChild(child, offsetX, offsetY)
    if not child.visible or (child.alpha and child.alpha <= 0) then return end
    local x = offsetX + child.x
    local y = offsetY + child.y
    if child.colors and child.currentColor then
        love.graphics.setColor(child.currentColor[1], child.currentColor[2], child.currentColor[3], (child.currentColor[4] or 1) * (child.alpha or 1))
        love.graphics.rectangle("fill", x, y, child.w, child.h, child.cornerRadius or 0)
    end
    if child.text then
        if child.colors and child.colors.text then
            love.graphics.setColor(child.colors.text[1], child.colors.text[2], child.colors.text[3], (child.colors.text[4] or 1) * (child.alpha or 1))
        else
            love.graphics.setColor(1, 1, 1, child.alpha or 1)
        end
        local font = love.graphics.getFont()
        local tw = font:getWidth(child.text)
        local th = font:getHeight()
        love.graphics.print(child.text, x + (child.w - tw) / 2, y + (child.h - th) / 2)
    end
end

function ScrollArea:draw()
    if not self.visible or self.alpha <= 0 then return end
    local ax, ay = self:getAbsolutePosition()
    love.graphics.setColor(self.colors.bg[1], self.colors.bg[2], self.colors.bg[3], self.colors.bg[4] * self.alpha)
    love.graphics.rectangle("fill", ax, ay, self.w, self.h)
    local contentW = self.w - (self.showScrollbarV and self.scrollbarWidth or 0)
    local contentH = self.h - (self.showScrollbarH and self.scrollbarWidth or 0)
    local prevScissor = {love.graphics.getScissor()}
    local KuruUI = require("kuruui")
    local scale, scOffsetX, scOffsetY = KuruUI.getScale()
    local scissorX = ax * scale + scOffsetX
    local scissorY = ay * scale + scOffsetY
    local scissorW = contentW * scale
    local scissorH = contentH * scale
    love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
    local drawOffsetX = ax - self.scrollX
    local drawOffsetY = ay - self.scrollY
    for _, child in ipairs(self.children) do
        self:drawChild(child, drawOffsetX, drawOffsetY)
    end
    if #prevScissor > 0 then
        love.graphics.setScissor(unpack(prevScissor))
    else
        love.graphics.setScissor()
    end
    if self.showScrollbarV and self.contentHeight > self.h and self.scrollbarAlpha > 0 then
        local maxScrollY = math.max(1, self.contentHeight - self.h)
        local trackHeight = self.h - (self.showScrollbarH and self.scrollbarWidth or 0)
        local handleHeight = math.max(30, trackHeight * (self.h / self.contentHeight))
        local handleY = (self.scrollY / maxScrollY) * (trackHeight - handleHeight)
        local scrollbarColor = self.draggingV and self.colors.scrollbarDrag or (self.hoveringScrollbar and self.colors.scrollbarHover or self.colors.scrollbar)
        love.graphics.setColor(scrollbarColor[1], scrollbarColor[2], scrollbarColor[3], scrollbarColor[4] * self.alpha * self.scrollbarAlpha)
        love.graphics.rectangle("fill", ax + self.w - self.scrollbarWidth, ay + handleY, self.scrollbarWidth - 2, handleHeight, 3)
    end
end

function ScrollArea:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    local ax, ay = self:getAbsolutePosition()
    if not (x >= ax and x <= ax + self.w and y >= ay and y <= ay + self.h) then
        return false
    end
    if self.showScrollbarV and self.contentHeight > self.h then
        local scrollbarX = ax + self.w - self.scrollbarWidth
        if x >= scrollbarX then
            local maxScrollY = math.max(1, self.contentHeight - self.h)
            local trackHeight = self.h - (self.showScrollbarH and self.scrollbarWidth or 0)
            local handleHeight = math.max(30, trackHeight * (self.h / self.contentHeight))
            local handleY = ay + (self.scrollY / maxScrollY) * (trackHeight - handleHeight)
            if y >= handleY and y <= handleY + handleHeight then
                self.draggingV = true
                self.dragOffset = y - handleY
            else
                local clickRatio = (y - ay) / trackHeight
                self.scrollY = clickRatio * maxScrollY
                self:clampScroll()
                self.draggingV = true
                self.dragOffset = handleHeight / 2
            end
            return true
        end
    end
    local contentX = x - ax + self.scrollX
    local contentY = y - ay + self.scrollY
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if contentX >= child.x and contentX <= child.x + child.w and
           contentY >= child.y and contentY <= child.y + child.h then
            child.pressed = true
            return true
        end
    end
    return true
end

function ScrollArea:mousereleased(x, y, button)
    self.draggingV = false
    self.draggingH = false
    local ax, ay = self:getAbsolutePosition()
    local contentX = x - ax + self.scrollX
    local contentY = y - ay + self.scrollY
    for i = #self.children, 1, -1 do
        local child = self.children[i]
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
    return false
end

function ScrollArea:wheelmoved(x, y)
    if not self.hovered then return false end
    self.scrollY = self.scrollY - y * self.scrollSpeed
    self:clampScroll()
    return true
end

return ScrollArea
