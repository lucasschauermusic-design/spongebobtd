-- Cache-Buster für GitHub
local githubUrl = "https://github.com/lucasschauermusic-design/spongebobtd/edit/main/SpongeBobHub.lua" 
-- Falls du es von GitHub lädst: game:HttpGet(githubUrl .. "?c=" .. tick())

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Final Ultra Fix", LoadingTitle = "Synchronisiere..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- Diese Variablen müssen exakt wie im Snippet behandelt werden
local config = {
    map = "ChumBucket",
    diff = 1,
    chapter = 1
}

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ChumBucket",
    Callback = function(Option) config.map = Option end,
})

MainTab:CreateButton({
    Name = "🚀 AKTIVIEREN (Snippet-Logik)",
    Callback = function()
        -- Wir kopieren DEINE Logik 1-zu-1 hier rein
        local connection
        connection = createEvent.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect()
                
                -- Wichtig: Die 2 Sekunden Pause aus deinem Snippet
                task.wait(2.0)
                
                -- Wir bauen das Paket EXAKT wie in deinem Snippet
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = tonumber(config.diff),
                        ["Chapter"] = tonumber(config.chapter),
                        ["Endless"] = false,
                        ["World"] = tostring(config.map) -- Erzwinge reinen Text
                    }
                }
                
                signalEvent:FireServer(table.unpack(packet))
                
                -- Start-Befehl nach der Map-Wahl
                task.wait(1.5)
                signalEvent:FireServer(lobbyID, "StartGame")
            end
        end)
        
        -- Teleport erst NACHDEM der Listener scharf ist
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
