local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Queue Master", LoadingTitle = "Verbinde mit Screen..."})
local Tab = Window:CreateTab("Lobby", 4483362458)

-- Wir suchen das QueueScreen Modul
local QueueScreen = nil
local scripts = game:GetService("Players").LocalPlayer.PlayerScripts
for _, mod in pairs(scripts:GetDescendants()) do
    if mod.Name == "QueueScreen" and mod:IsA("ModuleScript") then
        local ok, res = pcall(require, mod)
        if ok then QueueScreen = res end
        break
    end
end

if not QueueScreen then
    Rayfield:Notify({Title="Fehler", Content="QueueScreen Modul nicht gefunden!"})
end

-- AUTOMATISCHE AUSWAHL
Tab:CreateButton({
    Name = "Setup: Conch Street (Normal)",
    Callback = function()
        if QueueScreen then
            print("--- SENDE SETUP BEFEHLE ---")
            
            -- Wir nutzen pcall, falls eine Funktion fehlschlägt
            pcall(function() 
                print("Wähle Welt...")
                QueueScreen.SelectWorld("ConchStreet") 
            end)
            
            task.wait(0.5) -- Kurze Pause für Sicherheit
            
            pcall(function() 
                print("Wähle Kapitel...")
                QueueScreen.SelectChapter(1) 
            end)
            
            task.wait(0.5)
            
            pcall(function() 
                print("Wähle Schwierigkeit...")
                QueueScreen.SelectDifficulty("Normal") 
            end)
            
            Rayfield:Notify({Title="Erledigt", Content="Setup gesendet!"})
        else
            Rayfield:Notify({Title="Fehler", Content="Modul nicht geladen"})
        end
    end,
})

-- BEREIT BUTTON SUCHE
Tab:CreateButton({
    Name = "Finde 'BEREIT' Funktion",
    Callback = function()
        print("\n--- SUCHE NACH READY/START ---")
        if QueueScreen then
            for key, val in pairs(QueueScreen) do
                if type(val) == "function" then
                    -- Wir suchen nach Namen, die den Start auslösen könnten
                    print("Funktion: " .. key)
                    if key:lower():find("ready") or key:lower():find("start") or key:lower():find("confirm") then
                        warn("!!! TREFFER: " .. key .. " !!!")
                    end
                end
            end
            Rayfield:Notify({Title="Scan fertig", Content="Schau in F9 nach 'Ready'!"})
        end
    end,
})
