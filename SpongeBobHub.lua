local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Spongebob Tower Defense",
    Folder = "SpongebobTD",
})

local MainTab = Window:Tab({
    Title = "Main",
})

local InfoSection = MainTab:Section({
    Title = "Script Information",
})

InfoSection:Section({
    Title = "Welcome to Spongebob Tower Defense Script",
    TextSize = 16,
    TextTransparency = 0.35,
})
