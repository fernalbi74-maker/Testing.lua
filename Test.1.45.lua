-- LocalScript (executor) — Log all remote calls and their arguments
-- When you attack the boss, this prints exactly what the client sends.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_RemoteLogger"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.4, 0)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 1, -20)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "Waiting for attacks..."
label.TextColor3 = Color3.fromRGB(140, 100, 255)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.TextYAlignment = Enum.TextYAlignment.Top
label.Parent = frame

local logs = {}

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" or method == "InvokeServer" then
            if typeof(self) == "Instance" then
                local args = {...}
                local argStr = ""
                for i, v in ipairs(args) do
                    argStr = argStr .. tostring(v) .. ", "
                end
                local log = string.format("%s: %s(%s)", method, self.Name, argStr)
                table.insert(logs, log)
                
                if #logs > 10 then table.remove(logs, 1) end
                label.Text = table.concat(logs, "\n\n")
            end
        end
        
        return oldNamecall(self, ...)
    end)
    label.Text = "Hook active. Attack the boss."
else
    label.Text = "No hookmetamethod available."
end
