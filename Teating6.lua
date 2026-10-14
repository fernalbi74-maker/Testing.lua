-- GGE VISUAL SCANNER v1.0
-- Безопасный поиск Remote-событий с возможностью копирования

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_Scanner_UI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.5, -150, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "REMOTE SCANNER (Copyable)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 4

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)

-- Функция для создания копируемого поля
local function CreateCopyField(text)
    local Box = Instance.new("TextBox", Scroll)
    Box.Size = UDim2.new(1, 0, 0, 30)
    Box.Text = text
    Box.TextColor3 = Color3.fromRGB(0, 255, 0)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Box.Font = Enum.Font.Code
    Box.TextSize = 12
    Box.ClearTextOnFocus = false
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.TextYAlignment = Enum.TextYAlignment.Center
end

-- Запуск сканирования в отдельном потоке
task.spawn(function()
    local foundCount = 0
    
    -- Проходим по всем объектам в игре
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            foundCount = foundCount + 1
            -- Выводим Имя и Путь к событию
            CreateCopyField("Name: " .. obj.Name .. " | Path: " .. obj:GetFullName())
        end
    end
    
    -- Обновляем размер прокрутки
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    
    -- Добавляем финальный статус
    local Final = Instance.new("TextLabel", Main)
    Final.Size = UDim2.new(1, 0, 0, 20)
    Final.Position = UDim2.new(0, 0, 1, -20)
    Final.Text = "Scan Finished: Found " .. foundCount .. " remotes"
    Final.TextColor3 = Color3.fromRGB(200, 200, 200)
    Final.BackgroundTransparency = 1
    Final.TextSize = 10
end)
