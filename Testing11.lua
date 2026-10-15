-- GGE SOURCE EXTRACTOR v2.0
-- Продвинутый инструмент извлечения кода с поддержкой декомпиляции

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_SourceExtractor"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 600)
Main.Position = UDim2.new(0.5, -250, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "SOURCE EXTRACTOR v2.0 (DECOMPILER)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 100, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold

local PathInput = Instance.new("TextBox", Main)
PathInput.Size = UDim2.new(1, -20, 0, 30)
PathInput.Position = UDim2.new(0, 10, 0, 40)
PathInput.PlaceholderText = "Full path (e.g. ReplicatedStorage.HitboxUtil)"
PathInput.Text = "ReplicatedStorage.HitboxUtil"
PathInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PathInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local ReadBtn = Instance.new("TextButton", Main)
ReadBtn.Size = UDim2.new(0, 150, 0, 30)
ReadBtn.Position = UDim2.new(0.5, -75, 0, 75)
ReadBtn.Text = "EXTRACT CODE"
ReadBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
    
    local start = 1
    if parts[1] == "game" then start = 2 end
    
    for i = start, #parts do
        current = current:FindFirstChild(parts[i])
        if not current then break end
    end
    
    if current and (current:IsA("ModuleScript") or current:IsA("LocalScript") or current:IsA("Script")) then
        local source = nil
        
        -- МЕТОД 1: Декомпиляция (Самый надежный для экзекуторов)
        local success1, res1 = pcall(function() return decompile(current) end)
        if success1 and res1 then 
            source = res1 
        else
            -- МЕТОД 2: getscriptsource
            local success2, res2 = pcall(function() return getscriptsource(current) end)
            if success2 and res2 then 
                source = res2 
            else
                -- МЕТОД 3: Прямое чтение .Source
                local success3, res3 = pcall(function() return current.Source end)
                if success3 and res3 then 
                    source = res3 
                end
            end
        end

        if source then
            ResultBox.Text = source
        else
            ResultBox.Text = "FAILED: Your executor does not support decompile, getscriptsource, or .Source for this object."
        end
    else
        ResultBox.Text = "Object not found or is not a script!"
    end
end)
