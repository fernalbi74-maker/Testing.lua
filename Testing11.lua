-- GGE MODULE READER
-- Инструмент для извлечения исходного кода модулей

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_ModuleReader"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 600)
Main.Position = UDim2.new(0.5, -250, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "MODULE SOURCE READER"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold

local PathInput = Instance.new("TextBox", Main)
PathInput.Size = UDim2.new(1, -20, 0, 30)
PathInput.Position = UDim2.new(0, 10, 0, 40)
PathInput.PlaceholderText = "Full path to ModuleScript (e.g. ReplicatedStorage.HitboxUtil)"
PathInput.Text = "ReplicatedStorage.HitboxUtil"
PathInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PathInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local ReadBtn = Instance.new("TextButton", Main)
ReadBtn.Size = UDim2.new(0, 150, 0, 30)
ReadBtn.Position = UDim2.new(0.5, -75, 0, 75)
ReadBtn.Text = "READ SOURCE"
ReadBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ReadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ResultBox = Instance.new("TextBox", Main)
ResultBox.Size = UDim2.new(1, -20, 1, -130)
ResultBox.Position = UDim2.new(0, 10, 0, 110)
ResultBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ResultBox.TextColor3 = Color3.fromRGB(0, 255, 0)
ResultBox.Font = Enum.Font.Code
ResultBox.TextSize = 12
ResultBox.ClearTextOnFocus = false
ResultBox.TextXAlignment = Enum.TextXAlignment.Left
ResultBox.TextYAlignment = Enum.TextYAlignment.Top
ResultBox.MultiLine = true

ReadBtn.MouseButton1Click:Connect(function()
    local path = PathInput.Text
    local current = game
    local parts = string.split(path, ".")
    
    -- Пропускаем "game" если он в начале
    local start = 1
    if parts[1] == "game" then start = 2 end
    
    for i = start, #parts do
        current = current:FindFirstChild(parts[i])
        if not current then break end
    end
    
    if current and (current:IsA("ModuleScript") or current:IsA("LocalScript") or current:IsA("Script")) then
        -- В большинстве экзекуторов .Source работает для чтения кода
        local success, source = pcall(function() return current.Source end)
        if success and source then
            ResultBox.Text = source
        else
            ResultBox.Text = "Error: Could not read source. Your executor might not support .Source"
        end
    else
        ResultBox.Text = "Object not found or is not a script!"
    end
end)
