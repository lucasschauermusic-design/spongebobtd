local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Auto-Join", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Einstellungen (Standardwerte basierend auf deinem Snippet)
local targetMap = "ConchStreet" 
local targetDifficulty = 1  -- 1 scheint "Easy" oder "Normal" zu sein? (Zahl statt Text!)
local targetChapter = 1
local targetEndless = false

-- 1. FastTravel Controller laden
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

-- UI
MainTab:CreateInput({
    Name = "Map (Interner Name)",
    PlaceholderText = "z.B. ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetMap = text
    end,
})

MainTab:CreateButton({
    Name = "AUTO JOIN & CONFIG & START",
    Callback = function()
        if not FastTravel then 
            Rayfield:Notify({Title="Fehler", Content="FastTravel nicht geladen!"})
            return 
        end

        -- A) Wir suchen die nötigen Remotes VORHER
        local eventFolder = ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents")
        if not eventFolder then
            Rayfield:Notify({Title="Fehler", Content="Ordner 'ReplicaRemoteEvents' nicht gefunden!"})
            return
        end

        local createEvent = eventFolder:FindFirstChild("Replica_ReplicaCreate")
        local signalEvent = eventFolder:FindFirstChild("Replica_ReplicaSignal") -- Das aus deinem Snippet

        if not createEvent or not signalEvent then
            Rayfield:Notify({Title="Fehler", Content="Remotes nicht gefunden!"})
            return
        end

        Rayfield:Notify({Title="Status", Content="Teleport gestartet - Warte auf ID..."})

        -- B) ID Abfangen (Listener)
        local capturedID = nil
        local connection = nil

        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            local id = args[1]
            if id and type(id) == "number" then
                capturedID = id
                connection:Disconnect() 
            end
        end)

        -- C) Teleport ausführen
        task.spawn(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)

        -- D) Warten auf ID
        local startTime = tick()
        repeat 
            task.wait(0.1)
        until capturedID or (tick() - startTime > 8)
        
        if connection then connection:Disconnect() end

        -- E) ABLAUF STARTEN
        if capturedID then
            Rayfield:Notify({Title="ID Gefunden", Content="Lobby: " .. capturedID})
            
            task.wait(0.5) -- Kurze Pause zur Sicherheit

            -- 1. MAP BESTÄTIGEN (Dein Snippet Code)
            local args = {
                [1] = capturedID,
                [2] = "ConfirmMap", -- WICHTIG: Das fehlte vorher!
                [3] = {
                    ["Difficulty"] = targetDifficulty,
                    ["Chapter"] = targetChapter,
                    ["Endless"] = targetEndless,
                    ["World"] = targetMap, -- Hier setzen wir deinen Map-Namen ein
                },
            }
            
            -- Senden
            signalEvent:FireServer(unpack(args))
            print("ConfirmMap gesendet für ID: " .. capturedID)
            Rayfield:Notify({Title="Config", Content="Map '"..targetMap.."' bestätigt."})

            task.wait(0.8) -- Dem Server kurz Zeit geben, die Map zu speichern

            -- 2. SPIEL STARTEN (Invoker)
            -- Jetzt wo die Map "Confirmed" ist, sollte der Start funktionieren.
            local invoker = ReplicatedStorage:FindFirstChild("MatchStartInvoker", true)
            
            if invoker then
                invoker:InvokeServer(capturedID)
                Rayfield:Notify({Title="Start", Content="Teleport ins Match..."})
            else
                -- Fallback: Manchmal muss man auch ein Signal zum Starten senden?
                -- Probieren wir "RequestStart" falls Invoker fehlt (nur Vermutung)
                -- signalEvent:FireServer(capturedID, "RequestStart")
                warn("MatchStartInvoker nicht gefunden!")
                Rayfield:Notify({Title="Warnung", Content="Konnte Start-Invoker nicht finden."})
            end

        else
            Rayfield:Notify({Title="Timeout", Content="Keine Lobby-ID erhalten."})
        end
    end,
})
