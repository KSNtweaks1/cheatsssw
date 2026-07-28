--[[
    KSN Pure ESP - Murder Duels
    Features: Box ESP only (Purple default)
    Hotkeys: K - Menu | G - Toggle ESP
]]

-- ─── Services ──────────────────────────────────────────────────────────────
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ─── Settings ──────────────────────────────────────────────────────────────
local Settings = {
    ESPEnabled = true,
    Color = Color3.fromRGB(180, 50, 255), -- Purple
}

-- ─── Drawing Setup ──────────────────────────────────────────────────────────
local Drawing = Drawing
local useLegacy = not Drawing

if useLegacy then
    local ESPGui = Instance.new("ScreenGui")
    ESPGui.Name = "KSN_ESP"
    ESPGui.ResetOnSpawn = false
    ESPGui.IgnoreGuiInset = true
    ESPGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    Drawing = {
        new = function(type)
            if type == "Line" then
                local line = Instance.new("Frame")
                line.Parent = ESPGui
                line.BackgroundColor3 = Color3.new(1, 1, 1)
                line.BorderSizePixel = 0
                line.Size = UDim2.new(0, 2, 0, 2)
                line.Visible = true
                return line
            elseif type == "Text" then
                local text = Instance.new("TextLabel")
                text.Parent = ESPGui
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.new(1, 1, 1)
                text.TextStrokeTransparency = 0.5
                text.TextStrokeColor3 = Color3.new(0, 0, 0)
                text.Font = Enum.Font.GothamBold
                text.TextSize = 11
                text.Size = UDim2.new(0, 300, 0, 25)
                text.Visible = true
                return text
            end
        end
    }
end

-- ─── Object Pool ────────────────────────────────────────────────────────────
local lines = {}
local lineIdx = 1

local function getLine()
    if lineIdx > #lines then
        lines[lineIdx] = Drawing.new("Line")
    end
    local line = lines[lineIdx]
    line.Visible = true
    lineIdx = lineIdx + 1
    return line
end

local function resetPool()
    for i = lineIdx, #lines do lines[i].Visible = false end
    lineIdx = 1
end

-- ─── Box Calculation ──────────────────────────────────────────────────────

local function getBox(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local cf = root.CFrame
    local sx, sy, sz = 1.1, 2.6, 0.6
    local pts = {
        cf * Vector3.new(sx, sy, sz), cf * Vector3.new(-sx, sy, sz),
        cf * Vector3.new(sx, -sy, sz), cf * Vector3.new(-sx, -sy, sz),
        cf * Vector3.new(sx, sy, -sz), cf * Vector3.new(-sx, sy, -sz),
        cf * Vector3.new(sx, -sy, -sz), cf * Vector3.new(-sx, -sy, -sz),
    }
    
    local mnX, mnY, mxX, mxY = math.huge, math.huge, -math.huge, -math.huge
    local hit = false
    
    for _, v in ipairs(pts) do
        local sp, on = Camera:WorldToViewportPoint(v)
        if sp.Z > 0 then
            hit = true
            mnX = math.min(mnX, sp.X)
            mnY = math.min(mnY, sp.Y)
            mxX = math.max(mxX, sp.X)
            mxY = math.max(mxY, sp.Y)
        end
    end
    
    if not hit then return nil end
    return mnX, mnY, mxX - mnX, mxY - mnY
end

-- ─── Drawing ─────────────────────────────────────────────────────────────────

local function drawBox(bx, by, bw, bh, color)
    local l = getLine()
    l.From = Vector2.new(bx, by)
    l.To = Vector2.new(bx + bw, by)
    l.Color = color
    l.Thickness = 2
    
    l = getLine()
    l.From = Vector2.new(bx + bw, by)
    l.To = Vector2.new(bx + bw, by + bh)
    l.Color = color
    l.Thickness = 2
    
    l = getLine()
    l.From = Vector2.new(bx + bw, by + bh)
    l.To = Vector2.new(bx, by + bh)
    l.Color = color
    l.Thickness = 2
    
    l = getLine()
    l.From = Vector2.new(bx, by + bh)
    l.To = Vector2.new(bx, by)
    l.Color = color
    l.Thickness = 2
end

-- ─── ESP ────────────────────────────────────────────────────────────────────

local function updateESP()
    if not Settings.ESPEnabled then
        resetPool()
        return
    end
    
    resetPool()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local bx, by, bw, bh = getBox(player.Character)
        if not bx then continue end
        
        drawBox(bx, by, bw, bh, Settings.Color)
    end
end

-- ─── Main Loop ──────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(updateESP)

-- ─── UI ─────────────────────────────────────────────────────────────────────

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KSN_Menu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 240, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -120, 0.5, -90)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Visible = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KSN Pure ESP"
    title.TextColor3 = Color3.fromRGB(180, 50, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 3)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
    
    -- ESP Toggle
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(0, 200, 0, 35)
    espBtn.Position = UDim2.new(0.5, -100, 0, 50)
    espBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBtn.Text = "ESP: ON"
    espBtn.TextSize = 16
    espBtn.Font = Enum.Font.GothamBold
    espBtn.Parent = mainFrame
    
    local espCorner = Instance.new("UICorner")
    espCorner.CornerRadius = UDim.new(0, 5)
    espCorner.Parent = espBtn
    
    local function updateEspBtn()
        espBtn.Text = Settings.ESPEnabled and "ESP: ON" or "ESP: OFF"
        espBtn.BackgroundColor3 = Settings.ESPEnabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 40, 40)
    end
    updateEspBtn()
    
    espBtn.MouseButton1Click:Connect(function()
        Settings.ESPEnabled = not Settings.ESPEnabled
        updateEspBtn()
    end)
    
    -- Color Picker
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 200, 0, 30)
    colorBtn.Position = UDim2.new(0.5, -100, 0, 100)
    colorBtn.BackgroundColor3 = Settings.Color
    colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorBtn.Text = "Change Color"
    colorBtn.TextSize = 14
    colorBtn.Font = Enum.Font.GothamBold
    colorBtn.Parent = mainFrame
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 5)
    colorCorner.Parent = colorBtn
    
    colorBtn.MouseButton1Click:Connect(function()
        Settings.Color = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
        colorBtn.BackgroundColor3 = Settings.Color
    end)
    
    return screenGui, mainFrame
end

local ui, mainFrame = createUI()

-- ─── Input ──────────────────────────────────────────────────────────────────

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        mainFrame.Visible = not mainFrame.Visible
    end
    
    if input.KeyCode == Enum.KeyCode.G then
        Settings.ESPEnabled = not Settings.ESPEnabled
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Text:match("ESP:") then
                child.Text = Settings.ESPEnabled and "ESP: ON" or "ESP: OFF"
                child.BackgroundColor3 = Settings.ESPEnabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 40, 40)
            end
        end
    end
end)

print("[KSN] Pure ESP loaded! (Purple default)")
print("[KSN] K - Menu | G - Toggle ESP")