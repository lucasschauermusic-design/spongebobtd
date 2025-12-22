local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Fenster-Initialisierung
local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Knit-Fix",
   LoadingTitle = "Lade Hardware-Schnittstelle...",
})

-- Wir erstellen das Tab direkt ohne Schleifen
local MainTab = Window:CreateTab("Welten", 4483362458)

local selectedWorld = "ChumBucket"

-- Nur wenn das Tab existiert, fügen wir Elemente hinzu
if MainTab then
    print("UI: Tab erfolgreich erstellt!")

    MainTab:CreateDropdown({
       Name = "Welt wählen",
       Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
       CurrentOption = {"ChumBucket"},
       Callback = function(Option) selectedWorld = Option[1] end,
    })

    MainTab:CreateButton({
       Name = "Welt-Auswahl erzwingen",
       Callback = function()
           -- Diese Nachricht MUSS im Log erscheinen
           print("--- START: Knit-Befehl ---")
           
           local success, err = pcall(function()
               -- Knit direkt im ReplicatedStorage suchen
               local ReplicatedStorage = game:GetService("ReplicatedStorage")
               local KnitPath = ReplicatedStorage:FindFirstChild("Knit", true)
               
               if KnitPath then
                   local KnitClient = require(KnitPath.Parent.Knit)
                   
                   -- Zugriff auf die Controller aus deinem Scan
                   local worldCtrl = KnitClient.GetController("FactionWorldController")
                   local uiCtrl = KnitClient.GetController("UIController")

                   -- Schritt 1: Welt (Deine Reihenfolge!)
                   if worldCtrl then
                       print("Knit: Setze Welt auf " .. selectedWorld)
                       worldCtrl:SelectWorld(selectedWorld)
                   end

                   task.wait(0.5)

                   -- Schritt 2: Kapitel
                   if uiCtrl then
                       print("Knit: Aktiviere Kapitel 1")
                       uiCtrl:SelectChapter(1)
                   end
                   
                   Rayfield:Notify({Title = "Knit-Status", Content = "Befehle gesendet!"})
               else
                   print("Knit-Framework Pfad nicht gefunden!")
               end
           end)

           if not success then 
               warn("Fehler in der Knit-Logik: " .. tostring(err)) 
           end
       end,
    })
else
    print("Fehler: MainTab konnte nicht initialisiert werden.")
end
