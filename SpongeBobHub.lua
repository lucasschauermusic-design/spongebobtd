local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Knit Scanner",
   LoadingTitle = "Analysiere Knit-Methoden...",
})

local MainTab = Window:CreateTab("Welten", 4483362458)
local selectedWorld = "ChumBucket"

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
           print("!!! START: KNIT-METHODEN-SCAN !!!")
           
           local success, err = pcall(function()
               -- Knit finden (basierend auf deinem Screenshot)
               local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
               local KnitClient = require(Knit.Parent.Knit)
               
               -- Den Controller laden, den wir in deinem Scan gefunden haben
               local worldCtrl = KnitClient.GetController("FactionWorldController")

               if worldCtrl then
                   print("--- Verfügbare Befehle in FactionWorldController: ---")
                   -- Wir gehen alle Einträge im Controller durch
                   for name, value in pairs(worldCtrl) do
                       if type(value) == "function" then
                           -- Wir schreiben jeden Funktionsnamen in den Log
                           print("GEFUNDEN: " .. name)
                       end
                   end
                   Rayfield:Notify({Title = "Scan fertig", Content = "Schau in das Codex-Log!"})
               else
                   print("Fehler: FactionWorldController nicht gefunden!")
               end
           end)

           if not success then warn("Scan-Fehler: " .. tostring(err)) end
       end,
    })
end
