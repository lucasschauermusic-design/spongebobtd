local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: God Mode Bot", LoadingTitle = "Systeme werden geladen..."})

-- [[ SERVICES & REMOTES ]] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remotes (Knit & Replica)
local GoldRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RP.Gold
local PlaceTowerRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.TowerService.RF.PlaceTower
local UpgradeRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.UpgradeTower
local SpeedRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.ChangeGameSpeed
local EndGameRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.EndGameVote
local StartRoundRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.VoteStartRound
local ReplicaCreate = ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaCreate
local signalEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")
local createEvent = ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaCreate")

-- [[ GLOBALE VARIABLEN ]] --
local macroData = {}
local myTowers = {} -- Speichert Tower-IDs für Auto-Upgrade
local isRecording = false
local isPlaying = false
local autoReplayEnabled = false
local autoStartWavesEnabled = false
local autoUpgradeActive = false
local nextStepIndex = 1
local currentMacroName = ""

-- [[ HELFER: DATEI-SYSTEM ]] --
local function getSavedMacros()
    local files = listfiles("")
    local found = {}
    for _, file in pairs(files) do
        if file:sub(1, 5) == "SBTD_" and file:sub(-5) == ".json" then
            table.insert(found, file:sub(6, -6))
        end
    end
    return found
end

local function autoSave(name)
    if #macroData == 0 or name == "" then return end
    local path = "SBTD_" .. name .. ".json"
    local export = {}
    for _, step in pairs(macroData) do
        table.insert(export, {pos = {step.cframe:GetComponents()}, slot = step.slot})
    end
    writefile(path, HttpService:JSONEncode(export))
    Rayfield:Notify({Title="Auto-Save", Content="Strategie '"..name.."' gespeichert!"})
end

local function loadMacro(name)
    local path = "SBTD_" .. name .. ".json"
    if isfile(path) then
        local data = HttpService:JSONDecode(readfile(path))
        macroData = {}
        for _, step in pairs(data) do
            table.insert(macroData, {cframe = CFrame.new(unpack(step.pos)), slot = step.slot})
        end
        nextStepIndex = 1
        Rayfield:Notify({Title="Laden", Content=name .. " bereit."})
    end
end

-- [[ TABS ERSTELLEN ]] --
local MainTab = Window:CreateTab("Lobby", 4483362458)
local GameTab = Window:CreateTab("Gameplay", 4483362458)
local MacroTab = Window:CreateTab("Macro", 4483362458)

-- [[ LOBBY TAB (AUTO-JOIN) ]] --
MainTab:CreateSection("Auto-Start Konfiguration")
local MapDrop = MainTab:CreateDropdown({Name = "Map", Options = {"ChumBucket", "ConchStreet", "JellyfishFields", "KampKoral", "KrustyKrab", "RockBottom", "SandysTreedome"}, CurrentOption = "ConchStreet", Callback = function() end})
local DiffDrop = MainTab:CreateDropdown({Name = "Schwierigkeit", Options = {"Normal", "Hard", "Nightmare", "DavyJones"}, CurrentOption = "Normal", Callback = function() end})

MainTab:CreateButton({
    Name = "🚀 START AUTO-JOIN",
    Callback = function()
        local rawMap = tostring(MapDrop.CurrentOption)
        local diffTable = {["Normal"] = 1, ["Hard"] = 2, ["Nightmare"] = 3, ["DavyJones"] = 4}
        local finalDiff = diffTable[DiffDrop.CurrentOption] or 1
        
        local connection
        connection = createEvent.OnClientEvent:Connect(function(lobbyID)
            if type(lobbyID) == "number" then
                connection:Disconnect()
                task.wait(2.0)
                signalEvent:FireServer(lobbyID, "ConfirmMap", {["Difficulty"] = finalDiff, ["Chapter"] = 1, ["Endless"] = false, ["World"] = rawMap})
                task.wait(1.5)
                signalEvent:FireServer(lobbyID, "StartGame")
            end
        end)
        
        local FT = nil
        for _, mod in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do if mod.Name == "FastTravelController" then FT = require(mod) break end end
        if FT then task.spawn(function() FT:_attemptTeleportToEmptyQueue() end) end
    end
})

-- [[ GAMEPLAY TAB ]] --
GameTab:CreateSection("Automatisierung")
GameTab:CreateToggle({Name = "Auto-Start Waves", CurrentValue = false, Callback = function(v) autoStartWavesEnabled = v end})
GameTab:CreateToggle({Name = "Auto-Replay (EndGame)", CurrentValue = false, Callback = function(v) autoReplayEnabled = v end})
GameTab:CreateToggle({Name = "Auto-Upgrade (nach Makro)", CurrentValue = false, Callback = function(v) autoUpgradeActive = v end})

GameTab:CreateSection("Speed")
GameTab:CreateDropdown({Name = "Set Speed", Options = {"X1", "X2", "X3", "X5", "X7"}, CurrentOption = "X1", Callback = function(o) pcall(function() SpeedRemote:InvokeServer(tonumber(o:sub(2))) end) end})

-- [[ MACRO TAB ]] --
MacroTab:CreateSection("Aufnahme")
MacroTab:CreateInput({Name = "Macro Name", PlaceholderText = "Name...", Callback = function(t) currentMacroName = t end})
MacroTab:CreateToggle({Name = "🔴 Aufnahme", CurrentValue = false, Callback = function(v) isRecording = v if not v then autoSave(currentMacroName) end end})

MacroTab:CreateSection("Playback")
local macroDropdown = MacroTab:CreateDropdown({Name = "Strategie wählen", Options = getSavedMacros(), CurrentOption = "", Callback = function(o) loadMacro(o) end})
MacroTab:CreateButton({Name = "🔄 Liste aktualisieren", Callback = function() macroDropdown:Refresh(getSavedMacros()) end})
MacroTab:CreateToggle({Name = "▶️ Macro abspielen", CurrentValue = false, Callback = function(v) isPlaying = v nextStepIndex = 1 myTowers = {} end})

-- [[ LOGIK-KERN ]] --

-- 1. TOWER-IDS TRACKEN (Deine Lösung via ReplicaCreate)
ReplicaCreate.OnClientEvent:Connect(function(id, data)
    for _, info in pairs(data) do
        if info[1] == "Towers" and info[3] and info[3].Owner == LocalPlayer then
            local tId = info[2].TowerId
            if tId and not table.find(myTowers, tId) then
                table.insert(myTowers, tId)
            end
        end
    end
end)

-- 2. AUTO-LOOPS (Replay & Waves)
task.spawn(function()
    while task.wait(1.5) do
        if autoReplayEnabled then pcall(function() EndGameRemote:InvokeServer("Replay") end) end
        if autoStartWavesEnabled then pcall(function() StartRoundRemote:InvokeServer() end) end
    end
end)

-- 3. RECORDER HOOK
local oldNc
oldNc = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if isRecording and self == PlaceTowerRemote and method == "InvokeServer" then
        table.insert(macroData, {cframe = args[1], slot = args[2]})
    end
    return oldNc(self, ...)
end)

-- 4. PLAYBACK & SMART UPGRADE (GOLD TRIGGER)
GoldRemote.OnClientEvent:Connect(function()
    if not isPlaying then return end

    -- Zuerst Makro-Platzierungen
    if nextStepIndex <= #macroData then
        local step = macroData[nextStepIndex]
        task.spawn(function()
            if PlaceTowerRemote:InvokeServer(step.cframe, step.slot) then
                nextStepIndex = nextStepIndex + 1
            end
        end)
    -- Dann Auto-Upgrade
    elseif autoUpgradeActive and #myTowers > 0 then
        task.spawn(function()
            for _, tId in pairs(myTowers) do
                UpgradeRemote:InvokeServer(tId)
            end
        end)
    end
end)

-- 5. RESET BEI NEUER RUNDE
createEvent.OnClientEvent:Connect(function(id) if type(id) == "number" then nextStepIndex = 1 myTowers = {} end end)
