local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Final Tools", LoadingTitle = "Scanning..."})
local Tab = Window:CreateTab("Tools", 4483362458)

-- 1. REMOTE SCANNER (Die direkte Leitung)
Tab:CreateButton({
    Name = "Scanne nach RemoteEvents",
    Callback = function()
        print("\n--- REMOTE EVENT SCAN ---")
        -- Wir suchen überall in ReplicatedStorage nach Events
        local rs = game:GetService("ReplicatedStorage")
        local count = 0
        
        for _, obj in pairs(rs:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                -- Wir filtern nach interessanten Namen
                if n:find("join") or n:find("queue") or n:find("start") or n:find("lobby") or n:find("ready") then
                    warn("TREFFER: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    print("Pfad: " .. obj:GetFullName())
                    count = count + 1
                end
            end
        end
        
        if count == 0 then print("Keine offensichtlichen Remotes gefunden.") end
        Rayfield:Notify({Title="Scan fertig", Content="Check F9 für Events!"})
    end,
})

-- 2. BUTTON CLICKER (Der physische Klick)
Tab:CreateButton({
    Name = "Suche & Drücke 'BEREIT'",
    Callback = function()
        print("\n--- BUTTON SUCHE ---")
        local gui = game:GetService("Players").LocalPlayer.PlayerGui
        local found = false
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                -- Wir suchen nach dem Text "ICH BIN BEREIT!" oder dem Namen
                if (obj:IsA("TextButton") and obj.Text:find("BEREIT")) or obj.Name:lower():find("ready") or obj.Name:lower():find("start") then
                    if obj.Visible then -- Nur sichtbare Knöpfe drücken
                        warn("KNOPF GEFUNDEN: " .. obj.Name)
                        print("Text: " .. (obj.Text or "Kein Text"))
                        print("Pfad: " .. obj:GetFullName())
                        
                        -- Versuche, ihn zu drücken
                        print("Versuche Klick...")
                        for _, conn in pairs(getconnections(obj.MouseButton1Click)) do
                            conn:Fire()
                        end
                        for _, conn in pairs(getconnections(obj.Activated)) do
                            conn:Fire()
                        end
                        found = true
                    end
                end
            end
        end
        
        if found then
            Rayfield:Notify({Title="Gefunden!", Content="Habe versucht zu klicken!"})
        else
            Rayfield:Notify({Title="Nichts gefunden", Content="Knopf nicht im UI gefunden."})
        end
    end,
})
