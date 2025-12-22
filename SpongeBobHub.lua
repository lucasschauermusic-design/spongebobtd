local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 1. Fenster erstellen
local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Final Knit",
   LoadingTitle = "Verbinde mit FactionWorldController...",
})

-- 2. Tab erstellen und aktiv warten, bis es existiert (Fix für Nil-Error)
local MainTab = Window:CreateTab("Welten", 4483362458)
while not MainTab do task.wait(0.1) end -- Warteschleife gegen den Absturz

local selectedWorld = "ChumBucket"

-- 3. Dropdown hinzufügen
MainTab:CreateDropdown({
   Name = "Welt wählen",
   Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
   CurrentOption = {"ChumBucket"},
   Callback = function(Option) selectedWorld = Option[1] end,
})

-- 4. Der Button mit der Knit-Logik aus deinem Fund
MainTab:CreateButton({
   Name = "Welt-Auswahl erzwingen",
   Callback = function()
       print("--- START: Knit-Sequenz ---") -- Dies MUSS jetzt im Log stehen!
       
       local success, err = pcall(function()
           -- Knit-Framework abrufen
           local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
           if not Knit then 
               print("Knit-Framework nicht im ReplicatedStorage gefunden!")
               return 
           end
           
           local KnitClient = require(Knit.Parent.Knit)
           
           -- Controller aus deinem Screenshot ansprechen
           local worldCtrl = KnitClient.GetController("FactionWorldController")
           local uiCtrl = KnitClient.GetController("UIController")

           -- DEINE REIHENFOLGE: Erst Welt, dann Kapitel
           if worldCtrl then
               print("Sende SelectWorld an FactionWorldController: " .. selectedWorld)
               worldCtrl:SelectWorld(selectedWorld)
           else
               print("FactionWorldController nicht gefunden!")
           end

           task.wait(0.8) -- Sicherheits-Pause für die Server-Synchronisation

           if uiCtrl then
               print("Sende SelectChapter(1) an UIController...")
               uiCtrl:SelectChapter(1)
           else
               print("UIController nicht gefunden!")
           end
           
           -- UI-Attribut erzwingen (aus deinem Log)
           local screen = game.Players.LocalPlayer.PlayerGui:FindFirstChild("QueueScreen")
           if screen then screen:SetAttribute("Hidden", false) end
       end)

       if success then
           print("--- ENDE: Sequenz erfolgreich gesendet ---")
           Rayfield:Notify({Title = "Erfolg", Content = "Knit-Befehle wurden abgesetzt!"})
       else
           warn("Kritischer Knit-Fehler: " .. tostring(err))
       end
   end,
})
