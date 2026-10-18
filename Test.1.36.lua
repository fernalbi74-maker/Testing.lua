-- LocalScript (executor) — Teleport and spam Gaster Blaster
-- Teleports to the boss and spams the attack remote.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_BlasterFarm"
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
title.Text = "ollie · Blaster Farm"
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
btn.Text = "Farm Boss"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local farming = false

btn.MouseButton1Click:Connect(function()
    farming = not farming
    btn.Text = farming and "Farming..." or "Farm Boss"
    if not farming then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)

    local function getBoss()
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= char and v:FindFirstChild("Zombie") then
                return v
            end
        end
        return nil
    end

    local function getRemote()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChild("Gaster Blaster")
        if not tool and char then tool = char:FindFirstChild("Gaster Blaster") end
        if tool then
            return tool:FindFirstChild("RemoteEvent2") or tool:FindFirstChild("RemoteEvent")
        end
        return nil
    end

    task.spawn(function()
        while farming do
            local boss = getBoss()
            if boss then
                local bHrp = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("Torso")
                if bHrp then
                    -- Teleport directly inside the boss
                    hrp.CFrame = bHrp.CFrame
                    hrp.Anchored = true
                    
                    local remote = getRemote()
                    if remote then
                        status.Text = "Spamming remote..."
                        for i = 1, 20 do
                            pcall(function()
                                remote:FireServer(bHrp.Position.X, bHrp.Position.Y, bHrp.Position.Z)
                            end)
                            task.wait(0.05)
                        end
                    else
                        status.Text = "No Gaster Blaster equipped."
                    end
                end
            else
                status.Text = "No boss found."
            end
            task.wait(0.1)
        end
        hrp.Anchored = false
    end)
end)
