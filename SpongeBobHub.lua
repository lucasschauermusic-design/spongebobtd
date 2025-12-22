print("LOG 1: Script gestartet")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeFix: Knit",
   LoadingTitle = "Warte auf Controller...",
})
print("LOG 2: Fenster initialisiert")

local MainTab = Window:CreateTab("Welten", 4483362458)

-- Wir prüfen sofort, ob das Tab existiert
if MainTab then
    print("LOG 3: Tab erfolgreich erstellt")
    local selectedWorld = "ChumBucket"

    MainTab:CreateDropdown({
       Name = "Welt wählen",
       Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
       CurrentOption = {"ChumBucket"},
       Callback = function(Option) selectedWorld = Option[1] end,
    })

    MainTab:CreateButton({
       Name = "Welt-Auswahl erzwingen",
       Callback = function()
           print("!!! BUTTON GEDRÜCKT !!!")
           
           local success, err = pcall(function()
               -- Knit Framework abrufen
               local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
               if Knit then
                   local KnitClient = require(Knit.Parent.Knit)
                   
                   -- Controller aus deinem Screenshot
                   local worldCtrl = KnitClient.GetController("FactionWorldController")
                   local uiCtrl = KnitClient.GetController("UIController")

                   -- REIHENFOLGE: ERST WELT, DANN KAPITEL
                   if worldCtrl then
                       print("Knit: Sende SelectWorld -> " .. selectedWorld)
                       worldCtrl:SelectWorld(selectedWorld)
                   end

                   task.wait(0.6) -- Zeit für den Server-Check

                   if uiCtrl then
                       print("Knit: Sende SelectChapter -> 1")
                       uiCtrl:SelectChapter(1)
                   end
                   
                   Rayfield:Notify({Title = "Erfolg", Content = "Signale an Knit-Controller gesendet!"})
               else
                   print("Fehler: Knit-Framework nicht gefunden.")
               end
           end)

           if not success then warn("Aktions-Fehler: " .. tostring(err)) end
       end,
    })
    print("LOG 4: Alles bereit!")
else
    warn("KRITISCH: Tab konnte nicht erstellt werden!")
end
