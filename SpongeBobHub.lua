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

MainTab:CreateButton({
   Name = "Welt-Auswahl erzwingen",
   Callback = function()
       local player = game.Players.LocalPlayer
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if screen then
           -- Wir setzen das Attribut, das wir im Log gesehen haben
           screen:SetAttribute("Hidden", false)
           
           local worlds = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
           local targetBtn = worlds:FindFirstChild(selectedWorld)

           if targetBtn then
               -- Wir simulieren den Klick, der die 'SelectWorld()' Funktion auslöst
               for _, connection in pairs(getconnections(targetBtn.MouseButton1Click)) do
                   connection:Fire()
               end
               
               Rayfield:Notify({Title = "Erfolg", Content = "Interne Auswahl für " .. selectedWorld .. " gestartet!"})
           end
       end
   end,
})
