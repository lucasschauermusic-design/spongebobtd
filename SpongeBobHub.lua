local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SpongeBob TD: Ultimate Bot", LoadingTitle = "Lade Macros..."})

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
local currentMacroName = ""
local savedMacros = {}

-- [[ HELFER: DATEI-SYSTEM ]] --

-- Scannt den Ordner nach SBTD_ Dateien
local function getSavedMacros()
    local files = listfiles("") -- Listet alle Dateien im Workspace
    local found = {}
    for _, file in pairs(files) do
        if file:sub(1, 5) == "SBTD_" and file:sub(-5) == ".json" then
            -- Entferne "SBTD_" am Anfang und ".json" am Ende für die Anzeige
            local name = file:sub(6, -6)
            table.insert(found, name)
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
    Rayfield:Notify({Title="Auto-Save", Content="Macro '" .. name .. "' gespeichert!"})
end

local function loadMacro(name)
    local path = "SBTD_" .. name .. ".json"
    if isfile(path) then
        local data = HttpService:JSONDecode(readfile(path))
        macroData = {}
        for _, step in pairs(data) do
            table.insert(macroData, {cframe = CFrame.new(unpack(step.pos)), slot = step.slot})
        end
        Rayfield:Notify({Title="Laden", Content=name .. " bereit (" .. #macroData .. " Units)"})
    end
end

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Main", 4483362458)
local MacroTab = Window:CreateTab("Macro", 4483362458)

-- [[ MACRO TAB ]] --

MacroTab:CreateSection("Neue Aufnahme")

MacroTab:CreateInput({
    Name = "Name für neues Macro",
    PlaceholderText = "z.B. Map1_Hard",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        currentMacroName = Text
    end,
})

local recordToggle = MacroTab:CreateToggle({
    Name = "🔴 Aufnahme (Speichert automatisch)",
    CurrentValue = false,
    Callback = function(Value)
        isRecording = Value
        if Value then
            macroData = {}
            Rayfield:Notify({Title="Aufnahme", Content="Platziere jetzt Einheiten..."})
        else
            if currentMacroName ~= "" then
                autoSave(currentMacroName)
                -- Liste nach dem Speichern aktualisieren
                -- (Hier müsste man das Dropdown-Objekt updaten)
            else
                Rayfield:Notify({Title="Fehler", Content="Kein Name angegeben!"})
            end
        end
    end,
})

MacroTab:CreateSection("Playback & Auswahl")

-- Initialer Scan der Dateien
savedMacros = getSavedMacros()

local macroDropdown = MacroTab:CreateDropdown({
    Name = "Gespeicherte Macros",
    Options = savedMacros,
    CurrentOption = "",
    Callback = function(Option)
        if Option ~= "" then
            loadMacro(Option)
        end
    end,
})

MacroTab:CreateButton({
    Name = "🔄 Liste aktualisieren",
    Callback = function()
        local newList = getSavedMacros()
        macroDropdown:Refresh(newList)
        Rayfield:Notify({Title="Refresh", Content="Dateien wurden neu gescannt."})
    end,
})

MacroTab:CreateToggle({
    Name = "▶️ Macro abspielen",
    CurrentValue = false,
    Callback = function(Value)
        isPlaying = Value
        nextStepIndex = 1
    end,
})

-- [[ LOGIK: HOOKS & GOLD-TRIGGER ]] --

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if isRecording and self == PlaceTowerRemote and method == "InvokeServer" then
        table.insert(macroData, {cframe = args[1], slot = args[2]})
    end
    return oldNamecall(self, ...)
end)

GoldRemote.OnClientEvent:Connect(function()
    if not isPlaying or #macroData == 0 or nextStepIndex > #macroData then return end
    
    local step = macroData[nextStepIndex]
    task.spawn(function()
        local success = PlaceTowerRemote:InvokeServer(step.cframe, step.slot)
        -- Da InvokeServer bei Knit oft den Status zurückgibt, 
        -- gehen wir nur zum nächsten Schritt, wenn der Server "Ja" sagt.
        if success then
            nextStepIndex = nextStepIndex + 1
        end
    end)
end)
