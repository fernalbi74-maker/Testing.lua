-- LocalScript (executor) — TBSOBR targeted scan
-- Skips all CoreScripts / PlayerModule / character sounds noise.
-- Only game-authored remotes, modules, and server scripts.
-- Small output, clipboard-exported, labeled by purpose.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)
local TEXT = Color3.fromRGB(235, 230, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieTBSOBR"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 420, 0, 60)
label.Position = UDim2.new(0, 24, 0, 24)
label.BackgroundColor3 = BG
label.BackgroundTransparency = 0.1
label.BorderSizePixel = 0
label.Text = "ollie TBSOBR scan · press Execute"
label.TextColor3 = ACCENT
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextWrapped = true
label.Parent = gui
Instance.new("UICorner", gui).CornerRadius = UDim.new(0, 8)

-- noise filter: anything under these prefixes is Roblox Core, not game
local NOISE_PREFIXES = {
    "Players.fernalki15.PlayerScripts.PlayerModule",
    "Players.fernalki15.PlayerScripts.RbxCharacterSounds",
    "Players.fernalki15.PlayerScripts.ChatScript",
    "Players.fernalki15.PlayerScripts.Chunk",
    "Players.fernalki15.PlayerGui.TouchGui",
    "Players.fernalki15.PlayerGui.ScreenGui",
    "Players.fernalki15.PlayerGui.Shiftlock",
    "Players.fernalki15.PlayerGui.HDAdmin",
    "Players.fernalki15.PlayerScripts.E666Screenshake",
    "ReplicatedStorage.HDAdmin",
    "ReplicatedStorage.Roblox",
    "StarterGui.PlayerModule",
    "StarterGui.ScreenGui",
}

local function isNoise(fullname)
    for _, p in ipairs(NOISE_PREFIXES) do
        if fullname:sub(1, #p) == p then return true end
    end
    return false
end

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

local function safeSource(scr)
    local ok, src = pcall(function() return scr.Source end)
    if ok and src and #src > 0 then return src end
    if decompile then
        local ok2, dec = pcall(decompile, scr)
        if ok2 and dec then return dec end
    end
    return ""
end

-- look for remote-calling patterns in source
local REMOTE_PATTERNS = {
    { pat = ":FireServer%(",   kind = "FireServer" },
    { pat = ":InvokeServer%(", kind = "InvokeServer" },
    { pat = ":FireAllClients%(", kind = "FireAllClients" },
}

local function extractRemotes(src)
    local hits = {}
    for _, r in ipairs(REMOTE_PATTERNS) do
        for line in src:gmatch("[^\n]+") do
            if line:find(r.pat) then
                table.insert(hits, r.kind .. " → " .. line:gsub("^%s+", ""):sub(1, 100))
            end
        end
    end
    return hits
end

-- scan only game-authored locations, not core
local SCAN_ROOTS = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("Workspace"),
}

local function dump()
    label.Text = "scanning game scripts…"
    task.wait()

    local found = {}
    local remoteIndex = {}  -- remote name -> {calledBy}

    for _, root in ipairs(SCAN_ROOTS) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("LuaSourceContainer") then
                    local full = getPath(d):gsub("^game%.", "")
                    if not isNoise(full) then
                        table.insert(found, d)
                    end
                elseif d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                    remoteIndex[getPath(d)] = {}
                end
            end
        end
    end

    -- also enumerate remotes directly
    local remoteList = {}
    for path, _ in pairs(remoteIndex) do
        table.insert(remoteList, path)
    end
    table.sort(remoteList)

    local out = {}
    table.insert(out, "-- TBSOBR targeted dump | " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC")
    table.insert(out, "-- place: " .. tostring(game.PlaceId) .. "  |  game scripts: " .. #found)
    table.insert(out, "")

    table.insert(out, "-- ═══════════ REMOTES (" .. #remoteList .. ") ═══════════")
    for _, r in ipairs(remoteList) do
        table.insert(out, "--   " .. r)
    end
    table.insert(out, "")

    table.insert(out, "-- ═══════════ GAME SCRIPTS (" .. #found .. ") ═══════════")
    for i, scr in ipairs(found) do
        if i % 5 == 0 then
            label.Text = string.format("scanning… %d / %d", i, #found)
            task.wait()
        end

        local src = safeSource(scr)
        local remotes = extractRemotes(src)
        local path = getPath(scr)

        table.insert(out, "")
        table.insert(out, string.rep("═", 60))
        table.insert(out, "-- [" .. scr.ClassName .. "] " .. path)
        if #remotes > 0 then
            table.insert(out, "-- REMOTE CALLS:")
            for _, r in ipairs(remotes) do
                table.insert(out, "--   " .. r)
            end
        end
        table.insert(out, string.rep("═", 60))
        table.insert(out, src)
    end

    local full = table.concat(out, "\n")
    local kb = math.floor(#full / 1024)

    if setclipboard then
        pcall(setclipboard, full)
        label.Text = string.format("done · %d scripts + %d remotes · %d KB → clipboard",
            #found, #remoteList, kb)
    elseif writefile then
        pcall(writefile, "tsob_dump.txt", full)
        label.Text = "done · saved tsob_dump.txt · " .. kb .. " KB"
    else
        print(full)
        label.Text = "done · printed to console"
    end
end

-- also print remotes live to console immediately (even if scripts fail)
for _, root in ipairs(SCAN_ROOTS) do
    if root then
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                print("[REMOTE] " .. d.ClassName .. " " .. getPath(d))
            end
        end
    end
end

dump()
