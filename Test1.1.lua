-- LocalScript (executor) — mobile-safe remotes scan
-- Writes each remote to file as it finds it. No table.concat.
-- No clipboard at the end (clipboard of 7k+ lines OOMs Mod Menu).
-- If you want clipboard, we do it in chunks after.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG = Color3.fromRGB(18, 16, 26)

local gui = Instance.new("ScreenGui")
gui.Name = "OllieRemotesMobile"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 500, 0, 80)
label.Position = UDim2.new(0, 30, 0, 30)
label.BackgroundColor3 = BG
label.BackgroundTransparency = 0.1
label.BorderSizePixel = 0
label.Text = "ollie remotes · press Execute"
label.TextColor3 = ACCENT
label.Font = Enum.Font.GothamBold
label.TextSize = 16
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

local SCAN_ROOTS = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
}

local function dump()
    label.Text = "scanning remotes…"
    task.wait()

    -- open file handle once, append lines as we go
    local okFile = pcall(function() writefile("tsob_remotes.txt", "-- TBSOBR remotes scan\n") end)
    if not okFile then
        label.Text = "writefile() not available — executor too limited"
        return
    end

    local count = 0
    local evCount, fnCount = 0, 0

    for _, root in ipairs(SCAN_ROOTS) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                count = count + 1
                if count % 50 == 0 then
                    label.Text = string.format("scanning… %d objects", count)
                    task.wait()
                end

                if d:IsA("RemoteEvent") then
                    evCount = evCount + 1
                    pcall(appendfile, "tsob_remotes.txt", "RE  " .. getPath(d) .. "\n")
                elseif d:IsA("RemoteFunction") then
                    fnCount = fnCount + 1
                    pcall(appendfile, "tsob_remotes.txt", "RF  " .. getPath(d) .. "\n")
                end
            end
        end
    end

    -- footer
    pcall(appendfile, "tsob_remotes.txt",
        string.format("\n-- total: %d events, %d functions\n", evCount, fnCount))

    label.Text = string.format(
        "done · %d events, %d functions\nsaved to tsob_remotes.txt\n(paste it back here)",
        evCount, fnCount
    )
end

dump()
