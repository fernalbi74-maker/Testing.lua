-- LocalScript (executor) — Find admin remotes & force touch
-- Scans for admin/kill remotes and tries to force the boss to die.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_AdminKill"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ollie · Admin Kill"
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
btn.Position = UDim2.new(0, 10, 0, 80)
btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
btn.Text = "Force Kill"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    status.Text = "Searching for kill remote..."
    
    local killRemote = nil
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("kill") or n:find("admin") or n:find("ban") or n:find("damage") or n:find("hit") then
                killRemote = v
                status.Text = "Found remote: " .. v:GetFullName()
                break
            end
        end
    end

    if killRemote then
        local boss = nil
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Zombie") then
                boss = v
                break
            end
        end

        if boss then
            status.Text = "Firing remote at " .. boss.Name
            pcall(function()
                killRemote:FireServer(boss)
                killRemote:FireServer(boss.Name)
                killRemote:FireServer(boss:FindFirstChild("Zombie"))
            end)
            task.wait(1)
        end
    else
        status.Text = "No obvious kill remote. Forcing touch..."
        -- Force the boss to touch itself (BreakJoints)
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Zombie") then
                local hrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    -- Force a massive touch damage if possible
                    pcall(function()
                        firetouchinterest(hrp, hrp, 0)
                        firetouchinterest(hrp, hrp, 1)
                        hum.Health = 0
                    end)
                end
            end
        end
        status.Text = "Touched boss."
    end
end)
