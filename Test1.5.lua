-- LocalScript (executor) — TBSOBR Godmode V3
-- Sets huge MaxHealth, blocks TakeDamage, and destroys hitboxes.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_GodV3"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "ollie · GodMode V3\nActive"
title.TextColor3 = Color3.fromRGB(140, 100, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

-- 1. MAX HEALTH OVERRIDE
local function applyGodMode(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    hum.MaxHealth = 1e9
    hum.Health = 1e9
    
    hum.HealthChanged:Connect(function(hp)
        if hp < 1e9 then
            hum.Health = 1e9
        end
    end)
end

if LocalPlayer.Character then applyGodMode(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(applyGodMode)

-- 2. HITBOX NEUTRALIZER
-- Scans for Bone, Blaster, Spike, Attack parts and disables them
RunService.Stepped:Connect(function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("bone") or n:find("blast") or n:find("spike") or n:find("tentacle") or n:find("knife") or n:find("attack") or n:find("damage") then
                obj.CanTouch = false
                obj.CanCollide = false
                obj.CanQuery = false
            end
        end
    end
    -- Also check Lighting for AttackTools
    for _, obj in ipairs(game:GetService("Lighting"):GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("bone") or n:find("blast") or n:find("spike") or n:find("tentacle") or n:find("knife") or n:find("attack") or n:find("damage") then
                obj.CanTouch = false
                obj.CanCollide = false
                obj.CanQuery = false
            end
        end
    end
end)

-- 3. NOCLIP & SPEED
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 100 end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)
