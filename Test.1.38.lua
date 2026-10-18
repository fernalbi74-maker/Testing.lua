-- LocalScript (executor) — Force Boss Death
-- Teleports to boss, forces Dead state, and destroys limbs.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_ForceKill"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ollie · Force Kill"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
btn.Text = "KILL BOSS"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)

    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= char and v:FindFirstChildOfClass("Humanoid") then
            if v:FindFirstChild("Zombie") or v:FindFirstChild("NPCTAG") then
                local hum = v:FindFirstChildOfClass("Humanoid")
                
                -- 1. Teleport to boss (no anchoring)
                if hrp and (v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")) then
                    local target = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                    hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
                end
                
                -- 2. Force Dead state
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                end)
                
                -- 3. Set health and max health
                pcall(function()
                    hum.MaxHealth = 0
                    hum.Health = 0
                end)
                
                -- 4. Destroy limbs (from admin script)
                local head = v:FindFirstChild("Head")
                if head then head:Destroy() end
                local torso = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso")
                if torso then torso:Destroy() end
                
                -- 5. Break joints
                pcall(function() v:BreakJoints() end)
            end
        end
    end
end)
