if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 85896571713843 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
    RunService = game:GetService("RunService"),
}

local Remotes = {
    CollectPickup = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pickups"):WaitForChild("CollectPickup")
}

local State = {
    AutoBlowBubbles = false,
    AutoSellBubbles = false,
    AutoClaimBattlepass = false,
    AutoClaimPlayTime = false,
    AutoCollectPickups = false,
    SelectedSellPoint = "",
    SellInterval = 30,
    SelectedEgg = "",
    AutoHatch = false,
    HatchAmount = 1,
    AntiAfkKickEnabled = false,
}

local SellPoints = {
    ["Twilight Island"] = Services.Workspace.Worlds["The Overworld"].Islands.Twilight.Island.Sell,
    ["Robo Factory Island"] = Services.Workspace.Worlds["Minigame Paradise"].Islands["Robot Factory"].Island.Sell,
}

local script_version = "V0.01"
local LocalPlayer = Services.Players.LocalPlayer

local function teleportToSell()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return false 
    end
    
    local hrp = character.HumanoidRootPart
    local originalPosition = hrp.CFrame
    
    local sellPoint = SellPoints[State.SelectedSellPoint]
    if not sellPoint then
        warn("Invalid sell point selected!")
        return false
    end
    
    hrp.CFrame = sellPoint.Ring.CFrame * CFrame.new(0, 5, 0)
    task.wait(0.5)
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("RemoteEvent"):FireServer("SellBubble")

    hrp.CFrame = originalPosition
    
    return true
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "LixHub - Bubble Gum Simulator",
    Icon = 0,
    LoadingTitle = "Loading for Bubble Gum Simulator",
    LoadingSubtitle = script_version,
    ShowText = "LixHub",
    Theme = {
        TextColor = Color3.fromRGB(240, 240, 240),
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(34, 34, 34),
        Shadow = Color3.fromRGB(20, 20, 20),
        NotificationBackground = Color3.fromRGB(20, 20, 20),
        NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabStroke = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
        TabTextColor = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
        SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
        ElementStroke = Color3.fromRGB(50, 50, 50),
        SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
        SliderBackground = Color3.fromRGB(50, 138, 220),
        SliderProgress = Color3.fromRGB(50, 138, 220),
        SliderStroke = Color3.fromRGB(58, 163, 255),
        ToggleBackground = Color3.fromRGB(30, 30, 30),
        ToggleEnabled = Color3.fromRGB(0, 146, 214),
        ToggleDisabled = Color3.fromRGB(100, 100, 100),
        ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
        ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
        ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
        DropdownSelected = Color3.fromRGB(102, 102, 102),
        DropdownUnselected = Color3.fromRGB(30, 30, 30),
        InputBackground = Color3.fromRGB(30, 30, 30),
        InputStroke = Color3.fromRGB(65, 65, 65),
        PlaceholderColor = Color3.fromRGB(178, 178, 178)
    },
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LixHub",
        FileName = "Lixhub_BGSI"
    },
    Discord = {
        Enabled = false, 
        Invite = "cYKnXE2Nf8",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "LixHub - BGSI - Free",
        Subtitle = "LixHub - Key System",
        Note = "Free key",
        FileName = "LixHub_Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"0xLIXHUB"},
    }
})

local MainTab = Window:CreateTab("Main", "tv")
local HatchingTab = Window:CreateTab("Hatching", "egg")

Toggle = MainTab:CreateToggle({
    Name = "anti afk (no kick message)",
    CurrentValue = false,
    Flag = "AntiAfkKickToggle",
    TextScaled = false,
    Callback = function(Value)
        State.AntiAfkKickEnabled = Value
    end,
})

task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if State.AntiAfkKickEnabled then
            Services.VIRTUAL_USER:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            Services.VIRTUAL_USER:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end)

MainTab:CreateToggle({
    Name = "auto buble",
    CurrentValue = false,
    Flag = "AutoBlowBubbles",
    Callback = function(Value)
        State.AutoBlowBubbles = Value
    end,
})

MainTab:CreateToggle({
    Name = "auto sell",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        State.AutoSellBubbles = Value
    end,
})

MainTab:CreateDropdown({
    Name = "select sell",
    Options = {"Twilight Island", "Robo Factory Island"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "SelectSellPoint",
    Callback = function(Options)
        State.SelectedSellPoint = Options[1]
    end,
})

MainTab:CreateSlider({
    Name = "sell interval",
    Range = {5, 300},
    Increment = 5,
    Suffix = " Seconds",
    CurrentValue = 30,
    Flag = "SellInterval", 
    Callback = function(Value)
        State.SellInterval = Value
    end,
})

MainTab:CreateToggle({
    Name = "auto claim battlepass",
    CurrentValue = false,
    Flag = "AutoBattlepass",
    Callback = function(Value)
        State.AutoClaimBattlepass = Value
    end,
})

MainTab:CreateToggle({
    Name = "auto claim playtime gift",
    CurrentValue = false,
    Flag = "AutoClaimPlayTime",
    Callback = function(Value)
        State.AutoClaimPlayTime = Value
    end,
})

MainTab:CreateToggle({
    Name = "auto collect pickup",
    CurrentValue = false,
    Flag = "AutoCollectPickups",
    Callback = function(Value)
        State.AutoCollectPickups = Value
    end,
})

local function getEggList()
    local eggs = {}
    local eggsFolder = Services.ReplicatedStorage:FindFirstChild("Assets")
    
    if eggsFolder then
        eggsFolder = eggsFolder:FindFirstChild("Eggs")
        
        if eggsFolder then
            for _, egg in ipairs(eggsFolder:GetChildren()) do
                local eggName = egg.Name
                
                if not eggName:match("Golden") and 
                   not eggName:match("Rainbow") and 
                   not eggName:match("Shiny") and
                   not eggName:match("Exclusive") then
                    table.insert(eggs, eggName)
                end
            end
        end
    end
    
    table.sort(eggs)
    return eggs
end

local EggDropdown = HatchingTab:CreateDropdown({
    Name = "egg",
    Options = getEggList(),
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "SelectEgg",
    Callback = function(Options)
        State.SelectedEgg = Options[1]
    end,
})

HatchingTab:CreateToggle({
    Name = "auto otwieracz (in range of egg)",
    CurrentValue = false,
    Flag = "AutoHatch",
    Callback = function(Value)
        State.AutoHatch = Value
    end,
})

HatchingTab:CreateSlider({
    Name = "hatch amount",
    Range = {1, 20},
    Increment = 1,
    Suffix = " Eggs",
    CurrentValue = 1,
    Flag = "HatchAmount",
    Callback = function(Value)
        State.HatchAmount = Value
    end,
})

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoBlowBubbles then
            pcall(function()
                Services.ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent:FireServer("BlowBubble")
            end)
        end
    end
end)

task.spawn(function()
    local lastSellTime = 0
    while true do
        task.wait(1)
        
        if State.AutoSellBubbles then
            local currentTime = tick()
            
            if currentTime - lastSellTime >= State.SellInterval then
                pcall(function()
                    teleportToSell()
                end)
                lastSellTime = currentTime
            end
        end
    end
end)


task.spawn(function()
    while true do
        task.wait(5)
        if State.AutoClaimBattlepass then
            pcall(function()
                Services.ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent:FireServer("ClaimSeason")
            end)
        end
    end
end)


task.spawn(function()
    while true do
        task.wait(5)
        if State.AutoClaimPlayTime then
            pcall(function()
                Services.ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent:FireServer("ClaimAllPlaytime")
            end)
        end
    end
end)


task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoCollectPickups then
            pcall(function()
                local rendered = Services.Workspace:FindFirstChild("Rendered")
                if not rendered then return end
                
                local chunker = rendered:GetChildren()[15]
                if not chunker then return end
                
                local pickups = chunker:GetChildren()
                
                for _, pickup in ipairs(pickups) do
                    Remotes.CollectPickup:FireServer(pickup.Name)
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoHatch and State.SelectedEgg ~= "" then
            pcall(function()
                local args = {
                    "HatchEgg",
                    State.SelectedEgg,
                    State.HatchAmount
                }
                Services.ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent:FireServer(unpack(args))
            end)
        end
    end
end)
