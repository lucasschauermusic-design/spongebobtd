local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "DEBUG MODE", LoadingTitle = "Diagnose..."})
local MainTab = Window:CreateTab("Debug", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- Standardwerte setzen
local selectedMap = "ConchStreet"
local selectedDifficulty = 1

MainTab:CreateSection("1. Auswahl treffen")

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ConchStreet",
    Callback = function(Option)
        selectedMap = Option
        -- DEBUG: Zeige sofort an, was ausgewählt wurde und welcher Datentyp es ist
        print("[DEBUG UI] Map geändert zu:", Option, " | Typ:", type(Option))
    end,
})

MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        local diffs = {Normal = 1, Hard = 2, Nightmare = 3, DavyJones = 4}
        selectedDifficulty = diffs[Option] or 1
        print("[DEBUG UI] Diff geändert zu:", selectedDifficulty, " | Typ:", type(selectedDifficulty))
    end,
})

MainTab:CreateSection("2. Aktivieren & Testen")

MainTab:CreateButton({
    Name = "🛑 DEBUG LISTENER AKTIVIEREN",
    Callback = function()
        print("-------------------------------------------------")
        print("[DEBUG START] Button gedrückt. Initialisiere...")
        
        -- 1. Wir frieren die Werte ein und prüfen sie
        local finalMap = selectedMap
        local finalDiff = selectedDifficulty
        
        print("[DEBUG CHECK] Gespeicherte Map:", finalMap, " (Typ: " .. type(finalMap) .. ")")
        print("[DEBUG CHECK] Gespeicherte Diff:", finalDiff, " (Typ: " .. type(finalDiff) .. ")")
        
        if type(finalMap) ~= "string" then
            warn("[CRITICAL ERROR] Map ist kein String! Map ist: " .. tostring(finalMap))
        end

        print("[DEBUG STATUS] Warte jetzt auf Replica_ReplicaCreate Event...")
        print(">>> BITTE JETZT MANUELL IN DIE QUEUE LAUFEN <<<")

        -- 2. Der Listener
        local connection
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            local lobbyID = args[1]
            
            print("[DEBUG EVENT] Event gefeuert! Argumente empfangen: " .. #args)
            print("[DEBUG EVENT] Erstes Argument (LobbyID):", lobbyID, " | Typ:", type(lobbyID))

            if type(lobbyID) == "number" then
                connection:Disconnect()
                print("[DEBUG SUCCESS] Gültige Lobby ID gefunden: " .. lobbyID)
                
                print("[DEBUG WAIT] Warte 2.0 Sekunden auf Server-Sync...")
                task.wait(2.0)
                
                -- Paket zusammenbauen
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = finalDiff,
                        ["Chapter"] = 1,
                        ["Endless"] = false,
                        ["World"] = finalMap
                    }
                }
                
                print("[DEBUG PACKET] Sende folgendes Paket:")
                print("   -> ID:", packet[1])
                print("   -> Command:", packet[2])
                print("   -> World:", packet[3].World)
                print("   -> Difficulty:", packet[3].Difficulty)

                -- Senden
                signalEvent:FireServer(table.unpack(packet))
                warn("[DEBUG ACTION] ConfirmMap gesendet!")
                
                task.wait(1.5)
                signalEvent:FireServer(lobbyID, "StartGame")
                warn("[DEBUG ACTION] StartGame gesendet!")
            else
                warn("[DEBUG FAIL] Empfangenes Argument war keine Nummer! Es war: " .. tostring(lobbyID))
            end
        end)
    end,
})
