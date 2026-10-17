-- LocalScript (executor) — TBSOBR True Godmode
-- Hooks __newindex to block Health from dropping.
-- Also wipes AttackTools hitboxes from Lighting before they touch you.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_God"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = BG
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ollie · TBSOBR God"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 40)
status.BackgroundTransparency = 1
status.Text = "Godmode: ACTIVE\nHitbox Destroyer: ACTIVE"
status.TextColor3 = Color3.fromRGB(0, 255, 100)
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.Parent = frame

-- 1. TRUE GODMODE VIA METAMETHOD HOOK
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__newindex", function(self, key, value)
        if key == "Health" and self:IsA("Humanoid") and self.Parent == LocalPlayer.Character then
            if value < self.Health then
                return -- block health reduction
            end
        end
        return oldNamecall(self, key, value)
    end)
else
    -- fallback if hookmetamethod is blocked
    LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function()
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end)
end

-- 2. HITBOX DESTROYER
-- Monitors Lighting.AttackTools and destroys newly spawned hitboxes.
local function processAttackFolder(folder)
    folder.ChildAdded:Connect(function(child)
        task.spawn(function()
            task.wait(0.05) -- let it initialize
            -- if it's a part or model with touch damage, kill it
            if child:IsA("BasePart") or child:IsA("Model") then
                if child.Name:find("Bone") or child.Name:find("Blast") or child.Name:find("Spike") or child.Name:find("Attack") or child.Name:find("Sword") then
                    child:Destroy()
                end
            end
        end)
    end)
    
    -- also sweep existing
    for _, child in ipairs(folder:GetChildren()) do
        if child.Name:find("Bone") or child.Name:find("Blast") or child.Name:find("Spike") then
            child:Destroy()
        end
    end
end

local atkTools = game:GetService("Lighting"):FindFirstChild("AttackTools")
if atkTools then
    processAttackFolder(atkTools)
    atkTools.ChildAdded:Connect(function(f) processAttackFolder(f) end)
else
    game:GetService("Lighting").ChildAdded:Connect(function(f)
        if f.Name == "AttackTools" then
            processAttackFolder(f)
        end
    end)
end

-- 3. NOCLIP & SPEED
local noclip = true
local speed = 100

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = speed end
        if noclip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)
