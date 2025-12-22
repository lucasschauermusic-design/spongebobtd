local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Selection Fix", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicaSignal = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local replicaCreate = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- AKTUELLE AUSWAHL (Standardwerte)
local selectedMap = "ConchStreet"
local selectedChapter = 1
local selectedDifficulty = 1

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ConchStreet",
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
    Name = "🚀 START (Selection Fix)",
    Callback = function()
        -- FIX: Wir speichern die Auswahl JETZT in lokalen Variablen
        local finalMap = selectedMap
        local finalDiff = selectedDifficulty
        local finalChapter = selectedChapter
        
        -- Listener aktivieren, um die Lobby-ID abzufangen
        local connection
        connection = replicaCreate.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect()
                
                -- Kurze Pause für die Stabilität des Spiels
                task.wait(2.0)
                
                -- Das Paket wird mit den vorab festgeschriebenen Werten erstellt
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = finalDiff,
                        ["Chapter"] = finalChapter,
                        ["Endless"] = false,
                        ["World"] = finalMap
                    }
                }
                
                -- Signal an den Server senden
                replicaSignal:FireServer(unpack(packet))
                
                -- Finaler Startbefehl
                task.wait(1.5)
                replicaSignal:FireServer(lobbyID, "StartGame")
            end
        end)

        -- Teleport in die Queue auslösen
        local FastTravel = nil
        for _, mod in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetDescendants()) do
            if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
                pcall(function() FastTravel = require(mod) end)
                break
            end
        end
        
        if FastTravel then
            task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)
        end
    end,
})
