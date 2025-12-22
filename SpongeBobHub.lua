local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local vim = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Pro Selector",
   LoadingTitle = "Hardware-Emulation startet...",
})

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
       local player = game.Players.LocalPlayer
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if screen then
           -- 1. Menü im System auf 'sichtbar' setzen (Wichtig laut deinem Log!)
           screen:SetAttribute("Hidden", false)
           
           local success, err = pcall(function()
               local stages = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
               local targetBtn = stages:FindFirstChild(selectedWorld)

               if targetBtn then
                   -- 2. Position auf dem Bildschirm berechnen
                   local pos = targetBtn.AbsolutePosition
                   local size = targetBtn.AbsoluteSize
                   -- Wir klicken genau in die Mitte des Buttons
                   local centerX = pos.X + (size.X / 2)
                   local centerY = pos.Y + (size.Y / 2) + 56 -- +56 für den Roblox-TopBar Offset

                   -- 3. Physischen Klick simulieren (Erzwingt SelectWorld())
                   vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                   task.wait(0.1)
                   vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                   
                   Rayfield:Notify({Title = "Aktion", Content = "Touch-Emulation an " .. selectedWorld .. " gesendet!"})
               end
           end)
           if not success then warn("Fehler: " .. tostring(err)) end
       end
   end,
})
