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

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = mapList,
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

-- Chapter Auswahl nebeneinander (Rayfield nutzt vertikale Listen, 
-- daher gruppieren wir sie in kleine Sections für bessere Übersicht)
MainTab:CreateSection("Chapter Auswahl (Aktuell: " .. tostring(selectedChapter) .. ")")

-- Um sie optisch "nebeneinander" zu wirken, nutzen wir hier eine kompakte Darstellung
local chaps = {}
for i = 1, 10 do table.insert(chaps, tostring(i)) end

MainTab:CreateDropdown({
    Name = "Schnellwahl Chapter",
    Options = chaps,
    CurrentOption = "1",
    Callback = function(Option)
        selectedChapter = tonumber(Option)
        Rayfield:Notify({Title = "Kapitel", Content = "Kapitel " .. Option .. " gewählt."})
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
        
        -- Listener für die ID
        local connection
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                currentLobbyID = args[1]
                connection:Disconnect()
            end
        end)

        -- 1. Teleport
        Rayfield:Notify({Title="Schritt 1", Content="Teleport zur Queue..."})
        task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)

        -- 2. Warten auf ID
        local start = tick()
        while not currentLobbyID and (tick() - start < 10) do task.wait(0.1) end
        
        if currentLobbyID then
            Rayfield:Notify({Title="Schritt 2", Content="ID erhalten: " .. tostring(currentLobbyID)})
            task.wait(0.8) -- Wichtig für Map-Erstellung
            
            -- 3. Map erstellen/bestätigen
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
            print("ConfirmMap gesendet")

            task.wait(0.6) -- Zeit lassen, damit das Spiel die Map lädt
            
            -- 4. Start Signal (Dein Screenshot-Fix)
            signalEvent:FireServer(currentLobbyID, "StartGame")
            Rayfield:Notify({Title="Erfolg", Content="Spiel wird gestartet!"})
        else
            if connection then connection:Disconnect() end
            Rayfield:Notify({Title="Fehler", Content="Timeout: Keine Lobby ID."})
        end
    end,
})
