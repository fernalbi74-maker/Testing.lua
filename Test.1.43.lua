-- LocalScript (executor) — Sandbox for the obfuscated script
-- Hooks FireServer, InvokeServer, and Kick to see what the script does.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Sandbox"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.3, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Interceptor Active. Run the admin script."
label.TextColor3 = Color3.fromRGB(255, 100, 100)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.TextYAlignment = Enum.TextYAlignment.Top
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

local logs = {}

-- Hook Namecall to log remotes and block Kick
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        -- Block Kick attempts
        if method == "Kick" and self == LocalPlayer then
            table.insert(logs, "BLOCKED KICK ATTEMPT!")
            label.Text = table.concat(logs, "\n")
            return nil
        end
        
        -- Log Remote calls
        if method == "FireServer" or method == "InvokeServer" then
            if typeof(self) == "Instance" then
                local args = {...}
                local argStr = ""
                for i, v in ipairs(args) do
                    argStr = argStr .. tostring(v) .. ", "
                end
                local log = string.format("%s: %s(%s)", method, self:GetFullName(), argStr)
                table.insert(logs, log)
                
                -- Keep log readable
                if #logs > 15 then table.remove(logs, 1) end
                label.Text = table.concat(logs, "\n")
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Hook kick function directly
if hookfunction then
    local oldKick = LocalPlayer.Kick
    hookfunction(LocalPlayer.Kick, function(self, reason)
        table.insert(logs, "BLOCKED KICK: " .. tostring(reason))
        label.Text = table.concat(logs, "\n")
        return nil
    end)
end
