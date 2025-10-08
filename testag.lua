--66
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.02"

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Guardians",
   Icon = 0,
   LoadingTitle = "Loading for Anime Guardians",
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
      FileName = "Lixhub_AG"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "LixHub - Anime Guardians - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
}

local stageRewards = require(Services.ReplicatedStorage.Module.StageRewards)
local LocalPlayer = Services.Players.LocalPlayer



local Config = {
   difficulties = {"Normal", "Nightmare"},
}

local Data = {
   availableStories = nil,
   storyData = nil,
}

local Config = {
    DISCORD_USER_ID = nil
}

local State = {
   AutoJoinStory = nil,
   StoryStageSelected = nil,
   StoryActSelected = nil,
   StoryDifficultySelected = nil,
   AutoJoinRaid = nil,
   RaidStageSelected = nil,
   RaidActSelected = nil,

   enableLimitFPS = false,
   SelectedFPS = 60,

   AntiAfkKickEnabled = false,

   deleteEntities = false,

   enableBlackScreen = false,

   AutoJoinGate = nil,

   enableAutoExecute = false,

   AutoJoinWorldlines = nil,
   AutoJoinWorldlinesSelected = nil,

   AutoJoinEvent = nil,
   AutoJoinEventSelected = nil,

   AutoJoinPortal = nil,
   AutoJoinPortalSelected = nil,

   AutoJoinChallenge = nil,

   AutoJoinTower = nil,
   AutoJoinTowerSelected = nil,

   AutoVoteRetry = false,
   AutoVoteNext = false,

   isGameRunning = false,

   SendStageCompletedWebhook = false,

   startingInventory = {},

   streamerModeEnabled = nil,

   enableLowPerformanceMode = nil,

   AutoPurchaseBlackMarket = nil,
   AutoPurchaseBlackMarketSelected = nil,

   AutoCollectChests = nil,

    gameStartRealTime = nil,
    gameEndRealTime = nil,
    actualClearTime = nil,
}

local PlaybackState = {
    loopCoroutine = nil,
    isRunning = false
}

local recordingHasStarted = false

local AutoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2
}

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

local trackedUnits = {} 

local macro = {}
local macroManager = {}
local currentMacroName = ""
local recordingHasStarted = false
local isAutoLoopEnabled = false
local gameHasEnded = false

local playbackUnitMapping = {} -- Maps placement order to actual unit name
local recordingSpawnIdToPlacement = {} -- Maps spawn ID to placement ID during recording
local recordingPlacementCounter = {} -- Counts placements per unit type
local placementExecutionLock = false -- Prevent race conditions

local gameInProgress = false
local macroHasPlayedThisGame = false

local gameStartTime = 0

local isRecording = false
local isPlaybacking = false
local isRecordingLoopRunning = false
local isPlayingLoopRunning = false
local playbackMode = "timing"
local currentWave = 0
local waveStartTime = 0
local currentPlacementOrder = 0
local detailedStatusLabel = nil

local ValidWebhook = nil

local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "tv")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

local MacroStatusLabel = MacroTab:CreateLabel("Macro Status: Ready")

CodeButton = LobbyTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        for _, stringValue in ipairs(Services.Players.LocalPlayer.Code:GetChildren()) do
	    if stringValue:IsA("Folder") and stringValue.Name ~= "Rewards" then
	            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Codes"):InvokeServer(stringValue.Name)
                Rayfield:Notify({Title = "Redeem All Codes",Content = "Redeeming: "..stringValue.Name,Duration = 0.5,Image = "Info",})
                task.wait(0.1)
            end
        end
    end,
})

local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Execute Script",
    CurrentValue = false,
    Flag = "enableAutoExecute",
    Info = "This auto executes and persists through teleports until you disable it or leave the game. ONLY USE 1 AUTOEXECUTE!",
    TextScaled = false,
    Callback = function(Value)
        State.enableAutoExecute = Value
        if State.enableAutoExecute then
            if queue_on_teleport then
                queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader"))()')
            else
                warn("queue_on_teleport not supported by this executor")
            end
        else
            if queue_on_teleport then
                queue_on_teleport("") -- Empty string clears queue in most executors
            end
        end
    end,
})

local Button = LobbyTab:CreateButton({
        Name = "Return to lobby",
        Callback = function()
            Services.TeleportService:Teleport(17282336195, Services.Players.LocalPlayer)
        end,
    })

local function getPlayerUnitsFolder()
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return nil
    end
    
    local playerUnitsFolder = unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)")
    if not playerUnitsFolder then
        warn("Player units folder not found!")
        return nil
    end
    
    return playerUnitsFolder
end

local function updateDetailedStatus(message)
    if detailedStatusLabel then
        detailedStatusLabel:Set("Macro Details: " .. message)
    end
    print("Macro Status: " .. message)
end

        local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
        })
    end

local function unitExistsInServer(unitName)
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        return false
    end
    
    return playerUnitsFolder:FindFirstChild(unitName) ~= nil
end

local function purchaseFromBlackMarket(unitName)
    local args = {
        1,
        unitName,
        "NightMarket"  -- or "BlackMarket" depending on your game
    }
    
    local success, result = pcall(function()
        return Services.ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("EventShop"):InvokeServer(unpack(args))
    end)
    
    if success then
        print("Successfully purchased:", unitName)
    else
        warn("Failed to purchase:", unitName, "Error:", result)
    end
end

local function checkBlackMarket()
    if not State.AutoPurchaseBlackMarket or not State.AutoPurchaseBlackMarketSelected or State.AutoPurchaseBlackMarketSelected == "" then
        return
    end
    if not workspace:FindFirstChild("RoomCreation") ~= nil then return end
    
    -- Wait for the black market to exist
    local blackMarket = LocalPlayer:FindFirstChild("BlackMarket")
    if not blackMarket then
        return
    end
    
    local market = blackMarket:FindFirstChild("Market")
    if not market then
        return
    end
    
    for _, child in pairs(market:GetChildren()) do
        if child:IsA("Folder") and child.Name == State.AutoPurchaseBlackMarketSelected then
            print("Found target unit in black market:", child.Name)
            purchaseFromBlackMarket(child.Name)
            break -- Exit after finding and purchasing
        end
    end
end

local function enableBlackScreen()
    local existingGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("BlackScreenGui")
    
    if State.enableBlackScreen then
        if existingGui then return end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BlackScreenGui"
        screenGui.Parent = Services.Players.LocalPlayer.PlayerGui
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = math.huge

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 36)
        frame.Position = UDim2.new(0, 0, 0, -36)
        frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        frame.ZIndex = 999999

        local toggleButtonFrame = Instance.new("Frame")
        toggleButtonFrame.Size = UDim2.new(0, 170,0, 44)
        toggleButtonFrame.Position = UDim2.new(0.5, -60, 1, -60)
        toggleButtonFrame.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
        toggleButtonFrame.BackgroundTransparency = 0.5
        toggleButtonFrame.Parent = screenGui
        toggleButtonFrame.ZIndex = 1000000

        local toggleButtonFrameUICorner =  Instance.new("UICorner")
        toggleButtonFrameUICorner.CornerRadius = UDim.new(1,0)
        toggleButtonFrameUICorner.Parent = toggleButtonFrame

        local toggleButtonFrameTitle = Instance.new("TextLabel")
        toggleButtonFrameTitle.ZIndex = math.huge
        toggleButtonFrameTitle.AnchorPoint = Vector2.new(0.5,0.5)
        toggleButtonFrameTitle.BackgroundTransparency = 1
        toggleButtonFrameTitle.Position = UDim2.new(0.5,0,0.5,0)
        toggleButtonFrameTitle.Size = UDim2.new(1,0,1,0)
        toggleButtonFrameTitle.Text = "Toggle Screen"
        toggleButtonFrameTitle.TextSize = 15
        toggleButtonFrameTitle.TextColor3 = Color3.fromRGB(255,255,255)
        toggleButtonFrameTitle.Parent = toggleButtonFrame

        local toggleButtonFrameTitleStroke = Instance.new("UIStroke")
        toggleButtonFrameTitleStroke.Parent = toggleButtonFrameTitle

        local toggleButtonFrameButton = Instance.new("TextButton")
        toggleButtonFrameButton.AnchorPoint = Vector2.new(0.5,0.5)
        toggleButtonFrameButton.BackgroundTransparency = 1
        toggleButtonFrameButton.Size = UDim2.new(1,0,1,0)
        toggleButtonFrameButton.Position = UDim2.new(0.5,0,0.5,0)
        toggleButtonFrameButton.Text = ""
        toggleButtonFrameButton.ZIndex = math.huge
        toggleButtonFrameButton.Parent = toggleButtonFrame

        toggleButtonFrameButton.MouseButton1Click:Connect(function()
            frame.Visible = not frame.Visible
        end)
    else
        if existingGui then
            existingGui:Destroy()
        end
    end
end

local function updateFPSLimit()
    if State.enableLimitFPS and State.SelectedFPS > 0 then
        setfpscap(State.SelectedFPS)
    else
        setfpscap(0) -- 0 = unlimited
    end
end

local function enableLowPerformanceMode()
    if State.enableLowPerformanceMode then
        Services.Lighting.Brightness = 1
        Services.Lighting.GlobalShadows = false
        Services.Lighting.Technology = Enum.Technology.Compatibility
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 0
        Services.Lighting.EnvironmentSpecularScale = 0

        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Transparency < 1 then
                    obj.Transparency = 1
                end
            end
        end
        
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then
                gui.Enabled = false
            end
        end
        
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or
            obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "ON",Setting = "Low Mode"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "OFF",Setting = "Visual Effects"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "OFF",Setting = "Damage Indicator"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "ON",Setting = "Hide Other's Units In Lobby"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "ON",Setting = "InvisibleEnemy"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "OFF",Setting = "Global Message"})
    else
        Services.Lighting.Brightness = 1.51
        Services.Lighting.GlobalShadows = true
        Services.Lighting.Technology = Enum.Technology.Future
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 1
        Services.Lighting.EnvironmentSpecularScale = 1

        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = true
            end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 0
            end
        end
        
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then
                gui.Enabled = true
            end
        end
        
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or
            obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = true
            end
        end
    end
end

    local Toggle = LobbyTab:CreateToggle({
    Name = "Snipe Unit From Black Market",
    CurrentValue = false,
    Flag = "AutoPurchaseBlackMarket",
    Callback = function(Value)
        State.AutoPurchaseBlackMarket = Value
    end,
    })

    local Input = LobbyTab:CreateInput({
    Name = "Input Unit Name (Black Market)",
    CurrentValue = "",
    PlaceholderText = "Input Unit Name...",
    RemoveTextAfterFocusLost = false,
    Flag = "BlackMarketInput",
    Callback = function(Text)
        local CleanedText = Text:gsub("^%s+", ""):gsub("%s+$", "")
        print(CleanedText)
        State.AutoPurchaseBlackMarketSelected = CleanedText
    end,
})

task.spawn(function()
    while true do
        if State.AutoPurchaseBlackMarket and State.AutoPurchaseBlackMarketSelected then
        checkBlackMarket()
        end
        task.wait(0.1)
    end
end)

    local JoinerSection = JoinerTab:CreateSection("📖 Story Joiner 📖")


    local AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoJoinStory",
    Callback = function(Value)
        State.AutoJoinStory = Value
    end,
    })

    local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryStageSelector",
    Callback = function(Option)
        State.StoryStageSelected = Option[1]
    end,
})

    local ChapterDropdown869 = JoinerTab:CreateDropdown({
    Name = "Select Story Act",
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6","Infinity"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryActSelector",
    Callback = function(Option)
    if Option[1] == "Infinity" then
        State.StoryActSelected = "Infinity"
    else
        local num = Option[1]:match("%d+")
        State.StoryActSelected = num
        end
    end,
})

    local ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Difficulty",
    Options = {"Normal","Nightmare"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector",
    Callback = function(Option)
        State.StoryDifficultySelected = Option[1]
    end,
    })

    local JoinerSection00 = JoinerTab:CreateSection("⚔️ Raid Joiner ⚔️")

    local AutoJoinRaidToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Raid",
    CurrentValue = false,
    Flag = "AutoJoinRaid",
    Callback = function(Value)
        State.AutoJoinRaid = Value
    end,
    })

    local StageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RaidStageSelector",
    Callback = function(Option)
        State.RaidStageSelected = Option[1]
    end,
})

    local JoinerSection00 = JoinerTab:CreateSection("🏆 Challenge Joiner 🏆")

    local AutoJoinChallengeToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Challenge",
    CurrentValue = false,
    Flag = "AutoJoinChallenge",
    Callback = function(Value)
        State.AutoJoinChallenge = Value
    end,
    })

    local JoinerSection00 = JoinerTab:CreateSection("🌀 Portal Joiner 🌀")

    local AutoJoinPortalToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Portal",
    CurrentValue = false,
    Flag = "AutoJoinPortal",
    Callback = function(Value)
        State.AutoJoinPortal = Value
    end,
    })

     local PortalStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Portal to join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinPortalSelector",
    Callback = function(Options)
        State.AutoJoinPortalSelected = Options[1]
    end,
})

    local JoinerSection00 = JoinerTab:CreateSection("👹 Event Joiner 👹")

    local AutoJoinEventToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Event",
    CurrentValue = false,
    Flag = "AutoJoinEvent",
    Callback = function(Value)
        State.AutoJoinEvent = Value
    end,
    })

     local EventStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Event to join",
    Options = {"Johny Joestar (JojoEvent)","Mushroom Rush (Mushroom)","Verdant Shroud (Mushroom2)","Frontline Command Post (Ragna)","Summer Beach (Summer)"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinEventSelector",
    Callback = function(Options)
        local extracted = string.match(Options[1], "%((.-)%)")
        State.AutoJoinEventSelected = extracted
    end,
})

    local JoinerSection00 = JoinerTab:CreateSection("🏆 Worldline Joiner 🏆")

    local AutoJoinWorldlineToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Worldlines",
    CurrentValue = false,
    Flag = "AutoJoinWorldlines",
    Callback = function(Value)
        State.AutoJoinWorldlines = Value
    end,
    })

     local WorldlineStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Worldline to join",
    Options = {"Double Dungeon (doubledungeon)","Double Dungeon 2 (doubledungeon2)","Lingxian Academy (lingxianacademy)","Lingxian Yard (lingxianyard)"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinWorldlinesSelector",
    Callback = function(Options)
        local extracted = string.match(Options[1], "%((.-)%)")
        State.AutoJoinWorldlinesSelected = extracted
    end,
})

    local JoinerSection00 = JoinerTab:CreateSection("🪜 Tower Joiner 🪜")

    local AutoJoinTowerToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Tower",
    CurrentValue = false,
    Flag = "AutoJoinTower",
    Callback = function(Value)
        State.AutoJoinTower = Value
    end,
    })

     local AutoJoinTowerStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Tower to join",
    Options = {"Cursed Place","The Lost Ancient World"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinTowerSelector",
    Callback = function(Options)
        State.AutoJoinTowerSelected = Options[1]
    end,
}) 

    local JoinerSection00 = JoinerTab:CreateSection("🚪 Gate Joiner 🚪")

    local AutoJoinGateToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Gate",
    CurrentValue = false,
    Flag = "AutoJoinGate",
    Callback = function(Value)
        State.AutoJoinGate = Value
    end,
    })

local function tryStartGame()
    if State.AutoStartGame then
        local mode = Services.Workspace.GameSettings.StagesChallenge.Mode.Value
        local gameStarted = Services.Workspace.GameSettings.GameStarted.Value
        local currentWave = Services.Workspace.GameSettings.Wave.Value
        
        -- Only try to start if game hasn't started, there's a mode, and we're on wave 1
        if (mode ~= nil and mode ~= "") and not gameStarted and currentWave == 0 then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Vote"):FireServer("Vote1")
            end)
        end
    end
end

local GameSection = GameTab:CreateSection("👥 Player 👥")

local Toggle = GameTab:CreateToggle({
    Name = "Black Screen",
    CurrentValue = false,
    Flag = "enableBlackScreen",
    Callback = function(Value)
        State.enableBlackScreen = Value
        enableBlackScreen()
    end,
})

    local Slider = GameTab:CreateSlider({
   Name = "Max Camera Zoom Distance",
   Range = {5, 100},
   Increment = 1,
   Suffix = "",
   CurrentValue = 35,
   Flag = "CameraZoomDistanceSelector",
   Callback = function(Value)
        Services.Players.LocalPlayer.CameraMaxZoomDistance = Value
   end,
})

    local Toggle = GameTab:CreateToggle({
    Name = "Anti AFK (No kick message)",
    CurrentValue = false,
    Flag = "AntiAfkKickToggle",
    Info = "Prevents roblox kick message.",
    TextScaled = false,
    Callback = function(Value)
        State.AntiAfkKickEnabled = Value
    end,
})

task.spawn(function()
    Services.Players.LocalPlayer.Idled:Connect(function()
        if State.AntiAfkKickEnabled then
            Services.VIRTUAL_USER:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            Services.VIRTUAL_USER:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end)

local Toggle = GameTab:CreateToggle({
    Name = "Streamer Mode (hide name/level/title)",
    CurrentValue = false,
    Flag = "StreamerMode",
    Callback = function(Value)
        State.streamerModeEnabled = Value
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Delete Enemies/Units",
    CurrentValue = false,
    Flag = "enableDeleteEnemies",
    Info = "Removes Unit/Enemy Models.",
    TextScaled = false,
    Callback = function(Value)
        State.deleteEntities = Value
        
        if Value then
            task.spawn(function()
                local agentFolder = workspace:FindFirstChild("Ground")
                if agentFolder then
                    local agentSubFolder = agentFolder:FindFirstChild("enemyClient")
                    if agentSubFolder then
                        -- Delete existing models first
                        for _, model in pairs(agentSubFolder:GetChildren()) do
                            if model and model.Parent then
                                model:Destroy()
                            end
                        end
                        
                        State.childAddedConnection = agentSubFolder.ChildAdded:Connect(function(child)
                            if State.deleteEntities and child then
                                child:Destroy()
                            end
                        end)
                    end
                end
            end)
        else
            if State.childAddedConnection then
                State.childAddedConnection:Disconnect()
                State.childAddedConnection = nil
            end
        end
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Low Performance Mode",
    CurrentValue = false,
    Flag = "LowPerformanceMode",
    Callback = function(Value)
        State.enableLowPerformanceMode = Value
        enableLowPerformanceMode()
    end,
})

if State.enableLowPerformanceMode then
    enableLowPerformanceMode()
end

 Toggle = GameTab:CreateToggle({
    Name = "Limit FPS",
    CurrentValue = false,
    Flag = "enableLimitFPS",
    Callback = function(Value)
        State.enableLimitFPS = Value
        updateFPSLimit()
    end,
})

 Slider = GameTab:CreateSlider({
   Name = "Limit FPS To",
   Range = {0, 240},
   Increment = 1,
   Suffix = " FPS",
   CurrentValue = 60,
   Flag = "FPSSelector",
   Callback = function(Value)
        State.SelectedFPS = Value
        updateFPSLimit()
   end,
})

local GameSection = GameTab:CreateSection("🎮 Game 🎮")

local Toggle = GameTab:CreateToggle({
    Name = "Auto Start Game",
    CurrentValue = false,
    Flag = "AutoStartGame",
    Callback = function(Value)
        State.AutoStartGame = Value
        if Value then
            tryStartGame()
        end
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Auto Vote Retry",
    CurrentValue = false,
    Flag = "AutoVoteRetry",
    Callback = function(Value)
        State.AutoVoteRetry = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Control"):FireServer("RetryVote")
        end
    end,
})

local Toggle2 = GameTab:CreateToggle({
    Name = "Auto Vote Next",
    CurrentValue = false,
    Flag = "AutoVoteNext", 
    Callback = function(Value)
        State.AutoVoteNext = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Control"):FireServer("Next Stage Vote")
        end
    end,
})

local Toggle2 = GameTab:CreateToggle({
    Name = "Auto Vote Lobby",
    CurrentValue = false,
    Flag = "AutoVoteLobby",
    Callback = function(Value)
        State.AutoVoteLobby = Value
    end,
})

--[[local function tryPickCard()
    -- Don't pick cards during retry
    if State.AutoPickCard and State.AutoPickCardSelected ~= nil and not isRetryInProgress then
        if Services.Workspace.GameSettings.GameStarted.Value == false then
            local mode = Services.Workspace.GameSettings.StagesChallenge.Mode.Value
            if mode == nil or mode == "" then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("StageChallenge"):FireServer(State.AutoPickCardSelected)
                end)
            end
        end
    end
end--]]

local Toggle = GameTab:CreateToggle({
    Name = "Auto Pick Card",
    CurrentValue = false,
    Flag = "AutoPickCard",
    Callback = function(Value)
        State.AutoPickCard = Value
       -- if Value then
         --   tryPickCard()
       -- end
    end,
})

local Dropdown = GameTab:CreateDropdown({
   Name = "Select Difficulty Card (Host Only)",
   Options = {"Normal","Fast Wave","Super Faster Wave"},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "AutoPickCardSelection",
   Callback = function(Option)
        State.AutoPickCardSelected = Option[1]
   end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Auto Collect Chests (Jojo Event)",
    CurrentValue = false,
    Flag = "AutoCollectChests",
    Callback = function(Value)
        State.AutoCollectChests = Value
    end,
})

local function isInLobby()
    return workspace:FindFirstChild("RoomCreation") ~= nil
end

local function collectChest(chest)
    if isInLobby() then return end
    if not State.AutoCollectChests then return end
    
    -- Get player's current character and root part
    local currentChar = Services.Players.LocalPlayer.Character
    if not currentChar then return end
    
    local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
    if not currentRoot then return end
    
    -- Find the ProximityPrompt in the chest
    local prompt = chest:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        -- Check if it's in a child of the chest
        for _, child in pairs(chest:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                prompt = child
                break
            end
        end
    end
    
    if not prompt then 
        print("No ProximityPrompt found in chest:", chest.Name)
        return 
    end
    
    -- Store original position
    local originalPosition = currentRoot.CFrame
    
    -- Teleport to chest
    currentRoot.CFrame = chest.CFrame + Vector3.new(0, 5, 0) -- Teleport slightly above chest
    
    -- Wait a brief moment for teleportation
    task.wait(0.1)
    
    -- Keep trying to collect until chest disappears or we timeout
    local maxAttempts = 20  -- Maximum number of attempts
    local attempts = 0
    local attemptDelay = 0.2  -- Delay between attempts
    
    print("Starting chest collection for:", chest.Name)
    
    while chest.Parent and attempts < maxAttempts do
        attempts = attempts + 1
        
        -- Try to fire the proximity prompt
        local success, err = pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.1)
            prompt:InputHoldEnd()
        end)
        
        if not success then
            -- If the prompt method fails, try the player-specific method
            pcall(function()
                prompt:InputHoldBegin(Services.Players.LocalPlayer)
                task.wait(0.1)
                prompt:InputHoldEnd(Services.Players.LocalPlayer)
            end)
        end
        
        print(string.format("Chest collection attempt %d/%d for %s", attempts, maxAttempts, chest.Name))
        
        -- Wait a moment to see if chest disappears
        task.wait(attemptDelay)
        
        -- Check if chest still exists
        if not chest.Parent then
            print("Chest successfully collected after", attempts, "attempts")
            break
        end
        
        -- If chest still exists after several attempts, try repositioning
        if attempts % 5 == 0 then
            -- Try a slightly different position
            local offset = Vector3.new(math.random(-2, 2), 5, math.random(-2, 2))
            currentRoot.CFrame = chest.CFrame + offset
            task.wait(0.1)
        end
    end
    
    if chest.Parent then
        print("Warning: Chest", chest.Name, "still exists after", attempts, "attempts")
    end
    
    -- Optional: Return to original position (comment out if you don't want this)
     currentRoot.CFrame = originalPosition
end

local function onChildAdded(child)
    if isInLobby() then return end
    if State.AutoCollectChests then
        -- Small delay to ensure chest is fully loaded
        task.wait(0.1)
        collectChest(child)
    end
end

local function collectExistingChests()
    if isInLobby() then return end
    local chestFolder = Services.Workspace:FindFirstChild("ChestSpawned")
    if not chestFolder then return end
    
    for _, chest in pairs(chestFolder:GetChildren()) do
        if State.AutoCollectChests then
            collectChest(chest)
            task.wait(0.1) -- Small delay between chests
        else
            break -- Stop if toggle was turned off
        end
    end
end

local function setupChestDetection()
    if isInLobby() then return end
    local chestFolder = Services.Workspace:FindFirstChild("ChestSpawned")
    
    if not chestFolder then
        -- Wait for ChestSpawned folder to exist using while loop
        task.spawn(function()
            while not Services.Workspace:FindFirstChild("ChestSpawned") do
                task.wait(0.1)
            end
            setupChestDetection()
        end)
        return
    end
    
    -- Connect to new chests being added
    chestFolder.ChildAdded:Connect(onChildAdded)
    
    -- Monitor toggle state and collect existing chests when enabled
    task.spawn(function()
        local lastToggleState = State.AutoCollectChests
        while true do
            task.wait(0.1)
            
            if State.AutoCollectChests and not lastToggleState then
                -- Toggle was just turned on, collect existing chests
                task.spawn(collectExistingChests)
            end
            
            lastToggleState = State.AutoCollectChests
        end
    end)
end

setupChestDetection()

    local function getCurrentWave()
        return Services.Workspace.GameSettings:FindFirstChild("Wave").Value or 0
    end

local function getUnitDisplayName(unit)
    if not unit then return nil end
    return unit:GetAttribute("original_name")
end

local function getUnitSpawnId(unit)
    if not unit then return nil end
    local spawnId = unit.Name:match("%s(%d+)$")
    return spawnId and tonumber(spawnId) or nil
end

local function takeUnitsSnapshot()
    local snapshot = {}
    local playerUnitsFolder = getPlayerUnitsFolder()
    
    if not playerUnitsFolder then 
        return snapshot 
    end
    
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        local displayName = getUnitDisplayName(unit)
        local spawnId = getUnitSpawnId(unit)
        
        if displayName and spawnId then
            table.insert(snapshot, {
                instance = unit,
                name = unit.Name,
                displayName = displayName,
                spawnId = spawnId,
                position = unit:FindFirstChild("HumanoidRootPart") and unit.HumanoidRootPart.Position or nil
            })
        end
    end
    
    return snapshot
end

local function findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
    local beforeSpawnIds = {}
    for _, unitData in pairs(beforeSnapshot) do
        beforeSpawnIds[unitData.spawnId] = true
    end
    
    for _, unitData in pairs(afterSnapshot) do
        if not beforeSpawnIds[unitData.spawnId] then
            return unitData.instance, unitData.displayName, unitData.spawnId
        end
    end
    
    return nil, nil, nil
end

local function getDisplayNameFromUnit(unitString)
    -- "Shigeru (Gachi Fighter) #1" -> "Shigeru (Gachi Fighter)"
    return unitString:match("^(.+)%s#%d+$") or unitString
end

local function getPlacementNumber(unitString)
    -- "Shigeru (Gachi Fighter) #1" -> 1
    return tonumber(unitString:match("#(%d+)$"))
end

local function getBaseUnitName(fullName)
    -- "Shigeru (Gachi Fighter) 1" -> "Shigeru (Gachi Fighter)"
    return fullName:match("^(.+)%s+%d+$") or fullName
end

local function findLatestSpawnedUnit(unitDisplayName, targetCFrame, strictTolerance)
    strictTolerance = strictTolerance or 8
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        warn("Player units folder not found")
        return nil
    end
    
    local baseUnitName = getBaseUnitName(unitDisplayName)
    print(string.format("🔍 Searching for: %s (base: %s)", unitDisplayName, baseUnitName))
    
    -- Build set of already tracked spawn IDs FOR THIS SPECIFIC UNIT TYPE
    local alreadyTrackedForThisUnit = {}
    for spawnId, placementId in pairs(recordingSpawnIdToPlacement) do
        -- Extract unit type from placement ID (e.g., "Judar (Era) #1" -> "Judar (Era)")
        local trackedUnitType = placementId:match("^(.+)%s#%d+$")
        if trackedUnitType == baseUnitName then
            alreadyTrackedForThisUnit[tonumber(spawnId)] = true
        end
    end
    
    print(string.format("Already tracked spawn IDs for %s: %d", baseUnitName, table.maxn(alreadyTrackedForThisUnit)))
    
    -- Collect untracked units of matching type
    local candidates = {}
    local scannedCount = 0
    local matchedTypeCount = 0
    
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        scannedCount = scannedCount + 1
        local unitBaseName = getBaseUnitName(unit.Name)
        
        -- Debug: Show what we're comparing
        if scannedCount <= 5 then
            print(string.format("Comparing: '%s' vs '%s'", unitBaseName, baseUnitName))
        end
        
        if unitBaseName == baseUnitName then
            matchedTypeCount = matchedTypeCount + 1
            local spawnId = getUnitSpawnId(unit)
            
            print(string.format("  → Matched type! Unit: %s, SpawnID: %s, Already tracked: %s", 
                unit.Name, tostring(spawnId), tostring(alreadyTrackedForThisUnit[spawnId] or false)))
            
            if spawnId and not alreadyTrackedForThisUnit[spawnId] then
                local originCFrame = unit:GetAttribute("origin")
                local hrp = originCFrame.Position
                if hrp then
                    local distance = (hrp - targetCFrame.Position).Magnitude
                    
                    print(string.format("  → Distance: %.2f studs (tolerance: %.2f)", distance, strictTolerance))
                    
                    if distance <= strictTolerance then
                        table.insert(candidates, {
                            unit = unit,
                            name = unit.Name,
                            distance = distance,
                            spawnId = spawnId,
                            position = hrp
                        })
                        print(string.format("  ✓ Added as candidate!"))
                    end
                end
            end
        end
    end
    
    print(string.format("Scan results: %d total units, %d matched type, %d candidates within range", 
        scannedCount, matchedTypeCount, #candidates))
    
    if #candidates == 0 then
        print("❌ No candidates found!")
        return nil
    end
    
    -- Sort by distance (closest first)
    table.sort(candidates, function(a, b) return a.distance < b.distance end)
    
    local best = candidates[1]
    print(string.format("✓ Found unit: %s at %.2f studs (ID: %d)", 
        best.name, best.distance, best.spawnId))
    
    return best.name
end

local function StreamerMode()
    local head = Services.Players.LocalPlayer.Character:WaitForChild("Head", 5)
    if not head then return end

    local billboard = head:WaitForChild("GUI"):WaitForChild("GUI"):WaitForChild("Frame")
    if not billboard then print("no billboard") return end

    local originalNumbers = Services.Players.LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("LevelFrame"):WaitForChild("Frame").texts
    if not originalNumbers then print("no originalnumbers") return end

    local streamerLabel = Services.Players.LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("LevelFrame"):WaitForChild("Frame"):FindFirstChild("Numbers_Streamer")
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "Numbers_Streamer"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = originalNumbers.Parent
    end

    if State.streamerModeEnabled then
        billboard:FindFirstChild("PlayerName").Text = "🔥 PROTECTED BY LIXHUB 🔥"
        billboard:FindFirstChild("Title").Text = "LIXHUB USER"

        originalNumbers.Visible = false
        streamerLabel.Visible = true
    else
        billboard:FindFirstChild("PlayerName").Text =  "Lv. " .. Services.Players.LocalPlayer:WaitForChild("Data").Levels.Value.." | "..tostring(Services.Players.LocalPlayer.Name)
        billboard:FindFirstChild("Title").Text = Services.Players.LocalPlayer:WaitForChild("Data").Title.Value

        originalNumbers.Visible = true
        streamerLabel.Visible = false
    end
end

local function clearSpawnIdMappings()
    playbackUnitMapping = {}
    trackedUnits = {}
    recordingPlacementCounter = {}
    placementExecutionLock = false
    print("✓ Cleared all tracking data")
end

local function startRecordingNow()
    if gameStartTime == 0 then
        gameStartTime = tick()
        print("Set game start time for recording:", gameStartTime)
    end
    
    recordingHasStarted = true
    clearSpawnIdMappings()
    table.clear(macro)
    trackedUnits = {}
    
    MacroStatusLabel:Set("Status: Recording active!")
    print("Recording started")
end

local function getMacroFilename(name)
        if type(name) == "table" then
            name = name[1] or ""
        end
        
        -- Ensure name is a string
        if type(name) ~= "string" or name == "" then
            warn("getMacroFilename: Invalid name provided:", name)
            return nil
        end
        
        return "LixHub/Macros/AG/" .. name .. ".json"
    end

local function saveMacroToFile(name)
    local data = macroManager[name]
    if not data then return end

    local json = Services.HttpService:JSONEncode(data)
    writefile(getMacroFilename(name), json)
end

local function setupGameTimeTracking()
    local waveNum = Services.Workspace.GameSettings.Wave
    
waveNum.Changed:Connect(function(newWave)
    if newWave >= 1 and not gameInProgress then
        gameInProgress = true
        gameStartTime = tick()
        
        -- Auto-start recording if enabled
        if isRecording and not recordingHasStarted then
            startRecordingNow()
        end
        
    elseif newWave == 0 and gameInProgress then
        gameInProgress = false
        
        -- Auto-stop recording
        if isRecording and recordingHasStarted then
            recordingHasStarted = false
            
            if currentMacroName and #macro > 0 then
                macroManager[currentMacroName] = macro
                saveMacroToFile(currentMacroName)
                Rayfield:Notify({
                    Title = "Recording Auto-Saved",
                    Content = string.format("%s (%d actions)", currentMacroName, #macro),
                    Duration = 3
                })
            end
        end
    end
end)
    
    -- Check current wave on startup
    if waveNum.Value >= 1 then
        gameInProgress = true
        gameStartTime = tick()
        print("Joined mid-game, tracking time from now")
    end
end

local function startGameTracking()
    if gameInProgress then return end
    
    gameInProgress = true
    macroHasPlayedThisGame = false
    gameStartTime = tick()
    gameHasEnded = false
    
    -- Auto-start recording if enabled
    if isRecording and not recordingHasStarted then
        recordingHasStarted = true
        clearSpawnIdMappings()
        table.clear(macro)
        MacroStatusLabel:Set("Status: Recording active!")
        notify("Recording Started", "Game started - recording active.")
        print("Recording auto-started with game")
    end
    
    State.startingInventory = snapshotInventory()
    
    print("Game tracking started - ready for macro playback/recording")
end

local function stopGameTracking()
    if not gameInProgress then return end
    
    print("Game ended - stopping tracking")
    
    -- Auto-stop recording if it was running
    if isRecording and recordingHasStarted then
        recordingHasStarted = false
        isRecording = false
        
        if RecordToggle then
            RecordToggle:Set(false)
        end
        
        Rayfield:Notify({
            Title = "Recording Stopped",
            Content = "Game ended, recording saved.",
            Duration = 3
        })
        
        if currentMacroName and #macro > 0 then
            macroManager[currentMacroName] = macro
            saveMacroToFile(currentMacroName)
            print(string.format("Auto-saved recording: %s with %d actions", currentMacroName, #macro))
        end
    end
    
    gameInProgress = false
    gameStartTime = 0
    macroHasPlayedThisGame = false
    
    print("Game tracking stopped")
end

local function getPlayerUnitsFolder()
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return nil
    end
    
    local playerUnitsFolder = unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)")
    if not playerUnitsFolder then
        warn("Player units folder not found!")
        return nil
    end
    
    return playerUnitsFolder
end

local function getUnitUUIDFromInventory(displayName)
    local unitsInventory = Services.Players.LocalPlayer:FindFirstChild("UnitsInventory")
    if not unitsInventory then return nil end
    
    for _, folder in pairs(unitsInventory:GetChildren()) do
        if folder:IsA("Folder") then
            local unitValue = folder:FindFirstChild("Unit")
            if unitValue and unitValue.Value == displayName then
                return folder.Name -- This is the UUID
            end
        end
    end
    return nil
end

local function getEquippedUnitUUID(displayName)
    local unitsInventory = Services.Players.LocalPlayer:FindFirstChild("UnitsInventory")
    if not unitsInventory then return nil end
    
    for _, folder in pairs(unitsInventory:GetChildren()) do
        if folder:IsA("Folder") then
            local unitValue = folder:FindFirstChild("Unit")
            local dataSetting = folder:FindFirstChild("data") and folder.data:FindFirstChild("setting")
            local equipValue = dataSetting and dataSetting:FindFirstChild("equip")
            
            if unitValue and unitValue.Value == displayName and 
               equipValue and equipValue.Value == "t" then
                return folder.Name -- UUID
            end
        end
    end
    return nil
end

local function countPlacedUnits()
    local count = 0
    local entities = Services.Workspace:FindFirstChild("Ground") and Services.Workspace.Ground:FindFirstChild("unitClient")
    
    if entities then
        for _, model in ipairs(entities:GetChildren()) do
            if model:IsA("Model") then
                    count = count + 1
            end
        end
    end
    
    return count
end

local function findUnitByPosition(unitDisplayName, targetPosition, tolerance)
    tolerance = tolerance or 5
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        warn("Player units folder not found")
        return nil
    end
    
    local baseUnitName = getBaseUnitName(unitDisplayName)
    print(string.format("🔍 Looking for %s near (%.1f, %.1f, %.1f)", 
        baseUnitName, targetPosition.X, targetPosition.Y, targetPosition.Z))
    
    local bestMatch = nil
    local bestDistance = math.huge
    
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        if unit.Name == "PLACEMENTFOLDER" then continue end

        local unitBaseName = getBaseUnitName(unit.Name)
        
        if unitBaseName == baseUnitName then
            -- Check if already tracked
            if trackedUnits[unit.Name] then
                continue -- Skip already tracked units
            end
            
            local originAttr = unit:GetAttribute("origin")
            if originAttr then
                local originPos = originAttr.Position
                local distance = (originPos - targetPosition).Magnitude
                
                print(string.format("  → Checking %s: distance = %.2f studs", unit.Name, distance))
                
                if distance <= tolerance and distance < bestDistance then
                    bestMatch = unit.Name
                    bestDistance = distance
                end
            end
        end
    end
    
    if bestMatch then
        print(string.format("✓ Found match: %s (%.2f studs away)", bestMatch, bestDistance))
    else
        print("❌ No matching unit found within tolerance")
    end
    
    return bestMatch
end

local function processPlacementAction(actionInfo)
    local args = actionInfo.args
    local unitDisplayName = args[1][1]
    local cframe = args[1][2]
    local rotation = args[1][3]
    
    print(string.format("📝 Recording placement: %s at position (%.1f, %.1f, %.1f)", 
        unitDisplayName, cframe.Position.X, cframe.Position.Y, cframe.Position.Z))
    
    -- Wait a bit for unit to spawn
    task.wait(0.5)
    
    -- Find the unit by position
    local actualUnitName = findUnitByPosition(unitDisplayName, cframe.Position, 5) -- 5 stud tolerance
    
    if not actualUnitName then
        warn("❌ RECORDING FAILED: Could not find unit at position:", unitDisplayName)
        return
    end
    
    -- Get placement cost
    local placementCost = nil
    local unitInServer = Services.Workspace.Ground.unitServer[tostring(Services.Players.LocalPlayer.Name).." (UNIT)"]:FindFirstChild(actualUnitName)
    if unitInServer then
        local sellingValue = unitInServer:FindFirstChild("Selling")
        if sellingValue and sellingValue:IsA("NumberValue") then
            placementCost = sellingValue.Value * 2
        end
    end
    
    -- Increment placement counter for this unit type
    recordingPlacementCounter[unitDisplayName] = (recordingPlacementCounter[unitDisplayName] or 0) + 1
    local placementNumber = recordingPlacementCounter[unitDisplayName]
    local placementId = string.format("%s #%d", unitDisplayName, placementNumber)
    
    -- Record to macro
    local gameRelativeTime = actionInfo.timestamp - gameStartTime
    
    local placementRecord = {
        Type = "spawn_unit",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime),
        Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z},
        Rotation = rotation,
        PlacementCost = placementCost
    }
    
    table.insert(macro, placementRecord)
    
    -- Map actual unit name to placement ID for upgrade/sell tracking
    trackedUnits[actualUnitName] = placementId
    
    print(string.format("✓ Recorded: %s → Server: %s (Cost: %d)", 
        placementId, actualUnitName, placementCost or 0))
end

local function executePlacementAction(action, actionIndex, totalActions)
    -- Prevent simultaneous placements
    while placementExecutionLock do
        task.wait(0.1)
    end
    placementExecutionLock = true
    
    print("=== EXECUTING PLACEMENT ===")
    print("Action Unit:", action.Unit)
    
    -- Extract placement order and display name
    local placementOrder = getPlacementNumber(action.Unit)
    local displayName = getDisplayNameFromUnit(action.Unit)
    
    if not placementOrder then
        warn("❌ Invalid placement order from:", action.Unit)
        placementExecutionLock = false
        return false
    end
    
    print("Placement Order:", placementOrder)
    print("Display Name:", displayName)
    
    -- Get UUID for equipped unit
    local uuid = getEquippedUnitUUID(displayName)
    
    if not uuid then
        warn("❌ Unit not equipped:", displayName)
        updateDetailedStatus(string.format("(%d/%d) ERROR: %s not equipped!", actionIndex, totalActions, displayName))
        placementExecutionLock = false
        return false
    end
    
    -- Reconstruct CFrame
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    
    local args = {
        {
            displayName,
            cframe,
            action.Rotation or 0
        },
        uuid
    }
    
    updateDetailedStatus(string.format("(%d/%d) Placing %s...", actionIndex, totalActions, action.Unit))
    
    -- Send placement request
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("spawnunit"):InvokeServer(unpack(args))
    end)
    
    if not success then 
        warn("❌ Failed to call spawnunit remote")
        placementExecutionLock = false
        return false 
    end
    
    -- Wait for unit to spawn and verify
    local placedUnitName = nil
    local maxWaitAttempts = 15
    
    for waitAttempt = 1, maxWaitAttempts do
        task.wait(0.5)
        
        placedUnitName = findLatestSpawnedUnit(displayName, cframe, 8)
        
        if placedUnitName then
            print(string.format("✅ Unit spawned after %.1fs", waitAttempt * 0.5))
            break
        end
        
        if waitAttempt < maxWaitAttempts then
            print(string.format("⏳ Waiting for spawn... (attempt %d/%d)", waitAttempt, maxWaitAttempts))
        end
    end
    
    if placedUnitName then
        -- ✅ CRITICAL FIX: Use full placement ID (e.g., "Ai #1") as key, not just the number
        playbackUnitMapping[action.Unit] = placedUnitName  -- Changed from [placementOrder]
        print(string.format("✓ MAPPED: %s → %s", action.Unit, placedUnitName))
        updateDetailedStatus(string.format("(%d/%d) Placed %s successfully", actionIndex, totalActions, action.Unit))
        placementExecutionLock = false
        return true
    end
    
    warn(string.format("❌ Failed to detect unit after %.1fs", maxWaitAttempts * 0.5))
    updateDetailedStatus(string.format("(%d/%d) FAILED to place %s", actionIndex, totalActions, action.Unit))
    placementExecutionLock = false
    return false
end

    local function getUnitUpgradeLevel(unit)
        --print(unit.Name)
        if Services.Workspace.Ground.unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)"):FindFirstChild(unit).Upgrade then
            return Services.Workspace.Ground.unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)"):FindFirstChild(unit).Upgrade.Value
        end
        return 0
    end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    
    if not checkcaller() then
        task.spawn(function()
            -- Detect spawnunit remote during recording
            if isRecording and method == "InvokeServer" and self.Name == "spawnunit" then
                local timestamp = tick()
                
                processPlacementAction({
                    args = args,
                    timestamp = timestamp
                })
            
            -- Keep sell detection
            elseif isRecording and method == "InvokeServer" and self.Name == "ManageUnits" and args[1] == "Selling" then
                local unitName = args[2]
                local timestamp = tick()
                
                local placementId = trackedUnits[unitName] -- Direct lookup
                
                if placementId then
                    local gameRelativeTime = timestamp - gameStartTime
                    
                    table.insert(macro, {
                        Type = "sell_unit_ingame",
                        Unit = placementId,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                    
                    print(string.format("Recorded sell: %s", placementId))
                    
                    -- Clean up tracking
                    trackedUnits[unitName] = nil
                end
            end
        end)
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    if not isRecording or not recordingHasStarted then return end

    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then return end

    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        if unit.Name == "PLACEMENTFOLDER" then continue end
        local unitName = unit.Name
        local currentLevel = getUnitUpgradeLevel(unitName)
        local placementId = trackedUnits[unitName] -- Direct lookup by unit name
        
        if placementId then
            -- Initialize tracking if new unit
            if not unit:GetAttribute("TrackedLevel") then
                unit:SetAttribute("TrackedLevel", currentLevel)
            end
            
            local lastLevel = unit:GetAttribute("TrackedLevel")
            
            -- Check for level increase
            if currentLevel > lastLevel then
                local levelIncrease = currentLevel - lastLevel
                local gameRelativeTime = tick() - gameStartTime
                
                local record = {
                    Type = "upgrade_unit_ingame",
                    Unit = placementId,
                    Time = string.format("%.2f", gameRelativeTime)
                }
                
                -- Only add Amount field if multi-upgrade
                if levelIncrease > 1 then
                    record.Amount = levelIncrease
                end
                
                table.insert(macro, record)
                
                print(string.format("Recorded upgrade: %s (L%d->L%d)",
                    placementId, lastLevel, currentLevel))
                
                -- Update tracked level
                unit:SetAttribute("TrackedLevel", currentLevel)
            end
        end
    end
end)

local function onWaveChanged()
    local newWave = getCurrentWave()
    if newWave ~= currentWave then
        currentWave = newWave
        waveStartTime = tick()
        print(string.format("Wave %d started", currentWave))
    end
end

local function getUnitMaxUpgradeLevel(unitName)
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        return nil
    end
    
    local unit = playerUnitsFolder:FindFirstChild(unitName)
    if not unit then
        return nil
    end
    
    local maxUpgradeValue = unit:FindFirstChild("MaxUpgrade")
    if maxUpgradeValue and maxUpgradeValue:IsA("NumberValue") then
        return maxUpgradeValue.Value
    end
    
    return nil
end

local function findUnitForPlayback(placementOrder, originalUnitName)
    -- First try exact mapping
    local mappedUnit = playbackUnitMapping[placementOrder]
    if mappedUnit and unitExistsInServer(mappedUnit) then
        return mappedUnit
    end
    
    -- If exact mapping failed, search by unit type and placement order
    local baseUnitName = originalUnitName:match("^(.-)%s*%d*$")
    local playerUnitsFolder = getPlayerUnitsFolder()
    
    if not playerUnitsFolder then
        return nil
    end
    
    -- Look for units of the same type
    local candidateUnits = {}
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        local unitBaseName = unit.Name:match("^(.-)%s*%d*$")
        if unitBaseName == baseUnitName then
            table.insert(candidateUnits, unit.Name)
        end
    end
    
    -- Sort by unit number (e.g., "Unit 1", "Unit 2", etc.)
    table.sort(candidateUnits, function(a, b)
        local numA = tonumber(a:match("%d+$")) or 0
        local numB = tonumber(b:match("%d+$")) or 0
        return numA < numB
    end)
    
    -- Return the unit corresponding to placement order (1st placed = index 1, etc.)
    if candidateUnits[placementOrder] then
        return candidateUnits[placementOrder]
    end
    
    -- Fallback: return first available unit of this type
    return candidateUnits[1]
end

local function getPlayerMoney()
    return tonumber(Services.Players.LocalPlayer.GameData.Yen.Value) or 0
end

local function getUnitUpgradeCost(unitName)
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return nil
    end
    
    local unit = unitServer[tostring(Services.Players.LocalPlayer).." (UNIT)"]:FindFirstChild(unitName)
    if not unit then
        warn("Unit not found in unitServer:", unitName)
        return nil
    end
    
    -- Look for PriceUpgrade in any child of the unit
    for _, child in pairs(unit:GetDescendants()) do
        if child.Name == "PriceUpgrade" and child:IsA("NumberValue") then
            return child.Value
        end
    end
    
    warn("PriceUpgrade not found for unit:", unitName)
    return nil
end

local function waitForSufficientMoneyForPlacement(unitName, placementCost, actionDescription)
    if not placementCost then
        warn("No placement cost provided for:", unitName)
        return true
    end
    
    local currentMoney = getPlayerMoney()
    
    if currentMoney >= placementCost then
        return true
    end
    
    MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - Place %s", 
        currentMoney, placementCost, unitName))
    
    print(string.format("Need %d more coins to place %s (Cost: %d)", 
        placementCost - currentMoney, unitName, placementCost))
    
    while getPlayerMoney() < placementCost and isPlaybacking do
        task.wait(0.5)
        local newMoney = getPlayerMoney()
        if newMoney ~= currentMoney then
            currentMoney = newMoney
            MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - Place %s", 
                currentMoney, placementCost, unitName))
        end
    end
    
    if not isPlaybacking then
        return false
    end
    
    print(string.format("Ready to place %s!", unitName))
    return true
end

local function waitForSufficientMoneyForUpgrades(unitName, upgradeAmount, actionDescription)
    upgradeAmount = upgradeAmount or 1
    
    local currentLevel = getUnitUpgradeLevel(unitName)
    local maxLevel = getUnitMaxUpgradeLevel(unitName)
    
    if not currentLevel or not maxLevel then
        warn("Could not get upgrade levels for:", unitName)
        return false
    end
    
    if currentLevel >= maxLevel then
        print(string.format("Unit %s already at max level (%d/%d)", unitName, currentLevel, maxLevel))
        return true
    end
    
    local totalCost = 0
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return false
    end
    
    local unit = unitServer[tostring(Services.Players.LocalPlayer).." (UNIT)"]:FindFirstChild(unitName)
    if not unit then
        warn("Unit not found:", unitName)
        return false
    end
    
    local priceUpgradeValue = nil
    for _, child in pairs(unit:GetDescendants()) do
        if child.Name == "PriceUpgrade" and child:IsA("NumberValue") then
            priceUpgradeValue = child
            break
        end
    end
    
    if not priceUpgradeValue then
        warn("PriceUpgrade not found for:", unitName)
        return false
    end
    
    for i = 1, upgradeAmount do
        if currentLevel + i > maxLevel then
            break
        end
        totalCost = totalCost + priceUpgradeValue.Value
    end
    
    print(string.format("Calculated upgrade cost for %s: %d (x%d upgrades from L%d)", 
        unitName, totalCost, upgradeAmount, currentLevel))
    
    local currentMoney = getPlayerMoney()
    
    if currentMoney >= totalCost then
        return true
    end
    
    MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
        currentMoney, totalCost, actionDescription))
    
    print(string.format("Need %d more coins for %s", totalCost - currentMoney, actionDescription))
    
    while getPlayerMoney() < totalCost and isPlaybacking do
        task.wait(0.5)
        local newMoney = getPlayerMoney()
        if newMoney ~= currentMoney then
            currentMoney = newMoney
            MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
                currentMoney, totalCost, actionDescription))
        end
    end
    
    if not isPlaybacking then
        return false
    end
    
    print(string.format("Ready to upgrade %s!", unitName))
    return true
end

local function executeUnitUpgrade(actionData)
    local unitPlacementId = actionData.Unit  -- e.g., "Ai #1", "Senko #2"
    local upgradeAmount = actionData.Amount or 1  -- Default to 1 if nil
    
    print(string.format("=== EXECUTING UPGRADE ==="))
    print(string.format("Target Unit: %s, Amount: %d", unitPlacementId or "nil", upgradeAmount))
    
    if not unitPlacementId then
        warn("❌ Invalid placement ID for upgrade")
        return false
    end
    
    -- Look up the actual unit name from playback mapping
    local currentUnitName = playbackUnitMapping[unitPlacementId]
    print(string.format("Mapped Unit: %s", currentUnitName or "nil"))
    
    if not currentUnitName then
        warn(string.format("❌ No mapping found for %s", unitPlacementId))
        print("Current mappings:")
        for k, v in pairs(playbackUnitMapping) do
            print(string.format("  %s → %s", k, v))
        end
        return false
    end
    
    -- Verify unit still exists
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        warn("❌ Player units folder not found")
        return false
    end
    
    local unitExists = playerUnitsFolder:FindFirstChild(currentUnitName)
    if not unitExists then
        warn(string.format("❌ Unit %s no longer exists", currentUnitName))
        return false
    end
    
    print(string.format("⬆️ Upgrading %s: %s (x%d levels)", unitPlacementId, currentUnitName, upgradeAmount))
    
    -- Check upgrade levels
    local currentUpgradeLevel = getUnitUpgradeLevel(currentUnitName)
    local maxUpgradeLevel = getUnitMaxUpgradeLevel(currentUnitName)
    
    if not currentUpgradeLevel or not maxUpgradeLevel then
        warn(string.format("❌ Could not determine upgrade levels for %s", currentUnitName))
        return false
    end
    
    if currentUpgradeLevel >= maxUpgradeLevel then
        print(string.format("ℹ️ Unit %s already at max (%d/%d)", currentUnitName, currentUpgradeLevel, maxUpgradeLevel))
        return true
    end
    
    -- Wait for money if needed
    if not waitForSufficientMoneyForUpgrades(currentUnitName, upgradeAmount, 
        string.format("upgrade %s x%d", currentUnitName, upgradeAmount)) then
        return false
    end

    local targetLevel = currentUpgradeLevel + upgradeAmount
    
    -- Perform upgrade
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits")
            :InvokeServer("Upgrade", currentUnitName, targetLevel)
    end)
    
    if success then
        task.wait(0.5)
        local newLevel = getUnitUpgradeLevel(currentUnitName)
        
        if newLevel and newLevel > currentUpgradeLevel then
            print(string.format("✓ Upgraded %s (%d→%d)", unitPlacementId, currentUpgradeLevel, newLevel))
            updateDetailedStatus(string.format("✓ Upgraded %s (%d→%d)", unitPlacementId, currentUpgradeLevel, newLevel))
            return true
        end
    else
        warn(string.format("❌ pcall failed: %s", tostring(err)))
    end
    
    warn(string.format("❌ Failed to upgrade %s", unitPlacementId))
    return false
end

local function executeUnitSell(actionData)
    local unitPlacementId = actionData.Unit  -- e.g., "Ai #1"
    
    print(string.format("=== EXECUTING SELL ==="))
    print(string.format("Target Unit: %s", unitPlacementId))
    
    if not unitPlacementId then
        warn("❌ Invalid placement ID for sell")
        return false
    end
    
    -- Look up the actual unit name from mapping
    local currentUnitName = playbackUnitMapping[unitPlacementId]  -- Changed lookup
    print(string.format("Mapped Unit: %s", currentUnitName or "nil"))
    
    if not currentUnitName then
        warn(string.format("❌ No mapping found for %s", unitPlacementId))
        return false
    end
    
    print(string.format("💰 Selling %s: %s", unitPlacementId, currentUnitName))
    
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits")
            :InvokeServer("Selling", currentUnitName)
    end)
    
    if success then
        task.wait(0.5)
        
        local playerUnitsFolder = getPlayerUnitsFolder()
        if playerUnitsFolder and not playerUnitsFolder:FindFirstChild(currentUnitName) then
            print(string.format("✓ Successfully sold %s", unitPlacementId))
            updateDetailedStatus(string.format("✓ Successfully sold %s", unitPlacementId))
            playbackUnitMapping[unitPlacementId] = nil  -- Remove from mapping
            return true
        end
    end
    
    warn(string.format("❌ Failed to sell %s", unitPlacementId))
    return false
end

local function executeUnitUlt(actionData)
    local targetOrder = actionData.targetPlacementOrder
    local unitType = actionData.unitType or getBaseUnitName(actionData.unitString or "")
    
    if not targetOrder or targetOrder == 0 then
        warn("Invalid target placement order for ult")
        return false
    end
    
    local currentUnitName = findUnitForPlayback(targetOrder, unitType)
    
    if not currentUnitName then
        warn(string.format("Could not find unit for placement #%d (type: %s)", targetOrder, unitType))
        return false
    end
    
    print(string.format("Using ult on placement #%d: %s", targetOrder, currentUnitName))
    
    -- Try to find the unit in unitClient for the ult
    local ground = Services.Workspace:FindFirstChild("Ground")
    if ground then
        local unitClient = ground:FindFirstChild("unitClient")
        if unitClient then
            for _, unit in pairs(unitClient:GetChildren()) do
                if unit:IsA("Model") and unit.Name:find(currentUnitName, 1, true) then
                    local success, err = pcall(function()
                        local args = {"SkillsButton", unit.Name}
                        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                            :WaitForChild("Events"):WaitForChild("Skills"):InvokeServer(unpack(args))
                    end)
                    
                    if success then
                        print(string.format("⚡ Successfully ulted placement #%d", targetOrder))
                        return true
                    end
                end
            end
        end
    end
    
    warn(string.format("Failed to ult placement #%d", targetOrder))
    return false
end

    detailedStatusLabel = MacroTab:CreateLabel("Macro Details: Ready")

    local Divider = MacroTab:CreateDivider()

local MacroDropdown = MacroTab:CreateDropdown({
        Name = "Select Macro",
        Options = {},
        CurrentOption = currentMacroName,
        MultipleOptions = false,
        Flag = "MacroDropdown",
        Callback = function(selected)
            local selectedName
            if type(selected) == "table" then
                selectedName = selected[1]
            else
                selectedName = selected
            end

            print("User selected macro:", selectedName)
            currentMacroName = selectedName
            if selectedName and macroManager[selectedName] then
                macro = macroManager[selectedName]
                print("Selected macro '" .. selectedName .. "' with " .. #macro .. " actions.")
            else
                print("Invalid selection or macro doesn't exist:", selectedName)
            end
        end,
    })

        local function ensureMacroFolders()
        if not isfolder("LixHub") then
            makefolder("LixHub")
        end
        if not isfolder("LixHub/Macros") then
            makefolder("LixHub/Macros")
        end
        if not isfolder("LixHub/Macros/AG") then
            makefolder("LixHub/Macros/AG")
        end
    end

local function refreshMacroDropdown()
        local options = {}

        for name in pairs(macroManager) do
            table.insert(options, name)
        end

        table.sort(options)

        if type(currentMacroName) == "table" then
            currentMacroName = currentMacroName[1] or ""
        end

        if not currentMacroName or currentMacroName == "" then
            currentMacroName = options[1]
        end

        if currentMacroName and macroManager[currentMacroName] then
            macro = macroManager[currentMacroName]
        end

        MacroDropdown:Refresh(options, currentMacroName)
        print("Refreshed dropdown with " .. #options .. " macros")
    end

local function exportMacroToClipboard(macroName, format)
    format = format or "json" -- default to json
    
    if not macroName or macroName == "" then
        Rayfield:Notify({
            Title = "Export Error",
            Content = "No macro selected for export.",
            Duration = 3
        })
        return false
    end
    
    local macroData = macroManager[macroName]
    if not macroData or #macroData == 0 then
        Rayfield:Notify({
            Title = "Export Error", 
            Content = "Macro '" .. macroName .. "' is empty or doesn't exist.",
            Duration = 3
        })
        return false
    end
    
    -- Create optimized export data
    local exportData = {
        version = script_version,
        actions = {}
    }
    
    -- Only include optional metadata if requested
    if format == "full" then
        exportData.macroName = macroName
        exportData.actionCount = #macroData
        exportData.exportTime = os.time()
    end
    
    -- Serialize the macro data with optimized structure
    for _, action in ipairs(macroData) do
        local serializedAction = {
            action = action.action,
            time = action.time,
            wave = action.wave
        }
        
        -- Add action-specific data
        if action.action == "PlaceUnit" then
            serializedAction.unitName = action.unitName
            serializedAction.cframe = serializeCFrame(action.cframe)
            serializedAction.rotation = action.rotation or 0
            serializedAction.unitId = action.unitId
            serializedAction.placementOrder = action.placementOrder
        elseif action.action == "UpgradeUnit" or action.action == "SellUnit" then
            serializedAction.targetPlacementOrder = action.targetPlacementOrder
        elseif action.action == "UltUnit" then
            serializedAction.targetPlacementOrder = action.targetPlacementOrder
            serializedAction.unitString = action.unitString
        end
        
        table.insert(exportData.actions, serializedAction)
    end
    
    local jsonData = Services.HttpService:JSONEncode(exportData)
    
    -- Format as .json file content
    local fileContent = jsonData
    local fileName = macroName .. ".json"
    
    -- Copy to clipboard
    local success, err = pcall(function()
        setclipboard(fileContent)
    end)
    
    if success then
        local sizeKB = math.floor(#fileContent / 1024 * 100) / 100
        Rayfield:Notify({
            Title = "Export Success",
            Content = string.format("Macro '%s' exported as JSON (%d actions, %.2f KB)", 
                macroName, #macroData, sizeKB),
            Duration = 4
        })
        print(string.format("Exported %s with %d actions (%.2f KB)", fileName, #macroData, sizeKB))
        return true
    else
        Rayfield:Notify({
            Title = "Export Error",
            Content = "Failed to copy to clipboard: " .. tostring(err),
            Duration = 4
        })
        return false
    end
end

local function importMacroFromURL(url, targetMacroName)
    if not url or url == "" then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "No URL provided for import.",
            Duration = 3
        })
        return false
    end
    
    if not targetMacroName or targetMacroName == "" then
        Rayfield:Notify({
            Title = "Import Error", 
            Content = "No target macro name specified.",
            Duration = 3
        })
        return false
    end
    
    -- Check if target macro already exists and has data
    if macroManager[targetMacroName] and #macroManager[targetMacroName] > 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Target macro '" .. targetMacroName .. "' already contains data. Use an empty macro.",
            Duration = 4
        })
        return false
    end
    
    Rayfield:Notify({
        Title = "Importing...",
        Content = "Downloading macro from URL...",
        Duration = 2
    })
    
    -- Try to fetch the URL content
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Failed to download from URL: " .. tostring(result),
            Duration = 4
        })
        return false
    end
    
    -- Try to parse the JSON
    local importData
    success, importData = pcall(function()
        return Services.HttpService:JSONDecode(result)
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Invalid JSON data in downloaded file.",
            Duration = 4
        })
        return false
    end
    
    -- Validate import data structure
    if not importData.actions or type(importData.actions) ~= "table" then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Invalid macro format - missing actions.",
            Duration = 4
        })
        return false
    end
    
    -- Process and normalize the macro data (handle both compact and full formats)
    local deserializedActions = {}
    for _, action in ipairs(importData.actions) do
        local newAction = table.clone(action)
        
        -- Deserialize CFrame if present
        if newAction.cframe then
            newAction.cframe = deserializeCFrame(newAction.cframe)
        end
        
        -- Normalize action data for internal use
        if newAction.action == "PlaceUnit" then
            -- For compact format, we need to populate expected fields
            newAction.actualUnitName = newAction.actualUnitName or (newAction.unitName .. " 1")
            newAction.timestamp = newAction.timestamp or os.time()
        elseif newAction.action == "UpgradeUnit" or newAction.action == "SellUnit" then
            -- Ensure we have the target placement order
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            -- For compatibility, set unitName (will be resolved during playback)
            newAction.unitName = newAction.unitName or "TBD"
            newAction.actualUnitName = newAction.actualUnitName or "TBD"
        elseif newAction.action == "UltUnit" then
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            newAction.targetUnitName = newAction.targetUnitName or "TBD"
        end
        
        table.insert(deserializedActions, newAction)
    end
    
    -- Import the macro
    macroManager[targetMacroName] = deserializedActions
    
    -- Save to file
    local success, err = pcall(function()
        ensureMacroFolders()
        saveMacroToFile(targetMacroName)
    end)
    
    if not success then
        warn("Failed to save imported macro to file:", err)
    end
    
    refreshMacroDropdown()
    
    Rayfield:Notify({
        Title = "Import Success",
        Content = "Imported '" .. (importData.macroName or "Unknown") .. "' to '" .. targetMacroName .. "' (" .. #deserializedActions .. " actions)",
        Duration = 4
    })
    
    return true
end

local function importMacroFromContent(jsonContent, targetMacroName)
    if not jsonContent or jsonContent:match("^%s*$") then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "No JSON content provided.",
            Duration = 3
        })
        return false
    end
    
    if not targetMacroName or targetMacroName == "" then
        Rayfield:Notify({
            Title = "Import Error", 
            Content = "No target macro name specified.",
            Duration = 3
        })
        return false
    end
    
    -- Check if target macro already exists and has data
    if macroManager[targetMacroName] and #macroManager[targetMacroName] > 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Target macro '" .. targetMacroName .. "' already contains data. Use an empty macro name.",
            Duration = 4
        })
        return false
    end
    
    -- Try to parse the JSON
    local importData
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(jsonContent)
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Invalid JSON format. Please check your pasted content.",
            Duration = 4
        })
        print("JSON Parse Error:", result)
        return false
    end
    
    importData = result
    
    -- Validate import data structure
    if not importData.actions or type(importData.actions) ~= "table" then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Invalid macro format - missing or invalid actions array.",
            Duration = 4
        })
        return false
    end
    
    if #importData.actions == 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Macro contains no actions.",
            Duration = 3
        })
        return false
    end
    
    -- Process and normalize the macro data
    local deserializedActions = {}
    local actionCount = 0
    
    for i, action in ipairs(importData.actions) do
        local newAction = table.clone(action)
        
        -- Validate required fields
        if not newAction.action or not newAction.time or not newAction.wave then
            warn(string.format("Action #%d missing required fields (action/time/wave)", i))
            continue
        end
        
        -- Deserialize CFrame if present
        if newAction.cframe then
            newAction.cframe = deserializeCFrame(newAction.cframe)
        end
        
        -- Normalize action data for internal use
        if newAction.action == "PlaceUnit" then
            if not newAction.unitName or not newAction.cframe then
                warn(string.format("PlaceUnit action #%d missing unitName or cframe", i))
                continue
            end
            newAction.actualUnitName = newAction.actualUnitName or (newAction.unitName .. " 1")
            newAction.timestamp = newAction.timestamp or os.time()
            newAction.rotation = newAction.rotation or 0
            
        elseif newAction.action == "UpgradeUnit" or newAction.action == "SellUnit" then
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            newAction.unitName = newAction.unitName or "TBD"
            newAction.actualUnitName = newAction.actualUnitName or "TBD"
            
        elseif newAction.action == "UltUnit" then
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            newAction.targetUnitName = newAction.targetUnitName or "TBD"
            
        else
            warn(string.format("Unknown action type '%s' in action #%d", newAction.action or "nil", i))
            continue
        end
        
        table.insert(deserializedActions, newAction)
        actionCount = actionCount + 1
    end
    
    if actionCount == 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "No valid actions found in the macro data.",
            Duration = 4
        })
        return false
    end
    
    -- Import the macro
    macroManager[targetMacroName] = deserializedActions
    
    -- Save to file
    local saveSuccess, saveErr = pcall(function()
        ensureMacroFolders()
        saveMacroToFile(targetMacroName)
    end)
    
    if not saveSuccess then
        warn("Failed to save imported macro to file:", saveErr)
    end
    
    refreshMacroDropdown()
    
    -- Calculate some stats
    local placeActions = 0
    local upgradeActions = 0
    local ultActions = 0
    local sellActions = 0
    
    for _, action in ipairs(deserializedActions) do
        if action.action == "PlaceUnit" then
            placeActions = placeActions + 1
        elseif action.action == "UpgradeUnit" then
            upgradeActions = upgradeActions + 1
        elseif action.action == "UltUnit" then
            ultActions = ultActions + 1
        elseif action.action == "SellUnit" then
            sellActions = sellActions + 1
        end
    end
    
    Rayfield:Notify({
        Title = "Import Success! 🎉",
        Content = string.format("Imported '%s' with %d actions:\n🏗️ %d Place | ⬆️ %d Upgrade | ⚡ %d Ult | 💰 %d Sell", 
            targetMacroName, actionCount, placeActions, upgradeActions, ultActions, sellActions),
        Duration = 5
    })
    
    print(string.format("✅ Successfully imported macro '%s' with %d actions", targetMacroName, actionCount))
    return true
end




local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not isfile(filePath) then return end

    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)
    
    -- No deserialization needed!
    macroManager[name] = data
    return data
end

    local function deleteMacroFile(name)
        if isfile(getMacroFilename(name)) then
            delfile(getMacroFilename(name))
        end
        macroManager[name] = nil
    end

    local function loadAllMacros()
        macroManager = {}
        for _, file in ipairs(listfiles("LixHub/Macros/AG/")) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                loadMacroFromFile(name)
            end
        end
    end

    local function waitForGameStart_Playback()
    local waveNum = Services.Workspace:WaitForChild("GameSettings"):WaitForChild("Wave")

    -- wait for game to end (if currently in one)
    while waveNum.Value > 0 do
        task.wait(1)
    end

    -- wait for next game to start
    while waveNum.Value < 1 do
        task.wait(1)
    end

    print("Playback started - wave " .. waveNum.Value)
end


local function waitForGameStart()
    local gameStarted = Services.Workspace.GameSettings.GameStarted.Value
    
    -- If game is currently running, wait for it to end first
    if gameStarted then
        MacroStatusLabel:Set("Status: Waiting for current game to end...")
        Rayfield:Notify({
            Title = "Waiting for Current Game",
            Content = "Waiting for current game to end...",
            Duration = 2,
            Image = 4483362458
        })
        
        -- Wait for current game to end
        repeat 
            task.wait(0.1) 
        until Services.Workspace.GameSettings.GameStarted.Value == false
        
        MacroStatusLabel:Set("Status: Game ended, waiting for next game...")
        Rayfield:Notify({
            Title = "Game Ended",
            Content = "Current game ended, waiting for next game...",
            Duration = 2,
            Image = 4483362458
        })
    else
        MacroStatusLabel:Set("Status: Waiting for next game to start...")
        Rayfield:Notify({
            Title = "Waiting for Game",
            Content = "Waiting for next game to start...",
            Duration = 2,
            Image = 4483362458
        })
    end

    -- Now wait for the next game to start
    repeat 
        task.wait(0.1) 
    until Services.Workspace.GameSettings.GameStarted.Value == true

    MacroStatusLabel:Set("Status: Game started! Initializing macro...")
    return Services.Workspace.GameSettings.GameStarted.Value
end

MacroInput = MacroTab:CreateInput({
        Name = "Create Macro",
        CurrentValue = "",
        PlaceholderText = "Enter macro name...",
        RemoveTextAfterFocusLost = true,
        Callback = function(text)
            local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            
            if cleanedName ~= "" then
                if macroManager[cleanedName] then
                    notify(nil,"Error: Macro '" .. cleanedName .. "' already exists.")
                    return
                end

                macroManager[cleanedName] = {}
                saveMacroToFile(cleanedName)
                refreshMacroDropdown()
                
                notify(nil,"Success: Created macro '" .. cleanedName .. "'.")
            elseif text ~= "" then
                notify(nil,"Error: Invalid macro name. Avoid special characters.")
            end
        end,
    })

    RefreshMacroListButton = MacroTab:CreateButton({
        Name = "Refresh Macro List",
        Callback = function()
            loadAllMacros()
            refreshMacroDropdown()
            notify(nil,"Success: Macro list refreshed.")
        end,
    })

    DeleteSelectedMacroButton = MacroTab:CreateButton({
        Name = "Delete Selected Macro",
        Callback = function()
            if not currentMacroName or currentMacroName == "" then
                notify(nil,"Error: No macro selected.")
                return
            end

            deleteMacroFile(currentMacroName)
            notify(nil,"Deleted: Deleted macro '" .. currentMacroName .. "'.")

            macroManager[currentMacroName] = nil
            macro = {}
            refreshMacroDropdown()
        end,
    })

    local function stopRecording()
        isRecording = false
        recordingHasStarted = false
        print(string.format("Stopped recording. Recorded %d actions", #macro))
        
        if currentMacroName and currentMacroName ~= "" then
            macroManager[currentMacroName] = macro
            saveMacroToFile(currentMacroName)
        end
        
        return macro
    end

local RecordToggle = MacroTab:CreateToggle({
    Name = "Record Macro",
    CurrentValue = false,
    Flag = "RecordMacro",
    Callback = function(Value)
        isRecording = Value

        if Value then
            -- Start recording immediately if in game, or when game starts
            if not isInLobby() and gameInProgress then
                recordingHasStarted = true
                isRecordingLoopRunning = true
                startRecordingNow() -- Your existing function
                MacroStatusLabel:Set("Status: Recording active!")
                notify("Recording Started", "Macro recording is now active.")
            else
                recordingHasStarted = false
                MacroStatusLabel:Set("Status: Recording enabled - will start when game begins")
                notify("Recording Ready", "Recording will start when you enter a game.")
            end
        elseif not Value then
            if isRecordingLoopRunning then
                notify("Recording Stopped", "Recording manually stopped.")
            end
            isRecordingLoopRunning = false
            stopRecording() -- Your existing function
            MacroStatusLabel:Set("Status: Recording stopped")
        end
    end
})

local function playMacroOnce()
    if not macro or #macro == 0 then
        print("No macro data to play")
        return false
    end
    
    MacroStatusLabel:Set("Status: Executing macro...")
    
    -- CRITICAL: Clear mappings at start
    clearSpawnIdMappings()
    
    local playbackStartTime = gameStartTime
    if playbackStartTime == 0 then
        playbackStartTime = tick()
        print("No game start time, using current time")
    end
    
    for actionIndex, action in ipairs(macro) do
        if not isPlaybacking or not gameInProgress then
            print("Playback stopped")
            return false
        end
        
        local actionTime = tonumber(action.Time) or 0
        local currentTime = tick() - playbackStartTime
        
        if currentTime < actionTime then
            local waitTime = actionTime - currentTime
            MacroStatusLabel:Set(string.format("Status: (%d/%d) Waiting %.1fs...", actionIndex, #macro, waitTime))
            
            local waitStart = tick()
            while (tick() - waitStart) < waitTime and isPlaybacking and gameInProgress do
                task.wait(0.1)
            end
        end
        
        if not isPlaybacking or not gameInProgress then break end
        
        if action.Type == "spawn_unit" then
            if action.PlacementCost then
                if not waitForSufficientMoneyForPlacement(action.Unit, action.PlacementCost, action.Unit) then
                    warn("Failed to get enough money for placement:", action.Unit)
                    return false
                end
            end
            
            MacroStatusLabel:Set(string.format("Status: (%d/%d) Placing %s", actionIndex, #macro, action.Unit))
            
            local success = executePlacementAction(action, actionIndex, #macro)
            
            if not success then
                print("Failed to place:", action.Unit)
            end
            
            task.wait(0.3)
            
        elseif action.Type == "upgrade_unit_ingame" then
            MacroStatusLabel:Set(string.format("Status: (%d/%d) Upgrading %s", actionIndex, #macro, action.Unit))
            
            local placementNum = getPlacementNumber(action.Unit)
            local unitType = getDisplayNameFromUnit(action.Unit)
            
            if placementNum and unitType then
                executeUnitUpgrade(action)
            else
                warn("Invalid upgrade action format:", action.Unit)
            end
            
        elseif action.Type == "sell_unit_ingame" then
            MacroStatusLabel:Set(string.format("Status: (%d/%d) Selling %s", actionIndex, #macro, action.Unit))
            
            local placementNum = getPlacementNumber(action.Unit)
            local unitType = getDisplayNameFromUnit(action.Unit)
            
            if placementNum and unitType then
                executeUnitSell(action)
            end
        end
        
        task.wait(0.1)
    end
    
    MacroStatusLabel:Set("Status: Macro completed")
    print("Macro playback finished")
    return true
end

local function autoPlaybackLoop()
    print("=== PLAYBACK LOOP STARTED ===")
    
    while isAutoLoopEnabled do
        MacroStatusLabel:Set("Status: Waiting for next game...")
        updateDetailedStatus("Waiting for next game...")
        
        waitForGameStart_Playback()
        
        if not isAutoLoopEnabled then 
            print("Playback disabled, stopping loop")
            break 
        end
        
        if not currentMacroName or currentMacroName == "" then
            MacroStatusLabel:Set("Status: Error - No macro selected!")
            updateDetailedStatus("Error - No macro selected!")
            notify(nil, "Playback Error: No macro selected for playback.")
            break
        end
        
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
            updateDetailedStatus("Error - Failed to load macro!")
            notify(nil, "Playback Error: Failed to load macro: " .. tostring(currentMacroName))
            break
        end
        
        macro = loadedMacro
        isPlaybacking = true
        macroHasPlayedThisGame = true
        
        MacroStatusLabel:Set("Status: Playing macro...")
        updateDetailedStatus("Loading macro: " .. currentMacroName)
        notify(nil, "Playback Started: " .. currentMacroName .. " (" .. #macro .. " actions)")
        
        local completed = playMacroOnce()
        
        isPlaybacking = false
        
        if completed then
            MacroStatusLabel:Set("Status: Macro completed - waiting for next game...")
            updateDetailedStatus("Macro completed - waiting for next game...")
            notify(nil, "Playback Complete: Waiting for next game to start...")
        else
            MacroStatusLabel:Set("Status: Macro interrupted - waiting for next game...")
            updateDetailedStatus("Macro interrupted - waiting for next game...")
            notify(nil, "Playback Interrupted: Game ended, waiting for next game...")
        end
        
        task.wait(1)
    end
    
    MacroStatusLabel:Set("Status: Playback stopped")
    updateDetailedStatus("Playback stopped")
    isPlaybacking = false
    print("=== PLAYBACK LOOP ENDED ===")
end

local function restartPlaybackLoop()
    if not isAutoLoopEnabled then return end
    
    print("=== RESTARTING PLAYBACK LOOP ===")
    
    -- Stop existing loop
    PlaybackState.isRunning = false
    if PlaybackState.loopCoroutine then
        task.cancel(PlaybackState.loopCoroutine)
        PlaybackState.loopCoroutine = nil
    end
    
    -- Reset ALL game state variables
    gameInProgress = false
    macroHasPlayedThisGame = false
    gameStartTime = 0
    isPlaybacking = false  -- Add this reset
    
    -- Wait for things to stabilize
    task.wait(1)
    
    -- Verify we still want to play and have a valid macro
    if not isAutoLoopEnabled then 
        print("Playback disabled during restart, aborting")
        return 
    end
    
    if not currentMacroName or currentMacroName == "" then
        print("No macro selected during restart, aborting")
        return
    end
    
    if not macro or #macro == 0 then
        print("No macro data during restart, attempting to reload")
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if loadedMacro then
            macro = loadedMacro
            print("Successfully reloaded macro:", currentMacroName)
        else
            print("Failed to reload macro, aborting restart")
            return
        end
    end
    
    -- Start new loop
    print("Starting fresh playback loop with", #macro, "actions")
    PlaybackState.loopCoroutine = task.spawn(autoPlaybackLoop)
end

local PlayToggle = MacroTab:CreateToggle({
    Name = "Playback Macro",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isAutoLoopEnabled = Value
        isPlaybacking = Value
        
        if Value then
            if not currentMacroName or currentMacroName == "" then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "No macro selected",
                    Duration = 3
                })
                --isAutoLoopEnabled = false
                --isPlaybacking = false
                --PlayToggle:Set(false)
                return
            end
            
            local loadedMacro = loadMacroFromFile(currentMacroName)
            if loadedMacro then
                macro = loadedMacro
                MacroStatusLabel:Set("Status: Playback enabled - waiting for game")
                notify("Playback Enabled", "Macro will play once per game.")
                
                -- Start the loop (like Crusaders)
                task.spawn(autoPlaybackLoop)
                
                print("Started playback:", currentMacroName, "with", #macro, "actions")
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to load macro",
                    Duration = 3
                })
                isAutoLoopEnabled = false
                isPlaybacking = false
                PlayToggle:Set(false)
            end
        else
            MacroStatusLabel:Set("Status: Playback disabled")
            isPlaybacking = false
            notify("Playback Disabled", "Macro playback stopped.")
        end
    end
})

local ImportInput = MacroTab:CreateInput({
    Name = "Import Macro (URL or JSON)",
    CurrentValue = "",
    PlaceholderText = "Paste URL or JSON content here...",
    RemoveTextAfterFocusLost = true,
    --Flag = "ImportInput",
    Callback = function(text)
        if not text or text:match("^%s*$") then
            return
        end
        
        local macroName = nil
        
        -- Detect if it's a URL or JSON content
        if text:match("^https?://") then
            -- Extract filename from URL for macro name (handle query parameters)
            local fileName = text:match("/([^/?]+)%.json") or text:match("/([^/?]+)$")
            print("DEBUG: URL detected:", text)
            print("DEBUG: Extracted fileName:", fileName)
            if fileName then
                macroName = fileName:gsub("%.json.*$", "") -- Remove .json and anything after it
            else
                macroName = "ImportedMacro_" .. os.time()
            end
            print("DEBUG: Final macroName from URL:", macroName)
        else
            -- For JSON content, try to extract macro name from content or use default
            local jsonData = nil
            pcall(function()
                jsonData = Services.HttpService:JSONDecode(text)
            end)
            
            print("DEBUG: JSON content detected, length:", #text)
            print("DEBUG: JSON macroName field:", jsonData and jsonData.macroName)
            -- Try to get name from JSON data, otherwise use default
            macroName = (jsonData and jsonData.macroName) or ("ImportedMacro_" .. os.time())
            print("DEBUG: Final macroName from JSON:", macroName)
        end
        
        -- Clean macro name (remove invalid characters)
        local originalName = macroName
        macroName = macroName:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        print("DEBUG: Cleaned macroName:", originalName, "->", macroName)
        
        -- Ensure name isn't empty
        if macroName == "" then
            macroName = "ImportedMacro_" .. os.time()
            print("DEBUG: Empty name fallback:", macroName)
        end
        
        -- Check if macro already exists
        if macroManager[macroName] then
            Rayfield:Notify({
                Title = "Import Cancelled",
                Content = "'" .. macroName .. "' already exists.",
                Duration = 3
            })
            return
        end
        
        -- Import the macro with the exact filename
        if text:match("^https?://") then
            importMacroFromURL(text, macroName)
        else
            importMacroFromContent(text, macroName)
        end
    end,
})

local ExportButton = MacroTab:CreateButton({
    Name = "Copy Macro JSON",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Export Error",
                Content = "No macro selected for export.",
                Duration = 3
            })
            return
        end
        exportMacroToClipboard(currentMacroName, "compact")
    end,
})

local SendWebhookButton = MacroTab:CreateButton({
    Name = "Send Macro via Webhook",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "No macro selected.",
                Duration = 3
            })
            return
        end
        
        if not ValidWebhook then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "No webhook URL configured.",
                Duration = 3
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "Selected macro is empty.",
                Duration = 3
            })
            return
        end
        
        -- Create export data
        local exportData = {
            version = script_version,
            actions = {}
        }
        
        for _, action in ipairs(macroData) do
            local serializedAction = {
                action = action.action,
                time = action.time,
                wave = action.wave
            }
            
            if action.action == "PlaceUnit" then
                serializedAction.unitName = action.unitName
                serializedAction.cframe = serializeCFrame(action.cframe)
                serializedAction.rotation = action.rotation or 0
                serializedAction.unitId = action.unitId
                serializedAction.placementOrder = action.placementOrder
            elseif action.action == "UpgradeUnit" or action.action == "SellUnit" then
                serializedAction.targetPlacementOrder = action.targetPlacementOrder
            elseif action.action == "UltUnit" then
                serializedAction.targetPlacementOrder = action.targetPlacementOrder
                serializedAction.unitString = action.unitString
            end
            
            table.insert(exportData.actions, serializedAction)
        end
        
        local jsonData = Services.HttpService:JSONEncode(exportData)
        local fileName = currentMacroName .. ".json"
        
        -- Create multipart form data for file upload
        local boundary = "----WebKitFormBoundary" .. tostring(tick())
        local body = ""
        
        -- Add payload_json field
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. Services.HttpService:JSONEncode({
            username = "LixHub Macro Share",
            content = "**Macro shared:** `" .. fileName .. "`\n📁 **Actions:** " .. tostring(#exportData.actions)}) .. "\r\n"
        
        -- Add file field
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. fileName .. "\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. jsonData .. "\r\n"
        
        -- End boundary
        body = body .. "--" .. boundary .. "--\r\n"
        
        -- Try multiple request functions
        local requestFunc = (syn and syn.request) or 
                           (http and http.request) or 
                           (http_request) or 
                           request
        
        if not requestFunc then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "No HTTP request function available.",
                Duration = 3
            })
            return
        end
        
        local success, result = pcall(function()
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = { 
                    ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
                    ["User-Agent"] = "LixHub-Webhook/1.0"
                },
                Body = body
            })
        end)
        
        if success and result then
            -- Check if the HTTP request was actually successful
            if result.Success and result.StatusCode and result.StatusCode >= 200 and result.StatusCode < 300 then
                Rayfield:Notify({
                    Title = "Webhook Success", 
                    Content = "Macro file sent to Discord successfully.",
                    Duration = 3
                })
            else
                -- Log the actual error for debugging
                local errorMsg = "HTTP Error"
                if result.StatusCode then
                    errorMsg = errorMsg .. " " .. tostring(result.StatusCode)
                end
                if result.Body then
                    errorMsg = errorMsg .. ": " .. tostring(result.Body)
                end
                
                Rayfield:Notify({
                    Title = "Webhook Error",
                    Content = errorMsg,
                    Duration = 5
                })
                
                -- Debug print (remove in production)
                print("Webhook Debug Info:")
                print("Success:", result.Success)
                print("StatusCode:", result.StatusCode) 
                print("Body:", result.Body)
            end
        else
            local errorMsg = "Failed to send request"
            if result then
                errorMsg = errorMsg .. ": " .. tostring(result)
            end
            
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = errorMsg,
                Duration = 3
            })
            
            -- Debug print (remove in production)
            print("Request failed:", result)
        end
    end,
})

local CheckUnitsButton = MacroTab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "No macro selected.",
                Duration = 3
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Error",
                Content = "Selected macro is empty.",
                Duration = 3
            })
            return
        end
        
        -- Extract unique units from macro
        local units = {}
        local unitCounts = {}
        
        for _, action in ipairs(macroData) do
            if action.action == "PlaceUnit" then
                local unitName = action.unitName
                if not units[unitName] then
                    units[unitName] = true
                    unitCounts[unitName] = 0
                end
                unitCounts[unitName] = unitCounts[unitName] + 1
            end
        end
        
        -- Create display text
        local unitList = {}
        for unitName, count in pairs(unitCounts) do
            table.insert(unitList, unitName .. " (Placed x" .. count .. " times)")
        end
        
        if #unitList > 0 then
            table.sort(unitList)
            local displayText = table.concat(unitList, "\n")
            
            Rayfield:Notify({
                Title = "Macro Units (" .. #unitList .. " types)",
                Content = displayText,
                Duration = 8
            })
        else
            Rayfield:Notify({
                Title = "No Units Found",
                Content = "This macro contains no unit placements.",
                Duration = 3
            })
        end
    end,
})

Input = WebhookTab:CreateInput({
    Name = "Input Webhook",
    CurrentValue = "",
    PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInput",
    Callback = function(Text)
        local trimmed = Text:match("^%s*(.-)%s*$")

        if trimmed == "" then
            ValidWebhook = nil
            return
        end

        local valid = trimmed:match("^https://")

        if valid then
            ValidWebhook = trimmed
        else
            ValidWebhook = nil
        end
    end,
})

 Input = WebhookTab:CreateInput({
    Name = "Input Discord ID (mention rares)",
    CurrentValue = "",
    PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInputUserID",
    Callback = function(Text)
        Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$")
    end,
})



     Toggle = WebhookTab:CreateToggle({
    Name = "Send On Stage Finished",
    CurrentValue = false,
    Flag = "SendWebhookOnStageFinished",
    Callback = function(Value)
        State.SendStageCompletedWebhook = Value
    end,
    })

local STAGE_PRIORITY = {
    "Lawless City",
    "Temple",
    "Orc Castle",
    "Kingdom of Wandenreich",
    "Namakora Village",
    "Central Command",
    "The Crimson Eclipse",
    "Hidden Leaf Village",
}

local excludedStages = {
    ["Easter Event"] = true,
    ["Moonbase Sci-Fi"] = true,
    ["Nazarick Mausoleum"] = true,
}

local STORY_STAGE_PRIORITY = {
    "Large Village",
    "Hollow Land",
    "Monster City",
    "Academy Demon",
}

local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
    })
end

local function canPerformAction()
    return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
end

local function setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()

    if action == "Story Auto Join" then
        notify("Auto Joiner: ", string.format(
            "Joining %s - %s [%s]",
            State.StoryStageSelected or "?",
            State.StoryActSelected or "?",
            State.StoryDifficultySelected or "?"
        ))
    end
end

local function clearProcessingState()
    AutoJoinState.isProcessing = false
    AutoJoinState.currentAction = nil
end

local function checkAndJoinGate()
    if not State.AutoJoinGate then return end
    if not isInLobby() then return end
    
    -- Check if GateOpening attribute is true
    local gateOpening = Services.Workspace:GetAttribute("GateOpening")
    if not gateOpening then return end
    
    setProcessingState("Auto Join Gate")
    
    -- Find the gate spawn point
    local gateSpawnPoint = Services.Workspace:FindFirstChild("Gatespawnpoint")
    if not gateSpawnPoint then
        warn("Gatespawnpoint not found in workspace")
        task.delay(5, clearProcessingState)
        return
    end
    
    local spawnPoint1 = gateSpawnPoint:FindFirstChild("1")
    if not spawnPoint1 then
        warn("Spawn point '1' not found in Gatespawnpoint")
        task.delay(5, clearProcessingState)
        return
    end
    
    local player = Services.Players.LocalPlayer
    
    -- Teleport player to the spawn point
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = spawnPoint1.CFrame
        
        -- Wait a moment for teleportation to complete
        task.wait(0.5)
        
        -- Look for proximity prompt in the area
        local proximityPrompt = nil
        
        -- Check if the spawn point itself has a proximity prompt
        proximityPrompt = Services.Workspace:WaitForChild("CreatingRoom"):WaitForChild("Server"):WaitForChild("PortalPart"):FindFirstChildOfClass("ProximityPrompt")
        
        -- If not found on spawn point, check nearby parts
        if not proximityPrompt then
            local function findNearbyParts(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("BasePart") then
                        local distance = (child.Position - spawnPoint1.Position).Magnitude
                        if distance <= 20 then -- Within 20 studs
                            local prompt = child:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                proximityPrompt = prompt
                                break
                            end
                        end
                    end
                    findNearbyParts(child)
                    if proximityPrompt then break end
                end
            end
            findNearbyParts(Services.Workspace)
        end
        
        -- Use the proximity prompt if found
        if proximityPrompt then
            proximityPrompt:InputHoldBegin()
            task.wait(0.1)
            proximityPrompt:InputHoldEnd()
            print("Gate joined successfully!")
            notify("Auto Joiner", "Gate joined successfully!")
        else
            warn("No proximity prompt found near the gate spawn point")
            notify("Auto Joiner", "No proximity prompt found at gate")
        end
    else
        warn("Player character or HumanoidRootPart not found")
    end
    
    task.delay(5, clearProcessingState)
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    if not canPerformAction() then return end

    --GATES
    if State.AutoJoinGate then
        checkAndJoinGate()
        return
    end

    --CHALLENGE
    if State.AutoJoinChallenge then
            setProcessingState("Auto Join Challenge")

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Challenge",{})
            task.wait(1)
            local portalpart = Services.Workspace:WaitForChild("CreatingRoom"):FindFirstChild(tostring(Services.Players.LocalPlayer.Name)):FindFirstChild("PortalPart")
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{portalpart:GetAttribute("Stages"),portalpart:GetAttribute("Act"),"Challenge"})


            task.delay(5, clearProcessingState)
            return
    end

    --TOWER ADVENTURES
    if State.AutoJoinTower and State.AutoJoinTowerSelected then
        setProcessingState("Auto Join Tower")

        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Tower Adventures",{State.AutoJoinTowerSelected,Services.Players.LocalPlayer.Stages[State.AutoJoinTowerSelected].Floor.Value,"Tower Adventures"})
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{State.AutoJoinTowerSelected,Services.Players.LocalPlayer.Stages[State.AutoJoinTowerSelected].Floor.Value,"Tower Adventures"})

        task.delay(5, clearProcessingState)
        return
    end

    if State.AutoJoinEvent and State.AutoJoinEventSelected then
        setProcessingState("Auto Join Event")

        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("host",{friendOnly = false,stage = State.AutoJoinEventSelected})
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("start")

            task.delay(5, clearProcessingState)
            return
    end

    if State.AutoJoinWorldlines and State.AutoJoinWorldlinesSelected then
        setProcessingState("Auto Join Worldlines")

        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("host",{friendOnly = false,stage = State.AutoJoinWorldlinesSelected})
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("start")

            task.delay(5, clearProcessingState)
            return
    end

    if State.AutoJoinPortal and State.AutoJoinPortalSelected then
            setProcessingState("Auto Join Portal")
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer(tostring(State.AutoJoinPortalSelected).." (Portal)",{})
            task.wait(1)
            local portalpart = Services.Workspace:WaitForChild("CreatingRoom"):FindFirstChild(tostring(Services.Players.LocalPlayer.Name)):FindFirstChild("PortalPart")
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{portalpart:GetAttribute("Stages"),portalpart:GetAttribute("Act"),portalpart:GetAttribute("Difficulty")})
            task.delay(5, clearProcessingState)
            return
    end

    --RAID
    if State.AutoJoinRaid and State.RaidStageSelected ~= nil then
            setProcessingState("Auto Join Raid")

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Raid",{State.RaidStageSelected,"1","Raid"})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{State.RaidStageSelected,"1","Boss Rush"})

            task.delay(5, clearProcessingState)
            return
    end

    -- STORY
    if State.AutoJoinStory and State.StoryStageSelected ~= nil and State.StoryActSelected ~= nil and State.StoryDifficultySelected ~= nil then
        setProcessingState("Auto Join Story")

        print(State.AutoJoinStory)
        print(State.StoryStageSelected)
        print(State.StoryActSelected)
        print(State.StoryDifficultySelected)

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Story",{State.StoryStageSelected,State.StoryActSelected,State.StoryDifficultySelected})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{State.StoryStageSelected,State.StoryActSelected,State.StoryDifficultySelected})

            task.delay(5, clearProcessingState)
            return
        end
    end

local function extractModuleStages()
    local moduleStages = {}
    
    for categoryName, categoryData in pairs(stageRewards) do
        if categoryName ~= "Story" and categoryName ~= "Infinity" then -- Skip Story and Infinity as they don't have named stages
            if type(categoryData) == "table" then
                -- Handle regular categories
                for stageName, stageData in pairs(categoryData) do
                    if stageName ~= "Rewards" and stageName ~= "ChanceRewards" and stageName ~= "FirstRewards" and stageName ~= "FloorRewards" then
                        if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards or stageData.FloorRewards or next(stageData)) then
                            moduleStages[stageName] = categoryName
                        end
                    end
                end
                
                -- Handle nested categories (like Darkness Gate)
                for subCategoryName, subCategoryData in pairs(categoryData) do
                    if type(subCategoryData) == "table" and not subCategoryData.Amount and not subCategoryData.Percents then
                        for nestedStageName, nestedStageData in pairs(subCategoryData) do
                            if nestedStageName ~= "Rewards" and nestedStageName ~= "ChanceRewards" and nestedStageName ~= "FirstRewards" and nestedStageName ~= "FloorRewards" then
                                if type(nestedStageData) == "table" and (nestedStageData.Rewards or nestedStageData.ChanceRewards or nestedStageData.FloorRewards or next(nestedStageData)) then
                                    moduleStages[nestedStageName] = categoryName .. " -> " .. subCategoryName
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return moduleStages
end

local function getPlayerStages()
    local playerStages = {}
    
    if LocalPlayer.Stages then
        for _, stageObject in pairs(LocalPlayer.Stages:GetChildren()) do
            playerStages[stageObject.Name] = true
        end
    else
        warn("LocalPlayer.Stages folder not found!")
        return {}
    end
    
    return playerStages
end

-- Function to find story stages
local function findStoryStages()
    local moduleStages = extractModuleStages()
    local playerStages = getPlayerStages()
    
    if next(playerStages) == nil then
        warn("No stages found in LocalPlayer.Stages folder!")
        return {}
    end
    
    local storyStages = {}
    
    -- Compare player stages with module stages
    for stageName, _ in pairs(playerStages) do
        if not moduleStages[stageName] and not excludedStages[stageName] then
            table.insert(storyStages, stageName)
        end
    end
    
    return storyStages
end

local function loadRaidStages()
    local allRaidStages = {}
    local orderedStages = {}
    local unlistedStages = {}
    
    -- Check if Raid category exists
    if stageRewards.Raid and type(stageRewards.Raid) == "table" then
        -- First, collect all valid raid stage names
        for stageName, stageData in pairs(stageRewards.Raid) do
            -- Make sure it's a valid stage (has rewards or chance rewards)
            if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards) then
                allRaidStages[stageName] = true
            end
        end
        
        -- Add stages in priority order (if they exist)
        for _, stageName in ipairs(STAGE_PRIORITY) do
            if allRaidStages[stageName] then
                table.insert(orderedStages, stageName)
                allRaidStages[stageName] = nil -- Remove from remaining stages
            end
        end
        
        -- Add any remaining stages alphabetically at the bottom
        for stageName, _ in pairs(allRaidStages) do
            table.insert(unlistedStages, stageName)
        end
        table.sort(unlistedStages) -- Sort alphabetically
        
        -- Combine ordered stages with unlisted stages
        local raidStages = {}
        for _, stageName in ipairs(orderedStages) do
            table.insert(raidStages, stageName)
        end
        for _, stageName in ipairs(unlistedStages) do
            table.insert(raidStages, stageName)
        end
        
        -- Set the dropdown options
        StageDropdown:Refresh(raidStages)
        
        print("Loaded " .. #raidStages .. " Raid stages into dropdown:")
        print("Priority ordered stages:")
        for i, stageName in ipairs(orderedStages) do
            print("  " .. i .. ". " .. stageName .. " (priority)")
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end 
    else
        warn("Raid category not found in StageRewards module!")
    end
end

local function loadStoryStages()
    print("=== STORY STAGE LOADER ===")
    print("Loading story stages into dropdown...")
    
    local allStoryStages = findStoryStages()

    if not allStoryStages or type(allStoryStages) ~= "table" then
        print("No story stages found or invalid data returned!")
        StoryStageDropdown:Refresh({})
        return
    end

    local orderedStages = {}
    local unlistedStages = {}
    local storyStageSet = {}
    
    -- Convert to set for quick lookup
    for _, stageName in ipairs(allStoryStages) do
        storyStageSet[stageName] = true
    end
    
    -- Add stages in priority order (if they exist)
    for _, stageName in ipairs(STORY_STAGE_PRIORITY) do
        if storyStageSet[stageName] then
            table.insert(orderedStages, stageName)
            storyStageSet[stageName] = nil -- Remove from remaining stages
        end
    end
    
    -- Add any remaining stages alphabetically at the bottom
    for stageName, _ in pairs(storyStageSet) do
        table.insert(unlistedStages, stageName)
    end
    table.sort(unlistedStages) -- Sort alphabetically
    
    -- Combine ordered stages with unlisted stages
    local finalStoryStages = {}
    for _, stageName in ipairs(orderedStages) do
        table.insert(finalStoryStages, stageName)
    end
    for _, stageName in ipairs(unlistedStages) do
        table.insert(finalStoryStages, stageName)
    end
    
    if #finalStoryStages > 0 then
        -- Set the dropdown options
        StoryStageDropdown:Refresh(finalStoryStages)
        
        print("Loaded " .. #finalStoryStages .. " Story stages into dropdown:")
        if #orderedStages > 0 then
            print("Priority ordered stages:")
            for i, stageName in ipairs(orderedStages) do
                print("  " .. i .. ". " .. stageName .. " (priority)")
            end
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end
    else
        print("No story stages found!")
        warn("Could not find any story stages. Make sure LocalPlayer.Stages exists and contains story stages.")
    end
end

local function loadPortalStages()
    local allPortalStages = {}
    local orderedStages = {}
    local unlistedStages = {}
    local playerInventory = Services.Players.LocalPlayer:FindFirstChild("ItemsInventory")
    
    -- Check if Portals category exists
    if stageRewards.Portals and type(stageRewards.Portals) == "table" then
        -- First, collect all valid portal stage names that the player has in inventory
        for stageName, stageData in pairs(stageRewards.Portals) do
            -- Make sure it's a valid stage (has rewards or chance rewards)
            if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards) then
                -- Check if player has the portal in their inventory
                local portalItemName = stageName .. " (Portal)"
                if playerInventory:FindFirstChild(portalItemName) then
                    allPortalStages[stageName] = true
                end
            end
        end
        
        -- Add stages in priority order (if they exist and player has them)
        if STAGE_PRIORITY then -- Check if STAGE_PRIORITY exists
            for _, stageName in ipairs(STAGE_PRIORITY) do
                if allPortalStages[stageName] then
                    table.insert(orderedStages, stageName)
                    allPortalStages[stageName] = nil -- Remove from remaining stages
                end
            end
        end
        
        -- Add any remaining stages alphabetically at the bottom
        for stageName, _ in pairs(allPortalStages) do
            table.insert(unlistedStages, stageName)
        end
        table.sort(unlistedStages) -- Sort alphabetically
        
        -- Combine ordered stages with unlisted stages
        local portalStages = {}
        for _, stageName in ipairs(orderedStages) do
            table.insert(portalStages, stageName)
        end
        for _, stageName in ipairs(unlistedStages) do
            table.insert(portalStages, stageName)
        end
        
        -- Set the dropdown options
        PortalStageDropdown:Refresh(portalStages)
        
        print("Loaded " .. #portalStages .. " Portal stages into dropdown:")
        print("Priority ordered stages:")
        for i, stageName in ipairs(orderedStages) do
            print("  " .. i .. ". " .. stageName .. " (priority)")
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end
        
        -- If no portals found in inventory
        if #portalStages == 0 then
            print("No portal items found in player's inventory!")
        end
    else
        warn("Portals category not found in StageRewards module!")
    end
end

local function snapshotInventory()
    local snapshot = {}
    State.unitNameSet = {}

    snapshot.Gold = Services.Players.LocalPlayer.Data.Coins.Value
    snapshot.Gem = Services.Players.LocalPlayer.Data.Tokens.Value
    snapshot.TraitReroll = Services.Players.LocalPlayer.Data.Reroll_Tokens.Value
    snapshot.Cog = Services.Players.LocalPlayer.Data.Cog.Value
    snapshot.Heart = Services.Players.LocalPlayer.Data.Heart.Value
    snapshot.Honey = Services.Players.LocalPlayer.Data.Honey.Value
    snapshot.MagicBall = Services.Players.LocalPlayer.Data.MagicBall.Value
    snapshot.MoonNight = Services.Players.LocalPlayer.Data.MoonNight.Value
    snapshot.Mushroom = Services.Players.LocalPlayer.Data.Mushroom.Value
    snapshot.Snowflake = Services.Players.LocalPlayer.Data.Snowflake.Value
    snapshot.StatReroll = Services.Players.LocalPlayer.Data.StatReroll.Value
    snapshot.SuperStatReroll = Services.Players.LocalPlayer.Data.SuperStatReroll.Value

    local itemInventory = Services.Players.LocalPlayer:WaitForChild("ItemsInventory")
    local unitInventory = Services.Players.LocalPlayer:WaitForChild("UnitsInventory")

    for _, item in pairs(itemInventory:GetChildren()) do
        if item:IsA("Folder") then
            snapshot[item.Name] = tonumber(item.Amount.Value)
        end
    end

    local unitCounts = {}
    for _, unit in pairs(unitInventory:GetChildren()) do
        if unit:IsA("Folder") then
            unitCounts[unit.Unit.Value] = (unitCounts[unit.Unit.Value] or 0) + 1
            State.unitNameSet[unit.Unit.Value] = true
        end
    end

    for unitName, count in pairs(unitCounts) do
        snapshot[unitName] = count
    end

    return snapshot
end

local function compareInventories(startInv, endInv)
    local gained = {}
    for itemName, endValue in pairs(endInv) do
        local startValue = startInv[itemName] or 0
        if endValue > startValue then
            local isUnit = State.unitNameSet[itemName] == true
            table.insert(gained, { name = itemName, amount = endValue - startValue, isUnit = isUnit })
        end
    end
    return gained
end

local function buildRewardsText()
    local endingInventory = snapshotInventory()
    local gainedItems = compareInventories(State.startingInventory, endingInventory)
    local lines = {}
    local detectedRewards = {}
    local detectedUnits = {}

    for _, reward in ipairs(gainedItems) do
        local itemName = reward.name
        local amount = reward.amount

        print(itemName.." - "..amount)

        detectedRewards[itemName] = amount

        local totalText = ""
        if reward.isUnit then
            table.insert(detectedUnits, itemName)
            totalText = ""
            table.insert(lines, string.format("🌟 %s x%d", itemName, amount))
        elseif itemName == "Gem" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Tokens.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName.."(s)", totalText))
        elseif itemName == "Gold" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Coins.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "TraitReroll" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Reroll_Tokens.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Cog" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Cog.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Heart" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Heart.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Honey" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Honey.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "MagicBall" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.MagicBall.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "MoonNight" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.MoonNight.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Snowflake" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Snowflake.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "StatReroll" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.StatReroll.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "SuperStatReroll" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.SuperStatReroll.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        else
            local itemObj = Services.Players.LocalPlayer:WaitForChild("ItemsInventory"):FindFirstChild(itemName)
            local totalAmount = itemObj and itemObj:FindFirstChild("Amount") and itemObj.Amount.Value or nil
            totalText = totalAmount and string.format(" [%d total]", totalAmount) or ""
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        end
    end

    if #gainedItems == 0 then
        return "_No rewards found after match_", {}, {}
    end

    local rewardsText = table.concat(lines, "\n")
    notify("Gained rewards:", rewardsText, 2)
    return rewardsText, detectedRewards, detectedUnits
end

local function calculateActualClearTime()
    if State.gameStartRealTime and State.gameEndRealTime then
        State.actualClearTime = State.gameEndRealTime - State.gameStartRealTime
        print(string.format("Clear time: %.2f seconds", State.actualClearTime))
        return State.actualClearTime
    end
    return nil
end

local function sendWebhook(messageType, rewards, clearTime, matchResult)
    if not ValidWebhook then return end

    local data
    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or "000000000000000000"),
            embeds = {{
                title = "📢 LixHub Notification",
                description = "🧪 Test webhook sent successfully",
                color = 0x5865F2,
                footer = { text = "LixHub Auto Logger" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
    elseif messageType == "stage" then
        local RewardsUI = Services.Workspace.GameSettings
        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stages").Value  or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Act").Value or "Unknown Act"
        local gameDif = RewardsUI and RewardsUI:FindFirstChild("Difficulty").Value  or "Unknown Difficulty"
        local isWin = Services.Workspace.GameSettings.Base.Health.Value > 0
        local resultText = isWin and "Victory" or "Defeat"
        local plrlevel = Services.Players.LocalPlayer.Data.Levels.Value or ""
        local actualClearTime = calculateActualClearTime()
        local formattedTime

         if actualClearTime then
            local hours = math.floor(actualClearTime / 3600)
            local minutes = math.floor((actualClearTime % 3600) / 60)
            local seconds = math.floor(actualClearTime % 60)
            formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end

        local rewardsText, detectedRewards, detectedUnits = buildRewardsText()
        local shouldPing = #detectedUnits > 0

        if #detectedUnits > 1 then return end

        local pingText = shouldPing and string.format("<@%s> 🎉 **SECRET UNIT OBTAINED!** 🎉", Config.DISCORD_USER_ID) or ""

        local stageResult = stageName.." - Act "..gameMode .. " - " .. gameDif .. " - " .. resultText
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        data = {
            username = "LixHub Bot",
            content = shouldPing and pingText or nil,
            embeds = {{
                title = shouldPing and "🌟 UNIT DROP! 🌟" or "🎯 Stage Finished!",
                description = shouldPing and (pingText .. "\n" .. stageResult) or stageResult,
                color = shouldPing and 0xFFD700 or (isWin and 0x57F287 or 0xED4245),
                fields = {
                    { name = "👤 Player", value = "||" .. Services.Players.LocalPlayer.Name .. " [" .. plrlevel .. "]||", inline = true },
                    { name = isWin and "✅ Won in:" or "❌ Lost after:", value = formattedTime, inline = true },
                    { name = "🏆 Rewards", value = rewardsText, inline = false },
                    shouldPing and { name = "🌟 Units Obtained", value = table.concat(detectedUnits, ", "), inline = false } or nil,
                    { name = "📈 Script Version", value = script_version, inline = true },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = timestamp
            }}
        }

        local filteredFields = {}
        for _, field in ipairs(data.embeds[1].fields) do if field then table.insert(filteredFields, field) end end
        data.embeds[1].fields = filteredFields
    else
        return
    end

    local payload = Services.HttpService:JSONEncode(data)
    local requestFunc = (syn and syn.request) or (http and http.request) or request

    if requestFunc then
        local success, result = pcall(function()
           -- notify("Webhook", "Sending webhook...")
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end)

        if success then
            notify("Webhook", "Webhook sent successfully.", 2)
        else
            warn("Webhook failed to send: " .. tostring(result))
            notify("Webhook Error", tostring(result))
        end
    else
        warn("No compatible HTTP request method found.")
        notify("Webhook Error", "No HTTP request method available.")
    end
end

local function onGameStart()
    gameInProgress = true
    macroHasPlayedThisGame = false
    gameStartTime = tick()
    
    -- Auto-start recording if enabled (like File 2)
    if isRecording and not recordingHasStarted then
        recordingHasStarted = true
        clearSpawnIdMappings()
        table.clear(macro)
        MacroStatusLabel:Set("Status: Recording active!")
        notify("Recording Started", "Game started - recording active.")
    end
    
    print("Game started, tracking initialized")
end

-- Update your wave monitoring to call onGameStart
Services.Workspace.GameSettings.Wave.Changed:Connect(function(newWave)
    if newWave >= 1 and not gameInProgress then
        startGameTracking()
    elseif newWave == 0 and gameInProgress then
        stopGameTracking()
    end
end)

local function checkInitialGameState()
    local waveNum = Services.Workspace.GameSettings.Wave
    if waveNum and waveNum.Value >= 1 then
        print("Joined mid-game at wave", waveNum.Value)
        startGameTracking()
    end
end

local function checkGameStarted()
    if isInLobby() then return end
    local gameStarted = Services.Workspace.GameSettings.GameStarted.Value
    if gameStarted then
        onGameStart()
    end
end

      TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
    })

loadRaidStages()
loadStoryStages()
loadPortalStages()
checkGameStarted()

task.spawn(function()
    while true do
    task.wait(0.5)
    checkAndExecuteHighestPriority()
    end
end)

if not isInLobby() then
    Services.ReplicatedStorage:WaitForChild("EndGame").OnClientEvent:Connect(function()
    print("Game ended")
    stopGameTracking()

    State.gameEndRealTime = tick()
    
if isRecording and recordingHasStarted then
    isRecording = false
    recordingHasStarted = false
    RecordToggle:Set(false)
    
    Rayfield:Notify({
        Title = "Recording Stopped",
        Content = "Game ended, recording saved.",
        Duration = 3
    })
    
    if currentMacroName then
        macroManager[currentMacroName] = macro
        saveMacroToFile(currentMacroName)
    end
end
    
    State.isGameRunning = false
    
    if State.SendStageCompletedWebhook then
        sendWebhook("stage", nil, "1:50", nil)
    end
    
    -- Handle retry with proper state management
    if State.AutoVoteRetry then
        RETRY_IN_PROGRESS = true
        print("Starting retry process")
        
        -- Send retry vote immediately
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                :WaitForChild("Events"):WaitForChild("Control"):FireServer("RetryVote")
        end)
        
        -- Monitor for game start and clear retry flag
        spawn(function()
            -- Wait for game to start
            while not game.Workspace.GameSettings.GameStarted.Value do
                task.wait(0.1)
            end
            
            -- Clear retry flag after game starts
            task.wait(1)
            RETRY_IN_PROGRESS = false
            print("Retry complete, auto functions restored")
        end)
        
    elseif State.AutoVoteNext then
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                :WaitForChild("Events"):WaitForChild("Control"):FireServer("Next Stage Vote")
        end)
    elseif State.AutoVoteLobby then
        Services.TeleportService:Teleport(17282336195, LocalPlayer)
    end
    
    isPlayingLoopRunning = false
end)
end

if not isInLobby() then
    game.Workspace.GameSettings.StagesChallenge.Mode.Changed:Connect(function()
    --if RETRY_IN_PROGRESS then 
    --    print("Retry in progress, ignoring mode change")
      --  return 
   -- end
    
    if State.AutoStartGame then
        local mode = game.Workspace.GameSettings.StagesChallenge.Mode.Value
        if mode ~= nil and mode ~= "" and not game.Workspace.GameSettings.GameStarted.Value then
            print("Mode set, starting game")
            task.wait(0.5)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Vote"):FireServer("Vote1")
            end)
        end
    end
end)
end

local function monitorStagesChallengeGUI()
    if isInLobby() then return end
    local playerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    local stagesChallenge = playerGui:WaitForChild("StagesChallenge")
    
    -- Check if GUI is already enabled when script starts
    if stagesChallenge.Enabled and State.AutoPickCard and State.AutoPickCardSelected then
        print("StagesChallenge GUI already open, picking card")
        task.wait(0.1)
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                :WaitForChild("Events"):WaitForChild("StageChallenge")
                :FireServer(State.AutoPickCardSelected)
        end)
    end
    
    -- Monitor for future changes
    stagesChallenge:GetPropertyChangedSignal("Enabled"):Connect(function()
        if stagesChallenge.Enabled and State.AutoPickCard and State.AutoPickCardSelected then
            print("StagesChallenge GUI opened, picking card")
            task.wait(0.1)
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                    :WaitForChild("Events"):WaitForChild("StageChallenge")
                    :FireServer(State.AutoPickCardSelected)
            end)
        end
    end)
end

-- Initialize the GUI monitor

if not isInLobby() then
    Services.Workspace.GameSettings.GameStarted.Changed:Connect(checkGameStarted)
end

ensureMacroFolders()
loadAllMacros()
setupGameTimeTracking()
checkInitialGameState()

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image = "eye-off", -- Lucide icon name
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RayfieldToggle"
screenGui.Parent = Services.Players.LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false

-- Create the circular image button
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.BorderSizePixel = 0
toggleButton.Position = UDim2.new(0, 50, 0, 50)
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Image = "rbxassetid://139436994731049" -- Put your logo image ID here like "rbxassetid://123456789"
toggleButton.ScaleType = Enum.ScaleType.Fit

-- Make it circular
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = toggleButton

-- Rayfield visibility state
local rayfieldVisible = true

-- Toggle function
local function toggleRayfield()
    rayfieldVisible = not rayfieldVisible
    
    if Rayfield then
        Rayfield:SetVisibility(rayfieldVisible)
    end
end

-- Dragging variables
local dragging = false
local dragStart = nil
local startPos = nil

-- Mouse input handling
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Click to toggle
local clickStartPos = nil
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        clickStartPos = input.Position
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if clickStartPos then
            local deltaMove = input.Position - clickStartPos
            local moveDistance = math.sqrt(deltaMove.X^2 + deltaMove.Y^2)
            
            if moveDistance < 10 then
                toggleRayfield()
            end
        end
    end
end)

task.spawn(function()
    task.wait(1)
    monitorStagesChallengeGUI()
end)

-- Restore macro selection and playback state after config loads
task.spawn(function()
    task.wait(2)
    
    local savedMacroName = Rayfield.Flags["MacroDropdown"]
    if type(savedMacroName) == "table" then
        savedMacroName = savedMacroName[1]
    end
    
    if savedMacroName and savedMacroName ~= "" and type(savedMacroName) == "string" then
        currentMacroName = savedMacroName
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if loadedMacro then
            macro = loadedMacro
            macroManager[currentMacroName] = loadedMacro
            print("Successfully loaded saved macro:", currentMacroName, "with", #macro, "actions")
        end
    end
    
    refreshMacroDropdown()
    
    -- Restore playback if it was enabled
    local savedPlaybackState = Rayfield.Flags["PlayBackMacro"]
    if savedPlaybackState == true and currentMacroName and currentMacroName ~= "" and macro and #macro > 0 then
        isAutoLoopEnabled = true
        
        task.spawn(autoPlaybackLoop)
        MacroStatusLabel:Set("Status: Playback restored - waiting for game")
        
        Rayfield:Notify({
            Title = "Playback Restored",
            Content = string.format("Auto-playing: %s", currentMacroName),
            Duration = 3
        })
        
        print(string.format("Playback restored: %s (%d actions)", currentMacroName, #macro))
    end
end)
