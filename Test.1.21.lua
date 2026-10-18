-- LocalScript (executor) — Snapshot scripts the moment the boss spawns
-- Monitors Workspace, Lighting, and ReplicatedStorage for new scripts.
-- Decompiles them instantly and copies to clipboard.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Snapshot"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.15, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.BorderSizePixel = 0
label.Text = "Watching for boss spawns..."
label.TextColor3 = Color3.fromRGB(0, 255, 100)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

local results = {}
local seen = {}

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

local function snapshot(obj)
    if seen[obj] then return end
    seen[obj] = true
    
    if obj:IsA("LuaSourceContainer") then
        local path = getPath(obj)
        label.Text = "Caught: " .. obj.Name
        task.wait(0.1)
        
        local src = nil
        if decompile then
            local ok, dec = pcall(decompile, obj)
            if ok and dec then src = dec end
        end
        if not src then
            local ok, raw = pcall(function() return obj.Source end)
            if ok and raw and #raw > 0 then src = raw end
        end
        
        if src then
            table.insert(results, string.format("-- [%s] %s\n%s\n", obj.ClassName, path, src))
        else
            table.insert(results, string.format("-- [%s] %s\n-- (decompile failed)\n", obj.ClassName, path))
        end
    elseif obj:IsA("Model") or obj:IsA("Folder") then
        for _, d in ipairs(obj:GetDescendants()) do
            snapshot(d)
        end
    end
end

local function watch(service)
    service.DescendantAdded:Connect(function(d)
        snapshot(d)
    end)
end

watch(workspace)
watch(Lighting)
watch(RS)

-- Copy to clipboard function
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
copyBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
copyBtn.Text = "Copy All Scripts"
copyBtn.TextColor3 = Color3.fromRGB(20, 16, 30)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = gui
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

copyBtn.MouseButton1Click:Connect(function()
    local out = table.concat(results, "\n")
    if #out > 150000 then out = out:sub(1, 150000) .. "\n-- TRUNCATED" end
    if setclipboard then
        pcall(setclipboard, out)
        label.Text = "Copied " .. #results .. " scripts!"
    end
end)

-- Initial scan in case boss is already alive
for _, v in ipairs(workspace:GetDescendants()) do snapshot(v) end
for _, v in ipairs(Lighting:GetDescendants()) do snapshot(v) end
