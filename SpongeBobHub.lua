local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Timer Killer", LoadingTitle = "Lade Konfiguration..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- AKTUELLE AUSWAHL
local selectedMap = "ConchStreet"
local selectedChapter = 1
local selectedDifficulty = 1
local selectedMode = "Game"

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

-- Map Dropdown
MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = mapList,
    CurrentOption = "ConchStreet",
    Callback = function(Option) selectedMap = Option end,
})

-- Chapter Dropdown (Neu statt Buttons)
MainTab:CreateDropdown({
    Name = "Wähle Chapter",
    Options = {"1","2","3","4","5","6","7","8","9","10"},
    CurrentOption = "1",
    Callback = function(Option) selectedChapter = tonumber(Option) end,
})

-- Difficulty Dropdown (Werte 1-4)
MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        local diffs = {Normal = 1, Hard = 2, Nightmare = 3, DavyJones = 4}
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
        
        -- Listener für die Lobby ID
        local connection
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                currentLobbyID = args[1]
                connection:Disconnect()
            end
        end)

        -- 1. In die Queue gehen
        task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)

        -- 2. Warten auf ID
        local timeout = tick()
        while not currentLobbyID and (tick() - timeout < 10) do task.wait(0.1) end
        
        if currentLobbyID then
            Rayfield:Notify({Title="ID Gefunden", Content="Starte Setup für Lobby: " .. tostring(currentLobbyID)})
            task.wait(1.0) -- Erhöhte Pause für Server-Sync
            
            -- 3. MAP ERSTELLEN (ConfirmMap)
            -- Die Argumente müssen exakt in dieser Reihenfolge im Table sein
            local mapConfig = {
                ["Difficulty"] = selectedDifficulty,
                ["Chapter"] = selectedChapter,
                ["Endless"] = false,
                ["World"] = selectedMap,
                ["Mode"] = selectedMode 
            }
            
            -- Wichtig: Erst die ID, dann der Command "ConfirmMap", dann das Config-Table
            signalEvent:FireServer(currentLobbyID, "ConfirmMap", mapConfig)
            
            task.wait(0.8) -- Zeit für die Map-Erstellung lassen
            
            -- 4. START SIGNAL (Screenshot-Fix)
            -- Wie in deinem Bild gesehen: ID gefolgt von "StartGame"
            signalEvent:FireServer(currentLobbyID, "StartGame")
            
            Rayfield:Notify({Title="Erfolg", Content="Map gewählt & Startbefehl gesendet!"})
        else
            if connection then connection:Disconnect() end
            Rayfield:Notify({Title="Fehler", Content="Timeout: Keine Lobby ID erhalten."})
        end
    end,
})
