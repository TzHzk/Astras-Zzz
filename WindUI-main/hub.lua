-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local ValidKey = "Testing 2" -- <--- AQUÍ DEFINES TU CLAVE
local KeyEntered = false

-- ... (código de la ventana de key) ...

KeyTab:Input({
    Title = "Clave de Acceso",
    Placeholder = "Escribe tu clave aquí...",
    Callback = function(key)
        if key == ValidKey then -- <--- AQUÍ SE VERIFICA SI LA CLAVE ES CORRECTA
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
