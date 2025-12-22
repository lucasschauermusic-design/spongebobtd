local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Reset Fix",
   LoadingTitle = "Initialisiere Hardware-Brücke...",
})

-- Wir erstellen das Tab und warten kurz, um sicherzugehen, dass es existiert
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
               -- Internes Attribut setzen (aus deinem Log)
               screen:SetAttribute("Hidden", false)
               
               local worlds = screen.Main.SelectionScreen.Main.StageSelect.WorldSelect.Content.Stages
               local targetBtn = worlds:FindFirstChild(selectedWorld)

               if targetBtn then
                   -- Nutze getconnections für maximale Zuverlässigkeit
                   for _, v in pairs(getconnections(targetBtn.MouseButton1Click)) do
                       v:Fire()
                   end
                   Rayfield:Notify({Title = "Erfolg", Content = selectedWorld .. " angewählt!"})
               end
           end
       end,
    })
else
    warn("FEHLER: MainTab konnte nicht erstellt werden. Bitte Script neu laden.")
end
