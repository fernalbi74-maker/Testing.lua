local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

-- Состояния
local flySpeed = 60
local flyOn, noclipOn, hpLock = false, false, false
local bv, bg
local conns = {}

-- Утилиты
local function tw(o, t, p, s)
    TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function getHum()
    local c = LP.Character
    if not c then return nil, nil end
    return c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

-- ===== GUI КОНСТРУКЦИЯ =====
local gui = new("ScreenGui", {
    Name = "goodgameg_menu", ResetOnSpawn = false, IgnoreGuiInset = true,
}, (typeof(gethui) == "function" and gethui()) or CoreGui)

local overlay = new("Frame", {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK,
    BackgroundTransparency = 1, BorderSizePixel = 0,
}, gui)

local panel = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(280, 350), BackgroundColor3 = BLACK,
    BorderSizePixel = 0, GroupTransparency = 1,
}, overlay)
new("UICorner", {CornerRadius = UDim.new(0, 12)}, panel)
new("UIStroke", {Color = WHITE, Thickness = 1.5}, panel)

-- Тень
new("ImageLabel", {
    Size = UDim2.new(1, 60, 1, 60), Position = UDim2.fromOffset(-30, -30),
    BackgroundTransparency = 1, Image = "rbxassetid://6014261993",
    ImageColor3 = BLACK, ImageTransparency = 0.4, ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0,
}, panel)

-- Заголовок
new("TextLabel", {
    Size = UDim2.new(1, -50, 0, 40), Position = UDim2.fromOffset(15, 0),
    BackgroundTransparency = 1, Text = "goodgameg", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local closeBtn = new("TextButton", {
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -35, 0, 5),
    BackgroundTransparency = 1, Text = "×", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 24, AutoButtonColor = false,
}, panel)

-- Разделитель вкладок
new("Frame", {
    Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 40),
    BackgroundColor3 = WHITE, BackgroundTransparency = 0.8, BorderSizePixel = 0,
}, panel)

-- Логика вкладок
local tabBtns, tabLines, pages = {}, {}, {}
local function makeTab(name, text, x)
    local b = new("TextButton", {
        Size = UDim2.new(0.5, -10, 0, 35), Position = UDim2.new(x, x == 0 and 10 or 0, 0, 45),
        BackgroundTransparency = 1, Text = text, TextColor3 = WHITE,
        Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false,
    }, panel)
    local line = new("Frame", {
        Size = UDim2.new(1, -20, 0, 2), Position = UDim2.fromOffset(10, 35),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, Visible = false,
    }, b)
    tabBtns[name], tabLines[name] = b, line
    local page = new("Frame", {
        Size = UDim2.new(1, 0, 1, -90), Position = UDim2.fromOffset(0, 90),
        BackgroundTransparency = 1, Visible = false,
    }, panel)
    pages[name] = page
    return page
end

local pPlayer = makeTab("player", "ИГРОК", 0)
local pKill = makeTab("kill", "УБИЙСТВО", 0.5)

local function showTab(name)
    for k, f in pairs(pages) do f.Visible = (k == name) end
    for k, b in pairs(tabBtns) do
        b.TextTransparency = (k == name) and 0 or 0.6
        tabLines[k].Visible = (k == name)
    end
end

-- Элемент меню (кнопка)
local function item(parent, y, icon, text)
    local btn = new("TextButton", {
        Size = UDim2.new(1, -20, 0, 40), Position = UDim2.fromOffset(10, y),
        BackgroundColor3 = WHITE, BackgroundTransparency = 1,
        AutoButtonColor = false, Text = "",
    }, parent)
    new("UICorner", {CornerRadius = UDim.new(0, 6)}, btn)
    
    local bar = new("Frame", {
        Size = UDim2.fromOffset(3, 22), Position = UDim2.fromOffset(0, 9),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, Visible = false,
    }, btn)
    
    new("TextLabel", {
        Size = UDim2.fromOffset(25, 40), Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1, Text = icon, TextColor3 = WHITE,
        Font = Enum.Font.GothamBold, TextSize = 16,
    }, btn)
    
    new("TextLabel", {
        Size = UDim2.new(1, -110, 1, 0), Position = UDim2.fromOffset(38, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = WHITE,
        Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    }, btn)
    
    local state = new("TextLabel", {
        Size = UDim2.fromOffset(50, 40), Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1, Text = "ВЫКЛ", TextColor3 = WHITE, TextTransparency = 0.4,
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
    }, btn)

    btn.MouseEnter:Connect(function() tw(btn, 0.2, {BackgroundTransparency = 0.9}) end)
    btn.MouseLeave:Connect(function() tw(btn, 0.2, {BackgroundTransparency = 1}) end)
    btn.MouseButton1Down:Connect(function() tw(btn, 0.1, {BackgroundTransparency = 0.8}) end)
    btn.MouseButton1Up:Connect(function() tw(btn, 0.1, {BackgroundTransparency = 0.9}) end)
    
    return btn, bar, state
end

-- ===== ФУНКЦИОНАЛ =====

-- Fly
local function setFly(on)
    flyOn = on
    local hum, hrp = getHum()
    if on and hrp and hum then
        bv = new("BodyVelocity", {MaxForce = Vector3.one * 1e6, Velocity = Vector3.zero}, hrp)
        bg = new("BodyGyro", {MaxTorque = Vector3.one * 1e6, P = 1e4, CFrame = hrp.CFrame}, hrp)
        hum.PlatformStand = true
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if hum then hum.PlatformStand = false end
    end
end

-- Noclip
local function setNoclip(on)
    noclipOn = on
end

-- UI Элементы
local flyBtn, flyBar, flyState = item(pPlayer, 0, "✈", "Fly (Пробел/Ctrl)")
local nocBtn, nocBar, nocState = item(pPlayer, 45, "👻", "Noclip")
local hpBtn, hpBar, hpState = item(pPlayer, 90, "❤", "God Mode (Local)")

local killBtn = item(pKill, 0, "☠", "Убить всех NPC/Боссов")

-- Обработка кликов
flyBtn.MouseButton1Click:Connect(function()
    setFly(not flyOn)
    flyBar.Visible = flyOn
    flyState.Text = flyOn and "ВКЛ" or "ВЫКЛ"
end)

nocBtn.MouseButton1Click:Connect(function()
    setNoclip(not noclipOn)
    nocBar.Visible = noclipOn
    nocState.Text = noclipOn and "ВКЛ" or "ВЫКЛ"
end)

hpBtn.MouseButton1Click:Connect(function()
    hpLock = not hpLock
    hpBar.Visible = hpLock
    hpState.Text = hpLock and "ВКЛ" or "ВЫКЛ"
end)

killBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= LP.Character then
            v.Health = 0
            count += 1
        end
    end
    -- Вторая попытка через удаление RootPart для обхода некоторых скриптов боссов
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "HumanoidRootPart" and not v:IsDescendantOf(LP.Character) then
            v:Destroy()
        end
    end
end)

-- Переключение вкладок
for name, b in pairs(tabBtns) do
    b.MouseButton1Click:Connect(function() showTab(name) end)
end
showTab("player")

-- ===== ЦИКЛЫ И ОБХОД =====
RunService.RenderStepped:Connect(function()
    if flyOn and bv and bg then
        local hum, hrp = getHum()
        if not hrp then return end
        local move = hum and hum.MoveDirection or Vector3.zero
        local vert = 0
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vert += 1 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vert -= 1 end
        local vel = move + Vector3.new(0, vert, 0)
        bv.Velocity = vel.Magnitude > 0 and vel.Unit * flySpeed or Vector3.zero
        bg.CFrame = Camera.CFrame
    end
end)

RunService.Stepped:Connect(function()
    if noclipOn and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if hpLock then
        local hum = getHum()
        if hum then hum.Health = hum.MaxHealth end
    end
end)

-- Анимация появления
tw(overlay, 0.4, {BackgroundTransparency = 0.5})
tw(panel, 0.5, {GroupTransparency = 0, Size = UDim2.fromOffset(280, 350)}, Enum.EasingStyle.Back)

closeBtn.MouseButton1Click:Connect(function()
    tw(overlay, 0.3, {BackgroundTransparency = 1})
    tw(panel, 0.3, {GroupTransparency = 1, Size = UDim2.fromOffset(200, 250)})
    task.wait(0.3)
    gui:Destroy()
end)
