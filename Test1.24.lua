-- LocalScript (executor) — Global Client Dump
-- Dumps every readable LocalScript and ModuleScript directly to a file.
-- No clipboard limits, no crashing.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local filename = "TBSOBR_FULL_DUMP.txt"

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Dump"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.2, 0)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 1, -20)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "Dumping everything..."
label.TextColor3 = Color3.fromRGB(140, 100, 255)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.TextYAlignment = Enum.TextYAlignment.Top
label.Parent = frame

task.wait(0.5)

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

local out = {}
table.insert(out, "-- TBSOBR GLOBAL CLIENT DUMP")
table.insert(out, "-- Place ID: " .. tostring(game.PlaceId))
table.insert(out, "-- Date: " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC\n")

local count = 0

-- Scan EVERYTHING in the game
for _, d in ipairs(game:GetDescendants()) do
    local path = getPath(d)
    
    -- Skip Roblox CoreScripts
    if not path:find("PlayerModule") and not path:find("HDAdmin") and not path:find("RbxCharacterSounds") then
        
        -- 1. Dump LocalScripts and ModuleScripts (these are readable)
        if d:IsA("LocalScript") or d:IsA("ModuleScript") then
            count = count + 1
            label.Text = "Dumping: " .. d.Name .. " (" .. count .. ")"
            
            local src = nil
            local ok, raw = pcall(function() return d.Source end)
            if ok and raw and #raw > 0 then src = raw end
            
            if not src and decompile then
                local ok2, dec = pcall(decompile, d)
                if ok2 and dec then src = dec end
            end
            
            if src then
                table.insert(out, string.format("-- ═══════════════════════════════════════\n-- [%s] %s\n-- ═══════════════════════════════════════\n%s\n", d.ClassName, path, src))
            else
                table.insert(out, string.format("-- [%s] %s (decompile failed)\n", d.ClassName, path))
            end
            
        -- 2. Dump Server Scripts (just names, can't read source)
        elseif d:IsA("Script") then
            table.insert(out, string.format("-- [Script - Server Side] %s\n", path))
        end
    end
end

label.Text = "Writing to file..."
task.wait(0.5)

local finalStr = table.concat(out, "\n")

local success, err = pcall(function()
    writefile(filename, finalStr)
end)

if success then
    label.Text = string.format("DONE!\nDumped %d scripts.\nSaved to Workspace/%s", count, filename)
else
    label.Text = "Write failed: " .. tostring(err)
end
