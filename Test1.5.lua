-- LocalScript (executor) — Dump Damage/Kill scripts
-- Scans for scripts with "Damage", "Kill", "Death", "Touch" in the name or source.
-- Copies everything to clipboard.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "OllieDamageDump"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.15, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Scanning for damage scripts..."
label.TextColor3 = Color3.fromRGB(255, 100, 100)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextWrapped = true
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

task.wait(1)

local results = {}
local count = 0

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

for _, d in ipairs(game:GetDescendants()) do
    if d:IsA("LuaSourceContainer") then
        local path = getPath(d)
        local name = d.Name:lower()
        
        -- Skip core junk
        if not path:find("PlayerModule") and not path:find("HDAdmin") and not path:find("RbxCharacterSounds") then
            local isDamage = false
            
            if name:find("damage") or name:find("kill") or name:find("death") or name:find("touch") or name:find("hit") then
                isDamage = true
            end
            
            local src = nil
            if decompile then
                local ok, dec = pcall(decompile, d)
                if ok and dec then src = dec end
            end
            
            if not src then
                local ok, raw = pcall(function() return d.Source end)
                if ok and raw and #raw > 0 then src = raw end
            end
            
            if src then
                if src:find("Health = 0") or src:find("TakeDamage") or src:find("Humanoid.Health") then
                    isDamage = true
                end
                
                if isDamage then
                    count = count + 1
                    label.Text = "Found " .. count .. ": " .. d.Name
                    task.wait(0.1)
                    table.insert(results, string.format("-- [%s] %s\n%s\n", d.ClassName, path, src))
                end
            end
        end
    end
end

label.Text = "Done! Found " .. count .. " scripts."
task.wait(1)

local fullText = table.concat(results, "\n")
if #fullText > 150000 then
    fullText = fullText:sub(1, 150000) .. "\n-- TRUNCATED"
end

if setclipboard then
    pcall(setclipboard, fullText)
    label.Text = "Copied " .. count .. " scripts to clipboard!\nPaste in chat."
else
    label.Text = "No clipboard."
end
