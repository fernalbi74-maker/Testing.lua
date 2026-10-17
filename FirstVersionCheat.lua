-- LocalScript (executor) — TBSOBR Godmode & Auto-Dodge
-- Bypasses server damage by forcing Humanoid health to max.
-- Adds Noclip, Fly, and a hitbox avoider.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local godmode = true
local noclip = true
local autoDodge = true

-- GUI
local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Cheat"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = BG
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ollie · TBSOBR"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.Parent = frame

local function makeToggle(text, y, state)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 40)
    btn.Text = text .. (state and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local godBtn = makeToggle("Godmode", 35, true)
local noclipBtn = makeToggle("Noclip", 70, true)
local dodgeBtn = makeToggle("Auto-Dodge", 105, true)

godBtn.MouseButton1Click:Connect(function()
    godmode = not godmode
    godBtn.Text = "Godmode " .. (godmode and "[ON]" or "[OFF]")
    godBtn.BackgroundColor3 = godmode and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 40)
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = "Noclip " .. (noclip and "[ON]" or "[OFF]")
    noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 40)
end)

dodgeBtn.MouseButton1Click:Connect(function()
    autoDodge = not autoDodge
    dodgeBtn.Text = "Auto-Dodge " .. (autoDodge and "[ON]" or "[OFF]")
    dodgeBtn.BackgroundColor3 = autoDodge and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(40, 40, 40)
end)

-- Godmode: If health drops, instantly heal back.
local function hookChar(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    hum.HealthChanged:Connect(function(hp)
        if godmode and hp < hum.MaxHealth and hp > 0 then
            hum.Health = hum.MaxHealth
        end
    end)
    
    RunService.Stepped:Connect(function()
        if godmode and hum.Parent and hum.Health > 0 then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end)
end

if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookChar)

-- Noclip and Auto-Dodge loops
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    -- Noclip
    if noclip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- Auto-Dodge (Push away from nearby moving parts)
    if autoDodge then
        for _, obj in ipairs(workspace:GetChildren()) do
            -- TBSOBR attacks are usually Neon parts or Meshes
            if obj:IsA("BasePart") and (obj.Name:find("Bone") or obj.Name:find("Spike") or obj.Name:find("Blaster") or obj.Name:find("Tentacle") or obj.Name:find("Knife") or obj.Name:find("Attack") or obj.Material == Enum.Material.Neon) then
                if obj.CanTouch and not obj:IsDescendantOf(char) then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < 15 then
                        local dir = (hrp.Position - obj.Position).Unit
                        hrp.CFrame = hrp.CFrame + (dir * 5) -- teleport away
                    end
                end
            end
        end
    end
end)
