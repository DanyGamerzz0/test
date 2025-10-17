local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.02"

-- Create Window
local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Last Stand",
   Icon = 0,
   LoadingTitle = "Loading for Anime Last Stand",
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
      FileName = "Lixhub_ALS"
   },
   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },
   KeySystem = true,
      KeySettings = {
      Title = "LixHub - Anime Last Stand - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})

-- Services
local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    TeleportService = game:GetService("TeleportService")
}

local LocalPlayer = Services.Players.LocalPlayer

-- State Management
local State = {
    gameInProgress = false,
    gameStartTime = 0,
    isRecording = false,
    isPlaybacking = false,
    recordingHasStarted = false,
    isAutoLoopEnabled = false,
    SendStageCompletedWebhook = false,
}

local RewardTotals = {}

local Config = {
    DISCORD_USER_ID = 0,
}

-- Macro Data
local macro = {}
local macroManager = {}
local currentMacroName = ""
local isAutoLoopEnabled = false
local ValidWebhook = nil

-- Unit Tracking
local trackedUnits = {} -- Maps tower instance name to placement ID
local recordingPlacementCounter = {} -- Counts placements per unit type
local playbackUnitMapping = {} -- Maps placement ID to current tower instance
local pendingUpgrades = {} -- Tracks upgrades waiting for validation
local UPGRADE_VALIDATION_TIMEOUT = 1.5
local abilityQueue = {}
local waveSkipQueueThread = nil
local placementExecutionLock = false

-- UI Elements
local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "tv")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")
local MacroStatusLabel = MacroTab:CreateLabel("Macro Status: Ready")
local detailedStatusLabel = MacroTab:CreateLabel("Macro Details: Ready")

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title or "Notice",
        Content = content or "No message.",
        Duration = duration or 5,
        Image = "info",
    })
end

local function isInLobby()
    return Services.Workspace:FindFirstChild("Lobby") ~= nil
end

local function getPlayerMoney()
    return tonumber(LocalPlayer.Cash.Value) or 0
end

local function getCurrentWave()
    return Services.ReplicatedStorage.Wave.Value or 0
end

local function ensureMacroFolders()
    if not isfolder("LixHub") then makefolder("LixHub") end
    if not isfolder("LixHub/Macros") then makefolder("LixHub/Macros") end
    if not isfolder("LixHub/Macros/ALS") then makefolder("LixHub/Macros/ALS") end
end

local function getMacroFilename(name)
    if type(name) == "table" then name = name[1] or "" end
    if type(name) ~= "string" or name == "" then return nil end
    return "LixHub/Macros/ALS/" .. name .. ".json"
end

local function updateDetailedStatus(message)
    if detailedStatusLabel then
        detailedStatusLabel:Set("Macro Details: " .. message)
    end
    print("Macro Status: " .. message)
end

-- ============================================
-- MACRO FILE OPERATIONS
-- ============================================

local function saveMacroToFile(name)
    local data = macroManager[name]
    if not data then return end
    
    local json = Services.HttpService:JSONEncode(data)
    writefile(getMacroFilename(name), json)
    print("Saved macro:", name)
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
    macroManager = {}
    for _, file in ipairs(listfiles("LixHub/Macros/ALS/")) do
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

-- ============================================
-- UNIT HELPER FUNCTIONS
-- ============================================

local function getBaseUnitName(fullName)
    -- "Rukia 1" -> "Rukia"
    return fullName:match("^(.+)%s+%d+$") or fullName
end

local function getUnitSpawnId(fullName)
    -- "Rukia 1" -> 1
    local id = fullName:match("%s(%d+)$")
    return id and tonumber(id) or nil
end

local function getDisplayNameFromUnit(unitString)
    -- "Rukia #1" -> "Rukia"
    return unitString:match("^(.+)%s#%d+$") or unitString
end

local function getPlacementNumber(unitString)
    -- "Rukia #1" -> 1
    return tonumber(unitString:match("#(%d+)$"))
end

local function getTowerUpgradeLevel(towerInstance)
    if not towerInstance or not towerInstance:FindFirstChild("Upgrade") then
        return 0
    end
    return towerInstance.Upgrade.Value
end

local function getTowerMaxUpgradeLevel(unitBaseName)
    local towerInfo = Services.ReplicatedStorage.Modules.TowerInfo
    local unitData = towerInfo:FindFirstChild(unitBaseName)
    
    if unitData then
        local success, moduleData = pcall(function()
            return require(unitData)
        end)
        
        if success and moduleData then
            -- Count the number of upgrade tiers
            local maxLevel = 0
            for i = 1, 100 do -- Reasonable upper limit
                if moduleData[i] then
                    maxLevel = i
                else
                    break
                end
            end
            return maxLevel
        end
    end
    
    return 3 -- Default fallback
end

local function getUpgradeCost(unitBaseName, currentLevel)
    local towerInfo = Services.ReplicatedStorage.Modules.TowerInfo
    local unitData = towerInfo:FindFirstChild(unitBaseName)
    
    if unitData then
        local success, moduleData = pcall(function()
            return require(unitData)
        end)
        
        if success and moduleData then
            local nextLevelData = moduleData[currentLevel + 1]
            if nextLevelData and nextLevelData.Cost then
                return nextLevelData.Cost
            end
        end
    end
    
    return nil
end

local function findNewlyPlacedTower(unitName, targetCFrame, usePreciseMatch)
    usePreciseMatch = usePreciseMatch or true  -- Default to precise matching

    local towersFolder = Services.Workspace:FindFirstChild("Towers")
    if not towersFolder then 
        warn("❌ Towers folder not found!")
        return nil 
    end

    print(string.format("🔍 Searching for NEW '%s' with CFrame: %s", 
        unitName, tostring(targetCFrame)))

    local candidatesFound = 0
    local skippedTracked = 0

    for _, tower in pairs(towersFolder:GetChildren()) do
        -- Skip already-tracked towers by UID
        local uid = tower:GetAttribute("UniqueID")
        if uid and trackedUnits[uid] then
            skippedTracked = skippedTracked + 1
            continue
        end

        -- Check owner
        local ownerValue = tower:FindFirstChild("Owner")
        if not ownerValue or ownerValue.Value ~= Services.Players.LocalPlayer then
            continue
        end

        -- Match by name
        if tower.Name == unitName then
            candidatesFound = candidatesFound + 1
            
            -- 🔥 GET THE OriginalCFrame ATTRIBUTE
            local originalCFrame = tower:GetAttribute("PlacePosition")
            
            if originalCFrame then
                -- 🔥 COMPARE CFRAMES DIRECTLY
                if usePreciseMatch then
                    -- Exact CFrame match (best method)
                    if originalCFrame == targetCFrame then
                        print(string.format("✅ EXACT MATCH FOUND! UID=%s", uid or "nil"))
                        return tower
                    end
                else
                    -- Fallback: Position tolerance (if needed)
                    local distance = (originalCFrame.Position - targetCFrame.Position).Magnitude
                    if distance < 0.01 then  -- Within 0.01 studs (practically identical)
                        print(string.format("✅ POSITION MATCH! UID=%s (%.6f studs)", uid or "nil", distance))
                        return tower
                    end
                end
                
                print(string.format("  ❌ Candidate #%d: UID=%s, CFrame mismatch", 
                    candidatesFound, uid or "nil"))
            else
                warn(string.format("  ⚠️ Candidate #%d has no OriginalCFrame attribute!", candidatesFound))
            end
        end
    end

    print(string.format("📊 Search results: %d candidates checked, %d already tracked, 0 exact matches", 
        candidatesFound, skippedTracked))
    
    warn(string.format("❌ No NEW '%s' found with matching CFrame!", unitName))
    return nil
end

-- ============================================
-- RECORDING FUNCTIONS
-- ============================================

local function clearTrackingData()
    trackedUnits = {}
    recordingPlacementCounter = {}
    pendingUpgrades = {}
    print("✓ Cleared all tracking data")
end

local function startRecordingNow()
    if State.gameStartTime == 0 then
        State.gameStartTime = tick()
        print("Set game start time for recording:", State.gameStartTime)
    end
    
    State.recordingHasStarted = true
    clearTrackingData()
    table.clear(macro)
    
    MacroStatusLabel:Set("Status: Recording active!")
    print("Recording started")
end

local function stopRecording()
    State.isRecording = false
    State.recordingHasStarted = false
    print(string.format("Stopped recording. Recorded %d actions", #macro))
    notify("Macro Recorder", "Stopped recording! Saved " .. #macro .. " actions.")
    
    if currentMacroName and currentMacroName ~= "" then
        macroManager[currentMacroName] = macro
        saveMacroToFile(currentMacroName)
    end
    
    return macro
end

local function processPlacementAction(unitName, cframe)
    print(string.format("📝 Recording placement: %s at CFrame: %s", 
        unitName, tostring(cframe)))

    -- Wait for tower to spawn
    task.wait(0.5)

    -- 🔥 USE CFRAME MATCHING INSTEAD OF POSITION
    local tower = findNewlyPlacedTower(unitName, cframe, true)

    if not tower then
        warn("❌ RECORDING FAILED: Could not find tower:", unitName)
        return
    end

    -- Validate UniqueID
    local uid = tower:GetAttribute("UniqueID")
    if not uid then
        warn("❌ RECORDING FAILED: Tower has no UniqueID:", tower.Name)
        return
    end

    -- Get placement cost
    local placementCost
    local sellValue = tower:FindFirstChild("SellValue")
    if sellValue and sellValue:IsA("NumberValue") then
        placementCost = sellValue.Value * 2
    end

    -- Increment placement counter
    recordingPlacementCounter[unitName] = (recordingPlacementCounter[unitName] or 0) + 1
    local placementNumber = recordingPlacementCounter[unitName]
    local placementId = string.format("%s #%d", unitName, placementNumber)

    -- Record to macro
    local gameRelativeTime = tick() - State.gameStartTime
    local record = {
        Type = "place_tower",
        Unit = placementId,
        UnitName = unitName,
        Time = string.format("%.2f", gameRelativeTime),
        Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z},
        Rotation = {cframe:ToEulerAnglesXYZ()},
        PlacementCost = placementCost
    }
    table.insert(macro, record)

    -- Track by UID
    trackedUnits[uid] = placementId

    print(string.format("✓ Recorded: %s → UID: %s (Cost: %d)", 
        placementId, uid, placementCost or 0))
end

local function processUpgradeAction(towerInstance, targetLevel)  -- 🆕 ADD PARAMETER
    local uid = towerInstance:GetAttribute("UniqueID")
    local placementId = uid and trackedUnits[uid]

    if not placementId then
        warn("❌ Upgrade attempted on untracked tower:", towerInstance.Name)
        return
    end

    local currentLevel = getTowerUpgradeLevel(towerInstance)
    local timestamp = tick()
    
    -- 🆕 USE TARGET LEVEL IF PROVIDED
    local expectedEndLevel = targetLevel or (currentLevel + 1)

    table.insert(pendingUpgrades, {
        towerUID = uid,
        placementId = placementId,
        startLevel = currentLevel,
        expectedEndLevel = expectedEndLevel,  -- 🆕 USE THIS
        timestamp = timestamp,
        validated = false
    })

    print(string.format("⏳ Upgrade remote fired: %s (L%d->L%d expected)", 
        placementId, currentLevel, expectedEndLevel))  -- 🆕 UPDATED LOG
end

local function processSellAction(towerInstance)
    local uid = towerInstance:GetAttribute("UniqueID")
    local placementId = uid and trackedUnits[uid]

    if not placementId then
        warn("❌ Sell attempted on untracked tower:", towerInstance.Name)
        return
    end

    local timestamp = tick()
    local gameRelativeTime = timestamp - State.gameStartTime

    -- Record sell in macro
    local record = {
        Type = "sell_tower",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime)
    }

    table.insert(macro, record)

    print(string.format("💰 Tower sold: %s", placementId))

    -- Cleanup tracking
    trackedUnits[uid] = nil
end

-- ============================================
-- PLAYBACK FUNCTIONS
-- ============================================

local function waitForSufficientMoney(requiredMoney, actionDescription)
    if not requiredMoney then return true end
    
    local currentMoney = getPlayerMoney()
    
    if currentMoney >= requiredMoney then
        return true
    end
    
    MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
        currentMoney, requiredMoney, actionDescription))
    
    print(string.format("Need %d more coins for %s (Cost: %d)", 
        requiredMoney - currentMoney, actionDescription, requiredMoney))
    
    while getPlayerMoney() < requiredMoney and State.isPlaybacking do
        task.wait(0.5)
        local newMoney = getPlayerMoney()
        if newMoney ~= currentMoney then
            currentMoney = newMoney
            MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
                currentMoney, requiredMoney, actionDescription))
        end
    end
    
    if not State.isPlaybacking then
        return false
    end
    
    print(string.format("Ready to execute %s!", actionDescription))
    return true
end

local function executePlacement(action, actionIndex, totalActions)
    while placementExecutionLock do
        task.wait(0.1)
    end
    placementExecutionLock = true
    
    local unitBaseName = action.UnitName
    local pos = action.Position
    local rot = action.Rotation
    
    print(string.format("🏗️ Placing: %s at (%.1f, %.1f, %.1f)", unitBaseName, pos[1], pos[2], pos[3]))
    
    -- Wait for money
    if action.PlacementCost then
        if not waitForSufficientMoney(action.PlacementCost, "place " .. action.Unit) then
            placementExecutionLock = false
            return false
        end
    end
    
    -- Reconstruct CFrame
    local cframe = CFrame.new(pos[1], pos[2], pos[3]) * CFrame.Angles(rot[1], rot[2], rot[3])
    
    updateDetailedStatus(string.format("(%d/%d) Placing %s...", actionIndex, totalActions, action.Unit))
    
    -- Fire placement remote
    local success = pcall(function()
        Services.ReplicatedStorage.Remotes.PlaceTower:FireServer(unitBaseName, cframe)
    end)
    
    if not success then
        warn("❌ Failed to place:", unitBaseName)
        placementExecutionLock = false
        return false
    end
    
    -- Wait for tower to spawn
    task.wait(0.5)
    
    -- 🔥 USE CFRAME MATCHING
    local tower = findNewlyPlacedTower(unitBaseName, cframe, true)
    
    if tower then
        local uid = tower:GetAttribute("UniqueID")
        
        if not uid then
            warn("❌ Placed tower has no UniqueID:", tower.Name)
            updateDetailedStatus(string.format("(%d/%d) ERROR: %s has no UID", actionIndex, totalActions, action.Unit))
            placementExecutionLock = false
            return false
        end
        
        playbackUnitMapping[action.Unit] = uid
        print(string.format("✅ Placed and mapped: %s → UID: %s", action.Unit, uid))
        updateDetailedStatus(string.format("(%d/%d) Placed %s successfully", actionIndex, totalActions, action.Unit))
        placementExecutionLock = false
        return true
    else
        warn("❌ Could not find placed tower:", action.Unit)
        updateDetailedStatus(string.format("(%d/%d) FAILED to place %s", actionIndex, totalActions, action.Unit))
        placementExecutionLock = false
        return false
    end
end

local function executeUpgrade(action, actionIndex, totalActions)
    local towerName = playbackUnitMapping[action.Unit]
    
    if not towerName then
        warn("❌ No mapping found for:", action.Unit)
        return false
    end
    
    local towers = Services.Workspace:FindFirstChild("Towers")
    if not towers then return false end
    
    local uid = playbackUnitMapping[action.Unit]
    local towerInstance = nil
    for _, t in pairs(Services.Workspace.Towers:GetChildren()) do
        if t:GetAttribute("UniqueID") == uid then
            towerInstance = t
            break
        end
    end
    
    if not towerInstance then
        warn("❌ Tower instance not found:", towerName)
        return false
    end
    
    local unitBaseName = getDisplayNameFromUnit(action.Unit) -- Extract base name like "Rukia"
    local maxLevel = getTowerMaxUpgradeLevel(unitBaseName)
    local currentLevel = getTowerUpgradeLevel(towerInstance)
    
    -- 🆕 HANDLE MULTI-LEVEL UPGRADES
    local upgradeAmount = action.Amount or 1
    local targetLevel = currentLevel + upgradeAmount
    
    if currentLevel >= maxLevel then
        print(string.format("ℹ️ Unit %s already at max level (%d/%d)", action.Unit, currentLevel, maxLevel))
        return true
    end
    
    -- Clamp target level to max
    if targetLevel > maxLevel then
        targetLevel = maxLevel
        upgradeAmount = targetLevel - currentLevel
    end
    
    -- 🆕 CALCULATE TOTAL COST FOR ALL UPGRADES
    local totalCost = 0
    for i = 1, upgradeAmount do
        local levelToUpgrade = currentLevel + i - 1
        local upgradeCost = getUpgradeCost(unitBaseName, levelToUpgrade)
        if upgradeCost then
            totalCost = totalCost + upgradeCost
        end
    end
    
    if totalCost > 0 then
        if not waitForSufficientMoney(totalCost, string.format("upgrade %s x%d", action.Unit, upgradeAmount)) then
            return false
        end
    end
    
    updateDetailedStatus(string.format("(%d/%d) Upgrading %s x%d...", actionIndex, totalActions, action.Unit, upgradeAmount))
    
    print(string.format("⬆️ Upgrading %s: %s (L%d -> L%d)", action.Unit, towerName, currentLevel, targetLevel))
    
    -- 🆕 USE NEW REMOTE FORMAT
    local success = pcall(function()
        Services.ReplicatedStorage.Remotes.Upgrade:InvokeServer(towerInstance, targetLevel)
    end)
    
    if success then
        task.wait(0.5)
        local newLevel = getTowerUpgradeLevel(towerInstance)
        
        if newLevel > currentLevel then
            print(string.format("✅ Upgraded %s (%d→%d)", action.Unit, currentLevel, newLevel))
            updateDetailedStatus(string.format("(%d/%d) Upgraded %s successfully", actionIndex, totalActions, action.Unit))
            return true
        end
    end
    
    warn(string.format("❌ Failed to upgrade %s", action.Unit))
    return false
end

local function executeSell(action, actionIndex, totalActions)
    local towerName = playbackUnitMapping[action.Unit]
    
    if not towerName then
        warn("❌ No mapping found for:", action.Unit)
        return false
    end
    
    local towers = Services.Workspace:FindFirstChild("Towers")
    if not towers then return false end
    
    local uid = playbackUnitMapping[action.Unit]
local towerInstance = nil
for _, t in pairs(Services.Workspace.Towers:GetChildren()) do
    if t:GetAttribute("UniqueID") == uid then
        towerInstance = t
        break
    end
end
    if not towerInstance then
        warn("❌ Tower instance not found:", towerName)
        return false
    end
    
    updateDetailedStatus(string.format("(%d/%d) Selling %s...", actionIndex, totalActions, action.Unit))
    
    print(string.format("💰 Selling %s: %s", action.Unit, towerName))
    
    local success = pcall(function()
        Services.ReplicatedStorage.Remotes.Sell:InvokeServer(towerInstance)
    end)
    
    if success then
        task.wait(0.5)
        
        if not towers:FindFirstChild(towerName) then
            print(string.format("✅ Successfully sold %s", action.Unit))
            updateDetailedStatus(string.format("(%d/%d) Sold %s successfully", actionIndex, totalActions, action.Unit))
            playbackUnitMapping[action.Unit] = nil
            return true
        end
    end
    
    warn(string.format("❌ Failed to sell %s", action.Unit))
    return false
end

local function executeWaveSkip(action, actionIndex, totalActions)
    print("---Executing wave skip---")
    updateDetailedStatus(string.format("(%d/%d) Skipping wave...", actionIndex, totalActions))
    
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
            :WaitForChild("VoteSkip"):FireServer()
    end)
    
    if success then
        print("✓ Wave skip vote sent")
        updateDetailedStatus(string.format("(%d/%d) Wave skip sent", actionIndex, totalActions))
        return true
    else
        warn("❌ Failed to skip wave:", err)
        return false
    end
end

local function waitForGameStart_Playback()
    local gameStartedValue = Services.ReplicatedStorage:WaitForChild("GameStarted") -- Boolean
    local gameEndedValue = Services.ReplicatedStorage:WaitForChild("GameEnded") -- Boolean

    print("🕓 Waiting for current game to finish...")

    -- Wait until the current game actually ends
    while gameStartedValue.Value and not gameEndedValue.Value do
        task.wait(1)
    end

    -- Wait for end screen / intermission phase
    while gameEndedValue.Value do
        task.wait(1)
    end

    print("⏳ Waiting for next game to start...")

    -- Now wait until the next game really starts
    while not gameStartedValue.Value or gameEndedValue.Value do
        task.wait(0.5)
    end

    print("🎬 Playback started - new game detected!")
end

local function waitForGameStart()
    local gameStarted = Services.ReplicatedStorage:WaitForChild("GameStarted")
    
    -- If game is currently running, wait for it to end first
    if gameStarted.Value then
        MacroStatusLabel:Set("Status: Waiting for current game to end...")
        Rayfield:Notify({
            Title = "Waiting for Current Game",
            Content = "Waiting for current game to end...",
            Duration = 2
        })
        
        -- Wait for current game to end
        repeat 
            task.wait(0.1) 
        until not gameStarted.Value
        
        MacroStatusLabel:Set("Status: Game ended, waiting for next game...")
        Rayfield:Notify({
            Title = "Game Ended",
            Content = "Current game ended, waiting for next game...",
            Duration = 2
        })
    else
        MacroStatusLabel:Set("Status: Waiting for next game to start...")
        Rayfield:Notify({
            Title = "Waiting for Game",
            Content = "Waiting for next game to start...",
            Duration = 2
        })
    end

    -- Now wait for the next game to start
    repeat 
        task.wait(0.1) 
    until gameStarted.Value

    MacroStatusLabel:Set("Status: Game started! Initializing macro...")
    return gameStarted.Value
end

local function playMacroOnce()
    if not macro or #macro == 0 then
        print("❌ No macro data to play")
        return false
    end
    
    print("▶️ Starting macro playback...")
    MacroStatusLabel:Set("Status: Executing macro...")
    
    playbackUnitMapping = {}
    abilityQueue = {} -- Clear queue
    
    local playbackStartTime = State.gameStartTime
    if playbackStartTime == 0 then
        playbackStartTime = tick()
    end
    
    -- 🆕 START WAVE SKIP QUEUE PROCESSOR
    if waveSkipQueueThread then
        task.cancel(waveSkipQueueThread)
    end
    
    waveSkipQueueThread = task.spawn(function()
        while State.isPlaybacking and State.gameInProgress do
            local currentTime = tick() - playbackStartTime
            
            for i = #abilityQueue, 1, -1 do
                local queuedItem = abilityQueue[i]
                
                if currentTime >= queuedItem.scheduledTime then
                    MacroStatusLabel:Set(string.format("Status: (%d/%d) Skipping wave", 
                        queuedItem.actionIndex, queuedItem.totalActions))
                    executeWaveSkip(queuedItem.action, queuedItem.actionIndex, queuedItem.totalActions)
                    print(string.format("✅ Fired wave skip at %.2fs", currentTime))
                    table.remove(abilityQueue, i)
                end
            end
            
            task.wait(0.1)
        end
    end)
    
    for i, action in ipairs(macro) do
        if not State.isPlaybacking or not State.gameInProgress then
            print("⏹️ Playback stopped")
            if waveSkipQueueThread then task.cancel(waveSkipQueueThread) end
            return false
        end
        
        local actionTime = tonumber(action.Time) or 0
        local currentTime = tick() - playbackStartTime
        
        -- 🆕 HANDLE WAVE SKIPS WITH SMART TIMING
        if action.Type == "skip_wave" then
            if State.IgnoreTiming then
                -- Schedule wave skip for correct timing
                table.insert(abilityQueue, {
                    action = action,
                    scheduledTime = actionTime,
                    actionIndex = i,
                    totalActions = #macro
                })
                print(string.format("⏰ Scheduled wave skip at %.2fs", actionTime))
            else
                -- Wait for correct timing
                if currentTime < actionTime then
                    local waitTime = actionTime - currentTime
                    print(string.format("⏳ Waiting %.1fs for wave skip", waitTime))
                    
                    local waitStart = tick()
                    while (tick() - waitStart) < waitTime and State.isPlaybacking and State.gameInProgress do
                        task.wait(0.1)
                    end
                end
                
                if not State.isPlaybacking or not State.gameInProgress then break end
                executeWaveSkip(action, i, #macro)
            end
            
            task.wait(0.1)
            continue
        end
        
        -- 🆕 FOR OTHER ACTIONS: SKIP TIMING IF IGNORE IS ENABLED
        if not State.IgnoreTiming then
            if currentTime < actionTime then
                local waitTime = actionTime - currentTime
                print(string.format("⏳ Waiting %.1fs for action %d/%d", waitTime, i, #macro))
                
                local waitStart = tick()
                while (tick() - waitStart) < waitTime and State.isPlaybacking and State.gameInProgress do
                    task.wait(0.1)
                end
            end
        end
        
        if not State.isPlaybacking or not State.gameInProgress then break end
        
        -- Execute action
        if action.Type == "place_tower" then
            executePlacement(action, i, #macro)
        elseif action.Type == "upgrade_tower" then
            executeUpgrade(action, i, #macro)
        elseif action.Type == "sell_tower" then
            executeSell(action, i, #macro)
        end
        
        task.wait(0.1)
    end
    
    -- 🆕 WAIT FOR QUEUED WAVE SKIPS
    if #abilityQueue > 0 then
        MacroStatusLabel:Set(string.format("Status: Waiting for %d scheduled wave skips...", #abilityQueue))
        print(string.format("Waiting for %d remaining wave skips...", #abilityQueue))
        
        while #abilityQueue > 0 and State.isPlaybacking and State.gameInProgress do
            task.wait(0.5)
        end
    end
    
    if waveSkipQueueThread then
        task.cancel(waveSkipQueueThread)
    end
    
    MacroStatusLabel:Set("Status: Macro completed")
    print("✅ Macro playback completed")
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
            notify("Playback Error", "No macro selected for playback.")
            break
        end
        
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
            updateDetailedStatus("Error - Failed to load macro!")
            notify("Playback Error", "Failed to load macro: " .. tostring(currentMacroName))
            break
        end
        
        macro = loadedMacro
        State.isPlaybacking = true
        
        -- CRITICAL: Reset unit mappings at start of each playback
        playbackUnitMapping = {}
        
        MacroStatusLabel:Set("Status: Playing macro...")
        updateDetailedStatus("Loading macro: " .. currentMacroName)
        notify("Playback Started", currentMacroName .. " (" .. #macro .. " actions)")
        
        local completed = playMacroOnce()
        
        State.isPlaybacking = false
        
        if completed then
            MacroStatusLabel:Set("Status: Macro completed - waiting for next game...")
            updateDetailedStatus("Macro completed - waiting for next game...")
            notify("Playback Complete", "Waiting for next game to start...")
        else
            MacroStatusLabel:Set("Status: Macro interrupted - waiting for next game...")
            updateDetailedStatus("Macro interrupted - waiting for next game...")
            notify("Playback Interrupted", "Game ended, waiting for next game...")
        end
        
        -- Clear mappings again after game ends
        playbackUnitMapping = {}
        
        task.wait(1)
    end
    
    MacroStatusLabel:Set("Status: Playback stopped")
    updateDetailedStatus("Playback stopped")
    State.isPlaybacking = false
    print("=== PLAYBACK LOOP ENDED ===")
end

-- ============================================
-- GAME STATE MONITORING
-- ============================================

local function onGameStart()
    State.gameInProgress = true
    State.gameStartTime = tick()
    clearTrackingData()
    print("Game started at:", State.gameStartTime)
    
    -- Auto-start recording if enabled
    if State.isRecording and not State.recordingHasStarted then
        startRecordingNow()
    end
end

local function waitForRewards()
    local endGameUI = LocalPlayer.PlayerGui:WaitForChild("EndGameUI", 10)

    if not endGameUI then
        warn("EndGameUI not found")
        return nil
    end

    -- Wait until the UI becomes visible
    local timeout = tick() + 10
    while not endGameUI.Enabled and tick() < timeout do
        task.wait(0.1)
    end

    if not endGameUI.Enabled then
        warn("EndGameUI never enabled")
        return nil
    end

    task.wait(0.5)

    -- Drill down to the rewards holder
    local holder = endGameUI:FindFirstChild("BG")
    if holder then holder = holder:FindFirstChild("Container") end
    if holder then holder = holder:FindFirstChild("Rewards") end
    if holder then holder = holder:FindFirstChild("Holder") end

    if not holder then
        warn("Rewards holder not found")
        return nil
    end

    -- Wait for rewards to populate
    timeout = tick() + 15
    while tick() < timeout and #holder:GetChildren() == 0 do
        task.wait(0.2)
    end

    if #holder:GetChildren() == 0 then
        warn("No rewards detected")
        return nil
    end

    local rewards = {}
    local detectedUnits = {}

    for _, rewardItem in pairs(holder:GetChildren()) do
        if rewardItem:IsA("TextButton") or rewardItem:IsA("ImageButton") then
            local unitName = rewardItem:GetAttribute("Unit")
            local itemName = rewardItem:GetAttribute("Item")
            local amount = rewardItem:GetAttribute("Amount")

            if unitName then
                table.insert(rewards, {
                    Name = unitName,
                    Amount = 1,
                    IsUnit = true
                })
                table.insert(detectedUnits, unitName)
            elseif itemName then
                table.insert(rewards, {
                    Name = itemName,
                    Amount = amount or 1,
                    IsUnit = false
                })
            end
        end
    end

    print(string.format("Captured %d rewards, %d units", #rewards, #detectedUnits))
    
    -- Copy current totals
    local totals = {}
    for name, total in pairs(RewardTotals) do
        totals[name] = total
    end
    
    -- Debug: Print totals
    print("📦 Totals being used:")
    for name, total in pairs(totals) do
        print(string.format("  - %s: %d", name, total))
    end
    
    return rewards, detectedUnits, totals
end


local function formatRewardsText(rewards, totals)
    if not rewards or #rewards == 0 then
        return "None"
    end
    
    totals = totals or {}
    local lines = {}
    
    for _, reward in ipairs(rewards) do
        local total = totals[reward.Name]
        local rewardText
        
        if total then
            rewardText = string.format("%s x%s (%s total)", reward.Name, tostring(reward.Amount), tostring(total))
        else
            rewardText = string.format("%s x%s", reward.Name, tostring(reward.Amount))
        end
        
        table.insert(lines, rewardText)
    end
    
    return table.concat(lines, "\n")
end

local function sendWebhook(messageType, rewards, detectedUnits, clearTime, totals)
    if not ValidWebhook then 
        return 
    end
    
    local data
    
    if messageType == "test" then
        data = {
            content = string.format("<@%s>", Config.DISCORD_USER_ID or "000000000000000000"),
            embeds = {{
                title = "LixHub Test",
                description = "Test webhook successful",
                color = 0x5865F2,
                footer = { text = "LixHub" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
    elseif messageType == "stage" then
        -- Get accurate game data from GetTeleportData
        local stageName = "Unknown"
        local gameType = "?"
        local mapNum = "?"
        local difficulty = "?"
        
        local success, teleportData = pcall(function()
            return Services.ReplicatedStorage.Remotes.GetTeleportData:InvokeServer()
        end)
        
        if success and teleportData then
            stageName = teleportData.MapName or stageName
            gameType = teleportData.Type or gameType
            mapNum = teleportData.MapNum or mapNum
            difficulty = teleportData.Difficulty or difficulty
        else
            warn("Failed to get teleport data, using fallback")
        end
        
        -- Get player level
        local plrlevel = LocalPlayer:FindFirstChild("Level") and LocalPlayer.Level.Value or "?"
        
        local hours = math.floor(clearTime / 3600)
        local minutes = math.floor((clearTime % 3600) / 60)
        local seconds = math.floor(clearTime % 60)
        local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        
        local rewardsText = formatRewardsText(rewards, totals)
        local hasUnits = detectedUnits and #detectedUnits > 0
        
        local shouldPing = hasUnits
        local content = shouldPing and string.format("<@%s>", Config.DISCORD_USER_ID or "") or nil
        
        local title = "Stage Finished - ALS"
        local stageInfo = string.format("%s - %s (Act %s) - Finished", stageName, gameType, mapNum)
        
        -- Nice gray/white color
        local embedColor = 0x95A5A6
        
        data = {
            username = "LixHub",
            content = content,
            embeds = {{
                title = title,
                description = stageInfo,
                color = embedColor,
                fields = {
                    { name = "Player", value = string.format("||%s [%s]||", LocalPlayer.Name, tostring(plrlevel)), inline = true },
                    { name = "Difficulty", value = tostring(difficulty), inline = true },
                    { name = "Time", value = formattedTime, inline = true },
                    { name = "Rewards", value = rewardsText, inline = false },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
    else
        return
    end
    
    local payload = Services.HttpService:JSONEncode(data)
    
    local requestFunc = request or 
                       (syn and syn.request) or 
                       (http and http.request) or 
                       http_request

    if not requestFunc then
        notify("Webhook Error", "No HTTP request function available")
        return
    end
    
    local success, result = pcall(function()
        return requestFunc({
            Url = ValidWebhook,
            Method = "POST",
            Headers = { 
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    end)

    if success and result then
        if result.Success or (result.StatusCode >= 200 and result.StatusCode < 300) then
            notify("Webhook", "Sent successfully", 2)
        else
            notify("Webhook Error", "HTTP " .. tostring(result.StatusCode))
        end
    else
        notify("Webhook Error", tostring(result))
    end
end

local function onGameEnd()
    if not State.gameInProgress then return end

    State.gameInProgress = false
    print("Game ended")

    -- Always wait for rewards before allowing progression
    task.spawn(function()
        local rewards, detectedUnits = waitForRewards()
        
        if not rewards then
            print("Failed to capture rewards")
            return
        end
        
        print(string.format("Rewards captured: %d items, %d units", #rewards, detectedUnits and #detectedUnits or 0))
        
        -- Send webhook only if enabled
        if State.SendStageCompletedWebhook then
            sendWebhook("stage", rewards, detectedUnits)
        end
    end)

    if State.isRecording and State.recordingHasStarted then
        State.isRecording = false
        State.recordingHasStarted = false
        if currentMacroName and #macro > 0 then
            macroManager[currentMacroName] = macro
            saveMacroToFile(currentMacroName)
            notify("Macro Saved", "Recording saved")
        end
    end
end

local function monitorGameState()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local gameStartedFlag = ReplicatedStorage:WaitForChild("GameStarted")
    local gameEndedFlag = ReplicatedStorage:WaitForChild("GameEnded")

    gameStartedFlag.Changed:Connect(function(val)
        if val then
            onGameStart()
        end
    end)

    gameEndedFlag.Changed:Connect(function(val)
        if val then
            onGameEnd()
        end
    end)
end

-- ============================================
-- REMOTE HOOKS
-- ============================================

local mt = getrawmetatable(game)
setreadonly(mt, false)
local originalNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and State.isRecording and State.recordingHasStarted and State.gameInProgress then
        task.spawn(function()
            -- Placement
            if method == "FireServer" and self.Name == "PlaceTower" then
                local unitName = args[1]
                local cframe = args[2]
                
                if unitName and cframe then
                    processPlacementAction(unitName, cframe)
                end
            end
            
            -- Upgrade
            if method == "InvokeServer" and self.Name == "Upgrade" then
                local towerInstance = args[1]
                local targetLevel = args[2]
                
                if towerInstance and towerInstance:IsA("Model") then
                    processUpgradeAction(towerInstance, targetLevel)
                end
            end
            
            -- Sell
            if method == "InvokeServer" and self.Name == "Sell" then
                local towerInstance = args[1]
                
                if towerInstance and towerInstance:IsA("Model") then
                    processSellAction(towerInstance)
                end
            end
            if method == "FireServer" and self.Name == "VoteSkip" then
            local timestamp = tick()
            local gameRelativeTime = timestamp - State.gameStartTime
            table.insert(macro, {
            Type = "skip_wave",
            Time = string.format("%.2f", gameRelativeTime)
        })
        print(string.format("📝 Recorded wave skip at %.2fs", gameRelativeTime))
            end
        end)
    end
    return originalNamecall(self, ...)
end)
setreadonly(mt, true)

-- ============================================
-- UI
-- ============================================

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

local RecordToggle = MacroTab:CreateToggle({
    Name = "Record Macro",
    CurrentValue = false,
    Flag = "RecordMacro",
    Callback = function(Value)
        State.isRecording = Value

        if Value then
            -- Start recording immediately if in game, or when game starts
            if not isInLobby() and State.gameInProgress then
                State.recordingHasStarted = true
                startRecordingNow()
                MacroStatusLabel:Set("Status: Recording active!")
                notify("Recording Started", "Macro recording is now active.")
            else
                State.recordingHasStarted = false
                MacroStatusLabel:Set("Status: Recording enabled - will start when game begins")
                notify("Recording Ready", "Recording will start when you enter a game.")
            end
        elseif not Value then
            notify("Recording Stopped", "Recording manually stopped.")
            stopRecording()
            MacroStatusLabel:Set("Status: Recording stopped")
        end
    end
})

local PlayToggle = MacroTab:CreateToggle({
    Name = "Playback Macro",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isAutoLoopEnabled = Value
        State.isPlaybacking = Value
        
        if Value then
            if isInLobby() then 
                notify("Playback Error", "Cannot start playback in lobby")
                PlayToggle:Set(false)
                return 
            end
            
            -- Ensure we have a valid macro name
            if type(currentMacroName) == "table" then
                currentMacroName = currentMacroName[1] or ""
            end
            
            if not currentMacroName or currentMacroName == "" then
                -- Try to get first available macro if none selected
                local firstMacro = next(macroManager)
                if firstMacro then
                    currentMacroName = firstMacro
                    print("No macro selected, using first available:", currentMacroName)
                else
                    Rayfield:Notify({
                        Title = "Error",
                        Content = "No macro selected and none available",
                        Duration = 3
                    })
                    isAutoLoopEnabled = false
                    State.isPlaybacking = false
                    PlayToggle:Set(false)
                    return
                end
            end
            
            -- Try to load from manager first, then from file
            local loadedMacro = macroManager[currentMacroName] or loadMacroFromFile(currentMacroName)
            
            if loadedMacro and #loadedMacro > 0 then
                macro = loadedMacro
                macroManager[currentMacroName] = loadedMacro -- Ensure it's in manager
                MacroStatusLabel:Set("Status: Playback enabled - waiting for game")
                notify("Playback Enabled", "Macro will play once per game.")
                
                -- Start the loop
                task.spawn(autoPlaybackLoop)
                
                print("Started playback:", currentMacroName, "with", #macro, "actions")
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to load macro or macro is empty",
                    Duration = 3
                })
                isAutoLoopEnabled = false
                State.isPlaybacking = false
                PlayToggle:Set(false)
            end
        else
            MacroStatusLabel:Set("Status: Playback disabled")
            State.isPlaybacking = false
            notify("Playback Disabled", "Macro playback stopped.")
        end
    end
})

-- Add Ignore Timing toggle
local IgnoreTimingToggle = MacroTab:CreateToggle({
    Name = "Ignore Timing",
    CurrentValue = false,
    Flag = "IgnoreTiming",
    Info = "Skip timing waits and execute actions immediately (except abilities)",
    Callback = function(Value)
        State.IgnoreTiming = Value
    end,
})

-- Also add these UI elements if not already present:

local Divider = MacroTab:CreateDivider()



-- Add Import/Export functionality
local ImportInput = MacroTab:CreateInput({
    Name = "Import Macro (JSON)",
    CurrentValue = "",
    PlaceholderText = "Paste JSON content here...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then return end
        
        local macroName = "ImportedMacro_" .. os.time()
        
        -- Try to parse JSON
        local success, importData = pcall(function()
            return Services.HttpService:JSONDecode(text)
        end)
        
        if not success then
            notify("Import Error", "Invalid JSON format")
            return
        end
        
        if type(importData) ~= "table" or #importData == 0 then
            notify("Import Error", "Invalid macro data")
            return
        end
        
        macroManager[macroName] = importData
        ensureMacroFolders()
        saveMacroToFile(macroName)
        refreshMacroDropdown()
        
        notify("Import Success", string.format("Imported '%s' with %d actions", macroName, #importData))
    end,
})

local ExportButton = MacroTab:CreateButton({
    Name = "Copy Macro JSON",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            notify("Export Error", "No macro selected")
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            notify("Export Error", "Macro is empty")
            return
        end
        
        local jsonData = Services.HttpService:JSONEncode(macroData)
        
        if setclipboard then
            setclipboard(jsonData)
            notify("Export Success", "Macro JSON copied to clipboard (" .. #macroData .. " actions)")
        else
            notify("Export Info", "Clipboard not supported. JSON printed to console.")
            print("=== MACRO EXPORT ===")
            print(jsonData)
            print("=== END EXPORT ===")
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

          TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
    })

-- Restore macro on script load
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

task.spawn(function()
    local waveValue = Services.ReplicatedStorage:WaitForChild("Wave")
    
    waveValue.Changed:Connect(function(newWave)
        if newWave >= 1 and not State.gameInProgress then
            -- Game started
            State.gameInProgress = true
            State.gameStartTime = tick()
            clearTrackingData()
            print("Game started at wave:", newWave)
            
            -- Auto-start recording if enabled
            if State.isRecording and not State.recordingHasStarted then
                startRecordingNow()
            end
            
            -- Note: Playback loop handles its own game detection
            
        elseif newWave == 0 and State.gameInProgress then
            -- Game ended
            State.gameInProgress = false
            print("Game ended (wave reset to 0)")
            
            -- Auto-stop recording if it was running
            if State.isRecording and State.recordingHasStarted then
                State.isRecording = false
                State.recordingHasStarted = false
                
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
            
            -- Playback will be handled by the loop itself
        end
    end)
    
    -- Check if we joined mid-game
    if waveValue.Value > 1 then
        State.gameInProgress = true
        State.gameStartTime = tick()
        print("Joined mid-game at wave:", waveValue.Value)
    end
end)

task.spawn(function() 
    local gameStarted = Services.ReplicatedStorage:WaitForChild("GameStarted")
    local gameEnded = Services.ReplicatedStorage:WaitForChild("GameEnded")

    gameStarted.Changed:Connect(function(started)
        if started and not State.gameInProgress then
            State.gameInProgress = true
            State.gameStartTime = tick()
            print("Game started (GameStarted flag)")

            if State.isRecording and not State.recordingHasStarted then
                startRecordingNow()
            end
        end
    end)

    gameEnded.Changed:Connect(function(ended)
    if ended and State.gameInProgress then
        local clearTime = tick() - State.gameStartTime
        State.gameInProgress = false
        print("Game ended (GameEnded flag)")

        -- Webhook + reward capture logic
        task.spawn(function()
            local rewards, detectedUnits, totals = waitForRewards()

            if not rewards then
                print("Failed to capture rewards")
                return
            end

            print(string.format(
                "Rewards captured: %d items, %d units",
                #rewards,
                detectedUnits and #detectedUnits or 0
            ))

            if State.SendStageCompletedWebhook then
                sendWebhook("stage", rewards, detectedUnits, clearTime, totals)
            end
            
            -- Clear totals after webhook sent
            RewardTotals = {}
            print("🧹 Cleared reward totals cache")
        end)

        -- Handle recording stop
        if State.isRecording and State.recordingHasStarted then
            State.isRecording = false
            State.recordingHasStarted = false

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
            end
        end
    end
end)
end)

-- ============================================
-- UPGRADE VALIDATION (HEARTBEAT)
-- ============================================

Services.RunService.Heartbeat:Connect(function()
    if not State.isRecording or not State.recordingHasStarted then return end
    
    local towers = Services.Workspace:FindFirstChild("Towers")
    if not towers then return end
    
    for _, tower in pairs(towers:GetChildren()) do
        local uid = tower:GetAttribute("UniqueID")
        if not uid then continue end

        local placementId = trackedUnits[uid]
        if not placementId then continue end

        local currentLevel = getTowerUpgradeLevel(tower)

        if not tower:GetAttribute("TrackedLevel") then
            tower:SetAttribute("TrackedLevel", currentLevel)
        end

        local lastLevel = tower:GetAttribute("TrackedLevel")

        -- 🆕 DETECT MULTI-LEVEL UPGRADES
        if currentLevel > lastLevel then
            local levelDifference = currentLevel - lastLevel
            
            local foundPending = nil
            for i = #pendingUpgrades, 1, -1 do
                local pending = pendingUpgrades[i]
                if pending.towerUID == uid and not pending.validated and pending.startLevel == lastLevel then
                    foundPending = pending
                    break
                end
            end

            if foundPending then
                local gameRelativeTime = foundPending.timestamp - State.gameStartTime
                local record = {
                    Type = "upgrade_tower",
                    Unit = foundPending.placementId,
                    Time = string.format("%.2f", gameRelativeTime)
                }
                
                -- 🆕 ADD AMOUNT IF MULTI-LEVEL
                if levelDifference > 1 then
                    record.Amount = levelDifference
                    print(string.format("✅ Validated multi-upgrade: %s (L%d->L%d, +%d levels)", 
                        foundPending.placementId, lastLevel, currentLevel, levelDifference))
                else
                    print(string.format("✅ Validated upgrade: %s (L%d->L%d)", 
                        foundPending.placementId, lastLevel, currentLevel))
                end
                
                table.insert(macro, record)
                foundPending.validated = true
            end

            tower:SetAttribute("TrackedLevel", currentLevel)
        end
    end
end)

task.spawn(function()
    print("🎯 Global reward totals listener started")
    
    -- Listen to ReplicaSetValue events
    game:GetService("ReplicatedStorage").ReplicaRemoteEvents.Replica_ReplicaSetValue.OnClientEvent:Connect(function(...)
        local args = {...}
        print("REPLICASETVALUE FIRED WITH "..args[1]..args[2]..args[3])
        if #args >= 3 then
            local category = args[2]
            local value = args[3]
            
            if category == "Emeralds" and type(value) == "number" then
                RewardTotals["Emerald"] = value
                print(string.format("📊 Updated Emerald total: %d", value))
            end
        end
    end)
    
    -- Listen to StartPreload for item totals
    game:GetService("ReplicatedStorage").Remotes.StartPreload.OnClientEvent:Connect(function(dataType, data)
        print("STARTPRELOAD FIRED")
        if dataType == "Item" and data.ItemName and data.Amount then
            RewardTotals[data.ItemName] = data.Amount
            print(string.format("📊 Updated %s total: %d", data.ItemName, data.Amount))
        end
    end)
end)

-- Cleanup expired pending upgrades
task.spawn(function()
    while true do
        task.wait(0.5)
        
        if State.isRecording and State.recordingHasStarted then
            local currentTime = tick()
            
            for i = #pendingUpgrades, 1, -1 do
                local pending = pendingUpgrades[i]
                local age = currentTime - pending.timestamp
                
                if not pending.validated and age > UPGRADE_VALIDATION_TIMEOUT then
                    print(string.format("🚫 Expired unvalidated upgrade: %s", pending.placementId))
                    table.remove(pendingUpgrades, i)
                end
            end
        else
            if #pendingUpgrades > 0 then
                pendingUpgrades = {}
            end
        end
    end
end)
ensureMacroFolders()
loadAllMacros()
Rayfield:LoadConfiguration()
-- ============================================
-- AUTO PLAYBACK LOOP
-- ============================================

