local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SpongeBob TD: Remote Bypass",
   LoadingTitle = "Suche Server-Schnittstelle...",
})

-- Sicherer Tab-Aufbau gegen den Nil-Error
local MainTab = Window:CreateTab("Welten", 4483362458)
local selectedWorld = "ChumBucket"

if MainTab then
    MainTab:CreateDropdown({
       Name = "Welt wählen",
       Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"},
       CurrentOption = {"ChumBucket"},
       Callback = function(Option) selectedWorld = Option[1] end,
    })

    MainTab:CreateButton({
       Name = "Welt-Auswahl erzwingen",
       Callback = function()
           local success, err = pcall(function()
               -- 1. Wir suchen alle Funk-Schnittstellen (Remotes) in Knit
               local replicatedStorage = game:GetService("ReplicatedStorage")
               
               -- 2. SCHRITT: WELT (Deine Reihenfolge!)
               -- Wir suchen nach Remotes, die 'World' im Namen haben
               for _, v in pairs(replicatedStorage:GetDescendants()) do
                   if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                       if v.Name:find("SelectWorld") or v.Name:find("SetWorld") then
                           if v:IsA("RemoteEvent") then v:FireServer(selectedWorld) 
                           else v:InvokeServer(selectedWorld) end
                           print("Signal gesendet an: " .. v.Name .. " mit Welt: " .. selectedWorld)
                       end
                   end
               end

               task.wait(0.5)

               -- 3. SCHRITT: KAPITEL
               for _, v in pairs(replicatedStorage:GetDescendants()) do
                   if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                       if v.Name:find("SelectChapter") or v.Name:find("SetChapter") then
                           if v:IsA("RemoteEvent") then v:FireServer(1) 
                           else v:InvokeServer(1) end
                           print("Signal gesendet an: " .. v.Name .. " mit Kapitel 1")
                       end
                   end
               end
               
               -- 4. ATTRIBUT-SYNC (Aus deinem Log)
               local screen = game.Players.LocalPlayer.PlayerGui:FindFirstChild("QueueScreen")
               if screen then screen:SetAttribute("Hidden", false) end

               Rayfield:Notify({Title = "Server-Sync", Content = "Remote-Signale für " .. selectedWorld .. " abgefeuert!"})
           end)

           if not success then warn("Remote-Fehler: " .. tostring(err)) end
       end,
    })
end
