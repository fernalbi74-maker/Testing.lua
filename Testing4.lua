-- GGE STABLE FRAMEWORK v1.0
-- Phase A: Stability & Phase B: Stealth Spy

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [СИСТЕМА ЛОГИРОВАНИЯ]
local LogQueue = {}
local function AddToLog(text)
    table.insert(LogQueue, 1, text)
    if #LogQueue > 50 then table.remove(LogQueue, 51) end
end

-- [UI: МИНИМАЛИСТИЧНЫЙ И НЕБЛОКИРУЮЩИЙ]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GGE_Framework"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 300)
Main.Position = UDim2.new(0.5, -140, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "GGE | STABLE SPY"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 3

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 3)

-- Функция обновления текста в UI (выполняется в отдельном потоке Heartbeat)
task.spawn(function()
    while true do
        -- Очистка старых лейблов для оптимизации
        for _, child in pairs(Scroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        
        -- Отрисовка текущей очереди логов
        for i, text in ipairs(LogQueue) do
            local L = Instance.new("TextLabel", Scroll)
            L.Size = UDim2.new(1, 0, 0, 30)
            L.Text = text
            L.TextColor3 = Color3.fromRGB(0, 255, 0)
            L.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            L.TextWrapped = true
            L.Font = Enum.Font.Code
            L.TextSize = 11
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
        task.wait(1) -- Обновление раз в секунду, чтобы не вешать игру
    end
end)

-- [БЕЗОПАСНЫЙ ПЕРЕХВАТ (STEALTH HOOK)]
-- Используем hookmetamethod для максимальной скрытности и стабильности
local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", function(self, args)
    local method = getnamecallmethod()
    
    -- Проверяем, является ли вызов отправкой на сервер
    if method == "FireServer" and self:IsA("RemoteEvent") then
        -- Оборачиваем логику записи в pcall, чтобы любая ошибка в логере 
        -- НЕ блокировала отправку пакета на сервер
        pcall(function()
            local argString = ""
            for i, v in pairs(args) do
                argString = argString .. tostring(v) .. (i < #args and ", " or "")
            end
            AddToLog("Event: " .. self.Name .. "\nArgs: " .. argString)
        end)
    end
    
    -- Возвращаем оригинальный вызов без изменений
    return oldNameCall(self, args)
end)

-- [ТЕСТ СТАБИЛЬНОСТИ]
task.spawn(function()
    print("GGE Framework Loaded: Stability Mode Active")
end)
