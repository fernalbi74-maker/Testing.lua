-- LocalScript (executor) — TBSOBR Standalone Insta-Kill & Autofarm
-- Uses the SimulationRadius bypass from the leaked scripts.
-- No external loadstrings, fully self-contained.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)
local BTN = Color3.fromRGB(32, 28, 46)
local ON = Color3.fromRGB(90, 220, 160)
local TEXT = Color3.fromRGB(235, 230, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Standalone"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(0, 24, 0, 24)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ollie · TBSOBR"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local function makeButton(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = color or BTN
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = "Ready."
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = frame

local killBtn = makeButton("Insta-Kill Boss", 60)
local farmBtn = makeButton("Autofarm: OFF", 100)
local doorBtn = makeButton("Remove Door", 140)

-- SimulationRadius Bypass
local function applySimRadius()
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 69696969)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)
end

-- Insta-Kill Logic
killBtn.MouseButton1Click:Connect(function()
    applySimRadius()
    status.Text = "Killing bosses..."
    local killed = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent then
            if v.Parent:FindFirstChild("Zombie") or v.Parent:FindFirstChild("NPCTAG") then
                if not v.Parent:FindFirstChild("invincible") then
                    v.Health = 0
                    v.MaxHealth = 0
                    killed = killed + 1
                end
            end
        end
    end
    status.Text = "Killed " .. killed .. " bosses."
end)

-- Autofarm Logic
local autofarmEnabled = false
local farmConn = nil

local function startAutofarm()
    applySimRadius()
    farmConn = RunService.Heartbeat:Connect(function()
        applySimRadius()
        
        -- Wave check
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local waveGui = pg and pg:FindFirstChild("Wave Counter")
        local waveText = waveGui and waveGui:FindFirstChild("WAVE") and waveGui.WAVE:FindFirstChildOfClass("TextLabel")
        
        if waveText and (waveText.Text == "Wave: 0/0" or waveText.Text == "Wave: 0/68408") then
            local start = workspace:FindFirstChild("Start")
            if start and start:FindFirstChild("Part") and LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                firetouchinterest(start.Part, LocalPlayer.Character.HumanoidRootPart, 0)
                firetouchinterest(start.Part, LocalPlayer.Character.HumanoidRootPart, 1)
            end
        else
            -- Kill whatever is alive
            for _, v in ipairs(workspace:GetChildren()) do
                if v:FindFirstChildOfClass("Humanoid") and (v:FindFirstChild("Zombie") or v:FindFirstChild("NPCTAG")) then
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    if hum.Health > 0 and not v:FindFirstChild("invincible") then
                        hum.Health = 0
                        hum.MaxHealth = 0
                    end
                end
            end
        end
    end)
end

farmBtn.MouseButton1Click:Connect(function()
    autofarmEnabled = not autofarmEnabled
    farmBtn.Text = "Autofarm: " .. (autofarmEnabled and "ON" or "OFF")
    farmBtn.BackgroundColor3 = autofarmEnabled and ON or BTN
    farmBtn.TextColor3 = autofarmEnabled and Color3.fromRGB(10, 20, 14) or TEXT
    
    if autofarmEnabled then
        status.Text = "Autofarming..."
        startAutofarm()
    else
        status.Text = "Autofarm stopped."
        if farmConn then farmConn:Disconnect(); farmConn = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

-- Door Remover
doorBtn.MouseButton1Click:Connect(function()
    local door = workspace:FindFirstChild("Door")
    if door then
        door:Destroy()
        status.Text = "Door removed."
    else
        status.Text = "No door found."
    end
end)

-- Physics tweaks from the leaked script
pcall(function()
    settings().Physics.AllowSleep = false
    settings().Physics.ThrottleAdjustTime = math.huge - math.huge
end)
