local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Final Sequence",
   LoadingTitle = "Synchronisiere Knit-Logik...",
})

-- Wir definieren das Tab sicher
local MainTab = Window:CreateTab("Welten", 4483362458)
local selectedWorld = "ChumBucket"

-- Sicherstellen, dass der Tab existiert, bevor wir Dropdowns hinzufügen
if MainTab then
    MainTab:CreateDropdown({
       Name = "Welt wählen",
       Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
       CurrentOption = {"ChumBucket"},
       Callback = function(Option) selectedWorld = Option[1] end,
    })

    MainTab:CreateButton({
       Name = "Welt-Auswahl erzwingen",
       Callback = function()
           local success, err = pcall(function()
               -- Knit-Dienst suchen
               local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
               if not Knit then 
                   Rayfield:Notify({Title = "Fehler", Content = "Knit Framework nicht gefunden!"})
                   return 
               end
               
               local KnitClient = require(Knit.Parent.Knit)
               
               -- Die Controller aus deinem Screenshot
               local worldCtrl = KnitClient.GetController("FactionWorldController")
               local uiCtrl = KnitClient.GetController("UIController")

               -- DEINE REIHENFOLGE: Zuerst World, dann Chapter
               if worldCtrl then
                   print("Schritt 1: Welt wird gesetzt...")
                   worldCtrl:SelectWorld(selectedWorld)
               end
               
               task.wait(0.7) -- Etwas längere Pause für die Server-Synchronisation
               
               if uiCtrl then
                   print("Schritt 2: Kapitel wird aktiviert...")
                   uiCtrl:SelectChapter(1)
               end

               -- ZUSATZ: Wir setzen das Attribut zur Sicherheit
               local screen = game.Players.LocalPlayer.PlayerGui:FindFirstChild("QueueScreen")
               if screen then
                   screen:SetAttribute("Hidden", false)
               end
               
               Rayfield:Notify({Title = "Sequenz beendet", Content = "World -> Chapter erfolgreich!"})
           end)
           
           if not success then 
               warn("Kritischer Fehler: " .. tostring(err)) 
               Rayfield:Notify({Title = "Fehler", Content = "Prüfe die Konsole (F9)"})
           end
       end,
    })
end
