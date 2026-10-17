-- LocalScript (executor) — labeled dumper
-- Each script gets: [CLASS] path  |  inferred purpose
-- Purpose guessed from name, parent, and source keywords.
-- Output is chunked, clipboard-exported, never freezes the client.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)
local TEXT = Color3.fromRGB(235, 230, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieDumpV2"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 380, 0, 56)
label.Position = UDim2.new(0, 24, 0, 24)
label.BackgroundColor3 = BG
label.BackgroundTransparency = 0.1
label.BorderSizePixel = 0
label.Text = "ollie dumper v2 · press Execute"
label.TextColor3 = ACCENT
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextWrapped = true
label.Parent = gui

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 8)
c.Parent = label

-- ── purpose heuristic ─────────────────────────────────────────
-- name/parent first, source keywords second. No false confidence:
-- if nothing matches, label stays "general".
local PURPOSE_RULES = {
    { match = "ControlModule",          tag = "player movement / walk controller" },
    { match = "CameraModule",           tag = "camera control" },
    { match = "ClickToMove",            tag = "click-to-move pathfinding" },
    { match = "Pathfinding",            tag = "pathfinding / navigation" },
    { match = "PlayerModule",           tag = "player controller bundle" },
    { match = "Animate",                tag = "character animation" },
    { match = "Health",                 tag = "health / damage display" },
    { match = "Sound",                  tag = "audio" },
    { match = "Chat",                   tag = "chat system" },
    { match = "Leaderboard",            tag = "leaderboard" },
    { match = "Inventory",              tag = "inventory" },
    { match = "Shop",                   tag = "shop / store" },
    { match = "Quest",                  tag = "quest system" },
    { match = "Tower",                  tag = "tower / defense logic (TBSOBR)" },
    { match = "Wave",                   tag = "wave spawner" },
    { match = "Enemy",                  tag = "enemy logic" },
    { match = "Remote",                 tag = "remote event handler" },
    { match = "DataStore",              tag = "data persistence" },
    { match = "Save",                   tag = "save / load" },
    { match = "AntiCheat",              tag = "anti-cheat / detection" },
    { match = "Anti",                   tag = "anti-* (cheat/exploit guard)" },
    { match = "Admin",                  tag = "admin commands" },
    { match = "Gui",                    tag = "gui" },
    { match = "UI",                     tag = "ui" },
    { match = "Notification",           tag = "notifications" },
    { match = "Tween",                  tag = "tweening / transitions" },
    { match = "Util",                   tag = "utility helpers" },
    { match = "Common",                 tag = "shared utilities" },
    { match = "Config",                 tag = "config / constants" },
    { match = "Module",                 tag = "module (required by others)" },
}

local KEYWORD_RULES = {
    { keyword = "FireServer",           tag = "fires remote → server (exploitable surface)" },
    { keyword = "InvokeServer",         tag = "invokes remote → server (exploitable surface)" },
    { keyword = "Humanoid",             tag = "character / humanoid" },
    { keyword = "Tower",                tag = "tower logic" },
    { keyword = "Wave",                 tag = "wave / round" },
    { keyword = "Damage",               tag = "damage calc" },
    { keyword = "Coins",                tag = "currency" },
    { keyword = "Cash",                 tag = "currency" },
    { keyword = "Gems",                 tag = "currency" },
    { keyword = "Level",                tag = "level / xp" },
    { keyword = "AntiCheat",            tag = "anti-cheat" },
    { keyword = "Kick",                 tag = "moderation / kick" },
    { keyword = "Ban",                  tag = "moderation / ban" },
    { keyword = "HTTP",                 tag = "http request" },
    { keyword = "Marketplace",          tag = "marketplace" },
}

local function inferPurpose(scr, src)
    local hay = (scr.Name or "") .. " " .. (scr:GetFullName() or "")
    for _, r in ipairs(PURPOSE_RULES) do
        if hay:find(r.match) then return r.tag end
    end
    for _, r in ipairs(KEYWORD_RULES) do
        if src:find(r.keyword) then return r.tag end
    end
    return "general / unlabeled"
end

-- ── helpers ───────────────────────────────────────────────────
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
    local ok, src = pcall(function()
        if scr:IsA("LocalScript") or scr:IsA("Script") or scr:IsA("ModuleScript") then
            return scr.Source
        end
        return nil
    end)
    if ok and src and #src > 0 then return src end
    if decompile then
        local ok2, dec = pcall(decompile, scr)
        if ok2 and dec then return dec end
    end
    return ""
end

-- ── main dump ─────────────────────────────────────────────────
local function dump()
    label.Text = "scanning…"
    task.wait()

    local scripts
    local ok = pcall(function()
        if getscripts then
            scripts = getscripts()
        else
            scripts = {}
            for _, name in ipairs({"ReplicatedStorage", "StarterGui", "StarterPack", "Workspace", "Lighting"}) do
                local svc = game:FindService(name)
                if svc then
                    for _, d in ipairs(svc:GetDescendants()) do
                        if d:IsA("LuaSourceContainer") then table.insert(scripts, d) end
                    end
                end
            end
        end
    end)

    if not ok or not scripts then
        label.Text = "getscripts() failed"
        return
    end

    -- build a compact summary first
    local summary = {}
    local bodies = {}
    local counts = {}

    for i, scr in ipairs(scripts) do
        if i % 8 == 0 then
            label.Text = string.format("scanning… %d / %d", i, #scripts)
            task.wait()
        end

        local path = getPath(scr)
        local cls = scr.ClassName
        local src = safeSource(scr)
        local purpose = inferPurpose(scr, src)

        counts[purpose] = (counts[purpose] or 0) + 1

        table.insert(summary, string.format("[%s] %s  —  %s  (%d chars)",
            cls, path, purpose, #src))

        table.insert(bodies, string.format("-- ═══════════════════════════════════════════════════════════\n-- %s\n-- class: %s\n-- purpose: %s\n-- path: %s\n-- chars: %d\n-- ═══════════════════════════════════════════════════════════\n%s\n",
            scr.Name, cls, purpose, path, #src, src))
    end

    -- header
    local out = {}
    table.insert(out, "-- ollie dump v2 | " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC")
    table.insert(out, "-- place: " .. tostring(game.PlaceId))
    table.insert(out, "-- total scripts: " .. tostring(#scripts))
    table.insert(out, "")
    table.insert(out, "-- ── PURPOSE SUMMARY ──")
    for purpose, n in pairs(counts) do
        table.insert(out, string.format("--   %-50s %d", purpose, n))
    end
    table.insert(out, "")
    table.insert(out, "-- ── INDEX ──")
    for _, line in ipairs(summary) do
        table.insert(out, "--   " .. line)
    end
    table.insert(out, "")
    table.insert(out, "-- ── SOURCE ──")
    table.insert(out, table.concat(bodies, "\n"))

    local full = table.concat(out, "\n")
    local kb = math.floor(#full / 1024)

    if setclipboard then
        pcall(setclipboard, full)
        label.Text = string.format("done · %d scripts · %d KB → clipboard\n(index first, source after)", #scripts, kb)
    elseif writefile then
        local ok2 = pcall(writefile, "ollie_dump_v2.txt", full)
        label.Text = ok2 and ("done · saved ollie_dump_v2.txt · " .. kb .. " KB")
            or "done · writefile failed"
    else
        print(full)
        label.Text = "done · printed to console"
    end
end

dump()
