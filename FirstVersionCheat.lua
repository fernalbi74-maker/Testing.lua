-- GGE REMOTE SPY v1.0
-- Перехватывает все вызовы FireServer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local LogBox = Instance.new("ScrollingFrame", ScreenGui)
LogBox.Size = UDim2.new(0, 400, 0, 300)
LogBox.Position = UDim2.new(0, 10, 0, 10)
LogBox.BackgroundColor3 = Color3.fromRGB(0,0,0)
LogBox.CanvasSize = UDim2.new(0,0,10,0)

local UIList = Instance.new("UIListLayout", LogBox)

local function Log(text)
    local label = Instance.new("TextLabel", LogBox)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.BackgroundColor3 = Color3.fromRGB(30,30,30)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 10
end

local oldFireServer
oldFireServer = hookmetamethod(game, "__namecall", function(self, method, ...)
    local args = {...}
    if method == "FireServer" and self:IsA("RemoteEvent") then
        local argString = ""
        for i, v in pairs(args) do
            argString = argString .. tostring(v) .. (i < #args and ", " or "")
        end
        Log("REMOTE: " .. self:GetFullName() .. " | ARGS: " .. argString)
    end
    return oldFireServer(self, method, ...)
end)

print("Remote Spy Active: Hit someone to see the signal!")
