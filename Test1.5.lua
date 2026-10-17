-- LocalScript (executor) — TBSOBR Boss Melter
-- Finds the boss, extracts its position, and spams the Gaster Blaster remote.
-- Bypasses cooldowns and normal targeting.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Melter"
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
title.Text = "ollie · Boss Melter"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 40)
status.BackgroundTransparency = 1
status.Text = "Looking for boss..."
status.TextColor3 = Color3.fromRGB(235, 230, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = frame

-- 1. Find the boss
local function getBoss()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and (v:FindFirstChild("Humanoid") or v:FindFirstChild("Zombie")) then
            -- skip players and self
            if not Players:GetPlayerFromCharacter(v) and v ~= LocalPlayer.Character then
                -- check if it has HP left (sometimes bosses hide it in a Value object)
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    return v, hum
                end
                -- custom health
                local zombie = v:FindFirstChild("Zombie")
                if zombie and zombie:FindFirstChild("TrueHp") and zombie.TrueHp.Value > 0 then
                    return v, zombie
                end
            end
        end
    end
    return nil, nil
end

-- 2. Get the remote
local function getRemote()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local tool = nil
    
    if backpack then tool = backpack:FindFirstChild("Gaster Blaster") end
    if not tool and char then tool = char:FindFirstChild("Gaster Blaster") end
    
    if tool then
        return tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("RemoteEvent2")
    end
    return nil
end

-- 3. Spam the remote
task.spawn(function()
    while task.wait(0.1) do -- yield so game doesn't crash
        local boss, hum = getBoss()
        if boss and hum then
            local hrp = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("Torso")
            if hrp then
                local remote = getRemote()
                if remote then
                    status.Text = "Melting " .. boss.Name .. "..."
                    
                    -- Fire the remote 10 times per tick at the boss's position
                    for i = 1, 10 do
                        pcall(function()
                            remote:FireServer(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
                        end)
                    end
                else
                    status.Text = "Gaster Blaster not in Backpack!"
                end
            end
        else
            status.Text = "No boss found."
        end
    end
end)
