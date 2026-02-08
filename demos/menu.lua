local KuruUI = require("kuruui")
local Theme = KuruUI.Theme
local Juice = KuruUI.Juice
local Tween = KuruUI.Tween

local Menu = {}

local screen = "main"
local transitioning = false
local horizontalMode = false

local menuItems = {}
local screenElements = {}
local persistentJuicy = {}
local screenJuicy = {}

local titleLabel, subtitleLabel, versionLabel
local particles = {}
local time = 0

local indicator = {
    y = 0, targetY = 0,
    alpha = 0, targetAlpha = 0,
    x = 0, targetX = 0,
}

local function makeParticle()
    return {
        x = math.random(0, 800),
        y = math.random(0, 600),
        size = math.random(1, 3),
        alpha = math.random() * 0.15 + 0.05,
        speed = math.random() * 8 + 2,
        drift = (math.random() - 0.5) * 0.3
    }
end

local function makeMenuButton(x, y, text, action, index)
    local btn = KuruUI.add(KuruUI.Button:new(x, y, 180, 42, text))
    btn.cornerRadius = 0
    btn.animateHover = false
    btn.animateClick = false
    btn.colors = {
        normal = {0, 0, 0, 0},
        hovered = {0, 0, 0, 0},
        pressed = {0, 0, 0, 0},
        text = {0, 0, 0, 0}
    }
    btn.currentColor = {0, 0, 0, 0}
    btn._baseX = 310
    btn._baseY = y
    btn._targetX = 310
    btn._targetY = y
    btn._textAlpha = 0.5
    btn._targetTextAlpha = 0.5
    btn._textColor = {unpack(Theme.color("text"))}
    btn._targetTextColor = {unpack(Theme.color("text"))}
    btn._accentColor = {unpack(Theme.color("primary"))}
    btn._seed = index * 1.7
    btn._entryDelay = 0.35 + index * 0.12
    btn.alpha = 0
    btn.onClick = action
    Tween.to(btn, {alpha = 1}, 0.6, "outCubic"):setDelay(btn._entryDelay)
    table.insert(menuItems, btn)
    table.insert(screenElements, btn)
    table.insert(screenJuicy, btn)
    return btn
end

local function toggleHorizontal()
    horizontalMode = not horizontalMode
    Juice.screenShake(4, 0.2)

    if horizontalMode then
        local positions = {70, 230, 390, 550}
        local commonY = 320
        for i, btn in ipairs(menuItems) do
            btn._baseX = positions[i] or 310
            btn._baseY = commonY
            btn._targetY = commonY
            Tween.to(btn, {y = commonY}, 0.4, "outBack"):setDelay((i - 1) * 0.06)
            Juice.pop(btn, 1.15, 0.15)
        end
    else
        local baseY = 240
        local spacing = 52
        for i, btn in ipairs(menuItems) do
            btn._baseX = 310
            btn._baseY = baseY + (i - 1) * spacing
            btn._targetY = btn._baseY
            Tween.to(btn, {y = btn._baseY}, 0.4, "outBack"):setDelay((i - 1) * 0.06)
            Juice.pop(btn, 1.15, 0.15)
        end
    end
end

local function buildMainScreen()
    horizontalMode = false
    local baseY = 240
    local spacing = 52
    makeMenuButton(500, baseY, "Start", function()
        if horizontalMode then toggleHorizontal() end
    end, 1)
    makeMenuButton(500, baseY + spacing, "Settings", function()
        if horizontalMode then
            toggleHorizontal()
            return
        end
        Menu.transitionTo("settings")
    end, 2)
    makeMenuButton(500, baseY + spacing * 2, "Options", function()
        toggleHorizontal()
    end, 3)
    makeMenuButton(500, baseY + spacing * 3, "Quit", function()
        if horizontalMode then
            toggleHorizontal()
            return
        end
        love.event.quit()
    end, 4)
end

local settingsState = {
    music = true,
    sound = true,
    fullscreen = false,
}

local function buildSettingsScreen()
    local baseY = 240
    local spacing = 52

    local function toggleLabel(key, label)
        return label .. ": " .. (settingsState[key] and "On" or "Off")
    end

    local musicBtn = makeMenuButton(500, baseY, toggleLabel("music", "Music"), nil, 1)
    musicBtn.onClick = function()
        settingsState.music = not settingsState.music
        musicBtn.text = toggleLabel("music", "Music")
    end

    local soundBtn = makeMenuButton(500, baseY + spacing, toggleLabel("sound", "Sound"), nil, 2)
    soundBtn.onClick = function()
        settingsState.sound = not settingsState.sound
        soundBtn.text = toggleLabel("sound", "Sound")
    end

    local fsBtn = makeMenuButton(500, baseY + spacing * 2, toggleLabel("fullscreen", "Fullscreen"), nil, 3)
    fsBtn.onClick = function()
        settingsState.fullscreen = not settingsState.fullscreen
        fsBtn.text = toggleLabel("fullscreen", "Fullscreen")
    end

    makeMenuButton(500, baseY + spacing * 3, "Back", function() Menu.transitionTo("main") end, 4)
end

function Menu.transitionTo(target)
    if transitioning then return end
    transitioning = true
    Juice.screenShake(3, 0.15)
    indicator.targetAlpha = 0

    local oldElements = {}
    for _, el in ipairs(screenElements) do
        table.insert(oldElements, el)
    end

    local slideDir = (target == "settings") and -60 or 60

    for i, el in ipairs(oldElements) do
        local delay = (i - 1) * 0.04
        Tween.cancel(el)
        Tween.to(el, {alpha = 0}, 0.25, "inCubic"):setDelay(delay)
        Tween.to(el, {x = el.x + slideDir}, 0.25, "inCubic"):setDelay(delay)
    end

    local timer = {t = 0}
    Tween.to(timer, {t = 1}, 0.35, "linear"):setOnComplete(function()
        for _, el in ipairs(oldElements) do
            KuruUI.remove(el)
        end

        menuItems = {}
        screenElements = {}
        screenJuicy = {}

        screen = target
        if target == "main" then
            buildMainScreen()
        else
            buildSettingsScreen()
        end
        transitioning = false
    end)
end

function Menu.load(pixelFont)
    Menu.build()
    love.graphics.setBackgroundColor(Theme.color("background"))
end

function Menu.build()
    KuruUI.clear()
    screen = "main"
    transitioning = false
    horizontalMode = false
    menuItems = {}
    screenElements = {}
    persistentJuicy = {}
    screenJuicy = {}
    particles = {}
    time = 0

    for i = 1, 40 do
        table.insert(particles, makeParticle())
    end

    titleLabel = KuruUI.add(KuruUI.Label:new(0, 120, "KURU"))
    titleLabel.color = {unpack(Theme.color("primary"))}
    titleLabel.alpha = 0
    table.insert(persistentJuicy, titleLabel)

    subtitleLabel = KuruUI.add(KuruUI.Label:new(0, 155, "user interface"))
    subtitleLabel.color = {unpack(Theme.color("textMuted"))}
    subtitleLabel.alpha = 0

    Tween.to(titleLabel, {alpha = 1}, 0.6, "outCubic")
        :setDelay(0.1)
        :setOnComplete(function()
            Juice.bob(titleLabel, "y", 2, 1.2)
        end)
    Tween.to(subtitleLabel, {alpha = 0.5}, 0.6, "outCubic"):setDelay(0.2)

    versionLabel = KuruUI.add(KuruUI.Label:new(0, 565, "v" .. KuruUI._VERSION))
    versionLabel.color = {unpack(Theme.color("textMuted"))}
    versionLabel.alpha = 0
    Tween.to(versionLabel, {alpha = 0.3}, 0.8, "outCubic"):setDelay(0.8)

    indicator.y = 261
    indicator.targetY = 261
    indicator.alpha = 0
    indicator.targetAlpha = 0

    buildMainScreen()
end

function Menu.update(dt)
    KuruUI.update(dt)
    Juice.updateScreenShake(dt)
    time = time + dt

    for _, el in ipairs(persistentJuicy) do
        Juice.update(el, dt)
    end
    for _, el in ipairs(screenJuicy) do
        Juice.update(el, dt)
    end

    local font = love.graphics.getFont()

    if titleLabel and not titleLabel._bobData then
        local tw = font:getWidth(titleLabel.text)
        titleLabel.x = Juice.lerp(titleLabel.x, 400 - tw / 2, 10, dt)
    elseif titleLabel and titleLabel._bobData then
        titleLabel._bobData.baseValue = Juice.lerp(titleLabel._bobData.baseValue, 120, 10, dt)
        local tw = font:getWidth(titleLabel.text)
        titleLabel.x = Juice.lerp(titleLabel.x, 400 - tw / 2, 10, dt)
    end

    if subtitleLabel then
        local tw = font:getWidth(subtitleLabel.text)
        subtitleLabel.x = Juice.lerp(subtitleLabel.x, 400 - tw / 2, 10, dt)
    end

    if versionLabel then
        local tw = font:getWidth(versionLabel.text)
        versionLabel.x = Juice.lerp(versionLabel.x, 400 - tw / 2, 10, dt)
    end

    local speed = 10
    local anyHovered = false

    for _, btn in ipairs(menuItems) do
        if btn.hovered then
            anyHovered = true
            btn._targetX = btn._baseX - 15
            btn._targetTextAlpha = 1
            btn._targetTextColor = {unpack(Theme.color("primary"))}

            local ax, ay = btn:getAbsolutePosition()
            local tw = font:getWidth(btn.text)
            indicator.targetY = ay + btn.h / 2
            indicator.targetAlpha = 1
            indicator.targetX = ax + btn.w / 2 - tw / 2 - 18
        else
            btn._targetX = btn._baseX
            btn._targetTextAlpha = 0.5
            btn._targetTextColor = {unpack(Theme.color("text"))}
        end

        if btn._entryDelay then
            btn._entryDelay = btn._entryDelay - dt
            if btn._entryDelay <= 0 then
                btn._entryDelay = nil
            end
        else
            btn.x = Juice.lerp(btn.x, btn._targetX, speed, dt)
        end

        btn._textAlpha = Juice.lerp(btn._textAlpha, btn._targetTextAlpha, speed, dt)
        Juice.lerpColor(btn._textColor, btn._targetTextColor, speed, dt)
    end

    if not anyHovered then
        indicator.targetAlpha = 0
    end

    indicator.y = Juice.lerp(indicator.y, indicator.targetY, 12, dt)
    indicator.alpha = Juice.lerp(indicator.alpha, indicator.targetAlpha, 8, dt)
    indicator.x = Juice.lerp(indicator.x, indicator.targetX, 10, dt)

    for _, p in ipairs(particles) do
        p.y = p.y - p.speed * dt
        p.x = p.x + p.drift
        if p.y < -5 then
            p.y = 610
            p.x = math.random(0, 800)
        end
    end
end

function Menu.draw()
    local s, ox, oy = KuruUI.getScale()
    local sx, sy = Juice.getScreenShakeOffset()

    love.graphics.push()
    love.graphics.translate(ox + sx, oy + sy)
    love.graphics.scale(s, s)

    local pc = Theme.color("primary")
    for _, p in ipairs(particles) do
        love.graphics.setColor(pc[1], pc[2], pc[3], p.alpha)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end

    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(sx, sy)
    KuruUI.draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(ox + sx, oy + sy)
    love.graphics.scale(s, s)

    local font = love.graphics.getFont()
    local th = font:getHeight()

    if indicator.alpha > 0.01 then
        local ac = Theme.color("primary")
        local bob = math.sin(time * 3) * 2
        love.graphics.setColor(ac[1], ac[2], ac[3], indicator.alpha)
        love.graphics.print(">", indicator.x + bob, indicator.y - th / 2)
    end

    for _, btn in ipairs(menuItems) do
        if btn.alpha <= 0 then goto continue end

        local ax, ay = btn:getAbsolutePosition()
        local tw = font:getWidth(btn.text)
        local cx = ax + btn.w / 2
        local cy = ay + btn.h / 2
        local a = btn._textAlpha * btn.alpha
        local tc = btn._textColor

        love.graphics.setColor(tc[1], tc[2], tc[3], a)
        love.graphics.print(btn.text, cx - tw / 2, cy - th / 2)

        ::continue::
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Menu.mousepressed(x, y, button)
    local ux, uy = KuruUI.toUICoords(x, y)
    for _, btn in ipairs(menuItems) do
        if btn:contains(ux, uy) and button == 1 then
            Juice.punch(btn, 0.92, 0.12)
            Juice.screenShake(2, 0.1)
        end
    end
    KuruUI.mousepressed(x, y, button)
end

function Menu.mousereleased(x, y, button)
    KuruUI.mousereleased(x, y, button)
end

function Menu.wheelmoved(x, y)
    KuruUI.wheelmoved(x, y)
end

function Menu.keypressed(key)
    KuruUI.keypressed(key)
end

function Menu.textinput(text)
    KuruUI.textinput(text)
end

function Menu.unload()
    KuruUI.clear()
end

return Menu
