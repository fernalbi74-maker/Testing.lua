-- GGE LOGIC HUNTER v1.0
-- Ищет только боевые скрипты, чтобы не лагало

local Keywords = {"Damage", "Attack", "FireServer", "RemoteEvent", "Hit", "Combat"}
local FoundScripts = {}

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("ScrollingFrame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.CanvasSize = UDim2.new(0, 0, 10, 0)

local UIList = Instance.new("UIListLayout", Frame)

local function AddToLog(text)
    local label = Instance.new("TextLabel", Frame)
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
end

local function ScanZone(zone)
    for _, obj in pairs(zone:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            -- Мы не можем читать .Source напрямую, но мы можем проверить имя 
            -- и попробовать найти упоминания в именах или путях
            local name = obj.Name:lower()
            for _, word in pairs(Keywords) do
                if name:find(word:lower()) then
                    table.insert(FoundScripts, obj)
                    AddToLog("FOUND: " .. obj:GetFullName())
                    break
                end
            end
        end
    end
end

-- Сканируем только важные зоны
print("Hunting for combat logic...")
ScanZone(game.ReplicatedStorage)
ScanZone(game.StarterPlayer.StarterPlayerScripts)
ScanZone(game.StarterPlayer.StarterCharacterScripts)
ScanZone(game.Players.LocalPlayer.PlayerGui)
ScanZone(game.Players.LocalPlayer.Backpack)

AddToLog("--- SCAN COMPLETE ---")
print("Logic Hunter finished. Check the list!")
