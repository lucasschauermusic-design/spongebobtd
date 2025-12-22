local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local vim = game:GetService("VirtualInputManager") -- Emuliert echte Hardware-Eingaben

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Pro Selector",
   LoadingTitle = "Emuliere Touch-Eingabe...",
})

-- Sicherstellen, dass das Tab existiert (Fix für den Nil-Error)
local MainTab = Window:CreateTab("Welten", 4483362458)
task.wait(0.5)

if MainTab then
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
               -- 1. Internes Attribut setzen (Wichtig laut deinem Log!)
               screen:SetAttribute("Hidden", false)
               
               local success, err = pcall(function()
                   local worlds = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
                   local targetBtn = worlds:FindFirstChild(selectedWorld)

                   if targetBtn then
                       -- 2. Position auf dem Bildschirm berechnen
                       local pos = targetBtn.AbsolutePosition
                       local size = targetBtn.AbsoluteSize
                       -- Wir klicken genau in die Mitte des Buttons
                       local centerX = pos.X + (size.X / 2)
                       local centerY = pos.Y + (size.Y / 2) + 58 -- Offset für die TopBar

                       -- 3. Physischen Klick simulieren
                       vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1) -- Drücken
                       task.wait(0.1)
                       vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1) -- Loslassen
                       
                       -- 4. Sicherheitshalber das Activated-Event zusätzlich feuern
                       firesignal(targetBtn.Activated)
                       
                       Rayfield:Notify({Title = "Status", Content = "Touch-Klick an " .. selectedWorld .. " emuliert!"})
                   end
               end)
               if not success then warn("Fehler: " .. tostring(err)) end
           else
               Rayfield:Notify({Title = "Fehler", Content = "Bitte Map-Menü öffnen!"})
           end
       end,
    })
end
