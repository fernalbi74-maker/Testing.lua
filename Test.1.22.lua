-- LocalScript (executor) — TBSOBR Data & Hitbox Inspector
-- Prints the children of the boss Zombie model and kills hitboxes.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Inspector"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.5, 0)
frame.Position = UDim2.new(0.05, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 1, -20)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "Inspecting Boss..."
label.TextColor3 = Color3.fromRGB(235, 230, 255)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.TextYAlignment = Enum.TextYAlignment.Top
label.Parent = frame

task.wait(1)

local results = {}

-- 1. Inspect the Zombie model inside the boss
local function inspectBoss(boss)
    if not boss then return end
    table.insert(results, "-- BOSS: " .. boss:GetFullName())
    
    local zombie = boss:FindFirstChild("Zombie")
    if zombie then
        table.insert(results, "  -- Zombie Children:")
        for _, child in ipairs(zombie:GetChildren()) do
            if child:IsA("ValueBase") then
                table.insert(results, string.format("    [%s] %s = %s", child.ClassName, child.Name, tostring(child.Value)))
            elseif child:IsA("Script") then
                table.insert(results, "    [Script] " .. child.Name)
            end
        end
    end
    
    -- Check for TrueHp anywhere in the boss
    for _, child in ipairs(boss:GetDescendants()) do
        if child.Name:lower():find("hp") or child.Name:lower():find("health") then
            if child:IsA("ValueBase") then
                table.insert(results, string.format("  [%s] %s = %s", child.ClassName, child.Name, tostring(child.Value)))
            end
        end
    end
end

-- Find the active boss
for _, v in ipairs(workspace:GetChildren()) do
    if v:IsA("Model") and (v:FindFirstChild("Zombie") or v:FindFirstChild("NPCTAG")) then
        inspectBoss(v)
    end
end

-- 2. Hitbox Neutralizer
task.spawn(function()
    while task.wait(0.5) do
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local n = v.Name:lower()
                if n:find("bone") or n:find("blast") or n:find("spike") or n:find("tentacle") or n:find("knife") or n:find("wall") then
                    v.CanTouch = false
                    v.CanCollide = false
                    v.CanQuery = false
                end
            end
        end
    end
end)

local out = table.concat(results, "\n")
label.Text = out

if setclipboard then
    pcall(setclipboard, out)
end
