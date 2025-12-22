-- === EINSTELLUNGEN ===
local TARGET_MAP = "ConchStreet"
local DIFFICULTY = 1 
local CHAPTER = 1

-- === SERVICES ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Pfade für Replica
local ReplicaEvents = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents")
local ReplicaSignal = ReplicaEvents:WaitForChild("Replica_ReplicaSignal")
local ReplicaCreate = ReplicaEvents:WaitForChild("Replica_ReplicaCreate")

-- Pfad für den Teleport-Service (Der "letzte Schritt")
local TeleportServiceRF = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.PlaceTeleportService.RF.Teleport

print("--- Script gestartet: Warte auf Lobby-ID ---")

-- 1. LISTENER: Wir warten darauf, dass wir eine Lobby bekommen (ID fangen)
local connection
connection = ReplicaCreate.OnClientEvent:Connect(function(replicaId, typeDef, replicaData)
    
    -- Prüfen: Gehört diese Lobby uns?
    if replicaData and replicaData.LobbyOwner == LocalPlayer then
        print(">> [SCHRITT 1] Lobby ID gefangen: " .. tostring(replicaId))
        
        -- Daten vorbereiten (Genau wie im Spy)
        local confirmData = {
            ["Difficulty"] = DIFFICULTY,
            ["Chapter"] = CHAPTER,
            ["Endless"] = false,
            ["World"] = TARGET_MAP
        }

        -- [SCHRITT 2] Map Einstellungen senden (via Replica)
        print(">> [SCHRITT 2] Sende Map-Bestätigung (Replica)...")
        ReplicaSignal:FireServer(replicaId, "ConfirmMap", confirmData)
        
        task.wait(0.2) -- Kurz atmen lassen

        -- [SCHRITT 3] Der Finale Teleport-Call (InvokeServer)
        print(">> [SCHRITT 3] Führe InvokeServer aus (Start)...")
        
        -- Wir nutzen die Argumente für den Start
        local args = { "Game", TARGET_MAP, DIFFICULTY, false }
        
        local success, err = pcall(function()
            TeleportServiceRF:InvokeServer(unpack(args))
        end)

        if success then
            print(">> InvokeServer erfolgreich gesendet!")
        else
            warn("Fehler bei InvokeServer: " .. tostring(err))
        end
        
        -- Aufräumen
        connection:Disconnect()
    end
end)

-- === TELEPORT TO EMPTY LOBBY (Der Auslöser) ===
-- Wir teleportieren den Spieler zum nächsten freien Kreis, um den Prozess zu starten.

local function teleportToPad()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    print(">> Suche freien Lobby-Kreis...")
    
    -- Wir suchen im Workspace nach den Kreisen (Namen variieren oft, meist "Lifts", "Lobbies", "Pads")
    local padsFolder = workspace:FindFirstChild("Lifts") or workspace:FindFirstChild("Lobbies") or workspace:FindFirstChild("Teleports")
    
    if padsFolder then
        for _, pad in pairs(padsFolder:GetChildren()) do
            -- Prüfen ob der Kreis frei ist (Oft gibt es ein Attribut oder man prüft ob wer drauf steht)
            -- Hier teleportieren wir einfach zum ersten gefundenen Pad, das "Status" Teile hat
            if pad:FindFirstChild("Part") or pad:FindFirstChild("Pad") then
                local targetPart = pad:FindFirstChild("Part") or pad:FindFirstChild("Pad") or pad.PrimaryPart
                
                if targetPart then
                    print(">> Teleportiere zu Pad: " .. pad.Name)
                    character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                    return -- Fertig, der Rest passiert im Listener oben
                end
            end
        end
        warn("Keine Pads gefunden! Versuche Fallback...")
    else
        warn("Konnte Pad-Ordner nicht finden. Bitte manuell in einen Kreis laufen!")
    end
end

-- Starten
teleportToPad()
