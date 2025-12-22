-- === EINSTELLUNGEN ===
local TARGET_MAP = "ConchStreet"
local DIFFICULTY = 1 -- 1 = Normal

-- === SERVICES ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- === HILFSFUNKTION: KNOPF KLICKEN ===
local function clickButton(textToFind)
    if not Player.PlayerGui then return false end

    for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            if gui.Visible then
                local found = false
                
                -- Text direkt im Button oder im Label prüfen
                if gui:IsA("TextButton") and string.find(string.upper(gui.Text), string.upper(textToFind)) then
                    found = true
                else
                    for _, child in pairs(gui:GetChildren()) do
                        if child:IsA("TextLabel") and string.find(string.upper(child.Text), string.upper(textToFind)) then
                            found = true
                            break
                        end
                    end
                end

                if found then
                    -- Position berechnen
                    local pos = gui.AbsolutePosition
                    local size = gui.AbsoluteSize
                    local centerX = pos.X + (size.X / 2)
                    local centerY = pos.Y + (size.Y / 2)

                    -- Echten Mausklick simulieren (wichtig für Roblox Erkennung)
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    return true
                end
            end
        end
    end
    return false
end

-- === SCHRITT 1: LOBBY ERSTELLEN (Remote) ===
print("--- [1] Starte Prozess wie im Video ---")

local args = { "Game", TARGET_MAP, DIFFICULTY, false }

-- Wir nutzen die RemoteFunction, um das Menü zu rufen (das spart das Laufen)
task.spawn(function()
    local knit = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"]
    knit.knit.Services.PlaceTeleportService.RF.Teleport:InvokeServer(unpack(args))
end)

-- === SCHRITT 2: AUTOMATIK (Loop) ===
-- Das Script wartet jetzt einfach, welche Knöpfe auftauchen und drückt sie

local readyDone = false
local startDone = false
local startTime = tick()

print("Warte auf Knöpfe...")

while tick() - startTime < 20 do -- Max 20 Sekunden versuchen
    task.wait(0.1) -- Sehr schnelle Reaktionszeit (wie im Video)

    -- A) "ICH BIN BEREIT!" suchen
    if not readyDone then
        if clickButton("ICH BIN BEREIT") then
            print("--> BEREIT gedrückt!")
            readyDone = true
            task.wait(0.5) -- Kurz warten bis Animation fertig
        end

    -- B) "STARTEN" suchen (Das ist der wichtigste Schritt)
    elseif not startDone then
        if clickButton("STARTEN") then
            print("--> STARTEN gedrückt! Teleport sollte kommen.")
            startDone = true
            -- Wir warten hier nicht, weil der Ladescreen sofort kommen sollte
        end
    
    -- C) SICHERUNG: Falls das blaue Fenster DOCH kommt (Notfall-Plan)
    -- Wenn im Video-Ablauf alles glatt geht, wird dieser Teil NIE ausgeführt.
    else
        if clickButton("Bestätigen") then
            print("--> (Notfall) Blaues Fenster bestätigt!")
            break
        end
    end
end

print("Script beendet. Viel Spaß im Dungeon!")
