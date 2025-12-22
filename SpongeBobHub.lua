local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Sequence Fix",
   LoadingTitle = "Synchronisiere Reihenfolge...",
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
       local screen = game.Players.LocalPlayer.PlayerGui:FindFirstChild("QueueScreen")
       if not screen then 
           Rayfield:Notify({Title = "Fehler", Content = "Menü nicht offen!"})
           return 
       end

       -- 1. Menü intern auf 'sichtbar' setzen
       screen:SetAttribute("Hidden", false)

       local success, err = pcall(function()
           -- PFADE DEFINIEREN
           local selection = screen.Main.SelectionScreen
           local worlds = selection.Main.StageSelect.WorldSelect.Content.Stages
           local chapterBtn = selection.Main:FindFirstChild("Chapter1", true) -- Sucht den Kapitel-Button

           -- SCHRITT 1: WELT AUSWÄHLEN (Deine gewünschte Reihenfolge)
           local targetBtn = worlds:FindFirstChild(selectedWorld)
           if targetBtn then
               for _, v in pairs(getconnections(targetBtn.MouseButton1Click)) do v:Fire() end
               firesignal(targetBtn.Activated)
               print("Schritt 1: Welt " .. selectedWorld .. " angewählt.")
           end

           task.wait(0.5) -- Kurze Pause für die Verarbeitung im Spiel

           -- SCHRITT 2: KAPITEL AUSWÄHLEN
           if chapterBtn then
               for _, v in pairs(getconnections(chapterBtn.MouseButton1Click)) do v:Fire() end
               firesignal(chapterBtn.Activated)
               print("Schritt 2: Kapitel 1 angewählt.")
           end
           
           -- ZUSATZ: INTERNER FUNKTIONSAUFRUF (Falls Buttons allein nicht reichen)
           for _, script in pairs(game:GetDescendants()) do
               if script:IsA("LocalScript") and script.Name:find("Queue") then
                   local sEnv = getsenv(script)
                   if sEnv and sEnv.SelectWorld and sEnv.SelectChapter then
                       sEnv.SelectWorld(selectedWorld)
                       task.wait(0.1)
                       sEnv.SelectChapter(1)
                       print("Logik-Aufruf: World -> Chapter erfolgreich.")
                   end
               end
           end
       end)

       if success then
           Rayfield:Notify({Title = "Sequenz aktiv", Content = "World -> Chapter wurde gesendet!"})
       else
           warn("Fehler in der Sequenz: " .. tostring(err))
       end
   end,
})
