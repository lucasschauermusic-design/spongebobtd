local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Ultimate Bot", LoadingTitle = "Systeme bereit..."})

-- [[ SERVICES & REMOTES ]] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GoldRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.GameService.RP.Gold
local PlaceTowerRemote = ReplicatedStorage.Packages._Index["acecateer_knit@1.7.1"].knit.Services.TowerService.RF.PlaceTower

-- [[ GLOBALE VARIABLEN ]] --
local macroData = {}
local isRecording = false
local isPlaying = false
local nextStepIndex = 1
local currentMacroName = "StandardMacro"

-- [[ HELFER: SPEICHER-LOGIK ]] --
local function autoSave(name)
    if #macroData == 0 then return end
    local path = "SBTD_" .. name .. ".json"
    local export = {}
    for _, step in pairs(macroData) do
        table.insert(export, {pos = {step.cframe:GetComponents()}, slot = step.slot})
    end
    writefile(path, HttpService:JSONEncode(export))
    Rayfield:Notify({Title="Auto-Save", Content="Macro '" .. name .. "' wurde gespeichert!"})
end

local function loadMacro(name)
    local path = "SBTD_" .. name .. ".json"
    if isfile(path) then
        local data = HttpService:JSONDecode(readfile(path))
        macroData = {}
        for _, step in pairs(data) do
            table.insert(macroData, {cframe = CFrame.new(unpack(step.pos)), slot = step.slot})
        end
        Rayfield:Notify({Title="Laden", Content=name .. " geladen (" .. #macroData .. " Units)"})
    else
        Rayfield:Notify({Title="Fehler", Content="Keine Datei für '" .. name .. "' gefunden."})
    end
end

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Main", 4483362458)
local GameTab = Window:CreateTab("Gameplay", 4483362458)
local MacroTab = Window:CreateTab("Macro", 4483362458)

-- [[ MACRO TAB: NEUE LOGIK ]] --
MacroTab:CreateSection("Konfiguration")

MacroTab:CreateInput({
    Name = "Macro Name",
    PlaceholderText = "z.B. ConchStreet_Hard",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        currentMacroName = Text
    end,
})

MacroTab:CreateSection("Steuerung")

MacroTab:CreateToggle({
    Name = "🔴 Aufnahme (Speichert automatisch beim Beenden)",
    CurrentValue = false,
    Callback = function(Value)
        isRecording = Value
        if Value then
            macroData = {}
            Rayfield:Notify({Title="Aufnahme", Content="Starte Aufnahme für: " .. currentMacroName})
        else
            -- AUTOMATISCHER SPEICHERVORGANG
            autoSave(currentMacroName)
        end
    end,
})

MacroTab:CreateButton({
    Name = "📂 Gespeichertes Macro laden",
    Callback = function()
        loadMacro(currentMacroName)
    end,
})

MacroTab:CreateToggle({
    Name = "▶️ Macro abspielen",
    CurrentValue = false,
    Callback = function(Value)
        isPlaying = Value
        nextStepIndex = 1
        if Value then
            Rayfield:Notify({Title="Playback", Content="Suche Gold-Signale..."})
        end
    end,
})

-- [[ LOGIK: HOOKS & GOLD-TRIGGER ]] --

-- Units beim Platzieren abgreifen
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if isRecording and self == PlaceTowerRemote and method == "InvokeServer" then
        table.insert(macroData, {cframe = args[1], slot = args[2]})
    end
    return oldNamecall(self, ...)
end)

-- Playback triggered durch Gold-Event
GoldRemote.OnClientEvent:Connect(function()
    if not isPlaying or #macroData == 0 or nextStepIndex > #macroData then return end
    
    local step = macroData[nextStepIndex]
    task.spawn(function()
        -- Wir versuchen die Unit zu setzen
        local success = PlaceTowerRemote:InvokeServer(step.cframe, step.slot)
        if success then
            nextStepIndex = nextStepIndex + 1
        end
    end)
end)
