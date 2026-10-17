-- LocalScript (executor) — read dump back into a textbox
-- Opens the file we just made and loads it into a scrolling textbox.
-- You can select, copy, or read it directly on screen.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local filename = "TBSOBR_DUMP.txt"

-- read the file we generated
local success, content = pcall(function()
    return readfile(filename)
end)

if not success or not content then
    local errGui = Instance.new("ScreenGui")
    errGui.ResetOnSpawn = false
    errGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local errLbl = Instance.new("TextLabel")
    errLbl.Size = UDim2.new(0.8, 0, 0.2, 0)
    errLbl.Position = UDim2.new(0.1, 0, 0.4, 0)
    errLbl.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    errLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    errLbl.Text = "Could not read " .. filename .. "\nMake sure you ran the dump script first!"
    errLbl.Font = Enum.Font.GothamBold
    errLbl.TextSize = 16
    errLbl.TextWrapped = true
    errLbl.Parent = errGui
    return
end

-- build GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OllieReadDump"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.95, 0, 0.9, 0)
frame.Position = UDim2.new(0.025, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "TBSOBR_DUMP.txt (" .. math.floor(#content / 1024) .. " KB)"
title.TextColor3 = Color3.fromRGB(140, 100, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, -20, 0, 30)
btnFrame.Position = UDim2.new(0, 10, 0, 36)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 120, 1, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
copyBtn.Text = "Copy All"
copyBtn.TextColor3 = Color3.fromRGB(20, 16, 30)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 13
copyBtn.Parent = btnFrame
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -80)
scroll.Position = UDim2.new(0, 10, 0, 72)
scroll.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = Color3.fromRGB(140, 100, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, 0, 0, 0) -- height adjusts
textBox.BackgroundTransparency = 1
textBox.Text = content
textBox.TextColor3 = Color3.fromRGB(235, 230, 255)
textBox.Font = Enum.Font.Code
textBox.TextSize = 12
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.TextEditable = false
textBox.Parent = scroll

local function updateCanvas()
    local textHeight = textBox.TextBounds.Y
    textBox.Size = UDim2.new(1, 0, 0, math.max(textHeight, scroll.AbsoluteSize.Y))
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight, scroll.AbsoluteSize.Y))
end

textBox:GetPropertyChangedSignal("TextBounds"):Connect(updateCanvas)
scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
task.spawn(updateCanvas)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        local ok, err = pcall(function()
            setclipboard(content)
        end)
        if ok then
            copyBtn.Text = "Copied!"
            task.wait(1.5)
            copyBtn.Text = "Copy All"
        else
            copyBtn.Text = "Clipboard too big"
            task.wait(1.5)
            copyBtn.Text = "Copy All"
        end
    else
        copyBtn.Text = "No clipboard"
        task.wait(1.5)
        copyBtn.Text = "Copy All"
    end
end)
