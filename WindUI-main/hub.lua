-- ASTRA HUB ZZ - TESTING VERSION (Estable)
-- Carga WindUI Oficial para asegurar compatibilidad
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Variables
local SpeedEnabled = false
local SpeedValue = 16
local ESPEnabled = false
local ESPFill = 0.5
local ESPObjects = {}
local Window = nil

-- Funciones Lógicas
local function ApplySpeed()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = SpeedEnabled and SpeedValue or 16
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed()
end)

local function UpdateESP()
    if not ESPEnabled then
        for _, obj in pairs(ESPObjects) do
            pcall(function() obj:Destroy() end)
        end
        ESPObjects = {}
        return
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    if not ESPObjects[plr] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = char
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = ESPFill
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                        ESPObjects[plr] = hl
                    else
                        ESPObjects[plr].FillTransparency = ESPFill
                    end
                elseif ESPObjects[plr] then
                    pcall(function() ESPObjects[plr]:Destroy() end)
                    ESPObjects[plr] = nil
                end
            elseif ESPObjects[plr] then
                pcall(function() ESPObjects[plr]:Destroy() end)
                ESPObjects[plr] = nil
            end
        end
    end
end

RunService.Heartbeat:Connect(UpdateESP)

-- Crear Ventana
Window = WindUI:CreateWindow({
    Title = "ASTRA HUB ZZ",
    Theme = "Dark",
    Size = UDim2.fromOffset(450, 400)
})

-- Tags Decorativos
Window:Tag({ Title = "AstraHub", Color = Color3.fromHex("#30ff6a") })
Window:Tag({ Title = "v1.0 Test", Color = Color3.fromHex("#315dff") })
Window:Tag({ Title = "by TzHzk", Color = Color3.fromHex("#888888") })

-- Tabs
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

-- MAIN TAB
MainTab:Paragraph({
    Title = "✨ AstraHub ZZ",
    Desc = "Testing Version\nStable • No Sliders • No Errors"
})
MainTab:Divider()
MainTab:Button({
    Title = "Discord Server",
    Icon = "message-circle",
    Callback = function()
        setclipboard("https://discord.gg/drR7ZVKPXe")
        WindUI:Notify({ Title = "Discord", Content = "Link copiado!", Duration = 2 })
    end
})

-- PLAYER TAB (Usando Botones en vez de Sliders)
PlayerTab:Toggle({
    Title = "⚡ Speed Activado",
    Value = false,
    Callback = function(state)
        SpeedEnabled = state
        ApplySpeed()
        WindUI:Notify({ Title = "Speed", Content = state and "ON" or "OFF", Duration = 1 })
    end
})

PlayerTab:Button({
    Title = "Velocidad: " .. SpeedValue,
    Callback = function(btn)
        SpeedValue = SpeedValue + 5
        if SpeedValue > 100 then SpeedValue = 16 end
        btn:SetTitle("Velocidad: " .. SpeedValue)
        if SpeedEnabled then ApplySpeed() end
        WindUI:Notify({ Title = "Speed", Content = "Velocidad: " .. SpeedValue, Duration = 1 })
    end
})

-- ESP TAB
ESPTab:Toggle({
    Title = "👁️ ESP Highlight",
    Value = false,
    Callback = function(state)
        ESPEnabled = state
        WindUI:Notify({ Title = "ESP", Content = state and "ON" or "OFF", Duration = 1 })
    end
})

ESPTab:Button({
    Title = "Opacidad: 50%",
    Callback = function(btn)
        if ESPFill == 0.5 then
            ESPFill = 0.2
            btn:SetTitle("Opacidad: 20%")
        elseif ESPFill == 0.2 then
            ESPFill = 0.8
            btn:SetTitle("Opacidad: 80%")
        else
            ESPFill = 0.5
            btn:SetTitle("Opacidad: 50%")
        end
    end
})

print("✅ AstraHub ZZ Loaded Successfully")
