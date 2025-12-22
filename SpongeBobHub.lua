local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Auto-Joiner", LoadingTitle = "Lade System..."})
local MainTab = Window:CreateTab("Automation", 4483362458)

-- Standard-Werte
local targetMap = "Bikini Bottom"
local targetDifficulty = "Hard" -- Beispiel

-- 1. FastTravel Controller laden (wie gehabt)
local FastTravel = nil
local player = game:GetService("Players").LocalPlayer
local scripts = player.PlayerScripts

for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "FastTravelController" and mod:IsA("ModuleScript") then
        local success, result = pcall(require, mod)
        if success then FastTravel = result end
        break
    end
end

if not FastTravel then
    Rayfield:Notify({Title="Fehler", Content="FastTravelController nicht gefunden!"})
else
    print("FastTravelController geladen.")
end

-- HILFSFUNKTION: Lobby ID finden
-- Wir müssen wissen, in welcher Lobby wir nach dem Teleport stehen.
local function GetCurrentLobbyID()
    -- Methode A: Oft wird die Lobby-ID als Attribut im Character oder PlayerGui gespeichert
    local char = player.Character
    if char:GetAttribute("LobbyID") then return char:GetAttribute("LobbyID") end
    
    -- Methode B: Suche im Workspace nach dem nächstgelegenen Lobby-Part
    -- (Dies ist ein Fallback, falls Attribut nicht existiert)
    -- Hier müsstest du ggf. den Pfad anpassen, wo die Lobbys im Workspace liegen
    return nil -- Rückgabe nil, wenn nicht gefunden
end

-- HILFSFUNKTION: Replica & Invoker nutzen
local function StartGameChain(lobbyID, mapName)
    if not lobbyID then 
        Rayfield:Notify({Title="Fehler", Content="Keine Lobby-ID gefunden!"})
        return 
    end

    -- 1. REPLICA SIGNAL: Daten setzen (Map wählen)
    -- Hinweis: Du musst prüfen, wie das RemoteEvent genau heißt. Oft in ReplicatedStorage.
    -- Beispielpfad: game:GetService("ReplicatedStorage").ReplicaRemoteSignal
    local replicaRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ReplicaRemoteSignal", true) 
    
    if replicaRemote then
        -- Argumente müssen hier exakt stimmen (LobbyID, MapName etc.)
        -- Dies ist ein Beispiel, wie es oft aufgebaut ist:
        local args = {
            [1] = lobbyID,
            [2] = {
                ["Map"] = mapName,
                ["Difficulty"] = targetDifficulty
            }
        }
        replicaRemote:FireServer(unpack(args))
        print("Replica Signal gesendet für Lobby " .. tostring(lobbyID))
    else
        Rayfield:Notify({Title="Fehler", Content="Replica Remote nicht gefunden!"})
        return
    end

    task.wait(0.5) -- Kurze Pause zur Sicherheit

    -- 2. INVOKER: Spiel starten (Teleport)
    -- Suche nach dem Invoker Remote
    local invokerRemote = game:GetService("ReplicatedStorage"):FindFirstChild("MatchStartInvoker", true) -- Name anpassen falls nötig!
    
    if invokerRemote then
        invokerRemote:InvokeServer(lobbyID)
        Rayfield:Notify({Title="Start", Content="Match wird gestartet..."})
    else
        -- Fallback: Manchmal ist es auch nur ein FireServer
        Rayfield:Notify({Title="Info", Content="Invoker Remote suchen..."})
    end
end


-- UI BUTTONS
MainTab:CreateInput({
    Name = "Map Name",
    PlaceholderText = "Z.B. Bikini Bottom",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetMap = text
    end,
})

MainTab:CreateButton({
    Name = "AUTO START (Queue -> Replica -> Invoker)",
    Callback = function()
        if FastTravel and FastTravel._attemptTeleportToEmptyQueue then
            
            -- SCHRITT 1: Teleport zum leeren Feld
            Rayfield:Notify({Title="Schritt 1", Content="Teleportiere zu leerer Queue..."})
            FastTravel:_attemptTeleportToEmptyQueue()
            
            -- Wir warten kurz, bis der Spieler angekommen ist
            task.spawn(function()
                task.wait(2) -- Zeit zum Teleportieren geben
                
                -- SCHRITT 2: Lobby ID holen
                -- Hier ist der kritische Punkt: Wir müssen wissen, welche ID wir bekommen haben.
                -- Oft zeigt das Spiel dies auch in der GUI an (z.B. PlayerGui.LobbyUI.LobbyId.Text)
                local lobbyID = GetCurrentLobbyID() 
                
                -- DEBUG: Falls wir keine ID automatisch finden, nimm eine Test-ID oder brich ab
                if not lobbyID then
                    -- Versuch, es aus der GUI zu lesen (Beispielpfad)
                    local gui = player.PlayerGui:FindFirstChild("MysteryMarket") -- oder wie das UI heißt
                    if gui then
                        -- Hier müsstest du mit Dex schauen, wo die ID steht
                        -- lobbyID = ...
                    end
                end
                
                if lobbyID then
                    Rayfield:Notify({Title="Schritt 2", Content="Lobby " .. tostring(lobbyID) .. " gefunden."})
                    
                    -- SCHRITT 3 & 4: Daten setzen und Starten
                    StartGameChain(lobbyID, targetMap)
                else
                    Rayfield:Notify({Title="Stop", Content="Konnte Lobby-ID nicht automatisch lesen. Bitte Pfad im Script anpassen."})
                    print("Lobby ID nicht gefunden. Bitte prüfe mit Dex, wo die ID gespeichert wird (Attribute oder GUI).")
                end
            end)
            
        else
            Rayfield:Notify({Title="Fehler", Content="FastTravel Funktion fehlt!"})
        end
    end,
})
