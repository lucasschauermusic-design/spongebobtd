local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Service Dump", LoadingTitle = "Lese Services..."})
local Tab = Window:CreateTab("Dump", 4483362458)

Tab:CreateButton({
    Name = "Alle Server-Befehle auflisten",
    Callback = function()
        print("\n=== SÜCHE NACH STANDARD-BEFEHLEN ===")
        
        -- Wir suchen den Knit-Ordner im ReplicatedStorage, egal wie tief er steckt
        local rs = game:GetService("ReplicatedStorage")
        local servicesFolder = nil
        
        -- Tiefe Suche nach dem Ordner "Services"
        for _, obj in pairs(rs:GetDescendants()) do
            if obj.Name == "Services" and obj.Parent.Name:find("knit") then
                servicesFolder = obj
                break
            end
        end
        
        if servicesFolder then
            print("Services-Ordner gefunden: " .. servicesFolder:GetFullName())
            
            -- Wir schauen uns jetzt Matchmaking, Party und Queue genau an
            local targetServices = {"MatchmakingService", "PartyService", "QueueService", "LobbyService", "GameService"}
            
            for _, serviceName in pairs(targetServices) do
                local service = servicesFolder:FindFirstChild(serviceName)
                if service then
                    print("------------------------------------------------")
                    print("SERVICE: " .. serviceName)
                    local foundAny = false
                    for _, remote in pairs(service:GetChildren()) do
                        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                            print(" > " .. remote.Name .. " (" .. remote.ClassName .. ")")
                            foundAny = true
                            
                            -- Markiere verdächtige Standard-Befehle
                            local n = remote.Name:lower()
                            if n:find("create") or n:find("join") or n:find("start") or n:find("queue") then
                                if not n:find("rogue") and not n:find("karate") then
                                    warn("!!! KANDIDAT: " .. remote.Name .. " !!!")
                                end
                            end
                        end
                    end
                    if not foundAny then print(" (Keine Remotes gefunden)") end
                end
            end
        else
            warn("Konnte den Services-Ordner nicht finden!")
        end
        Rayfield:Notify({Title="Fertig", Content="Schau in F9 nach der Liste!"})
    end,
})
