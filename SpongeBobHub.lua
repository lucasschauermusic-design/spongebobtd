local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Global Selector",
   LoadingTitle = "Suche Spiellogik...",
})

local MainTab = Window:CreateTab("Welten", 4483362458)
local selectedWorld = "ChumBucket"

-- Dropdown zur Auswahl
MainTab:CreateDropdown({
   Name = "Welt wählen",
   Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
   CurrentOption = {"ChumBucket"},
   Callback = function(Option) selectedWorld = Option[1] end,
})

-- Button-Name exakt wie in deinem Screenshot
MainTab:CreateButton({
   Name = "Welt-Auswahl erzwingen",
   Callback = function()
       local found = false
       
       -- Wir durchsuchen JEDES Script nach der SelectWorld-Funktion
       for _, script in pairs(game:GetDescendants()) do
           if script:IsA("LocalScript") then
               local success, sEnv = pcall(getsenv, script)
               if success and sEnv and (sEnv.SelectWorld or sEnv.SelectChapter) then
                   pcall(function()
                       -- Zuerst Chapter 1 wählen (Voraussetzung laut Log)
                       if sEnv.SelectChapter then sEnv.SelectChapter(1) end
                       task.wait(0.1)
                       -- Dann die Welt setzen
                       if sEnv.SelectWorld then sEnv.SelectWorld(selectedWorld) end
                       found = true
                   end)
               end
           end
       end

       if found then
           Rayfield:Notify({Title = "Erfolg", Content = "Logik für " .. selectedWorld .. " gefunden und ausgeführt!"})
       else
           -- Fallback: UI-Klick Methode
           local screen = game.Players.LocalPlayer.PlayerGui:FindFirstChild("QueueScreen")
           if screen then
               local btn = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages:FindFirstChild(selectedWorld)
               if btn then
                   for _, v in pairs(getconnections(btn.MouseButton1Click)) do v:Fire() end
                   Rayfield:Notify({Title = "Fallback", Content = "Button-Klick gesendet!"})
               end
           end
       end
   end,
})
