MainTab:CreateButton({
   Name = "Welt-Auswahl erzwingen (Touch-Mode)",
   Callback = function()
       local player = game.Players.LocalPlayer
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if screen then
           local success, err = pcall(function()
               local worlds = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
               local targetBtn = worlds:FindFirstChild(selectedWorld)

               if targetBtn then
                   -- Wir machen den Button für das System "aktiv"
                   targetBtn.Visible = true
                   
                   -- Wir holen uns die exakte Bildschirmposition des Buttons
                   local pos = targetBtn.AbsolutePosition
                   local size = targetBtn.AbsoluteSize
                   local centerX = pos.X + (size.X / 2)
                   local centerY = pos.Y + (size.Y / 2)

                   -- Wir simulieren eine Berührung (Touch) genau in der Mitte des Buttons
                   local VirtualUser = game:GetService("VirtualUser")
                   VirtualUser:SetKeyDown('0') -- Simuliert Aktivierung
                   VirtualUser:Button1Down(Vector2.new(centerX, centerY))
                   task.wait(0.05)
                   VirtualUser:Button1Up(Vector2.new(centerX, centerY))
                   
                   -- Zusätzlicher Versuch über das interne Signal
                   firesignal(targetBtn.Activated)
                   
                   Rayfield:Notify({Title = "Status", Content = "Touch-Signal an " .. selectedWorld .. " gesendet!"})
               end
           end)
           if not success then warn(err) end
       end
   end,
})
