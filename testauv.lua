if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 17899227840 and game.PlaceId ~= 133424448378099 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer

-- ============================================
-- RAYFIELD UI SETUP
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Ultra Verse",
   Icon = 0,
   LoadingTitle = "Loading for Anime Ultra Verse",
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
      FileName = "Lixhub_AUV"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "LixHub - Anime Ultra Verse - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})

local MacroTab = Window:CreateTab("Macro", "tv")
local GameTab = Window:CreateTab("Game", "gamepad-2")

local MacroStatusLabel = MacroTab:CreateLabel("Status: Ready")
local detailedStatusLabel = MacroTab:CreateLabel("Details: Ready")

task.wait(0.1)

local function isInLobby()
    local map = Services.Workspace:FindFirstChild("Map")
    if map then
        local lobby = map:FindFirstChild("Lobby")
        return lobby ~= nil
    end
    return false
end

-- ============================================
-- REPLICA & DATA MODULE SETUP
-- ============================================
if not isInLobby then
local MainSharedFolder = Services.ReplicatedStorage:WaitForChild("MainSharedFolder")
local ReplicaModule = require(MainSharedFolder.Modules.ReplicaModule)
local ReplicaStore = ReplicaModule.ReplicaStore
local DataModule = MainSharedFolder.Modules.DataModule
local WaveManager = ReplicaStore.Get("WaveManagerReplica")
end

-- ============================================
-- STATE MANAGEMENT
-- ============================================

local State = {
    IgnoreTiming = false,
    AutoRetry = false,
    AutoNext = false,
    AutoLobby = false,
    AutoGameSpeed = false,
    GameSpeed = 0,
}
local lastWave = 0
local isAutoLoopEnabled =  false
local playbackLoopRunning = false
local trackedUnits = {}
local macro = {}
local macroManager = {}
local currentMacroName = ""
local isRecording = false
local isPlaybacking = false
local recordingHasStarted = false
local gameInProgress = false
local gameStartTime = 0

-- Unit tracking for RECORDING
local unitTrackedLevels = {}
local unitUpgradeListeners = {}
local recordingUnitCounter = {} -- Maps "UnitName" -> count (e.g., "Feral Beast" -> 2 means we've placed 2)
local recordingUnitIDToTag = {} -- Maps unitID -> "UnitName #N" (e.g., 1383 -> "Feral Beast #1")

-- Unit tracking for PLAYBACK
local playbackUnitTagToID = {} -- Maps "UnitName #N" -> current game's unitID (e.g., "Feral Beast #1" -> 2891)
local statusUpdateQueue = {
    macroStatus = nil,
    detailedStatus = nil,
    toggleUpdate = nil
}

-- Upgrade validation
local pendingUpgrades = {}
local UPGRADE_VALIDATION_TIMEOUT = 1.5

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function notify(title, content)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 3
    })
end

local function updateMacroStatus(message)
    --print("Macro Status: " .. tostring(message))
    statusUpdateQueue.macroStatus = message
end

local function updateDetailedStatus(message)
    --print("Macro Details: " .. tostring(message))
    statusUpdateQueue.detailedStatus = message
end

local function ensureMacroFolders()
    if not isfolder("LixHub") then
        makefolder("LixHub")
    end
    if not isfolder("LixHub/Macros") then
        makefolder("LixHub/Macros")
    end
    if not isfolder("LixHub/Macros/AUV") then
        makefolder("LixHub/Macros/AUV")
    end
end

local function getMacroFilename(name)
    return "LixHub/Macros/AUV/" .. name .. ".json"
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not isfile(filePath) then return nil end
    
    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)
    macroManager[name] = data
    return data
end

local function loadAllMacros()
    ensureMacroFolders()
    macroManager = {}
    for _, file in ipairs(listfiles("LixHub/Macros/AUV/")) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            loadMacroFromFile(name)
        end
    end
end

local function deleteMacroFile(name)
    if isfile(getMacroFilename(name)) then
        delfile(getMacroFilename(name))
    end
    macroManager[name] = nil
end

local function getMacroList()
    local list = {}
    for name in pairs(macroManager) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

local function saveMacroToFile(name)
    ensureMacroFolders()
    local data = macroManager[name]
    if not data then return end
    
    local json = Services.HttpService:JSONEncode(data)
    writefile(getMacroFilename(name), json)
end

local function stopRecording()
    if not isRecording then return end
    
    recordingHasStarted = false
    isRecording = false
    
    -- Capture the data we need BEFORE any operations
    local macroToSave = {}
    for i, v in ipairs(macro) do
        macroToSave[i] = v
    end
    local macroNameToSave = currentMacroName
    
    --print(string.format("Stopped recording. Recorded %d actions", #macroToSave))
    
    -- Schedule the file save operation to happen on main thread
    if macroNameToSave and macroNameToSave ~= "" then
        task.spawn(function()
            Services.RunService.Heartbeat:Wait()
            
            pcall(function()
                macroManager[macroNameToSave] = macroToSave
                saveMacroToFile(macroNameToSave)
                --print(string.format("✓ Saved macro file: %s (%d actions)", macroNameToSave, #macroToSave))
            end)
        end)
    end
    
    statusUpdateQueue.macroStatus = "Recording stopped"
    statusUpdateQueue.detailedStatus = "Recording stopped"
    return macro
end

local RecordToggle = MacroTab:CreateToggle({
    Name = "Record Macro",
    CurrentValue = false,
    Flag = "RecordMacro",
    Callback = function(Value)
        -- Don't set isRecording yet - validate first
        if Value then
            -- Check if macro is selected
            if not currentMacroName or currentMacroName == "" then
                -- Schedule notification
                task.defer(function()
                    Rayfield:Notify({
                        Title = "Recording Error",
                        Content = "Please select a macro first!",
                        Duration = 3
                    })
                end)
                
                -- The toggle will reset itself since we're returning without setting isRecording
                return
            end

            -- NOW it's safe to enable recording
            isRecording = true

            local currentWave = WaveManager and WaveManager.Data.Wave or 0
            local inLobby = isInLobby()
            
            --print(string.format("🔍 Recording enabled - Current wave: %d, In lobby: %s", currentWave, tostring(inLobby)))
            
            if currentWave >= 1 and not inLobby then
                -- We're mid-game! Start recording immediately
                --print(string.format("🎮 Mid-game detected (Wave %d) - Starting recording NOW", currentWave))
                
                gameInProgress = true
                gameStartTime = tick()
                recordingHasStarted = true
                
                -- Clean up tracking tables
                recordingUnitCounter = {}
                recordingUnitIDToTag = {}
                pendingUpgrades = {}
                unitTrackedLevels = {}
                macro = {}
                
                --print("✅ Recording started mid-game - " .. currentMacroName)
                
                updateMacroStatus("Recording... (Started mid-game)")
                updateDetailedStatus(string.format("Recording in progress - %s (Wave %d)", currentMacroName, currentWave))
                
                task.defer(function()
                    Rayfield:Notify({
                        Title = "Recording Started!",
                        Content = string.format("Mid-game recording: %s (Wave %d)", currentMacroName, currentWave),
                        Duration = 4
                    })
                end)
            else
                -- We're in lobby - wait for wave 1
                recordingHasStarted = false
                
                --print("Recording enabled - waiting for game to start")
                
                updateMacroStatus("Recording enabled - Waiting for game to start...")
                updateDetailedStatus("Recording enabled - Waiting for game start...")
                
                task.defer(function()
                    Rayfield:Notify({
                        Title = "Recording Ready",
                        Content = "Recording will start when game begins",
                        Duration = 3
                    })
                end)
            end
            
        else
            -- Stop recording
            if recordingHasStarted then
                local actionCount = #macro
                stopRecording()
                
                task.defer(function()
                    Rayfield:Notify({
                        Title = "Recording Stopped",
                        Content = string.format("Saved %d actions", actionCount),
                        Duration = 3
                    })
                end)
            else
                isRecording = false
                
                updateMacroStatus("Ready")
                updateDetailedStatus("Ready")
                
                task.defer(function()
                    Rayfield:Notify({
                        Title = "Recording Disabled",
                        Content = "Recording toggle turned off",
                        Duration = 2
                    })
                end)
            end
        end
    end
})

task.spawn(function()
    while true do
        Services.RunService.Heartbeat:Wait()
        
        -- Apply queued macro status update
        if statusUpdateQueue.macroStatus and MacroStatusLabel then
            local msg = statusUpdateQueue.macroStatus
            statusUpdateQueue.macroStatus = nil
            
            pcall(function()
                MacroStatusLabel:Set("Status: " .. tostring(msg))
            end)
        end
        
        -- Apply queued detailed status update
        if statusUpdateQueue.detailedStatus and detailedStatusLabel then
            local msg = statusUpdateQueue.detailedStatus
            statusUpdateQueue.detailedStatus = nil
            
            pcall(function()
                detailedStatusLabel:Set("Details: " .. tostring(msg))
            end)
        end
        
        -- Apply queued toggle update
        if statusUpdateQueue.toggleUpdate ~= nil and RecordToggle then
            local value = statusUpdateQueue.toggleUpdate
            statusUpdateQueue.toggleUpdate = nil
            
            pcall(function()
                RecordToggle:Set(value)
            end)
        end
    end
end)

local function getPlayerMoney()
    local success, money = pcall(function()
        return game:GetService("Players").LocalPlayer.leaderstats.Cash.Value
    end)
    
    if success and money then
        return money
    end
    
    return 0
end

local function getUnitDataModule(unitName)
    local unitModule = DataModule.Units:FindFirstChild(unitName)
    if unitModule then
        local success, data = pcall(require, unitModule)
        if success then
            return data
        end
    end
    return nil
end

local function getUnitPlacementCost(unitName)
    local unitData = getUnitDataModule(unitName)
    return unitData and unitData.Cost or nil
end

local function getUnitUpgradeCost(unitName, currentLevel)
    local unitData = getUnitDataModule(unitName)
    if not unitData or not unitData.Upgrades then return nil end
    
    local upgradeData = unitData.Upgrades[currentLevel + 1]
    return upgradeData and upgradeData.Cost or nil
end

local function calculateTotalUpgradeCost(unitName, startLevel, upgradeAmount)
    local unitData = getUnitDataModule(unitName)
    if not unitData or not unitData.Upgrades then return nil end
    
    local totalCost = 0
    for i = 1, upgradeAmount do
        local targetLevel = startLevel + i
        local upgradeData = unitData.Upgrades[targetLevel]
        
        if upgradeData and upgradeData.Cost then
            totalCost = totalCost + upgradeData.Cost
        else
            return nil
        end
    end
    
    return totalCost
end

local function clearAllUpgradeListeners()
    -- Just disconnect all connections immediately, don't spawn a task
    for unitID, connection in pairs(unitUpgradeListeners) do
        pcall(function()
            connection:Disconnect()
        end)
        unitUpgradeListeners[unitID] = nil
    end
    
    --print("🧹 Cleared all upgrade listeners")
    unitTrackedLevels = {}
end

local function clearSpawnIdMappings()
    playbackUnitTagToID = {}
    recordingUnitCounter = {}
    recordingUnitIDToTag = {}
    pendingUpgrades = {}
    clearAllUpgradeListeners() -- Clear listeners instead of just tables
end

local function isGameActive()
    -- Check if we're in an active game (wave 1 or higher)
    local wave = WaveManager and WaveManager.Data.Wave or 0
    return wave >= 1 and gameInProgress
end

local function waitForGameStart_Playback()
    while isInLobby() and isPlaybacking and isAutoLoopEnabled do
        task.wait(0.5)
    end
    
    if isPlaybacking and isAutoLoopEnabled then
        task.wait(1)
    end
end

-- ============================================
-- UNIT TRACKING FUNCTIONS
-- ============================================

local function getUnitReplicaFolder()
    local unitReplica = ReplicaStore.Get("UnitReplica")
    return unitReplica and unitReplica.Children or nil
end

local function getUnitByID(unitID)
    local unitReplicas = getUnitReplicaFolder()
    if not unitReplicas then return nil end
    
    for _, unit in pairs(unitReplicas) do
        if unit.Id == unitID then
            return unit
        end
    end
    
    return nil
end

local function getUnitName(unitID)
    local unit = getUnitByID(unitID)
    return unit and unit.Data.Name or nil
end

local function getUnitUpgradeLevel(unitID)
    local unit = getUnitByID(unitID)
    if not unit then return 0 end
    return unit.Data.Upgrade or 0
end

local function getUnitMaxUpgradeLevel(unitName)
    local unitData = getUnitDataModule(unitName)
    if not unitData or not unitData.Upgrades then return 0 end
    return #unitData.Upgrades
end

local function findLatestPlacedUnit(targetCFrame, tolerance, excludeUnitIDs)
    tolerance = tolerance or 5
    excludeUnitIDs = excludeUnitIDs or {}
    
    local unitReplicas = getUnitReplicaFolder()
    if not unitReplicas then return nil, nil end
    
    local unitsFolder = Services.Workspace:FindFirstChild("Map")
    if unitsFolder then
        unitsFolder = unitsFolder:FindFirstChild("Units")
    end
    
    if not unitsFolder then
        warn("⚠️ workspace.Map.Units folder not found!")
        return nil, nil
    end
    
    local candidates = {}
    
    -- Go through all unit replicas
    for _, unitReplica in pairs(unitReplicas) do
        local unitID = unitReplica.Id
        
        -- Skip if already mapped or excluded
        if excludeUnitIDs[unitID] then
            continue
        end
        
        local unitName = unitReplica.Data.Name
        
        -- Find the MODEL in workspace that matches this replica
        for _, unitModel in pairs(unitsFolder:GetChildren()) do
            if unitModel.Name == unitName and unitModel:IsA("Model") then
                local unitCFrame = unitModel:GetPivot()
                local distance = (unitCFrame.Position - targetCFrame.Position).Magnitude
                
                -- Check if this model is close to target position
                if distance <= tolerance then
                    table.insert(candidates, {
                        unitID = unitID,
                        unitName = unitName,
                        distance = distance
                    })
                    break -- Only match one model per replica
                end
            end
        end
    end
    
    if #candidates == 0 then return nil, nil end
    
    -- Return the closest match
    table.sort(candidates, function(a, b) return a.distance < b.distance end)
    
    return candidates[1].unitID, candidates[1].unitName
end

local function restartMatch()
    local success, result = pcall(function()
        local settingsFrame = LocalPlayer.PlayerGui.MainScreenFolder.SharedSideScreen.Frames.SettingsFrame.Selected.Scroll
        
        -- Search for the Match frame with "Restart" title
        for _, frame in ipairs(settingsFrame:GetChildren()) do
            if frame.Name == "Match" and frame:IsA("Frame") then
                local title = frame:FindFirstChild("Title")
                if title and title:IsA("TextLabel") and title.Text:find("Restart") then
                    local actionButton = frame:FindFirstChild("Action")
                    if actionButton and actionButton:IsA("ImageButton") then
                        -- Use MouseButton1Down like in your working example
                        for _, connection in pairs(getconnections(actionButton.MouseButton1Down)) do
                            connection:Fire()
                            --print("🔄 Restarted Match")
                            return true
                        end
                    end
                end
            end
        end
        --warn("⚠️ Could not find restart button")
        return false
    end)
    
    if not success then
        warn("⚠️ Failed to restart match via button:", result)
        return false
    end
    
    return result
end

local function startTrackingUnitUpgrades(unitID, unitTag, unitName)
    -- If already tracking this unit, don't add duplicate listener
    if unitUpgradeListeners[unitID] then
        return
    end
    
    local unit = getUnitByID(unitID)
    if not unit then
        return
    end
    
    -- Initialize the tracked level
    local currentLevel = getUnitUpgradeLevel(unitID)
    unitTrackedLevels[unitID] = currentLevel
    
    --print(string.format("👀 Started tracking upgrades for %s (ID=%d, StartLevel=%d)", unitTag, unitID, currentLevel))
    
    -- Listen to changes in the Upgrade field
    local connection = unit:ListenToChange("Upgrade", function(newLevel, oldLevel)
        -- Only run during recording
        if not isRecording or not recordingHasStarted or not gameInProgress then
            return
        end
        
        -- Safety check
        if not recordingUnitIDToTag[unitID] then
            return
        end
        
        local lastLevel = unitTrackedLevels[unitID] or oldLevel or 0
        newLevel = tonumber(newLevel) or 0
        
        -- Check if level actually increased
        if newLevel > lastLevel then
            -- Find matching pending upgrade
            local foundPending = nil
            for i = #pendingUpgrades, 1, -1 do
                local pending = pendingUpgrades[i]
                
                if pending.unitID == unitID and 
                   not pending.validated and
                   pending.startLevel == lastLevel then
                    foundPending = pending
                    break
                end
            end
            
            if foundPending then
                -- VALIDATED UPGRADE
                local gameRelativeTime = foundPending.timestamp - gameStartTime
                local upgradeAmount = newLevel - foundPending.startLevel
                
                local record = {
                    Type = "upgrade_unit",
                    Unit = foundPending.unitTag,
                    Time = string.format("%.2f", gameRelativeTime)
                }
                
                if upgradeAmount > 1 then
                    record.Amount = upgradeAmount
                    local totalCost = calculateTotalUpgradeCost(foundPending.unitName, foundPending.startLevel, upgradeAmount)
                    if totalCost then
                        record.UpgradeCost = totalCost
                    end
                else
                    if foundPending.upgradeCost then
                        record.UpgradeCost = foundPending.upgradeCost
                    end
                end
                
                table.insert(macro, record)
                
                --print(string.format("✅ Validated upgrade: %s (L%d->L%d, Cost=%d)", 
                    --foundPending.unitTag, foundPending.startLevel, newLevel, record.UpgradeCost or 0))
                
                foundPending.validated = true
            else
                -- AUTO-UPGRADE (not from player action)
                --print(string.format("🚫 Auto-upgrade: %s (L%d->L%d) - skipping", 
                    --unitTag, lastLevel, newLevel))
            end
            
            -- Update tracked level
            unitTrackedLevels[unitID] = newLevel
        end
    end)
    
    -- Store the connection so we can disconnect it later
    unitUpgradeListeners[unitID] = connection
end

local function stopTrackingUnitUpgrades(unitID)
    local connection = unitUpgradeListeners[unitID]
    if connection then
        connection:Disconnect()
        unitUpgradeListeners[unitID] = nil
        unitTrackedLevels[unitID] = nil
        --print(string.format("🛑 Stopped tracking unit ID %d", unitID))
    end
end

-- ============================================
-- MACRO RECORDING - REMOTE HOOKS
-- ============================================

local mt = getrawmetatable(game)
setreadonly(mt, false)
local originalNamecall = mt.__namecall

local generalHook = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and isRecording and recordingHasStarted then
        task.spawn(function()
            local timestamp = tick()
            local gameRelativeTime = timestamp - gameStartTime
            
            -- PLACEMENT HOOK
            if method == "InvokeServer" and self.Name == "UnitPlace" then
    local uuid = args[1]
    local cframe = args[2]
    
    --print(string.format("📝 Recording placement: UUID=%s at (%.1f, %.1f, %.1f)", 
        --uuid, cframe.Position.X, cframe.Position.Y, cframe.Position.Z))
    
    task.wait(0.5)
    
    -- BUILD PROPER EXCLUDE LIST - all units we've already mapped
    local excludeIDs = {}
    for mappedUnitID, _ in pairs(recordingUnitIDToTag) do
        excludeIDs[mappedUnitID] = true
        --print(string.format("  Excluding already-mapped unit ID: %d", mappedUnitID))
    end
    
    local unitID, unitName = findLatestPlacedUnit(cframe, 5, excludeIDs)
    
    if unitID and unitName then
        -- Double-check we haven't already mapped this unit
        if recordingUnitIDToTag[unitID] then
            warn(string.format("⚠️ Unit ID %d was already mapped! Skipping duplicate.", unitID))
            return
        end
        
        -- Increment counter for this unit type
        recordingUnitCounter[unitName] = (recordingUnitCounter[unitName] or 0) + 1
        local unitNumber = recordingUnitCounter[unitName]
        local unitTag = string.format("%s #%d", unitName, unitNumber)
        
        -- Track this unit
        recordingUnitIDToTag[unitID] = unitTag
        
        local placementCost = getUnitPlacementCost(unitName)
        
        -- Record to macro
        local record = {
            Type = "spawn_unit",
            Unit = unitTag,
            UUID = uuid,
            Time = string.format("%.2f", gameRelativeTime),
            Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z}
        }
        
        if placementCost then
            record.PlacementCost = placementCost
        end
        
        table.insert(macro, record)
        
        -- START TRACKING UPGRADES FOR THIS UNIT
        startTrackingUnitUpgrades(unitID, unitTag, unitName)
        
        --print(string.format("✓ Recorded: %s (ID=%d, Cost=%d)", 
            --unitTag, unitID, placementCost or 0))
    else
        warn("❌ Failed to find placed unit!")
    end
            
            -- UPGRADE/SELL HOOK
            elseif method == "FireServer" and self.Name == "Replica_ReplicaSignal" then
                local unitID = args[1]
                local action = args[2]
                
                local unitTag = recordingUnitIDToTag[unitID]
                if not unitTag then return end
                
                local unitName = unitTag:match("^(.+) #%d+$")
                
                if action == "Upgrade" then
                    local currentLevel = getUnitUpgradeLevel(unitID)
                    local upgradeCost = getUnitUpgradeCost(unitName, currentLevel)
                    
                    table.insert(pendingUpgrades, {
                        unitID = unitID,
                        unitTag = unitTag,
                        unitName = unitName,
                        startLevel = currentLevel,
                        expectedEndLevel = currentLevel + 1,
                        upgradeCost = upgradeCost,
                        timestamp = timestamp,
                        validated = false
                    })
                    
                    --print(string.format("⏳ Upgrade fired: %s (ID=%d, L%d->L%d, Cost=%d)", 
                        --unitTag, unitID, currentLevel, currentLevel + 1, upgradeCost or 0))
                    
                elseif action == "Sell" then
                    table.insert(macro, {
                        Type = "sell_unit",
                        Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                    
                    --print(string.format("✓ Recorded sell: %s (ID=%d)", unitTag, unitID))
                    
                    -- STOP TRACKING THIS UNIT'S UPGRADES
                    stopTrackingUnitUpgrades(unitID)
                    recordingUnitIDToTag[unitID] = nil
                end
            end
        end)
    end
    
    return originalNamecall(self, ...)
end)

mt.__namecall = generalHook
setreadonly(mt, true)

-- ============================================
-- UPGRADE VALIDATION (Heartbeat Monitor)
-- ============================================

-- Expire unvalidated upgrades
task.spawn(function()
    while true do
        task.wait(0.5)
        
        if isRecording and recordingHasStarted then
            local currentTime = tick()
            
            for i = #pendingUpgrades, 1, -1 do
                local pending = pendingUpgrades[i]
                local age = currentTime - pending.timestamp
                
                if not pending.validated and age > UPGRADE_VALIDATION_TIMEOUT then
                    --print(string.format("🚫 Expired upgrade: %s (likely auto-upgrade)", pending.unitTag))
                    --table.remove(pendingUpgrades, i)
                end
            end
        else
            if #pendingUpgrades > 0 then
                pendingUpgrades = {}
            end
        end
    end
end)

-- ============================================
-- MACRO PLAYBACK
-- ============================================

local function waitForSufficientMoney(cost, actionDescription)
    if not cost then return true end
    
    local currentMoney = getPlayerMoney()
    
    if currentMoney >= cost then return true end
    
    updateMacroStatus(string.format("Waiting for money (%d/%d)", currentMoney, cost))
    updateDetailedStatus(string.format("Need $%d more for: %s", cost - currentMoney, actionDescription))
    --print(string.format("Need %d more money for: %s", cost - currentMoney, actionDescription))
    
    while getPlayerMoney() < cost and isPlaybacking do
        task.wait(0.5)
        local newMoney = getPlayerMoney()
        if newMoney ~= currentMoney then
            currentMoney = newMoney
            updateMacroStatus(string.format("Waiting for money (%d/%d)", currentMoney, cost))
            updateDetailedStatus(string.format("Need $%d more for: %s", cost - currentMoney, actionDescription))
        end
    end
    
    return isPlaybacking
end

local function findUnitIDByTag(unitTag)
    -- Check if we already have this unit mapped
    if playbackUnitTagToID[unitTag] then
        return playbackUnitTagToID[unitTag]
    end
    
    -- Extract base unit name and number
    local unitName, unitNumber = unitTag:match("^(.+) #(%d+)$")
    if not unitName or not unitNumber then
        warn("Invalid unit tag format:", unitTag)
        return nil
    end
    
    unitNumber = tonumber(unitNumber)
    
    -- Find all units of this type in current game
    local unitReplicas = getUnitReplicaFolder()
    if not unitReplicas then return nil end
    
    local matchingUnits = {}
    
    for _, unit in pairs(unitReplicas) do
        if unit.Data.Name == unitName then
            table.insert(matchingUnits, unit.Id)
        end
    end
    
    -- Sort by ID to get consistent ordering
    table.sort(matchingUnits)
    
    -- Return the Nth unit of this type
    if matchingUnits[unitNumber] then
        playbackUnitTagToID[unitTag] = matchingUnits[unitNumber]
        return matchingUnits[unitNumber]
    end
    
    return nil
end

local function executePlacementAction(action, actionIndex, totalActions)
    updateMacroStatus(string.format("(%d/%d) Placing %s", actionIndex, totalActions, action.Unit))
    updateDetailedStatus(string.format("(%d/%d) Placing %s...", actionIndex, totalActions, action.Unit))
    --print("=== EXECUTING PLACEMENT ===")
    --print("Unit Tag:", action.Unit)
    
    if action.PlacementCost then
        if not waitForSufficientMoney(action.PlacementCost, action.Unit) then
            return false
        end
    end
    
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    
    local success = pcall(function()
        Services.ReplicatedStorage:WaitForChild("DefenseSharedFolder")
            :WaitForChild("Remotes"):WaitForChild("UnitPlace")
            :InvokeServer(action.UUID, cframe)
    end)
    
    if not success then
        warn("❌ Failed to place unit")
        return false
    end
    
    -- Build exclude list of already-mapped units
    local excludeIDs = {}
    for _, mappedID in pairs(playbackUnitTagToID) do
        excludeIDs[mappedID] = true
    end
    
    -- Wait and find the placed unit
    local unitID = nil
    local unitName = nil
    
    for attempt = 1, 15 do
        task.wait(0.5)
        unitID, unitName = findLatestPlacedUnit(cframe, 8, excludeIDs)
        if unitID then break end
    end
    
    if unitID then
        -- Map this placement to the unit tag
        playbackUnitTagToID[action.Unit] = unitID
        --print(string.format("✓ Placed %s (ID=%d)", action.Unit, unitID))
        updateMacroStatus(string.format("(%d/%d) Placed %s", actionIndex, totalActions, action.Unit))
        updateDetailedStatus(string.format("(%d/%d) Placed %s successfully", actionIndex, totalActions, action.Unit))
        return true
    end
    
    warn("❌ Failed to detect placed unit")
    updateDetailedStatus(string.format("(%d/%d) Failed to place %s", actionIndex, totalActions, action.Unit))
    return false
end

local function executeUnitUpgrade(action, actionIndex, totalActions)
    updateMacroStatus(string.format("(%d/%d) Upgrading %s", actionIndex, totalActions, action.Unit))
    updateDetailedStatus(string.format("(%d/%d) Upgrading %s...", actionIndex, totalActions, action.Unit))
    --print("=== EXECUTING UPGRADE ===")
    --print("Unit Tag:", action.Unit)
    
    local unitID = findUnitIDByTag(action.Unit)
    
    if not unitID then
        warn("❌ No mapping found for:", action.Unit)
        return false
    end
    
    local unitName = action.Unit:match("^(.+) #%d+$")
    local upgradeAmount = action.Amount or 1
    local currentLevel = getUnitUpgradeLevel(unitID)
    local maxLevel = getUnitMaxUpgradeLevel(unitName)
    
    if currentLevel >= maxLevel then
        --print(string.format("ℹ️ %s already at max level", action.Unit))
        return true
    end
    
    if action.UpgradeCost then
        if not waitForSufficientMoney(action.UpgradeCost, 
            string.format("Upgrade %s x%d", action.Unit, upgradeAmount)) then
            return false
        end
    end
    
    for i = 1, upgradeAmount do
        local success = pcall(function()
            Services.ReplicatedStorage:WaitForChild("ReplicaRemoteEvents")
                :WaitForChild("Replica_ReplicaSignal")
                :FireServer(unitID, "Upgrade")
        end)
        
        if not success then
            warn(string.format("❌ Upgrade %d/%d failed", i, upgradeAmount))
            updateDetailedStatus(string.format("(%d/%d) Upgrade failed", actionIndex, totalActions))
            return false
        end
        
        task.wait(0.3)
    end
    
    --print(string.format("✓ Upgraded %s x%d times", action.Unit, upgradeAmount))
    updateMacroStatus(string.format("(%d/%d) Upgraded %s", actionIndex, totalActions, action.Unit))
    updateDetailedStatus(string.format("(%d/%d) Upgraded %s x%d", actionIndex, totalActions, action.Unit, upgradeAmount))
    return true
end

local function executeUnitSell(action, actionIndex, totalActions)
    updateMacroStatus(string.format("(%d/%d) Selling %s", actionIndex, totalActions, action.Unit))
    updateDetailedStatus(string.format("(%d/%d) Selling %s...", actionIndex, totalActions, action.Unit))
    --print("=== EXECUTING SELL ===")
    --print("Unit Tag:", action.Unit)
    
    local unitID = findUnitIDByTag(action.Unit)
    
    if not unitID then
        warn("❌ No mapping found")
        return false
    end
    
    local success = pcall(function()
        Services.ReplicatedStorage:WaitForChild("ReplicaRemoteEvents")
            :WaitForChild("Replica_ReplicaSignal")
            :FireServer(unitID, "Sell")
    end)
    
    if success then
        playbackUnitTagToID[action.Unit] = nil
        --print(string.format("✓ Sold %s", action.Unit))
        updateMacroStatus(string.format("(%d/%d) Sold %s", actionIndex, totalActions, action.Unit))
        updateDetailedStatus(string.format("(%d/%d) Sold %s", actionIndex, totalActions, action.Unit))
        return true
    end
    
    warn("❌ Failed to sell unit")
    updateDetailedStatus(string.format("(%d/%d) Failed to sell %s", actionIndex, totalActions, action.Unit))
    return false
end

local function playMacroOnce()
    if not macro or #macro == 0 then
        notify("Playback Error", "No macro data to play")
        return false
    end
    
    --print("=== PLAYBACK STARTED ===")
    updateMacroStatus("Status: Playing macro...")
    updateDetailedStatus("Starting macro playback...")
    
    -- Clear playback mappings
    playbackUnitTagToID = {}
    
    local playbackStartTime = gameStartTime
    if playbackStartTime == 0 then
        playbackStartTime = tick()
    end
    
    for actionIndex, action in ipairs(macro) do
        if not isPlaybacking or not gameInProgress then
            --print("Playback stopped")
            return false
        end
        
        local actionTime = tonumber(action.Time) or 0
        local currentTime = tick() - playbackStartTime
        
        -- Wait for timing (unless ignoring)
        if not State.IgnoreTiming then
            if currentTime < actionTime then
                local waitTime = actionTime - currentTime
                updateMacroStatus(string.format("(%d/%d) Waiting %.1fs...", actionIndex, #macro, waitTime))
                updateDetailedStatus(string.format("Waiting %.1fs for timing...", waitTime))
                
                local waitStart = tick()
                while (tick() - waitStart) < waitTime and isPlaybacking and gameInProgress do
                    task.wait(0.1)
                end
            end
        end
        
        if not isPlaybacking or not gameInProgress then break end
        
        -- Execute action
        if action.Type == "spawn_unit" then
            executePlacementAction(action, actionIndex, #macro)
            task.wait(0.3)
            
        elseif action.Type == "upgrade_unit" then
            executeUnitUpgrade(action, actionIndex, #macro)
            task.wait(0.3)
            
        elseif action.Type == "sell_unit" then
            executeUnitSell(action, actionIndex, #macro)
            task.wait(0.3)
        end
    end
    
    updateMacroStatus("Status: Macro completed!")
    updateDetailedStatus("Macro completed successfully!")
    --print("=== PLAYBACK COMPLETED ===")
    notify("Playback", "Macro completed successfully!")
    return true
end

-- ============================================
-- GAME STATE TRACKING
-- ============================================

local function startGameTracking()
    if gameInProgress then return end
    
    gameInProgress = true
    gameStartTime = tick()
    
    --print("✓ GAME STARTED - Tracking initialized")
    
    -- Auto-start recording if enabled
    if isRecording and not recordingHasStarted then
        recordingHasStarted = true
        
        -- SAFE CLEANUP
        recordingUnitCounter = {}
        recordingUnitIDToTag = {}
        pendingUpgrades = {}
        unitTrackedLevels = {}
        macro = {}

        updateMacroStatus("Recording...")
        updateDetailedStatus("Recording in progress - " .. currentMacroName)
        
        --print("✅ Recording started - " .. currentMacroName)
    end
    
    -- Auto-start playback if enabled
    if isPlaybacking then
        --print("Starting macro playback...")
        updateMacroStatus("Starting playback...")
        updateDetailedStatus("Starting playback...")
        
        task.spawn(function()
            playMacroOnce()
        end)
    end
    
    -- If neither recording nor playback, just update status
    if not isRecording and not isPlaybacking then
        updateMacroStatus("Game started")
        updateDetailedStatus("Game in progress")
    end
end

local function stopGameTracking(gameResult)
    if not gameInProgress then return end
    
    local resultText = gameResult and gameResult.Completed and "WON" or "LOST"
    print(string.format("Game ended (%s)", resultText))
    
    gameInProgress = false
    gameStartTime = 0
    
    local wasRecording = isRecording and recordingHasStarted
    local wasPlaybacking = isPlaybacking and isAutoLoopEnabled
    
    -- AUTO-STOP RECORDING
    if wasRecording then
        local actionCount = #macro
        stopRecording()
        
        -- Queue the toggle update to happen on main thread FIRST
        statusUpdateQueue.toggleUpdate = false
        
        -- Queue status updates
        statusUpdateQueue.macroStatus = "Recording saved - Ready"
        statusUpdateQueue.detailedStatus = string.format("Saved %d actions to %s", actionCount, currentMacroName)
        
        task.defer(function()
            Rayfield:Notify({
                Title = "Recording Auto-Stopped",
                Content = string.format("Saved %d actions to %s", actionCount, currentMacroName),
                Duration = 4
            })
        end)
        
        --print(string.format("🛑 Recording stopped - saved %d actions", actionCount))
    end
    
    if wasPlaybacking then
        --print("Game ended - playback will restart on next game")
        statusUpdateQueue.macroStatus = "Game ended - waiting for next game..."
        statusUpdateQueue.detailedStatus = "Game ended - waiting for next game"
    end
    
    recordingUnitCounter = {}
    recordingUnitIDToTag = {}
    playbackUnitTagToID = {}
    pendingUpgrades = {}
    unitTrackedLevels = {}
    clearAllUpgradeListeners()
    
    if not wasRecording and not wasPlaybacking then
        statusUpdateQueue.macroStatus = "Ready"
        statusUpdateQueue.detailedStatus = "Ready"
    end
end


-- ============================================
-- WAVE MANAGER LISTENERS
-- ============================================
if not isInLobby then
WaveManager:ListenToChange("Wave", function(wave)
    --print(string.format("🌊 Wave changed: %d (lastWave: %d, gameInProgress: %s)", wave, lastWave, tostring(gameInProgress)))
    
    if wave < lastWave and gameInProgress then
        --print("🔄 Wave reset detected (restart pressed)")
        
        if isPlaybacking and isAutoLoopEnabled then
            gameInProgress = false
            gameStartTime = 0
            clearSpawnIdMappings()
            statusUpdateQueue.macroStatus = "Game restarted - waiting for game start..."
            statusUpdateQueue.detailedStatus = "Waiting for game start..."
            --print("⏸️ Playback stopped due to restart - waiting for next game")
        end
        
        if isRecording and recordingHasStarted then
            local actionCount = #macro
            stopRecording()
            unitTrackedLevels = {}
            
            statusUpdateQueue.macroStatus = "Recording saved - Ready"
            statusUpdateQueue.detailedStatus = string.format("Saved %d actions (game restarted)", actionCount)
            
            task.defer(function()
                Rayfield:Notify({
                    Title = "Recording Stopped",
                    Content = string.format("Game restarted - saved %d actions", actionCount),
                    Duration = 3
                })
            end)
            
            --print("🛑 Recording stopped and saved due to restart")
            recordingHasStarted = false
            
            statusUpdateQueue.macroStatus = "Recording enabled - Waiting for game to start..."
            statusUpdateQueue.detailedStatus = "Waiting for game start to restart recording..."
        end
        
        lastWave = 0
        return
    end
    
    lastWave = wave
    
    if wave == 1 and not gameInProgress then
        --print("🎮 Wave 1 detected - Starting game tracking")
        startGameTracking()
    end
end)

WaveManager:ConnectOnClientEvent(function(endData)
    if gameInProgress then
        stopGameTracking(endData)
    end
    lastWave = 0
end)

task.spawn(function()
    local lastGameEndState = false
    
    while true do
        task.wait(0.5)
        
        local success, waveEndScreen = pcall(function()
            return game:GetService("Players").LocalPlayer.PlayerGui.DefenseScreenFolder.WaveEndScreen
        end)
        
        if success and waveEndScreen then
            local waveEnd = waveEndScreen:FindFirstChild("WaveEnd")
            local isVisible = waveEnd and waveEnd.Visible or false
            
            -- Game just ended (transitioned from hidden to visible)
            if isVisible and not lastGameEndState then
                lastGameEndState = true
                
                task.spawn(function()
                    task.wait(1) -- Delay to ensure UI is ready
                    
                    -- Priority 1: Auto Retry (highest priority)
                    if State.AutoRetry then
                        print("Auto Retry enabled - Clicking Replay...")
                        local success = pcall(function()
                            local replayButton = game:GetService("Players").LocalPlayer.PlayerGui.DefenseScreenFolder.WaveEndScreen.WaveEnd.Buttons.Replay
                            
                            if replayButton then
                                for _, connection in pairs(getconnections(replayButton.MouseButton1Down)) do
                                    connection:Fire()
                                end
                            end
                        end)
                        
                        if success then
                            notify("Auto Retry", "Replaying...", 3)
                        end
                        return
                    end
                    
                    -- Priority 2: Auto Next
                    if State.AutoNext then
                        print("Auto Next enabled - Clicking Next...")
                        local success = pcall(function()
                            local nextButton = game:GetService("Players").LocalPlayer.PlayerGui.DefenseScreenFolder.WaveEndScreen.WaveEnd.Buttons.Next
                            
                            if nextButton then
                                for _, connection in pairs(getconnections(nextButton.MouseButton1Down)) do
                                    connection:Fire()
                                end
                            end
                        end)
                        
                        if success then
                            notify("Auto Next", "Going to next level...", 3)
                        end
                        return
                    end
                    
                    -- Priority 3: Auto Lobby (lowest priority)
                    if State.AutoLobby then
                        print("Auto Lobby enabled - Clicking Lobby...")
                        local success = pcall(function()
                            local lobbyButton = game:GetService("Players").LocalPlayer.PlayerGui.DefenseScreenFolder.WaveEndScreen.WaveEnd.Buttons.Lobby
                            
                            if lobbyButton then
                                for _, connection in pairs(getconnections(lobbyButton.MouseButton1Down)) do
                                    connection:Fire()
                                end
                            end
                        end)
                        
                        if success then
                            notify("Auto Lobby", "Returning to lobby...", 3)
                        end
                        return
                    end
                end)
            end
            
            -- Game ended screen is no longer visible
            if not isVisible and lastGameEndState then
                lastGameEndState = false
            end
        end
    end
end)
end


local AutoRetryToggle = GameTab:CreateToggle({
    Name = "Auto Retry",
    CurrentValue = false,
    Flag = "AutoRetry",
    Callback = function(Value)
        State.AutoRetry = Value
    end,
})

local AutoNextToggle = GameTab:CreateToggle({
    Name = "Auto Next",
    CurrentValue = false,
    Flag = "AutoNext",
    Callback = function(Value)
        State.AutoNext = Value
    end,
})

local AutoLobbyToggle = GameTab:CreateToggle({
    Name = "Auto Lobby",
    CurrentValue = false,
    Flag = "AutoLobby",
    Callback = function(Value)
        State.AutoLobby = Value
    end,
})

local AutoGameSpeedToggle = GameTab:CreateToggle({
    Name = "Auto Game Speed",
    CurrentValue = false,
    Flag = "AutoGameSpeed",
    Callback = function(Value)
        State.AutoGameSpeed = Value
    end,
})

local GameSpeedSelector = GameTab:CreateDropdown({
    Name = "Game Speed Selector",
    Options = {"1x", "2x", "3x"},
    CurrentOption = {"1x"},
    MultipleOptions = false,
    Flag = "GameSpeed",
    Info = "Select the game speed value",
    Callback = function(Options)
        local selected = Options[1]
        if selected == "1x" then
            State.GameSpeed = 1
        elseif selected == "2x" then
            State.GameSpeed = 2
        elseif selected == "3x" then
            State.GameSpeed = 3
        end
    end,
})

local function applyGameSpeed(speed)
    local speedStr = tostring(speed)
    
    local success = pcall(function()
        local speedButton = game:GetService("Players").LocalPlayer.PlayerGui.DefenseScreenFolder.WaveScreen.WaveTop.Speed.Buttons[speedStr]
        
        if speedButton then
            for _, connection in pairs(getconnections(speedButton.MouseButton1Down)) do
                connection:Fire()
            end
            print(string.format("Applied game speed: %sx", speedStr))
        end
    end)
    
    if not success then
        warn("Failed to apply game speed")
    end
end

-- Apply game speed continuously when enabled
task.spawn(function()
    while true do
        task.wait(0.5)
        
        if State.AutoGameSpeed and State.GameSpeed then
            applyGameSpeed(State.GameSpeed)
        end
    end
end)

local MacroDropdown = MacroTab:CreateDropdown({
    Name = "Select Macro",
    Options = {},
    CurrentOption = {},
    Flag = "MacroDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        currentMacroName = name
        if name and macroManager[name] then
            macro = macroManager[name]
            --print("Selected:", name, "with", #macro, "actions")
        end
    end,
})

local MacroInput = MacroTab:CreateInput({
    Name = "Create Macro",
    PlaceholderText = "Enter macro name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        
        if cleanedName ~= "" then
            if macroManager[cleanedName] then
                notify("Error", "Macro already exists")
                return
            end
            
            macroManager[cleanedName] = {}
            saveMacroToFile(cleanedName)
            MacroDropdown:Refresh(getMacroList(), cleanedName)
            notify("Success", "Created: " .. cleanedName)
        end
    end,
})

MacroTab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        loadAllMacros()
        MacroDropdown:Refresh(getMacroList())
        notify("Refreshed", "Macro list updated")
    end,
})

MacroTab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            notify("Error", "No macro selected")
            return
        end
        
        deleteMacroFile(currentMacroName)
        notify("Deleted", currentMacroName)
        currentMacroName = ""
        macro = {}
        MacroDropdown:Refresh(getMacroList())
    end,
})

local function updateStatusWithDetails(message)
    MacroStatusLabel:Set("Status: " .. message)
    if detailedStatusLabel then
        detailedStatusLabel:Set("Details: " .. message)
    end
end

local function startRecordingNow()
    if gameStartTime == 0 then
        gameStartTime = tick()
    end
    
    recordingHasStarted = true
    clearSpawnIdMappings()
    table.clear(macro)
    trackedUnits = {}
    
    updateStatusWithDetails("Recording...")
    --print("Recording started")
end

local function autoPlaybackLoop()
    if playbackLoopRunning then
        warn("Playback loop already running!")
        return
    end
    
    playbackLoopRunning = true
    --print("=== PLAYBACK LOOP STARTED (INFINITE) ===")
    
    while isAutoLoopEnabled and isPlaybacking do
        -- Wait until we're in an active game (not lobby, not intermission)
        while (isInLobby() or not isGameActive()) and isAutoLoopEnabled and isPlaybacking do
            updateMacroStatus("Status: Playback - Waiting for game to start...")
            updateDetailedStatus("Waiting for game to start...")
            task.wait(0.5)
        end
        
        -- Check if playback was disabled while waiting
        if not isAutoLoopEnabled or not isPlaybacking then 
            --print("Playback disabled, stopping loop")
            break 
        end
        
        -- Double-check we're actually in a game before proceeding
        if not isGameActive() then
            task.wait(0.5)
            continue
        end
        
        if not currentMacroName or currentMacroName == "" then
            updateMacroStatus("Status: Error - No macro selected!")
            updateDetailedStatus("Error - No macro selected!")
            Rayfield:Notify({
                Title = "Playback Error",
                Content = "No macro selected!",
                Duration = 3
            })
            break
        end
        
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            updateMacroStatus("Status: Error - Failed to load macro!")
            updateDetailedStatus("Error - Failed to load macro!")
            Rayfield:Notify({
                Title = "Playback Error",
                Content = "Failed to load: " .. tostring(currentMacroName),
                Duration = 3
            })
            break
        end
        
        macro = loadedMacro
        
        clearSpawnIdMappings()
        
        updateMacroStatus("Status: Playback - Executing (" .. #macro .. " actions)...")
        updateDetailedStatus("Starting playback: " .. currentMacroName)
        Rayfield:Notify({
            Title = "Playback Started",
            Content = currentMacroName .. " (" .. #macro .. " actions)",
            Duration = 3
        })
        
        -- CRITICAL FIX: Spawn playMacroOnce in a new thread so it can be properly interrupted
        local playbackThread = task.spawn(function()
            local completed = playMacroOnce()
            
            -- Only update status if we're still in playback mode
            if isPlaybacking and isAutoLoopEnabled then
                if completed then
                    updateMacroStatus("Status: Macro completed - waiting for next game...")
                    updateDetailedStatus("Macro completed successfully - waiting for next game")
                    Rayfield:Notify({
                        Title = "Playback Complete",
                        Content = "Waiting for next game to start...",
                        Duration = 3
                    })
                else
                    updateMacroStatus("Status: Game ended - waiting for next game...")
                    updateDetailedStatus("Game ended mid-macro - waiting for next game")
                    Rayfield:Notify({
                        Title = "Game Ended",
                        Content = "Macro interrupted - waiting for next game...",
                        Duration = 3
                    })
                end
            end
        end)
        
        -- Wait for either playback to complete OR game to end
        while isGameActive() and isAutoLoopEnabled and isPlaybacking do
            task.wait(0.5)
        end
        
        -- If game ended, wait a bit for cleanup
        if not isGameActive() then
            --print("Game ended - waiting for playback thread to finish cleanup...")
            task.wait(1) -- Give playback thread time to clean up
        end
        
        clearSpawnIdMappings()
        
        -- Wait a bit before checking for next game
        task.wait(2)
    end
    
    updateMacroStatus("Status: Playback Stopped")
    updateDetailedStatus("Playback loop ended")
    isPlaybacking = false
    playbackLoopRunning = false
    --print("=== PLAYBACK LOOP ENDED ===")
end

local PlayToggle = MacroTab:CreateToggle({
    Name = "Playback Macro",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        if Value then
            -- Small delay to let configuration load properly
            task.wait(0.1)

            -- Check if macro is selected
            if not currentMacroName or currentMacroName == "" then
                Rayfield:Notify({
                    Title = "Playback Error",
                    Content = "Please select a macro first!",
                    Duration = 3
                })
                task.wait(0.1)
                return
            end

            -- Load the macro
            local loadedMacro = macroManager[currentMacroName] or loadMacroFromFile(currentMacroName)
            
            if not loadedMacro or #loadedMacro == 0 then
                Rayfield:Notify({
                    Title = "Playback Error",
                    Content = "Macro is empty or doesn't exist",
                    Duration = 3
                })
                task.wait(0.1)
                return
            end

            -- CRITICAL: Check if already running BEFORE setting flags
            if playbackLoopRunning then
                --print("⚠️ Playback loop already running, ignoring duplicate start")
                return
            end

            macro = loadedMacro
            
            -- Clear any stale game state when manually enabling playback
            if not isInLobby() then
                local currentWave = WaveManager and WaveManager.Data.Wave or 0
                if currentWave >= 1 then
                    -- We're mid-game, restart it
                    Rayfield:Notify({
                        Title = "Mid-Game Detected",
                        Content = "Restarting game for accurate playback...",
                        Duration = 4
                    })
                        restartMatch()
                    -- Reset game state after requesting restart
                    gameInProgress = false
                    gameStartTime = 0
                else
                    -- We're in intermission, just reset state
                    gameInProgress = false
                    gameStartTime = 0
                end
            end
            
            isAutoLoopEnabled = true
            isPlaybacking = true
            
            updateMacroStatus("Status: Playback Enabled - Waiting for game...")
            Rayfield:Notify({
                Title = "Playback Enabled",
                Content = "Loaded: " .. currentMacroName,
                Duration = 4
            })

            -- Start the playback loop
            task.spawn(autoPlaybackLoop)

        else
            -- Stop playback
            isAutoLoopEnabled = false
            isPlaybacking = false
            
            -- Wait for loop to actually stop
            local timeout = 0
            while playbackLoopRunning and timeout < 20 do
                task.wait(0.1)
                timeout = timeout + 1
            end
            
            -- Force reset if it didn't stop
            if playbackLoopRunning then
                warn("⚠️ Force stopping playback loop")
                playbackLoopRunning = false
            end
            
            updateMacroStatus("Status: Playback Disabled")
            Rayfield:Notify({
                Title = "Playback Disabled",
                Content = "Stopped playback",
                Duration = 3
            })
        end
    end
})

local IgnoreTimingToggle = MacroTab:CreateToggle({
    Name = "Ignore Timing",
    CurrentValue = false,
    Flag = "IgnoreTiming",
    Info = "Skip timing waits and execute actions immediately",
    Callback = function(Value)
        State.IgnoreTiming = Value
    end,
})

local ExportButton = MacroTab:CreateButton({
    Name = "Copy Macro JSON",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            notify("Error", "No macro selected")
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            notify("Error", "Macro is empty")
            return
        end
        
        local json = Services.HttpService:JSONEncode(macroData)
        
        if setclipboard then
            setclipboard(json)
            notify("Export Success", string.format("Copied %s (%d actions)", currentMacroName, #macroData))
        else
            --print("=== MACRO JSON ===")
            --print(json)
            --print("=== END ===")
            --notify("Export", "JSON printed to console")
        end
    end,
})

local ImportInput = MacroTab:CreateInput({
    Name = "Import Macro (JSON)",
    PlaceholderText = "Paste JSON content here...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then
            return
        end
        
        local macroName = "ImportedMacro_" .. os.time()
        
        local success, importData = pcall(function()
            return Services.HttpService:JSONDecode(text)
        end)
        
        if not success then
            notify("Import Error", "Invalid JSON format")
            return
        end
        
        local deserializedActions
        if type(importData) == "table" then
            if #importData > 0 then
                deserializedActions = importData
            else
                notify("Import Error", "No actions found")
                return
            end
        end
        
        if #deserializedActions == 0 then
            notify("Import Error", "Macro contains no actions")
            return
        end
        
        macroManager[macroName] = deserializedActions
        saveMacroToFile(macroName)
        MacroDropdown:Refresh(getMacroList(), macroName)
        
        notify("Import Success", string.format("%s (%d actions)", macroName, #deserializedActions))
    end,
})

local CheckUnitsButton = MacroTab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            notify("Error", "No macro selected")
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            notify("Error", "Macro is empty")
            return
        end
        
        local units = {}
        local unitCounts = {}
        
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local baseUnitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                
                if not units[baseUnitName] then
                    units[baseUnitName] = true
                    unitCounts[baseUnitName] = 0
                end
                unitCounts[baseUnitName] = unitCounts[baseUnitName] + 1
            end
        end
        
        local unitList = {}
        for unitName, count in pairs(unitCounts) do
            table.insert(unitList, string.format("%s", unitName))
        end
        
        if #unitList > 0 then
            table.sort(unitList)
            local displayText = table.concat(unitList, ", ")
            
            notify("Macro Units", displayText)
            --print("=== MACRO UNITS ===")
            for _, line in ipairs(unitList) do
                print(line)
            end
        else
            notify("No Units", "No placements found")
        end
    end,
})

-- ============================================
-- INITIALIZATION
-- ============================================



ensureMacroFolders()
loadAllMacros()
MacroDropdown:Refresh(getMacroList())

Rayfield:LoadConfiguration()

task.spawn(function()
    task.wait(2)
    
    -- Restore saved macro selection
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
            --print("Successfully loaded saved macro:", currentMacroName, "with", #macro, "actions")
        else
            --print("Could not load saved macro:", savedMacroName)
        end
    end
    
    MacroDropdown:Refresh(getMacroList())
    
    -- Restore playback if it was enabled
    local savedPlaybackState = Rayfield.Flags["PlayBackMacro"]
    if savedPlaybackState == true and currentMacroName and currentMacroName ~= "" and macro and #macro > 0 then
        -- Double check we're not already running
        if not playbackLoopRunning then
            isAutoLoopEnabled = true
            isPlaybacking = true
            
            -- Check if we need to restart mid-game
            local currentWave = WaveManager and WaveManager.Data.Wave or 0
            if not isInLobby() and currentWave >= 1 then
                --print("Mid-Round detected on restore, requesting restart...")
                    restartMatch()
            end
            
            task.spawn(autoPlaybackLoop)
            updateMacroStatus("Status: Playback restored - waiting for game")
            
            Rayfield:Notify({
                Title = "Playback Restored",
                Content = string.format("Auto-playing: %s", currentMacroName),
                Duration = 3
            })
            
            --print(string.format("Playback restored: %s (%d actions)", currentMacroName, #macro))
        else
            --print("Playback loop already running, skipping restore")
        end
    end
end)
