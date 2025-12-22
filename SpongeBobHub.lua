local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Internal Selector",
   LoadingTitle = "Synchronisiere mit Spiellogik...",
})

local MainTab = Window:CreateTab("Welten", 4483362458)
local selectedWorld = "ChumBucket"

MainTab:CreateDropdown({
   Name = "Welt wählen",
   Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
   CurrentOption = {"ChumBucket"},
   Callback = function(Option) selectedWorld = Option[1] end,
})

-- Name exakt wie im Screenshot: "Welt-Auswahl erzwingen"
MainTab:CreateButton({
   Name = "Welt-Auswahl erzwingen",
   Callback = function()
       local player = game.Players.LocalPlayer
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if screen then
           local success, err = pcall(function()
               -- 1. Internes Attribut setzen (aus deinem Log-Fund)
               screen:SetAttribute("Hidden", false)
               
               local selection = screen.Main.SelectionScreen
               local worlds = selection.Main.StageSelect.WorldSelect.Content.Stages
               
               -- 2. Sicherstellen, dass Chapter 1 aktiv ist (Triggert SelectChapter())
               local ch1 = selection.Main:FindFirstChild("Chapter1", true)
               if ch1 and ch1:IsA("GuiButton") then
                   firesignal(ch1.MouseButton1Click)
                   task.wait(0.2) -- Wartezeit für das Spiel-Backend
               end

               -- 3. Welt auswählen (Triggert SelectWorld())
               local targetBtn = worlds:FindFirstChild(selectedWorld)
               if targetBtn then
                   -- Wir feuern alle möglichen Signale ab
                   firesignal(targetBtn.MouseButton1Click)
                   firesignal(targetBtn.Activated)
                   
                   Rayfield:Notify({Title = "Erfolg", Content = "Auswahl für " .. selectedWorld .. " gestartet!"})
               end
           end)
           
           if not success then warn("Fehler: " .. tostring(err)) end
       end
   end,
})
