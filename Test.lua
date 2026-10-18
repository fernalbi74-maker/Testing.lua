-- LocalScript (executor) — Spoof VIP and GamePasses
-- Hooks GamePass checks and sets VIP attributes.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_VIP"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Spoofing VIP & Whitelist..."
label.TextColor3 = Color3.fromRGB(255, 215, 0)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

-- 1. Hook UserOwnsGamePassAsync
if hookfunction then
    local oldOwns = MarketplaceService.UserOwnsGamePassAsync
    hookfunction(MarketplaceService.UserOwnsGamePassAsync, function(self, userId, gamePassId)
        -- Return true for any gamepass check
        return true
    end)
end

-- 2. Set VIP Attributes
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            LocalPlayer:SetAttribute("IsVIP", true)
            LocalPlayer:SetAttribute("TBSOBRPlus", true)
            LocalPlayer:SetAttribute("E666Gamepass", true)
            LocalPlayer:SetAttribute("Whitelisted", true)
            LocalPlayer:SetAttribute("PreNerfE666", true)
            
            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("IsVIP", true)
                char:SetAttribute("TBSOBRPlus", true)
            end
        end)
    end
end)

-- 3. Set Whitelist string in config if it exists
for _, v in ipairs(LocalPlayer:GetDescendants()) do
    if v:IsA("BoolValue") or v:IsA("StringValue") then
        local n = v.Name:lower()
        if n:find("vip") or n:find("whitelist") or n:find("e666") then
            pcall(function()
                if v:IsA("BoolValue") then v.Value = true else v.Value = "true" end
            end)
        end
    end
end
