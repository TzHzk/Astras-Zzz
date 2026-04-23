-- ASTRA HUB ZZ - Con KeySystem
-- Clave: "Testing 2"

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Txzp/Astras-Zzz/main/WindUI-main/dist/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Variables del Hub
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

-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local ValidKey = "Testing 2"
local KeyEntered = false

-- Crear Ventana de KeySystem
local KeyWindow = WindUI:CreateWindow({
    Title = "ASTRA HUB ZZ - KeySystem",
    Theme = "Dark",
    Size = UDim2.fromOffset(400, 300),
    IgnoreAlerts = true -- Evita el dialog de cierre
})

local KeyTab = KeyWindow:Tab({ Title = "Activación", Icon = "key" })

KeyTab:Paragraph({
    Title = "🔑 Sistema de Licencia",
    Desc = "Introduce tu clave para acceder a AstraHub ZZ."
})

KeyTab:Input({
    Title = "Clave de Acceso",
    Placeholder = "Escribe tu clave aquí...",
    Callback = function(key)
        if key == ValidKey then
            KeyEntered = true
            WindUI:Notify({
                Title = "✅ Éxito",
                Content = "Clave correcta. Cargando hub...",
                Duration = 2
            })
            task.wait(1)
            KeyWindow:Destroy() -- Cierra la ventana de KeySystem
            LoadMainHub() -- Carga el hub principal
        else
            WindUI:Notify({
                Title = "❌ Error",
                Content = "Clave incorrecta. Intenta de nuevo.",
                Icon = "x",
                Duration = 2
            })
        end
    end
})

KeyTab:Button({
    Title = "Activar",
    Callback = function()
        -- Este botón es opcional, ya que el Input ya valida al presionar Enter
        WindUI:Notify({
            Title = "ℹ️ Info",
            Content = "Presiona Enter en el campo de texto para validar.",
            Duration = 2
        })
    end
})

-- ═══════════════════════════════════════════════════════════════
-- HUB PRINCIPAL (Se carga después de introducir la clave)
-- ═══════════════════════════════════════════════════════════════

function LoadMainHub()
    Window = WindUI:CreateWindow({
        Title = "ASTRA HUB ZZ",
        Theme = "Dark",
        Size = UDim2.fromOffset(480, 420)
    })

    -- Tags Decorativos
    Window:Tag({ Title = "AstraHub", Color = Color3.fromHex("#30ff6a") })
    Window:Tag({ Title = "v1.0", Color = Color3.fromHex("#315dff") })
    Window:Tag({ Title = "by TzHzk", Color = Color3.fromHex("#888888") })

    -- Tabs
    local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
    local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
    local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

    -- MAIN TAB
    MainTab:Paragraph({
        Title = "✨ AstraHub ZZ",
        Desc = "Hub con KeySystem\nSliders Verdes\nDialog Personalizado"
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

    -- PLAYER TAB
    PlayerTab:Toggle({
        Title = "⚡ Speed Activado",
        Value = false,
        Callback = function(state)
            SpeedEnabled = state
            ApplySpeed()
        end
    })

    PlayerTab:Slider({
        Title = "Velocidad",
        Value = { Min = 16, Max = 120, Default = 16 },
        Callback = function(value)
            SpeedValue = value
            if SpeedEnabled then ApplySpeed() end
        end
    })

    -- ESP TAB
    ESPTab:Toggle({
        Title = "👁️ ESP Highlight",
        Value = false,
        Callback = function(state)
            ESPEnabled = state
        end
    })

    ESPTab:Slider({
        Title = "Opacidad del ESP",
        Value = { Min = 0, Max = 1, Default = 0.5 },
        Increment = 0.1,
        Callback = function(value)
            ESPFill = value
        end
    })

    print("✅ AstraHub ZZ Cargado Correctamente")
end

print("🔑 KeySystem cargado. Introduce la clave: 'Testing 2'")
