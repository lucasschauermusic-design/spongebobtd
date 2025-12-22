local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Ultimate Auto-Start", LoadingTitle = "Lade Live-System..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- AKTUELLE AUSWAHL
local selectedMap = "ConchStreet"
local selectedChapter = 1
local selectedDifficulty = 1

local mapList = {
    "ChumBucket", 
    "ConchStreet", 
    "JellyfishFields", 
    "KampKoral", 
    "KrustyKrab", 
    "RockBottom", 
    "SandysTreedome"
}

-- FastTravel Modul
local FastTravel = nil
for _, mod in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

MainTab:CreateSection("Konfiguration")

-- Map Dropdown
MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = mapList,
    CurrentOption = "ConchStreet",
    Callback = function(Option) selectedMap = Option end,
})

-- Chapter Dropdown
MainTab:CreateDropdown({
    Name = "Wähle Chapter",
    Options = {"1","2","3","4","5","6","7","8","9","10"},
    CurrentOption = "1",
    Callback = function(Option) selectedChapter = tonumber(Option) end,
})

-- Difficulty Dropdown (Normal=1, Hard=2, Nightmare=3, DavyJones=4)
MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        local diffs = {["Normal"] = 1, ["Hard"] = 2, ["Nightmare"] = 3, ["DavyJones"] = 4}
        selectedDifficulty = diffs[Option] or 1
    end,
})

MainTab:CreateSection("Aktion")

MainTab:CreateButton({
    Name = "🚀 START LIVE-AUTO-JOIN",
    Callback = function()
        local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
        local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")
        
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel-Modul nicht gefunden!"})
            return 
        end

        Rayfield:Notify({Title="Status", Content="Warte auf Lobby-Erstellung... Gehe jetzt in eine Queue!"})

        -- LIVE-LISTENER (Die Methode, die funktioniert hat)
        local connection
        connection = createEvent.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect() -- Nur für diese eine Lobby ausführen
                
                Rayfield:Notify({Title="ID Abgefangen", Content="Lobby ID: " .. tostring(lobbyID)})
                
                -- Kurze Pause für Server-Sync (wie im Snippet)
                task.wait(2.0)
                
                -- MAP-DATEN SENDEN (Exakt wie in deinen Logs)
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
                
                signalEvent:FireServer(table.unpack(packet))
                Rayfield:Notify({Title="Erfolg", Content="Map-Signal für " .. selectedMap .. " gesendet!"})
                
                -- Optional: Sofort Starten nach der Wahl
                task.wait(0.5)
                signalEvent:FireServer(lobbyID, "StartGame")
            end
        end)

        -- Den Teleport automatisch starten
        task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)
    end,
})
