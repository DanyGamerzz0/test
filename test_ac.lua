-- 5
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

local script_version = "V0.02"

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
    PLACEMENT_WAIT_TIME = 1.5,
    SNAPSHOT_WAIT_TIME = 0.5,
}

local loadingRetries = {
    story = 0,
    legend = 0,
    raid = 0,
    ignoreWorlds = 0
}

local currentActionIndex = 0
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
local isPlayingLoopRunning = false
local recordingStartTime = 0
local recordingHasStarted = false
local recordingPlacementCounter = 0
local unitPositionToPlacementOrder = {}
local placementOrderToPosition = {}
local placementOrderToSpawnUUID = {}

local isAutoLoopEnabled = false
local gameHasEnded = false

local autoSelectEnabled = false
local worldMacroMappings = {} -- Format: {worldKey = macroName}
local currentWorldKey = nil
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
local waveStartTimes = {} -- Track when each wave started
local recordingStartWave = 0

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
}

-- ========== CREATE TABS ==========
local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "joystick")
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
    return owner == getLocalPlayer()
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

local function getCurrentWave()
    local success, wave = pcall(function()
        if Services.Workspace:FindFirstChild("_wave_num") then
            return Services.Workspace._wave_num.Value
        end
        local playerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui", 5)
        
        for _, gui in pairs(playerGui:GetChildren()) do
            local function searchForWave(obj)
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextBox") then
                        local text = child.Text:lower()
                        local waveMatch = text:match("wave[%s:]*(%d+)")
                        if waveMatch then
                            return tonumber(waveMatch)
                        end
                    end
                end
            end
            
            local foundWave = searchForWave(gui)
            if foundWave then return foundWave end
        end
        
        return 1
    end)
    
    return success and wave or 1
end

local function findUnitBySpawnId(targetSpawnId)
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    if not unitsFolder then return nil end
    
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if isOwnedByLocalPlayer(unit) then
            local unitStats = unit:FindFirstChild("_stats")
            if unitStats and unitStats:FindFirstChild("spawn_id") then
                local unitSpawnId = unitStats.spawn_id.Value
                -- Direct comparison, no string parsing
                if unitSpawnId == targetSpawnId or tostring(unitSpawnId) == tostring(targetSpawnId) then
                    return unit
                end
            end
        end
    end
    
    return nil
end

local function findUnitFromRemoteParam(remoteParam)
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    if not unitsFolder then return nil, nil end
    
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if isOwnedByLocalPlayer(unit) then
            local unitStats = unit:FindFirstChild("_stats")
            if unitStats and unitStats:FindFirstChild("spawn_id") then
                local spawnId = unitStats.spawn_id.Value
                
                -- Check if this spawn_id matches the remote parameter in any way
                if tostring(spawnId) == tostring(remoteParam) or 
                   spawnId == remoteParam or
                   string.find(tostring(remoteParam), tostring(spawnId)) then
                    return unit, spawnId
                end
            end
        end
    end
    
    return nil, nil
end

local function positionToKey(position)
    return string.format("%.2f,%.2f,%.2f", position.X, position.Y, position.Z)
end

local function getUnitType(unit)
    if unit then
        local unitType = unit:GetAttribute("UnitType") or 
                        unit:GetAttribute("_UNIT_TYPE") or
                        unit:GetAttribute("Type")
        
        if unitType then return unitType end
        
        local unitName = unit.Name
        return unitName:match("^([^_]+)") or unitName
    end
    
    return "Unknown"
end

-- Recording Functions
local function clearRecordingMapping()
    unitPositionToPlacementOrder = {}
    placementOrderToPosition = {}
    placementOrderToSpawnUUID = {}
    recordingPlacementCounter = 0
end

local function startRecording()
    table.clear(macro)
    isRecording = true
    recordingStartTime = tick()
    recordingStartWave = getCurrentWave()
    waveStartTimes = {}
    clearRecordingMapping()
    
    -- Record the start time of the initial wave
    waveStartTimes[recordingStartWave] = tick()
    
    print("Started recording macro with wave-synchronized timing")
    print(string.format("Recording started at wave %d", recordingStartWave))
end

local function getMacroFilename(name)
    if type(name) == "table" then name = name[1] or "" end
    if type(name) ~= "string" or name == "" then return nil end
    return "LixHub/Macros/AC/" .. name .. ".json"
end

local function serializeVector3(v)
    return { x = v.X, y = v.Y, z = v.Z }
end

local function serializeCFrame(cframe)
    if not cframe then return nil end
    local components = {cframe:GetComponents()}
    return components
end

local function deserializeVector3(t)
    return Vector3.new(t.x, t.y, t.z)
end

local function deserializeCFrame(components)
    if not components or #components ~= 12 then return nil end
    return CFrame.new(unpack(components))
end

local function getUnitDisplayName(unitId)
    if not unitId then return "Unknown Unit" end
    
    -- Try to find unit name in ReplicatedStorage data
    local success, displayName = pcall(function()
        local unitsData = Services.ReplicatedStorage:FindFirstChild("Framework")
        if unitsData then
            unitsData = unitsData:FindFirstChild("Data")
            if unitsData then
                unitsData = unitsData:FindFirstChild("Units")
                if unitsData then
                    for _, moduleScript in pairs(unitsData:GetChildren()) do
                        if moduleScript:IsA("ModuleScript") then
                            local moduleData = require(moduleScript)
                            if moduleData and moduleData[unitId] then
                                return moduleData[unitId].name or unitId
                            end
                        end
                    end
                end
            end
        end
        return unitId
    end)
    
    return success and displayName or unitId
end

local function getUnitNameFromInstance(spawnUUID)
    local unit = findUnitBySpawnUUID(spawnUUID)
    if unit and unit:FindFirstChild("_stats") and unit._stats:FindFirstChild("id") then
        local unitId = unit._stats.id.Value
        return getUnitDisplayName(unitId)
    end
    return "Unknown Unit"
end

local function createDetailedStatusLabel()
    if detailedStatusLabel then
        return -- Already created
    end
    
    detailedStatusLabel = MacroTab:CreateLabel("Macro Details: Ready")
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

    local serializedData = {}
    
    for _, action in ipairs(data) do
        local newAction = table.clone(action)
        
        -- Handle Vector3 positions
        if newAction.actualPosition then
            newAction.actualPosition = serializeVector3(newAction.actualPosition)
        end
        if newAction.unitPosition then
            newAction.unitPosition = serializeVector3(newAction.unitPosition)
        end
        
        -- Handle raycast serialization
        if newAction.raycast and type(newAction.raycast) == "table" then
            local serializedRaycast = {}
            
            if newAction.raycast.Origin then
                serializedRaycast.Origin = {
                    x = newAction.raycast.Origin.X,
                    y = newAction.raycast.Origin.Y,
                    z = newAction.raycast.Origin.Z
                }
            end
            
            if newAction.raycast.Direction then
                serializedRaycast.Direction = {
                    x = newAction.raycast.Direction.X,
                    y = newAction.raycast.Direction.Y,
                    z = newAction.raycast.Direction.Z
                }
            end
            
            if newAction.raycast.Unit then
                serializedRaycast.Unit = {
                    x = newAction.raycast.Unit.X,
                    y = newAction.raycast.Unit.Y,
                    z = newAction.raycast.Unit.Z
                }
            end
            
            newAction.raycast = serializedRaycast
        end
        
        table.insert(serializedData, newAction)
    end

    local json = Services.HttpService:JSONEncode(serializedData)
    local filePath = getMacroFilename(name)
    if filePath then
        writefile(filePath, json)
        print("Saved macro to file:", name, "with", #serializedData, "actions")
    end
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not filePath or not isfile(filePath) then return nil end

    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)
    
    local actionsArray
    
    -- Handle both formats when loading
    if data.actions and type(data.actions) == "table" then
        -- Wrapped format
        actionsArray = data.actions
        print("Loading wrapped format file:", name)
    elseif data[1] and data[1].action then
        -- Direct array format
        actionsArray = data
        print("Loading direct array format file:", name)
    else
        warn("Unrecognized file format for macro:", name)
        return nil
    end

    for _, action in ipairs(actionsArray) do
        -- Handle Vector3 positions
        if action.actualPosition then
            action.actualPosition = deserializeVector3(action.actualPosition)
        end
        if action.unitPosition then
            action.unitPosition = deserializeVector3(action.unitPosition)
        end
        
        -- Deserialize raycast data - FIXED VERSION
        if action.raycast and type(action.raycast) == "table" then
            local deserializedRaycast = {}
            
            -- Deserialize Origin
            if action.raycast.Origin and type(action.raycast.Origin) == "table" and
               action.raycast.Origin.x and action.raycast.Origin.y and action.raycast.Origin.z then
                deserializedRaycast.Origin = Vector3.new(action.raycast.Origin.x, action.raycast.Origin.y, action.raycast.Origin.z)
            end
            
            -- Deserialize Direction
            if action.raycast.Direction and type(action.raycast.Direction) == "table" and
               action.raycast.Direction.x and action.raycast.Direction.y and action.raycast.Direction.z then
                deserializedRaycast.Direction = Vector3.new(action.raycast.Direction.x, action.raycast.Direction.y, action.raycast.Direction.z)
            end
            
            -- Deserialize Unit
            if action.raycast.Unit and type(action.raycast.Unit) == "table" and
               action.raycast.Unit.x and action.raycast.Unit.y and action.raycast.Unit.z then
                deserializedRaycast.Unit = Vector3.new(action.raycast.Unit.x, action.raycast.Unit.y, action.raycast.Unit.z)
            end
            
            -- Create fallback if any components are missing
            if not deserializedRaycast.Origin or not deserializedRaycast.Direction or not deserializedRaycast.Unit then
                print("Warning: Incomplete raycast in saved file, creating fallback")
                local fallbackPos = action.actualPosition or Vector3.new(0, 0, 0)
                
                if not deserializedRaycast.Origin then
                    deserializedRaycast.Origin = Vector3.new(fallbackPos.X, fallbackPos.Y + 10, fallbackPos.Z)
                end
                if not deserializedRaycast.Direction then
                    deserializedRaycast.Direction = Vector3.new(0, -1, 0)
                end
                if not deserializedRaycast.Unit then
                    deserializedRaycast.Unit = fallbackPos
                end
            end
            
            action.raycast = deserializedRaycast
        end
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

local function getUnitTotalSpent(unit)
    if unit and unit:FindFirstChild("_stats") and unit._stats:FindFirstChild("total_spent") then
        return unit._stats.total_spent.Value
    end
    return 0
end

local function handleUnitPlacement(args)
    if not isRecording or not recordingHasStarted then return end
    
    local unitId = args[1]
    local raycastData = args[2]
    local rotationIndex = args[3] or 0
    
    local timestamp = tick()
    local currentWaveNum = getCurrentWave()
    
    -- Record money before placement
    local moneyBefore = getPlayerMoney()
    
    -- Calculate wave-relative time
    local waveStartTime = waveStartTimes[currentWaveNum] or timestamp
    local waveRelativeTime = timestamp - waveStartTime
    
    print(string.format("Recording placement attempt for unit ID: %s at wave %d (%.2fs into wave) - Money: %d", 
        unitId, currentWaveNum, waveRelativeTime, moneyBefore))
    
    local beforeSnapshot = takeUnitsSnapshot()
    
    task.wait(MACRO_CONFIG.PLACEMENT_WAIT_TIME + MACRO_CONFIG.SNAPSHOT_WAIT_TIME)
    
    local afterSnapshot = takeUnitsSnapshot()
    local placedUnit = findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
    
    if placedUnit and isOwnedByLocalPlayer(placedUnit) then
        recordingPlacementCounter = recordingPlacementCounter + 1
        local thisPlacementOrder = recordingPlacementCounter
        
        local actualPosition = placedUnit.PrimaryPart and placedUnit.PrimaryPart.Position or 
                              placedUnit:FindFirstChildWhichIsA("BasePart").Position
        
        local positionKey = positionToKey(actualPosition)
        unitPositionToPlacementOrder[positionKey] = thisPlacementOrder
        placementOrderToPosition[thisPlacementOrder] = actualPosition
        
        local spawnUUID = placedUnit:GetAttribute("_SPAWN_UNIT_UUID")
        if spawnUUID then
            placementOrderToSpawnUUID[thisPlacementOrder] = spawnUUID
        end
        
        local unitType = getUnitType(placedUnit)
        
        -- Get placement cost by checking unit's total_spent (should be the placement cost)
        local placementCost = getUnitTotalSpent(placedUnit)
        
        -- Record money after placement for verification
        local moneyAfter = getPlayerMoney()
        local moneySpent = moneyBefore - moneyAfter
        
        print(string.format("Placement cost analysis - Total spent on unit: %d, Money difference: %d", 
            placementCost, moneySpent))
        
        -- Validate and serialize raycast data
        local serializedRaycast = {}
        local hasValidRaycast = false
        
        if raycastData and type(raycastData) == "table" then
            -- Check if we have valid Origin
            if raycastData.Origin and type(raycastData.Origin) == "userdata" and 
               raycastData.Origin.X and raycastData.Origin.Y and raycastData.Origin.Z then
                serializedRaycast.Origin = {
                    x = raycastData.Origin.X,
                    y = raycastData.Origin.Y,
                    z = raycastData.Origin.Z
                }
                hasValidRaycast = true
            end
            
            -- Check if we have valid Direction
            if raycastData.Direction and type(raycastData.Direction) == "userdata" and
               raycastData.Direction.X and raycastData.Direction.Y and raycastData.Direction.Z then
                serializedRaycast.Direction = {
                    x = raycastData.Direction.X,
                    y = raycastData.Direction.Y,
                    z = raycastData.Direction.Z
                }
                hasValidRaycast = true
            end
            
            -- Check if we have valid Unit
            if raycastData.Unit and type(raycastData.Unit) == "userdata" and
               raycastData.Unit.X and raycastData.Unit.Y and raycastData.Unit.Z then
                serializedRaycast.Unit = {
                    x = raycastData.Unit.X,
                    y = raycastData.Unit.Y,
                    z = raycastData.Unit.Z
                }
                hasValidRaycast = true
            elseif raycastData.Direction and raycastData.Direction.Unit and 
                   type(raycastData.Direction.Unit) == "userdata" and
                   raycastData.Direction.Unit.X and raycastData.Direction.Unit.Y and raycastData.Direction.Unit.Z then
                serializedRaycast.Unit = {
                    x = raycastData.Direction.Unit.X,
                    y = raycastData.Direction.Unit.Y,
                    z = raycastData.Direction.Unit.Z
                }
                hasValidRaycast = true
            end
        end
        
        -- If we don't have valid raycast data, create a fallback using the actual position
        if not hasValidRaycast then
            print("Warning: No valid raycast data found, creating fallback from position")
            serializedRaycast = {
                Origin = {
                    x = actualPosition.X,
                    y = actualPosition.Y + 10,
                    z = actualPosition.Z
                },
                Direction = {
                    x = 0,
                    y = -1,
                    z = 0
                },
                Unit = {
                    x = actualPosition.X,
                    y = actualPosition.Y,
                    z = actualPosition.Z
                }
            }
        end
        
        local placementData = {
            action = "PlaceUnit",
            unitId = unitId,
            unitType = unitType,
            spawnUUID = spawnUUID,
            actualPosition = actualPosition,
            raycast = serializedRaycast,
            rotation = rotationIndex,
            wave = currentWaveNum,
            waveRelativeTime = waveRelativeTime,
            timestamp = timestamp,
            placementOrder = thisPlacementOrder,
            placementCost = placementCost  -- NEW: Store placement cost
        }
        
        table.insert(macro, placementData)

        notify("Macro Recorder", string.format("Recorded placement #%d: %s (Wave %d, %.2fs) - Cost: %d", 
            thisPlacementOrder, unitId, currentWaveNum, waveRelativeTime, placementCost))
    end
end

local function handleUnitUpgradeClean(args)
    if not isRecording or not recordingHasStarted then return end
    
    local spawnUUIDFromRemote = args[1]
    local timestamp = tick()
    local currentWaveNum = getCurrentWave()
    
    -- Calculate wave-relative time
    local waveStartTime = waveStartTimes[currentWaveNum] or timestamp
    local waveRelativeTime = timestamp - waveStartTime
    
    -- Find the unit directly by checking all spawn_ids
    local targetUnit, targetSpawnId = findUnitFromRemoteParam(spawnUUIDFromRemote)
    
    if not targetUnit or not targetSpawnId then
        print("Could not find unit for upgrade with remote parameter:", spawnUUIDFromRemote)
        return
    end
    
    -- Find the placement order by checking our stored spawn_ids
    local targetPlacementOrder = nil
    for placementOrder, storedSpawnId in pairs(placementOrderToSpawnUUID) do
        if storedSpawnId == targetSpawnId then
            targetPlacementOrder = placementOrder
            break
        end
    end
    
    if not targetPlacementOrder then
        print("Could not find placement order for spawn_id:", targetSpawnId)
        return
    end
    
    -- Get unit's total spent BEFORE upgrade
    local totalSpentBefore = getUnitTotalSpent(targetUnit)
    local moneyBefore = getPlayerMoney()
    
    print(string.format("Recording upgrade attempt - Spawn ID: %s, Total spent before: %d, Player money: %d", 
        tostring(targetSpawnId), totalSpentBefore, moneyBefore))
    
    -- Wait for the upgrade to process
    task.wait(0.5)
    
    -- Get unit's total spent AFTER upgrade
    local totalSpentAfter = getUnitTotalSpent(targetUnit)
    local upgradeCost = totalSpentAfter - totalSpentBefore
    
    local moneyAfter = getPlayerMoney()
    local moneySpent = moneyBefore - moneyAfter
    
    print(string.format("Upgrade cost analysis - Total spent difference: %d, Money difference: %d", 
        upgradeCost, moneySpent))
    
    local expectedPosition = placementOrderToPosition[targetPlacementOrder]
    local originalUnitId = nil
    
    -- Find the original unit ID from placement action
    for _, action in ipairs(macro) do
        if action.action == "PlaceUnit" and action.placementOrder == targetPlacementOrder then
            originalUnitId = action.unitId
            break
        end
    end
    
    table.insert(macro, {
        action = "UpgradeUnit",
        unitId = originalUnitId,
        spawnId = targetSpawnId,
        upgradeRemoteParam = spawnUUIDFromRemote,
        unitPosition = expectedPosition,
        wave = currentWaveNum,
        waveRelativeTime = waveRelativeTime,
        targetPlacementOrder = targetPlacementOrder,
        upgradeCost = upgradeCost
    })

    notify("Macro Recorder", string.format("Recorded upgrade for placement #%d (Spawn ID: %s, Wave %d, %.2fs) - Cost: %d", 
        targetPlacementOrder, tostring(targetSpawnId), currentWaveNum, waveRelativeTime, upgradeCost))
end

local function handleUnitSellClean(args)
    if not isRecording or not recordingHasStarted then return end
    
    local spawnUUIDFromRemote = args[1]
    local timestamp = tick()
    local currentWaveNum = getCurrentWave()
    
    -- Calculate wave-relative time
    local waveStartTime = waveStartTimes[currentWaveNum] or timestamp
    local waveRelativeTime = timestamp - waveStartTime
    
    -- Find the unit directly by checking all spawn_ids
    local targetUnit, targetSpawnId = findUnitFromRemoteParam(spawnUUIDFromRemote)
    
    if not targetUnit or not targetSpawnId then
        print("Could not find unit for sell with remote parameter:", spawnUUIDFromRemote)
        return
    end
    
    -- Find the placement order by checking our stored spawn_ids
    local targetPlacementOrder = nil
    for placementOrder, storedSpawnId in pairs(placementOrderToSpawnUUID) do
        if storedSpawnId == targetSpawnId then
            targetPlacementOrder = placementOrder
            break
        end
    end
    
    if not targetPlacementOrder then
        print("Could not find placement order for spawn_id:", targetSpawnId)
        return
    end
    
    local expectedPosition = placementOrderToPosition[targetPlacementOrder]
    local originalUnitId = nil
    
    -- Find the original unit ID from placement action
    for _, action in ipairs(macro) do
        if action.action == "PlaceUnit" and action.placementOrder == targetPlacementOrder then
            originalUnitId = action.unitId
            break
        end
    end
    
    table.insert(macro, {
        action = "SellUnit",
        unitId = originalUnitId,
        spawnId = targetSpawnId,
        sellRemoteParam = spawnUUIDFromRemote,
        unitPosition = expectedPosition,
        wave = currentWaveNum,
        waveRelativeTime = waveRelativeTime,
        targetPlacementOrder = targetPlacementOrder
    })

    notify("Macro Recorder", string.format("Recorded sell for placement #%d (Spawn ID: %s, Wave %d, %.2fs)", 
        targetPlacementOrder, tostring(targetSpawnId), currentWaveNum, waveRelativeTime))
    
    -- Clean up mappings
    placementOrderToSpawnUUID[targetPlacementOrder] = nil
    if expectedPosition then
        local positionKey = positionToKey(expectedPosition)
        unitPositionToPlacementOrder[positionKey] = nil
    end
    placementOrderToPosition[targetPlacementOrder] = nil
end

local function handleWaveSkip(args)
    if not isRecording or not recordingHasStarted then return end
    
    local timestamp = tick()
    local currentWaveNum = getCurrentWave()
    
    -- Calculate wave-relative time
    local waveStartTime = waveStartTimes[currentWaveNum] or timestamp
    local waveRelativeTime = timestamp - waveStartTime
    
    table.insert(macro, {
        action = "SkipWave",
        wave = currentWaveNum,
        waveRelativeTime = waveRelativeTime,
        timestamp = timestamp
        -- Removed playerOwner field
    })

    notify("Macro Recorder",string.format("Recorded wave skip at wave %d (%.2fs into wave)", 
        currentWaveNum, waveRelativeTime))
end

-- Hook Setup
local function setupMacroHooks()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()
        
        if not checkcaller() then
            task.spawn(function()
                if isRecording and method == "InvokeServer" and self.Parent and self.Parent.Name == "client_to_server" then
                    
                    if self.Name == MACRO_CONFIG.SPAWN_REMOTE then
                        handleUnitPlacement(args)
                    elseif self.Name == MACRO_CONFIG.UPGRADE_REMOTE then
                        handleUnitUpgradeClean(args)
                    elseif self.Name == MACRO_CONFIG.SELL_REMOTE then
                        handleUnitSellClean(args)
                    elseif self.Name == MACRO_CONFIG.WAVE_SKIP_REMOTE then
                        handleWaveSkip(args)
                    end
                end
            end)
        end
        
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
    print("Macro hooks setup complete")
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

local function getUnitNameFromSpawnId(spawnId)
    local unit = findUnitBySpawnId(spawnId)
    if unit and unit:FindFirstChild("_stats") and unit._stats:FindFirstChild("id") then
        local unitId = unit._stats.id.Value
        return getUnitDisplayName(unitId)
    end
    return "Unknown Unit"
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

local function executeActionWithStatusClean(action, playbackMapping, actionIndex, totalActionCount)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    
    currentActionIndex = actionIndex
    totalActions = totalActionCount
    
    if action.action == "PlaceUnit" then
        local unitDisplayName = getUnitDisplayName(action.unitId)
        local currentMoney = getPlayerMoney()
        local requiredCost = action.placementCost or 0
        
        if requiredCost > 0 and currentMoney < requiredCost then
            local missingMoney = requiredCost - currentMoney
            updateDetailedStatus(string.format("(%d/%d) Missing %d yen to place %s", 
                actionIndex, totalActionCount, missingMoney, unitDisplayName))
            return
        end
        
        updateDetailedStatus(string.format("(%d/%d) Placing %s (Cost: %d)", 
            actionIndex, totalActionCount, unitDisplayName, requiredCost))
        
        local beforeSnapshot = takeUnitsSnapshot()
        
        -- Build raycast parameter
        local raycastParam = {}
        if action.raycast then
            if action.raycast.Origin then
                if type(action.raycast.Origin) == "table" then
                    raycastParam.Origin = Vector3.new(action.raycast.Origin.x, action.raycast.Origin.y, action.raycast.Origin.z)
                else
                    raycastParam.Origin = action.raycast.Origin
                end
            end
            
            if action.raycast.Direction then
                if type(action.raycast.Direction) == "table" then
                    raycastParam.Direction = Vector3.new(action.raycast.Direction.x, action.raycast.Direction.y, action.raycast.Direction.z)
                else
                    raycastParam.Direction = action.raycast.Direction
                end
            end
            
            if action.raycast.Unit then
                if type(action.raycast.Unit) == "table" then
                    raycastParam.Unit = Vector3.new(action.raycast.Unit.x, action.raycast.Unit.y, action.raycast.Unit.z)
                else
                    raycastParam.Unit = action.raycast.Unit
                end
            end
        end

        local success, error = pcall(function()
            endpoints:WaitForChild(MACRO_CONFIG.SPAWN_REMOTE):InvokeServer(
                action.unitId,
                raycastParam,
                action.rotation
            )
        end)
        
        if not success then
            updateDetailedStatus(string.format("(%d/%d) Failed to place %s", 
                actionIndex, totalActionCount, unitDisplayName))
            return
        end
        
        task.wait(MACRO_CONFIG.PLACEMENT_WAIT_TIME + MACRO_CONFIG.SNAPSHOT_WAIT_TIME)
        local afterSnapshot = takeUnitsSnapshot()
        
        local placedUnit = findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
        if placedUnit and isOwnedByLocalPlayer(placedUnit) then
            local newSpawnId = getUnitSpawnId(placedUnit)
            if newSpawnId then
                playbackMapping[action.placementOrder] = newSpawnId
                updateDetailedStatus(string.format("(%d/%d) Placed %s", 
                    actionIndex, totalActionCount, unitDisplayName))
            end
        else
            updateDetailedStatus(string.format("(%d/%d) Failed to find placed %s", 
                actionIndex, totalActionCount, unitDisplayName))
        end
        
    elseif action.action == "UpgradeUnit" then
        local currentSpawnId = playbackMapping[action.targetPlacementOrder]
        if currentSpawnId then
            local unit = findUnitBySpawnId(currentSpawnId)
            if unit and isOwnedByLocalPlayer(unit) then
                local unitDisplayName = getUnitNameFromSpawnId(currentSpawnId)
                local currentMoney = getPlayerMoney()
                local requiredCost = action.upgradeCost or 0
                
                if requiredCost > 0 and currentMoney < requiredCost then
                    local missingMoney = requiredCost - currentMoney
                    updateDetailedStatus(string.format("(%d/%d) Missing %d yen to upgrade %s", 
                        actionIndex, totalActionCount, missingMoney, unitDisplayName))
                    return
                end
                
                updateDetailedStatus(string.format("(%d/%d) Upgrading %s (Cost: %d)", 
                    actionIndex, totalActionCount, unitDisplayName, requiredCost))
                
                -- Use the original remote parameter for the upgrade call
                local success = pcall(function()
                    endpoints:WaitForChild(MACRO_CONFIG.UPGRADE_REMOTE):InvokeServer(action.upgradeRemoteParam)
                end)
                
                if success then
                    updateDetailedStatus(string.format("(%d/%d) Upgraded %s", 
                        actionIndex, totalActionCount, unitDisplayName))
                else
                    updateDetailedStatus(string.format("(%d/%d) Failed to upgrade %s", 
                        actionIndex, totalActionCount, unitDisplayName))
                end
            else
                updateDetailedStatus(string.format("(%d/%d) Could not find unit for upgrade", 
                    actionIndex, totalActionCount))
            end
        else
            updateDetailedStatus(string.format("(%d/%d) No unit mapped for upgrade", 
                actionIndex, totalActionCount))
        end
        
    elseif action.action == "SellUnit" then
        local currentSpawnId = playbackMapping[action.targetPlacementOrder]
        if currentSpawnId then
            local unit = findUnitBySpawnId(currentSpawnId)
            if unit and isOwnedByLocalPlayer(unit) then
                local unitDisplayName = getUnitNameFromSpawnId(currentSpawnId)
                
                updateDetailedStatus(string.format("(%d/%d) Selling %s", 
                    actionIndex, totalActionCount, unitDisplayName))
                
                -- Use the original remote parameter for the sell call
                local success = pcall(function()
                    endpoints:WaitForChild(MACRO_CONFIG.SELL_REMOTE):InvokeServer(action.sellRemoteParam)
                end)
                
                if success then
                    playbackMapping[action.targetPlacementOrder] = nil
                    updateDetailedStatus(string.format("(%d/%d) Sold %s", 
                        actionIndex, totalActionCount, unitDisplayName))
                else
                    updateDetailedStatus(string.format("(%d/%d) Failed to sell %s", 
                        actionIndex, totalActionCount, unitDisplayName))
                end
            else
                updateDetailedStatus(string.format("(%d/%d) Could not find unit for sell", 
                    actionIndex, totalActionCount))
            end
        else
            updateDetailedStatus(string.format("(%d/%d) No unit mapped for sell", 
                actionIndex, totalActionCount))
        end
        
    elseif action.action == "SkipWave" then
        updateDetailedStatus(string.format("(%d/%d) Skipping wave", 
            actionIndex, totalActionCount))
        
        pcall(function()
            endpoints:WaitForChild(MACRO_CONFIG.WAVE_SKIP_REMOTE):InvokeServer()
        end)
        
        updateDetailedStatus(string.format("(%d/%d) Wave skipped", 
            actionIndex, totalActionCount))
    end
end

local playbackWaveStartTimes = {}

local function playMacroLoop()
    if not macro or #macro == 0 then
        print("No macro data to play back")
        return
    end
    
    print(string.format("Starting wave-synchronized macro playback with %d actions", #macro))
    
    local playbackMapping = {}
    playbackWaveStartTimes = {}
    
    -- Monitor wave changes during playback
    if Services.Workspace:FindFirstChild("_wave_num") then
        local waveNum = Services.Workspace._wave_num
        local connection
        
        connection = waveNum.Changed:Connect(function(newWave)
            if isPlaybacking then
                playbackWaveStartTimes[newWave] = tick()
                print(string.format("Wave %d started during playback", newWave))
            else
                connection:Disconnect()
            end
        end)
        
        -- Record current wave start time
        local currentWave = waveNum.Value
        playbackWaveStartTimes[currentWave] = tick()
    end
    
    for i, action in ipairs(macro) do
        if not isPlaybacking then break end
        
        -- Wait for the correct wave
        local targetWave = action.wave
        local currentWave = getCurrentWave()
        
        while currentWave < targetWave and isPlaybacking do
            task.wait(0.5)
            currentWave = getCurrentWave()
        end
        
        if not isPlaybacking then break end
        
        -- Wait for the correct time within the wave
        local targetWaveTime = action.waveRelativeTime or 0
        local waveStartTime = playbackWaveStartTimes[currentWave]
        
        if waveStartTime then
            local currentWaveTime = tick() - waveStartTime
            local waitTime = targetWaveTime - currentWaveTime
            
            if waitTime > 0 then
                print(string.format("Waiting %.2fs for wave %d timing", waitTime, currentWave))
                task.wait(waitTime)
            end
        end
        
        if isPlaybacking then
            executeAction(action, playbackMapping)
        end
    end
    
    print("Wave-synchronized macro playback completed")
end

local function waitForGameStart_Record()
    local waveNum = Services.Workspace:WaitForChild("_wave_num")

    -- wait until we detect any active game
    while waveNum.Value < 1 do
        task.wait(1)
    end

    print("Recording started - wave " .. waveNum.Value)
end

local function waitForGameStart_Playback()
    local waveNum = Services.Workspace:WaitForChild("_wave_num")

    -- wait for game to end
    while waveNum.Value > 0 do
        task.wait(1)
    end

    -- wait for next game to start
    while waveNum.Value < 1 do
        task.wait(1)
    end

    print("Playback started - wave " .. waveNum.Value)
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

-- Function to get current map info
local function getMapInfo()
    local mapName = "Unknown Map"
    
    -- Try to get map data from GetLevelData
    if Services.Workspace:FindFirstChild("_MAP_CONFIG") and Services.Workspace._MAP_CONFIG:FindFirstChild("GetLevelData") then
        local success, result = pcall(function()
            return Services.Workspace._MAP_CONFIG.GetLevelData:InvokeServer()
        end)
        
        if success and result then
            -- Try different possible field names for the map name
            mapName = result.MapName or result.mapName or result.Name or result.name or 
                     result.LevelName or result.levelName or result.Map or result.map or "Unknown Map"
            
            print("Map info retrieved:", mapName)
            print("Full map data:", result)
        else
            print("Failed to get map data:", result)
        end
    end
    
    return mapName
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
        ["player_xp"] = "XP"
    }
    
    return statMappings[statName] or getItemDisplayName(statName)
end

-- Enhanced webhook function
local function sendWebhook(messageType)
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

    elseif messageType == "stage" then
        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        local gameDuration = tick() - gameStartTime
        local formattedTime = formatTime(gameDuration)
        
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
                    { name = "Duration", value = formattedTime, inline = true },
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
        notify(nil,"Game summary webhook sent!")
    else
        print("Webhook failed:", response and response.StatusCode or "No response")
    end
end

-- Function to start game tracking
local function startGameTracking()
    if gameInProgress then return end
    
    gameInProgress = true
    sessionItems = {}
    gameStartTime = tick()
    startStats = captureStats()
    currentMapName = getMapInfo()
    gameResult = "In Progress"
    
    print("Game tracking started!")
    print("Map: " .. currentMapName)
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
    gameResult = "Unknown"
end

-- Monitor wave number for game start detection
local function monitorWaves()
    if not Services.Workspace:FindFirstChild("_wave_num") then
        print("Waiting for _wave_num...")
        Services.Workspace:WaitForChild("_wave_num")
    end
    
    local waveNum = Services.Workspace._wave_num
    
    -- Connect to value changes
    waveNum.Changed:Connect(function(newWave)
        lastWave = newWave
        
        -- Game start detection (wave 1 OR if we join mid-game)
        if newWave >= 1 and not gameInProgress then
            startGameTracking()
        elseif newWave > 0 and gameInProgress then
            print("Wave " .. newWave .. " started")
        end
    end)
    
    -- Check initial value
    local initialWave = waveNum.Value
    if initialWave >= 1 then
        lastWave = initialWave
        startGameTracking()
        print("Joined mid-game at wave " .. initialWave .. "!")
    end
    
    print("Monitoring wave changes for game start detection...")
end

local function monitorWavesForRecording()
    if Services.Workspace:FindFirstChild("_wave_num") then
        local waveNum = Services.Workspace._wave_num
        
        waveNum.Changed:Connect(function(newWave)
            if isRecording and recordingHasStarted then
                waveStartTimes[newWave] = tick()
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
        notify("Auto Joiner: ", string.format(
            "Joining %s%s [%s]",
            State.StoryStageSelected or "?",
            State.StoryActSelected or "?",
            State.StoryDifficultySelected or "?"
        ))
    elseif action == "Legend Stage Auto Join" then
        notify("Auto Joiner: ", string.format(
            "Joining %s%s",
            string.lower(State.LegendStageSelected) or "?",
            State.LegendActSelected or "?"
        ))
    elseif action == "Raid Auto Join" then
        notify("Auto Joiner: ", string.format(
            "Joining %s%s",
            string.lower(State.RaidStageSelected) or "?",
            State.RaidActSelected or "?"
        ))
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
        return false
    end

    -- Check if challenge has desired rewards
    if not checkChallengeRewards(challengeData) then
        print("Challenge doesn't contain desired rewards, skipping")
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

local function joinGate(gateInfo)
    if not gateInfo then return false end
    
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

local function checkGateJoin()
    if not State.AutoJoinGate then return false end
    if not isInLobby() then return false end
    if AutoJoinState.isProcessing then return false end
    if not canPerformAction() then return false end
    
    local bestGate = findBestGate()
    if bestGate then
        setProcessingState("Gate Auto Join")
        
        if joinGate(bestGate) then
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
            
            if joinChallenge() then
                print("Successfully initiated challenge join!")
            else
                print("Challenge join failed or skipped!")
            end
            
            task.delay(5, clearProcessingState)
            return -- Exit early since challenge has highest priority
        end
    end

    -- STORY
    if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and State.StoryDifficultySelected then
        setProcessingState("Story Auto Join")

        -- Build the complete stage ID
        local completeStageId = State.StoryStageSelected .. State.StoryActSelected

        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("P1")

        local args = {
            "P1",
            completeStageId,
            false,
            State.StoryDifficultySelected
        }

        local success = pcall(function()
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer(unpack(args))
        end)

        if success then
            print("Successfully sent story join request!")
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("P1")
        else
            warn("Failed to send story join request!")
        end

        task.delay(5, clearProcessingState)
        return
    end

    -- LEGEND STAGE
    if State.AutoJoinLegendStage and State.LegendStageSelected and State.LegendActSelected then
        setProcessingState("Legend Stage Auto Join")

        -- Build the complete legend stage ID
        local completeLegendStageId = State.LegendStageSelected .. State.LegendActSelected

        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("P1")

        local args = {
            "P1",
            string.lower(completeLegendStageId),
            false,
            "Hard"
        }

        local success = pcall(function()
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer(unpack(args))
        end)

        if success then
            print("Successfully sent legend join request!")
	        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("P1")
        else
            warn("Failed to send legend join request!")
        end
        task.delay(5, clearProcessingState)
        return
    end
    if State.AutoJoinRaid and State.RaidStageSelected and State.RaidActSelected then
        setProcessingState("Raid Auto Join")

        local completeRaidStageId = State.RaidStageSelected .. State.RaidActSelected

        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("R1")

        local args = {
            "R1",
            completeRaidStageId,
            false,
            "Hard"
        }

        local success = pcall(function()
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer(unpack(args))
        end)

        if success then
            print("Successfully sent raid join request!")
	        Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("R1")
        else
            warn("Failed to send raid join request!")
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

local AutoJoinStoryToggle = JoinerTab:CreateToggle({
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

local ChapterDropdown869 = JoinerTab:CreateDropdown({
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

local ChapterDropdown = JoinerTab:CreateDropdown({
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

local AutoJoinLegendToggle = JoinerTab:CreateToggle({
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

local LegendChapterDropdown = JoinerTab:CreateDropdown({
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

section = JoinerTab:CreateSection("Raid Joiner")

local AutoJoinRaidToggle = JoinerTab:CreateToggle({
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

local RaidChapterDropdown = JoinerTab:CreateDropdown({
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

section = JoinerTab:CreateSection("Challenge Joiner")

local AutoJoinChallengeToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Challenge",
    CurrentValue = false,
    Flag = "AutoJoinChallenge",
    Callback = function(Value)
        State.AutoJoinChallenge = Value
    end,
})

local ChallengeRewardsDropdown = JoinerTab:CreateDropdown({
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

local ReturnToLobbyToggle = JoinerTab:CreateToggle({
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

local AutoJoinGateToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Gate",
    CurrentValue = false,
    Flag = "AutoJoinGate",
    Callback = function(Value)
        State.AutoJoinGate = Value
    end,
})

local AvoidGatesDropdown = JoinerTab:CreateDropdown({
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

local AvoidModifiersDropdown = JoinerTab:CreateDropdown({
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

local Toggle = JoinerTab:CreateToggle({
   Name = "Auto Next Gate",
   CurrentValue = false,
   Flag = "AutoNextGate",
   Info = "Automatically pick and join next gate after game ends (requires Auto Join Gate enabled)",
   Callback = function(Value)
        State.AutoNextGate = Value
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

local Toggle = GameTab:CreateToggle({
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

local Toggle = GameTab:CreateToggle({
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

local Toggle = GameTab:CreateToggle({
   Name = "Auto Next",
   CurrentValue = false,
   Flag = "AutoNext",
   Callback = function(Value)
        State.AutoVoteNext = Value
        if Services.Players.LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_story")
        end
   end,
})

local Toggle = GameTab:CreateToggle({
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

-- Macro Tab
local MacroStatusLabel = MacroTab:CreateLabel("Macro Status: Ready")

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

local MacroInput = MacroTab:CreateInput({
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

local function importMacroFromTXT(txtContent, macroName)
    -- This is a simple TXT parser - you can customize the format as needed
    -- Example TXT format:
    -- PlaceUnit,unit_id,wave,time,x,y,z
    -- UpgradeUnit,placement_order,wave,time
    -- etc.
    
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
                
                if actionType == "PlaceUnit" and #parts >= 7 then
                    -- Format: PlaceUnit,unit_id,wave,time,x,y,z[,rotation]
                    local action = {
                        action = "PlaceUnit",
                        unitId = parts[2],
                        wave = tonumber(parts[3]) or 1,
                        waveRelativeTime = tonumber(parts[4]) or 0,
                        actualPosition = Vector3.new(
                            tonumber(parts[5]) or 0,
                            tonumber(parts[6]) or 0,
                            tonumber(parts[7]) or 0
                        ),
                        rotation = tonumber(parts[8]) or 0,
                        placementOrder = #actions + 1,
                        -- Create basic raycast from position
                        raycast = {
                            Origin = Vector3.new(tonumber(parts[5]) or 0, (tonumber(parts[6]) or 0) + 10, tonumber(parts[7]) or 0),
                            Direction = Vector3.new(0, -1, 0),
                            Unit = Vector3.new(tonumber(parts[5]) or 0, tonumber(parts[6]) or 0, tonumber(parts[7]) or 0)
                        }
                    }
                    table.insert(actions, action)
                    
                elseif actionType == "UpgradeUnit" and #parts >= 4 then
                    -- Format: UpgradeUnit,placement_order,wave,time
                    local action = {
                        action = "UpgradeUnit",
                        targetPlacementOrder = tonumber(parts[2]) or 1,
                        wave = tonumber(parts[3]) or 1,
                        waveRelativeTime = tonumber(parts[4]) or 0
                    }
                    table.insert(actions, action)
                    
                elseif actionType == "SellUnit" and #parts >= 4 then
                    -- Format: SellUnit,placement_order,wave,time
                    local action = {
                        action = "SellUnit",
                        targetPlacementOrder = tonumber(parts[2]) or 1,
                        wave = tonumber(parts[3]) or 1,
                        waveRelativeTime = tonumber(parts[4]) or 0
                    }
                    table.insert(actions, action)
                    
                elseif actionType == "SkipWave" and #parts >= 3 then
                    -- Format: SkipWave,wave,time
                    local action = {
                        action = "SkipWave",
                        wave = tonumber(parts[2]) or 1,
                        waveRelativeTime = tonumber(parts[3]) or 0
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
    
    -- Save the macro
    macroManager[macroName] = actions
    saveMacroToFile(macroName)
    refreshMacroDropdown()
    
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
    
    -- Handle both formats: direct array and wrapped in actions field
    if type(data) == "table" then
        if data.actions and type(data.actions) == "table" then
            -- New export format with metadata
            importedActions = data.actions
            print("Importing wrapped format macro with", #importedActions, "actions")
        elseif data[1] and data[1].action then
            -- Direct array format (old recorded format)
            importedActions = data
            print("Importing direct array format macro with", #importedActions, "actions")
        else
            Rayfield:Notify({
                Title = "Import Error", 
                Content = "Unrecognized macro format",
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
    
    -- Process the imported actions (deserialize Vector3 and raycast data)
    local processedMacro = {}
    
    for i, action in ipairs(importedActions) do
        local processedAction = {}
        
        -- Copy all fields
        for key, value in pairs(action) do
            if key == "actualPosition" and type(value) == "table" then
                -- Deserialize Vector3 position
                processedAction[key] = deserializeVector3(value)
                print("Deserialized actualPosition for action", i)
            elseif key == "unitPosition" and type(value) == "table" then
                -- Deserialize Vector3 position
                processedAction[key] = deserializeVector3(value)
                print("Deserialized unitPosition for action", i)
            elseif key == "raycast" and type(value) == "table" then
                -- Handle raycast deserialization
                local deserializedRaycast = {}
                local hasOrigin, hasDirection, hasUnit = false, false, false
                
                -- Check and deserialize Origin
                if value.Origin and type(value.Origin) == "table" and 
                   value.Origin.x and value.Origin.y and value.Origin.z then
                    deserializedRaycast.Origin = Vector3.new(value.Origin.x, value.Origin.y, value.Origin.z)
                    hasOrigin = true
                    print("Deserialized raycast Origin:", deserializedRaycast.Origin)
                end
                
                -- Check and deserialize Direction
                if value.Direction and type(value.Direction) == "table" and
                   value.Direction.x and value.Direction.y and value.Direction.z then
                    deserializedRaycast.Direction = Vector3.new(value.Direction.x, value.Direction.y, value.Direction.z)
                    hasDirection = true
                    print("Deserialized raycast Direction:", deserializedRaycast.Direction)
                end
                
                -- Check and deserialize Unit
                if value.Unit and type(value.Unit) == "table" and
                   value.Unit.x and value.Unit.y and value.Unit.z then
                    deserializedRaycast.Unit = Vector3.new(value.Unit.x, value.Unit.y, value.Unit.z)
                    hasUnit = true
                    print("Deserialized raycast Unit:", deserializedRaycast.Unit)
                end
                
                -- Create fallback if any components are missing
                if not hasOrigin or not hasDirection or not hasUnit then
                    print("Warning: Incomplete raycast data for action", i, "filling in missing components")
                    local fallbackPos = processedAction.actualPosition or 
                                      (action.actualPosition and deserializeVector3(action.actualPosition)) or
                                      Vector3.new(0, 0, 0)
                    
                    if not hasOrigin then
                        deserializedRaycast.Origin = Vector3.new(fallbackPos.X, fallbackPos.Y + 10, fallbackPos.Z)
                        print("Created fallback Origin:", deserializedRaycast.Origin)
                    end
                    if not hasDirection then
                        deserializedRaycast.Direction = Vector3.new(0, -1, 0)
                        print("Created fallback Direction:", deserializedRaycast.Direction)
                    end
                    if not hasUnit then
                        deserializedRaycast.Unit = fallbackPos
                        print("Created fallback Unit:", deserializedRaycast.Unit)
                    end
                end
                
                processedAction[key] = deserializedRaycast
            else
                -- Copy value as-is
                processedAction[key] = value
            end
        end
        
        -- Additional check: If this is a PlaceUnit action and still has no raycast, create one
        if processedAction.action == "PlaceUnit" and not processedAction.raycast and processedAction.actualPosition then
            print("Creating missing raycast for PlaceUnit action", i)
            processedAction.raycast = {
                Origin = Vector3.new(processedAction.actualPosition.X, processedAction.actualPosition.Y + 10, processedAction.actualPosition.Z),
                Direction = Vector3.new(0, -1, 0),
                Unit = processedAction.actualPosition
            }
        end
        
        table.insert(processedMacro, processedAction)
    end
    
    -- Validate the processed macro
    local placementCount = 0
    local upgradeCount = 0
    local sellCount = 0
    local raycastIssues = 0
    
    for i, action in ipairs(processedMacro) do
        if action.action == "PlaceUnit" then
            placementCount = placementCount + 1
            -- Check if raycast is valid
            if not action.raycast or not action.raycast.Origin or not action.raycast.Direction or not action.raycast.Unit then
                raycastIssues = raycastIssues + 1
                print("Warning: PlaceUnit action", i, "has invalid raycast data")
            end
        elseif action.action == "UpgradeUnit" then
            upgradeCount = upgradeCount + 1
        elseif action.action == "SellUnit" then
            sellCount = sellCount + 1
        end
    end
    
    print(string.format("Macro validation: %d placements, %d upgrades, %d sells, %d raycast issues", 
          placementCount, upgradeCount, sellCount, raycastIssues))
    
    -- Save the processed macro
    macroManager[macroName] = processedMacro
    saveMacroToFile(macroName)
    refreshMacroDropdown()
    
    local statusMsg = string.format("Imported '%s' with %d actions (%d placements)", macroName, #processedMacro, placementCount)
    if raycastIssues > 0 then
        statusMsg = statusMsg .. string.format(", %d raycast issues fixed", raycastIssues)
    end
    
    Rayfield:Notify({
        Title = "Import Success",
        Content = statusMsg,
        Duration = 5
    })
    
    print("Successfully imported macro:", macroName)
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
        -- Check if it's a TXT or JSON file based on URL or content
        if url:match("%.txt") then
            -- Handle as TXT file
            importMacroFromTXT(response.Body, macroName)
        else
            -- Handle as JSON file (default)
            importMacroFromContent(response.Body, macroName)
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
    
    -- Export in DIRECT ARRAY format to match recorded macros
    local serializedData = {}
    
    for _, action in ipairs(macroData) do
        local serializedAction = {}
        
        -- Copy all fields and serialize Vector3 positions for JSON compatibility
        for key, value in pairs(action) do
            if key == "actualPosition" and value then
                serializedAction[key] = serializeVector3(value)
            elseif key == "unitPosition" and value then
                serializedAction[key] = serializeVector3(value)
            elseif key == "raycast" and value then
                -- Properly serialize raycast data
                local serializedRaycast = {}
                
                if value.Origin then
                    serializedRaycast.Origin = {
                        x = value.Origin.X,
                        y = value.Origin.Y,
                        z = value.Origin.Z
                    }
                end
                
                if value.Direction then
                    serializedRaycast.Direction = {
                        x = value.Direction.X,
                        y = value.Direction.Y,
                        z = value.Direction.Z
                    }
                end
                
                if value.Unit then
                    serializedRaycast.Unit = {
                        x = value.Unit.X,
                        y = value.Unit.Y,
                        z = value.Unit.Z
                    }
                end
                
                serializedAction[key] = serializedRaycast
            else
                serializedAction[key] = value
            end
        end
        
        table.insert(serializedData, serializedAction)
    end
    
    -- Export as direct array (same format as recorded macros save to file)
    local jsonData = Services.HttpService:JSONEncode(serializedData)
    
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

local RefreshMacroListButton = MacroTab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        loadAllMacros()
        refreshMacroDropdown()
        notify(nil,"Success: Macro list refreshed.")
    end,
})

local DeleteSelectedMacroButton = MacroTab:CreateButton({
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

        if Value and not isRecordingLoopRunning and not isInLobby() then
            recordingHasStarted = false
            MacroStatusLabel:Set("Status: Preparing to record...")
            notify(nil,"Macro Recording: Waiting for game to start...")

            task.spawn(function()
                waitForGameStart_Record()
                if isRecording then
                    recordingHasStarted = true
                    isRecordingLoopRunning = true
                    startRecording()
                    MacroStatusLabel:Set("Status: Recording active!")
                    notify(nil,"Recording Started: Macro recording is now active.")
                end
            end)

        elseif not Value then
            if isRecordingLoopRunning then
                notify(nil,"Recording Stopped: Recording manually stopped.")
            end
            isRecordingLoopRunning = false
            stopRecording()
            MacroStatusLabel:Set("Status: Recording stopped")
        end
        end})

local function playMacroLoopWithInterruptsIgnoreTiming()
    if not macro or #macro == 0 then
        print("No macro data to play back")
        updateDetailedStatus("No macro data to play back")
        return false
    end
    
    totalActions = #macro
    currentActionIndex = 0
    
    if State.IgnoreTiming then
        updateDetailedStatus(string.format("Starting immediate playback with %d actions", totalActions))
        print("Starting immediate macro playback (ignoring timing)")
    else
        updateDetailedStatus(string.format("Starting wave based playback with %d actions", totalActions))
        print("Starting wave based macro playback")
    end
    
    gameHasEnded = false
    
    local playbackMapping = {}
    playbackWaveStartTimes = {}
    
    -- Monitor wave changes during playback (still useful for status updates)
    if Services.Workspace:FindFirstChild("_wave_num") then
        local waveNum = Services.Workspace._wave_num
        local connection
        
        connection = waveNum.Changed:Connect(function(newWave)
            if isPlaybacking then
                playbackWaveStartTimes[newWave] = tick()
                print(string.format("Wave %d started during playback", newWave))
            else
                connection:Disconnect()
            end
        end)
        
        local currentWave = waveNum.Value
        playbackWaveStartTimes[currentWave] = tick()
    end
    
    for i, action in ipairs(macro) do
        if not isPlaybacking or not isAutoLoopEnabled or gameHasEnded then
            updateDetailedStatus("Macro interrupted - stopping execution")
            print("Macro interrupted - stopping execution")
            return false
        end
        
        -- Only do timing checks if ignore timing is disabled
        if not State.IgnoreTiming then
            -- Wait for the correct wave
            local targetWave = action.wave
            local currentWave = getCurrentWave()
            
            while currentWave < targetWave and isPlaybacking and not gameHasEnded do
                updateDetailedStatus(string.format("(%d/%d) Waiting for wave %d", 
                    i, totalActions, targetWave))
                task.wait(0.5)
                currentWave = getCurrentWave()
            end
            
            if not isPlaybacking or gameHasEnded then
                updateDetailedStatus("Game ended during wave wait - stopping macro")
                print("Game ended during wave wait - stopping macro")
                return false
            end
            
            -- Wait for the correct time within the wave
            local targetWaveTime = action.waveRelativeTime or 0
            local waveStartTime = playbackWaveStartTimes[currentWave]
            
            if waveStartTime then
                local currentWaveTime = tick() - waveStartTime
                local waitTime = targetWaveTime - currentWaveTime
                
                if waitTime > 0 then
                    updateDetailedStatus(string.format("(%d/%d) Waiting %.1fs for timing", 
                        i, totalActions, waitTime))
                    print(string.format("Waiting %.2fs for wave %d timing", waitTime, currentWave))
                    
                    local waitStart = tick()
                    while tick() - waitStart < waitTime and isPlaybacking and not gameHasEnded do
                        task.wait(0.1)
                    end
                end
            end
        else
            -- When ignoring timing, add a small delay between actions for stability
            if i > 1 then
                task.wait(0.2) -- Small delay to prevent overwhelming the server
            end
            
            -- For placement actions, we might still want to check if we have enough money and wait if needed
            if action.action == "PlaceUnit" or action.action == "UpgradeUnit" then
                local requiredCost = action.placementCost or action.upgradeCost or 0
                local maxWaitTime = 180 -- Maximum time to wait for money (30 seconds)
                local waitStart = tick()
                
                while requiredCost > 0 and getPlayerMoney() < requiredCost and isPlaybacking and not gameHasEnded do
                    if tick() - waitStart > maxWaitTime then
                        updateDetailedStatus(string.format("(%d/%d) Timeout waiting for money", i, totalActions))
                        print("Timeout waiting for sufficient money")
                        break
                    end
                    
                    local missingMoney = requiredCost - getPlayerMoney()
                    updateDetailedStatus(string.format("(%d/%d) Waiting for %d more yen", 
                        i, totalActions, missingMoney))
                    task.wait(1)
                end
            end
        end
        
        -- Check if we should still continue
        if not isPlaybacking or gameHasEnded then
            updateDetailedStatus("Macro stopped before action execution")
            print("Macro stopped before action execution")
            return false
        end
        
        -- Execute the action
        executeActionWithStatusClean(action, playbackMapping, i, totalActions)
    end
    
    if State.IgnoreTiming then
        updateDetailedStatus("Immediate macro playback completed")
        print("Immediate macro playback completed")
    else
        updateDetailedStatus("Wave bsed macro playback completed")
        print("Wave based macro playback completed")
    end
    return true
end

createDetailedStatusLabel()

local function refreshAutoSelectDropdowns()
    local macroOptions = {"None"}
    
    -- Add all available macros
    for macroName in pairs(macroManager) do
        table.insert(macroOptions, macroName)
    end
    
    table.sort(macroOptions)
    
    -- Refresh each dropdown
    for worldKey, dropdown in pairs(worldDropdowns) do
        local currentMapping = worldMacroMappings[worldKey] or "None"
        dropdown:Refresh(macroOptions, currentMapping)
    end
end

local function getCurrentWorld()
    local success, levelData = pcall(function()
        return Services.Workspace._MAP_CONFIG.GetLevelData:InvokeServer()
    end)
    
    if success and levelData then
        -- Check for regular world field first (story stages)
        if levelData.world then
            return levelData.world -- Returns "namek", "marineford", etc.
        end
        
        -- Check for map field (portals/dungeons like DoubleDungeon)
        if levelData.map then
            return levelData.map -- Returns "DoubleDungeon"
        end
    end
    
    return nil
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

local function createAutoSelectDropdowns()
    if not isGameDataLoaded() then
        print("Game data not loaded yet for auto-select dropdowns")
        return
    end
    
    local success, allWorldData = pcall(function()
        local allWorldNames = {}
        
        -- Get all worlds/maps from Maps folder only
        local MapsFolder = Services.ReplicatedStorage.Framework.Data.Maps
        if MapsFolder then
            for _, mapModule in ipairs(MapsFolder:GetChildren()) do
                if mapModule:IsA("ModuleScript") then
                    local moduleSuccess, mapData = pcall(require, mapModule)
                    
                    if moduleSuccess and mapData then
                        -- Iterate through all maps in this module
                        for mapKey, mapInfo in pairs(mapData) do
                            if type(mapInfo) == "table" and mapInfo.name and mapInfo.id then
                                -- Skip legend stages (they're copies of story stages)
                                if not mapInfo.id:lower():find("legend") then
                                    allWorldNames[mapInfo.id] = mapInfo.name
                                    print("Added world/map:", mapInfo.name, "with key:", mapInfo.id)
                                else
                                    print("Skipped legend stage:", mapInfo.name, "with key:", mapInfo.id)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return allWorldNames
    end)
    
    if not success or not allWorldData then
        warn("Failed to load worlds from Maps folder for auto-select dropdowns")
        return
    end
    
    -- Create dropdowns for each world/map
    for worldKey, worldDisplayName in pairs(allWorldData) do
        local dropdown = MacroTab:CreateDropdown({
            Name = string.format("Auto: %s", worldDisplayName),
            Options = {"None"},
            CurrentOption = {"None"},
            MultipleOptions = false,
            Flag = "AutoSelect_" .. worldKey,
            Info = string.format("Auto-select macro for %s", worldDisplayName),
            Callback = function(Option)
                local selectedMacro = type(Option) == "table" and Option[1] or Option
                
                if selectedMacro == "None" or selectedMacro == "" then
                    worldMacroMappings[worldKey] = nil
                    print("Cleared auto-select for", worldDisplayName)
                else
                    worldMacroMappings[worldKey] = selectedMacro
                    print("Set auto-select:", worldDisplayName, "->", selectedMacro)
                end
                
                -- Save mappings
                saveWorldMappings()
            end,
        })
        
        worldDropdowns[worldKey] = dropdown
    end
    
    -- Initial refresh with current macros
    refreshAutoSelectDropdowns()
    print("Created auto-select dropdowns for", table.getn(allWorldData), "worlds from Maps folder")
end

local function getMacroForCurrentWorld()
    if isInLobby() then
        return nil -- Don't auto-select in lobby
    end
    
    local currentWorld = getCurrentWorld()
    if not currentWorld then
        return nil
    end
    
    local mappedMacro = worldMacroMappings[currentWorld]
    if mappedMacro and macroManager[mappedMacro] then
        return mappedMacro
    end
    
    return nil
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

local function autoLoopPlaybackWithTiming()
        while isAutoLoopEnabled do
        updateDetailedStatus("Waiting for game to start...")
        waitForGameStart_Playback()
        
        if not isAutoLoopEnabled then break end
        
        -- Check if there's a world-specific macro first
        local worldSpecificMacro = getMacroForCurrentWorld()
        local macroToUse = worldSpecificMacro or currentMacroName
        
        if not macroToUse or macroToUse == "" then
            MacroStatusLabel:Set("Status: Error - No macro selected!")
            updateDetailedStatus("Error - No macro selected!")
            notify(nil, "Playback Error: No macro selected for playback.")
            break
        end
        
        local loadedMacro = loadMacroFromFile(macroToUse)
        if not loadedMacro or #loadedMacro == 0 then
            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
            updateDetailedStatus("Error - Failed to load macro!")
            notify(nil, "Playback Error: Failed to load macro: " .. tostring(macroToUse))
            break
        end
        
        macro = loadedMacro
        isPlaybacking = true
        isPlayingLoopRunning = true
        
        -- Update status based on macro source and timing mode
        local macroSource = worldSpecificMacro and " (Auto-selected)" or " (Manual selection)"
        local timingMode = State.IgnoreTiming and " - Immediate Mode" or " - Wave Synchronized"
        
        MacroStatusLabel:Set("Status: Playing " .. macroToUse .. macroSource .. "...")
        updateDetailedStatus("Loading macro: " .. macroToUse .. macroSource .. timingMode)
        
        notify(nil, "Playback Started: " .. macroToUse .. macroSource .. timingMode .. " (" .. #macro .. " actions)")
        
        local completed = playMacroLoopWithInterruptsIgnoreTiming()
        
        isPlaybacking = false
        isPlayingLoopRunning = false
        
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
    
    MacroStatusLabel:Set("Status: Autoplay stopped")
    updateDetailedStatus("Autoplay stopped")
    isPlaybacking = false
    isPlayingLoopRunning = false
end

local PlayToggleEnhanced = MacroTab:CreateToggle({
    Name = "Playback Macro",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isAutoLoopEnabled = Value
        
        if Value and not isInLobby() then
            if State.IgnoreTiming then
                MacroStatusLabel:Set("Status: Autoplay enabled (immediate mode) - waiting for game...")
                notify(nil, "Autoplay Enabled: Macro will play immediately each game (ignoring timing).")
            else
                MacroStatusLabel:Set("Status: Autoplay enabled (wave-sync mode) - waiting for game...")
                notify(nil, "Autoplay Enabled: Macro will play with wave synchronization each game.")
            end
            
            task.spawn(function()
                autoLoopPlaybackWithTiming()
            end)
        else
            MacroStatusLabel:Set("Status: Autoplay disabled")
            isPlaybacking = false
            isPlayingLoopRunning = false
            gameHasEnded = false
            notify(nil, "Autoplay Disabled: Macro playback stopped.")
        end
    end,
})

local IgnoreTimingToggle = MacroTab:CreateToggle({
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

--[[local CheckUnitsButton = MacroTab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            notify(nil,"Error: No macro selected.")
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            notify(nil,"Error: Selected macro is empty.")
            return
        end
        
        -- Extract unique units from macro
        local units = {}
        local unitCounts = {}
        
        for _, action in ipairs(macroData) do
            if action.action == "PlaceUnit" then
                local unitName = action.unitId or action.unitType or "Unknown"
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
            notify(nil,"Macro Units (" .. #unitList .. " types):")
            print("Units in macro:")
            for _, unitInfo in ipairs(unitList) do
                print("  " .. unitInfo)
            end
        else
            notify(nil,"No Units Found: This macro contains no unit placements.")
        end
    end,
})--]]

local ImportInput = MacroTab:CreateInput({
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

local ExportButton = MacroTab:CreateButton({
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

--[[local SendWebhookButton = MacroTab:CreateButton({
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
        
        -- Create export data using the SAME format as the fixed export function
        local exportData = {
            version = script_version,
            macroName = currentMacroName,
            totalActions = #macroData,
            actions = {}
        }
        
        -- Copy actions and serialize Vector3 positions for JSON compatibility
        for _, action in ipairs(macroData) do
            local serializedAction = {}
            
            -- Copy all fields directly
            for key, value in pairs(action) do
                if key == "actualPosition" and value then
                    serializedAction[key] = serializeVector3(value)
                elseif key == "unitPosition" and value then
                    serializedAction[key] = serializeVector3(value)
                else
                    serializedAction[key] = value
                end
            end
            
            table.insert(exportData.actions, serializedAction)
        end
        
        local jsonData = Services.HttpService:JSONEncode(exportData)
        local fileName = currentMacroName .. ".json"
        
        -- Count different action types for summary
        local placementCount = 0
        local upgradeCount = 0
        local sellCount = 0
        
        for _, action in ipairs(macroData) do
            if action.action == "PlaceUnit" then
                placementCount = placementCount + 1
            elseif action.action == "UpgradeUnit" then
                upgradeCount = upgradeCount + 1
            elseif action.action == "SellUnit" then
                sellCount = sellCount + 1
            end
        end
        
        -- Create multipart form data for file upload
        local boundary = "----WebKitFormBoundary" .. tostring(tick())
        local body = ""
        
        -- Add payload_json field
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. Services.HttpService:JSONEncode({
            username = "LixHub Macro Share",
            content = "**Macro shared:** `" .. fileName .. "`\n" ..
                     "📁 **Total Actions:** " .. tostring(#exportData.actions) .. "\n" ..
                     "🏗️ **Placements:** " .. tostring(placementCount) .. "\n" ..
                     "⬆️ **Upgrades:** " .. tostring(upgradeCount) .. "\n" ..
                     "💸 **Sells:** " .. tostring(sellCount)
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
                    Content = "Macro file sent to Discord successfully.",
                    Duration = 3
                })
            else
                -- Log the actual error for debugging
                local errorMsg = "HTTP Error"
                if result.StatusCode then
                    errorMsg = errorMsg .. " " .. tostring(result.StatusCode)
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
})--]]

-- Webhook Tab
local WebhookInput = WebhookTab:CreateInput({
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

local UserIDInput = WebhookTab:CreateInput({
    Name = "Input Discord ID (mention rares)",
    CurrentValue = "",
    PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInputUserID",
    Callback = function(Text)
        Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$")
    end,
})

local WebhookToggle = WebhookTab:CreateToggle({
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

-- ========== REMOTE EVENT CONNECTIONS ==========
local itemAddedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("normal_item_added")
local gameFinishedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("game_finished")
local challengeChangedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("normal_challenge_changed")


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

if challengeChangedRemote then
    challengeChangedRemote.OnClientEvent:Connect(function(...)
        local args = {...}
        print("normal_challenge_changed RemoteEvent fired!")
        print("New challenge detected - arguments:", #args)
        
        -- Print challenge change data for debugging
        for i, arg in ipairs(args) do
            print("Challenge Change Arg[" .. i .. "] (" .. type(arg) .. "):")
            if type(arg) == "table" then
                printTableContents(arg, 1)
            else
                print("  " .. tostring(arg))
            end
        end
        
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
    end)
else
    warn("normal_challenge_changed RemoteEvent not found!")
end

-- Connect game finish tracking
if gameFinishedRemote then
    gameFinishedRemote.OnClientEvent:Connect(function(...)
        local args = {...}
        print("game_finished RemoteEvent fired!")
        print("Number of arguments:", #args)

        gameHasEnded = true
        
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
    
    -- NEW: Priority 1: Auto Next Gate (highest priority when both Auto Join Gate and Auto Next Gate are enabled)
    if State.AutoNextGate and State.AutoJoinGate then
        print("Auto Next Gate enabled - Finding and joining next gate...")
        
        local bestGate = findBestGate()
        if bestGate then
            local success, err = pcall(function()
                local args = {
                    "play_gate_next",
                    {
                        GateUuid = bestGate.id
                    }
                }
                Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer(unpack(args))
            end)
            
            if success then
                print("Successfully voted for next gate:", bestGate.id, "Type:", bestGate.type, "Modifier:", bestGate.modifier)
                notify("Auto Next Gate", string.format("Joining next %s Gate with %s modifier", bestGate.type, bestGate.modifier), 5)
            else
                warn("Failed to vote for next gate:", err)
                notify("Auto Next Gate", "Failed to join next gate - falling back to other auto vote options", 3)
                -- Don't return here, let it fall through to other options
            end
            return -- Exit early if successful
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
setupMacroHooks()
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
end

-- Initialize macro system
ensureMacroFolders()
loadAllMacros()

task.delay(1, function()
    print("Starting dropdown loading with retry logic...")
    
    -- Start all loading processes concurrently
    task.spawn(loadStoryStagesWithRetry)
    task.spawn(loadLegendStagesWithRetry)
    task.spawn(loadRaidStagesWithRetry)
    task.spawn(loadIgnoreWorldsWithRetry)
    task.spawn(loadWorldMappings)
    task.spawn(createAutoSelectDropdowns)
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
