local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Finale", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === EINSTELLUNGEN ===
local targetMap = "ConchStreet" 
local targetDifficulty = 1 
local targetEndless = false
local targetMode = "Game" 

-- 1. FastTravel
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- 2. Knit Services (HideCharacter)
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
    Name = "AUTO START (Mit Wartezeit)",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt!"})
            return 
        end

        local knitFuncs = GetKnitFunctions()
        if not knitFuncs or not knitFuncs.HideCharacter then
            Rayfield:Notify({Title="Fehler", Content="HideCharacter fehlt!"})
            return
        end

        -- A) PFADE FINDEN (Die sichere Methode von vorhin)
        local remoteFolder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 10)
        local createEvent = remoteFolder:WaitForChild("Replica_ReplicaCreate", 10)
        local signalEvent = remoteFolder:WaitForChild("Replica_ReplicaSignal", 10)

        if not signalEvent then 
            Rayfield:Notify({Title="Fehler", Content="Replica Signal nicht gefunden!"})
            return 
        end

        Rayfield:Notify({Title="Status", Content="Suche freien Platz..."})

        -- B) LISTENER
        local capturedID = nil
        local connection = nil
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                capturedID = args[1]
                connection:Disconnect()
            end
        end)

        -- C) TELEPORT
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- D) WARTEN AUF ID
        local start = tick()
        while not capturedID and (tick() - start < 10) do task.wait(0.1) end
        if connection then connection:Disconnect() end

        if capturedID then
            Rayfield:Notify({Title="Gefunden!", Content="Lobby ID: " .. capturedID})
            
            -- WICHTIG: Kurz warten, damit wir sicher stehen
            task.wait(0.8)

            -- E) MAP BESTÄTIGEN
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
            print(">>> Map Config gesendet.")
            Rayfield:Notify({Title="Schritt 1", Content="Map ausgewählt."})
            
            -- === DER FIX: LANGE WARTEZEIT ===
            -- Wir geben dem Server volle 2 Sekunden, um die Map anzuzeigen/zu speichern
            -- Bevor wir Start drücken.
            task.wait(2.0)

            -- F) START DRÜCKEN
            signalEvent:FireServer(capturedID, "RequestStart")
            signalEvent:FireServer(capturedID, "Start")
            print(">>> Start Request gesendet.")
            Rayfield:Notify({Title="Schritt 2", Content="Start gedrückt."})

            task.wait(1.0) 

            -- G) HIDE CHARACTER (Trigger Teleport)
            Rayfield:Notify({Title="Finale", Content="Ladebildschirm..."})
            
            local success, err = pcall(function()
                knitFuncs.HideCharacter:InvokeServer()
            end)

            if success then
                print("HideCharacter ausgeführt!")
                Rayfield:Notify({Title="Erfolg", Content="Teleport läuft!"})
            else
                warn("HideCharacter Fehler:", err)
            end

        else
            Rayfield:Notify({Title="Fehler", Content="Keine Lobby ID erhalten."})
        end
    end,
})
