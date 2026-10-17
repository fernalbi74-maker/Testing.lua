-- LocalScript (executor) — decompile to clipboard
-- Grabs game scripts, decompiles via Mod Menu's built-in decompile(),
-- copies to clipboard in chunks so mobile doesn't OOM.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI
local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieClipDecomp"
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
status.Text = "Decompiling and copying..."
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

local scripts = {}
if getscripts then
    scripts = getscripts()
else
    for _, d in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if d:IsA("LuaSourceContainer") then table.insert(scripts, d) end
    end
end

local results = {}
local count = 0

for i, scr in ipairs(scripts) do
    local path = getPath(scr)
    
    -- ONLY game scripts. skip core garbage.
    if not path:find("PlayerModule") and not path:find("HDAdmin") and not path:find("RbxCharacterSounds") then
        count = count + 1
        status.Text = "Decompiling " .. count .. "... " .. scr.Name
        task.wait(0.05)
        
        local src = nil
        if decompile then
            local ok, dec = pcall(decompile, scr)
            if ok and dec then src = dec end
        end
        if not src then
            local ok, raw = pcall(function() return scr.Source end)
            if ok and raw and #raw > 0 then src = raw end
        end
        
        if src then
            table.insert(results, string.format("-- [%s] %s\n%s\n", scr.ClassName, path, src))
        else
            table.insert(results, string.format("-- [%s] %s\n-- (decompile failed)\n", scr.ClassName, path))
        end
    end
end

status.Text = "Copying to clipboard..."
task.wait(0.5)

local fullText = table.concat(results, "\n")

-- mobile OOM protection: cap at 150KB
if #fullText > 150000 then
    fullText = fullText:sub(1, 150000) .. "\n\n-- [TRUNCATED TO PREVENT CRASH] --"
end

if setclipboard then
    local ok, err = pcall(setclipboard, fullText)
    if ok then
        status.Text = "DONE! " .. count .. " scripts copied.\nPaste here."
    else
        status.Text = "clipboard crash: " .. tostring(err)
    end
else
    status.Text = "no setclipboard!"
end
