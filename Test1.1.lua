-- LocalScript (executor) — TBSOBR full bytecode decompiler
-- Scans the whole game, decompiles every script via API, copies to clipboard.
-- No 10-minute waits, yields every 5 scripts, no memory OOM.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- CONFIG
local API_URL = "https://medal.bot/api/decompile"
local SCAN_ROOTS = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPlayer"),
}

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
status.Text = "Click to scan and decompile ALL scripts"
status.TextColor3 = ACCENT
status.Font = Enum.Font.GothamBold
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 30)
btn.Position = UDim2.new(0, 10, 1, -40)
btn.BackgroundColor3 = ACCENT
btn.Text = "START DECOMPILE"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

local function getDecompiledSource(scr)
    -- 1. try direct source
    local ok, src = pcall(function() return scr.Source end)
    if ok and src and #src > 0 then return src end

    -- 2. try executor decompile
    if decompile then
        local ok2, dec = pcall(decompile, scr)
        if ok2 and dec then return dec end
    end

    -- 3. try bytecode + API
    if getscriptbytecode and request then
        local ok3, bytecode = pcall(getscriptbytecode, scr)
        if ok3 and bytecode and #bytecode > 0 then
            local ok4, resp = pcall(function()
                return request({
                    Url = API_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/octet-stream" },
                    Body = bytecode,
                })
            end)
            if ok4 and resp and resp.StatusCode == 200 and resp.Body then
                return resp.Body
            end
        end
    end

    return nil
end

btn.MouseButton1Click:Connect(function()
    btn.Visible = false
    status.Text = "Scanning tree..."
    task.wait(0.5)

    local scripts = {}
    for _, root in ipairs(SCAN_ROOTS) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("LuaSourceContainer") then
                    -- skip known useless noise
                    local path = getPath(d)
                    if not path:find("PlayerModule") and not path:find("RbxCharacterSounds") and not path:find("HDAdmin") then
                        table.insert(scripts, d)
                    end
                end
            end
        end
    end

    local results = {}
    local count = 0
    local failed = 0

    for i, scr in ipairs(scripts) do
        count = count + 1
        status.Text = string.format("Decompiling %d / %d...\n%s", i, #scripts, scr.Name)
        task.wait(0.1) -- yield to prevent mobile freeze

        local src = getDecompiledSource(scr)
        local path = getPath(scr)

        if src then
            table.insert(results, string.format("-- ═══════════════════════════════\n-- SCRIPT: %s\n-- CLASS: %s\n-- PATH: %s\n-- ═══════════════════════════════\n\n%s\n\n", scr.Name, scr.ClassName, path, src))
        else
            failed = failed + 1
            table.insert(results, string.format("-- [FAILED TO DECOMPILE] %s (%s)\n", path, scr.ClassName))
        end

        -- flush memory every 20 scripts
        if count % 20 == 0 then
            task.wait(0.5)
        end
    end

    status.Text = "Copying to clipboard..."
    task.wait(0.5)

    local finalStr = table.concat(results, "\n")

    -- safety limit to prevent mobile OOM crash
    if #finalStr > 200000 then
        finalStr = finalStr:sub(1, 200000) .. "\n\n-- [TRUNCATED TO PREVENT CRASH] --"
    end

    if setclipboard then
        local ok, err = pcall(setclipboard, finalStr)
        if ok then
            status.Text = string.format("DONE! %d scripts (%d failed)\nCopied to clipboard. Paste it here.", count, failed)
        else
            status.Text = "clipboard failed: " .. tostring(err)
        end
    else
        status.Text = "no setclipboard available!"
    end

    btn.Text = "SCAN AGAIN"
    btn.Visible = true
end)
