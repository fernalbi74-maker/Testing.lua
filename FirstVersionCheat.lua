-- GGE STABILIZED COMBINE v2.0
-- Исправлен баг с поломкой карты и оптимизирована атака

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local AttackFolder = game.Lighting:FindFirstChild("AttackTools")

-- Настройки
local Settings = {
    AttackRange = 100,
    HitboxSize = 15, -- Уменьшено для стабильности (карта больше не сломается)
    DamageValue = 999999,
    DefenseValue = 95
}

-- Компактный UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 60, 0, 30)
MainBtn.Position = UDim2.new(0, 10, 0, 10)
MainBtn.Text = "OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.Draggable = true

local Active = false

-- Поиск цели (включая боссов)
local function GetTarget()
    local closest = nil
    local dist = Settings.AttackRange
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= Player.Character then
            local root = obj:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (Player.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = obj
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if not Active then return end
    
    local target = GetTarget()
    local char = Player.Character
    
    -- 1. ТОЧНАЯ АТАКА (Без перегрузки сервера)
    if target and AttackFolder then
        for _, remote in pairs(AttackFolder:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                -- Отправляем сигнал только раз в несколько кадров, чтобы не кикнуло
                if math.random(1, 10) == 1 then 
                    pcall(function()
                        remote:FireServer(target, Settings.DamageValue)
                    end)
                end
            end
        end
    end
    
    -- 2. СТАБИЛЬНЫЙ ХИТБОКС (Исправлено: больше не ломает карту)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CollisionGroup == "PlrAttacks" then
            -- ГЛАВНОЕ ИСПРАВЛЕНИЕ: Не трогаем закрепленные детали!
            if not obj.Anchored then 
                obj.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                obj.CanCollide = false
                obj.Transparency = 0.7
            end
        end
    end
    
    -- 3. ЗАЩИТА
    if char then
        char:SetAttribute("BaseDefense", Settings.DefenseValue)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:SetAttribute("BaseDefense", Settings.DefenseValue) end
    end
end)

MainBtn.MouseButton1Click:Connect(function()
    Active = not Active
    MainBtn.Text = Active and "ON" or "OFF"
    MainBtn.BackgroundColor3 = Active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

print("GGE Stabilized Loaded. Map physics fixed!")
