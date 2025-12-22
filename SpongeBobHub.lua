local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Ultimate", LoadingTitle = "Startklar..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- Standardwerte (als reine Daten)
local config = {
    map = "ChumBucket",
    diff = 1,
    chapter = 1
}

MainTab:CreateSection("Einstellungen")

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ChumBucket",
    Callback = function(Option) 
        -- Hier speichern wir es direkt als String ab
        config.map = tostring(Option)
    end,
})

MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        local diffs = {Normal = 1, Hard = 2, Nightmare = 3, DavyJones = 4}
        config.diff = diffs[Option] or 1
    end,
})

MainTab:CreateSection("Start")

MainTab:CreateButton({
    Name = "🚀 START (Clean Data Mode)",
    Callback = function()
        -- 1. DATEN "WASCHEN" (Das ist der Trick!)
        -- Wir erstellen lokale Kopien, die sich nicht mehr ändern können.
        local targetMap = tostring(config.map)
        local targetDiff = tonumber(config.diff)
        local targetChapter = tonumber(config.chapter)

        print("Starte Logik für: " .. targetMap .. " (Diff: " .. targetDiff .. ")")

        -- 2. LISTENER STARTEN (Exakt dein funktionierender Code)
        local connection
        connection = createEvent.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect()
                
                print("Lobby gefunden: " .. lobbyID)
                
                -- Die magische Pause
                task.wait(2.0)
                
                -- Paket bauen mit den "sauberen" Variablen von oben
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = targetDiff,
                        ["Chapter"] = targetChapter,
                        ["Endless"] = false,
                        ["World"] = targetMap -- Hier kommt jetzt garantiert ein String rein
                    }
                }
                
                signalEvent:FireServer(table.unpack(packet))
                warn(">>> Map gesendet: " .. targetMap)
                
                task.wait(1.5)
                signalEvent:FireServer(lobbyID, "StartGame")
            end
        end)

        -- 3. TELEPORT
        local FastTravel = nil
        for _, mod in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetDescendants()) do
            if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
                pcall(function() FastTravel = require(mod) end)
                break
            end
        end
        
        if FastTravel then
            -- Ganz kurz warten, damit der Listener sicher "hört"
            task.wait(0.1)
            task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)
        end
    end,
})
