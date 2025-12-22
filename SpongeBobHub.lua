local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Timer Killer", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- EINSTELLUNGEN
local targetMap = "ConchStreet"
local targetDifficulty = 1 
local targetMode = "Game" 

-- FastTravel Modul finden
local FastTravel = nil
for _, mod in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- Suchfunktion für Remotes
local function DeepFind(name, className)
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == name and (not className or desc:IsA(className)) then
            return desc
        end
    end
    return nil
end

MainTab:CreateButton({
    Name = "🚀 FULL AUTO: JOIN & START",
    Callback = function()
        -- 1. Events finden
        local signalEvent = DeepFind("Replica_ReplicaSignal", "RemoteEvent")
        local createEvent = DeepFind("Replica_ReplicaCreate", "RemoteEvent")
        
        if not signalEvent or not createEvent or not FastTravel then 
             Rayfield:Notify({Title="Fehler", Content="Module oder Events nicht gefunden!"})
             return 
        end

        local currentLobbyID = nil
        
        -- 2. Listener für die Lobby ID starten
        local connection
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                currentLobbyID = args[1]
                connection:Disconnect()
            end
        end)

        -- 3. Teleport zur Queue
        Rayfield:Notify({Title="Status", Content="Teleportiere zur Queue..."})
        task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)

        -- 4. Warten bis ID da ist (max 10 Sek)
        local start = tick()
        while not currentLobbyID and (tick() - start < 10) do task.wait(0.1) end
        
        if currentLobbyID then
            Rayfield:Notify({Title="ID Gefunden", Content="Lobby: " .. tostring(currentLobbyID)})
            task.wait(0.3)
            
            -- 5. Map bestätigen (ConfirmMap)
            local confirmArgs = {
                [1] = currentLobbyID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = targetDifficulty,
                    ["Chapter"] = 1,
                    ["Endless"] = false,
                    ["World"] = targetMap,
                    ["Mode"] = targetMode 
                }
            }
            signalEvent:FireServer(unpack(confirmArgs))
            
            task.wait(0.2) -- Kurze Pause für den Server
            
            -- 6. FORCE START (Das Signal aus deinem Screenshot)
            signalEvent:FireServer(currentLobbyID, "StartGame")
            
            Rayfield:Notify({Title="Erfolg", Content="Start-Signal gesendet!"})
        else
            if connection then connection:Disconnect() end
            Rayfield:Notify({Title="Timeout", Content="Keine Lobby ID erhalten."})
        end
    end,
})

MainTab:CreateSection("Info")
MainTab:CreateLabel("Script wartet nach Klick automatisch auf ID")
