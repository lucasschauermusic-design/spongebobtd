local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Logic Overdrive",
   LoadingTitle = "Erzwinge System-Synchronisation...",
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
           -- SCHRITT 1: Attribute setzen (Aus deinem Log-Fund)
           screen:SetAttribute("Hidden", false)
           screen:SetAttribute("SelectedWorld", selectedWorld)
           
           -- SCHRITT 2: Interne Funktionen suchen und direkt ausführen
           -- Wir scannen jetzt alle Scripte im PlayerGui, nicht nur im QueueScreen
           for _, script in pairs(player.PlayerGui:GetDescendants()) do
               if script:IsA("LocalScript") then
                   local success, sEnv = pcall(getsenv, script)
                   if success and sEnv then
                       -- Wir rufen die Funktionen in der richtigen Reihenfolge auf
                       if sEnv.SelectWorld then 
                           pcall(function() sEnv.SelectWorld(selectedWorld) end)
                       end
                       task.wait(0.1)
                       if sEnv.SelectChapter then 
                           pcall(function() sEnv.SelectChapter(1) end)
                       end
                   end
               end
           end

           -- SCHRITT 3: Physische Button-Verbindungen feuern (Fallback)
           local stages = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
           local targetBtn = stages:FindFirstChild(selectedWorld)
           if targetBtn then
               for _, connection in pairs(getconnections(targetBtn.MouseButton1Click)) do
                   connection:Fire()
               end
           end

           Rayfield:Notify({Title = "Sequenz beendet", Content = "Alle Signale für " .. selectedWorld .. " gesendet!"})
       end
   end,
})
