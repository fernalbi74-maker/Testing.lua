-- LocalScript (executor) — Dump only Remotes
-- Gets every RemoteEvent and RemoteFunction name and path.
-- Skips scripts, no decompile, instant clipboard.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "OllieRemotes"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.15, 0)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 1, -20)
status.Position = UDim2.new(0, 10, 0, 10)
status.BackgroundTransparency = 1
status.Text = "Scanning for remotes..."
status.TextColor3 = Color3.fromRGB(140, 100, 255)
status.Font = Enum.Font.GothamBold
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

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

local remotes = {}

-- get everything in game, filter for remotes
for _, d in ipairs(game:GetDescendants()) do
    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("UnreliableRemoteEvent") then
        table.insert(remotes, string.format("[%s] %s", d.ClassName, getPath(d)))
    end
end

table.sort(remotes)
local out = table.concat(remotes, "\n")

if setclipboard then
    pcall(setclipboard, out)
    status.Text = string.format("Done! Found %d remotes.\nCopied to clipboard.", #remotes)
else
    status.Text = "No setclipboard!"
end
