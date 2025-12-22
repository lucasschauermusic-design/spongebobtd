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

-- 1. FastTravel Controller suchen
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- UI
MainTab:CreateInput({
    Name = "Map Name (Intern)",
    PlaceholderText = "Standard: ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) targetMap = text end,
})

MainTab:CreateButton({
    Name = "AUTO JOIN & START (Ultra Robust)",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel Skript nicht gefunden!"})
            return 
        end

        print("--- STARTE AUTO-JOIN PROZESS ---")

        -- SCHRITT A: REMOTES SICHER FINDEN
        -- Wir nutzen WaitForChild mit Timeout, damit er wartet, falls es noch lädt
        local remoteFolder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
        if not remoteFolder then
             Rayfield:Notify({Title="Fehler", Content="Ordner ReplicaRemoteEvents fehlt!"})
             return
        end

        local createEvent = remoteFolder:WaitForChild("Replica_ReplicaCreate", 5)
        local signalEvent = remoteFolder:WaitForChild("Replica_ReplicaSignal", 5)

        if not createEvent or not signalEvent then
            Rayfield:Notify({Title="Fehler", Content="Remotes konnten nicht geladen werden!"})
            warn("Create Event:", createEvent)
            warn("Signal Event:", signalEvent)
            return
        end
        print("Remotes erfolgreich gefunden.")

        -- SCHRITT B: LISTENER AKTIVIEREN
        local capturedID = nil
        local connection = nil
        
        Rayfield:Notify({Title="Status", Content="Warte auf Teleport & ID..."})

        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            local id = args[1]
            -- Wir nehmen die ID, wenn sie eine Zahl ist
            if type(id) == "number" then
                print(">> EVENT EMPFANGEN! ID: " .. id)
                capturedID = id
                if connection then connection:Disconnect() connection = nil end
            end
        end)

        -- SCHRITT C: TELEPORTIEREN
        task.spawn(function()
            -- Falls die Funktion nicht direkt existiert, probieren wir sie sicher aufzurufen
            if FastTravel._attemptTeleportToEmptyQueue then
                FastTravel:_attemptTeleportToEmptyQueue()
            else
                print("ACHTUNG: _attemptTeleportToEmptyQueue nicht gefunden! Suche Alternative...")
                -- Fallback Versuch falls FastTravel anders aufgebaut ist
                for k,v in pairs(FastTravel) do
                    if type(v) == "function" and (string.find(k, "Empty") or string.find(k, "Join")) then
                        print("Probiere Funktion: " .. k)
                        v()
                    end
                end
            end
        end)

        -- SCHRITT D: WARTEN AUF ID (mit Loop)
        local timeout = 10 -- 10 Sekunden Zeit geben
        local start = tick()
        while not capturedID and (tick() - start < timeout) do
            task.wait(0.1)
        end
        
        -- Sicherstellen, dass Verbindung getrennt ist
        if connection then connection:Disconnect() end

        if not capturedID then
            Rayfield:Notify({Title="Timeout", Content="Keine ID erhalten (Teleport fehlgeschlagen?)"})
            return
        end

        -- SCHRITT E: DATEN SENDEN & STARTEN
        Rayfield:Notify({Title="ID Gefunden", Content="Lobby: " .. capturedID})
        task.wait(0.5)

        -- 1. Map bestätigen (ConfirmMap)
        local confirmArgs = {
            [1] = capturedID,
            [2] = "ConfirmMap",
            [3] = {
                ["Difficulty"] = targetDifficulty,
                ["Chapter"] = targetChapter,
                ["Endless"] = targetEndless,
                ["World"] = targetMap
            }
        }
        signalEvent:FireServer(unpack(confirmArgs))
        print("ConfirmMap gesendet.")
        
        task.wait(1) -- Wichtig: Kurz warten!

        -- 2. Spiel starten (Invoker suchen)
        local invoker = ReplicatedStorage:FindFirstChild("MatchStartInvoker", true)
        if invoker then
            print("Invoker gefunden, starte Match...")
            invoker:InvokeServer(capturedID)
            Rayfield:Notify({Title="Erfolg", Content="Match wird gestartet!"})
        else
            warn("MatchStartInvoker nicht gefunden! Suche im RemoteFolder...")
            -- Fallback: Manchmal ist der Invoker auch in ReplicaRemoteEvents?
            local altInvoker = remoteFolder:FindFirstChild("MatchStartInvoker")
            if altInvoker then
                 altInvoker:InvokeServer(capturedID)
            else
                 Rayfield:Notify({Title="Warnung", Content="Start Invoker nicht gefunden."})
            end
        end
    end,
})
