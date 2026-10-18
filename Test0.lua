-- LocalScript (executor) — Fake GamePass Purchase
-- Fires PromptGamePassPurchaseFinished locally with wasPurchased = true.
-- Only works if the game's LocalScripts trust this event.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_GamePassSpoof"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 30)
btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
btn.Text = "Fake GamePass Purchase"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    -- Try common TBSOBR gamepass IDs or just spam event
    local passIds = {1999028481, 2005748682, 2006630649} -- from LocalDailyRewards dump
    
    for _, id in ipairs(passIds) do
        pcall(function()
            -- This fires the event that LocalScripts listen to
            MarketplaceService:SignalPromptGamePassPurchaseFinished(LocalPlayer, id, true)
        end)
        
        -- Some executors have this alternative
        pcall(function()
            firegamepasspurchase(id, true)
        end)
    end
    
    btn.Text = "Fired! Check if VIP works."
end)
