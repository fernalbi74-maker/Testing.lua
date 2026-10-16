-- GGE COMBAT BRUTE-FORCER
-- Пытается вызвать все ремоты атак с максимальным уроном

local AttackFolder = game.Lighting:FindFirstChild("AttackTools")
if not AttackFolder then print("AttackTools not found!") return end

local function GetClosestPlayer()
    local closest = nil
    local dist = 50
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

local function BruteForce()
    local target = GetClosestPlayer()
    if not target then print("No target nearby!") return end
    
    for _, remote in pairs(AttackFolder:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            -- Пробуем разные комбинации аргументов, которые часто используются:
            -- 1. (Цель, Урон)
            -- 2. (Цель, Позиция, Урон)
            -- 3. (Урон, Цель)
            
            pcall(function()
                remote:FireServer(target, 999999) 
                remote:FireServer(target, target.HumanoidRootPart.Position, 999999)
                remote:FireServer(999999, target)
            end)
        end
    end
end

-- Создаем кнопку для активации брутфорса
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0, 200, 0, 50)
Btn.Position = UDim2.new(0.5, -100, 0.8, 0)
Btn.Text = "BRUTE FORCE ATTACK"
Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

Btn.MouseButton1Click:Connect(function()
    BruteForce()
    print("Brute force signal sent to closest target!")
end)
