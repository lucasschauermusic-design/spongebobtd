MainTab:CreateButton({
   Name = "Auswahl erzwingen (Chapter + World)",
   Callback = function()
       local player = game.Players.LocalPlayer
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if screen then
           local success, err = pcall(function()
               -- 1. Das Menü im System "freischalten"
               screen:SetAttribute("Hidden", false)
               
               -- 2. Pfade definieren
               local selection = screen.Main.SelectionScreen
               local worlds = selection.Main.StageSelect.WorldSelect.Content.Stages
               
               -- 3. Zuerst sicherstellen, dass Chapter 1 aktiv ist (falls ein Button da ist)
               -- Im Log stand 'Already selected chapter 1', wir triggern es zur Sicherheit
               local ch1 = selection.Main:FindFirstChild("Chapter1", true) or selection:FindFirstChild("1", true)
               if ch1 and ch1:IsA("GuiButton") then
                   firesignal(ch1.MouseButton1Click)
               end
               
               task.wait(0.1)

               -- 4. Die Welt auswählen
               local targetBtn = worlds:FindFirstChild(selectedWorld)
               if targetBtn then
                   -- Wir feuern alles ab, was das Spiel registrieren könnte
                   firesignal(targetBtn.MouseButton1Down)
                   firesignal(targetBtn.MouseButton1Click)
                   firesignal(targetBtn.Activated)
                   
                   -- Wir versuchen den Text-Wert direkt zu setzen, falls das Spiel darauf achtet
                   if targetBtn:FindFirstChild("Title") then
                       print("Sende Klick an: " .. targetBtn.Title.Text)
                   end
               end
           end)
           
           if success then
               Rayfield:Notify({Title = "Status", Content = "Sequenz für " .. selectedWorld .. " gesendet!"})
           else
               warn("Fehler: " .. tostring(err))
           end
       end
   end,
})
