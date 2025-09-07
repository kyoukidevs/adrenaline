--переменные
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")



---гуишка
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Adrenaline Defusal FPS",
    LoadingTitle = "Adrenaline.CC",
    LoadingSubtitle = "by kyoukidevs",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil,
       FileName = "Adrenaline"
    }
})

local LegitTab = Window:CreateTab("Legit", "mouse")
local RageTab = Window:CreateTab("Rage", "crosshair")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local LocalTab = Window:CreateTab("Local", "user-round")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
        
local aimbotEnabled = false

local function getClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local targetPosition = player.Character.Head.Position
            local screenPosition, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetPosition)

            if onScreen then
                local distance = (Mouse.X - screenPosition.X)^2 + (Mouse.Y - screenPosition.Y)^2
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

local function aimAtTarget(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local targetPosition = target.Character.Head.Position
        local camera = workspace.CurrentCamera
        local direction = (targetPosition - camera.CFrame.Position).unit
        camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        aimAtTarget(target)
    end
end)

Mouse.Button2Down:Connect(function()
    aimbotEnabled = true
end)

Mouse.Button2Up:Connect(function()
    aimbotEnabled = false
end)

local AimToggle = LegitTab:CreateToggle({
    Name = "Toggle Aimbot",
    Callback = function()
        aimbotEnabled = not aimbotEnabled
    end,
})

-- Rage | Silent Aim
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- Настройки
local Settings = {
    Enabled = false,
    TeamCheck = false,
    VisibleCheck = true,
    TargetPart = "Head",
    FOVRadius = 100,
    FOVVisible = true,
    ShowTarget = true,
    HitChance = 100
}

-- Создаем FOV круг
local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 2
fov_circle.NumSides = 64
fov_circle.Radius = Settings.FOVRadius
fov_circle.Filled = false
fov_circle.Visible = Settings.FOVVisible
fov_circle.Color = Color3.fromRGB(0, 255, 0)
fov_circle.Transparency = 1

-- Создаем индикатор цели
local target_dot = Drawing.new("Circle")
target_dot.Thickness = 2
target_dot.NumSides = 12
target_dot.Radius = 6
target_dot.Filled = true
target_dot.Visible = false
target_dot.Color = Color3.fromRGB(255, 0, 0)
target_dot.Transparency = 1

-- Переменные
local target = nil

-- Функция проверки шанса
local function CalculateChance(Percentage)
    return math.random(1, 100) <= Percentage
end

-- Функция получения позиции мыши
local function getMousePosition()
    return Vector2.new(mouse.X, mouse.Y)
end

-- Проверка видимости через raycast
local function IsVisible(targetPart)
    if not Settings.VisibleCheck then return true end
    if not player.Character then return false end
    
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, targetPart.Parent}
    
    local raycastResult = Workspace:Raycast(origin, direction * distance, raycastParams)
    return raycastResult == nil
end

-- Поиск ближайшего игрока в FOV
local function getClosestPlayer()
    if not Settings.Enabled then return nil end
    
    local closestTarget = nil
    local closestDistance = Settings.FOVRadius
    local mousePos = getMousePosition()
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer == player then continue end
        if Settings.TeamCheck and targetPlayer.Team == player.Team then continue end

        local character = targetPlayer.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local targetPart = character:FindFirstChild(Settings.TargetPart)
        
        if not humanoid or humanoid.Health <= 0 or not targetPart then continue end
        
        if not IsVisible(targetPart) then continue end
        
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (mousePos - targetPos).Magnitude
        
        if distance <= closestDistance then
            closestTarget = targetPart
            closestDistance = distance
        end
    end
    
    return closestTarget
end

-- Основной цикл обновления
RunService.RenderStepped:Connect(function()
    -- Обновление FOV круга
    fov_circle.Position = getMousePosition()
    fov_circle.Visible = Settings.FOVVisible
    fov_circle.Radius = Settings.FOVRadius
    
    -- Поиск цели
    target = getClosestPlayer()
    
    -- Обновление индикатора цели
    if Settings.ShowTarget and target and target.Parent then
        local screenPos, onScreen = camera:WorldToViewportPoint(target.Position)
        if onScreen then
            target_dot.Visible = true
            target_dot.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            target_dot.Visible = false
        end
    else
        target_dot.Visible = false
    end
end)

-- Hook для raycast метода
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    
    if Settings.Enabled and Method == "Raycast" then
        if CalculateChance(Settings.HitChance) and target and target.Parent then
            local self = Arguments[1]
            if self == Workspace then
                local origin = Arguments[2]
                local direction = Arguments[3]
                
                -- Меняем направление raycast на цель
                local newDirection = (target.Position - origin).Unit * direction.Magnitude
                Arguments[3] = newDirection
                
                return oldNamecall(unpack(Arguments))
            end
        end
    end
    
    return oldNamecall(...)
end)
local SilentToggle = RageTab:CreateToggle({
        Name = "Enable Silent Aim"
        Callback = function()
            SilentAimSettings.Enabled = Not SilentAimSettings.Enabled
        end)
--- Visuals | Chams
local espEnabled = false
local espHighlights = {}
local connection

local function createHighlight(player)
    if player == LocalPlayer then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character

    return highlight
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not espHighlights[player.Name] then
                espHighlights[player.Name] = createHighlight(player)
            end
        end
    end
end

local ESPToggle = VisualsTab:CreateToggle({
    Name = "Toggle Chams",
    Callback = function()
        espEnabled = not espEnabled
        if espEnabled then
            updateESP()
            connection = RunService.RenderStepped:Connect(updateESP)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
            for name, highlight in pairs(espHighlights) do
                if highlight then highlight:Destroy() end
            end
            espHighlights = {}
        end
    end,
})

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if espEnabled then
            espHighlights[player.Name] = createHighlight(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espHighlights[player.Name] then
        espHighlights[player.Name]:Destroy()
        espHighlights[player.Name] = nil
    end
end)

---local | speedhack
local speedHackEnabled = false
local speedHackConnection = nil
local currentSpeed = 16

local SpeedSlider = Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        currentSpeed = Value
        
        if speedHackConnection then
            speedHackConnection:Disconnect()
            speedHackConnection = nil
        end
        
        speedHackEnabled = true
        speedHackConnection = game:GetService("RunService").Stepped:Connect(function()
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = currentSpeed
            end
        end)
    end,
})

local thirdPersonEnabled = false
local defaultZoom = 12.5
local thirdPersonConnection = nil

local ThirdPersonButton = Tab:CreateButton({
    Name = "ThirdPerson (Stable)",
    Callback = function()
        thirdPersonEnabled = not thirdPersonEnabled
        local player = game:GetService("Players").LocalPlayer
        
        if thirdPersonEnabled then
            if thirdPersonConnection then
                thirdPersonConnection:Disconnect()
            end
            
            thirdPersonConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if player then
                    player.CameraMode = Enum.CameraMode.Classic
                    player.CameraMaxZoomDistance = defaultZoom
                    player.CameraMinZoomDistance = defaultZoom
                end
            end)
        else
            if thirdPersonConnection then
                thirdPersonConnection:Disconnect()
                thirdPersonConnection = nil
            end
            player.CameraMode = Enum.CameraMode.LockFirstPerson
            player.CameraMaxZoomDistance = 0.5
            player.CameraMinZoomDistance = 0.5
        end
    end,
})

local CameraZoomSlider = Tab:CreateSlider({
    Name = "Camera Distance (Stable)",
    Range = {5, 25},
    Increment = 0.5,
    Suffix = "Studs",
    CurrentValue = 12.5,
    Flag = "CameraZoomSlider",
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        defaultZoom = Value
        
        if thirdPersonEnabled then
            player.CameraMaxZoomDistance = Value
            player.CameraMinZoomDistance = Value
        end
    end,
})

local transparencyEnabled = false
local transparencyValue = 0.7
local transparencyConnection = nil

local TransparencyButton = Tab:CreateButton({
    Name = "Local Transparency (Stable)",
    Callback = function()
        transparencyEnabled = not transparencyEnabled
        local player = game:GetService("Players").LocalPlayer
        
        local function setTransparency(model, value)
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = value
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = value
                elseif part:IsA("ParticleEmitter") then
                    part.Transparency = NumberSequence.new(value)
                end
            end
            
            for _, cloth in pairs(model:GetChildren()) do
                if cloth:IsA("Shirt") or cloth:IsA("Pants") or 
                   cloth:IsA("ShirtGraphic") or cloth:IsA("Accessory") or
                   cloth:IsA("Hat") then
                    for _, part in pairs(cloth:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = value
                        elseif part:IsA("Decal") or part:IsA("Texture") then
                            part.Transparency = value
                        end
                    end
                end
            end
        end
        
        if transparencyEnabled then
            if transparencyConnection then
                transparencyConnection:Disconnect()
            end
            
            transparencyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local character = player.Character
                if character then
                    setTransparency(character, transparencyValue)
                end
            end)
        else
            if transparencyConnection then
                transparencyConnection:Disconnect()
                transparencyConnection = nil
            end
            local character = player.Character
            if character then
                setTransparency(character, 0)
            end
        end
    end,
})

local TransparencySlider = Tab:CreateSlider({
    Name = "Transparency (Stable)",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "Alpha",
    CurrentValue = 0.7,
    Flag = "TransparencySlider",
    Callback = function(Value)
        transparencyValue = Value
    end,
})

local spinEnabled = false
local spinConnection = nil
local spinSpeed = 10

local SpinButton = Tab:CreateButton({
    Name = "Spin (Stable)",
    Callback = function()
        spinEnabled = not spinEnabled
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.AutoRotate = not spinEnabled
        
        if spinEnabled then
            local spinForce = Instance.new("BodyAngularVelocity")
            spinForce.Name = "SpinForce"
            spinForce.AngularVelocity = Vector3.new(0, spinSpeed, 0)
            spinForce.MaxTorque = Vector3.new(0, math.huge, 0)
            spinForce.Parent = character.HumanoidRootPart
            
            if spinConnection then spinConnection:Disconnect() end
            
            spinConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local spinForce = character.HumanoidRootPart:FindFirstChild("SpinForce")
                    if spinForce then
                        spinForce.AngularVelocity = Vector3.new(0, spinSpeed, 0)
                    end
                end
            end)
            
            character.Humanoid.Died:Connect(function()
                if spinEnabled then
                    spinEnabled = false
                    if spinConnection then
                        spinConnection:Disconnect()
                        spinConnection = nil
                    end
                end
            end)
        else
            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
            
            local spinForce = character.HumanoidRootPart:FindFirstChild("SpinForce")
            if spinForce then spinForce:Destroy() end
            
            humanoid.AutoRotate = true
        end
    end,
})

local SpinSpeedSlider = Tab:CreateSlider({
    Name = "Spin Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 10,
    Flag = "SpinSpeedSlider",
    Callback = function(Value)
        spinSpeed = Value
    end,
})
