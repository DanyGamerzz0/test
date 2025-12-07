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
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
    RunService = game:GetService("RunService"),
}

    local LocalPlayer = Services.Players.LocalPlayer

    local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

    local script_version = "V0.03"
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

    local LobbyTab = Window:CreateTab("Lobby", "tv")
    local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
    local MacroTab = Window:CreateTab("Macro", "tv")
    local GameTab = Window:CreateTab("Game", "gamepad-2")
    local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

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
local MainSharedFolder
local ReplicaModule
local ReplicaStore
local DataModule
local WaveManager
local lastGameRewards = {}
local ValidWebhook = nil
local hasSentWebhook = false
local ChallengeModule = nil
local InfoModule = nil

        local loadingRetries = {
        story = 0,
        legend = 0,
        raid = 0,
        ignoreWorlds = 0,
        portal = 0
    }

     local AutoJoinState = {
        isProcessing = false,
        currentAction = nil,
        lastActionTime = 0,
        actionCooldown = 2
    }

    local maxRetries = 20 -- Maximum number of retry attempts
    local retryDelay = 2

local Config = {
    DISCORD_USER_ID = nil,
}

local Modules = Services.ReplicatedStorage:FindFirstChild("MainSharedFolder"):FindFirstChild("Modules")
local InfoModuleFolder = Modules:FindFirstChild("InfoModule")

 if Modules:FindFirstChild("ChallengeModule") then
        ChallengeModule = require(Modules.ChallengeModule)
        print("✓ ChallengeModule loaded")
    else
        warn("[-] ChallengeModule not found")
    end

    if InfoModuleFolder and InfoModuleFolder:FindFirstChild("Worlds") then
        WorldsModule = require(InfoModuleFolder.Worlds)
        print("✓ WorldsModule loaded")
    else
        warn("[-] WorldsModule not found")
    end

if game.PlaceId ~= 17899227840 then
if Services.ReplicatedStorage:FindFirstChild("MainSharedFolder") then
    MainSharedFolder = Services.ReplicatedStorage:FindFirstChild("MainSharedFolder")
    
    if MainSharedFolder:FindFirstChild("Modules") then
        local Modules = MainSharedFolder:FindFirstChild("Modules")

        if Modules:FindFirstChild("ReplicaModule") then
            ReplicaModule = require(Modules.ReplicaModule)
            
            if ReplicaModule.ReplicaStore then
                ReplicaStore = ReplicaModule.ReplicaStore
                
                if ReplicaStore.Get then
                    WaveManager = ReplicaStore.Get("WaveManagerReplica")
                    
                    if WaveManager then
                        print("✓ Replicas loaded")
                    else
                        warn("[-] WaveManagerReplica not found")
                    end
                else
                    warn("[-] ReplicaStore.Get function not found")
                end
            else
                warn("[-] ReplicaStore not found in ReplicaModule")
            end
        else
            warn("[-] ReplicaModule not found in Modules")
        end
        
        if Modules:FindFirstChild("DataModule") then
            DataModule = Modules.DataModule
        else
            warn("[-] DataModule not found")
        end
    else
        warn("[-] Modules folder not found in MainSharedFolder")
    end
else
    warn("[-] MainSharedFolder not found in ReplicatedStorage")
end
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
        SendStageCompletedWebhook = false,
        AntiAfkKickEnabled = false,
        enableAutoExecute = false,
        enableLowPerformanceMode = false,
        enableBlackScreen = false,
        enableLimitFPS = false,
        SelectedFPS = 60,
        streamerModeEnabled = false,
        SelectedChallenges = {},
        ChallengeBug = false,
        NewChallengeDetected = false,



        AutoJoinStory = false,
        StoryStageSelected = "",
        StoryActSelected = "",
        StoryDifficultySelected = false,
        SelectedStoryStageName = "",
        SelectedStoryStageIndex = "",


        AutoJoinLegendStage = false,
        SelectedLegendStageIndex = "",
        SelectedLegendStageName = "",
        LegendActSelected = "",
        LegendDifficultySelected = false,

        AutoJoinRaid = false,
        SelectedRaidStageName = "",
        SelectedRaidStageIndex = "",
        RaidActSelected = "",
        RaidDifficultySelected = false,

        AutoJoinChallenge = false,
        IgnoreWorlds = {},
        ReturnToLobbyOnNewChallenge = false,

    }
    local lastChallengeResetTime = 0
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

    local function enableAutoMatchRewards()
    if Services.ReplicatedStorage:FindFirstChild("MainSharedFolder") then
        local success = pcall(function()
            Services.ReplicatedStorage:FindFirstChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Auto Match Rewards",true)
        end)
    end
end

local function disableModuleScripts()
    if game:GetService("ReplicatedStorage").MainSharedFolder.Packages.Webhook then
    game:GetService("ReplicatedStorage").MainSharedFolder.Packages.Webhook:Destroy()
    end
end

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
                    
                    recordingHasStarted = true
                    gameStartTime = tick()
                    
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

    local function setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()

   notify("Auto Join", action)
end

 local function clearProcessingState()
        AutoJoinState.isProcessing = false
        AutoJoinState.currentAction = nil
    end

local function getCurrentChallengeData(challengeType)
    if not ChallengeModule then
        warn("ChallengeModule not loaded")
        return nil
    end
    
    local challengeData = ChallengeModule:GetChallenge(challengeType)
    
    if not challengeData then
        return nil
    end
    
    -- Get the world/map name
    local worldName = "Unknown"
    if WorldsModule and WorldsModule.Maps then
        local worldInfo = WorldsModule.Maps[challengeData.WorldNumber]
        if worldInfo then
            worldName = worldInfo.Name
        end
    end
    
    -- Get the modifier name
    local modifierName = "Unknown"
    if ChallengeModule.Modifiers and ChallengeModule.Modifiers[challengeData.Modifier] then
        modifierName = ChallengeModule.Modifiers[challengeData.Modifier].Name
    end
    
    return {
        Type = challengeData.Type,
        WorldNumber = challengeData.WorldNumber,
        WorldName = worldName,
        Chapter = challengeData.Chapter,
        Modifier = modifierName,
        ModifierIndex = challengeData.Modifier,
        Rewards = challengeData.Rewards[challengeData.Chapter] or {},
        GUID = challengeData.GUID,
        RawData = challengeData
    }
end

local function get15MinuteChallenge()
    return getCurrentChallengeData("15-Minutes")
end

local function get30MinuteChallenge()
    return getCurrentChallengeData("30-Minutes")
end

local function getDailyChallenge()
    return getCurrentChallengeData("Daily")
end

local function getWeeklyChallenge()
    return getCurrentChallengeData("Weekly")
end

local function checkChallengeResetTime()
    local currentTime = os.time()
    local currentDate = os.date("!*t", currentTime) -- UTC time
    
    -- Check if we just passed a reset time (within first 10 seconds)
    local isResetTime = false
    
    for _, challengeName in ipairs(State.SelectedChallenges) do
        if challengeName == "15 Minute" then
            -- 15-minute challenges reset at :00, :15, :30, :45
            isResetTime = (currentDate.min == 0 or currentDate.min == 15 or currentDate.min == 30 or currentDate.min == 45) and currentDate.sec < 10
            if isResetTime then break end
        elseif challengeName == "30 Minute" then
            -- 30-minute challenges reset at :00, :30
            isResetTime = (currentDate.min == 0 or currentDate.min == 30) and currentDate.sec < 10
            if isResetTime then break end
        end
    end
    
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
                
                for _, challengeName in ipairs(State.SelectedChallenges) do
                    local challenge = nil
                    
                    if challengeName == "15 Minute" then
                        challenge = get15MinuteChallenge()
                    elseif challengeName == "30 Minute" then
                        challenge = get30MinuteChallenge()
                    elseif challengeName == "Daily" then
                        challenge = getDailyChallenge()
                    elseif challengeName == "Weekly" then
                        challenge = getWeeklyChallenge()
                    end
                    
                    if challenge then
                        notify("Challenge System", string.format("New %s challenge: %s", challengeName, challenge.WorldName))
                        print(string.format("New %s challenge details:", challengeName))
                        print("  Map:", challenge.WorldName)
                        print("  Chapter:", challenge.Chapter)
                        print("  Modifier:", challenge.Modifier)
                    end
                end
            end)
            
            notify("Challenge Reset", string.format("Challenge reset detected at %02d:%02d UTC", currentDate.hour, currentDate.min))
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if State.ReturnToLobbyOnNewChallenge and State.AutoJoinChallenge and State.SelectedChallenges and #State.SelectedChallenges > 0 then
            checkChallengeResetTime()
        end
    end
end)

    local function joinChallenge()
    if not State.SelectedChallenges or #State.SelectedChallenges == 0 then
        print("No challenges selected")
        return false
    end
    
    -- Map user-friendly names to challenge types and their AreaNumbers
    local challengeTypeMap = {
        ["15 Minute"] = {type = "15-Minutes", areaNumber = 1},
        ["30 Minute"] = {type = "30-Minutes", areaNumber = 6},
        ["Daily"] = {type = "Daily", areaNumber = 7},
        ["Weekly"] = {type = "Weekly", areaNumber = 8}
    }
    
    -- Check each selected challenge in priority order
    for _, selectedName in ipairs(State.SelectedChallenges) do
        local challengeInfo = challengeTypeMap[selectedName]
        
        if challengeInfo then
            local challengeData = getCurrentChallengeData(challengeInfo.type)
            
            if challengeData then
                print(string.format("=== %s CHALLENGE ===", selectedName:upper()))
                print("Map:", challengeData.WorldName)
                print("Chapter:", challengeData.Chapter)
                print("Modifier:", challengeData.Modifier)
                print("AreaNumber:", challengeInfo.areaNumber)
                
                -- Check if we should ignore this world
                local shouldIgnore = false
                if State.IgnoreWorlds then
                    for _, ignoredWorld in ipairs(State.IgnoreWorlds) do
                        if challengeData.WorldName == ignoredWorld then
                            shouldIgnore = true
                            print(string.format("Skipping %s challenge (world: %s is ignored)", selectedName, challengeData.WorldName))
                            break
                        end
                    end
                end
                
                if shouldIgnore then
                    continue -- Try next challenge
                end
                
                -- Attempt to join this challenge with the correct AreaNumber
                print(string.format("Attempting to join %s challenge with AreaNumber %d...", selectedName, challengeInfo.areaNumber))
                
                local success = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("LobbyFolder"):WaitForChild("Remotes"):WaitForChild("Play"):FireServer("Join",{AreaType = "Challenge",AreaNumber = challengeInfo.areaNumber})
                end)
                
                if success then
                    notify("Challenge Joiner", string.format("Joining %s challenge: %s (Ch.%d, %s)", 
                        selectedName, challengeData.WorldName, challengeData.Chapter, challengeData.Modifier))
                    return true
                else
                    warn(string.format("Failed to join %s challenge", selectedName))
                end
            else
                warn(string.format("Could not get data for %s challenge", selectedName))
            end
        end
    end
    
    print("No suitable challenges found")
    return false
end

local function canPerformAction()
        return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
    end

    local function checkAndExecuteHighestPriority()
        if not isInLobby() then return end
        if AutoJoinState.isProcessing then return end
        if not canPerformAction() then return end

        if State.AutoJoinChallenge and State.SelectedChallenges and #State.SelectedChallenges > 0 then
        setProcessingState("Challenge Auto Join")
        
        local joinSuccess = joinChallenge()
        
        if joinSuccess then
            print("Successfully initiated challenge join!")
            task.delay(5, clearProcessingState)
            return
        else
            print("Challenge join failed - falling through to other options")
            clearProcessingState()
            -- Don't return - let it fall through to next priority
        end
    end

        -- STORY
        if State.AutoJoinStory and State.SelectedStoryStageIndex and State.StoryActSelected then
            setProcessingState("Story Auto Join")

            game:GetService("ReplicatedStorage"):WaitForChild("LobbyFolder"):WaitForChild("Remotes"):WaitForChild("Play"):FireServer("Join",{AreaType = "Story",AreaNumber = 4})
            game:GetService("ReplicatedStorage"):WaitForChild("LobbyFolder"):WaitForChild("Remotes"):WaitForChild("Play"):FireServer("Update",{Chapter = tonumber(State.StoryActSelected),Ultramode = false,Hardmode = State.StoryDifficultySelected,Owner = game:GetService("Players"):WaitForChild(Services.Players.LocalPlayer.Name),FriendsOnly = false,WorldNumber = State.SelectedStoryStageIndex,AreaType = "Story",Timer = 27,AreaNumber = 4,Players = {}})


            task.delay(5, clearProcessingState)
            return
        end

          if State.AutoJoinLegendStage and State.SelectedLegendStageIndex and State.LegendActSelected then
            setProcessingState("Ultra Stage Auto Join")

            game:GetService("ReplicatedStorage"):WaitForChild("LobbyFolder"):WaitForChild("Remotes"):WaitForChild("Play"):FireServer("Join",{AreaType = "Story",AreaNumber = 4})
            game:GetService("ReplicatedStorage"):WaitForChild("LobbyFolder"):WaitForChild("Remotes"):WaitForChild("Play"):FireServer("Update",{Chapter = tonumber(State.LegendActSelected),Ultramode = true,Hardmode = State.LegendDifficultySelected,Owner = game:GetService("Players"):WaitForChild(Services.Players.LocalPlayer.Name),FriendsOnly = false,WorldNumber = State.SelectedLegendStageIndex,AreaType = "Story",Timer = 27,AreaNumber = 4,Players = {}})


            task.delay(5, clearProcessingState)
            return
        end

        if State.AutoJoinRaid and State.SelectedRaidStageIndex and State.RaidActSelected then
            setProcessingState("Raid Auto Join")
            game:GetService("ReplicatedStorage"):WaitForChild("LobbyFolder"):WaitForChild("Remotes"):WaitForChild("Play"):FireServer("Join",{AreaType = "Raid",AreaNumber = 1})
            game:GetService("ReplicatedStorage"):WaitForChild("LobbyFolder"):WaitForChild("Remotes"):WaitForChild("Play"):FireServer("Update",{Chapter = tostring(State.RaidActSelected),Ultramode = false,Hardmode = State.RaidDifficultySelected,Owner = game:GetService("Players"):WaitForChild(Services.Players.LocalPlayer.Name),FriendsOnly = false,WorldNumber = State.SelectedRaidStageIndex,AreaType = "Raid",Timer = 1,AreaNumber = 1,Players = {}})

            task.delay(5, clearProcessingState)
            return
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
    
    print("=== SEARCHING FOR PLACED UNIT ===")
    print(string.format("Target Position: (%.1f, %.1f, %.1f)", targetCFrame.Position.X, targetCFrame.Position.Y, targetCFrame.Position.Z))
    print(string.format("Tolerance: %d studs", tolerance))
    
    local unitReplicas = getUnitReplicaFolder()
    if not unitReplicas then 
        warn("❌ No unit replicas found!")
        return nil, nil 
    end
    
    local unitsFolder = Services.Workspace:FindFirstChild("Map")
    if unitsFolder then
        unitsFolder = unitsFolder:FindFirstChild("Units")
    end
    
    if not unitsFolder then
        warn("⚠️ workspace.Map.Units folder not found!")
        return nil, nil
    end
    
    print(string.format("📊 Total unit replicas: %d", #unitReplicas))
    print(string.format("📊 Total models in Units folder: %d", #unitsFolder:GetChildren()))
    
    local candidates = {}
    local checkedReplicas = 0
    
    -- Go through all unit replicas
    for _, unitReplica in pairs(unitReplicas) do
        local unitID = unitReplica.Id
        local unitName = unitReplica.Data.Name
        
        -- Skip if already mapped or excluded
        if excludeUnitIDs[unitID] then
            print(string.format("  ⏭️ Skipping excluded unit: %s (ID=%d)", unitName, unitID))
            continue
        end
        
        checkedReplicas = checkedReplicas + 1
        print(string.format("  🔍 Checking replica: %s (ID=%d)", unitName, unitID))
        
        -- Search for models that match this unit
        local foundModel = false
        for _, unitModel in pairs(unitsFolder:GetChildren()) do
            if unitModel:IsA("Model") then
                local modelName = unitModel.Name
                
                -- Try exact match first
                if modelName == unitName then
                    local unitCFrame = unitModel:GetPivot()
                    local distance = (unitCFrame.Position - targetCFrame.Position).Magnitude
                    
                    print(string.format("    ✓ Model match: '%s' at (%.1f, %.1f, %.1f), distance: %.2f", 
                        modelName, unitCFrame.Position.X, unitCFrame.Position.Y, unitCFrame.Position.Z, distance))
                    
                    if distance <= tolerance then
                        table.insert(candidates, {
                            unitID = unitID,
                            unitName = unitName,
                            distance = distance
                        })
                        print(string.format("      ✅ CANDIDATE ADDED! (within tolerance)"))
                        foundModel = true
                        break
                    else
                        print(string.format("      ❌ Too far (tolerance: %d)", tolerance))
                    end
                end
            end
        end
        
        if not foundModel then
            print(string.format("    ❌ No matching model found for: %s", unitName))
        end
    end
    
    print(string.format("📊 Checked %d replicas, found %d candidates", checkedReplicas, #candidates))
    
    if #candidates == 0 then 
        print("❌ No candidates found!")
        print("🔍 Let me show you what models ARE near the target position:")
        
        for _, unitModel in pairs(unitsFolder:GetChildren()) do
            if unitModel:IsA("Model") then
                local unitCFrame = unitModel:GetPivot()
                local distance = (unitCFrame.Position - targetCFrame.Position).Magnitude
                
                if distance <= tolerance * 2 then -- Check double the tolerance
                    print(string.format("  📍 Nearby model: '%s' at distance %.2f", unitModel.Name, distance))
                end
            end
        end
        
        return nil, nil 
    end
    
    -- Return the closest match
    table.sort(candidates, function(a, b) return a.distance < b.distance end)
    
    print(string.format("✅ Selected: %s (ID=%d, distance=%.2f)", candidates[1].unitName, candidates[1].unitID, candidates[1].distance))
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
    
    print(string.format("👀 Started tracking upgrades for %s (ID=%d, StartLevel=%d)", unitTag, unitID, currentLevel))
    
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
        
        print(string.format("🔔 Level change detected: %s (ID=%d) L%d->L%d", unitTag, unitID, lastLevel, newLevel))
        
        -- Check if level actually increased
        if newLevel > lastLevel then
            -- FIXED: Find ALL matching pending upgrades for this unit ID
            local matchingPendings = {}
            
            for i, pending in ipairs(pendingUpgrades) do
                if pending.unitID == unitID and not pending.validated then
                    table.insert(matchingPendings, {index = i, pending = pending})
                end
            end
            
            if #matchingPendings > 0 then
                -- Calculate total upgrade amount
                local totalUpgrades = newLevel - lastLevel
                
                print(string.format("  Found %d pending upgrade(s), total levels gained: %d", #matchingPendings, totalUpgrades))
                
                -- OPTION 1: Record as single multi-upgrade
                if #matchingPendings > 1 then
                    -- Use the FIRST pending upgrade's timestamp
                    local firstPending = matchingPendings[1].pending
                    local gameRelativeTime = firstPending.timestamp - gameStartTime
                    
                    local record = {
                        Type = "upgrade_unit",
                        Unit = firstPending.unitTag,
                        Time = string.format("%.2f", gameRelativeTime),
                        Amount = totalUpgrades
                    }
                    
                    local totalCost = calculateTotalUpgradeCost(firstPending.unitName, lastLevel, totalUpgrades)
                    if totalCost then
                        record.UpgradeCost = totalCost
                    end
                    
                    table.insert(macro, record)
                    print(string.format("✅ Recorded multi-upgrade: %s (L%d->L%d, Cost=%d)", 
                        firstPending.unitTag, lastLevel, newLevel, record.UpgradeCost or 0))
                    
                    -- Mark all as validated
                    for _, item in ipairs(matchingPendings) do
                        pendingUpgrades[item.index].validated = true
                    end
                    
                else
                    -- Single upgrade
                    local pending = matchingPendings[1].pending
                    local gameRelativeTime = pending.timestamp - gameStartTime
                    
                    local record = {
                        Type = "upgrade_unit",
                        Unit = pending.unitTag,
                        Time = string.format("%.2f", gameRelativeTime)
                    }
                    
                    if pending.upgradeCost then
                        record.UpgradeCost = pending.upgradeCost
                    end
                    
                    table.insert(macro, record)
                    print(string.format("✅ Recorded upgrade: %s (L%d->L%d, Cost=%d)", 
                        pending.unitTag, lastLevel, newLevel, record.UpgradeCost or 0))
                    
                    pendingUpgrades[matchingPendings[1].index].validated = true
                end
                
            else
                -- NO PENDING UPGRADES - This shouldn't happen anymore
                print(string.format("⚠️ Level increased but no pending upgrades found for %s", unitTag))
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
                
                -- ✅ Capture immediately
                local capturedUUID = tostring(uuid)
                local capturedPosition = cframe.Position
                local capturedCFrame = CFrame.new(capturedPosition.X, capturedPosition.Y, capturedPosition.Z)
                
                print(string.format("📝 Placement detected at (%.1f, %.1f, %.1f)", 
                    capturedPosition.X, capturedPosition.Y, capturedPosition.Z))
                
                -- ✅ STEP 1: Find the UnitCircle at the placement position
                local unitsFolder = Services.Workspace:FindFirstChild("Map")
                if unitsFolder then
                    unitsFolder = unitsFolder:FindFirstChild("Units")
                end
                
                if not unitsFolder then
                    warn("❌ No Units folder!")
                    return
                end
                
                local unitCircle = nil
                local maxAttempts = 20
                
                for attempt = 1, maxAttempts do
                    task.wait(0.2)
                    
                    -- Search for UnitCircle near placement position
                    for _, obj in pairs(unitsFolder:GetChildren()) do
                        if obj.Name == "UnitCircle" and obj:IsA("BasePart") then
                            local distance = (obj.Position - capturedPosition).Magnitude
                            
                            if distance <= 5 then -- UnitCircle should be very close
                                unitCircle = obj
                                print(string.format("✅ Found UnitCircle at distance %.2f", distance))
                                break
                            end
                        end
                    end
                    
                    if unitCircle then break end
                end
                
                if not unitCircle then
                    warn("❌ Failed to find UnitCircle!")
                    return
                end
                
                -- ✅ STEP 2: Now find the actual unit model near this UnitCircle
                local excludeIDs = {}
                for mappedUnitID, _ in pairs(recordingUnitIDToTag) do
                    excludeIDs[mappedUnitID] = true
                end
                
                -- Use the UnitCircle's position to search for the unit
                local unitCirclePos = unitCircle.Position
                local searchCFrame = CFrame.new(unitCirclePos)
                
                local unitID, unitName = nil, nil
                
                for attempt = 1, 15 do
                    task.wait(0.3)
                    unitID, unitName = findLatestPlacedUnit(searchCFrame, 10, excludeIDs)
                    if unitID then break end
                end
                
                if unitID and unitName then
                    -- Check if already mapped (shouldn't happen but safety check)
                    if recordingUnitIDToTag[unitID] then
                        warn(string.format("⚠️ Unit ID %d already mapped! Skipping.", unitID))
                        return
                    end
                    
                    -- Increment counter for this unit type
                    recordingUnitCounter[unitName] = (recordingUnitCounter[unitName] or 0) + 1
                    local unitNumber = recordingUnitCounter[unitName]
                    local unitTag = string.format("%s #%d", unitName, unitNumber)
                    
                    -- Track this unit
                    recordingUnitIDToTag[unitID] = unitTag
                    
                    local placementCost = getUnitPlacementCost(unitName)
                    
                    -- Record to macro using ORIGINAL captured position
                    local record = {
                        Type = "spawn_unit",
                        Unit = unitTag,
                        UUID = capturedUUID,
                        Time = string.format("%.2f", gameRelativeTime),
                        Position = {capturedPosition.X, capturedPosition.Y, capturedPosition.Z}
                    }
                    
                    if placementCost then
                        record.PlacementCost = placementCost
                    end
                    
                    table.insert(macro, record)
                    
                    -- START TRACKING UPGRADES
                    startTrackingUnitUpgrades(unitID, unitTag, unitName)
                    
                    print(string.format("✓ Recorded: %s (ID=%d, Cost=%d)", 
                        unitTag, unitID, placementCost or 0))
                else
                    warn("❌ Failed to find unit model near UnitCircle!")
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
                    
                    -- Add pending upgrade
                    local pendingUpgrade = {
                        unitID = unitID,
                        unitTag = unitTag,
                        unitName = unitName,
                        startLevel = currentLevel,
                        expectedEndLevel = currentLevel + 1,
                        upgradeCost = upgradeCost,
                        timestamp = timestamp,
                        validated = false
                    }
                    
                    table.insert(pendingUpgrades, pendingUpgrade)
                    
                    print(string.format("⏳ Upgrade fired: %s (ID=%d, L%d->L%d, Cost=%d) [Pending #%d]", 
                        unitTag, unitID, currentLevel, currentLevel + 1, upgradeCost or 0, #pendingUpgrades))
                    
                elseif action == "Sell" then
                    table.insert(macro, {
                        Type = "sell_unit",
                        Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                    
                    print(string.format("✓ Recorded sell: %s (ID=%d)", unitTag, unitID))
                    
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
        task.wait(1.0) -- Check every second
        
        if isRecording and recordingHasStarted then
            local currentTime = tick()
            local cleaned = 0
            
            -- Remove validated or expired upgrades
            for i = #pendingUpgrades, 1, -1 do
                local pending = pendingUpgrades[i]
                local age = currentTime - pending.timestamp
                
                -- Remove if validated OR too old (5 seconds)
                if pending.validated or age > 5.0 then
                    if not pending.validated then
                        print(string.format("🧹 Removing expired pending: %s (age: %.2fs)", 
                            pending.unitTag, age))
                    end
                    table.remove(pendingUpgrades, i)
                    cleaned = cleaned + 1
                end
            end
            
            if cleaned > 0 then
                print(string.format("🧹 Cleaned %d pending upgrade(s), %d remaining", cleaned, #pendingUpgrades))
            end
        else
            -- Clear all pending when not recording
            if #pendingUpgrades > 0 then
                print(string.format("🧹 Clearing %d pending upgrades (not recording)", #pendingUpgrades))
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
        hasSentWebhook = false
        print("hassentwebhook is false")
        
        print("✓ GAME STARTED - Tracking initialized")
        
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

local function captureGameRewards()
    local rewards = {}
    
    print("🔍 Starting reward capture...")
    
    local success, err = pcall(function()
        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
        local rewardsFrame = playerGui.DefenseScreenFolder.WaveEndScreen.WaveEnd.Rewards
        
        print("📁 Rewards frame found, checking children...")
        
        -- Wait for rewards to populate
        local maxWait = 5
        local waited = 0
        
        while waited < maxWait do
            local childCount = 0
            for _, child in ipairs(rewardsFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "UIListLayout" then
                    childCount = childCount + 1
                end
            end
            
            print(string.format("Found %d reward frames", childCount))
            
            if childCount > 0 then
                break
            end
            
            task.wait(0.5)
            waited = waited + 0.5
        end
        
        -- Capture rewards
        for _, rewardFrame in ipairs(rewardsFrame:GetChildren()) do
            if rewardFrame:IsA("Frame") and rewardFrame.Name ~= "UIListLayout" then
                print(string.format("Processing reward frame: %s", rewardFrame.Name))
                
                local button = rewardFrame:FindFirstChild("Button")
                
                if button then
                    local quantityLabel = button:FindFirstChild("Quantity")
                    local titleLabel = button:FindFirstChild("Title")
                    
                    if quantityLabel and titleLabel then
                        local rewardType = titleLabel.Text or "Unknown"
                        local rewardAmount = quantityLabel.Text or "0"
                        
                        print(string.format("  Raw values - Type: '%s', Amount: '%s'", rewardType, rewardAmount))
                        
                        -- ✅ More robust cleaning
                        local cleanAmount = 0
                        
                        -- Try to extract just the numbers
                        local numberStr = tostring(rewardAmount):gsub("[^%d]", "")
                        
                        if numberStr ~= "" then
                            cleanAmount = tonumber(numberStr) or 0
                        end
                        
                        print(string.format("  Cleaned amount: %d", cleanAmount))
                        
                        if cleanAmount > 0 then
                            rewards[rewardType] = cleanAmount
                            print(string.format("✅ Captured: %s = %d", rewardType, cleanAmount))
                        else
                            print(string.format("⚠️ Skipped %s (amount was 0 or invalid)", rewardType))
                        end
                    else
                        print(string.format("  Missing Quantity or Title in %s", rewardFrame.Name))
                        if quantityLabel then print("    Has Quantity") end
                        if titleLabel then print("    Has Title") end
                    end
                else
                    print(string.format("  No Button found in %s", rewardFrame.Name))
                end
            end
        end
    end)
    
    if not success then
        warn("❌ Error capturing rewards:", err)
        return {}
    end
    
    if next(rewards) == nil then
        warn("⚠️ No rewards captured - rewards table is empty")
    else
        print(string.format("✅ Successfully captured %d reward types", 
            (function()
                local count = 0
                for _ in pairs(rewards) do count = count + 1 end
                return count
            end)()))
    end
    
    return rewards
end

local function captureGameInfo()
    local gameInfo = {
        Act = nil,
        Map = nil,
        Mode = nil,
        Duration = nil
    }
    
    local success = pcall(function()
        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
        local waveEnd = playerGui.DefenseScreenFolder.WaveEndScreen.WaveEnd
        
        -- Capture game info
        local infoFrame = waveEnd.Info
        
        -- Capture Act
        local actLabel = infoFrame:FindFirstChild("Act")
        if actLabel and actLabel:IsA("TextLabel") then
            gameInfo.Act = actLabel.Text
        end
        
        -- Capture Map
        local mapLabel = infoFrame:FindFirstChild("Map")
        if mapLabel and mapLabel:IsA("TextLabel") then
            gameInfo.Map = mapLabel.Text
        end
        
        -- Capture Mode
        local modeLabel = infoFrame:FindFirstChild("Mode")
        if modeLabel and modeLabel:IsA("TextLabel") then
            gameInfo.Mode = modeLabel.Text
        end
        
        -- ✅ Capture Duration from UI
        local statsFrame = waveEnd:FindFirstChild("Stats")
        if statsFrame then
            local playTime = statsFrame:FindFirstChild("PlayTime")
            if playTime then
                local valueLabel = playTime:FindFirstChild("Value")
                if valueLabel and valueLabel:IsA("TextLabel") then
                    gameInfo.Duration = valueLabel.Text
                    print(string.format("✅ Captured duration from UI: %s", gameInfo.Duration))
                end
            end
        end
    end)
    
    if not success then
        warn("⚠️ Failed to capture game info")
    end
    
    return gameInfo
end

local function sendWebhook(messageType, rewards, gameResult, gameInfo, gameDuration)
    if not ValidWebhook or ValidWebhook == "" then
        return
    end

    local data

    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or ""),
            embeds = {{
                title = "LixHub Notification",
                description = "Test webhook sent successfully",
                color = 0x5865F2,
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }

    elseif messageType == "game_end" then
        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        
        -- FIX: Format duration properly
        
        -- FIX: Format rewards text properly
        local rewardsText = ""
        
        if next(rewards) then
            for rewardType, amount in pairs(rewards) do
                rewardsText = rewardsText .. string.format("+%s %s\n", amount, rewardType)
            end
            rewardsText = rewardsText:gsub("\n$", "") -- Remove trailing newline
        else
            rewardsText = "No rewards obtained"
        end
        
        -- Determine title and color based on game result
        local titleText = gameResult and "Stage Completed!" or "Stage Failed!"
        local embedColor = gameResult and 0x57F287 or 0xED4245
        
        -- Build description with game info
        local TitleSubText = "Unknown Stage"
        if gameInfo and gameInfo.Act and gameInfo.Map and gameInfo.Mode then
            local resultText = gameResult and "Victory" or "Defeat"
            TitleSubText = string.format("%s %s (%s) - %s", gameInfo.Map, gameInfo.Act, gameInfo.Mode, resultText)
        end
        
        local currentWave = WaveManager and WaveManager.Data.Wave or lastWave or 0
        
        -- Build fields array
        local fields = {
            { name = "Player", value = playerName, inline = true },
            { name = "Duration", value = gameDuration, inline = true },
            { name = "Waves Completed", value = tostring(currentWave), inline = true },
            { name = "Rewards", value = rewardsText, inline = false },
        }
        
        data = {
            username = "LixHub",
            embeds = {{
                title = titleText,
                description = TitleSubText,
                color = embedColor,
                fields = fields,
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = timestamp
            }}
        }
    end
    
    local payload = Services.HttpService:JSONEncode(data)
    
    local requestFunc = syn and syn.request or request or http_request or 
                      (fluxus and fluxus.request) or getgenv().request
    
    if not requestFunc then
        warn("No HTTP function found! Your executor might not support HTTP requests.")
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
        notify("Webhook", "Webhook successfully sent!")
    else
        warn("Webhook failed:", response and response.StatusCode or "No response")
    end
end
    if game.PlaceId ~= 17899227840 then
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
end
    task.spawn(function()
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local defenseScreenFolder = playerGui:WaitForChild("DefenseScreenFolder")
    
    while true do
        while hasSentWebhook do
            task.wait(1)
        end
        -- Wait for WaveEndScreen to be created
        local waveEndScreen = defenseScreenFolder:WaitForChild("WaveEndScreen")
        
        -- Wait for it to become visible
        local waveEnd = waveEndScreen:WaitForChild("WaveEnd")
        
        local function waitForVisible()
            while not waveEnd.Visible do
                task.wait(0.1)
            end
        end
        
        waitForVisible()
        
        -- Game just ended!
        print("Game ended - WaveEndScreen is now visible")
        
        task.wait(2) -- Delay to ensure UI is fully ready

        local rewards = captureGameRewards()
        local gameInfo = captureGameInfo()
        lastGameRewards = rewards
        local gameResult = false

        local gameDuration = gameInfo.Duration or "00:00"

local success = pcall(function()
    local winFrame = waveEnd:FindFirstChild("Win")
    local lostFrame = waveEnd:FindFirstChild("Lost")
    
    if winFrame and winFrame.Visible then
        gameResult = true
    elseif lostFrame and lostFrame.Visible then
        gameResult = false
    end
end)

if not success then
    warn("⚠️ Failed to determine game result, defaulting to defeat")
end
        sendWebhook("game_end", rewards, gameResult, gameInfo, gameDuration)
        hasSentWebhook = true
        print("hassentwebhook is true")

        task.wait(0.5)

        if State.NewChallengeDetected then
            print("New challenge detected during game - Returning to lobby...")
            local success = pcall(function()
                local lobbyButton = waveEnd.Buttons:FindFirstChild("Lobby")
                
                if lobbyButton then
                    for _, connection in pairs(getconnections(lobbyButton.Activated)) do
                        connection:Fire()
                    end
                end
            end)
            
            if success then
                notify("New Challenge", "Returning to lobby for new challenge...", 3)
                
                -- Reset game state
                gameInProgress = false
                gameStartTime = 0
                clearSpawnIdMappings()
                
                -- Reset flag after using it
                State.NewChallengeDetected = false
            end
        end

        if State.ChallengeBug then
    print("Secret Feature enabled - Clicking Restart...")
    local success = pcall(function()
        local settingsFrame = LocalPlayer.PlayerGui.MainScreenFolder.SharedSideScreen.Frames.SettingsFrame.Selected.Scroll
        
        -- Search for the Match frame with "Restart" title
        for _, frame in ipairs(settingsFrame:GetChildren()) do
            if frame.Name == "Match" and frame:IsA("Frame") then
                local title = frame:FindFirstChild("Title")
                if title and title:IsA("TextLabel") and title.Text:find("Restart") then
                    local actionButton = frame:FindFirstChild("Action")
                    if actionButton and actionButton:IsA("ImageButton") then
                        for _, connection in pairs(getconnections(actionButton.MouseButton1Down)) do
                            connection:Fire()
                        end
                    end
                end
            end
        end
    end)
    if success then
        notify("Secret Feature", "Restarting match...", 3)
        
        -- Reset game state immediately
        gameInProgress = false
        gameStartTime = 0
        clearSpawnIdMappings()
        
        if isPlaybacking and isAutoLoopEnabled then
            updateMacroStatus("Secret Feature - Waiting for next game...")
            updateDetailedStatus("Match restarted - waiting for wave 1...")
        end
    end
end
        
        if State.AutoRetry then
            print("Auto Retry enabled - Clicking Replay...")
            local success = pcall(function()
                local replayButton = waveEnd.Buttons:FindFirstChild("Replay")
                
                if replayButton then
                    for _, connection in pairs(getconnections(replayButton.Activated)) do
                        connection:Fire()
                    end
                end
            end)
            
            if success then
                notify("Auto Retry", "Replaying...", 3)
                
                -- Reset game state immediately
                gameInProgress = false
                gameStartTime = 0
                clearSpawnIdMappings()
                
                if isPlaybacking and isAutoLoopEnabled then
                    updateMacroStatus("Auto Retry - Waiting for next game...")
                    updateDetailedStatus("Game restarted - waiting for wave 1...")
                end
            end
            
        -- Priority 2: Auto Next
        elseif State.AutoNext then
            print("Auto Next enabled - Clicking Next...")
            local success = pcall(function()
                local nextButton = waveEnd.Buttons:FindFirstChild("Next")
                
                if nextButton then
                    for _, connection in pairs(getconnections(nextButton.Activated)) do
                        connection:Fire()
                    end
                end
            end)
            
            if success then
                notify("Auto Next", "Going to next level...", 3)
                
                -- Reset game state
                gameInProgress = false
                gameStartTime = 0
                clearSpawnIdMappings()
            end
            
        -- Priority 3: Auto Lobby (lowest priority)
        elseif State.AutoLobby then
            print("Auto Lobby enabled - Clicking Lobby...")
            local success = pcall(function()
                local lobbyButton = waveEnd.Buttons:FindFirstChild("Lobby")
                
                if lobbyButton then
                    for _, connection in pairs(getconnections(lobbyButton.Activated)) do
                        connection:Fire()
                    end
                end
            end)
            
            if success then
                notify("Auto Lobby", "Returning to lobby...", 3)
                
                -- Reset game state
                gameInProgress = false
                gameStartTime = 0
                clearSpawnIdMappings()
            end
        end
    end
end)

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
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Disable VFX",true)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Disable Damage Indicators",true)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Disable Synergy Effect",true)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Image Replacement",true)
    else
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Disable VFX",false)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Disable Damage Indicators",false)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Disable Synergy Effect",false)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Image Replacement",false)
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

Toggle = GameTab:CreateToggle({
    Name = "Low Performance Mode",
    CurrentValue = false,
    Flag = "enableLowPerformanceMode",
    Callback = function(Value)
        State.enableLowPerformanceMode = Value
        enableLowPerformanceMode()
    end,
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

local function getWorldIndexByName(worldName)
    local success, result = pcall(function()
        local WorldsModule = require(Services.ReplicatedStorage.MainSharedFolder.Modules.InfoModule.Worlds)
        
        if not WorldsModule or not WorldsModule.Maps then
            return nil
        end
        
        -- Find the index of the world in the Maps array
        for index, worldInfo in ipairs(WorldsModule.Maps) do
            if worldInfo.Name == worldName then
                return index
            end
        end
        
        return nil
    end)
    
    if success and result then
        return result
    else
        warn("Failed to get world index for:", worldName)
        return nil
    end
end

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
    Name = "Story Stage",
    Options = {},
    CurrentOption = {},
    Flag = "StoryStageSelector",
    Callback = function(Option)
        local worldIndex = getWorldIndexByName(Option[1])
        if worldIndex then
            State.SelectedStoryStageIndex = worldIndex
            State.SelectedStoryStageName = Option[1]
            print(string.format("Selected story stage: %s (Index: %d)", Option[1], worldIndex))
        else
            warn("Could not find index for selected world:", Option[1])
        end
    end,
})

     ChapterDropdown869 = JoinerTab:CreateDropdown({
        Name = "Select Story Chapter",
        Options = {"Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6", "Infinite"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "StoryActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            if selectedOption == "Infinite" then
                State.StoryActSelected = "7"
            else
                local num = selectedOption:match("%d+")
                if num then
                    State.StoryActSelected = num
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
            if Option[1] == "Normal" then
                State.StoryDifficultySelected = false
            elseif Option[1] == "Hard" then
                State.StoryDifficultySelected = true
            end
            print("Selected "..Option[1])
        end,
    })

    section = JoinerTab:CreateSection("Ultra Stage Joiner")

    AutoJoinLegendToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Ultra Stage",
        CurrentValue = false,
        Flag = "AutoJoinLegend",
        Callback = function(Value)
            State.AutoJoinLegendStage = Value
        end,
    })

local LegendStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Ultra Stage",
    Options = {},
    CurrentOption = {},
    Flag = "LegendStageSelector",
    Callback = function(Option)
        local worldIndex = getWorldIndexByName(Option[1])
        if worldIndex then
            State.SelectedLegendStageIndex = worldIndex
            State.SelectedLegendStageName = Option[1]
            print(string.format("Selected legend stage: %s (Index: %d)", Option[1], worldIndex))
        else
            warn("Could not find index for selected world:", Option[1])
        end
    end,
})

    LegendChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Ultra Stage Chapter",
        Options = {"Chapter 1", "Chapter 2", "Chapter 3"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "LegendActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            
            local num = selectedOption:match("%d+")
            if num then
                State.LegendActSelected = num
            end
        end,
    })

         ChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Ultra Stage Difficulty",
        Options = {"Normal","Hard"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "LegendDifficultySelector",
        Callback = function(Option)
            if Option[1] == "Normal" then
                State.LegendDifficultySelected = false
            elseif Option[1] == "Hard" then
                State.LegendDifficultySelected = true
            end
            print("Selected "..Option[1])
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
    Flag = "RaidStageSelector",
    Callback = function(Option)
        local worldIndex = getWorldIndexByName(Option[1])
        if worldIndex then
            State.SelectedRaidStageIndex = worldIndex
            State.SelectedRaidStageName = Option[1]
            print(string.format("Selected raid stage: %s (Index: %d)", Option[1], worldIndex))
        else
            warn("Could not find index for selected world:", Option[1])
        end
    end,
})

    RaidChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Raid Stage Chapter",
        Options = {"Chapter 1", "Chapter 2", "Chapter 3","Chapter 4","Chapter 5","Chapter 6"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "RaidActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            
            local num = selectedOption:match("%d+")
            if num then
                State.RaidActSelected = num
            end
        end,
    })

         ChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Raid Difficulty",
        Options = {"Normal","Hard"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "RaidDifficultySelector",
        Callback = function(Option)
            if Option[1] == "Normal" then
                State.RaidDifficultySelected = false
            elseif Option[1] == "Hard" then
                State.RaidDifficultySelected = true
            end
            print("Selected "..Option[1])
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

    local ChallengeSelectionDropdown = JoinerTab:CreateDropdown({
        Name = "Select Challenge",
        Options = {"15 Minute","30 Minute","Daily","Weekly"},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "ChallengeSelectionDropdown",
        Info = "Will do all challenges that are selected",
        Callback = function(Options)
            State.SelectedChallenges = Options or {}
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
        end,
    })

    ReturnToLobbyToggle = JoinerTab:CreateToggle({
        Name = "Return to Lobby on New Challenge",
        CurrentValue = false,
        Flag = "ReturnToLobbyOnNewChallenge",
        Info = "Return to lobby when new challenge appears instead of using retry/next",
        TextScaled = true,
        Callback = function(Value)
            State.ReturnToLobbyOnNewChallenge = Value
        end,
    })

local function isGameDataLoaded()
    return Services.ReplicatedStorage:FindFirstChild("MainSharedFolder") and
        Services.ReplicatedStorage.MainSharedFolder:FindFirstChild("Modules") and
        Services.ReplicatedStorage.MainSharedFolder.Modules:FindFirstChild("InfoModule") and
        Services.ReplicatedStorage.MainSharedFolder.Modules.InfoModule:FindFirstChild("Worlds")
end

local function loadAllStoryStagesWithRetry()
    loadingRetries.story = loadingRetries.story + 1
    
    if not isGameDataLoaded() then
        if loadingRetries.story <= maxRetries then
            print(string.format("Story stages loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.story, maxRetries))
            task.wait(retryDelay)
            task.spawn(loadAllStoryStagesWithRetry)
        else
            warn("Failed to load story stages after", maxRetries, "attempts - giving up")
            StoryStageDropdown:Refresh({"Failed to load - check console"})
            LegendStageDropdown:Refresh({"Failed to load - check console"})
        end
        return
    end
    
    local success, result = pcall(function()
        local WorldsModule = require(Services.ReplicatedStorage.MainSharedFolder.Modules.InfoModule.Worlds)
        
        if not WorldsModule or not WorldsModule.Maps then
            error("WorldsModule or Maps not found")
        end

        local displayNames = {}
        
        -- Filter for non-event, non-raid stages (story stages)
        for _, worldInfo in ipairs(WorldsModule.Maps) do
            if type(worldInfo) == "table" and worldInfo.Name then
                -- Story stages are those without Event or Raid flags
                if not worldInfo.Event and not worldInfo.Raid then
                    table.insert(displayNames, worldInfo.Name)
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
        LegendStageDropdown:Refresh(result)  -- Same worlds for legend dropdown
        print(string.format("Successfully loaded %d story stages (attempt %d)", #result, loadingRetries.story))
    else
        if loadingRetries.story <= maxRetries then
            print(string.format("Story stages loading failed (attempt %d/%d): %s - retrying...", loadingRetries.story, maxRetries, tostring(result)))
            task.wait(retryDelay)
            task.spawn(loadAllStoryStagesWithRetry)
        else
            warn("Failed to load story stages after", maxRetries, "attempts:", result)
            StoryStageDropdown:Refresh({"Failed to load - check console"})
            LegendStageDropdown:Refresh({"Failed to load - check console"})
        end
    end
end

-- New function to load story stages into Ignore Worlds dropdown
local function loadIgnoreWorldsWithRetry()
    loadingRetries.ignoreWorlds = loadingRetries.ignoreWorlds or 0
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
        local WorldsModule = require(Services.ReplicatedStorage.MainSharedFolder.Modules.InfoModule.Worlds)
        
        if not WorldsModule or not WorldsModule.Maps then
            error("WorldsModule or Maps not found")
        end

        local displayNames = {}
        
        -- Filter for non-event, non-raid stages (story stages)
        for _, worldInfo in ipairs(WorldsModule.Maps) do
            if type(worldInfo) == "table" and worldInfo.Name then
                -- Story stages are those without Event or Raid flags
                if not worldInfo.Event and not worldInfo.Raid then
                    table.insert(displayNames, worldInfo.Name)
                end
            end
        end
        
        if #displayNames == 0 then
            error("No story stages found")
        end
        
        return displayNames
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

local function loadAllRaidStagesWithRetry()
    loadingRetries.raid = loadingRetries.raid + 1
    
    if not isGameDataLoaded() then
        if loadingRetries.raid <= maxRetries then
            print(string.format("Raid stages loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.raid, maxRetries))
            task.wait(retryDelay)
            task.spawn(loadAllRaidStagesWithRetry)
        else
            warn("Failed to load raid stages after", maxRetries, "attempts - giving up")
            RaidStageDropdown:Refresh({"Failed to load - check console"})
        end
        return
    end
    
    local success, result = pcall(function()
        local WorldsModule = require(Services.ReplicatedStorage.MainSharedFolder.Modules.InfoModule.Worlds)
        
        if not WorldsModule or not WorldsModule.Maps then
            error("WorldsModule or Maps not found")
        end

        local displayNames = {}
        
        -- Filter for raid stages
        for _, worldInfo in ipairs(WorldsModule.Maps) do
            if type(worldInfo) == "table" and worldInfo.Name and worldInfo.Raid then
                table.insert(displayNames, worldInfo.Name)
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
            task.spawn(loadAllRaidStagesWithRetry)
        else
            warn("Failed to load raid stages after", maxRetries, "attempts:", result)
            RaidStageDropdown:Refresh({"Failed to load - check console"})
        end
    end
end

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
    local head = Services.Players.LocalPlayer.PlayerGui.CacheOverheads[Services.Players.LocalPlayer.Name]
    if not head then return end

    local billboard = head:WaitForChild("Frame")
    if not billboard then print("no billboard") return end

    local originalNumbers = Services.Players.LocalPlayer.PlayerGui:WaitForChild("MainScreenFolder"):WaitForChild("HotbarScreen"):WaitForChild("Container"):FindFirstChild("Level"):FindFirstChild("Count")
    if not originalNumbers then print("no originalnumbers") return end

    local streamerLabel = Services.Players.LocalPlayer.PlayerGui:WaitForChild("MainScreenFolder"):WaitForChild("HotbarScreen"):WaitForChild("Container"):FindFirstChild("Level"):FindFirstChild("streamerlabel")
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "streamerlabel"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = originalNumbers.Parent
    end

    -- ✅ Extract player's level from the UI text
    local playerLevel = "1"
    pcall(function()
        local levelText = originalNumbers.Text -- e.g., "Level 14 [59.32K/368.91K]"
        local levelMatch = levelText:match("Level (%d+)")
        if levelMatch then
            playerLevel = levelMatch
        end
    end)

    -- ✅ Get player's actual title
    local playerTitle = ""
    pcall(function()
        local playerReplicas = ReplicaStore.GetAll("PlayerReplica")
        
        for _, replica in pairs(playerReplicas) do
            if replica.Tags.Player == Services.Players.LocalPlayer then
                local titleEquipped = replica.Data.TitleEquipped
                if titleEquipped then
                    local InfoModule = require(Services.ReplicatedStorage.MainSharedFolder.Modules.InfoModule)
                    local titleData = InfoModule.Titles.Titles[titleEquipped]
                    if titleData then
                        playerTitle = '['..titleData.Name..']'
                    end
                end
                break
            end
        end
    end)

    if State.streamerModeEnabled then
        billboard:FindFirstChild("Username").Text = "🔥 PROTECTED BY LIXHUB 🔥"
        billboard:FindFirstChild("Title").Text = "LIXHUB USER"
        billboard:FindFirstChild("Level").Text = "999"

        originalNumbers.Visible = false
        streamerLabel.Visible = true
    else
        billboard:FindFirstChild("Username").Text = Services.Players.LocalPlayer.Name
        billboard:FindFirstChild("Level").Text = playerLevel
        billboard:FindFirstChild("Title").Text = playerTitle

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

AutoStartToggle = GameTab:CreateToggle({
        Name = "Auto Start",
        CurrentValue = false,
        Flag = "AutoStart",
        Callback = function(Value)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Auto Match Start", Value)
        end,
    })

     AutoRetryToggle = GameTab:CreateToggle({
        Name = "Auto Retry",
        CurrentValue = false,
        Flag = "AutoRetry",
        Callback = function(Value)
            State.AutoRetry = Value
        end,
    })

     AutoNextToggle = GameTab:CreateToggle({
        Name = "Auto Next",
        CurrentValue = false,
        Flag = "AutoNext",
        Callback = function(Value)
            State.AutoNext = Value
        end,
    })

     AutoLobbyToggle = GameTab:CreateToggle({
        Name = "Auto Lobby",
        CurrentValue = false,
        Flag = "AutoLobby",
        Callback = function(Value)
            State.AutoLobby = Value
        end,
    })

         AutoLobbyToggle = GameTab:CreateToggle({
        Name = "Auto Skip Waves",
        CurrentValue = false,
        Flag = "AutoSkipWaves",
        Callback = function(Value)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Auto-Skip Waves", Value)
        end,
    })

     AutoGameSpeedToggle = GameTab:CreateToggle({
        Name = "Auto Game Speed",
        CurrentValue = false,
        Flag = "AutoGameSpeed",
        Callback = function(Value)
            game:GetService("ReplicatedStorage"):WaitForChild("MainSharedFolder"):WaitForChild("Remotes"):WaitForChild("Settings"):FireServer("Auto Match Speed", Value)
        end,
    })

      ChallengeBugToggle = GameTab:CreateToggle({
        Name = "Secret Feature",
        CurrentValue = false,
        Flag = "ChallengeBug",
        Callback = function(Value)
            State.ChallengeBug = Value
        end,
    })

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


      task.spawn(function()
        while true do
            task.wait(0.5)
            checkAndExecuteHighestPriority()
        end
    end)


    ensureMacroFolders()
    loadAllMacros()
    MacroDropdown:Refresh(getMacroList())

    task.spawn(loadAllStoryStagesWithRetry)
    task.spawn(loadIgnoreWorldsWithRetry)
    task.spawn(loadAllRaidStagesWithRetry)

    Rayfield:LoadConfiguration()
    Rayfield:SetVisibility(false)
    enableAutoMatchRewards()
    disableModuleScripts()

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
