-- LocalScript (executor) — Wave Skipper
-- Fires the ClickDetectors for SoulKiller and Start to skip waves.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Skipper"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ollie · Skipper"
title.TextColor3 = Color3.fromRGB(140, 100, 255)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local btnSoul = Instance.new("TextButton")
btnSoul.Size = UDim2.new(1, -20, 0, 30)
btnSoul.Position = UDim2.new(0, 10, 0, 40)
btnSoul.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
btnSoul.Text = "Click SoulKiller"
btnSoul.TextColor3 = Color3.fromRGB(20, 16, 30)
btnSoul.Font = Enum.Font.GothamBold
btnSoul.Parent = frame
Instance.new("UICorner", btnSoul).CornerRadius = UDim.new(0, 6)

local btnStart = Instance.new("TextButton")
btnStart.Size = UDim2.new(1, -20, 0, 30)
btnStart.Position = UDim2.new(0, 10, 0, 80)
btnStart.BackgroundColor3 = Color3.fromRGB(90, 220, 160)
btnStart.Text = "Click Start"
btnStart.TextColor3 = Color3.fromRGB(20, 16, 30)
btnStart.Font = Enum.Font.GothamBold
btnStart.Parent = frame
Instance.new("UICorner", btnStart).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 120)
status.BackgroundTransparency = 1
status.Text = "Ready."
status.TextColor3 = Color3.fromRGB(235, 230, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = frame

btnSoul.MouseButton1Click:Connect(function()
    local soulKiller = workspace:FindFirstChild("SoulKiller")
    if soulKiller then
        local cd = soulKiller:FindFirstChild("ClickDetector")
        if cd then
            fireclickdetector(cd)
            status.Text = "Clicked SoulKiller."
        end
    else
        status.Text = "No SoulKiller found."
    end
end)

btnStart.MouseButton1Click:Connect(function()
    local start = workspace:FindFirstChild("Start")
    if start then
        local cd = start:FindFirstChild("ClickDetector")
        if cd then
            fireclickdetector(cd)
            status.Text = "Clicked Start."
        else
            -- Some start buttons use parts
            local part = start:FindFirstChild("Part")
            if part and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    firetouchinterest(part, hrp, 0)
                    firetouchinterest(part, hrp, 1)
                    status.Text = "Touched Start Part."
                end
            end
        end
    else
        status.Text = "No Start found."
    end
end)
