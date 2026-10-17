-- LocalScript (executor) — fast script + remote dump
-- No full tree walk. Only Scripts, LocalScripts, ModuleScripts, Remotes.
-- No 1-minute waits. Batches into memory and writes once per 100 items.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local filename = "TBSOBR_DUMP.txt"

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OllieFastDump"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.1, 0)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.BorderSizePixel = 0
frame.Parent = gui

local c = Instance.new("UICorner", frame)
c.CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 1, -20)
status.Position = UDim2.new(0, 10, 0, 10)
status.BackgroundTransparency = 1
status.Text = "scanning..."
status.TextColor3 = Color3.fromRGB(140, 100, 255)
status.Font = Enum.Font.GothamBold
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

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

-- Only scan these game areas
local SCAN_ROOTS = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("Workspace"),
}

local out = {}
table.insert(out, "-- TBSOBR FAST DUMP | Place: " .. tostring(game.PlaceId) .. "\n\n")

local count = 0
for _, root in ipairs(SCAN_ROOTS) do
    if root then
        for _, d in ipairs(root:GetDescendants()) do
            local isScript = d:IsA("LuaSourceContainer")
            local isRemote = d:IsA("RemoteEvent") or d:IsA("RemoteFunction")
            
            if isScript or isRemote then
                count = count + 1
                if count % 100 == 0 then
                    status.Text = "found " .. count .. " items..."
                    task.wait()
                end

                local path = getPath(d)
                
                -- Skip CoreScripts
                if not path:find("PlayerScripts.PlayerModule") 
                and not path:find("RbxCharacterSounds")
                and not path:find("ChatScript")
                and not path:find("HDAdmin") 
                and not path:find("TouchGui") then
                    
                    table.insert(out, "[" .. d.ClassName .. "] " .. path)
                    
                    if isScript then
                        local okSrc, src = pcall(function() return d.Source end)
                        if okSrc and src and #src > 0 then
                            table.insert(out, "--- SOURCE START ---")
                            table.insert(out, src)
                            table.insert(out, "--- SOURCE END ---\n")
                        end
                    end
                end
            end
        end
    end
end

status.Text = "writing " .. count .. " items..."
task.wait()

local finalStr = table.concat(out, "\n")
local ok, err = pcall(function()
    writefile(filename, finalStr)
end)

if ok then
    status.Text = "done! " .. count .. " items saved to " .. filename
else
    status.Text = "write failed: " .. tostring(err)
end
