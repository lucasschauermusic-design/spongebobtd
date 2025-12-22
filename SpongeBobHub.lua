local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade System..."})
local MainTab = Window:CreateTab("Automation", 4483362458)

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- User Settings
local targetMap = "ConchStreet" -- Achte auf exakte Schreibweise (siehe dein Snippet: "ConchStreet" statt "Bikini Bottom"?)
local targetDifficulty = "Hard" 

-- 1. FastTravel Controller laden
local FastTravel = nil
local scripts = LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

if FastTravel then print("FastTravel geladen") else warn("FastTravel fehlt") end

-- 2. Hilfsfunktion: Auf Lobby-ID warten
-- Diese Funktion wartet darauf, dass der Server uns die ID schickt (ReplicaCreate)
local function CaptureLobbyID(timeout)
    local foundID = nil
    local connection = nil
    local startTime = tick()
    
    -- Pfad zum Event basierend auf deinem Snippet
    local replicaEvents = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents", 5)
    local createEvent = replicaEvents and replicaEvents:WaitForChild("Replica_ReplicaCreate", 5)
    
    if not createEvent then 
        Rayfield:Notify({Title="Fehler", Content="Replica Event nicht gefunden!"})
        return nil 
    end

    -- Listener erstellen
    connection = createEvent.OnClientEvent:Connect(function(...)
        local args = {...}
        local id = args[1]     -- Das erste Argument ist die ID (z.B. 23)
        local data = args[2]   -- Das zweite ist die Datentabelle
        
        -- Sicherheitshalber prüfen, ob wir der Owner sind (wie in deinem Snippet)
        -- Struktur: data[3]["LobbyOwner"]
        if data and data[3] and data[3].LobbyOwner == LocalPlayer then
            print("Lobby ID abgefangen: " .. tostring(id))
            foundID = id
        elseif id and (not foundID) then
            -- Fallback: Nimm die ID auch wenn Owner Check schwierig ist, 
            -- da wir uns gerade erst teleportiert haben.
            foundID = id
        end
    end)
    
    -- Warten bis ID da ist oder Timeout
    while not foundID do
        if tick() - startTime > timeout then break end
        task.wait(0.1)
    end
    
    if connection then connection:Disconnect() end
    return foundID
end

-- UI
MainTab:CreateInput({
    Name = "Map Internal Name",
    PlaceholderText = "z.B. ConchStreet",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetMap = text
    end,
})

MainTab:CreateButton({
    Name = "AUTO START (Smart Listener)",
    Callback = function()
        if not FastTravel or not FastTravel._attemptTeleportToEmptyQueue then
            Rayfield:Notify({Title="Fehler", Content="FastTravel Script fehlt!"})
            return
        end

        -- ABLAUF STARTEN
        task.spawn(function()
            Rayfield:Notify({Title="Schritt 1", Content="Teleportiere..."})
            
            -- Listener scharf schalten BEVOR wir teleportieren, damit wir das Event nicht verpassen
            local idTask = task.spawn(function()
                 -- Wir geben dem Ganzen 5 Sekunden Zeit
                 _G.CapturedID = CaptureLobbyID(8) 
            end)
            
            -- Teleport ausführen
            FastTravel:_attemptTeleportToEmptyQueue()
            
            -- Warten bis Capture fertig ist
            task.wait(1) 
            while task.status(idTask) ~= "dead" do task.wait(0.2) end
            
            local lobbyID = _G.CapturedID
            
            if lobbyID then
                Rayfield:Notify({Title="Gefunden!", Content="Lobby ID: " .. tostring(lobbyID)})
                task.wait(0.5)
                
                -- SCHRITT 2: Map Daten senden (Replica Signal)
                local replicaRemote = ReplicatedStorage:FindFirstChild("ReplicaRemoteSignal", true)
                if replicaRemote then
                    -- Hier müssen wir dem Server sagen: "Ändere die Map in dieser Lobby"
                    -- Das Format hängt davon ab, wie ReplicaService Updates erwartet.
                    -- Meistens: ID, Pfad, Wert
                    
                    local args = {
                        [1] = lobbyID,
                        [2] = {
                            ["Stage"] = targetMap,
                            ["Difficulty"] = targetDifficulty,
                            ["Mode"] = "Story" -- Falls nötig
                        }
                    }
                    -- Hinweis: Falls das nicht geht, braucht ReplicaService oft separate Calls für jeden Wert.
                    -- Aber probieren wir erst das Setzen der Tabelle.
                    replicaRemote:FireServer(unpack(args))
                    print("Daten gesendet.")
                end
                
                task.wait(0.5)
                
                -- SCHRITT 3: Start Invoker
                local invoker = ReplicatedStorage:FindFirstChild("MatchStartInvoker", true)
                if invoker then
                    invoker:InvokeServer(lobbyID)
                    Rayfield:Notify({Title="Erfolg", Content="Spiel gestartet!"})
                else
                    Rayfield:Notify({Title="Fehler", Content="Invoker nicht gefunden"})
                end
            else
                Rayfield:Notify({Title="Fehler", Content="Keine Lobby ID empfangen. Evtl. war der Server zu langsam?"})
            end
        end)
    end,
})
