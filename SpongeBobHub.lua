local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Deep Search",
   LoadingTitle = "Scanne alle Knit-Controller...",
})

local MainTab = Window:CreateTab("System-Scan", 4483362458)

if MainTab then
    MainTab:CreateButton({
       Name = "Alle Controller auflisten",
       Callback = function()
           print("--- START: VOLLSTÄNDIGER KNIT-SCAN ---")
           
           local success, err = pcall(function()
               local Knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit", true)
               local KnitClient = require(Knit.Parent.Knit)
               
               -- Wir greifen auf die interne Liste aller Controller zu
               -- Knit speichert diese meistens in einer Tabelle namens "Controllers"
               local controllers = KnitClient.Controllers or {}
               
               print("Gefundene Controller im System:")
               for name, ctrl in pairs(controllers) do
                   print("Controller: " .. name)
                   
                   -- Wenn der Name nach Spiel-Logik klingt, scannen wir die Methoden
                   if name:find("Stage") or name:find("Match") or name:find("Queue") or name:find("Map") or name:find("Level") then
                       print("--- ANALYSE: " .. name .. " ---")
                       for methodName, func in pairs(ctrl) do
                           if type(func) == "function" then
                               print("  > Methode: " .. methodName)
                           end
                       end
                   end
               end
           end)

           if success then
               Rayfield:Notify({Title = "Scan beendet", Content = "Alle Controller wurden im Log aufgelistet!"})
           else
               warn("Kritischer Scan-Fehler: " .. tostring(err))
           end
       end,
    })
end
