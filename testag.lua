--pipi
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local script_version = "V0.01"

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

   AutoJoinWorldlines = nil,
   AutoJoinWorldlinesSelected = nil,

   AutoJoinEvent = nil,
   AutoJoinEventSelected = nil,

   AutoJoinPortal = nil,
   AutoJoinPortalSelected = nil,

   AutoJoinChallenge = nil,

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

local macroManager = {}
local currentMacroName
local macro = {}
local pendingMacroName = ""
local pendingImportURL = ""
local pendingImportContent = ""

local recordingStartTime
local isRecording = false
local isPlaybacking = false
local isRecordingLoopRunning = false
local isPlayingLoopRunning = false
local playbackMode = "timing"
local currentWave = 0
local waveStartTime = 0
local currentPlacementOrder = 0

local unitMapping = {}

local playbackUnitMapping = {}
local recordingPlacementCounter = 0
local playbackPlacementIndex = 0

local ValidWebhook = nil

local UpdateLogTab = Window:CreateTab("Update Log", "scroll")
local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "tv")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

local UpdateLogSection = UpdateLogTab:CreateSection(script_version)

local Label1 = UpdateLogTab:CreateLabel("+ Release")
local Labelo2 = UpdateLogTab:CreateLabel("If you like my work feel free to donate at: https://ko-fi.com/lixhub")
local Labelo3 = UpdateLogTab:CreateLabel("Also please join the discord: https://discord.gg/cYKnXE2Nf8")

local MacroStatusLabel = MacroTab:CreateLabel("Status: Idle", "info")

CodeButton = LobbyTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        for _, stringValue in ipairs(Services.Players.LocalPlayer.Code:GetChildren()) do
	    if stringValue:IsA("Folder") and stringValue.Name ~= "Rewards" then
	            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Codes"):InvokeServer(stringValue.Name)
                print("redeemed "..stringValue.Name)
                task.wait(0.1)
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
    Name = "Streamer Mode (hide name/level/title)",
    CurrentValue = false,
    Flag = "StreamerMode",
    Callback = function(Value)
        State.streamerModeEnabled = Value
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
    
    if not prompt then return end
    
    -- Store original position
    local originalPosition = currentRoot.CFrame
    
    -- Teleport to chest
    currentRoot.CFrame = chest.CFrame + Vector3.new(0, 5, 0) -- Teleport slightly above chest
    
    -- Wait a brief moment for teleportation
    task.wait(0.1)
    
    -- Collect the chest
    prompt:InputHoldBegin(Services.Players.LocalPlayer)
    task.wait(0.2)
    prompt:InputHoldEnd(Services.Players.LocalPlayer)
    
    -- Optional: Wait a moment before moving to next chest
    task.wait(0.1)
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

local function findLatestSpawnedUnit(originalUnitName, unitCFrame)
    local ground = Services.Workspace:FindFirstChild("Ground")

    if not ground then 
        warn("Services.Workspace.Ground not found!")
        return originalUnitName 
    end

    local unitClient = ground:FindFirstChild("unitClient")
    if not unitClient then
        warn("Services.Workspace.Ground.unitClient not found!")
        return originalUnitName
    end

    local closestDistance = math.huge
    local closestUnitName = nil

    -- Extract base name without number for comparison
    local baseUnitName = originalUnitName:match("^(.-)%s*%d*$")

    for _, unit in pairs(unitClient:GetChildren()) do
        if unit:IsA("Model") then
            local unitPosition = unit.WorldPivot.Position
            local placementPosition = unitCFrame.Position
            local distance = (unitPosition - placementPosition).Magnitude

            -- Only consider units within 1 stud tolerance
            if distance <= 1 and distance < closestDistance then
                -- Check if this unit matches our base name
                local unitBaseName = unit.Name:match("^(.-)%s*%d*$")
                if unitBaseName == baseUnitName or unit.Name:find(originalUnitName, 1, true) then
                    closestDistance = distance
                    closestUnitName = unit.Name
                    print("Found matching unit: " .. unit.Name .. " within tolerance (distance: " .. distance .. ")")
                end
            end
        end
    end

    return closestUnitName or originalUnitName
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

local function getCurrentUnitName(recordedUnitName)
    return unitMapping[recordedUnitName] or recordedUnitName
end

local function clearUnitMapping()
    unitMapping = {}
    placementOrder = {}
    print("Unit mapping cleared for new game")
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

mt.__namecall = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    if not checkcaller() then
        task.spawn(function()
            -- Detection for spawnunit remote
            if isRecording and method == "InvokeServer" and self.Name == "spawnunit" then
                local unitsBefore = countPlacedUnits()
                local unitData = args[1]
                local unitName = unitData[1]
                local unitCFrame = unitData[2]
                local unitRotation = unitData[3]
                local unitId = args[2]
                local timestamp = tick()
                local currentWaveNum = getCurrentWave()
                
                -- Increment placement counter BEFORE attempting placement
                recordingPlacementCounter = recordingPlacementCounter + 1
                local thisPlacementOrder = recordingPlacementCounter
                
                print(string.format("Recording placement attempt #%d for %s", thisPlacementOrder, unitName))
                
                task.wait(1.5)
                
                local unitsAfter = countPlacedUnits()
                
                if unitsAfter > unitsBefore then
                    local actualUnitName = findLatestSpawnedUnit(unitName, unitCFrame)
                    
                    local placementData = {
                        action = "PlaceUnit",
                        unitName = unitName,
                        actualUnitName = actualUnitName,
                        cframe = unitCFrame,
                        rotation = unitRotation,
                        unitId = unitId,
                        time = timestamp - recordingStartTime,
                        wave = currentWaveNum,
                        timestamp = timestamp,
                        placementOrder = thisPlacementOrder
                    }
                    
                    table.insert(macro, placementData)
                    
                    -- FIXED: Store mapping using the ACTUAL unit name that appears in server
                    if actualUnitName then
                        unitMapping[actualUnitName] = thisPlacementOrder
                        print(string.format("🔗 Stored mapping: '%s' -> placement #%d", actualUnitName, thisPlacementOrder))
                    end
                    
                    print(string.format("✅ Recorded placement #%d: %s -> %s", 
                        thisPlacementOrder, unitName, actualUnitName or "Unknown"))
                else
                    -- If placement failed, decrement the counter
                    recordingPlacementCounter = recordingPlacementCounter - 1
                    print(string.format("❌ Placement failed, not recording: %s", unitName))
                end
                
            -- Detection for ManageUnits remote (Upgrade/Sell)
            elseif isRecording and method == "InvokeServer" and self.Name == "ManageUnits" then
                local action = args[1]
                local unitName = args[2] -- This is the actual server unit name like "Shigeru (Gachi Fighter) 1"
                local timestamp = tick()
                local currentWaveNum = getCurrentWave()
                
                task.wait(0.5)
                
                -- Use the stored mapping to find placement order
                local targetPlacementOrder = unitMapping[unitName]
                
                print(string.format("🔍 Looking for placement order for unit: '%s'", unitName))
                print("📋 Current unit mapping:")
                for mappedName, placementOrder in pairs(unitMapping) do
                    print(string.format("  '%s' -> placement #%d", mappedName, placementOrder))
                end
                
                if not targetPlacementOrder then
                    print(string.format("⚠️ Warning: Could not find exact placement order for unit '%s'", unitName))
                    
                    -- Try to find by partial match (remove numbers and compare base names)
                    local unitBaseName = unitName:match("^(.-)%s*%d*$")
                    print(string.format("🔧 Trying partial match with base name: '%s'", unitBaseName))
                    
                    for mappedName, placementOrder in pairs(unitMapping) do
                        local mappedBaseName = mappedName:match("^(.-)%s*%d*$")
                        if mappedBaseName == unitBaseName then
                            targetPlacementOrder = placementOrder
                            print(string.format("✅ Found placement order %d for '%s' via partial match (%s ≈ %s)", 
                                targetPlacementOrder, unitName, unitBaseName, mappedBaseName))
                            -- Update the mapping with the correct name
                            unitMapping[unitName] = targetPlacementOrder
                            unitMapping[mappedName] = nil -- Remove old mapping
                            break
                        end
                    end
                    
                    -- If still not found, try searching recent placements as fallback
                    if not targetPlacementOrder then
                        print("🔧 Trying fallback search through recent placements...")
                        for i = #macro, math.max(1, #macro - 10), -1 do
                            if macro[i].action == "PlaceUnit" then
                                local recordedBaseName = (macro[i].actualUnitName or macro[i].unitName):match("^(.-)%s*%d*$")
                                if recordedBaseName == unitBaseName then
                                    targetPlacementOrder = macro[i].placementOrder
                                    unitMapping[unitName] = targetPlacementOrder
                                    print(string.format("✅ Found placement order %d for '%s' via fallback search", 
                                        targetPlacementOrder, unitName))
                                    break
                                end
                            end
                        end
                    end
                end
                
                -- Ensure we have a valid placement order before recording
                if not targetPlacementOrder or targetPlacementOrder == 0 then
                    warn(string.format("❌ Cannot record %s action - no valid placement order found for unit '%s'", action, unitName))
                    return -- Don't record this action
                end
                
                if action == "Upgrade" then
                    table.insert(macro, {
                        action = "UpgradeUnit", 
                        unitName = unitName,
                        actualUnitName = unitName,
                        time = timestamp - recordingStartTime,
                        wave = currentWaveNum,
                        targetPlacementOrder = targetPlacementOrder
                    })
                    print(string.format("📈 Recorded upgrade for unit '%s' (targets placement #%d)", 
                        unitName, targetPlacementOrder))
                    
                elseif action == "Selling" then
                    table.insert(macro, {
                        action = "SellUnit", 
                        unitName = unitName,
                        actualUnitName = unitName,
                        time = timestamp - recordingStartTime,
                        wave = currentWaveNum,
                        targetPlacementOrder = targetPlacementOrder
                    })
                    print(string.format("💰 Recorded sell for unit '%s' (targets placement #%d)", 
                        unitName, targetPlacementOrder))
                    
                    -- Remove from mapping since unit is sold
                    unitMapping[unitName] = nil
                end
                
            elseif isRecording and method == "InvokeServer" and self.Name == "Skills" then
                local timestamp = tick()
                local currentWaveNum = getCurrentWave()
                
                local buttonType = args[1]
                local unitString = args[2]
                
                if buttonType == "SkillsButton" and unitString then
                    -- Extract unit name from the unit string to find placement order
                    local targetPlacementOrder = nil
                    local targetUnitName = nil
                    
                    -- Try to match with our stored mapping first
                    for actualName, placementOrder in pairs(unitMapping) do
                        if unitString:find(actualName, 1, true) then
                            targetPlacementOrder = placementOrder
                            targetUnitName = actualName
                            break
                        end
                    end
                    
                    table.insert(macro, {
                        action = "UltUnit",
                        unitString = unitString,
                        targetUnitName = targetUnitName,
                        time = timestamp - recordingStartTime,
                        wave = currentWaveNum,
                        targetPlacementOrder = targetPlacementOrder or 0
                    })
                    
                    print(string.format("⚡ Recorded ult: %s (targets placement #%s)", 
                        unitString, tostring(targetPlacementOrder or "UNKNOWN")))
                end
            end
        end)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local function shouldExecuteAction(action, currentTime, currentWave, currentWaveTime)
    if playbackMode == "timing" then
        return currentTime >= action.time
    elseif playbackMode == "wave" then
        if currentWave > action.wave then
            return true
        elseif currentWave == action.wave then
            return currentWaveTime >= (action.waveTime or 0)
        end
        return false
    elseif playbackMode == "both" then
        local timingReady = currentTime >= action.time
        local waveReady = currentWave >= action.wave and 
                        (currentWave > action.wave or currentWaveTime >= (action.waveTime or 0))
        return timingReady and waveReady
    end
    return false
end

local function onWaveChanged()
    local newWave = getCurrentWave()
    if newWave ~= currentWave then
        currentWave = newWave
        waveStartTime = tick()
        print(string.format("Wave %d started", currentWave))
    end
end

local function getPlayerUnitsFolder()
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return nil
    end
    
    local playerUnitsFolder = unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer).." (UNIT)")
    if not playerUnitsFolder then
        warn("Player units folder not found!")
        return nil
    end
    
    return playerUnitsFolder
end

local function getUnitUpgradeLevel(unitName)
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        return nil
    end
    
    local unit = playerUnitsFolder:FindFirstChild(unitName)
    if not unit then
        return nil
    end
    
    local upgradeValue = unit:FindFirstChild("Upgrade")
    if upgradeValue and upgradeValue:IsA("NumberValue") then
        return upgradeValue.Value
    end
    
    return nil
end

local function unitExistsInServer(unitName)
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        return false
    end
    
    return playerUnitsFolder:FindFirstChild(unitName) ~= nil
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

local function waitForSufficientMoney(requiredAmount, actionDescription)
    local currentMoney = getPlayerMoney()
    
    if currentMoney >= requiredAmount then
        return true -- Already have enough money
    end
    
    MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
        currentMoney, requiredAmount, actionDescription))
    
    print(string.format("💰 Insufficient funds for %s. Need %d, have %d. Waiting...", 
        actionDescription, requiredAmount, currentMoney))
    
    -- Wait until we have enough money
    while getPlayerMoney() < requiredAmount and isPlaybacking do
        task.wait(1) -- Check every second
        local newMoney = getPlayerMoney()
        if newMoney ~= currentMoney then
            currentMoney = newMoney
            MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
                currentMoney, requiredAmount, actionDescription))
        end
    end
    
    if not isPlaybacking then
        return false -- Playback was stopped while waiting
    end
    
    print(string.format("✅ Sufficient funds available for %s!", actionDescription))
    return true
end

local function tryPlaceUnitUntilSuccess(unitName, cframe, rotation, unitId, maxAttempts)
    maxAttempts = maxAttempts or 10
    local attempts = 0
    
    while attempts < maxAttempts and isPlaybacking do
        attempts = attempts + 1
        
        MacroStatusLabel:Set(string.format("Status: Placing %s (attempt %d/%d)", 
            unitName, attempts, maxAttempts))
        
        print(string.format("🎯 Attempting to place %s (attempt %d/%d)", 
            unitName, attempts, maxAttempts))
        
        -- Try to place the unit
        local success, err = pcall(function()
            local args = {
                {
                    unitName,
                    cframe,
                    rotation or 0
                },
                unitId
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                :WaitForChild("Events"):WaitForChild("spawnunit"):InvokeServer(unpack(args))
        end)
        
        if not success then
            warn(string.format("❌ Failed to send place request for %s: %s", unitName, err))
            task.wait(1)
            continue
        end
        
        -- Wait and check if unit was actually placed
        task.wait(1.5)
        
        -- Find and verify the unit exists in unitServer
        local actualUnitName = findLatestSpawnedUnit(unitName, cframe)
        if actualUnitName and unitExistsInServer(actualUnitName) then
            print(string.format("✅ Successfully placed %s! Server unit: %s", 
                unitName, actualUnitName))
            
            -- Update the mapping for upgrades/sells later
            playbackUnitMapping[currentPlacementOrder] = actualUnitName
            print(string.format("🔗 Mapped placement #%d -> %s", currentPlacementOrder, actualUnitName))
            
            return true
        end
        
        -- If we reach here, placement failed
        print(string.format("❌ Placement failed - unit not found in server"))
        
        if attempts < maxAttempts then
            print(string.format("⏳ Placement attempt %d failed, waiting before retry...", attempts))
            task.wait(2) -- Wait before next attempt
        end
    end
    
    warn(string.format("❌ Failed to place %s after %d attempts", unitName, attempts))
    return false
end

local function executeUnitPlacement(actionData)
    -- Use the RECORDED placement order, not a generated one
    local recordedPlacementOrder = actionData.placementOrder
    
    print(string.format("🎯 Placing unit: %s (recorded as placement #%d)", 
        actionData.unitName, recordedPlacementOrder or "UNKNOWN"))
    
    local success = tryPlaceUnitUntilSuccess(
        actionData.unitName, 
        actionData.cframe, 
        actionData.rotation or 0, 
        actionData.unitId,
        10
    )
    
    if success then
        -- Find the actual unit name that was placed
        local actualUnitName = findLatestSpawnedUnit(actionData.unitName, actionData.cframe)
        
        if actualUnitName and recordedPlacementOrder then
            -- Map the recorded placement order to the actual unit name
            playbackUnitMapping[recordedPlacementOrder] = actualUnitName
            print(string.format("🔗 Mapped placement #%d -> %s", 
                recordedPlacementOrder, actualUnitName))
        else
            warn(string.format("⚠️ Warning: Failed to map placement order %s to actual unit %s", 
                tostring(recordedPlacementOrder), tostring(actualUnitName)))
        end
    end
    
    return success
end

local function executeUnitUpgrade(actionData)
    local targetOrder = actionData.targetPlacementOrder or 0
    local currentUnitName = playbackUnitMapping[targetOrder]
    
    if not currentUnitName or targetOrder == 0 then
        warn(string.format("❌ Could not find current unit name for placement #%d", targetOrder))
        MacroStatusLabel:Set("Status: Error - Unit not found for upgrade")
        return false
    end
    
    print(string.format("🔍 Preparing to upgrade placement #%d: %s", targetOrder, currentUnitName))
    
    -- Get current upgrade level before upgrade
    local upgradeLevelBefore = getUnitUpgradeLevel(currentUnitName)
    
    if not upgradeLevelBefore then
        warn(string.format("❌ Could not determine current upgrade level for %s", currentUnitName))
        MacroStatusLabel:Set("Status: Error - Cannot read upgrade level")
        return false
    end
    
    -- Get upgrade cost
    local upgradeCost = getUnitUpgradeCost(currentUnitName)
    
    if not upgradeCost then
        warn(string.format("❌ Could not determine upgrade cost for %s", currentUnitName))
        MacroStatusLabel:Set("Status: Error - Unknown upgrade cost")
        return false
    end
    
    -- Wait for sufficient money
    local unitDescription = string.format("upgrade %s", currentUnitName)
    if not waitForSufficientMoney(upgradeCost, unitDescription) then
        return false -- Playback was stopped while waiting
    end
    
    -- Attempt the upgrade
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits"):InvokeServer("Upgrade", currentUnitName)
    end)
    
    if success then
        -- Wait a moment and verify upgrade level increased
        task.wait(0.5)
        local upgradeLevelAfter = getUnitUpgradeLevel(currentUnitName)
        
        if upgradeLevelAfter and upgradeLevelAfter > upgradeLevelBefore then
            print(string.format("⬆️ Successfully upgraded unit from placement #%d (%d→%d)", 
                targetOrder, upgradeLevelBefore, upgradeLevelAfter))
            MacroStatusLabel:Set(string.format("Status: Upgraded unit (%d→%d)", upgradeLevelBefore, upgradeLevelAfter))
            return true
        else
            warn(string.format("❌ Upgrade request sent but level unchanged (%s)", tostring(upgradeLevelAfter)))
            MacroStatusLabel:Set("Status: Upgrade failed - level unchanged")
            return false
        end
    else
        warn(string.format("❌ Failed to upgrade unit from placement #%d: %s", targetOrder, err))
        MacroStatusLabel:Set("Status: Upgrade request failed")
        return false
    end
end

local function executeUnitSell(actionData)
    -- Get the target placement order - ensure it's not 0
    local targetOrder = actionData.targetPlacementOrder
    
    -- Enhanced debugging
    print(string.format("🔍 Attempting to sell - Target placement order: %s", tostring(targetOrder)))
    print("📋 Current playback mapping:")
    for order, unitName in pairs(playbackUnitMapping) do
        print(string.format("  Placement #%d -> %s", order, unitName))
    end
    print(string.format("   Recorded data: unitName='%s', actualUnitName='%s'", 
        tostring(actionData.unitName), tostring(actionData.actualUnitName)))
    
    -- If targetOrder is invalid, try to find it from the recorded data
    if not targetOrder or targetOrder == 0 then
        warn(string.format("❌ Invalid target placement order: %s", tostring(targetOrder)))
        
        -- Try to find the placement order from recorded unit names
        local recordedUnitName = actionData.actualUnitName or actionData.unitName
        if recordedUnitName then
            print(string.format("🔧 Searching for unit matching: %s", recordedUnitName))
            
            -- Search through the playback mapping for a matching unit
            for placementOrder, currentUnitName in pairs(playbackUnitMapping) do
                print(string.format("  Checking placement #%d: %s", placementOrder, currentUnitName))
                
                -- Try exact match first
                if currentUnitName == recordedUnitName then
                    targetOrder = placementOrder
                    print(string.format("✅ Found exact match: placement #%d", targetOrder))
                    break
                end
                
                -- Try partial match (in case numbers are different)
                local recordedBaseName = recordedUnitName:match("^(.-)%s*%d*$") -- Remove trailing numbers
                local currentBaseName = currentUnitName:match("^(.-)%s*%d*$")   -- Remove trailing numbers
                
                if recordedBaseName and currentBaseName and recordedBaseName == currentBaseName then
                    targetOrder = placementOrder
                    print(string.format("✅ Found partial match: placement #%d (%s ≈ %s)", 
                        targetOrder, recordedBaseName, currentBaseName))
                    break
                end
            end
        end
    end
    
    -- If still no valid target order, error out
    if not targetOrder or targetOrder == 0 then
        warn(string.format("❌ Could not determine valid placement order for sell action"))
        warn(string.format("   All recorded data: targetPlacementOrder=%s, unitName=%s, actualUnitName=%s", 
            tostring(actionData.targetPlacementOrder), 
            tostring(actionData.unitName), 
            tostring(actionData.actualUnitName)))
        MacroStatusLabel:Set("Status: Error - Invalid placement order for sell")
        return false
    end
    
    -- Get the current unit name based on placement order
    local currentUnitName = playbackUnitMapping[targetOrder]
    
    if not currentUnitName then
        warn(string.format("❌ Could not find current unit name for placement #%d", targetOrder))
        MacroStatusLabel:Set("Status: Error - Unit not found for sell")
        return false
    end
    
    print(string.format("🎯 Selling placement #%d: %s", targetOrder, currentUnitName))
    
    -- Check if unit exists before selling
    if not unitExistsInServer(currentUnitName) then
        warn(string.format("❌ Unit %s not found in server before sell attempt", currentUnitName))
        MacroStatusLabel:Set("Status: Error - Unit not found in server")
        return false
    end
    
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits"):InvokeServer("Selling", currentUnitName)
    end)
    
    if success then
        task.wait(0.5)
        
        -- Verify unit no longer exists in server
        if not unitExistsInServer(currentUnitName) then
            print(string.format("💰 Successfully sold unit from placement #%d", targetOrder))
            MacroStatusLabel:Set(string.format("Status: Successfully sold unit"))
            
            -- Remove from mapping since unit is sold
            playbackUnitMapping[targetOrder] = nil
            
            return true
        else
            warn(string.format("❌ Sell request sent but unit still exists in server"))
            MacroStatusLabel:Set("Status: Sell failed - unit still exists")
            return false
        end
    else
        warn(string.format("❌ Failed to sell unit from placement #%d: %s", targetOrder, err))
        MacroStatusLabel:Set("Status: Sell request failed")
        return false
    end
end

local function executeUnitUlt(actionData)
    -- Get the current unit name based on which placement this ult targets
    local currentUnitName = playbackUnitMapping[actionData.targetPlacementOrder]
    
    if not currentUnitName or actionData.targetPlacementOrder == 0 then
        warn(string.format("❌ Could not find current unit name for placement #%d", actionData.targetPlacementOrder or 0))
        MacroStatusLabel:Set("Status: Error - Unit not found for ult")
        return false
    end
    
    print(string.format("🔍 Preparing to ult placement #%d: %s", actionData.targetPlacementOrder, currentUnitName))
    
    -- Check if unit exists in server before attempting ult
    if not unitExistsInServer(currentUnitName) then
        warn(string.format("❌ Unit %s not found in server before ult attempt", currentUnitName))
        MacroStatusLabel:Set("Status: Error - Unit not found in server")
        return false
    end
    
    -- Method 1: Try to find the exact unit in unitClient and use its full name
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
                        print(string.format("⚡ Successfully ulted unit from placement #%d: %s", 
                            actionData.targetPlacementOrder, unit.Name))
                        MacroStatusLabel:Set(string.format("Status: Ulted unit %s", currentUnitName))
                        return true
                    else
                        warn(string.format("❌ Failed to ult unit %s: %s", unit.Name, err))
                    end
                end
            end
        end
    end
    
    -- Method 2: Fallback - try using the current unit name directly
    local success, err = pcall(function()
        local args = {"SkillsButton", currentUnitName}
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("Skills"):InvokeServer(unpack(args))
    end)
    
    if success then
        print(string.format("⚡ Successfully ulted unit (fallback method): %s", currentUnitName))
        MacroStatusLabel:Set(string.format("Status: Ulted unit %s", currentUnitName))
        return true
    else
        warn(string.format("❌ Failed to ult unit %s: %s", currentUnitName, err))
    end
    
    warn(string.format("❌ Failed to ult unit from placement #%d - no valid method worked", actionData.targetPlacementOrder or 0))
    MacroStatusLabel:Set("Status: Failed to ult unit")
    return false
end

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
        Rayfield:Notify({
                Title = "Macro Selected",
                Content = "Selected macro '" .. selectedName .. "' with " .. #macro .. " actions.",
                Duration = 3
            })
    else
        print("Invalid selection or macro doesn't exist:", selectedName)
    end
    end,
    })

    local MacroInput = MacroTab:CreateInput({
    Name = "Input Macro Name",
    CurrentValue = "",
    PlaceholderText = "Enter macro name...",
    RemoveTextAfterFocusLost = false,
    Flag = "MacroInput",
    Callback = function(text)
        pendingMacroName = text
    end,
    })

local function serializeVector3(v)
    return { x = v.X, y = v.Y, z = v.Z }
end

local function serializeCFrame(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return {
        x = x, y = y, z = z,
        r00 = r00, r01 = r01, r02 = r02,
        r10 = r10, r11 = r11, r12 = r12,
        r20 = r20, r21 = r21, r22 = r22
    }
end


local function deserializeVector3(t)
    return Vector3.new(t.x, t.y, t.z)
end

local function deserializeCFrame(t)
    return CFrame.new(
        t.x, t.y, t.z,
        t.r00, t.r01, t.r02,
        t.r10, t.r11, t.r12,
        t.r20, t.r21, t.r22
    )
end

local function serializeAction(action)
    local serializedAction = table.clone(action)
    if serializedAction.cframe then
        serializedAction.cframe = serializeCFrame(serializedAction.cframe)
    end
    return serializedAction
end

local function deserializeAction(action)
    local deserializedAction = table.clone(action)
    if deserializedAction.cframe then
        deserializedAction.cframe = deserializeCFrame(deserializedAction.cframe)
    end
    return deserializedAction
end

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
local function getMacroFilename(name)
        -- Handle case where name might be a table
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

        local serializedData = {}
        for _, action in ipairs(data) do
            local newAction = table.clone(action)
            if newAction.position then
                newAction.position = serializeVector3(newAction.position)
            end
            if newAction.cframe then
                newAction.cframe = serializeCFrame(newAction.cframe)
            end
            table.insert(serializedData, newAction)
        end

        local json = Services.HttpService:JSONEncode(serializedData)
        writefile(getMacroFilename(name), json)
    end

local function refreshMacroDropdown()
        local options = {}

        for name in pairs(macroManager) do
            table.insert(options, name)
        end

        table.sort(options)

        -- Handle case where currentMacroName might be a table
        if type(currentMacroName) == "table" then
            currentMacroName = currentMacroName[1] or ""
        end

        -- Only set currentMacroName to first option if it's completely empty/nil
        -- Don't override if it exists but isn't in macroManager (it might be loading from config)  
        if not currentMacroName or currentMacroName == "" then
            currentMacroName = options[1]
        end

        -- Only update macro if currentMacroName exists in macroManager
        if currentMacroName and macroManager[currentMacroName] then
            macro = macroManager[currentMacroName]
        end

        MacroDropdown:Refresh(options, currentMacroName)

        for i, opt in ipairs(options) do
            print("Option " .. i .. " = " .. tostring(opt) .. " (" .. typeof(opt) .. ")")
        end

        print("Refreshed dropdown with:", table.concat(options, ", "))
        print("Current macro is:", currentMacroName, "Type:", type(currentMacroName))
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

            for _, action in ipairs(data) do
            if action.position then
                action.position = deserializeVector3(action.position)
            end
            if action.cframe then
                action.cframe = deserializeCFrame(action.cframe)
            end
        end
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

local CreateMacroButton = MacroTab:CreateButton({
    Name = "Create Empty Macro",
    Callback = function()
        local name = pendingMacroName
        if not name or name == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a valid macro name.",
                Duration = 3
            })
            return
        end
        if macroManager[name] then
            Rayfield:Notify({
                Title = "Error",
                Content = "Macro '" .. name .. "' already exists.",
                Duration = 3
            })
            return
        end

        macroManager[name] = {}

        saveMacroToFile(name)
        refreshMacroDropdown()
        Rayfield:Notify({
            Title = "Success",
            Content = "Created macro '" .. name .. "'.",
            Duration = 3
        })
    end,
    })

    local RefreshMacroListButton = MacroTab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        loadAllMacros()
        refreshMacroDropdown()
        Rayfield:Notify({
            Title = "Success",
            Content = "Macro list refreshed.",
            Duration = 3
        })
    end,
    })

    local DeleteSelectedMacroButton = MacroTab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
            if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "No macro selected.",
                Duration = 3
            })
            return
        end

        deleteMacroFile(currentMacroName)
        Rayfield:Notify({
            Title = "Deleted",
            Content = "Deleted macro '" .. currentMacroName .. "'.",
            Duration = 3
        })

        macroManager[currentMacroName] = nil
        macro = {}
        refreshMacroDropdown()
    end,
    })

local function clearRecordingMapping()
    unitMapping = {}
    recordingPlacementCounter = 0
    print("🧹 Cleared recording mapping for new game")
end

RecordToggle = MacroTab:CreateToggle({
    Name = "Record",
    CurrentValue = false,
    Flag = "RecordMacro",
    Callback = function(Value)
        isRecording = Value

        if Value and not isRecordingLoopRunning then
            recordingHasStarted = false -- Reset the flag when starting
            MacroStatusLabel:Set("Status: Preparing to record...")
            Rayfield:Notify({
                Title = "Macro Recording",
                Content = "Waiting for game to start...",
                Duration = 4
            })

            recordingThread = task.spawn(function()
                waitForGameStart()
                if isRecording then
                    recordingHasStarted = true -- Set flag when recording actually starts
                    isRecordingLoopRunning = true
                    clearRecordingMapping()
                    table.clear(macro)
                    recordingStartTime = tick()
                    MacroStatusLabel:Set("Status: Recording active!")

                    Rayfield:Notify({
                        Title = "Recording Started",
                        Content = "Macro recording is now active.",
                        Duration = 4
                    })
                end
            end)

        elseif not Value then
            if isRecordingLoopRunning then
                Rayfield:Notify({
                    Title = "Recording Stopped",
                    Content = "Recording manually stopped.",
                    Duration = 3
                })
            end
            isRecordingLoopRunning = false
            recordingHasStarted = false -- Reset flag when stopping
            MacroStatusLabel:Set("Status: Recording stopped")

            if currentMacroName then
                macroManager[currentMacroName] = macro
                ensureMacroFolders()
                saveMacroToFile(currentMacroName)
            end
        end
    end
})

local function clearPlaybackMapping()
    playbackUnitMapping = {}
    playbackPlacementIndex = 0
    print("🧹 Cleared playback unit mapping for new game")
end

local function playMacroLoop()
    if not macro or #macro == 0 then
        MacroStatusLabel:Set("Status: Error - No macro data!")
        Rayfield:Notify({
            Title = "Playback Error",
            Content = "No macro data to play back.",
            Duration = 3
        })
        return
    end

    isPlayingLoopRunning = true
    MacroStatusLabel:Set("Status: Macro playback active")
    
    while isPlaybacking do
        -- Clear mapping at start of each game
        clearPlaybackMapping()
        
        local gameStartTime = tick()
        print("Starting macro playback...")
        MacroStatusLabel:Set("Status: Executing macro actions...")
        
        local actionIndex = 1
        currentWave = getCurrentWave()
        waveStartTime = tick()
        placedUnitsTracking = {}
        -- REMOVED: currentPlacementOrder = 0 -- Don't track this separately anymore
        
        print(string.format("Macro has %d total actions to execute", #macro))
        
        while isPlaybacking and actionIndex <= #macro do
            onWaveChanged()
            
            local currentTime = tick() - gameStartTime
            local currentWaveTime = tick() - waveStartTime
            local action = macro[actionIndex]
            
            local shouldExecute = shouldExecuteAction(action, currentTime, currentWave, currentWaveTime)
            
            if shouldExecute then
                print(string.format("Executing action %d/%d: %s", 
                    actionIndex, #macro, action.action))
                
                local actionSuccess = false
                
                if action.action == "PlaceUnit" then
                    -- REMOVED: currentPlacementOrder = action.placementOrder or (currentPlacementOrder + 1)
                    actionSuccess = executeUnitPlacement(action)
                    
                elseif action.action == "UpgradeUnit" then
                    actionSuccess = executeUnitUpgrade(action)
                    
                elseif action.action == "SellUnit" then
                    actionSuccess = executeUnitSell(action)

                elseif action.action == "UltUnit" then
                    actionSuccess = executeUnitUlt(action)
                    
                elseif action.action == "SkipWave" then
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Vote"):FireServer("Vote2")
                        end)
                    if success then
                        print("⏭️ Skipped wave")
                        MacroStatusLabel:Set("Status: Skipped wave")
                        actionSuccess = true
                    else
                        warn(string.format("Failed to skip wave: %s", err))
                        MacroStatusLabel:Set("Status: Failed to skip wave")
                    end
                end
                
                -- Only proceed to next action if current one succeeded (except for non-critical actions)
                if actionSuccess or action.action == "SkipWave" then
                    actionIndex = actionIndex + 1
                else
                    -- For failed critical actions, wait a bit before retrying
                    print("⏳ Action failed, waiting before retry...")
                    task.wait(2)
                end
            end
            local entityCount = countPlacedUnits()
            local waitTime = entityCount > 20 and 0.5 or 0.1
            task.wait(waitTime)
        end
        
        if actionIndex > #macro then
            print("Macro completed all actions, waiting for next game...")
            MacroStatusLabel:Set("Status: Macro completed, waiting for next game...")
        else
            print("Macro interrupted")
            MacroStatusLabel:Set("Status: Macro interrupted")
        end
        
        if actionIndex > #macro and isPlaybacking then
            print("Waiting for next game to start...")
            MacroStatusLabel:Set("Status: Waiting for next game...")
            waitForGameStart()
        end
    end
    
    isPlayingLoopRunning = false
    MacroStatusLabel:Set("Status: Playback stopped")
    print("Macro playback loop ended")
end

PlayToggle = MacroTab:CreateToggle({
    Name = "Playback",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isPlaybacking = Value

        if Value and not isPlayingLoopRunning then
            MacroStatusLabel:Set("Status: Preparing playback...")
            Rayfield:Notify({
                Title = "Macro Playback",
                Content = "Waiting for game to start...",
                Duration = 4
            })

            playbackThread = task.spawn(function()
                waitForGameStart()
                if isPlaybacking then
                    if currentMacroName then
                        ensureMacroFolders()
                        local loadedMacro = loadMacroFromFile(currentMacroName)
                        if loadedMacro then
                            macro = loadedMacro
                        else
                            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
                            Rayfield:Notify({
                                Title = "Playback Error",
                                Content = "Failed to load macro: " .. tostring(currentMacroName),
                                Duration = 5,
                            })
                            isPlaybacking = false
                            PlayToggle:Set(false)
                            return
                        end
                    else
                        MacroStatusLabel:Set("Status: Error - No macro selected!")
                        Rayfield:Notify({
                            Title = "Playback Error",
                            Content = "No macro selected for playback.",
                            Duration = 5,
                        })
                        isPlaybacking = false
                        PlayToggle:Set(false)
                        return
                    end

                    isPlayingLoopRunning = true

                    Rayfield:Notify({
                        Title = "Playback Started",
                        Content = "Macro is now executing...",
                        Duration = 4
                    })

                    playMacroLoop()

                    isPlayingLoopRunning = false
                end
            end)
        elseif not Value then
            MacroStatusLabel:Set("Status: Playback disabled")
            Rayfield:Notify({
                Title = "Macro Playback",
                Content = "Playback disabled.",
                Duration = 3
            })
        end
    end,
})

local ExportMacroButton = MacroTab:CreateButton({
    Name = "Export Selected Macro (Compact JSON)",
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

    local ImportURLInput = MacroTab:CreateInput({
        Name = "Import URL",
        CurrentValue = "",
        PlaceholderText = "Paste download URL here...",
        RemoveTextAfterFocusLost = false,
        Flag = "ImportURLInput",
        Callback = function(text)
            pendingImportURL = text
        end,
    })

    local ExportMacroFullButton = MacroTab:CreateButton({
    Name = "Export Selected Macro (Full JSON)",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Export Error",
                Content = "No macro selected for export.",
                Duration = 3
            })
            return
        end
        exportMacroToClipboard(currentMacroName, "full")
    end,
})

    local ImportFromURLButton = MacroTab:CreateButton({
        Name = "Import from URL",
        Callback = function()
            if not pendingImportURL or pendingImportURL == "" then
                Rayfield:Notify({
                    Title = "Import Error",
                    Content = "Please enter a URL first.",
                    Duration = 3
                })
                return
            end
            
            if not pendingMacroName or pendingMacroName == "" then
                Rayfield:Notify({
                    Title = "Import Error",
                    Content = "Please enter a macro name first.",
                    Duration = 3
                })
                return
            end
            
            importMacroFromURL(pendingImportURL, pendingMacroName)
        end,
    })

    local ImportContentInput = MacroTab:CreateInput({
    Name = "Paste Macro JSON Content",
    CurrentValue = "",
    PlaceholderText = "Paste your macro JSON here...",
    RemoveTextAfterFocusLost = false,
    Flag = "ImportContentInput",
    Callback = function(text)
        pendingImportContent = text
    end,
})

    local ImportFromContentButton = MacroTab:CreateButton({
    Name = "Import from Pasted Content",
    Callback = function()
        if not pendingImportContent or pendingImportContent:match("^%s*$") then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Please paste macro JSON content first.",
                Duration = 3
            })
            return
        end
        
        if not pendingMacroName or pendingMacroName == "" then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Please enter a macro name first.",
                Duration = 3
            })
            return
        end
        
        importMacroFromContent(pendingImportContent, pendingMacroName)
    end,
})

local Label5 = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

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
            Label5:Set("Awaiting Webhook Input...")
            return
        end

        local valid = trimmed:match("^https://discord%.com/api/webhooks/%d+/.+$")

        if valid then
            ValidWebhook = trimmed
            Label5:Set("✅ Webhook URL set!")
        else
            ValidWebhook = nil
            Label5:Set("❌ Invalid Webhook URL. Ensure it's complete and starts with 'https://discord.com/api/webhooks/'")
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

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    if not canPerformAction() then return end

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
    State.startingInventory = snapshotInventory()
    State.isGameRunning = true

    State.gameStartRealTime = tick()
    State.gameEndRealTime = nil
    State.actualClearTime = nil
    print("🟢Game Started: ", State.gameStartRealTime)
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

--[[Services.ReplicatedStorage:WaitForChild("EndGame").OnClientEvent:Connect(function()
                if isRecording then
            isRecording = false
            isRecordingLoopRunning = false
            Rayfield:Notify({
                Title = "Recording Stopped",
                Content = "Game ended, recording has been automatically stopped and saved.",
                Duration = 3,
                Image = 0,
            })
            RecordToggle:Set(false)

            if currentMacroName then
                macroManager[currentMacroName] = macro
                saveMacroToFile(currentMacroName)
            end
        end 
    State.isGameRunning = false
    if State.SendStageCompletedWebhook then
        sendWebhook("stage", nil, "1:50", nil)
    end
    if State.AutoVoteNext and not isNexting then
        isNexting = true
        spawn(function()
            while State.AutoVoteNext and not game.Workspace.GameSettings.GameStarted.Value do
                local success, err = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                        :WaitForChild("Events"):WaitForChild("Control"):FireServer("Next Stage Vote")
                end)
                
                if success then
                    print("Next sent!")
                else
                    print("Next failed, retrying...")
                end
                
                wait(10)
            end
            isNexting = false
        end)
    end

   if State.AutoVoteRetry and not isRetrying then
    isRetrying = true
    retryStartTime = tick()
    
    spawn(function()
        while State.AutoVoteRetry and not game.Workspace.GameSettings.GameStarted.Value do
            local success, err = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                    :WaitForChild("Events"):WaitForChild("Control"):FireServer("RetryVote")
            end)
            
            if success then
                print("Vote sent!")
            else
                print("Failed, retrying...")
            end
            wait(10)
        end
        isRetrying = false
    end)
end
    if State.AutoVoteLobby then
        Services.TeleportService:Teleport(17282336195, LocalPlayer)
    end
    isPlayingLoopRunning = false
end)--]]

if not isInLobby() then
    Services.ReplicatedStorage:WaitForChild("EndGame").OnClientEvent:Connect(function()
    print("Game ended")
    
    -- Handle recording stop - only stop if recording has actually started
    if isRecording and recordingHasStarted then
        isRecording = false
        isRecordingLoopRunning = false
        recordingHasStarted = false
        RecordToggle:Set(false)
        
        Rayfield:Notify({
            Title = "Recording Stopped",
            Content = "Game ended, recording has been automatically stopped and saved.",
            Duration = 3
        })
        
        if currentMacroName then
            macroManager[currentMacroName] = macro
            saveMacroToFile(currentMacroName)
        end
    elseif isRecording and not recordingHasStarted then
        -- If recording is enabled but hasn't started yet, don't stop it
        print("Recording was waiting for game start - not stop recording")
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

Rayfield:LoadConfiguration()

    task.spawn(function()
        while true do
            task.wait(0.1)
            StreamerMode()
        end
    end)

    task.delay(1, function()
        task.spawn(function()
    monitorStagesChallengeGUI()
end)



        local savedMacroName = Rayfield.Flags["MacroDropdown"]
        
        -- Handle case where savedMacroName might be a table
        if type(savedMacroName) == "table" then
            savedMacroName = savedMacroName[1]
        end
        
        if savedMacroName and savedMacroName ~= "" and type(savedMacroName) == "string" then
            currentMacroName = savedMacroName
            
            -- Load the macro data from file when restoring from config
            local loadedMacro = loadMacroFromFile(currentMacroName)
            if loadedMacro then
                macro = loadedMacro
                macroManager[currentMacroName] = loadedMacro
                print("Successfully loaded saved macro:", currentMacroName, "with", #macro, "actions")
            else
                print("Failed to load saved macro:", currentMacroName)
                currentMacroName = nil
            end
        else
            print("No valid saved macro name found. Type:", type(savedMacroName), "Value:", tostring(savedMacroName))
        end
        
        refreshMacroDropdown()
    end)
