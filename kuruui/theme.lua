local Theme = {}

local themes = {}
local currentTheme = nil
local onChangeCallbacks = {}

local defaultTheme = {
    name = "Default",
    colors = {
        background = {0.10, 0.10, 0.12, 1},
        panel = {0.15, 0.15, 0.15, 0.95},
        panelBorder = {0.30, 0.30, 0.30, 1},
        button = {0.30, 0.30, 0.30, 1},
        buttonHover = {0.40, 0.40, 0.40, 1},
        buttonPressed = {0.20, 0.20, 0.20, 1},
        buttonText = {1, 1, 1, 1},
        primary = {0.40, 0.60, 0.90, 1},
        primaryHover = {0.50, 0.70, 1.00, 1},
        primaryPressed = {0.30, 0.50, 0.80, 1},
        success = {0.30, 0.70, 0.40, 1},
        successHover = {0.40, 0.80, 0.50, 1},
        danger = {0.80, 0.30, 0.30, 1},
        dangerHover = {0.90, 0.40, 0.40, 1},
        warning = {0.90, 0.80, 0.20, 1},
        text = {1, 1, 1, 1},
        textMuted = {0.60, 0.60, 0.60, 1},
        input = {0.15, 0.15, 0.15, 1},
        inputBorder = {0.30, 0.30, 0.30, 1},
        inputFocused = {0.40, 0.60, 0.90, 1},
        toggle = {0.30, 0.30, 0.30, 1},
        toggleOn = {0.40, 0.60, 0.90, 1},
        toggleKnob = {1, 1, 1, 1},
        slider = {0.20, 0.20, 0.20, 1},
        sliderFill = {0.40, 0.60, 0.90, 1},
        sliderKnob = {1, 1, 1, 1},
        checkbox = {0.30, 0.30, 0.30, 1},
        checkboxChecked = {0.40, 0.60, 0.90, 1},
        checkmark = {1, 1, 1, 1},
        scrollbar = {0.30, 0.30, 0.30, 1},
        scrollbarHover = {0.40, 0.40, 0.40, 1},
        scrollbarDrag = {0.50, 0.50, 0.50, 1},
        scrollArea = {0.12, 0.12, 0.12, 1},
        dropdown = {0.20, 0.20, 0.20, 1},
        dropdownList = {0.18, 0.18, 0.18, 0.98},
        dropdownHover = {0.30, 0.30, 0.30, 1},
        dropdownSelected = {0.40, 0.60, 0.90, 0.30},
        progressBg = {0.15, 0.15, 0.15, 1},
        progressFill = {0.40, 0.60, 0.90, 1},
        progressBorder = {0.30, 0.30, 0.30, 1},
        tooltip = {0.10, 0.10, 0.10, 0.95},
        tooltipBorder = {0.30, 0.30, 0.30, 1},
        tooltipText = {1, 1, 1, 1},
        notification = {0.20, 0.50, 0.40, 0.95},
    },
    cornerRadius = 4,
    borderWidth = 1,
    spacing = 8,
    animationSpeed = 12,
}

local imguiTheme = {
    name = "ImGui",
    colors = {
        background = {0.06, 0.06, 0.06, 1},
        panel = {0.11, 0.11, 0.14, 0.95},
        panelBorder = {0.25, 0.25, 0.28, 1},
        button = {0.16, 0.29, 0.48, 1},
        buttonHover = {0.20, 0.40, 0.60, 1},
        buttonPressed = {0.12, 0.24, 0.40, 1},
        buttonText = {1, 1, 1, 1},
        primary = {0.26, 0.59, 0.98, 1},
        primaryHover = {0.30, 0.65, 1.00, 1},
        primaryPressed = {0.20, 0.50, 0.85, 1},
        success = {0.35, 0.70, 0.35, 1},
        successHover = {0.40, 0.80, 0.40, 1},
        danger = {0.86, 0.20, 0.20, 1},
        dangerHover = {0.95, 0.30, 0.30, 1},
        warning = {0.90, 0.70, 0.00, 1},
        text = {1, 1, 1, 1},
        textMuted = {0.50, 0.50, 0.50, 1},
        input = {0.09, 0.09, 0.09, 1},
        inputBorder = {0.25, 0.25, 0.28, 1},
        inputFocused = {0.26, 0.59, 0.98, 1},
        toggle = {0.20, 0.22, 0.27, 1},
        toggleOn = {0.26, 0.59, 0.98, 1},
        toggleKnob = {1, 1, 1, 1},
        slider = {0.20, 0.22, 0.27, 1},
        sliderFill = {0.26, 0.59, 0.98, 1},
        sliderKnob = {0.46, 0.54, 0.67, 1},
        checkbox = {0.20, 0.22, 0.27, 1},
        checkboxChecked = {0.26, 0.59, 0.98, 1},
        checkmark = {1, 1, 1, 1},
        scrollbar = {0.20, 0.22, 0.27, 1},
        scrollbarHover = {0.30, 0.32, 0.37, 1},
        scrollbarDrag = {0.40, 0.42, 0.47, 1},
        scrollArea = {0.07, 0.07, 0.09, 1},
        dropdown = {0.20, 0.22, 0.27, 1},
        dropdownList = {0.11, 0.11, 0.14, 0.98},
        dropdownHover = {0.26, 0.59, 0.98, 0.40},
        dropdownSelected = {0.26, 0.59, 0.98, 0.35},
        progressBg = {0.20, 0.22, 0.27, 1},
        progressFill = {0.26, 0.59, 0.98, 1},
        progressBorder = {0.25, 0.25, 0.28, 1},
        tooltip = {0.08, 0.08, 0.10, 0.95},
        tooltipBorder = {0.30, 0.30, 0.35, 1},
        tooltipText = {1, 1, 1, 1},
        notification = {0.26, 0.59, 0.98, 0.9},
    },
    cornerRadius = 2,
    borderWidth = 1,
    spacing = 6,
    animationSpeed = 15,
}

themes["Default"] = defaultTheme
themes["ImGui"] = imguiTheme
currentTheme = defaultTheme

function Theme.register(name, theme)
    theme.name = name
    themes[name] = theme
end

function Theme.get(name)
    return themes[name]
end

function Theme.list()
    local names = {}
    for name, _ in pairs(themes) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function Theme.set(name)
    if themes[name] then
        currentTheme = themes[name]
        for _, callback in ipairs(onChangeCallbacks) do
            callback(currentTheme)
        end
        return true
    end
    return false
end

function Theme.current()
    return currentTheme
end

function Theme.name()
    return currentTheme.name
end

function Theme.color(name)
    return currentTheme.colors[name] or {1, 1, 1, 1}
end

function Theme.cornerRadius()
    return currentTheme.cornerRadius
end

function Theme.borderWidth()
    return currentTheme.borderWidth
end

function Theme.spacing()
    return currentTheme.spacing
end

function Theme.animationSpeed()
    return currentTheme.animationSpeed
end

function Theme.onChange(callback)
    table.insert(onChangeCallbacks, callback)
end

function Theme.applyToElement(element, elementType)
    if elementType == "button" then
        element.colors = {
            normal = Theme.color("button"),
            hovered = Theme.color("buttonHover"),
            pressed = Theme.color("buttonPressed"),
            text = Theme.color("buttonText")
        }
        element.currentColor = {unpack(Theme.color("button"))}
        element.cornerRadius = Theme.cornerRadius()
    elseif elementType == "panel" then
        element.color = Theme.color("panel")
        element.borderColor = Theme.color("panelBorder")
        element.cornerRadius = Theme.cornerRadius() + 2
    elseif elementType == "toggle" then
        element.colors = {
            off = Theme.color("toggle"),
            on = Theme.color("toggleOn"),
            knob = Theme.color("toggleKnob"),
            text = Theme.color("text")
        }
        element.currentColor = element.on and {unpack(Theme.color("toggleOn"))} or {unpack(Theme.color("toggle"))}
    elseif elementType == "slider" then
        element.colors = {
            track = Theme.color("slider"),
            fill = Theme.color("sliderFill"),
            knob = Theme.color("sliderKnob")
        }
    elseif elementType == "checkbox" then
        element.colors = {
            box = Theme.color("checkbox"),
            checked = Theme.color("checkboxChecked"),
            check = Theme.color("checkmark"),
            text = Theme.color("text")
        }
        element.currentColor = element.checked and {unpack(Theme.color("checkboxChecked"))} or {unpack(Theme.color("checkbox"))}
    elseif elementType == "textinput" then
        element.colors = {
            bg = Theme.color("input"),
            border = Theme.color("inputBorder"),
            focused = Theme.color("inputFocused"),
            text = Theme.color("text"),
            placeholder = Theme.color("textMuted"),
            cursor = Theme.color("text")
        }
        element.borderColor = {unpack(Theme.color("inputBorder"))}
    elseif elementType == "dropdown" then
        element.colors = {
            bg = Theme.color("dropdown"),
            hover = Theme.color("dropdownHover"),
            selected = Theme.color("dropdownSelected"),
            border = Theme.color("panelBorder"),
            text = Theme.color("text"),
            placeholder = Theme.color("textMuted"),
            dropdown = Theme.color("dropdownList")
        }
        element.cornerRadius = Theme.cornerRadius()
    elseif elementType == "progressbar" then
        element.colors = {
            bg = Theme.color("progressBg"),
            fill = Theme.color("progressFill"),
            border = Theme.color("progressBorder"),
            text = Theme.color("text")
        }
        element.cornerRadius = Theme.cornerRadius()
    elseif elementType == "scrollarea" then
        element.colors = {
            bg = Theme.color("scrollArea"),
            scrollbar = Theme.color("scrollbar"),
            scrollbarHover = Theme.color("scrollbarHover"),
            scrollbarDrag = Theme.color("scrollbarDrag")
        }
    elseif elementType == "label" then
        element.color = Theme.color("text")
    end
end

return Theme
