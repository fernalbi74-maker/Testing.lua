-- LocalScript (executor) — in-game remote viewer
-- No files, no clipboard. Just a scrolling frame you can read.
-- Scans safely, shows remotes with a copy button per line if needed.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)
local TEXT = Color3.fromRGB(235, 230, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieRemotesUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.8, 0)
frame.Position = UDim2.new(0.05, 0, 0.1, 0)
frame.BackgroundColor3 = BG
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 10)
c.Parent = frame
local s = Instance.new("UIStroke")
s.Color = ACCENT
s.Thickness = 2
s.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "ollie · TBSOBR remotes"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = ACCENT
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 4)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

local function addRow(text, color)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -10, 0, 24)
    row.BackgroundTransparency = 1
    row.Text = text
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextColor3 = color or TEXT
    row.Font = Enum.Font.Code
    row.TextSize = 13
    row.TextWrapped = true
    row.AutoButtonColor = false
    row.Parent = scroll
    row.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(setclipboard, text)
            row.TextColor3 = Color3.fromRGB(100, 255, 150)
            task.wait(0.5)
            row.TextColor3 = color or TEXT
        end
    end)
    return row
end

local SCAN_ROOTS = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
}

local function dump()
    title.Text = "scanning…"

    local evCount, fnCount = 0, 0
    local count = 0

    for _, root in ipairs(SCAN_ROOTS) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                count = count + 1
                if count % 100 == 0 then task.wait() end

                if d:IsA("RemoteEvent") then
                    evCount = evCount + 1
                    addRow("RE  " .. getPath(d), Color3.fromRGB(160, 200, 255))
                elseif d:IsA("RemoteFunction") then
                    fnCount = fnCount + 1
                    addRow("RF  " .. getPath(d), Color3.fromRGB(255, 180, 100))
                end
            end
        end
    end

    title.Text = string.format("ollie · %d events, %d functions (tap to copy)", evCount, fnCount)
    scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
end

list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
end)

dump()
