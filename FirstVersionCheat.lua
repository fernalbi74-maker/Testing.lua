-- GGE COMBAT ADVANCED EXPLOITER V2
local AttackFolder = game.Lighting:FindFirstChild("AttackTools")
if not AttackFolder then 
    -- Создаем временный лейбл для ошибки, если папка не найдена
    local ErrorGui = Instance.new("ScreenGui", game.CoreGui)
    local ErrorLbl = Instance.new("TextLabel", ErrorGui)
    ErrorLbl.Size = UDim2.new(0, 400, 0, 50)
    ErrorLbl.Position = UDim2.new(0.5, -200, 0.1, 0)
    ErrorLbl.Text = "CRITICAL ERROR: AttackTools folder not found!"
    ErrorLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
    ErrorLbl.BackgroundTransparency = 1
    return 
end

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- Текстовое поле для уведомлений (вместо консоли)
local StatusLabel = Instance.new("TextLabel", ScreenGui)
StatusLabel.Size = UDim2.new(0, 400, 0, 30)
StatusLabel.Position = UDim2.new(0.5, -200, 0.1, 0) -- В верхней части экрана
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusLabel.BackgroundTransparency = 0.5
StatusLabel.TextSize = 18

-- Кнопка активации (перемещена вверх)
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0, 200, 0, 50)
Btn.Position = UDim2.new(0.5, -100, 0.2, 0) -- Поднята выше (Y = 0.2)
Btn.Text = "EXECUTE EXPLOIT"
Btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 20

-- LOGIC
local function GetClosestPlayer()
    local closest = nil
    local dist = 100
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
    if not target then 
        StatusLabel.Text = "Status: No target nearby!" 
        StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        return 
    end
    
    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    local targetHum = target:FindFirstChild("Humanoid")
    if not targetHRP or not targetHum then return end

    StatusLabel.Text = "Status: Attacking " .. target.Name .. "..."
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)

    for _, remote in pairs(AttackFolder:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(target) 
                remote:FireServer(targetHum)
                remote:FireServer(targetHRP.Position)
                remote:FireServer({["Damage"] = 999999, ["Target"] = target})
                remote:FireServer(targetHRP)
            end)
        end
    end
end

Btn.MouseButton1Click:Connect(function()
    -- Цикл спама для обхода серверных кулдаунов
    for i = 1, 15 do 
        ExecuteAttack()
        task.wait(0.05) 
    end
    StatusLabel.Text = "Status: Attack Sequence Finished"
end)
