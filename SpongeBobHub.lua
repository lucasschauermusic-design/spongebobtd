local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Complete", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === EINSTELLUNGEN ===
local targetMap = "ConchStreet" 
local targetDifficulty = 1 
local targetEndless = false
local targetMode = "Game" -- WICHTIG: "Game" laut deinem Spy-Log

-- 1. FastTravel
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- 2. Knit Services (Hide & Teleport)
local function GetKnitFunctions()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if not packages then return nil end
    local index = packages:FindFirstChild("_Index")
    if not index then return nil end

    for _, child in pairs(index:GetChildren()) do
        if string.find(child.Name, "acecateer_knit") then
            local services = child:FindFirstChild("knit") and child.knit:FindFirstChild("Services")
            local teleportService = services and services:FindFirstChild("PlaceTeleportService")
            
            if teleportService then
                local rf = teleportService:FindFirstChild("RF")
                if rf then
                    return {
                        HideCharacter = rf:FindFirstChild("HideCharacter"),
                        Teleport = rf:FindFirstChild("Teleport")
                    }
                end
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
    Name = "AUTO START (Combo)",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt!"})
            return 
        end

        local knitFuncs = GetKnitFunctions()
        if not knitFuncs or not knitFuncs.HideCharacter or not knitFuncs.Teleport then
            Rayfield:Notify({Title="Fehler", Content="Knit Funktionen fehlen!"})
            return
        end

        local remoteFolder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 10)
        local createEvent = remoteFolder:WaitForChild("Replica_ReplicaCreate", 10)
        local signalEvent = remoteFolder:WaitForChild("Replica_ReplicaSignal", 10)

        if not signalEvent then 
            Rayfield:Notify({Title="Fehler", Content="Replica Signal fehlt!"})
            return 
        end

        Rayfield:Notify({Title="Status", Content="Suche freien Platz..."})

        -- A) LISTENER
        local capturedID = nil
        local connection = nil
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                capturedID = args[1]
                connection:Disconnect()
            end
        end)

        -- B) TELEPORT ZUR LOBBY
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- C) WARTEN AUF ID
        local start = tick()
        while not capturedID and (tick() - start < 10) do task.wait(0.1) end
        if connection then connection:Disconnect() end

        if capturedID then
            Rayfield:Notify({Title="Gefunden!", Content="Lobby ID: " .. capturedID})
            task.wait(0.8)

            -- D) MAP BESTÄTIGEN
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
            
            task.wait(1.5) -- Warten bis Config durch ist

            -- E) START SIGNAL (Wichtig für Server-State!)
            signalEvent:FireServer(capturedID, "RequestStart")
            signalEvent:FireServer(capturedID, "Start")
            print("Start Request gesendet.")
            Rayfield:Notify({Title="Status", Content="Starten..."})

            task.wait(1.0) -- Warten bis Lobby-Status auf "Started" wechselt

            -- F) KOMBINATION: HIDE + TELEPORT
            -- 1. Charakter verstecken (Visuals)
            pcall(function() knitFuncs.HideCharacter:InvokeServer() end)
            
            task.wait(0.5) -- Kurze Pause für den Effekt

            -- 2. Tatsächlichen Teleport auslösen (Transport)
            Rayfield:Notify({Title="Finale", Content="Sende Teleport Befehl..."})
            
            local teleportArgs = {
                targetMode,      -- "Game"
                targetMap,       -- "ConchStreet"
                targetDifficulty,-- 1
                targetEndless    -- false
            }
            
            local success, result = pcall(function()
                return knitFuncs.Teleport:InvokeServer(unpack(teleportArgs))
            end)

            if success then
                print("Teleport Result:", result)
                if result == "Success" or result == true then
                    Rayfield:Notify({Title="Erfolg", Content="Reise beginnt!"})
                else
                    -- Falls der Server eine Meldung zurückgibt
                    Rayfield:Notify({Title="Info", Content="Status: " .. tostring(result)})
                end
            else
                warn("Teleport Fehler:", result)
            end

        else
            Rayfield:Notify({Title="Fehler", Content="Keine Lobby ID erhalten."})
        end
    end,
})
