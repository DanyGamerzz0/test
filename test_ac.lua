   if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()
    end)

    if not success then
        warn("Failed to load Rayfield UI library:", Rayfield)
        return
    end

    if not Rayfield then
        warn("Rayfield library returned nil - check if the URL is accessible")
        return
    end

    local script_version = "V0.25"

    local Window = Rayfield:CreateWindow({
    Name = "LixHub - Anime Crusaders",
    Icon = 0,
    LoadingTitle = "Loading for Anime Crusaders",
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
        FileName = "Lixhub_AC"
    },
    Discord = {
        Enabled = true,
        Invite = "cYKnXE2Nf8",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "LixHub - AC - Free",
        Subtitle = "LixHub - Key System",
        Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
        FileName = "LixHub_Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"0xLIXHUB"}
    }
    })

    -- ========== SERVICES ==========
    local Services = {
        HttpService = game:GetService("HttpService"),
        Players = game:GetService("Players"),
        TeleportService = game:GetService("TeleportService"),
        Lighting = game:GetService("Lighting"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        Workspace = game:GetService("Workspace"),
        VIRTUAL_USER = game:GetService("VirtualUser"),
    }

    -- ========== MACRO SYSTEM CONFIGURATION ==========
    local MACRO_CONFIG = {
        SPAWN_REMOTE = "spawn_unit",
        UPGRADE_REMOTE = "upgrade_unit_ingame", 
        SELL_REMOTE = "sell_unit_ingame",
        WAVE_SKIP_REMOTE = "vote_wave_skip",
        PLACEMENT_WAIT_TIME = 0.3, -- Reduced from 1.5s to 0.3s for normal operations
        SNAPSHOT_WAIT_TIME = 0.1,  -- Reduced from 0.5s to 0.1s
    }

    local loadingRetries = {
        story = 0,
        legend = 0,
        raid = 0,
        ignoreWorlds = 0,
        portal = 0
    }

    local totalActions = 0
    local detailedStatusLabel = nil

    local maxRetries = 20 -- Maximum number of retry attempts
    local retryDelay = 2 -- Seconds between retries

    -- ========== MACRO SYSTEM CORE ==========
local macro = {}
local macroManager = {}
local currentMacroName = ""
local isRecording = false
local isPlaybacking = false
local isRecordingLoopRunning = false
local recordingHasStarted = false
local currentChallenge = nil
local macroHasPlayedThisGame = false
local trackedUnits = {}
local recordingSpawnIdToPlacement = {} -- spawn_id -> "Shadow #1"
local recordingPlacementCounter = {} -- "Shadow" -> 3 (how many placed so far)
local recordingUnitNameToSpawnId = {}

local playbackPlacementToSpawnId = {} -- "Shadow #1" -> current spawn_id

local playbackDisplayNameInstances = {}

    local VALIDATION_CONFIG = {
        PLACEMENT_MAX_RETRIES = 3,
        UPGRADE_MAX_RETRIES = 3,
        PLACEMENT_TIMEOUT = 5.0,    -- Reduced from 10.0s to 5.0s
        UPGRADE_TIMEOUT = 4.0,      -- Reduced from 8.0s to 4.0s
        VALIDATION_CHECK_INTERVAL = 0.1, -- Reduced from 0.2s to 0.1s
        RETRY_DELAY = 0.5,         -- Keep retry delay as is - this is when something went wrong
        NORMAL_VALIDATION_TIME = 0.3, -- New: Quick validation time for normal operations
        EXTENDED_VALIDATION_TIME = 1.0, -- New: Longer validation for retries
    }

    local isAutoLoopEnabled = false
    local gameHasEnded = false

    local worldMacroMappings = {} -- Format: {worldKey = macroName}
    local worldDropdowns = {}

    -- ========== EXISTING VARIABLES (keep all your existing variables) ==========
    local gameInProgress = false
    local sessionItems = {}
    local gameStartTime = 0
    local lastWave = 0
    local startStats = {}
    local endStats = {}
    local currentMapName = "Unknown Map"
    local gameResult = "Unknown"
    local itemNameCache = {}
    local storedPortalData = nil

    local Config = {
        DISCORD_USER_ID = nil,
    }

    local AutoJoinState = {
        isProcessing = false,
        currentAction = nil,
        lastActionTime = 0,
        actionCooldown = 2
    }

    local State = {
        SendStageCompletedWebhook = false,
        StoryStageSelected = nil,
        StoryStageMapping = nil,
        StoryActSelected = nil,
        StoryDifficultySelected = nil,
        AutoJoinStory = false,
        AutoJoinLegendStage = false,
        LegendStageSelected = nil,
        LegendActSelected = nil,
        AutoVoteRetry = false,
        AutoVoteNext = false,
        AutoVoteLobby = false,
        AntiAfkKickEnabled = false,
        enableLowPerformanceMode = false,
        enableBlackScreen = false,
        enableAutoExecute = false,
        enableLimitFPS = false,
        streamerModeEnabled = false,
        SelectedFPS = 0,
        RaidStageSelected = nil,
        RaidActSelected = nil,
        AutoJoinRaid = false,
        AutoJoinChallenge = false,
        ChallengeRewardsFilter = {},
        IgnoreWorlds = {},
        ReturnToLobbyOnNewChallenge = false,
        NewChallengeDetected = false,
        AutoJoinGate = false,
        AvoidGateTypes = {},
        AvoidModifiers = {},
        IgnoreTiming = false,
        AutoNextGate = false,
        AutoSelectMacro = false,
        AutoVoteStart = false,
        deleteEntities = false,
        AutoSkipWaves = false,
        AutoSkipUntilWave = 0,
        RandomOffsetEnabled = false,
        RandomOffsetAmount = 0.5,
        AutoSellEnabled = false,
        AutoSellWave = 10,
        AutoSellFarmEnabled = false,
        AutoSellFarmWave = 15,
        ReturnToLobbyFailsafe = false,
        failsafeActive = false,
        AutoMatchmakeLegendStage = false,
        AutoMatchmakeRaidStage = false,
        AutoMatchmakeGateStage = false,
        AutoJoinPortal = false,
        SelectedPortal = {},
        AutoNextPortal = false,
        AutoJoinSpiritInvasion = false,
        AutoMatchmakeSpiritInvasion = false,
        AutoJoinHalloween = false,
        AutoMatchmakeHalloween = false,
        AutoSelectCard = false,
        AutoEquipMacroUnits = false,
        challengeJoinAttempts = 0,
        maxChallengeAttempts = 3,
        AutoNextInfinityCastle = false,
        AutoJoinInfinityCastle = false,
        AutoAbility = false,
        PrioritizeFarmUnits = false,
        AutoUpgrade = false,
        AutoJoinBossRush = false,
        AutoJoinBossRushSelectionMode = false,
        CardPriority = {["Enemy Shield"] = {tier1 = 0, tier2 = 0, tier3 = 0},["Enemy Health"] = {tier1 = 0, tier2 = 0, tier3 = 0},["Enemy Speed"] = {tier1 = 0, tier2 = 0, tier3 = 0},["Damage"] = {tier1 = 0, tier2 = 0, tier3 = 0},["Cooldown"] = {tier1 = 0, tier2 = 0, tier3 = 0},["Range"] = {tier1 = 0, tier2 = 0, tier3 = 0}},
        AutoSelectPortalReward = false,
        PortalRewardTierFilter = {},
    }


    local currentCardData = nil

    -- ========== CREATE TABS ==========
    local LobbyTab = Window:CreateTab("Lobby", "tv")
    local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
    local CardPriorityTab = Window:CreateTab("Auto Pick Card", "award")
    local GameTab = Window:CreateTab("Game", "gamepad-2")
    local MacroTab = Window:CreateTab("Macro", "joystick")
    local AutoplayTab = Window:CreateTab("Autoplay", "joystick")
    local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

    -- ========== MACRO SYSTEM FUNCTIONS ==========

    local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
        })
    end

local function clearSpawnIdMappings()
    recordingSpawnIdToPlacement = {}
    recordingPlacementCounter = {}
    recordingUnitNameToSpawnId = {}
    playbackPlacementToSpawnId = {}
end

    -- Utility Functions
    local function getLocalPlayer()
        return Services.Players.LocalPlayer
    end

    local function getUnitOwner(unit)
        local stats = unit:FindFirstChild("_stats")
        if not stats then return nil end
        
        local playerValue = stats:FindFirstChild("player")
        if not playerValue or not playerValue:IsA("ObjectValue") then return nil end
        
        return playerValue.Value
    end

local function isOwnedByLocalPlayer(unit)
    local owner = getUnitOwner(unit)
    if owner ~= getLocalPlayer() then
        return false
    end
    
    local stats = unit:FindFirstChild("_stats")
    if stats then
        local parentUnit = stats:FindFirstChild("Parent_unit")
        if parentUnit then
            return false -- This is a summon, not a direct player unit
        end
    end
    
    return true
end

    local function takeUnitsSnapshot()
        local snapshot = {}
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        
        if not unitsFolder then 
            warn("_UNITS folder not found in workspace")
            return snapshot 
        end
        
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if isOwnedByLocalPlayer(unit) then
                local unitData = {
                    instance = unit,
                    name = unit.Name,
                    spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID"),
                    position = unit.PrimaryPart and unit.PrimaryPart.Position or 
                            unit:FindFirstChildWhichIsA("BasePart") and unit:FindFirstChildWhichIsA("BasePart").Position,
                    owner = getUnitOwner(unit)
                }
                
                if unitData.position and unitData.spawnUUID then
                    table.insert(snapshot, unitData)
                end
                end
            end
        print(string.format("Snapshot taken: %d player-owned units found", #snapshot))
        return snapshot
    end

    local function findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
        local beforeUUIDs = {}
        for _, unitData in pairs(beforeSnapshot) do
            if unitData.spawnUUID then
                beforeUUIDs[tostring(unitData.spawnUUID)] = true
            end
        end
        
        local newUnits = {}
        for _, unitData in pairs(afterSnapshot) do
            if unitData.spawnUUID and not beforeUUIDs[tostring(unitData.spawnUUID)] then
                table.insert(newUnits, unitData)
            end
        end
        
        if #newUnits == 0 then
            print("No new units detected")
            return nil
        elseif #newUnits == 1 then
            print(string.format("Found newly placed unit: %s (UUID: %s)", newUnits[1].name, tostring(newUnits[1].spawnUUID)))
            return newUnits[1].instance
        else
            warn(string.format("Multiple new units detected (%d), returning first one", #newUnits))
            return newUnits[1].instance
        end
    end

local function startRecordingWithSpawnIdMapping()
    table.clear(macro)
    clearSpawnIdMappings()
    trackedUnits = {}
    isRecording = true
    
    if gameStartTime == 0 then
        gameStartTime = tick()
        print("Setting game start time for recording:", gameStartTime)
    end
    
    print("Started recording with spawn ID mapping system")
end

local function clearPlaybackTrackingWithSpawnIdMapping()
    clearSpawnIdMappings() -- Clear all temporary mappings for fresh playback
end

    local function getMacroFilename(name)
        if type(name) == "table" then name = name[1] or "" end
        if type(name) ~= "string" or name == "" then return nil end
        return "LixHub/Macros/AC/" .. name .. ".json"
    end

    local function findUnitBySpawnUUID(targetUUID)
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    if not unitsFolder then return nil end
    
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if isOwnedByLocalPlayer(unit) then
            local stats = unit:FindFirstChild("_stats")
            if stats then
                local uuidValue = stats:FindFirstChild("uuid")
                if uuidValue and uuidValue:IsA("StringValue") then
                    if uuidValue.Value == targetUUID then
                        return unit
                    end
                end
            end
        end
    end
    
    return nil
end

local function getInternalSpawnName(unit)
    if not unit or not unit:FindFirstChild("_stats") then
        return nil
    end
    
    local idValue = unit._stats:FindFirstChild("id")
    if idValue and idValue:IsA("StringValue") then
        return idValue.Value
    end
    
    return nil
end

local function getDisplayNameFromUnitId(unitId)
    if not unitId then return nil end
    
    local success, displayName = pcall(function()
        local UnitsFolder = Services.ReplicatedStorage.Framework.Data.Units
        if not UnitsFolder then return nil end


        for _, moduleScript in pairs(UnitsFolder:GetDescendants()) do
            if moduleScript:IsA("ModuleScript") then
                local moduleSuccess, unitData = pcall(require, moduleScript)
                
                if moduleSuccess and unitData then
                    for unitKey, unitInfo in pairs(unitData) do
                        if type(unitInfo) == "table" and unitInfo.id == unitId and unitInfo.name then
                            return unitInfo.name
                        end
                    end
                end
            end
        end
        return nil
    end)
    return success and displayName or unitId
end

local function getUnitData(unitId)
    local success, unitData = pcall(function()
        local UnitsFolder = Services.ReplicatedStorage.Framework.Data.Units
        if not UnitsFolder then return nil end
        
        for _, moduleScript in pairs(UnitsFolder:GetDescendants()) do
            if moduleScript:IsA("ModuleScript") then
                local moduleSuccess, data = pcall(require, moduleScript)
                
                if moduleSuccess and data then
                    for unitKey, unitInfo in pairs(data) do
                        if type(unitInfo) == "table" and unitInfo.id == unitId then
                            return unitInfo
                        end
                    end
                end
            end
        end
        return nil
    end)
    
    return success and unitData or nil
end

local function getCostScale()
    local success, costScale = pcall(function()
        local levelModifiers = Services.Workspace:FindFirstChild("_DATA")
        if levelModifiers then
            levelModifiers = levelModifiers:FindFirstChild("LevelModifiers")
            if levelModifiers then
                local playerCostScale = levelModifiers:FindFirstChild("player_cost_scale")
                if playerCostScale and playerCostScale:IsA("NumberValue") then
                    return playerCostScale.Value
                end
            end
        end
        return 1.0 -- Default to normal cost if not found
    end)
    
    if success and costScale then
        if costScale ~= 1.0 then
            print("Cost scale modifier detected:", costScale)
        end
        return costScale
    else
        print("Failed to get cost scale, defaulting to 1.0")
        return 1.0
    end
end

local function getPlacementCost(unitId)
    local unitData = getUnitData(unitId)
    local baseCost = unitData and unitData.cost or 0
    local costScale = getCostScale()
    
    local finalCost = math.floor(baseCost * costScale)
    
    if costScale ~= 1.0 then
        print(string.format("Placement cost for %s: %d -> %d (x%.1f scale)", 
            unitId, baseCost, finalCost, costScale))
    end
    
    return finalCost
end


local function getUpgradeCost(unitId, currentLevel)
    local unitData = getUnitData(unitId)
    if not unitData or not unitData.upgrade then return 0 end

    local upgradeIndex = currentLevel + 1
    
    if upgradeIndex > #unitData.upgrade then
        return 0
    end
    
    local baseCost = unitData.upgrade[upgradeIndex] and unitData.upgrade[upgradeIndex].cost or 0
    local costScale = getCostScale()
    
    local finalCost = math.floor(baseCost * costScale)
    
    if costScale ~= 1.0 then
        print(string.format("Upgrade cost for %s level %d->%d: %d -> %d (x%.1f scale)", 
            unitId, currentLevel, currentLevel + 1, baseCost, finalCost, costScale))
    end
    
    return finalCost
end

local function getUnitIdFromDisplayName(displayName)
    if not displayName then return nil end
    
    local success, unitId = pcall(function()
        local UnitsFolder = Services.ReplicatedStorage.Framework.Data.Units
        if not UnitsFolder then return nil end
        
        -- Search through all unit modules
        for _, moduleScript in pairs(UnitsFolder:GetDescendants()) do
            if moduleScript:IsA("ModuleScript") then
                local moduleSuccess, unitData = pcall(require, moduleScript)
                
                if moduleSuccess and unitData then
                    -- Search through each unit in this module
                    for unitKey, unitInfo in pairs(unitData) do
                        if type(unitInfo) == "table" and unitInfo.name == displayName and unitInfo.id then
                            return unitInfo.id
                        end
                    end
                end
            end
        end
        return nil
    end)
    
    return success and unitId or displayName -- Fallback to display name if not found
end

local function resolveUUIDFromInternalName(internalName)
    if not internalName then return nil end
    
    local success, uuid = pcall(function()
        local fxCache = Services.ReplicatedStorage:FindFirstChild("_FX_CACHE")
        if not fxCache then return nil end
        
        for _, child in pairs(fxCache:GetChildren()) do
            local itemIndex = child:GetAttribute("ITEMINDEX")
            
            if itemIndex == internalName then
                -- Check if this unit is equipped using EquippedList
                local equippedList = child:FindFirstChild("EquippedList")
                if equippedList then
                    local equipped = equippedList:FindFirstChild("Equipped")
                    if equipped and equipped.Visible == true then
                        local uuidValue = child:FindFirstChild("_uuid")
                        if uuidValue and uuidValue:IsA("StringValue") then
                            print("Found EQUIPPED", internalName, "UUID:", uuidValue.Value)
                            return uuidValue.Value
                        end
                    end
                end
            end
        end
        
        print("WARNING: No equipped unit found for", internalName)
        return nil
    end)
    
    if not success then
        warn("Error resolving UUID for", internalName, ":", uuid)
        return nil
    end
    
    return uuid
end

    local function updateDetailedStatus(message)
        if detailedStatusLabel then
            detailedStatusLabel:Set("Macro Details: " .. message)
        end
        print("Macro Status: " .. message)
    end

local function saveMacroToFile(name)
    if not name or name == "" then return end
    
    local data = macroManager[name]
    if not data then return end

    -- Direct JSON encoding - no complex serialization needed
    local json = Services.HttpService:JSONEncode(data)
    local filePath = getMacroFilename(name)
    if filePath then
        writefile(filePath, json)
        print("Saved macro to file:", name, "with", #data, "actions")
    end
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not filePath or not isfile(filePath) then return nil end

    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)
    
    if type(data) == "table" and #data == 0 then
        return {}
    end
    
    local actionsArray
    if data.actions and type(data.actions) == "table" then
        actionsArray = data.actions
    elseif type(data) == "table" then
        actionsArray = data
    else
        warn("Unrecognized file format for macro:", name)
        return nil
    end

    return actionsArray
end

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

    local function getPlayerMoney()
        local player = Services.Players.LocalPlayer
        if player and player:FindFirstChild("_stats") and player._stats:FindFirstChild("resource") then
            return player._stats.resource.Value
        end
        return 0
    end

    local function getUnitUpgradeLevel(unit)
        if unit and unit:FindFirstChild("_stats") and unit._stats:FindFirstChild("upgrade") then
            return unit._stats.upgrade.Value
        end
        return 0
    end

    local function getUnitSpawnId(unit)
        if not unit then return nil end
        
        -- Try to get spawn_id from the unit's _stats
        local stats = unit:FindFirstChild("_stats")
        if stats then
            local spawnIdValue = stats:FindFirstChild("spawn_id")
            if spawnIdValue then
                return spawnIdValue.Value
            end
        end
        
        -- Fallback: try to get from _SPAWN_UNIT_UUID attribute
        local spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID")
        if spawnUUID then
            return spawnUUID
        end
        
        return nil
    end

local function processPlacementActionWithSpawnIdMapping(actionInfo)

    local beforeSnapshot = actionInfo.preActionUnits or takeUnitsSnapshot()
    
    task.wait(0.3) -- Wait for unit to spawn

    local afterSnapshot = takeUnitsSnapshot()
    
    local spawnedUnit = findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
    if not spawnedUnit then
        warn("Could not find newly placed unit")
        Rayfield:Notify({Title = "Macro Recorder",Content = "Could not find newly placed unit",Duration = 3,Image = 4483362458})
        return
    end
    
    -- Get the spawn_id from the unit
    local spawnId = getUnitSpawnId(spawnedUnit)
    if not spawnId then
        warn("Could not get spawn_id from newly placed unit")
        Rayfield:Notify({Title = "Macro Recorder",Content = "Could not get spawn_id from newly placed unit",Duration = 3,Image = 4483362458})
        return
    end
    
    -- Get display name (e.g., "Shadow")
    local internalName = getInternalSpawnName(spawnedUnit)
    local displayName = getDisplayNameFromUnitId(internalName)
    if not displayName then
        warn("Could not get display name for unit")
        Rayfield:Notify({Title = "Macro Recorder",Content = "Could not get display name for unit",Duration = 3,Image = 4483362458})
        return
    end
    
    -- Increment placement counter for this unit type
    recordingPlacementCounter[displayName] = (recordingPlacementCounter[displayName] or 0) + 1
    local placementNumber = recordingPlacementCounter[displayName]
    
    -- Create the logical placement identifier
    local placementId = string.format("%s #%d", displayName, placementNumber)
    
    -- Map spawn_id to logical placement for upgrade/sell tracking
    recordingSpawnIdToPlacement[tostring(spawnId)] = placementId

    recordingUnitNameToSpawnId[spawnedUnit.Name] = tostring(spawnId)
    
    local raycastData = actionInfo.args[2] or {}
    local rotation = actionInfo.args[3] or 0
    local gameRelativeTime = actionInfo.timestamp - gameStartTime
    
    -- Store clean macro record (no spawn_id!)
    local placementRecord = {
        Type = "spawn_unit",
        Unit = placementId, -- "Shadow #1", "Shadow #2", etc.
        Time = string.format("%.2f", gameRelativeTime),
        Pos = raycastData.Origin and string.format("%.17f, %.17f, %.17f", raycastData.Origin.X, raycastData.Origin.Y, raycastData.Origin.Z) or "",
        Dir = raycastData.Direction and string.format("%.17f, %.17f, %.17f", raycastData.Direction.X, raycastData.Direction.Y, raycastData.Direction.Z) or "",
        Rot = rotation ~= 0 and rotation or 0
    }
    
    table.insert(macro, placementRecord)
    
print(string.format("Recorded placement: %s (spawn_id: %s)", placementId, tostring(spawnId)))
Rayfield:Notify({
    Title = "Macro Recorder",
    Content = string.format("Recorded placement: %s", placementId),
    Duration = 3,
    Image = 4483362458
})
end

local function parseUnitString(unitString)
    -- Parse "DisplayName #InstanceNumber" format
    local displayName, instanceNumber = unitString:match("^(.-) #%s*(%d+)$")
    if displayName and instanceNumber then
        return displayName, tonumber(instanceNumber)
    end
    return nil, nil
end

local function getMultiUpgradeCost(unitId, currentLevel, upgradeAmount)
    local unitData = getUnitData(unitId)
    if not unitData or not unitData.upgrade then return 0 end
    
    local totalCost = 0
    local costScale = getCostScale()
    
    -- Calculate cumulative cost for multiple upgrades
    for i = 1, upgradeAmount do
        local upgradeIndex = currentLevel + i
        
        if upgradeIndex > #unitData.upgrade then
            break -- Can't upgrade beyond max level
        end
        
        local baseCost = unitData.upgrade[upgradeIndex] and unitData.upgrade[upgradeIndex].cost or 0
        totalCost = totalCost + math.floor(baseCost * costScale)
    end
    
    if costScale ~= 1.0 then
        print(string.format("Multi-upgrade cost for %s level %d->%d (x%d): %d (x%.1f scale)", 
            unitId, currentLevel, currentLevel + upgradeAmount, upgradeAmount, totalCost, costScale))
    end
    
    return totalCost
end

local function waitForSufficientMoney(action, actionIndex, totalActions)
    local requiredCost = 0
    local displayName, instanceNumber = parseUnitString(action.Unit)
    local unitid = displayName and getUnitIdFromDisplayName(displayName)
    
    if action.Type == "spawn_unit" and unitid then
        requiredCost = getPlacementCost(unitid)
    elseif action.Type == "upgrade_unit_ingame" and displayName and instanceNumber then
        local currentUUID = playbackDisplayNameInstances[displayName] and
                          playbackDisplayNameInstances[displayName][instanceNumber]
        if currentUUID then
            local unit = findUnitBySpawnUUID(currentUUID)
            if unit then
                local currentLevel = getUnitUpgradeLevel(unit)
                local upgradeAmount = action.Amount or 1
                
                if upgradeAmount > 1 then
                    requiredCost = getMultiUpgradeCost(unitid, currentLevel, upgradeAmount)
                else
                    requiredCost = getUpgradeCost(unitid, currentLevel)
                end
            end
        end
    end
    
    if requiredCost > 0 then
        local maxWaitTime = 9999999999999999999999999999999999999999
        local waitStart = tick()
        
        while getPlayerMoney() < requiredCost and isPlaybacking and not gameHasEnded do
            if tick() - waitStart > maxWaitTime then
                updateDetailedStatus(string.format("(%d/%d) Timeout waiting for money - continuing macro", actionIndex, totalActions))
                return true
            end
            
            local missingMoney = requiredCost - getPlayerMoney()
            local upgradeAmount = action.Amount or 1
            local upgradeText = upgradeAmount > 1 and string.format(" (x%d upgrade)", upgradeAmount) or ""
            
            updateDetailedStatus(string.format("(%d/%d) Waiting for %d more yen%s (need %d, have %d)", 
                actionIndex, totalActions, missingMoney, upgradeText, requiredCost, getPlayerMoney()))
            task.wait(1)
        end
    end
    return true
end

local function processSellActionWithSpawnIdMapping(actionInfo)
    local remoteParam = actionInfo.args[1] -- This should be the unit.Name like "ea27546614ef43b1"
    
    -- Find spawn ID from unit name
    local spawnId = recordingUnitNameToSpawnId[remoteParam]
    if not spawnId then
        warn("Could not find spawn ID for unit name:", remoteParam)
        Rayfield:Notify({Title = "Macro Recorder",Content = "Could not find spawn ID for unit name: "..remoteParam,Duration = 3,Image = 4483362458})
        return
    end
    
    -- Find placement ID from spawn ID
    local placementId = recordingSpawnIdToPlacement[spawnId]
    if not placementId then
        warn("Could not find placement mapping for spawn_id:", spawnId)
        Rayfield:Notify({Title = "Macro Recorder",Content = "Could not find placement mapping for spawn_id: "..spawnId,Duration = 3,Image = 4483362458})
        return
    end
    
    local gameRelativeTime = actionInfo.timestamp - gameStartTime
    
    local sellRecord = {
        Type = "sell_unit_ingame",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime)
    }
    
    table.insert(macro, sellRecord)
    
    -- Clean up mappings
    recordingSpawnIdToPlacement[spawnId] = nil
    recordingUnitNameToSpawnId[remoteParam] = nil
    
print(string.format("Recorded sell: %s (was unit_name: %s)", placementId, remoteParam))
Rayfield:Notify({
    Title = "Macro Recorder",
    Content = string.format("Recorded sell: %s", placementId),
    Duration = 3,
    Image = 4483362458
})
end

local function processWaveSkipAction(actionInfo)
    local gameRelativeTime = actionInfo.timestamp - gameStartTime
    
    table.insert(macro, {
        Type = "vote_wave_skip",
        Time = string.format("%.2f", gameRelativeTime)
    })
    Rayfield:Notify({Title = "Macro Recorder",Content = "Recorded wave skip",Duration = 3,Image = 4483362458})
end

local function processAbilityActionWithSpawnIdMapping(actionInfo)
    local unitUUID = actionInfo.unitUUID
    
    -- Find which placement ID this UUID belongs to
    local placementId = nil
    
    for spawnId, placement in pairs(recordingSpawnIdToPlacement) do
        -- Find the unit with this spawn_id
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        if unitsFolder then
            for _, unit in pairs(unitsFolder:GetChildren()) do
                if isOwnedByLocalPlayer(unit) then
                    local stats = unit:FindFirstChild("_stats")
                    if stats then
                        local uuidValue = stats:FindFirstChild("uuid")
                        if uuidValue and uuidValue:IsA("StringValue") and uuidValue.Value == unitUUID then
                            placementId = placement
                            break
                        end
                    end
                end
            end
            if placementId then break end
        end
    end
    
    if not placementId then
        warn("Could not find placement ID for ability UUID:", unitUUID)
        return
    end
    
    local gameRelativeTime = actionInfo.timestamp - gameStartTime
    
    local abilityRecord = {
        Type = "use_active_attack",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime)
    }
    
    table.insert(macro, abilityRecord)
    
    print(string.format("Recorded ability: %s", placementId))
    Rayfield:Notify({
        Title = "Macro Recorder",
        Content = string.format("Recorded ability: %s", placementId),
        Duration = 2,
        Image = 4483362458
    })
end

local function processActionResponseWithSpawnIdMapping(actionInfo)
    if actionInfo.remoteName == MACRO_CONFIG.SPAWN_REMOTE then
        Rayfield:Notify({
            Title = "Macro Recorder",
            Content = "Processing spawn action",
            Duration = 2,
            Image = 4483362458,
        })
        processPlacementActionWithSpawnIdMapping(actionInfo)
    elseif actionInfo.remoteName == MACRO_CONFIG.SELL_REMOTE then
        processSellActionWithSpawnIdMapping(actionInfo)
    elseif actionInfo.remoteName == MACRO_CONFIG.WAVE_SKIP_REMOTE then
        Rayfield:Notify({
            Title = "Macro Recorder",
            Content = "Processing wave skip action",
            Duration = 2,
            Image = 4483362458,
        })
        processWaveSkipAction(actionInfo)
    end
    -- Note: upgrade branch removed - now handled by Heartbeat monitor
end

local function setupMacroHooksRefactored()
    trackedUnits = {}

    task.spawn(function()
        workspace:WaitForChild("_UNITS")
    end)

    -- Hook placement, sell, and ability remotes
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if not checkcaller() and isRecording and method == "InvokeServer"
           and self.Parent and self.Parent.Name == "client_to_server" then

            if self.Name == MACRO_CONFIG.SPAWN_REMOTE then
                task.spawn(function()
                    if gameStartTime == 0 then gameStartTime = tick() end
                    local preActionUnits = takeUnitsSnapshot()
                    task.wait(0.3)
                    processActionResponseWithSpawnIdMapping({
                        remoteName = MACRO_CONFIG.SPAWN_REMOTE,
                        args = args,
                        timestamp = tick(),
                        preActionUnits = preActionUnits
                    })
                end)
            elseif self.Name == MACRO_CONFIG.SELL_REMOTE then
                task.spawn(function()
                    processActionResponseWithSpawnIdMapping({
                        remoteName = MACRO_CONFIG.SELL_REMOTE,
                        args = args,
                        timestamp = tick()
                    })
                end)
            elseif self.Name == MACRO_CONFIG.WAVE_SKIP_REMOTE then
                task.spawn(function()
                    processActionResponseWithSpawnIdMapping({
                        remoteName = MACRO_CONFIG.WAVE_SKIP_REMOTE,
                        timestamp = tick()
                    })
                end)
            elseif self.Name == "use_active_attack" then
                -- NEW: Record ability usage
                task.spawn(function()
                    processAbilityActionWithSpawnIdMapping({
                        unitUUID = args[1],
                        timestamp = tick()
                    })
                end)
            end
        end

        return oldNamecall(self, ...)
    end)

    -- Heartbeat: watch for level changes on all our units
    local RunService = game:GetService("RunService")
    RunService.Heartbeat:Connect(function()
        if not isRecording then return end

        local unitsFolder = workspace:FindFirstChild("_UNITS")
        if not unitsFolder then return end

        for _, unit in pairs(unitsFolder:GetChildren()) do
            if isOwnedByLocalPlayer(unit) then
                local spawnId = getUnitSpawnId(unit)
                if spawnId then
                    local spawnKey = tostring(spawnId)
                    local currentLevel = getUnitUpgradeLevel(unit)
                    local placementId = recordingSpawnIdToPlacement[spawnKey]
                    
                    if placementId then
                        -- Initialize tracking if new unit
                        if not trackedUnits[spawnKey] then
                            trackedUnits[spawnKey] = {
                                placementId = placementId,
                                lastLevel = currentLevel
                            }
                        end
                        
                        -- Check for level increase
                        local lastLevel = trackedUnits[spawnKey].lastLevel
                        if currentLevel > lastLevel then
                            local levelIncrease = currentLevel - lastLevel
                            
                            local record = {
                                Type = MACRO_CONFIG.UPGRADE_REMOTE,
                                Unit = placementId,
                                Time = string.format("%.2f", tick() - gameStartTime)
                            }
                            
                            if levelIncrease > 1 then
                                record.Amount = levelIncrease
                            end
                            
                            table.insert(macro, record)
                            
                            local upgradeText = levelIncrease > 1 
                                and string.format("x%d", levelIncrease) or ""
                            
                            print(string.format("Recorded upgrade%s: %s (L%d->L%d)",
                                upgradeText, placementId, lastLevel, currentLevel))
                            
                            --Rayfield:Notify({
                               -- Title = "Macro Recorder",
                               -- Content = string.format("Recorded upgrade%s: %s", upgradeText, placementId),
                               -- Duration = 3,
                              --  Image = 4483362458
                           -- })
                            
                            -- Update tracked level
                            trackedUnits[spawnKey].lastLevel = currentLevel
                        end
                    end
                end
            end
        end
    end)

    print("Macro hooks initialized - placement, sell, and upgrade monitoring active")
end

    -- File Management Functions
    local function ensureMacroFolders()
        if not isfolder("LixHub") then makefolder("LixHub") end
        if not isfolder("LixHub/Macros") then makefolder("LixHub/Macros") end
        if not isfolder("LixHub/Macros/AC") then makefolder("LixHub/Macros/AC") end
    end

    local function loadAllMacros()
        macroManager = {}
        ensureMacroFolders()
        
        local success, files = pcall(function()
            return listfiles("LixHub/Macros/AC/")
        end)
        
        if success then
            for _, file in ipairs(files) do
                if file:match("%.json$") then
                    local name = file:match("([^/\\]+)%.json$")
                    if name then
                        local data = loadMacroFromFile(name)
                        if data then
                            macroManager[name] = data
                        end
                    end
                end
            end
        end
    end

    local function deleteMacroFile(name)
        local filePath = getMacroFilename(name)
        if filePath and isfile(filePath) then
            delfile(filePath)
        end
        macroManager[name] = nil
    end

    local function clearPlaybackTracking()
    playbackDisplayNameInstances = {}
end

local function validatePlacementActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local maxRetries = VALIDATION_CONFIG.PLACEMENT_MAX_RETRIES
    
    -- Parse unit info from clean macro format
    local placementId = action.Unit -- "Shadow #1"
    local displayName, placementNumber = placementId:match("^(.-) #%s*(%d+)$")
    
    if not displayName or not placementNumber then
        updateDetailedStatus(string.format("(%d/%d) FAILED: Invalid unit format: %s", 
            actionIndex, totalActionCount, placementId))
        return false
    end
    
    placementNumber = tonumber(placementNumber)
    
    if not waitForSufficientMoney(action, actionIndex, totalActionCount) then
        return false
    end
    
    for attempt = 1, maxRetries do
        if not isPlaybacking then return false end
        
        local unitId = getUnitIdFromDisplayName(displayName)
        if not unitId then
            updateDetailedStatus(string.format("(%d/%d) FAILED: Could not resolve unit ID for: %s", 
                actionIndex, totalActionCount, displayName))
            return false
        end
        
        local resolvedUUID = resolveUUIDFromInternalName(unitId)
        if not resolvedUUID then
            updateDetailedStatus(string.format("(%d/%d) FAILED: Could not resolve UUID for: %s", 
                actionIndex, totalActionCount, unitId))
            return false
        end
        
        updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d: Placing %s", 
            actionIndex, totalActionCount, attempt, maxRetries, placementId))
        
        local beforeSnapshot = takeUnitsSnapshot()
        
        -- Parse position and direction
        local px, py, pz = action.Pos:match("([%-%d%.e%-]+), ([%-%d%.e%-]+), ([%-%d%.e%-]+)")
        local dx, dy, dz = action.Dir:match("([%-%d%.e%-]+), ([%-%d%.e%-]+), ([%-%d%.e%-]+)")
        
        if not (px and py and pz and dx and dy and dz) then
            updateDetailedStatus(string.format("(%d/%d) FAILED: Invalid position format", actionIndex, totalActionCount))
            return false
        end
        
        local originPos = Vector3.new(tonumber(px), tonumber(py), tonumber(pz))
        local direction = Vector3.new(tonumber(dx), tonumber(dy), tonumber(dz))
        
        -- Apply random offset if enabled
        if State.RandomOffsetEnabled then
            local offsetX = (math.random() - 0.5) * 2 * State.RandomOffsetAmount
            local offsetZ = (math.random() - 0.5) * 2 * State.RandomOffsetAmount
            originPos = Vector3.new(originPos.X + offsetX, originPos.Y, originPos.Z + offsetZ)
        end
        
        local raycastParam = {
            Origin = originPos,
            Direction = direction
        }
        
        local success = pcall(function()
            endpoints:WaitForChild(MACRO_CONFIG.SPAWN_REMOTE):InvokeServer(
                resolvedUUID,
                raycastParam,
                action.Rot or 0
            )
        end)
        
        if not success then
            if attempt < maxRetries then
                task.wait(VALIDATION_CONFIG.RETRY_DELAY)
                continue
            else
                return false
            end
        end
        
        local validationWaitTime = (attempt == 1) and VALIDATION_CONFIG.NORMAL_VALIDATION_TIME or VALIDATION_CONFIG.EXTENDED_VALIDATION_TIME
        task.wait(validationWaitTime)
        
        local afterSnapshot = takeUnitsSnapshot()
        local placedUnit = findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
        
        if placedUnit and isOwnedByLocalPlayer(placedUnit) then
            -- Get spawn_id and create mapping
            local newSpawnId = getUnitSpawnId(placedUnit)
            if newSpawnId then
                playbackPlacementToSpawnId[placementId] = newSpawnId

                print("PLACEMENT SUCCESS - Unit:", placementId, "Mapped to spawn_id:", newSpawnId)
                
                print(string.format("Playback placement success: %s -> spawn_id %s", placementId, tostring(newSpawnId)))
                updateDetailedStatus(string.format("(%d/%d) SUCCESS: Placed %s", 
                    actionIndex, totalActionCount, placementId))
                return true
            end
        end
        
        if attempt < maxRetries then
            task.wait(VALIDATION_CONFIG.RETRY_DELAY)
        end
    end
    
updateDetailedStatus(string.format("(%d/%d) FAILED: Could not place %s - continuing macro", 
    actionIndex, totalActionCount, placementId))
return true
end

local function validateUpgradeActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local maxRetries = VALIDATION_CONFIG.UPGRADE_MAX_RETRIES
    
    local placementId = action.Unit
    local upgradeAmount = action.Amount or 1 -- Default to single upgrade
    
    -- Look up current spawn_id for this placement
    local currentSpawnId = playbackPlacementToSpawnId[placementId]
    if not currentSpawnId then
        updateDetailedStatus(string.format("(%d/%d) FAILED: No spawn_id mapping for %s", 
            actionIndex, totalActionCount, placementId))
        return false
    end
    
    for attempt = 1, maxRetries do
        if not isPlaybacking then return false end
        
        -- Find the unit by spawn_id FRESH each attempt (important for retries)
        local targetUnit = nil
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        
        if unitsFolder then
            for _, unit in pairs(unitsFolder:GetChildren()) do
                if isOwnedByLocalPlayer(unit) and getUnitSpawnId(unit) == currentSpawnId then
                    targetUnit = unit
                    break
                end
            end
        end
        
        if not targetUnit then
            updateDetailedStatus(string.format("(%d/%d) FAILED: Unit not found for %s (spawn_id: %s)", 
                actionIndex, totalActionCount, placementId, tostring(currentSpawnId)))
            if attempt < maxRetries then
                updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d failed - unit not found, retrying...", 
                    actionIndex, totalActionCount, attempt, maxRetries))
                task.wait(VALIDATION_CONFIG.RETRY_DELAY)
                continue
            else
                return false
            end
        end
        
        local originalLevel = getUnitUpgradeLevel(targetUnit)
        local upgradeText = upgradeAmount > 1 and 
            string.format("Multi-upgrading x%d", upgradeAmount) or "Upgrading"
        
        -- Calculate required money FRESH each attempt for ALL upgrades
        local displayName = parseUnitString(action.Unit)
        local unitId = displayName and getUnitIdFromDisplayName(displayName)
        local requiredCost = 0
        
        if unitId then
            if upgradeAmount > 1 then
                requiredCost = getMultiUpgradeCost(unitId, originalLevel, upgradeAmount)
            else
                requiredCost = getUpgradeCost(unitId, originalLevel)
            end
        end
        
        -- Wait for money if needed (per attempt timeout)
        if requiredCost > 0 then
            local maxWaitTime = 999999999999999999999999999999 -- Shorter wait time per attempt
            local waitStart = tick()
            
            while getPlayerMoney() < requiredCost and isPlaybacking and not gameHasEnded do
                if tick() - waitStart > maxWaitTime then
                    updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d: Money timeout - need %d, have %d", 
                        actionIndex, totalActionCount, attempt, maxRetries, requiredCost, getPlayerMoney()))
                    break
                end
                
                local missingMoney = requiredCost - getPlayerMoney()
                updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d: Waiting for %d more yen (%s)", 
                    actionIndex, totalActionCount, attempt, maxRetries, missingMoney, upgradeText))
                task.wait(1)
            end
        end
        
        -- Skip attempt if still not enough money
        if requiredCost > 0 and getPlayerMoney() < requiredCost then
            updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d: Insufficient money, trying next attempt", 
                actionIndex, totalActionCount, attempt, maxRetries))
            if attempt < maxRetries then
                task.wait(VALIDATION_CONFIG.RETRY_DELAY)
                continue
            else
                return false
            end
        end
        
        updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d: %s %s (Level %d)", 
            actionIndex, totalActionCount, attempt, maxRetries, upgradeText, placementId, originalLevel))
        
        -- NEW: Fire multiple single upgrade remotes instead of one multi-upgrade remote
        local successfulUpgrades = 0
        local lastKnownLevel = originalLevel
        
        for upgradeIndex = 1, upgradeAmount do
            -- Re-find unit for each upgrade (in case the unit reference changes)
            local currentTargetUnit = nil
            local currentUnitsFolder = Services.Workspace:FindFirstChild("_UNITS")
            
            if currentUnitsFolder then
                for _, unit in pairs(currentUnitsFolder:GetChildren()) do
                    if isOwnedByLocalPlayer(unit) and getUnitSpawnId(unit) == currentSpawnId then
                        currentTargetUnit = unit
                        break
                    end
                end
            end
            
            if not currentTargetUnit then
                updateDetailedStatus(string.format("(%d/%d) Upgrade %d/%d: Unit lost during upgrade sequence", 
                    actionIndex, totalActionCount, upgradeIndex, upgradeAmount))
                break
            end
            
            -- Check if we have enough money for this individual upgrade
            local currentLevel = getUnitUpgradeLevel(currentTargetUnit)
            local singleUpgradeCost = getUpgradeCost(unitId, currentLevel)
            
            if singleUpgradeCost > 0 and getPlayerMoney() < singleUpgradeCost then
                updateDetailedStatus(string.format("(%d/%d) Upgrade %d/%d: Insufficient money for upgrade (need %d, have %d)", 
                    actionIndex, totalActionCount, upgradeIndex, upgradeAmount, singleUpgradeCost, getPlayerMoney()))
                break
            end
            
            -- Fire single upgrade remote
            local upgradeSuccess = pcall(function()
                local currentSpawnId = getUnitSpawnId(currentTargetUnit)
                endpoints:WaitForChild(MACRO_CONFIG.UPGRADE_REMOTE):InvokeServer(currentTargetUnit.Name)
            end)
            
            if not upgradeSuccess then
                updateDetailedStatus(string.format("(%d/%d) Upgrade %d/%d: Remote call failed", 
                    actionIndex, totalActionCount, upgradeIndex, upgradeAmount))
                break
            end
            
            -- Quick validation for this single upgrade (shorter wait time)
            local upgradeValidated = false
            local validationStart = tick()
            
            while tick() - validationStart < 2.0 do -- 2 second timeout per upgrade
                if not isPlaybacking then return false end
                
                -- Re-check unit level
                local validationUnit = nil
                local validationUnitsFolder = Services.Workspace:FindFirstChild("_UNITS")
                
                if validationUnitsFolder then
                    for _, unit in pairs(validationUnitsFolder:GetChildren()) do
                        if isOwnedByLocalPlayer(unit) and getUnitSpawnId(unit) == currentSpawnId then
                            validationUnit = unit
                            break
                        end
                    end
                end
                
                if validationUnit then
                    local newLevel = getUnitUpgradeLevel(validationUnit)
                    if newLevel > lastKnownLevel then
                        lastKnownLevel = newLevel
                        successfulUpgrades = successfulUpgrades + 1
                        upgradeValidated = true
                        updateDetailedStatus(string.format("(%d/%d) Upgrade %d/%d: Level %d -> %d SUCCESS", 
                            actionIndex, totalActionCount, upgradeIndex, upgradeAmount, currentLevel, newLevel))
                        break
                    end
                else
                    -- Unit lost during validation
                    updateDetailedStatus(string.format("(%d/%d) Upgrade %d/%d: Unit lost during validation", 
                        actionIndex, totalActionCount, upgradeIndex, upgradeAmount))
                    break
                end
                
                task.wait(0.1)
            end
            
            if not upgradeValidated then
                updateDetailedStatus(string.format("(%d/%d) Upgrade %d/%d: Validation timeout", 
                    actionIndex, totalActionCount, upgradeIndex, upgradeAmount))
                -- Continue to next upgrade instead of breaking - maybe this one will work
            end
            
            -- Small delay between upgrades to prevent server overload
            task.wait(0.1)
        end
        
        -- Check overall success
        if successfulUpgrades >= upgradeAmount then
            updateDetailedStatus(string.format("(%d/%d) SUCCESS: %s %s (Level %d->%d, +%d upgrades)", 
                actionIndex, totalActionCount, upgradeText, placementId, 
                originalLevel, lastKnownLevel, successfulUpgrades))
            return true
        elseif successfulUpgrades > 0 then
            updateDetailedStatus(string.format("(%d/%d) PARTIAL: %s %s (Level %d->%d, %d/%d upgrades)", 
                actionIndex, totalActionCount, upgradeText, placementId, 
                originalLevel, lastKnownLevel, successfulUpgrades, upgradeAmount))
            -- Consider partial success as success if we got at least some upgrades
            return true
         else
            updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d: No upgrades succeeded", 
                actionIndex, totalActionCount, attempt, maxRetries))
            
            if attempt < maxRetries then
                updateDetailedStatus(string.format("(%d/%d) Attempt %d/%d failed, retrying in %.1fs...", 
                    actionIndex, totalActionCount, attempt, maxRetries, VALIDATION_CONFIG.RETRY_DELAY))
                task.wait(VALIDATION_CONFIG.RETRY_DELAY)
            else
                -- Final attempt failed, exit function and continue macro
                updateDetailedStatus(string.format("(%d/%d) All upgrade attempts failed - continuing macro", 
                    actionIndex, totalActionCount))
                return true
            end
        end
    end
    updateDetailedStatus(string.format("(%d/%d) FAILED: Could not %s %s after %d attempts - continuing macro", 
        actionIndex, totalActionCount, upgradeText:lower(), placementId, maxRetries))
    return true
end

local function validateSellActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    
    local placementId = action.Unit -- "Shadow #1"
    
    -- Look up current spawn_id for this placement
    local currentSpawnId = playbackPlacementToSpawnId[placementId]
    if not currentSpawnId then
        updateDetailedStatus(string.format("(%d/%d) FAILED: No spawn_id mapping for %s", 
            actionIndex, totalActionCount, placementId))
        return false
    end
    
    -- Find the unit by spawn_id
    local targetUnit = nil
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    
    if unitsFolder then
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if isOwnedByLocalPlayer(unit) and getUnitSpawnId(unit) == currentSpawnId then
                targetUnit = unit
                break
            end
        end
    end
    
    if not targetUnit then
        updateDetailedStatus(string.format("(%d/%d) FAILED: Unit not found for %s (spawn_id: %s)", 
            actionIndex, totalActionCount, placementId, tostring(currentSpawnId)))
        return false
    end
    
    updateDetailedStatus(string.format("(%d/%d) Selling %s", actionIndex, totalActionCount, placementId))
    
    local success = pcall(function()
        endpoints:WaitForChild(MACRO_CONFIG.SELL_REMOTE):InvokeServer(targetUnit.Name)
    end)
    
    if success then
        task.wait(0.5)
        
        -- Verify unit is gone
        local soldUnit = nil
        local unitsFolder2 = Services.Workspace:FindFirstChild("_UNITS")
        
        if unitsFolder2 then
            for _, unit in pairs(unitsFolder2:GetChildren()) do
                if isOwnedByLocalPlayer(unit) and getUnitSpawnId(unit) == currentSpawnId then
                    soldUnit = unit
                    break
                end
            end
        end
        
        if not soldUnit then
            -- Remove from mapping
            playbackPlacementToSpawnId[placementId] = nil
            
            updateDetailedStatus(string.format("(%d/%d) Successfully sold %s", 
                actionIndex, totalActionCount, placementId))
            return true
        end
    end
    
updateDetailedStatus(string.format("(%d/%d) Failed to sell %s - continuing macro", 
    actionIndex, totalActionCount, placementId))
return true
end

local function validateAbilityActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    local placementId = action.Unit
    
    -- Look up current spawn_id for this placement
    local currentSpawnId = playbackPlacementToSpawnId[placementId]
    if not currentSpawnId then
        updateDetailedStatus(string.format("(%d/%d) FAILED: No spawn_id mapping for %s", 
            actionIndex, totalActionCount, placementId))
        return false
    end
    
    -- Find the unit by spawn_id to get its current UUID
    local targetUnit = nil
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    
    if unitsFolder then
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if isOwnedByLocalPlayer(unit) and getUnitSpawnId(unit) == currentSpawnId then
                targetUnit = unit
                break
            end
        end
    end
    
    if not targetUnit then
        updateDetailedStatus(string.format("(%d/%d) FAILED: Unit not found for %s (spawn_id: %s)", 
            actionIndex, totalActionCount, placementId, tostring(currentSpawnId)))
        return false
    end
    
    -- Get the current UUID from the unit's _stats
    local stats = targetUnit:FindFirstChild("_stats")
    if not stats then
        updateDetailedStatus(string.format("(%d/%d) FAILED: No stats for %s", 
            actionIndex, totalActionCount, placementId))
        return false
    end
    
    local uuidValue = stats:FindFirstChild("uuid")
    if not uuidValue or not uuidValue:IsA("StringValue") then
        updateDetailedStatus(string.format("(%d/%d) FAILED: No UUID for %s", 
            actionIndex, totalActionCount, placementId))
        return false
    end
    
    local currentUUID = uuidValue.Value
    
    updateDetailedStatus(string.format("(%d/%d) Using ability for %s", actionIndex, totalActionCount, placementId))
    
    local success = pcall(function()
        local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
        endpoints:WaitForChild("use_active_attack"):InvokeServer(currentUUID)
    end)
    
    if success then
        task.wait(0.2) -- Small delay after ability use
        updateDetailedStatus(string.format("(%d/%d) Successfully used ability for %s", 
            actionIndex, totalActionCount, placementId))
        return true
    else
        updateDetailedStatus(string.format("(%d/%d) Failed to use ability for %s", 
            actionIndex, totalActionCount, placementId))
        return false
    end
end

local function executeActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    if action.Type == "spawn_unit" then
        return validatePlacementActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    elseif action.Type == "upgrade_unit_ingame" then
        return validateUpgradeActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    elseif action.Type == "sell_unit_ingame" then
        return validateSellActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    elseif action.Type == "use_active_attack" then
        -- NEW: Handle ability actions
        return validateAbilityActionWithSpawnIdMapping(action, actionIndex, totalActionCount)
    elseif action.Type == "vote_wave_skip" then
        -- Wave skip logic remains unchanged
        updateDetailedStatus(string.format("(%d/%d) Skipping wave", actionIndex, totalActionCount))
        
        local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
        local success = pcall(function()
            endpoints:WaitForChild(MACRO_CONFIG.WAVE_SKIP_REMOTE):InvokeServer()
        end)
        
        return success
    end
    
    return false
end

    -- ========== EXISTING FUNCTIONS (keep all your existing functions) ==========

    local function getItemDisplayName(itemName)
        -- Check cache first
        if itemNameCache[itemName] then
            return itemNameCache[itemName]
        end
        
        -- Try to find the item in Framework.Data.Items ModuleScripts
        local itemsPath = Services.ReplicatedStorage.Framework.Data.Items
        if itemsPath then
            -- Search through all ModuleScripts in the Items folder
            for _, moduleScript in pairs(itemsPath:GetChildren()) do
                if moduleScript:IsA("ModuleScript") then
                    local success, itemData = pcall(require, moduleScript)
                    if success and itemData then
                        -- Search through the module data for our item
                        for itemKey, data in pairs(itemData) do
                            if type(data) == "table" and data.id == itemName then
                                -- Found the item! Use the name field
                                local displayName = data.name
                                if displayName then
                                    itemNameCache[itemName] = displayName
                                    print("Found item mapping: " .. itemName .. " -> " .. displayName)
                                    return displayName
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Fallback to formatted version if not found in ModuleScripts
        local displayName = itemName:gsub("_", " "):gsub("(%w)(%w*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
        
        itemNameCache[itemName] = displayName
        return displayName
    end

local function getChallengeDisplayName(challenge)
    if not challenge then return nil end
    
    -- Convert snake_case to Title Case
    return challenge:gsub("_", " "):gsub("(%w)(%w*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

    -- Function to get current map info
local function getMapInfo()
    local mapName = "Unknown Map"
    local challengeModifier = nil
    
    -- Try to get map data from GetLevelData
    if Services.Workspace:FindFirstChild("_MAP_CONFIG") and Services.Workspace._MAP_CONFIG:FindFirstChild("GetLevelData") then
        local success, result = pcall(function()
            return Services.Workspace._MAP_CONFIG.GetLevelData:InvokeServer()
        end)
        
        if success and result then
            -- Try different possible field names for the map name
            mapName = result.MapName or result.mapName or result.Name or result.name or 
                     result.LevelName or result.levelName or result.Map or result.map or "Unknown Map"
            
            -- Capture challenge modifier
            challengeModifier = result.challenge
            
            print("Map info retrieved:", mapName)
            if challengeModifier then
                print("Challenge modifier found:", challengeModifier)
            end
            print("Full map data:", result)
        else
            print("Failed to get map data:", result)
        end
    end
    
    return mapName, challengeModifier
end

    -- Function to capture current stats
    local function captureStats()
        local player = Services.Players.LocalPlayer
        local stats = {}
        
        if player and player:FindFirstChild("_stats") then
            for _, statObj in pairs(player._stats:GetChildren()) do
                if statObj:IsA("IntValue") or statObj:IsA("NumberValue") then
                    stats[statObj.Name] = statObj.Value
                end
            end
        end
        
        return stats
    end

    -- Function to calculate stat changes
    local function getStatChanges()
        local changes = {}
        
        for statName, endValue in pairs(endStats) do
            -- Skip resource stat
            if statName ~= "resource" then
                local startValue = startStats[statName] or 0
                local change = endValue - startValue
                
                if change > 0 then
                    changes[statName] = change
                end
            end
        end
        
        return changes
    end

    -- Function to format time as MM:SS
    local function formatTime(seconds)
        local minutes = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%d:%02d", minutes, secs)
    end

    -- Function to print table contents recursively
    local function printTableContents(tbl, indent)
        indent = indent or 0
        local spaces = string.rep("  ", indent)
        
        for key, value in pairs(tbl) do
            if type(value) == "table" then
                print(spaces .. tostring(key) .. ": (table)")
                printTableContents(value, indent + 1)
            else
                print(spaces .. tostring(key) .. ": " .. tostring(value))
            end
        end
    end

    local function getStatDisplayName(statName)
        local statMappings = {
            ["gem_amount"] = "Gems",
            ["player_xp"] = "XP",
            ["Resourcejewels"] = "Jewels",

        }
        
        return statMappings[statName] or getItemDisplayName(statName)
    end

    -- Enhanced webhook function
    local function sendWebhook(messageType, unitData)
        if ValidWebhook == "YOUR_WEBHOOK_URL_HERE" then
            notify("Please set your Discord webhook URL first!")
            return
        end

        local data

        if messageType == "test" then
            data = {
                username = "LixHub Bot",
                content = string.format("<@%s>", Config.DISCORD_USER_ID or "000000000000000000"),
                embeds = {{
                    title = "LixHub Notification",
                    description = "Test webhook sent successfully",
                    color = 0x5865F2,
                    footer = { text = "LixHub Auto Logger" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            }

    elseif messageType == "unit_drop" then
        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        local unitName = "Unknown Unit"
        
        print("DEBUG WEBHOOK: unitData type:", type(unitData), "value:", unitData)
        
        -- Simply get the unit name from argument 5 (based on your console output)
        if unitData and type(unitData) == "table" then
            print("DEBUG WEBHOOK: unitData has", #unitData, "items")
            for _, argInfo in ipairs(unitData) do
                print("DEBUG WEBHOOK: arg", argInfo.index, "=", argInfo.value)
                if argInfo.index == 5 and argInfo.type == "string" then
                    unitName = argInfo.value
                    print("DEBUG WEBHOOK: Set unitName to:", unitName)
                    break
                end
            end
        end
        
        print("DEBUG WEBHOOK: Final unitName:", unitName)
        
        data = {
            username = "LixHub",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or "000000000000000000"),
            embeds = {{
                title = "Unit Drop!",
                description = string.format("**%s** obtained **%s**!", playerName, unitName),
                color = 0x5865F2,
                footer = { text = "LixHub" },
                timestamp = timestamp
            }}
        }

        elseif messageType == "stage" then
    -- Keep existing stage webhook code unchanged
    local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local gameDuration = tick() - gameStartTime
    local formattedTime = formatTime(gameDuration)
    
    -- Add challenge info to duration if it exists
    local durationText = formattedTime
    if currentChallenge then
        local challengeDisplay = getChallengeDisplayName(currentChallenge)
        durationText = formattedTime .. " - (" .. challengeDisplay .. ")"
    end
    
    -- Get stat changes (excluding resource)
    endStats = captureStats()
    local statChanges = getStatChanges()
    
    -- Format rewards text
    local rewardsText = ""
    
    -- Add items if any were collected
    if next(sessionItems) then
        for itemName, quantity in pairs(sessionItems) do
            local displayName = getItemDisplayName(itemName)
            rewardsText = rewardsText .. "+" .. quantity .. " " .. displayName .. "\n"
        end
    end
    
    -- Add stat changes if any with total amounts (excluding resource)
    if next(statChanges) then
        for statName, change in pairs(statChanges) do
            local totalAmount = endStats[statName] or 0
            local displayStatName = getStatDisplayName(statName)
            rewardsText = rewardsText .. "+" .. change .. " " .. displayStatName .. " [" .. totalAmount .. "]\n"
        end
    end
    
    if rewardsText == "" then
        rewardsText = "No rewards gained this match"
    else
        rewardsText = rewardsText:gsub("\n$", "")
    end
    
    local footerText = "discord.gg/cYKnXE2Nf8"
    
    -- Determine title and color based on game result
    local titleText = "Stage Completed!"
    local embedColor = 0x57F287
    
    if gameResult == "Victory" or gameResult == "Win" then
        titleText = "Stage Finished!"
        embedColor = 0x57F287
    elseif gameResult == "Defeat" or gameResult == "Loss" then
        titleText = "Stage Failed!"
        embedColor = 0xED4245
    end
    
     data = {
        username = "LixHub",
        embeds = {{
            title = titleText,
            description = currentMapName .. " - " .. gameResult,
            color = embedColor,
            fields = {
                { name = "Player", value = playerName, inline = true },
                { name = "Duration", value = durationText, inline = true }, -- This now includes challenge info
                { name = "Waves Completed", value = tostring(lastWave), inline = true },
                { name = "Rewards", value = rewardsText, inline = false },
            },
            footer = { text = footerText },
            timestamp = timestamp
        }}
    }
        end
        
        local payload = Services.HttpService:JSONEncode(data)
        
        -- Try different executor HTTP functions
        local requestFunc = syn and syn.request or request or http_request or 
                        (fluxus and fluxus.request) or getgenv().request
        
        if not requestFunc then
            print("No HTTP function found! Your executor might not support HTTP requests.")
            return
        end
        
        local success, response = pcall(function()
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end)
        
        if success and response and (response.StatusCode == 204 or response.StatusCode == 200) then
            if messageType == "unit_drop" then
                notify(nil, "Unit drop webhook sent!")
            elseif messageType == "stage" then
                notify(nil, "Game summary webhook sent!")
            else
                notify(nil, "Webhook sent successfully!")
            end
        else
            print("Webhook failed:", response and response.StatusCode or "No response")
        end
    end

local function startGameTracking()
    if gameInProgress then return end
    
    State.failsafeActive = false
    gameInProgress = true
    sessionItems = {}
    gameStartTime = tick()  -- Always track game start time
    startStats = captureStats()
    macroHasPlayedThisGame = false  -- Reset macro play flag
    
    -- Get both map name and challenge info
    currentMapName, currentChallenge = getMapInfo()
    gameResult = "In Progress"
    
    print("Game tracking started!")
    print("Map: " .. currentMapName)
    print("Game start time recorded:", gameStartTime)
    if currentChallenge then
        print("Challenge: " .. currentChallenge)
    end
end

    -- Function to end game tracking
local function endGameTracking()
    if not gameInProgress then return end
    
    print("Game ended! Sending summary...")
    
    -- Send summary webhook
    if State.SendStageCompletedWebhook then
        sendWebhook("stage")
    end
    
    -- Reset tracking
    gameInProgress = false
    sessionItems = {}
    gameStartTime = 0
    lastWave = 0
    startStats = {}
    endStats = {}
    currentMapName = "Unknown Map"
    currentChallenge = nil -- Clear challenge info
    gameResult = "Unknown"
end

local function monitorWaves()
    if not Services.Workspace:FindFirstChild("_wave_num") then
        print("Waiting for _wave_num...")
        Services.Workspace:WaitForChild("_wave_num")
    end
    
    local waveNum = Services.Workspace._wave_num
    
    waveNum.Changed:Connect(function(newWave)
        lastWave = newWave
        
        -- Game start detection (wave 1 OR if we join mid-game)
        if newWave >= 1 and not gameInProgress then
            startGameTracking()
            
            -- Start recording if it's enabled but not started yet
            if isRecording and not recordingHasStarted then
                recordingHasStarted = true
                isRecordingLoopRunning = true
                startRecordingWithSpawnIdMapping()
                --MacroStatusLabel:Set("Status: Recording active!")
                notify("Recording Started", "Game started - macro recording is now active.")
            end
        elseif newWave > 0 and gameInProgress then
            print("Wave " .. newWave .. " started")
        end
    end)
    
    -- Check initial value
    local initialWave = waveNum.Value
    if initialWave >= 1 then
        lastWave = initialWave
        startGameTracking()
        
        -- Start recording if enabled
        if isRecording and not recordingHasStarted then
            recordingHasStarted = true
            isRecordingLoopRunning = true
            startRecordingWithSpawnIdMapping()
            --MacroStatusLabel:Set("Status: Recording active!")
            notify("Recording Started", "Joined mid-game - macro recording is now active.")
        end
        
        print("Joined mid-game at wave " .. initialWave .. "!")
    end
    
    print("Monitoring wave changes for game start detection...")
end

    local function sellAllPlayerUnits()
        if not State.AutoSellEnabled then return end
        
        local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        
        if not unitsFolder then
            print("No units folder found")
            return
        end
        
        local soldCount = 0
        local unitsToSell = {}
        
        -- Collect all player-owned units first to avoid issues with collection changing during iteration
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if isOwnedByLocalPlayer(unit) then
                table.insert(unitsToSell, unit)
            end
        end
        
        -- Sell each unit
        for _, unit in pairs(unitsToSell) do
            local success = pcall(function()
                endpoints:WaitForChild(MACRO_CONFIG.SELL_REMOTE):InvokeServer(unit.Name)
            end)
            
            if success then
                soldCount = soldCount + 1
                print("Sold unit:", unit.Name)
            else
                warn("Failed to sell unit:", unit.Name)
            end
            
            task.wait(0.1) -- Small delay to prevent overwhelming the server
        end
        
        if soldCount > 0 then
            notify("Auto Sell", string.format("Sold %d units on wave %d", soldCount, State.AutoSellWave))
            print(string.format("Auto-sold %d units on wave %d", soldCount, State.AutoSellWave))
        end
    end

    local function sellAllFarmUnits()
        if not State.AutoSellFarmEnabled then return end
        
        local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        
        if not unitsFolder then
            print("No units folder found")
            return
        end
        
        local soldCount = 0
        local farmUnitsToSell = {}
        
        -- Collect all farm units first
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if isOwnedByLocalPlayer(unit) then
                local stats = unit:FindFirstChild("_stats")
                if stats then
                    local farmAmount = stats:FindFirstChild("farm_amount")
                    if farmAmount and farmAmount.Value and farmAmount.Value > 0 then
                        table.insert(farmUnitsToSell, {
                            unit = unit,
                            farmAmount = farmAmount.Value
                        })
                        print("Found farm unit:", unit.Name, "with farm_amount:", farmAmount.Value)
                    end
                end
            end
        end
        
        -- Sell each farm unit
        for _, unitData in pairs(farmUnitsToSell) do
            local unit = unitData.unit
            local success = pcall(function()
                endpoints:WaitForChild(MACRO_CONFIG.SELL_REMOTE):InvokeServer(unit.Name)
            end)
            
            if success then
                soldCount = soldCount + 1
                print("Sold farm unit:", unit.Name, "with farm_amount:", unitData.farmAmount)
            else
                warn("Failed to sell farm unit:", unit.Name)
            end
            
            task.wait(0.1) -- Small delay to prevent overwhelming the server
        end
        
        if soldCount > 0 then
            notify("Auto Sell Farm", string.format("Sold %d farm units on wave %d", soldCount, State.AutoSellFarmWave))
            print(string.format("Auto-sold %d farm units on wave %d", soldCount, State.AutoSellFarmWave))
        else
            print("No farm units found to sell on wave", State.AutoSellFarmWave)
        end
    end

    local function monitorWavesForAutoSell()
        if not Services.Workspace:FindFirstChild("_wave_num") then
            Services.Workspace:WaitForChild("_wave_num")
        end
        
        local waveNum = Services.Workspace._wave_num
        local lastProcessedWave = 0
        
        waveNum.Changed:Connect(function(newWave)
            if State.AutoSellEnabled and newWave == State.AutoSellWave and newWave ~= lastProcessedWave then
                lastProcessedWave = newWave
                print("Auto-sell triggered on wave", newWave)
                
                -- Small delay to ensure wave has properly started
                task.wait(0.5)
                sellAllPlayerUnits()
            end
        end)
        
        -- Check initial wave value
        local currentWave = waveNum.Value
        if State.AutoSellEnabled and currentWave == State.AutoSellWave and currentWave ~= lastProcessedWave then
            lastProcessedWave = currentWave
            task.wait(0.5)
            sellAllPlayerUnits()
        end
    end

    local function monitorWavesForAutoSellFarm()
        if not Services.Workspace:FindFirstChild("_wave_num") then
            Services.Workspace:WaitForChild("_wave_num")
        end
        
        local waveNum = Services.Workspace._wave_num
        local lastProcessedFarmWave = 0
        
        waveNum.Changed:Connect(function(newWave)
            if State.AutoSellFarmEnabled and newWave == State.AutoSellFarmWave and newWave ~= lastProcessedFarmWave then
                lastProcessedFarmWave = newWave
                print("Auto-sell farm units triggered on wave", newWave)
                
                -- Small delay to ensure wave has properly started
                task.wait(0.5)
                sellAllFarmUnits()
            end
        end)
        
        -- Check initial wave value
        local currentWave = waveNum.Value
        if State.AutoSellFarmEnabled and currentWave == State.AutoSellFarmWave and currentWave ~= lastProcessedFarmWave then
            lastProcessedFarmWave = currentWave
            task.wait(0.5)
            sellAllFarmUnits()
        end
    end

    local function monitorWavesForRecording()
        if Services.Workspace:FindFirstChild("_wave_num") then
            local waveNum = Services.Workspace._wave_num
            
            waveNum.Changed:Connect(function(newWave)
                if isRecording and recordingHasStarted then
                    print(string.format("Wave %d started during recording", newWave))
                end
            end)
        end
    end

    local function getBackendWorldKeyFromDisplayName(selectedDisplayName)
        local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
        local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
        
        if not WorldsFolder or not WorldLevelOrder or not WorldLevelOrder.WORLD_ORDER then
            return nil
        end
        
        for _, orderedWorldKey in ipairs(WorldLevelOrder.WORLD_ORDER) do
            local worldModules = WorldsFolder:GetChildren()
            
            for _, worldModule in ipairs(worldModules) do
                if worldModule:IsA("ModuleScript") then
                    local success, worldData = pcall(require, worldModule)
                    
                    if success and worldData and worldData[orderedWorldKey] then
                        local worldInfo = worldData[orderedWorldKey]
                        
                        if type(worldInfo) == "table" and worldInfo.name then
                            if worldInfo.name == selectedDisplayName then
                                return orderedWorldKey
                            end
                        end
                        break
                    end
                end
            end
        end
        
        return nil
    end

    local function getBackendLegendWorldKeyFromDisplayName(selectedDisplayName)
        local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
        local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
        
        if not WorldsFolder or not WorldLevelOrder or not WorldLevelOrder.LEGEND_WORLD_ORDER then
            return nil
        end
        
        -- Only search through legend worlds that are in LEGEND_WORLD_ORDER
        for _, orderedWorldKey in ipairs(WorldLevelOrder.LEGEND_WORLD_ORDER) do
            -- Get all world modules to find the one containing this world
            local worldModules = WorldsFolder:GetChildren()
            
            for _, worldModule in ipairs(worldModules) do
                if worldModule:IsA("ModuleScript") then
                    local success, worldData = pcall(require, worldModule)
                    
                    if success and worldData and worldData[orderedWorldKey] then
                        local worldInfo = worldData[orderedWorldKey]
                        
                        if type(worldInfo) == "table" and worldInfo.name and worldInfo.legend_stage then
                            if worldInfo.name == selectedDisplayName then
                                return orderedWorldKey -- Return the backend world key like "Shibuya_legend"
                            end
                        end
                        break -- Found the world, no need to check other modules
                    end
                end
            end
        end
        
        return nil
    end


    local function getBackendRaidWorldKeyFromDisplayName(selectedDisplayName)
        local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
        local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
        
        if not WorldsFolder or not WorldLevelOrder or not WorldLevelOrder.RAID_WORLD_ORDER then
            return nil
        end
        
        for _, orderedWorldKey in ipairs(WorldLevelOrder.RAID_WORLD_ORDER) do
            local worldModules = WorldsFolder:GetChildren()
            
            for _, worldModule in ipairs(worldModules) do
                if worldModule:IsA("ModuleScript") then
                    local success, worldData = pcall(require, worldModule)
                    
                    if success and worldData and worldData[orderedWorldKey] then
                        local worldInfo = worldData[orderedWorldKey]
                        
                        if type(worldInfo) == "table" and worldInfo.raid_world and worldInfo.name == selectedDisplayName then
                            return orderedWorldKey .. "_Raid"
                        end
                        break
                    end
                end
            end
        end
        
        return nil
    end

    local function isInLobby()
        return Services.Workspace:FindFirstChild("_MAP_CONFIG").IsLobby.Value
    end

    local function canPerformAction()
        return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
    end

local function setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()

    if action == "Story Auto Join" then
        local joinType = State.AutoMatchmakeStoryStage and "Matchmaking" or "Solo joining"
        notify("Auto Joiner: ", string.format(
            "%s %s%s [%s]",
            joinType,
            State.StoryStageSelected or "?",
            State.StoryActSelected or "?",
            State.StoryDifficultySelected or "?"
        ))
    elseif action == "Legend Stage Auto Join" then
        local joinType = State.AutoMatchmakeLegendStage and "Matchmaking" or "Solo joining"
        notify("Auto Joiner: ", string.format(
            "%s %s%s",
            joinType,
            string.lower(State.LegendStageSelected) or "?",
            State.LegendActSelected or "?"
        ))
    elseif action == "Raid Auto Join" then
        local joinType = State.AutoMatchmakeRaidStage and "Matchmaking" or "Solo joining"
        notify("Auto Joiner: ", string.format(
            "%s %s%s",
            joinType,
            string.lower(State.RaidStageSelected) or "?",
            State.RaidActSelected or "?"
        ))
    elseif action == "Gate Auto Join" then
        notify("Auto Joiner: ","Attempting to join gate...")
    elseif action == "Challenge Auto Join" then
        notify("Auto Joiner: ","Attempting to join challenge...")
    elseif action == "Spirit Invasion Auto Join" then
        notify("Auto Joiner: ","Attempting to join event...")
    elseif action == "Halloween Event Auto Join" then
        notify("Auto Joiner: ","Attempting to join event...")
    elseif action == "Boss Rush Auto Join" then
        notify("Auto Joiner: ","Attempting to join Boss Rush...")
    end
end

    local function clearProcessingState()
        AutoJoinState.isProcessing = false
        AutoJoinState.currentAction = nil
    end

    local function getChallengeData()
        local success, challengeData = pcall(function()
            local getNormalChallenge = Services.ReplicatedStorage:WaitForChild("endpoints")
                :WaitForChild("client_to_server")
                :WaitForChild("get_normal_challenge")
            
            return getNormalChallenge:InvokeServer()
        end)
        
        if success and challengeData then
            print("Challenge data retrieved:", challengeData.current_challenge, "Level:", challengeData.current_level_id)
            return challengeData
        else
            print("Failed to get challenge data or no challenge available")
            return nil
        end
    end

    local lastChallengeResetTime = 0

    local function checkChallengeResetTime()
        local currentTime = os.time()
        local currentDate = os.date("!*t", currentTime) -- UTC time
        
        -- Check if we just passed :00 or :30 (challenges reset twice per hour)
        local isResetTime = (currentDate.min == 0 or currentDate.min == 30) and currentDate.sec < 10
        
        if isResetTime then
            -- If we haven't detected this reset yet
            if currentTime - lastChallengeResetTime > 600 then -- At least 10 minutes since last reset
                lastChallengeResetTime = currentTime
                
                print(string.format("Challenge reset time detected: %02d:%02d UTC", currentDate.hour, currentDate.min))
                
                -- Set flag that new challenge was detected
                State.NewChallengeDetected = true
                
                -- Get the new challenge data for logging
                task.spawn(function()
                    task.wait(0.5) -- Small delay to ensure challenge data is updated
                    local newChallenge = getChallengeData()
                    if newChallenge then
                        notify("Challenge System", string.format("New challenge available: %s", newChallenge.current_challenge or "Unknown"))
                        print("New challenge details:")
                        print("  Type:", newChallenge.current_challenge)
                        print("  Level:", newChallenge.current_level_id)
                    end
                end)
                
                notify("Challenge Reset", string.format("Challenge reset detected at %02d:%02d UTC", currentDate.hour, currentDate.min))
            end
        end
    end
    
    -- Run time check every second
    task.spawn(function()
        while true do
            task.wait(1)
            if State.ReturnToLobbyOnNewChallenge then
                checkChallengeResetTime()
            end
        end
    end)

    local function getItemIdFromDisplayName(displayName)
        local success, itemId = pcall(function()
            local ItemsModule = Services.ReplicatedStorage.Framework.Data.Items.Items_Release
            local itemsData = require(ItemsModule)
            
            -- Search through all items to find matching display name
            for itemKey, itemData in pairs(itemsData) do
                if type(itemData) == "table" and itemData.name == displayName then
                    return itemData.id
                end
            end
            
            return nil
        end)
        
        return success and itemId or nil
    end

    local rewardMappingsCache = {}
    local function buildRewardMappingsCache()
        if next(rewardMappingsCache) then
            return -- Already built
        end
        
        -- Static mappings for non-item rewards
        rewardMappingsCache = {
            ["gems"] = {"gems"},
            ["xp"] = {"exp"},
            ["gold"] = {"gold"},
            ["trait crystals"] = {"traitcrystal"},
            ["evolution crystals"] = {"evolutioncrystal"}, 
            ["summon tickets"] = {"summonticket"},
            ["legendary summon tickets"] = {"legendaryticket"},
            ["star remnants"] = {"starfruit"},
            ["capsules"] = {"capsule"},
            ["units"] = {"unit"},
            ["crates"] = {"crate"},
            ["boosters"] = {"booster"}
        }
        
        -- Add stone mappings from Items module
        local stoneDisplayNames = {
            "Air Stone", "Earth Stone", "Fire Stone", "Fear Stone", 
            "Water Stone", "Divine Stone"
        }
        
        for _, stoneName in ipairs(stoneDisplayNames) do
            local itemId = getItemIdFromDisplayName(stoneName)
            if itemId then
                rewardMappingsCache[string.lower(stoneName)] = {itemId}
                print("Mapped stone:", stoneName, "->", itemId)
            else
                warn("Could not find item ID for stone:", stoneName)
            end
        end
    end

    local function checkChallengeRewards(challengeData)
        if not challengeData or not challengeData._show_rewards or #State.ChallengeRewardsFilter == 0 then
            return true -- If no filter set or no rewards data, accept all challenges
        end
        
        -- Build mappings cache if not already built
        buildRewardMappingsCache()
        
        -- Check if challenge contains any of the desired rewards
        for rewardName, rewardData in pairs(challengeData._show_rewards) do
            if rewardData.type == "item" and rewardData.params then
                local itemId = rewardData.params.item_id
                
                -- Check against our filter
                for _, desiredReward in ipairs(State.ChallengeRewardsFilter) do
                    local desiredLower = string.lower(desiredReward)
                    local itemIdLower = string.lower(itemId)
                    
                    -- First check direct matches
                    if itemIdLower == desiredLower or 
                    string.find(itemIdLower, desiredLower) or
                    string.find(desiredLower, itemIdLower) then
                        print("Found direct matching reward:", itemId, "matches filter:", desiredReward)
                        return true
                    end
                    
                    -- Check against cached mappings
                    local mappedRewards = rewardMappingsCache[desiredLower]
                    if mappedRewards then
                        for _, mappedReward in ipairs(mappedRewards) do
                            if itemIdLower == string.lower(mappedReward) or 
                            string.find(itemIdLower, string.lower(mappedReward)) then
                                print("Found mapped reward:", itemId, "matches mapped filter:", mappedReward, "for:", desiredReward)
                                return true
                            end
                        end
                    end
                end
            end
        end
        
        print("No matching rewards found in challenge")
        return false
    end

    local function getWorldNameFromLevelId(levelId)
        local success, worldName = pcall(function()
            local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
            
            -- Search through all world modules
            for _, worldModule in ipairs(WorldsFolder:GetChildren()) do
                if worldModule:IsA("ModuleScript") then
                    local moduleSuccess, worldData = pcall(require, worldModule)
                    
                    if moduleSuccess and worldData then
                        -- Search through each world in this module
                        for worldKey, worldInfo in pairs(worldData) do
                            if type(worldInfo) == "table" and worldInfo.name then
                                -- Check regular levels
                                if worldInfo.levels then
                                    for levelNum, levelData in pairs(worldInfo.levels) do
                                        if levelData.id == levelId then
                                            return worldInfo.name
                                        end
                                    end
                                end
                                
                                -- Check infinite mode
                                if worldInfo.infinite and worldInfo.infinite.id == levelId then
                                    return worldInfo.name
                                end
                                
                                -- Check legend stages
                                if worldInfo.legend_stage and worldInfo.legend_stage.levels then
                                    for levelNum, levelData in pairs(worldInfo.legend_stage.levels) do
                                        if levelData.id == levelId then
                                            return worldInfo.name
                                        end
                                    end
                                end
                                
                                -- Check raid levels (if they exist in similar structure)
                                if worldInfo.raid_world and worldInfo.raid_levels then
                                    for levelNum, levelData in pairs(worldInfo.raid_levels) do
                                        if levelData.id == levelId then
                                            return worldInfo.name
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            return nil
        end)
        
        return success and worldName or nil
    end

    local function checkIgnoreWorlds(challengeData)
        if not challengeData or #State.IgnoreWorlds == 0 then
            return false -- Don't ignore if no worlds specified
        end
        
        local challengeLevelId = challengeData.current_level_id or ""
        
        -- Get the actual world name from the level ID
        local worldName = getWorldNameFromLevelId(challengeLevelId)
        
        if not worldName then
            print("Could not determine world name for level ID:", challengeLevelId)
            return false
        end
        
        print("Challenge is from world:", worldName, "(Level ID:", challengeLevelId .. ")")
        
        -- Check if this world should be ignored
        for _, ignoredWorld in ipairs(State.IgnoreWorlds) do
            if string.lower(worldName) == string.lower(ignoredWorld) then
                print("Ignoring challenge based on world filter:", ignoredWorld)
                return true
            end
        end
        
        return false
    end

    local function joinChallenge()
    local challengeData = getChallengeData()
    
    if not challengeData then
        print("No challenge data available")
        return false
    end

    -- Check if we should ignore this challenge based on world
    if checkIgnoreWorlds(challengeData) then
        print("Skipping challenge due to ignored world")
        State.challengeJoinAttempts = 0 -- Reset counter for skipped challenges
        return false
    end

    -- Check if challenge has desired rewards
    if not checkChallengeRewards(challengeData) then
        print("Challenge doesn't contain desired rewards, skipping")
        State.challengeJoinAttempts = 0 -- Reset counter for skipped challenges
        return false
    end

    -- Attempt to join the challenge
    print("Challenge passed all filters, attempting to join...")
    print("Challenge type:", challengeData.current_challenge)
    print("Challenge level:", challengeData.current_level_id)

    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("ChallengePod1")
        task.wait(0.5)
        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("ChallengePod1")
    end)

    if success then
        notify("Challenge Joiner", string.format("Joining challenge: %s", challengeData.current_challenge or "Unknown"))
        State.challengeJoinAttempts = 0 -- Reset on success
        return true
    else
        notify("Challenge Joiner", "Failed to join challenge")
        return false
    end
end

    local function getAvailableGates()
        local gates = {}
        local gatesFolder = Services.Workspace:FindFirstChild("_GATES")
        
        if not gatesFolder or not gatesFolder:FindFirstChild("gates") then
            return gates
        end
        
        for i = 1, 6 do
            local gateFolder = gatesFolder.gates:FindFirstChild(tostring(i))
            if gateFolder then
                local gateType = gateFolder:FindFirstChild("GateType")
                local currentChallenge = gateFolder:FindFirstChild("current_challenge")
                
                if gateType and currentChallenge then
                    table.insert(gates, {
                        id = i,
                        type = gateType.Value,
                        modifier = currentChallenge.Value
                    })
                end
            end
        end
        
        return gates
    end

    local function isGateTypeAllowed(gateType)
        for _, avoidType in ipairs(State.AvoidGateTypes) do
            if gateType == avoidType then
                return false
            end
        end
        return true
    end

    local function isModifierAllowed(modifier)
        for _, avoidModifier in ipairs(State.AvoidModifiers) do
            if modifier == avoidModifier then
                return false
            end
        end
        return true
    end

    local function findBestGate()
        local availableGates = getAvailableGates()
        
        if #availableGates == 0 then
            return nil
        end
        
        -- Filter out avoided gates and modifiers
        local acceptableGates = {}
        for _, gate in ipairs(availableGates) do
            if isGateTypeAllowed(gate.type) and isModifierAllowed(gate.modifier) then
                table.insert(acceptableGates, gate)
            end
        end
        
        if #acceptableGates == 0 then
            print("No acceptable gates found after filtering")
            return nil
        end
        
        -- Priority order for gates (S is best, D is worst)
        local gatePriorityOrder = {"National","S", "A", "B", "C", "D"}
        
        -- Sort acceptable gates by priority (best first)
        table.sort(acceptableGates, function(a, b)
            local aPriority = 999
            local bPriority = 999
            
            for i, priority in ipairs(gatePriorityOrder) do
                if a.type == priority then aPriority = i end
                if b.type == priority then bPriority = i end
            end
            
            return aPriority < bPriority
        end)
        
        -- Return the best acceptable gate
        return acceptableGates[1]
    end

    local function joinGate(gateInfo, useMatchmaking)
        if not gateInfo then return false end
        
        if useMatchmaking then
        local success = pcall(function()
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer("_GATE",{GateUuid = tonumber(gateInfo.id)})
        end)
        if success then
            notify("Gate Matchmaking", string.format("Matchmaking for %s Gate with %s modifier", gateInfo.type, gateInfo.modifier))
            return true
        else
            notify("Gate Joiner", "Failed to matchmake gate")
            return false
        end
    else
        local success = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("_GATE"..gateInfo.id)

            task.wait(0.5)

            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("_GATE"..gateInfo.id)

            print("Would join gate", gateInfo.id, "with type", gateInfo.type, "and modifier", gateInfo.modifier)
        end)
        
        if success then
            notify("Gate Joiner", string.format("Joining %s Gate with %s modifier", gateInfo.type, gateInfo.modifier))
            return true
        else
            notify("Gate Joiner", "Failed to join gate")
            return false
        end
    end
end

local function getPortalUUID(portalId)
    local itemsGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("items")
    
    if not itemsGui then
        warn("Items GUI not found")
        return nil
    end
    
    local itemFrames = itemsGui:FindFirstChild("grid")
    if itemFrames then
        itemFrames = itemFrames:FindFirstChild("List")
    end
    if itemFrames then
        itemFrames = itemFrames:FindFirstChild("Outer")
    end
    if itemFrames then
        itemFrames = itemFrames:FindFirstChild("ItemFrames")
    end
    
    if not itemFrames then
        warn("ItemFrames not found in PlayerGui")
        return nil
    end

    print("Searching for portal with identifier:", portalId)
    
    -- Search for the portal item by ID
    for _, child in ipairs(itemFrames:GetChildren()) do
        if child.Name == portalId then
            -- Look for _uuid or id Value object
            local uuidValue = child:FindFirstChild("_uuid_or_id")
            
            if uuidValue and uuidValue:IsA("StringValue") then
                print("Found portal UUID:", uuidValue.Value, "for portal:", portalId)
                return uuidValue.Value
            else
                warn("UUID/ID not found in portal item:", portalId)
                return nil
            end
        end
    end
    
    warn("Portal item not found in ItemFrames:", portalId)
    return nil
end

local function getOwnedPortalsFromInventory()
    local ownedPortals = {} -- {id = uuid}

    local portalNameToIdMap = {
        ["portal_christmas"] = "ChristmasLevel",
        -- Add more mappings here if there are other mismatched portals
    }
    
    local itemsGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("items")
    if not itemsGui then 
        print("Items GUI not found")
        return ownedPortals 
    end

    local itemFrames = itemsGui:FindFirstChild("grid")
    if itemFrames then itemFrames = itemFrames:FindFirstChild("List") end
    if itemFrames then itemFrames = itemFrames:FindFirstChild("Outer") end
    if itemFrames then itemFrames = itemFrames:FindFirstChild("ItemFrames") end
    
    if not itemFrames then 
        print("ItemFrames not found")
        return ownedPortals 
    end

    -- Scan through all inventory items
    for _, child in ipairs(itemFrames:GetChildren()) do
        local inventoryName = child.Name  -- "portal_christmas"
        
        -- Only process items that contain "portal" in their name
        if inventoryName and inventoryName:lower():find("portal") then
            local uuidValue = child:FindFirstChild("_uuid_or_id")

            if uuidValue and uuidValue:IsA("StringValue") then
                -- Check if there's a manual mapping first
                local actualPortalId = portalNameToIdMap[inventoryName] or inventoryName
                
                ownedPortals[actualPortalId] = uuidValue.Value
                print("Found owned portal:", inventoryName, "| Mapped to ID:", actualPortalId, "| UUID:", uuidValue.Value)
            end
        end
    end
    
    return ownedPortals
end

local function joinPortal(portalId)
    if not portalId then return false end
    
    print("Attempting to join portal with ID:", portalId)
    
    -- Get UUID from inventory
    local ownedPortals = getOwnedPortalsFromInventory()
    local portalUUID = ownedPortals[portalId]
    
    if not portalUUID then
        notify("Portal Joiner", "Portal not found in inventory - do you own this portal?")
        print("Failed to find UUID for portal ID:", portalId)
        return false
    end
    
    print("Found portal UUID:", portalUUID, "for ID:", portalId)
    
    local success = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("endpoints")
            :WaitForChild("client_to_server")
            :WaitForChild("use_portal")
            :InvokeServer(portalUUID)
    end)
    
    if success then
        notify("Portal Joiner", string.format("Joining portal: %s", portalId))
        print("Successfully called use_portal with UUID:", portalUUID)
        
        task.wait(0.5)
        
        game:GetService("ReplicatedStorage")
            :WaitForChild("endpoints")
            :WaitForChild("client_to_server")
            :WaitForChild("request_start_game")
            :InvokeServer(portalUUID)
            
        return true
    else
        notify("Portal Joiner", "Failed to join portal")
        return false
    end
end

    local function checkGateJoin()
        if not State.AutoJoinGate then return false end
        if not isInLobby() then return false end
        if AutoJoinState.isProcessing then return false end
        if not canPerformAction() then return false end
        
        local bestGate = findBestGate()
        if bestGate then
            setProcessingState("Gate Auto Join")

            local useMatchmaking = State.AutoMatchmakeGateStage or false
            
            if joinGate(bestGate, useMatchmaking) then
                print("Successfully initiated gate join!")
            else
                print("Gate join failed!")
            end
            
            task.delay(5, clearProcessingState)
            return true
        end
        
        return false
    end

    local function checkAndExecuteHighestPriority()
        if not isInLobby() then return end
        if AutoJoinState.isProcessing then return end
        if not canPerformAction() then return end

        if checkGateJoin() then return end

        if State.AutoJoinChallenge then
        local challengeData = getChallengeData()
        if challengeData then
            setProcessingState("Challenge Auto Join")
            
            local joinSuccess = joinChallenge()
            
            if joinSuccess then
                print("Successfully initiated challenge join!")
                State.challengeJoinAttempts = 0 -- Reset counter on success
            else
                State.challengeJoinAttempts = State.challengeJoinAttempts + 1
                print(string.format("Challenge join failed! Attempt %d/%d", State.challengeJoinAttempts, State.maxChallengeAttempts))
                
                if State.challengeJoinAttempts >= State.maxChallengeAttempts then
                    notify("Challenge Joiner", string.format("Failed %d times - trying other options", State.maxChallengeAttempts))
                    print("Max challenge attempts reached, falling through to other join options")
                    State.challengeJoinAttempts = 0 -- Reset counter
                    -- Don't return here - let it fall through to next priority
                else
                    -- Still have attempts left, wait and return to try again
                    task.delay(5, clearProcessingState)
                    return
                end
            end
            
            task.delay(5, clearProcessingState)
            if joinSuccess or State.challengeJoinAttempts >= State.maxChallengeAttempts then
                return -- Only return if successful or max attempts reached
            end
        end
    end

    if State.AutoJoinPortal and State.SelectedPortal and State.SelectedPortal ~= "" then
        setProcessingState("Portal Auto Join")
        
        if joinPortal(State.SelectedPortal) then
            print("Successfully initiated portal join!")
        else
            print("Portal join failed!")
        end
        
        task.delay(5, clearProcessingState)
        return
    end

    --BOSS RUSH
    if State.AutoJoinBossRush then
        setProcessingState("Boss Rush Auto Join")

        if State.AutoJoinBossRushSelectionMode then
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("_CSM_BOSSRUSH_TRAITLESS")
             task.wait(0.5) 
             game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("_CSM_BOSSRUSH_TRAITLESS") 
        else
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("_CSM_BOSSRUSH_TRAITS")
            task.wait(0.5)
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("_CSM_BOSSRUSH_TRAITS")
        end
            task.delay(5, clearProcessingState)
            return
    end

    --SPIRIT INVASION
        if State.AutoJoinSpiritInvasion then
            setProcessingState("Spirit Invasion Auto Join")

            if State.AutoMatchmakeSpiritInvasion then
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer("_EVENT_MOB_")
        else
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("_EVENT_MOB_")
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("_EVENT_MOB_")
        end
            task.delay(5, clearProcessingState)
            return
        end

        --HALLOWEEN
                if State.AutoJoinHalloween then
            setProcessingState("Halloween Event Auto Join")

            if State.AutoMatchmakeHalloween then
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer("_EVENT_HALLOWEEN_")
        else
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("_EVENT_HALLOWEEN_")
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("_EVENT_HALLOWEEN_")
        end
            task.delay(5, clearProcessingState)
            return
        end

        if State.AutoJoinInfinityCastle then
            setProcessingState("Infinity Castle Auto Join")

            local roomNumber = tonumber(string.match(Services.Players.LocalPlayer.PlayerGui.InfinityCastle.Main.Frame.core.Room.Text, "%d+"))
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower:InvokeServer(roomNumber,"Normal",false)
            task.delay(5, clearProcessingState)
            return
        end

        -- STORY
        if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and State.StoryDifficultySelected then
            setProcessingState("Story Auto Join")

            -- Build the complete stage ID
            local completeStageId = State.StoryStageSelected .. State.StoryActSelected

            if State.AutoMatchmakeStoryStage then      
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer(completeStageId,{Difficulty = State.StoryDifficultySelected})
        else
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("P1")

                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer("P1",completeStageId,false,State.StoryDifficultySelected)
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("P1")
        end
            task.delay(5, clearProcessingState)
            return
        end

        -- LEGEND STAGE
        if State.AutoJoinLegendStage and State.LegendStageSelected and State.LegendActSelected then
            setProcessingState("Legend Stage Auto Join")

            -- Build the complete legend stage ID
            local completeLegendStageId = State.LegendStageSelected .. State.LegendActSelected

            if State.AutoMatchmakeLegendStage then            
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer(string.lower(completeLegendStageId),{Difficulty = "Normal"})
        else
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("P1")

                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer("P1",string.lower(completeLegendStageId),false,"Hard")

                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("P1")
        end
            task.delay(5, clearProcessingState)
            return
        end
        if State.AutoJoinRaid and State.RaidStageSelected and State.RaidActSelected then
            setProcessingState("Raid Auto Join")

            local completeRaidStageId = State.RaidStageSelected .. State.RaidActSelected

             if State.AutoMatchmakeRaidStage then        
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer(completeRaidStageId,{Difficulty = "Normal"})
        else

            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("R1")

                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer("R1",completeRaidStageId,false,"Hard")

                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("R1")
        end
            task.delay(5, clearProcessingState)
            return
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
    --Remotes.SettingEvent:FireServer(unpack({"Abilities VFX", false}))
    --Remotes.SettingEvent:FireServer(unpack({"Hide Cosmetic", true}))
    --Remotes.SettingEvent:FireServer(unpack({"Low Graphic Quality", true}))
    --Remotes.SettingEvent:FireServer(unpack({"HeadBar", false}))
    --Remotes.SettingEvent:FireServer(unpack({"Display Players Units", false}))
    --Remotes.SettingEvent:FireServer(unpack({"DisibleGachaChat", true}))
    --Remotes.SettingEvent:FireServer(unpack({"DisibleDamageText", true}))
    --Services.Players.LocalPlayer.PlayerGui.HUD.InGame.Main.BOTTOM.Visible = false
    --Services.Players.LocalPlayer.PlayerGui.Notification.Enabled = false
        else
            --Services.Players.LocalPlayer.PlayerGui.HUD.InGame.Main.BOTTOM.Visible = true
            --Services.Players.LocalPlayer.PlayerGui.Notification.Enabled = true
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

    GameSection = LobbyTab:CreateSection("🏨 Lobby 🏨")

    Button = LobbyTab:CreateButton({
            Name = "Return to lobby",
            Callback = function()
                notify("Return to lobby", "Returning to lobby!")
                Services.TeleportService:Teleport(107573139811370, Services.Players.LocalPlayer)
        end,
    })

    local function isGameDataLoaded()
        return Services.ReplicatedStorage:FindFirstChild("Framework") and
            Services.ReplicatedStorage.Framework:FindFirstChild("Data") and
            Services.ReplicatedStorage.Framework.Data:FindFirstChild("WorldLevelOrder") and
            Services.ReplicatedStorage.Framework.Data:FindFirstChild("Worlds")
    end

    -- ========== CREATE UI SECTIONS ==========

    section = JoinerTab:CreateSection("Story Joiner")

     AutoJoinStoryToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Story",
        CurrentValue = false,
        Flag = "AutoJoinStory",
        Callback = function(Value)
            State.AutoJoinStory = Value
        end,
    })

    local StoryStageDropdown = JoinerTab:CreateDropdown({
        Name = "Select Stage",
        Options = {},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "StageStorySelector",
        Callback = function(Option)
            -- Safety check - don't run if data isn't loaded yet
            if not isGameDataLoaded() then
                warn("Game data not loaded yet, ignoring story stage selection")
                return
            end
            
            -- Handle both table and string inputs safely
            local selectedDisplayName
            if type(Option) == "table" and Option[1] then
                selectedDisplayName = Option[1]
            elseif type(Option) == "string" then
                selectedDisplayName = Option
            else
                warn("Invalid option type in StoryStageDropdown:", type(Option))
                return
            end
            
            -- Safely call the backend function with additional error handling
            local success, backendWorldKey = pcall(function()
                return getBackendWorldKeyFromDisplayName(selectedDisplayName)
            end)
            
            if success and backendWorldKey then
                State.StoryStageSelected = backendWorldKey
                print("Selected story stage:", selectedDisplayName, "->", backendWorldKey)
            else
                warn("Failed to get backend world key for story stage:", selectedDisplayName)
                if not success then
                    warn("Error:", backendWorldKey)
                end
            end
        end,
    })

     ChapterDropdown869 = JoinerTab:CreateDropdown({
        Name = "Select Story Act",
        Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinite"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "StoryActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            if selectedOption == "Infinite" then
                State.StoryActSelected = "_infinite"
            else
                local num = selectedOption:match("%d+")
                if num then
                    State.StoryActSelected = "_level_" .. num
                end
            end
        end,
    })

     ChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Story Difficulty",
        Options = {"Normal","Hard"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "StoryDifficultySelector",
        Callback = function(Option)
            local selectedOption = Option[1]
            if selectedOption == "Normal" then
                State.StoryDifficultySelected = "Normal"
            elseif selectedOption == "Hard" then
                State.StoryDifficultySelected = "Hard"
            end
        end,
    })

    section = JoinerTab:CreateSection("Legend Stage Joiner")

    AutoJoinLegendToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Legend",
        CurrentValue = false,
        Flag = "AutoJoinLegend",
        Callback = function(Value)
            State.AutoJoinLegendStage = Value
        end,
    })

    local LegendStageDropdown = JoinerTab:CreateDropdown({
        Name = "Select Legend Stage",
        Options = {},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "LegendWorldSelector",
        Callback = function(Option)
            -- Safety check - don't run if data isn't loaded yet
            if not isGameDataLoaded() then
                warn("Game data not loaded yet, ignoring legend stage selection")
                return
            end
            
            -- Handle both table and string inputs safely
            local selectedDisplayName
            if type(Option) == "table" and Option[1] then
                selectedDisplayName = Option[1]
            elseif type(Option) == "string" then
                selectedDisplayName = Option
            else
                warn("Invalid option type in LegendStageDropdown:", type(Option))
                return
            end
            
            -- Safely call the backend function
            local success, backendWorldKey = pcall(function()
                return getBackendLegendWorldKeyFromDisplayName(selectedDisplayName)
            end)
            
            if success and backendWorldKey then
                State.LegendStageSelected = backendWorldKey
                print("Selected legend stage:", selectedDisplayName, "->", backendWorldKey)
            else
                warn("Failed to get backend legend world key for:", selectedDisplayName)
                if not success then
                    warn("Error:", backendWorldKey)
                end
            end
        end,
    })

    LegendChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Legend Stage Act",
        Options = {"Act 1", "Act 2", "Act 3"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "LegendActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            
            local num = selectedOption:match("%d+")
            if num then
                State.LegendActSelected = "_" .. num
            end
        end,
    })

    MatchMakeToggle = JoinerTab:CreateToggle({
    Name = "Auto Matchmake Legend Stage",
    CurrentValue = false,
    Flag = "AutoMatchmakeLegendStage",
    Callback = function(Value)
        State.AutoMatchmakeLegendStage = Value
    end,
})

    section = JoinerTab:CreateSection("Raid Joiner")

    AutoJoinRaidToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Raid",
        CurrentValue = false,
        Flag = "AutoJoinRaid",
        Callback = function(Value)
            State.AutoJoinRaid = Value
        end,
    })

    local RaidStageDropdown = JoinerTab:CreateDropdown({
        Name = "Select Raid Stage",
        Options = {},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "RaidWorldSelector",
        Callback = function(Option)
            -- Safety check - don't run if data isn't loaded yet
            if not isGameDataLoaded() then
                warn("Game data not loaded yet, ignoring raid stage selection")
                return
            end
            
            -- Handle both table and string inputs safely
            local selectedDisplayName
            if type(Option) == "table" and Option[1] then
                selectedDisplayName = Option[1]
            elseif type(Option) == "string" then
                selectedDisplayName = Option
            else
                warn("Invalid option type in RaidStageDropdown:", type(Option))
                return
            end
            
            -- Safely call the backend function
            local success, backendWorldKey = pcall(function()
                return getBackendRaidWorldKeyFromDisplayName(selectedDisplayName)
            end)
            
            if success and backendWorldKey then
                State.RaidStageSelected = backendWorldKey
                print("Selected raid stage:", selectedDisplayName, "->", backendWorldKey)
            else
                warn("Failed to get backend raid world key for:", selectedDisplayName)
                if not success then
                    warn("Error:", backendWorldKey)
                end
            end
        end,
    })

    RaidChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Raid Stage Act",
        Options = {"Act 1", "Act 2", "Act 3","Act 4","Act 5"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "RaidActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            
            local num = selectedOption:match("%d+")
            if num then
                State.RaidActSelected = "_" .. num
            end
        end,
    })

         MatchMakeToggle = JoinerTab:CreateToggle({
    Name = "Auto Matchmake Raid Stage",
    CurrentValue = false,
    Flag = "AutoMatchmakeRaidStage",
    Callback = function(Value)
        State.AutoMatchmakeRaidStage = Value
    end,
})

    section = JoinerTab:CreateSection("Challenge Joiner")

    AutoJoinChallengeToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Challenge",
        CurrentValue = false,
        Flag = "AutoJoinChallenge",
        Callback = function(Value)
            State.AutoJoinChallenge = Value
        end,
    })

    ChallengeRewardsDropdown = JoinerTab:CreateDropdown({
        Name = "Select Challenge Rewards",
        Options = {"Air Stone","Earth Stone","Fire Stone","Fear Stone","Water Stone","Divine Stone"},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "ChallengeRewardsSelector",
        Info = "Only join challenges that contain one or more of these rewards",
        Callback = function(Options)
            State.ChallengeRewardsFilter = Options or {}
            print("Challenge rewards filter updated:", table.concat(State.ChallengeRewardsFilter, ", "))
        end,
    })

    local IgnoreWorldsDropdown = JoinerTab:CreateDropdown({
        Name = "Ignore Worlds",
        Options = {},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "IgnoreWorldsSelector",
        Info = "Skip challenges based on these worlds",
        Callback = function(Options)
            State.IgnoreWorlds = Options or {}
            print("Ignore worlds updated:", table.concat(State.IgnoreWorlds, ", "))
        end,
    })

    ReturnToLobbyToggle = JoinerTab:CreateToggle({
        Name = "Return to Lobby on New Challenge",
        CurrentValue = false,
        Flag = "ReturnToLobbyOnNewChallenge",
        Info = "Return to lobby when new challenge appears instead of using retry/next",
        Callback = function(Value)
            State.ReturnToLobbyOnNewChallenge = Value
        end,
    })

    section = JoinerTab:CreateSection("Gate Joiner")

    local GateStatusLabel = JoinerTab:CreateLabel("Gate Status: Checking...")

     AutoJoinGateToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Gate",
        CurrentValue = false,
        Flag = "AutoJoinGate",
        Callback = function(Value)
            State.AutoJoinGate = Value
        end,
    })

    AvoidGatesDropdown = JoinerTab:CreateDropdown({
        Name = "Avoid Gate Types",
        Options = {"National","S", "A", "B", "C", "D"},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "AvoidGatesSelector",
        Info = "Select gate types to avoid. Will join best available from remaining types.",
        Callback = function(Options)
            State.AvoidGateTypes = Options or {}
            print("Avoiding gate types:", table.concat(State.AvoidGateTypes, ", "))
        end,
    })

    AvoidModifiersDropdown = JoinerTab:CreateDropdown({
        Name = "Avoid Modifiers",
        Options = {"fast_enemies", "tank_enemies", "regen_enemies", "shield_enemies", "double_cost"},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "AvoidModifiersSelector",
        Info = "Select modifiers to avoid. Will join best available gate with acceptable modifier.",
        Callback = function(Options)
            State.AvoidModifiers = Options or {}
            print("Avoiding modifiers:", table.concat(State.AvoidModifiers, ", "))
        end,
    })

     AutoNextGateToggle = JoinerTab:CreateToggle({
    Name = "Auto Next Gate",
    CurrentValue = false,
    Flag = "AutoNextGate",
    Info = "Automatically pick and join next gate after game ends (requires Auto Join Gate enabled)",
    Callback = function(Value)
            State.AutoNextGate = Value
    end,
    })

             MatchMakeToggle = JoinerTab:CreateToggle({
    Name = "Auto Matchmake Gate",
    CurrentValue = false,
    Flag = "AutoMatchmakeGateStage",
    Callback = function(Value)
        State.AutoMatchmakeGateStage = Value
    end,
})

section = JoinerTab:CreateSection("Portal Joiner")

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Join Portal",
   CurrentValue = false,
   Flag = "AutoJoinPortal",
   Callback = function(Value)
        State.AutoJoinPortal = Value
   end,
})

local function getAllPortalDataFromModules()
    local portalData = {} -- {id = {name, id, moduleName}}
    
    local testingFolder = Services.ReplicatedStorage.Framework.Data.Levels.Testing
    if not testingFolder then return portalData end
    
    -- Scan all modules in the Testing folder
    for _, moduleScript in ipairs(testingFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, moduleData = pcall(require, moduleScript)
            
            if success and moduleData and type(moduleData) == "table" then
                for levelKey, levelInfo in pairs(moduleData) do
                    if type(levelInfo) == "table" and 
                       levelInfo._portal_only_level == true and 
                       levelInfo.id and 
                       levelInfo.name then
                        
                        portalData[levelInfo.id] = {
                            name = levelInfo.name,
                            id = levelInfo.id,
                            moduleName = moduleScript.Name
                        }
                        
                        print("Found portal:", levelInfo.name, "| ID:", levelInfo.id, "| Module:", moduleScript.Name)
                    end
                end
            end
        end
    end
    
    return portalData
end

local function buildPortalDropdownOptions()
    local portalModuleData = getAllPortalDataFromModules()
    local ownedPortals = getOwnedPortalsFromInventory()
    
    local dropdownOptions = {}
    
    for portalId, uuid in pairs(ownedPortals) do
        local moduleInfo = portalModuleData[portalId]
        
        if moduleInfo then
            table.insert(dropdownOptions, moduleInfo.name)
            print("Added to dropdown:", moduleInfo.name, "(Owned)")
        end
    end
    
    table.sort(dropdownOptions)
    return dropdownOptions
end

local SelectPortalDropdown = JoinerTab:CreateDropdown({
    Name = "Select Portal to join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "SelectPortalDropdown",
    Callback = function(Option)
        if not isGameDataLoaded() then
            warn("Game data not loaded yet, ignoring portal selection")
            return
        end
        
        local selectedDisplayName
        if type(Option) == "table" and Option[1] then
            selectedDisplayName = Option[1]
        elseif type(Option) == "string" then
            selectedDisplayName = Option
        else
            warn("Invalid option type in SelectPortalDropdown:", type(Option))
            return
        end
        
        -- Find the portal ID from display name
        local portalModuleData = getAllPortalDataFromModules()
        
        for portalId, moduleInfo in pairs(portalModuleData) do
            if moduleInfo.name == selectedDisplayName then
                State.SelectedPortal = portalId
                print("Selected portal:", selectedDisplayName, "| ID:", portalId)
                return
            end
        end
        
        warn("Could not find portal ID for:", selectedDisplayName)
    end,
})



RefreshPortalsButton = JoinerTab:CreateButton({
    Name = "Refresh Portal List",
    Callback = function()
        local options = buildPortalDropdownOptions()
        if #options > 0 then
            SelectPortalDropdown:Refresh(options)
            notify("Portal Refresh", string.format("Found %d owned portals", #options))
        else
            notify("Portal Refresh", "No portals found in inventory")
        end
    end,
})

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Next Portal",
   CurrentValue = false,
   Flag = "AutoNextPortal",
   Callback = function(Value)
        State.AutoNextPortal = Value
   end,
})

Toggle = JoinerTab:CreateToggle({
   Name = "Auto Select Portal Reward",
   CurrentValue = false,
   Flag = "AutoSelectPortalReward",
   Info = "Automatically picks a portal reward after completing a portal",
   Callback = function(Value)
        State.AutoSelectPortalReward = Value
   end,
})

local PortalTierFilterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Reward Tiers",
    Options = {"Tier 1", "Tier 2", "Tier 3", "Tier 4", "Tier 5", "Tier 6", "Tier 7", "Tier 8", "Tier 9", "Tier 10", "Tier 11"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PortalRewardTierFilter",
    Info = "Only pick portals with these tiers.",
    Callback = function(Options)
        State.PortalRewardTierFilter = {}
        
        -- Convert "Tier X" strings to numbers
        for _, option in ipairs(Options) do
            local tierNum = tonumber(option:match("%d+"))
            if tierNum then
                table.insert(State.PortalRewardTierFilter, tierNum)
            end
        end
    end,
})

    task.spawn(function()
        while true do
            task.wait(2)
            
            if State.AutoJoinGate then
                local availableGates = getAvailableGates()
                local acceptableGates = {}
                
                -- Count acceptable gates
                for _, gate in ipairs(availableGates) do
                    if isGateTypeAllowed(gate.type) and isModifierAllowed(gate.modifier) then
                        table.insert(acceptableGates, gate.type)
                    end
                end
                
                local statusText = string.format("Gates: %d total, %d acceptable", #availableGates, #acceptableGates)
                
                if #acceptableGates > 0 then
                    statusText = statusText .. " (" .. table.concat(acceptableGates, ", ") .. ")"
                end
                
                GateStatusLabel:Set(statusText)
            else
                GateStatusLabel:Set("Gate Status: Auto-join disabled")
            end
        end
    end)

section = JoinerTab:CreateSection("Event Joiner")

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Join Spirit Invasion",
   CurrentValue = false,
   Flag = "AutoJoinSpiritInvasion",
   Callback = function(Value)
        State.AutoJoinSpiritInvasion = Value
   end,
})

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Matchmake Spirit Invasion",
   CurrentValue = false,
   Flag = "AutoMatchmakeSpiritInvasion",
   Callback = function(Value)
        State.AutoMatchmakeSpiritInvasion = Value
   end,
})

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Join Halloween Event",
   CurrentValue = false,
   Flag = "AutoJoinHalloween",
   Callback = function(Value)
        State.AutoJoinHalloween = Value
   end,
})

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Matchmake Halloween Event",
   CurrentValue = false,
   Flag = "AutoMatchmakeHalloween",
   Callback = function(Value)
        State.AutoMatchmakeHalloween = Value
   end,
})

section = JoinerTab:CreateSection("Infinity Castle Joiner")

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Join Infinity Castle",
   CurrentValue = false,
   Flag = "AutoJoinInfinityCastle",
   Callback = function(Value)
        State.AutoJoinInfinityCastle = Value
   end,
})

Toggle = JoinerTab:CreateToggle({
    Name = "Auto Next Infinity Castle",
    CurrentValue = false,
    Flag = "AutoNextInfinityCastle",
    Info = "Automatically clicks 'Next' button after completing Infinity Castle stage",
    Callback = function(Value)
        State.AutoNextInfinityCastle = Value
    end,
})  

section = JoinerTab:CreateSection("Boss Rush Joiner")

 Toggle = JoinerTab:CreateToggle({
   Name = "Auto Join Boss Rush",
   CurrentValue = false,
   Flag = "AutoJoinBossRush",
   Callback = function(Value)
        State.AutoJoinBossRush = Value
   end,
})

 Toggle = JoinerTab:CreateToggle({
   Name = "Traits Disabled Mode",
   CurrentValue = true,
   Flag = "AutoJoinBossRushSelectionMode",
   Callback = function(Value)
        State.AutoJoinBossRushSelectionMode = Value
   end,
})

 AutoSelectCardToggle = CardPriorityTab:CreateToggle({
    Name = "Auto Select Card",
    CurrentValue = false,
    Flag = "AutoSelectCard",
    Info = "Automatically select cards based on your priority settings below. Avoid setting multiple sliders to the same value",
    Callback = function(Value)
        State.AutoSelectCard = Value
    end,
})

-- Enemy Shield Section (instead of Collapsible)
CardPriorityTab:CreateSection("Enemy Shield Priority")

CardPriorityTab:CreateSlider({
    Name = "Enemy Shield Tier 1",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemyShieldT1Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Shield"].tier1 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Enemy Shield Tier 2",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemyShieldT2Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Shield"].tier2 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Enemy Shield Tier 3",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemyShieldT3Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Shield"].tier3 = Value
    end,
})

CardPriorityTab:CreateSection("Enemy Health Priority")

CardPriorityTab:CreateSlider({
    Name = "Enemy Health Tier 1",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemyHealthT1Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Health"].tier1 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Enemy Health Tier 2",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemyHealthT2Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Health"].tier2 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Enemy Health Tier 3",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemyHealthT3Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Health"].tier3 = Value
    end,
})

-- Enemy Speed Section
CardPriorityTab:CreateSection("Enemy Speed Priority")

CardPriorityTab:CreateSlider({
    Name = "Enemy Speed Tier 1",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemySpeedT1Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Speed"].tier1 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Enemy Speed Tier 2",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemySpeedT2Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Speed"].tier2 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Enemy Speed Tier 3",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "EnemySpeedT3Priority",
    Callback = function(Value)
        State.CardPriority["Enemy Speed"].tier3 = Value
    end,
})

-- Damage Section
CardPriorityTab:CreateSection("Damage Priority")

CardPriorityTab:CreateSlider({
    Name = "Damage Tier 1",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "DamageT1Priority",
    Callback = function(Value)
        State.CardPriority["Damage"].tier1 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Damage Tier 2",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "DamageT2Priority",
    Callback = function(Value)
        State.CardPriority["Damage"].tier2 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Damage Tier 3",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "DamageT3Priority",
    Callback = function(Value)
        State.CardPriority["Damage"].tier3 = Value
    end,
})

-- Cooldown Section
CardPriorityTab:CreateSection("Cooldown Priority")

CardPriorityTab:CreateSlider({
    Name = "Cooldown Tier 1",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "CooldownT1Priority",
    Callback = function(Value)
        State.CardPriority["Cooldown"].tier1 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Cooldown Tier 2",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "CooldownT2Priority",
    Callback = function(Value)
        State.CardPriority["Cooldown"].tier2 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Cooldown Tier 3",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "CooldownT3Priority",
    Callback = function(Value)
        State.CardPriority["Cooldown"].tier3 = Value
    end,
})

-- Range Section
CardPriorityTab:CreateSection("Range Priority")

CardPriorityTab:CreateSlider({
    Name = "Range Tier 1",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "RangeT1Priority",
    Callback = function(Value)
        State.CardPriority["Range"].tier1 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Range Tier 2",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "RangeT2Priority",
    Callback = function(Value)
        State.CardPriority["Range"].tier2 = Value
    end,
})

CardPriorityTab:CreateSlider({
    Name = "Range Tier 3",
    Range = {0, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "RangeT3Priority",
    Callback = function(Value)
        State.CardPriority["Range"].tier3 = Value
    end,
})

local function getCardButtons()
    local playerGui = Services.Players.LocalPlayer.PlayerGui
    local promptGui = playerGui:FindFirstChild("Prompt")
    
    if not promptGui then return nil end
    
    local success, buttons = pcall(function()
        return promptGui:GetChildren()[2]:GetChildren()[4]:GetChildren()
    end)
    
    if success and buttons then
        local cardButtons = {}
        for _, child in ipairs(buttons) do
            if child:IsA("GuiButton") or child:IsA("TextButton") or child:IsA("ImageButton") then
                table.insert(cardButtons, child)
            end
        end
        return cardButtons
    end
    
    return nil
end

local function calculateCardScore(card)
    if not card.Effects then return 0 end
    
    local totalScore = 0
    
    for _, effect in ipairs(card.Effects) do
        local effectName = effect.Name or ""
        
        -- Determine card type and tier
        local cardType = nil
        local tier = nil
        
        -- Enemy Shield
        if effectName:find("Enemy Shield") then
            cardType = "Enemy Shield"
            if effectName:find("Tier 1") then tier = "tier1"
            elseif effectName:find("Tier 2") then tier = "tier2"
            elseif effectName:find("Tier 3") then tier = "tier3"
            end
        -- Enemy Health
        elseif effectName:find("Enemy Health") then
            cardType = "Enemy Health"
            if effectName:find("Tier 1") then tier = "tier1"
            elseif effectName:find("Tier 2") then tier = "tier2"
            elseif effectName:find("Tier 3") then tier = "tier3"
            end
        -- Enemy Speed
        elseif effectName:find("Enemy Speed") then
            cardType = "Enemy Speed"
            if effectName:find("Tier 1") then tier = "tier1"
            elseif effectName:find("Tier 2") then tier = "tier2"
            elseif effectName:find("Tier 3") then tier = "tier3"
            end
        -- Damage
        elseif effectName:find("Damage") then
            cardType = "Damage"
            if effectName:find("Tier 1") then tier = "tier1"
            elseif effectName:find("Tier 2") then tier = "tier2"
            elseif effectName:find("Tier 3") then tier = "tier3"
            end
        -- Cooldown
        elseif effectName:find("Cooldown") then
            cardType = "Cooldown"
            if effectName:find("Tier 1") then tier = "tier1"
            elseif effectName:find("Tier 2") then tier = "tier2"
            elseif effectName:find("Tier 3") then tier = "tier3"
            end
        -- Range
        elseif effectName:find("Range") then
            cardType = "Range"
            if effectName:find("Tier 1") then tier = "tier1"
            elseif effectName:find("Tier 2") then tier = "tier2"
            elseif effectName:find("Tier 3") then tier = "tier3"
            end
        end
        
        -- Add priority score
        if cardType and tier and State.CardPriority[cardType] then
            totalScore = totalScore + (State.CardPriority[cardType][tier] or 0)
        end
    end
    return totalScore
end

local function selectBestCard(cardData)
    if not cardData or #cardData == 0 then return 1 end
    
    local bestIndex = 1
    local bestScore = calculateCardScore(cardData[1])
    
    for i = 2, #cardData do
        local score = calculateCardScore(cardData[i])
        if score > bestScore then
            bestScore = score
            bestIndex = i
        end
    end
    
    return bestIndex, bestScore
end

local function autoSelectCard(cardData)
    if not cardData or #cardData == 0 then return false end
    
    local selectedIndex, score = selectBestCard(cardData)
    local selectedCard = cardData[selectedIndex]
    
    local buttons = getCardButtons()
    if not buttons or #buttons == 0 or not buttons[selectedIndex] then
        return false
    end
    
    local success = pcall(function()
        local button = buttons[selectedIndex]
        
        for _, connection in pairs(getconnections(button.MouseButton1Click)) do
            connection:Fire()
        end
        
        for _, connection in pairs(getconnections(button.Activated)) do
            connection:Fire()
        end
        
        for _, connection in pairs(getconnections(button.MouseButton1Down)) do
            connection:Fire()
        end
        task.wait(0.05)
        for _, connection in pairs(getconnections(button.MouseButton1Up)) do
            connection:Fire()
        end
    end)
    
    if success then
        local effectsText = ""
        if selectedCard.Effects then
            for i, effect in ipairs(selectedCard.Effects) do
                effectsText = effectsText .. effect.Description
                if i < #selectedCard.Effects then
                    effectsText = effectsText .. ", "
                end
            end
        end
        
        notify("Card Selected", string.format("%s (Score: %d)\n%s", 
            selectedCard.CardName, 
            score,
            effectsText:sub(1, 80)
        ))
            local promptGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Prompt")
            
            if promptGui then
                local confirmButton = promptGui:GetChildren()[2]:GetChildren()[5].Template
                
                if confirmButton then
                    -- Fire all connection types for the confirm button
                    for _, connection in pairs(getconnections(confirmButton.MouseButton1Click)) do
                        connection:Fire()
                    end
                    
                    for _, connection in pairs(getconnections(confirmButton.Activated)) do
                        connection:Fire()
                    end
                    
                    for _, connection in pairs(getconnections(confirmButton.MouseButton1Down)) do
                        connection:Fire()
                    end
                    task.wait(0.05)
                    for _, connection in pairs(getconnections(confirmButton.MouseButton1Up)) do
                        connection:Fire()
                    end
                    
                    print("Successfully clicked confirm button after card selection")
                end
            end
        return true
    end
    return false
end

local function setupCardSelectionMonitoring()
    local cardsRemote = Services.ReplicatedStorage:WaitForChild("endpoints")
        :WaitForChild("server_to_client")
        :WaitForChild("Cards")
    
    cardsRemote.OnClientEvent:Connect(function(action, cardData, waveReq, ...)
        if action == "StartSelection" then
            currentCardData = cardData
            
            if State.AutoSelectCard then
                task.spawn(function()
                    task.wait(0.1) -- Small delay for UI to load
                    
                    if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Prompt") then
                        autoSelectCard(cardData)
                    end
                end)
            end
        end
    end)
end

task.spawn(setupCardSelectionMonitoring)

    local function loadIgnoreWorldsWithRetry()
        loadingRetries.ignoreWorlds = loadingRetries.ignoreWorlds + 1
        
        if not isGameDataLoaded() then
            if loadingRetries.ignoreWorlds <= maxRetries then
                print(string.format("Ignore worlds loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.ignoreWorlds, maxRetries))
                task.wait(retryDelay)
                task.spawn(loadIgnoreWorldsWithRetry)
            else
                warn("Failed to load ignore worlds after", maxRetries, "attempts - giving up")
                IgnoreWorldsDropdown:Refresh({"Failed to load - check console"})
            end
            return
        end
        
        local success, result = pcall(function()
            local allWorlds = {}
            
            -- Get story worlds
            local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
            local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
            
            if not WorldLevelOrder then
                error("WorldLevelOrder not found")
            end
            
            if WorldLevelOrder.WORLD_ORDER then
                for _, orderedWorldKey in ipairs(WorldLevelOrder.WORLD_ORDER) do
                    local worldModules = WorldsFolder:GetChildren()
                    
                    for _, worldModule in ipairs(worldModules) do
                        if worldModule:IsA("ModuleScript") then
                            local moduleSuccess, worldData = pcall(require, worldModule)
                            
                            if moduleSuccess and worldData and worldData[orderedWorldKey] then
                                local worldInfo = worldData[orderedWorldKey]
                                
                                if type(worldInfo) == "table" and worldInfo.name then
                                    table.insert(allWorlds, worldInfo.name)
                                end
                                break
                            end
                        end
                    end
                end
            end
            
            -- Add legend worlds
            if WorldLevelOrder.LEGEND_WORLD_ORDER then
                for _, orderedWorldKey in ipairs(WorldLevelOrder.LEGEND_WORLD_ORDER) do
                    local worldModules = WorldsFolder:GetChildren()
                    
                    for _, worldModule in ipairs(worldModules) do
                        if worldModule:IsA("ModuleScript") then
                            local moduleSuccess, worldData = pcall(require, worldModule)
                            
                            if moduleSuccess and worldData and worldData[orderedWorldKey] then
                                local worldInfo = worldData[orderedWorldKey]
                                
                                if type(worldInfo) == "table" and worldInfo.name and worldInfo.legend_stage then
                                    table.insert(allWorlds, worldInfo.name .. " (Legend)")
                                end
                                break
                            end
                        end
                    end
                end
            end
            
            -- Remove duplicates and sort
            local uniqueWorlds = {}
            local seen = {}
            for _, world in ipairs(allWorlds) do
                if not seen[world] then
                    table.insert(uniqueWorlds, world)
                    seen[world] = true
                end
            end
            table.sort(uniqueWorlds)
            
            if #uniqueWorlds == 0 then
                error("No worlds found for ignore list")
            end
            
            return uniqueWorlds
        end)
        
        if success and result and #result > 0 then
            IgnoreWorldsDropdown:Refresh(result)
            print(string.format("Successfully loaded %d worlds for ignore list (attempt %d)", #result, loadingRetries.ignoreWorlds))
        else
            if loadingRetries.ignoreWorlds <= maxRetries then
                print(string.format("Ignore worlds loading failed (attempt %d/%d): %s - retrying...", loadingRetries.ignoreWorlds, maxRetries, tostring(result)))
                task.wait(retryDelay)
                task.spawn(loadIgnoreWorldsWithRetry)
            else
                warn("Failed to load ignore worlds after", maxRetries, "attempts:", result)
                IgnoreWorldsDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end

local function autoNextPortal()
    if not State.AutoNextPortal or not State.SelectedPortal or State.SelectedPortal == "" then
        return false
    end
    
    -- IMPORTANT: We need to look for the INVENTORY name, not the module ID
    -- So we need to reverse-map: ChristmasLevel -> portal_christmas
    local portalIdToInventoryName = {
        ["ChristmasLevel"] = "portal_christmas",
        ["portal_christmas_secret"] = "portal_christmas_secret",
        -- Add more reverse mappings as needed
    }
    
    local inventoryName = portalIdToInventoryName[State.SelectedPortal] or State.SelectedPortal
    
    print("Auto Next Portal - Looking for portal ID:", State.SelectedPortal, "| Inventory name:", inventoryName)
    task.wait(1)
    
    local ownedPortals = getOwnedPortalsFromInventory()
    local portalUUID = ownedPortals[State.SelectedPortal]
    
    if not portalUUID then
        notify("Auto Next Portal", "Portal not found in inventory", 3)
        return false
    end
    
    print("Found portal UUID for auto-next:", portalUUID)
    
    local success = pcall(function()
        local args = {"replay_portal", portalUUID}
        game:GetService("ReplicatedStorage")
            :WaitForChild("endpoints")
            :WaitForChild("client_to_server")
            :WaitForChild("set_game_finished_vote")
            :InvokeServer(unpack(args))
    end)
    
    if success then
        notify("Auto Next Portal", "Replaying portal", 3)
        return true
    else
        notify("Auto Next Portal", "Failed to replay portal", 3)
        return false
    end
end

-- Load portals function (simplified - no more retry logic needed)
local function loadPortals()
    local options = buildPortalDropdownOptions()
    
    if #options > 0 then
        SelectPortalDropdown:Refresh(options)
        print(string.format("Successfully loaded %d portals", #options))
    else
        print("No owned portals found")
        SelectPortalDropdown:Refresh({"No portals found"})
    end
end

    local function loadLegendStagesWithRetry()
        loadingRetries.legend = loadingRetries.legend + 1
        
        if not isGameDataLoaded() then
            if loadingRetries.legend <= maxRetries then
                print(string.format("Legend stages loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.legend, maxRetries))
                task.wait(retryDelay)
                task.spawn(loadLegendStagesWithRetry)
            else
                warn("Failed to load legend stages after", maxRetries, "attempts - giving up")
                LegendStageDropdown:Refresh({"Failed to load - check console"})
            end
            return
        end
        
        local success, result = pcall(function()
            local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
            local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
            
            if not WorldLevelOrder or not WorldLevelOrder.LEGEND_WORLD_ORDER then
                error("WorldLevelOrder or LEGEND_WORLD_ORDER not found")
            end

            local displayNames = {}
            
            for _, orderedWorldKey in ipairs(WorldLevelOrder.LEGEND_WORLD_ORDER) do
                local worldModules = WorldsFolder:GetChildren()
                
                for _, worldModule in ipairs(worldModules) do
                    if worldModule:IsA("ModuleScript") then
                        local moduleSuccess, worldData = pcall(require, worldModule)
                        
                        if moduleSuccess and worldData and worldData[orderedWorldKey] then
                            local worldInfo = worldData[orderedWorldKey]
                            
                            if type(worldInfo) == "table" and worldInfo.name and worldInfo.legend_stage then
                                table.insert(displayNames, worldInfo.name)
                            end
                            break
                        end
                    end
                end
            end
            
            if #displayNames == 0 then
                error("No legend stages found")
            end
            
            return displayNames
        end)
        
        if success and result and #result > 0 then
            LegendStageDropdown:Refresh(result)
            print(string.format("Successfully loaded %d legend stages (attempt %d)", #result, loadingRetries.legend))
        else
            if loadingRetries.legend <= maxRetries then
                print(string.format("Legend stages loading failed (attempt %d/%d): %s - retrying...", loadingRetries.legend, maxRetries, tostring(result)))
                task.wait(retryDelay)
                task.spawn(loadLegendStagesWithRetry)
            else
                warn("Failed to load legend stages after", maxRetries, "attempts:", result)
                LegendStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end

    local function loadStoryStagesWithRetry()
        loadingRetries.story = loadingRetries.story + 1
        
        if not isGameDataLoaded() then
            if loadingRetries.story <= maxRetries then
                print(string.format("Story stages loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.story, maxRetries))
                task.wait(retryDelay)
                task.spawn(loadStoryStagesWithRetry)
            else
                warn("Failed to load story stages after", maxRetries, "attempts - giving up")
                StoryStageDropdown:Refresh({"Failed to load - check console"})
            end
            return
        end
        
        local success, result = pcall(function()
            local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
            local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
            
            if not WorldLevelOrder or not WorldLevelOrder.WORLD_ORDER then
                error("WorldLevelOrder or WORLD_ORDER not found")
            end

            local displayNames = {}
            
            for _, orderedWorldKey in ipairs(WorldLevelOrder.WORLD_ORDER) do
                local worldModules = WorldsFolder:GetChildren()
                
                for _, worldModule in ipairs(worldModules) do
                    if worldModule:IsA("ModuleScript") then
                        local moduleSuccess, worldData = pcall(require, worldModule)
                        
                        if moduleSuccess and worldData and worldData[orderedWorldKey] then
                            local worldInfo = worldData[orderedWorldKey]
                            
                            if type(worldInfo) == "table" and worldInfo.name then
                                table.insert(displayNames, worldInfo.name)
                            end
                            break
                        end
                    end
                end
            end
            
            if #displayNames == 0 then
                error("No story stages found")
            end
            
            return displayNames
        end)
        
        if success and result and #result > 0 then
            StoryStageDropdown:Refresh(result)
            print(string.format("Successfully loaded %d story stages (attempt %d)", #result, loadingRetries.story))
        else
            if loadingRetries.story <= maxRetries then
                print(string.format("Story stages loading failed (attempt %d/%d): %s - retrying...", loadingRetries.story, maxRetries, tostring(result)))
                task.wait(retryDelay)
                task.spawn(loadStoryStagesWithRetry)
            else
                warn("Failed to load story stages after", maxRetries, "attempts:", result)
                StoryStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end

    local function loadRaidStagesWithRetry()
        loadingRetries.raid = loadingRetries.raid + 1
        
        if not isGameDataLoaded() then
            if loadingRetries.raid <= maxRetries then
                print(string.format("Raid stages loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.raid, maxRetries))
                task.wait(retryDelay)
                task.spawn(loadRaidStagesWithRetry)
            else
                warn("Failed to load raid stages after", maxRetries, "attempts - giving up")
                RaidStageDropdown:Refresh({"Failed to load - check console"})
            end
            return
        end
        
        local success, result = pcall(function()
            local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
            local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
            
            if not WorldLevelOrder or not WorldLevelOrder.RAID_WORLD_ORDER then
                error("WorldLevelOrder or RAID_WORLD_ORDER not found")
            end

            local displayNames = {}
            local addedWorlds = {}
            
            for _, orderedWorldKey in ipairs(WorldLevelOrder.RAID_WORLD_ORDER) do
                local worldModules = WorldsFolder:GetChildren()
                
                for _, worldModule in ipairs(worldModules) do
                    if worldModule:IsA("ModuleScript") then
                        local moduleSuccess, worldData = pcall(require, worldModule)
                        
                        if moduleSuccess and worldData and worldData[orderedWorldKey] then
                            local worldInfo = worldData[orderedWorldKey]
                            
                            if type(worldInfo) == "table" and worldInfo.name and worldInfo.raid_world then
                                if not addedWorlds[orderedWorldKey] then
                                    table.insert(displayNames, worldInfo.name)
                                    addedWorlds[orderedWorldKey] = true
                                end
                            end
                            break
                        end
                    end
                end
            end
            
            if #displayNames == 0 then
                error("No raid stages found")
            end
            
            return displayNames
        end)
        
        if success and result and #result > 0 then
            RaidStageDropdown:Refresh(result)
            print(string.format("Successfully loaded %d raid stages (attempt %d)", #result, loadingRetries.raid))
        else
            if loadingRetries.raid <= maxRetries then
                print(string.format("Raid stages loading failed (attempt %d/%d): %s - retrying...", loadingRetries.raid, maxRetries, tostring(result)))
                task.wait(retryDelay)
                task.spawn(loadRaidStagesWithRetry)
            else
                warn("Failed to load raid stages after", maxRetries, "attempts:", result)
                RaidStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end

    GameSection = GameTab:CreateSection("👥 Player 👥")

        Slider = GameTab:CreateSlider({
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

        Toggle = GameTab:CreateToggle({
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

        Toggle = GameTab:CreateToggle({
        Name = "Low Performance Mode",
        CurrentValue = false,
        Flag = "enableLowPerformanceMode",
        Callback = function(Value)
            State.enableLowPerformanceMode = Value
            enableLowPerformanceMode()
        end,
    })

    Toggle = GameTab:CreateToggle({
        Name = "Black Screen",
        CurrentValue = false,
        Flag = "enableBlackScreen",
        Callback = function(Value)
            State.enableBlackScreen = Value
            enableBlackScreen()
        end,
    })

    Toggle = LobbyTab:CreateToggle({
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

    local function updateFPSLimit()
        if State.enableLimitFPS and State.SelectedFPS > 0 then
            setfpscap(tonumber(State.SelectedFPS))
        else
            setfpscap(0)
        end
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

     Toggle = GameTab:CreateToggle({
        Name = "Streamer Mode (hide name/level/title)",
        CurrentValue = false,
        Flag = "StreamerMode",
        Callback = function(Value)
            State.streamerModeEnabled = Value
        end,
    })

    local function StreamerMode()
        local head = Services.Players.LocalPlayer.Character:WaitForChild("Head", 5)
        if not head then return end

        local billboard = head:WaitForChild("overhead_player"):WaitForChild("Frame")
        if not billboard then print("no billboard") return end

        local originalNumbers = Services.Players.LocalPlayer.PlayerGui:WaitForChild("spawn_units"):WaitForChild("Lives"):WaitForChild("Main"):FindFirstChild("Desc"):FindFirstChild("Level")
        if not originalNumbers then print("no originalnumbers") return end

        local streamerLabel = Services.Players.LocalPlayer.PlayerGui:WaitForChild("spawn_units"):WaitForChild("Lives"):WaitForChild("Main"):FindFirstChild("Desc"):FindFirstChild("streamerlabel")
        local leaderstats = Services.Players.LocalPlayer:FindFirstChild("leaderstats")
        local levelStat = leaderstats and leaderstats:FindFirstChild("Level")
        if not streamerLabel then
            streamerLabel = originalNumbers:Clone()
            streamerLabel.Name = "streamerlabel"
            streamerLabel.Text = "Level 999 - Protected by Lixhub"
            streamerLabel.Visible = false
            streamerLabel.Parent = originalNumbers.Parent
        end

        if State.streamerModeEnabled then
            billboard:FindFirstChild("Name_Frame"):FindFirstChild("Name_Text").Text = "🔥 PROTECTED BY LIXHUB 🔥"
            billboard:FindFirstChild("Level_Frame"):FindFirstChild("Level").Text = "999"

            originalNumbers.Visible = false
            streamerLabel.Visible = true
        else
            billboard:FindFirstChild("Name_Frame"):FindFirstChild("Name_Text").Text = Services.Players.LocalPlayer.Name
            if levelStat then
            billboard:FindFirstChild("Level_Frame"):FindFirstChild("Level").Text = Services.Players.LocalPlayer.leaderstats:FindFirstChild("Level").Value
            end

            originalNumbers.Visible = true
            streamerLabel.Visible = false
        end
    end

        task.spawn(function()
            while true do
                task.wait(0.1)
                StreamerMode()
            end
        end)

    if State.enableLowPerformanceMode then
        enableLowPerformanceMode()
    end

    GameSection = GameTab:CreateSection("🎮 Game 🎮")


    Toggle = GameTab:CreateToggle({
        Name = "Delete Enemies",
        CurrentValue = false,
        Flag = "enableDeleteEnemies",
        Info = "Removes Enemy Models",
        TextScaled = false,
        Callback = function(Value)
            State.deleteEntities = Value
            
            if Value then
                -- Function to check if a unit is an enemy (no player ObjectValue in _stats)
                local function isEnemy(unit)
                    local statsFolder = unit:FindFirstChild("_stats")
                    if not statsFolder then
                        return true -- No _stats folder = likely enemy
                    end

                    local maxupgradeValue = statsFolder:FindFirstChild("max_upgrade")
                    if not maxupgradeValue then 
                        return true
                    end
                    if maxupgradeValue and maxupgradeValue.Value == 0 then
                        return true
                    end
                    
                    local playerValue = statsFolder:FindFirstChild("player")
                    return not (playerValue and playerValue:IsA("ObjectValue"))
                end
                
                -- Function to safely delete enemy units
                local function deleteEnemyUnit(unit)
                    if unit and unit.Parent and isEnemy(unit) then
                        unit:Destroy()
                    end
                end
                
                task.spawn(function()
                    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
                    if unitsFolder then
                        -- Delete existing enemy units first
                        for _, unit in pairs(unitsFolder:GetChildren()) do
                            deleteEnemyUnit(unit)
                        end
                        
                        -- Set up instant deletion for new enemy spawns
                        State.childAddedConnection = unitsFolder.ChildAdded:Connect(function(child)
                            if State.deleteEntities then
                                -- Small delay to ensure the unit is fully loaded before checking
                                task.wait(0.1)
                                deleteEnemyUnit(child)
                            end
                        end)
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

    local function autoEquipMacroUnits(macroName)
    if isInLobby() then 
        print("Cannot auto-equip: Still in lobby")
        return false
    end

    if not macroName or macroName == "" then
        print("Cannot auto-equip: No macro name provided")
        return false
    end
    
    local macroData = macroManager[macroName]
    if not macroData or #macroData == 0 then
        print("Cannot auto-equip: Macro is empty")
        return false
    end
    
    -- Extract unique units from macro
    local requiredUnits = {}
    
    for _, action in ipairs(macroData) do
        if action.Type == "spawn_unit" and action.Unit then
            local unitName = action.Unit
            
            -- Extract base unit name (remove instance number like "#1", "#2")
            local baseUnitName = unitName:match("^(.+) #%d+$") or unitName
            
            requiredUnits[baseUnitName] = true
        end
    end
    
    -- Get list of required units
    local requiredUnitsList = {}
    for unitName, _ in pairs(requiredUnits) do
        table.insert(requiredUnitsList, unitName)
    end
    
    if #requiredUnitsList == 0 then
        print("No units found in macro to equip")
        return false
    end
    
    -- Check if we have all required units in our collection
    local success, result = pcall(function()
        local fxCache = Services.ReplicatedStorage:FindFirstChild("_FX_CACHE")
        if not fxCache then
            error("_FX_CACHE not found")
        end
        
        local availableUnits = {} -- {displayName: uuid}
        local missingUnits = {}
        
        -- Scan through _FX_CACHE to find available units
        for _, child in pairs(fxCache:GetChildren()) do
            local itemIndex = child:GetAttribute("ITEMINDEX")
            if itemIndex then
                local displayName = getDisplayNameFromUnitId(itemIndex)
                if displayName then
                    local uuidValue = child:FindFirstChild("_uuid")
                    if uuidValue and uuidValue:IsA("StringValue") then
                        availableUnits[displayName] = uuidValue.Value
                    end
                end
            end
        end
        
        -- Check if we have all required units
        for _, requiredUnit in ipairs(requiredUnitsList) do
            if not availableUnits[requiredUnit] then
                table.insert(missingUnits, requiredUnit)
            end
        end
        
        if #missingUnits > 0 then
            local missingText = table.concat(missingUnits, ", ")
            error("Missing units: " .. missingText)
        end
        
        return availableUnits
    end)
    
    if not success then
        print("Auto-equip failed:", result)
        notify("Auto Equip Failed", result:sub(1, 50))
        return false
    end
    
    local availableUnits = result
    
    print(string.format("Auto-equipping %d units for macro: %s", #requiredUnitsList, macroName))
    notify("Auto Equip", string.format("Equipping %d units for %s", #requiredUnitsList, macroName))
    
    -- Step 1: Unequip all current units
    local unequipSuccess = pcall(function()
        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("unequip_all"):InvokeServer()
    end)
    
    if not unequipSuccess then
        print("Failed to unequip current units")
        return false
    end
    
    print("Successfully unequipped all units")
    task.wait(0.5) -- Small delay after unequipping
    
    -- Step 2: Equip each required unit
    local equippedCount = 0
    local failedUnits = {}
    
    for _, unitName in ipairs(requiredUnitsList) do
        local unitUUID = availableUnits[unitName]
        if unitUUID then
            local equipSuccess = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("equip_unit"):InvokeServer(unitUUID)
            end)
            
            if equipSuccess then
                equippedCount = equippedCount + 1
                print("Successfully equipped:", unitName)
            else
                table.insert(failedUnits, unitName)
                print("Failed to equip:", unitName)
            end
            
            task.wait(0.2) -- Small delay between equips
        end
    end
    
    if #failedUnits == 0 then
        print(string.format("Auto-equip complete: %d/%d units equipped", equippedCount, #requiredUnitsList))
        notify("Auto Equip Complete", string.format("%d/%d units equipped", equippedCount, #requiredUnitsList))
    else
        print(string.format("Auto-equip partial: %d/%d units equipped", equippedCount, #requiredUnitsList))
        notify("Auto Equip Partial", string.format("%d/%d units equipped", equippedCount, #requiredUnitsList))
    end
    
    return true
end

local function getCurrentWorld()
    local success, levelData = pcall(function()
        return Services.Workspace._MAP_CONFIG.GetLevelData:InvokeServer()
    end)
    
    if success and levelData then
        -- Priority 1: Check if this is a portal level
        if levelData._portal_only_level == true and levelData.id then
            print("getCurrentWorld: Detected portal level, ID:", levelData.id)
            return levelData.id -- Returns "portal_tengen", "portal_tengen_secret", etc.
        end
        
        -- Priority 2: Check for world field (story/legend/raid stages)
        if levelData.world then
            print("getCurrentWorld: Using world field:", levelData.world)
            return levelData.world
        end
        
        -- Priority 3: Fallback to map field (special maps like "DoubleDungeon")
        if levelData.map then
            print("getCurrentWorld: Using map field:", levelData.map)
            return levelData.map
        end
        
        print("getCurrentWorld: No world, map, or portal ID found in levelData")
    else
        print("getCurrentWorld: Failed to get level data:", levelData)
    end
    
    return nil
end

local function getMacroForCurrentWorld()
    if isInLobby() then
        return nil
    end
    
    local currentWorld = getCurrentWorld()
    if not currentWorld then
        return nil
    end
    
    local isLegendStage = false
    local actNum = nil
    local success, levelData = pcall(function()
        return Services.Workspace._MAP_CONFIG.GetLevelData:InvokeServer()
    end)
    
    if success and levelData then
        -- Check for legend indicators
        if levelData.legend or 
           (levelData.level_id and levelData.level_id:lower():find("legend")) or
           (levelData.map and levelData.map:lower():find("legend")) then
            isLegendStage = true
        end
        
        -- FIXED: Check for ds_legend OR nightmare OR mugen_train
        if currentWorld:lower():find("ds_legend") or 
           currentWorld:lower():find("nightmare") or
           currentWorld:lower():find("mugen_train") or
           (levelData.map and (levelData.map:lower():find("nightmare") or levelData.map:lower():find("mugen_train"))) or
           (levelData.level_id and levelData.level_id:lower():find("ds_legend")) then
            
            -- Try to extract act number from map field FIRST (mugen_train_one, mugen_train_two, mugen_train_three)
            if levelData.map then
                local mapLower = levelData.map:lower()
                if mapLower:find("mugen_train_one") or mapLower:find("one") then
                    actNum = 1
                    print("Detected Nightmare Train Act 1 from map field:", levelData.map)
                elseif mapLower:find("mugen_train_two") or mapLower:find("two") then
                    actNum = 2
                    print("Detected Nightmare Train Act 2 from map field:", levelData.map)
                elseif mapLower:find("mugen_train_three") or mapLower:find("three") then
                    actNum = 3
                    print("Detected Nightmare Train Act 3 from map field:", levelData.map)
                end
            end
            
            -- Fallback: Try Waves field
            if not actNum and levelData.Waves then
                local extractedAct = levelData.Waves:match("ds_legend_(%d)$")
                if extractedAct then
                    actNum = tonumber(extractedAct)
                    print("Detected Nightmare Train Act from Waves field:", actNum)
                end
            end
            
            -- Fallback: Try level_id
            if not actNum and levelData.level_id then
                local extractedAct = levelData.level_id:match("_(%d)$")
                if extractedAct then
                    actNum = tonumber(extractedAct)
                    print("Detected Nightmare Train Act from level_id:", actNum)
                end
            end
            
            -- Fallback: Try numeric pattern in map field
            if not actNum and levelData.map then
                local extractedAct = levelData.map:match("_(%d)$")
                if extractedAct then
                    actNum = tonumber(extractedAct)
                    print("Detected Nightmare Train Act from map numeric:", actNum)
                end
            end
            
            if not actNum then
                print("Nightmare Train detected but couldn't determine act")
                print("Waves field:", levelData.Waves)
                print("level_id field:", levelData.level_id)
                print("map field:", levelData.map)
                print("Full level data:", levelData)
            end
        end
    end
    
    print("Current world:", currentWorld, "- Legend stage:", isLegendStage, "- Act:", actNum or "N/A")
    
    -- If Nightmare Train with detected act, try act-specific mapping first
    if (currentWorld:lower():find("ds_legend") or currentWorld:lower():find("nightmare") or currentWorld:lower():find("mugen_train")) and actNum then
        local nightmareKey = "ds_legend_act_" .. actNum
        local mappedMacro = worldMacroMappings[nightmareKey]
        
        if mappedMacro and macroManager[mappedMacro] then
            print("Found Nightmare Train Act", actNum, "mapping:", nightmareKey, "->", mappedMacro)
            return mappedMacro
        else
            print("No mapping found for:", nightmareKey)
        end
    end
    
    -- First try exact match for legend stages
    if isLegendStage then
        for worldKey, macroName in pairs(worldMacroMappings) do
            if worldKey:lower():find("legend") and 
               (worldKey:lower():find(currentWorld:lower()) or currentWorld:lower():find(worldKey:lower():gsub("_legend", ""))) then
                if macroManager[macroName] then
                    print("Found legend-specific mapping:", worldKey, "->", macroName)
                    return macroName
                end
            end
        end
    end
    
    -- Try exact match for regular stages
    local mappedMacro = worldMacroMappings[currentWorld]
    if mappedMacro and macroManager[mappedMacro] then
        print("Found exact match for world:", currentWorld, "->", mappedMacro)
        return mappedMacro
    end
    
    -- If no exact match, try case-insensitive comparison
    local currentWorldLower = string.lower(currentWorld)
    
    for worldKey, macroName in pairs(worldMacroMappings) do
        if string.lower(worldKey) == currentWorldLower and macroManager[macroName] then
            print("Found case-insensitive match:", currentWorld, "matched with", worldKey, "->", macroName)
            return macroName
        end
    end
    
    -- Try base name matching (for cases like "namek_cartoon" -> "namek")
    for worldKey, macroName in pairs(worldMacroMappings) do
        local baseWorldKey = worldKey:match("^([^_]+)") or worldKey
        local baseCurrentWorld = currentWorld:match("^([^_]+)") or currentWorld
        
        if string.lower(baseWorldKey) == string.lower(baseCurrentWorld) and macroManager[macroName] then
            print("Found base name match:", currentWorld, "matched with", worldKey, "via base names:", baseCurrentWorld, "->", macroName)
            return macroName
        end
    end
    
    print("No macro mapping found for world:", currentWorld)
    return nil
end

    Toggle = GameTab:CreateToggle({
    Name = "Auto Start Game",
    CurrentValue = false,
    Flag = "AutoStartGame",
    Callback = function(Value)
            State.AutoVoteStart = Value
    end,
    })

    spawn(function()
        while true do
            wait(1)
            if State.AutoVoteStart then
                local waveNum = Services.Workspace:WaitForChild("_wave_num")
                if waveNum.Value == 0 and not isInLobby() then
                    -- Auto-equip macro units BEFORE starting the game
                    if State.AutoEquipMacroUnits then
                        local worldSpecificMacro = getMacroForCurrentWorld()
                        local macroToEquip = worldSpecificMacro or currentMacroName
                        
                        if macroToEquip and macroToEquip ~= "" and macroManager[macroToEquip] then
                            print("Auto-equipping units for macro:", macroToEquip)
                            local equipSuccess = autoEquipMacroUnits(macroToEquip)
                            
                            if equipSuccess then
                                task.wait(1) -- Wait a bit after equipping before starting
                            end
                        end
                    end
                    
                    -- Now start the game
                    game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("vote_start"):InvokeServer()
                end
            end
        end
    end)

     Toggle = GameTab:CreateToggle({
    Name = "Auto Retry",
    CurrentValue = false,
    Flag = "AutoRetry",
    Callback = function(Value)
            State.AutoVoteRetry = Value
            if Services.Players.LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("replay")
            end
    end,
    })

    Toggle = GameTab:CreateToggle({
    Name = "Auto Next",
    CurrentValue = false,
    Flag = "AutoNext",
    Callback = function(Value)
            State.AutoVoteNext = Value
            if Services.Players.LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_story")
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_raid")
            end
    end,
    })

    Toggle = GameTab:CreateToggle({
    Name = "Auto Lobby",
    CurrentValue = false,
    Flag = "AutoLobby",
    Callback = function(Value)
            State.AutoVoteLobby = Value
            if Services.Players.LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("teleport_back_to_lobby"):InvokeServer()
            end
    end,
    })

     ReturnToLobbyFailsafeToggle = GameTab:CreateToggle({
    Name = "Return to Lobby Failsafe",
    CurrentValue = false,
    Flag = "ReturnToLobbyFailsafe",
    Info = "Return to lobby if no auto-vote happens within 2 minutes after game ends",
    Callback = function(Value)
        State.ReturnToLobbyFailsafe = Value
    end,
})

    Toggle = GameTab:CreateToggle({
    Name = "Auto Skip Waves",
    CurrentValue = false,
    Flag = "AutoSkipWaves",
    Callback = function(Value)
            State.AutoSkipWaves = Value
            if Services.Players.LocalPlayer.PlayerGui.VoteSkip.Enabled == true then
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("vote_wave_skip"):InvokeServer()
            end
    end,
    })

    Slider = GameTab:CreateSlider({
    Name = "Auto Skip Until Wave",
    Range = {0, 30},
    Increment = 1,
    Suffix = "wave",
    CurrentValue = 0,
    Flag = "Slider1",
    Info = "0 = disable",
    Callback = function(Value)
            State.AutoSkipUntilWave = Value
    end,
    })

    task.spawn(function()
        while true do
            task.wait(1)
            if State.AutoSkipWaves then
                local waveNum = Services.Workspace:WaitForChild("_wave_num").Value
                local skipLimit = State.AutoSkipUntilWave
                if skipLimit == 0 then
                    local voteSkip = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("VoteSkip")
                    if voteSkip and voteSkip.Enabled then
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("endpoints")
                            :WaitForChild("client_to_server")
                            :WaitForChild("vote_wave_skip")
                            :InvokeServer()
                    end
                elseif waveNum <= skipLimit then
                    local voteSkip = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("VoteSkip")
                    if voteSkip and voteSkip.Enabled then
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("endpoints")
                            :WaitForChild("client_to_server")
                            :WaitForChild("vote_wave_skip")
                            :InvokeServer()
                    end
                end
            end
        end
    end)

    GameTab:CreateSection("Boss Rush")

     AutoSelectCardToggle = GameTab:CreateToggle({
    Name = "Auto Select Card",
    CurrentValue = false,
    Flag = "AutoSelectCardBossRush",
    Callback = function(Value)
        State.AutoSelectCardBossRush = Value
    end,
})

CardSelectionDropdown = GameTab:CreateDropdown({
    Name = "Select Modifier",
    Options = {"Unit Slot", "Damage", "Placement Limit"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoSelectCardBossRushSelection",
    Callback = function(option)
        if option[1] == "Damage" then
            State.AutoSelectCardBossRushSelection = "Damage"
        elseif option[1] == "Placement Limit" then
            State.AutoSelectCardBossRushSelection = "Placement"
        elseif option[1] == "Unit Slot" then
            State.AutoSelectCardBossRushSelection = "Slot"
        end
    end,
})

task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoSelectCardBossRush then
            if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Prompt") and State.AutoSelectCardBossRushSelection then
                    game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_makima_sacrifice"):InvokeServer(State.AutoSelectCardBossRushSelection)
                    task.wait(0.1)
            end
        end
    end
end)

    GameTab:CreateSection("Auto Sell")

     AutoSellToggle = GameTab:CreateToggle({
        Name = "Auto Sell All Units",
        CurrentValue = false,
        Flag = "AutoSellEnabled",
        Info = "Automatically sell all your units when the specified wave is reached",
        Callback = function(Value)
            State.AutoSellEnabled = Value
            if Value then
                notify("Auto Sell", string.format("Enabled - will sell all units on wave %d", State.AutoSellWave))
            else
                notify("Auto Sell", "Disabled")
            end
        end,
    })

     AutoSellSlider = GameTab:CreateSlider({
        Name = "Sell on Wave",
        Range = {1, 500},
        Increment = 1,
        Suffix = "",
        CurrentValue = 10,
        Flag = "AutoSellWave",
        Info = "Wave number to automatically sell all units",
        Callback = function(Value)
            State.AutoSellWave = Value
            if State.AutoSellEnabled then
                notify("Auto Sell", string.format("Updated - will sell all units on wave %d", Value))
            end
        end,
    })

     AutoSellFarmToggle = GameTab:CreateToggle({
        Name = "Auto Sell Farm Units",
        CurrentValue = false,
        Flag = "AutoSellFarmEnabled",
        Info = "Automatically sell all farm units (that are sellable) when the specified wave is reached",
        Callback = function(Value)
            State.AutoSellFarmEnabled = Value
            if Value then
                notify("Auto Sell Farm", string.format("Enabled - will sell farm units on wave %d", State.AutoSellFarmWave))
            else
                notify("Auto Sell Farm", "Disabled")
            end
        end,
    })

     AutoSellFarmSlider = GameTab:CreateSlider({
        Name = "Sell Farm Units on Wave",
        Range = {1, 500},
        Increment = 1,
        Suffix = "",
        CurrentValue = 15,
        Flag = "AutoSellFarmWave",
        Info = "Wave number to automatically sell all farm units",
        Callback = function(Value)
            State.AutoSellFarmWave = Value
            if State.AutoSellFarmEnabled then
                notify("Auto Sell Farm", string.format("Updated - will sell farm units on wave %d", Value))
            end
        end,
    })

    -- Macro Tab
    local MacroStatusLabel = MacroTab:CreateLabel("Macro Status: Ready")
    detailedStatusLabel = MacroTab:CreateLabel("Macro Details: Ready")

     Divider = MacroTab:CreateDivider()

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

    local function startFailsafeTimer()
    if not State.ReturnToLobbyFailsafe then return end
    
    State.failsafeActive = true
    
    task.spawn(function()
        task.wait(10)
        
        if State.failsafeActive and not isInLobby() then
            notify("Failsafe", "No vote detected - returning to lobby")
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("teleport_back_to_lobby"):InvokeServer()
        end
    end)
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

    local function saveWorldMappings()
        local mappingsData = {
            version = script_version,
            mappings = worldMacroMappings
        }
        
        local json = Services.HttpService:JSONEncode(mappingsData)
        local filePath = "LixHub/world_macro_mappings.json"
        
        if not isfolder("LixHub") then makefolder("LixHub") end
        writefile(filePath, json)
    end

local function refreshAutoSelectDropdowns()
    local macroOptions = {"None"}
    
    -- Add all available macros
    for macroName in pairs(macroManager) do
        table.insert(macroOptions, macroName)
    end
    
    table.sort(macroOptions)
    
    print("Refreshing auto-select dropdowns with", #macroOptions - 1, "macros") -- -1 to exclude "None"
    
    -- Refresh each dropdown
    for worldKey, dropdown in pairs(worldDropdowns) do
        if dropdown and type(dropdown) == "table" then
            local currentMapping = worldMacroMappings[worldKey] or "None"
            
            -- Ensure the current mapping exists in options
            local mappingExists = false
            for _, option in ipairs(macroOptions) do
                if option == currentMapping then
                    mappingExists = true
                    break
                end
            end
            
            -- Reset to None if saved mapping doesn't exist
            if not mappingExists and currentMapping ~= "None" then
                print("Saved mapping", currentMapping, "for", worldKey, "no longer exists, resetting to None")
                worldMacroMappings[worldKey] = nil
                currentMapping = "None"
                saveWorldMappings()
            end
            
            -- Try multiple refresh approaches
            local refreshSuccess = pcall(function()
                if dropdown.Refresh then
                    dropdown:Refresh(macroOptions, currentMapping)
                    print("✓ Refreshed dropdown for", worldKey, "using Refresh method")
                elseif dropdown.UpdateOptions then
                    dropdown:UpdateOptions(macroOptions)
                    print("✓ Updated options for", worldKey, "using UpdateOptions method")
                elseif dropdown.Options then
                    -- Direct property update as fallback
                    dropdown.Options = macroOptions
                    if dropdown.CurrentOption then
                        dropdown.CurrentOption = {currentMapping}
                    end
                    print("✓ Updated", worldKey, "via direct property access")
                else
                    print("⚠ No refresh method available for", worldKey)
                end
            end)
            
            if not refreshSuccess then
                print("✗ Failed to refresh dropdown for", worldKey)
            end
        else
            print("⚠ Invalid dropdown object for", worldKey)
        end
    end
    
    print("Finished refreshing all auto-select dropdowns")
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
                task.wait(0.1)
                refreshAutoSelectDropdowns()
                
                notify(nil,"Success: Created macro '" .. cleanedName .. "'.")
            elseif text ~= "" then
                notify(nil,"Error: Invalid macro name. Avoid special characters.")
            end
        end,
    })

local function importMacroFromTXT(txtContent, macroName)    
    local lines = {}
    for line in txtContent:gmatch("[^\r\n]+") do
        table.insert(lines, line:match("^%s*(.-)%s*$")) -- trim whitespace
    end
    
    local actions = {}
    
    for i, line in ipairs(lines) do
        if line and line ~= "" and not line:match("^#") then -- skip empty lines and comments
            local parts = {}
            for part in line:gmatch("[^,]+") do
                table.insert(parts, part:match("^%s*(.-)%s*$"))
            end
            
            if #parts >= 1 then
                local actionType = parts[1]
                
                if actionType == "spawn_unit" and #parts >= 10 then
                    -- Format: spawn_unit,unit_name,time,pos_x,pos_y,pos_z,dir_x,dir_y,dir_z,rotation
                    local action = {
                        Type = "spawn_unit",
                        Unit = parts[2],
                        Time = parts[3],
                        Pos = string.format("%.17f, %.17f, %.17f", tonumber(parts[4]) or 0, tonumber(parts[5]) or 0, tonumber(parts[6]) or 0),
                        Dir = string.format("%.17f, %.17f, %.17f", tonumber(parts[7]) or 0, tonumber(parts[8]) or 0, tonumber(parts[9]) or 0),
                        Rot = tonumber(parts[10]) or 0
                    }
                    table.insert(actions, action)
                    
                elseif actionType == "upgrade_unit_ingame" and #parts >= 3 then
                    -- Format: upgrade_unit_ingame,unit_name,time
                    local action = {
                        Type = "upgrade_unit_ingame",
                        Unit = parts[2],
                        Time = parts[3]
                    }
                    table.insert(actions, action)
                    
                elseif actionType == "sell_unit_ingame" and #parts >= 3 then
                    -- Format: sell_unit_ingame,unit_name,time
                    local action = {
                        Type = "sell_unit_ingame",
                        Unit = parts[2],
                        Time = parts[3]
                    }
                    table.insert(actions, action)
                    
                elseif actionType == "vote_wave_skip" and #parts >= 2 then
                    -- Format: vote_wave_skip,time
                    local action = {
                        Type = "vote_wave_skip",
                        Time = parts[2]
                    }
                    table.insert(actions, action)
                elseif actionType == "use_active_attack" and #parts >= 3 then
                    local action = {
                        Type = "use_active_attack",
                        Unit = parts[2],
                        Time = parts[3]
                    }
    table.insert(actions, action)
                end
            end
        end
    end
    
    if #actions == 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "No valid actions found in TXT file",
            Duration = 3
        })
        return
    end
    
    -- Save the macro in new format
    macroManager[macroName] = actions
    saveMacroToFile(macroName)
    refreshMacroDropdown()
    refreshAutoSelectDropdowns()
    
    Rayfield:Notify({
        Title = "TXT Import Success",
        Content = string.format("Imported '%s' with %d actions", macroName, #actions),
        Duration = 5
    })
    
    print("Successfully imported TXT macro:", macroName, "with", #actions, "actions")
end

local function importMacroFromContent(jsonContent, macroName)
    local success, data = pcall(function()
        return Services.HttpService:JSONDecode(jsonContent)
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Invalid JSON format",
            Duration = 3
        })
        return
    end
    
    local importedActions
    
    -- Only accept new format with Type field
    if type(data) == "table" then
        if data.actions and type(data.actions) == "table" then
            -- Wrapped format with metadata
            importedActions = data.actions
            print("Importing wrapped format macro with", #importedActions, "actions")
        elseif data[1] and data[1].Type then
            -- Direct array format with Type field
            importedActions = data
            print("Importing new format macro with", #importedActions, "actions")
        else
            Rayfield:Notify({
                Title = "Import Error", 
                Content = "Only new macro format with 'Type' field is supported",
                Duration = 3
            })
            return
        end
    else
        Rayfield:Notify({
            Title = "Import Error", 
            Content = "Invalid macro data structure",
            Duration = 3
        })
        return
    end
    
    if #importedActions == 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Macro contains no actions",
            Duration = 3
        })
        return
    end
    
    -- Validate that all actions have the required Type field
    for i, action in ipairs(importedActions) do
        if not action.Type then
            Rayfield:Notify({
                Title = "Import Error",
                Content = string.format("Action %d missing 'Type' field", i),
                Duration = 3
            })
            return
        end
    end
    
    -- Count action types for summary
    local placementCount = 0
    local upgradeCount = 0
    local sellCount = 0
    local skipCount = 0
    
    for _, action in ipairs(importedActions) do
        if action.Type == "spawn_unit" then
            placementCount = placementCount + 1
        elseif action.Type == "upgrade_unit_ingame" then
            upgradeCount = upgradeCount + 1
        elseif action.Type == "sell_unit_ingame" then
            sellCount = sellCount + 1
        elseif action.Type == "vote_wave_skip" then
            skipCount = skipCount + 1
        end
    end
    
    print(string.format("Macro validation: %d placements, %d upgrades, %d sells, %d skips", 
        placementCount, upgradeCount, sellCount, skipCount))
    
    -- Save the macro as-is (no conversion)
    macroManager[macroName] = importedActions
    saveMacroToFile(macroName)
    refreshMacroDropdown()
    refreshAutoSelectDropdowns()
    
    local statusMsg = string.format("Imported '%s' with %d actions (%d placements, %d upgrades, %d sells, %d skips)", 
        macroName, #importedActions, placementCount, upgradeCount, sellCount, skipCount)
    
    Rayfield:Notify({
        Title = "Import Success",
        Content = statusMsg,
        Duration = 5
    })
    
    print("Successfully imported new format macro:", macroName)
end

local function importMacroFromURL(url, macroName)
    local requestFunc = syn and syn.request or 
                    http and http.request or 
                    http_request or 
                    request
    
    if not requestFunc then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "HTTP requests not supported by your executor",
            Duration = 3
        })
        return
    end
    
    local success, response = pcall(function()
        return requestFunc({
            Url = url,
            Method = "GET"
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        -- Try to detect if content is JSON first, regardless of file extension
        local isJSON = false
        pcall(function()
            local testDecode = Services.HttpService:JSONDecode(response.Body)
            isJSON = true
        end)
        
        if isJSON then
            -- Handle as JSON content
            print("Detected JSON content in URL, using JSON import")
            importMacroFromContent(response.Body, macroName)
        else
            -- Handle as TXT format (CSV-like)
            print("Detected TXT content in URL, using TXT import")
            importMacroFromTXT(response.Body, macroName)
        end
    else
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Failed to download from URL",
            Duration = 3
        })
    end
end

local function exportMacroToClipboard(macroName, format)
    if not macroManager[macroName] or #macroManager[macroName] == 0 then
        Rayfield:Notify({
            Title = "Export Error",
            Content = "No macro data to export",
            Duration = 3
        })
        return
    end
    
    local macroData = macroManager[macroName]
    
    -- Export in new format (no conversion needed since data is already in new format)
    local jsonData = Services.HttpService:JSONEncode(macroData)
    
    -- Copy to clipboard (if supported)
    if setclipboard then
        setclipboard(jsonData)
        Rayfield:Notify({
            Title = "Export Success",
            Content = "Macro JSON copied to clipboard (" .. #macroData .. " actions)",
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "Export Info",
            Content = "Clipboard not supported. JSON printed to console.",
            Duration = 3
        })
        print("=== MACRO EXPORT ===")
        print(jsonData)
        print("=== END EXPORT ===")
    end
end

    RefreshMacroListButton = MacroTab:CreateButton({
        Name = "Refresh Macro List",
        Callback = function()
            loadAllMacros()
            refreshMacroDropdown()
            refreshAutoSelectDropdowns()
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
                startRecordingWithSpawnIdMapping()
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
            stopRecording()
            MacroStatusLabel:Set("Status: Recording stopped")
        end
    end
})

local function playMacroWithGameTimingRefactored()
    if not macro or #macro == 0 then
        print("No macro data to play back")
        updateDetailedStatus("No macro data to play back")
        return false
    end
    
    if macroHasPlayedThisGame then
        print("Macro already played this game, skipping")
        updateDetailedStatus("Macro already played this game - waiting for next game")
        return false
    end
    
    macroHasPlayedThisGame = true
    totalActions = #macro
    
    if State.IgnoreTiming then
        updateDetailedStatus(string.format("Starting immediate playback with %d actions", totalActions))
        print("Starting immediate macro playback (ignoring timing)")
    else
        updateDetailedStatus(string.format("Starting game-time playback with %d actions", totalActions))
        print("Starting macro playback with absolute game timing")
    end
    
    gameHasEnded = false
    clearPlaybackTracking()
    clearPlaybackTrackingWithSpawnIdMapping()

    print("Starting macro playback - mappings cleared")
    
    if gameStartTime == 0 then
        gameStartTime = tick()
        print("Setting game start time for playback:", gameStartTime)
    end
    
    for i, action in ipairs(macro) do
        if not isPlaybacking or not isAutoLoopEnabled or gameHasEnded then
            updateDetailedStatus("Macro interrupted - stopping execution")
            print("Macro interrupted - stopping execution")
            return false
        end
        
        -- Money waiting logic for ALL timing modes
        if action.Type == "spawn_unit" or action.Type == "upgrade_unit_ingame" then
            local requiredCost = 0
            
            if action.Type == "spawn_unit" then
                -- Calculate placement cost
                local displayName, instanceNumber = parseUnitString(action.Unit)
                if displayName then
                    local unitId = getUnitIdFromDisplayName(displayName)
                    if unitId then
                        requiredCost = getPlacementCost(unitId)
                    end
                end
            elseif action.Type == "upgrade_unit_ingame" then
                -- Calculate upgrade cost
                local placementId = action.Unit
                local currentSpawnId = playbackPlacementToSpawnId[placementId]
                
                if currentSpawnId then
                    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
                    if unitsFolder then
                        for _, unit in pairs(unitsFolder:GetChildren()) do
                            if isOwnedByLocalPlayer(unit) and getUnitSpawnId(unit) == currentSpawnId then
                                local displayName = parseUnitString(action.Unit)
                                if displayName then
                                    local unitId = getUnitIdFromDisplayName(displayName)
                                    local currentLevel = getUnitUpgradeLevel(unit)
                                    requiredCost = getUpgradeCost(unitId, currentLevel)
                                end
                                break
                            end
                        end
                    end
                end
            end
            
            if requiredCost > 0 then
                local maxWaitTime = 999999999999999999999999999999999999999
                local waitStart = tick()
                
                while getPlayerMoney() < requiredCost and isPlaybacking and not gameHasEnded do
                    if tick() - waitStart > maxWaitTime then
                        updateDetailedStatus(string.format("(%d/%d) Timeout waiting for money", i, totalActions))
                        print("Timeout waiting for sufficient money")
                        break
                    end
                    
                    local missingMoney = requiredCost - getPlayerMoney()
                    updateDetailedStatus(string.format("(%d/%d) Waiting for %d more yen (need %d, have %d)", 
                        i, totalActions, missingMoney, requiredCost, getPlayerMoney()))
                    task.wait(1)
                end
                
                if not isPlaybacking or gameHasEnded then
                    updateDetailedStatus("Macro stopped during money wait")
                    return false
                end
            end
        end
        
        -- Timing logic with proper field access
        if not State.IgnoreTiming then
            -- Convert stored time string to number
            local targetGameTime = tonumber(action.Time) or 0
            local currentGameTime = tick() - gameStartTime
            local waitTime = targetGameTime - currentGameTime
            
            if waitTime > 0 then
                updateDetailedStatus(string.format("(%d/%d) Waiting %.1fs for timing (target: %.1fs, current: %.1fs)", 
                    i, totalActions, waitTime, targetGameTime, currentGameTime))
                print(string.format("Waiting %.2fs for game time %.2fs", waitTime, targetGameTime))
                
                local waitStart = tick()
                while tick() - waitStart < waitTime and isPlaybacking and not gameHasEnded do
                    task.wait(0.1)
                end
            end
            
            if not isPlaybacking or gameHasEnded then
                updateDetailedStatus("Macro stopped during timing wait")
                print("Macro stopped during timing wait")
                return false
            end
        else
            -- Small delay between actions in immediate mode
            if i > 1 then
                task.wait(0.3)
            end
        end
        
        -- Execute the action
        local actionSuccess = executeActionWithSpawnIdMapping(action, i, totalActions)
        
        if not actionSuccess then
            --notify("Macro Playback", string.format("Action %d failed, continuing with next action", i))
            print(string.format("Action %d failed: %s", i, action.Type))
        end
    end
    
    if State.IgnoreTiming then
        updateDetailedStatus("Immediate macro playback completed")
        print("Immediate macro playback completed")
    else
        updateDetailedStatus("Game-time macro playback completed")
        print("Game-time macro playback completed")
    end
    return true
end

local function createAutoSelectDropdowns()
    print("Creating auto-select dropdowns using existing dropdown data...")
    
    -- Get initial macro options
    local initialMacroOptions = {"None"}
    for macroName in pairs(macroManager) do
        table.insert(initialMacroOptions, macroName)
    end
    table.sort(initialMacroOptions)
    
    print("Initial macro options:", table.concat(initialMacroOptions, ", "))
    
    -- Create collapsibles for each category
    local categoryCollapsibles = {}
    
    -- Story Collapsible - Use existing StoryStageDropdown options
    if StoryStageDropdown and StoryStageDropdown.Options and #StoryStageDropdown.Options > 0 then
        categoryCollapsibles.Story = MacroTab:CreateCollapsible({
            Name = "Story Stages",
            DefaultExpanded = false,
            Flag = "StoryAutoSelectCollapsible"
        })
        
        print("Creating Story auto-select dropdowns for", #StoryStageDropdown.Options, "stages")
        
        for _, stageName in ipairs(StoryStageDropdown.Options) do
            -- Get backend key for this stage
            local backendKey = getBackendWorldKeyFromDisplayName(stageName)
            if not backendKey then
                warn("Could not get backend key for story stage:", stageName)
                continue
            end
            
            local currentMapping = worldMacroMappings[backendKey] or "None"
            
            local dropdown = categoryCollapsibles.Story.Tab:CreateDropdown({
                Name = stageName,
                Options = initialMacroOptions,
                CurrentOption = {currentMapping},
                MultipleOptions = false,
                Flag = "AutoSelect_" .. backendKey,
                Info = string.format("Auto-select macro for %s", stageName),
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    
                    if selectedMacro == "None" or selectedMacro == "" then
                        worldMacroMappings[backendKey] = nil
                        print("Cleared auto-select for", stageName)
                    else
                        worldMacroMappings[backendKey] = selectedMacro
                        print("Set auto-select:", stageName, "->", selectedMacro)
                    end
                    
                    saveWorldMappings()
                end,
            })
            
            worldDropdowns[backendKey] = dropdown
        end
    end
    
    -- Legend Collapsible - Use existing LegendStageDropdown options
    if LegendStageDropdown and LegendStageDropdown.Options and #LegendStageDropdown.Options > 0 then
        categoryCollapsibles.Legend = MacroTab:CreateCollapsible({
            Name = "Legend Stages",
            DefaultExpanded = false,
            Flag = "LegendAutoSelectCollapsible"
        })
        
        print("Creating Legend auto-select dropdowns for", #LegendStageDropdown.Options, "stages")
        
        for _, stageName in ipairs(LegendStageDropdown.Options) do
            -- Get backend key for this stage
            local backendKey = getBackendLegendWorldKeyFromDisplayName(stageName)
            if not backendKey then
                warn("Could not get backend key for legend stage:", stageName)
                continue
            end
            
            -- Special handling for Nightmare Train - create 3 dropdowns
            if stageName:lower():find("nightmare") then
                print("Creating 3 separate dropdowns for Nightmare Train acts...")
                
                for actNum = 1, 3 do
                    local actKey = "ds_legend_act_" .. actNum
                    local currentMapping = worldMacroMappings[actKey] or "None"
                    
                    local dropdown = categoryCollapsibles.Legend.Tab:CreateDropdown({
                        Name = "Nightmare Train Act " .. actNum,
                        Options = initialMacroOptions,
                        CurrentOption = {currentMapping},
                        MultipleOptions = false,
                        Flag = "AutoSelect_" .. actKey,
                        Info = string.format("Auto-select macro for Nightmare Train Act %d", actNum),
                        Callback = function(Option)
                            local selectedMacro = type(Option) == "table" and Option[1] or Option
                            
                            if selectedMacro == "None" or selectedMacro == "" then
                                worldMacroMappings[actKey] = nil
                                print("Cleared auto-select for Nightmare Train Act", actNum)
                            else
                                worldMacroMappings[actKey] = selectedMacro
                                print("Set auto-select: Nightmare Train Act", actNum, "->", selectedMacro)
                            end
                            
                            saveWorldMappings()
                        end,
                    })
                    
                    worldDropdowns[actKey] = dropdown
                end
            else
                -- Normal legend stage handling (NOT Nightmare Train)
                local currentMapping = worldMacroMappings[backendKey] or "None"
                
                local dropdown = categoryCollapsibles.Legend.Tab:CreateDropdown({
                    Name = stageName,
                    Options = initialMacroOptions,
                    CurrentOption = {currentMapping},
                    MultipleOptions = false,
                    Flag = "AutoSelect_" .. backendKey,
                    Info = string.format("Auto-select macro for %s (Legend)", stageName),
                    Callback = function(Option)
                        local selectedMacro = type(Option) == "table" and Option[1] or Option
                        
                        if selectedMacro == "None" or selectedMacro == "" then
                            worldMacroMappings[backendKey] = nil
                            print("Cleared auto-select for", stageName, "(Legend)")
                        else
                            worldMacroMappings[backendKey] = selectedMacro
                            print("Set auto-select:", stageName, "(Legend) ->", selectedMacro)
                        end
                        
                        saveWorldMappings()
                    end,
                })
                
                worldDropdowns[backendKey] = dropdown
            end
        end
    end
    
    -- Raid Collapsible - Use existing RaidStageDropdown options
    if RaidStageDropdown and RaidStageDropdown.Options and #RaidStageDropdown.Options > 0 then
        categoryCollapsibles.Raid = MacroTab:CreateCollapsible({
            Name = "Raid Stages",
            DefaultExpanded = false,
            Flag = "RaidAutoSelectCollapsible"
        })
        
        print("Creating Raid auto-select dropdowns for", #RaidStageDropdown.Options, "stages")
        
        for _, stageName in ipairs(RaidStageDropdown.Options) do
            -- Get backend key for this stage
            local backendKey = getBackendRaidWorldKeyFromDisplayName(stageName)
            if not backendKey then
                warn("Could not get backend key for raid stage:", stageName)
                continue
            end
            
            local currentMapping = worldMacroMappings[backendKey] or "None"
            
            local dropdown = categoryCollapsibles.Raid.Tab:CreateDropdown({
                Name = stageName,
                Options = initialMacroOptions,
                CurrentOption = {currentMapping},
                MultipleOptions = false,
                Flag = "AutoSelect_" .. backendKey,
                Info = string.format("Auto-select macro for %s (Raid)", stageName),
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    
                    if selectedMacro == "None" or selectedMacro == "" then
                        worldMacroMappings[backendKey] = nil
                        print("Cleared auto-select for", stageName, "(Raid)")
                    else
                        worldMacroMappings[backendKey] = selectedMacro
                        print("Set auto-select:", stageName, "(Raid) ->", selectedMacro)
                    end
                    
                    saveWorldMappings()
                end,
            })
            
            worldDropdowns[backendKey] = dropdown
        end
    end
    
    -- Portal Collapsible - Use existing SelectPortalDropdown options
    if SelectPortalDropdown and SelectPortalDropdown.Options and #SelectPortalDropdown.Options > 0 then
        categoryCollapsibles.Portal = MacroTab:CreateCollapsible({
            Name = "Portals",
            DefaultExpanded = false,
            Flag = "PortalAutoSelectCollapsible"
        })
        
        print("Creating Portal auto-select dropdowns for", #SelectPortalDropdown.Options, "portals")
        
        for _, portalName in ipairs(SelectPortalDropdown.Options) do
            -- Get backend key for this portal
            local backendKey = nil
            local portalModuleData = getAllPortalDataFromModules()

            for portalId, moduleInfo in pairs(portalModuleData) do
                if moduleInfo.name == portalName then
                    backendKey = portalId
                    break
                end
            end

            if not backendKey then
                warn("Could not get backend key for portal:", portalName)
                continue
            end
            
            local currentMapping = worldMacroMappings[backendKey] or "None"
            
            local dropdown = categoryCollapsibles.Portal.Tab:CreateDropdown({
                Name = portalName,
                Options = initialMacroOptions,
                CurrentOption = {currentMapping},
                MultipleOptions = false,
                Flag = "AutoSelect_" .. backendKey,
                Info = string.format("Auto-select macro for %s (Portal)", portalName),
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    
                    if selectedMacro == "None" or selectedMacro == "" then
                        worldMacroMappings[backendKey] = nil
                        print("Cleared auto-select for", portalName, "(Portal)")
                    else
                        worldMacroMappings[backendKey] = selectedMacro
                        print("Set auto-select:", portalName, "(Portal) ->", selectedMacro)
                    end
                    
                    saveWorldMappings()
                end,
            })
            
            worldDropdowns[backendKey] = dropdown
        end
    end
    
    -- Other Collapsible - Special events (Halloween, Spirit Invasion, etc.)
    categoryCollapsibles.Other = MacroTab:CreateCollapsible({
        Name = "Other",
        DefaultExpanded = false,
        Flag = "OtherEventsAutoSelectCollapsible"
    })
    
    print("Creating Other Events auto-select dropdowns...")
    
    -- Load Halloween events
    local halloweenSuccess, halloweenData = pcall(function()
        return require(Services.ReplicatedStorage.Framework.Data.Levels.Testing.Levels_Halloween)
    end)
    
    if halloweenSuccess and halloweenData then
        for levelKey, levelInfo in pairs(halloweenData) do
            if type(levelInfo) == "table" and levelInfo.name and levelInfo.id then
                -- Skip portal-only levels (they're already in Portals category)
                if not levelInfo._portal_only_level then
                    local backendKey = levelInfo.id
                    local currentMapping = worldMacroMappings[backendKey] or "None"
                    
                    local dropdown = categoryCollapsibles.Other.Tab:CreateDropdown({
                        Name = levelInfo.name,
                        Options = initialMacroOptions,
                        CurrentOption = {currentMapping},
                        MultipleOptions = false,
                        Flag = "AutoSelect_" .. backendKey,
                        Info = string.format("Auto-select macro for %s (Halloween)", levelInfo.name),
                        Callback = function(Option)
                            local selectedMacro = type(Option) == "table" and Option[1] or Option
                            
                            if selectedMacro == "None" or selectedMacro == "" then
                                worldMacroMappings[backendKey] = nil
                                print("Cleared auto-select for", levelInfo.name, "(Halloween)")
                            else
                                worldMacroMappings[backendKey] = selectedMacro
                                print("Set auto-select:", levelInfo.name, "(Halloween) ->", selectedMacro)
                            end
                            
                            saveWorldMappings()
                        end,
                    })
                    
                    worldDropdowns[backendKey] = dropdown
                    print("  ✓ Added Halloween event:", levelInfo.name, "| ID:", backendKey)
                end
            end
        end
    else
        print("Could not load Halloween events:", halloweenData)
    end
    
    -- Load Spirit Invasion events
    local psychoSuccess, psychoData = pcall(function()
        return require(Services.ReplicatedStorage.Framework.Data.Levels.Testing.Levels_Psycho)
    end)
    
    if psychoSuccess and psychoData then
        for levelKey, levelInfo in pairs(psychoData) do
            if type(levelInfo) == "table" and levelInfo.name and levelInfo.id then
                local backendKey = levelInfo.id
                local currentMapping = worldMacroMappings[backendKey] or "None"
                
                local dropdown = categoryCollapsibles.Other.Tab:CreateDropdown({
                    Name = levelInfo.name,
                    Options = initialMacroOptions,
                    CurrentOption = {currentMapping},
                    MultipleOptions = false,
                    Flag = "AutoSelect_" .. backendKey,
                    Info = string.format("Auto-select macro for %s (Spirit Invasion)", levelInfo.name),
                    Callback = function(Option)
                        local selectedMacro = type(Option) == "table" and Option[1] or Option
                        
                        if selectedMacro == "None" or selectedMacro == "" then
                            worldMacroMappings[backendKey] = nil
                            print("Cleared auto-select for", levelInfo.name, "(Spirit Invasion)")
                        else
                            worldMacroMappings[backendKey] = selectedMacro
                            print("Set auto-select:", levelInfo.name, "(Spirit Invasion) ->", selectedMacro)
                        end
                        
                        saveWorldMappings()
                    end,
                })
                
                worldDropdowns[backendKey] = dropdown
                print("  ✓ Added Spirit Invasion event:", levelInfo.name, "| ID:", backendKey)
            end
        end
    else
        print("Could not load Spirit Invasion events:", psychoData)
    end
    
    print("Created categorized auto-select dropdowns")
end

    local function loadWorldMappings()
        local filePath = "LixHub/world_macro_mappings.json"
        
        if not isfile(filePath) then return end
        
        local success, data = pcall(function()
            local json = readfile(filePath)
            return Services.HttpService:JSONDecode(json)
        end)
        
        if success and data and data.mappings then
            worldMacroMappings = data.mappings
            print("Loaded world macro mappings")
        end
    end

local function autoLoopPlaybackWithGameTiming()
    while isAutoLoopEnabled do
        -- Wait for a game to be active (but don't wait for new game to start)
        while (not gameInProgress or isInLobby()) and isAutoLoopEnabled do
            updateDetailedStatus("Waiting for active game...")
            task.wait(1)
        end
        
        if not isAutoLoopEnabled then break end
        
        -- Check if macro already played this game
        if macroHasPlayedThisGame then
            updateDetailedStatus("Macro already played this game - waiting for next game...")
            
            -- Wait for this game to end and next to start
            while gameInProgress and isAutoLoopEnabled do
                task.wait(1)
            end
            
            -- Wait for next game to start
            while (not gameInProgress or isInLobby()) and isAutoLoopEnabled do
                task.wait(1)
            end
            
            if not isAutoLoopEnabled then break end
        end
        
        -- Get macro to use
        local worldSpecificMacro = getMacroForCurrentWorld()
        local macroToUse = worldSpecificMacro or currentMacroName
        
        if not macroToUse or macroToUse == "" then
            MacroStatusLabel:Set("Status: Error - No macro selected!")
            updateDetailedStatus("Error - No macro selected!")
            notify("Playback Error", "No macro selected for playback.")
            break
        end
        
        local loadedMacro = loadMacroFromFile(macroToUse)
        if not loadedMacro or #loadedMacro == 0 then
            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
            updateDetailedStatus("Error - Failed to load macro!")
            notify("Playback Error", "Failed to load macro: " .. tostring(macroToUse))
            break
        end
        
        macro = loadedMacro
        isPlaybacking = true
        
        local macroSource = worldSpecificMacro and " (Auto-selected)" or " (Manual selection)"
        local timingMode = State.IgnoreTiming and " - Immediate Mode" or " - Game Time Sync"
        
        MacroStatusLabel:Set("Status: Playing " .. macroToUse .. macroSource .. "...")
        updateDetailedStatus("Starting macro: " .. macroToUse .. macroSource .. timingMode)
        
        notify("Playbook Started", macroToUse .. macroSource .. timingMode .. " (" .. #macro .. " actions)")
        clearSpawnIdMappings()
        
        local completed = playMacroWithGameTimingRefactored()
        
        isPlaybacking = false
        
        if isAutoLoopEnabled then
            if completed then
                MacroStatusLabel:Set("Status: Macro completed - waiting for next game...")
                updateDetailedStatus("Macro completed - waiting for next game...")
            else
                MacroStatusLabel:Set("Status: Macro interrupted - waiting for next game...")
                updateDetailedStatus("Macro interrupted - waiting for next game...")
            end
        end
        
        task.wait(1)
    end
    
    MacroStatusLabel:Set("Status: Playback stopped")
    updateDetailedStatus("Playback stopped")
    isPlaybacking = false
end

local PlayToggleEnhanced = MacroTab:CreateToggle({
    Name = "Playback Macro",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isAutoLoopEnabled = Value
        
        if Value then
            MacroStatusLabel:Set("Status: Playback enabled - will play when conditions are met")
            notify("Playback Enabled", "Macro will play once per game when conditions are met.")
            
            task.spawn(function()
                autoLoopPlaybackWithGameTiming()
            end)
        else
            MacroStatusLabel:Set("Status: Playback disabled")
            isPlaybacking = false
            gameHasEnded = false
            notify("Playback Disabled", "Macro playback stopped.")
        end
    end,
})

 Divider = MacroTab:CreateDivider()

    RandomOffsetToggle = MacroTab:CreateToggle({
        Name = "Random Offset",
        CurrentValue = false,
        Flag = "RandomOffsetEnabled",
        Info = "Slightly randomize placement positions to make macros less detectable",
        Callback = function(Value)
            State.RandomOffsetEnabled = Value
            if Value then
                print("Random offset enabled with amount:", State.RandomOffsetAmount)
            else
                print("Random offset disabled")
            end
        end,
    })

    RandomOffsetSlider = MacroTab:CreateSlider({
        Name = "Offset Amount",
        Range = {0.1, 5.0},
        Increment = 0.1,
        Suffix = " studs",
        CurrentValue = 0.5,
        Flag = "RandomOffsetAmount",
        Info = "Maximum random offset distance in studs (recommended value is around 0.5)",
        Callback = function(Value)
            State.RandomOffsetAmount = Value
            print("Random offset amount set to:", Value)
        end,
    })

    IgnoreTimingToggle = MacroTab:CreateToggle({
        Name = "Ignore Timing",
        CurrentValue = false,
        Flag = "IgnoreTiming",
        Info = "Skip wave/timing waits and execute actions immediately.",
        Callback = function(Value)
            State.IgnoreTiming = Value
            if Value then
                updateDetailedStatus("Timing mode: Immediate execution")
            else
                updateDetailedStatus("Timing mode: Wave execution")
            end
        end,
    })

     Divider = MacroTab:CreateDivider()

    ImportInput = MacroTab:CreateInput({
        Name = "Import Macro",
        CurrentValue = "",
        PlaceholderText = "Paste content here...",
        RemoveTextAfterFocusLost = true,
        Callback = function(text)
            if not text or text:match("^%s*$") then
                return
            end
            
            local macroName = nil
            
            -- Detect if it's a URL, JSON content, or TXT content
            if text:match("^https?://") then
                -- Extract filename from URL for macro name (handle query parameters)
                local fileName = text:match("/([^/?]+)%.json") or text:match("/([^/?]+)%.txt") or text:match("/([^/?]+)$")
                if fileName then
                    macroName = fileName:gsub("%.json.*$", ""):gsub("%.txt.*$", "")
                else
                    macroName = "ImportedMacro_" .. os.time()
                end
                
                -- Import from URL (will handle both JSON and TXT)
                importMacroFromURL(text, macroName)
            else
                -- Check if it's JSON format
                local isJSON = false
                pcall(function()
                    local testDecode = Services.HttpService:JSONDecode(text)
                    isJSON = true
                end)
                
                if isJSON then
                    -- Handle JSON import
                    local jsonData = nil
                    pcall(function()
                        jsonData = Services.HttpService:JSONDecode(text)
                    end)
                    
                    macroName = (jsonData and jsonData.macroName) or ("ImportedMacro_" .. os.time())
                    importMacroFromContent(text, macroName)
                else
                    -- Handle TXT format - assume it's line-by-line action format
                    macroName = "ImportedTXT_" .. os.time()
                    importMacroFromTXT(text, macroName)
                end
            end
            
            -- Clean macro name
            macroName = macroName:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            if macroName == "" then
                macroName = "ImportedMacro_" .. os.time()
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
        end,
    })

    ExportButton = MacroTab:CreateButton({
        Name = "Export Macro To Clipboard",
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

     SendWebhookButton = MacroTab:CreateButton({
    Name = "Export Macro via Webhook",
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
        
        -- Extract unique units from macro (new format with "Type" field)
        local unitsUsed = {}
        local unitCounts = {}
        local actionCounts = {
            spawn_unit = 0,
            upgrade_unit_ingame = 0,
            sell_unit_ingame = 0,
            vote_wave_skip = 0
        }
        
        for _, action in ipairs(macroData) do
            -- Count action types
            if actionCounts[action.Type] then
                actionCounts[action.Type] = actionCounts[action.Type] + 1
            end
            
            -- Extract units from spawn actions
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit
                
                -- Extract base unit name (remove instance number like "#1", "#2")
                local baseUnitName = unitName:match("^(.+) #%d+$") or unitName
                
                if not unitsUsed[baseUnitName] then
                    unitsUsed[baseUnitName] = true
                    unitCounts[baseUnitName] = 0
                end
                unitCounts[baseUnitName] = unitCounts[baseUnitName] + 1
            end
        end
        
        -- Create units list for webhook message
        local unitsText = ""
        if next(unitCounts) then
            local unitsList = {}
            for unitName, count in pairs(unitCounts) do
                table.insert(unitsList, unitName .. " (x" .. count .. ")")
            end
            table.sort(unitsList)
            unitsText = table.concat(unitsList, ", ")
        else
            unitsText = "No units found"
        end
        
        -- Create the JSON data in the new format
        local jsonData = Services.HttpService:JSONEncode(macroData)
        local fileName = currentMacroName .. ".json"
        
        -- Create multipart form data for file upload
        local boundary = "----WebKitFormBoundary" .. tostring(tick())
        local body = ""
        
        -- Add payload_json field with enhanced message
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. Services.HttpService:JSONEncode({
            username = "LixHub Macro Share",
            embeds = {{
                title = "📁 Macro Shared: " .. currentMacroName,
                color = 0x5865F2,
                fields = {
                    {
                        name = "📊 Action Summary",
                        value = string.format("**Total Actions:** %d\n🏗️ **Placements:** %d\n⬆️ **Upgrades:** %d\n💸 **Sells:** %d\n➡️ **Wave Skips:** %d",
                            #macroData,
                            actionCounts.spawn_unit,
                            actionCounts.upgrade_unit_ingame, 
                            actionCounts.sell_unit_ingame,
                            actionCounts.vote_wave_skip
                        ),
                        inline = false
                    },
                    {
                        name = "🎯 Units Used",
                        value = unitsText,
                        inline = false
                    },
                },
                footer = {
                    text = script_version
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }) .. "\r\n"
        
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
                    Content = string.format("Macro '%s' sent successfully!\nUnits: %s", currentMacroName, unitsText:sub(1, 50) .. (unitsText:len() > 50 and "..." or "")),
                    Duration = 5
                })
            elseif result.StatusCode then
                -- Handle Discord webhook specific errors
                local errorMsg = "HTTP Error " .. tostring(result.StatusCode)
                if result.StatusCode == 400 then
                    errorMsg = errorMsg .. " (Bad Request)"
                elseif result.StatusCode == 401 then
                    errorMsg = errorMsg .. " (Unauthorized)"
                elseif result.StatusCode == 404 then
                    errorMsg = errorMsg .. " (Webhook Not Found)"
                elseif result.StatusCode == 413 then
                    errorMsg = errorMsg .. " (File Too Large)"
                elseif result.StatusCode == 429 then
                    errorMsg = errorMsg .. " (Rate Limited)"
                end
                
                Rayfield:Notify({
                    Title = "Webhook Error",
                    Content = errorMsg,
                    Duration = 5
                })
                
                print("Webhook failed - StatusCode:", result.StatusCode)
                if result.Body then
                    print("Response body:", result.Body)
                end
            else
                Rayfield:Notify({
                    Title = "Webhook Error",
                    Content = "Request failed with no status code",
                    Duration = 3
                })
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
            
            print("Request failed:", result)
        end
    end,
})

 CheckUnitsButton = MacroTab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Check Units Error",
                Content = "No macro selected.",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Check Units Error", 
                Content = "Selected macro is empty.",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        -- Extract unique units from macro
        local unitsUsed = {}
        
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit
                
                -- Extract base unit name (remove instance number like "#1", "#2")
                local baseUnitName = unitName:match("^(.+) #%d+$") or unitName
                
                unitsUsed[baseUnitName] = true
            end
        end
        
        -- Create display text for units
        local unitsList = {}
        for unitName, _ in pairs(unitsUsed) do
            table.insert(unitsList, unitName)
        end
        
        if #unitsList > 0 then
            table.sort(unitsList)
            local unitsText = table.concat(unitsList, ", ")
            
            Rayfield:Notify({
                Title = currentMacroName,
                Content = unitsText,
                Duration = 6,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = currentMacroName,
                Content = "No units found in this macro.",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

 EquipMacroUnitsButton = MacroTab:CreateButton({
    Name = "Equip Macro Units",
    Callback = function()
        if not isInLobby() then 
            Rayfield:Notify({
                Title = "Equip Error",
                Content = "You must be in lobby to use this!",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end

        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Equip Error",
                Content = "No macro selected.",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Equip Error", 
                Content = "Selected macro is empty.",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        -- Extract unique units from macro
        local requiredUnits = {}
        
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit
                
                -- Extract base unit name (remove instance number like "#1", "#2")
                local baseUnitName = unitName:match("^(.+) #%d+$") or unitName
                
                requiredUnits[baseUnitName] = true
            end
        end
        
        -- Get list of required units
        local requiredUnitsList = {}
        for unitName, _ in pairs(requiredUnits) do
            table.insert(requiredUnitsList, unitName)
        end
        
        if #requiredUnitsList == 0 then
            Rayfield:Notify({
                Title = "Equip Error",
                Content = "No units found in this macro.",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        -- Check if we have all required units in our collection
        local success, result = pcall(function()
            local fxCache = Services.ReplicatedStorage:FindFirstChild("_FX_CACHE")
            if not fxCache then
                error("_FX_CACHE not found")
            end
            
            local availableUnits = {} -- {displayName: uuid}
            local missingUnits = {}
            
            -- Scan through _FX_CACHE to find available units
            for _, child in pairs(fxCache:GetChildren()) do
                local itemIndex = child:GetAttribute("ITEMINDEX")
                if itemIndex then
                    local displayName = getDisplayNameFromUnitId(itemIndex)
                    if displayName then
                        local uuidValue = child:FindFirstChild("_uuid")
                        if uuidValue and uuidValue:IsA("StringValue") then
                            availableUnits[displayName] = uuidValue.Value
                            --print("Found available unit:", displayName, "UUID:", uuidValue.Value)
                        end
                    end
                end
            end
            
            -- Check if we have all required units
            for _, requiredUnit in ipairs(requiredUnitsList) do
                if not availableUnits[requiredUnit] then
                    table.insert(missingUnits, requiredUnit)
                end
            end
            
            if #missingUnits > 0 then
                local missingText = table.concat(missingUnits, ", ")
                error("Missing units: " .. missingText)
            end
            
            return availableUnits
        end)
        
        if not success then
            Rayfield:Notify({
                Title = "Equip Error",
                Content = result,
                Duration = 5,
                Image = 4483362458,
            })
            return
        end
        
        local availableUnits = result
        
        -- Start equipping process
        Rayfield:Notify({
            Title = "Equipping Units",
            Content = string.format("Starting to equip %d units...", #requiredUnitsList),
            Duration = 3,
            Image = 4483362458,
        })
        
        task.spawn(function()
            -- Step 1: Unequip all current units
            local unequipSuccess = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("unequip_all"):InvokeServer()
            end)
            
            if not unequipSuccess then
                Rayfield:Notify({
                    Title = "Equip Error",
                    Content = "Failed to unequip current units.",
                    Duration = 3,
                    Image = 4483362458,
                })
                return
            end
            
            print("Successfully unequipped all units")
            task.wait(0.5) -- Small delay after unequipping
            
            -- Step 2: Equip each required unit
            local equippedCount = 0
            local failedUnits = {}
            
            for _, unitName in ipairs(requiredUnitsList) do
                local unitUUID = availableUnits[unitName]
                if unitUUID then
                    local equipSuccess = pcall(function()
                        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("equip_unit"):InvokeServer(unitUUID)
                    end)
                    
                    if equipSuccess then
                        equippedCount = equippedCount + 1
                        print("Successfully equipped:", unitName, "UUID:", unitUUID)
                    else
                        table.insert(failedUnits, unitName)
                        print("Failed to equip:", unitName)
                    end
                    
                    task.wait(0.2) -- Small delay between equips
                end
            end
            
            -- Final notification
            if #failedUnits == 0 then
                Rayfield:Notify({
                    Title = "Equip Complete",
                    Content = string.format("Successfully equipped all %d units for %s", equippedCount, currentMacroName),
                    Duration = 5,
                    Image = 4483362458,
                })
            else
                local failedText = table.concat(failedUnits, ", ")
                Rayfield:Notify({
                    Title = "Equip Partial",
                    Content = string.format("Equipped %d/%d units. Failed: %s", equippedCount, #requiredUnitsList, failedText),
                    Duration = 5,
                    Image = 4483362458,
                })
            end
            
            print(string.format("Equip process completed: %d/%d successful", equippedCount, #requiredUnitsList))
        end)
    end,
})

    local AutoEquipMacroUnitsToggle = MacroTab:CreateToggle({
        Name = "Auto Equip Macro Units",
        CurrentValue = false,
        Flag = "AutoEquipMacroUnits",
        Info = "Automatically equip units needed for the macro before starting game (requires Auto Start Game enabled)",
        Callback = function(Value)
            State.AutoEquipMacroUnits = Value
            if Value then
                notify("Auto Equip", "Will automatically equip macro units before starting game")
            end
        end,
    })

     Divider = MacroTab:CreateDivider()

      AutoUpgradeToggle = AutoplayTab:CreateToggle({
    Name = "Auto Upgrade Units",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Info = "Automatically upgrade units when you have enough money",
    Callback = function(Value)
        State.AutoUpgrade = Value
    end,
})


     PrioritizeFarmToggle = AutoplayTab:CreateToggle({
    Name = "Prioritize Farm Units",
    CurrentValue = false,
    Flag = "PrioritizeFarm",
    Info = "Upgrade farm units before other units",
    Callback = function(Value)
        State.PrioritizeFarmUnits = Value
    end,
})

 AutoAbilityToggle = AutoplayTab:CreateToggle({
    Name = "Auto Use Abilities",
    CurrentValue = false,
    Flag = "AutoAbility",
    Info = "Automatically use unit abilities when available",
    Callback = function(Value)
        State.AutoAbility = Value
    end,
})

task.spawn(function()
    while true do
        task.wait(0.5) -- Check every 0.5 seconds
        
        if State.AutoUpgrade and not isInLobby() and gameInProgress then
            local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
            if not unitsFolder then continue end
            
            local currentMoney = getPlayerMoney()
            local unitsToUpgrade = {}
            
            -- Collect all upgradeable units
            for _, unit in pairs(unitsFolder:GetChildren()) do
                if isOwnedByLocalPlayer(unit) then
                    local stats = unit:FindFirstChild("_stats")
                    if stats then
                        local currentLevel = getUnitUpgradeLevel(unit)
                        local unitId = getInternalSpawnName(unit)
                        local upgradeCost = getUpgradeCost(unitId, currentLevel)
                        
                        if upgradeCost > 0 and currentMoney >= upgradeCost then
                            local isFarmUnit = stats:FindFirstChild("farm_amount") and 
                                             stats.farm_amount.Value > 0
                            
                            table.insert(unitsToUpgrade, {
                                unit = unit,
                                cost = upgradeCost,
                                isFarm = isFarmUnit,
                                level = currentLevel
                            })
                        end
                    end
                end
            end
            
            -- Sort by priority (farm first if enabled, then by cost)
            table.sort(unitsToUpgrade, function(a, b)
                if State.PrioritizeFarmUnits then
                    if a.isFarm ~= b.isFarm then
                        return a.isFarm -- Farm units first
                    end
                end
                return a.cost < b.cost -- Cheaper upgrades first
            end)
            
            -- Upgrade units
            for _, upgradeData in ipairs(unitsToUpgrade) do
                if getPlayerMoney() >= upgradeData.cost then
                    pcall(function()
                        local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints")
                            :WaitForChild("client_to_server")
                        endpoints:WaitForChild("upgrade_unit_ingame"):InvokeServer(upgradeData.unit.Name)
                    end)
                    
                    task.wait(0.2) -- Small delay between upgrades
                else
                    break -- Not enough money for next upgrade
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1) -- Check every second
        
        if State.AutoAbility and not isInLobby() and gameInProgress then
            local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
            if not unitsFolder then continue end
            
            for _, unit in pairs(unitsFolder:GetChildren()) do
                if isOwnedByLocalPlayer(unit) then
                    local stats = unit:FindFirstChild("_stats")
                    if stats then
                        -- Only use ability if unit has an active_attack
                        local activeAttack = stats:FindFirstChild("active_attack")
                        if activeAttack and activeAttack.Value ~= nil and activeAttack.Value ~= "nil" and activeAttack.Value ~= "" then
                            pcall(function()
                                Services.ReplicatedStorage:WaitForChild("endpoints")
                                    :WaitForChild("client_to_server")
                                    :WaitForChild("use_active_attack")
                                    :InvokeServer(unit.Name)
                            end)
                            
                            task.wait(1) -- Small delay between ability casts
                        end
                    end
                end
            end
        end
    end
end)

    -- Webhook Tab
    WebhookInput = WebhookTab:CreateInput({
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

    UserIDInput = WebhookTab:CreateInput({
        Name = "Input Discord ID (mention rares)",
        CurrentValue = "",
        PlaceholderText = "Input Discord ID...",
        RemoveTextAfterFocusLost = false,
        Flag = "WebhookInputUserID",
        Callback = function(Text)
            Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$")
        end,
    })

    WebhookToggle = WebhookTab:CreateToggle({
        Name = "Send On Stage Finished",
        CurrentValue = false,
        Flag = "SendWebhookOnStageFinished",
        Callback = function(Value)
            State.SendStageCompletedWebhook = Value
        end,
    })

    local TestWebhookButton = WebhookTab:CreateButton({
        Name = "Test webhook",
        Callback = function()
            if ValidWebhook then
                sendWebhook("test")
            else
                notify(nil,"Error: No webhook URL set!")
            end
        end,
    })

local function getPortalDepth(portalData)
    if portalData and 
       portalData._unique_item_data and 
       portalData._unique_item_data._unique_portal_data and
       portalData._unique_item_data._unique_portal_data.portal_depth then
        return portalData._unique_item_data._unique_portal_data.portal_depth
    end
    return 0
end

local function pickBestPortalFromStoredData()
    if not storedPortalData or #storedPortalData == 0 then
        print("No stored portal data available")
        return false
    end
    
    print(string.format("Picking best portal from %d stored portals", #storedPortalData))
    
    -- Apply tier filter if set
    local hasFilter = #State.PortalRewardTierFilter > 0
    local acceptablePortals = {}
    
    for i, portalData in ipairs(storedPortalData) do
        local depth = getPortalDepth(portalData)
        local rewardScale = portalData._unique_item_data._unique_portal_data._portal_reward_scale or 0
        
        print(string.format("Portal %d: Tier (Depth) = %d, Reward Scale = %.2f", 
            i, depth, rewardScale))
        
        -- Check if tier matches filter
        if hasFilter then
            for _, allowedTier in ipairs(State.PortalRewardTierFilter) do
                if depth == allowedTier then
                    table.insert(acceptablePortals, {
                        index = i,
                        tier = depth,
                        rewardScale = rewardScale
                    })
                    break
                end
            end
        else
            -- No filter - accept all
            table.insert(acceptablePortals, {
                index = i,
                tier = depth,
                rewardScale = rewardScale
            })
        end
    end
    
    -- If no portals match filter, fall back to highest tier
    if #acceptablePortals == 0 then
        if hasFilter then
            print("No portals match filter - falling back to highest tier")
            notify("Auto Portal Pick", "No match - picking highest tier", 3)
        end
        
        -- Find highest tier among all portals
        for i, portalData in ipairs(storedPortalData) do
            local depth = getPortalDepth(portalData)
            local rewardScale = portalData._unique_item_data._unique_portal_data._portal_reward_scale or 0
            
            table.insert(acceptablePortals, {
                index = i,
                tier = depth,
                rewardScale = rewardScale
            })
        end
    end
    
    if #acceptablePortals == 0 then
        print("No portals available")
        return false
    end
    
    -- Find highest tier among acceptable portals
    local bestPortal = acceptablePortals[1]
    for _, portal in ipairs(acceptablePortals) do
        if portal.tier > bestPortal.tier then
            bestPortal = portal
        elseif portal.tier == bestPortal.tier and portal.rewardScale > bestPortal.rewardScale then
            bestPortal = portal
        end
    end
    
    print(string.format("Selected Portal %d (Tier: %d, Reward Scale: %.2f)", 
        bestPortal.index,
        bestPortal.tier,
        bestPortal.rewardScale
    ))
    
    -- The index IS the Num we need (1=right, 2=middle, 3=left)
    local portalNum = bestPortal.index
    
    -- Fire the portal selection remote
    local success = pcall(function()
        Services.ReplicatedStorage.endpoints.client_to_server.RequestPortal:InvokeServer(portalNum)
        print("Fired ChoosePortal remote with Num:", portalNum)
    end)
    
    if success then
        local filterInfo = hasFilter and " (filtered)" or " (highest tier)"
        notify("Auto Portal Pick", 
            string.format("Selected Portal %d (Tier %d)%s", 
                bestPortal.index, 
                bestPortal.tier,
                filterInfo
            ), 
            3
        )
        
        -- Clear stored data after use
        storedPortalData = nil
        return true
    else
        notify("Auto Portal Pick", "Failed to select portal", 3)
        return false
    end
end

task.spawn(function()
    local Select_Portals = Services.ReplicatedStorage.endpoints.server_to_client.Select_Portals
    
    Select_Portals.OnClientEvent:Connect(function(portalsArray)
        print("Select_Portals remote fired!")
        
        if State.AutoSelectPortalReward then
            -- Store portal data for later use
            storedPortalData = portalsArray
            print("Stored portal data for auto-selection at game end")
            
            -- Log portal info
            for i, portalData in ipairs(portalsArray) do
                local depth = getPortalDepth(portalData)
                local rewardScale = portalData._unique_item_data._unique_portal_data._portal_reward_scale or 0
                print(string.format("Portal %d: Tier (Depth) = %d, Reward Scale = %.2f", i, depth, rewardScale))
            end
        end
    end)
    
    print("Hooked into Select_Portals remote - ready to store portal data")
end)

    -- ========== REMOTE EVENT CONNECTIONS ==========
    local itemAddedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("normal_item_added")
    local gameFinishedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("game_finished")
    local unitAddedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("unit_added")

    if unitAddedRemote then
        unitAddedRemote.OnClientEvent:Connect(function(...)
            if isInLobby() then return end
            local args = {...}
            print("unit_added RemoteEvent fired!")
            print("Number of arguments:", #args)
            
            -- Print detailed argument contents for debugging
            for i, arg in ipairs(args) do
                print("Unit Drop Arg[" .. i .. "] (" .. type(arg) .. "):")
                if type(arg) == "table" then
                    printTableContents(arg, 1)
                else
                    print("  " .. tostring(arg))
                end
            end
            
            -- Send webhook notification if enabled
            if State.SendStageCompletedWebhook then
                print("DEBUG: SendUnitDropWebhook is enabled, processing args...")
                
                -- FIXED: Process the actual remote arguments directly
                local remoteParamsInfo = {}
                
                -- If the first argument is a table, process its contents as individual arguments
                if #args == 1 and type(args[1]) == "table" then
                    local tableData = args[1]
                    for i = 1, 8 do -- Process up to 8 arguments based on your console output
                        if tableData[i] then
                            local argInfo = {
                                index = i,
                                type = type(tableData[i]),
                                value = tostring(tableData[i])
                            }
                            table.insert(remoteParamsInfo, argInfo)
                            print("DEBUG: Added table arg", i, "=", argInfo.value)
                        end
                    end
                else
                    -- Process arguments normally if not in a table
                    for i, arg in ipairs(args) do
                        local argInfo = {
                            index = i,
                            type = type(arg),
                            value = tostring(arg)
                        }
                        table.insert(remoteParamsInfo, argInfo)
                        print("DEBUG: Added direct arg", i, "=", argInfo.value)
                    end
                end
                
                print("DEBUG: About to call sendWebhook with", #remoteParamsInfo, "arguments")
                sendWebhook("unit_drop", remoteParamsInfo)
            else
                print("DEBUG: SendUnitDropWebhook is disabled")
            end
            
            notify("Unit Drop", "You got a unit drop! Check webhook for details.")
        end)
    else
        warn("unit_added RemoteEvent not found!")
    end

    -- Connect item tracking
    if itemAddedRemote then
        itemAddedRemote.OnClientEvent:Connect(function(itemName, quantity)
            if gameInProgress then
                if sessionItems[itemName] then
                    sessionItems[itemName] = sessionItems[itemName] + quantity
                else
                    sessionItems[itemName] = quantity
                end
                
                print("Item collected: " .. itemName .. " x" .. quantity .. " (Total: " .. sessionItems[itemName] .. ")")
            end
        end)
    end

    -- Connect game finish tracking
    if gameFinishedRemote then
        gameFinishedRemote.OnClientEvent:Connect(function(...)
            local args = {...}
            print("game_finished RemoteEvent fired!")
            print("Number of arguments:", #args)

            gameHasEnded = true
            startFailsafeTimer()
            macroHasPlayedThisGame = false
            
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

            -- Print detailed argument contents for debugging
            for i, arg in ipairs(args) do
                print("Arg[" .. i .. "] (" .. type(arg) .. "):")
                if type(arg) == "table" then
                    printTableContents(arg, 1)
                else
                    print("  " .. tostring(arg))
                end
            end
            
            -- WIN/LOSS DETECTION
            gameResult = "Defeat" -- Default to defeat
            
            -- Look for victory field in table arguments or direct boolean
            for i, arg in ipairs(args) do
                if type(arg) == "table" and arg.victory ~= nil then
                    if arg.victory == true then
                        gameResult = "Victory"
                        print("Found victory field: true -> Result: Victory")
                    else
                        gameResult = "Defeat"
                        print("Found victory field: false -> Result: Defeat")
                    end
                    break
                elseif type(arg) == "boolean" then
                    if arg == true then
                        gameResult = "Victory"
                        print("Found boolean argument: true -> Result: Victory")
                    else
                        gameResult = "Defeat"
                        print("Found boolean argument: false -> Result: Defeat")
                    end
                    break
                end
            end
            
            print("Final game result:", gameResult)
            
            -- Handle auto voting logic with priority system
    task.spawn(function()
        task.wait(1) -- Small delay to ensure game state is stable

        if State.AutoSelectPortalReward and storedPortalData then
        pickBestPortalFromStoredData()
        task.wait(0.5) -- Small delay after portal selection
    end
        
        if State.ReturnToLobbyOnNewChallenge and State.NewChallengeDetected then
            notify("Auto Challenge", "New challenge detected - returning to lobby instead of using auto vote settings")
            
            task.spawn(function()
                task.wait(2) -- Delay to ensure game state is stable
                
                local success, err = pcall(function()
                    Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("teleport_back_to_lobby"):InvokeServer()
                end)
                
                if success then
                    print("Successfully returned to lobby for new challenge!")
                    notify("Challenge Handler", "Returned to lobby - new challenge detected!", 3)
                    State.NewChallengeDetected = false
                else
                    warn("Failed to return to lobby for new challenge:", err)
                end
            end)
            
            return
        end
       if State.AutoNextPortal and State.SelectedPortal and State.SelectedPortal ~= "" then
    if autoNextPortal() then
        return -- Successfully replayed portal
    end
    -- If failed, fall through to other auto-vote options
end

if State.AutoNextInfinityCastle then
            local success, err = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_infinite_tower")
            end)
    return
end
        
if State.AutoNextGate and State.AutoJoinGate then
    print("Auto Next Gate enabled - Finding and joining next gate...")
    
    local bestGate = findBestGate()
    if bestGate then
        if State.AutoMatchmakeGateStage then
            local success, err = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_matchmaking"):InvokeServer("_GATE",{GateUuid = tonumber(bestGate.id)})
            end)
            if success then
                print("Successfully started matchmaking for next gate:", bestGate.id, "Type:", bestGate.type, "Modifier:", bestGate.modifier)
                notify("Auto Next Gate", string.format("Matchmaking next %s Gate with %s modifier", bestGate.type, bestGate.modifier), 5)
            else
                warn("Failed to matchmake next gate:", err)
                notify("Auto Next Gate", "Failed to matchmake next gate - falling back to other auto vote options", 3)
            end
        else
            local success, err = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("play_gate_next",{GateUuid = bestGate.id})
            end)
            
            if success then
                print("Successfully voted for next gate:", bestGate.id, "Type:", bestGate.type, "Modifier:", bestGate.modifier)
                notify("Auto Next Gate", string.format("Solo joining next %s Gate with %s modifier", bestGate.type, bestGate.modifier), 5)
            else
                warn("Failed to vote for next gate:", err)
                notify("Auto Next Gate", "Failed to join next gate - falling back to other auto vote options", 3)
                -- Don't return here, let it fall through to other options
            end
        end
        return -- Exit early if we attempted gate logic (successful or not)
    else
        print("No acceptable gates available for Auto Next Gate")
        notify("Auto Next Gate", "No acceptable gates available - falling back to other auto vote options", 3)
        -- Don't return here, let it fall through to other options
    end
end
        
        -- Priority 2: Auto Retry (high priority)
        if State.AutoVoteRetry then
            print("Auto Retry enabled - Voting to replay...")
            local success, err = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("replay")
            end)
            
            if success then
                print("Successfully voted for retry!")
                notify("Auto Vote", "Voted to retry the stage", 3)
            else
                warn("Failed to vote for retry:", err)
            end
            return -- Exit early since retry has high priority
        end
        
        -- Priority 3: Auto Next (medium priority) - only for victories
        if State.AutoVoteNext and gameResult == "Victory" then
            print("Auto Next enabled and game won - Voting for next stage...")
            local success, err = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_story")
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_raid")
            end)
            
            if success then
                print("Successfully voted for next stage!")
                notify("Auto Vote", "Voted for next stage", 3)
            else
                warn("Failed to vote for next stage:", err)
            end
            return -- Exit early
        end
        
        -- Priority 4: Auto Lobby (lowest priority)
        if State.AutoVoteLobby then
            print("Auto Lobby enabled - Returning to lobby...")
            -- Small additional delay for lobby return
            task.wait(1)
            
            local success, err = pcall(function()
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("teleport_back_to_lobby"):InvokeServer()
            end)
            
            if success then
                print("Successfully returned to lobby!")
                notify("Auto Vote", "Returned to lobby", 3)
            else
                warn("Failed to return to lobby:", err)
            end
        end
    end)
            task.spawn(function()
                task.wait(0.1)
                if gameInProgress then
                    endGameTracking()
                end
            end)
        end)
    end

    -- ========== MAIN EXECUTION ==========

    -- Setup macro hooks
    setupMacroHooksRefactored()
    monitorWavesForRecording()

    -- Auto joiner loop
    task.spawn(function()
        while true do
            task.wait(0.5)
            checkAndExecuteHighestPriority()
        end
    end)

    -- Only monitor waves if not in lobby
    if not isInLobby() then 
        monitorWaves() 
        task.spawn(monitorWavesForAutoSell)
        task.spawn(monitorWavesForAutoSellFarm)
    end

    -- Initialize macro system
    ensureMacroFolders()
    loadAllMacros()


task.delay(1, function()
    print("Starting dropdown loading with retry logic...")
    
    -- Load world mappings and macros
    loadWorldMappings()
    loadAllMacros()
    
    -- Start all dropdown loading processes concurrently
    task.spawn(loadStoryStagesWithRetry)
    task.spawn(loadLegendStagesWithRetry) 
    task.spawn(loadRaidStagesWithRetry)
    task.spawn(loadIgnoreWorldsWithRetry)
    task.spawn(loadPortals)
    
    -- Wait for ALL dropdowns to load FIRST
    task.wait(3) -- Increased wait time
    
    -- THEN create auto-select dropdowns
    createAutoSelectDropdowns()
    
    -- Wait a bit then refresh with loaded mappings
    task.wait(0.5)
    refreshAutoSelectDropdowns()
    
    -- Force set the dropdown values based on saved mappings
    task.wait(0.5)
    for worldKey, macroName in pairs(worldMacroMappings) do
        if worldDropdowns[worldKey] and macroManager[macroName] then
            worldDropdowns[worldKey]:Set(macroName)
            print("Restored auto-select mapping:", worldKey, "->", macroName)
        end
    end
end)

Rayfield:LoadConfiguration()

    -- Restore saved macro from config after a delay
    task.delay(1, function()
        local savedMacroName = Rayfield.Flags["MacroDropdown"]
        
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
                currentMacroName = ""
            end
        else
            print("No valid saved macro name found")
        end
        
        refreshMacroDropdown()
    end)

    for worldKey, macroName in pairs(worldMacroMappings) do
        if worldDropdowns[worldKey] and macroManager[macroName] then
            worldDropdowns[worldKey]:Set(macroName)
            print("Restored auto-select mapping:", worldKey, "->", macroName)
        end
    end

    Rayfield:SetVisibility(false)

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

    Rayfield:TopNotify({
        Title = "UI is hidden",
        Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
        Image = "eye-off", -- Lucide icon name
        IconColor = Color3.fromRGB(100, 150, 255),
        Duration = 5
    })
