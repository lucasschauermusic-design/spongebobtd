local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Final Fix", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicaSignal = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local replicaCreate = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- AKTUELLE AUSWAHL
local selectedMap = "ConchStreet"
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
    Name = "🚀 START (No Error Version)",
    Callback = function()
        -- Wir speichern die Auswahl als feste Strings/Zahlen
        local finalMap = tostring(selectedMap)
        local finalDiff = tonumber(selectedDifficulty)
        
        -- Listener aktivieren
        local connection
        connection = replicaCreate.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect()
                
                task.wait(2.2)
                
                -- Das Paket exakt nach deinen Logs bauen
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
                
                -- Senden ohne Text-Verknüpfung (Verhindert den Concatenate Error)
                replicaSignal:FireServer(table.unpack(packet))
                
                task.wait(1.5)
                replicaSignal:FireServer(lobbyID, "StartGame")
            end
        end)

        -- Teleport auslösen
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
