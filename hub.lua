
-- =============================================
-- MM2 MEGA HUB | ФИНАЛЬНАЯ ВЕРСИЯ (FIX)
-- Красивое меню + выбор цвета
-- Режимы: ПК / Телефон
-- Июнь 2026
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== НАСТРОЙКИ =====
local Settings = {
    Mode = "Phone",
    SilentAim = true,
    ESP = true,
    Wallhop = true,
    NoClip = false,
    Fly = false,
    Speed = 35,
    JumpPower = 80,
    WallhopPower = 40,
    WallhopHeight = 15,
    WallhopDelay = 0.3,
    WallhopCount = 1,
    Crosshair = true,
    FlySpeed = 50,
    FlyKey = Enum.KeyCode.F,
    HubColor = Color3.fromRGB(100, 50, 200)
}

-- ===== ПЕРЕМЕННЫЕ =====
local flying = false
local flyBodyVelocity = nil
local wallhopCooldown = 0
local wallhopJumpsLeft = 0

-- ===== ЦВЕТА =====
local Colors = {
    {Name = "Красный", Color = Color3.fromRGB(200, 30, 30)},
    {Name = "Синий", Color = Color3.fromRGB(30, 80, 255)},
    {Name = "Зелёный", Color = Color3.fromRGB(30, 200, 50)},
    {Name = "Фиолетовый", Color = Color3.fromRGB(150, 50, 255)},
    {Name = "Розовый", Color = Color3.fromRGB(255, 80, 180)},
    {Name = "Оранжевый", Color = Color3.fromRGB(255, 150, 30)},
    {Name = "Белый", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Чёрный", Color = Color3.fromRGB(20, 20, 20)}
}

-- ===== ОПРЕДЕЛЕНИЕ РОЛЕЙ =====
local function GetPlayerRole(player)
    if player == LocalPlayer then return nil end
    local char = player.Character
    if not char then return nil end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Knife" then
            return "Killer"
        end
    end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Gun" then
            return "Sheriff"
        end
    end
    return "Innocent"
end

-- ===== СОЗДАНИЕ GUI (с защитой от ошибок) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ===== ГЛАВНОЕ МЕНЮ =====
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 260, 0, 580)
MainFrame.Position = UDim2.new(0.03, 0, 0.03, 0)
MainFrame.BackgroundColor3 = Settings.HubColor
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🔥 MM2 MEGA HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Settings.HubColor
Title.BackgroundTransparency = 0.3
Title.TextScaled = true

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.Size = UDim2.new(0, 35, 0, 40)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.TextScaled = true
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== ВКЛАДКИ =====
local Tabs = {}
local CurrentTab = "Main"
local TabButtons = {}

local function CreateTabButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.3, 0, 0, 35)
    btn.Position = UDim2.new(0.02 + (y * 0.33), 0, 0.08, 0)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Settings.HubColor
    btn.BackgroundTransparency = 0.4
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        CurrentTab = name
        for _, tab in pairs(Tabs) do
            tab.Visible = false
        end
        for _, btn2 in pairs(TabButtons) do
            btn2.BackgroundTransparency = 0.4
        end
        btn.BackgroundTransparency = 0.1
        Tabs[name].Visible = true
    end)
    table.insert(TabButtons, btn)
    return btn
end

CreateTabButton("Main", 0)
CreateTabButton("Wallhop", 1)
CreateTabButton("Settings", 2)
TabButtons[1].BackgroundTransparency = 0.1

-- ===== ВКЛАДКА MAIN =====
local MainTab = Instance.new("Frame")
MainTab.Parent = MainFrame
MainTab.Size = UDim2.new(1, 0, 1, -55)
MainTab.Position = UDim2.new(0, 0, 0.17, 0)
MainTab.BackgroundTransparency = 1
Tabs["Main"] = MainTab

local function CreateToggle(parent, y, text, settingName)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, y, 0)
    btn.Text = text .. ": ON"
    btn.TextColor3 = Color3.new(0, 1, 0)
    btn.BackgroundColor3 = Settings.HubColor
    btn.BackgroundTransparency = 0.6
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        btn.Text = text .. ": " .. (Settings[settingName] and "ON" or "OFF")
        btn.TextColor3 = Settings[settingName] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        if settingName == "Fly" and not Settings.Fly then
            flying = false
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
        end
        if settingName == "Crosshair" then
            CrosshairFrame.Visible = Settings.Crosshair
        end
    end)
    return btn
end

CreateToggle(MainTab, 0.05, "Silent Aim", "SilentAim")
CreateToggle(MainTab, 0.15, "ESP", "ESP")
CreateToggle(MainTab, 0.25, "NoClip", "NoClip")
CreateToggle(MainTab, 0.35, "Fly", "Fly")
CreateToggle(MainTab, 0.45, "Crosshair", "Crosshair")

-- Speed
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainTab
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 28)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.56, 0)
SpeedLabel.Text = "Speed: " .. Settings.Speed
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BackgroundColor3 = Settings.HubColor
SpeedLabel.BackgroundTransparency = 0.5
SpeedLabel.TextScaled = true

local SpeedSlider = Instance.new("TextBox")
SpeedSlider.Parent = MainTab
SpeedSlider.Size = UDim2.new(0.4, 0, 0, 28)
SpeedSlider.Position = UDim2.new(0.5, 0, 0.56, 0)
SpeedSlider.Text = tostring(Settings.Speed)
SpeedSlider.TextColor3 = Color3.new(1, 1, 1)
SpeedSlider.BackgroundColor3 = Settings.HubColor
SpeedSlider.BackgroundTransparency = 0.5
SpeedSlider.TextScaled = true
SpeedSlider.FocusLost:Connect(function()
    local val = tonumber(SpeedSlider.Text)
    if val then
        Settings.Speed = val
        SpeedLabel.Text = "Speed: " .. val
    end
end)

-- Jump
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Parent = MainTab
JumpLabel.Size = UDim2.new(0.4, 0, 0, 28)
JumpLabel.Position = UDim2.new(0.05, 0, 0.66, 0)
JumpLabel.Text = "Jump: " .. Settings.JumpPower
JumpLabel.TextColor3 = Color3.new(1, 1, 1)
JumpLabel.BackgroundColor3 = Settings.HubColor
JumpLabel.BackgroundTransparency = 0.5
JumpLabel.TextScaled = true

local JumpSlider = Instance.new("TextBox")
JumpSlider.Parent = MainTab
JumpSlider.Size = UDim2.new(0.4, 0, 0, 28)
JumpSlider.Position = UDim2.new(0.5, 0, 0.66, 0)
JumpSlider.Text = tostring(Settings.JumpPower)
JumpSlider.TextColor3 = Color3.new(1, 1, 1)
JumpSlider.BackgroundColor3 = Settings.HubColor
JumpSlider.BackgroundTransparency = 0.5
JumpSlider.TextScaled = true
JumpSlider.FocusLost:Connect(function()
    local val = tonumber(JumpSlider.Text)
    if val then
        Settings.JumpPower = val
        JumpLabel.Text = "Jump: " .. val
    end
end)

-- ===== ВКЛАДКА WALLHOP =====
local WallhopTab = Instance.new("Frame")
WallhopTab.Parent = MainFrame
WallhopTab.Size = UDim2.new(1, 0, 1, -55)
WallhopTab.Position = UDim2.new(0, 0, 0.17, 0)
WallhopTab.BackgroundTransparency = 1
WallhopTab.Visible = false
Tabs["Wallhop"] = WallhopTab

CreateToggle(WallhopTab, 0.02, "Wallhop", "Wallhop")

local function CreateSetting(parent, y, text, settingName)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Size = UDim2.new(0.45, 0, 0, 28)
    label.Position = UDim2.new(0.03, 0, y, 0)
    label.Text = text .. ": " .. Settings[settingName]
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundColor3 = Settings.HubColor
    label.BackgroundTransparency = 0.5
    label.TextScaled = true

    local slider = Instance.new("TextBox")
    slider.Parent = parent
    slider.Size = UDim2.new(0.45, 0, 0, 28)
    slider.Position = UDim2.new(0.52, 0, y, 0)
    slider.Text = tostring(Settings[settingName])
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.BackgroundColor3 = Settings.HubColor
    slider.BackgroundTransparency = 0.5
    slider.TextScaled = true
    slider.FocusLost:Connect(function()
        local val = tonumber(slider.Text)
        if val then
            Settings[settingName] = val
            label.Text = text .. ": " .. val
        end
    end)
    return label, slider
end

CreateSetting(WallhopTab, 0.12, "Power", "WallhopPower")
CreateSetting(WallhopTab, 0.24, "Height", "WallhopHeight")
CreateSetting(WallhopTab, 0.36, "Delay", "WallhopDelay")

-- Количество прыжков
local CountLabel = Instance.new("TextLabel")
CountLabel.Parent = WallhopTab
CountLabel.Size = UDim2.new(0.45, 0, 0, 28)
CountLabel.Position = UDim2.new(0.03, 0, 0.48, 0)
CountLabel.Text = "Jumps: " .. (Settings.WallhopCount == 0 and "∞" or tostring(Settings.WallhopCount))
CountLabel.TextColor3 = Color3.new(1, 1, 1)
CountLabel.BackgroundColor3 = Settings.HubColor
CountLabel.BackgroundTransparency = 0.5
CountLabel.TextScaled = true

local CountSlider = Instance.new("TextBox")
CountSlider.Parent = WallhopTab
CountSlider.Size = UDim2.new(0.3, 0, 0, 28)
CountSlider.Position = UDim2.new(0.52, 0, 0.48, 0)
CountSlider.Text = Settings.WallhopCount == 0 and "∞" or tostring(Settings.WallhopCount)
CountSlider.TextColor3 = Color3.new(1, 1, 1)
CountSlider.BackgroundColor3 = Settings.HubColor
CountSlider.BackgroundTransparency = 0.5
CountSlider.TextScaled = true

local InfiniteButton = Instance.new("TextButton")
InfiniteButton.Parent = WallhopTab
InfiniteButton.Size = UDim2.new(0.12, 0, 0, 28)
InfiniteButton.Position = UDim2.new(0.85, 0, 0.48, 0)
InfiniteButton.Text = "∞"
InfiniteButton.TextColor3 = Color3.new(1, 1, 0)
InfiniteButton.BackgroundColor3 = Settings.HubColor
InfiniteButton.BackgroundTransparency = 0.3
InfiniteButton.TextScaled = true
InfiniteButton.MouseButton1Click:Connect(function()
    Settings.WallhopCount = 0
    CountLabel.Text = "Jumps: ∞"
    CountSlider.Text = "∞"
end)

CountSlider.FocusLost:Connect(function()
    local val = tonumber(CountSlider.Text)
    if val and val >= 1 and val <= 20 then
        Settings.WallhopCount = val
        CountLabel.Text = "Jumps: " .. val
        CountSlider.Text = tostring(val)
    elseif CountSlider.Text == "∞" then
        Settings.WallhopCount = 0
        CountLabel.Text = "Jumps: ∞"
    end
end)

-- ===== ВКЛАДКА SETTINGS =====
local SettingsTab = Instance.new("Frame")
SettingsTab.Parent = MainFrame
SettingsTab.Size = UDim2.new(1, 0, 1, -55)
SettingsTab.Position = UDim2.new(0, 0, 0.17, 0)
SettingsTab.BackgroundTransparency = 1
SettingsTab.Visible = false
Tabs["Settings"] = SettingsTab

-- Режим
local ModeLabel = Instance.new("TextLabel")
ModeLabel.Parent = SettingsTab
ModeLabel.Size = UDim2.new(0.9, 0, 0, 30)
ModeLabel.Position = UDim2.new(0.05, 0, 0.03, 0)
ModeLabel.Text = "Mode: " .. Settings.Mode
ModeLabel.TextColor3 = Color3.new(1, 1, 1)
ModeLabel.BackgroundColor3 = Settings.HubColor
ModeLabel.BackgroundTransparency = 0.4
ModeLabel.TextScaled = true

local PcModeBtn = Instance.new("TextButton")
PcModeBtn.Parent = SettingsTab
PcModeBtn.Size = UDim2.new(0.4, 0, 0, 32)
PcModeBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
PcModeBtn.Text = "💻 PC"
PcModeBtn.TextColor3 = Color3.new(1, 1, 1)
PcModeBtn.BackgroundColor3 = Settings.HubColor
PcModeBtn.BackgroundTransparency = 0.5
PcModeBtn.TextScaled = true
PcModeBtn.MouseButton1Click:Connect(function()
    Settings.Mode = "PC"
    ModeLabel.Text = "Mode: PC"
end)

local PhoneModeBtn = Instance.new("TextButton")
PhoneModeBtn.Parent = SettingsTab
PhoneModeBtn.Size = UDim2.new(0.4, 0, 0, 32)
PhoneModeBtn.Position = UDim2.new(0.55, 0, 0.12, 0)
PhoneModeBtn.Text = "📱 Phone"
PhoneModeBtn.TextColor3 = Color3.new(1, 1, 1)
PhoneModeBtn.BackgroundColor3 = Settings.HubColor
PhoneModeBtn.BackgroundTransparency = 0.5
PhoneModeBtn.TextScaled = true
PhoneModeBtn.MouseButton1Click:Connect(function()
    Settings.Mode = "Phone"
    ModeLabel.Text = "Mode: Phone"
end)

-- Выбор цвета
local ColorLabel = Instance.new("TextLabel")
ColorLabel.Parent = SettingsTab
ColorLabel.Size = UDim2.new(0.9, 0, 0, 30)
ColorLabel.Position = UDim2.new(0.05, 0, 0.22, 0)
ColorLabel.Text = "🎨 Выбери цвет хаба:"
ColorLabel.TextColor3 = Color3.new(1, 1, 1)
ColorLabel.BackgroundColor3 = Settings.HubColor
ColorLabel.BackgroundTransparency = 0.4
ColorLabel.TextScaled = true

local function CreateColorButton(parent, x, y, colorData)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0.2, 0, 0, 30)
    btn.Position = UDim2.new(x, 0, y, 0)
    btn.Text = colorData.Name
    btn.TextColor3 = colorData.Color
    btn.BackgroundColor3 = colorData.Color
    btn.BackgroundTransparency = 0.5
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        Settings.HubColor = colorData.Color
        MainFrame.BackgroundColor3 = colorData.Color
        Title.BackgroundColor3 = colorData.Color
        for _, btn2 in pairs(TabButtons) do
            btn2.BackgroundColor3 = colorData.Color
        end
        for _, child in pairs(MainFrame:GetDescendants()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                if child ~= Title and child ~= CloseButton then
                    child.BackgroundColor3 = colorData.Color
                end
            end
        end
        ColorLabel.Text = "🎨 Выбери цвет хаба: " .. colorData.Name
    end)
    return btn
end

CreateColorButton(SettingsTab, 0.02, 0.30, Colors[1])
CreateColorButton(SettingsTab, 0.24, 0.30, Colors[2])
CreateColorButton(SettingsTab, 0.46, 0.30, Colors[3])
CreateColorButton(SettingsTab, 0.68, 0.30, Colors[4])
CreateColorButton(SettingsTab, 0.02, 0.42, Colors[5])
CreateColorButton(SettingsTab, 0.24, 0.42, Colors[6])
CreateColorButton(SettingsTab, 0.46, 0.42, Colors[7])
CreateColorButton(SettingsTab, 0.68, 0.42, Colors[8])

-- ===== RGB-ПРИЦЕЛ =====
local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Parent = ScreenGui
CrosshairFrame.Size = UDim2.new(0, 50, 0, 50)
CrosshairFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = Settings.Crosshair

local OuterRing = Instance.new("ImageLabel")
OuterRing.Parent = CrosshairFrame
OuterRing.Size = UDim2.new(1, 0, 1, 0)
OuterRing.Position = UDim2.new(0, 0, 0, 0)
OuterRing.BackgroundTransparency = 1
OuterRing.Image = "rbxassetid://10942395483"
OuterRing.ImageColor3 = Color3.new(1, 1, 1)
OuterRing.ImageTransparency = 0.2

local CenterDot = Instance.new("ImageLabel")
CenterDot.Parent = CrosshairFrame
CenterDot.Size = UDim2.new(0, 10, 0, 10)
CenterDot.Position = UDim2.new(0.5, -5, 0.5, -5)
CenterDot.BackgroundTransparency = 1
CenterDot.Image = "rbxassetid://10942395483"
CenterDot.ImageColor3 = Color3.new(1, 1, 1)

spawn(function()
    local hue = 0
    while CrosshairFrame and CrosshairFrame.Parent do
        hue = (hue + 0.003) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        OuterRing.ImageColor3 = color
        CenterDot.ImageColor3 = color
        CrosshairFrame.Rotation = (CrosshairFrame.Rotation or 0) + 0.15
        wait(0.02)
    end
end)

-- ===== ESP =====
if Settings.ESP then
    local function AddESP(player)
        if player == LocalPlayer then return end
        player.CharacterAdded:Connect(function(char)
            wait(0.5)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = part
                    highlight.FillTransparency = 0.3
                    spawn(function()
                        while highlight and highlight.Parent do
                            local role = GetPlayerRole(player)
                            if role == "Killer" then
                                highlight.FillColor = Color3.new(1, 0, 0)
                            elseif role == "Sheriff" then
                                highlight.FillColor = Color3.new(0, 0, 1)
                            else
                                highlight.FillColor = Color3.new(0, 1, 0)
                            end
                            wait(1)
                        end
                    end)
                end
            end
        end)
    end

    for _, player in pairs(Players:GetPlayers()) do
        AddESP(player)
    end
    Players.PlayerAdded:Connect(AddESP)
end

-- ===== SILENT AIM =====
if Settings.SilentAim then
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hasGun = false
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Gun" then
                hasGun = true
                break
            end
        end
        if not hasGun then return end

        local target = nil
        local dist = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if GetPlayerRole(player) == "Killer" then
                    local root = player.Character.HumanoidRootPart
                    local distance = (root.Position - char.HumanoidRootPart.Position).Magnitude
                    if distance < 120 and distance < dist then
                        target = player
                        dist = distance
                    end
                end
            end
        end

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local cam = workspace.CurrentCamera
            if cam then
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end)
end

-- ===== SPEED + JUMP =====
local function ApplySpeedAndJump()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = Settings.Speed
    humanoid.JumpPower = Settings.JumpPower
end

RunService.RenderStepped:Connect(ApplySpeedAndJump)
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    ApplySpeedAndJump()
end)

-- ===== WALLHOP =====
if Settings.Wallhop then
    RunService.Heartbeat:Connect(function(delta)
        wallhopCooldown = math.max(0, wallhopCooldown - delta)
        if wallhopCooldown > 0 then return end

        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end

        if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {char}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local cam = workspace.CurrentCamera
            if not cam then return end
            
            local direction = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
            local ray = workspace:Raycast(root.Position, direction * 5, raycastParams)

            if ray then
                if wallhopJumpsLeft == 0 then
                    wallhopJumpsLeft = Settings.WallhopCount == 0 and 999 or Settings.WallhopCount
