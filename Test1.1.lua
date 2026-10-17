-- LocalScript (executor) — full tree + script dump to file
-- Writes to Workspace/TBSOBR_DUMP.txt (executor folder).
-- Appends line by line so it doesn't crash on mobile.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local filename = "TBSOBR_DUMP.txt"

-- GUI forced to the absolute top layer
local gui = Instance.new("ScreenGui")
gui.Name = "OllieDump"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.9, 0, 0.15, 0)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.BorderSizePixel = 0
frame.Parent = gui

local c = Instance.new("UICorner", frame)
c.CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 1, -20)
status.Position = UDim2.new(0, 10, 0, 10)
status.BackgroundTransparency = 1
status.Text = "scanning..."
status.TextColor3 = Color3.fromRGB(140, 100, 255)
status.Font = Enum.Font.GothamBold
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

task.wait(1) -- let GUI render before scan freezes

-- file init
local ok, err = pcall(function()
    writefile(filename, "-- TBSOBR FULL DUMP\n-- Place: " .. tostring(game.PlaceId) .. "\n\n")
end)

if not ok then
    status.Text = "writefile failed: " .. tostring(err)
    return
end

local count = 0
local function dump(inst, depth)
    for _, child in ipairs(inst:GetChildren()) do
        if child.Name == "CoreGui" or child.Name == "CorePackages" then
            -- skip
        else
            count = count + 1
            if count % 20 == 0 then
                status.Text = "scanning... " .. count .. " objects"
                task.wait() -- yield to prevent mobile crash
            end
            
            local indent = string.rep("  ", depth)
            local line = indent .. "[" .. child.ClassName .. "] " .. child.Name .. "\n"
            pcall(appendfile, filename, line)
            
            if child:IsA("LuaSourceContainer") then
                local okSrc, src = pcall(function() return child.Source end)
                if okSrc and src and #src > 0 then
                    pcall(appendfile, filename, indent .. "  --- SOURCE START ---\n" .. src .. "\n" .. indent .. "  --- SOURCE END ---\n")
                end
            end
            
            dump(child, depth + 1)
        end
    end
end

dump(game, 0)

status.Text = "done · " .. count .. " objects\nSaved to Workspace/" .. filename
