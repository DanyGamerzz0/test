--10
local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
}

local Remotes = {}
do
    local RS = Services.ReplicatedStorage
    Remotes.GameEnd = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.Code = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("Code")
    Remotes.StartGame = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VotePlaying")
    Remotes.Merchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("Merchant")
    Remotes.RaidMerchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("Raid_Shop")
    Remotes.RaidMerchantCSW = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("RaidCSW_Shop")
    Remotes.RiftMerchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("RiftStormExchange")
    Remotes.SwarmMerchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("FallShopExchange")
    Remotes.BossRushMerchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("BossRushExchange")
    Remotes.PlayEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
    Remotes.SettingEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Settings"):WaitForChild("Setting_Event")
    Remotes.RetryEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteRetry")
    Remotes.GameEndedUI = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.UpgradeUnit = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Upgrade")
    Remotes.NextEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteNext")
    Remotes.SelectWay = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("SelectWay")
    Remotes.SellRemote = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Sell")
    Remotes.ApplyCurseRemote = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gambling"):WaitForChild("ApplyCurse")
end

local GameObjects = {
    challengeFolder = Services.ReplicatedStorage:WaitForChild("Gameplay"):WaitForChild("Game"):WaitForChild("Challenge"),
    AFKChamberUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AFKChamber"),
    STAGE_MODULES_FOLDER = Services.ReplicatedStorage.Shared.Info.GameWorld.Levels,
}
GameObjects.GetData = require(Services.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GetData"))
GameObjects.getUnitFolder = GameObjects.GetData.GetUnitFolder
GameObjects.itemsFolder = GameObjects.challengeFolder:WaitForChild("Items")
local GearData = require(Services.ReplicatedStorage.Shared.Info.CraftingRecipes.Gears)

local Config = {
    DISCORD_USER_ID = "",
    chapters = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"},
    difficulties = {"Normal", "Hard", "Nightmare"},
    UPGRADE_COOLDOWN = 0.5,
    maxRetryAttempts = 20,
    unitLevelCaps = {9, 9, 9, 9, 9, 9},
    unitDeployLevelCaps = {0, 0, 0, 0, 0, 0},
    unitReDeployLevel = {9, 9, 9, 9, 9, 9},
    oldbartext = Services.Players.LocalPlayer.PlayerGui.HUD.ExpBar.Numbers.Text,
}

local State = {
    AutoPurchaseRiftStorm = false,
    enableBlackScreen = false,
    enableAutoExecute = false,
    enableAutoSummon = false,
    deleteEntities = false,
    AutoFarmEnabled = false,
    selectedGears = {},
    craftAmounts = {},
    currentlyFarming = false,
    farmingQueue = {},
    playerInventory = {},
    totalMaterialsNeeded = {},
    stageAnalysis = {},
    curseMinimums = {},
    selectedCurseForRequirement = "Ability Damage",
    AutoSummonBannerSelected = nil,
    AutoRerollEnabled = false,
    selectedTraits = {},
    rollOnlyDoubleTraits = false,
    pendingChallengeReturn = false,
    AutoFailSafeEnabled = false,
    autoPlayDelayActive = false,
    AutoPlayDelayNumber = 0,
    AutoFailSafeNumber = 0,
    hasSentWebhook = false,
    portalUsed = false,
    isAutoJoining = false,
    hasNewRewards = false,
    pendingBossTicketReturn = false,
    gameRunning = false,
    hasGameEnded = false,
    retryAttempted = false,
    NextAttempted = false,
    stageStartTime = nil,
    skipCooldownSlots = {},
    lastDeploymentTimes = {},
    startingInventory = {},
    unitNameSet = {},
    selectedPortals = {},
    selectedCurses = {},
    selectedRaidStages = {},
    AutoSellUnitChoice = {},
    AutoDungeonDifficultySelector = "",
    DelayAutoUltimate = 0,
    
    autoBossEventEnabled = false,
    autoInfiniteEnabled = false,
    autoSummerEventEnabled = false,
    SelectedBossEventDifficulty = false,
    autoJoinRaid = false,
    autoJoinEnabled = false,
    autoStartEnabled = false,
    autoRetryEnabled = false,
    autoReturnEnabled = false,
    autoDisableEndUI = false,
    autoNextEnabled = false,
    autoChallengeEnabled = false,
    autoPortalEnabled = false,
    autoClaimBP = false,
    AutoClaimQuests = false,
    AutoClaimMilestones = false,
    AutoPurchaseMerchant = false,
    AutoPurchaseBossRush = false,
    AutoPurchaseRaidCSW = false,
    AutoPurchaseSwarmEvent = false,
    AutoPurchaseRaid = false,
    challengeAutoReturnEnabled = false,
    autoBossAttackEnabled = false,
    autoReturnBossTicketResetEnabled = false,
    autoInfinityCastleEnabled = false,
    autoRiftEnabled = false,
    autoUpgradeEnabled = false,
    autoAfkTeleportEnabled = false,
    AutoUltimateEnabled = false,
    AutoSellRarities = false,
    DisableSummonUI = false,
    streamerModeEnabled = false,
    enableLowPerformanceMode = false,
    SendStageCompletedWebhook = false,
    AntiAfkEnabled = false,
    AntiAfkKickEnabled = false,
    AutoCurseEnabled = false,
    enableDeleteMap = false,
    autoBossRushEnabled = false,
    autoDungeonEnabled = false,
    autoPlayBossRushEnabled = false,
    AutoSelectSpeed = false,
    AutoReDeployEnabled = false,
    SelectedSpeedValue = {},
    bossRushTask = nil,
    currentBossPath = nil,
    BossRushPathSwitcher = 1,
    lastBossRushScan = 0,
    currentBossRushPath = nil,
    SelectedRaritiesToSell = {},
    currentSlot = 1,
    slotLastFailTime = {},
    slotExists = {},
    
    matchResult = "Unknown",
    storedChallengeSerial = nil,
    selectedWorld = nil,
    selectedChapter = nil,
    selectedDifficulty = nil,
    lastBossTicketCount = 0,
    lastBossTicketResetTime = 0,
    infinityCastleTask = nil,
    currentPath = nil,
    upgradeMethod = "Left to right until max",
    upgradeTask = nil,
    ultimateTask = nil,
    currentUpgradeSlot = 1,
    currentRetryAttempt = 0,

    bossRushAutoDeployEnabled = false,
    bossRushDeployConfig = {
    -- Example configuration: [slotNumber] = {paths = {1, 2, 3, 4}, enabled = true}
    [1] = {paths = {1, 4}, enabled = true},
    [2] = {paths = {1, 2}, enabled = true},
    [3] = {paths = {2, 3}, enabled = true},
    [4] = {paths = {3, 4}, enabled = true},
    [5] = {paths = {1, 2, 3, 4}, enabled = false},
    [6] = {paths = {1, 2, 3, 4}, enabled = false}},
    bossRushCurrentSlot = 1,
    bossRushLastDeploymentTimes = {},
}

local Data = {
    selectedRawStages = {},
    MerchantPurchaseTable = {},
    BossRushPurchaseTable = {},
    RaidPurchaseTable = {},
    RaidPurchaseTableCSW = {},
    RiftStormPurchaseTable = {},
    SwarmEventPurchaseTable = {},
    rangerStages = {},
    wantedRewards = {},
    capturedRewards = {},
    availableStories = {},
    availableRangerStages = {},
    availableRaids = {},
    storyData = {},
    raidData = {},
    worldDisplayNameMap = {},
    selectedChallengeWorlds = {},
   -- CurrentCodes = {"SorryRaids","RAIDS","BizzareUpdate2!","Sorry4Delays","BOSSTAKEOVER","Sorry4Quest","SorryDelay!!!","SummerEvent!","2xWeekEnd!","Sorry4EvoUnits","Sorry4AutoTraitRoll","!TYBW","!MattLovesARX2","!RaitoLovesARX","!BrandonTheBest","!FixBossRushShop","SmallFixs"},
}

local autoSummonActive = false
local initialUnits = {}
local summonTask = nil

local script_version = "V0.1"

local ValidWebhook

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Rangers X",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading for Anime Rangers X",
   LoadingSubtitle = script_version,
   ShowText = "LixHub", -- for mobile users to unhide rayfield, change if you'd like
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
}, -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub", -- Create a custom folder for your hub/game
      FileName = "Lixhub_ARX"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "cYKnXE2Nf8", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "LixHub - ARX - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8", -- Use this to tell the user how to get a key
      FileName = "LixHub_Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"0xLIXHUB"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

--//TABS\\--

local LobbyTab = Window:CreateTab("Lobby", "tv")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

--//SECTIONS\\--

--//DIVIDERS\\--

--//LABELS\\--

--//FUNCTIONS\\--

local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
        })
    end

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function enableDeleteMap()
    if isInLobby() then return end
    if State.enableDeleteMap then

    if Services.Workspace:FindFirstChild("Building"):FindFirstChild("Map") then
        Services.Workspace:FindFirstChild("Building"):FindFirstChild("Map"):Destroy()
         Services.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
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
Remotes.SettingEvent:FireServer(unpack({"Abilities VFX", false}))
Remotes.SettingEvent:FireServer(unpack({"Hide Cosmetic", true}))
Remotes.SettingEvent:FireServer(unpack({"Low Graphic Quality", true}))
Remotes.SettingEvent:FireServer(unpack({"HeadBar", false}))
Remotes.SettingEvent:FireServer(unpack({"Display Players Units", false}))
Remotes.SettingEvent:FireServer(unpack({"DisibleGachaChat", true}))
Remotes.SettingEvent:FireServer(unpack({"DisibleDamageText", true}))
Services.Players.LocalPlayer.PlayerGui.HUD.InGame.Main.BOTTOM.Visible = false
Services.Players.LocalPlayer.PlayerGui.Notification.Enabled = false
    else
        Services.Players.LocalPlayer.PlayerGui.HUD.InGame.Main.BOTTOM.Visible = true
        Services.Players.LocalPlayer.PlayerGui.Notification.Enabled = true
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

local function GetAllLevelModules()
    local success, modules = pcall(function()
        local levelsFolder = Services.ReplicatedStorage.Info.GameWorld.Levels
        local levelModules = {}

        for _, moduleScript in pairs(levelsFolder:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local success, moduleData = pcall(function()
                    return require(moduleScript)
                end)

                if success and moduleData then
                    levelModules[moduleScript.Name] = moduleData
                else
                    warn("Failed to require:", moduleScript.Name)
                end
            end
        end

        return levelModules
    end)

    return success and modules or {}
end


local function GetAllGearNames()
    local gearNames = {}
    for gearName, _ in pairs(GearData) do
        table.insert(gearNames, gearName)
    end
    table.sort(gearNames)
    return gearNames
end

local function GetPlayerInventory()
    local success, inventory = pcall(function()
        local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name]
        local items = playerData:FindFirstChild("Items")
        
        if not items then
            return {}
        end
        
        local currentInventory = {}
        for _, item in pairs(items:GetChildren()) do
            if item:IsA("Folder") then
                currentInventory[item.Name] = item.Amount.Value
            end
        end
        return currentInventory
    end)
    return success and inventory or {}
end

local function CalculateTotalMaterialsNeeded()
    local totalNeeded = {}
    
    for gearName, amount in pairs(State.craftAmounts) do
        if amount > 0 and GearData[gearName] then
            local requirements = GearData[gearName].Requirement
            for materialName, requiredAmount in pairs(requirements) do
                totalNeeded[materialName] = (totalNeeded[materialName] or 0) + (requiredAmount * amount)
            end
        end
    end
    
    State.totalMaterialsNeeded = totalNeeded
    return totalNeeded
end

local function FindMaterialSource(materialName)
    local allLevels = GetAllLevelModules()
    local sources = {}

    for moduleName, moduleData in pairs(allLevels) do
        for worldName, worldData in pairs(moduleData) do
            -- worldName = "SAO", worldData = { SAO_Chapter1 = {...}, SAO_RangerStage3 = {...}, ... }
            for chapterName, chapterData in pairs(worldData) do
                if type(chapterData) == "table" and chapterData.Items then
                    for _, itemDrop in pairs(chapterData.Items) do
                        if itemDrop.Name == materialName then
                            table.insert(sources, {
                                module = moduleName,
                                world = worldName,
                                chapter = chapterName,
                                readableName = chapterData.Name or chapterName,
                                dropRate = itemDrop.DropRate,
                                minDrop = itemDrop.MinDrop,
                                maxDrop = itemDrop.MaxDrop,
                                fullPath = string.format(
                                    "%s -> %s",
                                    moduleName,
                                    chapterData.Name or chapterName
                                )
                            })
                        end
                    end
                end
            end
        end
    end

    return sources
end



local function AnalyzeRequiredStages()
    if #State.selectedGears == 0 then
        notify("Stage Analysis", "No gears selected!")
        return
    end
    
    print("=== STAGE ANALYSIS FOR SELECTED GEARS ===")
    
    -- Calculate total materials needed
    local totalNeeded = CalculateTotalMaterialsNeeded()
    local inventory = GetPlayerInventory()
    
    -- Track all stages we need to play
    local stagesToPlay = {}
    local materialSources = {}
    
    print("\nMaterials needed:")
    for materialName, needed in pairs(totalNeeded) do
        local current = inventory[materialName] or 0
        local deficit = math.max(0, needed - current)
        
        print(string.format("  %s: %d needed, %d current, %d deficit", 
            materialName, needed, current, deficit))
        
        if deficit > 0 then
            -- Find all sources for this material
            local sources = FindMaterialSource(materialName)
            
            if #sources > 0 then
                materialSources[materialName] = sources
                print(string.format("    Sources found for %s:", materialName))
                
                for i, source in ipairs(sources) do
                    local avgDrop = (source.minDrop + source.maxDrop) / 2
                    local dropChance = source.dropRate / 100
                    local expectedPerRun = avgDrop * dropChance
                    local estimatedRuns = math.ceil(deficit / expectedPerRun)
                    
                    print(string.format("      %d. %s (%.1f%% drop, avg %.1f per drop, ~%d runs needed)", 
                        i, source.fullPath, source.dropRate, avgDrop, estimatedRuns))
                    
                    -- Add to stages we need to play
                    local stageKey = source.fullPath
                    if not stagesToPlay[stageKey] then
                        stagesToPlay[stageKey] = {
                            module = source.module,
                            world = source.world,
                            chapter = source.chapter,
                            materials = {},
                            totalEstimatedRuns = 0
                        }
                    end
                    
                    stagesToPlay[stageKey].materials[materialName] = {
                        needed = deficit,
                        estimatedRuns = estimatedRuns,
                        dropRate = source.dropRate,
                        avgDrop = avgDrop
                    }
                    
                    -- Use the highest estimated runs for this stage
                    stagesToPlay[stageKey].totalEstimatedRuns = math.max(
                        stagesToPlay[stageKey].totalEstimatedRuns, 
                        estimatedRuns
                    )
                end
            else
                print(string.format("    ⚠️  No sources found for %s!", materialName))
            end
        else
            print(string.format("    ✅ %s - Already have enough!", materialName))
        end
    end
    
    print("\n=== STAGES TO PLAY ===")
    if next(stagesToPlay) == nil then
        print("No stages need to be played! You have all required materials.")
    else
        local stageList = {}
        for stageName, stageInfo in pairs(stagesToPlay) do
            table.insert(stageList, {
                name = stageName,
                info = stageInfo
            })
        end
        
        -- Sort by estimated runs (most efficient first)
        table.sort(stageList, function(a, b)
            return a.info.totalEstimatedRuns < b.info.totalEstimatedRuns
        end)
        
        for i, stage in ipairs(stageList) do
            print(string.format("%d. %s (~%d runs)", 
                i, stage.name, stage.info.totalEstimatedRuns))
            
            for materialName, matInfo in pairs(stage.info.materials) do
                print(string.format("    - %s: need %d (%.1f%% drop, ~%d runs)", 
                    materialName, matInfo.needed, matInfo.dropRate, matInfo.estimatedRuns))
            end
        end
        
        -- Summary
        print(string.format("\nSUMMARY: Need to play %d different stages", #stageList))
        
        -- Show gear breakdown
        print("\nGEAR BREAKDOWN:")
        for _, gearName in ipairs(State.selectedGears) do
            local amount = State.craftAmounts[gearName] or 1
            if amount > 0 then
                print(string.format("  %s x%d:", gearName, amount))
                local requirements = GearData[gearName].Requirement
                for materialName, requiredPerCraft in pairs(requirements) do
                    local totalRequired = requiredPerCraft * amount
                    print(string.format("    - %s: %d (%d per craft)", 
                        materialName, totalRequired, requiredPerCraft))
                end
            end
        end
    end
    
    print("=== END STAGE ANALYSIS ===\n")
    
    -- Store the analysis for later use
    State.stageAnalysis = {
        stagesToPlay = stagesToPlay,
        materialSources = materialSources,
        totalMaterialsNeeded = totalNeeded
    }
    
    -- Notify user
    local stageCount = 0
    for _ in pairs(stagesToPlay) do
        stageCount = stageCount + 1
    end
    
    notify("Stage Analysis", string.format("Analysis complete! Need to play %d stages. Check console for details.", stageCount))
end

local function HasEnoughMaterials(gearName, amount)
    amount = amount or 1
    local requirements = GearData[gearName].Requirement
    local inventory = GetPlayerInventory()
    
    for materialName, requiredAmount in pairs(requirements) do
        local needed = requiredAmount * amount
        local current = inventory[materialName] or 0
        if current < needed then
            return false, materialName, needed - current
        end
    end
    
    return true
end

local function FarmMaterial(materialName, neededAmount)
    -- This will be implemented later with actual joining logic
    notify("Auto Gear Farm", string.format("Farming %d %s - Logic to be implemented", neededAmount, materialName))
    return true -- Placeholder
end

local function CraftGear(gearName, amount)
    amount = amount or 1
    
    local success = pcall(function()
        -- Replace with your actual crafting remote
        for i = 1, amount do
            Remotes.CraftGearRemote:FireServer(gearName)
            task.wait(0.5) -- Small delay between crafts
        end
    end)
    
    if success then
        notify("Auto Gear Farm", string.format("Successfully crafted %dx %s", amount, gearName))
        return true
    else
        notify("Auto Gear Farm", string.format("Failed to craft %s", gearName))
        return false
    end
end

local function StartAutoFarmGear()
    if not isInLobby() then
        notify("Auto Gear Farm", "Must be in lobby to use auto gear farm!")
        return
    end
    
    if #State.selectedGears == 0 then
        notify("Auto Gear Farm", "Please select at least 1 gear to farm!")
        return
    end
    
    State.currentlyFarming = true
    
    task.spawn(function()
        notify("Auto Gear Farm", "Starting gear farming process...")
        
        -- Calculate total materials needed
        local totalNeeded = CalculateTotalMaterialsNeeded()
        local inventory = GetPlayerInventory()
        
        -- Run stage analysis instead of old material farming
        AnalyzeRequiredStages()
        
        -- For now, we'll skip the actual farming and go straight to crafting
        -- (farming logic will be implemented later)
        notify("Auto Gear Farm", "Skipping farming for now - check console for stage analysis")
        
        -- Craft the gears (if we have materials)
        if State.AutoFarmEnabled then
            notify("Auto Gear Farm", "Starting crafting phase...")
            
            for gearName, amount in pairs(State.craftAmounts) do
                if not State.AutoFarmEnabled then break end
                
                if amount > 0 then
                    local hasEnough, missingMaterial, missingAmount = HasEnoughMaterials(gearName, amount)
                    
                    if hasEnough then
                        notify("Auto Gear Farm", string.format("Crafting %dx %s...", amount, gearName))
                        CraftGear(gearName, amount)
                    else
                        notify("Auto Gear Farm", string.format("Still missing %d %s for %s", 
                            missingAmount, missingMaterial, gearName))
                    end
                end
            end
        end
        
        State.currentlyFarming = false
        notify("Auto Gear Farm", "Gear farming completed!")
    end)
end

local function FarmMaterial(materialName, neededAmount)
    local source = FindMaterialSource(materialName)
    if not source then
        notify("Auto Gear Farm", string.format("No source found for material: %s", materialName))
        return false
    end
    
    notify("Auto Gear Farm", string.format("Farming %d %s from %s %s", neededAmount, materialName, source.world, source.chapter))
    
    -- Calculate estimated runs needed based on drop rate and average drop
    local avgDrop = (source.minDrop + source.maxDrop) / 2
    local dropChance = source.dropRate / 100
    local expectedPerRun = avgDrop * dropChance
    local estimatedRuns = math.ceil(neededAmount / expectedPerRun)
    
    print(string.format("Estimated runs needed: %d (%.1f%% drop rate, avg %.1f per drop)", 
        estimatedRuns, source.dropRate, avgDrop))
    
    -- Farm the material (you'll need to implement the actual farming logic)
    local success = pcall(function()
        -- Replace with your actual remote calls for starting a chapter
        Remotes.StartChapterRemote:FireServer(source.world, source.chapter)
        -- or however your game handles chapter farming
    end)
    
    return success
end

local function fetchStoryData()
    Data.storyData = {}   

        for _, moduleScript in ipairs(Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("World"):GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local success, data = pcall(function()
                    return require(moduleScript)
                end)

                if success and typeof(data) == "table" then
                    for key, storyTable in pairs(data) do
                        if typeof(storyTable) == "table" and storyTable.StoryAble == true then
                            if storyTable.Name and storyTable.Ani_Names then
                                table.insert(Data.storyData, {
                                    SeriesName = storyTable.Name,
                                    InternalName = storyTable.Ani_Names,
                                    ModuleName = moduleScript.Name,
                                    Key = key
                                })

                            end
                        end
                    end
                else
                    print("Error loading " .. moduleScript.Name)
                end
            end
        end
        
        return Data.storyData
    end

local function fetchRaidData()
    Data.raidData = {}

    for _, moduleScript in ipairs(Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("World"):GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for key, raidTable in pairs(data) do
                    if typeof(raidTable) == "table" and raidTable.IsRaid == true then
                        if raidTable.Name and raidTable.Levels then

                            -- Build both display names and ID map
                            local displayStages = {}
                            local internalMap = {} -- displayName -> real ID

                            for index, stage in ipairs(raidTable.Levels) do
                                if stage.id then
                                    local displayName = string.format("%s - Chapter %d", raidTable.Name, index)
                                    table.insert(displayStages, displayName)
                                    internalMap[displayName] = stage.id
                                end
                            end

                            table.insert(Data.raidData, {
                                SeriesName = raidTable.Name,
                                DisplayStages = displayStages, -- For dropdown
                                InternalStages = internalMap,  -- For ID lookup
                                ModuleName = moduleScript.Name,
                                Key = key
                            })
                        end
                    end
                end
            else
                print("Error loading " .. moduleScript.Name)
            end
        end
    end
    return Data.raidData
end

local function fetchRangerStageData(storyData)

    local worldPriority = {
        ["OnePiece"] = 1,
        ["Namek"] = 2,
        ["DemonSlayer"] = 3,
        ["Naruto"] = 4,
        ["OPM"] = 5,
        ["TokyoGhoul"] = 6,
        ["JojoPart1"] = 7,
        ["SoulSociety"] = 8,
    }

    local worldDisplayNames = {}
    for _, story in ipairs(storyData) do
        worldDisplayNames[story.ModuleName] = story.SeriesName
    end

    local worldStages = {}

    for _, moduleScript in ipairs(Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("Levels"):GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for seriesName, chapters in pairs(data) do
                    if typeof(chapters) == "table" then
                        for chapterKey, chapterData in pairs(chapters) do
                            if typeof(chapterData) == "table" and chapterData.Wave then
                                if string.find(chapterData.Wave, "RangerStage") then
                                    local worldName = chapterData.World or "UnknownWorld"
                                    worldStages[worldName] = worldStages[worldName] or {}
                                    local displayWorldName = worldDisplayNames[worldName] or worldName

                                    table.insert(worldStages[worldName], {
                                        Series = seriesName,
                                        Chapter = chapterKey,
                                        Wave = chapterData.Wave,
                                        LayoutOrder = chapterData.LayoutOrder or math.huge,
                                        DisplayName = displayWorldName .. " - " .. (chapterData.Wave:match("RangerStage(%d+)") or chapterData.Wave)
                                    })
                                end
                            end
                        end
                    end
                end
            else
                warn("Error loading module: " .. moduleScript.Name)
            end
        end
    end

    local worldOrder = {}
    local rangerStages = {}

    for worldName, stages in pairs(worldStages) do
        table.sort(stages, function(a, b)
            return a.LayoutOrder < b.LayoutOrder
        end)

        local priority = worldPriority[worldName] or 1e6
        table.insert(worldOrder, {World = worldName, Priority = priority, Stages = stages})
    end

    table.sort(worldOrder, function(a, b)
        return a.Priority < b.Priority
    end)

    for _, worldInfo in ipairs(worldOrder) do
        local worldName = worldInfo.World
        for _, stage in ipairs(worldInfo.Stages) do
            table.insert(rangerStages, {
                RawName = stage.Wave,
                DisplayName = stage.DisplayName,
                World = worldName,
                Series = stage.Series,
                Chapter = stage.Chapter,
                LayoutOrder = stage.LayoutOrder
            })
        end
    end

    return rangerStages
end

local function snapshotInventory()
    local snapshot = {}
    State.unitNameSet = {}

    snapshot.Gold = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gold.Value
    snapshot.Gem = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gem.Value
    snapshot["Beach Balls"] = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data["Beach Balls"].Value

    local itemInventory = Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items"):WaitForChild("Main"):WaitForChild("Base"):WaitForChild("Space"):WaitForChild("Scrolling")
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items").Enabled = true
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items").Main.Visible = false
    task.wait(1)
     Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items").Enabled = false
     Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items").Main.Visible = true
    local unitInventory = Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection"):WaitForChild("Main"):WaitForChild("Base"):WaitForChild("Space"):WaitForChild("Unit")
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection").Enabled = true
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection").Main.Visible = false
    task.wait(1)
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection").Enabled = false
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection").Main.Visible = true

    for _, item in pairs(itemInventory:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            local text = item:WaitForChild("Frame"):WaitForChild("ItemFrame"):WaitForChild("Info"):WaitForChild("Amonut").Text
            local formattedtext = text:gsub("%D", "")
            snapshot[item.Name] = tonumber(formattedtext)
        end
    end

    local unitCounts = {}
    for _, unit in pairs(unitInventory:GetChildren()) do
        if unit:IsA("TextButton") or unit:IsA("ImageButton") then
            unitCounts[unit.Name] = (unitCounts[unit.Name] or 0) + 1
            State.unitNameSet[unit.Name] = true
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

local function patchRewardsFromFolder(existingGained, detectedRewards, detectedUnits, lines)
    local rewardFolder = Services.Players.LocalPlayer:FindFirstChild("RewardsShow")
    if not rewardFolder then return end

    for _, rewardEntry in pairs(rewardFolder:GetChildren()) do
        if not detectedRewards[rewardEntry.Name] and rewardEntry:FindFirstChild("Amount") then
            local amount = rewardEntry.Amount.Value

            if amount > 0 then
                detectedRewards[rewardEntry.Name] = amount
                table.insert(existingGained, { name = rewardEntry.Name, amount = amount, isUnit = false })

                local totalText = ""

                if rewardEntry.Name == "Gem" or rewardEntry.Name == "Gold" or rewardEntry.Name == "Beach Balls" or rewardEntry.Name == "BossRushCurrency" or rewardEntry.Name == "Fall Currency" then
                    local dataValue = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data:FindFirstChild(rewardEntry.Name)
                    totalText = dataValue and string.format(" [%d total]", dataValue.Value) or ""
                else
                    local item = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(rewardEntry.Name)
                    local itemAmount = item and item:FindFirstChild("Amount")
                    totalText = itemAmount and string.format(" [%d total]", itemAmount.Value) or ""
                end

                table.insert(lines, string.format("+ %s %s%s", amount, rewardEntry.Name, totalText))
            end
        end
    end
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

        detectedRewards[itemName] = amount

        local totalText = ""
        if reward.isUnit then
            table.insert(detectedUnits, itemName)
            totalText = ""
            table.insert(lines, string.format("🌟 %s x%d", itemName, amount))
        elseif itemName == "Gem" then
            totalText = string.format(" [%d total]", Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gem.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName.."(s)", totalText))
        elseif itemName == "Gold" then
            totalText = string.format(" [%d total]", Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gold.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Beach Balls" then
            totalText = string.format(" [%d total]", Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data["Beach Balls"].Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Fall Currency" then
            totalText = string.format(" [%d total]", Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data["Fall Currency"].Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        else
            local itemObj = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(itemName)
            local totalAmount = itemObj and itemObj:FindFirstChild("Amount") and itemObj.Amount.Value or nil
            totalText = totalAmount and string.format(" [%d total]", totalAmount) or ""
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        end
    end

    patchRewardsFromFolder(gainedItems, detectedRewards, detectedUnits, lines)

    if #gainedItems == 0 then
        return "_No rewards found after match_", {}, {}
    end

    local rewardsText = table.concat(lines, "\n")
    notify("Gained rewards:", rewardsText, 2)
    return rewardsText, detectedRewards, detectedUnits
end

local function getUnitNameFromSlot(slotNumber)
    local success, unitInstance = pcall(function()
        return Services.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
end)

    if success and unitInstance then
        return typeof(unitInstance) == "Instance" and unitInstance.Name or tostring(unitInstance)
    end

    return nil
end

local function getOrderedUnits()
    local units = {}
    for i = 1, 6 do
        local name = getUnitNameFromSlot(i)
        if name then
            table.insert(units, string.format("%d️⃣ - %s", i, name))
        else
            table.insert(units, string.format("%d️⃣ Empty", i))
        end
    end
    return table.concat(units, "\n")
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
        local RewardsUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("InGame"):WaitForChild("Main"):WaitForChild("GameInfo")
        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stage") and RewardsUI.Stage.Label.Text or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Gamemode") and RewardsUI.Gamemode.Label.Text or "Unknown Time"
        local isWin = matchResult == "Victory"
        local plrlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value or ""

        local rewardsText, detectedRewards, detectedUnits = buildRewardsText()
        local shouldPing = #detectedUnits > 0

        if #detectedUnits > 1 then return end

        local pingText = shouldPing and string.format("<@%s> 🎉 **SECRET UNIT OBTAINED!** 🎉", Config.DISCORD_USER_ID) or ""

        local stageResult = stageName .. " (" .. gameMode .. ")" .. " - " .. matchResult
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        local orderedUnits = getOrderedUnits()

        data = {
            username = "LixHub Bot",
            content = shouldPing and pingText or nil,
            embeds = {{
                title = shouldPing and "🌟 UNIT DROP! 🌟" or "🎯 Stage Finished!",
                description = shouldPing and (pingText .. "\n" .. stageResult) or stageResult,
                color = shouldPing and 0xFFD700 or (isWin and 0x57F287 or 0xED4245),
                fields = {
                    { name = "👤 Player", value = "||" .. Services.Players.LocalPlayer.Name .. " [" .. plrlevel .. "]||", inline = true },
                    { name = isWin and "✅ Won in:" or "❌ Lost after:", value = clearTime, inline = true },
                    { name = "🏆 Rewards", value = rewardsText, inline = false },
                    { name = "📦 Units Loadout", value = orderedUnits, inline = false },
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

--boss rush

local function getBossRushWaypoints(pathNum)
    local pathFolder = Services.Workspace.WayPoint:FindFirstChild("P" .. pathNum)
    return pathFolder and pathFolder:GetChildren() or {}
end

local function scanBossRushPaths()
    local pathData = {
        [1] = {enemies = 0, units = 0},
        [2] = {enemies = 0, units = 0},
        [3] = {enemies = 0, units = 0},
        [4] = {enemies = 0, units = 0}
    }
    
    -- Scan enemies
    for _, enemy in pairs(Services.Workspace.Agent.EnemyT:GetChildren()) do
        if enemy:IsA("Part") then
            local closestPath = nil
            local closestDist = math.huge
            
            for pathNum = 1, 4 do
                for _, waypoint in pairs(getBossRushWaypoints(pathNum)) do
                    local dist = (enemy.Position - waypoint.Position).Magnitude
                    if dist < closestDist and dist < 25 then
                        closestDist = dist
                        closestPath = pathNum
                    end
                end
            end
            
            if closestPath then
                pathData[closestPath].enemies = pathData[closestPath].enemies + 1
            end
        end
    end
    
    -- Scan player units
    for _, unit in pairs(Services.Workspace.Agent.UnitT:GetChildren()) do
        if unit:IsA("Part") then
            local closestPath = nil
            local closestDist = math.huge
            
            for pathNum = 1, 4 do
                for _, waypoint in pairs(getBossRushWaypoints(pathNum)) do
                    local dist = (unit.Position - waypoint.Position).Magnitude
                    if dist < closestDist and dist < 25 then
                        closestDist = dist
                        closestPath = pathNum
                    end
                end
            end
            
            if closestPath then
                pathData[closestPath].units = pathData[closestPath].units + 1
            end
        end
    end
    
    return pathData
end

local function getAvailablePaths()
    local phase = Services.ReplicatedStorage:WaitForChild("Values"):WaitForChild("Game"):WaitForChild("BossRush"):WaitForChild("Fase").Value
    
    if phase == 1 then
        return {1}
    elseif phase == 2 or phase == 3 then
        return {1, 2}
    elseif phase == 4 or phase == 5 or phase == 6 then
        return {1, 2, 3}
    else -- phase 7+
        return {1, 2, 3, 4}
    end
end

local function getBestBossRushPath(pathData)
    local availablePaths = getAvailablePaths()
    local bestPath = State.currentBossPath or 1
    local bestScore = -1
    
    -- Check if current path has too many units (force switch)
    local currentPathData = pathData[State.currentBossPath or 1]
    local unitCap = 4 -- Adjust this number based on your preference
    
    for _, pathNum in pairs(availablePaths) do
        local data = pathData[pathNum]
        local score = data.enemies * 10 - data.units * 3
        
        -- Bonus for having fewer units when current path is overcrowded
        if currentPathData.units >= unitCap then
            score = score + (unitCap - data.units) * 5 -- Bonus for paths with fewer units
        end
        
        -- Only switch if significantly better (reduces path thrashing)
        local threshold = (pathNum == State.currentBossPath) and 0 or 5
        
        -- Force switch if current path is overcrowded
        if currentPathData.units >= unitCap and data.units < currentPathData.units then
            threshold = -10 -- Make it easier to switch away from overcrowded paths
        end
        
        if score > bestScore + threshold then
            bestScore = score
            bestPath = pathNum
        end
    end
    
    return bestPath, pathData[bestPath].enemies, pathData[bestPath].units
end

local function countPartsOnPath(folder, pathFolder)
    local count = 0
    for _, part in ipairs(folder:GetChildren()) do
        if part:IsA("BasePart") and part:FindFirstChildOfClass("Humanoid") then
            local distToStart = (part.Position - pathFolder["1"].Position).Magnitude
            local distToEnd = (part.Position - pathFolder["2"].Position).Magnitude
            local totalDist = (pathFolder["1"].Position - pathFolder["2"].Position).Magnitude
            if distToStart + distToEnd <= totalDist + 15 then
                count = count + 1
            end
        end
    end
    return count
end

local function getBestPath()
    local bestPath, lowestUnits = nil, math.huge
    for i = 1, 3 do
        local pathName = "P" .. i
        local pathFolder = Services.Workspace:WaitForChild("WayPoint"):FindFirstChild(pathName)
        if pathFolder then
            local unitCount = countPartsOnPath(Services.Workspace.Agent.UnitT, pathFolder)
            local enemyCount = countPartsOnPath(Services.Workspace.Agent.EnemyT, pathFolder)
            if enemyCount > 0 and unitCount < lowestUnits then
                lowestUnits = unitCount
                bestPath = i
            end
        end
    end
    return bestPath
end

local function startInfinityCastleLogic()
    if State.infinityCastleTask then task.cancel(State.infinityCastleTask) end
    State.infinityCastleTask = task.spawn(function()
        while State.autoInfinityCastleEnabled do
            local success, error = pcall(function()
                local bestPath = getBestPath()
                if bestPath and bestPath ~= State.currentPath then
                    notify("🚀 Switching to path: ", bestPath)
                    State.currentPath = bestPath
                    Remotes.SelectWay:FireServer(bestPath)
                else

                end
            end)
            if not success then warn("❌ Infinity Castle error:", error) end
            task.wait(2.5)
        end
    end)
end

local function stopInfinityCastleLogic()
    if State.infinityCastleTask then
        task.cancel(State.infinityCastleTask)
        State.infinityCastleTask = nil
    end
    State.currentPath = nil
end

local function isWantedChallengeRewardPresent()
    for _, reward in ipairs(Data.wantedRewards) do
        local value = GameObjects.itemsFolder:FindFirstChild(reward)
        if value and value:IsA("BoolValue") then
            return true, reward
        end
    end
    return false, nil
end

local function getPlayerCurrency()
    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data
    if not playerData then return {} end

    local currencies = {}

    local GoldValue = playerData:FindFirstChild("Gold")
    if GoldValue then currencies["Gold"] = GoldValue.Value end

    local gemsValue = playerData:FindFirstChild("Gem")
    if gemsValue then currencies["Gem"] = gemsValue.Value end

    local raidValue = playerData:FindFirstChild("Raid Currency")
    if raidValue then currencies["Raid Currency"] = raidValue.Value end

    local bossrushValue = playerData:FindFirstChild("BossRushCurrency")
    if bossrushValue then currencies["BossRushCurrency"] = bossrushValue.Value end

    local raidCSMValue = playerData:FindFirstChild("CSW Raid Currency")
    if raidCSMValue then currencies["CSW Raid Currency"] = raidCSMValue.Value end

    local riftStormValue = playerData:FindFirstChild("RiftStormCurrency")
    if riftStormValue then currencies["RiftStormCurrency"] = riftStormValue.Value end

    local SwarmEventValue = playerData:FindFirstChild("Fall Currency")
    if SwarmEventValue then currencies["Fall Currency"] = SwarmEventValue.Value end

    return currencies
end

local function canAffordItem(itemFolder)
    local priceValue = itemFolder:FindFirstChild("CurrencyAmount")
    local currencyTypeValue = itemFolder:FindFirstChild("CurrencyType")
    if not priceValue or not currencyTypeValue then return false end

    local playerCurrencies = getPlayerCurrency()

    return playerCurrencies[currencyTypeValue.Value] and playerCurrencies[currencyTypeValue.Value] >= priceValue.Value
end

local function purchaseItem(itemName, quantity, folderName)
    quantity = quantity or 1
    pcall(function()
        if folderName == "Merchant" then
            Remotes.Merchant:FireServer(itemName, quantity)
        end
        if folderName == "Boss_Rush" then
            Remotes.BossRushMerchant:FireServer(itemName, quantity)
        end
        if folderName == "Raid_Shop" then
            Remotes.RaidMerchant:FireServer(itemName, quantity)
        end
        if folderName == "RaidCSW_Shop" then
            Remotes.RaidMerchantCSW:FireServer(itemName, quantity)
        end
        if folderName == "Rift_Storm" then
            Remotes.RiftMerchant:FireServer(itemName, quantity)
        end
        if folderName == "Fall_Shop" then
            Remotes.SwarmMerchant:FireServer(itemName, quantity)
        end
    end)
end

local didNotify = false

local function autoPurchaseItems(isEnabled, purchaseTable, folderName, shopDisplayName)
    if not isEnabled then return end
    if not purchaseTable or #purchaseTable == 0 then return end

    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name]
    if not playerData then return end

    local shopFolder = playerData:FindFirstChild(folderName)
    if not shopFolder then return end

    for _, selectedItem in pairs(purchaseTable) do
        local itemFolder = shopFolder:FindFirstChild(selectedItem)
        if itemFolder then
            if canAffordItem(itemFolder) then
                local availableQuantity = itemFolder:FindFirstChild("Quantity") and itemFolder:FindFirstChild("Quantity").Value or 1
                local currentQuantity = itemFolder:FindFirstChild("BuyAmount") and itemFolder:FindFirstChild("BuyAmount").Value or 0

                if currentQuantity <= 0 then
                    purchaseItem(selectedItem, availableQuantity, folderName)
                    notify("Auto Purchase " .. shopDisplayName, "Purchased: " ..selectedItem)
                    task.wait(0.5)
                end
            else
                if didNotify == false then
                    didNotify = true
                    notify("Auto Purchase " .. shopDisplayName, "Can't afford: " .. selectedItem)
                    task.delay(20, function()
                        didNotify = false
                    end)
                end
            end
        end
    end
end

local function autoJoinRangerStage(stageName)
    if not isInLobby() then 
        print("❌ Not in lobby, cannot join ranger stage")
        return 
    end

    print("🚀 Joining ranger stage:", stageName)

    -- 1. Create
    Remotes.PlayEvent:FireServer("Create")
    task.wait(0.3)

    -- 2. Change-Mode
    Remotes.PlayEvent:FireServer("Change-Mode", { Mode = "Ranger Stage" })
    task.wait(0.3)

    -- 3. Extract world from stage name (e.g., "Naruto_RangerStage2" → "Naruto")
    local world = stageName:match("^(.-)_RangerStage")
    if not world then
        warn("❌ Couldn't extract world from:", stageName)
        return
    end

    -- 4. Change-World
    Remotes.PlayEvent:FireServer("Change-World", { World = world })
    task.wait(0.3)

    -- 5. Change-Chapter
    Remotes.PlayEvent:FireServer("Change-Chapter", { Chapter = stageName })
    task.wait(0.3)

    -- 6. Submit
    Remotes.PlayEvent:FireServer("Submit")
    task.wait(0.3)

    -- 7. Start
    Remotes.PlayEvent:FireServer("Start")

    print("✅ Ranger stage join sequence completed for:", stageName)
end

local autoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2 
}

local function canPerformAction()
    return tick() - autoJoinState.lastActionTime >= autoJoinState.actionCooldown
end

local function setProcessingState(action)
    autoJoinState.isProcessing = true
    autoJoinState.currentAction = action
    autoJoinState.lastActionTime = tick()

    if action == "Ranger Stage Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Challenge Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Portal Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Story Auto Join" then
        notify("🔄 Processing: ", string.format(
            "Joining %s - %s [%s]",
            State.selectedWorld or "?",
            State.selectedChapter or "?",
            State.selectedDifficulty or "?"
        ))
        elseif action == "Boss Event Auto Join" then
           notify("🔄 Processing: ", action)
        elseif action == "Infinite Mode Auto Join" then
           notify("🔄 Processing: ", action)
        elseif action == "Summer Event Auto Join" then
           notify("🔄 Processing: ", action)

           elseif action == "Boss Rush Auto Join" then
            notify("🔄 Processing: ", action)
            elseif action == "Infinity Castle Auto Join" then
            notify("🔄 Processing: ", action)
            elseif action == "Dungeon Auto Join" then
            notify("🔄 Processing: ", action)
            elseif action == "Rift Auto Join" then
            notify("🔄 Processing: ", action)
    end
end

local function clearProcessingState()
    autoJoinState.isProcessing = false
    autoJoinState.currentAction = nil
end

local function getBossAttackTickets()
    local success, tickets = pcall(function()
        return Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackTicket.Value
    end)
    return success and tickets or 0
end

local function getBossTicketResetTime()
    local success, resetTime = pcall(function()
        return Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackReset.Value
    end)
    return success and resetTime or 0
end

local function getInternalWorldName(displayName)
    for _, story in ipairs(Data.availableStories) do
        if story.SeriesName == displayName then
            return story.ModuleName
        end
    end
    return nil
end

local function equipTeamSlot(teamSlot)
    if not teamSlot or teamSlot < 1 or teamSlot > 5 then
        warn("Invalid team slot:", teamSlot)
        return false
    end
    
    local success = pcall(function()
        local args = {
            "Equip",
            "Slot" .. teamSlot
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Teams"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    end)
    
    if success then
        print("✅ Equipped team slot:", teamSlot)
        return true
    else
        warn("❌ Failed to equip team slot:", teamSlot)
        return false
    end
end

local function getTeamSlotForMode(mode)
    if not State.autoTeamSlotPicker then return nil end -- Feature disabled
    
    -- Check which team slot should be used for this mode
    if State.modeTeamSelector1 and table.find(State.modeTeamSelector1, mode) then
        return 1
    elseif State.modeTeamSelector2 and table.find(State.modeTeamSelector2, mode) then
        return 2
    elseif State.modeTeamSelector3 and table.find(State.modeTeamSelector3, mode) then
        return 3
    elseif State.modeTeamSelector4 and table.find(State.modeTeamSelector4, mode) then
        return 4
    elseif State.modeTeamSelector5 and table.find(State.modeTeamSelector5, mode) then
        return 5
    end
    
    return nil
end

local function handleTeamEquipping(mode)
    local teamSlot = getTeamSlotForMode(mode)
    if teamSlot then
        print("🔄 Equipping team slot", teamSlot, "for mode:", mode)
        equipTeamSlot(teamSlot)
        task.wait(0.5) -- Small delay to ensure team is equipped
    end
end

local function getHighestNumberFromNames(parent)
    local highestNumber = -math.huge -- Start with the smallest possible number

    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("StringValue") then
            local num = tonumber(obj.Name)
            if num and num > highestNumber then
                highestNumber = num
            end
        end
    end

    if highestNumber == -math.huge then
        return nil -- No numeric names found
    end

    return highestNumber
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if autoJoinState.isProcessing then return end
    if not canPerformAction() then return end

    -- Priority 1: Challenge Auto Join
    if State.autoChallengeEnabled then
        local skipChallenge = false
        if #Data.selectedChallengeWorlds > 0 then
             local ignoredInternalNames = {}
    for _, displayName in pairs(Data.selectedChallengeWorlds) do
        local internalName = getInternalWorldName(displayName)
        if internalName then
            table.insert(ignoredInternalNames, internalName)
        end
    end

    -- Check if the current challenge world is in the ignored list
    for _, ignoredInternal in pairs(ignoredInternalNames) do
        if ignoredInternal == Services.ReplicatedStorage.Gameplay.Game.Challenge.World.Value then
            skipChallenge = true
            break
        end
    end
        end
        if not skipChallenge then
        local foundRewardOK, foundReward = isWantedChallengeRewardPresent()
        if foundRewardOK then
            setProcessingState("Challenge Auto Join")
            print("🎯 Found wanted reward '" .. foundReward .. "' → creating challenge room")

            handleTeamEquipping("Challenge")

            notify("Challenge Mode", string.format("Found %s, joining challenge...", foundReward))
            Remotes.PlayEvent:FireServer("Create", { CreateChallengeRoom = true })
            Remotes.PlayEvent:FireServer("Start")
            task.delay(5, clearProcessingState)
            return
        end
        end
    end

     -- Priority 2: Portal Auto Join
    if State.autoPortalEnabled and not State.portalUsed and State.selectedPortals and #State.selectedPortals > 0 then
        local success, result = pcall(function()
            local inventoryFrame = Services.Players.LocalPlayer:FindFirstChild("PlayerGui").Items.Main.Base.Space:FindFirstChild("Scrolling")
            if not inventoryFrame then return nil end
            for _, item in ipairs(inventoryFrame:GetChildren()) do
                if item.Name:lower():find("portal") and table.find(State.selectedPortals, item.Name) then
                return item.Name
                end
            end
    end)

        if success and result then
            setProcessingState("Portal Auto Join")

            local portalInstance = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(result)
            if portalInstance then

                handleTeamEquipping("Portal")

                Services.ReplicatedStorage.Remote.Server.Lobby.ItemUse:FireServer(portalInstance)
                State.portalUsed = true
                notify("Portal Joiner", "Using portal: " .. result)

                task.wait(1)

                print("▶️ Starting portal match...")
                Services.ReplicatedStorage.Remote.Server.Lobby.PortalEvent:FireServer("Start")

                task.delay(5, clearProcessingState)
                return
            else
                 notify("Portal Joiner", "Portal not found: " .. result)
                clearProcessingState()
                State.portalUsed = false
            end
        end
    end

    if State.autoBossRushEnabled then
        setProcessingState("Boss Rush Auto Join")

        handleTeamEquipping("Boss Rush")

        Remotes.PlayEvent:FireServer("BossRush")
        task.wait(1)
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Start")
        task.delay(5, clearProcessingState)
        return
    end

    if State.autoJoinRaid then
        if State.selectedRaidStages and #State.selectedRaidStages > 0 then
            setProcessingState("Raid Auto Join")

             handleTeamEquipping("Raid")

             local fullName = tostring(State.selectedRaidStages[1])
             local mapName = string.match(fullName, "^(.-)_")
             print(mapName)  -- Output: TheGraveyard


            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Create")
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Change-Mode",{Mode = "Raids Stage"})
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Change-World",{World = mapName})
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Change-Chapter",{Chapter = State.selectedRaidStages[1]})
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Submit")
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Start")
            task.delay(5, clearProcessingState)
            return
        end
    end

    -- priority 3: boss event auto join
    if State.autoSummerEventEnabled then
    setProcessingState("Summer Event Auto Join")

        handleTeamEquipping("Summer Event")

    Remotes.PlayEvent:FireServer("Summer-Event")
    task.delay(5, clearProcessingState)
        return
    end

    if State.autoBossEventEnabled then
    setProcessingState("Boss Event Auto Join")

        handleTeamEquipping("Boss Event")

    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Swarm Event")
    task.delay(5, clearProcessingState)
        return
    end

    -- Priority 4: Ranger Stage Auto Join
    if State.isAutoJoining and Data.selectedRawStages and #Data.selectedRawStages > 0 then
        local selectedStageSet = {}
        for _, raw in ipairs(Data.selectedRawStages) do
            selectedStageSet[raw] = true
        end

        local prioritizedStageList = {}
        for _, stage in ipairs(Data.availableRangerStages) do
            if selectedStageSet[stage.RawName] then
                table.insert(prioritizedStageList, stage.RawName)
            end
        end

        if #prioritizedStageList > 0 then
            local stageName = prioritizedStageList[1]
            setProcessingState("Ranger Stage Auto Join")

            handleTeamEquipping("Ranger")

            print("🌍 Attempting to join Ranger Stage:", stageName)
            autoJoinRangerStage(stageName)
            task.delay(5, clearProcessingState)
            return
        end
    end

    if State.autoJoinInfinityCastleEnabled then
        setProcessingState("Infinity Castle Auto Join")

        handleTeamEquipping("InfCastle")

        local CastleFloor = getHighestNumberFromNames(Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].InfinityCastleRewards)

        Remotes.PlayEvent:FireServer("Infinity-Castle",{Floor = CastleFloor + 1})
        task.delay(5, clearProcessingState)
        return
    end

    if State.autoDungeonEnabled and State.AutoDungeonDifficultySelector and State.AutoDungeonDifficultySelector ~= "" then
        setProcessingState("Dungeon Auto Join")

        handleTeamEquipping("Dungeon")
        print(State.AutoDungeonDifficultySelector)
        local args = {"Dungeon",{Difficulty = State.AutoDungeonDifficultySelector[1]}}
        print(State.AutoDungeonDifficultySelector[1])
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer(unpack(args))

        task.delay(5, clearProcessingState)
        return
    end

    if State.autoRiftEnabled then
        setProcessingState("Rift Auto Join")

        handleTeamEquipping("RiftStorm")

        Remotes.PlayEvent:FireServer("RiftStorm")
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Start")


        task.delay(5, clearProcessingState)
        return
    end

            if State.autoInfiniteEnabled then
            setProcessingState("Infinite Mode Auto Join")

            handleTeamEquipping("Infinite")

            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Infinite Mode")

            task.delay(5, clearProcessingState)
        end

    -- Priority 5: Story Auto Join
    if State.autoJoinEnabled and State.selectedWorld and State.selectedChapter and State.selectedDifficulty then
        setProcessingState("Story Auto Join")

        local internalWorldName = getInternalWorldName(State.selectedWorld)
        if internalWorldName then
            print("📚 Joining Story:", State.selectedWorld, "/", State.selectedChapter, "/", State.selectedDifficulty)

            handleTeamEquipping("Story")

            local combinedWorld = internalWorldName .. "_" .. State.selectedChapter:gsub(" ", "")

            local function sendPlayRoomEvent(action, data)
                Remotes.PlayEvent:FireServer(action, data)
                task.wait(0.25)
            end

            sendPlayRoomEvent("Create")
            sendPlayRoomEvent("Change-World", { World = tostring(internalWorldName) })
            sendPlayRoomEvent("Change-Chapter", { Chapter = tostring(combinedWorld) })
            sendPlayRoomEvent("Change-Difficulty", { Difficulty = tostring(State.selectedDifficulty) })
            sendPlayRoomEvent("Submit")
            sendPlayRoomEvent("Start")

            task.delay(5, clearProcessingState)
            return
        else
            warn("[Story Auto Join] Invalid selection.")
            notify("⚠️ Story Join", "Selected World/Chapter/Difficulty is invalid.")
            clearProcessingState()
        end
    end
end


local function getCurrentChallengeSerial()
    local success, serial = pcall(function()
        return challengeFolder:FindFirstChild("serial_number") and challengeFolder.serial_number.Value
    end)
    return success and serial or nil
end

if not State.storedChallengeSerial then
    State.storedChallengeSerial = getCurrentChallengeSerial()
end

local function getCurrentUpgradeLevel(unitName)
    if not unitName then return 0 end

    local success, upgradeLevel = pcall(function()
        local upgradeText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].UpgradeText.Text

        if string.find(upgradeText:upper(), "MAX") then
            return "MAX"
        end

        local level = string.match(upgradeText, "Upgrade:</font>%s*(%d+)")
        return tonumber(level) or 0
    end)

    if success then
        return upgradeLevel
    else
        return 0
    end
end

local function getUpgradeCost(unitName)
    if not unitName then return 9999 end

    local success, cost = pcall(function()
        local costText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].CostText.Text
        local costValue = string.match(costText, "Cost:</font>%s*([%d,]+)")
        if costValue then
            costValue = costValue:gsub(",", "")
            return tonumber(costValue) or 9999
        end
    end)

    return success and cost or 9999
end

local function getDeploymentCost(unitName)
    if not unitName then return 5000 end

    local success, costText = pcall(function()
        return Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].Unit.Frame.UnitFrame.Info.Cost.Text
    end)

    if success and costText then
        local numericCost = tonumber(costText:match("%d+"))
        if numericCost then
            return numericCost
        else
            return 9999 -- Extraction failed, fallback cost
        end
    else
        return 9999 -- Retrieval failed, fallback cost
    end
end


local function getCurrentMoney()
    local success, money = pcall(function()
        return Services.Players.LocalPlayer.Yen.Value
    end)

    return (success and money) or 0
end

local function upgradeUnit(unitName)
    if not unitName then return false end

    local unitNameStr = typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)

    local success = pcall(function()
        local args = { Services.Players.LocalPlayer.UnitsFolder:WaitForChild(unitNameStr) }
        Remotes.UpgradeUnit:FireServer(unpack(args))
    end)

    if success then
        return true
    else
        return false
    end
end

local function hasEnoughMoney(slotNumber)
    local currentMoney = getCurrentMoney()
    local unitName = getUnitNameFromSlot(slotNumber)
    local unitNameStr = typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)
    local unitCost = getDeploymentCost(unitNameStr)

    
    --print("Slot " .. slotNumber .. " - Money: " .. currentMoney .. ", Cost: " .. unitCost)
    
    return currentMoney >= unitCost
end

local function leftToRightUpgrade()
    while State.autoUpgradeEnabled and State.gameRunning do
        local unitName = getUnitNameFromSlot(State.currentUpgradeSlot)
        local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
        local maxLevel = Config.unitLevelCaps[tonumber(State.currentUpgradeSlot)] or 9

        if unitName and unitNameStr ~= "" and unitNameStr ~= "nil" then
            local currentLevel = getCurrentUpgradeLevel(unitNameStr)

            if currentLevel == "MAX" or tonumber(currentLevel) >= maxLevel then
                State.currentUpgradeSlot = State.currentUpgradeSlot + 1
                if State.currentUpgradeSlot > 6 then
                    State.currentUpgradeSlot = 1
                end
            else
                local currentMoney = getCurrentMoney()
                local upgradeCost = getUpgradeCost(unitNameStr)

                if currentMoney >= upgradeCost then
                    if upgradeUnit(unitNameStr) then
                        task.wait(UPGRADE_COOLDOWN)
                    else
                        warn("❌ Failed to upgrade, will retry")
                        task.wait(1)
                    end
                end
            end
        else
            State.currentUpgradeSlot = State.currentUpgradeSlot + 1
            if State.currentUpgradeSlot > 6 then
                State.currentUpgradeSlot = 1
            end
        end

        task.wait(0.5)
    end

    print("🛑 Upgrade cycle ended")
end

local function startAutoUpgrade()
    if isInLobby() then
        print("⚠️ Cannot start auto-upgrade while in lobby.")
        return
    end

    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end

    State.upgradeTask = task.spawn(function()
        while State.autoUpgradeEnabled do
            if State.gameRunning then
                local success, err = pcall(function()
                    if State.upgradeMethod == "Left to right until max" then
                        leftToRightUpgrade()
                    elseif State.upgradeMethod == "randomize" then
                        print("🔄 Randomize method not implemented yet")
                    elseif State.upgradeMethod == "lowest level spread upgrade" then
                        print("🔄 Lowest level spread method not implemented yet")
                    end
                end)

                if not success then
                    warn("❌ Auto upgrade error:", err)
                end
            else
                --print("⏳ Waiting for game to start...")
            end

            task.wait(1)
        end
    end)
end

local function stopAutoUpgrade()
    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end
end

local function resetUpgradeOrder()
    State.currentUpgradeSlot = 1
    print("🔄 Reset upgrade order to slot 1")
end


local function isTargetAlive(targetValue)
    if not targetValue or not targetValue.Name then
        return false
    end
    local success, result = pcall(function()
        local agentFolder = Services.Workspace:WaitForChild("Agent", 5)
        if not agentFolder then return false end
        
        local enemyFolder = agentFolder:FindFirstChild("EnemyT")
        if not enemyFolder then return false end
        
        -- Check if enemy with same name exists in EnemyT
        local enemy = enemyFolder:FindFirstChild(targetValue.Name)
        return enemy ~= nil
    end)
    
    return success and result
end

local function getUnitsWithUltimates()
    local unitsWithUltimates = {}

    local success, result = pcall(function()
        local agentFolder = Services.Workspace:WaitForChild("Agent", 5)
        if not agentFolder then return {} end

        local unitFolder = agentFolder:WaitForChild("UnitT", 5)
        if not unitFolder then return {} end

        for _, part in pairs(unitFolder:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Part") then
                local infoFolder = part:FindFirstChild("Info")
                if infoFolder then
                    local activeAbility = infoFolder:FindFirstChild("ActiveAbility")
                    local targetObject = infoFolder:FindFirstChild("TargetObject")
                    local ownerValue = infoFolder:FindFirstChild("Owner")

                    if activeAbility and activeAbility:IsA("StringValue") and targetObject and targetObject:IsA("ObjectValue") and ownerValue and ownerValue:IsA("StringValue") then
                        if activeAbility.Value ~= "" and targetObject.Value ~= nil and ownerValue.Value == Services.Players.LocalPlayer.Name then
                            if isTargetAlive(targetObject.Value) then
                            table.insert(unitsWithUltimates, {
                                part = part,
                                abilityName = activeAbility.Value
                            })
                        end
                        end
                    end
                end
            end
        end

        return unitsWithUltimates
    end)

    if success then
        return result
    else
        warn("❌ Error getting units with ultimates:", result)
        return {}
    end
end

local function fireUltimateForUnit(unitData)
    local success = pcall(function()
        Services.ReplicatedStorage.Remote.Server.Units.Ultimate:FireServer(unitData.part)
    end)

    if not success then
        warn("❌ Failed to fire ultimate for unit:", unitData.part.Name)
    end
end

local function autoUltimateLoop()
    if isInLobby() then return end
    while State.AutoUltimateEnabled do
        local unitsWithUltimates = getUnitsWithUltimates()
        if #unitsWithUltimates > 0 then
            for _, unitData in pairs(unitsWithUltimates) do
                if not State.AutoUltimateEnabled then break end
                if State.DelayAutoUltimate > 0 then
                    task.wait(State.DelayAutoUltimate)
                end
                fireUltimateForUnit(unitData)
                task.wait(0.1)
            end
        end
        task.wait(1)
    end
    print("🛑 Auto Ultimate loop stopped")
end

local function checkSlotExists(slotNumber)
    local slotPath = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber]
    if slotPath and slotPath.Frame.UnitFrame and slotPath.Frame.UnitFrame.Info.Folder.Value ~= nil then
        State.slotExists[slotNumber] = true
        return true
    else
        State.slotExists[slotNumber] = false
        return false
    end
end

local function isSlotOnCooldown(slotNumber)
    local cooldownPath = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame:FindFirstChild("CD_FRAME")
    return cooldownPath and cooldownPath.Visible or false
end

local function shouldSkipSlotTemporarily(slotNumber)
    local lastAttempt = State.lastDeploymentTimes[slotNumber]
    if lastAttempt and (tick() - lastAttempt) < 3 then
        return true
    end
    return false
end

local function IsUnitLevelReached(slotNumber)
    local unitName = getUnitNameFromSlot(slotNumber)
    local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
    local currentUnitLevel = getCurrentUpgradeLevel(unitNameStr)
    if currentUnitLevel == "MAX" then
        return false
    end
    if currentUnitLevel < Config.unitDeployLevelCaps[slotNumber] then
        return true
    end
end

local function getNextReadySlot()
    local startSlot = State.currentSlot
    local checkedSlots = 0
    
    while checkedSlots < 6 do
    task.wait(0.05)
    local slotToCheck = State.currentSlot

    local shouldSkip = false

    if not checkSlotExists(slotToCheck) then
        shouldSkip = true
    elseif isSlotOnCooldown(slotToCheck) then
        shouldSkip = true
    elseif not hasEnoughMoney(slotToCheck) then
        shouldSkip = true
    elseif shouldSkipSlotTemporarily(slotToCheck) then
        shouldSkip = true
    elseif IsUnitLevelReached(slotToCheck) then
        shouldSkip = true
    end

    if shouldSkip then
        State.currentSlot = (State.currentSlot % 6) + 1
        checkedSlots = checkedSlots + 1
    else
        return slotToCheck
    end
end
    return nil
end

local function deployUnit(slotNumber)
    if not checkSlotExists(slotNumber) then
        return false, "Slot doesn't exist"
    end
    
    if isSlotOnCooldown(slotNumber) then
        return false, "Unit is on cooldown"
    end

    if not hasEnoughMoney(slotNumber) then
        return false, "Not enough money"
    end

    if IsUnitLevelReached(slotNumber) then
        return false, "Unit can't be deployed yet because of level"
    end
    -- Get the unit folder for this slot
    local unitFolder = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
    
    if not unitFolder then
        return false, "Unit folder not found"
    end
    
    -- Try to deploy the unit
    local success, errorMessage = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Deployment"):FireServer(unitFolder)
    end)
    
    if success then
        --print("Successfully deployed unit from slot " .. slotNumber)
        -- Clear any temporary skip for this slot since it worked
        State.lastDeploymentTimes[slotNumber] = nil
        return true, "Success"
    else
        print("Failed to deploy unit from slot " .. slotNumber .. ": " .. tostring(errorMessage))
        -- Mark this slot as recently failed
        State.lastDeploymentTimes[slotNumber] = tick()
        return false, "Deployment failed"
    end
end

local function autoPlayLoop()
    task.spawn(function()
        while State.autoPlayEnabled do
            -- Check if we should apply delay at the start of each game
            if State.gameRunning and State.AutoPlayDelayNumber > 0 and not State.autoPlayDelayActive then
                State.autoPlayDelayActive = true
                notify("Auto Play Delay", "Waiting " .. State.AutoPlayDelayNumber .. " seconds before starting deployment...", 5)
                
                -- Wait for the specified delay
                task.wait(State.AutoPlayDelayNumber)
                
                notify("Auto Play Delay", "Delay finished, starting deployment..", 5)
            end
            
            -- Only proceed with deployment if game is running and delay has passed (or no delay set)
            if State.gameRunning and (State.AutoPlayDelayNumber == 0 or State.autoPlayDelayActive) then
                -- Find next ready slot
                local slotToDeploy = getNextReadySlot()
                
                if slotToDeploy then
                    local success, message = deployUnit(slotToDeploy)
                    
                    if success then
                        -- Successfully deployed, move to next slot for next deployment
                        State.currentSlot = (slotToDeploy % 6) + 1
                    elseif not success and message == "Not enough money" then
                        State.currentSlot = (slotToDeploy % 6)
                    else
                        -- Failed deployment, slot will be temporarily skipped
                        -- Move to next slot to continue the cycle
                        State.currentSlot = (slotToDeploy % 6) + 1
                        print("Failed to deploy from slot " .. slotToDeploy .. " (" .. message .. "), trying next slot")
                    end
                else
                    -- No ready slots found, continue cycling
                    -- The getNextReadySlot function already moved currentSlot forward
                    -- print("No ready slots found, continuing cycle...")
                end
            end
            
            -- Wait before next attempt
            task.wait(0.1)
        end
    end)
end

local function startAutoPlay()
    if isInLobby() then 
        print("Cannot start autoplay: Player is in lobby")
        return 
    end
    
    print("Starting autoplay system...")
    
    -- Reset state
    if Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.AutoPlay.Value == true then
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("AutoPlay"):FireServer()
    end
    State.currentSlot = 1
    State.lastDeploymentTimes = {}
    State.slotExists = {}
    State.autoPlayDelayActive = false  -- Reset delay flag
    
    -- Check which slots have units initially
    for i = 1, 6 do
        checkSlotExists(i)
        print("Slot " .. i .. " exists: " .. tostring(State.slotExists[i]))
    end
    
    autoPlayLoop()
end

local function shouldDeployOnCurrentPath(slotNumber)
    local config = State.bossRushDeployConfig[slotNumber]
    if not config or not config.enabled then
        return false
    end
    
    local currentPath = State.currentBossPath or 1
    
    -- Check if current path is in the allowed paths for this slot
    for _, allowedPath in pairs(config.paths) do
        if allowedPath == currentPath then
            return true
        end
    end
    
    return false
end

local function bossRushShouldSkipSlotTemporarily(slotNumber)
    local lastAttempt = State.bossRushLastDeploymentTimes[slotNumber]
    if lastAttempt and (tick() - lastAttempt) < 3 then
        return true
    end
    return false
end

local function getBossRushNextReadySlot()
    local startSlot = State.bossRushCurrentSlot
    local checkedSlots = 0
    
    while checkedSlots < 6 do
        task.wait(0.05)
        local slotToCheck = State.bossRushCurrentSlot

        local shouldSkip = false

        -- Check if slot is configured for boss rush and enabled
        if not State.bossRushDeployConfig[slotToCheck] or not State.bossRushDeployConfig[slotToCheck].enabled then
            shouldSkip = true
        -- Check if unit should be deployed on current path
        elseif not shouldDeployOnCurrentPath(slotToCheck) then
            shouldSkip = true
        -- Use existing checks
        elseif not checkSlotExists(slotToCheck) then
            shouldSkip = true
        elseif isSlotOnCooldown(slotToCheck) then
            shouldSkip = true
        elseif not hasEnoughMoney(slotToCheck) then
            shouldSkip = true
        elseif bossRushShouldSkipSlotTemporarily(slotToCheck) then
            shouldSkip = true
        elseif IsUnitLevelReached(slotToCheck) then
            shouldSkip = true
        end

        if shouldSkip then
            State.bossRushCurrentSlot = (State.bossRushCurrentSlot % 6) + 1
            checkedSlots = checkedSlots + 1
        else
            return slotToCheck
        end
    end
    return nil
end

local function bossRushDeployUnit(slotNumber)
    if not checkSlotExists(slotNumber) then
        return false, "Slot doesn't exist"
    end
    
    if isSlotOnCooldown(slotNumber) then
        return false, "Unit is on cooldown"
    end

    if not hasEnoughMoney(slotNumber) then
        return false, "Not enough money"
    end

    if IsUnitLevelReached(slotNumber) then
        return false, "Unit can't be deployed yet because of level"
    end

    if not shouldDeployOnCurrentPath(slotNumber) then
        return false, "Unit not configured for current path"
    end
    
    -- Get the unit folder for this slot
    local unitFolder = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
    
    if not unitFolder then
        return false, "Unit folder not found"
    end
    
    -- Try to deploy the unit
    local success, errorMessage = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Deployment"):FireServer(unitFolder)
    end)
    
    if success then
        print("Successfully deployed boss rush unit from slot " .. slotNumber .. " on path " .. (State.currentBossPath or 1))
        -- Clear any temporary skip for this slot since it worked
        State.bossRushLastDeploymentTimes[slotNumber] = nil
        return true, "Success"
    else
        print("Failed to deploy boss rush unit from slot " .. slotNumber .. ": " .. tostring(errorMessage))
        -- Mark this slot as recently failed
        State.bossRushLastDeploymentTimes[slotNumber] = tick()
        return false, "Deployment failed"
    end
end

local function bossRushAutoPlayLoop()
    task.spawn(function()
        while State.bossRushAutoDeployEnabled do
            -- Only deploy if we're in a boss rush game
            if State.gameRunning then
                -- Find next ready slot for current path
                local slotToDeploy = getBossRushNextReadySlot()
                
                if slotToDeploy then
                    local success, message = bossRushDeployUnit(slotToDeploy)
                    
                    if success then
                        -- Successfully deployed, move to next slot for next deployment
                        State.bossRushCurrentSlot = (slotToDeploy % 6) + 1
                    elseif not success and message == "Not enough money" then
                        State.bossRushCurrentSlot = (slotToDeploy % 6)
                    else
                        -- Failed deployment, slot will be temporarily skipped
                        State.bossRushCurrentSlot = (slotToDeploy % 6) + 1
                        if message ~= "Unit not configured for current path" then
                            print("Failed to deploy boss rush unit from slot " .. slotToDeploy .. " (" .. message .. "), trying next slot")
                        end
                    end
                else
                    -- No ready slots found for current path, continue cycling
                    -- print("No ready slots found for current path, continuing cycle...")
                end
            end
            
            -- Wait before next attempt
            task.wait(0.1)
        end
    end)
end

local function startBossRushAutoPlay()
    if isInLobby() then 
        print("Cannot start boss rush autoplay: Player is in lobby")
        return 
    end
    
    print("Starting boss rush auto deploy system...")
    
    -- Reset state
    if Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.AutoPlay.Value == true then
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("AutoPlay"):FireServer()
    end
    State.bossRushCurrentSlot = 1
    State.bossRushLastDeploymentTimes = {}
    State.slotExists = {}
    
    -- Check which slots have units initially
    for i = 1, 6 do
        checkSlotExists(i)
        if State.bossRushDeployConfig[i] and State.bossRushDeployConfig[i].enabled then
            print("Boss Rush Slot " .. i .. " configured for paths: " .. table.concat(State.bossRushDeployConfig[i].paths, ", "))
        end
    end
    
    bossRushAutoPlayLoop()
end

local function stopBossRushAutoPlay()
    State.bossRushAutoDeployEnabled = false
    print("Boss rush auto deploy system stopped")
end

local function setBossRushSlotPaths(slotNumber, paths)
    if slotNumber >= 1 and slotNumber <= 6 then
        if not State.bossRushDeployConfig[slotNumber] then
            State.bossRushDeployConfig[slotNumber] = {paths = {}, enabled = false}
        end
        State.bossRushDeployConfig[slotNumber].paths = paths
        print("Set slot " .. slotNumber .. " to deploy on paths: " .. table.concat(paths, ", "))
    end
end

local function setBossRushSlotEnabled(slotNumber, enabled)
    if slotNumber >= 1 and slotNumber <= 6 then
        if not State.bossRushDeployConfig[slotNumber] then
            State.bossRushDeployConfig[slotNumber] = {paths = {1, 2, 3, 4}, enabled = false}
        end
        State.bossRushDeployConfig[slotNumber].enabled = enabled
        print("Slot " .. slotNumber .. " boss rush deployment " .. (enabled and "enabled" or "disabled"))
    end
end

local function toggleBossRushAutoPlay()
    State.bossRushAutoDeployEnabled = not State.bossRushAutoDeployEnabled
    
    if State.bossRushAutoDeployEnabled then
        startBossRushAutoPlay()
    else
        stopBossRushAutoPlay()
    end
end

-- Helper function to convert path string to number
local function pathStringToNumber(pathString)
    local pathMap = {
        ["Path 1"] = 1,
        ["Path 2"] = 2,
        ["Path 3"] = 3,
        ["Path 4"] = 4
    }
    return pathMap[pathString]
end

local function StreamerMode()
    local head = Services.Players.LocalPlayer.Character:WaitForChild("Head", 5)
    if not head then return end

    local billboard = head:FindFirstChild("PlayerHeadGui")
    if not billboard then return end

    local originalNumbers = Services.Players.LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("ExpBar"):FindFirstChild("Numbers")
    if not originalNumbers then return end

    local streamerLabel = Services.Players.LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("ExpBar"):FindFirstChild("Numbers_Streamer")
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "Numbers_Streamer"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = originalNumbers.Parent
    end

    if State.streamerModeEnabled then
        billboard:FindFirstChild("PlayerName").Text = "🔥 Protected By LixHub 🔥"
        billboard:FindFirstChild("Level").Text = "Level 999"
        billboard:FindFirstChild("Title").Text = "Lixhub User"

        originalNumbers.Visible = false
        streamerLabel.Visible = true
    else
        billboard:FindFirstChild("PlayerName").Text = tostring(Services.Players.LocalPlayer.Name)
        billboard:FindFirstChild("Level").Text = "Level " .. Services.ReplicatedStorage:WaitForChild("Player_Data")[Services.Players.LocalPlayer.Name].Data.Level.Value
        billboard:FindFirstChild("Title").Text = Services.ReplicatedStorage:WaitForChild("Player_Data")[Services.Players.LocalPlayer.Name].Data.Title.Value

        originalNumbers.Visible = true
        streamerLabel.Visible = false
    end
end

local failsafeRunning = false

local function startFailsafeAfterGameEnd()
    if failsafeRunning then
        warn("⚠️ Failsafe is already running. Skipping new start.")
        return
    end
    failsafeRunning = true

    task.spawn(function()
        local waitTime = tonumber(State.AutoFailSafeNumber) or 300
        notify("Failsafe", "Failsafe started, Waiting ".. waitTime .." seconds or until game starts...", 5)

        local startTime = tick()
        while tick() - startTime < waitTime do
            if State.gameRunning then
                notify("Failsafe", "New game started during wait. Cancelling failsafe.", 3)
                failsafeRunning = false
                return
            end
            task.wait(1)
        end

        if not State.gameRunning then
            notify("Failsafe", "Teleporting to lobby...", 3)
            Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
        else
            print("✅ Game started right at the end of wait. No recovery needed.")
        end

        failsafeRunning = false
    end)
end

local function startRetryLoop()
    State.retryAttempted = true
    task.spawn(function()
        while State.retryAttempted and State.autoRetryEnabled do
            Remotes.RetryEvent:FireServer()
            task.wait(0.5)
        end
    end)
end

local function stopRetryLoop()
    State.retryAttempted = false
end

local function startNextLoop()
    State.NextAttempted = true

    task.spawn(function()
        while State.NextAttempted and State.autoNextEnabled do
            Remotes.NextEvent:FireServer()
            task.wait(0.5) -- Retry interval (can adjust)
        end
    end)
end

local function stopNextLoop()
    State.NextAttempted = false
end

local function getunitRarity(unit)
    local success, result = pcall(function()
        local gui = Services.Players.LocalPlayer.PlayerGui.Collection.Main.Base.Space.Unit[unit.Name].Frame.UnitFrame
        for _, rarity in ipairs({ "Ranger", "Secret", "Mythic", "Legendary", "Epic", "Rare" }) do
            if gui:FindFirstChild(rarity) then return rarity end
        end
    end)
    return success and result or nil
end

local function isUnitShiny(unit)
    local success, result = pcall(function()
        -- Check if "Shiny" is in the unit name
        if string.find(unit.Name:lower(), "shiny") then
            return true
        end
        local gui = Services.Players.LocalPlayer.PlayerGui.Collection.Main.Base.Space.Unit[unit.Name]
        if gui and string.find(gui.Name:lower(), "shiny") then
            return true
        end
        return false
    end)
    return success and result or false
end

local function shouldSellUnit(unit, selectedRarities)
    local rarity = getunitRarity(unit)
    local isShiny = isUnitShiny(unit)
    
    local hasShinySelected = table.find(selectedRarities, "Shiny")
    local hasRaritySelected = table.find(selectedRarities, rarity)
    
    if not hasRaritySelected then
        return false
    end
    if hasShinySelected then
        return true
    else
        return not isShiny
    end
end

local CurseImageIDs = {
    ["Ability Damage"] = "rbxassetid://129472130637846",
    ["Ability Cooldown"] = "rbxassetid://94734246361320",
    ["Health"] = "rbxassetid://132403000977312",
    ["Damage"] = "rbxassetid://128960075980851",
    ["Attack Cooldown"] = "rbxassetid://102308191455123",
    ["Range"] = "rbxassetid://105399018590765",
    ["Speed"] = "rbxassetid://131770445081586",
}

local function GetAppliedCurses()
    local main = Services.Players.LocalPlayer.PlayerGui:WaitForChild("ApplyCurse").Main.Base.Stats.Main
    local results = {}

    for _, statFrame in pairs(main:GetChildren()) do
        if statFrame.Name == "StatTemp" then
            local icon = statFrame:FindFirstChild("StatsIconic")
            local buffIcon = statFrame:FindFirstChild("BuffIconic")
            local percentageLabel = statFrame:FindFirstChild("Value") -- You might need to adjust this name
            
            if icon and buffIcon then
                local isGreen = buffIcon.Image == "rbxassetid://73853750530888"
                local percentage = 0
                
                -- Extract percentage value from the label
                if percentageLabel and percentageLabel.Text then
                    local percentText = percentageLabel.Text
                    -- Extract number from text like "+15%" or "-7%"
                    local sign, number = percentText:match("([+-]?)(%d+)")
                    if number then
                        percentage = tonumber(number) or 0
                        if sign == "-" then
                            percentage = -percentage
                        end
                    end
                end
                
                table.insert(results, {
                    image = icon.Image,
                    isGreen = isGreen,
                    percentage = percentage,
                    slot = #results + 1
                })
            end
        end
    end
    return results
end

local function CursesMatch(applied, selected)
    if not applied or #applied == 0 then
        return false
    end
    
    -- If only 1 curse selected, find it anywhere with its requirement
    if #selected == 1 then
        local targetCurse = selected[1]
        local minRequired = State.curseMinimums[targetCurse] or 1
        
        for _, curse in ipairs(applied) do
            if curse.image == CurseImageIDs[targetCurse] and curse.isGreen then
                -- Check if this curse meets its minimum requirement
                local isReverseStat = targetCurse == "Attack Cooldown" or targetCurse == "Ability Cooldown"
                
                if isReverseStat then
                    -- For reverse stats, we want curse.percentage <= -minRequired
                    if curse.percentage <= -minRequired then
                        return true
                    end
                else
                    -- For normal stats, we want curse.percentage >= minRequired
                    if curse.percentage >= minRequired then
                        return true
                    end
                end
            end
        end
        return false
    end
    
    -- For multiple curses, find ANY of them that meet their individual requirements
    local foundCurses = {}
    for _, curse in ipairs(applied) do
        if curse.isGreen then
            for _, selectedName in ipairs(selected) do
                if curse.image == CurseImageIDs[selectedName] then
                    local minRequired = State.curseMinimums[selectedName] or 1
                    local meetsRequirement = true
                    
                    -- Check if this specific curse meets its requirement
                    local isReverseStat = selectedName == "Attack Cooldown" or selectedName == "Ability Cooldown"
                    
                    if isReverseStat then
                        -- For reverse stats, we want curse.percentage <= -minRequired
                        if curse.percentage > -minRequired then
                            meetsRequirement = false
                        end
                    else
                        -- For normal stats, we want curse.percentage >= minRequired
                        if curse.percentage < minRequired then
                            meetsRequirement = false
                        end
                    end
                    
                    if meetsRequirement then
                        foundCurses[selectedName] = true
                    end
                    break
                end
            end
        end
    end
    
    -- Count how many different selected curses we found that meet their requirements
    local foundCount = 0
    for _ in pairs(foundCurses) do
        foundCount = foundCount + 1
    end
    
    -- Success if we found at least 2 of our selected curses with proper percentages
    return foundCount >= 2
end

local function GetSelectedUnit()
    local success, unit = pcall(function()
        local playerGui = Services.Players.LocalPlayer.PlayerGui
        local applyCurseGui = playerGui:FindFirstChild("ApplyCurse")
        
        if not applyCurseGui then
            return nil
        end

        local unitFolder = applyCurseGui:FindFirstChild("Main")
            and applyCurseGui.Main:FindFirstChild("Base")
            and applyCurseGui.Main.Base:FindFirstChild("UnitFolder")

        return unitFolder and unitFolder.Value or nil
    end)

    return success and unit or nil
end

local function GetSelectedUnitTraits()
    local success, result = pcall(function()
        local objVal = Services.Players.LocalPlayer.PlayerGui
            :WaitForChild("Traits")
            :WaitForChild("Main")
            :WaitForChild("Base")
            :WaitForChild("UnitFolder")

        local folder = objVal.Value
        
        if not folder then
            return nil
        end

        local primary = folder:FindFirstChild("PrimaryTrait")
        local secondary = folder:FindFirstChild("SecondaryTrait")

        if primary and secondary then
            return {
                primary = primary.Value,
                secondary = secondary.Value,
                unit = folder
            }
        end
        return nil
    end)

    return success and result or nil
end

local function TraitsMatch(currentTraits, selectedTraits, requireDouble)
    if not currentTraits then
        return false
    end
    
    local primary = currentTraits.primary
    local secondary = currentTraits.secondary
    
    -- Convert selected traits to a lookup table for faster checking
    local selectedLookup = {}
    for _, trait in ipairs(selectedTraits) do
        selectedLookup[trait] = true
    end
    
    if requireDouble then
        -- For double traits: need one selected trait in primary AND one in secondary
        local primaryMatch = selectedLookup[primary]
        local secondaryMatch = selectedLookup[secondary]
        
        return primaryMatch and secondaryMatch and primary ~= secondary
    else
        -- For single trait: need at least one selected trait in either slot
        return selectedLookup[primary] or selectedLookup[secondary]
    end
end

local function RerollTraits(unit)
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gambling"):WaitForChild("RerollTrait"):FireServer(game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild("DrzonersonAloerson"):WaitForChild("Collection"):WaitForChild(unit.Name),"Reroll","Main","Shards")
    end)
    return success
end

local function StartAutoReroll(selectedTraits)
    if not isInLobby() then -- Assuming you have this function from your curse system
        notify("Auto Reroll", "Must be in lobby to use auto reroll!")
        return
    end
    
    if #selectedTraits < 1 then
        notify("Auto Reroll", "Please select at least 1 trait!")
        return
    end
    
    if State.rollOnlyDoubleTraits and #selectedTraits < 2 then
        notify("Auto Reroll", "Need at least 2 traits selected for double trait mode!")
        return
    end
    
    task.spawn(function()
        local attempts = 0
        local maxAttempts = 999999999999999 -- Adjust as needed
        
        -- Dynamic success message based on mode
        local targetMessage
        if State.rollOnlyDoubleTraits then
            targetMessage = string.format("Looking for 2 traits from: %s", table.concat(selectedTraits, ", "))
        else
            targetMessage = string.format("Looking for any of: %s", table.concat(selectedTraits, ", "))
        end
        
        notify("Auto Reroll", targetMessage)
        
        while State.AutoRerollEnabled and attempts < maxAttempts do
            attempts = attempts + 1
            
            -- Get current unit and traits
            local currentTraits = GetSelectedUnitTraits()
            if not currentTraits then
                notify("Auto Reroll", "No unit selected! Please select a unit in the trait UI.")
                task.wait(3)
                continue
            end
            
            -- Check if current traits match our requirements
            if TraitsMatch(currentTraits, selectedTraits, State.rollOnlyDoubleTraits) then
                local successMessage
                if State.rollOnlyDoubleTraits then
                    successMessage = string.format("Found double traits: %s + %s! (Attempt %d)", 
                        currentTraits.primary, currentTraits.secondary, attempts)
                else
                    successMessage = string.format("Found matching trait! Primary: %s, Secondary: %s (Attempt %d)", 
                        currentTraits.primary, currentTraits.secondary, attempts)
                end
                
                notify("Auto Reroll", successMessage)
                State.AutoRerollEnabled = false
                break
            end
            
            -- Log current attempt
            print(string.format("Attempt %d: Primary: %s, Secondary: %s", 
                attempts, currentTraits.primary, currentTraits.secondary))
            
            -- Reroll traits
            local rollSuccess = RerollTraits(currentTraits.unit)
            if not rollSuccess then
                notify("Auto Reroll", "Failed to reroll traits! Retrying...")
                task.wait(1)
                continue
            end
            
            -- Wait a bit before checking results
            task.wait(0.5)
            
            -- Progress notification every 20 attempts
            if attempts % 20 == 0 then
                notify("Auto Reroll", string.format("Attempt %d/%d - Still searching...", attempts, maxAttempts))
            end
        end
        
        -- Handle failure case
        if State.AutoRerollEnabled and attempts >= maxAttempts then
            notify("Auto Reroll", string.format("Failed after %d attempts. Consider different trait selection.", maxAttempts))
            State.AutoRerollEnabled = false
        end
    end)
end

local function StartAutoCurse(selectedCurses)
    if not isInLobby() then
        notify("Auto Curse", "Must be in lobby to use auto curse!")
        return
    end
    
    if #selectedCurses < 1 then
        notify("Auto Curse", "Please select at least 1 curse!")
        return
    end
    
    task.spawn(function()
        local attempts = 0
        local maxAttempts = 50
        
        -- Dynamic success message based on selection
        local targetMessage = #selectedCurses == 1 and 
            string.format("Looking for: %s", selectedCurses[1]) or
            string.format("Looking for any 2 of: %s", table.concat(selectedCurses, ", "))
        
        notify("Auto Curse", targetMessage)
        
        while State.AutoCurseEnabled and attempts < maxAttempts do
            attempts = attempts + 1
            
            -- Enhanced unit validation
            local unit = GetSelectedUnit()
            if not unit then
                notify("Auto Curse", "No unit selected! Please select a unit in the curse UI.")
                task.wait(3)
                continue
            end
            
            -- Apply curse with error handling
            local success = pcall(function()
                Remotes.ApplyCurseRemote:FireServer("ApplyCurse - Normal", unit)
            end)
            
            if not success then
                notify("Auto Curse", "Failed to apply curse! Retrying...")
                task.wait(1)
                continue
            end
            
            task.wait(1)

            local applied = GetAppliedCurses()

            if CursesMatch(applied, selectedCurses) then
                local successMessage = #selectedCurses == 1 and
                    string.format("Found %s! (Attempt %d)", selectedCurses[1], attempts) or
                    string.format("Found matching curses! (Attempt %d)", attempts)
                
                notify("Auto Curse", successMessage)
                State.AutoCurseEnabled = false
                break
            end
            
            -- Enhanced logging with percentage info
            if applied then
                local currentCurses = {}
                for i, curse in ipairs(applied) do
                    if curse.isGreen then
                        for curseName, imageId in pairs(CurseImageIDs) do
                            if curse.image == imageId then
                                local slotInfo = string.format("%s %+d%% (Slot %d)", curseName, curse.percentage, i)
                                table.insert(currentCurses, slotInfo)
                                break
                            end
                        end
                    end
                end
                if #currentCurses > 0 then
                    print(string.format("Attempt %d got: %s", attempts, table.concat(currentCurses, ", ")))
                end
            end
            
            -- Progress notification every 10 attempts
            if attempts % 10 == 0 then
                notify("Auto Curse", string.format("Attempt %d/%d - Still searching...", attempts, maxAttempts))
            end
        end
        
        -- Handle failure case
        if State.AutoCurseEnabled and attempts >= maxAttempts then
            notify("Auto Curse", string.format("Failed after %d attempts. Try different requirements.", maxAttempts))
            State.AutoCurseEnabled = false
        end
    end)
end

local function deleteUnit(unitName)
    if not unitName then return false end
    
    local success, result = pcall(function()
        -- Loop through all parts in UnitT folder
        for _, part in pairs(Services.Workspace.Agent.UnitT:GetChildren()) do
            if part:IsA("Part") then
                local info = part:FindFirstChild("Info")
                if info then
                    local unitNameValue = info:FindFirstChild("UnitName")
                    if unitNameValue and unitNameValue.Value == unitName then
                        local args = {part, nil}
                        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("DeleteUnit"):FireServer(unpack(args))
                        return true
                    end
                end
            end
        end
        return false
    end)
    
    if success and result then
        print("Successfully deleted unit: " .. unitName)
        return true
    else
        return false
    end
end

local lastCheckedLevels = {}
local processedUnits = {}

local function checkAndRefreshUnits()
    for slot = 1, 6 do
        local unitName = getUnitNameFromSlot(slot)

        if unitName then
            local currentLevel = getCurrentUpgradeLevel(unitName)
            local targetLevel = Config.unitReDeployLevel[slot]

            if targetLevel ~= 0 then
                local slotKey = "slot_" .. slot

                if not processedUnits[slotKey] and lastCheckedLevels[slotKey] ~= currentLevel then
                    lastCheckedLevels[slotKey] = currentLevel

                    if currentLevel == "MAX" and targetLevel <= 9 then
                        print("Slot " .. slot .. " (" .. unitName .. ") reached MAX level, deleting...")
                        deleteUnit(unitName)
                        processedUnits[slotKey] = true
                    elseif type(currentLevel) == "number" and currentLevel >= targetLevel then
                        print("Slot " .. slot .. " (" .. unitName .. ") reached level " .. currentLevel .. ", deleting...")
                        deleteUnit(unitName)
                        processedUnits[slotKey] = true
                    end
                end
            end
        else
            lastCheckedLevels["slot_" .. slot] = nil
        end
    end
end

local function autoSellUnitLoop()
        if State.AutoSellUnitChoice[1] and State.AutoSellUnitChoice[1] ~= "No Unit" then
        local slotNumber = tonumber(State.AutoSellUnitChoice[1]:match("Unit(%d)"))
        if slotNumber then
            local unitName = getUnitNameFromSlot(slotNumber)
            if unitName then
                if not isSlotOnCooldown(slotNumber) then
                    deleteUnit(unitName)
                end
            end
        end
        end
end

task.spawn(function()
    while true do
        if State.AutoSellUnitChoice[1] ~= "No Unit" and not isInLobby() then
            autoSellUnitLoop()
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if State.AutoReDeployEnabled and not isInLobby() then
            checkAndRefreshUnits()
        end
        task.wait(1)
    end
end)

--//\\--

task.spawn(function()
    while true do
        task.wait(0.5) -- check every 0.5 seconds

        if State.AutoSellRarities and typeof(State.SelectedRaritiesToSell) == "table" then
            local data = GameObjects.GetData.GetData(Services.Players.LocalPlayer)
            local collection = data.Collection:GetChildren()

            for _, unit in ipairs(collection) do
                if shouldSellUnit(unit, State.SelectedRaritiesToSell) then
                    local realUnitFolder = GameObjects.getUnitFolder(Services.Players.LocalPlayer, unit)
                    if realUnitFolder then
                        local lockedFlag = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Collection[unit.Name].Lock
                        if lockedFlag.Value == false then
                            local args = {{ realUnitFolder, nil }}
                            Remotes.SellRemote:FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

    task.spawn(function()
        print("🔄 Fetching story data...")
        Data.availableStories = fetchStoryData()
        
        print("🔄 Fetching ranger stage data...")
        Data.availableRangerStages = fetchRangerStageData(Data.availableStories)

        print("🔄 Fetching raid data...")
        Data.availableRaids = fetchRaidData()
        
        print("✅ Data fetching complete!")
    end)

    task.spawn(function()
        while true do
            task.wait(0.5) -- Check every 0.5 seconds
            checkAndExecuteHighestPriority()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            StreamerMode()
        end
    end)

task.spawn(function()
    while true do
        wait(0.1)
             if State.autoDisableEndUI and not isInLobby() then
     for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
    if child.Name == "GameEndedAnimationUI" then
        child.Enabled = false
    end
end
for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
    if child.Name == "RewardsUI" then
        child.Enabled = false
    end
end
for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
    if child.Name == "Visual" then
        child.Enabled = false
    end
end
end
    end
end)
        task.spawn(function()
        while true do
            task.wait(2)
            if State.autoAfkTeleportEnabled and isInLobby() and GameObjects.AFKChamberUI.Enabled == false then
                print("🚀 Teleporting to AFK world...")
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("AFKWorldTeleport"):FireServer()
            end
        end
    end)

    task.spawn(function()
        while true do
            if State.AutoPurchaseMerchant and #Data.MerchantPurchaseTable > 0 then
                autoPurchaseItems(State.AutoPurchaseMerchant, Data.MerchantPurchaseTable, "Merchant", "Merchant")
            end
            if State.AutoPurchaseBossRush and #Data.BossRushPurchaseTable > 0 then
                autoPurchaseItems(State.AutoPurchaseBossRush, Data.BossRushPurchaseTable, "Boss_Rush", "Boss Rush")
            end
            if State.AutoPurchaseRaid and #Data.RaidPurchaseTable > 0 then
                autoPurchaseItems(State.AutoPurchaseRaid, Data.RaidPurchaseTable, "Raid_Shop", "Raid Shop")
            end
            if State.AutoPurchaseRaidCSW and #Data.RaidPurchaseTableCSW > 0 then
                autoPurchaseItems(State.AutoPurchaseRaidCSW, Data.RaidPurchaseTableCSW, "RaidCSW_Shop", "Graveyard Raid Shop")
            end
            if State.AutoPurchaseRiftStorm and #Data.RiftStormPurchaseTable > 0 then
                autoPurchaseItems(State.AutoPurchaseRiftStorm, Data.RiftStormPurchaseTable, "Rift_Storm", "Rift Storm Shop")
            end
            if State.AutoPurchaseSwarmEvent and #Data.SwarmEventPurchaseTable > 0 then
                autoPurchaseItems(State.AutoPurchaseSwarmEvent, Data.SwarmEventPurchaseTable, "Fall_Shop", "Swarm Event Shop")
            end
            task.wait(1)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(3)
           -- if isInLobby() then
            if State.autoClaimBP then
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events"):WaitForChild("ClaimBp"):FireServer("Claim All")
            end
            if State.AutoClaimQuests then
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("QuestEvent"):FireServer("ClaimAll")
            end
            if State.AutoClaimMilestones then
            local playerlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("LevelMilestone"):FireServer(tonumber(playerlevel))
               -- end
            end
        end
    end)

     task.spawn(function()
        while true do
            task.wait(1)

            if State.autoStartEnabled then
                local voteVisible = false

                pcall(function()
                    voteVisible = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
                        :WaitForChild("HUD")
                        :WaitForChild("InGame")
                        :WaitForChild("VotePlaying").Visible
                end)

                if voteVisible then
                    print("✅ Vote screen is visible — sending start signal...")
                    Remotes.StartGame:FireServer()
                    task.wait(3) -- optional cooldown between fires
                end
            end
        end
    end)

--//BUTTONS\\--

local function redeemallcodes()
    notify("Code Redemption", "Starting code redemption...", 3)
    
    local success, error = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/Codes_ARX.lua"))()
    end)
    
    if not success then
        notify("Error", "Failed to load code script", 5)
        warn("❌ Failed to load script: " .. tostring(error))
    end
end

local function updateFPSLimit()
    if State.enableLimitFPS and State.SelectedFPS > 0 then
        setfpscap(State.SelectedFPS)
    else
        setfpscap(0) -- 0 = unlimited
    end
end

local function getCurrentGems()
    local leaderstats = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data
    if leaderstats then
        local gems = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gem
        if gems then
            return gems.Value
        end
    end
    return 0
end

local function showUnitInventory()
    local playerGui = Services.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local unitInventory = playerGui:FindFirstChild("Collection")
        if unitInventory then
            unitInventory.Enabled = true
            unitInventory.Main.Visible = true
            task.wait(0.5)
            return true
        end
    end
    return false
end

local function takeUnitSnapshot()
    local units = {}
    local playerGui = Services.Players.LocalPlayer:FindFirstChild("PlayerGui")
    
    if playerGui then
        local unitInventory =playerGui:FindFirstChild("Collection").Main.Base.Space.Unit
        if unitInventory then
            for _, unitFrame in pairs(unitInventory:GetDescendants()) do
                if unitFrame:IsA("TextButton") then
                    local unitName = unitFrame.Name
                    if unitName then
                        local name = unitName
                        units[name] = (units[name] or 0) + 1
                    end
                end
            end
        end
    end
    return units
end

local function compareUnits(before, after)
    local newUnits = {}
    
    for unitName, afterCount in pairs(after) do
        local beforeCount = before[unitName] or 0
        local difference = afterCount - beforeCount
        
        if difference > 0 then
            newUnits[unitName] = difference
        end
    end
    
    return newUnits
end

local function sendSummaryWebhook(newUnits, totalGems)
    -- Replace with your webhook URL
    local webhookUrl = ValidWebhook
    
    if not webhookUrl or webhookUrl == "YOUR_WEBHOOK_URL_HERE" then
        print("No webhook URL configured")
        return
    end
    
    local embed = {
        title = "🎲 Auto Summon Results",
        color = 3447003, -- Blue color
        fields = {
            -- Gems spent at the top
            {
                name = "💎 Gems Spent",
                value = totalGems,
                inline = false
            }
        },
        footer = {
            text = "discord.gg/cYKnXE2Nf8"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    -- Add new units to embed (after gems spent)
    for unitName, count in pairs(newUnits) do
        table.insert(embed.fields, {
            name = unitName,
            value = "x" .. count,
            inline = true
        })
    end
    
    if #embed.fields == 1 then -- Only gems field exists
        embed.description = "No new units obtained this session."
    end
    
    local data = {
        embeds = {embed}
    }
    
    -- Use executor webhook function
    local success, result = pcall(function()
        if syn and syn.request then
            -- Synapse X
            return syn.request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Services.HttpService:JSONEncode(data)
            })
        elseif request then
            -- Script-Ware, Krnl, etc.
            return request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Services.HttpService:JSONEncode(data)
            })
        elseif http_request then
            -- Some other executors
            return http_request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Services.HttpService:JSONEncode(data)
            })
        else
            error("No HTTP request function available")
        end
    end)
    
    if success then
        print("📤 Webhook sent successfully!")
    else
        print("❌ Failed to send webhook:", result)
    end
end

local function doSummon()
    local args = {
        "10x",
        State.AutoSummonBannerSelected,
        {
            Epic = true,
            Legendary = true,
            Rare = true
        }
    }
    
    pcall(function()
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gambling"):WaitForChild("UnitsGacha"):FireServer(unpack(args))
    end)
end

local function startAutoSummon()
    if not isInLobby() then return end
    if autoSummonActive then return end
    if not State.enableAutoSummon then return end
    if not State.AutoSummonBannerSelected then return end
    
    autoSummonActive = true
    print("🎰 Starting Auto Summon...")
    notify("Auto Summon","Starting Auto Summon...")
    
    if not showUnitInventory() then
        print("❌ Failed to show unit inventory")
        autoSummonActive = false
        return
    end
    
    initialUnits = takeUnitSnapshot()
    print("📸 Initial units snapshot taken")
    
    local initialGems = getCurrentGems()
    Services.Players.LocalPlayer:SetAttribute("InitialGems", initialGems)
    
    -- UI keeping task - runs independently
    local uiTask = task.spawn(function()
        while autoSummonActive do
            local playerGui = Services.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local collection = playerGui:FindFirstChild("Collection")
                if collection and collection.Main then
                    collection.Main.Visible = true
                    collection.Enabled = true
                end
            end
            task.wait(0.1) -- Keep UI enabled every 0.1 seconds
        end
    end)
    
    -- Main summoning task
    summonTask = task.spawn(function()
        while autoSummonActive do
            local currentGems = getCurrentGems()
            
            if currentGems < 500 then
                print("💎 Not enough gems! Stopping auto summon...")
                notify("Auto Summon","Not enough gems! Stopping auto summon...")
                Services.Players.LocalPlayer.PlayerGui.HUD.Enabled = true
                break
            end
            
            doSummon()
            print("🎲 Summoned! Gems remaining:", currentGems)
            
            task.wait(3) -- Normal 3 second delay between summons
        end
        
        -- Auto summon stopped - generate summary
        local finalGems = getCurrentGems()
        gemsSpent = initialGems - finalGems
        
        task.wait(1) -- Wait for inventory to update
        local finalUnits = takeUnitSnapshot()
        local newUnits = compareUnits(initialUnits, finalUnits)
        
        -- Send webhook if any units were obtained
        local hasNewUnits = false
        for _, count in pairs(newUnits) do
            if count > 0 then
                hasNewUnits = true
                break
            end
        end
        
        if hasNewUnits then
            sendSummaryWebhook(newUnits, gemsSpent)
            print("📊 Summary sent to webhook!")
        else
            print("📊 No new units obtained")
        end
        
        autoSummonActive = false
        print("🛑 Auto Summon stopped")
    end)
end

-- Function to stop auto summon
local function stopAutoSummon()
    if not autoSummonActive then return end
    
    autoSummonActive = false
    if summonTask then
        task.cancel(summonTask)
        summonTask = nil
        Services.Players.LocalPlayer.PlayerGui.HUD.Enabled = true
    end
    
    -- Generate summary even when manually stopped
    task.spawn(function()
        local finalGems = getCurrentGems()
        local gemsSpent = (Services.Players.LocalPlayer:GetAttribute("InitialGems") or getCurrentGems()) - finalGems
        
        task.wait(1) -- Wait for inventory to update
        local finalUnits = takeUnitSnapshot()
        local newUnits = compareUnits(initialUnits, finalUnits)
        
        -- Send webhook if any units were obtained
        local hasNewUnits = false
        for _, count in pairs(newUnits) do
            if count > 0 then
                hasNewUnits = true
                break
            end
        end
        
        if hasNewUnits then
            sendSummaryWebhook(newUnits, gemsSpent)
            print("📊 Summary sent to webhook!")
        else
            print("📊 No new units obtained")
        end
    end)
    
    print("🛑 Auto Summon manually stopped")
end

local GameSection = LobbyTab:CreateSection("🏨 Lobby 🏨")

CodeButton = LobbyTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        redeemallcodes()
    end,
})

local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Summon",
    CurrentValue = false,
    Flag = "enableAutoSummon",
    Info = "Will start summoning on selected banner, to send obtained units webhook make sure you set your webhook id and then turn off the toggle. If your UI bugs after using this simply rejoin.",
    TextScaled = true,
    Callback = function(Value)
        State.enableAutoSummon = Value
        if Value then
            startAutoSummon()
        else
            stopAutoSummon()
        end
    end,
})

local Dropdown = LobbyTab:CreateDropdown({
   Name = "Auto Summon Bannter",
   Options = {"Standard","Rateup"},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "AutoSummonBannerSelection",
   Callback = function(Options)
        State.AutoSummonBannerSelected = Options[1]
   end,
})

local Button = LobbyTab:CreateButton({
        Name = "Load Item Tracker",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/DanyGamerzz0/test/refs/heads/main/item.lua"))()
        end,
    })

 GameSection = LobbyTab:CreateSection("🔮 Auto Curse 🔮")

local AutoCurseToggle = LobbyTab:CreateToggle({
    Name = "Auto Curse",
    CurrentValue = false,
    Flag = "AutoCurseToggle",
    Info = "Open curse UI and select unit manually before enabling.",
    TextScaled = false,
    Callback = function(Value)
        State.AutoCurseEnabled = Value
        if #State.selectedCurses >= 1 and State.AutoCurseEnabled then
            StartAutoCurse(State.selectedCurses)
        elseif Value and #State.selectedCurses < 1 then
            notify("Auto Curse", "Please select at least 1 curse first!")
        end
    end,
})

local CurseSelectorDropdown = LobbyTab:CreateDropdown({
    Name = "Select Curses",
    Options = {"Ability Damage","Ability Cooldown","Health","Damage","Attack Cooldown","Range","Speed"},
    CurrentOption = "Ability Damage",
    MultipleOptions = true,
    Flag = "CurseSelector",
    Callback = function(Options)
        State.selectedCurses = Options
        if State.AutoCurseEnabled and #Options < 1 then
            State.AutoCurseEnabled = false
            AutoCurseToggle:Set(false)
            notify("Auto Curse", "Auto curse disabled - need at least 1 curse selected!")
        end
    end,
})

local CurseRequirementsDropdown = LobbyTab:CreateDropdown({
    Name = "Set Requirements For",
    Options = {"Ability Damage","Ability Cooldown","Health","Damage","Attack Cooldown","Range","Speed"},
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "CurseRequirementsSelector",
    Info = "Select which curse to set minimum percentage for",
    Callback = function(Option)
        State.selectedCurseForRequirement = Option[1]
    end,
})

local CurseMinimumSlider = LobbyTab:CreateSlider({
    Name = "Minimum Percentage",
    Range = {1, 15},
    Increment = 1,
    CurrentValue = 1,
    Flag = "CurseMinimumPercentage",
    Info = "Minimum percentage for the selected curse",
    Callback = function(Value)
        if State.selectedCurseForRequirement then
            State.curseMinimums[State.selectedCurseForRequirement] = Value
            notify("Auto Curse", string.format("Set %s minimum to %d%%", State.selectedCurseForRequirement, Value))
        end
    end,
})

local ShowRequirementsButton = LobbyTab:CreateButton({
    Name = "Show Current Requirements",
    Callback = function()
        local requirements = {}
        for curse, minPercent in pairs(State.curseMinimums) do
            table.insert(requirements, string.format("%s: %d%%", curse, minPercent))
        end
        if #requirements > 0 then
            notify("Requirements", table.concat(requirements, ", "))
        else
            notify("Requirements", "No requirements set")
        end
    end,
})

local ResetButton = LobbyTab:CreateButton({
    Name = "Reset All Settings",
    Callback = function()
        State.selectedCurses = {}
        State.curseMinimums = {}
        CurseSelectorDropdown:Set({})
        notify("Auto Curse", "All settings cleared")
    end,
})

GameSection = LobbyTab:CreateSection("💎 Auto Trait 💎")

local AutoTraitToggle = LobbyTab:CreateToggle({
    Name = "Auto Reroll Traits",
    CurrentValue = false,
    Flag = "AutoTraitToggle",
    Info = "Open trait UI and select unit manually before enabling.",
    TextScaled = false,
    Callback = function(Value)
        State.AutoRerollEnabled = Value
        if #State.selectedTraits >= 1 and State.AutoRerollEnabled then
            StartAutoReroll(State.selectedTraits)
        elseif Value and #State.selectedTraits < 1 then
            notify("Auto Reroll", "Please select at least 1 trait first!")
        end
    end,
})

local TraitSelectorDropdown = LobbyTab:CreateDropdown({
    Name = "Select Traits",
    Options = {"Endure I","Endure II","Endure III","Horizon I","Horizon II","Horizon III","Superior I","Superior II","Superior III","Brute","Sniper","Colossal","Investor","Jokester","Blitz","Juggernaut","Millionaire","Violent","Seraph","Capitalist","Duplicator","Sovereign"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "TraitSelector",
    Callback = function(Options)
        State.selectedTraits = Options
        if State.AutoRerollEnabled and #Options < 1 then
            State.AutoRerollEnabled = false
            AutoTraitToggle:Set(false)
            notify("Auto Reroll", "Auto reroll disabled - need at least 1 trait selected!")
        end
    end,
})

local DoubleTraitToggle = LobbyTab:CreateToggle({
    Name = "Roll Only Double Traits",
    CurrentValue = false,
    Flag = "DoubleTraitToggle",
    Info = "When enabled, will only stop when 2 selected traits are found (1 in main trait, 1 in sub-trait).",
    TextScaled = false,
    Callback = function(Value)
        State.rollOnlyDoubleTraits = Value
    end,
})

GameSection = LobbyTab:CreateSection("⚙️ Auto Gear ⚙️")

local GearSelectorDropdown = LobbyTab:CreateDropdown({
    Name = "Select Gears",
    Options = GetAllGearNames(),
    CurrentOption = GetAllGearNames()[1],
    MultipleOptions = true,
    Flag = "GearSelector",
    Callback = function(Options)
        State.selectedGears = Options
        
        -- Reset craft amounts for unselected gears
        local newCraftAmounts = {}
        for _, gearName in ipairs(Options) do
            newCraftAmounts[gearName] = State.craftAmounts[gearName] or 1
        end
        State.craftAmounts = newCraftAmounts
        
        if State.AutoFarmEnabled and #Options == 0 then
            State.AutoFarmEnabled = false
            AutoGearFarmToggle:Set(false)
            notify("Auto Gear Farm", "Auto farm disabled - need at least 1 gear selected!")
        end
    end,
})

local GearAmountSelector = LobbyTab:CreateDropdown({
    Name = "Set Amount For",
    Options = GetAllGearNames(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "GearAmountSelector",
    Info = "Select which gear to set craft amount for",
    Callback = function(Option)
        State.selectedGearForAmount = Option[1]
    end,
})

local CraftAmountSlider = LobbyTab:CreateSlider({
    Name = "Craft Amount",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 1,
    Flag = "CraftAmount",
    Info = "Amount to craft for the selected gear",
    Callback = function(Value)
        if State.selectedGearForAmount then
            State.craftAmounts[State.selectedGearForAmount] = Value
            notify("Auto Gear Farm", string.format("Set %s amount to %d", State.selectedGearForAmount, Value))
        end
    end,
})

local AnalyzeStagesButton = LobbyTab:CreateButton({
    Name = "Analyze Required Stages",
    Callback = function()
        AnalyzeRequiredStages()
    end,
})

local ShowRequiredMaterialsButton = LobbyTab:CreateButton({
    Name = "Show Required Materials",
    Callback = function()
        if #State.selectedGears == 0 then
            notify("Required Materials", "No gears selected!")
            return
        end
        
        local totalNeeded = CalculateTotalMaterialsNeeded()
        local inventory = GetPlayerInventory()
        
        local materialsList = {}
        for materialName, needed in pairs(totalNeeded) do
            local current = inventory[materialName] or 0
            local status = current >= needed and "✓" or "✗"
            table.insert(materialsList, string.format("%s %s: %d/%d", status, materialName, current, needed))
        end
        
        if #materialsList > 0 then
            notify("Required Materials", table.concat(materialsList, "\n"))
        else
            notify("Required Materials", "No materials needed!")
        end
    end,
})

local ShowCraftAmountsButton = LobbyTab:CreateButton({
    Name = "Show Craft Amounts",
    Callback = function()
        local amounts = {}
        for gearName, amount in pairs(State.craftAmounts) do
            if amount > 0 then
                table.insert(amounts, string.format("%s: %dx", gearName, amount))
            end
        end
        
        if #amounts > 0 then
            notify("Craft Amounts", table.concat(amounts, "\n"))
        else
            notify("Craft Amounts", "No craft amounts set!")
        end
    end,
})

local ResetGearSettingsButton = LobbyTab:CreateButton({
    Name = "Reset All Gear Settings",
    Callback = function()
        State.selectedGears = {}
        State.craftAmounts = {}
        State.totalMaterialsNeeded = {}
        GearSelectorDropdown:Set({})
        notify("Auto Gear Farm", "All gear settings cleared!")
    end,
})

-- Helper function to show gear info
local ShowGearInfoButton = LobbyTab:CreateButton({
    Name = "Show Gear Info",
    Callback = function()
        if not State.selectedGearForAmount then
            notify("Gear Info", "Please select a gear first!")
            return
        end
        
        local gearName = State.selectedGearForAmount
        local gearData = GearData[gearName]
        
        if not gearData then
            notify("Gear Info", "Gear data not found!")
            return
        end
        
        local requirements = {}
        for materialName, amount in pairs(gearData.Requirement) do
            local sources = FindMaterialSource(materialName)
            local sourceInfo = ""
            
            if #sources > 0 then
                sourceInfo = string.format(" (found in %d stages)", #sources)
            else
                sourceInfo = " (source unknown)"
            end
            
            table.insert(requirements, string.format("%s: %d%s", materialName, amount, sourceInfo))
        end
        
        local info = string.format("%s\nCost: %d Gold\n\nMaterials:\n%s", 
            gearName, gearData.Cost, table.concat(requirements, "\n"))
        
        notify("Gear Info", info)
    end,
})

GameSection = LobbyTab:CreateSection("⚙️ Misc ⚙️")

local Button = LobbyTab:CreateButton({
        Name = "Return to lobby",
        Callback = function()
            notify("Return to lobby", "Returning to lobby!")
            Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
        end,
    })

    local Label5 = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

    local GameSection = GameTab:CreateSection("👥 Player 👥")

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
    Name = "Low Performance Mode",
    CurrentValue = false,
    Flag = "enableLowPerformanceMode",
    Callback = function(Value)
        State.enableLowPerformanceMode = Value
        enableLowPerformanceMode()
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Black Screen",
    CurrentValue = false,
    Flag = "enableBlackScreen",
    Callback = function(Value)
        State.enableBlackScreen = Value
        enableBlackScreen()
    end,
})

local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Execute Script",
    CurrentValue = false,
    Flag = "enableAutoExecute",
    Info = "This auto executes and persists through teleports until you disable it or leave the game.",
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

     Toggle = GameTab:CreateToggle({
    Name = "Delete Map",
    CurrentValue = false,
    Flag = "enableDeleteMap",
    Info = "Rejoin to disable.",
    TextScaled = false,
    Callback = function(Value)
        State.enableDeleteMap = Value
        enableDeleteMap()
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
            -- Approach 1: Event-based instant deletion (most efficient)
            task.spawn(function()
                local agentFolder = workspace:FindFirstChild("Agent")
                if agentFolder then
                    local agentSubFolder = agentFolder:FindFirstChild("Agent")
                    if agentSubFolder then
                        -- Delete existing models first
                        for _, model in pairs(agentSubFolder:GetChildren()) do
                            if model and model.Parent then
                                model:Destroy()
                            end
                        end
                        
                        -- Set up instant deletion for new spawns
                        State.childAddedConnection = agentSubFolder.ChildAdded:Connect(function(child)
                            if State.deleteEntities and child then
                                child:Destroy() -- Delete immediately when spawned
                            end
                        end)
                    end
                end
            end)
        else
            -- Clean up connection when disabled
            if State.childAddedConnection then
                State.childAddedConnection:Disconnect()
                State.childAddedConnection = nil
            end
        end
    end,
})

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

if State.enableLowPerformanceMode then
    enableLowPerformanceMode()
end

if State.enableDeleteMap then
    enableDeleteMap()
end

local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Sell Rarities",
    CurrentValue = false,
    Flag = "AutoSellRarities",
    Info = "",
    TextScaled = false,
    Callback = function(Value)
        State.AutoSellRarities = Value
    end,
})

local RaritySellerDropdown = LobbyTab:CreateDropdown({
    Name = "Select Rarities To Sell",
    Options = {"Rare", "Epic", "Legendary", "Shiny"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "RaritySellerSelector",
    Info = "This won't touch locked units of any type.",
    TextScaled = false,
    Callback = function(Options)
        State.SelectedRaritiesToSell = Options
    end,
})

 GameSection = ShopTab:CreateSection("💰 Merchant 💰")

 Toggle = ShopTab:CreateToggle({
    Name = "Auto Purchase Merchant Items",
    CurrentValue = false,
    Flag = "AutoPurchaseMerchant",
    Callback = function(Value)
        State.AutoPurchaseMerchant = Value
    end,
    })

      MerchantSelectorDropdown = ShopTab:CreateDropdown({
    Name = "Select Items To Purchase (Merchant)",
    Options = {"Dr. Megga Punk","Cursed Finger","Perfect Stats Key","Stats Key","Trait Reroll","Ranger Crystal","Soul Fragments"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "MerchantPurchaseSelector",
    Callback = function(Options)
        Data.MerchantPurchaseTable = Options
    end,
    })

 GameSection = ShopTab:CreateSection("🔪 Raid Shop 🔪")

     Toggle = ShopTab:CreateToggle({
    Name = "Auto Purchase Raid Shop",
    CurrentValue = false,
    Flag = "AutoPurchaseRaid",
    Callback = function(Value)
        State.AutoPurchaseRaid = Value
    end,
    })

      MerchantSelectorDropdown = ShopTab:CreateDropdown({
    Name = "Select Items To Purchase (Raid)",
    Options = {"Dr. Megga Punk","Cursed Finger","Perfect Stats Key","Stats Key","Trait Reroll"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "RaidPurchaseSelector",
    Callback = function(Options)
        Data.RaidPurchaseTable = Options
    end,
    })

 GameSection = ShopTab:CreateSection("👹 Boss Rush Shop 👹")

     Toggle = ShopTab:CreateToggle({
    Name = "Auto Purchase Boss Rush Shop",
    CurrentValue = false,
    Flag = "AutoPurchaseBossRush",
    Callback = function(Value)
        State.AutoPurchaseBossRush = Value
    end,
    })

      MerchantSelectorDropdown = ShopTab:CreateDropdown({
    Name = "Select Items To Purchase (Boss Rush)",
    Options = {"Dr. Megga Punk","Perfect Stats Key","Stats Key","Trait Reroll","Soul Fragments"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "BossRushPurchaseSelector",
    Callback = function(Options)
        Data.BossRushPurchaseTable = Options
    end,
    })

 GameSection = ShopTab:CreateSection("⚰️ Graveyard Raid Shop ⚰️")

     Toggle = ShopTab:CreateToggle({
    Name = "Auto Purchase Graveyard Raid Shop",
    CurrentValue = false,
    Flag = "AutoPurchaseRaidCSW",
    Callback = function(Value)
        State.AutoPurchaseRaidCSW = Value
    end,
    })

     MerchantSelectorDropdown = ShopTab:CreateDropdown({
    Name = "Select Items To Purchase (Graveyard Raid Shop)",
    Options = {"Cursed Finger","Perfect Stats Key","Stats Key","Trait Reroll"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "RaidPurchaseSelectorCSW",
    Callback = function(Options)
        Data.RaidPurchaseTableCSW = Options
    end,
    })

local GameSection = ShopTab:CreateSection("🌀 Rift Storm Shop 🌀")

    local Toggle = ShopTab:CreateToggle({
    Name = "Auto Purchase Rift Storm Shop",
    CurrentValue = false,
    Flag = "AutoPurchaseRiftStorm",
    Callback = function(Value)
        State.AutoPurchaseRiftStorm = Value
    end,
    })

     local MerchantSelectorDropdown = ShopTab:CreateDropdown({
    Name = "Select Items To Purchase (Rift Storm Shop)",
    Options = {"Dr. Megga Punk","Perfect Stats Key","Stats Key","Trait Reroll","Cursed Finger","Ranger Crystal"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "RiftStormPurchaseSelector",
    Callback = function(Options)
        Data.RiftStormPurchaseTable = Options
    end,
    })

 GameSection = ShopTab:CreateSection("⚱️ Swarm Event Shop ⚱️")

     Toggle = ShopTab:CreateToggle({
    Name = "Auto Purchase Swarm Event Shop",
    CurrentValue = false,
    Flag = "AutoPurchaseSwarmEvent",
    Callback = function(Value)
        State.AutoPurchaseSwarmEvent = Value
    end,
    })

      MerchantSelectorDropdown = ShopTab:CreateDropdown({
    Name = "Select Items To Purchase (Swarm Event Shop)",
    Options = {"Dr. Megga Punk","Perfect Stats Key","Stats Key","Trait Reroll","Cursed Finger","Stat Boosters","Soul Fragments","Borus Capsule"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SwarmEventPurchaseSelector",
    Callback = function(Options)
        Data.SwarmEventPurchaseTable = Options
    end,
    })

     GameSection = LobbyTab:CreateSection("🎁 Claimers 🎁")

     Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Battlepass",
    CurrentValue = false,
    Flag = "AutoClaimBattlepass",
    Callback = function(Value)
        State.autoClaimBP = Value
    end,
    })

     Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Quests",
    CurrentValue = false,
    Flag = "AutoClaimQuests",
    Callback = function(Value)
        State.AutoClaimQuests = Value
    end,
    })

     Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Level Milestones",
    CurrentValue = false,
    Flag = "AutoClaimMilestones",
    Callback = function(Value)
        State.AutoClaimMilestones = Value
    end,
    })

     GameSection = LobbyTab:CreateSection("💤 AFK Chamber 💤")

    Toggle = LobbyTab:CreateToggle({
        Name = "Auto Teleport to AFK Chamber",
        CurrentValue = false,
        Flag = "AutoAfkTeleportToggle",
        Callback = function(Value)
            State.autoAfkTeleportEnabled = Value
        end,
    })

         Toggle = LobbyTab:CreateToggle({
    Name = "Anti Teleport to AFK Chamber",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Callback = function(Value)
        State.AntiAfkEnabled = Value
    end,
})

task.spawn(function()
    while true do
        if State.AntiAfkEnabled then
            Services.Workspace:WaitForChild(Services.Players.LocalPlayer.Name):FindFirstChild("AFK").Disabled = true
        else
            Services.Workspace:WaitForChild(Services.Players.LocalPlayer.Name):FindFirstChild("AFK").Disabled = false
        end
        task.wait(5)
    end
end)

      Toggle = GameTab:CreateToggle({
    Name = "Streamer Mode (hide name/level/title)",
    CurrentValue = false,
    Flag = "streamerModeEnabled",
    Callback = function(Value)
        State.streamerModeEnabled = Value
    end,
})

     JoinerSection0 = JoinerTab:CreateSection("🤖 Boss Rush Joiner 🤖")

     Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Boss Rush",
    CurrentValue = false,
    Flag = "AutoBossRushToggle",
    Callback = function(Value)
        State.autoBossRushEnabled = Value
    end,
    })

     JoinerSection98285728 = JoinerTab:CreateSection("🎮 Advanced AutoPlay 🎮")

     Toggle = JoinerTab:CreateToggle({
    Name = "Auto Select Path For Boss Rush/Rift Storm",
    CurrentValue = false,
    Flag = "AutoPlayBossRush",
    Callback = function(Value)
        State.autoPlayBossRushEnabled = Value  
    end,
    })

task.spawn(function()
    while true do
        if State.autoPlayBossRushEnabled and State.gameRunning then
            local pathData = scanBossRushPaths()
            local bestPath, enemyCount, unitCount = getBestBossRushPath(pathData)
            
            if bestPath ~= State.currentBossPath and enemyCount > 0 then
                Remotes.SelectWay:FireServer(bestPath)
                State.currentBossPath = bestPath
            end
        end
        task.wait(0.5)
    end
end)

 Toggle = JoinerTab:CreateToggle({
    Name = "Advanced Auto Play (pair with select path(s) to deploy unit x on)",
    CurrentValue = false,
    Flag = "AutoBossRushDeployToggle",
    Callback = function(Value)
        State.bossRushAutoDeployEnabled = Value
        
        if Value then
            startBossRushAutoPlay()
        else
            stopBossRushAutoPlay()
        end
    end,
})

 DeployBossRushSelector1 = JoinerTab:CreateDropdown({
    Name = "Select path(s) to deploy unit 1 on",
    Options = {"Path 1","Path 2","Path 3","Path 4"},
    CurrentOption = {},
    MultipleOptions = true, -- Changed to true for multiple path selection
    Flag = "DeployBossRushSelector1",
    Callback = function(Options)
        local paths = {}
        if type(Options) == "table" then
            for _, pathString in pairs(Options) do
                local pathNum = pathStringToNumber(pathString)
                if pathNum then
                    table.insert(paths, pathNum)
                end
            end
        else
            -- Single option selected
            local pathNum = pathStringToNumber(Options)
            if pathNum then
                paths = {pathNum}
            end
        end
        
        setBossRushSlotPaths(1, paths)
        setBossRushSlotEnabled(1, #paths > 0) -- Enable if paths are selected
    end,
})

 DeployBossRushSelector2 = JoinerTab:CreateDropdown({
    Name = "Select path(s) to deploy unit 2 on",
    Options = {"Path 1","Path 2","Path 3","Path 4"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "DeployBossRushSelector2",
    Callback = function(Options)
        local paths = {}
        if type(Options) == "table" then
            for _, pathString in pairs(Options) do
                local pathNum = pathStringToNumber(pathString)
                if pathNum then
                    table.insert(paths, pathNum)
                end
            end
        else
            local pathNum = pathStringToNumber(Options)
            if pathNum then
                paths = {pathNum}
            end
        end
        
        setBossRushSlotPaths(2, paths)
        setBossRushSlotEnabled(2, #paths > 0)
    end,
})

 DeployBossRushSelector3 = JoinerTab:CreateDropdown({
    Name = "Select path(s) to deploy unit 3 on",
    Options = {"Path 1","Path 2","Path 3","Path 4"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "DeployBossRushSelector3",
    Callback = function(Options)
        local paths = {}
        if type(Options) == "table" then
            for _, pathString in pairs(Options) do
                local pathNum = pathStringToNumber(pathString)
                if pathNum then
                    table.insert(paths, pathNum)
                end
            end
        else
            local pathNum = pathStringToNumber(Options)
            if pathNum then
                paths = {pathNum}
            end
        end
        
        setBossRushSlotPaths(3, paths)
        setBossRushSlotEnabled(3, #paths > 0)
    end,
})

 DeployBossRushSelector4 = JoinerTab:CreateDropdown({
    Name = "Select path(s) to deploy unit 4 on",
    Options = {"Path 1","Path 2","Path 3","Path 4"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "DeployBossRushSelector4",
    Callback = function(Options)
        local paths = {}
        if type(Options) == "table" then
            for _, pathString in pairs(Options) do
                local pathNum = pathStringToNumber(pathString)
                if pathNum then
                    table.insert(paths, pathNum)
                end
            end
        else
            local pathNum = pathStringToNumber(Options)
            if pathNum then
                paths = {pathNum}
            end
        end
        
        setBossRushSlotPaths(4, paths)
        setBossRushSlotEnabled(4, #paths > 0)
    end,
})

 DeployBossRushSelector5 = JoinerTab:CreateDropdown({
    Name = "Select path(s) to deploy unit 5 on",
    Options = {"Path 1","Path 2","Path 3","Path 4"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "DeployBossRushSelector5",
    Callback = function(Options)
        local paths = {}
        if type(Options) == "table" then
            for _, pathString in pairs(Options) do
                local pathNum = pathStringToNumber(pathString)
                if pathNum then
                    table.insert(paths, pathNum)
                end
            end
        else
            local pathNum = pathStringToNumber(Options)
            if pathNum then
                paths = {pathNum}
            end
        end
        
        setBossRushSlotPaths(5, paths)
        setBossRushSlotEnabled(5, #paths > 0)
    end,
})

 DeployBossRushSelector6 = JoinerTab:CreateDropdown({
    Name = "Select path(s) to deploy unit 6 on",
    Options = {"Path 1","Path 2","Path 3","Path 4"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "DeployBossRushSelector6",
    Callback = function(Options)
        local paths = {}
        if type(Options) == "table" then
            for _, pathString in pairs(Options) do
                local pathNum = pathStringToNumber(pathString)
                if pathNum then
                    table.insert(paths, pathNum)
                end
            end
        else
            local pathNum = pathStringToNumber(Options)
            if pathNum then
                paths = {pathNum}
            end
        end
        
        setBossRushSlotPaths(6, paths)
        setBossRushSlotEnabled(6, #paths > 0)
    end,
})

     JoinerSection0 = JoinerTab:CreateSection("👹 Boss Event Joiner 👹")

    --[[local AutoJoinBossEventToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Summer Event",
    CurrentValue = false,
    Flag = "AutoSummerEventToggle",
    Callback = function(Value)
        State.autoSummerEventEnabled = Value
    end,
    })--]]

     AutoJoinBossEvent2Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Boss Event (Swarm Event)",
    CurrentValue = false,
    Flag = "AutoBossEventToggle",
    Callback = function(Value)
        State.autoBossEventEnabled = Value
    end,
    })

     JoinerSection000000 = JoinerTab:CreateSection("⏳ Infinite Mode Joiner ⏳")

     AutoJoinInfiniteMode = JoinerTab:CreateToggle({
    Name = "Auto Join Infinite Mode",
    CurrentValue = false,
    Flag = "AutoInfiniteToggle",
    Callback = function(Value)
        State.autoInfiniteEnabled = Value
    end,
    })

     JoinerSection00 = JoinerTab:CreateSection("⚔️ Raid Joiner ⚔️")

      AutoJoinBossEventToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Raid",
    CurrentValue = false,
    Flag = "AutoRaidToggle",
    Callback = function(Value)
        State.autoJoinRaid = Value
    end,
    })

local RaidSelectorDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Stage(s) To Join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RaidSelector",
    Callback = function(Option)
        State.selectedRaidStages = {}
        
        -- Handle both table and string cases
        local selectedOption
        if type(Option) == "table" then
            selectedOption = Option[1] -- Get first element if it's a table
        else
            selectedOption = Option
        end
        
        print("Processing option:", selectedOption, "Type:", type(Option))
        
        -- Find which raid contains this display name
        for _, raid in ipairs(Data.raidData) do
            if raid.InternalStages[selectedOption] then
                table.insert(State.selectedRaidStages, raid.InternalStages[selectedOption])
                print("Found raid stage:", selectedOption, "-> ID:", raid.InternalStages[selectedOption])
                break
            end
        end
        
        if #State.selectedRaidStages == 0 then
            print("❌ No internal ID found for:", selectedOption)
        else
            print("Selected raid stages (internal IDs):", table.concat(State.selectedRaidStages, ", "))
        end
    end,
})

task.spawn(function()
    while #Data.raidData == 0 do
        task.wait(0.5)
    end

    local raidStageDisplayNames = {}
    for _, raid in ipairs(Data.raidData) do
        for _, displayName in ipairs(raid.DisplayStages) do
            table.insert(raidStageDisplayNames, displayName)
        end
    end

    RaidSelectorDropdown:Refresh(raidStageDisplayNames)

    print("✅ Raid dropdown updated with", #raidStageDisplayNames, "options")
end)

     JoinerSection = JoinerTab:CreateSection("📖 Story Joiner 📖")

       AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoStoryToggle",
    Callback = function(Value)
        State.autoJoinEnabled = Value
    end,
    })

      local StageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryStageSelector",
    Callback = function(Option)
        State.selectedWorld = Option[1]
    end,
    })

     ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Stage Chapter",
    Options = Config.chapters,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryChapterSelector", 
    Callback = function(Option)
        State.selectedChapter = Option[1]
    end,
    })
     DifficultyDropdown = JoinerTab:CreateDropdown({
    Name = "Select Stage Difficulty",
    Options = Config.difficulties,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector", 
    Callback = function(Option)
        State.selectedDifficulty = Option[1]
    end,
    })

    local rewardNames = {}

    for _, reward in ipairs(GameObjects.itemsFolder:GetChildren()) do
        if reward:IsA("BoolValue") then
            table.insert(rewardNames, reward.Name)
        end
    end


     JoinerSection2 = JoinerTab:CreateSection("🏆 Challenge Joiner 🏆")
    local rewardText = #rewardNames > 0 and table.concat(rewardNames, ", ") or "None"
    local Label3 = JoinerTab:CreateLabel("Current Challenge Rewards: " .. rewardText, "gift")

         Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Challenge",
    CurrentValue = false,
    Flag = "AutoChallengeToggle",
    Callback = function(Value)
        State.autoChallengeEnabled = Value
    end,
    })

    local IgnoreChallengeDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Challenge Worlds",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "IgnoreChallengeWorld",
    Callback = function(Options)
        Data.selectedChallengeWorlds = Options
    end,
})

    task.spawn(function()
        while #Data.availableStories == 0 do
            task.wait(0.5)
        end
        
        local storyNames = {}
        for _, story in ipairs(Data.availableStories) do
            table.insert(storyNames, story.SeriesName)
        end
        
        StageDropdown:Refresh(storyNames)
        IgnoreChallengeDropdown:Refresh(storyNames)
        print("✅ Story dropdown(s) updated with", #storyNames, "options")
    end)

  ChallengeDropdown = JoinerTab:CreateDropdown({
    Name = "Select Challenge Rewards",
    Options = {"Dr. Megga Punk","Ranger Crystal","Stats Key","Perfect Stats Key","Trait Reroll","Cursed Finger"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ChallengeRewardSelector",
    Callback = function(options)
        Data.wantedRewards = options
    end,
    })

     Toggle = JoinerTab:CreateToggle({
        Name = "Return to Lobby on New Challenge",
        CurrentValue = false,
        Flag = "AutoReturnChallengeToggle",
        Callback = function(Value)
            State.challengeAutoReturnEnabled = Value
        end,
    })

     JoinerSection3 = JoinerTab:CreateSection("🌀 Portal Joiner 🌀")

      Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Portal(s)",
    CurrentValue = false,
    Flag = "AutoPortalToggle",
    Callback = function(Value)
        State.autoPortalEnabled = Value
         if State.autoPortalEnabled then
            State.portalUsed = false
         end
    end,
    })

     local PortalSelectorDropdown = JoinerTab:CreateDropdown({
    Name = "Select Portal(s) to join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PortalSelector",
    Callback = function(Options)
        State.selectedPortals = Options
    end,
})

task.spawn(function()
        local portalNames = {}

        local inventory = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items
        if inventory then
            for _, item in ipairs(inventory:GetChildren()) do
                if item:IsA("Folder") and item.Name:lower():find("portal") and item:FindFirstChild("Amount").Value > 0 then
                    table.insert(portalNames, item.Name)
                end
            end
        end
        PortalSelectorDropdown:Refresh(portalNames)
end)

     JoinerSection4 = JoinerTab:CreateSection("🏹 Ranger Stage Joiner 🏹")

         Toggle = JoinerTab:CreateToggle({
        Name = "Auto Join Ranger Stage",
        CurrentValue = false,
        Flag = "AutoRangerStageToggle",
        Callback = function(Value)
            State.isAutoJoining = Value
        end,
    })

     RangerStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Ranger Stage(s) To Join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RangerStageSelector",
    Callback = function(Options)
        Data.selectedRawStages = {}
        
        for _, selectedDisplay in ipairs(Options) do
            for _, stage in ipairs(Data.availableRangerStages) do
                if stage.DisplayName == selectedDisplay then
                table.insert(Data.selectedRawStages, stage.RawName)
                break
                end
            end
        end
    end,
})

task.spawn(function()
        while #Data.availableRangerStages == 0 do
            task.wait(0.5)
        end
        
        local rangerDisplayNames = {}
        for _, stage in ipairs(Data.availableRangerStages) do
            table.insert(rangerDisplayNames, stage.DisplayName)
        end
        
        RangerStageDropdown:Refresh(rangerDisplayNames)
        print("✅ Ranger stage dropdown updated with", #rangerDisplayNames, "options")
    end)

     JoinerSectionDungeons = JoinerTab:CreateSection("🌀 Rifts 🌀")

     Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Rift Storm",
    CurrentValue = false,
    Flag = "AutoRiftToggle",
    Callback = function(Value)
        State.autoRiftEnabled = Value
    end,
    })

     JoinerSectionDungeons = JoinerTab:CreateSection("⛓️ Dungeons ⛓️")

     Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Dungeon",
    CurrentValue = false,
    Flag = "AutoDungeonToggle",
    Callback = function(Value)
        State.autoDungeonEnabled = Value
    end,
    })

    Dropdown = JoinerTab:CreateDropdown({
   Name = "Select Dungeon Difficulty",
   Options = {"Easy","Normal","Hell"},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "AutoDungeonDifficultySelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
        State.AutoDungeonDifficultySelector = Option
   end,
})

     JoinerSection6 = JoinerTab:CreateSection("🏰 Infinity Castle 🏰")

     Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Infinity Castle",
    CurrentValue = false,
    Flag = "AutoJoinInfinityCastle",
    Callback = function(Value)
        State.autoJoinInfinityCastleEnabled = Value
    end,
    })

     Toggle = JoinerTab:CreateToggle({
    Name = "Auto Select Path For Infinity Castle",
    CurrentValue = false,
    Flag = "AutoInfinityCastle",
    Callback = function(Value)
        State.autoInfinityCastleEnabled = Value
        if State.autoInfinityCastleEnabled then
            startInfinityCastleLogic()
        else
            stopInfinityCastleLogic()
        end
    end,
    })

     GameSection = GameTab:CreateSection("🎮 Game 🎮")
    --local Label4 = JoinerTab:CreateLabel("You need decently good units for infinity castle to win. Don't use any other auto joiners if you're enabling this and don't panic if it fails sometimes (unless your units are not good enough).", "badge-info")

 Dropdown = GameTab:CreateDropdown({
   Name = "AutoSell Unit",
   Options = {"No Unit","Unit1","Unit2","Unit3","Unit4","Unit5","Unit6"},
   CurrentOption = {"No Unit"},
   MultipleOptions = false,
   Info = "Will remove the unit as soon as cd is over.",
   TextScaled = false,
   Flag = "AutoSellUnitDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
        State.AutoSellUnitChoice = Option
   end,
})

     Toggle = GameTab:CreateToggle({
    Name = "Auto 1x/2x/3x Speed",
    CurrentValue = false,
    Flag = "AutoSpeedToggle",
    Callback = function(Value)
        State.AutoSelectSpeed = Value
       
    end,
})

     AutoSpeedDropdown = GameTab:CreateDropdown({
    Name = "Select Auto Speed Value",
    Options = {"1x","2x","3x"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoSpeedSelector",
    Callback = function(Options)
       State.SelectedSpeedValue = Options
    end,
})

task.spawn(function()
    while true do
        if State.AutoSelectSpeed and State.SelectedSpeedValue then
            local raw = State.SelectedSpeedValue
            local value = type(raw) == "table" and raw[1] or raw
            local clean = tostring(value):gsub("[^%d]", "")
            local speedNum = tonumber(clean)
            if speedNum then
                game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("SpeedGamepass"):FireServer(speedNum)
            end
        end
        task.wait(1)
    end
end)

      Toggle = GameTab:CreateToggle({
    Name = "Auto Start Game",
    CurrentValue = false,
    Flag = "AutoStartToggle",
    Callback = function(Value)
        State.autoStartEnabled = Value
    end,
    })

     Toggle = GameTab:CreateToggle({
    Name = "Auto Vote Next",
    CurrentValue = false,
    Flag = "AutoNextToggle",
    Callback = function(Value)
        State.autoNextEnabled = Value
        if State.autoNextEnabled then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteNext"):FireServer()
        end
    end,
    })

     Toggle = GameTab:CreateToggle({
    Name = "Auto Vote Retry",
    CurrentValue = false,
    Flag = "AutoRetryToggle",
    Callback = function(Value)
        State.autoRetryEnabled = Value
        if State.autoRetryEnabled then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteRetry"):FireServer()
        end
    end,
    })

     Toggle = GameTab:CreateToggle({
    Name = "Auto Teleport to Lobby",
    CurrentValue = false,
    Flag = "AutoLobbyToggle", 
    Callback = function(Value)
        State.autoReturnEnabled = Value
        if State.hasGameEnded and State.autoReturnEnabled then
            Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
        end
    end,
    })

     Toggle = GameTab:CreateToggle({
    Name = "Disable Reward Screen UI",
    CurrentValue = false,
    Flag = "AutoDisableEndUI",
    Callback = function(Value)
        State.autoDisableEndUI = Value
    end,
    })

     Toggle = GameTab:CreateToggle({
    Name = "Enable Game Failsafe",
    CurrentValue = false,
    Flag = "AutoFailSafeEnabled",
    Info = "Will teleport to lobby after x amount of seconds of game inactivity.",
    TextScaled = false,
    Callback = function(Value)
        State.AutoFailSafeEnabled = Value
    end,
    })

     Slider = GameTab:CreateSlider({
   Name = "Start Failsafe after",
   Range = {1, 3600},
   Increment = 1,
   Suffix = "seconds",
   CurrentValue = 300,
   Flag = "FailsafeSlider",
   Callback = function(Value)
        State.AutoFailSafeNumber = Value
   end,
})

 GameSection = AutoPlayTab:CreateSection("👥 Auto Team Selector 👥")

     Toggle = AutoPlayTab:CreateToggle({
    Name = "Enable x team for x mode",
    CurrentValue = false,
    Flag = "AutoTeamModeSlotEnabler",
    Callback = function(Value)
        State.autoTeamSlotPicker = Value
    end,
    })

     TeamSelectorDropdown1 = AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 1",
    Options = {"Story","Challenge","Ranger","Raid","Boss Rush","Summer Event","Boss Event","Portal","InfCastle","RiftStorm","Dungeon","Infinite"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector1",
    Callback = function(Options)
        State.modeTeamSelector1 = Options
    end,
    })

      TeamSelectorDropdown2 = AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 2",
    Options = {"Story","Challenge","Ranger","Raid","Boss Rush","Summer Event","Boss Event","Portal","InfCastle","RiftStorm","Dungeon","Infinite"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector2",
    Callback = function(Options)
        State.modeTeamSelector2 = Options
    end,
    })

      TeamSelectorDropdown3 = AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 3",
    Options = {"Story","Challenge","Ranger","Raid","Boss Rush","Summer Event","Boss Event","Portal","InfCastle","RiftStorm","Dungeon","Infinite"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector3",
    Callback = function(Options)
        State.modeTeamSelector3 = Options
    end,
    })

    TeamSelectorDropdown4 = AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 4",
    Options = {"Story","Challenge","Ranger","Raid","Boss Rush","Summer Event","Boss Event","Portal","InfCastle","RiftStorm","Dungeon","Infinite"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector4",
    Callback = function(Options)
        State.modeTeamSelector4 = Options
    end,
    })

    TeamSelectorDropdown3 = AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 5",
    Options = {"Story","Challenge","Ranger","Raid","Boss Rush","Summer Event","Boss Event","Portal","InfCastle","RiftStorm","Dungeon","Infinite"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector5",
    Callback = function(Options)
        State.modeTeamSelector5 = Options
    end,
    })

 GameSection = AutoPlayTab:CreateSection("🎮 Auto Play 🎮")

     Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Play",
    CurrentValue = false,
    Flag = "AutoPlayToggle",
    Callback = function(Value)
    State.autoPlayEnabled = Value
    if State.autoPlayEnabled then
        startAutoPlay()
    end
    end,
    })

   Slider = AutoPlayTab:CreateSlider({
   Name = "Delay Auto Play by",
   Range = {0, 300},
   Increment = 1,
   Suffix = "seconds",
   CurrentValue = 0,
   Flag = "AutoPlayDelaySlider",
   Callback = function(Value)
        State.AutoPlayDelayNumber = Value
   end,
})

 GameSection = AutoPlayTab:CreateSection("💥 Auto Ultimate 💥")

    Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Use Ultimate(s)",
    CurrentValue = false,
    Flag = "AutoUltimate",
    Callback = function(Value)
        State.AutoUltimateEnabled = Value
        if Value then
            task.spawn(autoUltimateLoop)
        end
    end,
    })

   Slider = AutoPlayTab:CreateSlider({
   Name = "Delay Ultimate Usage by",
   Range = {0, 100},
   Increment = 1,
   Suffix = "seconds",
   CurrentValue = 0,
   Flag = "DelayAutoUltimateSlider",
   Callback = function(Value)
        State.DelayAutoUltimate = Value
   end,
})

 GameSection = AutoPlayTab:CreateSection("🆙 Auto Upgrade 🆙")

     Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Upgrade Units",
    CurrentValue = false,
    Flag = "AutoUpgradeToggle",
    Callback = function(Value)
        State.autoUpgradeEnabled = Value
        if State.autoUpgradeEnabled then
            --State.gameRunning = true
            resetUpgradeOrder()
            startAutoUpgrade()
        else
            stopAutoUpgrade()
        end
    end,
    })

    AutoUpgradeDropdown = AutoPlayTab:CreateDropdown({
    Name = "Select Upgrade Method",
    Options = {"Left to right until max"},
    CurrentOption = {"Left to right until max"},
    MultipleOptions = false,
    Flag = "UpgradeMethodSelector",
    Callback = function(Options)
        State.upgradeMethod = Options[1] or "Left to right until max"
        if State.autoUpgradeEnabled then
            stopAutoUpgrade()
            resetUpgradeOrder()
           -- State.gameRunning = true
            task.wait(0.5)
            startAutoUpgrade()
        end
    end,
    })

    Slider1 = AutoPlayTab:CreateSlider({
    Name = "Unit 1 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit1LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[1] = Value
    end,
    })

    Slider1_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 1 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit1DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[1] = Value
    end,
    })

    Slider2 = AutoPlayTab:CreateSlider({
    Name = "Unit 2 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit2LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[2] = Value
    end,
    })

      Slider2_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 2 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit2DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[2] = Value
    end,
    })

    Slider3 = AutoPlayTab:CreateSlider({
    Name = "Unit 3 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit3LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[3] = Value
    end,
    })

      Slider3_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 3 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit3DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[3] = Value
    end,
    })

    Slider4 = AutoPlayTab:CreateSlider({
    Name = "Unit 4 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit4LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[4] = Value
    end,
    })

      Slider4_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 4 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit4DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[4] = Value
    end,
    })

    Slider5 = AutoPlayTab:CreateSlider({
    Name = "Unit 5 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit5LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[5] = Value
    end,
    })

      Slider5_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 5 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit5DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[5] = Value
    end,
    })

    Slider6 = AutoPlayTab:CreateSlider({
    Name = "Unit 6 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit6LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[6] = Value
    end,
    })

    Slider6_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 6 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit6DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[6] = Value
    end,
    })

 GameSection = AutoPlayTab:CreateSection("🗑️ Auto Delete Unit(s) 🗑️")

      Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Delete Unit(s) on level",
    CurrentValue = false,
    Flag = "AutoReDeployToggle",
    Info = "Level 0 = disable",
    TextScaled = false,
    Callback = function(Value)
        State.AutoReDeployEnabled = Value
    end,
    })

    Slider1_6 = AutoPlayTab:CreateSlider({
    Name = "Sell Unit 1 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit1ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[1] = Value
    end,
    })

     Slider2_6 = AutoPlayTab:CreateSlider({
    Name = "Sell Unit 2 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit2ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[2] = Value
    end,
    })

     Slider3_6 = AutoPlayTab:CreateSlider({
    Name = "Sell Unit 3 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit3ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[3] = Value
    end,
    })

     Slider4_6 = AutoPlayTab:CreateSlider({
    Name = "Sell Unit 4 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit4ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[4] = Value
    end,
    })

     Slider5_6 = AutoPlayTab:CreateSlider({
    Name = "Sell Unit 5 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit5ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[5] = Value
    end,
    })

     Slider6_6 = AutoPlayTab:CreateSlider({
    Name = "Sell Unit 6 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit6ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[6] = Value
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

      TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
    })

     Toggle = WebhookTab:CreateToggle({
    Name = "Send On Stage Finished",
    CurrentValue = false,
    Flag = "sendWebhookWhenStageCompleted",
    Callback = function(Value)
        State.SendStageCompletedWebhook = Value
    end,
    })

game.ReplicatedStorage.Remote.Replicate.OnClientEvent:Connect(function(...)
        local args = {...}
        if table.find(args, "Game_Start") then
            State.gameRunning = true
            State.startingInventory = snapshotInventory()
        resetUpgradeOrder()
        stopRetryLoop()
        stopNextLoop()
        
        

        lastCheckedLevels = {}
        processedUnits = {}

            State.retryAttempted = false
            State.NextAttempted = false
            State.hasGameEnded = false
            State.hasSentWebhook = false
            State.stageStartTime = tick()
            print("🟢 Stage started at", State.stageStartTime)
        end
    end)

Remotes.GameEndedUI.OnClientEvent:Connect(function(_, outcome)
        if typeof(outcome) == "string" then
            local l = outcome:lower()
            if l:find("defeat") then
                State.matchResult = "Defeat"
            elseif l:find("won") or l:find("win") then
                State.matchResult = "Victory"
            else
                State.matchResult = "Unknown"
            end
            print("🎯 Match result detected:", State.matchResult)
        end
    end)

Services.ReplicatedStorage.Remote.Client.UI.Challenge_Updated.OnClientEvent:Connect(function()
        if State.challengeAutoReturnEnabled and not isInLobby() then
           -- notify("Challenge Update", "New challenge detected - will return to lobby when game ends")
             State.pendingChallengeReturn = true
        end
    end)

Remotes.GameEnd.OnClientEvent:Connect(function()
    if State.hasSentWebhook then
            return
        end
        State.hasGameEnded = true
        if State.SendStageCompletedWebhook then
        State.hasSentWebhook = true
        end
        State.gameRunning = false
                if State.AutoFailSafeEnabled == true then
            startFailsafeAfterGameEnd()
        end
        resetUpgradeOrder()

        task.wait(0.5)
        local clearTimeStr = "Unknown"
        if State.stageStartTime then
            local dt = math.floor(tick() - State.stageStartTime)
            clearTimeStr = string.format("%d:%02d", dt // 60, dt % 60)
        end

        if State.SendStageCompletedWebhook then
        sendWebhook("stage", nil, clearTimeStr, State.matchResult)
        end

        State.autoPlayDelayActive = false
        State.actionTaken = false

        if State.pendingChallengeReturn and not State.actionTaken then
            notify("Challenge Return", "New challenge detected - returning to lobby")
            State.pendingChallengeReturn = false
            State.actionTaken = true
            task.delay(2, function()
                Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
            end)
            return
        end

        local TIMEOUT = 10

    local function waitForGameRunning(timeout)
        local elapsed = 0
        while elapsed < timeout do
            if State.gameRunning then
                return true
            end
            task.wait(1)
            elapsed = elapsed + 1
        end
        return false
    end

    local actions = {
        {
            enabled = State.autoRetryEnabled,
            func = function()
                print("Starting Auto Retry...")
                startRetryLoop()
            end
        },
        {
            enabled = State.autoNextEnabled,
            func = function()
                print("Starting Auto Next...")
                startNextLoop()
            end
        },
        {
            enabled = State.autoReturnEnabled,
            func = function()
                print("Teleporting to Lobby...")
                task.delay(2, function()
                    Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
                end)
            end,
            skipCheck = true
        }
    }
    task.spawn(function()
        for _, action in ipairs(actions) do
            if action.enabled then
                action.func()
                if not action.skipCheck then
                    local success = waitForGameRunning(TIMEOUT)
                    if success then
                        print("Game restarted successfully. Stopping sequence.")
                        return
                    else
                        print("Action failed to restart game, moving to next...")
                    end
                end
            end
        end
        print("All actions tried. Returning to lobby if enabled.")
    end)
end)

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image = "eye-off", -- Lucide icon name
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})

--[[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local objVal = Players.LocalPlayer.PlayerGui
    :WaitForChild("Traits")
    :WaitForChild("Main")
    :WaitForChild("Base")
    :WaitForChild("UnitFolder")

local folder = objVal.Value

if folder then
    local primary = folder:FindFirstChild("PrimaryTrait")
    local secondary = folder:FindFirstChild("SecondaryTrait")

    if primary and secondary then
        print("PrimaryTrait:", primary.Value)
        print("SecondaryTrait:", secondary.Value)
    else
        warn("Traits not found inside folder:", folder:GetFullName())
    end
else
    warn("ObjectValue is not pointing to any folder!")
end--]]
