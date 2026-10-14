-- GGE DEEP-DIVE SCANNER v3.0
-- Модульный поиск объектов: Remotes, Models, Folders, Scripts

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_DeepScanner"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 450)
Main.Position = UDim2.new(0.5, -175, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "DEEP-DIVE SCANNER"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold

local ButtonContainer = Instance.new("Frame", Main)
ButtonContainer.Size = UDim2.new(1, -10, 0, 120)
ButtonContainer.Position = UDim2.new(0, 5, 0, 35)
ButtonContainer.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", ButtonContainer)
Layout.Padding = UDim.new(0, 5)

-- Поле для вывода результатов (Копируемое)
local ResultBox = Instance.new("TextBox", Main)
ResultBox.Size = UDim2.new(1, -10, 1, -165)
ResultBox.Position = UDim2.new(0, 5, 0, 160)
ResultBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ResultBox.TextColor3 = Color3.fromRGB(0, 255, 0)
ResultBox.Font = Enum.Font.Code
ResultBox.TextSize = 11
ResultBox.ClearTextOnFocus = false
ResultBox.TextXAlignment = Enum.TextXAlignment.Left
ResultBox.TextYAlignment = Enum.TextYAlignment.Top
ResultBox.MultiLine = true

-- Функция сканирования конкретной зоны
local function ScanZone(zone)
    local results = {}
    local target = zone
    
    -- Если зона — это строка, пробуем найти её в игре
    if type(zone) == "string" then
        target = game:GetService(zone) or game:FindFirstChild(zone, true)
    end

    if not target then 
        ResultBox.Text = "Error: Zone not found!"
        return 
    end

    for _, obj in pairs(target:GetDescendants()) do
        -- Ищем всё интересное: Remote-ы, Модели, Папки, Скрипты
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("ModuleScript") then
            table.insert(results, "[" .. obj.ClassName .. "] " .. obj.Name .. " | " .. obj:GetFullName())
        end
    end

    -- Превращаем таблицу в одну большую строку
    local finalString = "--- ZONE: " .. (type(zone) == "string" and zone or target.Name) .. " ---\n"
    for _, line in ipairs(results) do
        finalString = finalString .. line .. "\n"
    end
    
    ResultBox.Text = finalString
end

-- Создание кнопок управления
local zones = {
    {"Scan LIGHTING", "Lighting"},
    {"Scan REPLICATED STORAGE", "ReplicatedStorage"},
    {"Scan WORKSPACE", "Workspace"},
    {"Scan ALL REMOTES (Global)", "AllRemotes"}
}

for _, data in ipairs(zones) do
    local btn = Instance.new("TextButton", ButtonContainer)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Text = data[1]
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    
    btn.MouseButton1Click:Connect(function()
        if data[2] == "AllRemotes" then
            -- Специальный глобальный поиск только по ремотам
            local res = {}
            for _, o in pairs(game:GetDescendants()) do
                if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                    table.insert(res, "[Remote] " .. o.Name .. " | " .. o:GetFullName())
                end
            end
            local s = "--- ALL REMOTES ---\n"
            for _, l in ipairs(res) do s = s .. l .. "\n" end
            ResultBox.Text = s
        else
            ScanZone(data[2])
        end
    end)
end
