local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Befehls-Scanner",
   LoadingTitle = "Analysiere Knit-Methoden...",
})

local MainTab = Window:CreateTab("Welten", 4483362458)

if MainTab then
    MainTab:CreateButton({
       -- Name exakt wie in deinem Screenshot
       Name = "Welt-Auswahl erzwingen",
       Callback = function()
           print("!!! START: KNIT-METHODEN-SCAN !!!")
           
           local success, err = pcall(function()
               -- Knit-Pfad aus deinem Scan nutzen
               local KnitPath = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
               local KnitClient = require(KnitPath.Parent.Knit)
               
               local worldCtrl = KnitClient.GetController("FactionWorldController")
               local uiCtrl = KnitClient.GetController("UIController")

               -- SCAN 1: Alle Befehle für die Welt auflisten
               if worldCtrl then
                   print("--- Methoden im FactionWorldController: ---")
                   for name, func in pairs(worldCtrl) do
                       if type(func) == "function" then
                           print("Gefunden: " .. name)
                       end
                   end
               end

               -- SCAN 2: Alle Befehle für das UI auflisten
               if uiCtrl then
                   print("--- Methoden im UIController: ---")
                   for name, func in pairs(uiCtrl) do
                       if type(func) == "function" then
                           print("Gefunden: " .. name)
                       end
                   end
               end
           end)

           if success then
               Rayfield:Notify({Title = "Scan fertig", Content = "Schau jetzt in dein Codex-Log!"})
           else
               warn("Scan-Fehler: " .. tostring(err))
           end
       end,
    })
end
