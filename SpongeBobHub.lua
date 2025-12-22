local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Auto-Join", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Einstellungen
local targetMap = "ConchStreet" 
local targetDifficulty = 1 
local targetChapter = 1
local targetEndless = false

-- 1. FastTravel Controller laden
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

MainTab:CreateInput({
    Name = "Map Name (Intern)",
    PlaceholderText = "z.B. ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) targetMap = text end,
})

MainTab:CreateButton({
    Name = "AUTO JOIN & START (Fixed Path)",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt!"})
            return 
        end

        -- == WICHTIG: PFADE KORRIGIERT ==
        -- Wir definieren den Ordner exakt, damit er ihn garantiert findet
        local remoteFolder = ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents")
        if not remoteFolder then
            Rayfield:Notify({Title="Fehler", Content="Ordner 'ReplicaRemoteEvents' fehlt!"})
            return
        end

        local createEvent = remoteFolder:FindFirstChild("Replica_ReplicaCreate")
        -- HIER lag der Fehler: Wir suchen es jetzt direkt im Ordner
        local signalEvent = remoteFolder:FindFirstChild("Replica_ReplicaSignal") 

        if not createEvent or not signalEvent then
            Rayfield:Notify({Title="Fehler", Content="Remote Events nicht gefunden!"})
            print("Create:", createEvent, "Signal:", signalEvent)
            return
        end

        Rayfield:Notify({Title="Status", Content="Warte auf Teleport..."})

        -- 1. Listener aufbauen (Die Falle)
        local capturedID = nil
        local connection = nil

        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            local id = args[1]
            if id and type(id) == "number" then
                capturedID = id
                connection:Disconnect() -- Sofort trennen, wir haben die ID
            end
        end)

        -- 2. Teleportieren
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- 3. Warten auf ID (Max 8 Sekunden)
        local startTime = tick()
        repeat task.wait(0.1) until capturedID or (tick() - startTime > 8)
        
        if connection then connection:Disconnect() end

        -- 4. Aktion ausführen
        if capturedID then
            Rayfield:Notify({Title="Erfolg", Content="Lobby ID: " .. capturedID})
            print("Gefundene ID:", capturedID)
            
            task.wait(0.5) 

            -- MAP BESTÄTIGEN
            -- Wir nutzen exakt die Struktur aus deinem Snippet
            local args = {
                [1] = capturedID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = targetDifficulty,
                    ["Chapter"] = targetChapter,
                    ["Endless"] = targetEndless,
                    ["World"] = targetMap, 
                },
            }
            
            signalEvent:FireServer(unpack(args))
            Rayfield:Notify({Title="Config", Content="Map bestätigt!"})
            print("ConfirmMap gesendet.")

            task.wait(1.0) -- Wichtig: Kurz warten, damit der Server speichert

            -- SPIEL STARTEN
            -- Wir suchen den Invoker (meistens direkt in ReplicatedStorage, nicht im Ordner)
            local invoker = ReplicatedStorage:FindFirstChild("MatchStartInvoker", true)
            
            if invoker then
                invoker:InvokeServer(capturedID)
                Rayfield:Notify({Title="Gestartet", Content="Teleport ins Match..."})
            else
                Rayfield:Notify({Title="Warnung", Content="MatchStartInvoker fehlt - versuche Fallback"})
                -- Fallback: Manchmal geht Start auch über das Signal Event
                signalEvent:FireServer(capturedID, "RequestStart") -- Nur ein Versuch
            end

        else
            Rayfield:Notify({Title="Timeout", Content="Keine Lobby ID bekommen."})
        end
    end,
})
