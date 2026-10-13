local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char) Character = char end)

-- Конфигурация
local Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Accent = Color3.fromRGB(255, 255, 255),
    Inactive = Color3.fromRGB(30, 30, 30),
    Overlay = Color3.fromRGB(0, 0, 0)
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Overlay = Instance.new("Frame", ScreenGui)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundTransparency = 1
Overlay.BackgroundColor3 = Theme.Overlay

local MainPanel = Instance.new("Frame", Overlay)
MainPanel.Size = UDim2.new(0, 400, 0, 350)
MainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
MainPanel.BackgroundColor3 = Theme.Background
MainPanel.Visible = false
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 15)
local Stroke = Instance.new("UIStroke", MainPanel)
Stroke.Color = Theme.Accent
Stroke.Thickness = 1.5

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Position = UDim2.new(0, 20, 1, -60)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.Text = ""
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton", MainPanel)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Theme.Accent
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextSize = 24

local TabContainer = Instance.new("Frame", MainPanel)
TabContainer.Size = UDim2.new(0, 100, 1, -60)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.Padding = UDim.new(0, 5)

local PageContainer = Instance.new("Frame", MainPanel)
PageContainer.Size = UDim2.new(1, -120, 1, -60)
PageContainer.Position = UDim2.new(0, 120, 0, 50)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Name = name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
    Pages[name] = Page
    return Page
end

local function SwitchTab(name)
    for k, v in pairs(Pages) do v.Visible = (k == name) end
end

local function CreateTabButton(name, pageName)
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Text = name
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Theme.Inactive
    Btn.TextColor3 = Theme.Accent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() SwitchTab(pageName) end)
end

local function CreateToggle(text, page, callback)
    local state = false
    local Btn = Instance.new("TextButton", page)
    Btn.Text = "  " .. text .. " [OFF]"
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Theme.Inactive
    Btn.TextColor3 = Theme.Accent
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = "  " .. text .. (state and " [ON]" or " [OFF]")
        Btn.BackgroundColor3 = state and Theme.Accent or Theme.Inactive
        Btn.TextColor3 = state and Color3.fromRGB(0,0,0) or Theme.Accent
        callback(state)
    end)
end

local function CreateAction(text, page, callback)
    local Btn = Instance.new("TextButton", page)
    Btn.Text = "  " .. text
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Theme.Inactive
    Btn.TextColor3 = Theme.Accent
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
end

--------------------------------------------------------------------------------
-- ЛОГИКА (FIXED)
--------------------------------------------------------------------------------

local noclip = false
local flying = false
local flySpeed = 70
local infJump = false

-- NEW FLY: BodyVelocity + Physics State
local function ToggleFly(state)
    flying = state
    local root = Character:FindFirstChild("HumanoidRootPart")
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if flying then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "GGE_FlyBV"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.new(0,0,0)

        local bg = Instance.new("BodyGyro", root)
        bg.Name = "GGE_FlyBG"
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.CFrame = root.CFrame

        task.spawn(function()
            while flying do
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                
                bv.Velocity = moveDir * flySpeed
                bg.CFrame = workspace.CurrentCamera.CFrame
                RunService.Heartbeat:Wait()
            end
            bv:Destroy()
            bg:Destroy()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

-- Infinite Jump Fix
UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if noclip then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Nuclear Kill (Same as before, as we wait for Remote Spy)
local function NuclearKill()
    for _, v in pairs(workspace:GetDescendants()) do
        if v == Character or v:IsDescendantOf(Character) then continue end
        if v:IsA("Humanoid") then v.Health = 0 end
        if v:IsA("Model") and (v.Name:lower():find("zombie") or v.Name:lower():find("npc")) then
            for _, c in pairs(v:GetChildren()) do
                if c.Name:lower():find("head") or c.Name:lower():find("header") then pcall(function() c:Destroy() end) end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- MENU ASSEMBLY
--------------------------------------------------------------------------------

local PlayerPage = CreatePage("Player")
local CombatPage = CreatePage("Combat")
local VisualPage = CreatePage("Visuals")

CreateTabButton("Игрок", "Player")
CreateTabButton("Бой", "Combat")
CreateTabButton("Визуал", "Visuals")

CreateToggle("Полет (Physics Fly)", PlayerPage, ToggleFly)
CreateToggle("Ноуклип", PlayerPage, function(s) noclip = s end)
CreateToggle("Беск. Прыжок", PlayerPage, function(s) infJump = s end)
CreateAction("Скорость x2", PlayerPage, function() Character.Humanoid.WalkSpeed = 32 end)

CreateAction("ЯДЕРНЫЙ KILL ALL", CombatPage, NuclearKill)

CreateToggle("ESP", VisualPage, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name ~= LocalPlayer.Name then
                        if not v:FindFirstChild("GGE_ESP") then
                            Instance.new("Highlight", v).Name = "GGE_ESP"
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

local function OpenMenu()
    Overlay.BackgroundTransparency = 0.5
    MainPanel.Visible = true
    OpenBtn.Visible = false
    SwitchTab("Player")
    TweenService:Create(MainPanel, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 400, 0, 350)}):Play()
end

local function CloseMenu()
    TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(MainPanel, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.3)
    MainPanel.Visible = false
    OpenBtn.Visible = true
end

CloseBtn.MouseButton1Click:Connect(CloseMenu)
OpenBtn.MouseButton1Click:Connect(OpenMenu)
OpenMenu()
