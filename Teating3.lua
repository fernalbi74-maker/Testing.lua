-- Stealth Remote Spy v2.0
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 300)
Main.Position = UDim2.new(0.5, -150, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Text = "STEALTH SPY (Testing...)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 2

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 3)

local function Log(text)
    local Label = Instance.new("TextLabel", Scroll)
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(0, 255, 0)
    Label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Label.TextWrapped = true
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

-- Стелс-перехват через hookmetamethod
local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", function(self, args)
    local method = getnamecallmethod()
    if method == "FireServer" and self:IsA("RemoteEvent") then
        local argString = ""
        for i, v in pairs(args) do
            argString = argString .. tostring(v) .. (i < #args and ", " or "")
        end
        Log("Remote: " .. self.Name .. "\nArgs: " .. argString)
    end
    return oldNameCall(self, args)
end)
