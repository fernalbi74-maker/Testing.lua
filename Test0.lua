-- LocalScript (executor) — Time and Coin Manipulator
-- Tries to force the server time to 0 and set coins.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_TimeHack"
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
btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
btn.Text = "Break Server Time"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    -- Spam server time to 0
    task.spawn(function()
        while true do
            task.wait(0.1)
            local values = workspace:FindFirstChild("Values")
            if values and values:FindFirstChild("ServerTime") then
                pcall(function()
                    values.ServerTime.Value = 0
                end)
            end
        end
    end)

    -- Try to set coins locally
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild("Coins")
        if coins then
            pcall(function()
                coins.Value = 999999999
            end)
        end
    end
end)
