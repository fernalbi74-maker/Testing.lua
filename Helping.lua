-- Remote Spy for Mobile
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "REMOTE SPY (Hit Zombie now!)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 4

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)

local function Log(text)
    local Label = Instance.new("TextLabel", Scroll)
    Label.Size = UDim2.new(1, 0, 0, 40)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(0, 255, 0)
    Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Label.TextWrapped = true
    Label.Font = Enum.Font.Code
    Label.TextSize = 12
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

-- Перехват FireServer
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" then
        local argString = ""
        for i, v in pairs(args) do
            argString = argString .. tostring(v) .. (i < #args and ", " or "")
        end
        Log("Remote: " .. self:GetFullName() .. "\nArgs: " .. argString)
    end
    return oldNamecall(self, ...)
end

setreadonly(mt, true)
