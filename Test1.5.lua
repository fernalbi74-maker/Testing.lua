-- LocalScript (executor) — Find what is killing you
-- Prints the exact script/remote that sets your health to 0.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0.2, 0)
label.Position = UDim2.new(0.05, 0, 0.05, 0)
label.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
label.Text = "Tracking Health drops..."
label.TextColor3 = Color3.fromRGB(255, 100, 100)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextWrapped = true
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

local function hookChar(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    hum.HealthChanged:Connect(function(hp)
        if hp < hum.MaxHealth and hp > 0 then
            -- if we drop health, trace it
            local trace = debug.traceback()
            print("=== HEALTH DROP ===")
            print("New Health: " .. hp)
            print(trace)
            label.Text = "Health dropped to " .. hp .. "!\nCheck console for traceback."
            
            -- heal back up
            hum.Health = hum.MaxHealth
        elseif hp <= 0 then
            print("=== DEATH ===")
            print(debug.traceback())
        end
    end)
end

if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookChar)

-- Also dump the BossAttacks scripts from ReplicatedStorage
task.spawn(function()
    task.wait(2)
    local results = {}
    local root = game:GetService("ReplicatedStorage"):FindFirstChild("BossAttacks")
    if root then
        label.Text = "Decompiling BossAttacks..."
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("LuaSourceContainer") and d.Name ~= "Animate" then
                if decompile then
                    local ok, dec = pcall(decompile, d)
                    if ok and dec then
                        table.insert(results, string.format("-- [%s] %s\n%s\n", d.ClassName, d:GetFullName(), dec))
                    end
                end
                task.wait(0.1)
            end
        end
        if #results > 0 then
            local str = table.concat(results, "\n")
            if #str > 150000 then str = str:sub(1, 150000) .. "\n-- TRUNCATED" end
            setclipboard(str)
            label.Text = "Boss scripts copied to clipboard!\nPaste in Discord."
        else
            label.Text = "Could not decompile boss scripts."
        end
    else
        label.Text = "No BossAttacks folder found."
    end
end)
