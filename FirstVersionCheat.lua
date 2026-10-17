-- GGE SCRIPT MAPPER v2.0
-- Выводит список ВСЕХ скриптов, чтобы найти скрытую логику

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("ScrollingFrame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 400)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.CanvasSize = UDim2.new(0, 0, 20, 0)

local UIList = Instance.new("UIListLayout", Frame)

local function Log(text, color)
    local label = Instance.new("TextLabel", Frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
end

local function Map(zone, zoneName)
    Log("--- Zone: " .. zoneName .. " ---", Color3.fromRGB(255, 255, 0))
    for _, obj in pairs(zone:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            Log(obj:GetFullName())
        end
    end
end

Map(game.ReplicatedStorage, "ReplicatedStorage")
Map(game.Players.LocalPlayer:WaitForChild("PlayerScripts"), "PlayerScripts")
Map(game.Players.LocalPlayer:WaitForChild("PlayerGui"), "PlayerGui")
Map(game.StarterPlayer.StarterPlayerScripts, "StarterPlayerScripts")

Log("--- END OF MAP ---", Color3.fromRGB(255, 255, 0))
