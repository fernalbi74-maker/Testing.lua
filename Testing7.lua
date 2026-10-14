-- GGE MEGA SCANNER v2.0
-- Поиск RemoteEvent + RemoteFunction с общим полем для копирования

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_MegaScanner"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "MEGA SCANNER (Copy All)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Одно большое поле для копирования всего списка
local FullLog = Instance.new("TextBox", Main)
FullLog.Size = UDim2.new(1, -10, 1, -40)
FullLog.Position = UDim2.new(0, 5, 0, 35)
FullLog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FullLog.TextColor3 = Color3.fromRGB(0, 255, 0)
FullLog.Font = Enum.Font.Code
FullLog.TextSize = 10
FullLog.ClearTextOnFocus = false
FullLog.TextXAlignment = Enum.TextXAlignment.Left
FullLog.TextYAlignment = Enum.TextYAlignment.Top
FullLog.MultiLine = true -- Позволяет многострочный текст

task.spawn(function()
    local allRemotes = {}
    local suspicious = {}
    local keywords = {"attack", "damage", "hit", "skill", "ability", "combat", "kill", "power", "event", "remote", "fire", "damage"}

    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local info = "[" .. obj.ClassName .. "] " .. obj.Name .. " | " .. obj:GetFullName()
            table.insert(allRemotes, info)
            
            -- Проверка на подозрительные слова
            for _, word in pairs(keywords) do
                if string.find(string.lower(obj.Name), word) then
                    table.insert(suspicious, info)
                    break
                end
            end
        end
    end

    -- Собираем всё в одну строку
    local finalString = "--- SUSPICIOUS ---\n" 
    for _, s in ipairs(suspicious) do finalString = finalString .. s .. "\n" end
    
    finalString = finalString .. "\n--- ALL REMOTES ---\n"
    for _, a in ipairs(allRemotes) do finalString = finalString .. a .. "\n" end

    FullLog.Text = finalString
end)
