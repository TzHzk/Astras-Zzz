-- ============================================================================
-- SCRIPT: WindUI Hub - Silent Aim + FOV + ESP + Hitbox con Team Check
-- AUTOR: Asistente IA para Yanso
-- FECHA: 2026
-- DESCRIPCIÓN: Integra Silent Aim con FOV dinámico, ESP con Team Check automático,
--              y configuración de Hitbox. Usa WindUI como interfaz.
-- ============================================================================

-- 1. CARGAR WINDUI
local WindUILoaded = false
if not game:IsLoaded() then game.Loaded:Wait() end

-- Cargar WindUI desde GitHub
local function LoadWindUI()
    local Success, Result = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Txzp/Astras-Zzz/main/WindUI-main/dist/main.lua"))()
    end)
    if Success then
        WindUILoaded = true
        print("[WindUI] Librería cargada correctamente.")
    else
        warn("[WindUI] Error al cargar la librería: " .. tostring(Result))
    end
end

LoadWindUI()
if not WindUILoaded then return end -- Detener si no cargó

-- 2. CONFIGURACIÓN GLOBAL Y SERVICIOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Tabla de configuración global
local Config = {
    Aimbot = {
        Enabled = false,
        FOV_Enabled = true,
        FOV_Radius = 150,
        FOV_Color_Inactive = Color3.fromRGB(255, 0, 0), -- Rojo cuando no hay objetivo
        FOV_Color_Active = Color3.fromRGB(0, 255, 0),   -- Verde cuando hay objetivo
        Keybind = Enum.KeyCode.E, -- Tecla para activar/desactivar Aimbot
        SilentAim_Keybind = Enum.KeyCode.Q -- Tecla alternativa para silent aim rápido
    },
    ESP = {
        Enabled = false,
        Keybind = Enum.KeyCode.V,
        Check_Teams = true,
        Color = Color3.fromRGB(255, 255, 255),
        Show_Name = true,
        Show_Box = true
    },
    Hitbox = {
        Enabled = false,
        Keybind = Enum.KeyCode.H,
        Size = 5,
        Invisible = false
    }
}

-- 3. VARIABLES DE ESTADO Y OBJETIVOS
local ClosestTarget = nil
local FOV_Circle = Drawing.new("Circle")
local ESP_Table = {} -- Guarda los objetos de dibujo de ESP
local TeamSystemDetected = false -- Para Team Check automático

-- 4. INICIALIZACIÓN DEL FOV
FOV_Circle.Visible = false
FOV_Circle.Color = Config.Aimbot.FOV_Color_Inactive
FOV_Circle.Thickness = 1
FOV_Circle.NumSides = 100
FOV_Circle.Radius = Config.Aimbot.FOV_Radius
FOV_Circle.Filled = false

-- 5. FUNCIONES DE UTILIDAD

-- Detectar sistema de equipos automáticamente
local function DetectTeamSystem()
    -- Verificar si usa Teams estándar
    if LocalPlayer.Team and #game.Teams:GetChildren() > 0 then
        TeamSystemDetected = "Standard"
        print("[TeamCheck] Sistema estándar de Teams detectado.")
        return true
    end
    
    -- Buscar en ReplicatedStorage posibles tablas de equipos
    for _, Child in ipairs(ReplicatedStorage:GetChildren()) do
        if Child:IsA("Folder") or Child:IsA("Model") then
            if string.lower(Child.Name):find("team") or string.lower(Child.Name):find("match") then
                TeamSystemDetected = "Custom"
                print("[TeamCheck] Sistema personalizado de equipos detectado en: " .. Child.Name)
                return true
            end
        end
    end
    
    print("[TeamCheck] No se detectó sistema de equipos. Se apuntará a todos.")
    return false
end

-- Verificar si un jugador es enemigo válido
local function IsValidTarget(Player)
    if not Player or Player == LocalPlayer then return false end
    if not Player.Character then return false end
    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return false end
    if not Player.Character:FindFirstChild("HumanoidRootPart") then return false end

    -- Team Check
    if Config.ESP.Check_Teams then
        if TeamSystemDetected == "Standard" then
            if LocalPlayer.Team and Player.Team and LocalPlayer.Team == Player.Team then
                return false -- Es aliado
            end
        elseif TeamSystemDetected == "Custom" then
            -- Aquí podrías agregar lógica específica si encuentras cómo se definen los equipos personalizados
            -- Por ahora, asumimos que si tiene equipo, es aliado
            if LocalPlayer:FindFirstChild("Team") and Player:FindFirstChild("Team") then
                if LocalPlayer.Team.Value == Player.Team.Value then
                    return false
                end
            end
        end
    end

    return true
end

-- Obtener parte del cuerpo para apuntar (Hitbox)
local function GetHitboxPart(Character)
    local Part = Character:FindFirstChild(Config.Hitbox.Invisible and "HumanoidRootPart" or "Head")
    return Part or Character:FindFirstChild("HumanoidRootPart")
end

-- 6. LÓGICA DE AIMBOT Y FOV

-- Actualizar posición del FOV y buscar objetivo
RunService.Heartbeat:Connect(function()
    -- Mover FOV al centro de la pantalla
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Radius = Config.Aimbot.FOV_Radius
    FOV_Circle.Visible = Config.Aimbot.Enabled and Config.Aimbot.FOV_Enabled

    if not Config.Aimbot.Enabled then
        ClosestTarget = nil
        FOV_Circle.Color = Config.Aimbot.FOV_Color_Inactive
        return
    end

    local MaxDistance = Config.Aimbot.FOV_Radius
    local ClosestDist = math.huge
    local NewTarget = nil

    for _, Player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(Player) then
            local Character = Player.Character
            if Character then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                    if OnScreen then
                        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                        if Dist < MaxDistance and Dist < ClosestDist then
                            ClosestDist = Dist
                            NewTarget = Player
                        end
                    end
                end
            end
        end
    end

    ClosestTarget = NewTarget

    -- Cambiar color del FOV según si hay objetivo
    if ClosestTarget then
        FOV_Circle.Color = Config.Aimbot.FOV_Color_Active -- Verde
    else
        FOV_Circle.Color = Config.Aimbot.FOV_Color_Inactive -- Rojo
    end
end)

-- Silent Aim: Redirigir Mouse.Target y Mouse.Hit cuando se hace clic
Mouse.Button1Down:Connect(function()
    if Config.Aimbot.Enabled and ClosestTarget then
        local Character = ClosestTarget.Character
        if Character then
            local Part = GetHitboxPart(Character)
            if Part then
                -- Redirigir el mouse hacia la parte del enemigo
                -- Esto engaña a muchos juegos que usan Mouse.Target para disparar
                Mouse.Target = Part
                Mouse.Hit = Part.CFrame
                
                -- Opcional: Forzar disparo si el juego usa RemoteEvent
                -- Descomenta esto si sabes el nombre del RemoteEvent y sus argumentos
                /*
                local ShootRemote = ReplicatedStorage.Remotes:FindFirstChild("ClientGunShot")
                if ShootRemote then
                    ShootRemote:FireServer(Part.Position, Part)
                end
                */
                
                print("[SilentAim] Disparo redirigido a: " .. ClosestTarget.Name)
            end
        end
    end
end)

-- 7. LÓGICA DE ESP

local function CreateESP(Player)
    if not Config.ESP.Enabled then return end
    if not IsValidTarget(Player) then return end
    if ESP_Table[Player] then return end -- Evitar duplicados

    local Box = Drawing.new("Square")
    Box.Color = Config.ESP.Color
    Box.Thickness = 1
    Box.Filled = false
    Box.Visible = false

    local NameTag = Drawing.new("Text")
    NameTag.Color = Color3.fromRGB(255, 255, 255)
    NameTag.Size = 13
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Text = Player.Name
    NameTag.Visible = false

    ESP_Table[Player] = { Box = Box, NameTag = NameTag }

    -- Actualizar ESP en cada frame
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not Config.ESP.Enabled or not IsValidTarget(Player) then
            Box.Visible = false
            NameTag.Visible = false
            return
        end

        local Character = Player.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            
            if OnScreen then
                -- Calcular tamaño de la caja basado en la distancia
                local Height = (Camera:WorldToViewportPoint((RootPart.CFrame * CFrame.new(0, 2.5, 0)).Position).Y - 
                                Camera:WorldToViewportPoint((RootPart.CFrame * CFrame.new(0, -2.5, 0)).Position).Y)
                local Width = Height * 0.75
                
                Box.Position = Vector2.new(Pos.X - Width / 2, Pos.Y - Height / 2)
                Box.Size = Vector2.new(Width, Height)
                Box.Visible = Config.ESP.Show_Box

                NameTag.Position = Vector2.new(Pos.X, Pos.Y - Height / 2 - 15)
                NameTag.Visible = Config.ESP.Show_Name
            else
                Box.Visible = false
                NameTag.Visible = false
            end
        else
            Box.Visible = false
            NameTag.Visible = false
        end
    end)

    -- Limpiar ESP cuando el jugador sale
    Player.AncestryChanged:Connect(function()
        if Connection then Connection:Disconnect() end
        if Box then Box:Remove() end
        if NameTag then NameTag:Remove() end
        ESP_Table[Player] = nil
    end)
end

-- Conectar ESP a nuevos jugadores
Players.PlayerAdded:Connect(CreateESP)
-- Crear ESP para jugadores ya existentes
for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

-- 8. LÓGICA DE HITBOX (SIMULADA)
-- Nota: Modificar hitboxes reales requiere hooks avanzados. Aquí simulamos la detección.
local function UpdateHitbox()
    if Config.Hitbox.Enabled then
        print("[Hitbox] Hitbox activada. Tamaño: " .. Config.Hitbox.Size)
        -- Aquí podrías agregar lógica para modificar el tamaño de las partes si el juego lo permite
    else
        print("[Hitbox] Hitbox desactivada.")
    end
end

-- 9. CREACIÓN DE LA INTERFAZ WINDUI

-- Crear ventana principal
local Window = WindUI.CreateWindow({
    Title = "WindUI Hub - By Yanso",
    SubTitle = "v1.0 | Silent Aim + ESP + Hitbox",
    Theme = "Dark" -- O "Light", "Blue", etc.
})

-- Pestaña 1: AIMBOT
local AimbotTab = Window.CreateTab({
    Title = "Aimbot",
    Icon = "aim" -- Icono opcional
})

-- Bienvenida
AimbotTab.CreateLabel({
    Text = "Bienvenido, " .. LocalPlayer.Name .. "! Usa el Aimbot con precaución."
})

-- Toggle Silent Aim
AimbotTab.CreateToggle({
    Title = "Activar Silent Aim",
    Description = "Activa el apuntado automático dentro del FOV.",
    Default = false,
    Callback = function(Value)
        Config.Aimbot.Enabled = Value
        print("[Aimbot] Silent Aim: " .. (Value and "ON" or "OFF"))
    end
})

-- Keybind para Silent Aim
AimbotTab.CreateKeybind({
    Title = "Keybind Silent Aim",
    Description = "Presiona esta tecla para activar/desactivar el Aimbot.",
    Default = Config.Aimbot.Keybind,
    Callback = function(Key)
        Config.Aimbot.Keybind = Key
        print("[Aimbot] Keybind cambiada a: " .. Key.Name)
    end,
    ChangedCallback = function(Key)
        -- Alternar estado al presionar la tecla
        UserInputService.InputBegan:Connect(function(Input, GameProcessed)
            if not GameProcessed and Input.KeyCode == Key then
                Config.Aimbot.Enabled = not Config.Aimbot.Enabled
                print("[Aimbot] Silent Aim alternado a: " .. (Config.Aimbot.Enabled and "ON" or "OFF"))
            end
        end)
    end
})

-- Toggle Mostrar FOV
AimbotTab.CreateToggle({
    Title = "Mostrar Círculo FOV",
    Description = "Muestra u oculta el círculo de campo de visión.",
    Default = true,
    Callback = function(Value)
        Config.Aimbot.FOV_Enabled = Value
        FOV_Circle.Visible = Value and Config.Aimbot.Enabled
    end
})

-- Slider Tamaño FOV
AimbotTab.CreateSlider({
    Title = "Tamaño del FOV",
    Description = "Ajusta el radio del círculo de apuntado.",
    Min = 50,
    Max = 500,
    Default = 150,
    Rounding = 0,
    Callback = function(Value)
        Config.Aimbot.FOV_Radius = Value
        FOV_Circle.Radius = Value
    end
})

-- Pestaña 2: ESP & HITBOX
local ESPHitboxTab = Window.CreateTab({
    Title = "ESP & Hitbox",
    Icon = "eye"
})

-- Sección ESP
ESPHitboxTab.CreateLabel({
    Text = "--- ESP (Wallhack) ---"
})

-- Toggle ESP
ESPHitboxTab.CreateToggle({
    Title = "Activar ESP",
    Description = "Muestra cajas y nombres de los enemigos.",
    Default = false,
    Callback = function(Value)
        Config.ESP.Enabled = Value
        -- Actualizar visibilidad de todos los ESPs existentes
        for _, Data in pairs(ESP_Table) do
            Data.Box.Visible = Value and Config.ESP.Show_Box
            Data.NameTag.Visible = Value and Config.ESP.Show_Name
        end
        print("[ESP] ESP: " .. (Value and "ON" or "OFF"))
    end
})

-- Keybind ESP
ESPHitboxTab.CreateKeybind({
    Title = "Keybind ESP",
    Description = "Presiona esta tecla para activar/desactivar el ESP.",
    Default = Config.ESP.Keybind,
    Callback = function(Key)
        Config.ESP.Keybind = Key
        print("[ESP] Keybind cambiada a: " .. Key.Name)
    end,
    ChangedCallback = function(Key)
        UserInputService.InputBegan:Connect(function(Input, GameProcessed)
            if not GameProcessed and Input.KeyCode == Key then
                Config.ESP.Enabled = not Config.ESP.Enabled
                print("[ESP] ESP alternado a: " .. (Config.ESP.Enabled and "ON" or "OFF"))
                -- Actualizar visibilidad
                for _, Data in pairs(ESP_Table) do
                    Data.Box.Visible = Config.ESP.Enabled and Config.ESP.Show_Box
                    Data.NameTag.Visible = Config.ESP.Enabled and Config.ESP.Show_Name
                end
            end
        end)
    end
})

-- Toggle Team Check
ESPHitboxTab.CreateToggle({
    Title = "Team Check Automático",
    Description = "Evita mostrar ESP en aliados. Detecta sistema de equipos automáticamente.",
    Default = true,
    Callback = function(Value)
        Config.ESP.Check_Teams = Value
        if Value then
            DetectTeamSystem() -- Re-detectar al activar
        end
        print("[ESP] Team Check: " .. (Value and "ON" or "OFF"))
    end
})

-- Sección Hitbox
ESPHitboxTab.CreateLabel({
    Text = "--- Hitbox Configuration ---"
})

-- Toggle Hitbox
ESPHitboxTab.CreateToggle({
    Title = "Activar Hitbox Expandida",
    Description = "Simula una hitbox más grande para facilitar impactos.",
    Default = false,
    Callback = function(Value)
        Config.Hitbox.Enabled = Value
        UpdateHitbox()
    end
})

-- Keybind Hitbox
ESPHitboxTab.CreateKeybind({
    Title = "Keybind Hitbox",
    Description = "Presiona esta tecla para activar/desactivar la Hitbox.",
    Default = Config.Hitbox.Keybind,
    Callback = function(Key)
        Config.Hitbox.Keybind = Key
        print("[Hitbox] Keybind cambiada a: " .. Key.Name)
    end,
    ChangedCallback = function(Key)
        UserInputService.InputBegan:Connect(function(Input, GameProcessed)
            if not GameProcessed and Input.KeyCode == Key then
                Config.Hitbox.Enabled = not Config.Hitbox.Enabled
                UpdateHitbox()
            end
        end)
    end
})

-- Slider Tamaño Hitbox
ESPHitboxTab.CreateSlider({
    Title = "Tamaño de Hitbox",
    Description = "Ajusta el tamaño de la hitbox (simulado).",
    Min = 1,
    Max = 20,
    Default = 5,
    Rounding = 0,
    Callback = function(Value)
        Config.Hitbox.Size = Value
        print("[Hitbox] Tamaño cambiado a: " .. Value)
    end
})

-- Toggle Hitbox Invisible
ESPHitboxTab.CreateToggle({
    Title = "Hitbox Invisible",
    Description = "Usa HumanoidRootPart en lugar de Head para apuntar.",
    Default = false,
    Callback = function(Value)
        Config.Hitbox.Invisible = Value
        print("[Hitbox] Hitbox Invisible: " .. (Value and "ON" or "OFF"))
    end
})

-- 10. INICIALIZACIÓN FINAL
print("[WindUI Hub] Script cargado completamente.")
DetectTeamSystem() -- Detectar equipos al inicio
