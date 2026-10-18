-- LocalScript (executor) — Replicate the leaked admin script
-- Teleports to the boss, anchors, waits, and kills it.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_AdminReplication"
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
title.Text = "ollie · Admin Replication"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 30)
status.BackgroundTransparency = 1
status.Text = "Ready."
status.TextColor3 = Color3.fromRGB(235, 230, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 30)
btn.Position = UDim2.new(0, 10, 0, 65)
btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
btn.Text = "Teleport & Kill"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)

    local function findBoss()
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= char and v:FindFirstChildOfClass("Humanoid") then
                if v:FindFirstChild("Zombie") or v:FindFirstChild("NPCTAG") then
                    return v
                end
            end
        end
        return nil
    end

    local boss = findBoss()
    if not boss then
        status.Text = "No boss found."
        return
    end

    local bHrp = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("Torso")
    if not bHrp then
        status.Text = "Boss has no HRP."
        return
    end

    -- Replicate the admin script logic
    status.Text = "Teleporting to boss..."
    hrp.CFrame = bHrp.CFrame + Vector3.new(1, 35, 1)
    task.wait(1)
    hrp.Anchored = true
    
    status.Text = "Anchored. Waiting 20s..."
    task.wait(20) -- the 20 second wait from the admin script

    status.Text = "Killing boss..."
    local hum = boss:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
        hum.MaxHealth = 0
    end
    
    -- Destroy limbs
    local head = boss:FindFirstChild("Head")
    if head then head:Destroy() end
    local torso = boss:FindFirstChild("Torso") or boss:FindFirstChild("UpperTorso")
    if torso then torso:Destroy() end

    hrp.Anchored = false
    status.Text = "Done."
end)
