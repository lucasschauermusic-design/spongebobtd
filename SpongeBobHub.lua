local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Fenster-Erstellung
local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Knit Selector",
   LoadingTitle = "Greife auf Knit-Controller zu...",
})

-- Sicherer Tab-Check gegen den Nil-Error
local MainTab = Window:CreateTab("Welten", 4483362458)
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
       local success, err = pcall(function()
           -- Wir suchen den Knit-Service im Spiel
           local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
           if Knit then
               local KnitClient = require(Knit.Parent.Knit) -- Knit laden
               
               -- Wir greifen die Controller aus deinem Screenshot ab
               local worldCtrl = KnitClient.GetController("FactionWorldController")
               local uiCtrl = KnitClient.GetController("UIController")

               -- Deine Reihenfolge: Erst Welt, dann Kapitel
               if worldCtrl and worldCtrl.SelectWorld then
                   worldCtrl:SelectWorld(selectedWorld)
               end
               
               task.wait(0.2)
               
               if uiCtrl and uiCtrl.SelectChapter then
                   uiCtrl:SelectChapter(1)
               end
               
               Rayfield:Notify({Title = "Knit Erfolg", Content = selectedWorld .. " über Controller gesetzt!"})
           else
               -- Fallback: Suche in den PlayerScripts
               for _, v in pairs(game.Players.LocalPlayer.PlayerScripts:GetDescendants()) do
                   if v:IsA("ModuleScript") and v.Name:find("Controller") then
                       local s = require(v)
                       if type(s) == "table" then
                           if s.SelectWorld then s:SelectWorld(selectedWorld) end
                           task.wait(0.1)
                           if s.SelectChapter then s:SelectChapter(1) end
                       end
                   end
               end
           end
       end)
       
       if not success then warn("Knit-Fehler: " .. tostring(err)) end
   end,
})
