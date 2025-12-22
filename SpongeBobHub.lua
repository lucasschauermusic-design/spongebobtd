local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Code Knacker", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Fernbedienung", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local targetMap = "ConchStreet"
local targetDifficulty = 1 
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

-- 2. Signal Finder (Deep Search)
local function FindReplicaSignal()
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == "Replica_ReplicaSignal" then return desc end
    end
    return nil
end

local function FindCreateEvent()
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == "Replica_ReplicaCreate" then return desc end
    end
    return nil
end

-- Globale Variable für die ID
_G.LobbyID = nil
_G.Signal = nil

MainTab:CreateButton({
    Name = "1. AUTO JOIN & MAP SETUP",
    Callback = function()
        if not FastTravel then Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt"}) return end
        
        local signalEvent = FindReplicaSignal()
        local createEvent = FindCreateEvent()
        
        if not signalEvent or not createEvent then 
             Rayfield:Notify({Title="Fehler", Content="Signale nicht gefunden"})
             return 
        end
        _G.Signal = signalEvent

        -- A) ID Abfangen
        local connection
        connection = createEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                _G.LobbyID = args[1]
                connection:Disconnect()
            end
        end)

        -- B) Teleport
        task.spawn(function() FastTravel:_attemptTeleportToEmptyQueue() end)

        -- C) Warten
        Rayfield:Notify({Title="Warte...", Content="Suche ID..."})
        local start = tick()
        while not _G.LobbyID and (tick() - start < 10) do task.wait(0.1) end
        
        if _G.LobbyID then
            Rayfield:Notify({Title="Gefunden!", Content="Lobby ID: " .. _G.LobbyID})
            task.wait(0.5)
            
            -- Map Confirmen
            local confirmArgs = {
                [1] = _G.LobbyID,
                [2] = "ConfirmMap",
                [3] = {
                    ["Difficulty"] = targetDifficulty,
                    ["Chapter"] = 1,
                    ["Endless"] = false,
                    ["World"] = targetMap,
                    ["Mode"] = targetMode 
                }
            }
            signalEvent:FireServer(unpack(confirmArgs))
            Rayfield:Notify({Title="Bereit", Content="Jetzt die unteren Buttons testen!"})
        else
            Rayfield:Notify({Title="Fehler", Content="Keine ID gefunden."})
        end
    end,
})

MainTab:CreateSection("TEST BUTTONS (Wenn Timer läuft)")

MainTab:CreateButton({
    Name = "Test A: 'Start' (Standard)",
    Callback = function()
        if _G.Signal and _G.LobbyID then
            _G.Signal:FireServer(_G.LobbyID, "Start")
            print("Gesendet: Start")
        end
    end,
})

MainTab:CreateButton({
    Name = "Test B: 'RequestStart'",
    Callback = function()
        if _G.Signal and _G.LobbyID then
            _G.Signal:FireServer(_G.LobbyID, "RequestStart")
            print("Gesendet: RequestStart")
        end
    end,
})

MainTab:CreateButton({
    Name = "Test C: 'ForceStart'",
    Callback = function()
        if _G.Signal and _G.LobbyID then
            _G.Signal:FireServer(_G.LobbyID, "ForceStart")
            print("Gesendet: ForceStart")
        end
    end,
})

MainTab:CreateButton({
    Name = "Test D: 'VoteStart'",
    Callback = function()
        if _G.Signal and _G.LobbyID then
            _G.Signal:FireServer(_G.LobbyID, "VoteStart")
            print("Gesendet: VoteStart")
        end
    end,
})

MainTab:CreateButton({
    Name = "Test E: 'Ready'",
    Callback = function()
        if _G.Signal and _G.LobbyID then
            _G.Signal:FireServer(_G.LobbyID, "Ready")
            print("Gesendet: Ready")
        end
    end,
})
