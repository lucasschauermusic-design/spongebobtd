local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Hide & Start", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === EINSTELLUNGEN ===
local targetMap = "ConchStreet" 
local targetDifficulty = 1 
local targetEndless = false
local targetMode = "Game" 

-- 1. FastTravel finden
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- 2. Knit Services finden (HideCharacter & Teleport)
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

-- 3. Hilfsfunktion: Replica Signal sicher finden
local function FindReplicaSignalSafe()
    local folder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
    if not folder then return nil end
    local signal = folder:FindFirstChild("Replica_ReplicaSignal")
    if signal then return signal end
    -- Manuelle Suche
    for _, child in pairs(folder:GetChildren()) do
        if string.find(child.Name, "ReplicaSignal") then return child end
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
    Name = "AUTO START (HideCharacter Methode)",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt!"})
            return 
        end

        local knitFuncs = GetKnitFunctions()
        if not knitFuncs or not knitFuncs.HideCharacter then
            Rayfield:Notify({Title="Fehler", Content="HideCharacter Funktion nicht gefunden!"})
            return
        end

        local remoteFolder = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
        local createEvent = remoteFolder and remoteFolder:WaitForChild("Replica_ReplicaCreate", 5)
        local signalEvent = FindReplicaSignalSafe()

        if not signalEvent then 
            Rayfield:Notify({Title="Fehler", Content="Replica Signal fehlt!"})
            return 
        end

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

        -- B) Teleport zum Kreis
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- C) Warten auf ID
        local start = tick()
        while not capturedID and (tick() - start < 10) do task.wait(0.1) end
        if connection then connection:Disconnect() end

        if capturedID then
            Rayfield:Notify({Title="Lobby", Content="ID: " .. capturedID})
            print("Lobby ID:", capturedID)
            
            task.wait(0.5)

            -- D) CONFIG SENDEN
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
            
            task.wait(0.6)

            -- E) START SIGNAL 
            -- Wir drücken den Start-Knopf, damit die Zeit abläuft
            signalEvent:FireServer(capturedID, "RequestStart")
            signalEvent:FireServer(capturedID, "Start")
            print("Start Request gesendet.")

            task.wait(0.5) 

            -- F) DER NEUE SCHLÜSSEL: HideCharacter
            -- Anstatt selbst zu teleportieren, sagen wir dem Server: "Versteck mich, ich bin bereit!"
            Rayfield:Notify({Title="Finale", Content="Trigger HideCharacter..."})
            
            local success, err = pcall(function()
                knitFuncs.HideCharacter:InvokeServer()
            end)

            if success then
                print("HideCharacter erfolgreich aufgerufen!")
                Rayfield:Notify({Title="Erfolg", Content="Teleport sollte gleich starten..."})
            else
                warn("HideCharacter fehlgeschlagen:", err)
                Rayfield:Notify({Title="Fehler", Content="HideCharacter fehlgeschlagen"})
            end

            -- Optional: Falls HideCharacter alleine nicht reicht, feuern wir nach 1 Sekunde zur Sicherheit doch den Teleport
            -- Aber wir lassen ihn diesmal leer oder mit Standard-Args, falls HideCharacter die Arbeit macht.
            -- (Diesen Teil habe ich auskommentiert, damit wir testen, ob HideCharacter alleine reicht)
            -- task.wait(1)
            -- knitFuncs.Teleport:InvokeServer(targetMode, targetMap, targetDifficulty, targetEndless)

        else
            Rayfield:Notify({Title="Fehler", Content="Keine Lobby ID erhalten."})
        end
    end,
})
