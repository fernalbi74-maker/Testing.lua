-- LocalScript (executor) — Direct memory dump viewer
-- Dumps scripts straight into the GUI textbox, no files needed.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Viewer"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.95, 0, 0.85, 0)
frame.Position = UDim2.new(0.025, 0, 0.075, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "Dumping to memory..."
title.TextColor3 = Color3.fromRGB(140, 100, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -100)
scroll.Position = UDim2.new(0, 10, 0, 36)
scroll.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, 0, 0, 0)
textBox.BackgroundTransparency = 1
textBox.TextColor3 = Color3.fromRGB(235, 230, 255)
textBox.Font = Enum.Font.Code
textBox.TextSize = 11
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.TextEditable = false
textBox.Text = ""
textBox.Parent = scroll

local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, -20, 0, 40)
btnFrame.Position = UDim2.new(0, 10, 1, -50)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, 0, 1, 0)
copyBtn.Position = UDim2.new(0, 0, 0, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
copyBtn.Text = "Copy All (First 150KB)"
copyBtn.TextColor3 = Color3.fromRGB(20, 16, 30)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = btnFrame
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

task.wait(0.5)

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
table.insert(out, "-- TBSOBR GLOBAL DUMP\n")

local count = 0
for _, d in ipairs(game:GetDescendants()) do
    local path = getPath(d)
    if not path:find("PlayerModule") and not path:find("HDAdmin") and not path:find("RbxCharacterSounds") then
        if d:IsA("LocalScript") or d:IsA("ModuleScript") then
            count = count + 1
            if count % 50 == 0 then
                title.Text = "Dumping... " .. count
                task.wait(0.05) -- yield so UI doesn't freeze
            end
            
            local src = nil
            local ok, raw = pcall(function() return d.Source end)
            if ok and raw and #raw > 0 then src = raw end
            if not src and decompile then
                local ok2, dec = pcall(decompile, d)
                if ok2 and dec then src = dec end
            end
            
            if src then
                table.insert(out, string.format("-- [%s] %s\n%s\n", d.ClassName, path, src))
            else
                table.insert(out, string.format("-- [%s] %s (failed)\n", d.ClassName, path))
            end
        elseif d:IsA("Script") then
            table.insert(out, string.format("-- [Script] %s\n", path))
        end
    end
end

title.Text = "Dumped " .. count .. " scripts."
task.wait(0.5)

local fullStr = table.concat(out, "\n")

-- Render in textbox (cap at 200KB so mobile doesn't crash)
local displayStr = fullStr
if #displayStr > 200000 then
    displayStr = displayStr:sub(1, 200000) .. "\n\n-- [TRUNCATED AT 200KB -- COPY TO GET THIS PART] --"
end

textBox.Text = displayStr

local function updateCanvas()
    textBox.Size = UDim2.new(1, 0, 0, math.max(textBox.TextBounds.Y, scroll.AbsoluteSize.Y))
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(textBox.TextBounds.Y, scroll.AbsoluteSize.Y))
end
textBox:GetPropertyChangedSignal("TextBounds"):Connect(updateCanvas)
task.spawn(updateCanvas)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        -- cap clipboard at 150KB to prevent OOM
        local copyStr = fullStr
        if #copyStr > 150000 then copyStr = copyStr:sub(1, 150000) .. "\n-- TRUNCATED" end
        local success = pcall(setclipboard, copyStr)
        if success then
            copyBtn.Text = "Copied! Paste in chat."
        else
            copyBtn.Text = "Clipboard failed."
        end
    end
end)
