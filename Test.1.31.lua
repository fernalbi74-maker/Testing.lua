-- LocalScript (executor) — Remote Blocker
-- Hooks Namecall and Index to block attack remotes and kill hitboxes.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_RemoteBlock"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Blocking Attack Remotes..."
label.TextColor3 = Color3.fromRGB(0, 255, 100)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

-- 1. Hook Metamethods to block attack remotes
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        -- Block firing attack remotes
        if method == "FireServer" or method == "InvokeServer" then
            if typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                local path = self:GetFullName():lower()
                if path:find("attack") or path:find("damage") or path:find("hit") or path:find("kill") or path:find("blast") or path:find("bone") then
                    return nil -- Block the call
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

-- 2. Destroy AttackTools in Lighting
task.spawn(function()
    while task.wait(0.1) do
        local atkTools = Lighting:FindFirstChild("AttackTools")
        if atkTools then
            for _, v in ipairs(atkTools:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Model") then
                    v:Destroy()
                end
            end
        end
        -- Also sweep workspace for hitboxes
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local n = v.Name:lower()
                if n:find("bone") or n:find("blast") or n:find("tentacle") or n:find("knife") then
                    v:Destroy()
                end
            end
        end
    end
end)

-- 3. True Godmode (MaxHealth + CanQuery false)
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.MaxHealth = 1e9
    hum.Health = 1e9
    hum.HealthChanged:Connect(function(hp)
        if hp < 1e9 then hum.Health = 1e9 end
    end)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanQuery = false
            p.CanCollide = false
            p.CanTouch = false
        end
    end
end)
