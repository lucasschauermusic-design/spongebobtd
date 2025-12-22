-- === EINSTELLUNGEN ===
local TARGET_MAP = "ConchStreet"
local DIFFICULTY = 1

-- === SERVICES ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- === HILFSFUNKTION: EINEN KNOPF KLICKEN ===
-- Diese Funktion sucht nach einem Text auf dem Bildschirm und klickt simulativ drauf
local function clickButtonByText(searchText)
    if not Player.PlayerGui then return false end

    -- Wir suchen durch ALLE GUI-Elemente
    for _, obj in pairs(Player.PlayerGui:GetDescendants()) do
        -- Wir prüfen, ob es ein Button ist (TextButton oder ImageButton)
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            if obj.Visible then -- Nur klicken, wenn auch sichtbar!
                
                -- Prüfen, ob der Text passt (entweder im Button selbst oder in einem Label darin)
                local found = false
                
                -- Fall A: Text steht direkt im Button
                if obj:IsA("TextButton") and string.find(string.upper(obj.Text), searchText) then
                    found = true
                else
                    -- Fall B: Text steht in einem TextLabel innerhalb des Buttons (häufig bei schönen UIs)
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("TextLabel") and string.find(string.upper(child.Text), searchText) then
                            found = true
                            break
                        end
                    end
                end

                if found then
                    print("--> Knopf '" .. searchText .. "' gefunden! Klicke...")
                    
                    -- Maus an die Position bewegen und klicken (VirtualInputManager)
                    -- Das ist sicherer als reines Script-Clicking
                    local pos = obj.AbsolutePosition
                    local size = obj.AbsoluteSize
                    local centerX = pos.X + (size.X / 2)
                    local centerY = pos.Y + (size.Y / 2)

                    -- Klick simulieren (Maus runter, kurz warten, Maus hoch)
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

-- === SCHRITT 1: MAP AUSWÄHLEN (REMOTE) ===
print("--- [1/3] Starte Lobby-Prozess für: " .. TARGET_MAP .. " ---")

local args = {
    "Game",
    TARGET_MAP,
    DIFFICULTY,
    false
}

local success, err = pcall(function()
    local knitPackages = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"]
    local teleportFunction = knitPackages.knit.Services.PlaceTeleportService.RF.Teleport
    teleportFunction:InvokeServer(unpack(args))
end)

if not success then
    warn("Fehler beim Starten der Lobby: " .. tostring(err))
    return -- Abbrechen
end

print("Lobby-Signal gesendet. Warte auf UI...")

-- === SCHRITT 2 & 3: AUTOMATISCHES KLICKEN (LOOP) ===
-- Wir starten eine Schleife, die auf die Fenster wartet

local readyClicked = false
local startClicked = false
local startTime = tick()

while true do
    task.wait(0.5) -- Kurze Pause, um CPU zu schonen
    
    -- Timeout nach 30 Sekunden (falls was schief geht)
    if tick() - startTime > 30 then
        warn("Timeout! Keine Knöpfe gefunden.")
        break
    end

    -- 1. Suche nach "ICH BIN BEREIT"
    if not readyClicked then
        if clickButtonByText("ICH BIN BEREIT") then
            readyClicked = true
            print("--- [2/3] Bereit bestätigt ---")
            task.wait(1) -- Kurz warten, bis das nächste Fenster kommt
        end
    
    -- 2. Suche nach "STARTEN" (erscheint erst nach "Bereit")
    elseif not startClicked then
        -- Suche explizit nach "STARTEN" (nicht verlassen)
        if clickButtonByText("STARTEN") then
            startClicked = true
            print("--- [3/3] START gedrückt! Teleport sollte gleich beginnen. ---")
            break -- Script fertig!
        end
    end
end
