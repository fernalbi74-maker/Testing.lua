-- GGE ALL-IN-ONE COMBINE v1.0
-- Максимальный функционал без необходимости в логах и сканировании

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local AttackFolder = game.Lighting:FindFirstChild("AttackTools")

-- Настройки
local Settings = {
    AttackRange = 100,
    HitboxSize = 30,
    DamageValue = 999999,
    DefenseValue = 95
}

-- Создание компактного UI (Маленькая кнопка в углу)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 60, 0, 30)
MainBtn.Position = UDim2.new(0, 10, 0, 10) -- Верхний левый угол
MainBtn.Text = "OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.TextSize = 14
MainBtn.Draggable = true -- Можно перетащить, если мешает

local Active = false

-- Функция поиска ближайшей цели
local function GetTarget()
    local closest = nil
    local dist = Settings.AttackRange
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (Player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = p.Character
            end
        end
    end
    return closest
end

-- Основной цикл чита
RunService.Heartbeat:Connect(function()
    if not Active then return end
    
    local target = GetTarget()
    local char = Player.Character
    
    -- 1. Попытка ударить всех найденными ремотами
    if target and AttackFolder then
        for _, remote in pairs(AttackFolder:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    -- Пробуем 3 самых частых формата аргументов
                    remote:FireServer(target, Settings.DamageValue)
                    remote:FireServer(target, target.HumanoidRootPart.Position, Settings.DamageValue)
                    remote:FireServer(Settings.DamageValue, target)
                end)
            end
        end
    end
    
    -- 2. Расширение хитбоксов (на основе HitboxUtil)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CollisionGroup == "PlrAttacks" then
            obj.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            obj.CanCollide = false
        end
    end
    
    -- 3. Спам атрибутами защиты/урона (на основе DefenseUtil)
    if char then
        char:SetAttribute("BaseDefense", Settings.DefenseValue)
        char:SetAttribute("VerityDamageBuff", Settings.DamageValue)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetAttribute("BaseDefense", Settings.DefenseValue)
        end
    end
end)

-- Переключатель
MainBtn.MouseButton1Click:Connect(function()
    Active = not Active
    MainBtn.Text = Active and "ON" or "OFF"
    MainBtn.BackgroundColor3 = Active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

print("GGE Combine Loaded. Click the small button to toggle.")
