-- GGE OMEGA-CHEAT v1.0
-- Базируется на анализе HitboxUtil и DefenseUtil

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- 1. GOD MODE (DefenseUtil Exploit)
-- Устанавливаем максимальный порог защиты, который разрешен в DefenseUtil
local function ApplyGodMode()
    local char = Player.Character
    if char then
        char:SetAttribute("BaseDefense", 95)
        char:SetAttribute("SatsuDef", true)
        char:SetAttribute("MasterSparkDefense", 95)
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetAttribute("BaseDefense", 95)
            hum:SetAttribute("Defense", 95)
        end
    end
    print("God Mode: Applied (95% Damage Reduction)")
end

-- 2. DAMAGE BOOST (HitboxUtil Exploit)
-- Взламываем множители урона из функции v_u_97
local function ApplyDamageBoost()
    local char = Player.Character
    if char then
        char:SetAttribute("VerityDamageBuff", 9999) -- Огромный множитель
        char:SetAttribute("VerityEquipped", true)
        char:SetAttribute("CrowbarEquipped", true)
    end
    print("Damage Boost: Applied (Verity Buff)")
end

-- 3. HITBOX EXPANDER (HitboxUtil Exploit)
-- Увеличиваем размер деталей, которые используются для GetPartBoundsInBox
local HitboxSize = 20 -- Размер куба атаки (чем больше, тем дальше бьешь)
local function ExpandHitboxes()
    game:GetService("RunService").Heartbeat:Connect(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            -- Ищем детали, которые относятся к атакам (CollisionGroup "PlrAttacks")
            if obj:IsA("BasePart") and obj.CollisionGroup == "PlrAttacks" then
                obj.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                obj.CanCollide = false
                obj.Transparency = 0.8 -- Сделаем их полупрозрачными, чтобы видеть зону поражения
                obj.Color = Color3.fromRGB(255, 0, 0)
            end
        end
    end)
    print("Hitbox Expander: Active")
end

-- Запуск всего функционала
task.spawn(function()
    ApplyGodMode()
    ApplyDamage laBoost()
    ExpandHitboxes()
end)

-- Авто-обновление при смерти/респавне
Player.CharacterAdded:Connect(function()
    Character = game.Players.LocalPlayer.Character
    task.wait(1)
    ApplyGodMode()
    ApplyDamageBoost()
end)

print("GGE Omega-Cheat Loaded Successfully!")
