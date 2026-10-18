-- LocalScript (executor) — Only readable Client Scripts
-- Skips Workspace, Lighting, CorePackages, and Server Scripts.
-- Only targets LocalScript and ModuleScript.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_ReadableDump"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.1, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Scanning for readable code..."
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

local function scan(container)
    for _, d in ipairs(container:GetDescendants()) do
        -- ONLY LocalScripts and ModuleScripts have readable source on the client
        if d:IsA("LocalScript") or d:IsA("ModuleScript") then
            local path = getPath(d)
            
            -- Skip Roblox core libraries
            if not path:find("CorePackages") and not path:find("PlayerModule") and not path:find("HDAdmin") and not path:find("RbxCharacterSounds") then
                count = count + 1
                label.Text = "Reading: " .. d.Name .. " (" .. count .. ")"
                task.wait(0.05)
                
                local src = nil
                local ok, raw = pcall(function() return d.Source end)
                if ok and raw and #raw > 0 then src = raw end
                if not src and decompile then
                    local ok2, dec = pcall(decompile, d)
                    if ok2 and dec then src = dec end
                end
                
                if src then
                    table.insert(out, string.format("-- [%s] %s\n%s\n", d.ClassName, path, src))
                end
            end
        end
    end
end

-- Scan only game areas
scan(game:GetService("ReplicatedStorage"))
scan(game:GetService("ReplicatedFirst"))
scan(game:GetService("StarterGui"))
scan(game:GetService("StarterPack"))
scan(game:GetService("StarterPlayer"))

-- Also scan our own PlayerScripts (client-side logic)
if LocalPlayer:FindFirstChild("PlayerScripts") then
    scan(LocalPlayer.PlayerScripts)
end

label.Text = "Found " .. count .. " readable scripts. Copying..."
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
