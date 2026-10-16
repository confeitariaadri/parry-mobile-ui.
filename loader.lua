--[[
    Parry Mobile UI - loader.lua
    Interface demonstrativa para Delta/ambiente Luau.
    Somente UI: não detecta projéteis nem aciona parry no Death Ball.
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("ParryMobileUI")
if existing then
    existing:Destroy()
end

local C = {
    bg = Color3.fromRGB(17, 18, 24),
    panel = Color3.fromRGB(28, 30, 39),
    border = Color3.fromRGB(54, 57, 70),
    text = Color3.fromRGB(244, 245, 249),
    muted = Color3.fromRGB(151, 156, 171),
    green = Color3.fromRGB(72, 210, 139),
    yellow = Color3.fromRGB(245, 197, 82),
    red = Color3.fromRGB(231, 78, 95),
    off = Color3.fromRGB(65, 68, 81),
}

local function create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

local function round(parent, px)
    create("UICorner", {CornerRadius = UDim.new(0, px)}, parent)
end

local gui = create("ScreenGui", {
    Name = "ParryMobileUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local panel = create("Frame", {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.52, 0),
    Size = UDim2.fromOffset(282, 268),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, gui)
round(panel, 14)
create("UIStroke", {Color = C.border, Thickness = 1}, panel)

local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, panel)
round(header, 14)
create("Frame", {
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, header)

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 0),
    Size = UDim2.new(1, -62, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "PARRY  /  MOBILE",
    TextColor3 = C.text,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minimize = create("TextButton", {
    Name = "Minimize",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.fromOffset(30, 27),
    BackgroundColor3 = Color3.fromRGB(48, 50, 62),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "−",
    TextColor3 = C.text,
    TextSize = 18,
}, header)
round(minimize, 8)

local body = create("Frame", {
    Name = "Body",
    Position = UDim2.fromOffset(0, 44),
    Size = UDim2.new(1, 0, 1, -44),
    BackgroundTransparency = 1,
}, panel)
create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 11),
    PaddingRight = UDim.new(0, 11),
}, body)
create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, body)

local state = {
    autoParry = false,
    perfectParry = false,
    timingMs = 80,
}

local function addToggle(order, title, key, accent)
    local row = create("Frame", {
        Name = key .. "Row",
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    }, body)
    round(row, 10)

    local stripe = create("Frame", {
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.fromOffset(3, 30),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
    }, row)
    round(stripe, 2)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -75, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = C.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local button = create("TextButton", {
        Name = "Toggle",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(48, 25),
        BackgroundColor3 = C.off,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, row)
    round(button, 13)

    local knob = create("Frame", {
        Name = "Knob",
        Position = UDim2.new(0, 4, 0.5, -8),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, button)
    round(knob, 8)

    local function render()
        local on = state[key]
        button.BackgroundColor3 = on and accent or C.off
        knob.Position = on and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    end

    button.Activated:Connect(function()
        state[key] = not state[key]
        render()
        print(("[Parry UI] %s = %s (visual only)"):format(key, tostring(state[key])))
    end)
    render()
end

addToggle(1, "AUTO PARRY", "autoParry", C.green)
addToggle(2, "PERFECT PARRY", "perfectParry", C.yellow)

local timing = create("Frame", {
    Name = "Timing",
    LayoutOrder = 3,
    Size = UDim2.new(1, 0, 0, 83),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, body)
round(timing, 10)

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 6),
    Size = UDim2.new(1, -90, 0, 18),
    Font = Enum.Font.GothamBold,
    Text = "PERFECT TIMING",
    TextColor3 = C.muted,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, timing)

local value = create("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 6),
    Size = UDim2.fromOffset(72, 18),
    Font = Enum.Font.GothamBold,
    Text = "80 ms",
    TextColor3 = C.yellow,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
}, timing)

local track = create("Frame", {
    Name = "Track",
    Position = UDim2.new(0, 12, 0, 39),
    Size = UDim2.new(1, -24, 0, 6),
    BackgroundColor3 = C.off,
    BorderSizePixel = 0,
}, timing)
round(track, 3)

local fill = create("Frame", {
    Name = "Fill",
    Size = UDim2.new(state.timingMs / 250, 0, 1, 0),
    BackgroundColor3 = C.yellow,
    BorderSizePixel = 0,
}, track)
round(fill, 3)

local handle = create("Frame", {
    Name = "Handle",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(state.timingMs / 250, 0, 0.5, 0),
    Size = UDim2.fromOffset(14, 14),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 3,
}, track)
round(handle, 7)

local sliderHitbox = create("TextButton", {
    Name = "SliderHitbox",
    Position = UDim2.new(0, -8, 0.5, -15),
    Size = UDim2.new(1, 16, 0, 30),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
}, track)

local function updateTiming(x)
    local width = track.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
    state.timingMs = math.clamp(math.floor((alpha * 250) / 5 + 0.5) * 5, 0, 250)
    local p = state.timingMs / 250
    fill.Size = UDim2.new(p, 0, 1, 0)
    handle.Position = UDim2.new(p, 0, 0.5, 0)
    value.Text = tostring(state.timingMs) .. " ms"
end

local sliding = false
sliderHitbox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = true
        updateTiming(input.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateTiming(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = false
    end
end)

create("TextLabel", {
    Name = "Disclaimer",
    LayoutOrder = 4,
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "UI DEMO  •  NO GAME AUTOMATION",
    TextColor3 = C.muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Center,
}, body)

local minimized = false
minimize.Activated:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    panel.Size = minimized and UDim2.fromOffset(282, 44) or UDim2.fromOffset(282, 268)
    minimize.Text = minimized and "+" or "−"
end)

-- Drag panel with mouse or touch by holding the header.
local dragging = false
local dragStart
local panelStart
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        panelStart = panel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            panelStart.X.Scale, panelStart.X.Offset + delta.X,
            panelStart.Y.Scale, panelStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[ParryMobileUI] Loaded. UI only; no parry automation.")
