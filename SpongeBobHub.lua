local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Knit Master",
   LoadingTitle = "Analysiere Controller-Methoden...",
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
           print("!!! START: Knit-Suche !!!")
           
           local success, err = pcall(function()
               local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
               local KnitClient = require(Knit.Parent.Knit)
               
               -- Controller aus deinem Fund
               local worldCtrl = KnitClient.GetController("FactionWorldController")
               local uiCtrl = KnitClient.GetController("UIController")

               -- SCHRITT 1: Die richtige Welt-Funktion finden
               if worldCtrl then
                   local foundMethod = nil
                   -- Wir suchen nach Namen wie SelectWorld, SetWorld, JoinWorld
                   for name, func in pairs(worldCtrl) do
                       if type(func) == "function" and (name:find("World") or name:find("Stage")) then
                           print("Mögliche Methode gefunden: " .. name)
                           foundMethod = name
                       end
                   end

                   if foundMethod then
                       print("Knit: Rufe " .. foundMethod .. " für " .. selectedWorld)
                       worldCtrl[foundMethod](worldCtrl, selectedWorld)
                   else
                       print("Keine passende Welt-Methode im FactionWorldController gefunden!")
                   end
               end

               task.wait(0.5)

               -- SCHRITT 2: Kapitel aktivieren (Name ist sicher aus deinem Log)
               if uiCtrl and uiCtrl.SelectChapter then
                   print("Knit: Aktiviere Kapitel 1")
                   uiCtrl:SelectChapter(1)
               end
           end)

           if not success then warn("Aktions-Fehler: " .. tostring(err)) end
       end,
    })
end
