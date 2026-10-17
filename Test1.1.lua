-- LocalScript (executor) — decompile EVERY script using getscripts()
-- Writes line by line to decompiled_all.txt so it never OOMs.
-- Relies on executor decompile() since it works on your Mod Menu.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local filename = "TBSOBR_ALL_SCRIPTS.txt"

-- GUI
local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieDecompiler"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.15, 0)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 1, -20)
status.Position = UDim2.new(0, 10, 0, 10)
status.BackgroundTransparency = 1
status.Text = "Waiting..."
status.TextColor3 = ACCENT
status.Font = Enum.Font.GothamBold
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

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

-- initialize file
pcall(function()
    writefile(filename, "-- TBSOBR ALL SCRIPTS\n\n")
end)

status.Text = "Grabbing scripts via getscripts()..."
task.wait(0.5)

local scripts = {}
if getscripts then
    scripts = getscripts()
else
    -- fallback if executor is weird
    for _, d in ipairs(game:GetDescendants()) do
        if d:IsA("LuaSourceContainer") then table.insert(scripts, d) end
    end
end

status.Text = "Found " .. #scripts .. " scripts. Decompiling..."

for i, scr in ipairs(scripts) do
    if i % 5 == 0 then
        status.Text = string.format("Decompiling %d / %d...\n%s", i, #scripts, scr.Name)
        task.wait(0.1)
    end
    
    local path = getPath(scr)
    local src = nil
    
    -- skip core noise
    if not path:find("PlayerModule") and not path:find("HDAdmin") and not path:find("RbxCharacterSounds") then
        -- try decompile() first (works on Mod Menu)
        if decompile then
            local ok, dec = pcall(decompile, scr)
            if ok and dec then src = dec end
        end
        
        -- fallback to Source
        if not src then
            local ok, raw = pcall(function() return scr.Source end)
            if ok and raw and #raw > 0 then src = raw end
        end
        
        -- write to file
        if src then
            local text = string.format("-- ═══════════════════════════════\n-- SCRIPT: %s\n-- CLASS: %s\n-- PATH: %s\n-- ═══════════════════════════════\n\n%s\n\n", scr.Name, scr.ClassName, path, src)
            pcall(appendfile, filename, text)
        else
            pcall(appendfile, filename, string.format("-- [FAILED] %s (%s)\n\n", path, scr.ClassName))
        end
    end
end

status.Text = "Done! Saved to Workspace/" .. filename
