local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Map Selector",
   LoadingTitle = "Lade Auswahl-Logik...",
})

local MainTab = Window:CreateTab("Welten", 4483362458)

local selectedWorld = "ChumBucket"

-- Dropdown für die Welten
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
           -- Der Pfad aus deinen Dex-Funden
           local worlds = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
           local targetBtn = worlds:FindFirstChild(selectedWorld)

           if targetBtn and targetBtn:IsA("GuiObject") then
               -- Wir versuchen mehrere Signale, damit das Spiel die Auswahl erzwingt
               if firesignal then
                   firesignal(targetBtn.MouseButton1Down)
                   task.wait(0.05)
                   firesignal(targetBtn.MouseButton1Up)
                   task.wait(0.05)
                   firesignal(targetBtn.MouseButton1Click)
               else
                   -- Fallback für andere Executor
                   for _, connection in pairs(getconnections(targetBtn.MouseButton1Click)) do
                       connection:Fire()
                   end
               end
               
               Rayfield:Notify({Title = "Erfolg", Content = selectedWorld .. " wurde angewählt!"})
           else
               Rayfield:Notify({Title = "Fehler", Content = "Welt " .. selectedWorld .. " nicht gefunden!"})
           end
       end)

       if not success then 
           warn("Fehler im Script: " .. tostring(err)) 
           Rayfield:Notify({Title = "Callback Error", Content = "Prüfe die Konsole (F9)"})
       end
   end,
})
