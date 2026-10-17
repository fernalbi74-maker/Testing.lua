-- LocalScript (executor) — TBSOBR Hitbox Bypass
-- Disables CanQuery on your character so GetPartBoundsInBox misses you.
-- Also destroys the client-side jumpscare handlers.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_God"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Godmode: Query Bypass Active"
label.TextColor3 = Color3.fromRGB(0, 255, 100)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

-- 1. CANQUERY BYPASS
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 100
            hum.MaxHealth = 1e9
            if hum.Health < 1e9 then hum.Health = 1e9 end
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.CanQuery = false -- This makes hitboxes miss us
                p.CanTouch = false
            end
        end
    end
end)

-- 2. DESTROY KILL SCRIPTS
-- The NightmareHandler sets Health = 0. We destroy it on sight.
local function destroyKillers()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") then
            if obj.Name == "NightmareHandler" or obj.Name == "Jumpscare" or obj.Name == "handle" or obj.Name == "handl" then
                obj:Destroy()
            end
        end
    end
end

-- Scan for killers every second
task.spawn(function()
    while task.wait(1) do
        pcall(destroyKillers)
    end
end)

-- 3. HOOK NEWINDEX FALLBACK
if hookmetamethod then
    local old
    old = hookmetamethod(game, "__newindex", function(self, key, value)
        if key == "Health" and self:IsA("Humanoid") and self.Parent == LocalPlayer.Character then
            if value <= 0 then return end -- block death
        end
        return old(self, key, value)
    end)
end
