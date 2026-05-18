if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 133410800847665 and game.PlaceId ~= 106402284955512 and game.PlaceId ~= 100391355714091 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

if getgenv().__LIXHUB_LOADED then return end
getgenv().__LIXHUB_LOADED = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local script_version = "V0.11"
getgenv().RAYFIELD_SECURE = true
getgenv().RAYFIELD_ASSET_ID = 77799463979503

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Universal Tower Defense",
   Icon = 0,
   LoadingTitle = "Loading for Universal Tower Defense",
   ScriptID = "sid_a20vo45rkxte",
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

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub",
      FileName = "Lixhub_UTD"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "LixHub - Universal Tower Defense - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local AutoPathTab = Window:CreateTab("Auto Path", "target")
local RagnarokTab = Window:CreateTab("Cards", "target")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local Tab = Window:CreateTab("Macro", "tv")
local AutoPlayTab = Window:CreateTab("Auto Play", "play")
local AutoAbilityTab = Window:CreateTab("Auto Abilities", "zap")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")
local MiscTab = Window:CreateTab("Misc", "cog")

local StatusLabel = Tab:CreateLabel("Status: Ready")
local DetailLabel = Tab:CreateLabel("Waiting...")

local AutoAbility = { enabled = false }
local abilitySettings = {} -- { [unitId_abilityName] = { mode, wave } }
local abilityUsedOnWave = {}

Div = Tab:CreateDivider()

local isRecording = false
local recordingHasStarted = false
local gameStartTime = 0
local macro = {}
local macroManager = {}
local currentMacroName = ""
local gameInProgress = false
local lastWave = 0
local isPlaybackEnabled = false
local playbackLoopRunning = false
local ignoreTiming = false
local ValidWebhook = nil
local beforeRewardData = nil
local afterRewardData = nil
local hasRecentlyRestarted = false
local moddedPlacementEnabled = false
local finishedRewardData = nil
local consecutiveLosses = 0
local forcedLobbyReturn = false
local pendingSubTowerInfo = nil
local pendingReplacementInfo = nil
local bossSpawnedThisWave = false
local bossAbilityFiredKeys = {}
local FriendlyNameToID = {}
local currentGameInfo = {
    MapName = nil,
    Act = nil,
    Category = nil,
    StartTime = nil
}
local UINameToModuleName = {}
local ModifierMapping = {}
local worldMacroMappings = {}
local worldDropdowns = {}
local pendingValkPlacement = nil
local pendingValkGUID = nil  -- for playback
local pendingValkCardList = nil
local currentShopOffers = {}
local disabledByLowPerf = {}
local lastMatchResult = nil
local iceGiftsBefore = 0
local RerollLimitHit = {
    TheHunt = false,
    Olympus = false,
    MirrorDimension = false,
}
local RecordCache = {
    secondaryUnits = nil,
    lastSecondaryCheck = 0,
    lastLoadoutCheck = 0,
    loadout = nil,
    unitDataCache = {},
}

-- ============================================
-- NAMESPACE TABLES
-- ============================================
 
-- Groups utility/helper functions
local Util = {}
-- Groups macro file I/O
local MacroIO = {}
-- Groups unit tracking/GC search
local UnitTracker = {}
-- Groups playback execution
local Playback = {}
-- Groups auto-join logic
local AutoJoin = {}
-- Groups webhook logic
local Webhook = {}
-- Groups path/blessing logic
local PathSystem = {}
-- Groups loader functions (stages, modifiers, etc.)
local Loader = {}
-- Groups game/match state helpers
local GameState = {}

local Autoplay = {}

local hologramParts = {}
local placementSquares = {}
local hologramEnabled = false
local hologramConnection = nil
Autoplay.manualPlacementActive = false
Autoplay.manualPlacementSlot = nil
Autoplay.manualPlacementSquare = nil
Autoplay.manualPlacementConnection = nil
local manualRayParams = RaycastParams.new()
manualRayParams.FilterDescendantsInstances = { workspace.Ignore }
manualRayParams.FilterType = Enum.RaycastFilterType.Exclude
manualRayParams.CollisionGroup = "Tower"
manualRayParams.RespectCanCollide = false
local autoPlaceRunning = false
local autoPlayUsedPositions = {}
local restartDisabled = false

local RagnarokState = {
    AutoPickEnabled = false,
    CardPriorities = {
        ["Quickened Hands"]   = 5,
        ["Spoils of War"]     = 4,
        ["Silence the Gods"]  = 3,
        ["Extended Reach"]    = 2,
        ["Exposed Weakness"]  = 1,
    }
}

local cardNames = {
    "Quickened Hands",
    "Spoils of War",
    "Silence the Gods",
    "Extended Reach",
    "Exposed Weakness",
}

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
}

task.spawn(function()
    task.wait(2)
    pcall(function()
        local SendFinished = Services.ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.WaveService.RE.SendFinished
        SendFinished.OnClientEvent:Connect(function(result, rewards, gameInfo, ...)
            finishedRewardData = { result = result, rewards = rewards, gameInfo = gameInfo }
            lastMatchResult = result -- "Won" or "Lost"
        end)
    end)
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.EffectService.RE.SendMessage
        Event.OnClientEvent:Connect(function(messageType, message)
            if messageType == "Error" and message == "Restart is disabled for this gamemode." then
                restartDisabled = true
            end
        end)
    end)
end)

local PathState = {
    AutoSelectPath = false,
    BlessingPriorities = {}
}

local pathSliders = {}

local State = {
    SelectedChallengeType = "HalfHour",
    DeleteEnemies = false,
    AutoJoinBlitz = false,
    AutoMatchmakeBlitz = false,
    AutoJoinMirrorDimension = false,
    AutoMatchmakeMirrorDimension = false,
    AutoJoinEmperorsKingdom = false,
    AutoFreeMochiUnits = false,
    AutoEquipBeforeGame = false,
    sessionRuns = getgenv().__LIXHUB_RUNS or 0,
    disableScriptNotifications = false,
    AutoStartGame = false,
    AutoRetry = false,
    AutoNext = false,
    AutoLobby = false,
    AutoSelectPath = false,
    SendStageCompletedWebhook = false,
    streamerModeEnabled = false,
    SelectedFPS = 60,
    enableLimitFPS = false,
    enableAutoExecute = false,
    enableBlackScreen = false,
    enableLowPerformanceMode = false,
    AntiAfkKickEnabled = false,
    AutoSkipWaves = false,
    AutoSkipUntilWave = 0,
    AutoGameSpeed = false,
    SelectedGameSpeed = 1,
    AutoRestartMatch = false,
    AutoRestartMatchWave = 0,
    SendMatchRestartedWebhook = false,
    AutoSellAllUnits = false,
    AutoSellAllUnitsWave = 0,

    AutoJoinStory = false,
    StoryStageSelected = nil,
    StoryActSelected = nil,
    StoryDifficultySelected = nil,
    StoryDifficultyMeterSelected = 100,

    -- Legend
    AutoJoinLegendStage = false,
    LegendStageSelected = nil,
    LegendStageActSelected = nil,
    LegendStageDifficultyMeterSelected = 100,

    -- Virtual
    AutoJoinVirtualStage = false,
    VirtualStageSelected = nil,
    VirtualStageActSelected = nil,
    VirtualStageDifficultySelected = nil,
    VirtualStageDifficultyMeterSelected = 100,

    -- Challenge
    AutoJoinFeaturedChallenge = false,
    AutoJoinChallenge = false,
    IgnoreWorlds = {},
    IgnoreModifier = {},
    SelectedChallengeRewards = {},
    ReturnToLobbyOnNewChallenge = false,
    LastFailedChallengeAttempt = 0,
    ChallengeJoinCooldown = 60,
    NewChallengesAvailable = false,
    AutoJoinOlympusJudgement = false,
    AutoJoinShinobiAlliance = false,
    AutoJoinRagnarok = false,
    AutoMatchmakeShinobiAlliance = false,
    AutoJoinUniversalTear = false,
    AutoMatchmakeUniversalTear = false,
    AutoCollectRiftOrbs = false,
    ReturnToLobbyAfterLosses = 0,
    ReturnToLobbyAfterMatches = 0,
    matchesPlayed = 0,
    LeaveAfterRerollLimitHitTheHunt = false,
    LeaveAfterRerollLimitHitOlympus = false,

    -- Raid
    AutoJoinRaid = false,
    RaidStageSelected = nil,
    RaidActSelected = nil,

    -- Winter Event
    AutoCollectPresents = false,
    AutoJoinWinterEvent = false,
    WinterActSelected = false,
    WinterStageDifficultySelected = false,
    WinterStageDifficultyMeterSelected = 100,

    -- Portal
    AutoJoinPortal = false,
    PortalsSelected = {},

    ShinobiAutoGaaraZone = false,
    ShinobiAutoOpenCoffin = false,
    AutoKuramaHands = false,

    SelectedRiftMaps = {},
    enableAutoClaimEventMissions = false,
    enableAutoClaimBattlepass = false,

    enableAutoSummonBanner = false,
    SelectedSummonType = nil,
    SelectedBannerId = nil,

    enableAutoOpenCapsules = false,
    SelectedCapsuleIds = {},
    CapsuleNameToId = {},
    enableAutoBuyCapsules = false,
    SelectedCapsulesToBuy = {},

    -- Autoplay
    AutoPlayEnableAutoPlace = false,
    AutoPlayEnableAutoUpgrade = false,
    AutoPlayFocusFarmUnitsUpgrade = false,
    AutoPlayFocusFarmUnits = false,
    AutoPlayEnableHologram = false,
    AutoPlayDistancePercentage = 50,
    AutoPlayGroundPercentage = 50,
    AutoPlayHillPercentage = 50,

    AutoPlayPlaceCap1 = 3,
    AutoPlayPlaceCap2 = 3,
    AutoPlayPlaceCap3 = 3,
    AutoPlayPlaceCap4 = 3,
    AutoPlayPlaceCap5 = 3,
    AutoPlayPlaceCap6 = 3,

    AutoPlayUpgradeCap1 = 10,
    AutoPlayUpgradeCap2 = 10,
    AutoPlayUpgradeCap3 = 10,
    AutoPlayUpgradeCap4 = 10,
    AutoPlayUpgradeCap5 = 10,
    AutoPlayUpgradeCap6 = 10,

    AutoPlayPlaceOnWaveUnit1 = 0,
    AutoPlayPlaceOnWaveUnit2 = 0,
    AutoPlayPlaceOnWaveUnit3 = 0,
    AutoPlayPlaceOnWaveUnit4 = 0,
    AutoPlayPlaceOnWaveUnit5 = 0,
    AutoPlayPlaceOnWaveUnit6 = 0,

    AutoPlayUpgradeOnWaveUnit1 = 0,
    AutoPlayUpgradeOnWaveUnit2 = 0,
    AutoPlayUpgradeOnWaveUnit3 = 0,
    AutoPlayUpgradeOnWaveUnit4 = 0,
    AutoPlayUpgradeOnWaveUnit5 = 0,
    AutoPlayUpgradeOnWaveUnit6 = 0,
    AutoPlayUnitPositions = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
},
}

        local loadingRetries = {
        story = 0,
        legend = 0,
        portal = 0,
        ignoreWorlds = 0,
        modifiers = 0,
        raid = 0,
    }

     local AutoJoinState = {
        isProcessing = false,
        currentAction = nil,
        lastActionTime = 0,
        actionCooldown = 2
    }

    local maxRetries = 20
    local retryDelay = 2

local Config = {
    DISCORD_USER_ID = nil,
}

function Util.isInLobby()
    return Services.Workspace:GetAttribute("IsLobby") or false
end

local function waitForClientReady()
    local deadline = tick() + 20 -- safety net so it never hangs forever
    if Util.isInLobby() then
        repeat task.wait(0.5) until
            (workspace:GetAttribute("ClientInit") ~= nil and workspace:GetAttribute("ClientInit") ~= false)
            or tick() > deadline
    else
        repeat task.wait(0.5) until
            (workspace:GetAttribute("ClientLoaded") ~= nil and workspace:GetAttribute("ClientLoaded") ~= false)
            or tick() > deadline
    end
end

waitForClientReady()

local UINameToPortalModule = {}
local TowerService = nil
local BlessingService = nil
local RequestData = nil
local ChallengeController = nil
local PodController = nil
local DataController = nil
local PlacedTowerController = nil
local pendingUpgrades = {}
local Knit = require(Services.ReplicatedStorage.Packages.knit)
local autoEquipRunning = false

task.spawn(function()
    task.wait(2)
    pcall(function()
        TowerService = Services.ReplicatedStorage
            :WaitForChild("Packages", 10)
            :WaitForChild("_Index", 10)
            :WaitForChild("sleitnick_knit@1.7.0", 10)
            :WaitForChild("knit", 10)
            :WaitForChild("Services", 10)
            :WaitForChild("TowerService", 10) -- 10s timeout instead of infinite
            :WaitForChild("RF", 10)
        BlessingService = Services.ReplicatedStorage
            :WaitForChild("Packages", 10)
            :WaitForChild("_Index", 10)
            :WaitForChild("sleitnick_knit@1.7.0", 10)
            :WaitForChild("knit", 10)
            :WaitForChild("Services", 10)
            :WaitForChild("BlessingService", 10)
            :WaitForChild("RE", 10)
        RequestData = Services.ReplicatedStorage
            :WaitForChild("Packages", 10)
            :WaitForChild("_Index", 10)
            :WaitForChild("sleitnick_knit@1.7.0", 10)
            :WaitForChild("knit", 10)
            :WaitForChild("Services", 10)
            :WaitForChild("DataService", 10)
            :WaitForChild("RF", 10)
            :WaitForChild("RequestData", 10)
    end)
end)

task.spawn(function()
    local ok, err = pcall(function()
        Knit.OnStart():await()
    end)
    if not ok then
        warn("Knit failed to start:", err)
        return
    end

    -- Now safely get controllers
    local maxAttempts = 10
    local retryDelay = 1

    local function tryGet(name)
        for attempt = 1, maxAttempts do
            local ok, result = pcall(function()
                return Knit.GetController(name)
            end)
            if ok and result then
                print(string.format("✓ Loaded %s (attempt %d)", name, attempt))
                return result
            end
            warn(string.format("%s not ready, retrying... (%d/%d)", name, attempt, maxAttempts))
            task.wait(retryDelay)
        end
        warn(string.format("✗ Failed to load %s after %d attempts", name, maxAttempts))
        return nil
    end

    PodController = tryGet("PodController")
    DataController = tryGet("DataController")
    PlacedTowerController = tryGet("PlacedTowerController")

    -- ChallengeController uses require instead of Knit
    for attempt = 1, maxAttempts do
        local ok, result = pcall(function()
            return require(game:GetService("ReplicatedStorage").Client.Controllers.ChallengeController)
        end)
        if ok and result then
            ChallengeController = result
            print(string.format("Loaded ChallengeController (attempt %d)", attempt))
            break
        end
        warn(string.format("ChallengeController not ready, retrying... (%d/%d)", attempt, maxAttempts))
        task.wait(retryDelay)
    end
end)

local function updateQueueOnTeleport()
    if not queue_on_teleport then return end
    local parts = {}

    table.insert(parts, string.format("getgenv().__LIXHUB_RUNS = %d", State.sessionRuns))
    table.insert(parts, "getgenv().__LIXHUB_LOADED = nil") -- add this line

    if State.enableAutoExecute then
        table.insert(parts, 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader"))()')
    end

    queue_on_teleport(table.concat(parts, "\n"))
end

-- ============================================
-- LOADOUT MANAGEMENT
-- ============================================

function MacroIO.ensureFolders()
    if not isfolder("LixHub") then makefolder("LixHub") end
    if not isfolder("LixHub/Macros") then makefolder("LixHub/Macros") end
    if not isfolder("LixHub/Macros/UTD") then makefolder("LixHub/Macros/UTD") end
end

function MacroIO.getFilename(name)
    return "LixHub/Macros/UTD/" .. name .. ".json"
end

function MacroIO.save(name, macroData)
    MacroIO.ensureFolders()
    local json = game:GetService("HttpService"):JSONEncode(macroData)
    writefile(MacroIO.getFilename(name), json)
    print(string.format("✓ Saved macro: %s (%d actions)", name, #macroData))
end

function MacroIO.load(name)
    local filePath = MacroIO.getFilename(name)
    if not isfile(filePath) then return nil end
    local json = readfile(filePath)
    return game:GetService("HttpService"):JSONDecode(json)
end

function MacroIO.delete(name)
    local filePath = MacroIO.getFilename(name)
    if isfile(filePath) then delfile(filePath) end
    macroManager[name] = nil
end

function MacroIO.loadAll()
    MacroIO.ensureFolders()
    macroManager = {}
    local files = listfiles("LixHub/Macros/UTD/")
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            local data = MacroIO.load(name)
            if data then
                macroManager[name] = data
                print(string.format("Loaded macro: %s (%d actions)", name, #data))
            end
        end
    end
end

function MacroIO.getList()
    local list = {}
    for name in pairs(macroManager) do table.insert(list, name) end
    table.sort(list)
    return list
end

function Util.updateMacroStatus(message)
    StatusLabel:Set("Status: " .. message)
end

function Util.updateDetailedStatus(message)
    DetailLabel:Set(message)
end

function Util.cleanUnitName(unitName)
    return unitName:gsub(":[Ss]hiny", "")
end

function Util.formatNumber(n)
    local s = tostring(math.floor(n))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

function UnitTracker.getPlayerLoadout()
    local loadout = {}
    local success, err = pcall(function()
        local dc = DataController or Knit.GetController("DataController")
        local EquippedUnits = game:GetService("HttpService"):JSONDecode(
            game:GetService("Players").LocalPlayer:WaitForChild("Equipped").Value
        )

        for slot, unitGUID in ipairs(EquippedUnits) do
            if unitGUID and unitGUID ~= "" then
                local ok, inventoryData = pcall(function() return dc:GetUnitData(unitGUID) end)
                if ok and inventoryData and inventoryData.UnitId then
                    loadout[slot] = Util.cleanUnitName(inventoryData.UnitId)
                end
            end
        end
    end)
    if not success then warn("Failed to get player loadout:", err) end
    return loadout
end

function UnitTracker.getSlotForUnit(unitName)
    local loadout = UnitTracker.getPlayerLoadout()
    local cleanSearchName = Util.cleanUnitName(unitName)
    for slot, name in pairs(loadout) do
        if Util.cleanUnitName(name) == cleanSearchName then return slot end
    end
    return nil
end

function UnitTracker.getUnitData(unitName)
    local cleanName = Util.cleanUnitName(unitName)
    local success, result = pcall(function()
        local module = game:GetService("ReplicatedStorage").Shared.Data.Towers:FindFirstChild(cleanName)
        if not module then return nil end
        if module:IsA("ModuleScript") then
            local required = require(module)
            if type(required) == "function" then return required() end
            return required
        end
        return nil
    end)
    if success and result then return result end
    warn(string.format(" Could not find unit data for: %s", unitName))
    return nil
end

-- ============================================
-- UNIT TRACKING
-- ============================================

function UnitTracker.getByUUID(uuid)
    local unitsFolder = workspace:FindFirstChild("Ignore")
    if unitsFolder then unitsFolder = unitsFolder:FindFirstChild("Units") end
    if not unitsFolder then return nil end
    return unitsFolder:FindFirstChild(uuid)
end

function UnitTracker.findNewInGC(unitName, excludeUUIDs)
    excludeUUIDs = excludeUUIDs or {}
    local cleanedUnitName = Util.cleanUnitName(unitName)
    local candidates = {}

    local unitsFolder = workspace:FindFirstChild("Ignore") and workspace.Ignore:FindFirstChild("Units")
    if not unitsFolder then
        warn("Units folder not found")
        return nil, nil
    end

    local function checkUnit(unit)
        local uuid = unit.Name
        if excludeUUIDs[uuid] then return end

        local unitClass = PlacedTowerController:GetUnitClass(uuid)
        if not unitClass then return end

        local towerId = rawget(unitClass, "TowerID") or rawget(unitClass, "UnitId") or ""
        local unitDisplayName = rawget(unitClass, "Name") or ""
        local cleanTowerId = Util.cleanUnitName(towerId)
        local cleanDisplayName = Util.cleanUnitName(unitDisplayName)

        if cleanTowerId == cleanedUnitName or cleanDisplayName:lower() == cleanedUnitName:lower() then
            table.insert(candidates, {
                uuid = uuid,
                unitName = towerId,
                upgrade = rawget(unitClass, "Upgrade") or 1
            })
        end
    end

    for _, unit in pairs(unitsFolder:GetChildren()) do
        checkUnit(unit)
    end

    if #candidates == 0 then
        warn(string.format("No new units found for: %s", unitName))
        return nil, nil
    end

    table.sort(candidates, function(a, b)
        return a.upgrade < b.upgrade
    end)

    return candidates[1].uuid, candidates[1].unitName
end

local unitChangeListeners = {}

function UnitTracker.findDataInGC(uuid)
    local success, result = pcall(function()
        local unitClass = PlacedTowerController:GetUnitClass(uuid)
        if not unitClass then return nil end

        return {
            GUID    = rawget(unitClass, "GUID"),
            UnitId  = rawget(unitClass, "TowerID") or rawget(unitClass, "UnitId"),
            Upgrade = rawget(unitClass, "Upgrade") or 1,
            Model   = rawget(unitClass, "Model")
        }
    end)

    if success and result then return result end
    warn("Could not find unit data for UUID: " .. tostring(uuid))
    return nil
end

function UnitTracker.startTracking(uuid, unitTag, unitName)
    local unit = UnitTracker.getByUUID(uuid)
    if not unit then return end
    local unitData = UnitTracker.findDataInGC(uuid)
    if unitData then
        unitChangeListeners[uuid] = { data = unitData, unitTag = unitTag, lastUpgradeLevel = unitData.Upgrade or 1 }
    else
        unitChangeListeners[uuid] = { unitTag = unitTag }
    end
end

function UnitTracker.stopTracking(uuid)
    if unitChangeListeners[uuid] then
        unitChangeListeners[uuid] = nil
    end
end

local upgradeCheckThread = nil

function UnitTracker.startUpgradePolling()
    if upgradeCheckThread then return end
    upgradeCheckThread = task.spawn(function()
        while isRecording and recordingHasStarted do
            task.wait(0.5)
            for uuid, listener in pairs(unitChangeListeners) do
                if type(listener) == "table" and listener.data then
                    local currentLevel = listener.data.Upgrade
                    local lastLevel = listener.lastUpgradeLevel
                    if currentLevel and lastLevel and currentLevel > lastLevel then
                        listener.lastUpgradeLevel = currentLevel
                    end
                end
            end
        end
        upgradeCheckThread = nil
    end)
end

function UnitTracker.stopUpgradePolling()
    if upgradeCheckThread then
        task.cancel(upgradeCheckThread)
        upgradeCheckThread = nil
    end
end

function Util.getUnitNameFromTag(unitTag)
    return unitTag:match("^(.+) #%d+$") or unitTag
end

-- ============================================
-- RECORDING HOOKS
-- ============================================

local recordingUnitCounter = {} -- Maps "UnitName" -> count
local recordingUUIDToTag = {} -- Maps UUID -> "UnitName #N"
local playbackUnitTagToUUID = {} -- Maps "UnitName #N" -> UUID (for playback)

local mt = getrawmetatable(game)
setreadonly(mt, false)
local originalNamecall = mt.__namecall

local generalHook = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    local results = {originalNamecall(self, table.unpack(args))}

    if checkcaller() or not isRecording or not recordingHasStarted then
        return table.unpack(results)
    end

    if method ~= "InvokeServer" and method ~= "FireServer" then
        return table.unpack(results)
    end

    local name = self.Name

    if name ~= "PlaceUnit" and name ~= "UpgradeUnit" and name ~= "SellUnit" 
    and name ~= "UseAbility" and name ~= "CommitSpecialPlacement" 
    and name ~= "VoteCard" and name ~= "Purchase" and name ~= "RequestFusion"
    and name ~= "PlaceSubTower" and name ~= "CommitUnitReplacement"
    and name ~= "AutoAbility" and name ~= "ToggleAutoUpgrade"
    and name ~= "IncrementAutoUpgradePriority" then 
        return table.unpack(results)
    end
    
        task.spawn(function()
            local timestamp = tick()
            local gameRelativeTime = timestamp - gameStartTime

            if method == "InvokeServer" and self.Name == "PlaceUnit" then
            local result = results[1]
            local message = results[2]
            if result == true then
                local slot = args[1]
                local cframe = args[2]

                local unitName = nil

                if tick() - RecordCache.lastSecondaryCheck > 5 then
                    local ok, res = pcall(function()
                        return TowerService:WaitForChild("GetSecondarySlotUnits"):InvokeServer()
                    end)
                    if ok then RecordCache.secondaryUnits = res end
                    RecordCache.lastSecondaryCheck = tick()
                end

                if RecordCache.secondaryUnits and type(RecordCache.secondaryUnits) == "table" and #RecordCache.secondaryUnits > 0 then
                    local slotData = RecordCache.secondaryUnits[slot]
                    if slotData and slotData.unitId then
                        unitName = Util.cleanUnitName(slotData.unitId)
                    end
                end

                if not unitName then
                    if tick() - RecordCache.lastLoadoutCheck > 3 then
                        RecordCache.loadout = UnitTracker.getPlayerLoadout()
                        RecordCache.lastLoadoutCheck = tick()
                    end
                    unitName = RecordCache.loadout and RecordCache.loadout[slot]
                end

                if not unitName then
                    warn("Could not determine unit name for slot", slot)
                    return
                end

                task.wait(0.2)

                local excludeUUIDs = {}
                for uuid, _ in pairs(recordingUUIDToTag) do excludeUUIDs[uuid] = true end
                local uuid, detectedName = nil, nil
                local unitsFolder = workspace:FindFirstChild("Ignore") and workspace.Ignore:FindFirstChild("Units")

                local found = false
                local connection
                connection = unitsFolder.ChildAdded:Connect(function(child)
                    if found then return end
                    local testUUID, testName = UnitTracker.findNewInGC(unitName, excludeUUIDs)
                    if testUUID then
                        uuid = testUUID
                        detectedName = testName
                        found = true
                    end
                end)

                local deadline = tick() + 3
                while not found and tick() < deadline do
                    task.wait(0.1)
                end
                connection:Disconnect()

                if not found then
                    uuid, detectedName = UnitTracker.findNewInGC(unitName, excludeUUIDs)
                end

                if uuid then
                    local unit = UnitTracker.getByUUID(uuid)
                    if not unit then
                        warn(string.format("UUID %s found in GC but not in workspace!", uuid))
                        return
                    end
                    local cleanName = Util.cleanUnitName(unitName)
                    recordingUnitCounter[cleanName] = (recordingUnitCounter[cleanName] or 0) + 1
                    local unitNumber = recordingUnitCounter[cleanName]
                    local unitTag = string.format("%s #%d", cleanName, unitNumber)
                    recordingUUIDToTag[uuid] = unitTag
                    table.insert(macro, {
                        Type = "spawn_unit", Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime),
                        Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z}
                    })
                    UnitTracker.startTracking(uuid, unitTag, unitName)
                    print(string.format("Recorded: %s (UUID=%s)", unitTag, uuid))
                    if pendingUpgrades[uuid] then
                        for _, buffered in ipairs(pendingUpgrades[uuid]) do
                            if buffered.result == true then
                                table.insert(macro, {
                                    Type = "upgrade_unit",
                                    Unit = unitTag,
                                    Time = string.format("%.2f", buffered.gameRelativeTime)
                                })
                                print(string.format("Flushed buffered upgrade: %s", unitTag))
                            end
                        end
                        pendingUpgrades[uuid] = nil
                    end
                else
                    warn("Failed to find placed unit in GC!")
                end
            else
                warn(string.format("Skipped placement: %s", tostring(message)))
            end

            elseif method == "InvokeServer" and self.Name == "UpgradeUnit" then
                local result = results[1]
                local message = results[2]
                local uuid = args[1]
                local unitTag = recordingUUIDToTag[uuid]
                
                if not unitTag then
                    -- Buffer this upgrade — placement detection may still be running
                    if not pendingUpgrades[uuid] then
                        pendingUpgrades[uuid] = {}
                    end
                    table.insert(pendingUpgrades[uuid], {
                        gameRelativeTime = gameRelativeTime,
                        result = result,
                        message = message,
                    })
                    warn("Buffered upgrade for untracked unit:", uuid)
                    return
                end
                
                if result == true then
                    table.insert(macro, {
                        Type = "upgrade_unit",
                        Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                else
                    warn(string.format("Skipped upgrade for %s: %s", unitTag, tostring(message)))
                end

            elseif method == "InvokeServer" and self.Name == "SellUnit" then
                local result = results[1]
                local message = results[2]
                local uuid = args[1]
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then return end
                if result == true then
                    table.insert(macro, {
                        Type = "sell_unit",
                        Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                    UnitTracker.stopTracking(uuid)
                    recordingUUIDToTag[uuid] = nil
                else
                    warn(string.format("Skipped sell for %s: %s", unitTag, tostring(message)))
                end

            elseif method == "FireServer" and self.Name == "UseAbility" then
                local uuid = args[1]
                local abilitySlot = args[2]
                local abilityType = args[3]  -- e.g. "Specialist", nil for basic abilities
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then warn("Ability used for untracked unit:", uuid) return end
                table.insert(macro, {
                    Type = "use_ability",
                    Unit = unitTag,
                    AbilitySlot = abilitySlot,
                    AbilityType = abilityType,  -- will be nil for abilities that don't send this
                    Time = string.format("%.2f", gameRelativeTime)
                })
                elseif method == "InvokeServer" and self.Name == "CommitSpecialPlacement" then
                local result = results[1]
                local placementKey = args[1]  -- the GUID key
                local cframe = args[2]
                if result == true then
                    -- Find the pending valk name we stored when BeginSpecialPlacement fired
                    local valkName = pendingValkPlacement and pendingValkPlacement.valkName
                    if valkName then
                        table.insert(macro, {
                            Type = "place_valkyrie",
                            ValkName = valkName,
                            Time = string.format("%.2f", gameRelativeTime),
                            Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z}
                        })
                        print(string.format("Recorded Valkyrie placement: %s", valkName))
                        pendingValkPlacement = nil
                    end
                end
                elseif method == "FireServer" and self.Name == "VoteCard" then
            local channel = args[1]
            local cardIndex = args[2]
            if channel == "RagnarokValkyrie" and isRecording and recordingHasStarted then
                local valkName = pendingValkCardList and pendingValkCardList[cardIndex] and pendingValkCardList[cardIndex].id
                if valkName then
                    table.insert(macro, {
                        Type = "pick_valkyrie",
                        ValkName = valkName,
                        Time = string.format("%.2f", gameRelativeTime),
                    })
                    print(string.format("Recorded Valkyrie pick: %s", valkName))
                end
            end
            elseif method == "InvokeServer" and self.Name == "Purchase" then
                local result = results[1]
                local shopId = args[1]      -- "Ragnarok"
                local itemId = args[2]      -- "RShop_ValkCard_Reginleif_RangeAura"
                if result then
                    table.insert(macro, {
                        Type = "shop_purchase",
                        ShopId = shopId,
                        ItemId = itemId,
                        Time = string.format("%.2f", gameRelativeTime),
                    })
                    print(string.format("Recorded shop purchase: %s / %s", shopId, itemId))
                end
            elseif method == "InvokeServer" and self.Name == "RequestFusion" then
                local success = results[1]
                local message = results[2]
                local resultGuid = results[3]
                if success == true then
                    local baseGuid = args[1]
                    local sacrificeGuid = args[2]
                    local baseTag = recordingUUIDToTag[baseGuid]
                    local sacrificeTag = recordingUUIDToTag[sacrificeGuid]
                    if not baseTag or not sacrificeTag then
                        warn(string.format("Fusion recorded but couldn't resolve tags — base: %s, sacrifice: %s", tostring(baseGuid), tostring(sacrificeGuid)))
                        return
                    end

                    recordingUUIDToTag[baseGuid] = nil
                    recordingUUIDToTag[sacrificeGuid] = nil

                    local unitClass = PlacedTowerController:GetUnitClass(resultGuid)
                    local fusedUnitName = unitClass and Util.cleanUnitName(
                        rawget(unitClass, "TowerID") or rawget(unitClass, "UnitId") or ""
                    ) or ""

                    if fusedUnitName == "" then
                        warn("Could not resolve fused unit name from result GUID: " .. resultGuid)
                        return
                    end

                    recordingUnitCounter[fusedUnitName] = (recordingUnitCounter[fusedUnitName] or 0) + 1
                    local fusedTag = string.format("%s #%d", fusedUnitName, recordingUnitCounter[fusedUnitName])
                    recordingUUIDToTag[resultGuid] = fusedTag

                    table.insert(macro, {
                        Type = "fuse_units",
                        BaseUnit = baseTag,
                        SacrificeUnit = sacrificeTag,
                        ResultUnit = fusedTag,
                        Time = string.format("%.2f", gameRelativeTime),
                    })
                    print(string.format("Recorded fusion: %s + %s → %s (UUID=%s)", baseTag, sacrificeTag, fusedTag, resultGuid))
                else
                    warn(string.format("Fusion failed/skipped: %s", tostring(message)))
                end
                elseif method == "InvokeServer" and self.Name == "PlaceSubTower" then
                local result  = results[1]
                local message = results[2]
                local subGUID = results[3]  -- new UUID of the placed sub tower

                if result == true then
                    local parentUUID   = args[1]
                    local subTowerName = args[2]
                    local cframe       = args[3]
                    -- args[4] = { placementToken = "..." }

                    local parentTag = recordingUUIDToTag[parentUUID]
                    if not parentTag then
                        warn("Sub tower placed for untracked parent:", parentUUID)
                        return
                    end

                    local cleanSubName = Util.cleanUnitName(subTowerName)
                    recordingUnitCounter[cleanSubName] = (recordingUnitCounter[cleanSubName] or 0) + 1
                    local subTag = string.format("%s #%d", cleanSubName, recordingUnitCounter[cleanSubName])

                    -- Track the sub tower so upgrades/sells work on it too
                    if subGUID then
                        recordingUUIDToTag[subGUID] = subTag
                    end

                    table.insert(macro, {
                        Type        = "place_sub_tower",
                        ParentUnit  = parentTag,
                        SubUnitTag  = subTag,
                        SubTowerName = cleanSubName,
                        Time        = string.format("%.2f", gameRelativeTime),
                        Position    = { cframe.Position.X, cframe.Position.Y, cframe.Position.Z },
                    })
                    print(string.format("Recorded sub tower: %s on %s (UUID=%s)", subTag, parentTag, tostring(subGUID)))
                else
                    warn(string.format("Skipped sub tower placement: %s", tostring(message)))
                end
            elseif method == "InvokeServer" and self.Name == "CommitUnitReplacement" then
                local cframe = args[2]  -- args[1] is the guid key
                local info = pendingReplacementInfo
                if info then
                    local sourceTag = recordingUUIDToTag[info.sourceUUID]
                    local cleanName = Util.cleanUnitName(info.unitName)
                    recordingUnitCounter[cleanName] = (recordingUnitCounter[cleanName] or 0) + 1
                    local newTag = string.format("%s #%d", cleanName, recordingUnitCounter[cleanName])

                    recordingUUIDToTag[info.sourceUUID] = newTag  -- keep old mapped to new tag
                    recordingUUIDToTag[args[1]] = newTag           -- map new GUID too

                    UnitTracker.stopTracking(info.sourceUUID)
                    UnitTracker.startTracking(args[1], newTag, cleanName)

                    table.insert(macro, {
                        Type = "replace_unit",
                        SourceUnit = sourceTag,
                        NewUnit = newTag,
                        UnitName = cleanName,
                        Time = string.format("%.2f", gameRelativeTime),
                        Position = { cframe.Position.X, cframe.Position.Y, cframe.Position.Z },
                    })
                    print(string.format("Recorded replacement: %s → %s (new UUID: %s)", tostring(sourceTag), newTag, args[1]))
                    pendingReplacementInfo = nil
                end
                elseif method == "InvokeServer" and self.Name == "AutoAbility" then
                local uuid = args[1]
                local abilitySlot = args[2]
                local enabled = args[3]
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then warn("AutoAbility for untracked unit:", uuid) return end
                table.insert(macro, {
                    Type = "auto_ability",
                    Unit = unitTag,
                    AbilitySlot = abilitySlot,
                    Enabled = enabled,
                    Time = string.format("%.2f", gameRelativeTime),
                })
                print(string.format("Recorded auto ability: %s slot %d enabled=%s", unitTag, abilitySlot, tostring(enabled)))

            elseif method == "InvokeServer" and self.Name == "ToggleAutoUpgrade" then
                local uuid = args[1]
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then warn("ToggleAutoUpgrade for untracked unit:", uuid) return end
                table.insert(macro, {
                    Type = "toggle_auto_upgrade",
                    Unit = unitTag,
                    Time = string.format("%.2f", gameRelativeTime),
                })
                print(string.format("Recorded toggle auto upgrade: %s", unitTag))

            elseif method == "InvokeServer" and self.Name == "IncrementAutoUpgradePriority" then
                local uuid = args[1]
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then warn("IncrementAutoUpgradePriority for untracked unit:", uuid) return end
                table.insert(macro, {
                    Type = "increment_auto_upgrade_priority",
                    Unit = unitTag,
                    Time = string.format("%.2f", gameRelativeTime),
                })
                print(string.format("Recorded increment auto upgrade priority: %s", unitTag))
            end
        end)
    return table.unpack(results)
end)

mt.__namecall = generalHook
setreadonly(mt, true)

task.spawn(function()
    task.wait(2)
    pcall(function()
        local TowerServiceRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.TowerService.RE
        local CardChoiceServiceRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CardChoiceService.RE

        -- Captures the GUID + valk name when placement begins
        TowerServiceRE.BeginSpecialPlacement.OnClientEvent:Connect(function(guid, valkId, options)
            if options and options.placementPurpose == "RagnarokValkyrie" then
                -- For recording: store pending placement info
                pendingValkPlacement = { guid = guid, valkName = valkId }
                -- For playback: store the live GUID so playback can use it
                pendingValkGUID = guid
                print(string.format("BeginSpecialPlacement: %s (GUID: %s)", valkId, guid))
            end
        end)

        TowerServiceRE.BeginUnitReplacement.OnClientEvent:Connect(function(guid, sourceUUID, unitName, options)
    pendingReplacementInfo = {
        guid = guid,
        sourceUUID = sourceUUID,
        unitName = unitName,
    }
    print(string.format("BeginUnitReplacement: %s replacing %s (GUID: %s)", unitName, sourceUUID, guid))
end)

        TowerServiceRE.EndSpecialPlacement.OnClientEvent:Connect(function(guid, status)
            if status == "Placed" then
                pendingValkGUID = nil
            end
        end)
        TowerServiceRE.BeginSubTowerPlacement.OnClientEvent:Connect(function(placementToken, parentGUID, subTowerName, options)
    pendingSubTowerInfo = {
        token = placementToken,
        parentUUID = parentGUID,
        subTowerName = subTowerName,
    }
    print(string.format("BeginSubTowerPlacement: %s (parent: %s, token: %s)", subTowerName, parentGUID, placementToken))
end)
    end)
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        local MatchShopRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.MatchShopService.RE
        MatchShopRE.ShopStateChanged.OnClientEvent:Connect(function(shopId, shopState)
            if not shopState or not shopState.offers then return end
            for _, offer in ipairs(shopState.offers) do
                if offer.type == "ValkCard" and offer.id then
                    currentShopOffers[offer.id] = { cost = offer.cost, meta = offer.meta }
                end
            end
        end)
    end)
end)

-- ============================================
-- PLAYBACK EXECUTION
-- ============================================

function Util.getPlayerMoney()
    return Services.Players.LocalPlayer:GetAttribute("Yen")
end

local function canAffordUnit(unitName)
    local unitData = getUnitData(unitName)
    if not unitData then
        warn(string.format("⚠️ No unit data for %s", unitName))
        return true -- Assume we can afford if we can't check
    end
    
    -- The FIRST upgrade is the placement cost!
    local stats = unitData.Stats
    if not stats or not stats.Upgrades or #stats.Upgrades == 0 then
        warn(string.format("⚠️ No Stats.Upgrades for %s", unitName))
        return true
    end
    
    local placementCost = stats.Upgrades[1].Cost or 0
    local money = getPlayerMoney()
    
    if not money then
        return true -- Can't check, assume we can afford
    end
    
    print(string.format("💰 Money: ¥%d | %s Placement Cost: ¥%d", money, unitName, placementCost))
    
    return money >= placementCost
end

local function canAffordUpgrade(uuid)
    local unitData = findUnitDataInGC(uuid)
    if not unitData then
        return true -- Can't check, assume we can afford
    end
    
    local currentLevel = unitData.Upgrade or 1
    local unitName = unitData.UnitId or unitData.TowerID
    
    if not unitName then
        return true
    end
    
    local towerData = getUnitData(unitName)
    if not towerData or not towerData.Stats or not towerData.Stats.Upgrades then
        return true
    end
    
    -- Current level + 1 because:
    -- Level 1 (placed) = Upgrades[1]
    -- Level 2 (first upgrade) = Upgrades[2]
    -- So to upgrade FROM level 1 TO level 2, we need Upgrades[2].Cost
    local nextUpgradeIndex = currentLevel + 1
    local nextUpgrade = towerData.Stats.Upgrades[nextUpgradeIndex]
    
    if not nextUpgrade or not nextUpgrade.Cost then
        warn(string.format("⚠️ No upgrade cost found for level %d->%d", currentLevel, nextUpgradeIndex))
        return true
    end
    
    local upgradeCost = nextUpgrade.Cost
    local money = getPlayerMoney()
    
    if not money then
        return true
    end
    
    print(string.format("💰 Money: ¥%d | Upgrade Cost: ¥%d (Level %d->%d)", 
        money, upgradeCost, currentLevel, nextUpgradeIndex))
    
    return money >= upgradeCost
end

function Playback.waitForMoney(requiredAmount, actionDescription)
    local currentMoney = Util.getPlayerMoney()
    if not currentMoney then return true end
    if currentMoney >= requiredAmount then return true end
    local lastUpdateTime = tick()
    while true do
        local matchFinished = workspace:GetAttribute("MatchFinished")
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            print("⚠️ Game ended while waiting for money - aborting wait")
            return false
        end
        task.wait(1)
        currentMoney = Util.getPlayerMoney()
        if not currentMoney then return true end
        if currentMoney >= requiredAmount then return true end
        if tick() - lastUpdateTime >= 1 then
            Util.updateDetailedStatus(string.format("Waiting: ¥%d / ¥%d (%s)", currentMoney, requiredAmount, actionDescription))
            lastUpdateTime = tick()
        end
    end
end

function Autoplay.waitForMoney(requiredAmount, actionDescription)
    local currentMoney = Util.getPlayerMoney()
    if not currentMoney or currentMoney >= requiredAmount then return true end
    while true do
        local matchFinished = workspace:GetAttribute("MatchFinished")
        if not State.AutoPlayEnableAutoPlace or not gameInProgress or matchFinished then
            return false
        end
        task.wait(1)
        currentMoney = Util.getPlayerMoney()
        if not currentMoney or currentMoney >= requiredAmount then return true end
        Util.updateDetailedStatus(string.format("Waiting: ¥%d / ¥%d (%s)", currentMoney, requiredAmount, actionDescription))
    end
end

function Playback.executePlacement(action, actionIndex, totalActions)
    local unitName = Util.getUnitNameFromTag(action.Unit)
    local cleanName = Util.cleanUnitName(unitName)
    Util.updateMacroStatus(string.format("(%d/%d) Placing %s", actionIndex, totalActions, action.Unit))
    local unitData = UnitTracker.getUnitData(cleanName)
    local placementCost = 0
    if unitData and unitData.Stats and unitData.Stats.Upgrades and #unitData.Stats.Upgrades > 0 then
        placementCost = unitData.Stats.Upgrades[1].Cost or 0
    end
    if placementCost > 0 then
        local currentMoney = Util.getPlayerMoney()
        if currentMoney and currentMoney < placementCost then
            Util.updateDetailedStatus(string.format("Waiting for ¥%d to place %s", placementCost, action.Unit))
        end
        local canContinue = Playback.waitForMoney(placementCost, cleanName)
        if not canContinue then
            Util.updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    local slot = nil
    local success, secondaryUnits = pcall(function()
    return TowerService:WaitForChild("GetSecondarySlotUnits"):InvokeServer()
end)
if success and secondaryUnits and type(secondaryUnits) == "table" and #secondaryUnits > 0 then
    for i, slotData in ipairs(secondaryUnits) do
        if slotData and slotData.unitId then
            local cleanSlotUnit = Util.cleanUnitName(slotData.unitId)
            if cleanSlotUnit == cleanName then
                slot = i
                break
            end
        end
    end
end
if not slot then
    slot = UnitTracker.getSlotForUnit(cleanName)
end

if not slot then
    Util.updateDetailedStatus(string.format("Error: %s not in loadout", cleanName))
    return false
end
    Util.updateDetailedStatus(string.format("Placing %s...", action.Unit))
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    local success = pcall(function()
        TowerService:WaitForChild("PlaceUnit"):InvokeServer(slot, cframe)
    end)
    if not success then
        Util.updateDetailedStatus("Placement failed")
        return false
    end
    task.wait(0.5)
    local excludeUUIDs = {}
    for _, mappedUUID in pairs(playbackUnitTagToUUID) do excludeUUIDs[mappedUUID] = true end
    local uuid = nil
    for attempt = 1, 10 do
        uuid = UnitTracker.findNewInGC(cleanName, excludeUUIDs)
        if uuid then break end
        task.wait(0.3)
    end
    if uuid then
        local unit = UnitTracker.getByUUID(uuid)
        if not unit then
            Util.updateDetailedStatus("Unit not found in workspace")
            return false
        end
        playbackUnitTagToUUID[action.Unit] = uuid
        Util.updateDetailedStatus(string.format("Placed %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Failed to detect placed unit")
    return false
end

function Playback.executeUpgrade(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Upgrading %s", actionIndex, totalActions, action.Unit))
    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid or type(uuid) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: Invalid UUID for %s", action.Unit))
        return false
    end
    local upgradeCost = 0
    local currentLevel = 1
    local unitData = UnitTracker.findDataInGC(uuid)
    if unitData then
        currentLevel = unitData.Upgrade or 1
        local unitName = unitData.UnitId or unitData.TowerID or action.Unit
        local towerData = UnitTracker.getUnitData(unitName)
        if towerData and towerData.Stats and towerData.Stats.Upgrades then
            local nextUpgrade = towerData.Stats.Upgrades[currentLevel + 1]
            if nextUpgrade and nextUpgrade.Cost then
                upgradeCost = nextUpgrade.Cost
            end
        end
    end
    if upgradeCost > 0 then
        local currentMoney = Util.getPlayerMoney()
        if currentMoney and currentMoney < upgradeCost then
            Util.updateDetailedStatus(string.format("Waiting for ¥%d to upgrade %s", upgradeCost, action.Unit))
        end
        local canContinue = Playback.waitForMoney(upgradeCost, string.format("%s upgrade", action.Unit))
        if not canContinue then
            Util.updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    Util.updateDetailedStatus(string.format("Upgrading %s (Lv%d→%d)...", action.Unit, currentLevel, currentLevel + 1))
    local success = pcall(function()
        TowerService:WaitForChild("UpgradeUnit"):InvokeServer(uuid)
    end)
    if success then
        Util.updateDetailedStatus(string.format("Upgraded %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Upgrade failed")
    return false
end

function Playback.executeSell(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Selling %s", actionIndex, totalActions, action.Unit))
    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid then
        Util.updateDetailedStatus(string.format("Error: No UUID for %s", action.Unit))
        return false
    end
    Util.updateDetailedStatus(string.format("Selling %s...", action.Unit))
    local success = pcall(function()
        TowerService:WaitForChild("SellUnit"):InvokeServer(uuid)
    end)
    if success then
        playbackUnitTagToUUID[action.Unit] = nil
        Util.updateDetailedStatus(string.format("Sold %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Sell failed")
    return false
end
 
function Playback.executeAbility(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Using %s ability", actionIndex, totalActions, action.Unit))
    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid or type(uuid) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: Invalid UUID for %s", action.Unit))
        return false
    end

    local abilityDesc = action.AbilityType
        and string.format("Slot %d (%s)", action.AbilitySlot, action.AbilityType)
        or string.format("Slot %d", action.AbilitySlot)
    Util.updateDetailedStatus(string.format("Using %s ability %s...", action.Unit, abilityDesc))

    local success = pcall(function()
        game:GetService("ReplicatedStorage")
            .Packages._Index["sleitnick_knit@1.7.0"]
            .knit.Services.TowerService.RE.UseAbility
            :FireServer(uuid, action.AbilitySlot, action.AbilityType)
    end)

    if success then
        Util.updateDetailedStatus(string.format("Used %s ability %s ✓", action.Unit, abilityDesc))
        return true
    end
    Util.updateDetailedStatus("Ability use failed")
    return false
end

function Playback.executePickValkyrie(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Picking Valkyrie: %s", actionIndex, totalActions, action.ValkName))
    
    -- Wait for the card event and match by name
    local CardChoiceServiceRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CardChoiceService.RE
    
    -- Poll for up to 15s for the card selection to appear
    local cardIndex = nil
    local deadline = tick() + 15
    local connection
    connection = CardChoiceServiceRE.GetNewCards.OnClientEvent:Connect(function(channel, cards, config)
        if channel ~= "RagnarokValkyrie" then return end
        for i, card in ipairs(cards) do
            if card.id == action.ValkName or card.name == action.ValkName then
                cardIndex = i
                break
            end
        end
    end)
    
    while not cardIndex and tick() < deadline do
        task.wait(0.5)
        if not isPlaybackEnabled or not gameInProgress then
            connection:Disconnect()
            return false
        end
    end
    connection:Disconnect()
    
    if not cardIndex then
        Util.updateDetailedStatus(string.format("Valkyrie card not found: %s", action.ValkName))
        return false
    end
    
    task.wait(0.5)
    local success = pcall(function()
        CardChoiceServiceRE.VoteCard:FireServer("RagnarokValkyrie", cardIndex)
    end)
    
    if success then
        Util.updateDetailedStatus(string.format("Picked Valkyrie: %s ✓", action.ValkName))
        Rayfield:Notify({ Title = "Valkyrie Picked", Content = action.ValkName, Duration = 3 })
        return true
    end
    Util.updateDetailedStatus("Valkyrie pick failed")
    return false
end

function Playback.executePlaceValkyrie(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Placing Valkyrie: %s", actionIndex, totalActions, action.ValkName))
    
    local TowerServiceRF = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.TowerService.RF
    
    -- Wait for BeginSpecialPlacement to give us the live GUID
    local guid = nil
    local deadline = tick() + 15
    while not pendingValkGUID and tick() < deadline do
        task.wait(0.5)
        if not isPlaybackEnabled or not gameInProgress then return false end
    end
    guid = pendingValkGUID
    
    if not guid then
        Util.updateDetailedStatus("No GUID received for Valkyrie placement")
        return false
    end
    
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    
    local success = pcall(function()
        TowerServiceRF.CommitSpecialPlacement:InvokeServer(guid, cframe)
    end)
    
    if success then
        pendingValkGUID = nil
        Util.updateDetailedStatus(string.format("Placed Valkyrie: %s ✓", action.ValkName))
        Rayfield:Notify({ Title = "Valkyrie Placed", Content = action.ValkName, Duration = 3 })
        return true
    end
    Util.updateDetailedStatus("Valkyrie placement failed")
    return false
end

function Playback.executeShopPurchase(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Purchasing: %s", actionIndex, totalActions, action.ItemId))
    
    local offerData = currentShopOffers[action.ItemId]
    if offerData and offerData.cost and offerData.cost > 0 then
        local currentMoney = Util.getPlayerMoney()
        if currentMoney and currentMoney < offerData.cost then
            Util.updateDetailedStatus(string.format("Waiting for ¥%d to purchase %s", offerData.cost, action.ItemId))
        end
        local canContinue = Playback.waitForMoney(offerData.cost, action.ItemId)
        if not canContinue then
            Util.updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end

    local success = pcall(function()
        local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.MatchShopService.RF.Purchase
        Event:InvokeServer(action.ShopId, action.ItemId)
    end)
    if success then
        Util.updateDetailedStatus(string.format("Purchased %s ✓", action.ItemId))
        return true
    end
    Util.updateDetailedStatus("Purchase failed")
    return false
end

function Playback.executeFusion(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Fusing %s + %s", actionIndex, totalActions, action.BaseUnit, action.SacrificeUnit))

    local baseUUID = playbackUnitTagToUUID[action.BaseUnit]
    local sacrificeUUID = playbackUnitTagToUUID[action.SacrificeUnit]

    if not baseUUID or type(baseUUID) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: No UUID for base unit %s", action.BaseUnit))
        return false
    end
    if not sacrificeUUID or type(sacrificeUUID) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: No UUID for sacrifice unit %s", action.SacrificeUnit))
        return false
    end

    Util.updateDetailedStatus(string.format("Fusing %s + %s...", action.BaseUnit, action.SacrificeUnit))

    local fusionRemote = game:GetService("ReplicatedStorage")
        .Packages._Index["sleitnick_knit@1.7.0"]["knit"].Services
        .TowerService.RF.RequestFusion

    local callOk, success, message, resultGuid = pcall(function()
        return fusionRemote:InvokeServer(baseUUID, sacrificeUUID)
    end)

    if not callOk then
        Util.updateDetailedStatus(string.format("Fusion remote call errored for %s", action.BaseUnit))
        return false
    end

    if success == true then
        playbackUnitTagToUUID[action.BaseUnit] = nil
        playbackUnitTagToUUID[action.SacrificeUnit] = nil

        if resultGuid and type(resultGuid) == "string" then
            playbackUnitTagToUUID[action.ResultUnit] = resultGuid
        else
            warn(string.format("Fusion succeeded but no result GUID returned for %s", action.ResultUnit))
        end

        Util.updateDetailedStatus(string.format("Fused %s + %s → %s ✓", action.BaseUnit, action.SacrificeUnit, action.ResultUnit))
        return true
    else
        Util.updateDetailedStatus(string.format("Fusion failed: %s", tostring(message)))
        return false
    end
end

function Playback.executePlaceSubTower(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Placing sub tower: %s on %s",
        actionIndex, totalActions, action.SubTowerName, action.ParentUnit))

    local parentUUID = playbackUnitTagToUUID[action.ParentUnit]
    if not parentUUID or type(parentUUID) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: No UUID for parent unit %s", action.ParentUnit))
        return false
    end

    -- DON'T clear pendingSubTowerInfo here — the event may have already fired
    local info    = nil
    local deadline = tick() + 15
    while tick() < deadline do
        if pendingSubTowerInfo and pendingSubTowerInfo.parentUUID == parentUUID then
            info = pendingSubTowerInfo
            pendingSubTowerInfo = nil
            break
        end
        task.wait(0.3)
        if not isPlaybackEnabled or not gameInProgress then return false end
    end

    if not info then
        Util.updateDetailedStatus(string.format("Timed out waiting for sub tower token (%s)", action.SubTowerName))
        return false
    end

    local pos    = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])

    local PlaceSubTowerRF = game:GetService("ReplicatedStorage")
        .Packages._Index["sleitnick_knit@1.7.0"]
        .knit.Services.TowerService.RF.PlaceSubTower

    local callOk, result, message, subGUID = pcall(function()
        return PlaceSubTowerRF:InvokeServer(
            parentUUID,
            action.SubTowerName,
            cframe,
            { placementToken = info.token }
        )
    end)

    if callOk and result == true then
        if subGUID and type(subGUID) == "string" then
            playbackUnitTagToUUID[action.SubUnitTag] = subGUID
        end
        Util.updateDetailedStatus(string.format("Placed sub tower %s ✓", action.SubTowerName))
        return true
    end

    Util.updateDetailedStatus(string.format("Sub tower placement failed: %s", tostring(message)))
    return false
end

function Playback.executeReplaceUnit(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Replacing unit: %s", actionIndex, totalActions, action.NewUnit))

    local TowerServiceRF = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.TowerService.RF

    -- Wait for BeginUnitReplacement to give us the live GUID
    local deadline = tick() + 15
    while not pendingReplacementInfo and tick() < deadline do
        task.wait(0.3)
        if not isPlaybackEnabled or not gameInProgress then return false end
    end

    local info = pendingReplacementInfo
    if not info then
        Util.updateDetailedStatus("Timed out waiting for replacement GUID")
        return false
    end
    pendingReplacementInfo = nil

    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])

    local callOk, result = pcall(function()
        return TowerServiceRF.CommitUnitReplacement:InvokeServer(info.guid, cframe)
    end)

    -- Clear old tag mappings regardless of result (same as recording side)
    if action.SourceUnit then
        playbackUnitTagToUUID[action.SourceUnit] = nil
    end

    -- Map new tag to the GUID from BeginUnitReplacement
    -- Also try to find it fresh in GC as fallback
    local newUUID = info.guid
    task.wait(0.5)
    local excludeUUIDs = {}
    for _, mappedUUID in pairs(playbackUnitTagToUUID) do excludeUUIDs[mappedUUID] = true end
    local foundUUID = UnitTracker.findNewInGC(action.UnitName, excludeUUIDs)
    if foundUUID then
        newUUID = foundUUID
        print(string.format("Found replaced unit in GC: %s -> %s", action.NewUnit, newUUID))
    end

    playbackUnitTagToUUID[action.NewUnit] = newUUID
    -- Also keep source tag mapped as fallback in case timing is off
    if action.SourceUnit then
        playbackUnitTagToUUID[action.SourceUnit] = newUUID
    end

    Util.updateDetailedStatus(string.format("Replaced → %s ✓ (UUID: %s)", action.NewUnit, newUUID))
    return true
end

function Playback.executeAutoAbility(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Auto ability %s slot %d = %s",
        actionIndex, totalActions, action.Unit, action.AbilitySlot, tostring(action.Enabled)))

    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid or type(uuid) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: No UUID for %s", action.Unit))
        return false
    end

    local success = pcall(function()
        game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"]
            .knit.Services.TowerService.RF.AutoAbility
            :InvokeServer(uuid, action.AbilitySlot, action.Enabled)
    end)

    if success then
        Util.updateDetailedStatus(string.format("Auto ability set: %s slot %d = %s ✓",
            action.Unit, action.AbilitySlot, tostring(action.Enabled)))
        return true
    end
    Util.updateDetailedStatus("Auto ability failed")
    return false
end

function Playback.executeToggleAutoUpgrade(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Toggle auto upgrade: %s", actionIndex, totalActions, action.Unit))

    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid or type(uuid) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: No UUID for %s", action.Unit))
        return false
    end

    local success = pcall(function()
        game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"]
            .knit.Services.DataService.RF.ToggleAutoUpgrade
            :InvokeServer(uuid)
    end)

    if success then
        Util.updateDetailedStatus(string.format("Toggled auto upgrade: %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Toggle auto upgrade failed")
    return false
end

function Playback.executeIncrementAutoUpgradePriority(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Increment auto upgrade priority: %s", actionIndex, totalActions, action.Unit))

    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid or type(uuid) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: No UUID for %s", action.Unit))
        return false
    end

    local success = pcall(function()
        game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"]
            .knit.Services.DataService.RF.IncrementAutoUpgradePriority
            :InvokeServer(uuid)
    end)

    if success then
        Util.updateDetailedStatus(string.format("Incremented auto upgrade priority: %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Increment auto upgrade priority failed")
    return false
end

-- ============================================
-- CLEANUP FUNCTIONS
-- ============================================

function UnitTracker.clearSpawnIdMappings()
    playbackUnitTagToUUID = {}
    recordingUnitCounter = {}
    recordingUUIDToTag = {}
    pendingUpgrades = {}
    for uuid, connection in pairs(unitChangeListeners) do
        pcall(function() connection:Disconnect() end)
    end
    unitChangeListeners = {}
    RecordCache.secondaryUnits = nil
    RecordCache.lastSecondaryCheck = 0
    RecordCache.lastLoadoutCheck = 0
    RecordCache.loadout = nil
    RecordCache.unitDataCache = {}
end

function GameState.startRecording()
    if isRecording then return end
    macro = {}
    UnitTracker.clearSpawnIdMappings()
    isRecording = true
    recordingHasStarted = true
    gameStartTime = tick()
    UnitTracker.startUpgradePolling()
    Util.updateMacroStatus("Recording...")
end

function GameState.stopRecording()
    if not isRecording then return end
    isRecording = false
    recordingHasStarted = false
    local actionCount = #macro
    if currentMacroName and currentMacroName ~= "" then
        macroManager[currentMacroName] = macro
        MacroIO.save(currentMacroName, macro)
        Util.updateMacroStatus(string.format("Saved %d actions to %s", actionCount, currentMacroName))
    else
        Util.updateMacroStatus(string.format("Recording stopped (%d actions)", actionCount))
    end
    return macro
end

function MacroIO.savePathPriorities()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local fileName = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    local json = game:GetService("HttpService"):JSONEncode(PathState.BlessingPriorities)
    writefile(fileName, json)
end

function MacroIO.saveRagnarokPriorities()
    MacroIO.ensureFolders()
    writefile(string.format("LixHub/%s_CardSettings_UTD.json", Services.Players.LocalPlayer.Name), Services.HttpService:JSONEncode(RagnarokState.CardPriorities))
end

-- Function to load path priorities from file
function MacroIO.loadPathPriorities()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local filePath = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    if not isfile(filePath) then return {} end
    local json = readfile(filePath)
    local data = game:GetService("HttpService"):JSONDecode(json)
    print("✓ Loaded path priorities")
    return data or {}
end

function MacroIO.loadRagnarokPriorities()
    local filePath = string.format("LixHub/%s_CardSettings_UTD.json", Services.Players.LocalPlayer.Name)
    if not isfile(filePath) then return {} end
    return Services.HttpService:JSONDecode(readfile(filePath)) or {}
end

function PathSystem.getCardOptions()
    local cards = {}
    local success = pcall(function()
        local cardsFolder = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Paths.PathSelection.Cards
        local frameChildren = {}
        for _, child in ipairs(cardsFolder:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("^Card") then
                table.insert(frameChildren, child)
            end
        end
        table.sort(frameChildren, function(a, b)
            if a.LayoutOrder ~= b.LayoutOrder then return a.LayoutOrder < b.LayoutOrder end
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)
        for cardIndex, cardFrame in ipairs(frameChildren) do
            local titleLabel = cardFrame:FindFirstChild("Title")
            local topTitleLabel = cardFrame:FindFirstChild("TopTitle")
            if titleLabel and topTitleLabel then
                local uiBlessingName = titleLabel.Text
                local uiCleanName = uiBlessingName:gsub("[^%w]", ""):lower()
                local matchedKey = nil
                local highestPriority = 0
                for sliderKey, priority in pairs(PathState.BlessingPriorities) do
                    local cleanSliderKey = sliderKey:lower()
                    if uiCleanName:find(cleanSliderKey, 1, true) then
                        if priority > highestPriority then
                            matchedKey = sliderKey
                            highestPriority = priority
                        end
                    end
                end
                if not matchedKey then
                    matchedKey = uiBlessingName:gsub("[^%w]", "")
                    if not PathState.BlessingPriorities[matchedKey] then
                        PathState.BlessingPriorities[matchedKey] = 0
                    end
                    highestPriority = 0
                end
                table.insert(cards, { index = cardIndex, blessingName = uiBlessingName, pathName = "", sliderKey = matchedKey, priority = highestPriority })
            end
        end
    end)
    if not success then warn("Failed to get card options") return {} end
    return cards
end

function PathSystem.selectBestCard()
    if not BlessingService then warn("BlessingService not initialized") return false end
    local cards = PathSystem.getCardOptions()
    if #cards == 0 then warn("No cards found") return false end
    table.sort(cards, function(a, b) return a.priority > b.priority end)
    local bestCard = cards[1]
    local remoteName = #cards >= 5 and "GetNewPath" or "GetNewBlessing"
    local remoteType = #cards >= 5 and "Path" or "Blessing"
    local success = pcall(function()
        BlessingService:WaitForChild(remoteName):FireServer(bestCard.index)
    end)
    if success then
        Rayfield:Notify({ Title = "Auto " .. remoteType, Content = string.format("Selected: %s", bestCard.blessingName), Duration = 3 })
        return true
    end
    warn(string.format("Failed to select card via %s", remoteName))
    return false
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoSelectPath then
            if not BlessingService then
                local timeout = 0
                while not BlessingService and timeout < 20 do task.wait(0.5) timeout = timeout + 1 end
                if not BlessingService then continue end
            end
            local pathsUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("GameUI")
            if pathsUI then
                pathsUI = pathsUI:FindFirstChild("Paths")
                if pathsUI and pathsUI.Enabled then
                    task.wait(0.5)
                    PathSystem.selectBestCard()
                    task.wait(1)
                end
            end
        end
    end
end)

function Util.deepCopy(tbl, seen)
    if type(tbl) ~= "table" then return tbl end
    seen = seen or {}
    if seen[tbl] then return seen[tbl] end
    local copy = {}
    seen[tbl] = copy
    for k, v in pairs(tbl) do copy[k] = Util.deepCopy(v, seen) end
    return copy
end

function Util.isTrackedPath(path)
    return
        path:match("^Currency%.") or
        path == "Battlepass.PassEXP" or
        path == "Stats.Experience" or
        path:match("^Relics%.[^%.]+$") or
        path:match("^Units%.Inventory%.%[.+%]$") or
        path:match("^Items%.CraftingItems") or 
        path:match("^Items%.UniqueItems")
end

    local ItemsFolder = Services.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Items")
    for _, module in ipairs(ItemsFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local ok, data = pcall(require, module)
            if ok and type(data) == "table" and data.Name and module.Name then
                FriendlyNameToID[data.Name] = module.Name
            end
        end
    end

function Webhook.getRewards(before, after, path)
    path = path or ""
    local rewards = {}
    for k, afterVal in pairs(after) do
        local beforeVal = before and before[k]
        local currentPath = path == "" and tostring(k) or path .. "." .. tostring(k)
        if not Util.isTrackedPath(currentPath) then
            if type(afterVal) == "table" and type(beforeVal) == "table" then
                local nestedRewards = Webhook.getRewards(beforeVal, afterVal, currentPath)
                for rewardKey, rewardVal in pairs(nestedRewards) do
                    rewards[rewardKey] = (rewards[rewardKey] or 0) + rewardVal
                end
            end
            continue
        end
        if beforeVal == nil then
            if type(afterVal) == "table" then
                if afterVal.ID and afterVal.Type and afterVal.Rarity then
                    local rewardKey = string.format("%s (%s) (%s)", afterVal.ID, afterVal.Type, afterVal.Rarity)
                    rewards[rewardKey] = (rewards[rewardKey] or 0) + 1
                elseif afterVal.UnitId then
                    local rewardKey = string.format("NEW UNIT: %s", afterVal.UnitId)
                    rewards[rewardKey] = (rewards[rewardKey] or 0) + 1
                    rewards["__UNIT_DROP__"] = true
                end
            end
        elseif type(afterVal) == "number" and beforeVal == nil then
            local itemName = currentPath:match("%.([^%.]+)$") or currentPath
            if currentPath:match("CraftingItems%.") then
                rewards["Crafting: " .. itemName] = (rewards["Crafting: " .. itemName] or 0) + afterVal
            elseif currentPath:match("UniqueItems%.") then
                rewards["Unique: " .. itemName] = (rewards["Unique: " .. itemName] or 0) + afterVal
            end
        elseif type(afterVal) == "number" and type(beforeVal) == "number" then
            local delta = afterVal - beforeVal
            if delta ~= 0 then
                local rewardName = currentPath:match("%.([^%.]+)$") or currentPath
                if rewardName == "PassEXP" then rewardName = "Battlepass XP"
                elseif rewardName == "Experience" then rewardName = "XP" end
                rewards[rewardName] = (rewards[rewardName] or 0) + delta
            end
        elseif type(afterVal) == "table" and type(beforeVal) == "table" then
            local nestedRewards = Webhook.getRewards(beforeVal, afterVal, currentPath)
            for rewardKey, rewardVal in pairs(nestedRewards) do
                rewards[rewardKey] = (rewards[rewardKey] or 0) + rewardVal
            end
        end
    end
    return rewards
end

function Webhook.getCurrencies()
    local p = Services.Players.LocalPlayer
    local icons = {
        Gems          = "<:gem_utd:1501278199382802523>",
        Coins         = "<:coin_utd:1501278159642034176>",
        DevilOrb      = "<:devil_orb_utd:1501278243247095919>",
        IceGifts      = "<:winter_gift_utd:1501278432154226939>",
        Rerolls       = "<:reroll_utd:1501278285336940695>",
        SpiritSouls   = "<:spirit_soul_utd:1501278328609575073>",
        VirtualTokens = "<:virtual_token_utd:1501278372372807792>",
    }
    local order = { "Gems", "Coins", "DevilOrb", "IceGifts", "Rerolls", "SpiritSouls", "VirtualTokens" }
    local lines = {}
    for _, key in ipairs(order) do
        local val = p:GetAttribute(key) or 0
        table.insert(lines, string.format("%s %s", icons[key], Util.formatNumber(val)))
    end
    return table.concat(lines, "\n")
end

function Webhook.send(messageType, gameResult, gameInfo, gameDuration, waveReached)
    if not ValidWebhook or ValidWebhook == "" then return end
    local data
    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or ""),
            embeds = {{ title = "LixHub Notification", description = "Test webhook sent successfully", color = 0x5865F2, footer = { text = "discord.gg/cYKnXE2Nf8" }, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") }}
        }
    elseif messageType == "game_end" then
        local rewards = {}
        local hasUnitDrop = false
        if finishedRewardData and finishedRewardData.rewards then
    local rewardData = finishedRewardData.rewards
    for rewardKey, rewardValue in pairs(rewardData) do
        -- Handle numeric rewards (Gold, Gems, XP, etc.)
        if type(rewardValue) == "number" and rewardValue > 0 then
            local friendlyName = rewardKey
            if rewardKey == "Experience" then friendlyName = "XP"
            elseif rewardKey == "SpiritSouls" then friendlyName = "Spirit Souls" end
            rewards[friendlyName] = rewardValue
        
        -- Handle table-based rewards
        elseif type(rewardValue) == "table" then
            -- Relics
            if rewardKey == "Relics" then
                for relicKey, relicData in pairs(rewardValue) do
                    local relicName = (relicKey:match("^[^:]+:(.+)$") or relicKey):gsub("^%d+Star_", "")
                    local displayName = string.format("%s (%s)", relicName, relicData.Rarity)
                    if relicData.Stars then displayName = displayName .. string.format(" ⭐%d", relicData.Stars) end
                    rewards[displayName] = relicData.Amount or 1
                end
            
            -- Unit drops
            elseif rewardKey == "Unit" then
            if rewardValue.Unit and rewardValue.Rarity then
                hasUnitDrop = true
                local unitName = rewardValue.Unit
                local isShiny = unitName:find(":shiny") or unitName:find(":Shiny")
                unitName = unitName:gsub(":[Ss]hiny", "")
                if isShiny then
                    unitName = unitName .. " (Shiny)"
                end
                rewards[string.format("[%s] %s", rewardValue.Rarity, unitName)] = 1
            end
            
            -- Generic items with ID/Rarity/Amount structure (Kunai, Keys, etc.)
            elseif rewardValue.ID and rewardValue.Rarity and rewardValue.Amount then
                local displayName = rewardKey  -- no rarity prefix
                rewards[displayName] = rewardValue.Amount
            end
        end
    end
end
            local iceGiftsAfter = Services.Players.LocalPlayer:GetAttribute("IceGifts") or 0
            if iceGiftsBefore > 0 then
                local iceGiftsDelta = iceGiftsAfter - iceGiftsBefore
                if iceGiftsDelta > 0 then
                    rewards["IceGifts"] = iceGiftsDelta
                end
            end
            iceGiftsBefore = 0
        finishedRewardData = nil
        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        local rewardsText = ""
        local function getRewardTotal(rewardType)
            local ok, dc = pcall(function() return DataController or Knit.GetController("DataController") end)
            if not ok or not dc then return nil end

            local data = dc:RequestData()
            local currencies = data and data.Currency or {}

            -- Try direct currency match
            if currencies[rewardType] ~= nil then
                return Util.formatNumber(currencies[rewardType])
            end

            -- Try items (CraftingItems / UniqueItems)
            local itemID = FriendlyNameToID[rewardType]
            if itemID then
                local craftingItems = data.Items and data.Items.CraftingItems
                if craftingItems and craftingItems[itemID] then
                    return Util.formatNumber(craftingItems[itemID])
                end
                local uniqueItems = data.Items and data.Items.UniqueItems
                if uniqueItems and uniqueItems[itemID] then
                    return Util.formatNumber(uniqueItems[itemID])
                end
            end
            return nil
        end
        if next(rewards) then
            for rewardType, amount in pairs(rewards) do
                local itemID = FriendlyNameToID[rewardType]
                print("Reward:", rewardType, "-> ItemID:", itemID)
                local sign = amount > 0 and "+" or ""
                local total = getRewardTotal(rewardType)
                if total then
                    rewardsText = rewardsText .. string.format("%s%s %s [%s]\n", sign, Util.formatNumber(amount), rewardType, total)
                else
                    rewardsText = rewardsText .. string.format("%s%s %s\n", sign, Util.formatNumber(amount), rewardType)
                end
            end
            rewardsText = rewardsText:gsub("\n$", "")
        else
            rewardsText = "No rewards obtained"
        end
        local unitStatsLines = {}
        local ok = pcall(function()
            local dc = DataController or Knit.GetController("DataController")
            local units = dc:RequestData("Units", "Inventory")
            local equipped = dc:RequestData("Units", "Equipped") or {}
            local StatsUtil = require(Services.ReplicatedStorage.Shared.Modules.StatsUtil)
            local Config = require(Services.ReplicatedStorage.Shared.Data.Config)
            local levelCap = Config.LevelCap or 70

            for guid, unitData in pairs(units) do
                if table.find(equipped, guid) then
                    local xp = unitData.Experience or 0
                    local level = math.min(StatsUtil.CalculateUnitLevel(xp), levelCap)
                    local takedowns = unitData.TotalTakedowns or 0
                    local name = unitData.UnitId and Util.cleanUnitName(unitData.UnitId) or "Unknown"
                    table.insert(unitStatsLines, string.format("[%d] %s - %s Takedowns", level, name, Util.formatNumber(takedowns)))
                end
            end
            table.sort(unitStatsLines)
        end)
        local unitStatsText = #unitStatsLines > 0 and table.concat(unitStatsLines, "\n") or "Unavailable"
        local titleText = (gameResult and "Stage Completed!" or "Stage Failed!") .. " - " .. tostring(State.sessionRuns) .. " Run(s)"
        local embedColor = gameResult and 0x57F287 or 0xED4245
        local TitleSubText = "Unknown Stage"
        if gameInfo and gameInfo.MapName and gameInfo.Act and gameInfo.Category then
            local resultText = gameResult and "Victory" or "Defeat"
            TitleSubText = string.format("%s - %s (%s) - %s", gameInfo.MapName, gameInfo.Act, gameInfo.Category, resultText)
        end
        local currentWave = workspace:GetAttribute("Wave") or lastWave or 0
        local macroInfo = "None"
        if isPlaybackEnabled and currentMacroName and currentMacroName ~= "" then macroInfo = currentMacroName end
        data = {
            username = "LixHub",
            content = hasUnitDrop and string.format("<@%s>", Config.DISCORD_USER_ID or "") or nil,
            embeds = {{
                title = titleText, description = TitleSubText, color = embedColor,
                fields = {
                    { name = "Player", value = playerName, inline = true },
                    { name = "Duration", value = gameDuration or "Unknown", inline = true },
                    { name = "Waves Completed", value = tostring(currentWave), inline = true },
                    { name = "Macro", value = macroInfo, inline = true },
                    { name = "Stats", value = Webhook.getCurrencies(), inline = false },
                    { name = "Rewards", value = rewardsText, inline = false },
                    { name = "Units", value = unitStatsText, inline = false },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" }, timestamp = timestamp
            }}
        }
    elseif messageType == "match_restart" then
        local rewards = {}
        if beforeRewardData and RequestData then
            local currentRewardData = Util.deepCopy(RequestData:InvokeServer())
            rewards = Webhook.getRewards(beforeRewardData, currentRewardData)
        end
        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        local description = "Unknown Stage"
        if gameInfo and gameInfo.MapName and gameInfo.Act and gameInfo.Category then
            description = string.format("%s Act %s (%s) - Match restarted", gameInfo.MapName, gameInfo.Act, gameInfo.Category)
        end
        local currentWave = waveReached or lastWave or 0
        local timeElapsed = "Unknown"
        if gameInfo and gameInfo.StartTime then
            local duration = tick() - gameInfo.StartTime
            timeElapsed = string.format("%dm %ds", math.floor(duration / 60), math.floor(duration % 60))
        end
        local rewardsText = ""
        if next(rewards) then
            for rewardType, amount in pairs(rewards) do
                local sign = amount > 0 and "+" or ""
                local total = getRewardTotal(rewardType)  -- use auto-mapped totals
                if total then
                    rewardsText = rewardsText .. string.format("%s%s %s [%s]\n", sign, Util.formatNumber(amount), rewardType, total)
                else
                    rewardsText = rewardsText .. string.format("%s%s %s\n", sign, Util.formatNumber(amount), rewardType)
                end
            end
            rewardsText = rewardsText:gsub("\n$", "")
        else
            rewardsText = "No rewards obtained"
        end
        data = {
            username = "LixHub",
            embeds = {{
                title = "Stage Completed!", description = description, color = 0xFFA500,
                fields = {
                    { name = "Player", value = playerName, inline = true },
                    { name = "Time Played", value = timeElapsed, inline = true },
                    { name = "Wave Reached", value = tostring(currentWave), inline = true },
                    { name = "Rewards", value = rewardsText, inline = false },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" }, timestamp = timestamp
            }}
        }
    end
    local payload = Services.HttpService:JSONEncode(data)
    local requestFunc = syn and syn.request or request or http_request or (fluxus and fluxus.request) or getgenv().request
    if not requestFunc then warn("No HTTP function found!") return end
    local success, response = pcall(function()
        return requestFunc({ Url = ValidWebhook, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
    end)
    if success and response and (response.StatusCode == 204 or response.StatusCode == 200) then
        Rayfield:Notify({ Title = "Webhook Sent", Content = "Successfully sent to Discord!", Duration = 2 })
    else
        warn("Webhook failed:", response and response.StatusCode or "No response")
    end
end

function Util.getCurrentWorldKey()
    local category = workspace:GetAttribute("Category")
    local mapName = workspace:GetAttribute("MapName")
    local mapInternal = workspace:GetAttribute("Map")
    if not category or not mapName then return nil end
    local categoryLower = category:lower()

    if categoryLower == "story" and mapInternal == "Winter" then
    return "winter_event"
    end

    if categoryLower == "story" then
        return "challenge_" .. mapName:lower():gsub("%s+", "_")
    end

    if categoryLower == "featured" then
        if mapName:lower():find("frozen") or mapName == "Frozen Stronghold" then
            return "challenge_featured"
        end
        if mapInternal and mapInternal:find("Olympus") then
            return "olympus_judgement"
        end
        if mapInternal == "KatakuriFCFeaturedChallenge" then  -- add this
            return "mirror_dimension"
        end
    end

    if categoryLower == "legendstage" then
        return "legend_" .. mapName:lower():gsub("%s+", "_")
    end

    if categoryLower:find("virtual") then
        return "virtual_" .. mapName:lower():gsub("%s+", "_")
    end

    if categoryLower == "raid" then
        if mapInternal then return "raid_" .. mapInternal:lower() end
        local moduleName = UINameToModuleName[mapName]
        if moduleName then return "raid_" .. moduleName:lower() end
    end

    if categoryLower == "ragnarok" then
        return "ragnarok"
    end

    if categoryLower == "shinobialliance" then
        return "shinobi_alliance"
    end

    if categoryLower == "worldraid" then
        if mapInternal == "AntKing" then return "ant_king_lair" end
        if mapInternal == "Kaido" then return "emperors_kingdom" end
    end

    if categoryLower == "rift" then
        if mapName == "The Strongest Of Today" then return "universal_tear_gojo" end
        if mapName == "The Strongest Of All Time" then return "universal_tear_sukuna" end
    end
    if categoryLower == "whitebeard" then
        if mapInternal == "WhiteBeardBlitz" then return "blitz" end
    end
    return nil
end

function Util.notify(params)
    if State.disableScriptNotifications then return end
    if type(params) == "string" then
        Rayfield:Notify({ Title = params, Content = "", Duration = 3 })
    elseif type(params) == "table" then
        Rayfield:Notify({
            Title = params.Title or "Notification",
            Content = params.Content or "",
            Duration = params.Duration or 3
        })
    end
end

function Util.canPerformAction()
    return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
end

function Util.setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()
    Util.notify(action, "Joining...")
end

function Util.clearProcessingState()
    AutoJoinState.isProcessing = false
    AutoJoinState.currentAction = nil
end

function AutoJoin.getModuleNameFromUI(uiName, category)
    if category == "Story" or category == "VirtualRealm" or category == "Raid" then
        local moduleName = UINameToModuleName[uiName]
        if moduleName then return moduleName end
        warn(string.format("⚠️ No module name found for UI name: %s", uiName))
        return uiName
    end
    if category == "LegendStage" then
        local success, moduleName = pcall(function()
            local LegendFolder = Services.ReplicatedStorage.Shared.Data.LegendStages
            for _, stageModule in ipairs(LegendFolder:GetChildren()) do
                if stageModule:IsA("ModuleScript") then
                    local stageData = require(stageModule)
                    if stageData.Information and stageData.Information.Name == uiName then
                        return stageModule.Name
                    end
                end
            end
            return nil
        end)
        if success and moduleName then return moduleName end
        warn(string.format("⚠️ No module name found for Legend stage: %s", uiName))
        return uiName
    end
    return uiName
end

function Util.convertDifficultyMeter(percentage)
    return percentage / 100
end

function AutoJoin.checkRerollLimit(challengeKey)
    local success, result = pcall(function()
        local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.DataService.RF.GetRerollLimit
        local current, limit = Event:InvokeServer(challengeKey)
        return current, limit
    end)
    if not success then return false end
    local current, limit = result
    if type(current) ~= "number" or type(limit) ~= "number" then return false end
    return current >= limit
end

function AutoJoin.joinStory(mapUIName, act, difficulty, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "Story")
    local gameData = { Category = "Story", Map = mapModuleName, Act = tostring(act), Difficulty = difficulty, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinWinter(act, difficulty, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local gameData = { Category = "LimitedTimeModes", Map = "Winter", Act = tostring(act), Difficulty = difficulty, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinLegend(mapUIName, act, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "LegendStage")
    local gameData = { Category = "LegendStage", Map = mapModuleName, Act = tostring(act), Difficulty = nil, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinVirtual(mapUIName, act, difficulty, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "VirtualRealm")
    local gameData = { Category = "VirtualRealm", Map = mapModuleName, Act = tostring(act), Difficulty = difficulty, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinRaid(mapUIName, act)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "Raid")
    local actValue = (act == "BossRush" or act == "Boss Rush") and "Boss Rush" or tostring(act)
    local gameData = { Category = "Raid", Map = mapModuleName, Act = actValue, Difficulty = "Nightmare", Modulation = 1.0, FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.waitForChallengeError(timeout)
    local startTime = tick()
    timeout = timeout or 3
    while tick() - startTime < timeout do
        local success, errorDetected = pcall(function()
            local messageList = Services.Players.LocalPlayer.PlayerGui.LobbyUi.Messages.Middle.MessageList
            local errorFrame = messageList:FindFirstChild("Error")
            if errorFrame then
                local messageText = errorFrame:FindFirstChild("Frame")
                if messageText then
                    messageText = messageText:FindFirstChild("MessageText")
                    if messageText then
                        local text = messageText.Text
                        if text:lower():find("already beaten") or text:lower():find("already completed") then
                            return true
                        end
                    end
                end
            end
            return false
        end)
        if success and errorDetected then return true end
        task.wait(0.1)
    end
    return false
end

function AutoJoin.joinDailyChallenge()
    if not ChallengeController or not PodController then warn("Controllers not initialized") return false end
    local challenges = AutoJoin.getCurrentChallengesData()
    if not challenges or not challenges["Daily"] then return false end

    local matchingChallenges = AutoJoin.findAllMatchingChallenges(challenges["Daily"])
    if #matchingChallenges == 0 then return false end

    for _, challenge in ipairs(matchingChallenges) do
        if challenge.data.Completed == true then continue end
        local success = pcall(function()
            PodController:RequestPod({
                Category = "Challenge",
                Challenge = { Type = "Daily", Number = challenge.index },
                Map = challenge.data.Map,
                Act = tostring(challenge.data.Act),
                Difficulty = "Easy",
                Modulation = 1.0,
                FriendsOnly = false,
            })
        end)
        if success then
            task.wait(1)
            local errorDetected = AutoJoin.waitForChallengeError(3)
            if errorDetected then continue end
            return true
        end
    end
    return false
end

function AutoJoin.joinChallenge(challengeType, challengeNumber)
    if not PodController or not ChallengeController then warn("Controllers not initialized") return false end
    local challenges = ChallengeController:GetCurrentChallenges()
    if not challenges or not challenges[challengeType] or not challenges[challengeType][challengeNumber] then
        warn(string.format("Challenge not found: %s #%d", challengeType, challengeNumber))
        return false
    end
    local challengeData = challenges[challengeType][challengeNumber]
    if challengeData.Completed == true then return "already_completed" end
    local gameData = { Category = "Challenge", Challenge = { Type = challengeType, Number = challengeNumber }, Map = challengeData.Map, Act = tostring(challengeData.Act), Difficulty = "Easy", Modulation = 1.0, FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    if success then
        task.wait(1)
        local errorDetected = AutoJoin.waitForChallengeError(3)
        if errorDetected then
            pcall(function()
                local LobbyUi = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
                if LobbyUi then
                    local closeButton = LobbyUi.Messages.Middle.MessageList.Error.CloseButton
                    if closeButton then
                        for _, conn in pairs(getconnections(closeButton.MouseButton1Down)) do
                            if conn.Enabled then conn:Fire() end
                        end
                    end
                end
            end)
            task.wait(0.3)
            return "already_completed"
        end
        return true
    end
    return false
end

function AutoJoin.joinFeaturedChallenge()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(
            buffer.fromstring(")\x11\x00Frozen Stronghold\x01\x02\a\x00Special\x00\x00\x80?\x01\x001\x00\x04\x00Easy\x00\x00\t\x00Challenge\x00\x00"),
            nil
        )
    end)
    return success
end

function AutoJoin.joinOlympusJudgement()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\x11\x00Olympus Judgement\x01\x01\a\x00Special\x00\x00\x80?\x01\x001\x00\x04\x00Easy\x00\x00\t\x00Challenge\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.joinShinobiAlliance()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\x0F\x00ShinobiAlliance\x00\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\x0F\x00ShinobiAlliance\x10\x00LimitedTimeModes\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.joinAntKingLair()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\a\x00AntKing\x00\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\x00\x00\t\x00WorldRaid\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.joinRagnarok()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\b\x00Ragnarok\x00\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\b\x00Ragnarok\x10\x00LimitedTimeModes\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.startGameViaAPI()
    if not PodController then warn("PodController not initialized") return false end
    local success = pcall(function()
        local startButton = Services.Players.LocalPlayer.PlayerGui.LobbyUi.PartyFrame.RightFrame.Content.Buttons.Container1.Start.Hitbox
        for _, conn in pairs(getconnections(startButton.MouseButton1Up)) do
            if conn.Enabled then conn:Fire() end
        end
    end)
    return success
end

function AutoJoin.waitForJoinSuccess(timeout)
    local startTime = tick()
    timeout = timeout or 10
    while tick() - startTime < timeout do
        local success, partyFrameVisible = pcall(function()
            local partyFrame = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
            if partyFrame then
                partyFrame = partyFrame:FindFirstChild("PartyFrame")
                if partyFrame then return partyFrame.Enabled end
            end
            return false
        end)
        if success and partyFrameVisible then return true end
        task.wait(0.5)
    end
    return false
end

function AutoJoin.waitForPortalJoinSuccess(timeout)
    print("Waiting for portal join success...")
    local startTime = tick()
    timeout = timeout or 10
    while tick() - startTime < timeout do
        local ok, visible = pcall(function()
            local portalParty = Services.Players.LocalPlayer.PlayerGui.LobbyUi:FindFirstChild("PortalParty")
            return portalParty and portalParty.Enabled
        end)
        if ok and visible then print("Portal join successful!") return true end
        task.wait(0.5)
    end
    print("Portal join failed after waiting")
    return false
end

function AutoJoin.tryStartGameWithRetry(maxAttempts)
    maxAttempts = maxAttempts or 3
    for attempt = 1, maxAttempts do
        AutoJoin.startGameViaAPI()
        local waitStart = tick()
        while tick() - waitStart < 3 do
            if not Util.isInLobby() then return true end
            local success, partyFrameVisible = pcall(function()
                local partyFrame = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
                if partyFrame then
                    partyFrame = partyFrame:FindFirstChild("PartyFrame")
                    if partyFrame then return partyFrame.Enabled end
                end
                return false
            end)
            if success and not partyFrameVisible then return true end
            task.wait(0.3)
        end
        local success, partyFrameVisible = pcall(function()
            local partyFrame = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
            if partyFrame then
                partyFrame = partyFrame:FindFirstChild("PartyFrame")
                if partyFrame then return partyFrame.Enabled end
            end
            return false
        end)
        if not success or not partyFrameVisible then return true end
        task.wait(0.5)
    end
    warn(" Failed to start game after", maxAttempts, "attempts - clicking Leave")
    pcall(function()
        local leaveButton = Services.Players.LocalPlayer.PlayerGui.LobbyUi.PartyFrame.RightFrame.Content.Buttons.Container1.Leave.Hitbox
        for _, conn in pairs(getconnections(leaveButton.MouseButton1Up)) do
            if conn.Enabled then conn:Fire() end
        end
    end)
    task.wait(2)
    return false
end

function AutoJoin.tryStartPortalWithRetry(maxAttempts)
    maxAttempts = maxAttempts or 3

    for attempt = 1, maxAttempts do
        print("Portal start attempt", attempt)
        pcall(function()
            local startHitbox = Services.Players.LocalPlayer.PlayerGui.LobbyUi
                .PortalParty.RightFrame.Content.Container.MainPanel
                .ContainerBottom.Buttons.Start.Hitbox
                print("Found hitbox:", startHitbox)
            for _, conn in pairs(getconnections(startHitbox.MouseButton1Click)) do
                if conn.Enabled then conn:Fire() end
            end
        end)

        local waitStart = tick()
        while tick() - waitStart < 3 do
            if not Util.isInLobby() then return true end
            local ok, visible = pcall(function()
                local portalParty = Services.Players.LocalPlayer.PlayerGui.LobbyUi:FindFirstChild("PortalParty")
                return portalParty and portalParty.Enabled
            end)
            if ok and not visible then return true end
            task.wait(0.3)
        end

        local ok, visible = pcall(function()
            local portalParty = Services.Players.LocalPlayer.PlayerGui.LobbyUi:FindFirstChild("PortalParty")
            return portalParty and portalParty.Enabled
        end)
        if not ok or not visible then return true end
        task.wait(0.5)
    end

    warn("Failed to start portal after", maxAttempts, "attempts - clicking Leave")
    pcall(function()
        local leaveHitbox = Services.Players.LocalPlayer.PlayerGui.LobbyUi
            .PortalParty.RightFrame.Content.Container.MainPanel
            .ContainerBottom.Buttons.Leave.Hitbox
        for _, conn in pairs(getconnections(leaveHitbox.MouseButton1Click)) do
            if conn.Enabled then conn:Fire() end
        end
    end)
    task.wait(2)
    return false
end

function AutoJoin.getCurrentChallengesData()
    if not ChallengeController then warn("ChallengeController not initialized") return nil end
    local success, challenges = pcall(function() return ChallengeController:GetCurrentChallenges() end)
    if success and challenges then return challenges end
    return nil
end

function AutoJoin.challengeMatchesFilters(challengeData)
    local challengeMapModule = challengeData.Map
    local modifiers = challengeData.Modifiers or {}
    local reward = challengeData.Reward

    if #State.IgnoreWorlds > 0 then
        for _, ignoredMapUI in ipairs(State.IgnoreWorlds) do
            local ignoredMapModule = UINameToModuleName[ignoredMapUI]
            if ignoredMapModule and challengeMapModule == ignoredMapModule then return false end
        end
    end

    if #State.IgnoreModifier > 0 then
        for _, modifierName in pairs(modifiers) do
            for _, ignoredModifier in ipairs(State.IgnoreModifier) do
                if modifierName == ignoredModifier then return false end
            end
        end
    end

    if #State.SelectedChallengeRewards > 0 then
        -- Map dropdown display names to actual Currency/Item keys
        local rewardKeyMap = {
            ["Universal Fragment"] = "UniversalFragment",
            ["Frozen Fragment"]    = "FrozenFragment",
            ["Ocean Fragment"]     = "OceanFragment",
            ["Petal Fragment"]     = "PetalFragment",
            ["Sky Fragment"]       = "SkyFragment",
            ["Burning Fragment"]   = "BurningFragment",
            ["Holy Fragment"]      = "HolyFragment",
            ["Phantom Fragment"]   = "PhantomFragment",
            ["Gems"]               = "Gems",
            ["Stat Rerolls"]       = "StatRerolls",
            ["Trait Rerolls"]      = "Rerolls",
            ["Relic Rerolls"]      = "RelicRerolls",
            ["Locks"]              = "Locks",
        }

        -- Load the reward module and collect all keys from Currency + Items
        local rewardKeys = {}
        pcall(function()
            local module = game:GetService("ReplicatedStorage").Shared.Data.ChallengeRewards:FindFirstChild(reward)
            if not module then return end
            local data = require(module)
            if data.Currency then
                for k in pairs(data.Currency) do rewardKeys[k] = true end
            end
            if data.Items then
                for k in pairs(data.Items) do rewardKeys[k] = true end
            end
        end)

        -- Check if at least one selected reward exists in this challenge's rewards
        local rewardMatches = false
        for _, selectedReward in ipairs(State.SelectedChallengeRewards) do
            local key = rewardKeyMap[selectedReward]
            if key and rewardKeys[key] then
                rewardMatches = true
                break
            end
        end
        if not rewardMatches then return false end
    else
        return false
    end

    return true
end

function AutoJoin.findAllMatchingChallenges(challengesData)
    local matchingChallenges = {}
    for challengeIndex, challengeData in pairs(challengesData) do
        if type(challengeIndex) ~= "number" then continue end
        if AutoJoin.challengeMatchesFilters(challengeData) then
            table.insert(matchingChallenges, { index = challengeIndex, data = challengeData, score = (challengeData.Act or 0) * 10 })
        end
    end
    table.sort(matchingChallenges, function(a, b) return a.score > b.score end)
    return matchingChallenges
end

function Util.isGameDataLoaded()
    local success = pcall(function()
        return Services.ReplicatedStorage:FindFirstChild("Shared") and
               Services.ReplicatedStorage.Shared:FindFirstChild("Data")
    end)
    return success
end

function AutoJoin.joinUniversalTear()
    local currentRift = game:GetService("ReplicatedStorage"):GetAttribute("CurrentRiftMap")
    if not currentRift then
        warn("No CurrentRiftMap attribute found")
        return false
    end
    
    local selectedMaps = State.SelectedRiftMaps or {}
    if #selectedMaps == 0 then
        warn("No rift maps selected")
        return false
    end
    
    local matchFound = false
    for _, map in ipairs(selectedMaps) do
        if currentRift == map then matchFound = true break end
    end
    
    if not matchFound then
        return false -- current rift not in selected list, skip
    end
    
    local Event = game:GetService("ReplicatedStorage").ByteNetReliable
    local success = false
    
    if currentRift == "MegunaRift" then
        success = pcall(function()
            Event:FireServer(buffer.fromstring(")\n\x00MegunaRift\x00\x00\x00\x80?\x01\x001\x00\x04\x00Easy\x00\x00\x05\x00Rifts\x00\x00"), nil)
        end)
    elseif currentRift == "GojoRift" then
        success = pcall(function()
            Event:FireServer(buffer.fromstring(")\b\x00GojoRift\x00\x00\x00\x80?\x01\x001\x00\x04\x00Easy\x00\x00\x05\x00Rifts\x00\x00"), nil)
        end)
    end
    
    return success
end

function AutoJoin.joinBlitz()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\x0F\x00WhiteBeardBlitz\x00\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\x0F\x00WhiteBeardBlitz\x10\x00LimitedTimeModes\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.joinMirrorDimension()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\n\x00KatakuriFC\x01\x03\a\x00Special\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\x00\x00\t\x00Challenge\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.joinEmperorsKingdom()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\x05\x00Kaido\x00\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\x00\x00\t\x00WorldRaid\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.checkAndExecuteHighestPriority()
    if not Util.isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    if not Util.canPerformAction() then return end
    if not ChallengeController or not PodController then return end
    if not Util.isGameDataLoaded() then return end
    if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi") then
        local lobbyUi = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
        if (lobbyUi:FindFirstChild("PartyFrame") and lobbyUi:FindFirstChild("PartyFrame").Enabled) then return end
    end
 
    if State.AutoJoinChallenge then
        local regularChallengeOnCooldown = false
        local timeSinceLastFail = tick() - (State.LastFailedChallengeAttempt or 0)
        if State.LastFailedChallengeAttempt > 0 and timeSinceLastFail < State.ChallengeJoinCooldown then
            regularChallengeOnCooldown = true
        end
        if not regularChallengeOnCooldown then
            Util.setProcessingState("Challenge Auto Join")

            if State.SelectedChallengeType == "Daily" then
                local success = AutoJoin.joinDailyChallenge()
                if success then
                    State.LastFailedChallengeAttempt = 0
                    if State.useMatchmakeChallenge then
                        task.wait(1.5)
                        pcall(function()
                            game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                        end)
                        local waitStart = tick()
                        while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinChallenge do
                            task.wait(0.5)
                        end
                        task.wait(3)
                    else
                        if AutoJoin.waitForJoinSuccess(10) then
                            if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                        end
                    end
                else
                    State.LastFailedChallengeAttempt = tick()
                end
            else
                local challenges = AutoJoin.getCurrentChallengesData()
                if challenges and challenges["HalfHour"] then
                    local matchingChallenges = AutoJoin.findAllMatchingChallenges(challenges["HalfHour"])
                    if #matchingChallenges > 0 then
                        for _, challenge in ipairs(matchingChallenges) do
                            local success = AutoJoin.joinChallenge("HalfHour", challenge.index)
                            if success == true then
                                State.LastFailedChallengeAttempt = 0
                                if State.useMatchmakeChallenge then
                                    task.wait(1.5)
                                    pcall(function()
                                        game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                                    end)
                                    local waitStart = tick()
                                    while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinChallenge do
                                        task.wait(0.5)
                                    end
                                    task.wait(3)
                                    Util.clearProcessingState()
                                    return
                                else
                                    if AutoJoin.waitForJoinSuccess(10) then
                                        if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                                    end
                                end
                            elseif success == "already_completed" then continue
                            else continue end
                        end
                        State.LastFailedChallengeAttempt = tick()
                    else
                        State.LastFailedChallengeAttempt = tick()
                    end
                else
                    State.LastFailedChallengeAttempt = tick()
                end
            end

            Util.clearProcessingState()
        end
    end

    if State.AutoJoinPortal and State.PortalsSelected and #State.PortalsSelected > 0 then
        Util.setProcessingState("Portal Auto Join")
        local success = AutoJoin.usePortal()
        if success then
            if State.useMatchmakePortal then
                task.wait(1.5)
                pcall(function()
                    game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PortalService.RF.RequestMatchmaking:InvokeServer()
                end)
                local waitStart = tick()
                while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinPortal do
                    task.wait(0.5)
                end
                task.wait(3)
            else
                if AutoJoin.waitForPortalJoinSuccess(10) then
                    if AutoJoin.tryStartPortalWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                end
            end
        end
        Util.clearProcessingState()
    end
 
    if State.AutoJoinFeaturedChallenge then
        if State.LeaveAfterRerollLimitHitTheHunt and not RerollLimitHit.TheHunt then
            RerollLimitHit.TheHunt = AutoJoin.checkRerollLimit("Frozen StrongholdFeaturedChallenge_1")
            if RerollLimitHit.TheHunt then
                Util.notify({ Title = "The Hunt", Content = "Reroll limit hit - skipping", Duration = 4 })
            end
        end
        if not (State.LeaveAfterRerollLimitHitTheHunt and RerollLimitHit.TheHunt) then
            Util.setProcessingState("Featured Challenge Auto Join")
            local success = AutoJoin.joinFeaturedChallenge()
            if success then
                if State.useMatchmakeTheHuntChallenge then
                    task.wait(1.5)
                    pcall(function()
                        game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                    end)
                    local waitStart = tick()
                    while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinFeaturedChallenge do
                        task.wait(0.5)
                    end
                    task.wait(3)
                else
                    if AutoJoin.waitForJoinSuccess(10) then
                        if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                    end
                end
            end
            Util.clearProcessingState()
        end
    end
 
    if State.AutoJoinOlympusJudgement then
        if State.LeaveAfterRerollLimitHitOlympus and not RerollLimitHit.Olympus then
            RerollLimitHit.Olympus = AutoJoin.checkRerollLimit("Olympus JudgementFeaturedChallenge_1")
            if RerollLimitHit.Olympus then
                Util.notify({ Title = "Olympus Judgement", Content = "Reroll limit hit - skipping", Duration = 4 })
            end
        end
        if not (State.LeaveAfterRerollLimitHitOlympus and RerollLimitHit.Olympus) then
            Util.setProcessingState("Olympus Judgement Auto Join")
            local success = AutoJoin.joinOlympusJudgement()
            if success then
                if State.useMatchmakeOlympusJudgement then
                    task.wait(1.5)
                    pcall(function()
                        game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                    end)
                    local waitStart = tick()
                    while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinOlympusJudgement do
                        task.wait(0.5)
                    end
                    task.wait(3)
                else
                    if AutoJoin.waitForJoinSuccess(10) then
                        if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                    end
                end
            end
            Util.clearProcessingState()
        end
    end

    if State.AutoJoinAntKingLair then
        Util.setProcessingState("Ant King Lair Auto Join")
        local success = AutoJoin.joinAntKingLair()
        if success then
            task.wait(1.5)
            pcall(function()
                game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
            end)
            local waitStart = tick()
            while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinAntKingLair do
                task.wait(0.5)
            end
            task.wait(3)
        end
        Util.clearProcessingState()
    end
 
    if State.AutoJoinShinobiAlliance then
        Util.setProcessingState("Shinobi Alliance Auto Join")
        local success = AutoJoin.joinShinobiAlliance()
        if success then
            if State.AutoMatchmakeShinobiAlliance then
                task.wait(1.5) -- wait for lobby to be created
                pcall(function()
                    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
                    Event:FireServer(buffer.fromstring(",\001"), nil)
                end)
                -- just wait for game to start, don't tryStartGameWithRetry
                local waitStart = tick()
                while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinShinobiAlliance do
                    task.wait(0.5)
                end
                task.wait(3)
            else
                if AutoJoin.waitForJoinSuccess(10) then
                    if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                end
            end
        end
        Util.clearProcessingState()
    end

    if State.AutoJoinUniversalTear and State.SelectedRiftMaps and #State.SelectedRiftMaps > 0 then
    local currentRift = game:GetService("ReplicatedStorage"):GetAttribute("CurrentRiftMap")
    if currentRift then
        local matchFound = false
        for _, map in ipairs(State.SelectedRiftMaps) do
            if currentRift == map then matchFound = true break end
        end
        if matchFound then
            Util.setProcessingState("Universal Tear Auto Join")
            local success = AutoJoin.joinUniversalTear()
            if success then
                if State.AutoMatchmakeUniversalTear then
                    task.wait(1.5)
                    pcall(function()
                        game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                    end)
                    local waitStart = tick()
                    while Util.isInLobby() and tick() - waitStart < 30 and State.AutoJoinUniversalTear do
                        task.wait(0.5)
                    end
                    task.wait(3)
                else
                    if AutoJoin.waitForJoinSuccess(10) then
                        if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                    end
                end
            end
            Util.clearProcessingState()
        end
    end
end
 
    if State.AutoJoinRagnarok then
        Util.setProcessingState("Ragnarok Infinite Auto Join")
        local success = AutoJoin.joinRagnarok()
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        end
        Util.clearProcessingState()
    end
 
    if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and State.StoryDifficultySelected and State.StoryDifficultyMeterSelected then
        Util.setProcessingState("Story Auto Join")
        local success = AutoJoin.joinStory(State.StoryStageSelected, State.StoryActSelected, State.StoryDifficultySelected, State.StoryDifficultyMeterSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinLegendStage and State.LegendStageSelected and State.LegendStageActSelected and State.LegendStageDifficultyMeterSelected then
        Util.setProcessingState("Legend Stage Auto Join")
        local success = AutoJoin.joinLegend(State.LegendStageSelected, tonumber(State.LegendStageActSelected), State.LegendStageDifficultyMeterSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinVirtualStage and State.VirtualStageSelected and State.VirtualStageActSelected and State.VirtualStageDifficultySelected and State.VirtualStageDifficultyMeterSelected then
        Util.setProcessingState("Virtual Stage Auto Join")
        local success = AutoJoin.joinVirtual(State.VirtualStageSelected, tonumber(State.VirtualStageActSelected), State.VirtualStageDifficultySelected, State.VirtualStageDifficultyMeterSelected)
        if success then
            if State.useMatchmakeVirtualStage then
                task.wait(1.5)
                pcall(function()
                    game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                end)
                local waitStart = tick()
                while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinVirtualStage do
                    task.wait(0.5)
                end
                task.wait(3)
            else
                if AutoJoin.waitForJoinSuccess(10) then
                    if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinRaid and State.RaidStageSelected and State.RaidActSelected then
        Util.setProcessingState("Raid Stage Auto Join")
        local success = AutoJoin.joinRaid(State.RaidStageSelected, State.RaidActSelected)
        if success then
            if State.useMatchmakeRaid then
                task.wait(1.5)
                pcall(function()
                    game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                end)
                local waitStart = tick()
                while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinRaid do
                    task.wait(0.5)
                end
                task.wait(3)
            else
                if AutoJoin.waitForJoinSuccess(10) then
                    if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinWinterEvent and State.WinterActSelected and State.WinterStageDifficultySelected and State.WinterStageDifficultyMeterSelected then
        Util.setProcessingState("Winter Event Auto Join")
        local success = AutoJoin.joinWinter(State.WinterActSelected, State.WinterStageDifficultySelected, State.WinterStageDifficultyMeterSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
    if State.AutoJoinBlitz then
        Util.setProcessingState("Blitz Auto Join")
        local success = AutoJoin.joinBlitz()
        if success then
            if State.AutoMatchmakeBlitz then
                task.wait(1.5)
                pcall(function()
                    game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                end)
                local waitStart = tick()
                while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinBlitz do
                    task.wait(0.5)
                end
                task.wait(3)
            else
                if AutoJoin.waitForJoinSuccess(10) then
                    if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                end
            end
        end
        Util.clearProcessingState()
    end

    if State.AutoJoinMirrorDimension then
        if State.LeaveAfterRerollLimitHitMirrorDimension and not RerollLimitHit.MirrorDimension then
            RerollLimitHit.MirrorDimension = AutoJoin.checkRerollLimit("KatakuriFCFeaturedChallenge_1")
            if RerollLimitHit.MirrorDimension then
                Util.notify({ Title = "Mirror Dimension", Content = "Reroll limit hit - skipping", Duration = 4 })
            end
        end
        if not (State.LeaveAfterRerollLimitHitMirrorDimension and RerollLimitHit.MirrorDimension) then
        Util.setProcessingState("Mirror Dimension Auto Join")
        local success = AutoJoin.joinMirrorDimension()
        if success then
            if State.AutoMatchmakeMirrorDimension then
                task.wait(1.5)
                pcall(function()
                    game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
                end)
                local waitStart = tick()
                while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinMirrorDimension do
                    task.wait(0.5)
                end
                task.wait(3)
            else
                if AutoJoin.waitForJoinSuccess(10) then
                    if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                end
            end
        end
        Util.clearProcessingState()
    end
    end

    if State.AutoJoinEmperorsKingdom then
        Util.setProcessingState("Emperor's Kingdom Auto Join")
        local success = AutoJoin.joinEmperorsKingdom()
        if success then
            task.wait(1.5)
            pcall(function()
                game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(buffer.fromstring(",\x01"), nil)
            end)
            local waitStart = tick()
            while Util.isInLobby() and tick() - waitStart < 360 and State.AutoJoinEmperorsKingdom do
                task.wait(0.5)
            end
            task.wait(3)
        end
        Util.clearProcessingState()
    end
end

--[[--------------------------------------------------------------]]

AutoPathTab:CreateButton({
    Name = "Export Path Config",
    Callback = function()
        setclipboard(Services.HttpService:JSONEncode(PathState.BlessingPriorities))
        Util.notify({ Title = "Exported", Content = "Path config copied to clipboard", Duration = 3 })
    end,
})

AutoPathTab:CreateInput({
    Name = "Import Path Config", PlaceholderText = "Paste JSON here...", RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local ok, data = pcall(function() return Services.HttpService:JSONDecode(text) end)
        if not ok or type(data) ~= "table" then
            Util.notify({ Title = "Error", Content = "Invalid JSON", Duration = 3 }) return
        end
        for k, v in pairs(data) do
            PathState.BlessingPriorities[k] = v
        end
        for _, slider in ipairs(pathSliders) do
            local flag = slider.Flag
            local key = flag:match("PathPriority_Resonance_(.+)$") or flag:match("PathPriority_[^_]+_(.+)$")
            if key and PathState.BlessingPriorities[key] then
                slider:Set(PathState.BlessingPriorities[key])
            end
        end
        MacroIO.savePathPriorities()
        Util.notify({ Title = "Imported", Content = "Path config applied", Duration = 3 })
    end,
})

AutoPathTab:CreateDivider()

AutoPathTab:CreateLabel("Higher number = higher priority")

AutoPathTab:CreateToggle({
    Name = "Auto Select Path", CurrentValue = false, Flag = "AutoSelectPath",
    Callback = function(Value)
        State.AutoSelectPath = Value
        PathState.AutoSelectPath = Value
    end,
})
 
AutoPathTab:CreateButton({
    Name = "Reset to default",
    Callback = function()
        local totalSliders = #pathSliders
        local currentPriority = totalSliders
        for _, slider in ipairs(pathSliders) do
            slider:Set(currentPriority)
            currentPriority = currentPriority - 1
        end
        MacroIO.savePathPriorities()
    end,
})
AutoPathTab:CreateDivider()

function PathSystem.loadSliders()
    local PathsFolder = game:GetService("ReplicatedStorage").Shared.Data.Paths
    local playerName = game:GetService("Players").LocalPlayer.Name
    local configPath = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    local configExists = isfile(configPath)
    local savedPriorities = configExists and MacroIO.loadPathPriorities() or {}
    for key, value in pairs(savedPriorities) do PathState.BlessingPriorities[key] = value end
    local pathsData = {}
    for _, pathModule in ipairs(PathsFolder:GetChildren()) do
        if pathModule:IsA("ModuleScript") then
            local success, pathData = pcall(function() return require(pathModule) end)
            if success and pathData.Blessings then
                local pathName = pathModule.Name
                pathsData[pathName] = { blessings = {}, resonanceName = nil }
                if pathData.Resonance and pathData.Resonance.Name then
                    pathsData[pathName].resonanceName = pathData.Resonance.Name
                end
                for rarity, blessings in pairs(pathData.Blessings) do
                    for blessingName, blessingData in pairs(blessings) do
                        table.insert(pathsData[pathName].blessings, { name = blessingName, rarity = rarity })
                    end
                end
                table.sort(pathsData[pathName].blessings, function(a, b) return a.name < b.name end)
            end
        end
    end
    local sortedPaths = {}
    for pathName in pairs(pathsData) do table.insert(sortedPaths, pathName) end
    table.sort(sortedPaths)
    local currentPriority = nil
    if not configExists then
        local totalItems = 0
        for _, pathInfo in pairs(pathsData) do
            if pathInfo.resonanceName then totalItems = totalItems + 1 end
            totalItems = totalItems + #pathInfo.blessings
        end
        currentPriority = totalItems
    end
    for _, pathName in ipairs(sortedPaths) do
        local pathInfo = pathsData[pathName]
        if pathInfo.resonanceName then
            local resonanceKey = pathInfo.resonanceName:gsub("[^%w]", "")
            local sliderValue
            if configExists then
                sliderValue = savedPriorities[resonanceKey] or 0
            else
                sliderValue = currentPriority
                savedPriorities[resonanceKey] = sliderValue
                currentPriority = currentPriority - 1
            end
            PathState.BlessingPriorities[resonanceKey] = sliderValue
            local slider = AutoPathTab:CreateSlider({
                Name = string.format("[%s] %s", pathName, pathInfo.resonanceName),
                Range = {0, 100}, Increment = 1, CurrentValue = sliderValue,
                Flag = "PathPriority_Resonance_" .. resonanceKey,
                Callback = function(Value)
                    PathState.BlessingPriorities[resonanceKey] = Value
                    MacroIO.savePathPriorities()
                end,
            })
            table.insert(pathSliders, slider)
        end
        for _, blessing in ipairs(pathInfo.blessings) do
            local sliderKey = blessing.name:gsub("[^%w]", "")
            local sliderValue
            if configExists then
                sliderValue = savedPriorities[sliderKey] or 0
            else
                sliderValue = currentPriority
                savedPriorities[sliderKey] = sliderValue
                currentPriority = currentPriority - 1
            end
            PathState.BlessingPriorities[sliderKey] = sliderValue
            local slider = AutoPathTab:CreateSlider({
                Name = string.format("[%s] %s", pathName, blessing.name),
                Range = {0, 100}, Increment = 1, CurrentValue = sliderValue,
                Flag = "PathPriority_" .. pathName .. "_" .. blessing.name:gsub("%s", ""),
                Callback = function(Value)
                    PathState.BlessingPriorities[sliderKey] = Value
                    MacroIO.savePathPriorities()
                end,
            })
            table.insert(pathSliders, slider)
        end
        AutoPathTab:CreateDivider()
    end
    if not configExists then MacroIO.savePathPriorities() end
end

task.spawn(function()
    task.wait(2)
    local success, err = pcall(PathSystem.loadSliders)
    if not success then
        warn("Failed to load path sliders:", err)
        AutoPathTab:CreateLabel("⚠️ Failed to load paths")
    end
end)

task.spawn(function()
    task.wait(2)
    local savedRagnarok = MacroIO.loadRagnarokPriorities()
    for k, v in pairs(savedRagnarok) do RagnarokState.CardPriorities[k] = v end
end)

RagnarokTab:CreateButton({
    Name = "Export Card Config",
    Callback = function()
        setclipboard(Services.HttpService:JSONEncode(RagnarokState.CardPriorities))
        Util.notify({ Title = "Exported", Content = "Card config copied to clipboard", Duration = 3 })
    end,
})

RagnarokTab:CreateInput({
    Name = "Import Card Config", PlaceholderText = "Paste JSON here...", RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local ok, data = pcall(function() return Services.HttpService:JSONDecode(text) end)
        if not ok or type(data) ~= "table" then
            Util.notify({ Title = "Error", Content = "Invalid JSON", Duration = 3 }) return
        end
        for k, v in pairs(data) do
            RagnarokState.CardPriorities[k] = v
        end
        Rayfield.Flags["RagnarokCard_QuickenedHands"]:Set(RagnarokState.CardPriorities["Quickened Hands"] or 1)
        Rayfield.Flags["RagnarokCard_SpoilsOfWar"]:Set(RagnarokState.CardPriorities["Spoils of War"] or 1)
        Rayfield.Flags["RagnarokCard_SilenceTheGods"]:Set(RagnarokState.CardPriorities["Silence the Gods"] or 1)
        Rayfield.Flags["RagnarokCard_ExtendedReach"]:Set(RagnarokState.CardPriorities["Extended Reach"] or 1)
        Rayfield.Flags["RagnarokCard_ExposedWeakness"]:Set(RagnarokState.CardPriorities["Exposed Weakness"] or 1)
        MacroIO.saveRagnarokPriorities()
        Util.notify({ Title = "Imported", Content = "Card config applied", Duration = 3 })
    end,
})

RagnarokTab:CreateDivider()

RagnarokTab:CreateToggle({
    Name = "Auto Pick Ragnarok Cards",
    CurrentValue = false,
    Flag = "AutoPickRagnarokCards",
    Callback = function(Value)
        RagnarokState.AutoPickEnabled = Value
    end,
})

RagnarokTab:CreateLabel("Higher number = higher priority")
RagnarokTab:CreateDivider()

RagnarokTab:CreateSlider({
    Name = "Quickened Hands",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Quickened Hands"],
    Flag = "RagnarokCard_QuickenedHands",
    Callback = function(Value) RagnarokState.CardPriorities["Quickened Hands"] = Value MacroIO.saveRagnarokPriorities() end,
})
RagnarokTab:CreateSlider({
    Name = "Spoils of War",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Spoils of War"],
    Flag = "RagnarokCard_SpoilsOfWar",
    Callback = function(Value) RagnarokState.CardPriorities["Spoils of War"] = Value MacroIO.saveRagnarokPriorities() end,
})
RagnarokTab:CreateSlider({
    Name = "Silence the Gods",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Silence the Gods"],
    Flag = "RagnarokCard_SilenceTheGods",
    Callback = function(Value) RagnarokState.CardPriorities["Silence the Gods"] = Value MacroIO.saveRagnarokPriorities() end,
})
RagnarokTab:CreateSlider({
    Name = "Extended Reach",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Extended Reach"],
    Flag = "RagnarokCard_ExtendedReach",
    Callback = function(Value) RagnarokState.CardPriorities["Extended Reach"] = Value MacroIO.saveRagnarokPriorities() end,
})
RagnarokTab:CreateSlider({
    Name = "Exposed Weakness",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Exposed Weakness"],
    Flag = "RagnarokCard_ExposedWeakness",
    Callback = function(Value) RagnarokState.CardPriorities["Exposed Weakness"] = Value MacroIO.saveRagnarokPriorities() end,
})

task.spawn(function()
    task.wait(2)
    local success, CardChoiceRE = pcall(function()
        return game:GetService("ReplicatedStorage")
            .Packages._Index["sleitnick_knit@1.7.0"]
            .knit.Services.CardChoiceService.RE
    end)
    if not success or not CardChoiceRE then
        warn("Failed to find CardChoiceService RE")
        return
    end

    CardChoiceRE.GetNewCards.OnClientEvent:Connect(function(channel, cards, config)
        if channel ~= "RagnarokCard" then return end
        if not RagnarokState.AutoPickEnabled then return end

        local bestIndex = 1
        local bestPriority = -1

        for i, card in ipairs(cards) do
            local priority = RagnarokState.CardPriorities[card.name] or 0
            if priority > bestPriority then
                bestPriority = priority
                bestIndex = i
            end
        end

        task.wait(0.5)

        if workspace:GetAttribute(config.votedAttribute) then return end

        local voteSuccess = pcall(function()
            CardChoiceRE.VoteCard:FireServer(channel, bestIndex)
        end)

        if voteSuccess then
            local chosenCard = cards[bestIndex]
            Util.notify({
                Title = "Ragnarok Card Picked",
                Content = "Selected: " .. (chosenCard and chosenCard.name or "Unknown"),
                Duration = 4,
            })
        end
    end)
    CardChoiceRE.GetNewCards.OnClientEvent:Connect(function(channel, cards, config)
    if channel ~= "RagnarokValkyrie" then return end

    -- RECORDING: Save which valk was picked by listening for VoteCard
    -- We'll store the card list so we can match by index later
    if isRecording and recordingHasStarted then
        -- Store cards so we can record the pick when VoteCard fires
        pendingValkCardList = cards
    end
end)
end)

JoinerTab:CreateSection("Story Joiner")

AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story", CurrentValue = false, Flag = "AutoJoinStory",
    Callback = function(Value) State.AutoJoinStory = Value end,
})
 
local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Stage", Options = {}, CurrentOption = {}, Flag = "StoryStageSelector",
    Callback = function(Option) State.StoryStageSelected = Option[1] end,
})
 
ChapterDropdown869 = JoinerTab:CreateDropdown({
    Name = "Select Story Act", Options = {"Act 1","Act 2","Act 3","Act 4","Act 5","Act 6","Infinite"},
    CurrentOption = {}, MultipleOptions = false, Flag = "StoryActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        if selectedOption == "Infinite" then State.StoryActSelected = "Infinite"
        else local num = selectedOption:match("%d+") if num then State.StoryActSelected = num end end
    end,
})
 
ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Difficulty", Options = {"Easy","Hard","Nightmare"},
    CurrentOption = {}, MultipleOptions = false, Flag = "StoryDifficultySelector",
    Callback = function(Option)
        State.StoryDifficultySelected = Option[1]
    end,
})
 
StorySlider = JoinerTab:CreateSlider({
    Name = "Select Difficulty Meter", Range = {75, 1000}, Increment = 1,
    Suffix = "", CurrentValue = 100, Flag = "StoryDifficultyMeterSelector",
    Callback = function(Value) State.StoryDifficultyMeterSelected = Value end,
})

JoinerTab:CreateInput({
    Name = "Select Difficulty Meter",
    PlaceholderText = "75 - 1000",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 75, 1000)
        num = math.round(num)
        StorySlider:Set(num)
        State.StoryDifficultyMeterSelected = num
    end,
})
 
JoinerTab:CreateSection("Legend Stage Joiner")
 
AutoJoinLegendToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Legend Stage", CurrentValue = false, Flag = "AutoJoinLegendStage",
    Callback = function(Value) State.AutoJoinLegendStage = Value end,
})
 
local LegendStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage", Options = {}, CurrentOption = {}, Flag = "LegendStageSelector",
    Callback = function(Option) State.LegendStageSelected = Option[1] end,
})
 
LegendChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage Act", Options = {"Act 1","Act 2","Act 3"},
    CurrentOption = {}, MultipleOptions = false, Flag = "LegendStageActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        local num = selectedOption:match("%d+") if num then State.LegendStageActSelected = num end
    end,
})
 
LegendSlider = JoinerTab:CreateSlider({
    Name = "Select Difficulty Meter", Range = {75, 1000}, Increment = 1,
    Suffix = "", CurrentValue = 100, Flag = "LegendStageDifficultyMeterSelector",
    Callback = function(Value) State.LegendStageDifficultyMeterSelected = Value end,
})

JoinerTab:CreateInput({
    Name = "Select Difficulty Meter",
    PlaceholderText = "75 - 1000",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 75, 1000)
        LegendSlider:Set(num)
        State.LegendStageDifficultyMeterSelected = num
    end,
})
 
JoinerTab:CreateSection("Virtual Stage Joiner")
 
AutoJoinVirtualToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Virtual Stage", CurrentValue = false, Flag = "AutoJoinVirtualStage",
    Callback = function(Value) State.AutoJoinVirtualStage = Value end,
})
 
local VirtualStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Virtual Stage", Options = {}, CurrentOption = {}, Flag = "VirtualStageSelector",
    Callback = function(Options) State.VirtualStageSelected = Options[1] end,
})
 
VirtualChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Virtual Stage Act", Options = {"Act 1","Act 2","Act 3"},
    CurrentOption = {}, MultipleOptions = false, Flag = "VirtualStageActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        local num = selectedOption:match("%d+") if num then State.VirtualStageActSelected = num end
    end,
})
 
VirtualDifficultyDropdown = JoinerTab:CreateDropdown({
    Name = "Select Virtual Difficulty", Options = {"Easy","Hard","Nightmare"},
    CurrentOption = {}, MultipleOptions = false, Flag = "VirtualStageDifficultySelector",
    Callback = function(Option) State.VirtualStageDifficultySelected = Option[1] end,
})
 
VirtualSlider = JoinerTab:CreateSlider({
    Name = "Select Difficulty Meter", Range = {75, 1000}, Increment = 1,
    Suffix = "", CurrentValue = 100, Flag = "VirtualStageDifficultyMeterSelector",
    Callback = function(Value) State.VirtualStageDifficultyMeterSelected = Value end,
})

JoinerTab:CreateInput({
    Name = "Select Difficulty Meter",
    PlaceholderText = "75 - 1000",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 75, 1000)
        VirtualSlider:Set(num)
        State.VirtualStageDifficultyMeterSelected = num
    end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake", CurrentValue = false, Flag = "useMatchmakeVirtualStage",
    Callback = function(Value) State.useMatchmakeVirtualStage = Value end,
})
 
JoinerTab:CreateSection("Raid Joiner")
 
AutoJoinRaidToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Raid", CurrentValue = false, Flag = "AutoJoinRaid",
    Callback = function(Value) State.AutoJoinRaid = Value end,
})
 
local RaidStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Stage", Options = {}, CurrentOption = {}, Flag = "RaidStageSelector",
    Callback = function(Option) State.RaidStageSelected = Option[1] end,
})
 
RaidChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Act", Options = {"Act 1","Act 2","Act 3","Act 4","Act 5","Boss Rush"},
    CurrentOption = {}, MultipleOptions = false, Flag = "RaidStageActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        if selectedOption == "Boss Rush" then State.RaidActSelected = "BossRush"
        else local num = selectedOption:match("%d+") if num then State.RaidActSelected = num end end
    end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake", CurrentValue = false, Flag = "useMatchmakeRaid",
    Callback = function(Value) State.useMatchmakeRaid = Value end,
})
 
JoinerTab:CreateSection("Featured Challenge 1 Joiner")
 
AutoJoinFeaturedChallengeToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Featured Challenge (The Hunt)", CurrentValue = false, Flag = "AutoJoinFeaturedChallenge",
    Callback = function(Value) State.AutoJoinFeaturedChallenge = Value end,
})

AutoLeaveTheHuntToggle = JoinerTab:CreateToggle({
    Name = "Stop Joining after reroll limit hit (The Hunt)", CurrentValue = false, Flag = "QuitAfterRerollLimitTheHunt",
    Callback = function(Value) State.LeaveAfterRerollLimitHitTheHunt = Value end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake (The Hunt)", CurrentValue = false, Flag = "useMatchmakeTheHuntChallenge",
    Callback = function(Value) State.useMatchmakeTheHuntChallenge = Value end,
})

JoinerTab:CreateSection("Featured Challenge 2 Joiner")
 
JoinerTab:CreateToggle({
    Name = "Auto Join Featured Challenge (Olympus Judgement)", CurrentValue = false, Flag = "AutoJoinOlympusJudgement",
    Callback = function(Value) State.AutoJoinOlympusJudgement = Value end,
})

JoinerTab:CreateToggle({
    Name = "Stop Joining after reroll limit hit (Olympus Judgement)", CurrentValue = false, Flag = "QuitAfterRerollLimitOlympus",
    Callback = function(Value) State.LeaveAfterRerollLimitHitOlympus = Value end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake (Olympus Judgement)", CurrentValue = false, Flag = "useMatchmakeOlympusJudgement",
    Callback = function(Value) State.useMatchmakeOlympusJudgement = Value end,
})

JoinerTab:CreateSection("Featured Challenge 3 Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Featured Challenge (Mirror Dimension)",
    CurrentValue = false,
    Flag = "AutoJoinMirrorDimension",
    Callback = function(Value) State.AutoJoinMirrorDimension = Value end,
})

JoinerTab:CreateToggle({
    Name = "Stop Joining after reroll limit hit (Mirror Dimension)", CurrentValue = false, Flag = "QuitAfterRerollLimitMirrorDimension",
    Callback = function(Value) State.LeaveAfterRerollLimitHitMirrorDimension = Value end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake (Mirror Dimension)",
    CurrentValue = false,
    Flag = "AutoMatchmakeMirrorDimension",
    Callback = function(Value) State.AutoMatchmakeMirrorDimension = Value end,
})

JoinerTab:CreateSection("Challenge Joiner")
 
JoinerTab:CreateToggle({
    Name = "Auto Join Challenge", CurrentValue = false, Flag = "AutoJoinChallenge",
    Callback = function(Value) State.AutoJoinChallenge = Value end,
})

JoinerTab:CreateDropdown({
    Name = "Select Challenge Type",
    Options = {"Half Hour", "Daily"},
    CurrentOption = {"Half Hour"},
    MultipleOptions = false,
    Flag = "ChallengeTypeSelector",
    Callback = function(Option)
        local selected = type(Option) == "table" and Option[1] or Option
        if selected == "Daily" then
            State.SelectedChallengeType = "Daily"
        else
            State.SelectedChallengeType = "HalfHour"
        end
    end,
})
 
local IgnoreWorldsDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Worlds", Options = {}, CurrentOption = {}, MultipleOptions = true,
    Flag = "IgnoreWorldsSelector", Info = "Skip challenges based on these worlds",
    Callback = function(Options) State.IgnoreWorlds = Options or {} end,
})
 
local IgnoreModifierDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Modifier", Options = {}, CurrentOption = {}, MultipleOptions = true,
    Flag = "IgnoreModifierSelector", Info = "Skip challenges based on these modifiers",
    Callback = function(Options)
        local moduleNames = {}
        for _, displayName in ipairs(Options or {}) do
            for _, modifier in ipairs(ModifierMapping) do
                if modifier.DisplayName == displayName then
                    table.insert(moduleNames, modifier.ModuleName)
                    break
                end
            end
        end
        State.IgnoreModifier = moduleNames
    end,
})
 
SelectChallengeRewardsDropdown = JoinerTab:CreateDropdown({
    Name = "Select Challenge Rewards", Options = {"Universal Fragment", "Frozen Fragment", "Ocean Fragment", "Petal Fragment", "Sky Fragment", "Burning Fragment", "Holy Fragment", "Phantom Fragment","Gems","Stat Rerolls","Trait Rerolls", "Relic Rerolls", "Locks"},
    CurrentOption = {}, MultipleOptions = true, Flag = "SelectedChallengeRewards1",
    Info = "Only join challenges that contain one or more of these rewards",
    Callback = function(Options) State.SelectedChallengeRewards = Options or {} end,
})
 
ReturnToLobbyToggle = JoinerTab:CreateToggle({
    Name = "Return to Lobby on New Challenge", CurrentValue = false, Flag = "ReturnToLobbyOnNewChallenge",
    Info = "Return to lobby when new challenge appears instead of using retry/next",
    Callback = function(Value) State.ReturnToLobbyOnNewChallenge = Value end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake", CurrentValue = false, Flag = "useMatchmakeChallenge",
    Callback = function(Value) State.useMatchmakeChallenge = Value end,
})

JoinerTab:CreateSection("Portal Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Portal",
    CurrentValue = false,
    Flag = "AutoJoinPortal",
    Callback = function(Value) State.AutoJoinPortal = Value end,
})

local PortalDropdown = JoinerTab:CreateDropdown({
    Name = "Select Portal(s)",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PortalSelector",
    Callback = function(Options)
        State.PortalsSelected = {}
        for _, displayName in ipairs(Options) do
            local moduleName = UINameToPortalModule[displayName]
            if moduleName then table.insert(State.PortalsSelected, moduleName) end
        end
    end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake", CurrentValue = false, Flag = "useMatchmakePortal",
    Callback = function(Value) State.useMatchmakePortal = Value end,
})

function AutoJoin.usePortal()
    if not State.PortalsSelected or #State.PortalsSelected == 0 then return false end

    local craftingItems = DataController and DataController.Items and DataController.Items.CraftingItems
    if not craftingItems then return false end

    for _, moduleName in ipairs(State.PortalsSelected) do
        if craftingItems[moduleName] and craftingItems[moduleName] > 0 then
            task.spawn(function()
                pcall(function()
                    Services.ReplicatedStorage.Packages
                        ._Index["sleitnick_knit@1.7.0"]
                        .knit.Services.ItemService.RF.UseItem
                        :InvokeServer(moduleName)
                end)
            end)
            return true
        end
    end

    return false
end

function Loader.portalItems()
    local ok, result = pcall(function()
        local displayNames = {}
        for _, module in ipairs(Services.ReplicatedStorage.Shared.Data.Items:GetChildren()) do
            if module:IsA("ModuleScript") then
                local moduleOk, data = pcall(require, module)
                if moduleOk and type(data) == "table" and data.IsPortal then
                    local displayName = data.Name or module.Name
                    UINameToPortalModule[displayName] = module.Name
                    table.insert(displayNames, displayName)
                end
            end
        end
        return displayNames
    end)
    if ok and result and #result > 0 then
        PortalDropdown:Refresh(result)
    end
end
 
JoinerTab:CreateSection("Event Joiner")
 
AutoJoinShinobiToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Shinobi Alliance", CurrentValue = false, Flag = "AutoJoinShinobiAlliance",
    Callback = function(Value) State.AutoJoinShinobiAlliance = Value end,
})

AutoJoinShinobiToggle = JoinerTab:CreateToggle({
    Name = "Use Matchmake for Shinobi Alliance", CurrentValue = false, Flag = "AutoMatchmakeShinobiAlliance",
    Callback = function(Value) State.AutoMatchmakeShinobiAlliance = Value end,
})

JoinerTab:CreateToggle({
    Name = "Auto Matchmake Ant King Lair", CurrentValue = false, Flag = "AutoJoinAntKingLair",
    Callback = function(Value) State.AutoJoinAntKingLair = Value end,
})

JoinerTab:CreateToggle({
    Name = "Auto Matchmake Emperor's Kingdom",
    CurrentValue = false,
    Flag = "AutoJoinEmperorsKingdom",
    Callback = function(Value) State.AutoJoinEmperorsKingdom = Value end,
})

JoinerTab:CreateLabel("Note: If you want to return to lobby automatically on rift refresh turn on both auto retry and auto lobby in game tab")

AutoJoinTearToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Universal Tear", CurrentValue = false, Flag = "AutoJoinUniversalTear",
    Callback = function(Value) State.AutoJoinUniversalTear = Value end,
})

JoinerTab:CreateDropdown({
    Name = "Select Rift", Options = {"Sukuna", "Gojo"}, CurrentOption = {}, MultipleOptions = true,
    Flag = "TearRiftSelector",
    Callback = function(Options)
        State.SelectedRiftMaps = {}
        for _, opt in ipairs(Options) do
            if opt == "Sukuna" then table.insert(State.SelectedRiftMaps, "MegunaRift")
            elseif opt == "Gojo" then table.insert(State.SelectedRiftMaps, "GojoRift") end
        end
    end,
})

AutoMatchmakeTearToggle = JoinerTab:CreateToggle({
    Name = "Use Matchmake for Universal Tear", CurrentValue = false, Flag = "AutoMatchmakeUniversalTear",
    Callback = function(Value) State.AutoMatchmakeUniversalTear = Value end,
})
 
AutoJoinRagnarokToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Ragnarok Infinite", CurrentValue = false, Flag = "AutoJoinRagnarok",
    Callback = function(Value) State.AutoJoinRagnarok = Value end,
})

JoinerTab:CreateToggle({
    Name = "Auto Join Blitz",
    CurrentValue = false,
    Flag = "AutoJoinBlitz",
    Callback = function(Value) State.AutoJoinBlitz = Value end,
})

JoinerTab:CreateToggle({
    Name = "Use Matchmake for Blitz",
    CurrentValue = false,
    Flag = "AutoMatchmakeBlitz",
    Callback = function(Value) State.AutoMatchmakeBlitz = Value end,
})

JoinerTab:CreateDivider()

JoinerTab:CreateToggle({
        Name = "Auto Join Winter Event",
        CurrentValue = false,
        Flag = "AutoJoinWinterEvent",
        Callback = function(Value)
            State.AutoJoinWinterEvent = Value
        end,
    })

JoinerTab:CreateDropdown({
    Name = "Select Winter Event Act",
    Options = {"Act 1", "Infinite"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "WinterStageActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
            if selectedOption == "Infinite" then
                State.WinterActSelected = "Infinite"
            else
                local num = selectedOption:match("%d+")
                if num then
                    State.WinterActSelected = num
                end
            end
    end,
})

JoinerTab:CreateDropdown({
        Name = "Select Winter Stage Difficulty",
        Options = {"Easy","Hard","Nightmare"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "WinterStageDifficultySelector",
        Callback = function(Option)
            if Option[1] == "Easy" then
                State.WinterStageDifficultySelected = "Easy"
            elseif Option[1] == "Hard" then
                State.WinterStageDifficultySelected = "Hard"
            elseif Option[1] == "Nightmare" then
                State.WinterStageDifficultySelected = "Nightmare"
            end
        end,
    })

JoinerTab:CreateSlider({
   Name = "Select Difficulty Meter",
   Range = {100, 700},
   Increment = 1,
   Suffix = "",
   CurrentValue = 100,
   Flag = "WinterStageDifficultyMeterSelector",
   Callback = function(Value)
    State.WinterStageDifficultyMeterSelected = Value
   end,
})

JoinerTab:CreateInput({
    Name = "Difficulty Meter",
    PlaceholderText = "100 - 700",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 100, 700)
        Rayfield.Flags["WinterStageDifficultyMeterSelector"]:Set(num)
        State.WinterStageDifficultyMeterSelected = num
    end,
})

function Loader.buildMapLookup()
    local success, result = pcall(function()
        local WavesFolder = Services.ReplicatedStorage.Shared.Data.Waves
        if not WavesFolder then warn("Waves folder not found") return false end
        local count = 0
        for _, stageModule in ipairs(WavesFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    UINameToModuleName[stageData.Information.Name] = stageModule.Name
                    count = count + 1
                end
            end
        end
        return true
    end)
    return success and result
end

function Loader.storyStages()
    loadingRetries.story = loadingRetries.story + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.story <= maxRetries then task.wait(retryDelay) task.spawn(Loader.storyStages) end
        return
    end
    local success, result = pcall(function()
        local WavesFolder = Services.ReplicatedStorage.Shared.Data.Waves
        if not WavesFolder then error("Waves folder not found") end
        local displayNames = {}
        for _, stageModule in ipairs(WavesFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No story stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if StoryStageDropdown then StoryStageDropdown:Refresh(result) end
        if IgnoreWorldsDropdown then IgnoreWorldsDropdown:Refresh(result) end
    else
        if loadingRetries.story <= maxRetries then task.wait(retryDelay) task.spawn(Loader.storyStages) end
    end
end

-- LEGEND STAGES LOADER
function Loader.legendStages()
    loadingRetries.legend = loadingRetries.legend + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.legend <= maxRetries then task.wait(retryDelay) task.spawn(Loader.legendStages) end
        return
    end
    local success, result = pcall(function()
        local LegendFolder = Services.ReplicatedStorage.Shared.Data.LegendStages
        if not LegendFolder then error("LegendStages folder not found") end
        local displayNames = {}
        for _, stageModule in ipairs(LegendFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No legend stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if LegendStageDropdown then LegendStageDropdown:Refresh(result) end
    else
        if loadingRetries.legend <= maxRetries then task.wait(retryDelay) task.spawn(Loader.legendStages) end
    end
end

-- VIRTUAL STAGES LOADER
function Loader.virtualStages()
    loadingRetries.portal = loadingRetries.portal + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.portal <= maxRetries then task.wait(retryDelay) task.spawn(Loader.virtualStages) end
        return
    end
    local success, result = pcall(function()
        local VirtualFolder = Services.ReplicatedStorage.Shared.Data.VirtualRealm
        if not VirtualFolder then error("VirtualRealm folder not found") end
        local displayNames = {}
        for _, stageModule in ipairs(VirtualFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No virtual stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if VirtualStageDropdown then VirtualStageDropdown:Refresh(result) end
    else
        if loadingRetries.portal <= maxRetries then task.wait(retryDelay) task.spawn(Loader.virtualStages) end
    end
end

function Loader.challengeModifiers()
    loadingRetries.modifiers = (loadingRetries.modifiers or 0) + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.modifiers <= maxRetries then task.wait(retryDelay) task.spawn(Loader.challengeModifiers) end
        return
    end
    local success, result = pcall(function()
        local ChallengesFolder = Services.ReplicatedStorage.Shared.Data.Challenges
        if not ChallengesFolder then error("Challenges folder not found") end
        local challengeModifiers = {}
        local seenTags = {}
        for _, challengeModule in ipairs(ChallengesFolder:GetChildren()) do
            if challengeModule:IsA("ModuleScript") and string.find(challengeModule.Name, "HalfHour") then
                local challengeSuccess, challengeData = pcall(function() return require(challengeModule) end)
                if challengeSuccess and challengeData and challengeData.ChallengeTag then
                    if not seenTags[challengeData.ChallengeTag] then
                        table.insert(challengeModifiers, { DisplayName = challengeData.ChallengeTag, ModuleName = challengeModule.Name })
                        seenTags[challengeData.ChallengeTag] = true
                    end
                end
            end
        end
        if #challengeModifiers == 0 then error("No challenge modifiers found") end
        table.sort(challengeModifiers, function(a, b) return a.DisplayName < b.DisplayName end)
        return challengeModifiers
    end)
    if success and result and #result > 0 then
        if IgnoreModifierDropdown then
            ModifierMapping = result
            local displayNames = {}
            for _, modifier in ipairs(result) do table.insert(displayNames, modifier.DisplayName) end
            IgnoreModifierDropdown:Refresh(displayNames)
        end
    else
        if loadingRetries.modifiers <= maxRetries then task.wait(retryDelay) task.spawn(Loader.challengeModifiers) end
    end
end

function Loader.raidStages()
    loadingRetries.raid = loadingRetries.raid + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.raid <= maxRetries then task.wait(retryDelay) task.spawn(Loader.raidStages) end
        return
    end
    local success, result = pcall(function()
        local RaidFolder = Services.ReplicatedStorage.Shared.Data.Raids
        if not RaidFolder then error("Raids folder not found") end
        local displayNames = {}
        for _, raidModule in ipairs(RaidFolder:GetChildren()) do
            if raidModule:IsA("ModuleScript") then
                local raidSuccess, raidData = pcall(function() return require(raidModule) end)
                if raidSuccess and raidData and raidData.Information and raidData.Information.Name then
                    UINameToModuleName[raidData.Information.Name] = raidModule.Name
                    table.insert(displayNames, raidData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No raid stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if RaidStageDropdown then RaidStageDropdown:Refresh(result) end
    else
        if loadingRetries.raid <= maxRetries then task.wait(retryDelay) task.spawn(Loader.raidStages) end
    end
end

function MacroIO.saveWorldMappings()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local fileName = string.format("LixHub/%s_WorldMappings_UTD1.json", playerName)
    local json = game:GetService("HttpService"):JSONEncode(worldMacroMappings)
    writefile(fileName, json)
    print("✓ Saved world macro mappings")
end

function MacroIO.saveAutoPlayPositions()
    MacroIO.ensureFolders()
    local playerName = Services.Players.LocalPlayer.Name
    local fileName = string.format("LixHub/%s_AutoplayPositions_UTD.json", playerName)
    local data = {}
    for i = 1, 6 do
        if State.AutoPlayUnitPositions[i] then
            local pos = State.AutoPlayUnitPositions[i]
            data[i] = { X = pos.X, Y = pos.Y, Z = pos.Z }
        end
    end
    writefile(fileName, Services.HttpService:JSONEncode(data))
end

function MacroIO.saveAutoAbilitySettings()
    MacroIO.ensureFolders()
    writefile(string.format("LixHub/%s_AutoAbilitySettings_UTD.json", Services.Players.LocalPlayer.Name), Services.HttpService:JSONEncode(abilitySettings))
end

function MacroIO.loadWorldMappings()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local filePath = string.format("LixHub/%s_WorldMappings_UTD1.json", playerName)
    if not isfile(filePath) then return {} end
    local json = readfile(filePath)
    local data = game:GetService("HttpService"):JSONDecode(json)
    print("✓ Loaded world macro mappings")
    return data or {}
end

function MacroIO.loadAutoPlayPositions()
    MacroIO.ensureFolders()
    local playerName = Services.Players.LocalPlayer.Name
    local filePath = string.format("LixHub/%s_AutoplayPositions_UTD.json", playerName)
    if not isfile(filePath) then return end
    local ok, data = pcall(function()
        return Services.HttpService:JSONDecode(readfile(filePath))
    end)
    if not ok or not data then return end
    for i = 1, 6 do
        if data[i] then
            State.AutoPlayUnitPositions[i] = Vector3.new(data[i].X, data[i].Y, data[i].Z)
        end
    end
    print("✓ Loaded autoplay positions")
end

function MacroIO.loadAutoAbilitySettings()
    local filePath = string.format("LixHub/%s_AutoAbilitySettings_UTD.json", Services.Players.LocalPlayer.Name)
    if not isfile(filePath) then return {} end
    local ok, data = pcall(function() return Services.HttpService:JSONDecode(readfile(filePath)) end)
    if ok and data then return data end
    return {}
end

local function refreshAllWorldDropdowns()
    local macroList = {"None"}
    for name in pairs(macroManager) do
        table.insert(macroList, name)
    end
    table.sort(macroList)
    
    for worldKey, dropdown in pairs(worldDropdowns) do
        dropdown:Refresh(macroList)
    end
    
    print("✓ Refreshed all world macro dropdowns")
end

local MacroDropdown = Tab:CreateDropdown({
    Name = "Select Macro", Options = {}, CurrentOption = {}, Flag = "MacroDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        currentMacroName = name
        if name and macroManager[name] then
            macro = macroManager[name]
            Util.updateMacroStatus(string.format("Selected: %s", name))
        end
    end,
})

local function createAutoSelectDropdowns()
    local initialMacroOptions = {"None"}
    for macroName in pairs(macroManager) do table.insert(initialMacroOptions, macroName) end
    table.sort(initialMacroOptions)
    task.wait(1)

local function tryPreloadMacro(selectedMacro, worldKey)
    if not selectedMacro or selectedMacro == "None" or selectedMacro == "" then return end
    local currentWorldKey = Util.getCurrentWorldKey()
    if currentWorldKey ~= worldKey then return end
    local loadedMacro = macroManager[selectedMacro] or MacroIO.load(selectedMacro)
    if not loadedMacro or #loadedMacro == 0 then
        Util.notify({ Title = "Warning", Content = string.format("'%s' is empty, record it first", selectedMacro), Duration = 4 })
        return
    end
    macroManager[selectedMacro] = loadedMacro
    macro = loadedMacro
    currentMacroName = selectedMacro
    MacroDropdown:Set(selectedMacro)
    Util.notify({ Title = "Macro Ready", Content = string.format("%s (%d actions)", selectedMacro, #loadedMacro), Duration = 4 })
end

    Tab:CreateSection("Legend Stage Macros")
    if LegendStageDropdown and LegendStageDropdown.Options then
        for _, stageName in ipairs(LegendStageDropdown.Options) do
            local worldKey = "legend_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                    tryPreloadMacro(selectedMacro, worldKey)
                end,
            })
            worldDropdowns[worldKey] = dropdown
        end
    end

    Tab:CreateSection("Virtual Stage Macros")
    if VirtualStageDropdown and VirtualStageDropdown.Options then
        for _, stageName in ipairs(VirtualStageDropdown.Options) do
            local worldKey = "virtual_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                    tryPreloadMacro(selectedMacro, worldKey)
                end,
            })
            worldDropdowns[worldKey] = dropdown
        end
    end

    Tab:CreateSection("Raid Stage Macros")
    if RaidStageDropdown and RaidStageDropdown.Options then
        for _, stageName in ipairs(RaidStageDropdown.Options) do
            local success, raidModuleName = pcall(function()
                local RaidFolder = Services.ReplicatedStorage.Shared.Data.Raids
                for _, stageModule in ipairs(RaidFolder:GetChildren()) do
                    if stageModule:IsA("ModuleScript") then
                        local stageData = require(stageModule)
                        if stageData.Information and stageData.Information.Name == stageName then return stageModule.Name end
                    end
                end
                return nil
            end)
            if success and raidModuleName then
                local worldKey = "raid_" .. raidModuleName:lower()
                local currentMapping = worldMacroMappings[worldKey] or "None"
                local dropdown = Tab:CreateDropdown({
                    Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                    MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                    Callback = function(Option)
                        local selectedMacro = type(Option) == "table" and Option[1] or Option
                        worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                        MacroIO.saveWorldMappings()
                        tryPreloadMacro(selectedMacro, worldKey)
                    end,
                })
                worldDropdowns[worldKey] = dropdown
            end
        end
    end

    Tab:CreateSection("Story/Challenge Macros")
    if StoryStageDropdown and StoryStageDropdown.Options then
        for _, stageName in ipairs(StoryStageDropdown.Options) do
            local worldKey = "challenge_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                    tryPreloadMacro(selectedMacro, worldKey)
                end,
            })
            worldDropdowns[worldKey] = dropdown
        end
    end

    Tab:CreateSection("Featured Challenge Macro")
    do
        local featuredMaps = {
            { key = "challenge_featured", name = "Frozen Stronghold (The Hunt)" },
            { key = "olympus_judgement", name = "Olympus Judgement" },
            { key = "mirror_dimension", name = "Mirror Dimension" },
        }
        for _, featured in ipairs(featuredMaps) do
            local currentMapping = worldMacroMappings[featured.key] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = featured.name, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. featured.key,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[featured.key] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                    tryPreloadMacro(selectedMacro, featured.key)
                end,
            })
            worldDropdowns[featured.key] = dropdown
        end
    end

    Tab:CreateSection("Event Macros")
    do
        local eventMaps = {
            { key = "ragnarok", name = "Ragnarok Infinite" },
            { key = "shinobi_alliance", name = "Shinobi Alliance" },
            { key = "ant_king_lair", name = "Ant King Lair" },
            { key = "universal_tear_gojo", name = "Universal Tear (Gojo)" },
            { key = "universal_tear_sukuna", name = "Universal Tear (Sukuna)" },
            { key = "winter_event", name = "Winter Event" },
            { key = "blitz", name = "Blitz" },
            { key = "emperors_kingdom", name = "Emperor's Kingdom" },
        }
        for _, event in ipairs(eventMaps) do
            local currentMapping = worldMacroMappings[event.key] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = event.name, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. event.key,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[event.key] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                    tryPreloadMacro(selectedMacro, event.key)
                end,
            })
            worldDropdowns[event.key] = dropdown
        end
    end
end

GameSection = GameTab:CreateSection("Player")

Slider = GameTab:CreateSlider({
    Name = "Max Camera Zoom Distance", Range = {5, 100}, Increment = 1,
    Suffix = "", CurrentValue = 35, Flag = "CameraZoomDistanceSelector",
    Callback = function(Value) Services.Players.LocalPlayer.CameraMaxZoomDistance = Value end,
})
 
Toggle = GameTab:CreateToggle({
    Name = "Anti AFK (No kick message)", CurrentValue = false, Flag = "AntiAfkKickToggle",
    Info = "Prevents roblox kick message.",
    Callback = function(Value) State.AntiAfkKickEnabled = Value end,
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
                if obj.Enabled then
                    obj.Enabled = false
                    disabledByLowPerf[obj] = true
                end
            end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then if obj.Transparency < 1 then obj.Transparency = 1 end end
        end
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then gui.Enabled = false end
        end
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then obj.Enabled = false end
        end
        local RE = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting")
        RE:FireServer("LowGraphics",true) RE:FireServer("DamageNumbers",false) RE:FireServer("VFX",false) RE:FireServer("EnableAnimations",false) RE:FireServer("EnemyInfo",false)
    else
        Services.Lighting.Brightness = 1.51
        Services.Lighting.GlobalShadows = true
        Services.Lighting.Technology = Enum.Technology.Future
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 1
        Services.Lighting.EnvironmentSpecularScale = 1
        for obj, _ in pairs(disabledByLowPerf) do
            if obj and obj.Parent then
                obj.Enabled = true
            end
        end
        disabledByLowPerf = {}
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 0 end
        end
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then gui.Enabled = true end
        end
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then obj.Enabled = true end
        end
    end
end
 
Toggle = GameTab:CreateToggle({
    Name = "Low Performance Mode", CurrentValue = false, Flag = "enableLowPerformanceMode",
    Callback = function(Value) State.enableLowPerformanceMode = Value enableLowPerformanceMode() end,
})
 
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
        toggleButtonFrame.Size = UDim2.new(0, 170, 0, 44)
        toggleButtonFrame.Position = UDim2.new(0.5, -60, 1, -60)
        toggleButtonFrame.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
        toggleButtonFrame.BackgroundTransparency = 0.5
        toggleButtonFrame.Parent = screenGui
        toggleButtonFrame.ZIndex = 1000000
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1,0)
        uiCorner.Parent = toggleButtonFrame
        local title = Instance.new("TextLabel")
        title.ZIndex = math.huge title.AnchorPoint = Vector2.new(0.5,0.5)
        title.BackgroundTransparency = 1 title.Position = UDim2.new(0.5,0,0.5,0)
        title.Size = UDim2.new(1,0,1,0) title.Text = "Toggle Screen"
        title.TextSize = 15 title.TextColor3 = Color3.fromRGB(255,255,255)
        title.Parent = toggleButtonFrame
        local stroke = Instance.new("UIStroke") stroke.Parent = title
        local btn = Instance.new("TextButton")
        btn.AnchorPoint = Vector2.new(0.5,0.5) btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(1,0,1,0) btn.Position = UDim2.new(0.5,0,0.5,0)
        btn.Text = "" btn.ZIndex = math.huge btn.Parent = toggleButtonFrame
        btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
    else
        if existingGui then existingGui:Destroy() end
    end
end
 
Toggle = GameTab:CreateToggle({
    Name = "Black Screen", CurrentValue = false, Flag = "enableBlackScreen",
    Callback = function(Value) State.enableBlackScreen = Value enableBlackScreen() end,
})

GameTab:CreateToggle({
    Name = "Delete Enemies",
    CurrentValue = false,
    Flag = "DeleteEnemies",
    Callback = function(Value)
        State.DeleteEnemies = Value
    end,
})

task.spawn(function()
    task.wait(2)
    pcall(function()
        local Event = game:GetService("ReplicatedStorage").ByteNetReliable

        local deadline = tick() + 10
        while #getconnections(Event.OnClientEvent) == 0 and tick() < deadline do
            task.wait(0.1)
        end

        for _, conn in ipairs(getconnections(Event.OnClientEvent)) do
            local original = conn.Function
            conn:Disable()
            Event.OnClientEvent:Connect(newcclosure(function(buf, extra)
                if State.DeleteEnemies and extra and type(extra) == "table" then
                    for _, v in ipairs(extra) do
                        if type(v) == "table" and v.PathName then
                            return
                        end
                    end
                end
                original(buf, extra)
            end))
        end
        print("✓ Delete Enemies hook active")
    end)
end)

MiscTab:CreateSection("Claim")

Toggle = MiscTab:CreateToggle({
    Name = "Auto Claim Event Missions", CurrentValue = false, Flag = "enableAutoClaimEventMissions",
    Callback = function(Value) State.enableAutoClaimEventMissions = Value end,
})

task.spawn(function()    
    -- Hardcoded mission IDs
    local missions = {
        "dailySameElement",
        "dailyClearStageWithPlayer1",
        "weeklySameClass",
        "dailyClearStageWithPlayer0",
        "dailySameClass",
        "weeklySupportClass",
        "dailySupportClass",
        "dailyFree",
        "weeklyFree"
    }
    
    -- Get the remote
    local claimMissionRemote = game:GetService("ReplicatedStorage")
        .Packages
        ._Index["sleitnick_knit@1.7.0"]
        .knit
        .Services
        .CalendarEventService
        .RF
        .claimMission
    
    while true do
        task.wait(5)
        
        if not State.enableAutoClaimEventMissions then continue end
        
        for _, missionId in ipairs(missions) do
            local success, result = pcall(function()
                return claimMissionRemote:InvokeServer("DevilWithin",missionId)
            end)
            task.wait(0.5)
        end
    end
end)

Toggle = MiscTab:CreateToggle({
    Name = "Auto Claim Battlepass", CurrentValue = false, Flag = "enableAutoClaimBattlepass",
    Callback = function(Value) State.enableAutoClaimBattlepass = Value end,
})

task.spawn(function()
    if Util.isInLobby() then
    local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BattlepassService.RF.ClaimTiers
    local done = false

    while true do
        task.wait(10)
        if not State.enableAutoClaimBattlepass or done then continue end
        
        for tier = 1, 50 do
            local ok, result = pcall(function()
                return Event:InvokeServer({ tier })
            end)

            if not ok or result == "Error" then
                if tier == 50 then done = true end
                break
            end
            if result == "Tier not unlocked!" then break end
            task.wait(0.5)
            end
        end
    end
end)

MiscTab:CreateSection("Banner")

Toggle = MiscTab:CreateToggle({
    Name = "Auto Summon Banner", CurrentValue = false, Flag = "enableAutoSummonBanner",
    Callback = function(Value) State.enableAutoSummonBanner = Value end,
})

MiscTab:CreateDropdown({
    Name = "Select Auto Summon Banner",
    Options = {"Special Banner", "Selection Banner", "Universal Festival"},
    CurrentOption = {}, MultipleOptions = false, Flag = "SelectAutoSummonBanner",
    Callback = function(Options)
        local selected = type(Options) == "table" and Options[1] or Options
        if selected == "Special Banner" then
            State.SelectedSummonType = "TenSummon"
            State.SelectedBannerId = "Special"
        elseif selected == "Selection Banner" then
            State.SelectedSummonType = "TenSummon"
            State.SelectedBannerId = "Selection"
        elseif selected == "Universal Festival" then
            State.SelectedSummonType = "TenSummon"
            State.SelectedBannerId = "Universal"
        end
    end,
})

task.spawn(function()
    if Util.isInLobby() then
    local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BannerService.RF.BuyBanner

    while true do
        task.wait(0.5)
        if not State.enableAutoSummonBanner then continue end
        if not State.SelectedSummonType or not State.SelectedBannerId then continue end

        local success, result = pcall(function()
            return Event:InvokeServer(State.SelectedSummonType, State.SelectedBannerId)
        end)

        if not success or result == "Not enough gems!" then
            State.enableAutoSummonBanner = false
            Util.notify({ Title = "Auto Summon", Content = result or "Error — stopping", Duration = 4 })
        end

        task.wait(0.5)
        end
    end
end)

MiscTab:CreateSection("Capsules")

MiscTab:CreateToggle({
    Name = "Auto Buy Capsules", CurrentValue = false, Flag = "enableAutoBuyCapsules",
    Callback = function(Value) State.enableAutoBuyCapsules = Value end,
})

MiscTab:CreateDropdown({
    Name = "Select Capsule(s) To Buy",
    Options = {"Devil Capsule", "Winter Capsule", "New Years Capsule"},
    CurrentOption = {}, MultipleOptions = true, Flag = "SelectAutoBuyCapsules",
    Callback = function(Options)
        State.SelectedCapsulesToBuy = {}
        for _, name in ipairs(Options) do
            if name == "Devil Capsule" then
                table.insert(State.SelectedCapsulesToBuy, { service = "CalendarEventService", method = "purchaseOffer", args = { "DevilWithin", "DMCCapsule", 10 } })
            elseif name == "Winter Capsule" then
                table.insert(State.SelectedCapsulesToBuy, { service = "WinterShopService", method = "BuyItem", args = { "WinterCapsule", 50 } })
            elseif name == "New Years Capsule" then
                table.insert(State.SelectedCapsulesToBuy, { service = "WinterShopService", method = "BuyItem", args = { "NewYearsCapsule", 50 } })
            end
        end
    end,
})

task.spawn(function()
    local base = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services

    while true do
        task.wait(0.1)
        if not State.enableAutoBuyCapsules then continue end
        if not State.SelectedCapsulesToBuy or #State.SelectedCapsulesToBuy == 0 then continue end

        for _, capsule in ipairs(State.SelectedCapsulesToBuy) do
            local ok, result = pcall(function()
                return base[capsule.service].RF[capsule.method]:InvokeServer(table.unpack(capsule.args))
            end)
            if not ok or result == "Error" or result == "Not enough currency!" then
                State.enableAutoBuyCapsules = false
                Util.notify({ Title = "Auto Buy Capsules", Content = result or "Error — stopping", Duration = 4 })
                break
            end
            task.wait(0.1)
        end
    end
end)

Toggle = MiscTab:CreateToggle({
    Name = "Auto Open Capsules", CurrentValue = false, Flag = "enableAutoOpenCapsules",
    Callback = function(Value) State.enableAutoOpenCapsules = Value end,
})

local CapsuleDropdown = MiscTab:CreateDropdown({
    Name = "Select Capsule(s) To Open",
    Options = {},
    CurrentOption = {}, MultipleOptions = true, Flag = "SelectAutoOpenCapsules",
    Callback = function(Options)
        State.SelectedCapsuleIds = {}
        for _, displayName in ipairs(Options) do
            if State.CapsuleNameToId[displayName] then
                table.insert(State.SelectedCapsuleIds, State.CapsuleNameToId[displayName])
            end
        end
    end,
})

task.spawn(function()
    task.wait(2)
    State.CapsuleNameToId = {}
    local displayNames = {}
    for _, module in ipairs(game:GetService("ReplicatedStorage").Shared.Data.Items:GetChildren()) do
        if module:IsA("ModuleScript") and module.Name:find("Capsule") then
            local ok, data = pcall(require, module)
            if ok and data.IsCapsule and data.CapsuleId and data.Name then
                State.CapsuleNameToId[data.Name] = data.CapsuleId
                table.insert(displayNames, data.Name)
            end
        end
    end
    table.sort(displayNames)
    CapsuleDropdown:Refresh(displayNames)
end)

task.spawn(function()
    if Util.isInLobby() then
    local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.ItemService.RF.UseItemBulk

    while true do
        task.wait(1)
        if not State.enableAutoOpenCapsules then continue end
        if not State.SelectedCapsuleIds or #State.SelectedCapsuleIds == 0 then continue end

        for _, capsuleId in ipairs(State.SelectedCapsuleIds) do
            local amount = DataController and DataController.Items and DataController.Items.CraftingItems and DataController.Items.CraftingItems[capsuleId] or 0
            if amount <= 0 then continue end

            while amount > 0 do
                local batch = math.min(amount, 250)
                local ok, result = pcall(function()
                    return Event:InvokeServer(capsuleId, batch)
                end)
                if not ok or result == "Error" or result == "You don't have enough of this item!" then break end
                amount = amount - batch
                task.wait(0.5)
                end
            end
        end
    end
end)

MiscTab:CreateSection("Misc")

Button = MiscTab:CreateButton({
    Name = "Return to lobby",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
    end,
})

Toggle = MiscTab:CreateToggle({
    Name = "Disable Script Notifications", CurrentValue = false, Flag = "disableScriptNotifications",
    Callback = function(Value) State.disableScriptNotifications = Value end,
})

Toggle = MiscTab:CreateToggle({
    Name = "Auto Execute Script", CurrentValue = false, Flag = "enableAutoExecute",
    Info = "This auto executes and persists through teleports until you disable it or leave the game.",
    Callback = function(Value)
        State.enableAutoExecute = Value
        if not queue_on_teleport then
            warn("queue_on_teleport not supported by this executor")
            return
        end
        updateQueueOnTeleport() -- handles both runs + auto execute together
    end,
})

local function updateFPSLimit()
    if State.enableLimitFPS and State.SelectedFPS > 0 then
        setfpscap(tonumber(State.SelectedFPS))
    else
        setfpscap(0)
    end
end

Toggle = GameTab:CreateToggle({
    Name = "Limit FPS", CurrentValue = false, Flag = "enableLimitFPS",
    Callback = function(Value) State.enableLimitFPS = Value updateFPSLimit() end,
})
 
Slider = GameTab:CreateSlider({
    Name = "Limit FPS To", Range = {0, 240}, Increment = 1, Suffix = " FPS",
    CurrentValue = 60, Flag = "FPSSelector",
    Callback = function(Value) State.SelectedFPS = Value updateFPSLimit() end,
})

 GameTab:CreateToggle({
    Name = "Streamer Mode (hide name/level/title)", CurrentValue = false, Flag = "StreamerMode",
    Callback = function(Value) State.streamerModeEnabled = Value end,
})

local function StreamerMode()
    local head = Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local billboard = head:WaitForChild("BillboardGui")
    if not billboard then return end
    local originalNumbers
    local streamerLabel
    if not Util.isInLobby() then
        originalNumbers = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameUI"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("Level")
        streamerLabel = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameUI"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("streamerlabel")
    else
        originalNumbers = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("Level")
        streamerLabel = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("streamerlabel")
    end
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "streamerlabel"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = originalNumbers.Parent
    end
    local playerLevel = "1"
    pcall(function()
        local levelText = originalNumbers.Text
        local levelMatch = levelText:match("Level (%d+)")
        if levelMatch then playerLevel = levelMatch end
    end)
    local playerTitle = ""
    if State.streamerModeEnabled then
        billboard:FindFirstChild("PlayerName").Text = "🔥 PROTECTED BY LIXHUB 🔥"
        billboard:FindFirstChild("PlayerName"):FindFirstChild("PlayerName").Text = "🔥 PROTECTED BY LIXHUB 🔥"
        billboard:FindFirstChild("Title").Text = "LIXHUB USER"
        billboard:FindFirstChild("LevelAmount").Text = "Lv. 999"
        billboard:FindFirstChild("Title"):FindFirstChild("Title").Text = "LIXHUB USER"
        billboard:FindFirstChild("LevelAmount"):FindFirstChild("TextLabel").Text = "Lv. 999"
        originalNumbers.Visible = false
        streamerLabel.Visible = true
    else
        billboard:FindFirstChild("PlayerName").Text = Services.Players.LocalPlayer.Name
        billboard:FindFirstChild("PlayerName"):FindFirstChild("PlayerName").Text = Services.Players.LocalPlayer.Name
        billboard:FindFirstChild("Title").Text = playerTitle
        billboard:FindFirstChild("LevelAmount").Text = "Lv. " .. playerLevel
        billboard:FindFirstChild("Title"):FindFirstChild("Title").Text = playerTitle
        billboard:FindFirstChild("LevelAmount"):FindFirstChild("TextLabel").Text = "Lv. " .. playerLevel
        originalNumbers.Visible = true
        streamerLabel.Visible = false
    end
end

task.spawn(function()
    local lastStreamerState = nil

    local function applyStreamerMode()
        local head = Services.Players.LocalPlayer.Character
            and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not head then return end
        local billboard = head:FindFirstChild("BillboardGui")
        if not billboard then return end

        -- Only update UI if state actually changed
        if State.streamerModeEnabled == lastStreamerState then return end
        lastStreamerState = State.streamerModeEnabled

        -- rest of StreamerMode logic unchanged
        StreamerMode()
    end

    -- Run on character spawn
    Services.Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        lastStreamerState = nil -- force refresh on respawn
        applyStreamerMode()
    end)

    -- Run when toggle changes (driven by the toggle callback, not a loop)
    while true do
        task.wait(1) -- 1s is plenty, names don't change mid-game
        applyStreamerMode()
    end
end)

if State.enableLowPerformanceMode then enableLowPerformanceMode() end

GameSection = GameTab:CreateSection("Game")

AutoStartToggle = GameTab:CreateToggle({
    Name = "Auto Start Game", CurrentValue = false, Flag = "AutoStartGame",
    Callback = function(Value)
        State.AutoStartGame = Value
        if Value then
            pcall(function()
                game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.DataService.RE.SetSetting:FireServer("AutoStart", false)
            end)
        end
    end,
})

AutoRetryToggle = GameTab:CreateToggle({
    Name = "Auto Retry", CurrentValue = false, Flag = "AutoRetry",
    Callback = function(Value) State.AutoRetry = Value end,
})
AutoNextToggle = GameTab:CreateToggle({
    Name = "Auto Next", CurrentValue = false, Flag = "AutoNext",
    Callback = function(Value) State.AutoNext = Value end,
})
AutoLobbyToggle = GameTab:CreateToggle({
    Name = "Auto Lobby", CurrentValue = false, Flag = "AutoLobby",
    Callback = function(Value) State.AutoLobby = Value end,
})

Slider = GameTab:CreateSlider({
    Name = "Return to lobby after x losses", Range = {0, 50}, Increment = 1, Suffix = "losses",
    CurrentValue = 0, Flag = "ReturnToLobbyAfterLosses", Info = "0 = disable",
    Callback = function(Value)
        State.ReturnToLobbyAfterLosses = Value
    end,
})

GameTab:CreateInput({
    Name = "Return to lobby after x losses",
    PlaceholderText = "0 - 50",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 50)
        Rayfield.Flags["ReturnToLobbyAfterLosses"]:Set(num)
        State.ReturnToLobbyAfterLosses = num
    end,
})

Slider = GameTab:CreateSlider({
    Name = "Return to lobby after x matches", Range = {0, 250}, Increment = 1, Suffix = "matches",
    CurrentValue = 0, Flag = "ReturnToLobbyAfterMatches", Info = "0 = disable",
    Callback = function(Value)
        State.ReturnToLobbyAfterMatches = Value
    end,
})

GameTab:CreateInput({
    Name = "Return to lobby after x matches",
    PlaceholderText = "0 - 250",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 250)
        Rayfield.Flags["ReturnToLobbyAfterMatches"]:Set(num)
        State.ReturnToLobbyAfterMatches = num
    end,
})
 
local function enableModdedPlacement()
    if moddedPlacementEnabled then return end
    if Util.isInLobby() then return end
    local success = pcall(function()
        local TowerController = require(game:GetService("ReplicatedStorage").Client.Controllers.TowerController)
        local functionsToHook = {"StartPlace","EndPlace","CanPlace","ValidatePlacement","CheckPlacement","IsValidPlacement"}
        for _, funcName in ipairs(functionsToHook) do
            if TowerController[funcName] and type(TowerController[funcName]) == "function" then
                local original = TowerController[funcName]
                TowerController[funcName] = function(...)
                    local results = {original(...)}
                    if results[1] == false or results[1] == nil then return true end
                    return unpack(results)
                end
            end
        end
        moddedPlacementEnabled = true
    end)
    return success
end
 
local function disableModdedPlacement()
    moddedPlacementEnabled = false
    Util.notify({ Title = "Success", Content = "Rejoin to disable", Duration = 4 })
end
 
Toggle = GameTab:CreateToggle({
    Name = "Place Anywhere", CurrentValue = false, Flag = "PlaceAnywhere",
    Info = "Place units anywhere",
    Callback = function(Value)
        if Value then
            local success = enableModdedPlacement()
            if success then Util.notify({ Title = "Success", Content = "Enabled! Place anywhere", Duration = 3 })
            else Util.notify({ Title = "Error", Content = "Failed to enable", Duration = 3 }) end
        else disableModdedPlacement() end
    end,
})
 
AutoGameSpeedToggle = GameTab:CreateToggle({
    Name = "Auto Game Speed", CurrentValue = false, Flag = "AutoGameSpeed",
    Callback = function(Value) State.AutoGameSpeed = Value end,
})
 
local Dropdown = GameTab:CreateDropdown({
    Name = "Select Game Speed", Options = {"1","1.5"}, CurrentOption = {}, MultipleOptions = false, Flag = "SelectGameSpeed",
    Callback = function(Options)
        local selected = type(Options) == "table" and Options[1] or Options
        State.SelectedGameSpeed = tonumber(selected)
    end,
})
 
task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoGameSpeed and State.SelectedGameSpeed then
            local currentSpeed = Services.Workspace:GetAttribute("Speed")
            if currentSpeed and currentSpeed ~= State.SelectedGameSpeed then
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RE"):WaitForChild("SetSpeed"):FireServer(State.SelectedGameSpeed)
            end
        end
    end
end)
 
Toggle = GameTab:CreateToggle({
    Name = "Auto Skip Waves", CurrentValue = false, Flag = "AutoSkipWaves",
    Callback = function(Value) State.AutoSkipWaves = Value end,
})
 
Slider = GameTab:CreateSlider({
    Name = "Auto Skip Until Wave", Range = {0, 300}, Increment = 1, Suffix = "wave",
    CurrentValue = 0, Flag = "Slider1", Info = "0 = disable",
    Callback = function(Value)
        State.AutoSkipUntilWave = Value
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("AutoSkip",Value)
    end,
})

GameTab:CreateInput({
    Name = "Auto Skip Until Wave",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["Slider1"]:Set(num)
        State.AutoSkipUntilWave = num
    end,
})
 
task.spawn(function()
    local lastAutoSkipState = nil
    while true do
        task.wait(1)
        if State.AutoSkipWaves then
            local waveNum = Services.Workspace:GetAttribute("Wave") or 0
            local skipLimit = State.AutoSkipUntilWave
            local shouldAutoSkip = (skipLimit == 0) or (waveNum > 0 and waveNum <= skipLimit)
            if shouldAutoSkip ~= lastAutoSkipState then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("AutoSkip", shouldAutoSkip)
                end)
                lastAutoSkipState = shouldAutoSkip
            end
        else
            lastAutoSkipState = nil
        end
    end
end)
 
Toggle = GameTab:CreateToggle({
    Name = "Auto Restart Match", CurrentValue = false, Flag = "AutoRestartMatch",
    Callback = function(Value) State.AutoRestartMatch = Value end,
})
Slider = GameTab:CreateSlider({
    Name = "Restart Match on Wave", Range = {0, 300}, Increment = 1, Suffix = "wave",
    CurrentValue = 0, Flag = "AutoRestartMatchWave", Info = "0 = disable",
    Callback = function(Value) State.AutoRestartMatchWave = Value end,
})

GameTab:CreateInput({
    Name = "Restart Match on Wave",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoRestartMatchWave"]:Set(num)
        State.AutoRestartMatchWave = num
    end,
})
 
task.spawn(function()
    local hasRestarted = false
    while true do
        task.wait(1)
        if State.AutoRestartMatch and State.AutoRestartMatchWave > 0 then
            local currentWave = Services.Workspace:GetAttribute("Wave") or 0
            local matchFinished = Services.Workspace:GetAttribute("MatchFinished")
            if currentWave >= State.AutoRestartMatchWave and not matchFinished and not hasRestarted then
                local success = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RE"):WaitForChild("MidMatchVote"):FireServer()
                end)
                if success then
                    hasRestarted = true
                    Util.notify({ Title = "Auto Restart", Content = string.format("Restarted at wave %d", currentWave), Duration = 3 })
                end
            end
            if currentWave == 1 then hasRestarted = false end
        end
    end
end)
 
Toggle = GameTab:CreateToggle({
    Name = "Auto Sell All Units", CurrentValue = false, Flag = "AutoSellAllUnits",
    Callback = function(Value) State.AutoSellAllUnits = Value end,
})
Slider = GameTab:CreateSlider({
    Name = "Sell All Units on Wave", Range = {0, 300}, Increment = 1, Suffix = "wave",
    CurrentValue = 0, Flag = "AutoSellAllUnitsWave", Info = "0 = disable",
    Callback = function(Value) State.AutoSellAllUnitsWave = Value end,
})

GameTab:CreateInput({
    Name = "Sell All Units on Wave",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoSellAllUnitsWave"]:Set(num)
        State.AutoSellAllUnitsWave = num
    end,
})
 
task.spawn(function()
    local hasSold = false
    while true do
        task.wait(1)
        if State.AutoSellAllUnits and State.AutoSellAllUnitsWave > 0 then
            local currentWave = Services.Workspace:GetAttribute("Wave") or 0
            local matchFinished = Services.Workspace:GetAttribute("MatchFinished")
            if currentWave >= State.AutoSellAllUnitsWave and not matchFinished and not hasSold then
                local success = pcall(function()
                    local button = Services.Players.LocalPlayer.PlayerGui.GameUI.HUD.RightFrame.Manager.Actions.SellAllButton.TextButton
                    for _, conn in pairs(getconnections(button.MouseButton1Down)) do
                        if conn.Enabled then conn:Fire() end
                    end
                end)
                if success then
                    hasSold = true
                    Util.notify({ Title = "Auto Sell", Content = string.format("Sold all units at wave %d", currentWave), Duration = 3 })
                end
            end
            if currentWave == 1 then hasSold = false end
        end
    end
end)

GameTab:CreateDivider()

GameTab:CreateToggle({
    Name = "Auto Gaara Zone (Shinobi Alliance)",
    CurrentValue = false,
    Flag = "AutoGaaraZone",
    Callback = function(Value)
        State.ShinobiAutoGaaraZone = Value
    end,
})

-- Auto Open Coffin
GameTab:CreateToggle({
    Name = "Auto Open Coffin (Shinobi Alliance)",
    CurrentValue = false,
    Flag = "AutoOpenCoffin",
    Callback = function(Value)
        State.ShinobiAutoOpenCoffin = Value
    end,
})

GameTab:CreateToggle({
    Name = "Auto Kurama Hands",
    CurrentValue = false,
    Flag = "AutoKuramaHands",
    Callback = function(Value)
        State.AutoKuramaHands = Value
    end,
})

GameTab:CreateToggle({
    Name = "Auto Collect Rift Orbs (Universal Tear)",
    CurrentValue = false,
    Flag = "AutoCollectRiftOrbs",
    Callback = function(Value)
        State.AutoCollectRiftOrbs = Value
    end,
})

GameTab:CreateToggle({
    Name = "Auto Collect Presents",
    CurrentValue = false,
    Flag = "AutoCollectPresents",
    Callback = function(Value)
        State.AutoCollectPresents = Value
    end,
})

GameTab:CreateToggle({
    Name = "Auto Free Trapped Units",
    CurrentValue = false,
    Flag = "AutoFreeMochiUnits",
    Callback = function(Value)
        State.AutoFreeMochiUnits = Value
    end,
})

task.spawn(function()
    local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function tweenTo(hrp, targetCFrame)
        local tween = Services.TweenService:Create(hrp, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
        tween.Completed:Wait()
    end

    local function tryFreeShell(shell)
        if not shell or not shell.Parent then return end
        local prompt = shell:FindFirstChild("FreeMochiUnitPrompt")
        if not prompt then return end
        local character = Services.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local shellPart = shell:IsA("BasePart") and shell or shell:FindFirstChildWhichIsA("BasePart")
        if not shellPart then return end

        tweenTo(hrp, shellPart.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)

        -- Retry until shell is gone or prompt disappears
        for attempt = 1, 8 do
            if not shell.Parent or not prompt.Parent then break end
            pcall(fireproximityprompt, prompt)
            task.wait(0.4)
            if not shell.Parent then break end -- freed successfully
        end
    end

    local processing = {} -- track shells already being handled
    local connection = nil

    while true do
        task.wait(0.3) -- tighter poll
        local effects = workspace:FindFirstChild("Ignore") and workspace.Ignore:FindFirstChild("Effects")
        if not effects then continue end

        if State.AutoFreeMochiUnits and not connection then
            connection = effects.ChildAdded:Connect(function(child)
                if not State.AutoFreeMochiUnits then return end
                if child.Name == "KatakuriMochiShell" and not processing[child] then
                    processing[child] = true
                    task.spawn(function()
                        tryFreeShell(child)
                        processing[child] = nil
                    end)
                end
            end)
        elseif not State.AutoFreeMochiUnits and connection then
            connection:Disconnect()
            connection = nil
            processing = {}
        end

        -- Continuous scan to catch any missed shells
        if State.AutoFreeMochiUnits then
            for _, child in pairs(effects:GetChildren()) do
                if child.Name == "KatakuriMochiShell" and not processing[child] then
                    processing[child] = true
                    task.spawn(function()
                        tryFreeShell(child)
                        processing[child] = nil
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- create once
    local isCollecting = false

    local function tweenTo(hrp, targetCFrame)
        local tween = Services.TweenService:Create(hrp, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
        tween.Completed:Wait()
    end

    local function collectPresents(dropsFolder)
        if isCollecting then return end
        isCollecting = true
        pcall(function()
            local hrp = Services.Players.LocalPlayer.Character
                and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local originalCFrame = hrp.CFrame
            for _, child in pairs(dropsFolder:GetChildren()) do
                if not State.AutoCollectPresents then break end
                if child.Name == "Present" and child:IsA("Model") and child.Parent then
                    tweenTo(hrp, CFrame.new(child:GetPivot().Position))
                    task.wait(0.1)
                end
            end
            if hrp and hrp.Parent then tweenTo(hrp, originalCFrame) end
        end)
        isCollecting = false
    end

    local connection = nil

    -- Watch toggle state instead of polling
    while true do
        task.wait(0.5)
        local ignore = workspace:FindFirstChild("Ignore")
        local drops = ignore and ignore:FindFirstChild("Drops")
        if not drops then continue end

        if State.AutoCollectPresents and not connection then
            -- Initial scan for existing presents
            task.spawn(collectPresents, drops)
            -- Watch for new presents via event instead of polling
            connection = drops.ChildAdded:Connect(function(child)
                if not State.AutoCollectPresents then return end
                if child.Name == "Present" and child:IsA("Model") then
                    task.wait(0.2)
                    task.spawn(collectPresents, drops)
                end
            end)
        elseif not State.AutoCollectPresents and connection then
            connection:Disconnect()
            connection = nil
        end
    end
end)

task.spawn(function()
    local function collectOrb(orb)
        local prompt = orb:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then return end
        local hrp = Services.Players.LocalPlayer.Character
            and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = orb.CFrame * CFrame.new(0, 0, -3)
        task.wait(0.15)
        if prompt and prompt.Parent then
            pcall(fireproximityprompt, prompt)
        end
    end

    local function isRiftOrb(name)
        return name:find("GojoEssencePrompt_Static", 1, true)
            or name:find("MegunaFugaPrompt_Static", 1, true)
    end

    -- Use a targeted folder instead of all of workspace
    local function watchFolder(folder)
        if not folder then return end
        -- Catch existing orbs
        for _, v in folder:GetDescendants() do
            if isRiftOrb(v.Name) then task.spawn(collectOrb, v) end
        end
        -- Watch for new ones
        folder.DescendantAdded:Connect(function(v)
            if not State.AutoCollectRiftOrbs then return end
            if isRiftOrb(v.Name) then
                task.wait(0.5)
                task.spawn(collectOrb, v)
            end
        end)
    end

    -- Wait for the Effects folder specifically, not all of workspace
    local ignore = workspace:WaitForChild("Ignore", 30)
    if ignore then
        local effects = ignore:WaitForChild("Effects", 30)
        watchFolder(effects)
    end
end)

task.spawn(function()
    local handLocations = {"1", "2", "3"}
    local lastFiredPrompt = nil
    local lastFiredTime = 0
    local cooldown = 3

    while true do
        task.wait(0.5)
        if not State.AutoKuramaHands then continue end

        local mapFolder = workspace:FindFirstChild("Map")
        if not mapFolder then continue end

        local handsFolder = mapFolder:FindFirstChild("Hands")
        if not handsFolder then continue end

        local locationsFolder = handsFolder:FindFirstChild("Locations")
        if not locationsFolder then continue end

        for _, locationIndex in ipairs(handLocations) do
            local locationPart = locationsFolder:FindFirstChild(locationIndex)
            if not locationPart then continue end

            -- Find ProximityPrompt inside the location
            local prompt = nil
            for _, child in ipairs(locationPart:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    prompt = child
                    break
                end
            end

            if not prompt then continue end
            if prompt == lastFiredPrompt and tick() - lastFiredTime < cooldown then continue end

            -- Teleport to the corresponding Hand part
            local handPart = handsFolder:FindFirstChild("Hand" .. locationIndex)
            if not handPart then continue end

            local character = Services.Players.LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local targetPart = handPart:IsA("BasePart") and handPart
                or handPart:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end

            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 50, 0)
            task.wait(0.3)

            -- Re-check prompt still valid after teleport
            if not prompt or not prompt.Parent then continue end

            local success = pcall(function()
                fireproximityprompt(prompt)
            end)

            if success then
                lastFiredPrompt = prompt
                lastFiredTime = tick()
                break -- Only fire one per cycle
            end
        end
    end
end)

local hasTeleported = false

task.spawn(function()
    while true do
        task.wait(1)
        if not State.ShinobiAutoGaaraZone then continue end

        local runtime = workspace:FindFirstChild("ShinobiAllianceRuntime")
        if not runtime then continue end

        local greenZone = runtime:FindFirstChild("GreenZone")

        -- Reset when zone disappears
        if not greenZone then
            hasTeleported = false
            continue
        end

        if hasTeleported then continue end

        local character = Services.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local zonePart = greenZone:IsA("BasePart") and greenZone
            or greenZone:FindFirstChildWhichIsA("BasePart")
        if not zonePart then continue end

        hrp.CFrame = zonePart.CFrame + Vector3.new(0, 5, 0)

        hasTeleported = true
    end
end)

-- Coffin loop
task.spawn(function()
    local lastTriedCoffin = nil
    local lastAttemptTime = 0

    while true do
        task.wait(1)
        if not State.ShinobiAutoOpenCoffin then
            lastTriedCoffin = nil
            continue
        end

        local runtime = workspace:FindFirstChild("ShinobiAllianceRuntime")
        if not runtime then continue end

        -- Find any coffin anchor
        local coffinAnchor = nil
        for _, child in ipairs(runtime:GetChildren()) do
            if child.Name:find("CoffinAnchor") then
                coffinAnchor = child
                break
            end
        end
        if not coffinAnchor then
            lastTriedCoffin = nil
            continue
        end

        -- Cooldown so we don't spam the same coffin
        if coffinAnchor == lastTriedCoffin and tick() - lastAttemptTime < 3 then
            continue
        end

        -- Find ProximityPrompt inside CoffinAttachment
        local prompt = nil
        local attachment = coffinAnchor:FindFirstChildWhichIsA("Attachment")
        if attachment then
            prompt = attachment:FindFirstChildOfClass("ProximityPrompt")
        end
        if not prompt then continue end

        -- Extract price from ObjectText e.g. "White Coffin (5000 Yen)"
        local objectText = prompt.ObjectText or ""
        local priceStr = objectText:match("%((%d+)%s*[Yy]en%)")
        local price = priceStr and tonumber(priceStr) or 0

        -- Teleport to coffin
        local character = Services.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local anchorPart = coffinAnchor:IsA("BasePart") and coffinAnchor
            or coffinAnchor:FindFirstChildWhichIsA("BasePart")
        if not anchorPart then continue end

        hrp.CFrame = anchorPart.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.3)

        -- Wait for enough money then fire
        if price > 0 then
            local money = Util.getPlayerMoney()
            if money and money < price then
                Util.updateDetailedStatus(string.format("Waiting ¥%d for coffin (%s)", price, coffinAnchor.Name))
                local canContinue = Playback.waitForMoney(price, coffinAnchor.Name)
                if not canContinue then continue end
            end
        end

        -- Re-check prompt still exists after waiting
        if not prompt or not prompt.Parent then
            lastTriedCoffin = nil
            continue
        end

        -- Fire the proximity prompt
        local fireSuccess = pcall(function()
            fireproximityprompt(prompt)
        end)

        if fireSuccess then
            Util.notify({
                Title = "Coffin Opened",
                Content = string.format("%s (¥%d)", coffinAnchor.Name, price),
                Duration = 3,
            })
            lastTriedCoffin = coffinAnchor
            lastAttemptTime = tick()
        end
    end
end)

local function getRequiredUnitsFromMacro(macroData)
    local seen = {}
    local ordered = {}
    for _, action in ipairs(macroData) do
        if action.Type == "spawn_unit" and action.Unit then
            local unitName = Util.cleanUnitName(action.Unit:match("^(.+) #%d+$") or action.Unit)
            if not seen[unitName] then
                seen[unitName] = true
                table.insert(ordered, unitName)
            end
        end
    end
    return ordered
end

local function findBestGuidForUnit(unitName, inventory)
    local cleanName = Util.cleanUnitName(unitName)
    local candidates = {}
    for guid, data in pairs(inventory) do
        if data.UnitId and Util.cleanUnitName(data.UnitId) == cleanName then
            table.insert(candidates, {
                guid = guid,
                locked = data.Locked or false,
                experience = data.Experience or 0,
            })
        end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b)
        if a.locked ~= b.locked then return a.locked end
        return a.experience > b.experience
    end)
    return candidates[1].guid
end

local function autoEquipMacroUnits()
    if Util.isInLobby() then return end
    if autoEquipRunning then return false end
    autoEquipRunning = true
    if not macro or #macro == 0 then
        Util.notify({ Title = "Auto Equip", Content = "No macro loaded", Duration = 3 })
        autoEquipRunning = false
        return false
    end

    local requiredUnits = getRequiredUnitsFromMacro(macro)
    if #requiredUnits == 0 then
        Util.notify({ Title = "Auto Equip", Content = "No units found in macro", Duration = 3 })
        autoEquipRunning = false
        return false
    end

    if #requiredUnits > 6 then
        Util.notify({ Title = "Auto Equip", Content = "Macro has more than 6 unique units", Duration = 3 })
        autoEquipRunning = false
        return false
    end

    -- Get inventory
    local ok, data = pcall(function()
        local dc = DataController or Knit.GetController("DataController")
        return dc:RequestData()
    end)
    if not ok or not data or not data.Units or not data.Units.Inventory then
        Util.notify({ Title = "Auto Equip", Content = "Failed to read inventory", Duration = 3 })
        autoEquipRunning = false
        return false
    end

    local inventory = data.Units.Inventory

    -- Find best GUID for each unit, abort if any missing
    local unitGUIDs = {}
    local missingUnits = {}
    for _, unitName in ipairs(requiredUnits) do
        local guid = findBestGuidForUnit(unitName, inventory)
        if guid then
            unitGUIDs[unitName] = guid
        else
            table.insert(missingUnits, unitName)
        end
    end

    if #missingUnits > 0 then
        Util.notify({
            Title = "Auto Equip Failed",
            Content = "Missing units: " .. table.concat(missingUnits, ", "),
            Duration = 6,
        })
        autoEquipRunning = false
        return false
    end

    -- Check if already equipped correctly
    local currentEquipped = {}
    pcall(function()
        local equipped = Services.HttpService:JSONDecode(
            Services.Players.LocalPlayer:WaitForChild("Equipped").Value
        )
        for _, guid in ipairs(equipped) do
            if guid and guid ~= "" then
                currentEquipped[guid] = true
            end
        end
    end)

    local alreadyCorrect = true
    for _, guid in pairs(unitGUIDs) do
        if not currentEquipped[guid] then
            alreadyCorrect = false
            break
        end
    end

    if alreadyCorrect then
        Util.notify({ Title = "Auto Equip", Content = "Already equipped correctly", Duration = 3 })
        autoEquipRunning = false
        return true
    end

    -- Unequip all
    local DataServiceRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.DataService.RE
    local DataServiceRF = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.DataService.RF

    local unequipOk = pcall(function()
        DataServiceRE.UnequipAll:FireServer()
    end)
    if not unequipOk then
        Util.notify({ Title = "Auto Equip", Content = "Failed to unequip units", Duration = 3 })
        autoEquipRunning = false
        return false
    end

    task.wait(0.5)

    -- Equip each unit in order
    local failedEquips = {}
    for _, unitName in ipairs(requiredUnits) do
        local guid = unitGUIDs[unitName]
        local equipOk, result = pcall(function()
            return DataServiceRF.ToggleEquip:InvokeServer(guid, nil)
        end)
        if not equipOk or result == false then
            table.insert(failedEquips, unitName)
        end
        task.wait(0.3)
    end

    if #failedEquips > 0 then
        Util.notify({
            Title = "Auto Equip Partial",
            Content = "Failed to equip: " .. table.concat(failedEquips, ", "),
            Duration = 5,
        })
        autoEquipRunning = false
        return false
    end

    Util.notify({
        Title = "Auto Equip Done",
        Content = string.format("Equipped %d units for %s", #requiredUnits, currentMacroName),
        Duration = 4,
    })
    autoEquipRunning = false
    return true
end

function Playback.checkAndSwitchMacroForCurrentWorld()
    if not isPlaybackEnabled then return false end
    local category = workspace:GetAttribute("Category")
    local mapName = workspace:GetAttribute("MapName")
    if not category or not mapName then return false end
    local deadline = tick() + 10
    while (not workspace:GetAttribute("Category") or not workspace:GetAttribute("MapName")) and tick() < deadline do
        task.wait(0.5)
    end
    local worldKey = Util.getCurrentWorldKey()
    if not worldKey then return false end
    if worldMacroMappings[worldKey] then
        local macroToLoad = worldMacroMappings[worldKey]
        if currentMacroName ~= macroToLoad then
            currentMacroName = macroToLoad
            MacroDropdown:Set(macroToLoad)
            Util.notify({ Title = "Macro Auto-Selected", Content = string.format("%s for %s", macroToLoad, mapName), Duration = 3 })
            return true
        end
        return true
    else
        if currentMacroName == "" or not currentMacroName then
            Util.notify({ Title = "No Macro Selected", Content = string.format("No macro mapped for %s", mapName), Duration = 4 })
        end
        return false
    end
end

local MacroInput = Tab:CreateInput({
    Name = "Create New Macro", PlaceholderText = "Enter macro name...", RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if cleanedName == "" then
            Util.notify({ Title = "Error", Content = "Macro name cannot be empty", Duration = 3 })
            return
        end
        if macroManager[cleanedName] then
            Util.notify({ Title = "Error", Content = "Macro already exists: " .. cleanedName, Duration = 3 })
            return
        end
        macroManager[cleanedName] = {}
        MacroIO.save(cleanedName, {})
        MacroDropdown:Refresh(MacroIO.getList(), cleanedName)
        Util.notify({ Title = "Success", Content = "Created macro: " .. cleanedName, Duration = 3 })
    end,
})

Tab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        MacroIO.loadAll()
        MacroDropdown:Refresh(MacroIO.getList())
        -- Refresh world dropdowns
        local macroList = {"None"}
        for name in pairs(macroManager) do table.insert(macroList, name) end
        table.sort(macroList)
        for worldKey, dropdown in pairs(worldDropdowns) do dropdown:Refresh(macroList) end
        Util.notify({ Title = "Refreshed", Content = "Macro list updated", Duration = 2 })
    end,
})

Tab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Util.notify({ Title = "Error", Content = "No macro selected", Duration = 3 })
            return
        end
        MacroIO.delete(currentMacroName)
        Util.notify({ Title = "Deleted", Content = currentMacroName, Duration = 3 })
        currentMacroName = ""
        macro = {}
        MacroDropdown:Refresh(MacroIO.getList())
        Util.updateMacroStatus("Ready")
    end,
})

function GameState.restartMatch()
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RE"):WaitForChild("MidMatchVote"):FireServer()
        return true
    end)
    if not success then warn("⚠️ Failed to press restart button:", result) return false end
    return result
end

local RecordToggle = Tab:CreateToggle({
    Name = "Record Macro", CurrentValue = false, Flag = "RecordToggle",
    Callback = function(Value)
        if Value then
            local currentWave = workspace:GetAttribute("Wave") or 0
            local matchFinished = workspace:GetAttribute("MatchFinished")

            if matchFinished or currentWave == 0 then
                -- Game hasn't started yet, just wait for wave 1
                isRecording = true
                recordingHasStarted = false
                Util.updateMacroStatus("Recording enabled - Waiting for game to start...")
                Util.notify({ Title = "Recording Ready", Content = "Recording will start when game begins (Wave 1)", Duration = 3 })
            elseif currentWave == 1 then
                -- Already on wave 1, begin immediately without restarting
                isRecording = true
                recordingHasStarted = true
                gameStartTime = tick()
                recordingUnitCounter = {}
                recordingUUIDToTag = {}
                macro = {}
                UnitTracker.startUpgradePolling()
                Util.updateMacroStatus("Recording...")
                Util.notify({ Title = "Recording Started", Content = "Started from Wave 1", Duration = 3 })
            elseif restartDisabled then
                -- Gamemode doesn't support restart, begin immediately from current wave
                isRecording = true
                recordingHasStarted = true
                gameStartTime = tick()
                recordingUnitCounter = {}
                recordingUUIDToTag = {}
                macro = {}
                UnitTracker.startUpgradePolling()
                Util.updateMacroStatus("Recording from Wave " .. currentWave)
                Util.notify({ Title = "Recording Started", Content = "Restart disabled - recording from Wave " .. currentWave, Duration = 3 })
            else
                -- Mid game above wave 1, restart
                isRecording = true
                recordingHasStarted = false
                Util.notify({ Title = "Mid-Game Detected", Content = "Attempting to restart game...", Duration = 3 })
                local restartSuccess = false
                for attempt = 1, 2 do
                    GameState.restartMatch()
                    local waitStart = tick()
                    while tick() - waitStart < 1 do
                        local wave = workspace:GetAttribute("Wave") or 0
                        if wave == 0 then restartSuccess = true break end
                        task.wait(0.1)
                    end
                    if restartSuccess then break end
                    if attempt < 2 then task.wait(0.2) end
                end
                if not restartSuccess then
                    Util.notify({ Title = "Restart Failed", Content = "Recording from current wave...", Duration = 5 })
                    recordingHasStarted = true
                    gameStartTime = tick()
                    recordingUnitCounter = {}
                    recordingUUIDToTag = {}
                    macro = {}
                    UnitTracker.startUpgradePolling()
                    Util.updateMacroStatus("Recording from Wave " .. currentWave)
                else
                    Util.updateMacroStatus("Recording enabled - Restarting game...")
                end
            end
        else
            if recordingHasStarted then
                local actionCount = #macro
                GameState.stopRecording()
                Util.notify({ Title = "Recording Stopped", Content = string.format("Saved %d actions", actionCount), Duration = 3 })
            else
                isRecording = false
                Util.updateMacroStatus("Ready")
            end
            isRecording = false
            recordingHasStarted = false
            UnitTracker.stopUpgradePolling()
            Util.updateMacroStatus("Ready")
            Util.updateDetailedStatus("Ready")
        end
    end,
})

function Playback.playMacro()
    if not macro or #macro == 0 then
        Util.updateDetailedStatus("No macro to play")
        return
    end
    Util.updateDetailedStatus("Starting playback...")
    UnitTracker.clearSpawnIdMappings()
    local totalActions = #macro
    local startTime = tick()
    for i, action in ipairs(macro) do
        local matchFinished = workspace:GetAttribute("MatchFinished")
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            Util.updateDetailedStatus("Game ended - stopped playback")
            UnitTracker.clearSpawnIdMappings()
            return
        end
        if not ignoreTiming then
            local actionTime = tonumber(action.Time)
            local currentElapsedTime = tick() - startTime
            local waitTime = actionTime - currentElapsedTime
            if waitTime > 1 then
                local waitStart = tick()
                while (tick() - waitStart) < waitTime do
                    matchFinished = workspace:GetAttribute("MatchFinished")
                    if not isPlaybackEnabled or not gameInProgress or matchFinished then
                        Util.updateDetailedStatus("Game ended - stopped playback")
                        UnitTracker.clearSpawnIdMappings()
                        return
                    end
                    local remaining = waitTime - (tick() - waitStart)
                    if remaining > 1 then
                        Util.updateDetailedStatus(string.format("(%d/%d) Waiting %.1fs for %s", i, totalActions, remaining, action.Unit or "next action"))
                    end
                    task.wait(0.5)
                end
            elseif waitTime > 0 then
                task.wait(waitTime)
            end
        else
            if i > 1 then
                Util.updateDetailedStatus(string.format("(%d/%d) Ready for next action", i, totalActions))
                task.wait(0.1)
            end
        end
        matchFinished = workspace:GetAttribute("MatchFinished")
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            Util.updateDetailedStatus("Game ended - stopped playback")
            UnitTracker.clearSpawnIdMappings()
            return
        end
        if action.Type == "spawn_unit" then
            Playback.executePlacement(action, i, totalActions)
        elseif action.Type == "upgrade_unit" then
            Playback.executeUpgrade(action, i, totalActions)
        elseif action.Type == "sell_unit" then
            Playback.executeSell(action, i, totalActions)
        elseif action.Type == "use_ability" then
            if ignoreTiming then
                local abilityTime = tonumber(action.Time)
                local delayTime = math.max(0, abilityTime - (tick() - startTime))
                task.spawn(function()
                    task.wait(delayTime)
                    local mf = workspace:GetAttribute("MatchFinished")
                    if isPlaybackEnabled and gameInProgress and not mf then
                        Playback.executeAbility(action, i, totalActions)
                    end
                end)
                Util.updateDetailedStatus(string.format("(%d/%d) Scheduled ability for %s", i, totalActions, action.Unit))
            else
                Playback.executeAbility(action, i, totalActions)
            end
        elseif action.Type == "pick_valkyrie" then
            Playback.executePickValkyrie(action, i, totalActions)
        elseif action.Type == "place_valkyrie" then
            Playback.executePlaceValkyrie(action, i, totalActions)
        elseif action.Type == "shop_purchase" then
            Playback.executeShopPurchase(action, i, totalActions)
        elseif action.Type == "fuse_units" then
            Playback.executeFusion(action, i, totalActions)
        elseif action.Type == "place_sub_tower" then
            if ignoreTiming then
                local subTime = tonumber(action.Time)
                local delayTime = math.max(0, subTime - (tick() - startTime))
                task.spawn(function()
                    task.wait(delayTime)
                    local mf = workspace:GetAttribute("MatchFinished")
                    if isPlaybackEnabled and gameInProgress and not mf then
                        Playback.executePlaceSubTower(action, i, totalActions)
                    end
                end)
                Util.updateDetailedStatus(string.format("(%d/%d) Scheduled sub tower for %s on %s",
                    i, totalActions, action.SubTowerName, action.ParentUnit))
            else
                Playback.executePlaceSubTower(action, i, totalActions)
            end
        elseif action.Type == "replace_unit" then
            Playback.executeReplaceUnit(action, i, totalActions)
        elseif action.Type == "auto_ability" then
            Playback.executeAutoAbility(action, i, totalActions)
        elseif action.Type == "toggle_auto_upgrade" then
            Playback.executeToggleAutoUpgrade(action, i, totalActions)
        elseif action.Type == "increment_auto_upgrade_priority" then
            Playback.executeIncrementAutoUpgradePriority(action, i, totalActions)
        end
        task.wait(0.1)
    end
    Util.updateMacroStatus("Playback Complete")
    Util.updateDetailedStatus(string.format("Completed %d/%d actions ✓", totalActions, totalActions))
end

function Playback.autoPlaybackLoop()
    if playbackLoopRunning then return end
    playbackLoopRunning = true
    while isPlaybackEnabled do
        while not gameInProgress and isPlaybackEnabled do
            Util.updateMacroStatus("Waiting for game to start...")
            Util.updateDetailedStatus("Waiting for wave 1...")
            task.wait(0.5)
        end
        if not isPlaybackEnabled then break end
        if not gameInProgress then task.wait(0.5) continue end

        if not currentMacroName or currentMacroName == "" then
            Util.updateMacroStatus("Error: No macro selected")
            Util.updateDetailedStatus("Select a macro to continue")
            break
        end

        local loadedMacro = MacroIO.load(currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            Util.updateMacroStatus("Error: Failed to load macro")
            Util.updateDetailedStatus("Could not load: " .. tostring(currentMacroName))
            break
        end

        macro = loadedMacro
        UnitTracker.clearSpawnIdMappings()
        -- Wait for wave 1 to be confirmed before starting playback
        local waveWait = tick()
        while (workspace:GetAttribute("Wave") or 0) < 1 and tick() - waveWait < 10 do
            task.wait(0.3)
        end
        if not isPlaybackEnabled or not gameInProgress then continue end
        Util.updateMacroStatus(string.format("Executing: %s (%d actions)", currentMacroName, #macro))
        Util.updateDetailedStatus("Starting playback...")
        Util.notify({ Title = "Playback Started", Content = currentMacroName .. " (" .. #macro .. " actions)", Duration = 3 })
        Playback.playMacro()

        while gameInProgress and isPlaybackEnabled do task.wait(0.5) end
        if not isPlaybackEnabled then break end

        UnitTracker.clearSpawnIdMappings()
        Util.updateMacroStatus("Game ended - waiting for next...")
        Util.updateDetailedStatus("Ready for next game")
        task.wait(2)
    end
    Util.updateMacroStatus("Playback Stopped")
    Util.updateDetailedStatus("Ready")
    playbackLoopRunning = false
end

local PlaybackToggle = Tab:CreateToggle({
    Name = "Playback Macro", CurrentValue = false, Flag = "PlaybackToggle",
    Callback = function(Value)
        if Value then
            task.wait(0.1)
            if not currentMacroName or currentMacroName == "" then
                Util.notify({ Title = "Playback Error", Content = "Please select a macro first!", Duration = 3 })
                return
            end
            local loadedMacro = macroManager[currentMacroName] or MacroIO.load(currentMacroName)
            if not loadedMacro or #loadedMacro == 0 then
                Util.notify({ Title = "Playback Error", Content = "Macro is empty or doesn't exist", Duration = 3 })
                return
            end
            if playbackLoopRunning then return end
            macro = loadedMacro
            local currentWave = workspace:GetAttribute("Wave") or 0
            local matchFinished = workspace:GetAttribute("MatchFinished")

            if not matchFinished and currentWave > 1 and not restartDisabled then
                -- Mid game above wave 1 and restart is supported, restart for accuracy
                Util.notify({ Title = "Mid-Game Detected", Content = "Restarting game for accurate playback...", Duration = 4 })
                GameState.restartMatch()
                gameInProgress = false
                autoPlayUsedPositions = {}
                gameStartTime = 0
            elseif not matchFinished and currentWave == 1 then
                -- Already on wave 1, playback will begin immediately via autoPlaybackLoop
                Util.notify({ Title = "Playback Ready", Content = "On Wave 1 - starting playback now", Duration = 3 })
            elseif restartDisabled then
                -- Restart not supported, begin from current state
                Util.notify({ Title = "Playback Ready", Content = "Restart disabled - playing from current wave", Duration = 3 })
            end
            isPlaybackEnabled = true
            local currentWave = workspace:GetAttribute("Wave") or 0
            local matchFinished = workspace:GetAttribute("MatchFinished")
            if currentWave >= 1 and not matchFinished then
                gameInProgress = true
                gameStartTime = gameStartTime ~= 0 and gameStartTime or tick()
            end
            Util.updateMacroStatus("Playback Enabled - Waiting for game...")
            Util.notify({ Title = "Playback Enabled", Content = "Macro will playback: " .. currentMacroName, Duration = 4 })
            task.spawn(Playback.autoPlaybackLoop)
        else
            isPlaybackEnabled = false
            local timeout = 0
            while playbackLoopRunning and timeout < 20 do task.wait(0.1) timeout = timeout + 1 end
            if playbackLoopRunning then playbackLoopRunning = false end
            Util.updateMacroStatus("Playback Disabled")
            Util.notify({ Title = "Playback Disabled", Content = "Stopped playback loop", Duration = 3 })
        end
    end,
})

Tab:CreateToggle({
    Name = "Ignore Timing", CurrentValue = false, Flag = "IgnoreTimingToggle",
    Callback = function(Value) ignoreTiming = Value end,
})

Tab:CreateToggle({
    Name = "Auto Equip Macro Units",
    CurrentValue = false,
    Flag = "AutoEquipBeforeGame",
    Callback = function(Value)
        State.AutoEquipBeforeGame = Value
    end,
})

Div = Tab:CreateDivider()

Button1 = Tab:CreateButton({
    Name = "Export Macro (Copy JSON)",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Util.notify({ Title = "Error", Content = "No macro selected", Duration = 3 }) return
        end
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Util.notify({ Title = "Error", Content = "Macro is empty", Duration = 3 }) return
        end
        local json = game:GetService("HttpService"):JSONEncode(macroData)
        if setclipboard then
            setclipboard(json)
            Util.notify({ Title = "Exported", Content = string.format("Copied %s (%d actions)", currentMacroName, #macroData), Duration = 3 })
        else
            print(json)
            Util.notify({ Title = "Exported", Content = "JSON printed to console", Duration = 3 })
        end
    end,
})

Button = Tab:CreateButton({
    Name = "Export Macro via Webhook",
    Callback = function()
        if not ValidWebhook or ValidWebhook == "" then
            Util.notify({ Title = "Error", Content = "No webhook URL set!", Duration = 3 }) return
        end
        if not currentMacroName or currentMacroName == "" then
            Util.notify({ Title = "Error", Content = "No macro selected", Duration = 3 }) return
        end
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Util.notify({ Title = "Error", Content = "Macro is empty", Duration = 3 }) return
        end
        local unitNames = {}
        local seenUnits = {}
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                if not seenUnits[unitName] then table.insert(unitNames, unitName) seenUnits[unitName] = true end
            end
        end
        table.sort(unitNames)
        local unitsText = #unitNames > 0 and table.concat(unitNames, ", ") or "No units"
        local jsonContent = Services.HttpService:JSONEncode(macroData)
        local boundary = "----WebKitFormBoundary" .. tostring(os.time())
        local fileName = currentMacroName .. ".json"
        local body = string.format(
            "--%s\r\nContent-Disposition: form-data; name=\"payload_json\"\r\nContent-Type: application/json\r\n\r\n%s\r\n--%s\r\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"%s\"\r\nContent-Type: application/json\r\n\r\n%s\r\n--%s--\r\n",
            boundary, Services.HttpService:JSONEncode({ username = "LixHub", content = "Units: " .. unitsText }), boundary, fileName, jsonContent, boundary
        )
        local requestFunc = syn and syn.request or request or http_request or (fluxus and fluxus.request) or getgenv().request
        if not requestFunc then Util.notify({ Title = "Error", Content = "Executor doesn't support HTTP requests", Duration = 3 }) return end
        local success, response = pcall(function()
            return requestFunc({ Url = ValidWebhook, Method = "POST", Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundary }, Body = body })
        end)
        if success and response and (response.StatusCode == 204 or response.StatusCode == 200) then
            Util.notify({ Title = "Macro Sent ✓", Content = string.format("Sent %s.json", currentMacroName), Duration = 3 })
        else
            Util.notify({ Title = "Error", Content = "Failed to send webhook", Duration = 3 })
        end
    end,
})

local ImportInput = Tab:CreateInput({
    Name = "Import Macro (Paste JSON)", PlaceholderText = "Paste JSON here...", RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then return end
        local success, importData = pcall(function() return game:GetService("HttpService"):JSONDecode(text) end)
        if not success then Util.notify({ Title = "Import Error", Content = "Invalid JSON format", Duration = 3 }) return end
        if type(importData) ~= "table" or #importData == 0 then Util.notify({ Title = "Import Error", Content = "No actions found in JSON", Duration = 3 }) return end
        local macroName = "Imported_" .. os.time()
        macroManager[macroName] = importData
        MacroIO.save(macroName, importData)
        MacroDropdown:Refresh(MacroIO.getList(), macroName)
        Util.notify({ Title = "Import Success", Content = string.format("%s (%d actions)", macroName, #importData), Duration = 4 })
    end,
})

Tab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Util.notify({ Title = "Error", Content = "No macro selected", Duration = 3 }) return
        end
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Util.notify({ Title = "Error", Content = "Macro is empty", Duration = 3 }) return
        end
        local unitCounts = {}
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                unitCounts[unitName] = (unitCounts[unitName] or 0) + 1
            end
        end
        if next(unitCounts) == nil then
            Util.notify({ Title = "No Units", Content = "No placements found in macro", Duration = 3 }) return
        end
        local unitList = {}
        for unitName in pairs(unitCounts) do table.insert(unitList, string.format("%s", unitName)) end
        table.sort(unitList)
        for _, line in ipairs(unitList) do print("  " .. line) end
        Util.notify({ Title = "Macro Units", Content = table.concat(unitList, ", "), Duration = 5 })
    end,
})

Div2 = Tab:CreateDivider()

function Autoplay.getPathPosition(percent)
    local PathManager = require(game:GetService("ReplicatedStorage").Shared.Modules.PathManager)
    local points, segStarts, segLengths, totalLength = PathManager.GetPathData()
    if not points or totalLength <= 0 then return nil end
    local distance = (percent / 100) * totalLength
    local position, _ = PathManager.GetPositionOnPath(distance)
    return position
end

function Autoplay.getGroundY()
    local realFloor = workspace.Map:FindFirstChild("RealFloor", true)
    if realFloor then
        local face = realFloor:FindFirstChild("Face")
        if face then
            return face.WorldPosition.Y + 0.1
        end
    end
    return 2.9 -- fallback from properties screenshot
end

function Autoplay.createHologramPart(name, size, color, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(0.1, size, size)
    part.Color = color
    part.Material = Enum.Material.Neon
    part.Transparency = transparency
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Anchored = true
    part.CastShadow = false
    part.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(90))
    part.Parent = workspace.Ignore
    return part
end

function Autoplay.updateHologramPosition()
    if not hologramEnabled then return end
    if not hologramParts.ground and not hologramParts.hill then return end

    local pathPos = Autoplay.getPathPosition(State.AutoPlayDistancePercentage)
    if not pathPos then return end

    local y = Autoplay.getGroundY()
    local pos = Vector3.new(pathPos.X, y, pathPos.Z)
    local rotation = CFrame.Angles(0, 0, math.rad(90))

    local groundSize = (State.AutoPlayGroundPercentage / 100) * 70
    local hillSize = (State.AutoPlayHillPercentage / 100) * 70

    if hologramParts.ground then
        hologramParts.ground.Size = Vector3.new(0.1, groundSize, groundSize)
        hologramParts.ground.CFrame = CFrame.new(pos) * rotation
    end

    if hologramParts.hill then
        hologramParts.hill.Size = Vector3.new(0.1, hillSize, hillSize)
        hologramParts.hill.CFrame = CFrame.new(pos) * rotation
    end
end

function Autoplay.hidePlacementSquares()
    for _, part in pairs(placementSquares) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    placementSquares = {}
end

function Autoplay.getCircleCenter()
    local pathPos = Autoplay.getPathPosition(State.AutoPlayDistancePercentage)
    if not pathPos then return nil end
    local y = Autoplay.getGroundY()
    return Vector3.new(pathPos.X, y, pathPos.Z)
end

function Autoplay.showPlacementSquares()
    Autoplay.hidePlacementSquares()
    if Util.isInLobby() then return end

    local center = Autoplay.getCircleCenter()
    if not center then return end

    local flatCenter = Vector3.new(center.X, 0, center.Z)
    local groundRadius = (State.AutoPlayGroundPercentage / 100) * 35
    local hillRadius = (State.AutoPlayHillPercentage / 100) * 35

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { workspace.Ignore }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.CollisionGroup = "Tower"
    rayParams.RespectCanCollide = false

    local stepSize = 2.5
    local floorY = center.Y + 50

    local function makeSquare(pos, color)
        local highlight = Instance.new("Part")
        highlight.Name = "AutoPlaySquare"
        highlight.Size = Vector3.new(1, 1, 1)
        highlight.CFrame = CFrame.new(pos)
        highlight.Color = color
        highlight.Material = Enum.Material.Plastic
        highlight.Transparency = 0.3
        highlight.CanCollide = false
        highlight.CanQuery = false
        highlight.CanTouch = false
        highlight.Anchored = true
        highlight.CastShadow = false
        highlight.Parent = workspace.Ignore
        table.insert(placementSquares, highlight)
    end

    -- Ground squares
    for x = -groundRadius, groundRadius, stepSize do
        for z = -groundRadius, groundRadius, stepSize do
            if Vector3.new(x, 0, z).Magnitude <= groundRadius then
                local origin = Vector3.new(center.X + x, floorY, center.Z + z)
                local result = workspace:Raycast(origin, Vector3.new(0, -100, 0), rayParams)
                if result then
                    local hit = result.Instance
                    local isFloor = false
                    local ok, floor = pcall(function()
                        return workspace.Map:FindFirstChild("RealFloor", true)
                    end)
                    if ok and floor and (hit == floor or hit:IsDescendantOf(floor)) then
                        isFloor = true
                    end
                    if isFloor then
                        makeSquare(result.Position, Color3.fromRGB(75, 219, 75))
                    end
                end
            end
        end
    end

    -- Hill squares
    for x = -hillRadius, hillRadius, stepSize do
        for z = -hillRadius, hillRadius, stepSize do
            if Vector3.new(x, 0, z).Magnitude <= hillRadius then
                local origin = Vector3.new(center.X + x, floorY, center.Z + z)
                local result = workspace:Raycast(origin, Vector3.new(0, -100, 0), rayParams)
                if result then
                    local hit = result.Instance
                    local isHill = hit:HasTag("HillPlacement") or 
                        (hit.Parent and hit.Parent:HasTag("HillPlacement"))
                    if isHill then
                        makeSquare(result.Position, Color3.fromRGB(13, 105, 229))
                    end
                end
            end
        end
    end
end

function Autoplay.showHologram()
    if hologramEnabled then return end
    if Util.isInLobby() then return end
    hologramEnabled = true

    hologramParts.ground = Autoplay.createHologramPart(
        "AutoPlayGroundCircle",
        70,
        Color3.fromRGB(75, 216, 75),
        0.9
    )

    hologramParts.hill = Autoplay.createHologramPart(
        "AutoPlayHillCircle",
        70,
        Color3.fromRGB(13, 105, 233),
        0.9
    )

    Autoplay.updateHologramPosition()
    Autoplay.showPlacementSquares()

    hologramConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not hologramEnabled then return end
        Autoplay.updateHologramPosition()
    end)
end

function Autoplay.hideHologram()
    hologramEnabled = false

    if hologramConnection then
        hologramConnection:Disconnect()
        hologramConnection = nil
    end

    for _, part in pairs(hologramParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    hologramParts = {}
    Autoplay.hidePlacementSquares()
end

function Autoplay.refreshHologram()
    if hologramEnabled then
        Autoplay.updateHologramPosition()
        Autoplay.showPlacementSquares()
    end
end

function Autoplay.getMouseHit()
    local camera = workspace.CurrentCamera
    local unitPos

    if Services.UserInputService.TouchEnabled then
        local touches = Services.UserInputService:GetTouchPositions()
        if #touches == 0 then return nil, false end
        unitPos = touches[1]
    else
        unitPos = Services.UserInputService:GetMouseLocation()
    end

    local ray = camera:ViewportPointToRay(unitPos.X, unitPos.Y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, manualRayParams)
    if not result then return nil, false end

    local hit = result.Instance
    local isHill = hit:HasTag("HillPlacement") or (hit.Parent and hit.Parent:HasTag("HillPlacement"))
    local ok, floor = pcall(function() return workspace.Map:FindFirstChild("RealFloor", true) end)
    local isFloor = ok and floor and (hit == floor or hit:IsDescendantOf(floor))
    local isValid = isHill or isFloor

    return result.Position, isValid
end

function Autoplay.getSlotUnitData(slot)
    local ok, result = pcall(function()
        local dc = DataController or Knit.GetController("DataController")
        local equipped = Services.HttpService:JSONDecode(
            Services.Players.LocalPlayer:WaitForChild("Equipped").Value
        )
        local guid = equipped[slot]
        if not guid or guid == "" then return nil end

        local unitData = dc:GetUnitData(guid)
        if not unitData or not unitData.UnitId then return nil end

        local cleanId = Util.cleanUnitName(unitData.UnitId)
        local module = Services.ReplicatedStorage.Shared.Data.Towers:FindFirstChild(cleanId)
        if not module then return nil end

        local moduleData = require(module)
        if type(moduleData) == "function" then moduleData = moduleData() end

        local isRuler = false
        if unitData.Traits then
            for _, trait in pairs(unitData.Traits) do
                if trait.Name == "Ruler" then
                    isRuler = true
                    break
                end
            end
        end

        local placementLimit = isRuler and 1 or (moduleData.Stats.Placement or 1)
        local isGround = moduleData.Stats.Ground or false
        local isHill = moduleData.Stats.Hill or false
        local isFarm = moduleData.Stats.IsFarm or false

        return {
            UnitId = cleanId,
            PlacementLimit = placementLimit,
            IsGround = isGround,
            IsHill = isHill,
            IsRuler = isRuler,
            IsFarm = isFarm,
        }
    end)

    if ok and result then return result end
    return nil
end

function Autoplay.beginManualPlacement(slot)
    if Autoplay.manualPlacementActive then
        Autoplay.endManualPlacement()
    end

    local unitData = Autoplay.getSlotUnitData(slot)
    if not unitData then
        Util.notify({ Title = "Error", Content = "No unit in slot " .. slot, Duration = 3 })
        return
    end

    Autoplay.manualPlacementActive = true
    Autoplay.manualPlacementSlot = slot
    Autoplay.manualPlacementUnitData = unitData
    Autoplay.manualPlacementSquares = {}

    -- Create one following square per placement limit
    for i = 1, unitData.PlacementLimit do
        local part = Instance.new("Part")
        part.Name = "ManualPlacementSquare"
        part.Size = Vector3.new(1, 1, 1)
        part.Material = Enum.Material.Plastic
        part.Transparency = 0.3
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.Anchored = true
        part.CastShadow = false
        part.Color = Color3.fromRGB(75, 151, 75)
        part.Parent = workspace.Ignore
        table.insert(Autoplay.manualPlacementSquares, part)
    end

    Util.notify({
        Title = "Manual Placement",
        Content = string.format("Click to set Unit %d position (%s, %dx)", 
            slot,
            unitData.IsGround and unitData.IsHill and "Ground/Hill" or unitData.IsGround and "Ground" or "Hill",
            unitData.PlacementLimit
        ),
        Duration = 4
    })

    Autoplay.manualPlacementConnection = Services.RunService.RenderStepped:Connect(function()
        if not Autoplay.manualPlacementActive then return end
        local pos, isValid = Autoplay.getMouseHit()
        if not pos then return end

        -- Validate based on unit type
        if isValid then
            local hit = workspace:Raycast(
                Vector3.new(pos.X, pos.Y + 50, pos.Z),
                Vector3.new(0, -100, 0),
                manualRayParams
            )
            if hit then
                local isHill = hit.Instance:HasTag("HillPlacement") or 
                    (hit.Instance.Parent and hit.Instance.Parent:HasTag("HillPlacement"))
                local ok2, floor = pcall(function() return workspace.Map:FindFirstChild("RealFloor", true) end)
                local isFloor = ok2 and floor and (hit.Instance == floor or hit.Instance:IsDescendantOf(floor))

                if isHill and not unitData.IsHill then isValid = false end
                if isFloor and not unitData.IsGround then isValid = false end
            end
        end

        local color = isValid 
            and Color3.fromRGB(75, 151, 75) 
            or Color3.fromRGB(255, 0, 0)

        -- Spread squares out slightly around the position
        for i, square in pairs(Autoplay.manualPlacementSquares) do
            local offset = Vector3.new((i - 1) * 1.5, 0, 0)
            square.CFrame = CFrame.new(pos + offset)
            square.Color = color
        end
    end)

    task.wait(0.3)

    Autoplay.manualPlacementClickConn = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        local isTap = input.UserInputType == Enum.UserInputType.Touch
        local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
        if not (isClick or isTap) then return end
        if not Autoplay.manualPlacementActive then return end

        local pos, isValid = Autoplay.getMouseHit()
        if pos and isValid then
            State.AutoPlayUnitPositions[Autoplay.manualPlacementSlot] = pos
            MacroIO.saveAutoPlayPositions()
            Util.notify({ Title = "Position Saved", Content = "Unit " .. slot .. " position set!", Duration = 3 })
            Autoplay.endManualPlacement()
        else
            Util.notify({ Title = "Invalid Position", Content = "Place on a valid position for this unit type", Duration = 2 })
        end
    end)
end

function Autoplay.endManualPlacement()
    Autoplay.manualPlacementActive = false
    Autoplay.manualPlacementSlot = nil
    Autoplay.manualPlacementUnitData = nil

    if Autoplay.manualPlacementConnection then
        Autoplay.manualPlacementConnection:Disconnect()
        Autoplay.manualPlacementConnection = nil
    end

    if Autoplay.manualPlacementClickConn then
        Autoplay.manualPlacementClickConn:Disconnect()
        Autoplay.manualPlacementClickConn = nil
    end

    if Autoplay.manualPlacementSquares then
        for _, part in pairs(Autoplay.manualPlacementSquares) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        Autoplay.manualPlacementSquares = nil
    end
end

function Autoplay.showAllPositions()
    local hasAny = false
    for i = 1, 6 do
        if State.AutoPlayUnitPositions[i] then
            hasAny = true
            break
        end
    end

    if not hasAny then
        Util.notify({ Title = "No Positions Set", Content = "No unit positions have been saved yet", Duration = 3 })
        return
    end

    local colors = {
        Color3.fromRGB(255, 100, 100),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 200, 100),
        Color3.fromRGB(0, 150, 255),
        Color3.fromRGB(200, 0, 255),
    }

    local positionParts = {}

    for i = 1, 6 do
        local pos = State.AutoPlayUnitPositions[i]
        if pos then
            local unitData = Autoplay.getSlotUnitData(i)
            local placementLimit = unitData and unitData.PlacementLimit or 1

            for j = 1, placementLimit do
                local offset = Vector3.new((j - 1) * 1.5, 0, 0)

                local part = Instance.new("Part")
                part.Name = "AutoPlayPositionSquare"
                part.Size = Vector3.new(1, 1, 1)
                part.CFrame = CFrame.new(pos + offset)
                part.Color = colors[i]
                part.Material = Enum.Material.Neon
                part.Transparency = 0.3
                part.CanCollide = false
                part.CanQuery = false
                part.CanTouch = false
                part.Anchored = true
                part.CastShadow = false
                part.Parent = workspace.Ignore

                -- Only add label on first square of each slot
                if j == 1 then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "UnitLabel"
                    billboard.Size = UDim2.new(0, 80, 0, 20)
                    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = part

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = string.format("Unit %d (%dx)", i, placementLimit)
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    label.Parent = billboard
                end

                table.insert(positionParts, part)
            end
        end
    end

    task.delay(10, function()
        for _, part in pairs(positionParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        positionParts = {}
    end)
end

function Autoplay.getValidSquaresInCircle()
    local center = Autoplay.getCircleCenter()
    if not center then return {} end

    local flatCenter = Vector3.new(center.X, 0, center.Z)
    local groundRadius = (State.AutoPlayGroundPercentage / 100) * 35
    local hillRadius = (State.AutoPlayHillPercentage / 100) * 35

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { workspace.Ignore }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.CollisionGroup = "Tower"
    rayParams.RespectCanCollide = false

    local squares = {}
    local stepSize = 2.5
    local floorY = center.Y + 50

    local function addSquare(pos, isHill)
        table.insert(squares, {
            Position = pos,
            IsHill = isHill,
            IsGround = not isHill,
        })
    end

    -- Ground squares
    for x = -groundRadius, groundRadius, stepSize do
        for z = -groundRadius, groundRadius, stepSize do
            if Vector3.new(x, 0, z).Magnitude <= groundRadius then
                local origin = Vector3.new(center.X + x, floorY, center.Z + z)
                local result = workspace:Raycast(origin, Vector3.new(0, -100, 0), rayParams)
                if result then
                    local ok, floor = pcall(function() return workspace.Map:FindFirstChild("RealFloor", true) end)
                    if ok and floor and (result.Instance == floor or result.Instance:IsDescendantOf(floor)) then
                        addSquare(result.Position, false)
                    end
                end
            end
        end
    end

    -- Hill squares
    for x = -hillRadius, hillRadius, stepSize do
        for z = -hillRadius, hillRadius, stepSize do
            if Vector3.new(x, 0, z).Magnitude <= hillRadius then
                local origin = Vector3.new(center.X + x, floorY, center.Z + z)
                local result = workspace:Raycast(origin, Vector3.new(0, -100, 0), rayParams)
                if result then
                    local isHill = result.Instance:HasTag("HillPlacement") or
                        (result.Instance.Parent and result.Instance.Parent:HasTag("HillPlacement"))
                    if isHill then
                        addSquare(result.Position, true)
                    end
                end
            end
        end
    end

    return squares
end

function Autoplay.getPathDistanceForPosition(pos)
    local PathManager = require(game:GetService("ReplicatedStorage").Shared.Modules.PathManager)
    local points, segStarts, segLengths, totalLength = PathManager.GetPathData()
    if not points or #points == 0 then return math.huge end

    local flatPos = Vector3.new(pos.X, 0, pos.Z)
    local closestDist = math.huge

    for i = 1, #points - 1 do
        local a = Vector3.new(points[i].X, 0, points[i].Z)
        local b = Vector3.new(points[i+1].X, 0, points[i+1].Z)
        local ab = b - a
        local ap = flatPos - a
        local t = math.clamp(ap:Dot(ab) / ab:Dot(ab), 0, 1)
        local closest = a + ab * t
        local dist = (flatPos - closest).Magnitude
        if dist < closestDist then
            closestDist = dist
        end
    end

    return closestDist
end

function Autoplay.isPositionOccupied(pos)
    local unitsFolder = workspace:FindFirstChild("Ignore") and workspace.Ignore:FindFirstChild("Units")
    if not unitsFolder then return false end
    local flatPos = Vector3.new(pos.X, 0, pos.Z)
    for _, unit in pairs(unitsFolder:GetChildren()) do
        local root = unit:FindFirstChild("HumanoidRootPart") or unit:FindFirstChildWhichIsA("BasePart")
        if root then
            local flatUnit = Vector3.new(root.Position.X, 0, root.Position.Z)
            if (flatUnit - flatPos).Magnitude < 2.5 then
                return true
            end
        end
    end
    return false
end

function Autoplay.findNearestValidSquare(squares, unitData, excludePositions)
    excludePositions = excludePositions or {}

    -- Filter by unit type
    local filtered = {}
    for _, square in pairs(squares) do
        local typeOk = (unitData.IsGround and square.IsGround) or (unitData.IsHill and square.IsHill)
        if typeOk then
            table.insert(filtered, square)
        end
    end

    -- Sort ALL squares by path proximity (closest to path first)
    table.sort(filtered, function(a, b)
        return Autoplay.getPathDistanceForPosition(a.Position) < Autoplay.getPathDistanceForPosition(b.Position)
    end)

    -- Find first unoccupied spot with enough spread from other placed units
    local MIN_SPREAD = 0.5 -- increase this to spread units further apart
    for _, square in pairs(filtered) do
        -- Check against already-placed units in workspace
        if Autoplay.isPositionOccupied(square.Position) then continue end

        -- Check against units placed THIS session (excludePositions)
        local tooClose = false
        for _, exPos in pairs(excludePositions) do
            local dist = (Vector3.new(square.Position.X, 0, square.Position.Z) 
                        - Vector3.new(exPos.X, 0, exPos.Z)).Magnitude
            if dist < MIN_SPREAD then
                tooClose = true
                break
            end
        end

        if not tooClose then
            return square.Position
        end
    end

    return nil
end

function Autoplay.getTowerUpgradeLevel(guid)
    local success, result = pcall(function()
        local towers = PlacedTowerController:GetTowers()
        local tower = towers[guid]
        if not tower then return nil end
        -- Use the model's Upgrade attribute directly
        local model = rawget(tower, "Model")
        if model then
            local upgradeAttr = model:GetAttribute("Upgrade")
            if upgradeAttr then return upgradeAttr end
        end
        -- Fallback to rawget
        return rawget(tower, "Upgrade") or 1
    end)
    if success and result then return result end
    return 1
end

function Autoplay.getPlacedCountForSlot(slot)
    if not PlacedTowerController then return 0 end
    local unitData = Autoplay.getSlotUnitData(slot)
    if not unitData then return 0 end

    local count = 0
    local towers = PlacedTowerController:GetTowers()
    for guid, tower in pairs(towers) do
        local owner = PlacedTowerController:GetOwner(guid)
        if not owner or owner ~= Services.Players.LocalPlayer then continue end

        local towerId = rawget(tower, "TowerID") or rawget(tower, "UnitId") or ""
        local cleanId = Util.cleanUnitName(towerId)
        if cleanId == unitData.UnitId then
            count = count + 1
        end
    end
    return count
end

function Autoplay.getEffectivePlacementCap(slot, unitData)
    local userCap = ({
        State.AutoPlayPlaceCap1,
        State.AutoPlayPlaceCap2,
        State.AutoPlayPlaceCap3,
        State.AutoPlayPlaceCap4,
        State.AutoPlayPlaceCap5,
        State.AutoPlayPlaceCap6,
    })[slot] or unitData.PlacementLimit

    -- User cap cant exceed unit's own limit
    return math.min(userCap, unitData.PlacementLimit)
end

function Autoplay.getPlaceOnWave(slot)
    return ({
        State.AutoPlayPlaceOnWaveUnit1,
        State.AutoPlayPlaceOnWaveUnit2,
        State.AutoPlayPlaceOnWaveUnit3,
        State.AutoPlayPlaceOnWaveUnit4,
        State.AutoPlayPlaceOnWaveUnit5,
        State.AutoPlayPlaceOnWaveUnit6,
    })[slot] or 0
end

function Autoplay.tryPlaceUnit(slot, unitData, squares)
    local currentWave = workspace:GetAttribute("Wave") or 0
    local placeOnWave = Autoplay.getPlaceOnWave(slot)
    if placeOnWave > 0 and currentWave < placeOnWave then return false end

    local effectiveCap = Autoplay.getEffectivePlacementCap(slot, unitData)
    local alreadyPlaced = Autoplay.getPlacedCountForSlot(slot)
    if alreadyPlaced >= effectiveCap then return false end

    local targetPos = nil

    if State.AutoPlayUnitPositions[slot] then
        targetPos = State.AutoPlayUnitPositions[slot]
        if Autoplay.isPositionOccupied(targetPos) then
            targetPos = Autoplay.findNearestValidSquare(squares, unitData, autoPlayUsedPositions)
        end
    else
        targetPos = Autoplay.findNearestValidSquare(squares, unitData, autoPlayUsedPositions)
    end

    if not targetPos then return false end

    -- Cost check
    local placementCost = 0
    local towerModule = Services.ReplicatedStorage.Shared.Data.Towers:FindFirstChild(unitData.UnitId)
    if towerModule then
        local ok, data = pcall(require, towerModule)
        if ok and data and data.Stats and data.Stats.Upgrades then
            placementCost = data.Stats.Upgrades[1].Cost or 0
        end
    end
    if placementCost > 0 then
        local canContinue = Autoplay.waitForMoney(placementCost, unitData.UnitId)
        if not canContinue then return false end
    end

    local slotNum = UnitTracker.getSlotForUnit(unitData.UnitId)
    if not slotNum then
        print(string.format("Unit %s not found in loadout", unitData.UnitId))
        return false
    end
    print(string.format("Placing %s at slot %d...", unitData.UnitId, slotNum))

    local cframe = CFrame.new(targetPos)
    local success = pcall(function()
        TowerService:WaitForChild("PlaceUnit"):InvokeServer(slotNum, cframe)
    end)

    if success then
        table.insert(autoPlayUsedPositions, targetPos) -- track for spread
        return true
    end
    return false
end

function Autoplay.startAutoPlace()
    if autoPlaceRunning then return end
    autoPlaceRunning = true

    task.spawn(function()
        while State.AutoPlayEnableAutoPlace and gameInProgress do
            local matchFinished = workspace:GetAttribute("MatchFinished")
            if matchFinished then break end

            local currentWave = workspace:GetAttribute("Wave") or 0
            if currentWave < 1 then
                task.wait(0.5)
                continue
            end

            local squares = Autoplay.getValidSquaresInCircle()
            if #squares == 0 then
                task.wait(1)
                continue
            end

            -- Build slot order, farm units first if Focus Farm enabled
            local slots = {}
            for i = 1, 6 do
                local unitData = Autoplay.getSlotUnitData(i)
                if unitData then
                    table.insert(slots, { slot = i, unitData = unitData })
                end
            end

            if State.AutoPlayFocusFarmUnits then
                table.sort(slots, function(a, b)
                    local aFarm = a.unitData.IsFarm or false
                    local bFarm = b.unitData.IsFarm or false
                    if aFarm ~= bFarm then return aFarm end
                    return a.slot < b.slot
                end)
            end

            local allPlaced = true
            for _, entry in pairs(slots) do
                local effectiveCap = Autoplay.getEffectivePlacementCap(entry.slot, entry.unitData)
                local alreadyPlaced = Autoplay.getPlacedCountForSlot(entry.slot)
                local placeOnWave = Autoplay.getPlaceOnWave(entry.slot)
                local currentWaveCheck = workspace:GetAttribute("Wave") or 0

                local waveOk = placeOnWave == 0 or currentWaveCheck >= placeOnWave

                if waveOk and alreadyPlaced < effectiveCap then
                    allPlaced = false
                    Autoplay.tryPlaceUnit(entry.slot, entry.unitData, squares)
                    task.wait(0.5)
                end
            end

            if allPlaced then
                task.wait(2)
            else
                task.wait(0.5)
            end
        end

        autoPlaceRunning = false
    end)
end

function Autoplay.stopAutoPlace()
    autoPlaceRunning = false
end

function Autoplay.getUpgradeOnWave(slot)
    return ({
        State.AutoPlayUpgradeOnWaveUnit1,
        State.AutoPlayUpgradeOnWaveUnit2,
        State.AutoPlayUpgradeOnWaveUnit3,
        State.AutoPlayUpgradeOnWaveUnit4,
        State.AutoPlayUpgradeOnWaveUnit5,
        State.AutoPlayUpgradeOnWaveUnit6,
    })[slot] or 0
end

function Autoplay.getEffectiveUpgradeCap(slot, unitData)
    local userCap = ({
        State.AutoPlayUpgradeCap1,
        State.AutoPlayUpgradeCap2,
        State.AutoPlayUpgradeCap3,
        State.AutoPlayUpgradeCap4,
        State.AutoPlayUpgradeCap5,
        State.AutoPlayUpgradeCap6,
    })[slot] or 10

    -- Get max upgrades from unit data
    local maxUpgrades = 1
    local ok, data = pcall(function()
        return require(Services.ReplicatedStorage.Shared.Data.Towers:FindFirstChild(unitData.UnitId))
    end)
    if ok and data and data.Stats and data.Stats.Upgrades then
        maxUpgrades = #data.Stats.Upgrades
    end

    -- User cap can't exceed unit's own max
    return math.min(userCap, maxUpgrades)
end

function Autoplay.startAutoUpgrade()
    task.spawn(function()
        while State.AutoPlayEnableAutoUpgrade and gameInProgress do
            local matchFinished = workspace:GetAttribute("MatchFinished")
            if matchFinished then break end

            local currentWave = workspace:GetAttribute("Wave") or 0
            if currentWave < 1 then task.wait(0.5) continue end

            if not PlacedTowerController then task.wait(1) continue end

            local towers = PlacedTowerController:GetTowers()
            local candidates = {}

            for guid, tower in pairs(towers) do
                local owner = PlacedTowerController:GetOwner(guid)
                if not owner or owner ~= Services.Players.LocalPlayer then continue end

                local towerId = rawget(tower, "TowerID") or rawget(tower, "UnitId") or ""
                local cleanId = Util.cleanUnitName(towerId)

                local currentLevel = PlacedTowerController:GetUpgradeLevel(guid)

                -- Find which slot
                local slot = nil
                for i = 1, 6 do
                    local unitData = Autoplay.getSlotUnitData(i)
                    if unitData and unitData.UnitId == cleanId then
                        slot = i
                        break
                    end
                end
                if not slot then continue end

                -- Wave restriction
                local upgradeOnWave = Autoplay.getUpgradeOnWave(slot)
                if upgradeOnWave > 0 and currentWave < upgradeOnWave then continue end

                local unitData = Autoplay.getSlotUnitData(slot)
                if not unitData then continue end

                local effectiveCap = Autoplay.getEffectiveUpgradeCap(slot, unitData)
                if currentLevel >= effectiveCap then continue end

                table.insert(candidates, {
                    guid = guid,
                    slot = slot,
                    level = currentLevel,
                    cap = effectiveCap,
                    isFarm = unitData.IsFarm or false,
                    unitId = cleanId,
                })
            end

            if #candidates == 0 then
                task.wait(2)
                continue
            end

            -- Farm priority
            if State.AutoPlayFocusFarmUnitsUpgrade then
                local farmNotMaxed = false
                for _, c in ipairs(candidates) do
                    if c.isFarm and c.level < c.cap then
                        farmNotMaxed = true
                        break
                    end
                end
                if farmNotMaxed then
                    local farmOnly = {}
                    for _, c in ipairs(candidates) do
                        if c.isFarm then table.insert(farmOnly, c) end
                    end
                    candidates = farmOnly
                end
            end

            -- Sort by lowest level
            table.sort(candidates, function(a, b)
                return a.level < b.level
            end)

            local upgraded = false
            for _, candidate in ipairs(candidates) do
                local freshLevel = PlacedTowerController:GetUpgradeLevel(candidate.guid)
                if freshLevel >= candidate.cap then continue end

                -- Get upgrade cost
                local upgradeCost = 0
                local ok, data = pcall(function()
                    return require(Services.ReplicatedStorage.Shared.Data.Towers:FindFirstChild(candidate.unitId))
                end)
                if ok and data and data.Stats and data.Stats.Upgrades then
                    local nextUpgrade = data.Stats.Upgrades[freshLevel + 1]
                    if nextUpgrade and nextUpgrade.Cost then
                        upgradeCost = nextUpgrade.Cost
                    end
                end

                if upgradeCost > 0 then
                    local canContinue = Autoplay.waitForMoney(upgradeCost, candidate.unitId .. " upgrade")
                    if not canContinue then break end
                end

                local success = pcall(function()
                    TowerService:WaitForChild("UpgradeUnit"):InvokeServer(candidate.guid)
                end)

                if success then
                    Util.updateDetailedStatus(string.format("Upgraded %s (Lv%d→%d)",
                        candidate.unitId, freshLevel, freshLevel + 1))
                    upgraded = true
                    task.wait(0.5)
                    break
                end
            end

            if not upgraded then
                task.wait(1)
            else
                task.wait(0.3)
            end
        end
    end)
end

AutoPlayTab:CreateToggle({
    Name = "Enable Hologram",
    CurrentValue = false,
    Flag = "AutoPlayEnableHologram",
    Callback = function(Value)
        State.AutoPlayEnableHologram = Value
        if Value then
            if not Util.isInLobby() then
            Autoplay.showHologram()
            end
        else
            Autoplay.hideHologram()
        end
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Distance Percentage",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "AutoPlayDistancePercentage",
    Callback = function(Value)
        State.AutoPlayDistancePercentage = Value
        Autoplay.refreshHologram()
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Ground Percentage",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "AutoPlayGroundPercentage",
    Callback = function(Value)
        State.AutoPlayGroundPercentage = Value
        Autoplay.refreshHologram()
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Hill Percentage",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "AutoPlayHillPercentage",
    Callback = function(Value)
        State.AutoPlayHillPercentage = Value
        Autoplay.refreshHologram()
    end,
})

-- ============================================
-- MANUAL PLACEMENT SECTION
-- ============================================

AutoPlayTab:CreateDivider()

AutoPlayTab:CreateSection("Manual Placement Positions")

AutoPlayTab:CreateButton({
    Name = "Set Unit 1 Position",
    Callback = function()
        Autoplay.beginManualPlacement(1)
    end,
})
AutoPlayTab:CreateButton({
    Name = "Reset Unit 1 Position",
    Callback = function()
        State.AutoPlayUnitPositions[1] = nil
        MacroIO.saveAutoPlayPositions()
        Util.notify({ Title = "Reset", Content = "Unit 1 position cleared", Duration = 1.5 })
    end,
})

AutoPlayTab:CreateButton({
    Name = "Set Unit 2 Position",
    Callback = function()
        Autoplay.beginManualPlacement(2)
    end,
})
AutoPlayTab:CreateButton({
    Name = "Reset Unit 2 Position",
    Callback = function()
        State.AutoPlayUnitPositions[2] = nil
        MacroIO.saveAutoPlayPositions()
        Util.notify({ Title = "Reset", Content = "Unit 2 position cleared", Duration = 1.5 })
    end,
})

AutoPlayTab:CreateButton({
    Name = "Set Unit 3 Position",
    Callback = function()
        Autoplay.beginManualPlacement(3)
    end,
})
AutoPlayTab:CreateButton({
    Name = "Reset Unit 3 Position",
    Callback = function()
        State.AutoPlayUnitPositions[3] = nil
        MacroIO.saveAutoPlayPositions()
        Util.notify({ Title = "Reset", Content = "Unit 3 position cleared", Duration = 1.5 })
    end,
})

AutoPlayTab:CreateButton({
    Name = "Set Unit 4 Position",
    Callback = function()
        Autoplay.beginManualPlacement(4)
    end,
})
AutoPlayTab:CreateButton({
    Name = "Reset Unit 4 Position",
    Callback = function()
        State.AutoPlayUnitPositions[4] = nil
        MacroIO.saveAutoPlayPositions()
        Util.notify({ Title = "Reset", Content = "Unit 4 position cleared", Duration = 1.5 })
    end,
})

AutoPlayTab:CreateButton({
    Name = "Set Unit 5 Position",
    Callback = function()
        Autoplay.beginManualPlacement(5)
    end,
})
AutoPlayTab:CreateButton({
    Name = "Reset Unit 5 Position",
    Callback = function()
        State.AutoPlayUnitPositions[5] = nil
        MacroIO.saveAutoPlayPositions()
        Util.notify({ Title = "Reset", Content = "Unit 5 position cleared", Duration = 1.5 })
    end,
})

AutoPlayTab:CreateButton({
    Name = "Set Unit 6 Position",
    Callback = function()
        Autoplay.beginManualPlacement(6)
    end,
})
AutoPlayTab:CreateButton({
    Name = "Reset Unit 6 Position",
    Callback = function()
        State.AutoPlayUnitPositions[6] = nil
        MacroIO.saveAutoPlayPositions()
        Util.notify({ Title = "Reset", Content = "Unit 6 position cleared", Duration = 1.5 })
    end,
})

AutoPlayTab:CreateButton({
    Name = "Show All Positions",
    Callback = function()
        Autoplay.showAllPositions()
    end,
})

-- ============================================
-- AUTO PLACE & UPGRADE SETTINGS SECTION
-- ============================================

AutoPlayTab:CreateDivider()

AutoPlayTab:CreateSection("Auto Place Settings")

AutoPlayTab:CreateToggle({
    Name = "Enable Auto Place",
    CurrentValue = false,
    Flag = "AutoPlayEnableAutoPlace",
    Callback = function(Value)
        State.AutoPlayEnableAutoPlace = Value
        if Value and gameInProgress then
            Autoplay.startAutoPlace()
        else
            Autoplay.stopAutoPlace()
        end
    end,
})

AutoPlayTab:CreateToggle({
    Name = "Focus On Farm Units",
    CurrentValue = false,
    Flag = "AutoPlayFocusFarmUnits",
    Callback = function(Value)
        State.AutoPlayFocusFarmUnits = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Place Cap Unit 1",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 3,
    Flag = "AutoPlayPlaceCap1",
    Callback = function(Value)
        State.AutoPlayPlaceCap1 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Place Cap Unit 2",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 3,
    Flag = "AutoPlayPlaceCap2",
    Callback = function(Value)
        State.AutoPlayPlaceCap2 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Place Cap Unit 3",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 3,
    Flag = "AutoPlayPlaceCap3",
    Callback = function(Value)
        State.AutoPlayPlaceCap3 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Place Cap Unit 4",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 3,
    Flag = "AutoPlayPlaceCap4",
    Callback = function(Value)
        State.AutoPlayPlaceCap4 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Place Cap Unit 5",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 3,
    Flag = "AutoPlayPlaceCap5",
    Callback = function(Value)
        State.AutoPlayPlaceCap5 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Place Cap Unit 6",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 3,
    Flag = "AutoPlayPlaceCap6",
    Callback = function(Value)
        State.AutoPlayPlaceCap6 = Value
    end,
})

-- ============================================
-- AUTO PLACE ON WAVE SECTION
-- ============================================

AutoPlayTab:CreateDivider()

AutoPlayTab:CreateSection("Auto Place On Wave")

AutoPlayTab:CreateSlider({
    Name = "Unit 1",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayPlaceOnWaveUnit1",
    Callback = function(Value)
        State.AutoPlayPlaceOnWaveUnit1 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 1",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayPlaceOnWaveUnit1"]:Set(num)
        State.AutoPlayPlaceOnWaveUnit1 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 2",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayPlaceOnWaveUnit2",
    Callback = function(Value)
        State.AutoPlayPlaceOnWaveUnit2 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 2",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayPlaceOnWaveUnit2"]:Set(num)
        State.AutoPlayPlaceOnWaveUnit2 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 3",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayPlaceOnWaveUnit3",
    Callback = function(Value)
        State.AutoPlayPlaceOnWaveUnit3 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 3",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayPlaceOnWaveUnit3"]:Set(num)
        State.AutoPlayPlaceOnWaveUnit3 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 4",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayPlaceOnWaveUnit4",
    Callback = function(Value)
        State.AutoPlayPlaceOnWaveUnit4 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 4",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayPlaceOnWaveUnit4"]:Set(num)
        State.AutoPlayPlaceOnWaveUnit4 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 5",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayPlaceOnWaveUnit5",
    Callback = function(Value)
        State.AutoPlayPlaceOnWaveUnit5 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 5",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayPlaceOnWaveUnit5"]:Set(num)
        State.AutoPlayPlaceOnWaveUnit5 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 6",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayPlaceOnWaveUnit6",
    Callback = function(Value)
        State.AutoPlayPlaceOnWaveUnit6 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 6",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayPlaceOnWaveUnit6"]:Set(num)
        State.AutoPlayPlaceOnWaveUnit6 = num
    end,
})

AutoPlayTab:CreateDivider()

AutoPlayTab:CreateSection("Auto Upgrade Settings")

AutoPlayTab:CreateToggle({
    Name = "Enable Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoPlayEnableAutoUpgrade",
    Callback = function(Value)
        State.AutoPlayEnableAutoUpgrade = Value
        if Value and gameInProgress then
            Autoplay.startAutoUpgrade()
        end
    end,
})

AutoPlayTab:CreateToggle({
    Name = "Focus On Farm Units",
    CurrentValue = false,
    Flag = "AutoPlayFocusFarmUnitsUpgrade",
    Callback = function(Value)
        State.AutoPlayFocusFarmUnitsUpgrade = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Upgrade Cap Unit 1",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AutoPlayUpgradeCap1",
    Callback = function(Value)
        State.AutoPlayUpgradeCap1 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Upgrade Cap Unit 2",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AutoPlayUpgradeCap2",
    Callback = function(Value)
        State.AutoPlayUpgradeCap2 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Upgrade Cap Unit 3",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AutoPlayUpgradeCap3",
    Callback = function(Value)
        State.AutoPlayUpgradeCap3 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Upgrade Cap Unit 4",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AutoPlayUpgradeCap4",
    Callback = function(Value)
        State.AutoPlayUpgradeCap4 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Upgrade Cap Unit 5",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AutoPlayUpgradeCap5",
    Callback = function(Value)
        State.AutoPlayUpgradeCap5 = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Upgrade Cap Unit 6",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AutoPlayUpgradeCap6",
    Callback = function(Value)
        State.AutoPlayUpgradeCap6 = Value
    end,
})

AutoPlayTab:CreateDivider()

AutoPlayTab:CreateSection("Auto Upgrade On Wave")

AutoPlayTab:CreateSlider({
    Name = "Unit 1",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayUpgradeOnWaveUnit1",
    Callback = function(Value)
        State.AutoPlayUpgradeOnWaveUnit1 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 1",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayUpgradeOnWaveUnit1"]:Set(num)
        State.AutoPlayUpgradeOnWaveUnit1 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 2",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayUpgradeOnWaveUnit2",
    Callback = function(Value)
        State.AutoPlayUpgradeOnWaveUnit2 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 2",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayUpgradeOnWaveUnit2"]:Set(num)
        State.AutoPlayUpgradeOnWaveUnit2 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 3",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayUpgradeOnWaveUnit3",
    Callback = function(Value)
        State.AutoPlayUpgradeOnWaveUnit3 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 3",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayUpgradeOnWaveUnit3"]:Set(num)
        State.AutoPlayUpgradeOnWaveUnit3 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 4",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayUpgradeOnWaveUnit4",
    Callback = function(Value)
        State.AutoPlayUpgradeOnWaveUnit4 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 4",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayUpgradeOnWaveUnit4"]:Set(num)
        State.AutoPlayUpgradeOnWaveUnit4 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 5",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayUpgradeOnWaveUnit5",
    Callback = function(Value)
        State.AutoPlayUpgradeOnWaveUnit5 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 5",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayUpgradeOnWaveUnit5"]:Set(num)
        State.AutoPlayUpgradeOnWaveUnit5 = num
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 6",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = 0,
    Flag = "AutoPlayUpgradeOnWaveUnit6",
    Callback = function(Value)
        State.AutoPlayUpgradeOnWaveUnit6 = Value
    end,
})

AutoPlayTab:CreateInput({
    Name = "Unit 6",
    PlaceholderText = "0 - 300",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        num = math.clamp(num, 0, 300)
        Rayfield.Flags["AutoPlayUpgradeOnWaveUnit6"]:Set(num)
        State.AutoPlayUpgradeOnWaveUnit6 = num
    end,
})

AutoPlayTab:CreateDivider()

AutoAbilityTab:CreateToggle({
    Name = "Enable Auto Abilities",
    CurrentValue = false,
    Flag = "AutoAbilityMasterToggle",
    Callback = function(Value)
        AutoAbility.enabled = Value
    end,
})

AutoAbilityTab:CreateDivider()

local function getEquippedUnitIds()
    local unitIds = {}
    local success, err = pcall(function()
        local dc = DataController or Knit.GetController("DataController")
        
        local equipped = Services.HttpService:JSONDecode(
            Services.Players.LocalPlayer:WaitForChild("Equipped", 10).Value
        )

        for _, guid in ipairs(equipped) do
            if not guid or guid == "" then continue end
            local ok, data = pcall(function() return dc:GetUnitData(guid) end)
            if ok and data and data.UnitId then
                table.insert(unitIds, data.UnitId)
            end
        end
    end)
    if not success then warn("getEquippedUnitIds failed:", err) end
    return unitIds
end

local function getAbilitiesFromModule(unitId)
    local abilities = {}
    local success, result = pcall(function()
        local cleanId = Util.cleanUnitName(unitId)
        local towersFolder = Services.ReplicatedStorage.Shared.Data.Towers
        local module = towersFolder:FindFirstChild(cleanId)
            or towersFolder:FindFirstChild(unitId)
        if not module or not module:IsA("ModuleScript") then return end

        local data = require(module)
        if type(data) == "function" then data = data() end
        if not data or not data.Stats or not data.Stats.Upgrades then return end

        -- Find the highest upgrade tier to get all possible abilities
        -- We collect all unique abilities across all upgrade tiers
        local seen = {}
        for _, upgrade in ipairs(data.Stats.Upgrades) do
            if upgrade.Ability then
                local abilityList = type(upgrade.Ability[1]) == "table" 
                    and upgrade.Ability 
                    or upgrade.Ability
                for _, ability in ipairs(abilityList) do
                    if ability.Name and not seen[ability.Name] then
                        seen[ability.Name] = true
                        table.insert(abilities, {
                            Name = ability.Name,
                            Title = ability.Title or ability.Name,
                            Cooldown = ability.Cooldown or 60,
                            Global = ability.Global or false,
                            Icon = ability.Icon,
                        })
                    end
                end
            end
        end
    end)
    if not success then warn("Failed to load module for: " .. tostring(unitId)) end
    return abilities
end

local function buildAutoAbilityUI()
    local savedSettings = MacroIO.loadAutoAbilitySettings()

    local unitIds = getEquippedUnitIds()
    if #unitIds == 0 then
        AutoAbilityTab:CreateLabel("No equipped units found. Rejoin or re-execute.")
        return
    end

    for _, unitId in ipairs(unitIds) do
        local abilities = getAbilitiesFromModule(unitId)
        if #abilities == 0 then continue end

        local cleanId = Util.cleanUnitName(unitId)
        local displayName = cleanId
        local ok, unitData = pcall(function()
            return require(Services.ReplicatedStorage.Shared.Data.Towers:FindFirstChild(cleanId)
                or Services.ReplicatedStorage.Shared.Data.Towers:FindFirstChild(unitId))
        end)
        if ok and unitData and unitData.Name then
            displayName = unitData.Name
        end
        AutoAbilityTab:CreateSection(displayName)

        for _, ability in ipairs(abilities) do
            local settingKey = cleanId .. "_" .. ability.Name
            local saved = savedSettings[settingKey] or {}
            abilitySettings[settingKey] = {
                mode = saved.mode or "Disabled",
                wave = saved.wave or 1,
                delay = saved.delay or 0,
                shanglongWish = saved.shanglongWish or "Wealth",
            }

            local label = string.format("%s",ability.Title)

            AutoAbilityTab:CreateLabel(label)

            if ability.Name == "ShenronSummon" then
                AutoAbilityTab:CreateDropdown({
                    Name = "Select Wish",
                    Options = { "Wealth", "Power", "Knowledge" },
                    CurrentOption = { abilitySettings[settingKey].shanglongWish },
                    MultipleOptions = false,
                    Callback = function(Option)
                        local selected = type(Option) == "table" and Option[1] or Option
                        abilitySettings[settingKey].shanglongWish = selected
                        MacroIO.saveAutoAbilitySettings()
                    end,
                })
            end

            AutoAbilityTab:CreateDropdown({
                Name = "Mode",
                Options = { "Disabled", "Auto (Always)", "On Wave", "On Boss" },
                CurrentOption = { abilitySettings[settingKey].mode },  -- read from saved
                MultipleOptions = false,
                Callback = function(Option)
                    local selected = type(Option) == "table" and Option[1] or Option
                    abilitySettings[settingKey].mode = selected
                    MacroIO.saveAutoAbilitySettings()
                end,
            })

            local delaySlider = AutoAbilityTab:CreateSlider({
                Name = "Delay use by x seconds (0 = disable)",
                Range = { 0, 300 },
                Increment = 1,
                CurrentValue = abilitySettings[settingKey].delay,  -- read from saved
                Callback = function(Value)
                    abilitySettings[settingKey].delay = Value
                    MacroIO.saveAutoAbilitySettings()
                end,
            })

            AutoAbilityTab:CreateInput({
                Name = "Delay use by x seconds (0 = disable)",
                PlaceholderText = "0 - 300",
                RemoveTextAfterFocusLost = true,
                Callback = function(Text)
                    local num = tonumber(Text)
                    if not num then return end
                    num = math.clamp(num, 0, 300)
                    delaySlider:Set(num)
                    abilitySettings[settingKey].delay = num
                    MacroIO.saveAutoAbilitySettings()
                end,
            })

            local waveSlider = AutoAbilityTab:CreateSlider({
                Name = "Use on Wave (if 'On Wave' selected)",
                Range = { 1, 300 },
                Increment = 1,
                CurrentValue = abilitySettings[settingKey].wave,  -- read from saved
                Callback = function(Value)
                    abilitySettings[settingKey].wave = Value
                    MacroIO.saveAutoAbilitySettings()
                end,
            })

            AutoAbilityTab:CreateInput({
                Name = "Use on Wave (if 'On Wave' selected)",
                PlaceholderText = "1 - 300",
                RemoveTextAfterFocusLost = true,
                Callback = function(Text)
                    local num = tonumber(Text)
                    if not num then return end
                    num = math.clamp(num, 1, 300)
                    waveSlider:Set(num)
                    abilitySettings[settingKey].wave = num
                    MacroIO.saveAutoAbilitySettings()
                end,
            })
        end
    end
end

-- Build UI on load
task.spawn(function()
    Knit.OnStart():await()
    
    local timeout = 0
    while not DataController and timeout < 20 do
        task.wait(0.5)
        timeout = timeout + 1
    end
    
    if not DataController then
        warn("DataController never loaded - can't build ability UI")
        return
    end
    
    task.wait(1)
    buildAutoAbilityUI()
end)

task.spawn(function()
    while not PlacedTowerController do
        task.wait(0.5)
    end
    print("PlacedTowerController ready!")

    while true do
        task.wait(0.5)

        if not AutoAbility.enabled then continue end
        if not gameInProgress then continue end
        if not PlacedTowerController then continue end

        local towers = PlacedTowerController:GetTowers()
        local count = 0
        for _ in pairs(towers) do count = count + 1 end
        if not towers then continue end

        local currentWave = workspace:GetAttribute("Wave") or 0

        for guid, towerData in pairs(towers) do
            local owner = PlacedTowerController:GetOwner(guid)
            if not owner or owner ~= Services.Players.LocalPlayer then continue end
            local unitId = towerData.TowerID
            if not unitId then continue end
            local cleanId = Util.cleanUnitName(unitId)

            -- Get all abilities via controller, not model
            local allAbilities = PlacedTowerController:GetAllAbilities(guid)
            if not allAbilities then continue end

            for abilityIndex, _ in pairs(allAbilities) do
                local abilityInfo = PlacedTowerController:GetAbility(guid, abilityIndex)
                if not abilityInfo then continue end

                -- GetAbilityData returns the ability table - check what field has the name
                local abilityName = abilityInfo.Name or abilityInfo.Title or tostring(abilityIndex)
                local settingKey = cleanId .. "_" .. abilityName
                local settings = abilitySettings[settingKey]

                if not settings or settings.mode == "Disabled" then continue end

                -- Use controller's built-in cooldown tracking
                local lastUsed = PlacedTowerController:GetLastAbilityUse(guid, abilityIndex)
                local cooldown = abilityInfo.Cooldown or 60
                -- GetLastAbilityUse returns elapsed time since last use
                local isReady = (lastUsed == nil) or (lastUsed >= cooldown)

                if not isReady then continue end

                if abilityInfo.Global and abilityName then
                    if PlacedTowerController:IsGlobalCooldownActive(abilityName) then
                        continue
                    end
                end

                local function fireAbility()
                    -- If Shenron wish UI is already open, just click the right card button
                    if abilityInfo.Name == "ShenronSummon" then
                        local playerGui = Services.Players.LocalPlayer.PlayerGui
                        local pathsGui = playerGui:FindFirstChild("GameUI")
                            and playerGui.GameUI:FindFirstChild("PathsBulma")
                        
                        if pathsGui and pathsGui.Enabled then
                            local wishMap = { Wealth = 1, Power = 2, Knowledge = 3 }
                            local wish = abilitySettings[settingKey].shanglongWish or "Wealth"
                            local wishIndex = tostring(wishMap[wish] or 1)
                            pcall(function()
                                local card = pathsGui.PathSelection.Cards[wishIndex]
                                for _, connection in pairs(getconnections(card.ImageButton.Activated)) do
                                    connection:Fire()
                                end
                            end)
                            return
                        end
                    end

                    local success = pcall(function()
                        game:GetService("ReplicatedStorage")
                            .Packages._Index["sleitnick_knit@1.7.0"]
                            .knit.Services.TowerService.RE.UseAbility
                            :FireServer(guid, abilityIndex, nil)
                    end)
                    if success and abilityInfo.Name == "ShenronSummon" then
                        local wishMap = { Wealth = 1, Power = 2, Knowledge = 3 }
                        local wish = abilitySettings[settingKey].shanglongWish or "Wealth"
                        local wishIndex = tostring(wishMap[wish] or 1)
                        task.spawn(function()
                            local deadline = tick() + 10
                            local playerGui = Services.Players.LocalPlayer.PlayerGui
                            while tick() < deadline do
                                local pathsGui = playerGui:FindFirstChild("GameUI")
                                    and playerGui.GameUI:FindFirstChild("PathsBulma")
                                if pathsGui and pathsGui.Enabled then
                                    task.wait(0.3)
                                    pcall(function()
                                        local card = pathsGui.PathSelection.Cards[wishIndex]
                                        for _, connection in pairs(getconnections(card.ImageButton.Activated)) do
                                            connection:Fire()
                                        end
                                    end)
                                    break
                                end
                                task.wait(0.2)
                            end
                        end)
                    end
                end
                local delaySeconds = settings.delay or 0
                local function fireWithDelay(onFire)
                    if delaySeconds > 0 then
                        task.spawn(function()
                            task.wait(delaySeconds)
                            local mf = workspace:GetAttribute("MatchFinished")
                            if isPlaybackEnabled or gameInProgress and not mf then
                                onFire()
                            end
                        end)
                    else
                        onFire()
                    end
                end

                if settings.mode == "Auto (Always)" then
                    fireWithDelay(fireAbility)
                elseif settings.mode == "On Wave" then
                    local targetWave = settings.wave or 1
                    local waveKey = guid .. "_" .. abilityIndex .. "_wave_" .. targetWave
                    if currentWave >= targetWave and not abilityUsedOnWave[waveKey] then
                        abilityUsedOnWave[waveKey] = true
                        fireWithDelay(fireAbility)
                    end
                elseif settings.mode == "On Boss" then
                    if bossSpawnedThisWave then
                        local bossKey = guid .. "_" .. abilityIndex .. "_boss_" .. currentWave
                        if not bossAbilityFiredKeys[bossKey] then
                            bossAbilityFiredKeys[bossKey] = true
                            fireWithDelay(fireAbility)
                        end
                    end
                end
            end
        end
    end
end)

-- Reset tracking on game restart
workspace:GetAttributeChangedSignal("Wave"):Connect(function()
    local wave = workspace:GetAttribute("Wave") or 0
    if wave <= 1 then
        abilityUsedOnWave = {}
        bossAbilityFiredKeys = {}
    end
    bossSpawnedThisWave = false
end)

WebhookInput = WebhookTab:CreateInput({
    Name = "Input Webhook", CurrentValue = "", PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false, Flag = "WebhookInput",
    Callback = function(Text)
        local trimmed = Text:match("^%s*(.-)%s*$")
        if trimmed == "" then ValidWebhook = nil return end
        ValidWebhook = trimmed:match("^https://") and trimmed or nil
    end,
})

UserIDInput = WebhookTab:CreateInput({
    Name = "Input Discord ID (mention rares)", CurrentValue = "", PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false, Flag = "WebhookInputUserID",
    Callback = function(Text) Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$") end,
})

WebhookToggle = WebhookTab:CreateToggle({
    Name = "Send On Stage Finished", CurrentValue = false, Flag = "SendWebhookOnStageFinished",
    Callback = function(Value) State.SendStageCompletedWebhook = Value end,
})
 
WebhookToggle = WebhookTab:CreateToggle({
    Name = "Send On Match Restarted", CurrentValue = false, Flag = "SendWebhookOnMatchRestarted",
    Callback = function(Value) State.SendMatchRestartedWebhook = Value end,
})
 
TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then Webhook.send("test")
        else Util.notify(nil, "Error: No webhook URL set!") end
    end,
})

workspace:GetAttributeChangedSignal("Wave"):Connect(function()
    local wave = workspace:GetAttribute("Wave") or 0
    if wave == 1 then
        restartDisabled = false
    end
    if wave < lastWave then
        if State.SendMatchRestartedWebhook and not hasRecentlyRestarted then
            Webhook.send("match_restart", nil, currentGameInfo, lastWave)
        end
        hasRecentlyRestarted = true
        if gameInProgress then gameInProgress = false autoPlayUsedPositions = {} gameStartTime = 0 end
        if isRecording and recordingHasStarted then
            local actionCount = #macro
            GameState.stopRecording()
            Util.notify({ Title = "Recording Stopped", Content = string.format("Game restarted - saved %d actions", actionCount), Duration = 3 })
            RecordToggle:Set(false)
        end
        if isRecording then
            recordingHasStarted = false
            macro = {}
            UnitTracker.clearSpawnIdMappings()
            Util.updateMacroStatus("Recording enabled - Waiting for wave 1...")
        end
        if isPlaybackEnabled and playbackLoopRunning then
            gameInProgress = false
            autoPlayUsedPositions = {}
            gameStartTime = 0
            UnitTracker.clearSpawnIdMappings()
            Util.updateMacroStatus("Game restarted - waiting for wave 1...")
        end
        lastWave = 0
        iceGiftsBefore = 0
        task.spawn(function() task.wait(2) hasRecentlyRestarted = false end)
        return
    end
    lastWave = wave
    if wave >= 1 and not gameInProgress then
        gameInProgress = true
        gameStartTime = tick()
        autoPlayUsedPositions = {}
            if State.AutoPlayEnableAutoPlace then
            Autoplay.stopAutoPlace()
            task.wait(0.5)
            Autoplay.startAutoPlace()
        end
        if State.AutoPlayEnableAutoUpgrade then
            Autoplay.startAutoUpgrade()
        end
        currentGameInfo = {
            MapName = workspace:GetAttribute("MapName") or "Unknown",
            Act = workspace:GetAttribute("ActName") or "Unknown",
            Category = workspace:GetAttribute("DifficultyName") or "Unknown",
            StartTime = tick()
        }
        task.spawn(function()
            local timeout = 0
            while not RequestData and timeout < 20 do task.wait(0.5) timeout = timeout + 1 end
            if RequestData then
                beforeRewardData = Util.deepCopy(RequestData:InvokeServer())
            end
        end)
        iceGiftsBefore = Services.Players.LocalPlayer:GetAttribute("IceGifts") or 0
        if isRecording and not recordingHasStarted then
            recordingHasStarted = true
            gameStartTime = tick()
            recordingUnitCounter = {}
            recordingUUIDToTag = {}
            macro = {}
            UnitTracker.startUpgradePolling()
            Util.updateMacroStatus("Recording...")
            Util.updateDetailedStatus("Recording in progress - " .. currentMacroName)
            Util.notify({ Title = "Recording Started", Content = string.format("Wave %d detected - recording: %s", wave, currentMacroName), Duration = 3 })
        end
    end
end)

workspace:GetAttributeChangedSignal("MatchFinished"):Connect(function()
    local matchFinished = workspace:GetAttribute("MatchFinished")
    if matchFinished and gameInProgress then
        local deadline = tick() + 5
        while (lastMatchResult == nil or finishedRewardData == nil) and tick() < deadline do
            task.wait(0.1)
        end
        afterRewardData = Util.deepCopy(RequestData:InvokeServer())
        State.sessionRuns = State.sessionRuns + 1
        updateQueueOnTeleport()
        if State.SendStageCompletedWebhook then
            local gameResult = lastMatchResult == "Won"
            local gameDuration = "Unknown"
            if currentGameInfo.StartTime then
                local duration = tick() - currentGameInfo.StartTime
                gameDuration = string.format("%dm %ds", math.floor(duration / 60), math.floor(duration % 60))
            end
            Webhook.send("game_end", gameResult, currentGameInfo, gameDuration)
        end
        iceGiftsBefore = 0
        gameInProgress = false
        autoPlayUsedPositions = {}

            if State.ReturnToLobbyAfterMatches and State.ReturnToLobbyAfterMatches > 0 then
            State.matchesPlayed = (State.matchesPlayed or 0) + 1
            Util.notify({ Title = "Match Tracked", Content = string.format("%d/%d matches", State.matchesPlayed, State.ReturnToLobbyAfterMatches), Duration = 3 })
            if State.matchesPlayed >= State.ReturnToLobbyAfterMatches then
                State.matchesPlayed = 0
                task.wait(1)
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
                end)
                Util.notify({ Title = "Returning to Lobby", Content = "Match limit reached", Duration = 4 })
            end
        end


        if State.ReturnToLobbyAfterLosses and State.ReturnToLobbyAfterLosses > 0 then
        if lastMatchResult == "Lost" then
            consecutiveLosses = consecutiveLosses + 1
            Util.notify({ Title = "Loss Tracked", Content = string.format("%d/%d losses", consecutiveLosses, State.ReturnToLobbyAfterLosses), Duration = 3 })
            if consecutiveLosses >= State.ReturnToLobbyAfterLosses then
                consecutiveLosses = 0
                task.wait(1)
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
                end)
                Util.notify({ Title = "Returning to Lobby", Content = "Loss limit reached", Duration = 4 })
            end
        else
            consecutiveLosses = 0 -- reset on win
        end
    end
        lastMatchResult = nil
        gameStartTime = 0
        lastWave = 0
        if isPlaybackEnabled then UnitTracker.clearSpawnIdMappings() end
        if isRecording and recordingHasStarted then
            local actionCount = #macro
            GameState.stopRecording()
            Util.notify({ Title = "Recording Auto-Stopped", Content = string.format("Saved %d actions to %s", actionCount, currentMacroName), Duration = 4 })
            RecordToggle:Set(false)
            recordingHasStarted = false
        end
        if isPlaybackEnabled then
            UnitTracker.clearSpawnIdMappings()
            Util.updateMacroStatus("Game ended - waiting for next game...")
        end
        if not isRecording and not isPlaybackEnabled then
            Util.updateMacroStatus("Ready")
            Util.updateDetailedStatus("Ready")
        end
    end
end)

task.spawn(function()
    local lastProcessedWave = nil
    while true do
        task.wait(0.5)
        if not State.AutoEquipBeforeGame then continue end
        if not isPlaybackEnabled then continue end
        if Util.isInLobby() then continue end

        local currentWave = workspace:GetAttribute("Wave") or 0
        local matchFinished = workspace:GetAttribute("MatchFinished")

        -- Only act on wave 0 (pre-game) and only once per session
        if currentWave == 0 and not matchFinished and lastProcessedWave ~= 0 then
            lastProcessedWave = 0
            if not State.AutoStartGame then
            task.spawn(autoEquipMacroUnits)
            end
        end

        -- Reset when a new game cycle begins
        if currentWave >= 1 then
            lastProcessedWave = currentWave
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoStartGame then
            local currentWave = workspace:GetAttribute("Wave") or 0
            if currentWave == 0 then
                local deadline = tick() + 10
                while (not workspace:GetAttribute("Category") or not workspace:GetAttribute("MapName")) and tick() < deadline do
                    task.wait(0.5)
                end
                    if isPlaybackEnabled then Playback.checkAndSwitchMacroForCurrentWorld() task.wait(0.5) end

                    -- Wait for auto equip to finish before starting
                    if State.AutoEquipBeforeGame and isPlaybackEnabled then
                        local equipDone = false
                        task.spawn(function()
                            autoEquipMacroUnits()
                            equipDone = true
                        end)
                        local waitStart = tick()
                        while not equipDone and tick() - waitStart < 15 do
                            task.wait(0.5)
                        end
                        if not equipDone then
                            Util.notify({ Title = "Auto Start", Content = "Equip timed out, starting anyway", Duration = 3 })
                        end
                    end

                    task.wait(2)
                    local success = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RF"):WaitForChild("Vote"):InvokeServer(true)
                    local skipButton = Services.Players.LocalPlayer.PlayerGui.GameUI.HUD.Vote.Button.TextButton
                    for _, startConn in pairs(getconnections(skipButton.MouseButton1Up)) do
                        if startConn.Enabled then startConn:Fire() end
                    end
                end)
                if success then
                    Util.notify({ Title = "Auto Start", Content = "Voting to start game...", Duration = 2 })
                    task.wait(5)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        AutoJoin.checkAndExecuteHighestPriority()
    end
end)

task.spawn(function()
    local timeout = 0
    while not Util.isGameDataLoaded() and timeout < 20 do task.wait(0.5) timeout = timeout + 1 end
    if Util.isGameDataLoaded() then Loader.buildMapLookup() end
end)

task.spawn(function()
    local lastCheckMinute = -1
    while true do
        task.wait(5)
        if State.ReturnToLobbyOnNewChallenge then
            local currentTime = os.date("*t")
            local currentMinute = currentTime.min
            if (currentMinute == 0 or currentMinute == 30) and currentMinute ~= lastCheckMinute then
                lastCheckMinute = currentMinute
                if Services.Workspace:GetAttribute("MatchFinished") then
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService", 10):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
                end
                State.NewChallengesAvailable = true
                Util.notify({ Title = "New Challenges Available", Content = "Will return to lobby when game ends", Duration = 4 })
            end
            if currentMinute > 1 and currentMinute < 30 then lastCheckMinute = -1
            elseif currentMinute > 31 then lastCheckMinute = -1 end
        else
            lastCheckMinute = -1
            State.NewChallengesAvailable = false
        end
    end
end)

task.spawn(function()
    local ok, EnemyNetwork = pcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("Network", 10):WaitForChild("Enemy", 10))
    end)
    if not ok or not EnemyNetwork then
        warn("Failed to find Enemy network")
        return
    end

    EnemyNetwork.CreateEnemy.listen(function(data)
        local enemyModule = game:GetService("ReplicatedStorage").Shared.Data.Enemies:FindFirstChild(data.EnemyID)
        if not enemyModule then return end
        local moduleOk, enemyData = pcall(require, enemyModule)
        if not moduleOk or not enemyData then return end
        if enemyData.Status and enemyData.Status.Boss then
            bossSpawnedThisWave = true
            print(string.format("Boss: %s (%s)", data.EnemyID, tostring(data.EnemyGUID)))
        end
    end)
end)

task.spawn(function()
    -- Wait for MapName to settle
    local deadline = tick() + 30
    while (not workspace:GetAttribute("MapName") or workspace:GetAttribute("MapName") == "") and tick() < deadline do
        task.wait(0.5)
    end

    -- Wait for macros to be loaded from disk
    local macrodeadline = tick() + 10
    while not next(macroManager) and tick() < macrodeadline do
        task.wait(0.5)
    end

    local mapName = workspace:GetAttribute("MapName")
    if not mapName or Util.isInLobby() then return end

    local worldKey = Util.getCurrentWorldKey()
    if not worldKey then return end

    local mappedMacro = worldMacroMappings[worldKey]
    if not mappedMacro or mappedMacro == "" or mappedMacro == "None" then return end

    local loadedMacro = macroManager[mappedMacro] or MacroIO.load(mappedMacro)
    if not loadedMacro or #loadedMacro == 0 then
        Util.notify({ Title = "Macro Error", Content = string.format("'%s' is empty or missing", mappedMacro), Duration = 4 })
        return
    end

    macroManager[mappedMacro] = loadedMacro
    macro = loadedMacro
    currentMacroName = mappedMacro
    MacroDropdown:Set(mappedMacro)

    Util.notify({ Title = "Macro Ready", Content = string.format("%s (%d actions)", mappedMacro, #loadedMacro), Duration = 4 })
end)

task.spawn(function()
    while true do
        while not workspace:GetAttribute("MatchFinished") do task.wait(0.5) end
        task.wait(1)
        if forcedLobbyReturn then
            forcedLobbyReturn = false
        else
            if State.NewChallengesAvailable and State.ReturnToLobbyOnNewChallenge then
                local success = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5):WaitForChild("ToLobby", 5):FireServer()
                end)
                if success then
                    Util.notify({ Title = "Returned to Lobby", Content = "Ready to join new challenges", Duration = 3 })
                    State.NewChallengesAvailable = false
                end
            else
                local actions = {}
                if State.AutoRetry then table.insert(actions, "retry") end
                if State.AutoNext then table.insert(actions, "next") end
                if State.AutoLobby then table.insert(actions, "lobby") end

                if #actions > 0 then
                    for _, action in ipairs(actions) do
                        local actionWorked = false
                        local maxAttempts = 3

                        for attempt = 1, maxAttempts do
                            local success = false
                            local remoteExists = false

                            if action == "retry" then
                                success, remoteExists = pcall(function()
                                    local service = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5)
                                    local remote = service:FindFirstChild("VoteReplay")
                                    if remote then remote:FireServer() return true else return false end
                                end)
                                if success and remoteExists then
                                    Util.notify({ Title = "Auto Retry", Content = string.format("Voting for Replay (attempt %d)...", attempt), Duration = 2 })
                                elseif not remoteExists then
                                    break
                                end
                            elseif action == "next" then
                                success, remoteExists = pcall(function()
                                    local service = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5)
                                    local remote = service:FindFirstChild("NextMap")
                                    if remote then remote:FireServer() return true else return false end
                                end)
                                if success and remoteExists then
                                    Util.notify({ Title = "Auto Next", Content = string.format("Voting for Next Stage (attempt %d)...", attempt), Duration = 2 })
                                elseif not remoteExists then
                                    break
                                end
                            elseif action == "lobby" then
                                success = pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5):WaitForChild("ToLobby", 5):FireServer()
                                end)
                                if success then
                                    Util.notify({ Title = "Auto Lobby", Content = "Returning to Lobby...", Duration = 2 })
                                    actionWorked = true
                                end
                                break
                            end

                            if remoteExists or action == "lobby" then
                                local waitStart = tick()
                                while tick() - waitStart < 10 do
                                    if not workspace:GetAttribute("MatchFinished") then
                                        actionWorked = true
                                        break
                                    end
                                    task.wait(0.5)
                                end
                                if actionWorked then break end
                                if attempt < maxAttempts then task.wait(1) end
                            end
                        end

                        if actionWorked then
                            break
                        else
                            if action ~= "lobby" then
                                Util.notify({ Title = "Fallback", Content = string.format("%s failed, trying next option...", action), Duration = 3 })
                            end
                        end
                    end
                end
            end
        end
        while workspace:GetAttribute("MatchFinished") do task.wait(0.5) end
    end
end)

MacroIO.ensureFolders()
MacroIO.loadAll()
worldMacroMappings = MacroIO.loadWorldMappings()
MacroDropdown:Refresh(MacroIO.getList())

task.spawn(Loader.storyStages)
task.spawn(Loader.legendStages)
task.spawn(Loader.virtualStages)
task.spawn(Loader.challengeModifiers)
task.spawn(Loader.raidStages)
task.spawn(Loader.portalItems)
task.spawn(MacroIO.loadAutoPlayPositions)

task.spawn(function()
    task.wait(2)
    createAutoSelectDropdowns()
end)

task.spawn(function()
    task.wait(2)
    local ok, ViewReward = pcall(require, game:GetService("ReplicatedStorage").Client.UiComponents.ViewReward)
    if not ok then warn("Failed:", ViewReward) return end

    local upvalues = getupvalues(ViewReward)
    for i, v in pairs(upvalues) do
        if type(v) == "table" and v.ClickContinue and v.Deactivate and v.Activate then
            local function autoContinue(self)
                self.CanNext = true
                -- Clean up character particles
                if self.OpenParticles and self.OpenParticles.Parent then
                    self.OpenParticles:Destroy()
                end
                pcall(function()
                    local character = game:GetService("Players").LocalPlayer.Character
                    if character then
                        for _, obj in pairs(character:GetChildren()) do
                            if obj.Name == "OpenParticles" then obj:Destroy() end
                        end
                    end
                end)
                -- Clean up camera VFX
                if self.ClonedEnableVFX and self.ClonedEnableVFX.Parent then
                    self.ClonedEnableVFX:Destroy()
                end
                if self.ClonedEmitVFX and self.ClonedEmitVFX.Parent then
                    self.ClonedEmitVFX:Destroy()
                end
                -- Fallback: nuke everything in Camera named after a rarity
                pcall(function()
                    for _, obj in pairs(workspace.CurrentCamera:GetChildren()) do
                        if obj.Name == "Exclusive" or obj.Name == "Secret" or obj.Name == "Mythic" or obj.Name == "Legendary" or obj.Name == "Rare" 
                        or obj.Name == "Epic" or obj.Name == "Common" or obj.Name == "Uncommon" then
                            obj:Destroy()
                        end
                    end
                end)
            end
            v.ClickContinue = autoContinue
            v.AutoContinue = autoContinue
            v.TapContinue = autoContinue
            -- patch any other *Continue methods
            for key, val in pairs(v) do
                if type(key) == "string" and key:find("Continue") and type(val) == "function" then
                    v[key] = autoContinue
                end
            end
            print("Patched")
            break
        end
    end
end)

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

task.spawn(function()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RayfieldToggle"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	if gethui then
		screenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(screenGui)
		screenGui.Parent = Services.CoreGui
	elseif Services.CoreGui:FindFirstChild("RobloxGui") then
		screenGui.Parent = Services.CoreGui:FindFirstChild("RobloxGui")
	else
		screenGui.Parent = Services.CoreGui
	end

	local toggleButton = Instance.new("ImageButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Parent = screenGui
	toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	toggleButton.BorderSizePixel = 0
	toggleButton.Position = UDim2.new(0, 50, 0, 50)
	toggleButton.Size = UDim2.new(0, 50, 0, 50)
	toggleButton.Image = "rbxassetid://139436994731049"
	toggleButton.ScaleType = Enum.ScaleType.Fit
	toggleButton.ImageTransparency = 0
	toggleButton.BackgroundTransparency = 0
	toggleButton.ZIndex = 10000

	-- ✂ No `corner` local — parent via second arg, set CornerRadius in one line
	Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

	local shadow = Instance.new("ImageLabel", toggleButton) -- ✂ No separate .Parent line
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.ZIndex = toggleButton.ZIndex - 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)

	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	toggleButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = toggleButton.Position

			-- ✂ No `connection` local — disconnect inside Changed directly
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	toggleButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	-- ✂ `update()` function eliminated — logic inlined here directly
	Services.UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			toggleButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + (input.Position.X - dragStart.X),
				startPos.Y.Scale,
				startPos.Y.Offset + (input.Position.Y - dragStart.Y)
			)
		end
	end)

	local clickStartPos, clickStartTime = nil, 0

	toggleButton.MouseButton1Down:Connect(function()
		clickStartPos = toggleButton.Position
		clickStartTime = tick()
	end)

	toggleButton.MouseButton1Up:Connect(function()
		if clickStartPos then
			-- ✂ No `timeDelta`/`positionDelta`/`moveDistance` locals — all inlined
			if (tick() - clickStartTime) < 0.2 and
				math.sqrt(
					(toggleButton.Position.X.Offset - clickStartPos.X.Offset)^2 +
					(toggleButton.Position.Y.Offset - clickStartPos.Y.Offset)^2
				) < 5 then
					if Rayfield:IsVisible() then
						Rayfield:SetVisibility(false)
					else
						Rayfield:SetVisibility(true)
					end
			end
		end
		clickStartPos = nil
	end)

	toggleButton.MouseEnter:Connect(function()
		Services.TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 55, 0, 55),
			BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		}):Play()
	end)

	toggleButton.MouseLeave:Connect(function()
		Services.TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 50, 0, 50),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		}):Play()
	end)
end)

task.spawn(function()
    task.wait(2)
    local savedMacroName = Rayfield.Flags["MacroDropdown"]
    if type(savedMacroName) == "table" then savedMacroName = savedMacroName[1] end
    if savedMacroName and savedMacroName ~= "" and type(savedMacroName) == "string" then
        currentMacroName = savedMacroName
        local loadedMacro = MacroIO.load(currentMacroName)
        if loadedMacro then
            macro = loadedMacro
            macroManager[currentMacroName] = loadedMacro
        end
    end
    MacroDropdown:Refresh(MacroIO.getList())
end)
