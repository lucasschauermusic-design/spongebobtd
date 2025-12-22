local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Timer Killer", LoadingTitle = "Lade Konfiguration..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- AKTUELLE AUSWAHL
local selectedMap = "ConchStreet"
local selectedChapter = 1
local selectedDifficulty = 1 -- Standard: Normal

local mapList = {
    "ChumBucket", 
    "ConchStreet", 
    "JellyfishFields", 
    "KampKoral", 
    "KrustyKrab", 
    "RockBottom", 
    "SandysTreedome"
}

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

MainTab:CreateSection("Konfiguration")

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = mapList,
    CurrentOption = "ConchStreet",
    Callback = function(Option) selectedMap = Option end,
})

MainTab:CreateDropdown({
    Name = "Wähle Chapter",
    Options = {"1","2","3","4","5","6","7","8","9","10"},
    CurrentOption = "1",
    Callback = function(Option) selectedChapter = tonumber(Option) end,
})

-- Difficulty basierend auf deinen Logs: Normal = 1, Hard = 2
MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        local diffs = {
            ["Normal"] = 1, 
            ["Hard"] = 2, 
            ["Nightmare"] = 3, 
            ["DavyJones"] = 4
        }
        selectedDifficulty = diffs[Option] or 1
    end,
})

MainTab:CreateSection("Aktion")

MainTab:CreateButton({
    Name = "🚀 FULL AUTO START",
    Callback = function()
        local signalEvent = DeepFind("Replica_ReplicaSignal", "RemoteEvent")
        local createEvent = DeepFind("Replica_ReplicaCreate", "RemoteEvent")
        
        if not signalEvent or not createEvent or not FastTravel then 
             Rayfield:Notify({Title="Fehler", Content="Events/Module nicht gefunden!"})
             return 
        end

        local currentLobbyID = nil
        
        local connection
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                currentLobbyID = args[1]
                connection:Disconnect()
            end
        end)

        task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)

        local timeout = tick()
        while not currentLobbyID and (tick() - timeout < 10) do task.wait(0.1) end
        
        if currentLobbyID then
            Rayfield:Notify({Title="ID Gefunden", Content="Lobby: " .. tostring(currentLobbyID)})
            task.wait(1.2) -- Zeit für Server-Sync
            
            -- EXAKTE REPLIKATION DEINER LOGS:
            local packet = {
                [1] = currentLobbyID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = selectedDifficulty,
                    ["Chapter"] = selectedChapter,
                    ["Endless"] = false,
                    ["World"] = selectedMap,
                }
            }
            
            -- Senden mit table.unpack für exakte Struktur
            signalEvent:FireServer(table.unpack(packet))
            
            task.wait(0.8)
            
            -- Finaler Start-Befehl (aus dem ersten Screenshot)
            signalEvent:FireServer(currentLobbyID, "StartGame")
            
            Rayfield:Notify({Title="Erfolg", Content="Map erstellt & Start gefeuert!"})
        else
            if connection then connection:Disconnect() end
            Rayfield:Notify({Title="Fehler", Content="Lobby ID nicht erhalten."})
        end
    end,
})
