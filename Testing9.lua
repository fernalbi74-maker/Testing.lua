-- GGE LAB-SCANNER v4.0
-- Инструмент для точечного анализа структуры игры

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_LabScanner"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 500)
Main.Position = UDim2.new(0.5, -200, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "LAB SCANNER v4.0"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold

-- Поле ввода зоны (например: ReplicatedStorage)
local ZoneInput = Instance.new("TextBox", Main)
ZoneInput.Size = UDim2.new(0, 200, 0, 30)
ZoneInput.Position = UDim2.new(0, 10, 0, 40)
ZoneInput.PlaceholderText = "Zone Name (e.g. ReplicatedStorage)"
ZoneInput.Text = "ReplicatedStorage"
ZoneInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ZoneInput.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Выбор типа объектов
local TypeInput = Instance.new("TextBox", Main)
TypeInput.Size = UDim2.new(0, 150, 0, 30)
TypeInput.Position = UDim2.new(0, 220, 0, 40)
TypeInput.PlaceholderText = "Type (All/Remote/Model)"
TypeInput.Text = "All"
TypeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TypeInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local ScanBtn = Instance.new("TextButton", Main)
ScanBtn.Size = UDim2.new(0, 100, 0, 30)
ScanBtn.Position = UDim2.new(0, 260, 0, 75) -- Смещено вниз
ScanBtn.Text = "START SCAN"
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Position = UDim2.new(0, 150, 0, 75)

-- Окно результатов
local ResultBox = Instance.new("TextBox", Main)
ResultBox.Size = UDim2.new(1, -20, 1, -120)
ResultBox.Position = UDim2.new(0, 10, 0, 110)
ResultBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ResultBox.TextColor3 = Color3.fromRGB(0, 255, 0)
ResultBox.Font = Enum.Font.Code
ResultBox.TextSize = 12
ResultBox.ClearTextOnFocus = false
ResultBox.TextXAlignment = Enum.TextXAlignment.Left
ResultBox.TextYAlignment = Enum.TextYAlignment.Top
ResultBox.MultiLine = true

local function PerformScan()
    local zoneName = ZoneInput.Text
    local filterType = TypeInput.Text:lower()
    local target = nil
    
    -- Поиск зоны
    pcall(function()
        target = game:GetService(zoneName) or game:FindFirstChild(zoneName, true)
    end)

    if not target then
        ResultBox.Text = "Zone not found!"
        return
    end

    local results = {}
    for _, obj in pairs(target:GetDescendants()) do
        local match = false
        if filterType == "all" then
            match = true
        elseif filterType == "remote" and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            match = true
        elseif filterType == "model" and obj:IsA("Model") then
            match = true
        elseif filterType == "script" and (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) then
            match = true
        end

        if match then
            table.insert(results, "[" .. obj.ClassName .. "] " .. obj.Name .. " | " .. obj:GetFullName())
        end
    end

    local finalString = "--- SCANNING: " .. zoneName .. " (" .. filterType .. ") ---\n"
    for _, line in ipairs(results) do
        finalString = finalString .. line .. "\n"
    end
    ResultBox.Text = finalString
end

ScanBtn.MouseButton1Click:Connect(PerformScan)
