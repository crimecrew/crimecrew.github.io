local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Настройки
local espCache = {}
local settings = {
    enabled = true,
    showNames = true,
    showDistance = true,
    showHealth = true,
    showWeapon = true,
    showBox = true,
    teamCheck = false,
    maxDistance = 1000,
    color = Color3.fromRGB(0, 255, 0),
    wallColor = Color3.fromRGB(255, 0, 0),
    textSize = 13
}

local aimbotSettings = {
    enabled = false,
    fov = 100,
    smoothness = 10,
    teamCheck = true,
    fovVisible = true,
    fovColor = Color3.fromRGB(255, 255, 255),
    aimPart = "Head"
}

local playerSettings = {
    walkSpeed = 16,
    jumpPower = 50,
    noclip = false,
    fly = false,
    infiniteJump = false
}

local gunSettings = {
    noRecoil = false,
    rapidFire = false,
    fireRateMultiplier = 5,
    infiniteAmmo = false
}

-- Создание GUI
local menu = Instance.new("ScreenGui")
menu.Name = "Cobalt_Menu"
menu.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = menu
mainFrame.Visible = false

-- Drag functionality
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
header.BorderSizePixel = 0
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "COBALT.WIN"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = header

-- Tabs
local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, 0, 0, 40)
tabs.Position = UDim2.new(0, 0, 0, 35)
tabs.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabs.BorderSizePixel = 0
tabs.Parent = mainFrame

local tabNames = {"MAIN", "VISUALS", "AIMBOT", "PLAYER", "GUN"}
local tabFrames = {}

for i, tabName in ipairs(tabNames) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1/#tabNames, 0, 1, 0)
    tabBtn.Position = UDim2.new((i-1)/#tabNames, 0, 0, 0)
    tabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(25, 25, 35)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = tabs
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1, 0, 1, -75)
    tabFrame.Position = UDim2.new(0, 0, 0, 75)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = i == 1
    tabFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
    tabFrame.ScrollBarThickness = 4
    tabFrame.Parent = mainFrame
    
    tabFrames[tabName] = tabFrame
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, frame in pairs(tabFrames) do
            frame.Visible = false
        end
        tabFrame.Visible = true
        
        for _, btn in ipairs(tabs:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            end
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    end)
end

-- Content
local function createSection(parent, titleText, yPosition)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 30)
    section.Position = UDim2.new(0, 10, 0, yPosition)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(180, 180, 220)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    return section
end

local function createToggle(parent, text, yPos, settingTable, settingKey)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -20, 0, 25)
    toggle.Position = UDim2.new(0, 10, 0, yPos)
    toggle.BackgroundTransparency = 1
    toggle.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.3, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0.7, 0, 0, 0)
    toggleBtn.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(80, 80, 100)
    toggleBtn.Text = settingTable[settingKey] and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = toggle
    
    toggleBtn.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        toggleBtn.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(80, 80, 100)
        toggleBtn.Text = settingTable[settingKey] and "ON" or "OFF"
    end)
    
    return toggle
end

local function createSlider(parent, text, yPos, settingTable, settingKey, min, max)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 40)
    sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. settingTable[settingKey]
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 6)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.BorderSizePixel = 0
    slider.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local relativeX = math.clamp((mousePos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                settingTable[settingKey] = math.floor(min + relativeX * (max - min))
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                label.Text = text .. ": " .. settingTable[settingKey]
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    return sliderFrame
end

-- MAIN TAB
local mainY = 10
createSection(tabFrames.MAIN, "INFORMATION", mainY); mainY = mainY + 35

local devLabel = Instance.new("TextLabel")
devLabel.Size = UDim2.new(1, -20, 0, 25)
devLabel.Position = UDim2.new(0, 10, 0, mainY)
devLabel.BackgroundTransparency = 1
devLabel.Text = "Developer: Cobalt.win"
devLabel.TextColor3 = Color3.fromRGB(200, 200, 240)
devLabel.TextSize = 12
devLabel.Font = Enum.Font.Gotham
devLabel.TextXAlignment = Enum.TextXAlignment.Left
devLabel.Parent = tabFrames.MAIN
mainY = mainY + 30

local discordLabel = Instance.new("TextLabel")
discordLabel.Size = UDim2.new(1, -20, 0, 25)
discordLabel.Position = UDim2.new(0, 10, 0, mainY)
discordLabel.BackgroundTransparency = 1
discordLabel.Text = "Discord: discord.gg/cobalt"
discordLabel.TextColor3 = Color3.fromRGB(200, 200, 240)
discordLabel.TextSize = 12
discordLabel.Font = Enum.Font.Gotham
discordLabel.TextXAlignment = Enum.TextXAlignment.Left
discordLabel.Parent = tabFrames.MAIN
mainY = mainY + 40

local unhookBtn = Instance.new("TextButton")
unhookBtn.Size = UDim2.new(1, -20, 0, 35)
unhookBtn.Position = UDim2.new(0, 10, 0, mainY)
unhookBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
unhookBtn.Text = "UNHOOK"
unhookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unhookBtn.TextSize = 14
unhookBtn.Font = Enum.Font.GothamBold
unhookBtn.BorderSizePixel = 0
unhookBtn.Parent = tabFrames.MAIN

unhookBtn.MouseButton1Click:Connect(function()
    menu:Destroy()
    for _, player in pairs(espCache) do
        if player.highlight then player.highlight:Destroy() end
        if player.billboard then player.billboard:Destroy() end
    end
    espCache = {}
end)

-- VISUALS TAB
local visY = 10
createSection(tabFrames.VISUALS, "ESP SETTINGS", visY); visY = visY + 35

visY = visY + createToggle(tabFrames.VISUALS, "ESP Enabled", visY, settings, "enabled").Size.Y.Offset + 5
visY = visY + createToggle(tabFrames.VISUALS, "Show Names", visY, settings, "showNames").Size.Y.Offset + 5
visY = visY + createToggle(tabFrames.VISUALS, "Show Distance", visY, settings, "showDistance").Size.Y.Offset + 5
visY = visY + createToggle(tabFrames.VISUALS, "Show Health", visY, settings, "showHealth").Size.Y.Offset + 5
visY = visY + createToggle(tabFrames.VISUALS, "Show Weapon", visY, settings, "showWeapon").Size.Y.Offset + 5
visY = visY + createToggle(tabFrames.VISUALS, "Bounding Box", visY, settings, "showBox").Size.Y.Offset + 5
visY = visY + createToggle(tabFrames.VISUALS, "Team Check", visY, settings, "teamCheck").Size.Y.Offset + 5

-- AIMBOT TAB
local aimY = 10
createSection(tabFrames.AIMBOT, "AIMBOT SETTINGS", aimY); aimY = aimY + 35

aimY = aimY + createToggle(tabFrames.AIMBOT, "Aimbot Enabled", aimY, aimbotSettings, "enabled").Size.Y.Offset + 5
aimY = aimY + createToggle(tabFrames.AIMBOT, "Team Check", aimY, aimbotSettings, "teamCheck").Size.Y.Offset + 5
aimY = aimY + createToggle(tabFrames.AIMBOT, "Show FOV", aimY, aimbotSettings, "fovVisible").Size.Y.Offset + 5
aimY = aimY + createSlider(tabFrames.AIMBOT, "FOV Size", aimY, aimbotSettings, "fov", 10, 500).Size.Y.Offset + 5
aimY = aimY + createSlider(tabFrames.AIMBOT, "Smoothness", aimY, aimbotSettings, "smoothness", 1, 30).Size.Y.Offset + 5

-- Aim part selector
local aimPartFrame = Instance.new("Frame")
aimPartFrame.Size = UDim2.new(1, -20, 0, 25)
aimPartFrame.Position = UDim2.new(0, 10, 0, aimY)
aimPartFrame.BackgroundTransparency = 1
aimPartFrame.Parent = tabFrames.AIMBOT

local aimLabel = Instance.new("TextLabel")
aimLabel.Size = UDim2.new(0.5, 0, 1, 0)
aimLabel.BackgroundTransparency = 1
aimLabel.Text = "Aim Part:"
aimLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
aimLabel.TextSize = 12
aimLabel.Font = Enum.Font.Gotham
aimLabel.TextXAlignment = Enum.TextXAlignment.Left
aimLabel.Parent = aimPartFrame

local headBtn = Instance.new("TextButton")
headBtn.Size = UDim2.new(0.25, 0, 1, 0)
headBtn.Position = UDim2.new(0.5, 0, 0, 0)
headBtn.BackgroundColor3 = aimbotSettings.aimPart == "Head" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(80, 80, 100)
headBtn.Text = "Head"
headBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
headBtn.TextSize = 11
headBtn.Font = Enum.Font.GothamBold
headBtn.BorderSizePixel = 0
headBtn.Parent = aimPartFrame

local bodyBtn = Instance.new("TextButton")
bodyBtn.Size = UDim2.new(0.25, 0, 1, 0)
bodyBtn.Position = UDim2.new(0.75, 0, 0, 0)
bodyBtn.BackgroundColor3 = aimbotSettings.aimPart == "HumanoidRootPart" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(80, 80, 100)
bodyBtn.Text = "Body"
bodyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bodyBtn.TextSize = 11
bodyBtn.Font = Enum.Font.GothamBold
bodyBtn.BorderSizePixel = 0
bodyBtn.Parent = aimPartFrame

headBtn.MouseButton1Click:Connect(function()
    aimbotSettings.aimPart = "Head"
    headBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    bodyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
end)

bodyBtn.MouseButton1Click:Connect(function()
    aimbotSettings.aimPart = "HumanoidRootPart"
    headBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    bodyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
end)

-- PLAYER TAB
local playerY = 10
createSection(tabFrames.PLAYER, "PLAYER SETTINGS", playerY); playerY = playerY + 35

playerY = playerY + createSlider(tabFrames.PLAYER, "Walk Speed", playerY, playerSettings, "walkSpeed", 16, 100).Size.Y.Offset + 5
playerY = playerY + createSlider(tabFrames.PLAYER, "Jump Power", playerY, playerSettings, "jumpPower", 50, 200).Size.Y.Offset + 5
playerY = playerY + createToggle(tabFrames.PLAYER, "Noclip", playerY, playerSettings, "noclip").Size.Y.Offset + 5
playerY = playerY + createToggle(tabFrames.PLAYER, "Fly", playerY, playerSettings, "fly").Size.Y.Offset + 5
playerY = playerY + createToggle(tabFrames.PLAYER, "Infinite Jump", playerY, playerSettings, "infiniteJump").Size.Y.Offset + 5

-- GUN TAB
local gunY = 10
createSection(tabFrames.GUN, "WEAPON SETTINGS", gunY); gunY = gunY + 35

gunY = gunY + createToggle(tabFrames.GUN, "No Recoil", gunY, gunSettings, "noRecoil").Size.Y.Offset + 5
gunY = gunY + createToggle(tabFrames.GUN, "Rapid Fire", gunY, gunSettings, "rapidFire").Size.Y.Offset + 5
gunY = gunY + createToggle(tabFrames.GUN, "Infinite Ammo", gunY, gunSettings, "infiniteAmmo").Size.Y.Offset + 5
gunY = gunY + createSlider(tabFrames.GUN, "Fire Rate Multiplier", gunY, gunSettings, "fireRateMultiplier", 1, 10).Size.Y.Offset + 5

-- FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, aimbotSettings.fov * 2, 0, aimbotSettings.fov * 2)
fovCircle.Position = UDim2.new(0.5, -aimbotSettings.fov, 0.5, -aimbotSettings.fov)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 1
fovCircle.BorderColor3 = aimbotSettings.fovColor
fovCircle.Visible = aimbotSettings.fovVisible
fovCircle.Parent = menu

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = fovCircle

-- ESP Functions
local function createESP(player)
    if player == LocalPlayer then return end
    if espCache[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = settings.color
    highlight.OutlineColor = settings.color
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0
    highlight.Parent = game:GetService("CoreGui")
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = settings.maxDistance
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = settings.textSize
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        billboard.Adornee = humanoidRootPart
        billboard.Parent = humanoidRootPart
    end
    
    espCache[player] = {
        highlight = highlight,
        billboard = billboard,
        textLabel = textLabel
    }
    
    player.CharacterAdded:Connect(function(newChar)
        if espCache[player] then
            espCache[player].highlight.Adornee = newChar
            local newRoot = newChar:WaitForChild("HumanoidRootPart", 5)
            if newRoot then
                espCache[player].billboard.Adornee = newRoot
                espCache[player].billboard.Parent = newRoot
            end
        end
    end)
end

local function removeESP(player)
    if espCache[player] then
        espCache[player].highlight:Destroy()
        espCache[player].billboard:Destroy()
        espCache[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if settings.enabled and player.Character then
                if settings.teamCheck and player.Team == LocalPlayer.Team then
                    removeESP(player)
                else
                    createESP(player)
                    if espCache[player] then
                        local character = player.Character
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoidRootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            
                            local text = ""
                            if settings.showNames then
                                text = player.Name
                            end
                            
                            if settings.showDistance then
                                text = text .. "\n" .. math.floor(distance) .. " studs"
                            end
                            
                            if settings.showHealth and humanoid then
                                text = text .. "\nHP: " .. math.floor(humanoid.Health)
                            end
                            
                            if settings.showWeapon then
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool then
                                    text = text .. "\nWeapon: " .. tool.Name
                                end
                            end
                            
                            espCache[player].textLabel.Text = text
                            espCache[player].highlight.Enabled = settings.showBox
                        end
                    end
                end
            else
                removeESP(player)
            end
        end
    end
end

-- Player Functions
local function updatePlayerStats()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = playerSettings.walkSpeed
        humanoid.JumpPower = playerSettings.jumpPower
    end
    
    if playerSettings.noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Aimbot Functions
local function updateFOV()
    fovCircle.Size = UDim2.new(0, aimbotSettings.fov * 2, 0, aimbotSettings.fov * 2)
    fovCircle.Position = UDim2.new(0.5, -aimbotSettings.fov, 0.5, -aimbotSettings.fov)
    fovCircle.BorderColor3 = aimbotSettings.fovColor
    fovCircle.Visible = aimbotSettings.fovVisible
end

local function aimbot()
    if not aimbotSettings.enabled or not LocalPlayer.Character then return end
    
    local camera = workspace.CurrentCamera
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local closestPlayer = nil
    local closestDistance = aimbotSettings.fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if aimbotSettings.teamCheck and player.Team == LocalPlayer.Team then continue end
            
            local character = player.Character
            local aimPart = character:FindFirstChild(aimbotSettings.aimPart)
            if aimPart then
                local screenPos = camera:WorldToViewportPoint(aimPart.Position)
                if screenPos.Z > 0 then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character then
        local aimPart = closestPlayer.Character:FindFirstChild(aimbotSettings.aimPart)
        if aimPart then
            local targetPos = camera:WorldToViewportPoint(aimPart.Position)
            local delta = (Vector2.new(targetPos.X, targetPos.Y) - center)
            
            if aimbotSettings.smoothness > 1 then
                delta = delta / aimbotSettings.smoothness
            end
            
            mousemoverel(delta.X, delta.Y)
        end
    end
end

-- Main Loop
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    updateESP()
    updateFOV()
    updatePlayerStats()
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        aimbot()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("Cobalt.win loaded! Press INSERT to open menu")