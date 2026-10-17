-- LocalScript (executor) — TBSOBR Hitbox Wiper
-- Finds every damage script in Workspace and destroys its parent part.
-- This stops TouchDamage from registering on you.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Wiper"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Hitbox Wiper: ACTIVE"
label.TextColor3 = Color3.fromRGB(0, 255, 100)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

-- Scans for damage scripts and destroys their parent
local function wipeHitboxes()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") then
            local name = v.Name:lower()
            if name:find("damage") or name:find("touchdamage") or name:find("kill") then
                -- If it's a damage script, destroy the part it's attached to
                local parent = v.Parent
                if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
                    parent:Destroy()
                else
                    v:Destroy()
                end
            end
        end
        -- Also catch parts named Damage or Hitbox
        if v:IsA("BasePart") then
            local pName = v.Name:lower()
            if pName:find("damage") or pName:find("hitbox") then
                v:Destroy()
            end
        end
    end
end

-- Run continuously to catch new spawns
task.spawn(function()
    while task.wait(0.5) do
        pcall(wipeHitboxes)
    end
end)

-- Keep your own body safe
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.MaxHealth = 1e9
            if hum.Health < 1e9 then hum.Health = 1e9 end
            hum.WalkSpeed = 100
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.CanQuery = false
                p.CanTouch = false
            end
        end
    end
end)
