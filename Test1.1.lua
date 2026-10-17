-- LocalScript (executor) — remotes only, no source reads
-- No decompile, no Workspace walk, no full-source clipboard.
-- Just: list every RemoteEvent / RemoteFunction and what parent holds it.
-- Nothing here touches Source, so anti-cheat heuristics stay quiet.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)
local TEXT = Color3.fromRGB(235, 230, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieRemotes"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 460, 0, 70)
label.Position = UDim2.new(0, 24, 0, 24)
label.BackgroundColor3 = BG
label.BackgroundTransparency = 0.1
label.BorderSizePixel = 0
label.Text = "ollie remotes scan · press Execute"
label.TextColor3 = ACCENT
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextWrapped = true
label.Parent = gui
Instance.new("UICorner", gui).CornerRadius = UDim.new(0, 8)

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return "game." .. table.concat(parts, ".")
end

-- scan only these services — no Workspace walk
local SCAN_ROOTS = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
}

local function dump()
    label.Text = "scanning remotes…"
    task.wait()

    local events, functions = {}, {}

    for _, root in ipairs(SCAN_ROOTS) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    table.insert(events, getPath(d))
                elseif d:IsA("RemoteFunction") then
                    table.insert(functions, getPath(d))
                end
            end
        end
    end

    table.sort(events)
    table.sort(functions)

    local out = {}
    table.insert(out, "-- TBSOBR remotes | place " .. tostring(game.PlaceId))
    table.insert(out, "-- generated " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC")
    table.insert(out, "")
    table.insert(out, string.format("-- RemoteEvents (%d)", #events))
    for _, e in ipairs(events) do
        table.insert(out, "RE  " .. e)
    end
    table.insert(out, "")
    table.insert(out, string.format("-- RemoteFunctions (%d)", #functions))
    for _, f in ipairs(functions) do
        table.insert(out, "RF  " .. f)
    end

    local full = table.concat(out, "\n")
    local kb = math.floor(#full / 1024)

    if setclipboard then
        pcall(setclipboard, full)
        label.Text = string.format("done · %d events + %d functions · %d KB → clipboard\npaste this — it's small",
            #events, #functions, kb)
    elseif writefile then
        pcall(writefile, "tsob_remotes.txt", full)
        label.Text = "done · saved tsob_remotes.txt"
    else
        print(full)
        label.Text = "done · printed to console"
    end
end

dump()
