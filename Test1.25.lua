-- LocalScript (executor) — In-game dump viewer
-- Shows the dump in a textbox and gives a button to save it.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local filename = "TBSOBR_FULL_DUMP.txt"

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
title.Text = "TBSOBR Dump Viewer"
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
textBox.Text = "Loading..."
textBox.Parent = scroll

local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, -20, 0, 40)
btnFrame.Position = UDim2.new(0, 10, 1, -50)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = frame

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.5, -10, 1, 0)
saveBtn.Position = UDim2.new(0, 0, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
saveBtn.Text = "Save File"
saveBtn.TextColor3 = Color3.fromRGB(20, 16, 30)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = btnFrame
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.5, -10, 1, 0)
copyBtn.Position = UDim2.new(0.5, 10, 0, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(32, 28, 46)
copyBtn.Text = "Copy All"
copyBtn.TextColor3 = Color3.fromRGB(235, 230, 255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = btnFrame
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

task.wait(1)

local success, content = pcall(function()
    return readfile(filename)
end)

if not success or not content then
    textBox.Text = "Could not read " .. filename .. "\nRun the dumper first."
    saveBtn.Visible = false
    copyBtn.Visible = false
    return
end

-- Mobile safe: truncate to 200KB so the textbox doesn't crash
local displayContent = content
if #displayContent > 200000 then
    displayContent = displayContent:sub(1, 200000) .. "\n\n-- [TRUNCATED TO PREVENT LAG. SAVE FILE FOR FULL VERSION] --"
end

textBox.Text = displayContent

local function updateCanvas()
    textBox.Size = UDim2.new(1, 0, 0, math.max(textBox.TextBounds.Y, scroll.AbsoluteSize.Y))
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(textBox.TextBounds.Y, scroll.AbsoluteSize.Y))
end

textBox:GetPropertyChangedSignal("TextBounds"):Connect(updateCanvas)
scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
task.spawn(updateCanvas)

saveBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        writefile("TBSOBR_DUMP_EXPORT.txt", content)
    end)
    if success then
        saveBtn.Text = "Saved to Workspace!"
    else
        saveBtn.Text = "Save failed."
    end
end)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        local success = pcall(setclipboard, displayContent)
        if success then
            copyBtn.Text = "Copied!"
        else
            copyBtn.Text = "Too big to copy."
        end
    end
end)
