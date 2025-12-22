local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: UI-Automator",
   LoadingTitle = "Lade Menü-Verknüpfungen...",
})

local MainTab = Window:CreateTab("Auto-Select", 4483362458)

-- Variablen für die Auswahl
local selectedWorld = "ChumBucket"
local selectedLevel = "1"
local selectedDiff = "Normal" -- Muss exakt wie in Dex heißen (z.B. DavyJones)

-- Dropdowns (hier die Listen einfügen, die wir aus Dex ausgelesen haben)
MainTab:CreateDropdown({
   Name = "Wähle Schwierigkeit",
   Options = {"Normal", "Hard", "Nightmare", "DavyJones"},
   CurrentOption = {"Normal"},
   Callback = function(Option)
      selectedDiff = Option[1]
   end,
})

-- Der Button, der die Auswahl im Spiel-UI "anklickt"
MainTab:CreateButton({
   Name = "Auswahl im Spiel bestätigen",
   Callback = function()
       local player = game.Players.LocalPlayer
       -- Wir nutzen den Pfad, den du in Dex gefunden hast
       local screen = player.PlayerGui:FindFirstChild("QueueScreen")
       
       if screen then
           local diffFolder = screen.Main.SelectionScreen.Info.Content.Difficulties
           local targetBtn = diffFolder:FindFirstChild(selectedDiff)
           
           if targetBtn and targetBtn:IsA("TextButton") then
               -- Simulation des Klicks
               -- Wir nutzen 'firesignal', was in Codex meist verfügbar ist
               firesignal(targetBtn.MouseButton1Click)
               
               Rayfield:Notify({
                  Title = "Erfolg",
                  Content = selectedDiff .. " wurde im Menü ausgewählt!",
                  Duration = 3
               })
           else
               print("Button nicht gefunden: " .. selectedDiff)
           end
       else
           Rayfield:Notify({
              Title = "Hinweis",
              Content = "Bitte öffne zuerst das Map-Menü im Spiel!",
              Duration = 5
           })
       end
   end,
})
