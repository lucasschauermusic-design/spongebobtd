local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Timer Killer", LoadingTitle = "Lade..."})
local MainTab = Window:CreateTab("Force Start", 4483362458)

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

-- 2. SUCH-FUNKTIONEN
local function DeepFind(name, className)
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == name and (not className or desc:IsA(className)) then
            return desc
        end
    end
    return nil
end

_G.LobbyID = nil
_G.Signal = nil
_G.Invoker = nil

MainTab:CreateButton({
    Name = "1. AUTO JOIN & SETUP",
    Callback = function()
        if not FastTravel then Rayfield:Notify({Title="Fehler", Content="FastTravel fehlt"}) return end
        
        local signalEvent = DeepFind("Replica_ReplicaSignal", "RemoteEvent")
        local createEvent = DeepFind("Replica_ReplicaCreate", "RemoteEvent")
        -- WICHTIG: Wir suchen jetzt gezielt danach!
        local startInvoker = DeepFind("MatchStartInvoker", "RemoteFunction")
        
        if not signalEvent or not createEvent then 
             Rayfield:Notify({Title="Fehler", Content="Replica Events fehlen"})
             return 
        end
        
        _G.Signal = signalEvent
        _G.Invoker = startInvoker

        if _G.Invoker then
            Rayfield:Notify({Title="HOFFNUNG!", Content="MatchStartInvoker GEFUNDEN!"})
            print("Invoker Pfad: ", _G.Invoker:GetFullName())
        else
            Rayfield:Notify({Title="Info", Content="Invoker nicht gefunden (Probiere Timer-Hack)"})
        end

        -- A) ID Listener
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
        local start = tick()
        while not _G.LobbyID and (tick() - start < 10) do task.wait(0.1) end
        
        if _G.LobbyID then
            Rayfield:Notify({Title="Lobby ID", Content=tostring(_G.LobbyID)})
            task.wait(0.5)
            
            -- Map Config
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
            Rayfield:Notify({Title="Bereit", Content="Drücke jetzt die Test-Buttons!"})
        end
    end,
})

MainTab:CreateSection("DIE NEUEN VERSUCHE")

MainTab:CreateButton({
    Name = "Test A: MatchStartInvoker (Function)",
    Callback = function()
        if _G.Invoker and _G.LobbyID then
            print("Rufe MatchStartInvoker auf...")
            local success, res = pcall(function()
                return _G.Invoker:InvokeServer(_G.LobbyID)
            end)
            if success then
                Rayfield:Notify({Title="Result", Content=tostring(res)})
            else
                Rayfield:Notify({Title="Fehler", Content="Invoker fehlgeschlagen"})
            end
        else
            Rayfield:Notify({Title="Fehler", Content="Invoker nicht gefunden!"})
        end
    end,
})

MainTab:CreateButton({
    Name = "Test B: Timer auf 0 setzen (Replica)",
    Callback = function()
        if _G.Signal and _G.LobbyID then
            -- Versuch: Wir tun so, als ob wir die Lobby-Daten updaten wollen
            -- Argumentstruktur geraten basierend auf ReplicaCreate
            local updateArgs = {
                [1] = _G.LobbyID,
                [2] = {
                    ["selectionTimeLeft"] = 0
                }
            }
            _G.Signal:FireServer(unpack(updateArgs))
            print("Gesendet: Timer auf 0 setzen")
        end
    end,
})

MainTab:CreateButton({
    Name = "Test C: Timer Hack (Alternative)",
    Callback = function()
        if _G.Signal and _G.LobbyID then
            -- Andere Struktur probieren
            local updateArgs = {
                [1] = _G.LobbyID,
                [2] = "SetValue", -- Oft genutzt bei Replica
                [3] = "selectionTimeLeft",
                [4] = 0
            }
            _G.Signal:FireServer(unpack(updateArgs))
            print("Gesendet: SetValue Timer")
        end
    end,
})
