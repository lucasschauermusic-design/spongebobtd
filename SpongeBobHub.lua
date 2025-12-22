local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Auto-Join", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === EINSTELLUNGEN ===
local targetMap = "ConchStreet" 
local targetDifficulty = 1 
local targetEndless = false
-- Laut deinem Spy Log muss hier "Game" stehen!
local targetMode = "Game" 

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

MainTab:CreateInput({
    Name = "Map Name",
    PlaceholderText = "ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) targetMap = text end,
})

MainTab:CreateButton({
    Name = "AUTO JOIN & FORCE START",
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

        -- Remotes suchen
        local remoteFolder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
        local createEvent = remoteFolder:WaitForChild("Replica_ReplicaCreate", 5)
        local signalEvent = remoteFolder:WaitForChild("Replica_ReplicaSignal", 5)

        if not createEvent or not signalEvent then return end

        Rayfield:Notify({Title="Status", Content="Suche freien Platz..."})

        -- A) ID Listener
        local capturedID = nil
        local connection = nil
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                capturedID = args[1]
                connection:Disconnect()
            end
        end)

        -- B) Teleportieren
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- C) Warten auf ID
        local start = tick()
        while not capturedID and (tick() - start < 10) do task.wait(0.1) end
        if connection then connection:Disconnect() end

        if capturedID then
            Rayfield:Notify({Title="Lobby Gefunden", Content="ID: " .. capturedID})
            print("Lobby ID:", capturedID)
            
            task.wait(0.5)

            -- D) KONFIGURATION SENDEN (ConfirmMap)
            local confirmArgs = {
                [1] = capturedID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = targetDifficulty,
                    ["Chapter"] = 1,
                    ["Endless"] = targetEndless,
                    ["World"] = targetMap,
                    ["Mode"] = targetMode -- "Game"
                }
            }
            signalEvent:FireServer(unpack(confirmArgs))
            print("Map Config gesendet.")
            
            task.wait(0.5)

            -- E) START SIGNAL SENDEN (WICHTIG!)
            -- Wir versuchen hier, den "Start"-Button zu drücken, damit die Lobby in den Start-Modus geht.
            -- Wir probieren beide gängigen Varianten.
            signalEvent:FireServer(capturedID, "RequestStart")
            signalEvent:FireServer(capturedID, "Start")
            print("Start-Request gesendet.")

            task.wait(1.0) -- Kurz warten, bis der Server "Start" verarbeitet hat

            -- F) FINALER TELEPORT (Knit)
            -- Hier nutzen wir EXAKT die Argumente aus deinem Spy Log
            local teleportArgs = {
                targetMode,      -- "Game"
                targetMap,       -- "ConchStreet"
                targetDifficulty,-- 1
                targetEndless    -- false
            }
            
            Rayfield:Notify({Title="Finaler Schritt", Content="Sende Teleport Befehl..."})
            
            local success, result = pcall(function()
                return teleportFunc:InvokeServer(unpack(teleportArgs))
            end)

            if success then
                print("Teleport Request Result:", result)
                Rayfield:Notify({Title="Erfolg", Content="Teleport sollte starten!"})
            else
                warn("Teleport Error:", result)
            end

        else
            Rayfield:Notify({Title="Fehler", Content="Keine Lobby ID erhalten."})
        end
    end,
})
