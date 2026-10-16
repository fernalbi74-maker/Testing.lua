-- GGE COMBAT ADVANCED EXPLOITER
local AttackFolder = game.Lighting:FindFirstChild("AttackTools")
if not AttackFolder then return end

local function GetClosestPlayer()
    local closest = nil
    local dist = 100 -- Увеличили радиус
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = p.Character
            end
        end
    end
    return closest
end

local function ExecuteAttack()
    local target = GetClosestPlayer()
    if not target then return end
    
    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    local targetHum = target:FindFirstChild("Humanoid")
    if not targetHRP or not targetHum then return end

    for _, remote in pairs(AttackFolder:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            -- Перебор наиболее вероятных структур аргументов, которые проходят валидацию:
            pcall(function()
                -- 1. Только цель (сервер сам считает урон)
                remote:FireServer(target) 
                
                -- 2. Цель и её Humanoid (часто используется в старых скриптах)
                remote:FireServer(targetHum)
                
                -- 3. Цель и позиция (обход проверки дистанции)
                remote:FireServer(targetHRP.Position)
                
                -- 4. Попытка передать таблицу (некоторые серверы принимают {damage = 999})
                remote:FireServer({["Damage"] = 999999, ["Target"] = target})
                
                -- 5. Передача объекта HumanoidRootPart
                remote:FireServer(targetHRP)
            end)
        end
    end
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0, 200, 0, 50)
Btn.Position = UDim2.new(0.5, -100, 0.8, 0)
Btn.Text = "EXECUTE EXPLOIT"
Btn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

Btn.MouseButton1Click:Connect(function()
    -- Запуск в цикле для обхода кулдаунов (Spamming)
    for i = 1, 10 do 
        ExecuteAttack()
        task.wait(0.1) 
    end
end)
