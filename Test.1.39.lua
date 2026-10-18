-- LocalScript (executor) — Auto-Farm Boss
-- Keeps you alive, teleports you to the boss, and spams the blaster.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_AutoFarm"
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
title.Text = "ollie · Auto-Farm"
title.TextColor3 = Color3.fromRGB(140, 100, 255)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
btn.Text = "Start Farming"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local farming = false

btn.MouseButton1Click:Connect(function()
    farming = not farming
    btn.Text = farming and "Farming..." or "Start Farming"
    if not farming then return end

    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)

    -- 1. Godmode loop
    task.spawn(function()
        while farming do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.MaxHealth = 1e9
                    if hum.Health < 1e9 then hum.Health = 1e9 end
                end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanQuery = false
                        p.CanCollide = false
                    end
                end
            end
        end
    end)

    -- 2. Attack & Teleport loop
    task.spawn(function()
        while farming do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")

            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Model") and v ~= char and v:FindFirstChild("Zombie") then
                    local target = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                    if target and hrp then
                        -- Teleport to boss
                        hrp.CFrame = target.CFrame
                        
                        -- Find and spam blaster
                        local bp = LocalPlayer:FindFirstChild("Backpack")
                        local tool = bp and bp:FindFirstChild("Gaster Blaster")
                        if not tool then tool = char:FindFirstChild("Gaster Blaster") end
                        
                        if tool then
                            local remote = tool:FindFirstChild("RemoteEvent2") or tool:FindFirstChild("RemoteEvent")
                            if remote then
                                for i = 1, 5 do
                                    pcall(function()
                                        remote:FireServer(target.Position.X, target.Position.Y, target.Position.Z)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end)
