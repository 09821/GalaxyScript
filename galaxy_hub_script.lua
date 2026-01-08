-- Galaxy Hub Script
-- Criado para Roblox Executors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = Workspace.CurrentCamera

-- Variáveis de estado
local states = {
    xray = false,
    hitboxExpander = false,
    hitboxSize = 10,
    teleguiado = false,
    tpTeleguiado = false,
    desyncV1 = false,
    desyncV2 = false,
    antiLag = false,
    espPlayers = false,
    infiniteJump = false,
    speedBoost = false,
    markedPosition = nil,
    antiReset = true,
    antiRagdoll = true,
    antiKick = true,
    cloneChar = nil
}

-- Cores do tema Galaxy (roxo suave)
local colors = {
    primary = Color3.fromRGB(147, 112, 219),
    secondary = Color3.fromRGB(138, 43, 226),
    background = Color3.fromRGB(25, 20, 35),
    titleBar = Color3.fromRGB(35, 28, 50),
    buttonNormal = Color3.fromRGB(60, 50, 80),
    buttonHover = Color3.fromRGB(80, 65, 105),
    buttonOn = Color3.fromRGB(50, 205, 50),
    buttonOff = Color3.fromRGB(60, 50, 80),
    text = Color3.fromRGB(255, 255, 255),
    minimize = Color3.fromRGB(255, 193, 7),
    close = Color3.fromRGB(244, 67, 54)
}

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GalaxyHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Função para fazer elementos arrastáveis
local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos

    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Criar botão circular (ícone)
local circleButton = Instance.new("ImageButton")
circleButton.Name = "CircleButton"
circleButton.Size = UDim2.new(0, 60, 0, 60)
circleButton.Position = UDim2.new(0, 20, 0.5, -30)
circleButton.BackgroundColor3 = colors.primary
circleButton.BorderSizePixel = 0
circleButton.Image = "rbxassetid://0" -- Mude este ID para sua imagem
circleButton.ScaleType = Enum.ScaleType.Fit
circleButton.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circleButton

makeDraggable(circleButton)

-- GUI Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Barra de título principal
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = colors.titleBar
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌌 Galaxy Hub"
titleLabel.TextColor3 = colors.text
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Botão minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -100, 0.5, -15)
minimizeBtn.BackgroundColor3 = colors.minimize
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = colors.text
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeBtn

-- Botão maximizar
local maximizeBtn = Instance.new("TextButton")
maximizeBtn.Size = UDim2.new(0, 30, 0, 30)
maximizeBtn.Position = UDim2.new(1, -65, 0.5, -15)
maximizeBtn.BackgroundColor3 = colors.buttonNormal
maximizeBtn.Text = "+"
maximizeBtn.TextColor3 = colors.text
maximizeBtn.TextSize = 20
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.BorderSizePixel = 0
maximizeBtn.Visible = false
maximizeBtn.Parent = titleBar

local maxCorner = Instance.new("UICorner")
maxCorner.CornerRadius = UDim.new(0, 5)
maxCorner.Parent = maximizeBtn

-- Botão fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0.5, -15)
closeBtn.BackgroundColor3 = colors.close
closeBtn.Text = "X"
closeBtn.TextColor3 = colors.text
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeBtn

makeDraggable(mainFrame, titleBar)

-- Container de conteúdo principal
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Função para criar botão toggle
local function createToggleButton(parent, text, position, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = colors.buttonOff
    btn.Text = text
    btn.TextColor3 = colors.text
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local isOn = false
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        btn.BackgroundColor3 = isOn and colors.buttonOn or colors.buttonOff
        if callback then callback(isOn) end
    end)

    return btn
end

-- Funções principais da GUI Principal
createToggleButton(contentFrame, "X-Ray", UDim2.new(0, 5, 0, 0), function(state)
    states.xray = state
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Baseplate" then
            obj.Transparency = state and 0.7 or obj.Transparency
        end
    end
end)

createToggleButton(contentFrame, "Super Boost", UDim2.new(0, 5, 0, 50), function(state)
    settings().Rendering.QualityLevel = state and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
end)

-- Hitbox Expander
local hitboxFrame = Instance.new("Frame")
hitboxFrame.Size = UDim2.new(1, -10, 0, 90)
hitboxFrame.Position = UDim2.new(0, 5, 0, 100)
hitboxFrame.BackgroundTransparency = 1
hitboxFrame.Parent = contentFrame

local hitboxBtn = createToggleButton(hitboxFrame, "Hitbox Expander", UDim2.new(0, 0, 0, 0), function(state)
    states.hitboxExpander = state
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then
                    hrp.Size = Vector3.new(states.hitboxSize, states.hitboxSize, states.hitboxSize)
                    hrp.Transparency = 0.6
                    hrp.Color = Color3.new(1, 1, 1)
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

local hitboxInput = Instance.new("TextBox")
hitboxInput.Size = UDim2.new(1, 0, 0, 35)
hitboxInput.Position = UDim2.new(0, 0, 0, 45)
hitboxInput.BackgroundColor3 = colors.buttonNormal
hitboxInput.Text = "10"
hitboxInput.PlaceholderText = "Tamanho da Hitbox"
hitboxInput.TextColor3 = colors.text
hitboxInput.TextSize = 14
hitboxInput.Font = Enum.Font.Gotham
hitboxInput.BorderSizePixel = 0
hitboxInput.Parent = hitboxFrame

local hitboxCorner = Instance.new("UICorner")
hitboxCorner.CornerRadius = UDim.new(0, 8)
hitboxCorner.Parent = hitboxInput

hitboxInput.FocusLost:Connect(function()
    local num = tonumber(hitboxInput.Text)
    if num then
        states.hitboxSize = num
    end
end)

-- Botão Abrir Painel
local panelBtn = Instance.new("TextButton")
panelBtn.Size = UDim2.new(1, -10, 0, 40)
panelBtn.Position = UDim2.new(0, 5, 0, 200)
panelBtn.BackgroundColor3 = colors.secondary
panelBtn.Text = "Abrir Painel 🌌"
panelBtn.TextColor3 = colors.text
panelBtn.TextSize = 14
panelBtn.Font = Enum.Font.GothamBold
panelBtn.BorderSizePixel = 0
panelBtn.Parent = contentFrame

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panelBtn

-- Mini Painel
local miniPanel = Instance.new("Frame")
miniPanel.Name = "MiniPanel"
miniPanel.Size = UDim2.new(0, 320, 0, 500)
miniPanel.Position = UDim2.new(1, -340, 0.5, -250)
miniPanel.BackgroundColor3 = colors.background
miniPanel.BorderSizePixel = 0
miniPanel.Visible = false
miniPanel.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 10)
miniCorner.Parent = miniPanel

-- Título do Mini Painel
local miniTitle = Instance.new("TextLabel")
miniTitle.Size = UDim2.new(1, 0, 0, 50)
miniTitle.BackgroundColor3 = colors.titleBar
miniTitle.Text = "Segue lá no TKK @galaxyscripts8"
miniTitle.TextColor3 = colors.text
miniTitle.TextSize = 12
miniTitle.Font = Enum.Font.GothamBold
miniTitle.TextWrapped = true
miniTitle.BorderSizePixel = 0
miniTitle.Parent = miniPanel

local miniTitleCorner = Instance.new("UICorner")
miniTitleCorner.CornerRadius = UDim.new(0, 10)
miniTitleCorner.Parent = miniTitle

makeDraggable(miniPanel, miniTitle)

-- ScrollFrame do Mini Painel
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = miniPanel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Funções do Mini Painel

-- Mark Position
local markBtn = Instance.new("TextButton")
markBtn.Size = UDim2.new(1, 0, 0, 40)
markBtn.BackgroundColor3 = colors.buttonNormal
markBtn.Text = "Mark Position 📍"
markBtn.TextColor3 = colors.text
markBtn.TextSize = 14
markBtn.Font = Enum.Font.Gotham
markBtn.BorderSizePixel = 0
markBtn.LayoutOrder = 1
markBtn.Parent = scrollFrame

local markCorner = Instance.new("UICorner")
markCorner.CornerRadius = UDim.new(0, 8)
markCorner.Parent = markBtn

markBtn.MouseButton1Click:Connect(function()
    if states.markedPosition then
        markBtn.Text = "Posição já marcada! Limpe primeiro"
        wait(2)
        markBtn.Text = "Mark Position 📍"
    else
        states.markedPosition = character.HumanoidRootPart.Position
        markBtn.Text = "Posição Marcada! ✓"
    end
end)

-- Clear Position
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, 0, 0, 40)
clearBtn.BackgroundColor3 = colors.close
clearBtn.Text = "Clear Position 🗑️"
clearBtn.TextColor3 = colors.text
clearBtn.TextSize = 14
clearBtn.Font = Enum.Font.Gotham
clearBtn.BorderSizePixel = 0
clearBtn.LayoutOrder = 2
clearBtn.Parent = scrollFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 8)
clearCorner.Parent = clearBtn

clearBtn.MouseButton1Click:Connect(function()
    states.markedPosition = nil
    markBtn.Text = "Mark Position 📍"
end)

-- Teleguiado
createToggleButton(scrollFrame, "Teleguiado", UDim2.new(0, 0, 0, 0), function(state)
    states.teleguiado = state
    if state then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "TeleguiadoVelocity"
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = character.HumanoidRootPart
        
        RunService.Heartbeat:Connect(function()
            if not states.teleguiado then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("TeleguiadoVelocity") then
                local velocity = camera.CFrame.LookVector * 27
                hrp.TeleguiadoVelocity.Velocity = velocity
            end
        end)
        
        spawn(function()
            while states.teleguiado do
                local part = Instance.new("Part")
                part.Size = Vector3.new(5, 1, 5)
                part.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                part.Anchored = true
                part.Transparency = 0.5
                part.Color = colors.primary
                part.Parent = Workspace
                game.Debris:AddItem(part, 3)
                wait(3)
            end
        end)
    else
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("TeleguiadoVelocity")
            if bv then bv:Destroy() end
        end
    end
end).LayoutOrder = 3

-- TP Teleguiado
createToggleButton(scrollFrame, "TP Teleguiado", UDim2.new(0, 0, 0, 0), function(state)
    states.tpTeleguiado = state
    if state and states.markedPosition then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "TPVelocity"
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Parent = character.HumanoidRootPart
        
        spawn(function()
            while states.tpTeleguiado do
                local hrp = character.HumanoidRootPart
                local direction = (states.markedPosition - hrp.Position).Unit
                bodyVelocity.Velocity = direction * 28
                
                local part = Instance.new("Part")
                part.Size = Vector3.new(5, 1, 5)
                part.Position = hrp.Position - Vector3.new(0, 3, 0)
                part.Anchored = true
                part.Transparency = 0.5
                part.Color = colors.secondary
                part.Parent = Workspace
                game.Debris:AddItem(part, 2)
                
                if (hrp.Position - states.markedPosition).Magnitude < 5 then
                    states.tpTeleguiado = false
                    bodyVelocity:Destroy()
                    break
                end
                wait(2)
            end
        end)
    end
end).LayoutOrder = 4

-- Desync V1
createToggleButton(scrollFrame, "Desync V1", UDim2.new(0, 0, 0, 0), function(state)
    states.desyncV1 = state
    if state then
        local FFlags = {
            GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
            LargeReplicatorWrite5 = true,
            MaxDataPacketPerSend = 2147483647
        }
        for name, value in pairs(FFlags) do
            pcall(function() setfflag(tostring(name), tostring(value)) end)
        end
        humanoid.Health = 0
        wait(Players.RespawnTime)
    end
end).LayoutOrder = 5

-- Desync V2
createToggleButton(scrollFrame, "Desync V2", UDim2.new(0, 0, 0, 0), function(state)
    states.desyncV2 = state
    if state then
        states.cloneChar = character:Clone()
        states.cloneChar.Parent = Workspace
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    else
        if states.cloneChar then
            states.cloneChar:Destroy()
        end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end).LayoutOrder = 6

-- Anti Lag - FPS Boost
createToggleButton(scrollFrame, "Anti Lag - FPS Boost", UDim2.new(0, 0, 0, 0), function(state)
    states.antiLag = state
    for _, obj in pairs(Workspace:GetDescendants()) do
        if state then
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    settings().Rendering.QualityLevel = state and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
end).LayoutOrder = 7

-- ESP Player + Line
createToggleButton(scrollFrame, "ESP Player + Line", UDim2.new(0, 0, 0, 0), function(state)
    states.espPlayers = state
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local esp = Instance.new("BillboardGui")
                esp.Name = "ESP"
                esp.AlwaysOnTop = true
                esp.Size = UDim2.new(0, 100, 0, 50)
                esp.Adornee = plr.Character.HumanoidRootPart
                esp.Parent = plr.Character.HumanoidRootPart
                
                local frame = Instance.new("Frame", esp)
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 0.5
                frame.BackgroundColor3 = Color3.new(1, 0, 0)
                frame.BorderSizePixel = 2
                
                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextScaled = true
            end
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                local esp = plr.Character.HumanoidRootPart:FindFirstChild("ESP")
                if esp then esp:Destroy() end
            end
        end
    end
end).LayoutOrder = 8

-- Infinite Jump
createToggleButton(scrollFrame, "Infinite Jump", UDim2.new(0, 0, 0, 0), function(state)
    states.infiniteJump = state
end).LayoutOrder = 9

UserInputService.JumpRequest:Connect(function()
    if states.infiniteJump then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Speed Boost
createToggleButton(scrollFrame, "Speed Boost", UDim2.new(0, 0, 0, 0), function(state)
    states.speedBoost = state
    humanoid.WalkSpeed = state and 35 or 16
end).LayoutOrder = 10

-- Sistemas de proteção
local originalHealth = humanoid.Health
humanoid.HealthChanged:Connect(function(health)
    if states.antiReset and health < originalHealth then
        humanoid.Health = originalHealth
    end
end)

-- Anti Ragdoll
RunService.Stepped:Connect(function()
    if states.antiRagdoll then
        for _, joint in pairs(character:GetDescendants()) do
            if joint:IsA("Motor6D") then
                joint.Enabled = true
            end
        end
    end
end)

-- Eventos dos botões
circleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

minimizeBtn.MouseButton1Click:Connect(function()
    contentFrame.Visible = false
    minimizeBtn.Visible = false
    maximizeBtn.Visible = true
    mainFrame.Size = UDim2.new(0, 320, 0, 40)
end)

maximizeBtn.MouseButton1Click:Connect(function()
    contentFrame.Visible = true
    minimizeBtn.Visible = true
    maximizeBtn.Visible = false
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

panelBtn.MouseButton1Click:Connect(function()
    miniPanel.Visible = not miniPanel.Visible
end)

print("Galaxy Hub carregado com sucesso!")
print("Criado por @galaxyscripts8")
