-- LocalScript (executor) — lag-free dumper
-- Uses getscripts() instead of recursive :GetDescendants()
-- pcall every read, chunked loop with task.wait, no GUI freeze

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)
local TEXT = Color3.fromRGB(235, 230, 255)

-- tiny status label, non-blocking
local gui = Instance.new("ScreenGui")
gui.Name = "OllieDump"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 340, 0, 40)
label.Position = UDim2.new(0, 24, 0, 24)
label.BackgroundColor3 = BG
label.BackgroundTransparency = 0.1
label.BorderSizePixel = 0
label.Text = "ollie dumper · press Execute to scan"
label.TextColor3 = ACCENT
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextWrapped = true
label.Parent = gui

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 8)
c.Parent = label

-- helpers
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
    -- fallback to executor decompiler if available
    if decompile then
        local ok2, dec = pcall(decompile, scr)
        if ok2 and dec then return dec end
    end
    return "--[[ source unavailable ]]"
end

-- main dump — chunked, yields every 8 scripts
local function dump()
    label.Text = "scanning…"
    task.wait()

    local scripts
    local ok = pcall(function()
        if getscripts then
            scripts = getscripts()
        else
            -- fallback: manual walk but only services likely to hold scripts
            scripts = {}
            local services = { "ReplicatedStorage", "StarterGui", "StarterPack", "Workspace", "Lighting" }
            for _, name in ipairs(services) do
                local svc = game:FindService(name)
                if svc then
                    for _, d in ipairs(svc:GetDescendants()) do
                        if d:IsA("LuaSourceContainer") then
                            table.insert(scripts, d)
                        end
                    end
                end
            end
        end
    end)

    if not ok or not scripts then
        label.Text = "getscripts() failed — executor too limited"
        return
    end

    local out = {}
    table.insert(out, "-- ollie dump | " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC")
    table.insert(out, "-- place: " .. tostring(game.PlaceId))
    table.insert(out, "-- scripts: " .. tostring(#scripts))
    table.insert(out, "")

    for i, scr in ipairs(scripts) do
        if i % 8 == 0 then
            label.Text = string.format("scanning… %d / %d", i, #scripts)
            task.wait() -- yield so client doesn't freeze
        end

        local path = getPath(scr)
        local class = scr.ClassName
        local src = safeSource(scr)

        table.insert(out, string.format("-- %s [%s]", path, class))
        table.insert(out, src)
        table.insert(out, "")
    end

    local full = table.concat(out, "\n")
    local size = #full

    -- prefer clipboard, then file
    if setclipboard then
        pcall(setclipboard, full)
        label.Text = string.format("done · %d scripts · %d KB copied to clipboard", #scripts, math.floor(size / 1024))
    elseif writefile then
        local ok2 = pcall(writefile, "ollie_dump.txt", full)
        label.Text = ok2 and ("done · saved to ollie_dump.txt") or "done · no clipboard, no writefile"
    else
        label.Text = "done · no clipboard/writefile — use console"
        print(full)
    end
end

dump()
