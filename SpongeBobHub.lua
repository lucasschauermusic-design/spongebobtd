local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Auto-UI",
   LoadingTitle = "Verbinde...",
})

local MainTab = Window:CreateTab("Auto-Select", 4483362458)

local selectedDiff = "Normal"

MainTab:CreateDropdown({
   Name = "Wähle Schwierigkeit",
   Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
   CurrentOption = {"Normal"},
   Callback = function(Option)
      selectedDiff = Option[1]
   end,
})

MainTab:CreateButton({
   Name = "Auswahl im Spiel bestätigen",
   Callback = function()
       -- 1. Pfad sicher abrufen
       local player = game.Players.LocalPlayer
       local queueScreen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if not queueScreen then
           Rayfield:Notify({Title = "Fehler", Content = "QueueScreen nicht gefunden! Bitte Menü öffnen.", Duration = 3})
           return
       end

       -- 2. Den exakten Pfad aus deinen Dex-Screenshots nutzen
       -- Pfad: QueueScreen -> Main -> SelectionScreen -> Info -> Content -> Difficulties
       local success, err = pcall(function()
           local diffs = queueScreen.Main.SelectionScreen.Info.Content.Difficulties
           local btn = diffs:FindFirstChild(selectedDiff)

           if btn and btn:IsA("TextButton") then
               -- Wir versuchen verschiedene Klick-Methoden für Codex
               if firesignal then
                   firesignal(btn.MouseButton1Click)
               elseif btn.MouseButton1Click then
                   -- Alternative falls firesignal fehlt
                   for _, v in pairs(getconnections(btn.MouseButton1Click)) do
                       v:Fire()
                   end
               end
               Rayfield:Notify({Title = "Erfolg", Content = selectedDiff .. " ausgewählt!", Duration = 2})
           else
               Rayfield:Notify({Title = "Fehler", Content = "Button " .. selectedDiff .. " nicht gefunden!", Duration = 3})
           end
       end)

       if not success then
           warn("Callback Error: " .. tostring(err))
           Rayfield:Notify({Title = "Script Fehler", Content = "Pfad im Menü ist anders als erwartet.", Duration = 5})
       end
   end,
})
