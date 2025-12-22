local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Internal Selector",
   LoadingTitle = "Verbinde mit Spiellogik...",
})

-- Hier stellen wir sicher, dass das Tab korrekt erstellt wird
local MainTab = Window:CreateTab("Welten", 4483362458)

local selectedWorld = "ChumBucket"

-- Dropdown zur Auswahl
MainTab:CreateDropdown({
   Name = "Welt wählen",
   Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
   CurrentOption = {"ChumBucket"},
   Callback = function(Option) 
      selectedWorld = Option[1] 
   end,
})

-- Der Button nutzt die Namen aus deinem Screenshot
MainTab:CreateButton({
   Name = "Welt-Auswahl erzwingen",
   Callback = function()
       local player = game.Players.LocalPlayer
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if screen then
           local success, err = pcall(function()
               -- 1. Menü intern aktivieren
               screen:SetAttribute("Hidden", false)
               
               local selection = screen.Main.SelectionScreen
               local worlds = selection.Main.StageSelect.WorldSelect.Content.Stages
               
               -- 2. Kapitel 1 triggern (da dies laut Log oft Voraussetzung ist)
               local ch1 = selection.Main:FindFirstChild("Chapter1", true)
               if ch1 then
                   for _, v in pairs(getconnections(ch1.MouseButton1Click)) do v:Fire() end
                   task.wait(0.3)
               end

               -- 3. Welt auswählen
               local targetBtn = worlds:FindFirstChild(selectedWorld)
               if targetBtn then
                   -- Wir feuern die Klicks direkt an die Spiellogik
                   for _, v in pairs(getconnections(targetBtn.MouseButton1Click)) do
                       v:Fire()
                   end
                   
                   Rayfield:Notify({Title = "Erfolg", Content = "Befehl für " .. selectedWorld .. " gesendet!"})
               else
                   Rayfield:Notify({Title = "Fehler", Content = "Welt im Pfad nicht gefunden!"})
               end
           end)
           
           if not success then warn("Fehler: " .. tostring(err)) end
       else
           Rayfield:Notify({Title = "Hinweis", Content = "QueueScreen nicht gefunden!"})
       end
   end,
})
