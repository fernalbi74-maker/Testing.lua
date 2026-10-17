-- LocalScript (executor) — Find Boss TrueHp and Remotes
-- Scans Workspace for boss models and their health values.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_BossScan"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.4, 0)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 1, -20)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "Scanning Bosses..."
label.TextColor3 = Color3.fromRGB(140, 100, 255)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.Parent = frame

task.wait(1)

local results = {}
local count = 0

-- 1. Find boss models and their health values
for _, v in ipairs(workspace:GetChildren()) do
    if v:IsA("Model") then
        local hasHumanoid = v:FindFirstChildOfClass("Humanoid")
        local zombie = v:FindFirstChild("Zombie")
        local trueHp = v:FindFirstChild("TrueHp") or (zombie and zombie:FindFirstChild("TrueHp"))
        
        if hasHumanoid or zombie or trueHp then
            count = count + 1
            table.insert(results, "-- BOSS FOUND: " .. v:GetFullName())
            
            if hasHumanoid then
                local hum = v:FindFirstChildOfClass("Humanoid")
                table.insert(results, "   Humanoid HP: " .. tostring(hum.Health) .. "/" .. tostring(hum.MaxHealth))
            end
            
            if trueHp then
                table.insert(results, "   TrueHp Value: " .. tostring(trueHp.Value))
            end
            
            -- Look for any NumberValue inside the boss
            for _, child in ipairs(v:GetDescendants()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    local n = child.Name:lower()
                    if n:find("hp") or n:find("health") or n:find("damage") then
                        table.insert(results, "   [" .. child.ClassName .. "] " .. child.Name .. " = " .. tostring(child.Value))
                    end
                end
            end
        end
    end
end

-- 2. Find remotes that might control boss damage
for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        local n = v.Name:lower()
        if n:find("hp") or n:find("health") or n:find("damage") or n:find("boss") or n:find("hit") then
            table.insert(results, "-- [REMOTE] " .. v:GetFullName())
        end
    end
end

local out = table.concat(results, "\n")
label.Text = "Found " .. count .. " bosses.\n\n" .. out

if setclipboard then
    pcall(setclipboard, out)
end
