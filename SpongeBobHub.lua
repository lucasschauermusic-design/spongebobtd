local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Service Scanner", LoadingTitle = "Scanning..."})
local Tab = Window:CreateTab("Services", 4483362458)

Tab:CreateButton({
    Name = "Scanne Knit Services",
    Callback = function()
        print("\n--- SUCHE NACH KNIT SERVICES ---")
        
        -- Normalerweise liegen die hier: ReplicatedStorage > Knit > Services
        local rs = game:GetService("ReplicatedStorage")
        local knitFolder = rs:FindFirstChild("Knit")
        local servicesFolder = knitFolder and knitFolder:FindFirstChild("Services")
        
        if servicesFolder then
            print("Services Ordner gefunden!")
            for _, service in pairs(servicesFolder:GetChildren()) do
                print("SERVICE: " .. service.Name)
                
                -- Wir schauen, was in dem Service drin ist (RemoteEvents/Functions)
                for _, remote in pairs(service:GetChildren()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        print("  > " .. remote.Name .. " (" .. remote.ClassName .. ")")
                        
                        -- Automatischer Treffer-Check
                        local n = remote.Name:lower()
                        if n:find("join") or n:find("start") or n:find("ready") or n:find("queue") then
                            warn("!!! TREFFER: " .. service.Name .. "." .. remote.Name .. " !!!")
                        end
                    end
                end
            end
        else
            warn("Knit/Services Ordner nicht gefunden. Scanne gesamten ReplicatedStorage...")
            -- Fallback: Alles scannen
            for _, obj in pairs(rs:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name:lower():find("queue") or obj.Name:lower():find("lobby")) then
                    print("Remote gefunden: " .. obj.Name .. " -> " .. obj:GetFullName())
                end
            end
        end
        Rayfield:Notify({Title="Scan fertig", Content="Check F9 Log!"})
    end,
})
