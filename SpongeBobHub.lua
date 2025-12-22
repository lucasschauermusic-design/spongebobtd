local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Traffic Spy", LoadingTitle = "Hooking Network..."})
local Tab = Window:CreateTab("Spy", 4483362458)

local isSpying = false

Tab:CreateToggle({
    Name = "Netzwerk-Spion aktivieren",
    CurrentValue = false,
    Callback = function(val)
        isSpying = val
        if val then
            Rayfield:Notify({Title="Aktiv", Content="Drücke jetzt BEREIT!"})
            print("\n--- SPION SCHARF GESTELLT ---")
            print("Warte auf Signale...")
        else
            print("--- SPION DEAKTIVIERT ---")
        end
    end,
})

-- Wir nutzen einen Hook auf die interne "Namecall"-Methode
-- Das fängt ALLES ab, was an den Server gesendet wird
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if isSpying and (method == "FireServer" or method == "InvokeServer") then
        -- Wir filtern unwichtige Hintergrund-Dinge raus
        if not self.Name:find("Analytics") and not self.Name:find("Log") and not self.Name:find("Sound") then
            print("------------------------------------------------")
            warn("!!! SIGNAL ABGEFANGEN !!!")
            print("Name: " .. self.Name)
            print("Pfad: " .. self:GetFullName())
            print("Methode: " .. method)
            
            -- Argumente auflisten (Was wird gesendet?)
            for i, v in pairs(args) do
                print("Arg " .. i .. ": " .. tostring(v))
            end
            print("------------------------------------------------")
        end
    end

    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
