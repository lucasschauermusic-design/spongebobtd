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

-- Maps aus deinen Screenshots
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

-- Suchfunktion
local function DeepFind(name, className)
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == name and (not className or desc:IsA(className)) then
            return desc
        end
    end
    return nil
end

MainTab:CreateSection("Map & Schwierigkeit")

-- Dropdown für Maps
MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = mapList,
    CurrentOption = "ConchStreet",
    Callback = function(Option)
        selectedMap = Option
    end,
})

-- Dropdown für Difficulty (Angepasste Werte)
MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        if Option == "Normal" then selectedDifficulty = 1
        elseif Option == "Hard" then selectedDifficulty = 2
        elseif Option == "Nightmare" then selectedDifficulty = 3
        elseif Option == "DavyJones" then selectedDifficulty = 4
        end
    end,
})

MainTab:CreateSection("Chapter Auswahl (Aktuell: " .. tostring(selectedChapter) .. ")")

-- Buttons für Chapter 1-10
for i = 1, 10 do
    MainTab:CreateButton({
        Name = "Chapter " .. i,
        Callback = function()
            selectedChapter = i
            Rayfield:Notify({Title = "Chapter gesetzt", Content = "Kapitel " .. i .. " ausgewählt."})
        end,
    })
end

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

        Rayfield:Notify({Title="Status", Content="Teleportiere zur Queue..."})
        task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)

        local start = tick()
        while not currentLobbyID and (tick() - start < 10) do task.wait(0.1) end
        
        if currentLobbyID then
            Rayfield:Notify({Title="ID Gefunden", Content="Lobby: " .. tostring(currentLobbyID)})
            task.wait(0.6)
            
            -- MAP & SETTINGS BESTÄTIGEN
            local confirmArgs = {
                [1] = currentLobbyID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = selectedDifficulty,
                    ["Chapter"] = selectedChapter,
                    ["Endless"] = false,
                    ["World"] = selectedMap,
                    ["Mode"] = selectedMode 
                }
            }
            signalEvent:FireServer(unpack(confirmArgs))
            
            task.wait(0.4)
            
            -- START SIGNAL (Dein Screenshot-Fix)
            signalEvent:FireServer(currentLobbyID, "StartGame")
            
            Rayfield:Notify({Title="Erfolg", Content="Spiel wird gestartet!"})
        else
            if connection then connection:Disconnect() end
            Rayfield:Notify({Title="Timeout", Content="ID nicht gefunden."})
        end
    end,
})
