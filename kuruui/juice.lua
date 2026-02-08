local Juice = {}

local Tween = require("kuruui.tween")

function Juice.pop(element, scale, duration)
    scale = scale or 1.2
    duration = duration or 0.15
    local originalScale = element.scale or 1
    element.scale = originalScale * scale
    return Tween.to(element, {scale = originalScale}, duration, "outBack")
end

function Juice.punch(element, scale, duration)
    scale = scale or 0.9
    duration = duration or 0.1
    local originalScale = element.scale or 1
    element.scale = originalScale * scale
    return Tween.to(element, {scale = originalScale}, duration, "outElastic")
end

function Juice.shake(element, intensity, duration, onComplete)
    intensity = intensity or 5
    duration = duration or 0.4
    local originalX = element.x
    local originalY = element.y
    local elapsed = 0
    local shakeData = {
        element = element,
        originalX = originalX,
        originalY = originalY,
        intensity = intensity,
        duration = duration,
        elapsed = 0,
        onComplete = onComplete
    }
    element._shakeData = shakeData
    return shakeData
end

function Juice.updateShake(element, dt)
    local data = element._shakeData
    if not data then return false end
    data.elapsed = data.elapsed + dt
    if data.elapsed >= data.duration then
        element.x = data.originalX
        element.y = data.originalY
        element._shakeData = nil
        if data.onComplete then data.onComplete() end
        return false
    end
    local progress = data.elapsed / data.duration
    local decay = 1 - progress
    local offsetX = (math.random() * 2 - 1) * data.intensity * decay
    local offsetY = (math.random() * 2 - 1) * data.intensity * decay
    element.x = data.originalX + offsetX
    element.y = data.originalY + offsetY
    return true
end

function Juice.pulse(element, minAlpha, maxAlpha, speed)
    minAlpha = minAlpha or 0.5
    maxAlpha = maxAlpha or 1.0
    speed = speed or 3
    element._pulseData = {
        minAlpha = minAlpha,
        maxAlpha = maxAlpha,
        speed = speed,
        time = 0
    }
end

function Juice.stopPulse(element)
    element._pulseData = nil
    element.alpha = 1
end

function Juice.updatePulse(element, dt)
    local data = element._pulseData
    if not data then return false end
    data.time = data.time + dt * data.speed
    local t = (math.sin(data.time) + 1) / 2
    element.alpha = data.minAlpha + (data.maxAlpha - data.minAlpha) * t
    return true
end

function Juice.flash(element, color, duration, onComplete)
    duration = duration or 0.2
    local originalColor = element.currentColor and {unpack(element.currentColor)} or nil
    if not originalColor and element.color then
        originalColor = {unpack(element.color)}
    end
    if not originalColor then return end
    color = color or {1, 1, 1, 1}
    if element.currentColor then
        element.currentColor = {unpack(color)}
        Tween.to(element, {
            currentColor = originalColor
        }, duration, "outQuad"):setOnComplete(onComplete)
    elseif element.color then
        element.color = {unpack(color)}
        Tween.to(element, {
            color = originalColor
        }, duration, "outQuad"):setOnComplete(onComplete)
    end
end

function Juice.wiggle(element, angle, duration, count)
    angle = angle or 5
    duration = duration or 0.4
    count = count or 3
    local originalRotation = element.rotation or 0
    element._wiggleData = {
        originalRotation = originalRotation,
        angle = angle,
        duration = duration,
        count = count,
        elapsed = 0
    }
end

function Juice.updateWiggle(element, dt)
    local data = element._wiggleData
    if not data then return false end
    data.elapsed = data.elapsed + dt
    if data.elapsed >= data.duration then
        element.rotation = data.originalRotation
        element._wiggleData = nil
        return false
    end
    local progress = data.elapsed / data.duration
    local decay = 1 - progress
    local wave = math.sin(progress * math.pi * 2 * data.count)
    element.rotation = data.originalRotation + math.rad(data.angle) * wave * decay
    return true
end

function Juice.bounce(element, height, duration, onComplete)
    height = height or 20
    duration = duration or 0.3
    local originalY = element.y
    Tween.to(element, {y = originalY - height}, duration * 0.4, "outQuad")
        :setOnComplete(function()
            Tween.to(element, {y = originalY}, duration * 0.6, "outBounce")
                :setOnComplete(onComplete)
        end)
end

function Juice.rubber(element, scaleX, scaleY, duration)
    scaleX = scaleX or 1.25
    scaleY = scaleY or 0.75
    duration = duration or 0.3
    element.scaleX = element.scaleX or 1
    element.scaleY = element.scaleY or 1
    local originalScaleX = element.scaleX
    local originalScaleY = element.scaleY
    element.scaleX = scaleX
    element.scaleY = scaleY
    Tween.to(element, {scaleX = originalScaleX, scaleY = originalScaleY}, duration, "outElastic")
end

function Juice.typewriter(element, text, speed, onCharacter, onComplete)
    speed = speed or 0.05
    element._typewriterData = {
        fullText = text,
        currentIndex = 0,
        speed = speed,
        elapsed = 0,
        onCharacter = onCharacter,
        onComplete = onComplete
    }
    element.text = ""
end

function Juice.updateTypewriter(element, dt)
    local data = element._typewriterData
    if not data then return false end
    data.elapsed = data.elapsed + dt
    if data.elapsed >= data.speed then
        data.elapsed = data.elapsed - data.speed
        data.currentIndex = data.currentIndex + 1
        if data.currentIndex <= #data.fullText then
            element.text = data.fullText:sub(1, data.currentIndex)
            if data.onCharacter then
                data.onCharacter(data.fullText:sub(data.currentIndex, data.currentIndex))
            end
        else
            element._typewriterData = nil
            if data.onComplete then
                data.onComplete()
            end
            return false
        end
    end
    return true
end

function Juice.fadeSlideIn(element, direction, distance, duration)
    direction = direction or "up"
    distance = distance or 30
    duration = duration or 0.3
    local originalX, originalY = element.x, element.y
    element.alpha = 0
    if direction == "up" then
        element.y = originalY + distance
    elseif direction == "down" then
        element.y = originalY - distance
    elseif direction == "left" then
        element.x = originalX + distance
    elseif direction == "right" then
        element.x = originalX - distance
    end
    element.visible = true
    Tween.to(element, {alpha = 1, x = originalX, y = originalY}, duration, "outCubic")
end

function Juice.fadeSlideOut(element, direction, distance, duration, onComplete)
    direction = direction or "up"
    distance = distance or 30
    duration = duration or 0.3
    local targetX, targetY = element.x, element.y
    if direction == "up" then
        targetY = element.y - distance
    elseif direction == "down" then
        targetY = element.y + distance
    elseif direction == "left" then
        targetX = element.x - distance
    elseif direction == "right" then
        targetX = element.x + distance
    end
    Tween.to(element, {alpha = 0, x = targetX, y = targetY}, duration, "inCubic")
        :setOnComplete(function()
            element.visible = false
            if onComplete then onComplete() end
        end)
end

function Juice.heartbeat(element, scale, speed)
    scale = scale or 1.1
    speed = speed or 1.5
    element._heartbeatData = {
        baseScale = element.scale or 1,
        scale = scale,
        speed = speed,
        time = 0
    }
end

function Juice.stopHeartbeat(element)
    if element._heartbeatData then
        element.scale = element._heartbeatData.baseScale
        element._heartbeatData = nil
    end
end

function Juice.updateHeartbeat(element, dt)
    local data = element._heartbeatData
    if not data then return false end
    data.time = data.time + dt * data.speed
    local beat = math.abs(math.sin(data.time * math.pi))
    beat = beat * beat
    element.scale = data.baseScale + (data.scale - data.baseScale) * beat
    return true
end

function Juice.glow(element, intensity, speed)
    intensity = intensity or 0.3
    speed = speed or 2
    element._glowData = {
        intensity = intensity,
        speed = speed,
        time = 0
    }
end

function Juice.updateGlow(element, dt)
    local data = element._glowData
    if not data then return false end
    data.time = data.time + dt * data.speed
    element.glowAmount = ((math.sin(data.time) + 1) / 2) * data.intensity
    return true
end

function Juice.sequence(...)
    local animations = {...}
    local index = 1
    local function runNext()
        if index <= #animations then
            local anim = animations[index]
            index = index + 1
            if type(anim) == "function" then
                anim(runNext)
            elseif anim.setOnComplete then
                anim:setOnComplete(runNext)
            end
        end
    end
    runNext()
end

function Juice.parallel(...)
    local animations = {...}
    for _, anim in ipairs(animations) do
        if type(anim) == "function" then
            anim()
        end
    end
end

function Juice.delay(duration, callback)
    local data = {elapsed = 0, duration = duration, callback = callback}
    return data
end

local screenShakeData = nil
local screenShakeX = 0
local screenShakeY = 0

function Juice.screenShake(intensity, duration)
    screenShakeData = {
        intensity = intensity or 3,
        duration = duration or 0.2,
        elapsed = 0,
    }
end

function Juice.updateScreenShake(dt)
    if not screenShakeData then
        screenShakeX = Juice.lerp(screenShakeX, 0, 20, dt)
        screenShakeY = Juice.lerp(screenShakeY, 0, 20, dt)
        if math.abs(screenShakeX) < 0.01 then screenShakeX = 0 end
        if math.abs(screenShakeY) < 0.01 then screenShakeY = 0 end
        return
    end
    screenShakeData.elapsed = screenShakeData.elapsed + dt
    if screenShakeData.elapsed >= screenShakeData.duration then
        screenShakeData = nil
        return
    end
    local progress = screenShakeData.elapsed / screenShakeData.duration
    local decay = 1 - progress
    screenShakeX = (math.random() * 2 - 1) * screenShakeData.intensity * decay
    screenShakeY = (math.random() * 2 - 1) * screenShakeData.intensity * decay
end

function Juice.getScreenShakeOffset()
    return screenShakeX, screenShakeY
end

function Juice.lerp(current, target, speed, dt)
    return current + (target - current) * math.min(speed * dt, 1)
end

function Juice.lerpColor(current, target, speed, dt)
    local t = math.min(speed * dt, 1)
    for i = 1, math.min(#current, #target) do
        current[i] = current[i] + (target[i] - current[i]) * t
    end
    return current
end

function Juice.bob(element, axis, amount, speed)
    element._bobData = {
        axis = axis or "y",
        amount = amount or 3,
        speed = speed or 2,
        time = 0,
        baseValue = element[axis or "y"]
    }
end

function Juice.stopBob(element)
    local data = element._bobData
    if data then
        element[data.axis] = data.baseValue
        element._bobData = nil
    end
end

function Juice.updateBob(element, dt)
    local data = element._bobData
    if not data then return false end
    data.time = data.time + dt * data.speed
    element[data.axis] = data.baseValue + math.sin(data.time) * data.amount
    return true
end

function Juice.update(element, dt)
    local active = false
    if Juice.updateShake(element, dt) then active = true end
    if Juice.updatePulse(element, dt) then active = true end
    if Juice.updateWiggle(element, dt) then active = true end
    if Juice.updateTypewriter(element, dt) then active = true end
    if Juice.updateHeartbeat(element, dt) then active = true end
    if Juice.updateGlow(element, dt) then active = true end
    if Juice.updateBob(element, dt) then active = true end
    return active
end

return Juice
