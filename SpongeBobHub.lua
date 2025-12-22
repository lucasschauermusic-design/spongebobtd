local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Teleport Master", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Auto-Join", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Einstellungen
local targetMap = "ConchStreet" -- Hier den internen Map-Namen eintragen (z.B. ConchStreet)
local targetDifficulty = "Hard"

-- 1. FastTravel Controller laden
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- UI erstellen
MainTab:CreateInput({
    Name = "Map Name (Intern)",
    PlaceholderText = "z.B. ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetMap = text
    end,
})

MainTab:CreateButton({
    Name = "AUTO JOIN & START",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel nicht geladen!"})
            return 
        end

        -- A) Wir suchen das Event, das die ID sendet
        local replicaEvents = ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents")
        local createEvent = replicaEvents and replicaEvents:FindFirstChild("Replica_ReplicaCreate")

        if not createEvent then
            Rayfield:Notify({Title="Fehler", Content="Konnte Replica_ReplicaCreate nicht finden!"})
            return
        end

        print("System bereit. Warte auf Teleport...")
        Rayfield:Notify({Title="Status", Content="Teleport gestartet - Warte auf ID..."})

        -- B) Variable für die gefundene ID
        local capturedID = nil
        local connection = nil

        -- C) DIE FALLE STELLEN: Wir hören zu, BEVOR wir uns bewegen
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            -- Laut deinem Snippet ist args[1] die ID und args[2] die Datentabelle
            local id = args[1]
            local data = args[2]

            print("Event empfangen! ID:", id)

            -- Optional: Prüfen, ob wir der Owner sind, um sicherzugehen
            -- (Nimmt die erste ID, die reinkommt, falls Owner-Check fehlschlägt)
            if id and type(id) == "number" then
                capturedID = id
                connection:Disconnect() -- Wir haben, was wir wollten, Verbindung trennen
            end
        end)

        -- D) JETZT erst teleportieren
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- E) Warten bis die ID da ist (mit Timeout, falls es buggt)
        local timeout = 8 -- Sekunden warten maximal
        local startTime = tick()
        
        repeat 
            task.wait(0.1)
        until capturedID or (tick() - startTime > timeout)

        -- Sicherheits-Disconnect, falls Timeout griff
        if connection then connection:Disconnect() end

        -- F) Auswertung
        if capturedID then
            Rayfield:Notify({Title="Erfolg!", Content="Lobby ID erhalten: " .. capturedID})
            print("Lobby ID erfolgreich abgefangen: " .. capturedID)
            
            -- Kurze Pause für Sync
            task.wait(0.5)

            -----------------------------------------------------
            -- SCHRITT G: MAP EINSTELLEN (Replica Signal)
            -----------------------------------------------------
            -- Hinweis: Hier senden wir die Daten an den Server
            local replicaSignal = ReplicatedStorage:FindFirstChild("ReplicaRemoteSignal", true)
            if replicaSignal then
                -- Versuche das typische Format für Updates
                -- Oft muss man spezifizieren, WAS man ändert. 
                -- Wir senden hier die Map-Daten passend zur ID.
                local args = {
                    [1] = capturedID,
                    [2] = {
                        ["Stage"] = targetMap,
                        ["Difficulty"] = targetDifficulty,
                        ["Mode"] = "Story"
                    }
                }
                replicaSignal:FireServer(unpack(args))
                print("Map Daten gesendet.")
            else
                warn("ReplicaRemoteSignal nicht gefunden!")
            end

            task.wait(0.5)

            -----------------------------------------------------
            -- SCHRITT H: SPIEL STARTEN (Invoker)
            -----------------------------------------------------
            local invoker = ReplicatedStorage:FindFirstChild("MatchStartInvoker", true)
            if invoker then
                invoker:InvokeServer(capturedID)
                Rayfield:Notify({Title="Gestartet", Content="Viel Spaß!"})
            else
                Rayfield:Notify({Title="Warnung", Content="MatchStartInvoker nicht gefunden."})
            end

        else
            Rayfield:Notify({Title="Timeout", Content="Keine Lobby-ID innerhalb von 8s erhalten."})
        end
    end,
})
