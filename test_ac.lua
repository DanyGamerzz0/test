-- Load Rayfield with error handling
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
}

-- ========== CREATE TABS ==========
local LobbyTab = Window:CreateTab("Lobby", "tv")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

-- ========== MACRO SYSTEM FUNCTIONS ==========

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

local function findUnitBySpawnUUID(spawnUUID)
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    if not unitsFolder then return nil end
    
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if isOwnedByLocalPlayer(unit) then
            local uuid = unit:GetAttribute("_SPAWN_UNIT_UUID")
            if uuid == spawnUUID or tostring(uuid) == tostring(spawnUUID) then
                return unit
            end
        end
    end
    
    return nil
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
    clearRecordingMapping()
    print("Started recording macro with enhanced snapshot tracking")
    print(string.format("Recording for player: %s", getLocalPlayer().Name))
end

local function getMacroFilename(name)
    if type(name) == "table" then name = name[1] or "" end
    if type(name) ~= "string" or name == "" then return nil end
    return "LixHub/Macros/AC/" .. name .. ".json"
end

local function serializeVector3(v)
    return { x = v.X, y = v.Y, z = v.Z }
end

local function deserializeVector3(t)
    return Vector3.new(t.x, t.y, t.z)
end

local function saveMacroToFile(name)
    if not name or name == "" then return end
    
    local data = macroManager[name]
    if not data then return end

    local serializedData = {}
    for _, action in ipairs(data) do
        local newAction = table.clone(action)
        if newAction.actualPosition then
            newAction.actualPosition = serializeVector3(newAction.actualPosition)
        end
        if newAction.unitPosition then
            newAction.unitPosition = serializeVector3(newAction.unitPosition)
        end
        table.insert(serializedData, newAction)
    end

    local json = Services.HttpService:JSONEncode(serializedData)
    local filePath = getMacroFilename(name)
    if filePath then
        writefile(filePath, json)
    end
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not filePath or not isfile(filePath) then return nil end

    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)

    for _, action in ipairs(data) do
        if action.actualPosition then
            action.actualPosition = deserializeVector3(action.actualPosition)
        end
        if action.unitPosition then
            action.unitPosition = deserializeVector3(action.unitPosition)
        end
    end
    
    return data
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

-- Action Handlers
local function handleUnitPlacement(args)
    if not isRecording or not recordingHasStarted then return end
    
    local unitId = args[1]
    local raycastData = args[2]
    local rotationIndex = args[3] or 0
    
    local timestamp = tick()
    local currentWaveNum = getCurrentWave()
    
    print(string.format("Recording placement attempt for unit ID: %s", unitId))
    
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
        local unitOwner = getUnitOwner(placedUnit)
        
        local placementData = {
            action = "PlaceUnit",
            unitId = unitId,
            unitType = unitType,
            spawnUUID = spawnUUID,
            actualPosition = actualPosition,
            raycast = {
                Origin = raycastData.Origin,
                Direction = raycastData.Direction,
                Unit = raycastData.Direction and raycastData.Direction.Unit,
            },
            rotation = rotationIndex,
            time = timestamp - recordingStartTime,
            wave = currentWaveNum,
            timestamp = timestamp,
            placementOrder = thisPlacementOrder,
            playerOwner = unitOwner and unitOwner.Name or "Unknown"
        }
        
        table.insert(macro, placementData)
        
        print(string.format("Recorded placement #%d: %s (Type: %s, UUID: %s)", 
            thisPlacementOrder, unitId, unitType, tostring(spawnUUID)))
    end
end

local function handleUnitUpgrade(args)
    if not isRecording or not recordingHasStarted then return end
    
    local spawnUUIDFromRemote = args[1]
    local timestamp = tick()
    local currentWaveNum = getCurrentWave()
    
    -- Extract placement UUID candidates
    local placementUUIDCandidates = {}
    
    if type(spawnUUIDFromRemote) == "string" then
        for i = 1, 3 do
            local substr = spawnUUIDFromRemote:sub(-i)
            if tonumber(substr) then
                table.insert(placementUUIDCandidates, tonumber(substr))
            end
        end
        
        local endDigits = spawnUUIDFromRemote:match("([%d]+)$")
        if endDigits then
            table.insert(placementUUIDCandidates, tonumber(endDigits))
        end
    end
    
    if #placementUUIDCandidates == 0 then return end
    
    local targetPlacementOrder = nil
    local matchedUUID = nil
    
    for _, candidateUUID in ipairs(placementUUIDCandidates) do
        for placementOrder, storedUUID in pairs(placementOrderToSpawnUUID) do
            if storedUUID == candidateUUID or 
               tostring(storedUUID) == tostring(candidateUUID) or
               tonumber(storedUUID) == tonumber(candidateUUID) then
                targetPlacementOrder = placementOrder
                matchedUUID = candidateUUID
                break
            end
        end
        if targetPlacementOrder then break end
    end
    
    if not targetPlacementOrder then return end
    
    local expectedPosition = placementOrderToPosition[targetPlacementOrder]
    local originalUnitId = nil
    
    for _, action in ipairs(macro) do
        if action.action == "PlaceUnit" and action.placementOrder == targetPlacementOrder then
            originalUnitId = action.unitId
            break
        end
    end
    
    table.insert(macro, {
        action = "UpgradeUnit",
        unitId = originalUnitId,
        spawnUUID = matchedUUID,
        upgradeRemoteParam = spawnUUIDFromRemote,
        unitPosition = expectedPosition,
        time = timestamp - recordingStartTime,
        wave = currentWaveNum,
        targetPlacementOrder = targetPlacementOrder,
        playerOwner = getLocalPlayer().Name
    })
    
    print(string.format("Recorded upgrade for placement #%d", targetPlacementOrder))
end

local function handleUnitSell(args)
    if not isRecording or not recordingHasStarted then return end
    
    local spawnUUIDFromRemote = args[1]
    local timestamp = tick()
    local currentWaveNum = getCurrentWave()
    
    -- Similar UUID extraction logic as upgrade
    local placementUUIDCandidates = {}
    
    if type(spawnUUIDFromRemote) == "string" then
        for i = 1, 3 do
            local substr = spawnUUIDFromRemote:sub(-i)
            if tonumber(substr) then
                table.insert(placementUUIDCandidates, tonumber(substr))
            end
        end
        
        local endDigits = spawnUUIDFromRemote:match("([%d]+)$")
        if endDigits then
            table.insert(placementUUIDCandidates, tonumber(endDigits))
        end
    end
    
    if #placementUUIDCandidates == 0 then return end
    
    local targetPlacementOrder = nil
    local matchedUUID = nil
    
    for _, candidateUUID in ipairs(placementUUIDCandidates) do
        for placementOrder, storedUUID in pairs(placementOrderToSpawnUUID) do
            if storedUUID == candidateUUID or 
               tostring(storedUUID) == tostring(candidateUUID) or
               tonumber(storedUUID) == tonumber(candidateUUID) then
                targetPlacementOrder = placementOrder
                matchedUUID = candidateUUID
                break
            end
        end
        if targetPlacementOrder then break end
    end
    
    if not targetPlacementOrder then return end
    
    local expectedPosition = placementOrderToPosition[targetPlacementOrder]
    local originalUnitId = nil
    
    for _, action in ipairs(macro) do
        if action.action == "PlaceUnit" and action.placementOrder == targetPlacementOrder then
            originalUnitId = action.unitId
            break
        end
    end
    
    table.insert(macro, {
        action = "SellUnit",
        unitId = originalUnitId,
        spawnUUID = matchedUUID,
        sellRemoteParam = spawnUUIDFromRemote,
        unitPosition = expectedPosition,
        time = timestamp - recordingStartTime,
        wave = currentWaveNum,
        targetPlacementOrder = targetPlacementOrder,
        playerOwner = getLocalPlayer().Name
    })
    
    print(string.format("Recorded sell for placement #%d", targetPlacementOrder))
    
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
    
    table.insert(macro, {
        action = "SkipWave",
        time = timestamp - recordingStartTime,
        wave = currentWaveNum,
        timestamp = timestamp,
        playerOwner = getLocalPlayer().Name
    })
    
    print(string.format("Recorded wave skip at wave %d", currentWaveNum))
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
                        handleUnitUpgrade(args)
                    elseif self.Name == MACRO_CONFIG.SELL_REMOTE then
                        handleUnitSell(args)
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

-- Playback Functions
local function executeAction(action, playbackMapping)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    
    if action.action == "PlaceUnit" then
        print(string.format("Executing: Place unit %s", action.unitId))
        
        local beforeSnapshot = takeUnitsSnapshot()
        
print("Raycast data:", action.raycast)
print("Origin:", action.raycast.Origin)
print("Direction:", action.raycast.Direction)

        endpoints:WaitForChild(MACRO_CONFIG.SPAWN_REMOTE):InvokeServer(
            action.unitId,
            action.raycast,
            action.rotation
        )
        
        task.wait(MACRO_CONFIG.PLACEMENT_WAIT_TIME + MACRO_CONFIG.SNAPSHOT_WAIT_TIME)
        local afterSnapshot = takeUnitsSnapshot()
        
        local placedUnit = findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
        if placedUnit and isOwnedByLocalPlayer(placedUnit) then
            local newSpawnUUID = placedUnit:GetAttribute("_SPAWN_UNIT_UUID")
            if newSpawnUUID then
                playbackMapping[action.placementOrder] = newSpawnUUID
                print(string.format("Mapped placement #%d to spawn UUID %s", action.placementOrder, tostring(newSpawnUUID)))
            end
        end
        
    elseif action.action == "UpgradeUnit" then
        local currentSpawnUUID = playbackMapping[action.targetPlacementOrder]
        if currentSpawnUUID then
            local unit = findUnitBySpawnUUID(currentSpawnUUID)
            if unit and isOwnedByLocalPlayer(unit) then
                print(string.format("Executing: Upgrade placement #%d", action.targetPlacementOrder))
                
                local success = false
                
                if action.unitId then
                    success = pcall(function()
                        endpoints:WaitForChild(MACRO_CONFIG.UPGRADE_REMOTE):InvokeServer(tostring(action.unitId) .. tostring(currentSpawnUUID))
                    end)
                end
                
                if not success then
                    pcall(function()
                        endpoints:WaitForChild(MACRO_CONFIG.UPGRADE_REMOTE):InvokeServer(currentSpawnUUID)
                    end)
                end
            end
        end
        
    elseif action.action == "SellUnit" then
        local currentSpawnUUID = playbackMapping[action.targetPlacementOrder]
        if currentSpawnUUID then
            local unit = findUnitBySpawnUUID(currentSpawnUUID)
            if unit and isOwnedByLocalPlayer(unit) then
                print(string.format("Executing: Sell placement #%d", action.targetPlacementOrder))
                
                local success = pcall(function()
                    if action.unitId then
                        endpoints:WaitForChild(MACRO_CONFIG.SELL_REMOTE):InvokeServer(tostring(action.unitId) .. tostring(currentSpawnUUID))
                    else
                        endpoints:WaitForChild(MACRO_CONFIG.SELL_REMOTE):InvokeServer(currentSpawnUUID)
                    end
                end)
                
                if success then
                    playbackMapping[action.targetPlacementOrder] = nil
                end
            end
        end
        
    elseif action.action == "SkipWave" then
        print("Executing: Skip wave")
        endpoints:WaitForChild(MACRO_CONFIG.WAVE_SKIP_REMOTE):InvokeServer()
    end
end

local function playMacroLoop()
    if not macro or #macro == 0 then
        print("No macro data to play back")
        return
    end
    
    print(string.format("Starting macro playback with %d actions", #macro))
    
    local playbackMapping = {}
    local startTime = tick()
    
    for i, action in ipairs(macro) do
        if not isPlaybacking then break end
        
        local targetTime = action.time
        local currentTime = tick() - startTime
        local waitTime = targetTime - currentTime
        
        if waitTime > 0 then
            task.wait(waitTime)
        end
        
        if isPlaybacking then
            executeAction(action, playbackMapping)
        end
    end
    
    print("Macro playback completed")
end

local function waitForGameStart()
    while true do
        if Services.Workspace:FindFirstChild("_wave_num") then
            local wave = Services.Workspace._wave_num.Value
            if wave >= 1 then
                print("Game detected - wave " .. wave)
                break
            end
        end
        task.wait(1)
    end
end

-- ========== EXISTING FUNCTIONS (keep all your existing functions) ==========
local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title or "Notice",
        Content = content or "No message.",
        Duration = duration or 5,
        Image = "info",
    })
end

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

    -- STORY
    if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and State.StoryDifficultySelected then
        setProcessingState("Story Auto Join")

        -- Build the complete stage ID
        local completeStageId = State.StoryStageSelected .. State.StoryActSelected
        
        print("=== JOINING STORY STAGE ===")
        print("World: " .. State.StoryStageSelected)
        print("Act: " .. State.StoryActSelected)
        print("Complete Stage ID: " .. completeStageId)
        print("Difficulty: " .. State.StoryDifficultySelected)

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
        
        print("=== JOINING LEGEND STAGE ===")
        print("Legend World: " .. State.LegendStageSelected)
        print("Legend Act: " .. State.LegendActSelected)
        print("Complete Legend Stage ID: " .. string.lower(completeLegendStageId))

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
end

local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StageStorySelector",
    Callback = function(Option)
        local selectedDisplayName = type(Option) == "table" and Option[1] or Option
        local backendWorldKey = getBackendWorldKeyFromDisplayName(selectedDisplayName)
        
        if backendWorldKey then
            State.StoryStageSelected = backendWorldKey
            print("Selected: " .. selectedDisplayName .. " -> Backend: " .. backendWorldKey)
        else
            warn("Could not find backend world key for: " .. tostring(selectedDisplayName))
        end
    end,
})

local LegendStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "LegendWorldSelector",
    Callback = function(Option)
        local selectedDisplayName = type(Option) == "table" and Option[1] or Option
        local backendWorldKey = getBackendLegendWorldKeyFromDisplayName(selectedDisplayName)
        
        if backendWorldKey then
            State.LegendStageSelected = backendWorldKey
            print("Selected Legend World: " .. selectedDisplayName .. " -> Backend: " .. backendWorldKey)
        else
            warn("Could not find backend legend world key for: " .. tostring(selectedDisplayName))
        end
    end,
})

local function loadLegendStages()
    print("=== LEGEND STAGE LOADER ===")
    print("Loading legend world names into dropdown...")
    
    -- Get the world ordering data
    local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
    local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
    
    if not WorldsFolder then
        print("Worlds folder not found!")
        LegendStageDropdown:Refresh({})
        return
    end
    
    if not WorldLevelOrder or not WorldLevelOrder.LEGEND_WORLD_ORDER then
        print("WorldLevelOrder or LEGEND_WORLD_ORDER not found!")
        LegendStageDropdown:Refresh({})
        return
    end

    local displayNames = {}
    
    -- Process legend worlds in the specified order from LEGEND_WORLD_ORDER
    for _, orderedWorldKey in ipairs(WorldLevelOrder.LEGEND_WORLD_ORDER) do
        print("  Processing ordered legend world: " .. orderedWorldKey)
        
        -- Get all world modules to find the one containing this world
        local worldModules = WorldsFolder:GetChildren()
        
        for _, worldModule in ipairs(worldModules) do
            if worldModule:IsA("ModuleScript") then
                local success, worldData = pcall(require, worldModule)
                
                if success and worldData and worldData[orderedWorldKey] then
                    local worldInfo = worldData[orderedWorldKey]
                    
                    if type(worldInfo) == "table" and worldInfo.name and worldInfo.legend_stage then
                        table.insert(displayNames, worldInfo.name)
                        print("    Loaded legend world: " .. worldInfo.name .. " (" .. orderedWorldKey .. ")")
                    end
                    break
                end
            end
        end
    end
    
    if #displayNames > 0 then
        LegendStageDropdown:Refresh(displayNames)
        print("Loaded " .. #displayNames .. " legend worlds into dropdown")
    else
        print("No legend worlds found!")
        LegendStageDropdown:Refresh({})
    end
end

local function loadStoryStages()
    print("=== WORLD STAGE LOADER ===")
    print("Loading world names into dropdown...")
    
    local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
    local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
    
    if not WorldsFolder then
        print("Worlds folder not found!")
        StoryStageDropdown:Refresh({})
        return
    end
    
    if not WorldLevelOrder or not WorldLevelOrder.WORLD_ORDER then
        print("WorldLevelOrder or WORLD_ORDER not found!")
        StoryStageDropdown:Refresh({})
        return
    end

    local displayNames = {}
    
    for _, orderedWorldKey in ipairs(WorldLevelOrder.WORLD_ORDER) do
        print("  Processing ordered world: " .. orderedWorldKey)
        
        local worldModules = WorldsFolder:GetChildren()
        
        for _, worldModule in ipairs(worldModules) do
            if worldModule:IsA("ModuleScript") then
                local success, worldData = pcall(require, worldModule)
                
                if success and worldData and worldData[orderedWorldKey] then
                    local worldInfo = worldData[orderedWorldKey]
                    
                    if type(worldInfo) == "table" and worldInfo.name then
                        table.insert(displayNames, worldInfo.name)
                        print("    Loaded world: " .. worldInfo.name .. " (" .. orderedWorldKey .. ")")
                    end
                    break
                end
            end
        end
    end
    
    if #displayNames > 0 then
        StoryStageDropdown:Refresh(displayNames)
        print("Loaded " .. #displayNames .. " worlds into dropdown")
    else
        print("No worlds found!")
        StoryStageDropdown:Refresh({})
    end
end

-- Macro UI Functions

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
        print("Act selected: " .. (State.StoryActSelected or "none"))
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
            print("Legend Act selected: " .. State.LegendActSelected)
        end
    end,
})

-- Game Tab
local RetryToggle = GameTab:CreateToggle({
   Name = "Auto Retry",
   CurrentValue = false,
   Flag = "AutoRetry",
   Callback = function(Value)
        State.AutoVoteRetry = Value
   end,
})

local NextToggle = GameTab:CreateToggle({
   Name = "Auto Next",
   CurrentValue = false,
   Flag = "AutoNext",
   Callback = function(Value)
        State.AutoVoteNext = Value
   end,
})

local LobbyToggle = GameTab:CreateToggle({
   Name = "Auto Lobby",
   CurrentValue = false,
   Flag = "AutoLobby",
   Callback = function(Value)
        State.AutoVoteLobby = Value
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
    Name = "Record",
    CurrentValue = false,
    Flag = "RecordMacro",
    Callback = function(Value)
        isRecording = Value

        if Value and not isRecordingLoopRunning then
            recordingHasStarted = false
            MacroStatusLabel:Set("Status: Preparing to record...")
            notify(nil,"Macro Recording: Waiting for game to start...")

            task.spawn(function()
                waitForGameStart()
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

local PlayToggle = MacroTab:CreateToggle({
    Name = "Playback",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isPlaybacking = Value

        if Value and not isPlayingLoopRunning then
            MacroStatusLabel:Set("Status: Preparing playback...")
            notify(nil,"Macro Playback: Waiting for game to start...")

            task.spawn(function()
                waitForGameStart()
                if isPlaybacking then
                    if currentMacroName then
                        local loadedMacro = loadMacroFromFile(currentMacroName)
                        if loadedMacro then
                            macro = loadedMacro
                        else
                            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
                            notify(nil,"Playback Error: Failed to load macro: " .. tostring(currentMacroName))
                            isPlaybacking = false
                            --PlayToggle:Set(false)
                            return
                        end
                    else
                        MacroStatusLabel:Set("Status: Error - No macro selected!")
                        notify(nil,"Playback Error: No macro selected for playback.")
                        isPlaybacking = false
                        --PlayToggle:Set(false)
                        return
                    end

                    isPlayingLoopRunning = true
                    notify(nil,"Playback Started: Macro is now executing...")
                    MacroStatusLabel:Set("Status: Playing macro...")
                    playMacroLoop()
                    isPlayingLoopRunning = false
                    MacroStatusLabel:Set("Status: Playback completed")
                    --PlayToggle:Set(false)
                    isPlaybacking = false
                end
            end)
        elseif not Value then
            MacroStatusLabel:Set("Status: Playback disabled")
            print("Macro Playback: Playback disabled.")
        end
    end,
})

local CheckUnitsButton = MacroTab:CreateButton({
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
})

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
            
            -- Priority 1: Auto Retry (highest priority)
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
                return -- Exit early since retry has highest priority
            end
            
            -- Priority 2: Auto Next (medium priority) - only for victories
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
            
            -- Priority 3: Auto Lobby (lowest priority)
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
        
        -- Handle webhook and tracking (existing code)
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

-- Auto joiner loop
task.spawn(function()
    while true do
        task.wait(0.5)
        checkAndExecuteHighestPriority()
    end
end)

-- Load stages and macros
loadStoryStages()
loadLegendStages()

-- Only monitor waves if not in lobby
if not isInLobby() then 
    monitorWaves() 
end

-- Initialize macro system
ensureMacroFolders()
loadAllMacros()

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

-- Load Rayfield configuration
Rayfield:LoadConfiguration()

print("LixHub - Anime Crusaders with Enhanced Macro System loaded!")
print("Macro system features:")
print("- Enhanced unit tracking with snapshots")
print("- Player ownership validation")
print("- Automatic placement order tracking")
print("- Smart upgrade/sell target matching")
print("- File-based macro persistence")
print("Ready for recording and playback!")
