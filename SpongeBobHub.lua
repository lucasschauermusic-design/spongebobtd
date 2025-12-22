local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Master Selector",
   LoadingTitle = "Initialisiere Hardware-Brücke...",
})

-- Sicherstellen, dass das Tab existiert, bevor wir Buttons hinzufügen
local MainTab = Window:CreateTab("Welten", 4483362458)

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
               local success, err = pcall(function()
                   -- 1. Internes Attribut aus deinem Log setzen
                   screen:SetAttribute("Hidden", false) --
                   
                   local selection = screen.Main.SelectionScreen
                   local worlds = selection.Main.StageSelect.WorldSelect.Content.Stages
                   
                   -- 2. Kapitel 1 aktivieren (Voraussetzung laut deinem Log)
                   local ch1 = selection.Main:FindFirstChild("Chapter1", true)
                   if ch1 then
                       for _, v in pairs(getconnections(ch1.MouseButton1Click)) do v:Fire() end
                       task.wait(0.3)
                   end

                   -- 3. Welt auswählen (Triggert SelectWorld())
                   local targetBtn = worlds:FindFirstChild(selectedWorld) --
                   if targetBtn then
                       for _, v in pairs(getconnections(targetBtn.MouseButton1Click)) do
                           v:Fire()
                       end
                       Rayfield:Notify({Title = "Erfolg", Content = selectedWorld .. " angewählt!"})
                   end
               end)
               if not success then warn("Fehler: " .. tostring(err)) end
           end
       end,
    })
else
    warn("Konnte MainTab nicht erstellen!")
end
