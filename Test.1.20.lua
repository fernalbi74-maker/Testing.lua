-- LocalScript (executor) — TBSOBR Boss Assassination
-- Finds the boss and breaks it completely: Destroying parts, BreakJoints, and Health = 0.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Assassin"
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
title.Text = "ollie · Assassin"
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
btn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
btn.Text = "Assassinate Boss"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    status.Text = "Assassinating..."
    
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)

    local killed = 0
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and (v:FindFirstChild("Zombie") or v:FindFirstChild("NPCTAG") or v:FindFirstChildOfClass("Humanoid")) then
            -- Don't kill self
            if v ~= LocalPlayer.Character then
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not v:FindFirstChild("invincible") then
                    
                    -- Method 1: Set health to 0
                    pcall(function() hum.Health = 0; hum.MaxHealth = 0 end)
                    
                    -- Method 2: Break joints
                    pcall(function() v:BreakJoints() end)
                    
                    -- Method 3: Destroy limbs (from leaked script)
                    local head = v:FindFirstChild("Head")
                    local torso = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso")
                    if head then head:Destroy() end
                    if torso then torso:Destroy() end
                    
                    -- Method 4: If it has a custom TrueHp or Zombie object
                    local zombie = v:FindFirstChild("Zombie")
                    if zombie then
                        for _, stat in ipairs(zombie:GetChildren()) do
                            if stat:IsA("NumberValue") and (stat.Name:lower():find("hp") or stat.Name:lower():find("health")) then
                                pcall(function() stat.Value = 0 end)
                            end
                        end
                    end
                    
                    killed = killed + 1
                end
            end
        end
    end
    status.Text = "Killed " .. killed .. " bosses."
end)
