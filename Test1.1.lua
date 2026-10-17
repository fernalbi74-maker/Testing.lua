-- LocalScript (executor) — read-only dumper
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)
local BTN = Color3.fromRGB(32, 28, 46)
local TEXT = Color3.fromRGB(235, 230, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieDumper"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 380)
frame.Position = UDim2.new(0.5, -260, 0.5, -190)
frame.BackgroundColor3 = BG
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 12)
c.Parent = frame
local s = Instance.new("UIStroke")
s.Color = ACCENT
s.Thickness = 1.5
s.Transparency = 0.4
s.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 12, 0, 6)
title.BackgroundTransparency = 1
title.Text = "ollie · script dumper"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0, 110, 0, 28)
scanBtn.Position = UDim2.new(1, -130, 0, 8)
scanBtn.BackgroundColor3 = ACCENT
scanBtn.BorderSizePixel = 0
scanBtn.Text = "Scan"
scanBtn.TextColor3 = Color3.fromRGB(20, 16, 30)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 12
scanBtn.Parent = frame
local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 6); c2.Parent = scanBtn

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -24, 1, -56)
scroll.Position = UDim2.new(0, 12, 0, 42)
scroll.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = ACCENT
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame
local c3 = Instance.new("UICorner"); c3.CornerRadius = UDim.new(0, 8); c3.Parent = scroll

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 2)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local function addRow(text, indent)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, -8, 0, 18)
    row.BackgroundTransparency = 1
    row.Text = text
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextColor3 = TEXT
    row.Font = Enum.Font.Code
    row.TextSize = 12
    row.Parent = scroll
    row.Position = UDim2.new(0, (indent or 0) * 12, 0, 0)
    return row
end

local function dump()
    for _, ch in ipairs(scroll:GetChildren()) do
        if ch:IsA("TextLabel") then ch:Destroy() end
    end

    local count = 0
    local function walk(inst, depth)
        for _, child in ipairs(inst:GetChildren()) do
            if child:IsA("LuaSourceContainer") then
                count += 1
                local kind = child.ClassName
                local src = ""
                pcall(function()
                    if child:IsA("LocalScript") or child:IsA("Script") or child:IsA("ModuleScript") then
                        src = child.Source or ""
                    end
                end)
                local line = string.format("[%s] %s  (%d chars)", kind, child:GetFullName(), #src)
                addRow(line, depth)
            end
            walk(child, depth + 1)
        end
    end

    walk(game, 0)
    addRow(string.format("── %d scripts found ──", count), 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 8)
end

scanBtn.MouseButton1Click:Connect(dump)
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 8)
end)
dump()
