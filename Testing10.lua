-- GGE ULTRA-SCANNER v5.0
-- Система постраничного вывода с фильтрацией мусора

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_UltraScanner"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 550)
Main.Position = UDim2.new(0.5, -225, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "ULTRA-SCANNER v5.0 (ANTI-LAG)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold

-- Поля ввода
local ZoneInput = Instance.new("TextBox", Main)
ZoneInput.Size = UDim2.new(0, 200, 0, 30)
ZoneInput.Position = UDim2.new(0, 10, 0, 40)
ZoneInput.PlaceholderText = "Zone (e.g. ReplicatedStorage)"
ZoneInput.Text = "ReplicatedStorage"
ZoneInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ZoneInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local TypeInput = Instance.new("TextBox", Main)
TypeInput.Size = UDim2.new(0, 130, 0, 30)
TypeInput.Position = UDim2.new(0, 220, 0, 40)
TypeInput.PlaceholderText = "Type (All/Remote/Script)"
TypeInput.Text = "All"
TypeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TypeInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local ScanBtn = Instance.new("TextButton", Main)
ScanBtn.Size = UDim2.new(0, 100, 0, 30)
ScanBtn.Position = UDim2.new(0, 160, 0, 75)
ScanBtn.Text = "SCAN ZONE"
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Окно результатов
local ResultBox = Instance.new("TextBox", Main)
ResultBox.Size = UDim2.new(1, -20, 1, -160)
ResultBox.Position = UDim2.new(0, 10, 0, 110)
ResultBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ResultBox.TextColor3 = Color3.fromRGB(0, 255, 0)
ResultBox.Font = Enum.Font.Code
ResultBox.TextSize = 12
ResultBox.ClearTextOnFocus = false
ResultBox.TextXAlignment = Enum.TextXAlignment.Left
ResultBox.TextYAlignment = Enum.TextYAlignment.Top
ResultBox.MultiLine = true

-- Навигация по страницам
local PageLabel = Instance.new("TextLabel", Main)
PageLabel.Size = UDim2.new(0, 100, 0, 30)
PageLabel.Position = UDim2.new(0, 10, 1, -50)
PageLabel.Text = "Page: 0/0"
PageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PageLabel.BackgroundTransparency = 1

local PrevBtn = Instance.new("TextButton", Main)
PrevBtn.Size = UDim2.new(0, 80, 0, 30)
PrevBtn.Position = UDim2.new(0, 120, 1, -50)
PrevBtn.Text = "<< Prev"
PrevBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local NextBtn = Instance.new("TextButton", Main)
NextBtn.Size = UDim2.new(0, 80, 0, 30)
NextBtn.Position = UDim2.new(0, 210, 1, -50)
NextBtn.Text = "Next >>"
NextBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Логика
local allResults = {}
local currentPage = 1
local itemsPerPage = 50

-- ЧЕРНЫЙ СПИСОК (что игнорируем, чтобы не лагало)
local blacklist = {
    ["PineTree"] = true,
    ["Part"] = true,
    ["MeshPart"] = true,
    ["Texture"] = true,
    ["Decal"] = true,
    ["SpecialMesh"] = true,
    ["BasePart"] = true,
    ["Cylinder"] = true,
    ["Sphere"] = true,
    ["WedgePart"] = true
}

local function UpdateDisplay()
    local startIdx = (currentPage - 1) * itemsPerPage + 1
    local endIdx = math.min(currentPage * itemsPerPage, #allResults)
    
    local text = ""
    for i = startIdx, endIdx do
        text = text .. allResults[i] .. "\n"
    end
    
    ResultBox.Text = text
    PageLabel.Text = "Page: " .. currentPage .. "/" .. math.ceil(#allResults / itemsPerPage)
end

ScanBtn.MouseButton1Click:Connect(function()
    local zoneName = ZoneInput.Text
    local filterType = TypeInput.Text:lower()
    local target = nil
    
    pcall(function()
        target = game:GetService(zoneName) or game:FindFirstChild(zoneName, true)
    end)

    if not target then ResultBox.Text = "Zone not found!"; return end

    allResults = {}
    currentPage = 1
    
    for _, obj in pairs(target:GetDescendants()) do
        -- 1. Проверка на черный список
        if not blacklist[obj.Name] and not blacklist[obj.ClassName] then
            local match = false
            
            if filterType == "all" then
                match = true
            elseif filterType == "remote" and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                match = true
            elseif filterType == "script" and (obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script")) then
                match = true
            elseif filterType == "model" and obj:IsA("Model") then
                match = true
            end

            if match then
                table.insert(allResults, "[" .. obj.ClassName .. "] " .. obj.Name .. " | " .. obj:GetFullName())
            end
        end
    end
    
    UpdateDisplay()
end)

NextBtn.MouseButton1Click:Connect(function()
    if currentPage * itemsPerPage < #allResults then
        currentPage = currentPage + 1
        UpdateDisplay()
    end
end)

PrevBtn.MouseButton1Click:Connect(function()
    if currentPage > 1 then
        currentPage = currentPage - 1
        UpdateDisplay()
    end
end)
