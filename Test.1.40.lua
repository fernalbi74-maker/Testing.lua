-- LocalScript (executor) — Move Boss to Void & Destroy Humanoid
-- Tries to break the boss by moving it out of bounds or destroying its core.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Void"
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
title.Text = "ollie · Void"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 30)
btn.Position = UDim2.new(0, 10, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
btn.Text = "Send Boss to Void"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local btn2 = Instance.new("TextButton")
btn2.Size = UDim2.new(1, -20, 0, 30)
btn2.Position = UDim2.new(0, 10, 0, 80)
btn2.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
btn2.Text = "Rip Humanoid"
btn2.TextColor3 = Color3.fromRGB(20, 16, 30)
btn2.Font = Enum.Font.GothamBold
btn2.Parent = frame
Instance.new("UICorner", btn2).CornerRadius = UDim.new(0, 6)

local function getBosses()
    local bosses = {}
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character then
            if v:FindFirstChild("Zombie") or v:FindFirstChild("NPCTAG") then
                table.insert(bosses, v)
            end
        end
    end
    return bosses
end

btn.MouseButton1Click:Connect(function()
    for _, boss in ipairs(getBosses()) do
        local hrp = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("Torso")
        if hrp then
            -- Move the whole model to the void
            pcall(function()
                boss:PivotTo(CFrame.new(0, -5000, 0))
            end)
            pcall(function()
                hrp.CFrame = CFrame.new(0, -5000, 0)
            end)
        end
    end
end)

btn2.MouseButton1Click:Connect(function()
    for _, boss in ipairs(getBosses()) do
        -- Destroy the Humanoid directly
        local hum = boss:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:Destroy() end)
        end
        -- Destroy the Zombie object (from previous dump, the game relies on it)
        local zombie = boss:FindFirstChild("Zombie")
        if zombie then
            pcall(function() zombie:Destroy() end)
        end
    end
end)
