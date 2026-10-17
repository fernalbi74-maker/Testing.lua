-- LocalScript (executor) — TBSOBR Death Blocker
-- Intercepts Humanoid.Health = 0 on the client and blocks it.
-- Also kills the NightmareHandler scripts if they spawn.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_AntiDeath"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Anti-Death: Active"
label.TextColor3 = Color3.fromRGB(0, 255, 100)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

-- 1. Metamethod Hook for Health = 0
local hookSuccess = false
if hookmetamethod and checkcaller then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__newindex", function(self, key, value)
        if not checkcaller() then
            if key == "Health" and self:IsA("Humanoid") and self.Parent == LocalPlayer.Character then
                if type(value) == "number" and value <= 0 then
                    return -- drop the death
                end
            end
        end
        return oldNamecall(self, key, value)
    end)
    hookSuccess = true
else
    -- fallback if hookmetamethod is blocked
    LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function(hp)
            if hp <= 0 then
                hum.Health = hum.MaxHealth
            end
        end)
    end)
end

-- 2. Script Destroyer
-- If we see NightmareHandler or Jumpscare, we destroy it before it runs.
local function scanForKillScripts()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") then
            if obj.Name == "NightmareHandler" or obj.Name == "Jumpscare" or obj.Name == "handle" or obj.Name == "handl" then
                -- check if it kills you
                local ok, src = pcall(function() return obj.Source end)
                if ok and src and src:find("Health = 0") then
                    obj:Destroy()
                end
            end
        end
    end
end

-- Run scan in background
task.spawn(function()
    while task.wait(2) do
        pcall(scanForKillScripts)
    end
end)

-- 3. Noclip and MaxHealth
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if hum.MaxHealth ~= 1e9 then
                hum.MaxHealth = 1e9
                hum.Health = 1e9
            end
            hum.WalkSpeed = 100
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)
