local Tween = {}
Tween.__index = Tween

local tweens = {}

local Easing = {
    linear = function(t) return t end,
    inQuad = function(t) return t * t end,
    outQuad = function(t) return t * (2 - t) end,
    inOutQuad = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end,
    inCubic = function(t) return t * t * t end,
    outCubic = function(t) return 1 + (t - 1) ^ 3 end,
    inOutCubic = function(t) return t < 0.5 and 4 * t ^ 3 or 1 + (t - 1) ^ 3 * 4 end,
    inQuart = function(t) return t ^ 4 end,
    outQuart = function(t) return 1 - (t - 1) ^ 4 end,
    inOutQuart = function(t) return t < 0.5 and 8 * t ^ 4 or 1 - 8 * (t - 1) ^ 4 end,
    inExpo = function(t) return t == 0 and 0 or 2 ^ (10 * (t - 1)) end,
    outExpo = function(t) return t == 1 and 1 or 1 - 2 ^ (-10 * t) end,
    inOutExpo = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return t < 0.5 and 2 ^ (20 * t - 11) or 1 - 2 ^ (-20 * t + 9)
    end,
    inBack = function(t) return t * t * (2.7 * t - 1.7) end,
    outBack = function(t) return 1 + (t - 1) ^ 2 * (2.7 * (t - 1) + 1.7) end,
    inOutBack = function(t)
        local c = 1.7 * 1.525
        return t < 0.5
            and (2 * t) ^ 2 * ((c + 1) * 2 * t - c) / 2
            or ((2 * t - 2) ^ 2 * ((c + 1) * (t * 2 - 2) + c) + 2) / 2
    end,
    inElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return -2 ^ (10 * t - 10) * math.sin((t * 10 - 10.75) * (2 * math.pi) / 3)
    end,
    outElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return 2 ^ (-10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi) / 3) + 1
    end,
    inOutElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        local c = (2 * math.pi) / 4.5
        return t < 0.5
            and -2 ^ (20 * t - 10) * math.sin((20 * t - 11.125) * c) / 2
            or 2 ^ (-20 * t + 10) * math.sin((20 * t - 11.125) * c) / 2 + 1
    end,
    inBounce = function(t) return 1 - Easing.outBounce(1 - t) end,
    outBounce = function(t)
        if t < 1 / 2.75 then
            return 7.5625 * t * t
        elseif t < 2 / 2.75 then
            t = t - 1.5 / 2.75
            return 7.5625 * t * t + 0.75
        elseif t < 2.5 / 2.75 then
            t = t - 2.25 / 2.75
            return 7.5625 * t * t + 0.9375
        else
            t = t - 2.625 / 2.75
            return 7.5625 * t * t + 0.984375
        end
    end,
    inOutBounce = function(t)
        return t < 0.5
            and (1 - Easing.outBounce(1 - 2 * t)) / 2
            or (1 + Easing.outBounce(2 * t - 1)) / 2
    end
}

function Tween:new(target, props, duration, easing)
    local self = setmetatable({}, Tween)
    self.target = target
    self.duration = duration or 0.3
    self.easing = type(easing) == "function" and easing or Easing[easing or "outQuad"]
    self.elapsed = 0
    self.playing = true
    self.startValues = {}
    self.endValues = props
    self.onComplete = nil
    self.onUpdate = nil
    self.delay = 0
    self.delayElapsed = 0
    for k, v in pairs(props) do
        if type(v) == "table" then
            self.startValues[k] = {}
            for i, val in ipairs(target[k]) do
                self.startValues[k][i] = val
            end
        else
            self.startValues[k] = target[k]
        end
    end
    table.insert(tweens, self)
    return self
end

function Tween:setDelay(d)
    self.delay = d
    return self
end

function Tween:setOnComplete(fn)
    self.onComplete = fn
    return self
end

function Tween:setOnUpdate(fn)
    self.onUpdate = fn
    return self
end

function Tween:stop()
    self.playing = false
    return self
end

function Tween:update(dt)
    if not self.playing then return true end
    if self.delayElapsed < self.delay then
        self.delayElapsed = self.delayElapsed + dt
        return false
    end
    self.elapsed = self.elapsed + dt
    local progress = math.min(self.elapsed / self.duration, 1)
    local easedProgress = self.easing(progress)
    for k, endVal in pairs(self.endValues) do
        if type(endVal) == "table" then
            for i, v in ipairs(endVal) do
                self.target[k][i] = self.startValues[k][i] + (v - self.startValues[k][i]) * easedProgress
            end
        else
            self.target[k] = self.startValues[k] + (endVal - self.startValues[k]) * easedProgress
        end
    end
    if self.onUpdate then self.onUpdate(self.target, easedProgress) end
    if progress >= 1 then
        self.playing = false
        if self.onComplete then self.onComplete(self.target) end
        return true
    end
    return false
end

local TweenManager = {
    Easing = Easing
}

function TweenManager.to(target, props, duration, easing)
    return Tween:new(target, props, duration, easing)
end

function TweenManager.update(dt)
    for i = #tweens, 1, -1 do
        if tweens[i]:update(dt) then
            table.remove(tweens, i)
        end
    end
end

function TweenManager.cancel(target)
    for i = #tweens, 1, -1 do
        if tweens[i].target == target then
            table.remove(tweens, i)
        end
    end
end

function TweenManager.cancelAll()
    tweens = {}
end

function TweenManager.count()
    return #tweens
end

return TweenManager
