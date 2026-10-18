-- LocalScript (executor) — Bytecode Decompiler
-- Pulls bytecode from server scripts and decompiles via Medal API.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local API_URL = "https://medal.bot/api/decompile"

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_BytecodeDump"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.15, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Scanning for bytecode..."
label.TextColor3 = Color3.fromRGB(255, 100, 100)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
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

local function getDecompiled(scr)
    -- Try getscriptbytecode
    if getscriptbytecode and request then
        local ok, bytecode = pcall(getscriptbytecode, scr)
        if ok and bytecode and #bytecode > 0 then
            local ok2, resp = pcall(function()
                return request({
                    Url = API_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/octet-stream" },
                    Body = bytecode,
                })
            end)
            if ok2 and resp and resp.StatusCode == 200 then
                return resp.Body
            else
                return "-- API failed (Status: " .. tostring(resp and resp.StatusCode) .. ")"
            end
        end
    end
    return nil
end

-- Look for the boss scripts
local targets = {}
local pathsToSearch = {
    "Workspace.Characters.Sans.Head.STATS",
    "Workspace.Characters.Sans.Head.ATTACKS",
    "Workspace.Characters.Sans.Head.TP",
    "Workspace.Characters.Goop sans.Head.STATS",
    "Workspace.the sp.fdsjhnf sahjdspawn.DONT EDIT",
    "ReplicatedFirst.SoulKiller.Script",
}

for _, p in ipairs(pathsToSearch) do
    local obj = game
    for part in p:gmatch("[^.]+") do
        obj = obj:FindFirstChild(part)
        if not obj then break end
    end
    if obj and (obj:IsA("Script") or obj:IsA("LocalScript")) then
        table.insert(targets, obj)
    end
end

local out = {}
local count = 0

for i, scr in ipairs(targets) do
    label.Text = "Decompiling " .. scr.Name .. " (" .. i .. "/" .. #targets .. ")"
    task.wait(0.5)
    
    local src = getDecompiled(scr)
    if src then
        table.insert(out, string.format("-- [%s] %s\n%s\n", scr.ClassName, getPath(scr), src))
        count = count + 1
    else
        table.insert(out, string.format("-- [%s] %s (bytecode failed)\n", scr.ClassName, getPath(scr)))
    end
end

label.Text = "Copied " .. count .. " scripts."
if setclipboard then
    pcall(setclipboard, table.concat(out, "\n"))
end
