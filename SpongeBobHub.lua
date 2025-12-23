local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Smart Bot", LoadingTitle = "Initialisiere..."})

-- [[ SERVICES & REMOTES ]] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local GoldRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RP.Gold
local PlaceTowerRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.TowerService.RF.PlaceTower
local UpgradeRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.UpgradeTower
local ReplicaCreate = ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaCreate

-- [[ GLOBALE VARIABLEN ]] --
local macroData = {}
local myTowers = {} -- Hier speichern wir die IDs unserer platzierten Türme
local isPlaying = false
local autoUpgradeActive = false
local nextStepIndex = 1

-- [[ REPLICA LISTENER: TOWER IDS ABGREIFEN ]] --
ReplicaCreate.OnClientEvent:Connect(function(replicaId, data)
    -- Wir suchen in den Daten nach dem Pfad, den du gefunden hast
    for _, info in pairs(data) do
        if info[1] == "Towers" then
            local towerData = info[3]
            -- Prüfen, ob der Turm uns gehört
            if towerData and towerData.Owner == LocalPlayer then
                local towerId = info[2].TowerId
                if towerId and not table.find(myTowers, towerId) then
                    table.insert(myTowers, towerId)
                    print("[BOT] Neuer Turm registriert: " .. towerId)
                end
            end
        end
    end
end)

-- [[ TABS ]] --
local MacroTab = Window:CreateTab("Macro & Upgrade", 4483362458)

MacroTab:CreateToggle({
    Name = "▶️ Makro abspielen",
    CurrentValue = false,
    Callback = function(Value)
        isPlaying = Value
        nextStepIndex = 1
        myTowers = {} -- Liste leeren für neue Runde
        autoUpgradeActive = false
    end,
})

MacroTab:CreateToggle({
    Name = "⬆️ Auto-Upgrade (nach Makro-Ende)",
    CurrentValue = false,
    Callback = function(Value)
        autoUpgradeActive = Value
    end,
})

-- [[ PLAYBACK & AUTO-UPGRADE LOGIK ]] --
GoldRemote.OnClientEvent:Connect(function()
    if not isPlaying then return end

    -- 1. SCHRITT: MAKRO ABARBEITEN (PLATZIEREN)
    if nextStepIndex <= #macroData then
        local step = macroData[nextStepIndex]
        task.spawn(function()
            local success = PlaceTowerRemote:InvokeServer(step.cframe, step.slot)
            if success then
                nextStepIndex = nextStepIndex + 1
            end
        end)
        
    -- 2. SCHRITT: AUTO-UPGRADE (WENN AKTIVIERT)
    elseif autoUpgradeActive and #myTowers > 0 then
        -- Wir gehen die Liste der gefundenen IDs durch
        task.spawn(function()
            for _, towerId in pairs(myTowers) do
                -- Wir versuchen das Upgrade für jeden Turm
                -- Der Server ignoriert es automatisch, wenn das Gold nicht reicht
                UpgradeRemote:InvokeServer(towerId)
            end
        end)
    end
end)

-- Hilfsfunktionen zum Laden (wie gehabt)
local function loadMacro(name)
    local path = "SBTD_" .. name .. ".json"
    if isfile(path) then
        local data = HttpService:JSONDecode(readfile(path))
        macroData = {}
        for _, step in pairs(data) do
            table.insert(macroData, {
                cframe = CFrame.new(unpack(step.pos)),
                slot = step.slot
            })
        end
        nextStepIndex = 1
    end
end
