-- LocalScript (executor) — Find boss TrueHp and hidden scripts
-- Scans for custom HP values and hidden server scripts.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "OllieFinder"
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
label.Text = "Scanning for TrueHp and hidden scripts..."
label.TextColor3 = Color3.fromRGB(140, 100, 255)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.Parent = frame

task.wait(1)

local results = {}
local count = 0

-- 1. Find TrueHp / custom health values
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("StringValue") then
        if v.Name:lower():find("hp") or v.Name:lower():find("health") or v.Name:lower():find("damage") then
            count = count + 1
            local path = v:GetFullName()
            local val = tostring(v.Value)
            table.insert(results, string.format("-- [%s] %s = %s", v.ClassName, path, val))
        end
    end
end

-- 2. Find hidden scripts in Workspace
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("LuaSourceContainer") then
        if v.Name:lower():find("hitbox") or v.Name:lower():find("damage") or v.Name:lower():find("kill") or v.Name:lower():find("boss") then
            count = count + 1
            table.insert(results, string.format("-- [SCRIPT] %s (%s)", v:GetFullName(), v.ClassName))
        end
    end
end

-- 3. Find Remotes that might be damage
for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        if v.Name:lower():find("hit") or v.Name:lower():find("damage") or v.Name:lower():find("attack") then
            count = count + 1
            table.insert(results, string.format("-- [REMOTE] %s (%s)", v:GetFullName(), v.ClassName))
        end
    end
end

local out = table.concat(results, "\n")
label.Text = "Found " .. count .. " items.\n\n" .. out

if setclipboard then
    pcall(setclipboard, out)
end
