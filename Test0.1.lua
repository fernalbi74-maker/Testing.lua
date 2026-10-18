-- LocalScript (executor) — Hook upgrade remote and spam
-- Intercepts the upgrade request and forces it.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Upgrade"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.15, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Waiting for upgrade click..."
label.TextColor3 = Color3.fromRGB(140, 100, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextWrapped = true
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

local lastRemote = nil
local lastArgs = {}

-- Hook to log the upgrade remote
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" or method == "InvokeServer" then
            if typeof(self) == "Instance" and self.Name:lower():find("upgrade") or self.Name:lower():find("tier") or self.Name:lower():find("buy") then
                lastRemote = self
                lastArgs = {...}
                label.Text = "Captured: " .. self.Name .. "\nSpamming..."
                
                -- Spam it 10 times to force it through
                task.spawn(function()
                    for i = 1, 10 do
                        pcall(function()
                            lastRemote:FireServer(unpack(lastArgs))
                        end)
                        task.wait(0.1)
                    end
                end)
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Also look for the upgrade part and click it directly
task.spawn(function()
    while task.wait(1) do
        local upgradePart = workspace:FindFirstChild("Upgrade") or workspace:FindFirstChild("TierUpgrade")
        if upgradePart and upgradePart:IsA("BasePart") and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                firetouchinterest(upgradePart, hrp, 0)
                firetouchinterest(upgradePart, hrp, 1)
            end
        end
    end
end)
