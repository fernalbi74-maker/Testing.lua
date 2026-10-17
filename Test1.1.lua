-- LocalScript (executor) — direct clipboard dump
-- Scans only game scripts, skips the noise, copies to clipboard.
-- No files, no GUI reading, just straight to the clipboard.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "OllieClip"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0.1, 0)
status.Position = UDim2.new(0.05, 0, 0.05, 0)
status.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
status.BorderSizePixel = 0
status.Text = "scanning game scripts..."
status.TextColor3 = Color3.fromRGB(140, 100, 255)
status.Font = Enum.Font.GothamBold
status.TextSize = 14
status.TextWrapped = true
status.Parent = gui
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 8)

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

-- Only game servers and storage. No Workspace (lags), no PlayerScripts (noise).
local SCAN_ROOTS = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
}

local out = {}
table.insert(out, "-- TBSOBR GAME SCRIPTS --\n")

local count = 0
for _, root in ipairs(SCAN_ROOTS) do
    if root then
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("LuaSourceContainer") then
                local path = getPath(d)
                
                -- Skip core junk
                if not path:find("HDAdmin") and not path:find("PlayerModule") then
                    count = count + 1
                    if count % 20 == 0 then
                        status.Text = "found " .. count .. " scripts..."
                        task.wait()
                    end

                    table.insert(out, "\n[" .. d.ClassName .. "] " .. path)
                    
                    local okSrc, src = pcall(function() return d.Source end)
                    if okSrc and src and #src > 0 then
                        table.insert(out, "--- SOURCE START ---")
                        table.insert(out, src)
                        table.insert(out, "--- SOURCE END ---")
                    else
                        table.insert(out, "-- (no source readable)")
                    end
                end
            end
        end
    end
end

status.Text = "copying to clipboard..."
task.wait(0.5)

local finalStr = table.concat(out, "\n")

-- safety check: if too big, cut it to prevent executor crash
if #finalStr > 150000 then
    status.Text = "WARNING: Too big ("..math.floor(#finalStr/1024).."KB). Copying first 150KB only."
    finalStr = finalStr:sub(1, 150000) .. "\n\n-- [TRUNCATED TO PREVENT CRASH] --"
    task.wait(2)
end

if setclipboard then
    local ok, err = pcall(function()
        setclipboard(finalStr)
    end)
    if ok then
        status.Text = "DONE! Copied " .. count .. " scripts.\nPaste here."
    else
        status.Text = "clipboard failed: " .. tostring(err)
    end
else
    status.Text = "executor has no setclipboard!"
end
