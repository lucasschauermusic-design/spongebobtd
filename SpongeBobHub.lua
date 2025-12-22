local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Teleport Master", LoadingTitle = "Lade FastTravel..."})
local MainTab = Window:CreateTab("Reisen", 4483362458)

-- Variable für den Welt-Namen
local targetWorld = "Bikini Bottom" -- Standard-Wert

-- Wir suchen und laden den Controller sofort beim Start
local FastTravel = nil
local scripts = game:GetService("Players").LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        local ok, res = pcall(require, mod)
        if ok then FastTravel = res end
        break
    end
end

if not FastTravel then
    Rayfield:Notify({Title="Fehler", Content="FastTravelController nicht gefunden!"})
end

-- UI ELEMENTE
if MainTab then
    -- 1. Eingabefeld für Welt-Namen
    MainTab:CreateInput({
        Name = "Ziel-Name (z.B. World 1)",
        PlaceholderText = "Gib hier einen Namen ein...",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            targetWorld = text
        end,
    })

    -- 2. Button für die normale "Travel" Funktion
    MainTab:CreateButton({
        Name = "Reisen (Travel)",
        Callback = function()
            if FastTravel and FastTravel.Travel then
                print("Versuche Reise nach: " .. targetWorld)
                -- Wir probieren es als Argument
                FastTravel:Travel(targetWorld)
                
                Rayfield:Notify({Title="Befehl gesendet", Content="Reise nach " .. targetWorld})
            else
                Rayfield:Notify({Title="Fehler", Content="Controller nicht geladen!"})
            end
        end,
    })

    -- 3. Button für den Auto-Join (Der geheime Trick)
    MainTab:CreateButton({
        Name = "Auto-Join (Leere Queue)",
        Callback = function()
            if FastTravel and FastTravel._attemptTeleportToEmptyQueue then
                print("Starte Auto-Join...")
                -- Oft brauchen interne Funktionen 'self' nicht, oder doch. Wir testen beides sicherheitshalber.
                pcall(function() FastTravel:_attemptTeleportToEmptyQueue() end)
                
                Rayfield:Notify({Title="Auto-Join", Content="Versuche Teleport..."})
            else
                Rayfield:Notify({Title="Fehler", Content="Funktion nicht verfügbar!"})
            end
        end,
    })
    
    -- 4. Notfall-Button für PlayScreen (Falls FastTravel nicht geht)
    MainTab:CreateButton({
        Name = "PlayScreen: Queue Join",
        Callback = function()
            -- Wir suchen kurz den PlayScreen, den du im Scan hattest
            for _, mod in pairs(scripts:GetDescendants()) do
                if mod.Name == "PlayScreen" and mod:IsA("ModuleScript") then
                    local ok, res = pcall(require, mod)
                    if ok and res._tryTravelToQueue then
                        res:_tryTravelToQueue()
                        Rayfield:Notify({Title="PlayScreen", Content="Join-Versuch gestartet!"})
                    end
                end
            end
        end,
    })
end
