-- LocalScript (executor) — Visible Health Tracker + Safe Boss Decompiler
-- Puts tracebacks on the screen so you don't need console.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Tracker"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.2, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.BorderSizePixel = 0
label.Text = "Tracking..."
label.TextColor3 = Color3.fromRGB(255, 100, 100)
label.Font = Enum.Font.Code
label.TextSize = 12
label.TextWrapped = true
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

local function showTrace(reason, trace)
    label.Text = reason .. "\n" .. (trace or "no trace")
    if setclipboard then
        pcall(setclipboard, reason .. "\n" .. (trace or ""))
    end
end

local function hookChar(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    hum.HealthChanged:Connect(function(hp)
        if hp < hum.MaxHealth and hp > 0 and not hum:GetAttribute("NoHeal") then
            hum:SetAttribute("NoHeal", true)
            
            local trace = debug.traceback()
            showTrace("Health dropped to " .. math.floor(hp), trace)
            
            task.wait(0.1)
            hum.Health = hum.MaxHealth
            hum:SetAttribute("NoHeal", nil)
        end
    end)
    
    hum.Died:Connect(function()
        showTrace("DIED", debug.traceback())
    end)
end

if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookChar)

-- Boss Decompiler (safe mode)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0.1, 0)
btn.Position = UDim2.new(0.05, 0, 0.3, 0)
btn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
btn.Text = "Decompile BossAttacks"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    btn.Text = "Working..."
    local results = {}
    local root = game:GetService("ReplicatedStorage"):FindFirstChild("BossAttacks")
    
    if root then
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("Script") and d.Name ~= "Animate" and d.Name ~= "TouchDamage" then
                local ok, dec = pcall(function()
                    if decompile then return decompile(d) end
                    return d.Source
                end)
                if ok and dec then
                    table.insert(results, string.format("-- [%s] %s\n%s\n", d.ClassName, d:GetFullName(), dec))
                end
            end
        end
        
        local str = table.concat(results, "\n")
        if #str > 0 then
            if #str > 150000 then str = str:sub(1, 150000) .. "\n-- TRUNCATED" end
            setclipboard(str)
            btn.Text = "Copied to clipboard! (" .. math.floor(#str/1024) .. "KB)"
        else
            btn.Text = "No scripts decompiled."
        end
    else
        btn.Text = "No BossAttacks folder."
    end
end)
