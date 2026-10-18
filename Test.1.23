-- LocalScript (executor) — Destroy Boss Zombie & Spoof Health
-- Nukes the Zombie folder and sets all numbers to 0.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Nuke"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ollie · Nuke"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 40)
status.BackgroundTransparency = 1
status.Text = "Ready."
status.TextColor3 = Color3.fromRGB(235, 230, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 30)
btn.Position = UDim2.new(0, 10, 0, 80)
btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
btn.Text = "Nuke Zombie"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    status.Text = "Nuking..."
    local nuked = 0

    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)

    for _, boss in ipairs(workspace:GetChildren()) do
        if boss:IsA("Model") then
            local zombie = boss:FindFirstChild("Zombie")
            if zombie then
                -- Method 1: Destroy scripts inside Zombie
                for _, child in ipairs(zombie:GetChildren()) do
                    if child:IsA("Script") or child:IsA("NumberValue") or child:IsA("IntValue") then
                        pcall(function() child:Destroy() end)
                    end
                end
                
                -- Method 2: Destroy the Zombie folder itself
                pcall(function() zombie:Destroy() end)
                
                -- Method 3: Kill Humanoid and destroy Head/Torso
                local hum = boss:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        hum.MaxHealth = 0
                        hum.Health = 0
                    end)
                end
                local head = boss:FindFirstChild("Head")
                if head then pcall(function() head:Destroy() end) end
                local torso = boss:FindFirstChild("Torso") or boss:FindFirstChild("UpperTorso")
                if torso then pcall(function() torso:Destroy() end) end
                
                -- Method 4: Break the whole model
                pcall(function() boss:BreakJoints() end)
                -- Method 5: Remove from workspace
                -- boss.Parent = nil
                
                nuked = nuked + 1
            end
        end
    end
    status.Text = "Nuked " .. nuked .. " bosses."
end)
