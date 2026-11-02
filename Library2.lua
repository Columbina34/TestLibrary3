-- Monium Library v2.1.2 — Simple Edition
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local function GuiParent()
    if gethui then local ok, h = pcall(gethui); if ok and h then return h end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local Theme = {
    Bg      = Color3.fromRGB(20, 20, 26),
    Surface = Color3.fromRGB(28, 28, 36),
    Alt     = Color3.fromRGB(38, 38, 48),
    Border  = Color3.fromRGB(48, 48, 62),
    Text    = Color3.fromRGB(238, 238, 245),
    Dim     = Color3.fromRGB(140, 140, 158),
    Accent  = Color3.fromRGB(130, 95, 255),
    Green   = Color3.fromRGB(90, 220, 140),
    Yellow  = Color3.fromRGB(250, 190, 90),
    Red     = Color3.fromRGB(255, 100, 100),
}

local function mk(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then i[k] = v end
    end
    if props and props.Parent then i.Parent = props.Parent end
    return i
end

local function corner(r)
    return mk("UICorner", { CornerRadius = r or UDim.new(0, 6) })
end

local function tween(i, p, t)
    TweenService:Create(i, TweenInfo.new(t or 0.15), p):Play()
end

local function list(pad, parent)
    return mk("UIListLayout", {
        Padding = UDim.new(0, pad or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function pad(p, parent)
    return mk("UIPadding", {
        PaddingTop = UDim.new(0, p), PaddingBottom = UDim.new(0, p),
        PaddingLeft = UDim.new(0, p), PaddingRight = UDim.new(0, p),
        Parent = parent,
    })
end

-- ─────────────────────────────────────────────────────────────
-- Class tables
-- ─────────────────────────────────────────────────────────────
local Lib    = {}
local Window = {}
local Tab    = {}
local Group  = {}

Window.__index = Window
Tab.__index    = Tab
Group.__index  = Group

-- ─────────────────────────────────────────────────────────────
-- Notifications
-- ─────────────────────────────────────────────────────────────
local notifGui, notifHolder, notifCount = nil, nil, 0

function Lib:Notify(title, text, duration)
    if not notifGui or not notifGui.Parent then
        notifGui = mk("ScreenGui", {
            Name = "MoniumNotif", ResetOnSpawn = false,
            DisplayOrder = 9999, Parent = GuiParent(),
        })
        notifHolder = mk("Frame", {
            Size = UDim2.new(0, 300, 1, -40),
            Position = UDim2.new(1, -320, 0, 20),
            BackgroundTransparency = 1, Parent = notifGui,
        })
        list(8, notifHolder)
    end

    while notifCount >= 4 do
        local old
        for _, c in ipairs(notifHolder:GetChildren()) do
            if c:IsA("Frame") then old = c; break end
        end
        if not old then break end
        old:Destroy(); notifCount = notifCount - 1
    end

    local f = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 40, 0, 0),
        Parent = notifHolder,
    })
    corner(UDim.new(0, 10)).Parent = f
    mk("UIStroke", { Color = Theme.Border, Parent = f })
    notifCount = notifCount + 1

    mk("Frame", {
        Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = f,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0, 20, 0, 10),
        BackgroundTransparency = 1, Text = title or "Notice",
        TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0, 20, 0, 30),
        BackgroundTransparency = 1, Text = text or "",
        TextColor3 = Theme.Dim, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
    })

    tween(f, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, 0.25)
    task.delay(duration or 4, function()
        if not f.Parent then return end
        tween(f, { BackgroundTransparency = 1, Position = UDim2.new(1, 40, 0, 0) }, 0.25)
        task.wait(0.3)
        if f.Parent then f:Destroy() end
        notifCount = math.max(0, notifCount - 1)
    end)
end

-- ─────────────────────────────────────────────────────────────
-- Window
-- ─────────────────────────────────────────────────────────────
function Lib:Window(opts)
    opts = opts or {}
    local self = setmetatable({}, Window)
    self.Tabs  = {}
    self.Title = opts.Title or "Hub"
    self.Size  = UDim2.fromOffset(560, 400)

    self.Gui = mk("ScreenGui", {
        Name = "MoniumUI", ResetOnSpawn = false,
        DisplayOrder = 9000, Parent = GuiParent(),
    })

    self.Frame = mk("Frame", {
        Size = self.Size,
        Position = UDim2.new(0.5, -280, 0.5, -200),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
        Parent = self.Gui,
    })
    corner(UDim.new(0, 12)).Parent = self.Frame
    mk("UIStroke", { Color = Theme.Border, Parent = self.Frame })

    local header = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
        Parent = self.Frame,
    })
    corner(UDim.new(0, 12)).Parent = header
    mk("Frame", {
        Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = header,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, Text = self.Title,
        TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
    })

    local close = mk("TextButton", {
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = Theme.Alt, BorderSizePixel = 0, Text = "×",
        TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 18,
        AutoButtonColor = false, Parent = header,
    })
    corner().Parent = close
    close.MouseEnter:Connect(function() tween(close, { BackgroundColor3 = Theme.Red }) end)
    close.MouseLeave:Connect(function() tween(close, { BackgroundColor3 = Theme.Alt }) end)
    close.MouseButton1Click:Connect(function() self.Gui:Destroy() end)

    self.Sidebar = mk("Frame", {
        Size = UDim2.new(0, 140, 1, -44), Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Parent = self.Frame,
    })
    list(4, self.Sidebar)
    pad(8, self.Sidebar)

    self.Content = mk("Frame", {
        Size = UDim2.new(1, -140, 1, -44), Position = UDim2.new(0, 140, 0, 44),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = self.Frame,
    })
    pad(10, self.Content)

    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = self.Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            self.Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    return self
end

function Window:Tab(opts)
    opts = opts or {}
    local self2 = setmetatable({}, Tab)
    self2.Window = self
    self2.Name   = opts.Name or "Tab"
    self2.Groups = {}

    self2.Button = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0, Text = "  " .. self2.Name,
        TextColor3 = Theme.Dim, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
        Parent = self.Sidebar,
    })
    corner().Parent = self2.Button

    self2.Frame = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, Parent = self.Content,
    })
    list(8, self2.Frame)

    self2.Button.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Frame.Visible = (t == self2)
            tween(t.Button, {
                BackgroundColor3 = (t == self2) and Theme.Accent or Theme.Bg,
                TextColor3 = (t == self2) and Theme.Text or Theme.Dim,
            })
        end
    end)

    table.insert(self.Tabs, self2)
    if #self.Tabs == 1 then
        self2.Frame.Visible = true
        self2.Button.BackgroundColor3 = Theme.Accent
        self2.Button.TextColor3 = Theme.Text
    end
    return self2
end

-- ─────────────────────────────────────────────────────────────
-- Tab
-- ─────────────────────────────────────────────────────────────
function Tab:Group(opts)
    opts = opts or {}
    local self2 = setmetatable({}, Group)
    self2.Tab = self

    self2.Frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
        Parent = self.Frame,
    })
    corner(UDim.new(0, 10)).Parent = self2.Frame
    list(6, self2.Frame)
    pad(10, self2.Frame)

    if opts.Name then
        mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
            Text = string.upper(opts.Name), TextColor3 = Theme.Accent,
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = self2.Frame,
        })
    end

    table.insert(self.Groups, self2)
    return self2
end

-- ─────────────────────────────────────────────────────────────
-- Group components
-- ─────────────────────────────────────────────────────────────
function Group:Button(opts)
    opts = opts or {}
    local b = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Alt,
        BorderSizePixel = 0, Text = opts.Name or "Button",
        TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        AutoButtonColor = false, Parent = self.Frame,
    })
    corner().Parent = b
    b.MouseEnter:Connect(function() tween(b, { BackgroundColor3 = Theme.Accent }) end)
    b.MouseLeave:Connect(function() tween(b, { BackgroundColor3 = Theme.Alt }) end)
    b.MouseButton1Click:Connect(function()
        if opts.Callback then
            local ok, e = pcall(opts.Callback)
            if not ok then warn("[Monium] " .. tostring(e)) end
        end
    end)
    return b
end

function Group:Toggle(opts)
    opts = opts or {}
    local state = opts.Default or false

    local frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Alt,
        BorderSizePixel = 0, Parent = self.Frame,
    })
    corner().Parent = frame

    mk("TextLabel", {
        Size = UDim2.new(1, -64, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = opts.Name or "Toggle",
        TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = frame,
    })

    local pill = mk("Frame", {
        Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = state and Theme.Accent or Theme.Border,
        BorderSizePixel = 0, Parent = frame,
    })
    corner(UDim.new(1, 0)).Parent = pill

    local knob = mk("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Parent = pill,
    })
    corner(UDim.new(1, 0)).Parent = knob

    local hit = mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", Parent = frame,
    })

    local ctrl = {}
    function ctrl:Get() return state end
    function ctrl:Set(v, silent)
        state = v
        tween(pill, { BackgroundColor3 = v and Theme.Accent or Theme.Border })
        tween(knob, { Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
        if not silent and opts.Callback then pcall(opts.Callback, v) end
    end
    hit.MouseButton1Click:Connect(function() ctrl:Set(not state) end)
    return ctrl
end

function Group:Slider(opts)
    opts = opts or {}
    local min, max = opts.Min or 0, opts.Max or 100
    local value = opts.Default or min

    local frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Theme.Alt,
        BorderSizePixel = 0, Parent = self.Frame,
    })
    corner().Parent = frame

    mk("TextLabel", {
        Size = UDim2.new(1, -70, 0, 18), Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1, Text = opts.Name or "Slider",
        TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = frame,
    })

    local valLabel = mk("TextLabel", {
        Size = UDim2.new(0, 60, 0, 18), Position = UDim2.new(1, -72, 0, 6),
        BackgroundTransparency = 1, Text = tostring(value),
        TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = frame,
    })

    local bar = mk("Frame", {
        Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 1, -16),
        BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = frame,
    })
    corner(UDim.new(1, 0)).Parent = bar

    local fill = mk("Frame", {
        Size = UDim2.new((value - min) / math.max(1, max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = bar,
    })
    corner(UDim.new(1, 0)).Parent = fill

    local hitbox = mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", Parent = bar,
    })

    local ctrl = {}
    local function set(v, silent)
        v = math.clamp(v, min, max)
        if opts.Round then v = math.floor(v + 0.5) end
        value = v
        valLabel.Text = tostring(v)
        tween(fill, { Size = UDim2.new((v - min) / math.max(1, max - min), 0, 1, 0) }, 0.08)
        if not silent and opts.Callback then pcall(opts.Callback, v) end
    end
    function ctrl:Get() return value end
    function ctrl:Set(v) set(v) end

    hitbox.MouseButton1Down:Connect(function()
        local c1, c2
        c1 = UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local rel = math.clamp(
                    (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                set(min + (max - min) * rel)
            end
        end)
        c2 = UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                if c1 then c1:Disconnect() end
                if c2 then c2:Disconnect() end
            end
        end)
    end)

    return ctrl
end

function Group:Input(opts)
    opts = opts or {}
    local frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Alt,
        BorderSizePixel = 0, Parent = self.Frame,
    })
    corner().Parent = frame

    local box = mk("TextBox", {
        Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = opts.Default or "",
        PlaceholderText = opts.Placeholder or (opts.Name or "Type..."),
        PlaceholderColor3 = Theme.Dim, TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, Parent = frame,
    })

    local ctrl = {}
    function ctrl:Get() return box.Text end
    function ctrl:Set(v) box.Text = v end

    box.FocusLost:Connect(function(enter)
        if enter and opts.Callback then pcall(opts.Callback, box.Text) end
    end)
    return ctrl
end

function Group:Dropdown(opts)
    opts = opts or {}
    local options = opts.Options or {}
    local selected = opts.Default
    local open = false

    local container = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Alt,
        BorderSizePixel = 0, Parent = self.Frame,
    })
    corner().Parent = container

    local btn = mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", Parent = container,
    })

    local label = mk("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = (opts.Name or "Select") .. (selected and ": " .. selected or ""),
        TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container,
    })

    mk("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1, Text = "▾",
        TextColor3 = Theme.Dim, Font = Enum.Font.GothamBold, TextSize = 12,
        Parent = container,
    })

    local drop = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 1, 4), BackgroundColor3 = Theme.Surface,
        Visible = false, ZIndex = 10, Parent = container,
    })
    corner().Parent = drop
    mk("UIStroke", { Color = Theme.Border, Parent = drop })
    list(2, drop)
    mk("UIPadding", {
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        Parent = drop,
    })

    local ctrl = {}

    for _, opt in ipairs(options) do
        local ob = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Theme.Alt,
            BorderSizePixel = 0, Text = tostring(opt),
            TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
            ZIndex = 11, Parent = drop,
        })
        corner().Parent = ob
        ob.MouseEnter:Connect(function() tween(ob, { BackgroundColor3 = Theme.Accent }, 0.1) end)
        ob.MouseLeave:Connect(function() tween(ob, { BackgroundColor3 = Theme.Alt }, 0.1) end)
        ob.MouseButton1Click:Connect(function()
            selected = opt
            label.Text = (opts.Name or "Select") .. ": " .. tostring(opt)
            drop.Visible = false; open = false
            if opts.Callback then pcall(opts.Callback, opt) end
        end)
    end

    function ctrl:Get() return selected end
    function ctrl:Set(v)
        selected = v
        label.Text = (opts.Name or "Select") .. ": " .. tostring(v)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open; drop.Visible = open
    end)

    UIS.InputBegan:Connect(function(input)
        if not open then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local mx, my = input.Position.X, input.Position.Y
        local ax, ay = container.AbsolutePosition.X, container.AbsolutePosition.Y
        local sx, sy = container.AbsoluteSize.X, container.AbsoluteSize.Y + drop.AbsoluteSize.Y
        if mx < ax or mx > ax + sx or my < ay or my > ay + sy then
            open = false; drop.Visible = false
        end
    end)

    return ctrl
end

function Group:Label(text)
    return mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = text or "",
        TextColor3 = Theme.Dim, Font = Enum.Font.Gotham, TextSize = 11,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })
end

function Group:Divider()
    return mk("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0, Parent = self.Frame,
    })
end

return Lib
