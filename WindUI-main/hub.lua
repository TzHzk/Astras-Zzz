-- ASTRA HUB ZZ - Usando KeySystem NATIVO de WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Txzp/Astras-Zzz/main/WindUI-main/dist/main.lua"))()

-- Crear la ventana CON la configuración KeySystem integrada
local Window = WindUI:CreateWindow({
    Title = "ASTRA HUB ZZ",
    Theme = "Dark",
    Size = UDim2.fromOffset(480, 420),
    Folder = "AstraHubZZ", -- Importante para guardar la clave
    
    -- CONFIGURACIÓN DEL KEYSYSTEM NATIVO
    KeySystem = {
        Title = "Verificación de Licencia", -- Título de la ventana de clave
        Note = "Introduce tu clave para acceder a AstraHub ZZ.", -- Texto de ayuda
        Key = "Testing 2", -- <--- TU CLAVE AQUÍ
        SaveKey = true,    -- Guarda la clave para no pedirla la próxima vez
    }
})

-- Si el código llega aquí, significa que la clave YA fue verificada y es correcta.
-- El script se detuvo arriba hasta que introdujiste la clave correcta.

print("✅ Clave correcta. Cargando interfaz...")

-- Ahora creas tus Tabs y Elementos normales del Hub
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })

MainTab:Paragraph({
    Title = "Bienvenido a AstraHub ZZ",
    Desc = "Has ingresado correctamente con la clave 'Testing 2'."
})

MainTab:Slider({
    Title = "Velocidad",
    Value = { Min = 16, Max = 100, Default = 16 },
    Callback = function(v) 
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})

MainTab:Toggle({
    Title = "ESP Highlight",
    Value = false,
    Callback = function(state)
        print("ESP:", state)
    end
})

print(" Hub cargado completamente.")
