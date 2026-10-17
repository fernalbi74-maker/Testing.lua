-- LocalScript (executor) — Tool & Remote Dumper
-- Scans StarterPack, Backpack, and PlayerGui for scripts that fire remotes.
-- Copies to clipboard.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "OllieToolDump"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.15, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Scanning Tools & PlayerGui..."
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

local function scan(obj)
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("LocalScript") or d:IsA("Script") then
            local path = getPath(d)
            local src = nil
            if decompile then
                local ok, dec = pcall(decompile, d)
                if ok and dec then src = dec end
            end
            if not src then
                local ok, raw = pcall(function() return d.Source end)
                if ok and raw and #raw > 0 then src = raw end
            end
            
            if src and (src:find("FireServer") or src:find("InvokeServer")) then
                count = count + 1
                label.Text = "Found remote: " .. d.Name
                task.wait(0.1)
                table.insert(results, string.format("-- [%s] %s\n%s\n", d.ClassName, path, src))
            end
        end
    end
end

-- scan tools and gui
if LocalPlayer:FindFirstChild("Backpack") then scan(LocalPlayer.Backpack) end
if LocalPlayer:FindFirstChild("PlayerGui") then scan(LocalPlayer.PlayerGui) end
if game:GetService("StarterPack") then scan(game:GetService("StarterPack")) end

label.Text = "Done! Found " .. count .. " scripts."
task.wait(1)

local fullText = table.concat(results, "\n")
if #fullText > 150000 then
    fullText = fullText:sub(1, 150000) .. "\n-- TRUNCATED"
end

if setclipboard then
    pcall(setclipboard, fullText)
    label.Text = "Copied " .. count .. " scripts!\nPaste in chat."
else
    label.Text = "No clipboard."
end
