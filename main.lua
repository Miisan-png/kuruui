local KuruUI = require("kuruui")
local Theme = KuruUI.Theme
local Juice = KuruUI.Juice

local font
local elements = {}
local juicyElements = {}
local tabPanels = {}
local activeTab = 1

function love.load()
    font = love.graphics.newFont("pixel.ttf", 13)
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    KuruUI.enableScaling(800, 600)
    buildUI()

    Theme.onChange(function(theme)
        love.graphics.setBackgroundColor(theme.colors.background)
        rebuildUI()
    end)

    love.graphics.setBackgroundColor(Theme.color("background"))
end

function switchTab(index)
    if index == activeTab then return end
    for i, panel in ipairs(tabPanels) do
        panel.visible = (i == index)
    end
    activeTab = index
end

function buildUI()
    KuruUI.clear()
    elements = {}
    juicyElements = {}
    tabPanels = {}

    local tabBar = KuruUI.add(KuruUI.Panel:new(30, 30, 740, 40))
    tabBar.color = Theme.color("panel")
    tabBar.borderColor = Theme.color("panelBorder")
    tabBar.cornerRadius = Theme.cornerRadius()

    local tabNames = {"Settings", "Stats", "Juice"}
    for i, name in ipairs(tabNames) do
        local btn = tabBar:addChild(KuruUI.Button:new(10 + (i-1) * 120, 5, 110, 30, name))
        btn.colors = {
            normal = Theme.color("button"),
            hovered = Theme.color("buttonHover"),
            pressed = Theme.color("primary"),
            text = Theme.color("text")
        }
        btn.currentColor = {unpack(Theme.color("button"))}
        btn.cornerRadius = Theme.cornerRadius()
        btn.onClick = function()
            switchTab(i)
            for j, b in ipairs(tabBar.children) do
                if j == i then
                    b.currentColor = {unpack(Theme.color("primary"))}
                else
                    b.currentColor = {unpack(Theme.color("button"))}
                end
            end
        end
        if i == 1 then
            btn.currentColor = {unpack(Theme.color("primary"))}
        end
    end

    buildSettingsPanel()
    buildStatsPanel()
    buildJuicePanel()

    tabPanels[1].visible = true
    tabPanels[2].visible = false
    tabPanels[3].visible = false

    local notification = KuruUI.add(KuruUI.Panel:new(250, 530, 300, 50))
    notification.color = Theme.color("notification")
    notification.borderColor = Theme.color("panelBorder")
    notification.cornerRadius = Theme.cornerRadius() + 2
    notification.visible = false
    local notifLabel = notification:addChild(KuruUI.Label:new(15, 15, ""))
    Theme.applyToElement(notifLabel, "label")
    notification.notifLabel = notifLabel
    elements.notification = notification
end

function buildSettingsPanel()
    local panel = KuruUI.add(KuruUI.Panel:new(30, 80, 740, 440))
    Theme.applyToElement(panel, "panel")
    table.insert(tabPanels, panel)

    local title = panel:addChild(KuruUI.Label:new(20, 15, "Settings"))
    Theme.applyToElement(title, "label")

    local themeLabel = panel:addChild(KuruUI.Label:new(20, 50, "Theme:"))
    Theme.applyToElement(themeLabel, "label")

    local themeDropdown = panel:addChild(KuruUI.Dropdown:new(20, 75, 300, 32))
    local themeList = Theme.list()
    themeDropdown:setOptions(themeList)
    for i, name in ipairs(themeList) do
        if name == Theme.name() then
            themeDropdown:select(i)
            break
        end
    end
    Theme.applyToElement(themeDropdown, "dropdown")
    themeDropdown.onChange = function(self, value)
        Theme.set(value)
    end

    local musicToggle = panel:addChild(KuruUI.Toggle:new(20, 130, "Music"))
    musicToggle.on = true
    musicToggle.knobX = musicToggle.w - musicToggle.h + 3
    Theme.applyToElement(musicToggle, "toggle")

    local sfxToggle = panel:addChild(KuruUI.Toggle:new(20, 165, "Sound FX"))
    sfxToggle.on = true
    sfxToggle.knobX = sfxToggle.w - sfxToggle.h + 3
    Theme.applyToElement(sfxToggle, "toggle")

    local fullscreenToggle = panel:addChild(KuruUI.Toggle:new(20, 200, "Fullscreen"))
    Theme.applyToElement(fullscreenToggle, "toggle")
    fullscreenToggle.onChange = function(self, on)
        love.window.setFullscreen(on, "desktop")
        KuruUI.updateScale()
    end

    local diffLabel = panel:addChild(KuruUI.Label:new(20, 250, "Difficulty:"))
    Theme.applyToElement(diffLabel, "label")

    local diffDropdown = panel:addChild(KuruUI.Dropdown:new(20, 275, 300, 32))
    diffDropdown:setOptions({"Easy", "Normal", "Hard", "Nightmare"})
    diffDropdown:select(2)
    Theme.applyToElement(diffDropdown, "dropdown")
    diffDropdown.onChange = function(self, value)
        showNotification("Difficulty: " .. value)
    end

    local applyBtn = panel:addChild(KuruUI.Button:new(20, 330, 300, 40, "Apply Settings"))
    applyBtn.colors = {
        normal = Theme.color("primary"),
        hovered = Theme.color("primaryHover"),
        pressed = Theme.color("primaryPressed"),
        text = Theme.color("text")
    }
    applyBtn.currentColor = {unpack(Theme.color("primary"))}
    applyBtn.cornerRadius = Theme.cornerRadius()
    applyBtn.onClick = function()
        Juice.pop(applyBtn, 1.1, 0.15)
        showNotification("Settings applied!")
    end
    table.insert(juicyElements, applyBtn)

    local invLabel = panel:addChild(KuruUI.Label:new(380, 15, "Inventory"))
    Theme.applyToElement(invLabel, "label")

    local scrollArea = panel:addChild(KuruUI.ScrollArea:new(380, 50, 330, 360))
    scrollArea:setContentSize(330, 500)
    Theme.applyToElement(scrollArea, "scrollarea")

    for i = 1, 12 do
        local itemBtn = scrollArea:addChild(KuruUI.Button:new(5, 5 + (i - 1) * 40, 300, 35, "Item " .. i))
        local hue = (i - 1) / 12
        local r, g, b = hslToRgb(hue, 0.5, 0.35)
        itemBtn.colors = {
            normal = {r, g, b, 1},
            hovered = {r + 0.1, g + 0.1, b + 0.1, 1},
            pressed = {r - 0.1, g - 0.1, b - 0.1, 1},
            text = Theme.color("text")
        }
        itemBtn.currentColor = {r, g, b, 1}
        itemBtn.cornerRadius = Theme.cornerRadius()
        itemBtn.onClick = function()
            showNotification("Selected: Item " .. i)
        end
    end
end

function buildStatsPanel()
    local panel = KuruUI.add(KuruUI.Panel:new(30, 80, 740, 440))
    Theme.applyToElement(panel, "panel")
    table.insert(tabPanels, panel)

    local title = panel:addChild(KuruUI.Label:new(20, 15, "Character Stats"))
    Theme.applyToElement(title, "label")

    local hpBar = panel:addChild(KuruUI.ProgressBar:new(20, 55, 340, 30))
    hpBar.colors.fill = Theme.color("danger")
    hpBar.colors.bg = Theme.color("progressBg")
    hpBar.colors.border = Theme.color("progressBorder")
    hpBar.colors.text = Theme.color("text")
    hpBar.showText = true
    hpBar.textFormat = function(self) return "HP: " .. math.floor(self:getValue()) .. "/100" end
    hpBar.max = 100
    hpBar.value = 0.8
    hpBar.displayValue = 0.8
    hpBar.cornerRadius = Theme.cornerRadius()
    elements.hpBar = hpBar

    local mpBar = panel:addChild(KuruUI.ProgressBar:new(20, 95, 340, 30))
    mpBar.colors.fill = Theme.color("primary")
    mpBar.colors.bg = Theme.color("progressBg")
    mpBar.colors.border = Theme.color("progressBorder")
    mpBar.colors.text = Theme.color("text")
    mpBar.showText = true
    mpBar.textFormat = function(self) return "MP: " .. math.floor(self:getValue()) .. "/50" end
    mpBar.max = 50
    mpBar.value = 0.6
    mpBar.displayValue = 0.6
    mpBar.cornerRadius = Theme.cornerRadius()
    elements.mpBar = mpBar

    local xpBar = panel:addChild(KuruUI.ProgressBar:new(20, 135, 340, 30))
    xpBar.colors.fill = Theme.color("warning")
    xpBar.colors.bg = Theme.color("progressBg")
    xpBar.colors.border = Theme.color("progressBorder")
    xpBar.colors.text = Theme.color("text")
    xpBar.showText = true
    xpBar.textFormat = "percent"
    xpBar.value = 0.45
    xpBar.displayValue = 0.45
    xpBar.cornerRadius = Theme.cornerRadius()

    local staminaBar = panel:addChild(KuruUI.ProgressBar:new(20, 175, 340, 30))
    staminaBar.colors.fill = Theme.color("success")
    staminaBar.colors.bg = Theme.color("progressBg")
    staminaBar.colors.border = Theme.color("progressBorder")
    staminaBar.colors.text = Theme.color("text")
    staminaBar.showText = true
    staminaBar.textFormat = "percent"
    staminaBar.value = 1
    staminaBar.displayValue = 1
    staminaBar.cornerRadius = Theme.cornerRadius()
    elements.staminaBar = staminaBar

    local dmgBtn = panel:addChild(KuruUI.Button:new(400, 55, 150, 38, "Take Damage"))
    dmgBtn.colors = {
        normal = Theme.color("danger"),
        hovered = Theme.color("dangerHover"),
        pressed = {Theme.color("danger")[1] * 0.7, Theme.color("danger")[2] * 0.7, Theme.color("danger")[3] * 0.7, 1},
        text = Theme.color("text")
    }
    dmgBtn.currentColor = {unpack(Theme.color("danger"))}
    dmgBtn.cornerRadius = Theme.cornerRadius()
    dmgBtn.onClick = function()
        elements.hpBar:tweenTo(math.max(0, elements.hpBar:getValue() - 20), 0.3)
        Juice.shake(dmgBtn, 5, 0.25)
    end
    table.insert(juicyElements, dmgBtn)

    local healBtn = panel:addChild(KuruUI.Button:new(560, 55, 150, 38, "Heal"))
    healBtn.colors = {
        normal = Theme.color("success"),
        hovered = Theme.color("successHover"),
        pressed = {Theme.color("success")[1] * 0.7, Theme.color("success")[2] * 0.7, Theme.color("success")[3] * 0.7, 1},
        text = Theme.color("text")
    }
    healBtn.currentColor = {unpack(Theme.color("success"))}
    healBtn.cornerRadius = Theme.cornerRadius()
    healBtn.onClick = function()
        elements.hpBar:tweenTo(math.min(100, elements.hpBar:getValue() + 30), 0.4, "outBack")
        Juice.pop(healBtn, 1.15, 0.15)
    end
    table.insert(juicyElements, healBtn)

    local castBtn = panel:addChild(KuruUI.Button:new(400, 105, 150, 38, "Cast Spell"))
    castBtn.colors = {
        normal = Theme.color("primary"),
        hovered = Theme.color("primaryHover"),
        pressed = Theme.color("primaryPressed"),
        text = Theme.color("text")
    }
    castBtn.currentColor = {unpack(Theme.color("primary"))}
    castBtn.cornerRadius = Theme.cornerRadius()
    castBtn.onClick = function()
        if elements.mpBar:getValue() >= 10 then
            elements.mpBar:tweenTo(elements.mpBar:getValue() - 10, 0.2)
            Juice.pop(castBtn, 1.1, 0.1)
            showNotification("Spell cast!")
        else
            Juice.shake(castBtn, 6, 0.3)
            showNotification("Not enough mana!")
        end
    end
    table.insert(juicyElements, castBtn)

    local restBtn = panel:addChild(KuruUI.Button:new(560, 105, 150, 38, "Rest"))
    Theme.applyToElement(restBtn, "button")
    restBtn.onClick = function()
        elements.mpBar:tweenTo(50, 0.5, "outQuad")
        elements.staminaBar:tweenTo(1, 0.5, "outQuad")
        showNotification("Resting...")
    end
end

function buildJuicePanel()
    local panel = KuruUI.add(KuruUI.Panel:new(30, 80, 740, 440))
    Theme.applyToElement(panel, "panel")
    table.insert(tabPanels, panel)

    local title = panel:addChild(KuruUI.Label:new(20, 15, "Animation Effects - Click buttons to test!"))
    Theme.applyToElement(title, "label")

    local effects = {
        {"Shake", function(btn) Juice.shake(btn, 8, 0.4) end},
        {"Pop", function(btn) Juice.pop(btn, 1.3, 0.2) end},
        {"Punch", function(btn) Juice.punch(btn, 0.85, 0.15) end},
        {"Bounce", function(btn) Juice.bounce(btn, 20, 0.5) end},
        {"Flash", function(btn) Juice.flash(btn, {1, 1, 1, 1}, 0.3) end},
        {"Pulse", function(btn)
            if btn._pulsing then
                Juice.stopPulse(btn)
                btn._pulsing = false
            else
                Juice.pulse(btn, 0.4, 1.0, 4)
                btn._pulsing = true
            end
        end},
        {"Heartbeat", function(btn)
            if btn._beating then
                Juice.stopHeartbeat(btn)
                btn._beating = false
            else
                Juice.heartbeat(btn, 1.15, 2)
                btn._beating = true
            end
        end},
        {"Slide In", function(btn)
            btn.alpha = 0
            Juice.fadeSlideIn(btn, "up", 30, 0.4)
        end},
    }

    for i, effect in ipairs(effects) do
        local row = math.floor((i - 1) / 4)
        local col = (i - 1) % 4
        local btn = panel:addChild(KuruUI.Button:new(20 + col * 175, 55 + row * 55, 165, 45, effect[1]))
        Theme.applyToElement(btn, "button")
        btn.onClick = function()
            effect[2](btn)
        end
        table.insert(juicyElements, btn)
    end

    local typeLabel = panel:addChild(KuruUI.Label:new(20, 180, ""))
    Theme.applyToElement(typeLabel, "label")
    elements.typeLabel = typeLabel

    local typeBtn = panel:addChild(KuruUI.Button:new(20, 210, 200, 45, "Typewriter"))
    Theme.applyToElement(typeBtn, "button")
    typeBtn.onClick = function()
        Juice.typewriter(elements.typeLabel, "Hello! This is a typewriter effect...", 0.05, nil, function()
            showNotification("Done typing!")
        end)
    end
    table.insert(juicyElements, typeBtn)

    local comboBtn = panel:addChild(KuruUI.Button:new(235, 210, 200, 45, "Combo Effect!"))
    comboBtn.colors = {
        normal = Theme.color("primary"),
        hovered = Theme.color("primaryHover"),
        pressed = Theme.color("primaryPressed"),
        text = Theme.color("text")
    }
    comboBtn.currentColor = {unpack(Theme.color("primary"))}
    comboBtn.cornerRadius = Theme.cornerRadius()
    comboBtn.onClick = function()
        Juice.pop(comboBtn, 1.2, 0.1)
        Juice.flash(comboBtn, {1, 1, 1, 1}, 0.2)
        Juice.shake(comboBtn, 4, 0.25)
    end
    table.insert(juicyElements, comboBtn)
end

function rebuildUI()
    local currentHP = elements.hpBar and elements.hpBar.value or 0.8
    local currentMP = elements.mpBar and elements.mpBar.value or 0.6
    local currentStamina = elements.staminaBar and elements.staminaBar.value or 1
    local savedTab = activeTab

    buildUI()

    if elements.hpBar then
        elements.hpBar.value = currentHP
        elements.hpBar.displayValue = currentHP
    end
    if elements.mpBar then
        elements.mpBar.value = currentMP
        elements.mpBar.displayValue = currentMP
    end
    if elements.staminaBar then
        elements.staminaBar.value = currentStamina
        elements.staminaBar.displayValue = currentStamina
    end

    switchTab(savedTab)
end

function hslToRgb(h, s, l)
    local r, g, b
    if s == 0 then
        r, g, b = l, l, l
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end
    return r, g, b
end

function showNotification(text)
    local notification = elements.notification
    if not notification then return end
    notification.notifLabel.text = text
    notification.alpha = 1
    notification.visible = true
    notification.y = 540
    KuruUI.Tween.cancel(notification)
    KuruUI.tween(notification, {y = 530}, 0.3, "outBack")
    KuruUI.tween(notification, {alpha = 0}, 0.3, "inQuad")
        :setDelay(1.5)
        :setOnComplete(function()
            notification.visible = false
        end)
end

function love.update(dt)
    KuruUI.update(dt)
    for _, element in ipairs(juicyElements) do
        Juice.update(element, dt)
    end
    if elements.typeLabel then
        Juice.updateTypewriter(elements.typeLabel, dt)
    end
end

function love.draw()
    KuruUI.draw()
end

function love.mousepressed(x, y, button)
    KuruUI.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    KuruUI.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
    KuruUI.wheelmoved(x, y)
end

function love.keypressed(key)
    if key == "escape" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
            KuruUI.updateScale()
        else
            love.event.quit()
        end
    else
        KuruUI.keypressed(key)
    end
end

function love.textinput(text)
    KuruUI.textinput(text)
end

function love.resize(w, h)
    KuruUI.resize(w, h)
end
