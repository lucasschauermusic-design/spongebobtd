local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Auto-Start Hub",
   LoadingTitle = "Lade Spiel-Konfiguration...",
   LoadingSubtitle = "by DeinName",
})

local MainTab = Window:CreateTab("Level Auswahl", 4483362458)

local selectedWorld = "ChumBucket"
local selectedLevel = "1"
local selectedDiff = "Normal"

-- Welt Dropdown
MainTab:CreateDropdown({
   Name = "Welt",
   Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KrustyKrab", "SandysTreedome", "RockBottom", "KampKoral"},
   CurrentOption = {"ChumBucket"},
   Callback = function(Option) selectedWorld = Option[1] end,
})

-- Level Dropdown
MainTab:CreateDropdown({
   Name = "Level",
   Options = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
   CurrentOption = {"1"},
   Callback = function(Option) selectedLevel = Option[1] end,
})

-- Schwierigkeit Dropdown
MainTab:CreateDropdown({
   Name = "Schwierigkeit",
   Options = {"Normal", "Hard", "Nightmare", "Davy Jones"},
   CurrentOption = {"Normal"},
   Callback = function(Option) selectedDiff = Option[1] end,
})

-- Start Funktion
MainTab:CreateButton({
   Name = "In Map-Zone teleportieren",
   Callback = function()
       local targetMap = selectedWorld .. "_" .. selectedLevel
       print("Teleportiere zu: " .. targetMap .. " (" .. selectedDiff .. ")")
       
       -- Suchen der Teleport-Zone im Workspace
       -- Hier nutzen wir den Pfad aus deinem Screenshot
       local character = game.Players.LocalPlayer.Character
       local lobbyArea = game.Workspace:FindFirstChild("Matchmakers", true)
       
       if character and character:FindFirstChild("HumanoidRootPart") then
           -- Simpler Teleport-Befehl zur QueueArea
           character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Platzhalter-Koordinaten
           
           Rayfield:Notify({
              Title = "Teleport",
              Content = "Du wirst zur Zone bewegt. Bitte kurz warten!",
              Duration = 3
           })
       end
   end,
})
