local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Ultimate", LoadingTitle = "Lade Systeme..."})

-- [[ SERVICES ]] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ REMOTES FINDEN ]] --
local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- Pfad für Game Speed (Knit Framework)
local SpeedRemote
pcall(function()
    SpeedRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.ChangeGameSpeed
end)

-- [[ TAB 1: AUTO START (LOBBY) ]] --
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("Lobby Einstellungen")

-- Wir speichern die Dropdowns in Variablen, um sie später direkt auszulesen (Direct Read Fix)
local MapDropdown = MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ConchStreet",
    Callback = function(Value) end, -- Callback ignoriert
})

local DiffDropdown = MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Value) end, -- Callback ignoriert
})

local ChapterDropdown = MainTab:CreateDropdown({
    Name = "Wähle Chapter",
    Options = {"1","2","3","4","5","6","7","8","9","10"},
    CurrentOption = "1",
    Callback = function(Value) end, -- Callback ignoriert
})

MainTab:CreateSection("Start")

MainTab:CreateButton({
    Name = "🚀 START AUTO-JOIN",
    Callback = function()
        print("--- START PROZESS ---")
        
        -- 1. DATEN DIREKT AUSLESEN (Fix für Rayfield Table-Bug)
        local rawMap = MapDropdown.CurrentOption
        if type(rawMap) == "table" then rawMap = rawMap[1] end
        local finalMap = tostring(rawMap)
        
        local rawDiff = DiffDropdown.CurrentOption
        if type(rawDiff) == "table" then rawDiff = rawDiff[1] end
        local diffTable = {["Normal"] = 1, ["Hard"] = 2, ["Nightmare"] = 3, ["DavyJones"] = 4}
        local finalDiff = diffTable[rawDiff] or 1
        
        local rawChapter = ChapterDropdown.CurrentOption
        if type(rawChapter) == "table" then rawChapter = rawChapter[1] end
        local finalChapter = tonumber(rawChapter) or 1

        print("Konfiguration: " .. finalMap .. " (Diff: " .. finalDiff .. ")")

        -- 2. LISTENER STARTEN
        local connection
        connection = createEvent.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect()
                
                Rayfield:Notify({Title="Lobby gefunden", Content="ID: " .. lobbyID})
                task.wait(2.0) -- Wichtige Pause
                
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = finalDiff,
                        ["Chapter"] = finalChapter,
                        ["Endless"] = false,
                        ["World"] = finalMap
                    }
                }
                
                signalEvent:FireServer(table.unpack(packet))
                Rayfield:Notify({Title="Gesendet", Content="Map: " .. finalMap})
                
                task.wait(1.5)
                signalEvent:FireServer(lobbyID, "StartGame")
            end
        end)

        -- 3. TELEPORT (FastTravel)
        local FastTravel = nil
        for _, mod in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
            if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
                pcall(function() FastTravel = require(mod) end)
                break
            end
        end
        
        if FastTravel then
            task.wait(0.1)
            task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)
        else
            Rayfield:Notify({Title="Fehler", Content="Bitte manuell in Queue laufen!"})
        end
    end,
})


-- [[ TAB 2: GAMEPLAY (INGAME) ]] --
local GameTab = Window:CreateTab("Gameplay", 4483362458) -- Icon ID kann angepasst werden

GameTab:CreateSection("Geschwindigkeit")

GameTab:CreateDropdown({
    Name = "Spielgeschwindigkeit (Game Speed)",
    Options = {"X1", "X2", "X3", "X5", "X7"},
    CurrentOption = "X1",
    Callback = function(Option)
        if not SpeedRemote then
            Rayfield:Notify({Title="Fehler", Content="Speed-Remote nicht gefunden!"})
            return
        end

        -- Extrahiere Zahl aus String (z.B. "X5" -> 5)
        local speedVal = tonumber(string.sub(Option, 2))
        
        -- Versuche Speed zu setzen (mit Error Handling für fehlenden Gamepass)
        local success, err = pcall(function()
            SpeedRemote:InvokeServer(speedVal)
        end)
        
        if success then
            Rayfield:Notify({Title="Erfolg", Content="Speed auf " .. Option .. " gesetzt!"})
        else
            -- Falls der Server blockt (z.B. wegen Gamepass Check), warnen wir nur
            Rayfield:Notify({Title="Server Block", Content="Evtl. Gamepass nötig für " .. Option})
            warn("Speed Change Error: " .. tostring(err))
        end
    end,
})
