-- LocalScript (executor) — TBSOBR bytecode decompiler
-- Tries Script.Source first, falls back to getscriptbytecode + web API.
-- Pastes decompiled source into a text box.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- CONFIG
local API_URL = "https://medal.bot/api/decompile" -- MedalDecomp public API
local TARGET_ROOT = game:GetService("ReplicatedStorage")
local FILTER = "DefenseUtil" -- change to "BossAttacks" for all boss scripts

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

-- try .Source, fall back to getscriptbytecode
local function getDecompiledSource(scr)
    -- 1. try direct source
    local ok, src = pcall(function() return scr.Source end)
    if ok and src and #src > 0 then
        return src, "Source"
    end

    -- 2. try executor decompile
    if decompile then
        local ok2, dec = pcall(decompile, scr)
        if ok2 and dec then return dec, "decompile()" end
    end

    -- 3. try getscriptbytecode + web API
    if getscriptbytecode and request then
        local ok3, bytecode = pcall(getscriptbytecode, scr)
        if ok3 and bytecode and #bytecode > 0 then
            local ok4, resp = pcall(function()
                return request({
                    Url = API_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "text/plain" },
                    Body = bytecode,
                })
            end)
            if ok4 and resp and resp.StatusCode == 200 and resp.Body then
                return resp.Body, "web decompile"
            end
        end
    end

    return nil, "protected"
end

-- scan and collect
local results = {}
local count = 0

for _, d in ipairs(TARGET_ROOT:GetDescendants()) do
    if d:IsA("LuaSourceContainer") and d.Name:find(FILTER) then
        count = count + 1
        local src, method = getDecompiledSource(d)
        if src then
            table.insert(results, string.format("-- [%s] %s\n-- method: %s\n\n%s\n\n", d.ClassName, getPath(d), method, src))
        else
            table.insert(results, string.format("-- [%s] %s\n-- FAILED: %s\n\n", d.ClassName, getPath(d), method))
        end
    end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.95, 0, 0.85, 0)
frame.Position = UDim2.new(0.025, 0, 0.075, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "decompiled: " .. count .. " scripts (filter: " .. FILTER .. ")"
title.TextColor3 = Color3.fromRGB(140, 100, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 42)
scroll.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, 0, 0, 0)
textBox.BackgroundTransparency = 1
textBox.Text = table.concat(results, "\n")
textBox.TextColor3 = Color3.fromRGB(235, 230, 255)
textBox.Font = Enum.Font.Code
textBox.TextSize = 11
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.TextEditable = false
textBox.Parent = scroll

local function update()
    local h = textBox.TextBounds.Y
    textBox.Size = UDim2.new(1, 0, 0, math.max(h, scroll.AbsoluteSize.Y))
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(h, scroll.AbsoluteSize.Y))
end
textBox:GetPropertyChangedSignal("TextBounds"):Connect(update)
scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
task.spawn(update)
