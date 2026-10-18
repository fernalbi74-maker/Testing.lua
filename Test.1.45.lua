-- LocalScript (executor) — Spoof the Gaster Blaster remote
-- Fires RemoteEvent and RemoteEvent2 with the boss's coordinates.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Spoofer"
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
title.Text = "ollie · Spoofer"
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
btn.Text = "Spoof Attack"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local spoofing = false

btn.MouseButton1Click:Connect(function()
    spoofing = not spoofing
    btn.Text = spoofing and "Spoofing..." or "Spoof Attack"
    if not spoofing then return end

    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)

    task.spawn(function()
        while spoofing do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if not char then continue end
            
            local tool = LocalPlayer.Backpack:FindFirstChild("Gaster Blaster") or char:FindFirstChild("Gaster Blaster")
            if not tool then
                status.Text = "Equip Gaster Blaster!"
                continue
            end

            local r1 = tool:FindFirstChild("RemoteEvent")
            local r2 = tool:FindFirstChild("RemoteEvent2")

            if not r1 or not r2 then
                status.Text = "Remotes not found in tool."
                continue
            end

            for _, boss in ipairs(workspace:GetChildren()) do
                if boss:IsA("Model") and boss:FindFirstChild("Zombie") then
                    local target = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("Torso")
                    if target then
                        status.Text = "Spoofing " .. boss.Name
                        for i = 1, 10 do
                            pcall(function()
                                -- Fire both remotes with the boss's position
                                r1:FireServer(target.Position.X, target.Position.Y, target.Position.Z)
                                r2:FireServer(target.Position.X, target.Position.Y, target.Position.Z)
                            end)
                        end
                    end
                end
            end
        end
    end)
end)
