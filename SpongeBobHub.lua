local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Knit Scanner",
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
           print("!!! START: Knit-Methoden-Scan !!!")
           
           local success, err = pcall(function()
               local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
               local KnitClient = require(Knit.Parent.Knit)
               
               local worldCtrl = KnitClient.GetController("FactionWorldController")
               local uiCtrl = KnitClient.GetController("UIController")

               -- SCAN 1: FactionWorldController
               if worldCtrl then
                   print("--- Methoden in FactionWorldController: ---")
                   for name, func in pairs(worldCtrl) do
                       if type(func) == "function" then
                           print("Gefunden: " .. name)
                           -- Automatischer Versuch, wenn der Name passt
                           if name:find("World") or name:find("Stage") or name:find("Select") then
                               print("Versuche Aufruf: " .. name)
                               pcall(function() worldCtrl[name](worldCtrl, selectedWorld) end)
                           end
                       end
                   end
               end

               task.wait(0.5)

               -- SCAN 2: UIController (Hier liegt SelectChapter)
               if uiCtrl then
                   print("--- Methoden in UIController: ---")
                   for name, func in pairs(uiCtrl) do
                       if type(func) == "function" then
                           print("Gefunden: " .. name)
                           if name == "SelectChapter" then
                               print("Knit: Aktiviere Kapitel 1 via UIController")
                               uiCtrl:SelectChapter(1)
                           end
                       end
                   end
               end
           end)

           if not success then warn("Aktions-Fehler: " .. tostring(err)) end
       end,
    })
end
