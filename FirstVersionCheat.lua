-- GGE REMOTE FUZZER v1.0
-- Пытается «угадать» правильный аргумент для убийства босса

local Player = game.Players.LocalPlayer
local AttackFolder = game.Lighting:FindFirstChild("AttackTools")

local function GetTarget()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= Player.Character then
            return obj
        end
    end
    return nil
end

local function Fuzz()
    local target = GetTarget()
    if not target then print("No target found!") return end
    
    local damage = 999999
    
    for _, remote in pairs(AttackFolder:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                -- Вариант 1: (Цель, Урон)
                remote:FireServer(target, damage)
                -- Вариант 2: (Урон, Цель)
                remote:FireServer(damage, target)
                -- Вариант 3: ("Damage", Цель, Урон)
                remote:FireServer("Damage", target, damage)
                -- Вариант 4: ("Attack", Цель, Урон)
                remote:FireServer("Attack", target, damage)
                -- Вариант 5: (Цель, {Damage = Урон})
                remote:FireServer(target, {Damage = damage, Power = damage})
                -- Вариант 6: (Цель, "Kill")
                remote:FireServer(target, "Kill")
            end)
        end
    end
end

-- Кнопка для запуска одного цикла «Фаззинга»
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0, 200, 0, 50)
Btn.Position = UDim2.new(0.5, -100, 0.8, 0)
Btn.Text = "FUZZ ATTACK (KILL BOSS)"
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

Btn.MouseButton1Click:Connect(function()
    Fuzz()
    print("Fuzzing signals sent!")
end)
