# KuruUI Documentation

## Table of Contents

1. [Getting Started](#getting-started)
2. [Core Functions](#core-functions)
3. [Components](#components)
4. [Theme System](#theme-system)
5. [Tween System](#tween-system)
6. [Juice Animations](#juice-animations)

---

## Getting Started

### Installation

Copy the `kuruui` folder into your Love2D project directory.

### Basic Setup

```lua
local KuruUI = require("kuruui")

function love.load()
    -- Optional: Enable scaling for resolution independence
    KuruUI.enableScaling(800, 600)
end

function love.update(dt)
    KuruUI.update(dt)
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
    KuruUI.keypressed(key)
end

function love.textinput(text)
    KuruUI.textinput(text)
end

function love.resize(w, h)
    KuruUI.resize(w, h)
end
```

---

## Core Functions

### KuruUI.add(element)
Adds an element to the root UI.
```lua
local panel = KuruUI.add(KuruUI.Panel:new(50, 50, 300, 200))
```

### KuruUI.remove(element)
Removes an element from the root UI.

### KuruUI.clear()
Removes all elements and cancels all tweens.

### KuruUI.enableScaling(baseWidth, baseHeight)
Enables automatic UI scaling. Design your UI for the base resolution and it will scale to any window size.
```lua
KuruUI.enableScaling(800, 600)
```

### KuruUI.disableScaling()
Disables automatic scaling.

### KuruUI.updateScale()
Manually recalculate scale (called automatically on resize).

### KuruUI.toUICoords(x, y)
Convert screen coordinates to UI coordinates.

### KuruUI.toScreenCoords(x, y)
Convert UI coordinates to screen coordinates.

---

## Components

### Element (Base Class)

All components inherit from Element.

**Properties:**
- `x, y` - Position
- `w, h` - Size
- `visible` - Whether element is drawn
- `enabled` - Whether element receives input
- `alpha` - Transparency (0-1)
- `scale` - Scale multiplier
- `parent` - Parent element
- `children` - Child elements table

**Methods:**
- `element:addChild(child)` - Add a child element
- `element:removeChild(child)` - Remove a child element
- `element:getAbsolutePosition()` - Get position relative to screen
- `element:contains(x, y)` - Check if point is inside element
- `element:fadeIn(duration, easing)` - Fade in animation
- `element:fadeOut(duration, easing)` - Fade out animation
- `element:slideTo(x, y, duration, easing)` - Slide animation
- `element:scaleTo(scale, duration, easing)` - Scale animation
- `element:pop(duration)` - Pop animation

---

### Button

```lua
local button = KuruUI.Button:new(x, y, width, height, text)
```

**Properties:**
- `text` - Button label
- `colors` - Table with `normal`, `hovered`, `pressed`, `text` colors
- `currentColor` - Current interpolated color
- `cornerRadius` - Corner rounding
- `animateHover` - Enable hover color animation (default true)
- `animateClick` - Enable click scale animation (default true)

**Callbacks:**
- `button.onClick` - Called when button is clicked

**Example:**
```lua
local btn = KuruUI.Button:new(20, 20, 200, 40, "Click Me")
btn.onClick = function()
    print("Button clicked!")
end
```

---

### Label

```lua
local label = KuruUI.Label:new(x, y, text)
```

**Properties:**
- `text` - Display text
- `color` - Text color

---

### Panel

```lua
local panel = KuruUI.Panel:new(x, y, width, height)
```

**Properties:**
- `color` - Background color
- `borderColor` - Border color
- `cornerRadius` - Corner rounding
- `border` - Show border (default true)

**Methods:**
- `panel:slideIn(direction, duration, easing)` - Slide in from "left", "right", "top", or "bottom"
- `panel:slideOut(direction, duration, easing)` - Slide out

---

### Slider

```lua
local slider = KuruUI.Slider:new(x, y, width, height)
```

**Properties:**
- `value` - Current value (0-1 normalized)
- `min, max` - Value range (default 0-1)
- `colors` - Table with `track`, `fill`, `knob` colors
- `knobRadius` - Knob size
- `animate` - Enable smooth value animation

**Methods:**
- `slider:getValue()` - Get value in min-max range
- `slider:setValue(value, animate)` - Set value

**Callbacks:**
- `slider.onChange(self, value)` - Called when value changes

---

### Checkbox

```lua
local checkbox = KuruUI.Checkbox:new(x, y, text)
```

**Properties:**
- `text` - Label text
- `checked` - Current state
- `colors` - Table with `box`, `checked`, `check`, `text` colors

**Callbacks:**
- `checkbox.onChange(self, checked)` - Called when state changes

---

### Toggle

iOS-style toggle switch.

```lua
local toggle = KuruUI.Toggle:new(x, y, text)
```

**Properties:**
- `text` - Label text
- `on` - Current state
- `colors` - Table with `off`, `on`, `knob`, `text` colors

**Callbacks:**
- `toggle.onChange(self, on)` - Called when state changes

---

### TextInput

```lua
local input = KuruUI.TextInput:new(x, y, width, height)
```

**Properties:**
- `text` - Current text
- `placeholder` - Placeholder text
- `focused` - Whether input is focused
- `cursorPos` - Cursor position
- `colors` - Table with `bg`, `border`, `focused`, `text`, `placeholder`, `cursor` colors

**Callbacks:**
- `input.onChange(self, text)` - Called when text changes
- `input.onSubmit(self, text)` - Called when Enter is pressed

---

### Dropdown

```lua
local dropdown = KuruUI.Dropdown:new(x, y, width, height)
```

**Properties:**
- `options` - Array of option strings
- `selected` - Currently selected option text
- `selectedIndex` - Currently selected index
- `placeholder` - Placeholder text
- `maxVisible` - Maximum visible options before scrolling
- `colors` - Various color options

**Methods:**
- `dropdown:setOptions(options)` - Set options array
- `dropdown:select(index)` - Select option by index

**Callbacks:**
- `dropdown.onChange(self, value, index)` - Called when selection changes

---

### ProgressBar

```lua
local bar = KuruUI.ProgressBar:new(x, y, width, height)
```

**Properties:**
- `value` - Current value (0-1 normalized)
- `displayValue` - Animated display value
- `min, max` - Value range
- `colors` - Table with `bg`, `fill`, `border`, `text` colors
- `showText` - Show text overlay
- `textFormat` - "percent", "value", "fraction", or function(self)
- `segments` - Number of segments (0 for solid)
- `glow` - Enable glow effect
- `pulseOnLow` - Pulse when below threshold
- `pulseThreshold` - Threshold for pulsing (default 0.25)
- `animate` - Enable smooth value animation
- `animationSpeed` - Animation speed

**Methods:**
- `bar:getValue()` - Get value in min-max range
- `bar:setValue(value, instant)` - Set value
- `bar:setValueNormalized(value, instant)` - Set normalized value (0-1)
- `bar:tweenTo(value, duration, easing)` - Animate to value

---

### ScrollArea

```lua
local scroll = KuruUI.ScrollArea:new(x, y, width, height)
```

**Properties:**
- `scrollX, scrollY` - Current scroll position
- `contentWidth, contentHeight` - Content size
- `scrollSpeed` - Scroll wheel speed
- `showScrollbarV, showScrollbarH` - Show scrollbars
- `colors` - Scrollbar colors

**Methods:**
- `scroll:setContentSize(width, height)` - Set content size
- `scroll:scrollTo(x, y, animate)` - Scroll to position
- `scroll:clampScroll()` - Clamp scroll to valid range

---

### Tooltip

Attach tooltips to any element.

```lua
KuruUI.tooltip(element, "Tooltip text")
```

**Static Methods:**
- `KuruUI.Tooltip.attach(element, text)` - Attach tooltip
- `KuruUI.Tooltip.detach(element)` - Remove tooltip
- `KuruUI.Tooltip.setDelay(seconds)` - Set hover delay (default 0.5)

---

## Theme System

### Built-in Themes

- `Default` - Dark theme with blue accents
- `ImGui` - Dear ImGui style theme

### Switching Themes

```lua
local Theme = KuruUI.Theme

Theme.set("ImGui")
```

### Getting Theme Values

```lua
local color = Theme.color("primary")
local radius = Theme.cornerRadius()
local spacing = Theme.spacing()
```

### Applying Theme to Elements

```lua
Theme.applyToElement(button, "button")
Theme.applyToElement(panel, "panel")
Theme.applyToElement(toggle, "toggle")
-- etc.
```

### Theme Change Callback

```lua
Theme.onChange(function(theme)
    love.graphics.setBackgroundColor(theme.colors.background)
end)
```

### Creating Custom Themes

```lua
Theme.register("MyTheme", {
    name = "MyTheme",
    colors = {
        background = {0.1, 0.1, 0.1, 1},
        panel = {0.15, 0.15, 0.15, 0.95},
        panelBorder = {0.3, 0.3, 0.3, 1},
        button = {0.3, 0.3, 0.3, 1},
        buttonHover = {0.4, 0.4, 0.4, 1},
        buttonPressed = {0.2, 0.2, 0.2, 1},
        buttonText = {1, 1, 1, 1},
        primary = {0.4, 0.6, 0.9, 1},
        -- ... see theme.lua for all color keys
    },
    cornerRadius = 4,
    borderWidth = 1,
    spacing = 8,
    animationSpeed = 12,
})
```

### Available Color Keys

```
background, panel, panelBorder
button, buttonHover, buttonPressed, buttonText
primary, primaryHover, primaryPressed
success, successHover
danger, dangerHover
warning
text, textMuted
input, inputBorder, inputFocused
toggle, toggleOn, toggleKnob
slider, sliderFill, sliderKnob
checkbox, checkboxChecked, checkmark
scrollbar, scrollbarHover, scrollbarDrag, scrollArea
dropdown, dropdownList, dropdownHover, dropdownSelected
progressBg, progressFill, progressBorder
tooltip, tooltipBorder, tooltipText
notification
```

---

## Tween System

### Basic Tweening

```lua
KuruUI.tween(element, {x = 100, y = 200}, 0.5, "outQuad")
```

### Tween Options

```lua
local tween = KuruUI.Tween.to(element, {alpha = 0}, 0.3, "outQuad")
tween:setDelay(0.5)
tween:setOnComplete(function()
    print("Done!")
end)
tween:setOnUpdate(function(target, progress)
    print("Progress: " .. progress)
end)
```

### Canceling Tweens

```lua
KuruUI.Tween.cancel(element)  -- Cancel all tweens on element
KuruUI.Tween.cancelAll()      -- Cancel all tweens
```

### Available Easing Functions

```
linear
inQuad, outQuad, inOutQuad
inCubic, outCubic, inOutCubic
inQuart, outQuart, inOutQuart
inExpo, outExpo, inOutExpo
inBack, outBack, inOutBack
inElastic, outElastic, inOutElastic
inBounce, outBounce, inOutBounce
```

---

## Juice Animations

The Juice module provides quick animation effects.

```lua
local Juice = KuruUI.Juice
```

### Available Effects

```lua
-- Scale effects
Juice.pop(element, scale, duration)      -- Scale up then back
Juice.punch(element, scale, duration)    -- Scale down with elastic

-- Movement effects
Juice.shake(element, intensity, duration)
Juice.bounce(element, height, duration)
Juice.wiggle(element, angle, duration, count)

-- Visual effects
Juice.flash(element, color, duration)
Juice.pulse(element, minAlpha, maxAlpha, speed)  -- Continuous
Juice.heartbeat(element, scale, speed)           -- Continuous
Juice.glow(element, intensity, speed)            -- Continuous

-- Transitions
Juice.fadeSlideIn(element, direction, distance, duration)
Juice.fadeSlideOut(element, direction, distance, duration)

-- Text effects
Juice.typewriter(element, text, speed, onCharacter, onComplete)
```

### Stopping Continuous Effects

```lua
Juice.stopPulse(element)
Juice.stopHeartbeat(element)
```

### Updating Juice Effects

Call in love.update for elements with juice effects:

```lua
function love.update(dt)
    KuruUI.update(dt)
    Juice.update(element, dt)  -- Updates all juice effects on element
end
```

### Combining Effects

```lua
button.onClick = function()
    Juice.pop(button, 1.2, 0.1)
    Juice.flash(button, {1, 1, 1, 1}, 0.2)
    Juice.shake(button, 4, 0.25)
end
```

---

## Tips

### Performance

- Use `visible = false` instead of removing/adding elements frequently
- Reuse elements when possible
- Limit simultaneous tweens on many elements

### Styling

- Use `Theme.applyToElement()` for consistent styling
- Create custom themes for different game screens
- Use Juice effects sparingly for important interactions

### Layout

- Children positions are relative to parent
- Use `getAbsolutePosition()` when you need screen coordinates
- ScrollArea children are positioned relative to content, not screen
