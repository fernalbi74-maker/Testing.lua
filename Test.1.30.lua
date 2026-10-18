-- LocalScript (executor) — Neutered HitboxUtil
-- Hooks require to block the game from using the real HitboxUtil.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_HitboxHook"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "HitboxUtil Hooked"
label.TextColor3 = Color3.fromRGB(0, 255, 100)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

-- The fake module
local fakeHitbox = {
    HitboxesDisabled = true,
    Disabled = true,
    onOverlap = function() 
        return { Disconnect = function() end } 
    end
}

-- Hook require
if hookfunction then
    local oldRequire = require
    hookfunction(require, function(target)
        if typeof(target) == "Instance" and target.Name == "HitboxUtil" then
            return fakeHitbox
        end
        return oldRequire(target)
    end)
    label.Text = "HitboxUtil: Hooked via require"
else
    -- fallback: overwrite the module if possible
    local hitbox = ReplicatedStorage:FindFirstChild("HitboxUtil")
    if hitbox then
        -- can't write .Source directly to a ModuleScript in ReplicatedStorage easily
        -- but we can set the metatable of the returned table if it's already required
        local ok, module = pcall(require, hitbox)
        if ok and type(module) == "table" then
            module.HitboxesDisabled = true
            module.Disabled = true
            module.onOverlap = function() return { Disconnect = function() end } end
            label.Text = "HitboxUtil: Overwritten table"
        end
    end
end
