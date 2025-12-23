local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: God Mode", LoadingTitle = "Initialisiere Bot..."})

-- [[ SERVICES & REMOTES ]] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remotes
local GoldRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RP.Gold
local PlaceTowerRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.TowerService.RF.PlaceTower
local SpeedRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.ChangeGameSpeed
local EndGameRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.EndGameVote
local StartRoundRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RF.VoteStartRound

-- [[ GLOBALE VARIABLEN ]] --
local macroData = {}
local isRecording = false
local isPlaying = false
local autoReplayEnabled = false
local autoStartWavesEnabled = false
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
        nextStepIndex = 1 -- Reset für neues Spiel
        Rayfield:Notify({Title="Laden", Content=name .. " erfolgreich geladen."})
    end
end

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Main", 4483362458)
local GameTab = Window:CreateTab("Gameplay", 4483362458)
local MacroTab = Window:CreateTab("Macro", 4483362458)

-- [[ GAMEPLAY TAB ]] --
GameTab:CreateSection("Automatisierung")

GameTab:CreateToggle({
    Name = "Auto-Start Waves",
    CurrentValue = false,
    Callback = function(Value)
        autoStartWavesEnabled = Value
    end,
})

GameTab:CreateToggle({
    Name = "Auto-Replay (EndGame)",
    CurrentValue = false,
    Callback = function(Value)
        autoReplayEnabled = Value
    end,
})

GameTab:CreateSection("Geschwindigkeit")
GameTab:CreateDropdown({
    Name = "Set Speed",
    Options = {"X1", "X2", "X3", "X5", "X7"},
    CurrentOption = "X1",
    Callback = function(Option)
        local speedVal = tonumber(string.sub(Option, 2))
        pcall(function() SpeedRemote:InvokeServer(speedVal) end)
    end,
})

-- [[ MACRO TAB ]] --
MacroTab:CreateSection("Recorder")
MacroTab:CreateInput({
    Name = "Macro Name",
    PlaceholderText = "Name eingeben...",
    Callback = function(Text) currentMacroName = Text end,
})

MacroTab:CreateToggle({
    Name = "🔴 Aufnahme",
    CurrentValue = false,
    Callback = function(Value)
        isRecording = Value
        if not Value then autoSave(currentMacroName) end
    end,
})

MacroTab:CreateSection("Playback")
local macroDropdown = MacroTab:CreateDropdown({
    Name = "Gespeicherte Strategien",
    Options = getSavedMacros(),
    CurrentOption = "",
    Callback = function(Option) loadMacro(Option) end,
})

MacroTab:CreateButton({
    Name = "🔄 Liste aktualisieren",
    Callback = function() macroDropdown:Refresh(getSavedMacros()) end,
})

MacroTab:CreateToggle({
    Name = "▶️ Macro abspielen",
    CurrentValue = false,
    Callback = function(Value)
        isPlaying = Value
        nextStepIndex = 1
    end,
})

-- [[ HINTERGRUND LOGIK ]] --

-- 1. SCHLEIFE: Auto-Replay & Auto-Start-Waves
task.spawn(function()
    while task.wait(1.5) do
        -- Auto-Replay Check
        if autoReplayEnabled then
            pcall(function() EndGameRemote:InvokeServer("Replay") end)
        end
        
        -- Auto-Start-Waves Check
        if autoStartWavesEnabled then
            pcall(function() StartRoundRemote:InvokeServer() end)
        end
    end
end)

-- 2. MACRO AUFNAHME (HOOK)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if isRecording and self == PlaceTowerRemote and method == "InvokeServer" then
        table.insert(macroData, {cframe = args[1], slot = args[2]})
    end
    return oldNamecall(self, ...)
end)

-- 3. MACRO ABSPIELEN (GOLD TRIGGER)
GoldRemote.OnClientEvent:Connect(function()
    if not isPlaying or #macroData == 0 or nextStepIndex > #macroData then return end
    
    local step = macroData[nextStepIndex]
    task.spawn(function()
        local success = PlaceTowerRemote:InvokeServer(step.cframe, step.slot)
        if success then 
            nextStepIndex = nextStepIndex + 1 
        end
    end)
end)

-- 4. AUTO-RESET BEI NEUER RUNDE
-- Wir erkennen eine neue Runde daran, dass der Replicas-Ordner sich leert oder die Zeit zurücksetzt.
-- Hier nutzen wir einfach den Lobby-Teleport als Reset-Trigger.
createEvent.OnClientEvent:Connect(function(id)
    if type(id) == "number" then
        nextStepIndex = 1
        print("Neue Runde erkannt: Macro Index zurückgesetzt.")
    end
end)
