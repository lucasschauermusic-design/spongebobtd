-- [[ KONFIGURATION ]] --
-- Hier einfach den Namen ändern, den du willst:
local TARGET_MAP = "JellyfishFields"  -- Optionen: "ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"
local TARGET_DIFFICULTY = 1           -- 1=Normal, 2=Hard, 3=Nightmare, 4=DavyJones
local TARGET_CHAPTER = 1              -- 1 bis 10

-- [[ SERVICES ]] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

print("--- AUTO START GESTARTET FÜR: " .. TARGET_MAP .. " ---")

-- 1. LISTENER VORBEREITEN (Exakt dein funktionierender Code)
local connection
connection = createEvent.OnClientEvent:Connect(function(lobbyID)
    if type(lobbyID) == "number" then
        connection:Disconnect() -- Nur einmal ausführen
        print("Lobby-ID live abgefangen: " .. lobbyID)
        
        -- WICHTIG: Die Pause aus deinem Test (2.0 Sekunden)
        task.wait(2.0)
        
        local packet = {
            [1] = lobbyID,
            [2] = "ConfirmMap",
            [3] = {
                ["Difficulty"] = TARGET_DIFFICULTY,
                ["Chapter"] = TARGET_CHAPTER,
                ["Endless"] = false,
                ["World"] = TARGET_MAP -- Nutzt die Variable von oben
            }
        }
        
        -- Senden
        signalEvent:FireServer(table.unpack(packet))
        warn(">>> MAP-SIGNAL GESENDET: " .. TARGET_MAP .. " <<<")
        
        -- Optional: Starten
        task.wait(1.5)
        signalEvent:FireServer(lobbyID, "StartGame")
        warn(">>> START-SIGNAL GESENDET <<<")
    end
end)

-- 2. TELEPORT AUTOMATISCH AUSFÜHREN
-- Wir suchen das FastTravel Modul und nutzen es, damit du nicht laufen musst
local FastTravel = nil
for _, mod in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

if FastTravel then
    print("FastTravel gefunden, teleportiere in Queue...")
    -- Kurze Verzögerung, damit der Listener sicher bereit ist
    task.wait(0.1) 
    task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)
else
    warn("FastTravel nicht gefunden! Bitte manuell in die Queue laufen.")
end
