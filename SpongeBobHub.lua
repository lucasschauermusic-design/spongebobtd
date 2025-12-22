local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Listener-First", LoadingTitle = "Lade Fix..."})
local MainTab = Window:CreateTab("Main", 4483362458)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicaSignal = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local replicaCreate = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- EINSTELLUNGEN
local selectedMap = "ChumBucket"
local selectedChapter = 1
local selectedDifficulty = 1

-- FastTravel Modul
local FastTravel = nil
for _, mod in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        pcall(function() FastTravel = require(mod) end)
        break
    end
end

MainTab:CreateDropdown({
    Name = "Wähle Map",
    Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
    CurrentOption = "ChumBucket",
    Callback = function(Option) selectedMap = Option end,
})

MainTab:CreateDropdown({
    Name = "Schwierigkeit",
    Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
    CurrentOption = "Normal",
    Callback = function(Option)
        local diffs = {Normal = 1, Hard = 2, Nightmare = 3, DavyJones = 4}
        selectedDifficulty = diffs[Option] or 1
    end,
})

MainTab:CreateButton({
    Name = "🚀 FULL AUTO (Listener First)",
    Callback = function()
        if not FastTravel then return end

        -- 1. SCHRITT: LISTENER AKTIVIEREN
        local connection
        connection = replicaCreate.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect() -- Sofort stoppen, wenn ID da ist
                
                print("Lobby-ID live abgefangen: " .. lobbyID)
                
                -- Warten wie im erfolgreichen Snippet
                task.wait(2.0)
                
                -- 3. SCHRITT: MAP-DATEN SENDEN (Exakt dein Format)
                local packet = {
                    [1] = lobbyID,
                    [2] = "ConfirmMap",
                    [3] = {
                        ["Difficulty"] = selectedDifficulty,
                        ["Chapter"] = selectedChapter,
                        ["Endless"] = false,
                        ["World"] = selectedMap
                    }
                }
                
                replicaSignal:FireServer(table.unpack(packet))
                
                -- 4. SCHRITT: STARTEN
                task.wait(1.5)
                replicaSignal:FireServer(lobbyID, "StartGame")
            end
        end)

        -- 2. SCHRITT: TELEPORT ERST JETZT STARTEN
        -- Wir nutzen task.defer, um sicherzustellen, dass der Listener im Hintergrund läuft
        task.defer(function()
            FastTravel:_attemptTeleportToEmptyQueue()
        end)
        
        Rayfield:Notify({Title="Aktiviert", Content="Listener läuft, Teleport gestartet..."})
    end,
})
