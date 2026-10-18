-- LocalScript (executor) — Clean Game Script Dump
-- Skips all CorePackages, only dumps game scripts.
-- Copies to clipboard.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_CleanDump"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Scanning game scripts..."
label.TextColor3 = Color3.fromRGB(140, 100, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

task.wait(1)

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
local count = 0

for _, d in ipairs(game:GetDescendants()) do
    local path = getPath(d)
    
    -- HARD FILTER: Skip CorePackages and Roblox internal stuff
    if not path:find("CorePackages") and not path:find("PlayerModule") and not path:find("HDAdmin") and not path:find("RbxCharacterSounds") then
        
        if d:IsA("LocalScript") or d:IsA("ModuleScript") then
            count = count + 1
            if count % 10 == 0 then
                label.Text = "Reading: " .. d.Name
                task.wait(0.05)
            end
            
            local src = nil
            local ok, raw = pcall(function() return d.Source end)
            if ok and raw and #raw > 0 then src = raw end
            if not src and decompile then
                local ok2, dec = pcall(decompile, d)
                if ok2 and dec then src = dec end
            end
            
            if src then
                table.insert(out, string.format("-- [%s] %s\n%s\n", d.ClassName, path, src))
            else
                table.insert(out, string.format("-- [%s] %s (no source)\n", d.ClassName, path))
            end
            
        elseif d:IsA("Script") then
            -- Server scripts only get their path dumped
            table.insert(out, string.format("-- [Script] %s\n", path))
        end
    end
end

label.Text = "Found " .. count .. " scripts. Copying..."
task.wait(0.5)

local fullStr = table.concat(out, "\n")
if #fullStr > 150000 then fullStr = fullStr:sub(1, 150000) .. "\n-- TRUNCATED" end

if setclipboard then
    local ok = pcall(setclipboard, fullStr)
    if ok then
        label.Text = "Copied " .. count .. " scripts!\nPaste in chat."
    else
        label.Text = "Clipboard failed."
    end
end
