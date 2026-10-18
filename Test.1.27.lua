-- LocalScript (executor) — Chunked Full Dump
-- Dumps everything, splits into 10 chunks, copies one at a time.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Chunk"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.2, 0)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 40)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "Preparing dump..."
label.TextColor3 = Color3.fromRGB(140, 100, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 12
label.TextWrapped = true
label.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 60)
btn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
btn.Text = "Load Chunk"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

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

local out = {}
local count = 0
local totalChars = 0

for _, d in ipairs(game:GetDescendants()) do
    local path = getPath(d)
    if not path:find("PlayerModule") and not path:find("HDAdmin") then
        if d:IsA("LocalScript") or d:IsA("ModuleScript") then
            count = count + 1
            if count % 20 == 0 then
                label.Text = "Scanning: " .. count
                task.wait(0.05)
            end
            
            local src = nil
            local ok, raw = pcall(function() return d.Source end)
            if ok and raw and #raw > 0 then src = raw end
            if not src and decompile then
                local ok2, dec = pcall(decompile, d)
                if ok2 and dec then src = dec end
            end
            
            local str = string.format("-- [%s] %s\n%s\n", d.ClassName, path, src or "(failed)")
            table.insert(out, str)
            totalChars = totalChars + #str
        elseif d:IsA("Script") then
            local str = string.format("-- [Script] %s\n", path)
            table.insert(out, str)
            totalChars = totalChars + #str
        end
    end
end

local fullText = table.concat(out, "\n")
label.Text = "Dumped " .. count .. " scripts (" .. math.floor(#fullText/1024) .. " KB)"
btn.Visible = false

-- split into 120KB chunks
local chunkSize = 120000
local chunks = {}
for i = 1, #fullText, chunkSize do
    table.insert(chunks, fullText:sub(i, i + chunkSize - 1))
end

local currentChunk = 1
local btnChunk = Instance.new("TextButton")
btnChunk.Size = UDim2.new(1, -20, 0, 40)
btnChunk.Position = UDim2.new(0, 10, 0, 60)
btnChunk.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
btnChunk.Text = "Copy Chunk 1 / " .. #chunks
btnChunk.TextColor3 = Color3.fromRGB(20, 16, 30)
btnChunk.Font = Enum.Font.GothamBold
btnChunk.Parent = frame
Instance.new("UICorner", btnChunk).CornerRadius = UDim.new(0, 6)

btnChunk.MouseButton1Click:Connect(function()
    if currentChunk > #chunks then
        btnChunk.Text = "All chunks copied!"
        return
    end
    
    local data = chunks[currentChunk]
    if setclipboard then
        local ok = pcall(setclipboard, data)
        if ok then
            label.Text = "Copied chunk " .. currentChunk .. "! Paste it in chat."
            currentChunk = currentChunk + 1
            if currentChunk <= #chunks then
                btnChunk.Text = "Copy Chunk " .. currentChunk .. " / " .. #chunks
            else
                btnChunk.Text = "Done"
            end
        else
            label.Text = "Clipboard failed on chunk " .. currentChunk
        end
    end
end)
