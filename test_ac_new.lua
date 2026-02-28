-- ============================================================
-- LIXHUB MACRO SYSTEM - REFACTORED
-- ============================================================

-- ============================================================
-- CONFIGURATION FLAGS
-- ============================================================
local DEBUG = true -- Set to false to disable all debug prints
local NOTIFICATION_ENABLED = true -- Can be toggled via UI

-- ============================================================
-- EXECUTOR CHECK
-- ============================================================
if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 107573139811370 and game.PlaceId ~= 72115712027203 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

-- ============================================================
-- SERVICES
-- ============================================================
local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local Util = {}

function Util.debugPrint(message, ...)
    if DEBUG then
        print("[DEBUG]", message, ...)
    end
end

function Util.notify(title, content, duration)
    if not NOTIFICATION_ENABLED then return end
    
    if _G.Rayfield then
        _G.Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
        })
    end
end

function Util.isInLobby()
    local mapConfig = Services.Workspace:FindFirstChild("_MAP_CONFIG")
    if mapConfig and mapConfig:FindFirstChild("IsLobby") then
        return mapConfig.IsLobby.Value
    end
    return false
end

function Util.getPlayerMoney()
    local player = Services.Players.LocalPlayer
    if player and player:FindFirstChild("_stats") and player._stats:FindFirstChild("resource") then
        return player._stats.resource.Value
    end
    return 0
end

function Util.ensureFolders()
    if not isfolder("LixHub") then makefolder("LixHub") end
    if not isfolder("LixHub/Macros") then makefolder("LixHub/Macros") end
    if not isfolder("LixHub/Macros/AC") then makefolder("LixHub/Macros/AC") end
end

function Util.getMacroFilename(name)
    if type(name) == "table" then name = name[1] or "" end
    if type(name) ~= "string" or name == "" then return nil end
    return "LixHub/Macros/AC/" .. name .. ".json"
end

function Util.isOwnedByLocalPlayer(unit)
    local stats = unit:FindFirstChild("_stats")
    if not stats then return false end
    
    local playerValue = stats:FindFirstChild("player")
    if not playerValue or not playerValue:IsA("ObjectValue") then return false end
    
    if playerValue.Value ~= Services.Players.LocalPlayer then return false end
    
    -- Skip summons (they have Parent_unit)
    if stats:FindFirstChild("Parent_unit") then return false end
    
    return true
end

function Util.getUnitUpgradeLevel(unit)
    if unit and unit:FindFirstChild("_stats") and unit._stats:FindFirstChild("upgrade") then
        return unit._stats.upgrade.Value
    end
    return 0
end

function Util.getUnitSpawnId(unit)
    if not unit then return nil end
    
    local stats = unit:FindFirstChild("_stats")
    if stats then
        local spawnIdValue = stats:FindFirstChild("spawn_id")
        if spawnIdValue then
            return spawnIdValue.Value
        end
    end
    
    local spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID")
    if spawnUUID then return spawnUUID end
    
    return nil
end

function Util.getInternalSpawnName(unit)
    if not unit or not unit:FindFirstChild("_stats") then return nil end
    
    local idValue = unit._stats:FindFirstChild("id")
    if idValue and idValue:IsA("StringValue") then
        return idValue.Value
    end
    
    return nil
end

function Util.getDisplayNameFromUnitId(unitId)
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

function Util.getUnitIdFromDisplayName(displayName)
    if not displayName then return nil end
    
    local success, unitId = pcall(function()
        local UnitsFolder = Services.ReplicatedStorage.Framework.Data.Units
        if not UnitsFolder then return nil end
        
        for _, moduleScript in pairs(UnitsFolder:GetDescendants()) do
            if moduleScript:IsA("ModuleScript") then
                local moduleSuccess, unitData = pcall(require, moduleScript)
                
                if moduleSuccess and unitData then
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
    
    return success and unitId or displayName
end

function Util.getUnitData(unitId)
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

function Util.getCostScale()
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
        return 1.0
    end)
    
    return success and costScale or 1.0
end

function Util.getPlacementCost(unitId)
    local unitData = Util.getUnitData(unitId)
    local baseCost = unitData and unitData.cost or 0
    local costScale = Util.getCostScale()
    
    return math.floor(baseCost * costScale)
end

function Util.getUpgradeCost(unitId, currentLevel)
    local unitData = Util.getUnitData(unitId)
    if not unitData or not unitData.upgrade then return 0 end

    local upgradeIndex = currentLevel + 1
    if upgradeIndex > #unitData.upgrade then return 0 end
    
    local baseCost = unitData.upgrade[upgradeIndex] and unitData.upgrade[upgradeIndex].cost or 0
    local costScale = Util.getCostScale()
    
    return math.floor(baseCost * costScale)
end

function Util.getMultiUpgradeCost(unitId, currentLevel, upgradeAmount)
    local unitData = Util.getUnitData(unitId)
    if not unitData or not unitData.upgrade then return 0 end
    
    local totalCost = 0
    local costScale = Util.getCostScale()
    
    for i = 1, upgradeAmount do
        local upgradeIndex = currentLevel + i
        if upgradeIndex > #unitData.upgrade then break end
        
        local baseCost = unitData.upgrade[upgradeIndex] and unitData.upgrade[upgradeIndex].cost or 0
        totalCost = totalCost + math.floor(baseCost * costScale)
    end
    
    return totalCost
end

function Util.parseUnitString(unitString)
    local displayName, instanceNumber = unitString:match("^(.-) #%s*(%d+)$")
    if displayName and instanceNumber then
        return displayName, tonumber(instanceNumber)
    end
    return nil, nil
end

function Util.resolveUUIDFromInternalName(internalName)
    if not internalName then return nil end
    
    local success, uuid = pcall(function()
        local fxCache = Services.ReplicatedStorage:FindFirstChild("_FX_CACHE")
        if not fxCache then return nil end
        
        for _, child in pairs(fxCache:GetChildren()) do
            local itemIndex = child:GetAttribute("ITEMINDEX")
            
            if itemIndex == internalName then
                -- Check if this unit is equipped
                local equippedList = child:FindFirstChild("EquippedList")
                if equippedList then
                    local equipped = equippedList:FindFirstChild("Equipped")
                    if equipped and equipped.Visible == true then
                        local uuidValue = child:FindFirstChild("_uuid")
                        if uuidValue and uuidValue:IsA("StringValue") then
                            Util.debugPrint("Found EQUIPPED unit", internalName, "UUID:", uuidValue.Value)
                            return uuidValue.Value
                        end
                    end
                end
            end
        end
        
        Util.debugPrint("WARNING: No equipped unit found for", internalName)
        return nil
    end)
    
    if not success then
        warn("Error resolving UUID for", internalName, ":", uuid)
        return nil
    end
    
    return uuid
end

-- ============================================================
-- GAME TRACKING MODULE
-- ============================================================
local GameTracking = {
    gameInProgress = false,
    gameStartTime = 0,
    gameHasEnded = false,
}

function GameTracking.startGame()
    if GameTracking.gameInProgress then return end
    
    GameTracking.gameInProgress = true
    GameTracking.gameStartTime = tick()
    GameTracking.gameHasEnded = false
    
    Util.debugPrint("Game started at:", GameTracking.gameStartTime)
end

function GameTracking.endGame()
    GameTracking.gameHasEnded = true
    GameTracking.gameInProgress = false
    
    Util.debugPrint("Game ended")
end

function GameTracking.reset()
    GameTracking.gameInProgress = false
    GameTracking.gameStartTime = 0
    GameTracking.gameHasEnded = false
end

-- ============================================================
-- MACRO MODULE
-- ============================================================
local Macro = {
    -- State
    isRecording = false,
    isPlaying = false,
    currentName = "",
    hasPlayedThisGame = false,
    
    -- Data
    actions = {},
    library = {},
    
    -- Recording tracking
    recordingHasStarted = false,
    trackedUnits = {},
    spawnIdToPlacement = {},
    placementCounter = {},
    unitNameToSpawnId = {},
    
    -- Playback tracking
    playbackPlacementToSpawnId = {},
    
    -- UI
    detailedStatusLabel = nil,
    
    -- Config
    SPAWN_REMOTE = "spawn_unit",
    UPGRADE_REMOTE = "upgrade_unit_ingame",
    SELL_REMOTE = "sell_unit_ingame",
    WAVE_SKIP_REMOTE = "vote_wave_skip",
    
    -- Special ability remotes (with unique argument structures)
    SPECIAL_ABILITY_REMOTES = {
        "use_active_attack",      -- Normal unit abilities
        "HestiaAssignBlade",      -- Hestia: args[1] = targetSpawnId
        "LelouchChoosePiece",     -- Lelouch: args[1] = lelouchSpawnId, args[2] = targetSpawnId, args[3] = pieceType
        "DioWrites",              -- Dio: args[1] = dioSpawnId, args[2] = abilityType
        "FrierenMagics",          -- Frieren: TBD
    },
    
    PLACEMENT_WAIT = 0.3,
    
    -- Validation config
    PLACEMENT_MAX_RETRIES = 3,
    UPGRADE_MAX_RETRIES = 3,
    PLACEMENT_TIMEOUT = 5.0,
    UPGRADE_TIMEOUT = 4.0,
    VALIDATION_INTERVAL = 0.1,
    RETRY_DELAY = 0.5,
    NORMAL_VALIDATION = 0.3,
    EXTENDED_VALIDATION = 1.0,
    
    -- Settings
    randomOffsetEnabled = false,
    randomOffsetAmount = 0.5,
    ignoreTiming = false,
}

function Macro.updateStatus(message)
    if Macro.detailedStatusLabel then
        Macro.detailedStatusLabel:Set("Macro Details: " .. message)
    end
    Util.debugPrint("Macro Status:", message)
end

function Macro.clearSpawnIdMappings()
    Util.debugPrint("=== CLEARING SPAWN ID MAPPINGS ===")
    for key, value in pairs(Macro.playbackPlacementToSpawnId) do
        Util.debugPrint(string.format("  Clearing: %s -> %s", key, tostring(value)))
    end
    
    Macro.spawnIdToPlacement = {}
    Macro.placementCounter = {}
    Macro.unitNameToSpawnId = {}
    Macro.playbackPlacementToSpawnId = {}
    
    Util.debugPrint("=== MAPPINGS CLEARED ===")
end

-- ============================================================
-- SNAPSHOT FUNCTIONS
-- ============================================================
function Macro.takeUnitsSnapshot()
    local snapshot = {}
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    
    if not unitsFolder then 
        Util.debugPrint("_UNITS folder not found")
        return snapshot 
    end
    
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if Util.isOwnedByLocalPlayer(unit) then
            local unitData = {
                instance = unit,
                name = unit.Name,
                spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID"),
                position = unit.PrimaryPart and unit.PrimaryPart.Position or 
                        unit:FindFirstChildWhichIsA("BasePart") and unit:FindFirstChildWhichIsA("BasePart").Position,
            }
            
            if unitData.position and unitData.spawnUUID then
                table.insert(snapshot, unitData)
            end
        end
    end
    
    Util.debugPrint(string.format("Snapshot: %d player-owned units found", #snapshot))
    return snapshot
end

function Macro.findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
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
        Util.debugPrint("No new units detected")
        return nil
    elseif #newUnits == 1 then
        Util.debugPrint(string.format("Found newly placed unit: %s (UUID: %s)", 
            newUnits[1].name, tostring(newUnits[1].spawnUUID)))
        return newUnits[1].instance
    else
        Util.debugPrint(string.format("Multiple new units detected (%d), returning first", #newUnits))
        return newUnits[1].instance
    end
end

function Macro.findUnitBySpawnUUID(targetUUID)
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    if not unitsFolder then return nil end
    
    Util.debugPrint(string.format("Searching for unit with _SPAWN_UNIT_UUID: %s", tostring(targetUUID)))
    
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if Util.isOwnedByLocalPlayer(unit) then
            local spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID")
            if spawnUUID and tostring(spawnUUID) == tostring(targetUUID) then
                Util.debugPrint(string.format("✓ Found unit: %s with _SPAWN_UNIT_UUID: %s", unit.Name, tostring(spawnUUID)))
                return unit
            end
        end
    end
    
    Util.debugPrint(string.format("✗ No unit found with _SPAWN_UNIT_UUID: %s", tostring(targetUUID)))
    return nil
end

-- ============================================================
-- RECORDING FUNCTIONS
-- ============================================================
function Macro.startRecording()
    table.clear(Macro.actions)
    Macro.clearSpawnIdMappings()
    Macro.trackedUnits = {}
    Macro.isRecording = true
    Macro.recordingHasStarted = true
    
    if GameTracking.gameStartTime == 0 then
        GameTracking.gameStartTime = tick()
        Util.debugPrint("Setting game start time for recording:", GameTracking.gameStartTime)
    end
    
    Util.debugPrint("Started recording with spawn ID mapping system")
    Util.notify("Recording Started", "Macro recording is active")
end

function Macro.stopRecording()
    Macro.isRecording = false
    Macro.recordingHasStarted = false
    
    Util.debugPrint(string.format("Stopped recording. Recorded %d actions", #Macro.actions))
    
    if Macro.currentName and Macro.currentName ~= "" then
        Macro.library[Macro.currentName] = Macro.actions
        Macro.saveToFile(Macro.currentName)
    end
    
    return Macro.actions
end

function Macro.processPlacementRecording(actionInfo)
    local beforeSnapshot = actionInfo.preActionUnits or Macro.takeUnitsSnapshot()
    
    task.wait(0.3)
    
    local afterSnapshot = Macro.takeUnitsSnapshot()
    local spawnedUnit = Macro.findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
    
    if not spawnedUnit then
        Util.debugPrint("Could not find newly placed unit")
        Util.notify("Macro Recorder", "Could not find newly placed unit")
        return
    end
    
    local internalName = Util.getInternalSpawnName(spawnedUnit)
    local displayName = Util.getDisplayNameFromUnitId(internalName)
    
    if not displayName then
        Util.debugPrint("Could not get display name for unit")
        Util.notify("Macro Recorder", "Could not get display name for unit")
        return
    end
    
    -- Increment placement counter
    Macro.placementCounter[displayName] = (Macro.placementCounter[displayName] or 0) + 1
    local placementNumber = Macro.placementCounter[displayName]
    local placementId = string.format("%s #%d", displayName, placementNumber)
    
    -- Get UUID for mapping
    local stats = spawnedUnit:FindFirstChild("_stats")
    if not stats then
        Util.notify("Macro Recorder", "No _stats found on spawned unit")
        return
    end

    local uuidValue = stats:FindFirstChild("uuid")
    if not uuidValue or not uuidValue:IsA("StringValue") then
        Util.notify("Macro Recorder", "No uuid found in _stats")
        return
    end

    local actualUUID = uuidValue.Value
    local spawnIdValue = stats:FindFirstChild("spawn_id")
    local combinedIdentifier = actualUUID
    
    if spawnIdValue then
        combinedIdentifier = actualUUID .. spawnIdValue.Value
    end

    -- Map for tracking
    Macro.spawnIdToPlacement[combinedIdentifier] = placementId
    Macro.unitNameToSpawnId[spawnedUnit.Name] = combinedIdentifier

    Util.debugPrint(string.format("Mapped combined ID %s -> %s", combinedIdentifier, placementId))
    
    -- Store macro record
    local raycastData = actionInfo.args[2] or {}
    local rotation = actionInfo.args[3] or 0
    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    
    local placementRecord = {
        Type = "spawn_unit",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime),
        Pos = raycastData.Origin and string.format("%.17f, %.17f, %.17f", 
            raycastData.Origin.X, raycastData.Origin.Y, raycastData.Origin.Z) or "",
        Dir = raycastData.Direction and string.format("%.17f, %.17f, %.17f", 
            raycastData.Direction.X, raycastData.Direction.Y, raycastData.Direction.Z) or "",
        Rot = rotation ~= 0 and rotation or 0
    }
    
    table.insert(Macro.actions, placementRecord)
    
    Util.debugPrint(string.format("Recorded placement: %s (UUID: %s)", placementId, actualUUID))
    Util.notify("Macro Recorder", string.format("Recorded placement: %s", placementId))
end

function Macro.processSellRecording(actionInfo)
    local remoteParam = actionInfo.args[1]
    
    local spawnId = Macro.unitNameToSpawnId[remoteParam]
    if not spawnId then
        Util.debugPrint("Could not find spawn ID for unit name:", remoteParam)
        return
    end
    
    local placementId = Macro.spawnIdToPlacement[spawnId]
    if not placementId then
        Util.debugPrint("Could not find placement mapping for spawn_id:", spawnId)
        return
    end
    
    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    
    local sellRecord = {
        Type = "sell_unit_ingame",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime)
    }
    
    table.insert(Macro.actions, sellRecord)
    
    -- Clean up mappings
    Macro.spawnIdToPlacement[spawnId] = nil
    Macro.unitNameToSpawnId[remoteParam] = nil
    
    Util.debugPrint(string.format("Recorded sell: %s", placementId))
    Util.notify("Macro Recorder", string.format("Recorded sell: %s", placementId))
end

function Macro.processWaveSkipRecording(actionInfo)
    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    
    table.insert(Macro.actions, {
        Type = "vote_wave_skip",
        Time = string.format("%.2f", gameRelativeTime)
    })
    
    Util.notify("Macro Recorder", "Recorded wave skip")
end

function Macro.processAbilityRecording(actionInfo)
    local remoteName = actionInfo.remoteName
    local args = actionInfo.args
    
    Util.debugPrint(string.format("Processing ability: %s with %d args", remoteName, #args))
    
    -- Helper function to find placement ID by spawn_id
    local function findPlacementBySpawnId(targetSpawnId)
        if not targetSpawnId then return nil end
        
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        if not unitsFolder then return nil end
        
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if Util.isOwnedByLocalPlayer(unit) then
                local stats = unit:FindFirstChild("_stats")
                if stats then
                    local unitSpawnId = stats:FindFirstChild("spawn_id")
                    if unitSpawnId and tostring(unitSpawnId.Value) == tostring(targetSpawnId) then
                        local uuidValue = stats:FindFirstChild("uuid")
                        if uuidValue and uuidValue:IsA("StringValue") then
                            local combinedIdentifier = uuidValue.Value .. tostring(unitSpawnId.Value)
                            local placementId = Macro.spawnIdToPlacement[combinedIdentifier]
                            if placementId then
                                Util.debugPrint(string.format("Found unit: spawn_id=%s -> placement=%s", 
                                    tostring(targetSpawnId), placementId))
                                return placementId
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    
    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    local abilityRecord = nil
    
    -- Handle different ability types
    if remoteName == "HestiaAssignBlade" then
        -- Hestia: args[1] = targetSpawnId
        local targetSpawnId = args[1]
        local targetPlacementId = findPlacementBySpawnId(targetSpawnId)
        
        if not targetPlacementId then
            Util.debugPrint("Could not find target for Hestia ability")
            return
        end
        
        abilityRecord = {
            Type = "HestiaAssignBlade",
            Target = targetPlacementId,
            Time = string.format("%.2f", gameRelativeTime)
        }
        
        Util.notify("Macro Recorder", string.format("Recorded Hestia ability: %s", targetPlacementId))
        
    elseif remoteName == "LelouchChoosePiece" then
        -- Lelouch: args[1] = lelouchSpawnId, args[2] = targetSpawnId, args[3] = pieceType
        local lelouchSpawnId = args[1]
        local targetSpawnId = args[2]
        local pieceType = args[3]
        
        local lelouchPlacementId = findPlacementBySpawnId(lelouchSpawnId)
        local targetPlacementId = findPlacementBySpawnId(targetSpawnId)
        
        if not lelouchPlacementId or not targetPlacementId then
            Util.debugPrint("Could not find Lelouch or target for ability")
            return
        end
        
        abilityRecord = {
            Type = "LelouchChoosePiece",
            Lelouch = lelouchPlacementId,
            Target = targetPlacementId,
            Piece = pieceType,
            Time = string.format("%.2f", gameRelativeTime)
        }
        
        Util.notify("Macro Recorder", string.format("Recorded Lelouch: %s (%s) -> %s", 
            lelouchPlacementId, pieceType, targetPlacementId))
        
    elseif remoteName == "DioWrites" then
        -- Dio: args[1] = dioSpawnId, args[2] = abilityType
        local dioSpawnId = args[1]
        local abilityType = args[2]
        
        local dioPlacementId = findPlacementBySpawnId(dioSpawnId)
        
        if not dioPlacementId then
            Util.debugPrint("Could not find Dio for ability")
            return
        end
        
        abilityRecord = {
            Type = "DioWrites",
            Dio = dioPlacementId,
            Ability = abilityType,
            Time = string.format("%.2f", gameRelativeTime)
        }
        
        Util.notify("Macro Recorder", string.format("Recorded Dio ability: %s (%s)", 
            dioPlacementId, abilityType))
        
    elseif remoteName == "use_active_attack" then
        -- Normal ability: args[1] = unit name (not spawn_id!)
        local unitName = args[1]
        
        if type(unitName) ~= "string" then
            Util.debugPrint("Invalid unit name for normal ability")
            return
        end
        
        local spawnId = Macro.unitNameToSpawnId[unitName]
        if not spawnId then
            Util.debugPrint("Could not find spawn ID for ability unit name:", unitName)
            return
        end
        
        local placementId = Macro.spawnIdToPlacement[spawnId]
        if not placementId then
            Util.debugPrint("Could not find placement mapping for ability")
            return
        end
        
        abilityRecord = {
            Type = "use_active_attack",
            Unit = placementId,
            Time = string.format("%.2f", gameRelativeTime)
        }
        
        Util.notify("Macro Recorder", string.format("Recorded ability: %s", placementId))
        
    else
        -- Unknown ability type - store raw
        Util.debugPrint("Unknown ability type:", remoteName)
        abilityRecord = {
            Type = remoteName,
            Time = string.format("%.2f", gameRelativeTime),
            Args = args
        }
    end
    
    if abilityRecord then
        table.insert(Macro.actions, abilityRecord)
        Util.debugPrint(string.format("Recorded %s ability", remoteName))
    end
end

function Macro.handleRemoteCall(remoteName, args, timestamp)
    if remoteName == Macro.SPAWN_REMOTE then
        task.spawn(function()
            if GameTracking.gameStartTime == 0 then
                GameTracking.gameStartTime = tick()
            end
            local preActionUnits = Macro.takeUnitsSnapshot()
            task.wait(0.3)
            Macro.processPlacementRecording({
                remoteName = Macro.SPAWN_REMOTE,
                args = args,
                timestamp = timestamp,
                preActionUnits = preActionUnits
            })
        end)
    elseif remoteName == Macro.SELL_REMOTE then
        task.spawn(function()
            Macro.processSellRecording({
                remoteName = Macro.SELL_REMOTE,
                args = args,
                timestamp = timestamp
            })
        end)
    elseif remoteName == Macro.WAVE_SKIP_REMOTE then
        task.spawn(function()
            Macro.processWaveSkipRecording({
                remoteName = Macro.WAVE_SKIP_REMOTE,
                timestamp = timestamp
            })
        end)
    else
        -- Check if it's an ability remote
        for _, abilityRemote in ipairs(Macro.SPECIAL_ABILITY_REMOTES) do
            if remoteName == abilityRemote then
                task.spawn(function()
                    Macro.processAbilityRecording({
                        remoteName = remoteName,
                        args = args,
                        timestamp = timestamp
                    })
                end)
                break
            end
        end
    end
end

-- ============================================================
-- UPGRADE TRACKING (HEARTBEAT MONITOR)
-- ============================================================
function Macro.setupUpgradeMonitoring()
    Services.RunService.Heartbeat:Connect(function()
        if not Macro.isRecording or not Macro.recordingHasStarted then return end

        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        if not unitsFolder then return end

        for _, unit in pairs(unitsFolder:GetChildren()) do
            if Util.isOwnedByLocalPlayer(unit) then
                local stats = unit:FindFirstChild("_stats")
                if not stats then continue end
                
                local uuidValue = stats:FindFirstChild("uuid")
                local spawnIdValue = stats:FindFirstChild("spawn_id")
                
                if not uuidValue or not uuidValue:IsA("StringValue") then continue end
                
                local combinedId = uuidValue.Value
                if spawnIdValue then
                    combinedId = combinedId .. spawnIdValue.Value
                end
                
                local placementId = Macro.spawnIdToPlacement[combinedId]
                
                -- Auto-map if needed
                if not placementId then
                    local internalName = Util.getInternalSpawnName(unit)
                    local displayName = Util.getDisplayNameFromUnitId(internalName)
                    
                    if displayName then
                        Macro.placementCounter[displayName] = (Macro.placementCounter[displayName] or 0) + 1
                        local placementNumber = Macro.placementCounter[displayName]
                        placementId = string.format("%s #%d", displayName, placementNumber)
                        Macro.spawnIdToPlacement[combinedId] = placementId
                        
                        Util.debugPrint(string.format("Auto-mapped unit for upgrade tracking: %s", placementId))
                    end
                end
                
                if placementId then
                    local currentLevel = Util.getUnitUpgradeLevel(unit)
                    
                    if not Macro.trackedUnits[combinedId] then
                        Macro.trackedUnits[combinedId] = {
                            placementId = placementId,
                            lastLevel = currentLevel
                        }
                    end
                    
                    local lastLevel = Macro.trackedUnits[combinedId].lastLevel
                    if currentLevel > lastLevel then
                        local levelIncrease = currentLevel - lastLevel
                        
                        local record = {
                            Type = Macro.UPGRADE_REMOTE,
                            Unit = placementId,
                            Time = string.format("%.2f", tick() - GameTracking.gameStartTime)
                        }
                        
                        if levelIncrease > 1 then
                            record.Amount = levelIncrease
                        end
                        
                        table.insert(Macro.actions, record)
                        
                        Util.debugPrint(string.format("✓ Recorded upgrade: %s (L%d→L%d)", 
                            placementId, lastLevel, currentLevel))
                        
                        Macro.trackedUnits[combinedId].lastLevel = currentLevel
                    end
                end
            end
        end
    end)
    
    Util.debugPrint("Upgrade monitoring initialized")
end

-- ============================================================
-- MACRO HOOK SETUP
-- ============================================================
function Macro.setupHook()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if not checkcaller() and Macro.isRecording and self.Parent and self.Parent.Name == "client_to_server" then
            -- Check for standard remotes
            if self.Name == Macro.SPAWN_REMOTE or 
               self.Name == Macro.SELL_REMOTE or 
               self.Name == Macro.WAVE_SKIP_REMOTE then
                Macro.handleRemoteCall(self.Name, args, tick())
            else
                -- Check if it's any ability remote
                for _, abilityRemote in ipairs(Macro.SPECIAL_ABILITY_REMOTES) do
                    if self.Name == abilityRemote then
                        Macro.handleRemoteCall(self.Name, args, tick())
                        break
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    Macro.setupUpgradeMonitoring()
    
    Util.debugPrint("Macro hooks initialized")
end

-- ============================================================
-- FILE OPERATIONS
-- ============================================================
function Macro.saveToFile(name)
    if not name or name == "" then return end
    
    local data = Macro.library[name]
    if not data then return end

    local json = Services.HttpService:JSONEncode(data)
    local filePath = Util.getMacroFilename(name)
    
    if filePath then
        writefile(filePath, json)
        Util.debugPrint("Saved macro:", name, "with", #data, "actions")
    end
end

function Macro.loadFromFile(name)
    local filePath = Util.getMacroFilename(name)
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

function Macro.loadAll()
    Macro.library = {}
    Util.ensureFolders()
    
    local success, files = pcall(function()
        return listfiles("LixHub/Macros/AC/")
    end)
    
    if success then
        for _, file in ipairs(files) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                if name then
                    local data = Macro.loadFromFile(name)
                    if data then
                        Macro.library[name] = data
                    end
                end
            end
        end
    end
    
    Util.debugPrint("Loaded", #Macro.library, "macros")
end

function Macro.delete(name)
    local filePath = Util.getMacroFilename(name)
    if filePath and isfile(filePath) then
        delfile(filePath)
    end
    Macro.library[name] = nil
end

-- ============================================================
-- IMPORT/EXPORT
-- ============================================================
function Macro.importFromJSON(jsonContent, macroName)
    local success, data = pcall(function()
        return Services.HttpService:JSONDecode(jsonContent)
    end)
    
    if not success then
        Util.notify("Import Error", "Invalid JSON format")
        return false
    end
    
    local importedActions
    
    if type(data) == "table" then
        if data.actions and type(data.actions) == "table" then
            importedActions = data.actions
        elseif data[1] and data[1].Type then
            importedActions = data
        else
            Util.notify("Import Error", "Only new macro format with 'Type' field is supported")
            return false
        end
    else
        Util.notify("Import Error", "Invalid macro data structure")
        return false
    end
    
    if #importedActions == 0 then
        Util.notify("Import Error", "Macro contains no actions")
        return false
    end
    
    -- Validate Type field
    for i, action in ipairs(importedActions) do
        if not action.Type then
            Util.notify("Import Error", string.format("Action %d missing 'Type' field", i))
            return false
        end
    end
    
    Macro.library[macroName] = importedActions
    Macro.saveToFile(macroName)
    
    Util.notify("Import Success", string.format("Imported '%s' with %d actions", macroName, #importedActions))
    return true
end

function Macro.importFromTXT(txtContent, macroName)
    local lines = {}
    for line in txtContent:gmatch("[^\r\n]+") do
        table.insert(lines, line:match("^%s*(.-)%s*$"))
    end
    
    local actions = {}
    
    for i, line in ipairs(lines) do
        if line and line ~= "" and not line:match("^#") then
            local parts = {}
            for part in line:gmatch("[^,]+") do
                table.insert(parts, part:match("^%s*(.-)%s*$"))
            end
            
            if #parts >= 1 then
                local actionType = parts[1]
                
                if actionType == "spawn_unit" and #parts >= 10 then
                    local action = {
                        Type = "spawn_unit",
                        Unit = parts[2],
                        Time = parts[3],
                        Pos = string.format("%.17f, %.17f, %.17f", 
                            tonumber(parts[4]) or 0, tonumber(parts[5]) or 0, tonumber(parts[6]) or 0),
                        Dir = string.format("%.17f, %.17f, %.17f", 
                            tonumber(parts[7]) or 0, tonumber(parts[8]) or 0, tonumber(parts[9]) or 0),
                        Rot = tonumber(parts[10]) or 0
                    }
                    table.insert(actions, action)
                elseif actionType == "upgrade_unit_ingame" and #parts >= 3 then
                    table.insert(actions, {
                        Type = "upgrade_unit_ingame",
                        Unit = parts[2],
                        Time = parts[3]
                    })
                elseif actionType == "sell_unit_ingame" and #parts >= 3 then
                    table.insert(actions, {
                        Type = "sell_unit_ingame",
                        Unit = parts[2],
                        Time = parts[3]
                    })
                elseif actionType == "vote_wave_skip" and #parts >= 2 then
                    table.insert(actions, {
                        Type = "vote_wave_skip",
                        Time = parts[2]
                    })
                elseif actionType == "use_active_attack" and #parts >= 3 then
                    table.insert(actions, {
                        Type = "use_active_attack",
                        Unit = parts[2],
                        Time = parts[3]
                    })
                end
            end
        end
    end
    
    if #actions == 0 then
        Util.notify("Import Error", "No valid actions found in TXT file")
        return false
    end
    
    Macro.library[macroName] = actions
    Macro.saveToFile(macroName)
    
    Util.notify("TXT Import Success", string.format("Imported '%s' with %d actions", macroName, #actions))
    return true
end

function Macro.importFromURL(url, macroName)
    local requestFunc = syn and syn.request or 
                    http and http.request or 
                    http_request or 
                    request
    
    if not requestFunc then
        Util.notify("Import Error", "HTTP requests not supported by your executor")
        return false
    end
    
    local success, response = pcall(function()
        return requestFunc({
            Url = url,
            Method = "GET"
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        local isJSON = false
        pcall(function()
            Services.HttpService:JSONDecode(response.Body)
            isJSON = true
        end)
        
        if isJSON then
            return Macro.importFromJSON(response.Body, macroName)
        else
            return Macro.importFromTXT(response.Body, macroName)
        end
    else
        Util.notify("Import Error", "Failed to download from URL")
        return false
    end
end

function Macro.exportToClipboard(macroName)
    if not Macro.library[macroName] or #Macro.library[macroName] == 0 then
        Util.notify("Export Error", "No macro data to export")
        return false
    end
    
    local jsonData = Services.HttpService:JSONEncode(Macro.library[macroName])
    
    if setclipboard then
        setclipboard(jsonData)
        Util.notify("Export Success", "Macro JSON copied to clipboard")
    else
        Util.notify("Export Info", "Clipboard not supported. JSON printed to console.")
        print("=== MACRO EXPORT ===")
        print(jsonData)
        print("=== END EXPORT ===")
    end
    
    return true
end

function Macro.exportToWebhook(macroName, webhookUrl)
    if not Macro.library[macroName] or #Macro.library[macroName] == 0 then
        Util.notify("Export Error", "No macro data to export")
        return false
    end
    
    if not webhookUrl or webhookUrl == "" then
        Util.notify("Export Error", "No webhook URL provided")
        return false
    end
    
    local requestFunc = syn and syn.request or 
                    http and http.request or 
                    http_request or 
                    request
    
    if not requestFunc then
        Util.notify("Export Error", "HTTP requests not supported by your executor")
        return false
    end
    
    local jsonData = Services.HttpService:JSONEncode(Macro.library[macroName])
    
    -- Calculate stats
    local stats = {
        placements = 0,
        upgrades = 0,
        sells = 0,
        abilities = 0,
        waveSkips = 0,
        duration = 0
    }
    
    for _, action in ipairs(Macro.library[macroName]) do
        if action.Type == "spawn_unit" then
            stats.placements = stats.placements + 1
        elseif action.Type == "upgrade_unit_ingame" then
            stats.upgrades = stats.upgrades + 1
        elseif action.Type == "sell_unit_ingame" then
            stats.sells = stats.sells + 1
        elseif action.Type == "use_active_attack" then
            stats.abilities = stats.abilities + 1
        elseif action.Type == "vote_wave_skip" then
            stats.waveSkips = stats.waveSkips + 1
        end
        
        local actionTime = tonumber(action.Time) or 0
        if actionTime > stats.duration then
            stats.duration = actionTime
        end
    end
    
    local embed = {
        title = "📋 Macro Export: " .. macroName,
        description = string.format("**Total Actions:** %d\n**Duration:** %.1f seconds", 
            #Macro.library[macroName], stats.duration),
        color = 3447003, -- Blue color
        fields = {
            {
                name = "📊 Action Breakdown",
                value = string.format(
                    "```\nPlacements:  %d\nUpgrades:    %d\nSells:       %d\nAbilities:   %d\nWave Skips:  %d\n```",
                    stats.placements, stats.upgrades, stats.sells, stats.abilities, stats.waveSkips
                ),
                inline = false
            },
            {
                name = "📦 Macro Data",
                value = "See attachment below",
                inline = false
            }
        },
        footer = {
            text = "LixHub Macro System • " .. os.date("%Y-%m-%d %H:%M:%S")
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    -- Send webhook with file attachment
    local success, response = pcall(function()
        return requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = Services.HttpService:JSONEncode({
                embeds = {embed},
                content = string.format("```json\n%s\n```", jsonData:sub(1, 1900))
            })
        })
    end)
    
    if success and response and response.StatusCode == 204 then
        Util.notify("Export Success", "Macro exported to webhook!")
        return true
    else
        Util.notify("Export Error", "Failed to send to webhook")
        if response then
            Util.debugPrint("Webhook error:", response.StatusCode, response.Body)
        end
        return false
    end
end

-- ============================================================
-- PLAYBACK FUNCTIONS
-- ============================================================
function Macro.waitForSufficientMoney(action, actionIndex, totalActions)
    Util.debugPrint("=== WAIT FOR MONEY START ===")
    Util.debugPrint("Action type:", action.Type)
    Util.debugPrint("Action unit:", action.Unit)
    
    local requiredCost = 0
    local displayName, instanceNumber = Util.parseUnitString(action.Unit)
    local unitid = displayName and Util.getUnitIdFromDisplayName(displayName)
    
    Util.debugPrint("Display name:", displayName)
    Util.debugPrint("Instance number:", instanceNumber)
    Util.debugPrint("Unit ID:", unitid)
    
    if action.Type == "spawn_unit" and unitid then
        requiredCost = Util.getPlacementCost(unitid)
        Util.debugPrint("SPAWN_UNIT: Required cost:", requiredCost)
    elseif action.Type == "upgrade_unit_ingame" and displayName and instanceNumber then
        local currentUUID = Macro.playbackPlacementToSpawnId[action.Unit]
        Util.debugPrint("UPGRADE: Current UUID mapping:", currentUUID)
        
        if currentUUID then
            local unit = Macro.findUnitBySpawnUUID(currentUUID)
            Util.debugPrint("UPGRADE: Found unit:", unit ~= nil)
            
            if unit then
                local currentLevel = Util.getUnitUpgradeLevel(unit)
                local upgradeAmount = action.Amount or 1
                
                Util.debugPrint("UPGRADE: Current level:", currentLevel)
                Util.debugPrint("UPGRADE: Upgrade amount:", upgradeAmount)
                
                if upgradeAmount > 1 then
                    requiredCost = Util.getMultiUpgradeCost(unitid, currentLevel, upgradeAmount)
                else
                    requiredCost = Util.getUpgradeCost(unitid, currentLevel)
                end
                
                Util.debugPrint("UPGRADE: Required cost:", requiredCost)
            end
        end
    end
    
    local currentMoney = Util.getPlayerMoney()
    Util.debugPrint("Current money:", currentMoney)
    Util.debugPrint("Required cost:", requiredCost)
    Util.debugPrint("Need to wait:", currentMoney < requiredCost)
    
    if requiredCost > 0 then
        local waitCount = 0
        while Util.getPlayerMoney() < requiredCost do
            if not Macro.isPlaying or GameTracking.gameHasEnded then
                Util.debugPrint("MONEY WAIT INTERRUPTED - isPlaying:", Macro.isPlaying, "gameHasEnded:", GameTracking.gameHasEnded)
                return false
            end
            
            waitCount = waitCount + 1
            local missingMoney = requiredCost - Util.getPlayerMoney()
            local upgradeText = action.Amount and action.Amount > 1 and 
                string.format(" (x%d upgrade)", action.Amount) or ""
            
            Util.debugPrint(string.format("WAITING FOR MONEY - Loop #%d, Missing: %d", waitCount, missingMoney))
            
            Macro.updateStatus(string.format("(%d/%d) Waiting for %d more yen%s (need %d, have %d)", 
                actionIndex, totalActions, missingMoney, upgradeText, requiredCost, Util.getPlayerMoney()))
            task.wait(1)
        end
        
        Util.debugPrint("MONEY WAIT COMPLETE - Waited", waitCount, "seconds")
    else
        Util.debugPrint("NO MONEY WAIT NEEDED - Required cost is 0 or negative")
    end
    
    Util.debugPrint("=== WAIT FOR MONEY END - RETURNING TRUE ===")
    return true
end

function Macro.validatePlacement(action, actionIndex, totalActions)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints")
        :WaitForChild("client_to_server")
    
    local placementId = action.Unit
    local displayName, placementNumber = Util.parseUnitString(placementId)
    
    if not displayName or not placementNumber then
        Macro.updateStatus(string.format("(%d/%d) FAILED: Invalid unit format: %s", 
            actionIndex, totalActions, placementId))
        return false
    end
    
    -- Money wait is now handled in main play() loop before this function is called
    
    for attempt = 1, Macro.PLACEMENT_MAX_RETRIES do
        if not Macro.isPlaying then return false end
        
        local unitId = Util.getUnitIdFromDisplayName(displayName)
        if not unitId then
            Macro.updateStatus(string.format("(%d/%d) FAILED: Could not resolve unit ID", 
                actionIndex, totalActions))
            return false
        end
        
        -- CRITICAL FIX: Resolve UUID from inventory
        local unitUUID = Util.resolveUUIDFromInternalName(unitId)
        if not unitUUID then
            Macro.updateStatus(string.format("(%d/%d) FAILED: Unit not equipped - %s", 
                actionIndex, totalActions, displayName))
            return false
        end
        
        Macro.updateStatus(string.format("(%d/%d) Attempt %d/%d: Placing %s", 
            actionIndex, totalActions, attempt, Macro.PLACEMENT_MAX_RETRIES, placementId))
        
        local beforeSnapshot = Macro.takeUnitsSnapshot()
        
        -- Parse position
        local px, py, pz = action.Pos:match("([%-%d%.e%-]+), ([%-%d%.e%-]+), ([%-%d%.e%-]+)")
        local dx, dy, dz = action.Dir:match("([%-%d%.e%-]+), ([%-%d%.e%-]+), ([%-%d%.e%-]+)")
        
        if not (px and py and pz and dx and dy and dz) then
            Macro.updateStatus(string.format("(%d/%d) FAILED: Invalid position format", 
                actionIndex, totalActions))
            return false
        end
        
        local originPos = Vector3.new(tonumber(px), tonumber(py), tonumber(pz))
        
        -- Apply random offset
        if Macro.randomOffsetEnabled then
            originPos = Vector3.new(
                originPos.X + (math.random() - 0.5) * 2 * Macro.randomOffsetAmount,
                originPos.Y,
                originPos.Z + (math.random() - 0.5) * 2 * Macro.randomOffsetAmount
            )
        end
        
        -- Try placement with UUID
        local success = pcall(function()
            endpoints:WaitForChild(Macro.SPAWN_REMOTE):InvokeServer(
                unitUUID,
                {
                    Origin = originPos,
                    Direction = Vector3.new(tonumber(dx), tonumber(dy), tonumber(dz))
                },
                action.Rot or 0
            )
        end)
        
        if not success then
            Util.debugPrint("Placement remote call failed on attempt", attempt)
            if attempt < Macro.PLACEMENT_MAX_RETRIES then
                task.wait(Macro.RETRY_DELAY)
                continue
            else
                return false
            end
        end
        
        task.wait((attempt == 1) and Macro.NORMAL_VALIDATION or Macro.EXTENDED_VALIDATION)
        
        local newUnit = Macro.findNewlyPlacedUnit(beforeSnapshot, Macro.takeUnitsSnapshot())
        
        if newUnit and Util.isOwnedByLocalPlayer(newUnit) then
            -- Get the SPAWN UUID from the attribute, not the unit type UUID from _stats
            local spawnUUID = newUnit:GetAttribute("_SPAWN_UNIT_UUID")
            
            if spawnUUID then
                Util.debugPrint(string.format("STORING MAPPING: '%s' -> SPAWN_UUID '%s'", placementId, tostring(spawnUUID)))
                
                -- Check if this spawn UUID is already mapped to something else
                for existingPlacement, existingUUID in pairs(Macro.playbackPlacementToSpawnId) do
                    if tostring(existingUUID) == tostring(spawnUUID) and existingPlacement ~= placementId then
                        Util.debugPrint(string.format("⚠️ WARNING: SPAWN_UUID '%s' already mapped to '%s'!", tostring(spawnUUID), existingPlacement))
                    end
                end
                
                Macro.playbackPlacementToSpawnId[placementId] = spawnUUID
                
                Util.debugPrint("Current mappings:")
                for k, v in pairs(Macro.playbackPlacementToSpawnId) do
                    Util.debugPrint(string.format("  %s -> %s", k, tostring(v)))
                end
                
                Macro.updateStatus(string.format("(%d/%d) SUCCESS: Placed %s", 
                    actionIndex, totalActions, placementId))
                return true
            else
                Util.debugPrint("Could not get _SPAWN_UNIT_UUID attribute from placed unit")
            end
        end
        
        Util.debugPrint("Unit not detected after placement on attempt", attempt)
        if attempt < Macro.PLACEMENT_MAX_RETRIES then
            task.wait(Macro.RETRY_DELAY)
        end
    end
    
    Macro.updateStatus(string.format("(%d/%d) FAILED: Could not place %s - continuing", 
        actionIndex, totalActions, placementId))
    return true
end

function Macro.validateUpgrade(action, actionIndex, totalActions)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints")
        :WaitForChild("client_to_server")
    
    local placementId = action.Unit
    local upgradeAmount = action.Amount or 1
    
    -- Money wait is now handled in main play() loop before this function is called
    
    for attempt = 1, Macro.UPGRADE_MAX_RETRIES do
        if not Macro.isPlaying then return false end
        
        -- Find unit using the stored UUID
        local targetUnit = nil
        local currentUUID = Macro.playbackPlacementToSpawnId[placementId]
        
        Util.debugPrint(string.format("Looking for unit with UUID: %s", tostring(currentUUID)))
        
        if currentUUID then
            targetUnit = Macro.findUnitBySpawnUUID(currentUUID)
            Util.debugPrint(string.format("Found target unit: %s", tostring(targetUnit ~= nil)))
        else
            Util.debugPrint("No UUID mapping found for:", placementId)
        end
        
        if not targetUnit then
            if attempt < Macro.UPGRADE_MAX_RETRIES then
                Util.debugPrint("Unit not found, retrying...")
                task.wait(Macro.RETRY_DELAY)
                continue
            else
                Util.debugPrint("Unit not found after all retries")
                return false
            end
        end
        
        local originalLevel = Util.getUnitUpgradeLevel(targetUnit)
        
        Macro.updateStatus(string.format("(%d/%d) Attempt %d/%d: Upgrading %s (Level %d)", 
            actionIndex, totalActions, attempt, Macro.UPGRADE_MAX_RETRIES, placementId, originalLevel))
        
        -- Perform upgrades
        local successfulUpgrades = 0
        
        for i = 1, upgradeAmount do
            local success = pcall(function()
                endpoints:WaitForChild(Macro.UPGRADE_REMOTE):InvokeServer(targetUnit.Name)
            end)
            
            if success then
                task.wait(0.2)
                
                -- Validate
                local newLevel = Util.getUnitUpgradeLevel(targetUnit)
                if newLevel > originalLevel then
                    successfulUpgrades = successfulUpgrades + 1
                    originalLevel = newLevel
                end
            end
        end
        
        if successfulUpgrades >= upgradeAmount then
            Macro.updateStatus(string.format("(%d/%d) SUCCESS: Upgraded %s", 
                actionIndex, totalActions, placementId))
            return true
        end
        
        if attempt < Macro.UPGRADE_MAX_RETRIES then
            task.wait(Macro.RETRY_DELAY)
        end
    end
    
    Macro.updateStatus(string.format("(%d/%d) Partial upgrade - continuing", actionIndex, totalActions))
    return true
end

function Macro.validateSell(action, actionIndex, totalActions)
    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints")
        :WaitForChild("client_to_server")
    
    local placementId = action.Unit
    local currentUUID = Macro.playbackPlacementToSpawnId[placementId]
    
    if not currentUUID then
        Macro.updateStatus(string.format("(%d/%d) FAILED: No UUID mapping for %s", 
            actionIndex, totalActions, placementId))
        return false
    end
    
    local targetUnit = Macro.findUnitBySpawnUUID(currentUUID)
    
    if not targetUnit then
        Macro.updateStatus(string.format("(%d/%d) FAILED: Unit not found", actionIndex, totalActions))
        return false
    end
    
    Macro.updateStatus(string.format("(%d/%d) Selling %s", actionIndex, totalActions, placementId))
    
    local success = pcall(function()
        endpoints:WaitForChild(Macro.SELL_REMOTE):InvokeServer(targetUnit.Name)
    end)
    
    if success then
        task.wait(0.5)
        Macro.playbackPlacementToSpawnId[placementId] = nil
        Macro.updateStatus(string.format("(%d/%d) Successfully sold %s", 
            actionIndex, totalActions, placementId))
        return true
    end
    
    Macro.updateStatus(string.format("(%d/%d) Failed to sell - continuing", actionIndex, totalActions))
    return true
end

function Macro.executeAction(action, actionIndex, totalActions)
    if action.Type == "spawn_unit" then
        return Macro.validatePlacement(action, actionIndex, totalActions)
    elseif action.Type == "upgrade_unit_ingame" then
        return Macro.validateUpgrade(action, actionIndex, totalActions)
    elseif action.Type == "sell_unit_ingame" then
        return Macro.validateSell(action, actionIndex, totalActions)
    elseif action.Type == "vote_wave_skip" then
        -- Schedule wave skip in background (even with ignore timing)
        task.spawn(function()
            local targetTime = tonumber(action.Time) or 0
            local waitTime = targetTime - (tick() - GameTracking.gameStartTime)
            
            if waitTime > 0 and not Macro.ignoreTiming then
                Util.debugPrint(string.format("Wave skip scheduled for %.1fs from now", waitTime))
                task.wait(waitTime)
            end
            
            if Macro.isPlaying and not GameTracking.gameHasEnded then
                Util.debugPrint(string.format("Executing scheduled wave skip at game time %.2f", tick() - GameTracking.gameStartTime))
                
                local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints")
                    :WaitForChild("client_to_server")
                
                pcall(function()
                    endpoints:WaitForChild(Macro.WAVE_SKIP_REMOTE):InvokeServer()
                end)
            end
        end)
        
        Macro.updateStatus(string.format("(%d/%d) Scheduled wave skip", actionIndex, totalActions))
        return true
    else
        -- Handle any ability remote (including special abilities)
        local isAbilityRemote = false
        for _, abilityRemote in ipairs(Macro.SPECIAL_ABILITY_REMOTES) do
            if action.Type == abilityRemote then
                isAbilityRemote = true
                break
            end
        end
        
        if isAbilityRemote then
            -- Schedule ability in background (even with ignore timing)
            task.spawn(function()
                local targetTime = tonumber(action.Time) or 0
                local waitTime = targetTime - (tick() - GameTracking.gameStartTime)
                
                if waitTime > 0 and not Macro.ignoreTiming then
                    Util.debugPrint(string.format("Ability (%s) scheduled for %.1fs from now", action.Type, waitTime))
                    task.wait(waitTime)
                end
                
                if Macro.isPlaying and not GameTracking.gameHasEnded then
                    local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints")
                        :WaitForChild("client_to_server")
                    
                    -- Handle different special ability types
                    if action.Type == "HestiaAssignBlade" then
                        -- Hestia: Find target unit and get its current spawn_id
                        local targetPlacementId = action.Target
                        local targetUUID = Macro.playbackPlacementToSpawnId[targetPlacementId]
                        
                        if targetUUID then
                            local targetUnit = Macro.findUnitBySpawnUUID(targetUUID)
                            if targetUnit then
                                local stats = targetUnit:FindFirstChild("_stats")
                                if stats then
                                    local spawnIdValue = stats:FindFirstChild("spawn_id")
                                    if spawnIdValue then
                                        Util.debugPrint(string.format("Executing Hestia ability on %s (spawn_id: %s)", 
                                            targetPlacementId, tostring(spawnIdValue.Value)))
                                        
                                        pcall(function()
                                            endpoints:WaitForChild("HestiaAssignBlade"):InvokeServer(spawnIdValue.Value)
                                        end)
                                    end
                                end
                            end
                        end
                        
                    elseif action.Type == "LelouchChoosePiece" then
                        -- Lelouch: Find both Lelouch and target units
                        local lelouchUUID = Macro.playbackPlacementToSpawnId[action.Lelouch]
                        local targetUUID = Macro.playbackPlacementToSpawnId[action.Target]
                        
                        if lelouchUUID and targetUUID then
                            local lelouchUnit = Macro.findUnitBySpawnUUID(lelouchUUID)
                            local targetUnit = Macro.findUnitBySpawnUUID(targetUUID)
                            
                            if lelouchUnit and targetUnit then
                                local lelouchStats = lelouchUnit:FindFirstChild("_stats")
                                local targetStats = targetUnit:FindFirstChild("_stats")
                                
                                if lelouchStats and targetStats then
                                    local lelouchSpawnId = lelouchStats:FindFirstChild("spawn_id")
                                    local targetSpawnId = targetStats:FindFirstChild("spawn_id")
                                    
                                    if lelouchSpawnId and targetSpawnId then
                                        Util.debugPrint(string.format("Executing Lelouch ability: %s -> %s (piece: %s)", 
                                            action.Lelouch, action.Target, action.Piece))
                                        
                                        pcall(function()
                                            endpoints:WaitForChild("LelouchChoosePiece"):InvokeServer(
                                                lelouchSpawnId.Value, 
                                                targetSpawnId.Value, 
                                                action.Piece
                                            )
                                        end)
                                    end
                                end
                            end
                        end
                        
                    elseif action.Type == "DioWrites" then
                        -- Dio: Find Dio unit
                        local dioUUID = Macro.playbackPlacementToSpawnId[action.Dio]
                        
                        if dioUUID then
                            local dioUnit = Macro.findUnitBySpawnUUID(dioUUID)
                            if dioUnit then
                                local stats = dioUnit:FindFirstChild("_stats")
                                if stats then
                                    local spawnIdValue = stats:FindFirstChild("spawn_id")
                                    if spawnIdValue then
                                        Util.debugPrint(string.format("Executing Dio ability: %s (type: %s)", 
                                            action.Dio, action.Ability))
                                        
                                        pcall(function()
                                            endpoints:WaitForChild("DioWrites"):InvokeServer(
                                                spawnIdValue.Value, 
                                                action.Ability
                                            )
                                        end)
                                    end
                                end
                            end
                        end
                        
                    elseif action.Type == "use_active_attack" then
                        -- Normal ability: Use unit name directly
                        local placementId = action.Unit
                        local currentUUID = Macro.playbackPlacementToSpawnId[placementId]
                        
                        if currentUUID then
                            local targetUnit = Macro.findUnitBySpawnUUID(currentUUID)
                            
                            if targetUnit then
                                Util.debugPrint(string.format("Executing normal ability for %s", placementId))
                                
                                pcall(function()
                                    endpoints:WaitForChild("use_active_attack"):InvokeServer(targetUnit.Name)
                                end)
                            end
                        end
                        
                    else
                        -- Unknown ability type - try generic execution
                        Util.debugPrint(string.format("Executing unknown ability type: %s", action.Type))
                        
                        if action.Args then
                            pcall(function()
                                endpoints:WaitForChild(action.Type):InvokeServer(unpack(action.Args))
                            end)
                        end
                    end
                end
            end)
            
            local abilityDesc = action.Unit and string.format("%s (%s)", action.Unit, action.Type) 
                or action.Target and string.format("%s (%s)", action.Target, action.Type)
                or action.Type
            Macro.updateStatus(string.format("(%d/%d) Scheduled ability: %s", actionIndex, totalActions, abilityDesc))
            return true
        end
    end
    
    return false
end

function Macro.play()
    if not Macro.actions or #Macro.actions == 0 then
        Macro.updateStatus("No macro data to play back")
        return false
    end
    
    if Macro.hasPlayedThisGame then
        Macro.updateStatus("Macro already played this game")
        return false
    end
    
    Macro.hasPlayedThisGame = true
    local totalActions = #Macro.actions
    
    local timingMode = Macro.ignoreTiming and " - Immediate Mode" or " - Game Time Sync"
    Macro.updateStatus(string.format("Starting playback with %d actions%s", totalActions, timingMode))
    
    -- DEBUG: Print all actions
    Util.debugPrint("=== MACRO ACTIONS SUMMARY ===")
    for i, action in ipairs(Macro.actions) do
        Util.debugPrint(string.format("Action %d: Type=%s, Unit=%s, Time=%s", 
            i, action.Type, action.Unit or "N/A", action.Time or "N/A"))
    end
    Util.debugPrint("=== END SUMMARY ===")
    
    GameTracking.gameHasEnded = false
    Macro.clearSpawnIdMappings()
    
    if GameTracking.gameStartTime == 0 then
        GameTracking.gameStartTime = tick()
    end
    
    for i, action in ipairs(Macro.actions) do
        if not Macro.isPlaying or GameTracking.gameHasEnded then
            Macro.updateStatus("Macro interrupted")
            return false
        end
        
        -- MONEY WAITING HAPPENS FIRST - BEFORE TIMING LOGIC
        -- This ensures we always wait for money regardless of timing mode
        if action.Type == "spawn_unit" or action.Type == "upgrade_unit_ingame" then
            if not Macro.waitForSufficientMoney(action, i, totalActions) then
                Macro.updateStatus("Money wait cancelled")
                return false
            end
        end
        
        -- Timing logic (AFTER money wait)
        if not Macro.ignoreTiming then
            local targetGameTime = tonumber(action.Time) or 0
            local currentGameTime = tick() - GameTracking.gameStartTime
            local waitTime = targetGameTime - currentGameTime
            
            if waitTime > 0 then
                Macro.updateStatus(string.format("(%d/%d) Waiting %.1fs for timing", 
                    i, totalActions, waitTime))
                
                local waitStart = tick()
                while tick() - waitStart < waitTime and Macro.isPlaying and not GameTracking.gameHasEnded do
                    task.wait(0.1)
                end
            end
        else
            if i > 1 then
                task.wait(0.3)
            end
        end
        
        if not Macro.isPlaying or GameTracking.gameHasEnded then
            Macro.updateStatus("Macro stopped during timing wait")
            return false
        end
        
        Macro.executeAction(action, i, totalActions)
    end
    
    Macro.updateStatus("Macro playback completed")
    return true
end

-- ============================================================
-- MAIN INITIALIZATION
-- ============================================================
local function initialize()
    -- Load UI library
    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()
    end)
    
    if not success then
        warn("Failed to load Rayfield UI library:", Rayfield)
        return
    end
    
    if not Rayfield then
        warn("Rayfield library returned nil")
        return
    end
    
    -- Make Rayfield global
    _G.Rayfield = Rayfield
    
    -- Create window
    local Window = Rayfield:CreateWindow({
        Name = "LixHub - Macro System",
        Icon = 0,
        LoadingTitle = "Loading Macro System",
        LoadingSubtitle = "V0.17",
        Theme = {
            TextColor = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(25, 25, 25),
            Topbar = Color3.fromRGB(34, 34, 34),
            Shadow = Color3.fromRGB(20, 20, 20),
        },
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "LixHub",
            FileName = "Lixhub_AC_Macro"
        },
    })
    
    -- Create tab
    local MacroTab = Window:CreateTab("Macro", "joystick")
    
    -- ============================================================
    -- UI ELEMENTS
    -- ============================================================
    
    MacroTab:CreateSection("Macro Management")
    
    local MacroStatusLabel = MacroTab:CreateLabel("Status: Ready")
    Macro.detailedStatusLabel = MacroTab:CreateLabel("Details: Ready")
    
    MacroTab:CreateDivider()
    
    -- Notification toggle
    MacroTab:CreateToggle({
        Name = "Enable Notifications",
        CurrentValue = true,
        Flag = "EnableNotifications",
        Callback = function(Value)
            NOTIFICATION_ENABLED = Value
        end,
    })
    
    MacroTab:CreateDivider()
    
    local MacroDropdown = MacroTab:CreateDropdown({
        Name = "Select Macro",
        Options = {},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "MacroDropdown",
        Callback = function(selected)
            local selectedName = type(selected) == "table" and selected[1] or selected
            Macro.currentName = selectedName
            
            if selectedName and Macro.library[selectedName] then
                Macro.actions = Macro.library[selectedName]
                Util.debugPrint("Selected macro:", selectedName, "with", #Macro.actions, "actions")
            end
        end,
    })
    
    local function refreshMacroDropdown()
        local options = {}
        for name in pairs(Macro.library) do
            table.insert(options, name)
        end
        table.sort(options)
        
        MacroDropdown:Refresh(options, Macro.currentName)
        Util.debugPrint("Refreshed dropdown with", #options, "macros")
    end
    
    MacroTab:CreateInput({
        Name = "Create Macro",
        CurrentValue = "",
        PlaceholderText = "Enter macro name...",
        RemoveTextAfterFocusLost = true,
        Callback = function(text)
            local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            
            if cleanedName ~= "" then
                if Macro.library[cleanedName] then
                    Util.notify("Error", "Macro '" .. cleanedName .. "' already exists.")
                    return
                end

                Macro.library[cleanedName] = {}
                Macro.saveToFile(cleanedName)
                refreshMacroDropdown()
                
                Util.notify("Success", "Created macro '" .. cleanedName .. "'.")
            end
        end,
    })
    
    MacroTab:CreateButton({
        Name = "Refresh Macro List",
        Callback = function()
            Macro.loadAll()
            refreshMacroDropdown()
            Util.notify("Success", "Macro list refreshed.")
        end,
    })
    
    MacroTab:CreateButton({
        Name = "Delete Selected Macro",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then
                Util.notify("Error", "No macro selected.")
                return
            end

            Macro.delete(Macro.currentName)
            Util.notify("Deleted", "Deleted macro '" .. Macro.currentName .. "'.")
            
            Macro.currentName = ""
            Macro.actions = {}
            refreshMacroDropdown()
        end,
    })
    
    MacroTab:CreateSection("Recording")
    
    local RecordToggle = MacroTab:CreateToggle({
        Name = "Record Macro",
        CurrentValue = false,
        Flag = "RecordMacro",
        Callback = function(Value)
            Macro.isRecording = Value

            if Value then
                if not Util.isInLobby() and GameTracking.gameInProgress then
                    Macro.startRecording()
                    MacroStatusLabel:Set("Status: Recording active!")
                else
                    MacroStatusLabel:Set("Status: Recording enabled - will start when game begins")
                    Util.notify("Recording Ready", "Recording will start when you enter a game.")
                end
            else
                Macro.stopRecording()
                MacroStatusLabel:Set("Status: Recording stopped")
                Util.notify("Recording Stopped", "Recording manually stopped.")
            end
        end
    })
    
    MacroTab:CreateSection("Playback")
    
    local PlayToggle = MacroTab:CreateToggle({
        Name = "Playback Macro",
        CurrentValue = false,
        Flag = "PlaybackMacro",
        Callback = function(Value)
            Macro.isPlaying = Value
            
            if Value then
                MacroStatusLabel:Set("Status: Playback enabled")
                Util.notify("Playback Enabled", "Macro will play when conditions are met.")
                
                task.spawn(function()
                    while Macro.isPlaying do
                        task.wait(1)
                        
                        if not Util.isInLobby() and GameTracking.gameInProgress and not Macro.hasPlayedThisGame then
                            if not Macro.currentName or Macro.currentName == "" then
                                MacroStatusLabel:Set("Status: Error - No macro selected!")
                                Macro.updateStatus("Error - No macro selected!")
                                break
                            end
                            
                            local loadedMacro = Macro.loadFromFile(Macro.currentName)
                            if not loadedMacro or #loadedMacro == 0 then
                                MacroStatusLabel:Set("Status: Error - Failed to load macro!")
                                Macro.updateStatus("Error - Failed to load macro!")
                                break
                            end
                            
                            Macro.actions = loadedMacro
                            MacroStatusLabel:Set("Status: Playing " .. Macro.currentName .. "...")
                            Macro.play()
                        end
                    end
                end)
            else
                MacroStatusLabel:Set("Status: Playback disabled")
                Util.notify("Playback Disabled", "Macro playback stopped.")
            end
        end,
    })
    
    MacroTab:CreateSection("Settings")
    
    MacroTab:CreateToggle({
        Name = "Random Offset",
        CurrentValue = false,
        Flag = "RandomOffsetEnabled",
        Info = "Slightly randomize placement positions",
        Callback = function(Value)
            Macro.randomOffsetEnabled = Value
        end,
    })
    
    MacroTab:CreateSlider({
        Name = "Offset Amount",
        Range = {0.1, 5.0},
        Increment = 0.1,
        Suffix = " studs",
        CurrentValue = 0.5,
        Flag = "RandomOffsetAmount",
        Info = "Maximum random offset distance (recommended: 0.5)",
        Callback = function(Value)
            Macro.randomOffsetAmount = Value
        end,
    })
    
    MacroTab:CreateToggle({
        Name = "Ignore Timing",
        CurrentValue = false,
        Flag = "IgnoreTiming",
        Info = "Execute actions immediately without waiting for timing",
        Callback = function(Value)
            Macro.ignoreTiming = Value
        end,
    })
    
    MacroTab:CreateSection("Import/Export")
    
    MacroTab:CreateInput({
        Name = "Import Macro",
        CurrentValue = "",
        PlaceholderText = "Paste JSON/TXT/URL here...",
        RemoveTextAfterFocusLost = true,
        Callback = function(text)
            if not text or text:match("^%s*$") then return end
            
            local macroName = "ImportedMacro_" .. os.time()
            
            if text:match("^https?://") then
                -- URL import
                local fileName = text:match("/([^/?]+)%.json") or text:match("/([^/?]+)%.txt") or text:match("/([^/?]+)$")
                if fileName then
                    macroName = fileName:gsub("%.json.*$", ""):gsub("%.txt.*$", "")
                end
                
                Macro.importFromURL(text, macroName)
            else
                -- Detect JSON vs TXT
                local isJSON = false
                pcall(function()
                    Services.HttpService:JSONDecode(text)
                    isJSON = true
                end)
                
                if isJSON then
                    Macro.importFromJSON(text, macroName)
                else
                    Macro.importFromTXT(text, macroName)
                end
            end
            
            refreshMacroDropdown()
        end,
    })
    
    MacroTab:CreateButton({
        Name = "Export Macro To Clipboard",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then
                Util.notify("Export Error", "No macro selected.")
                return
            end
            
            Macro.exportToClipboard(Macro.currentName)
        end,
    })
    
    local webhookUrl = ""
    
    MacroTab:CreateInput({
        Name = "Webhook URL (Optional)",
        CurrentValue = "",
        PlaceholderText = "https://discord.com/api/webhooks/...",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            webhookUrl = text
        end,
    })
    
    MacroTab:CreateButton({
        Name = "Export Macro To Webhook",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then
                Util.notify("Export Error", "No macro selected.")
                return
            end
            
            if not webhookUrl or webhookUrl == "" then
                Util.notify("Export Error", "Please enter a webhook URL first.")
                return
            end
            
            Macro.exportToWebhook(Macro.currentName, webhookUrl)
        end,
    })
    
    MacroTab:CreateButton({
        Name = "Check Macro Units",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then
                Util.notify("Check Error", "No macro selected.")
                return
            end
            
            local macroData = Macro.library[Macro.currentName]
            if not macroData or #macroData == 0 then
                Util.notify("Check Error", "Selected macro is empty.")
                return
            end
            
            local unitsUsed = {}
            for _, action in ipairs(macroData) do
                if action.Type == "spawn_unit" and action.Unit then
                    local baseUnitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                    unitsUsed[baseUnitName] = true
                end
            end
            
            local unitsList = {}
            for unitName in pairs(unitsUsed) do
                table.insert(unitsList, unitName)
            end
            
            if #unitsList > 0 then
                table.sort(unitsList)
                Util.notify(Macro.currentName, table.concat(unitsList, ", "))
            else
                Util.notify(Macro.currentName, "No units found in this macro.")
            end
        end,
    })
    
    -- ============================================================
    -- GAME TRACKING
    -- ============================================================
    
    local function monitorWaves()
        if not Services.Workspace:FindFirstChild("_wave_num") then
            Services.Workspace:WaitForChild("_wave_num")
        end
        
        local waveNum = Services.Workspace._wave_num
        
        waveNum.Changed:Connect(function(newWave)
            if newWave >= 1 and not GameTracking.gameInProgress then
                GameTracking.startGame()
                
                if Macro.isRecording and not Macro.recordingHasStarted then
                    Macro.startRecording()
                    MacroStatusLabel:Set("Status: Recording active!")
                end
            end
        end)
        
        -- Check initial value
        if waveNum.Value >= 1 then
            GameTracking.startGame()
            
            if Macro.isRecording and not Macro.recordingHasStarted then
                Macro.startRecording()
                MacroStatusLabel:Set("Status: Recording active!")
            end
        end
        
        Util.debugPrint("Wave monitoring active")
    end
    
    local function setupRemoteConnections()
        local gameFinishedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints")
            :FindFirstChild("server_to_client")
            :FindFirstChild("game_finished")
        
        if gameFinishedRemote then
            gameFinishedRemote.OnClientEvent:Connect(function(...)
                Util.debugPrint("game_finished RemoteEvent fired")
                
                GameTracking.endGame()
                Macro.hasPlayedThisGame = false
                
                if Macro.isRecording then
                    Macro.stopRecording()
                    Util.notify("Recording Stopped", "Game ended, recording saved.")
                    RecordToggle:Set(false)
                    
                    if Macro.currentName then
                        Macro.library[Macro.currentName] = Macro.actions
                        Macro.saveToFile(Macro.currentName)
                    end
                end
            end)
        end
        
        Util.debugPrint("Remote connections setup")
    end
    
    -- ============================================================
    -- FINALIZE INITIALIZATION
    -- ============================================================
    
    Util.ensureFolders()
    Macro.loadAll()
    refreshMacroDropdown()
    
    Macro.setupHook()
    setupRemoteConnections()
    
    if not Util.isInLobby() then
        monitorWaves()
    end
    
    Rayfield:LoadConfiguration()
    
    Util.notify("Macro System", "Initialized successfully!")
    Util.debugPrint("=== MACRO SYSTEM READY ===")
end

-- Run initialization
initialize()
