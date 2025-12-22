local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Direct Read Fix", LoadingTitle = "Initialisiere..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

MainTab:CreateSection("Einstellungen")

-- 1. WIR SPEICHERN DAS DROPDOWN-OBJEKT IN EINER VARIABLE
local MapDropdown = MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ConchStreet",
    Callback = function(Value) 
        -- Wir machen hier NICHTS mehr, da der Callback kaputt ist (Table statt String)
    end,
})

local DiffDropdown = MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Value)
        -- Auch hier ignorieren wir den Callback
    end,
})

local ChapterDropdown = MainTab:CreateDropdown({
    Name = "Wähle Chapter",
    Options = {"1","2","3","4","5","6","7","8","9","10"},
    CurrentOption = "1",
    Callback = function(Value) end,
})

MainTab:CreateSection("Start")

MainTab:CreateButton({
    Name = "🚀 START (Bypass UI Bug)",
    Callback = function()
        print("--- START PROZESS ---")
        
        -- 2. WIR LESEN DEN WERT DIREKT AUS DEM OBJEKT (Bypass)
        -- Rayfield speichert die aktuelle Auswahl immer in .CurrentOption
        
        -- MAP AUSLESEN
        local rawMap = MapDropdown.CurrentOption
        -- Sicherheitscheck: Falls Rayfield den Wert als Tabelle {"Map"} speichert
        if type(rawMap) == "table" then 
            rawMap = rawMap[1] 
        end
        local finalMap = tostring(rawMap)
        
        -- SCHWIERIGKEIT AUSLESEN & UMRECHNEN
        local rawDiff = DiffDropdown.CurrentOption
        if type(rawDiff) == "table" then rawDiff = rawDiff[1] end
        
        local diffTable = {["Normal"] = 1, ["Hard"] = 2, ["Nightmare"] = 3, ["DavyJones"] = 4}
        local finalDiff = diffTable[rawDiff] or 1
        
        -- CHAPTER AUSLESEN
        local rawChapter = ChapterDropdown.CurrentOption
        if type(rawChapter) == "table" then rawChapter = rawChapter[1] end
        local finalChapter = tonumber(rawChapter) or 1

        print("Gelesene Daten -> Map: " .. finalMap .. " | Diff: " .. finalDiff)

        -- 3. LISTENER STARTEN (Dein funktionierender Code)
        local connection
        connection = createEvent.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect()
                
                print("Lobby ID gefangen: " .. lobbyID)
                task.wait(2.0)
                
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = finalDiff,
                        ["Chapter"] = finalChapter,
                        ["Endless"] = false,
                        ["World"] = finalMap -- Hier ist jetzt garantiert der String drin
                    }
                }
                
                signalEvent:FireServer(table.unpack(packet))
                warn(">>> Map Config gesendet: " .. finalMap)
                
                task.wait(1.5)
                signalEvent:FireServer(lobbyID, "StartGame")
            end
        end)

        -- 4. TELEPORT
        local FastTravel = nil
        for _, mod in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetDescendants()) do
            if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
                pcall(function() FastTravel = require(mod) end)
                break
            end
        end
        
        if FastTravel then
            task.wait(0.1)
            task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)
        end
    end,
})
