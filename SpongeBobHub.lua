local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Simple Map Selector",
   LoadingTitle = "Lade Map-Logik...",
})

local MainTab = Window:CreateTab("Welten", 4483362458)

local selectedWorld = "ChumBucket"

-- Dropdown nur für die Welten
MainTab:CreateDropdown({
   Name = "Welt wählen",
   Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
   CurrentOption = {"ChumBucket"},
   Callback = function(Option) 
       selectedWorld = Option[1] 
   end,
})

MainTab:CreateButton({
   Name = "Map im Menü auswählen",
   Callback = function()
       local player = game.Players.LocalPlayer
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if not screen then
           Rayfield:Notify({Title = "Fehler", Content = "Bitte öffne zuerst das Map-Menü im Spiel!"})
           return
       end

       local success, err = pcall(function()
           -- Der Pfad, den du in Dex bestätigt hast
           local worlds = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
           local targetBtn = worlds:FindFirstChild(selectedWorld)

           if targetBtn then
               -- Simuliert den Klick auf die Map
               if firesignal then
                   firesignal(targetBtn.MouseButton1Click)
               else
                   -- Alternative Methode für andere Executor
                   for _, v in pairs(getconnections(targetBtn.MouseButton1Click)) do
                       v:Fire()
                   end
               end
               
               Rayfield:Notify({Title = "Erfolg", Content = selectedWorld .. " wurde markiert!"})
           else
               Rayfield:Notify({Title = "Fehler", Content = "Welt " .. selectedWorld .. " nicht gefunden!"})
           end
       end)

       if not success then warn("Fehler: " .. tostring(err)) end
   end,
})
