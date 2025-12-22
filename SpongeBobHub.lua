local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade System..."})
local MainTab = Window:CreateTab("Auto-Join", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === EINSTELLUNGEN ===
local targetMap = "ConchStreet" 
local targetDifficulty = 1 
local targetChapter = 1
local targetEndless = false

-- 1. FastTravel Controller laden (für den Weg zum Kreis)
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- 2. Knit Teleport Funktion finden (Dynamisch)
local function GetTeleportFunction()
    -- Wir suchen im Packages/_Index Ordner nach irgendwas mit "acecateer_knit"
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if not packages then return nil end
    local index = packages:FindFirstChild("_Index")
    if not index then return nil end

    for _, child in pairs(index:GetChildren()) do
        if string.find(child.Name, "acecateer_knit") then
            -- Pfad: knit -> Services -> PlaceTeleportService -> RF -> Teleport
            local services = child:FindFirstChild("knit") and child.knit:FindFirstChild("Services")
            local teleportService = services and services:FindFirstChild("PlaceTeleportService")
            local rf = teleportService and teleportService:FindFirstChild("RF")
            if rf and rf:FindFirstChild("Teleport") then
                return rf.Teleport
            end
        end
    end
    return nil
end

-- === UI ===
MainTab:CreateInput({
    Name = "Map Name (Intern)",
    PlaceholderText = "z.B. ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) targetMap = text end,
})

MainTab:CreateButton({
    Name = "START KOMPLETT (Queue -> Confirm -> Teleport)",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt!"})
            return 
        end

        local teleportFunc = GetTeleportFunction()
        if not teleportFunc then
            Rayfield:Notify({Title="Fehler", Content="Knit Teleport Service nicht gefunden!"})
            return
        end

        local remoteFolder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
        local createEvent = remoteFolder and remoteFolder:WaitForChild("Replica_ReplicaCreate", 5)
        local signalEvent = remoteFolder and remoteFolder:WaitForChild("Replica_ReplicaSignal", 5)

        if not createEvent or not signalEvent then
            Rayfield:Notify({Title="Fehler", Content="Replica Events fehlen!"})
            return
        end

        Rayfield:Notify({Title="Schritt 1", Content="Suche freien Platz..."})

        -- 1. ID Listener starten
        local capturedID = nil
        local connection = nil
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                capturedID = args[1]
                connection:Disconnect()
            end
        end)

        -- 2. Zum Kreis laufen
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- 3. Warten auf ID
        local start = tick()
        while not capturedID and (tick() - start < 10) do task.wait(0.1) end
        if connection then connection:Disconnect() end

        if capturedID then
            Rayfield:Notify({Title="Schritt 2", Content="Lobby ID: " .. capturedID})
            print("Lobby ID:", capturedID)
            
            task.wait(0.5)

            -- 4. Map Bestätigen (ConfirmMap via Replica)
            local confirmArgs = {
                [1] = capturedID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = targetDifficulty,
                    ["Chapter"] = targetChapter,
                    ["Endless"] = targetEndless,
                    ["World"] = targetMap
                }
            }
            signalEvent:FireServer(unpack(confirmArgs))
            print("Map bestätigt via Replica.")
            
            task.wait(1.5) -- Wichtig: Kurz warten, bis der Server die Map gespeichert hat!

            -- 5. FINALER TELEPORT (Knit PlaceTeleportService)
            Rayfield:Notify({Title="Schritt 3", Content="Starte Match Teleport..."})
            
            local teleportArgs = {
                "Game",         -- Modus
                targetMap,      -- Map Name
                targetDifficulty,
                targetEndless   -- false/true
            }
            
            -- Ausführen der Knit Funktion
            local success, result = pcall(function()
                return teleportFunc:InvokeServer(unpack(teleportArgs))
            end)

            if success then
                print("Teleport Befehl gesendet. Ergebnis:", result)
                Rayfield:Notify({Title="Erfolg", Content="Teleport wird eingeleitet!"})
            else
                warn("Knit Teleport Error:", result)
                Rayfield:Notify({Title="Fehler", Content="Teleport gescheitert (siehe Konsole)"})
            end

        else
            Rayfield:Notify({Title="Timeout", Content="Keine Lobby gefunden."})
        end
    end,
})
