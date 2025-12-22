local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Final Fix", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === EINSTELLUNGEN ===
local targetMap = "ConchStreet" 
local targetDifficulty = 1 
local targetEndless = false
local targetMode = "Game" -- Laut deinem Spy Log ist "Game" korrekt!

-- 1. FastTravel laden
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- 2. Knit Teleport Funktion finden
local function GetTeleportFunction()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if not packages then return nil end
    local index = packages:FindFirstChild("_Index")
    if not index then return nil end

    for _, child in pairs(index:GetChildren()) do
        if string.find(child.Name, "acecateer_knit") then
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

-- 3. HILFSFUNKTION: Remote Signal sicher finden
-- Das behebt den Fehler aus deinem Screenshot!
local function FindReplicaSignalSafe()
    local folder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
    if not folder then return nil end
    
    -- Versuch 1: Direkter Zugriff
    local signal = folder:FindFirstChild("Replica_ReplicaSignal")
    if signal then return signal end
    
    -- Versuch 2: Suche nach Namen (falls Leerzeichen o.ä.)
    print("Suche ReplicaSignal manuell...")
    for _, child in pairs(folder:GetChildren()) do
        if string.find(child.Name, "ReplicaSignal") then
            print("Gefunden: " .. child.Name)
            return child
        end
    end
    return nil
end

MainTab:CreateInput({
    Name = "Map Name",
    PlaceholderText = "ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) targetMap = text end,
})

MainTab:CreateButton({
    Name = "AUTO START (Final)",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt!"})
            return 
        end

        local teleportFunc = GetTeleportFunction()
        if not teleportFunc then
            Rayfield:Notify({Title="Fehler", Content="Knit Teleport nicht gefunden!"})
            return
        end

        -- A) Remotes Suchen (Mit Fix)
        local remoteFolder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
        local createEvent = remoteFolder and remoteFolder:WaitForChild("Replica_ReplicaCreate", 5)
        local signalEvent = FindReplicaSignalSafe() -- Hier nutzen wir die neue Such-Funktion

        if not createEvent or not signalEvent then 
            Rayfield:Notify({Title="CRITICAL", Content="Replica Signal FEHLT immer noch!"})
            -- Debug Info in Konsole
            if remoteFolder then
                print("Inhalt von ReplicaRemoteEvents:")
                for _, c in pairs(remoteFolder:GetChildren()) do print("- " .. c.Name) end
            end
            return 
        end

        Rayfield:Notify({Title="Status", Content="Suche freien Platz..."})

        -- B) ID Listener
        local capturedID = nil
        local connection = nil
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                capturedID = args[1]
                connection:Disconnect()
            end
        end)

        -- C) Teleport zum Kreis
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- D) Warten auf ID
        local start = tick()
        while not capturedID and (tick() - start < 10) do task.wait(0.1) end
        if connection then connection:Disconnect() end

        if capturedID then
            Rayfield:Notify({Title="Lobby Gefunden", Content="ID: " .. capturedID})
            print("Lobby ID:", capturedID)
            
            task.wait(0.5)

            -- E) CONFIG SENDEN
            local confirmArgs = {
                [1] = capturedID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = targetDifficulty,
                    ["Chapter"] = 1,
                    ["Endless"] = targetEndless,
                    ["World"] = targetMap,
                    ["Mode"] = targetMode 
                }
            }
            signalEvent:FireServer(unpack(confirmArgs))
            print("Map Config gesendet.")
            
            task.wait(0.8)

            -- F) START DRÜCKEN (WICHTIG!)
            -- Das simuliert den "Starten" Knopf aus deinem Bild
            -- Ohne das bleibt die Lobby im "Countdown"-Modus
            signalEvent:FireServer(capturedID, "RequestStart")
            -- Sicherheitshalber auch "Start" senden, manche Events brauchen das
            signalEvent:FireServer(capturedID, "Start")
            print("Start-Signal gesendet.")

            Rayfield:Notify({Title="Start", Content="Match wird gestartet..."})
            task.wait(1.5) -- Wichtig: Dem Server Zeit geben, den Status auf "Starting" zu setzen

            -- G) FINALER TELEPORT (Knit)
            -- Jetzt, wo der Server weiß "Es geht los", rufen wir den Teleport auf.
            -- Das entspricht dem "Bestätigen" im grünen Popup.
            
            local teleportArgs = {
                targetMode,      -- "Game"
                targetMap,       -- "ConchStreet"
                targetDifficulty,-- 1
                targetEndless    -- false
            }
            
            local success, result = pcall(function()
                return teleportFunc:InvokeServer(unpack(teleportArgs))
            end)

            if success then
                print("Teleport Request Result:", result)
                Rayfield:Notify({Title="Erfolg", Content="Teleport..."})
            else
                warn("Teleport Error:", result)
                Rayfield:Notify({Title="Fehler", Content="Teleport gescheitert"})
            end

        else
            Rayfield:Notify({Title="Fehler", Content="Keine Lobby ID erhalten."})
        end
    end,
})
