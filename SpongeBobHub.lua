local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Map Force", LoadingTitle = "Lade Fix..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- EINSTELLUNGEN
local selectedMap = "ChumBucket"
local selectedChapter = 1
local selectedDifficulty = 1

-- FastTravel Modul finden
local FastTravel = nil
for _, mod in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ChumBucket",
    Callback = function(Option) selectedMap = Option end,
})

MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        local diffs = {Normal = 1, Hard = 2, Nightmare = 3, DavyJones = 4}
        selectedDifficulty = diffs[Option] or 1
    end,
})

MainTab:CreateButton({
    Name = "🚀 FORCE START (MAP FIX)",
    Callback = function()
        local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
        local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")
        
        -- LISTENER ZUERST STARTEN
        local connection
        connection = createEvent.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect() 
                
                -- 1. Kurze Pause für Initialisierung
                task.wait(1.5) 
                
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = selectedDifficulty,
                        ["Chapter"] = selectedChapter,
                        ["Endless"] = false,
                        ["World"] = selectedMap
                    }
                }
                
                -- 2. MAP AUSWAHL ERZWINGEN (3x senden zur Sicherheit)
                -- Das stellt sicher, dass der Server die Wahl nicht wegen Timing-Fehlern ignoriert
                for i = 1, 3 do
                    signalEvent:FireServer(table.unpack(packet))
                    task.wait(0.5)
                end
                
                warn("Map-Daten mehrfach gesendet: " .. selectedMap)
                
                -- 3. Längere Pause vor dem Start
                task.wait(2.0)
                
                -- 4. Spiel erst starten, wenn Map sicher gewählt wurde
                signalEvent:FireServer(lobbyID, "StartGame")
                Rayfield:Notify({Title="Erfolg", Content="Map erzwungen und gestartet!"})
            end
        end)

        -- TELEPORT
        if FastTravel then
            task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)
        end
    end,
})
