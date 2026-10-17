-- GGE NUCLEAR BOSS-SLAYER v1.0
-- Максимальный перебор аргументов + Копируемый список скриптов

local Player = game.Players.LocalPlayer
local AttackFolder = game.Lighting:FindFirstChild("AttackTools")

-- Настройки атаки
local Damage = 9999999
local AttackInterval = 0.5 -- Скорость атаки (сек)

-- Создание UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- 1. КНОПКА АТАКИ
local AttackBtn = Instance.new("TextButton", ScreenGui)
AttackBtn.Size = UDim2.new(0, 200, 0, 50)
AttackBtn.Position = UDim2.new(0.5, -100, 0.7, 0)
AttackBtn.Text = "START NUCLEAR ATTACK"
AttackBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AttackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AttackBtn.TextSize = 18

-- 2. КОПИРУЕМОЕ ОКНО СПИСКА (TextBox вместо TextLabel)
local CopyBox = Instance.new("TextBox", ScreenGui)
CopyBox.Size = UDim2.new(0, 300, 0, 300)
CopyBox.Position = UDim2.new(0, 10, 0, 10)
CopyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CopyBox.TextColor3 = Color3.fromRGB(0, 255, 0)
CopyBox.TextXAlignment = Enum.TextXAlignment.Left
CopyBox.TextYAlignment = Enum.TextYAlignment.Top
CopyBox.ClearTextOnFocus = false
CopyBox.MultiLine = true
CopyBox.Text = "Loading scripts..."

local Active = false

-- Поиск босса/цели
local function GetTarget()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= Player.Character then
            return obj
        end
    end
    return nil
end

-- Ядерный цикл атак
local function NuclearAttack()
    local target = GetTarget()
    if not target then return end
    
    for _, remote in pairs(AttackFolder:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                -- ПЕРЕБОР 10 ВАРИАНТОВ АРГУМЕНТОВ
                remote:FireServer(target, Damage) -- (Цель, Урон)
                remote:FireServer(Damage, target) -- (Урон, Цель)
                remote:FireServer("Damage", target, Damage) -- (Команда, Цель, Урон)
                remote:FireServer("Attack", target, Damage) -- (Команда, Цель, Урон)
                remote:FireServer(target, {Damage = Damage}) -- (Цель, Таблица)
                remote:FireServer({Target = target, Damage = Damage}) -- (Таблица всего)
                remote:FireServer(target, "Kill") -- (Цель, Команда смерти)
                remote:FireServer(target, target.HumanoidRootPart.Position, Damage) -- (Цель, Позиция, Урон)
                remote:FireServer(target, Vector3.new(0,0,0), Damage) -- (Цель, Нулевой вектор, Урон)
                remote:FireServer(Damage, Damage, target) -- (Урон, Урон, Цель)
            end)
        end
    end
end

-- Запуск цикла
task.spawn(function()
    while true do
        if Active then
            NuclearAttack()
        end
        task.wait(AttackInterval)
    end
end)

-- Переключатель
AttackBtn.MouseButton1Click:Connect(function()
    Active = not Active
    AttackBtn.Text = Active and "STOP ATTACK" or "START NUCLEAR ATTACK"
    AttackBtn.BackgroundColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- Заполнение CopyBox списком скриптов (теперь можно копировать!)
local scriptList = ""
for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
    if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        scriptList = scriptList .. obj:GetFullName() .. "\n"
    end
end
CopyBox.Text = scriptList == "" and "No scripts found" or scriptList

print("Nuclear Slayer Loaded. You can now copy scripts from the box!")
