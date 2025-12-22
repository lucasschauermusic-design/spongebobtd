local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "DEBUG MODUS", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Debug", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- DEBUG LOGGER
local function Log(msg)
    print("[DEBUG] " .. msg)
    -- Optional: Auch als Notify anzeigen
    -- Rayfield:Notify({Title="Debug", Content=msg})
end

-- 1. FastTravel
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- 2. Signal Sucher mit Print-Ausgabe
local function FindSignalDebug()
    Log("Suche ReplicaRemoteSignal...")
    
    -- Schritt 1: Standard Ordner prüfen
    local folder = ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents")
    if folder then
        Log("Ordner 'ReplicaRemoteEvents' gefunden.")
        local sig = folder:FindFirstChild("Replica_ReplicaSignal")
        if sig then
            Log(">>> SIGNAL GEFUNDEN (Standard): " .. sig:GetFullName())
            return sig
        else
            Log("Signal NICHT im Standard-Ordner.")
            Log("Inhalt des Ordners:")
            for _, c in pairs(folder:GetChildren()) do
                print(" - " .. c.Name .. " (" .. c.ClassName .. ")")
            end
        end
    else
        Log("Ordner 'ReplicaRemoteEvents' NICHT gefunden!")
    end

    -- Schritt 2: Deep Search
    Log("Starte Deep Search im gesamten ReplicatedStorage...")
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == "Replica_ReplicaSignal" then
            Log(">>> SIGNAL GEFUNDEN (Deep Search): " .. desc:GetFullName())
            return desc
        end
    end
    
    Log("!!! CRITICAL: Signal nirgendwo gefunden !!!")
    return nil
end

MainTab:CreateButton({
    Name = "DEBUG START (Nur Setup - Kein TP)",
    Callback = function()
        print("\n\n=== START DEBUG LAUF ===")
        
        -- A) FastTravel Check
        if not FastTravel then 
            Log("FEHLER: FastTravel Module fehlt!") 
            return 
        else
            Log("FastTravel Module geladen.")
        end

        -- B) Signal Suchen
        local signalEvent = FindSignalDebug()
        if not signalEvent then
            Rayfield:Notify({Title="FEHLER", Content="Siehe F9 Konsole!"})
            return
        end

        -- C) ID Event suchen (meistens im gleichen Ordner)
        local createEvent = nil
        if signalEvent.Parent then
            createEvent = signalEvent.Parent:FindFirstChild("Replica_ReplicaCreate")
        end
        
        if not createEvent then
            Log("Warnung: ReplicaCreate nicht neben Signal gefunden. Suche global...")
            for _, d in pairs(ReplicatedStorage:GetDescendants()) do
                if d.Name == "Replica_ReplicaCreate" then 
                    createEvent = d 
                    Log("Create Event gefunden bei: " .. d:GetFullName())
                    break 
                end
            end
        end

        -- D) Listener Setup
        local capturedID = nil
        local connection = nil
        if createEvent then
            Log("Listener aktiviert. Warte auf Event...")
            connection = createEvent.OnClientEvent:Connect(function(...)
                local args = {...}
                Log("Event empfangen! Args: " .. tostring(args[1]))
                if args[1] and type(args[1]) == "number" then
                    capturedID = args[1]
                    Log("ID gespeichert: " .. capturedID)
                    connection:Disconnect()
                end
            end)
        else
            Log("FEHLER: CreateEvent fehlt, kann ID nicht abfangen.")
            return
        end

        -- E) Teleport zum Kreis (AutoJoin)
        Log("Führe AutoJoin aus...")
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- F) Warten auf ID
        local start = tick()
        while not capturedID and (tick() - start < 10) do task.wait(0.1) end
        if connection then connection:Disconnect() end

        if capturedID then
            Rayfield:Notify({Title="ID Gefunden", Content=tostring(capturedID)})
            Log("--- LOBBY SETUP BEGINNT ---")
            task.wait(1.0)

            -- G) ConfirmMap senden
            -- Wir nutzen exakt deine Werte
            local confirmArgs = {
                [1] = capturedID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = 1,
                    ["Chapter"] = 1,
                    ["Endless"] = false,
                    ["World"] = "ConchStreet",
                    ["Mode"] = "Game" 
                }
            }
            
            Log("Sende 'ConfirmMap'...")
            pcall(function() 
                signalEvent:FireServer(unpack(confirmArgs)) 
            end)
            Log("ConfirmMap gesendet. (Schau auf das Lobby-Schild!)")
            
            task.wait(2.0) -- Zeit zum Beobachten

            -- H) RequestStart senden
            Log("Sende 'RequestStart' & 'Start'...")
            pcall(function() signalEvent:FireServer(capturedID, "RequestStart") end)
            pcall(function() signalEvent:FireServer(capturedID, "Start") end)
            
            Rayfield:Notify({Title="Fertig", Content="Signale gesendet. KEIN Teleport."})
            Log("--- DEBUG ENDE ---")
            Log("Bitte prüfen: Startet der Countdown? Zeigt das Schild die Map?")

        else
            Log("TIMEOUT: Keine ID empfangen. Bist du auf dem Kreis gelandet?")
            Rayfield:Notify({Title="Fehler", Content="Keine ID (Timeout)"})
        end
    end,
})
