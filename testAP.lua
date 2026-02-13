if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 76806550943352 and game.PlaceId ~= 85661754644506 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.27"

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Paradox",
   Icon = 0,
   LoadingTitle = "Loading for Anime Paradox",
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
      FileName = game:GetService("Players").LocalPlayer.Name .. "_AnimeParadox"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "LixHub - Anime Paradox - Free",
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
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "tv")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

local StatusLabel = MacroTab:CreateLabel("Status: Ready")
local DetailLabel = MacroTab:CreateLabel("Waiting...")

Div = MacroTab:CreateDivider()

local currentGameInfo = {
    MapName = nil,
    Act = nil,
    Category = nil,
    StartTime = nil
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
}

local State = {
    DisableNotifications = false,
    AutoNext = false,
    AutoRetry = false,
    AutoLobby = false,
    AutoStartGame = false,
    AntiAfkKickEnabled = false,
    enableAutoExecute = false,
    RemoveGamePopups = false,
    SendStageCompletedWebhook = false,
    ReturnToLobbyFailsafe = false,

    --story
    AutoJoinStory = false,
    StoryStageSelected = nil,
    StoryActSelected = nil,
    StoryDifficultySelected = nil,
    --legend
    AutoJoinLegendStage = false,
    LegendStageSelected = nil,
    LegendActSelected = nil,
    --challenge
    AutoJoinChallenge = false,
    ChallengeStageSelected = nil,
    ChallengeRewardsFilter = {},
    IgnoreWorlds = {},
    ReturnToLobbyOnNewChallenge = false,
    NewChallengeDetected = false,
    LastChallengeCheckTime = 0,
    --raid
    AutoJoinRaid = false,
    RaidStageSelected = nil,
    RaidActSelected = nil,
    --siege
    AutoJoinSiege = false,
    SiegeStageSelected = nil,
    SiegeActSelected = nil,
}

local loadingRetries = {
    story = 0,
    legend = 0,
    raid = 0,
    siege = 0,
    ignoreWorlds = 0,
    modifiers = 0,
}

local StageDataCache = {
    story = {},
    legend = {},
    raid = {},
    siege = {},
    challenge = {}
}

local AutoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2
}

local Config = {
    DISCORD_USER_ID = nil,
    VALID_WEBHOOK = nil,
}

local MacroManager = {
    macros = {},
    currentMacroName = nil,
    currentMacro = nil,
}

local PlayerLoadout = {
    units = {},
    loaded = false,
}

local MacroState = {
    isRecording = false,
    recordingHasStarted = false,
    gameStartTime = 0,
    waveStartTime = 0,
    currentWave = 0,
    currentMacro = {},
    isPlaybackEnabled = false,
    playbackLoopRunning = false,
    gameInProgress = false,
    lastWave = 0,
    currentPlaybackThread = nil,
    recordingStartTime = 0,
    scheduledAbilities = {},
    activeThreads = {},
    playbackLoopThread = nil,
}

local recordingUnitCounter = {} -- Maps "UnitName" -> count
local recordingInstanceToTag = {} -- Maps Instance -> "UnitName #N"
local playbackUnitTagToInstance = {} -- Maps "UnitName #N" -> Instance (for playback)
local UnitDataCache = {}
local DEBUG = true

local function isInLobby()
    return Services.Workspace:FindFirstChild("Lobby") or false
end

local function getCurrentWave()
    local success, wave = pcall(function()
        return Services.ReplicatedStorage.GameConfig.Wave.Value
    end)
    
    return success and wave or 0
end

local function debugPrint(...)
    if DEBUG then print(...) end
end

local function notify(title, content, duration)
    if State.DisableNotifications then return end
    Rayfield:Notify({Title = title or "Notice",Content = content or "No message.",Duration = duration or 3,Image = "info"})
end

local function getMacroList()
    local list = {}
    for name in pairs(MacroManager.macros) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

local function updateMacroStatus(message)
    StatusLabel:Set("Status: " .. message)
end

local function updateDetailedStatus(message)
    DetailLabel:Set(message)
end
local function getMacroFilename(name)
    return "LixHub/Macros/AP/" .. name .. ".json"
end

local function ensureMacroFolders()
    if not isfolder("LixHub") then
        makefolder("LixHub")
    end
    if not isfolder("LixHub/Macros") then
        makefolder("LixHub/Macros")
    end
    if not isfolder("LixHub/Macros/AP") then
        makefolder("LixHub/Macros/AP")
    end
end

local function saveMacroToFile(name, macroData)
    ensureMacroFolders()
    
    local json = Services.HttpService:JSONEncode(macroData)
    writefile(getMacroFilename(name), json)
    
    debugPrint(string.format("Saved macro: %s (%d actions)", name, #macroData))
end

local function loadMacroFromFile(name)
    if not isfile(getMacroFilename(name)) then 
        return nil 
    end

    local json = readfile(getMacroFilename(name))
    local data = Services.HttpService:JSONDecode(json)

    return data
end

local function loadAllMacros()
    ensureMacroFolders()
    MacroManager.macros = {}
    
    local files = listfiles("LixHub/Macros/AP/")
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            local data = loadMacroFromFile(name)
            if data then
                MacroManager.macros[name] = data
                debugPrint(string.format("Loaded macro: %s (%d actions)", name, #data))
            end
        end
    end
end

local function waitForLoadout()
    local timeout = 0
    while not PlayerLoadout.loaded and timeout < 30 do
        task.wait(0.5)
        timeout = timeout + 0.5
    end
    
    if not PlayerLoadout.loaded then
        warn("Loadout never loaded - proceeding anyway")
        return false
    end
    
    return true
end

local function getUnitData(unitName)
    if UnitDataCache[unitName] then
        return UnitDataCache[unitName]
    end
    
    local success, result = pcall(function()
        local module = Services.ReplicatedStorage.Modules.Shared.Data.UnitData.Units:FindFirstChild(unitName)
        if not module or not module:IsA("ModuleScript") then return nil end
        return require(module)
    end)
    
    if success and result then
        UnitDataCache[unitName] = result
    end
    
    return success and result or nil
end

local function prewarmUnitDataCache()
    for slot, data in pairs(PlayerLoadout.units) do
        if data and data.Name then
            getUnitData(data.Name)
        end
    end
    debugPrint("✓ Unit data cached for all equipped units")
end

local function fetchPlayerLoadout()
        debugPrint("Waiting for client data...")
    local timeout = 0
    while timeout < 60 do
        local clientIsLoaded = Services.Players.LocalPlayer:GetAttribute("ClientIsLoaded")
        local clientLoaded = Services.Players.LocalPlayer:GetAttribute("ClientLoaded")
        
        if clientIsLoaded and clientLoaded then
            break
        end
        
        task.wait(0.5)
        timeout = timeout + 0.5
    end
    
    if timeout >= 60 then
        warn("Client load timeout - proceeding anyway")
    end
    
    debugPrint("Client loaded, fetching loadout...")
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "Instance" then continue end
        if type(obj) ~= "table" then continue end
        
        local reqFunc = rawget(obj, "RequestPlayerData")
        
        if type(reqFunc) == "function" then
            local success, data = pcall(function()
                return reqFunc(obj, Services.Players.LocalPlayer)
            end)
            
            if success and data and data.EquippedUnits and data.Inventory and data.Inventory.Units then
                local equipped = data.EquippedUnits
                local inventory = data.Inventory.Units
                
                for slot = 1, 6 do
                    local guid = equipped[tostring(slot)]
                    if guid and inventory[guid] then
                        local unit = inventory[guid]
                        if unit and unit.Name then
                            PlayerLoadout.units[slot] = {
                                GUID = guid,
                                Name = unit.Name,
                                Level = unit.Level or 1
                            }
                        end
                    end
                end
                
                if next(PlayerLoadout.units) then
                    PlayerLoadout.loaded = true
                    debugPrint("✓ Loadout cached:")
                    prewarmUnitDataCache()
                    for slot, data in pairs(PlayerLoadout.units) do
                        debugPrint(string.format("  Slot %d: %s (GUID: %s)", slot, data.Name, data.GUID))
                    end
                    return true
                end
            end
        end
    end
    
    warn("Failed to fetch player loadout")
    return false
end

local function getEquippedUnits()
    return PlayerLoadout.units
end

local function getUnitFromSlot(slot)
    return PlayerLoadout.units[slot]
end

local function getSlotFromUnitName(unitName)
    for slot, data in pairs(PlayerLoadout.units) do
        if data.Name == unitName then
            return slot
        end
    end
    return nil
end

local function getPlayerMoney()
    local success, money = pcall(function()
        return Services.Players.LocalPlayer:GetAttribute("Yen") or 0
    end)
    
    return success and money or 0
end

local function canAffordUnit(unitName)
    local unitData = getUnitData(unitName)
    if not unitData or not unitData.BaseStats then
        return true
    end
    
    local placementCost = unitData.BaseStats.Cost or 0
    local money = getPlayerMoney()
    
    debugPrint(string.format("💰 Money: $%d | %s Placement Cost: $%d", money, unitName, placementCost))
    
    return money >= placementCost
end

local function waitForMoney(requiredAmount, actionDescription)
    local currentMoney = getPlayerMoney()
    
    if not currentMoney then
        return true
    end
    
    if currentMoney >= requiredAmount then
        return true
    end
    
    local lastUpdateTime = tick()
    
    while true do
        -- Check if game ended
        if not MacroState.isPlaybackEnabled or not MacroState.gameInProgress then
            debugPrint("⚠️ Game ended while waiting for money - aborting wait")
            return false
        end
        
        task.wait(1)
        
        currentMoney = getPlayerMoney()
        if not currentMoney then
            return true
        end
        
        if currentMoney >= requiredAmount then
            return true
        end
        
        if tick() - lastUpdateTime >= 1 then
            updateDetailedStatus(string.format("Waiting: $%d / $%d (%s)", currentMoney, requiredAmount, actionDescription))
            lastUpdateTime = tick()
        end
    end
end

local function findNewUnitInWorkspace(unitName, excludeInstances)
    excludeInstances = excludeInstances or {}
    
    local candidates = {}
    
    pcall(function()
        local entitiesFolder = Services.Workspace:FindFirstChild("Entities")
        if not entitiesFolder then return end
        
        for _, unit in pairs(entitiesFolder:GetChildren()) do
            if excludeInstances[unit] then
                continue
            end
            
            -- Extract unit name from instance name (e.g., "Dio_0.30" -> "Dio")
            local instanceName = unit.Name:match("^(.+)_%d")
            
            if instanceName == unitName then
                table.insert(candidates, unit)
            end
        end
    end)
    
    if #candidates == 0 then
        warn(string.format("❌ No new units found for: %s", unitName))
        return nil
    end
    
    -- Return the most recently created one
    return candidates[#candidates]
end

local function cancelAllThreads()
    for _, thread in ipairs(MacroState.activeThreads) do
        pcall(function()
            task.cancel(thread)
        end)
    end
    MacroState.activeThreads = {}
    MacroState.scheduledAbilities = {}
end

local function clearSpawnIdMappings()
    cancelAllThreads()
    playbackUnitTagToInstance = {}
    recordingUnitCounter = {}
    recordingInstanceToTag = {}
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local originalNamecall = mt.__namecall

local generalHook = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and MacroState.isRecording and MacroState.recordingHasStarted then
        task.spawn(function()
            local timestamp = tick()
            local timeFromGameStart = timestamp - MacroState.gameStartTime  -- Time from when wave 1 started
            
            -- PLACEMENT HOOK
            if method == "FireServer" and self.Name == "UnitAction" and args[1] == "Place" then
                local unitGUID = args[2]
                local position = args[3]
                
                debugPrint(string.format("Placement detected: GUID=%s at (%.1f, %.1f, %.1f)", 
                    unitGUID, position.X, position.Y, position.Z))
                
                local unitName = nil
                local slot = nil
                
                local equipped = getEquippedUnits()
                for equipSlot, data in pairs(equipped) do
                    if data.GUID == unitGUID then
                        unitName = data.Name
                        slot = equipSlot
                        break
                    end
                end
                
                if not unitName then
                    warn("Could not determine unit name from GUID:", unitGUID)
                    return
                end
                
                debugPrint(string.format("Placing unit: %s (Slot %d)", unitName, slot))
                
                task.wait(0.5)
                
                local excludeInstances = {}
                for instance, _ in pairs(recordingInstanceToTag) do
                    excludeInstances[instance] = true
                end
                
                local unitInstance = nil
                local targetPos = position
                
                for attempt = 1, 10 do
                    local candidates = {}
                    
                    pcall(function()
                        local entitiesFolder = Services.Workspace:FindFirstChild("Entities")
                        if not entitiesFolder then return end
                        
                        for _, unit in pairs(entitiesFolder:GetChildren()) do
                            if excludeInstances[unit] then
                                continue
                            end
                            
                            local instanceName = unit.Name:match("^(.+)_%d")
                            
                            if instanceName == unitName then
                                local unitPos = unit:GetPivot().Position
                                local distance = (unitPos - targetPos).Magnitude
                                
                                table.insert(candidates, {
                                    instance = unit,
                                    distance = distance
                                })
                            end
                        end
                    end)
                    
                    if #candidates > 0 then
                        table.sort(candidates, function(a, b) 
                            return a.distance < b.distance 
                        end)
                        
                        if candidates[1].distance < 10 then
                            unitInstance = candidates[1].instance
                            debugPrint(string.format("Found unit at distance %.2f on attempt %d", 
                                candidates[1].distance, attempt))
                            break
                        end
                    end
                    
                    task.wait(0.3)
                end
                
                if unitInstance then
    recordingUnitCounter[unitName] = (recordingUnitCounter[unitName] or 0) + 1
    local unitNumber = recordingUnitCounter[unitName]
    local unitTag = string.format("%s #%d", unitName, unitNumber)
    
    recordingInstanceToTag[unitInstance] = unitTag
    
    local record = {
        Type = "spawn_unit",
        Unit = unitTag,
        Time = string.format("%.2f", timeFromGameStart),
        Position = {position.X, position.Y, position.Z},
    }
    
    table.insert(MacroState.currentMacro, record)
    
    debugPrint(string.format("Recorded: %s at %.2fs from game start (Instance=%s)", 
        unitTag, timeFromGameStart, unitInstance.Name))
else
    warn("Failed to find placed unit in workspace!")
end
                
            -- UPGRADE HOOK
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Upgrade" then
                local unitInstance = args[2]
                
                local unitTag = recordingInstanceToTag[unitInstance]
                if not unitTag then
                    warn("Upgrade detected for untracked unit:", unitInstance.Name)
                    return
                end
                
                table.insert(MacroState.currentMacro, {
                    Type = "upgrade_unit",
                    Unit = unitTag,
                    Time = string.format("%.2f", timeFromGameStart)
                })
                
                debugPrint(string.format("Recorded upgrade: %s at %.2fs from game start (Instance=%s)", 
                    unitTag, timeFromGameStart, unitInstance.Name))
                
            -- SELL HOOK
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Sell" then
                local unitInstance = args[2]
                
                local unitTag = recordingInstanceToTag[unitInstance]
                if not unitTag then
                    warn("Sell detected for untracked unit:", unitInstance.Name)
                    return
                end
                
                table.insert(MacroState.currentMacro, {
                    Type = "sell_unit",
                    Unit = unitTag,
                    Time = string.format("%.2f", timeFromGameStart)
                })
                
                debugPrint(string.format("Recorded sell: %s at %.2fs from game start (Instance=%s)", 
                    unitTag, timeFromGameStart, unitInstance.Name))
                
                recordingInstanceToTag[unitInstance] = nil
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Active" then
    local unitInstance = args[2]
    local abilitySlot = args[3]
    
    local unitTag = recordingInstanceToTag[unitInstance]
    if not unitTag then
        warn("Ability detected for untracked unit:", unitInstance.Name)
        return
    end
    
    local timeFromGameStart = timestamp - MacroState.gameStartTime
    
    table.insert(MacroState.currentMacro, {
        Type = "use_ability",
        Unit = unitTag,
        AbilitySlot = abilitySlot,
        Time = string.format("%.2f", timeFromGameStart)
    })
    
    debugPrint(string.format("Recorded ability: %s used ability slot %s at %.2fs from game start", 
        unitTag, abilitySlot, timeFromGameStart))
end
        end)
    end
    
    return originalNamecall(self, ...)
end)

mt.__namecall = generalHook
setreadonly(mt, true)

local function getUnitNameFromTag(unitTag)
    return unitTag:match("^(.+) #%d+$") or unitTag
end

local function executePlacementAction(action, actionIndex, totalActions)
    local unitName = getUnitNameFromTag(action.Unit)
    
    updateMacroStatus(string.format("(%d/%d) Placing %s", actionIndex, totalActions, action.Unit))
    
    -- Dynamically find this unit in player's equipped units
    local slot = getSlotFromUnitName(unitName)
    
    if not slot then
        updateDetailedStatus(string.format("Error: %s not equipped!", unitName))
        warn(string.format("%s is not in loadout - skipping placement", unitName))
        return false
    end
    
    -- Get the unit info (including GUID) from the slot
    local unitInfo = getUnitFromSlot(slot)
    if not unitInfo then
        updateDetailedStatus("Error: Could not get unit data")
        return false
    end
    
    debugPrint(string.format("Found %s in slot %d (GUID: %s)", unitName, slot, unitInfo.GUID))
    
    -- Get unit data to check cost
    local unitData = getUnitData(unitName)
    local placementCost = 0
    
    if unitData and unitData.BaseStats then
        placementCost = unitData.BaseStats.Cost or 0
    end
    
    if placementCost > 0 then
        local currentMoney = getPlayerMoney()
        if currentMoney and currentMoney < placementCost then
            updateDetailedStatus(string.format("Waiting for $%d to place %s", placementCost, action.Unit))
        end
        
        local canContinue = waitForMoney(placementCost, unitName)
        if not canContinue then
            updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    
    updateDetailedStatus(string.format("Placing %s...", action.Unit))
    
    local pos = action.Position
    local position = Vector3.new(pos[1], pos[2], pos[3])
    
    local success = pcall(function()
        local remote = Services.Players.LocalPlayer.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Place", unitInfo.GUID, position, slot - 1) -- AP uses 0-indexed slots
    end)
    
    if not success then
        updateDetailedStatus("Placement failed")
        return false
    end
    
    task.wait(0.5)
    
    local excludeInstances = {}
    for _, mappedInstance in pairs(playbackUnitTagToInstance) do
        excludeInstances[mappedInstance] = true
    end
    
    local unitInstance = nil
    
    for attempt = 1, 10 do
        unitInstance = findNewUnitInWorkspace(unitName, excludeInstances)
        if unitInstance then break end
        task.wait(0.3)
    end
    
    if unitInstance then
        playbackUnitTagToInstance[action.Unit] = unitInstance
        updateDetailedStatus(string.format("Placed %s", action.Unit))
        return true
    end
    
    updateDetailedStatus("Failed to detect placed unit")
    return false
end

local function executeUnitUpgrade(action, actionIndex, totalActions)
    updateMacroStatus(string.format("(%d/%d) Upgrading %s", actionIndex, totalActions, action.Unit))
    
    local unitInstance = playbackUnitTagToInstance[action.Unit]
    
    if not unitInstance or not unitInstance.Parent then
        updateDetailedStatus(string.format("Error: Unit instance not found for %s", action.Unit))
        return false
    end
    
    -- Get unit name and current upgrade level
    local unitName = getUnitNameFromTag(action.Unit)
    local currentUpgrade = unitInstance:GetAttribute("Upgrades") or 0
    
    debugPrint(string.format("Attempting to upgrade %s (Current Level: %d)", action.Unit, currentUpgrade))
    
    -- Get unit data to determine upgrade cost
    local unitData = getUnitData(unitName)
    local upgradeCost = 0
    
    if unitData and unitData.UpgradeStats then
        -- UpgradeStats is an array where each index is an upgrade level
        -- Index 1 = upgrade to level 1, Index 2 = upgrade to level 2, etc.
        local nextUpgradeIndex = currentUpgrade + 1
        local upgradeData = unitData.UpgradeStats[nextUpgradeIndex]
        
        if upgradeData and upgradeData.Cost then
            upgradeCost = upgradeData.Cost
            debugPrint(string.format("Upgrade cost for level %d->%d: $%d", currentUpgrade, nextUpgradeIndex, upgradeCost))
        else
            debugPrint(string.format("No upgrade data found for level %d (max level may be %d)", nextUpgradeIndex, #unitData.UpgradeStats))
            -- If no more upgrades available, skip
            updateDetailedStatus(string.format("%s is max level (%d)", action.Unit, currentUpgrade))
            return true
        end
    else
        debugPrint("No UpgradeStats found in unit data for: " .. unitName)
        updateDetailedStatus("Could not get upgrade data")
        return false
    end
    
    -- Wait for money if needed
    local currentMoney = getPlayerMoney()
    debugPrint(string.format("Current money: $%d | Need: $%d", currentMoney or 0, upgradeCost))
    
    if currentMoney and currentMoney < upgradeCost then
        updateDetailedStatus(string.format("Waiting for $%d to upgrade %s (have $%d)", upgradeCost, action.Unit, currentMoney))
        
        local canContinue = waitForMoney(upgradeCost, string.format("%s upgrade to level %d", action.Unit, currentUpgrade + 1))
        if not canContinue then
            updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    
    updateDetailedStatus(string.format("Upgrading %s to level %d...", action.Unit, currentUpgrade + 1))
    
    local success = pcall(function()
        local remote = Services.Players.LocalPlayer.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Upgrade", unitInstance, true)
    end)
    
    if success then
        -- Wait for upgrade to process
        task.wait(0.5)
        
        -- Verify upgrade went through
        local newUpgrade = unitInstance:GetAttribute("Upgrades") or 0
        if newUpgrade > currentUpgrade then
            debugPrint(string.format("Upgrade successful: %d -> %d", currentUpgrade, newUpgrade))
            updateDetailedStatus(string.format("Upgraded %s to level %d ✓", action.Unit, newUpgrade))
        else
            debugPrint(string.format("Upgrade may have failed: level still at %d", newUpgrade))
            updateDetailedStatus(string.format("Upgrade attempt for %s (level %d)", action.Unit, newUpgrade))
        end
        return true
    end
    
    updateDetailedStatus("Upgrade failed")
    return false
end

local function executeUnitSell(action, actionIndex, totalActions)
    updateMacroStatus(string.format("(%d/%d) Selling %s", actionIndex, totalActions, action.Unit))
    
    local unitInstance = playbackUnitTagToInstance[action.Unit]
    
    if not unitInstance or not unitInstance.Parent then
        updateDetailedStatus(string.format("Error: Unit instance not found for %s", action.Unit))
        return false
    end
    
    updateDetailedStatus(string.format("Selling %s...", action.Unit))
    
    local success = pcall(function()
        local remote = Services.Players.LocalPlayer.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Sell", unitInstance)
    end)
    
    if success then
        playbackUnitTagToInstance[action.Unit] = nil
        updateDetailedStatus(string.format("Sold %s", action.Unit))
        return true
    end
    
    updateDetailedStatus("Sell failed")
    return false
end

local function executeAbilityAction(action)
    local unitInstance = playbackUnitTagToInstance[action.Unit]
    
    if not unitInstance or not unitInstance.Parent then
        debugPrint(string.format("Cannot use ability - %s not found or sold", action.Unit))
        return false
    end
    
    local abilitySlot = action.AbilitySlot
    
    debugPrint(string.format("Using ability: %s slot %s", action.Unit, abilitySlot))
    
    local success = pcall(function()
        local remote = Services.Players.LocalPlayer.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Active", unitInstance, abilitySlot)
    end)
    
    if success then
        debugPrint(string.format("Ability fired: %s slot %s", action.Unit, abilitySlot))
        return true
    end
    
    debugPrint(string.format("Ability failed: %s slot %s", action.Unit, abilitySlot))
    return false
end

local function autoStartGame()
    for i, connection in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.GameHUD.VoteSkipFrame.BTNs.Yes.Activated)) do
    connection:Fire()
    end
end

local function scheduleAbility(action, targetTime)
    local schedulerId = tostring(action) .. "_" .. tostring(targetTime)
    
    if MacroState.scheduledAbilities[schedulerId] then
        return
    end
    
    MacroState.scheduledAbilities[schedulerId] = true
    
    local thread = task.spawn(function()
        while MacroState.isPlaybackEnabled and MacroState.gameInProgress do
            local currentGameTime = tick() - MacroState.gameStartTime
            local waitTime = targetTime - currentGameTime
            
            if waitTime <= 0 then
                executeAbilityAction(action)
                MacroState.scheduledAbilities[schedulerId] = nil
                return
            end
            
            task.wait(0.1)
        end
        
        MacroState.scheduledAbilities[schedulerId] = nil
    end)
    
    -- Track the thread so we can cancel it
    table.insert(MacroState.activeThreads, thread)
end

local function playMacro()
    if not MacroState.currentMacro or #MacroState.currentMacro == 0 then
        updateDetailedStatus("No macro to play")
        return
    end
    
    updateDetailedStatus("Starting playback...")
    
    clearSpawnIdMappings()
    MacroState.scheduledAbilities = {}  -- Clear scheduled abilities
    
    local totalActions = #MacroState.currentMacro
    local playbackStartTime = tick() - MacroState.gameStartTime
    
    debugPrint(string.format("Starting playback: %d actions", totalActions))
    debugPrint(string.format("Playback starting %.2fs into game", playbackStartTime))
    
    for i, action in ipairs(MacroState.currentMacro) do
        if not MacroState.isPlaybackEnabled or not MacroState.gameInProgress then
            debugPrint(string.format("Stopping playback at action %d/%d", i, totalActions))
            updateDetailedStatus("Game ended - stopped playback")
            clearSpawnIdMappings()
            MacroState.scheduledAbilities = {}
            return
        end
        
        debugPrint(string.format("Action %d: Type=%s, Time=%s", 
            i, action.Type, tostring(action.Time)))
        
        -- Handle abilities specially - always respect timing
        if action.Type == "use_ability" then
            local actionTime = tonumber(action.Time)
            
            if actionTime then
                local currentGameTime = tick() - MacroState.gameStartTime
                
                if currentGameTime < actionTime then
                    -- Schedule it for later and continue
                    scheduleAbility(action, actionTime)
                    updateDetailedStatus(string.format("(%d/%d) Scheduled ability for %.1fs", 
                        i, totalActions, actionTime))
                else
                    -- Time already passed, fire immediately
                    executeAbilityAction(action)
                    updateDetailedStatus(string.format("(%d/%d) Used ability (late by %.1fs)", 
                        i, totalActions, currentGameTime - actionTime))
                end
            end
            
            task.wait(0.1)  -- Small delay before next action
            continue
        end
        
        -- Handle timing for non-ability actions (unless ignoring)
        if not State.ignoreTiming then
            local actionTime = tonumber(action.Time)
            
            if not actionTime then
                debugPrint("Action missing Time, executing immediately")
            else
                local currentGameTime = tick() - MacroState.gameStartTime
                local waitTime = actionTime - currentGameTime
                
                debugPrint(string.format("Game time: %.2fs | Action time: %.2fs | Wait: %.2fs", 
                    currentGameTime, actionTime, waitTime))
                
                if waitTime > 1 then
                    local waitStart = tick()
                    while (tick() - waitStart) < waitTime do
                        if not MacroState.isPlaybackEnabled or not MacroState.gameInProgress then
                            debugPrint("Game ended while waiting - stopping playback")
                            updateDetailedStatus("Game ended - stopped playback")
                            clearSpawnIdMappings()
                            MacroState.scheduledAbilities = {}
                            return
                        end
                        
                        local remaining = waitTime - (tick() - waitStart)
                        if remaining > 1 then
                            updateDetailedStatus(string.format("(%d/%d) Waiting %.1fs for %s", 
                                i, totalActions, remaining, action.Unit or "next action"))
                        end
                        
                        task.wait(0.5)
                    end
                elseif waitTime > 0 then
                    task.wait(waitTime)
                else
                    -- Action time already passed, execute immediately
                    debugPrint(string.format("Action time already passed (%.2fs late), executing now", -waitTime))
                    updateDetailedStatus(string.format("(%d/%d) Catching up - executing %s", 
                        i, totalActions, action.Unit or "action"))
                end
            end
        else
            if i > 1 then
                updateDetailedStatus(string.format("(%d/%d) Ready for next action", i, totalActions))
                task.wait(0.2)
            end
        end
        
        if not MacroState.isPlaybackEnabled or not MacroState.gameInProgress then
            debugPrint("Game ended before action execution")
            updateDetailedStatus("Game ended - stopped playback")
            clearSpawnIdMappings()
            MacroState.scheduledAbilities = {}
            return
        end
        
        local success = false
        
        if action.Type == "spawn_unit" then
            success = executePlacementAction(action, i, totalActions)
        elseif action.Type == "upgrade_unit" then
            success = executeUnitUpgrade(action, i, totalActions)
        elseif action.Type == "sell_unit" then
            success = executeUnitSell(action, i, totalActions)
        end
        
        task.wait(0.2)
    end
    
    updateMacroStatus("Playback Complete")
    updateDetailedStatus(string.format("Completed %d/%d actions ✓", totalActions, totalActions))
    
    -- Wait a bit for any scheduled abilities to fire
    task.wait(1)
end

local function startRecording()
    if MacroState.isRecording then
        return
    end
    
    MacroState.currentMacro = {}
    clearSpawnIdMappings()
    
    MacroState.isRecording = true
    MacroState.recordingHasStarted = true
    MacroState.gameStartTime = tick()
    
    updateMacroStatus("Recording...")
end

local function stopRecording()
    if not MacroState.isRecording then return end
    
    MacroState.isRecording = false
    MacroState.recordingHasStarted = false
    
    local actionCount = #MacroState.currentMacro
    
    if MacroManager.currentMacroName and MacroManager.currentMacroName ~= "" then
        MacroManager.macros[MacroManager.currentMacroName] = MacroState.currentMacro
        saveMacroToFile(MacroManager.currentMacroName, MacroState.currentMacro)
        updateMacroStatus(string.format("Saved %d actions to %s", actionCount, MacroManager.currentMacroName))
    else
        updateMacroStatus(string.format("Recording stopped (%d actions)", actionCount))
    end
    
    return MacroState.currentMacro
end

local function autoPlaybackLoop()
    if MacroState.playbackLoopRunning then
        return
    end
    
    MacroState.playbackLoopRunning = true
    MacroState.playbackLoopThread = coroutine.running()

    while MacroState.isPlaybackEnabled do
        -- Wait for game to start
        while not MacroState.gameInProgress and MacroState.isPlaybackEnabled do
            updateMacroStatus("Waiting for game to start...")
            updateDetailedStatus("Waiting for wave 1...")
            task.wait(0.5)
        end
        
        if not MacroState.isPlaybackEnabled then break end
        
        if not MacroState.gameInProgress then
            task.wait(0.5)
            continue
        end
        
        -- Wait for wave timing to be initialized
        local timeout = 0
        while MacroState.waveStartTime == 0 and timeout < 20 do
            task.wait(0.1)
            timeout = timeout + 1
        end
        
        if MacroState.waveStartTime == 0 then
            -- Initialize it now if it hasn't been set
            MacroState.waveStartTime = tick()
            MacroState.currentWave = getCurrentWave()
        end
        
        if not MacroManager.currentMacroName or MacroManager.currentMacroName == "" then
            updateMacroStatus("Error: No macro selected")
            updateDetailedStatus("Select a macro to continue")
            break
        end
        
        if not MacroState.currentMacro or #MacroState.currentMacro == 0 then
            updateMacroStatus("Error: No macro loaded")
            break
        end
        clearSpawnIdMappings()
        
        updateMacroStatus(string.format("Executing: %s (%d actions)", MacroManager.currentMacroName, #MacroState.currentMacro))
        updateDetailedStatus("Starting playback...")
        
        notify("Playback Started", MacroManager.currentMacroName .. " (" .. #MacroState.currentMacro .. " actions)")
        
        MacroState.currentPlaybackThread = coroutine.running()
        playMacro()
        MacroState.currentPlaybackThread = nil
        
        -- Wait for game to end
        while MacroState.gameInProgress and MacroState.isPlaybackEnabled do
            task.wait(0.5)
        end
        
        if not MacroState.isPlaybackEnabled then break end
        
        clearSpawnIdMappings()
        updateMacroStatus("Game ended - waiting for next...")
        updateDetailedStatus("Ready for next game")
        
        task.wait(2)
    end
    
    updateMacroStatus("Playback Stopped")
    updateDetailedStatus("Ready")
    MacroState.playbackLoopRunning = false
    MacroState.playbackLoopThread = nil
end

local function validateMacro(macro)
    if not macro or #macro == 0 then
        return false, "Macro is empty"
    end

    if not PlayerLoadout.loaded then
        waitForLoadout()
    end
    
    -- Collect all unique unit names from macro
    local requiredUnits = {}
    for _, action in ipairs(macro) do
        if action.Type == "spawn_unit" and action.Unit then
            local unitName = getUnitNameFromTag(action.Unit)
            requiredUnits[unitName] = true
        end
    end
    
    -- Get equipped units
    debugPrint("Checking equipped units...")
    local equipped = getEquippedUnits()
    
    if not next(equipped) then
        return false, "Could not load equipped units data"
    end
    
    local equippedUnitNames = {}
    for slot, data in pairs(equipped) do
        equippedUnitNames[data.Name] = true
    end
    
    -- Check for missing units
    local missingUnits = {}
    for unitName, _ in pairs(requiredUnits) do
        if not equippedUnitNames[unitName] then
            table.insert(missingUnits, unitName)
        end
    end
    
    if #missingUnits > 0 then
        return false, "Missing units in loadout:\n" .. table.concat(missingUnits, ", ")
    end
    
    return true, "All required units equipped"
end

local function sendWebhook(messageType, stageInfo, playerStats, rewardsData, playerData)
    if not Config.VALID_WEBHOOK or Config.VALID_WEBHOOK == "" then
        warn("No valid webhook URL configured")
        return
    end

    local data

    if messageType == "test" then
        data = {
            username = "LixHub",
            content = Config.DISCORD_USER_ID and string.format("<@%s>", Config.DISCORD_USER_ID) or "",
            embeds = {{
                title = "Webhook Test",
                description = "Test webhook sent successfully!",
                color = 0x5865F2,
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
    elseif messageType == "game_end" then
    -- Extract player name (spoilered)
    local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
    
    -- Determine win/loss
    local didWin = stageInfo.Result == "Win"
    local resultText = didWin and "Victory" or "Defeat"
    local embedColor = didWin and 0x57F287 or 0xED4245
    
    -- Format stage info
    local stageName = stageInfo.StageName or "Unknown Stage"
    local actName = stageInfo.ActName or "Unknown Act"
    local difficulty = stageInfo.Difficulty or "Unknown Difficulty"
    
    -- Title based on win/loss
    local stageTitle = didWin and "Stage Finished!" or "Stage Failed!"
    
    -- Subtitle: Leaf Village - Act 1:Cabuto's Schemes (Normal) - Victory
    local stageSubtitle = string.format("%s - %s (%s) - %s", 
        stageName:gsub("_", " "), 
        actName, 
        difficulty, 
        resultText
    )
    
    -- Format play time
    local playTime = stageInfo.PlayTime or 0
    local minutes = math.floor(playTime / 60)
    local seconds = playTime % 60
    local timeText = string.format("%dm %ds", minutes, seconds)
    
    -- Get current totals from playerData for bracketed amounts
    local currentGems = 0
    local currentGold = 0
    local currentItems = {}
    
    if playerData and playerData.ClientData then
        currentGems = playerData.ClientData.Gems or 0
        currentGold = playerData.ClientData.Gold or 0
    end
    
    if playerData and playerData.Inventory and playerData.Inventory.Items then
        for itemId, itemData in pairs(playerData.Inventory.Items) do
            if itemData.BaseDataRef and itemData.Amount then
                currentItems[itemData.BaseDataRef] = itemData.Amount
            end
        end
    end
    
    -- Format rewards
    local rewardsText = ""
    
    if rewardsData then
        -- Add Gems
        if rewardsData.Gems and rewardsData.Gems > 0 then
            rewardsText = rewardsText .. string.format("+%d Gems [%d]\n", rewardsData.Gems, currentGems)
        end
        
        -- Add Gold
        if rewardsData.Gold and rewardsData.Gold > 0 then
            rewardsText = rewardsText .. string.format("+%d Gold [%d]\n", rewardsData.Gold, currentGold)
        end
        
        -- Add Items (like Ramen, TraitRerolls, etc)
        for itemName, amount in pairs(rewardsData) do
            if itemName ~= "Gems" and itemName ~= "Gold" and type(amount) == "number" and amount > 0 then
                local currentTotal = currentItems[itemName] or 0
                rewardsText = rewardsText .. string.format("+%d %s [%d]\n", amount, itemName, currentTotal)
            end
        end
    end
    
    if rewardsText == "" then
        rewardsText = "No rewards obtained"
    else
        rewardsText = rewardsText:gsub("\n$", "") -- Remove trailing newline
    end
    
    -- Get macro info
    local macroText = "None"
    if MacroState.isPlaybackEnabled and MacroManager.currentMacroName and MacroManager.currentMacroName ~= "" then
        macroText = MacroManager.currentMacroName
    end
    
    -- Build embed fields
    local fields = {
        { name = "Player", value = playerName, inline = true },
        { name = "Duration", value = timeText, inline = true },
        { name = "Macro", value = macroText, inline = true },
        { name = "Rewards", value = rewardsText, inline = true },
    }
    data = {
        username = "LixHub",
        embeds = {{
            title = stageTitle,
            description = stageSubtitle,
            color = embedColor,
            fields = fields,
            footer = { text = "discord.gg/cYKnXE2Nf8" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
end
    
    -- Send the webhook
    local payload = Services.HttpService:JSONEncode(data)
    
    local requestFunc = syn and syn.request or request or http_request or 
                      (fluxus and fluxus.request) or getgenv().request
    
    if not requestFunc then
        warn("No HTTP function found! Your executor might not support HTTP requests.")
        return
    end
    
    local success, response = pcall(function()
        return requestFunc({
            Url = Config.VALID_WEBHOOK,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
    end)
    
    if success and response and (response.StatusCode == 204 or response.StatusCode == 200) then
        debugPrint("Webhook sent successfully")
        notify("Webhook Sent", "Successfully sent to Discord!", 2)
    else
        warn("Webhook failed:", response and response.StatusCode or "No response")
        notify("Webhook Failed", "Failed to send webhook", 3)
    end
end

local function waitForClientLoaded()
    local maxWait = 60
    local startTime = tick()
    
    debugPrint("Waiting for client to load...")
    
    while (tick() - startTime) < maxWait do
        local clientIsLoaded = Services.Players.LocalPlayer:GetAttribute("ClientIsLoaded")
        local clientsLoaded = Services.Players.LocalPlayer:GetAttribute("ClientLoaded")
        
        if clientIsLoaded and clientsLoaded then
            debugPrint("Client fully loaded!")
            return true
        end
        
        task.wait(0.5)
    end
    
    warn("Client load timeout - proceeding anyway")
    return false
end

local function handleEndGameActions()
    local endGameUI = nil
    local maxWait = 10
    local startTime = tick()
    
    while (tick() - startTime) < maxWait do
        local success = pcall(function()
            local resultsUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("StageEnd")
            
            if resultsUI and resultsUI.Enabled then
                endGameUI = resultsUI
            end
        end)
        
        if endGameUI then
            break
        end
        
        task.wait(0.5)
    end
    
    if not endGameUI then
        warn("End game UI not found - skipping auto actions")
        return
    end
    
    -- Check if we should return to lobby for new challenges
    if State.ReturnToLobbyOnNewChallenge and State.NewChallengeDetected and State.AutoJoinChallenge then
        State.NewChallengeDetected = false -- Reset flag
        
        debugPrint("New challenge detected - returning to lobby")
        
        for attempt = 1, 5 do
            local success = pcall(function()
                Services.ReplicatedStorage.Remotes.StageEnd:FireServer("Lobby")
            end)
            
            if success then
                debugPrint("Fired Lobby remote (attempt " .. attempt .. ")")
            end
            
            task.wait(1)
            
            local uiClosed = pcall(function()
                return not endGameUI.Enabled
            end)
            
            if uiClosed or not endGameUI.Parent then
                debugPrint("Auto Lobby successful for new challenge!")
                notify("Auto Action", "Returned to lobby for new challenge", 2)
                return
            end
        end
        
        warn("Failed to return to lobby for new challenge")
        return
    end
    
    -- Normal priority order: Next > Retry > Lobby
    local actions = {}
    
    if State.AutoNext then
        table.insert(actions, {name = "Next", remote = "Next"})
    end
    
    if State.AutoRetry then
        table.insert(actions, {name = "Retry", remote = "Replay"})
    end
    
    if State.AutoLobby then
        table.insert(actions, {name = "Lobby", remote = "Lobby"})
    end
    
    if #actions == 0 then
        debugPrint("ℹNo auto end game actions enabled")
        return
    end
    
    -- Try each action until UI closes
    for _, action in ipairs(actions) do
        debugPrint(string.format("Attempting auto %s...", action.name))
        
        for attempt = 1, 5 do
            local success = pcall(function()
                Services.ReplicatedStorage.Remotes.StageEnd:FireServer(action.remote)
            end)
            
            if success then
                debugPrint(string.format("Fired %s remote (attempt %d)", action.name, attempt))
            end
            
            -- Wait and check if UI closed (action succeeded)
            task.wait(1)
            
            local uiClosed = pcall(function()
                return not endGameUI.Enabled
            end)
            
            if uiClosed or not endGameUI.Parent then
                debugPrint(string.format("Auto %s successful!", action.name))
                notify("Auto Action", string.format("Auto %s activated", action.name), 2)
                return
            end
        end
        
        debugPrint(string.format("Auto %s failed after 5 attempts, trying next action...", action.name))
    end
    
    warn("All auto end game actions failed")
end

local function exportMacroToClipboard(macroName, format)
    if not macroName or macroName == "" then
        notify("Export Error", "No macro selected for export.", 3)
        return
    end
    
    local macroData = MacroManager.macros[macroName]
    if not macroData or #macroData == 0 then
        notify("Export Error", "Selected macro is empty.", 3)
        return
    end
    
    -- Try different clipboard functions
    local setclipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    
    if not setclipboard then
        notify("Clipboard Error", "Your executor doesn't support clipboard.", 3)
        return
    end
    
    -- Export just the raw actions array (no metadata wrapper)
    local success, jsonData = pcall(function()
        return Services.HttpService:JSONEncode(macroData)
    end)
    
    if not success then
        notify("Export Error", "Failed to encode macro.", 3)
        return
    end
    
    success = pcall(function()
        setclipboard(jsonData)
    end)
    
    if success then
        notify("Export Success", "'" .. macroName .. "' copied to clipboard!", 3)
    else
        notify("Clipboard Error", "Failed to copy to clipboard.", 3)
    end
end

local function importMacroFromURL(url, macroName)
    local requestFunc = (syn and syn.request) or 
                        (http and http.request) or 
                        (http_request) or 
                        request
    
    if not requestFunc then
        notify("HTTP Error", "Your executor doesn't support HTTP requests.", 3)
        return
    end
    
    notify("Importing", "Downloading from URL...", 2)
    
    local success, response = pcall(function()
        return requestFunc({
            Url = url,
            Method = "GET"
        })
    end)
    
    if not success or not response or response.StatusCode ~= 200 then
        notify("Import Error", "Failed to download from URL.", 3)
        return
    end
    
    importMacroFromContent(response.Body, macroName)
end

local function importMacroFromContent(jsonContent, macroName)
    if not jsonContent or jsonContent:match("^%s*$") then
        notify("Import Error", "Content is empty.", 3)
        return
    end
    
    local success, decodedData = pcall(function()
        return Services.HttpService:JSONDecode(jsonContent)
    end)
    
    if not success then
        notify("Import Error", "Invalid JSON format.", 3)
        return
    end
    
    -- Extract macro data
    local importedActions = nil
    local importedName = macroName
    
    -- Check if it has the export wrapper format
    if decodedData.actions and type(decodedData.actions) == "table" then
        importedActions = decodedData.actions
        -- Priority: provided macroName > macroName from JSON > fallback
        if not macroName or macroName == "" then
            importedName = decodedData.macroName or ("ImportedMacro_" .. os.time())
        end
    -- Or if it's a raw action array
    elseif type(decodedData) == "table" and #decodedData > 0 then
        importedActions = decodedData
        -- Use provided macroName or fallback
        if not macroName or macroName == "" then
            importedName = "ImportedMacro_" .. os.time()
        end
    else
        notify("Import Error", "Unrecognized macro format.", 3)
        return
    end
    
    if not importedActions or #importedActions == 0 then
        notify("Import Error", "Macro has no actions.", 3)
        return
    end
    
    -- Clean the macro name
    importedName = importedName:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    
    if importedName == "" then
        importedName = "ImportedMacro_" .. os.time()
    end
    
    -- Check if macro already exists
    if MacroManager.macros[importedName] then
        notify("Import Cancelled", "'" .. importedName .. "' already exists.", 3)
        return
    end
    
    -- Save the imported macro
    MacroManager.macros[importedName] = importedActions
    saveMacroToFile(importedName, importedActions)
    
    -- Store name for later dropdown refresh
    MacroManager.currentMacroName = importedName
    MacroManager.currentMacro = importedActions
    
    notify("Import Success", "'" .. importedName .. "' imported (" .. #importedActions .. " actions)!", 3)
end

local function importMacroFromTXT(txtContent, macroName)
    if not txtContent or txtContent:match("^%s*$") then
        notify("Import Error", "Content is empty.", 3)
        return
    end
    
    local actions = {}
    
    for line in txtContent:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        
        if line ~= "" and not line:match("^#") then
            local parts = {}
            for part in line:gmatch("%S+") do
                table.insert(parts, part)
            end
            
            if #parts >= 3 then
                local actionType = parts[1]
                
                if actionType == "spawn_unit" then
                    local unit = parts[2] .. " " .. parts[3]
                    local time = tonumber(parts[4])
                    local x, y, z = parts[5]:match("([^,]+),([^,]+),([^,]+)")
                    
                    if time and x and y and z then
                        table.insert(actions, {
                            Type = "spawn_unit",
                            Unit = unit,
                            Time = string.format("%.2f", time),
                            Position = {tonumber(x), tonumber(y), tonumber(z)}
                        })
                    end
                    
                elseif actionType == "upgrade_unit" then
                    local unit = parts[2] .. " " .. parts[3]
                    local time = tonumber(parts[4])
                    
                    if time then
                        table.insert(actions, {
                            Type = "upgrade_unit",
                            Unit = unit,
                            Time = string.format("%.2f", time)
                        })
                    end
                    
                elseif actionType == "sell_unit" then
                    local unit = parts[2] .. " " .. parts[3]
                    local time = tonumber(parts[4])
                    
                    if time then
                        table.insert(actions, {
                            Type = "sell_unit",
                            Unit = unit,
                            Time = string.format("%.2f", time)
                        })
                    end
                    
                elseif actionType == "use_ability" then
                    local unit = parts[2] .. " " .. parts[3]
                    local abilitySlot = parts[4]
                    local time = tonumber(parts[5])
                    
                    if time then
                        table.insert(actions, {
                            Type = "use_ability",
                            Unit = unit,
                            AbilitySlot = abilitySlot,
                            Time = string.format("%.2f", time)
                        })
                    end
                end
            end
        end
    end
    
    if #actions == 0 then
        notify("Import Error", "No valid actions found in TXT.", 3)
        return
    end
    
    -- Use provided macroName or fallback
    local cleanedName = ""
    if macroName and macroName ~= "" then
        cleanedName = macroName:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    end
    
    if cleanedName == "" then
        cleanedName = "ImportedTXT_" .. os.time()
    end
    
    MacroManager.macros[cleanedName] = actions
    saveMacroToFile(cleanedName, actions)
    
    -- Store name for later dropdown refresh
    MacroManager.currentMacroName = cleanedName
    MacroManager.currentMacro = actions
    
    notify("Import Success", "'" .. cleanedName .. "' imported from TXT (" .. #actions .. " actions)!", 3)
end

local function setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()
end

local function clearProcessingState()
    AutoJoinState.isProcessing = false
    AutoJoinState.currentAction = nil
end

local function doesChallengePassFilters(challengeFolder, challengeType)
    if not challengeFolder or not challengeFolder:IsA("Folder") then
        return false
    end
    
    -- Get challenge data
    local stageNameObj = challengeFolder:FindFirstChild("StageName")
    local modifierObj = challengeFolder:FindFirstChild("Modifier")
    local rewardsFolder = challengeFolder:FindFirstChild("Rewards")
    
    if not stageNameObj then
        return false
    end
    
    -- Check if challenge type matches selection
    if State.ChallengeStageSelected and State.ChallengeStageSelected ~= "" then
        if challengeType ~= State.ChallengeStageSelected then
            debugPrint(string.format("Challenge type %s doesn't match filter %s", challengeType, State.ChallengeStageSelected))
            return false
        end
    end
    
    -- Check if world is in ignore list
    if State.IgnoreWorlds and #State.IgnoreWorlds > 0 then
        local stageName = stageNameObj.Value
        
        -- Check against internal names in ignore list
        for _, ignoredWorld in ipairs(State.IgnoreWorlds) do
            if stageName == ignoredWorld then
                debugPrint(string.format("Challenge world %s is in ignore list", stageName))
                return false
            end
        end
    end
    
    -- Check if modifier is in ignore list
    if State.IgnoreModifiers and #State.IgnoreModifiers > 0 and modifierObj then
        local modifierValue = modifierObj.Value
        if modifierValue and modifierValue ~= "" then
            for _, ignoredModifier in ipairs(State.IgnoreModifiers) do
                if modifierValue == ignoredModifier then
                    debugPrint(string.format("Challenge modifier %s is in ignore list", modifierValue))
                    return false
                end
            end
        end
    end
    
    -- Check if rewards match filter
    if State.ChallengeRewardsFilter and #State.ChallengeRewardsFilter > 0 and rewardsFolder then
        local hasMatchingReward = false
        
        -- Loop through reward items in the Rewards folder
        for _, rewardObj in pairs(rewardsFolder:GetChildren()) do
            local rewardName = rewardObj.Name
            
            -- Check if this reward is in our filter
            for _, filteredReward in ipairs(State.ChallengeRewardsFilter) do
                -- Match exact name or if the reward name contains the filter
                -- e.g., "BlueEssence" matches "Blue Essence"
                local normalizedReward = filteredReward:gsub(" ", "")
                if rewardName == filteredReward or 
                   rewardName == normalizedReward or 
                   rewardName:find(filteredReward) or
                   filteredReward:find(rewardName) then
                    hasMatchingReward = true
                    debugPrint(string.format("Found matching reward: %s", rewardName))
                    break
                end
            end
            
            if hasMatchingReward then
                break
            end
        end
        
        if not hasMatchingReward then
            debugPrint("Challenge rewards don't match filter")
            return false
        end
    end
    
    return true
end

local function isChallengeCompleted(challengeType, challengeFolder)
    if not challengeFolder or not challengeFolder:IsA("Folder") then
        return true -- Skip if invalid
    end
    
    -- Get challenge data we need to match
    local stageNameObj = challengeFolder:FindFirstChild("StageName")
    local actObj = challengeFolder:FindFirstChild("Act")
    local stageTypeObj = challengeFolder:FindFirstChild("StageType")
    
    if not stageNameObj or not actObj or not stageTypeObj then
        return true -- Skip if missing data
    end
    
    local targetStageNameInternal = stageNameObj.Value
    local targetAct = "Act " .. tostring(actObj.Value)
    local targetStageType = stageTypeObj.Value
    
    -- Convert internal stage name to display name
    local targetStageNameDisplay = targetStageNameInternal
    
    -- First try to find it in StageDataCache
    for category, worlds in pairs(StageDataCache) do
        for internalName, worldData in pairs(worlds) do
            if internalName == targetStageNameInternal then
                targetStageNameDisplay = worldData.displayName
                debugPrint(string.format("Converted stage name: %s -> %s", targetStageNameInternal, targetStageNameDisplay))
                break
            end
        end
        if targetStageNameDisplay ~= targetStageNameInternal then
            break
        end
    end
    
    -- If not found in cache, try to get it from StageData modules
    if targetStageNameDisplay == targetStageNameInternal then
        pcall(function()
            local stageDataFolder = Services.ReplicatedStorage.Modules.Shared.Data.StageData
            local worldModule = stageDataFolder:FindFirstChild(targetStageNameInternal)
            if worldModule and worldModule:IsA("ModuleScript") then
                local worldData = require(worldModule)
                if worldData.StageName then
                    targetStageNameDisplay = worldData.StageName
                    debugPrint(string.format("Converted stage name from module: %s -> %s", targetStageNameInternal, targetStageNameDisplay))
                else
                    -- Fallback: format the internal name
                    targetStageNameDisplay = targetStageNameInternal:gsub("_", " ")
                    debugPrint(string.format("Formatted stage name: %s -> %s", targetStageNameInternal, targetStageNameDisplay))
                end
            end
        end)
    end
    
    debugPrint(string.format("Checking completion for: %s - %s (%s)", challengeType, targetStageNameDisplay, targetAct))
    
    -- Fire the appropriate button based on challenge type
    local success = pcall(function()
        local podsUI = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Pods")
        if not podsUI then return end
        
        local challengeSelection = podsUI:FindFirstChild("ChallengeSelection")
        if not challengeSelection then return end
        
        local buttonPath = nil
        if challengeType == "Daily" then
            buttonPath = challengeSelection.List.DailyChallenges.Content.ChallengeHolder.Btn
        elseif challengeType == "Weekly" then
            buttonPath = challengeSelection.List.WeeklyChallenges.Content.ChallengeHolder.Btn
        elseif challengeType == "Regular" then
            buttonPath = challengeSelection.List.RegularChallenges.Content.ChallengeHolder.Btn
        end
        
        if buttonPath then
            for _, connection in pairs(getconnections(buttonPath.MouseButton1Up)) do
                connection:Fire()
            end
            task.wait(0.3) -- Wait for UI to update
        end
    end)
    
    if not success then
        warn("Failed to fire challenge button")
        return false -- Assume not completed if we can't check
    end
    
    -- Check the Quests folder for completed challenges
    local questsFolder = nil
    success = pcall(function()
        questsFolder = Services.Players.LocalPlayer.PlayerGui.Pods.ChallengeSelection.Quests
    end)
    
    if not success or not questsFolder then
        warn("Could not access Quests folder")
        return false
    end
    
    -- Check all ChallengeEX frames
    for _, frame in pairs(questsFolder:GetChildren()) do
        if frame.Name == "ChallengeEX" and frame:IsA("Frame") then
            local claimed = frame:FindFirstChild("Claimed")
            local info = frame:FindFirstChild("Info")
            
            if claimed and info then
                -- Check if this challenge matches our target
                local actFrame = info:FindFirstChild("Act")
                local stageNameFrame = info:FindFirstChild("StageName")
                local stageTypeFrame = info:FindFirstChild("StageType")
                
                if actFrame and stageNameFrame and stageTypeFrame then
                    local actText = actFrame:FindFirstChild("MainContent") and 
                                   actFrame.MainContent:FindFirstChild("Txt") and 
                                   actFrame.MainContent.Txt.Text
                    local stageNameText = stageNameFrame:FindFirstChild("MainContent") and 
                                         stageNameFrame.MainContent:FindFirstChild("Txt") and 
                                         stageNameFrame.MainContent.Txt.Text
                    local stageTypeText = stageTypeFrame:FindFirstChild("MainContent") and 
                                         stageTypeFrame.MainContent:FindFirstChild("Txt") and 
                                         stageTypeFrame.MainContent.Txt.Text
                    
                    debugPrint(string.format("Checking frame - Act: %s, Stage: %s, Type: %s", 
                        tostring(actText), tostring(stageNameText), tostring(stageTypeText)))
                    
                    -- Match the challenge using display name
                    if actText == targetAct and 
                       stageNameText == targetStageNameDisplay then
                        
                        local isCompleted = claimed.Visible
                        debugPrint(string.format("Challenge match found - Completed: %s", tostring(isCompleted)))
                        return isCompleted
                    end
                end
            end
        end
    end
    
    debugPrint("No matching challenge found - assuming not completed")
    return false
end

local function findAndJoinChallenge()
    local challengesFolder = Services.ReplicatedStorage:FindFirstChild("Challenges")
    if not challengesFolder then
        warn("Challenges folder not found!")
        return false
    end
    
    -- Loop through Daily, Weekly, Regular folders
    for _, typeFolder in pairs(challengesFolder:GetChildren()) do
        if typeFolder:IsA("Folder") then
            local challengeType = typeFolder.Name -- "Daily", "Weekly", or "Regular"
            
            -- Loop through numbered challenge folders (1, 2, 3, etc.)
            for _, challengeFolder in pairs(typeFolder:GetChildren()) do
                if challengeFolder:IsA("Folder") and doesChallengePassFilters(challengeFolder, challengeType) then
                    
                    -- Check if challenge is already completed
                    if isChallengeCompleted(challengeType, challengeFolder) then
                        debugPrint(string.format("Skipping completed %s challenge", challengeType))
                        continue
                    end
                    
                    -- Get challenge data
                    local idObj = challengeFolder:FindFirstChild("ID")
                    local stageNameObj = challengeFolder:FindFirstChild("StageName")

                    local actObj = challengeFolder:FindFirstChild("Act")
                    local stageTypeObj = challengeFolder:FindFirstChild("StageType")
                    local challengeNameObj = challengeFolder:FindFirstChild("ChallengeName")
                    
                    if not idObj or not stageNameObj or not actObj then
                        warn("Challenge missing required data: " .. challengeFolder.Name)
                        continue
                    end
                    
                    local id = idObj.Value
                    local stageName = stageNameObj.Value
                    local act = tostring(actObj.Value)
                    local stageType = stageTypeObj and stageTypeObj.Value or "Story"
                    local challengeName = challengeNameObj and challengeNameObj.Value or challengeFolder.Name
                    
                    debugPrint(string.format("Found valid uncompleted challenge: %s (%s) - Stage: %s, Act: %s, ID: %s", 
                        challengeName, challengeType, stageName, act, tostring(id)))
                    
                    -- Join the challenge
                    local success = pcall(function()
                        Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer(
                            "Create",
                            stageName,
                            stageType,
                            act,
                            false,
                            "Normal",
                            {
                                ID = id,
                                Type = challengeType
                            }
                        )
                        --Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Start")
                    end)
                    
                    if success then
                        notify("Challenge Started", string.format("Joined %s challenge: %s", challengeType, challengeName), 3)
                        return true
                    else
                        warn("Failed to join challenge")
                        return false
                    end
                end
            end
        end
    end
    
    debugPrint("All matching challenges are completed or no valid challenges found")
    notify("All Challenges Complete", "Moving to next auto-join option", 3)
    return false
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    --if not tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown then return end

    if State.AutoJoinChallenge then
        setProcessingState("Challenge Auto Join")
        
        local success = findAndJoinChallenge()
        
        if success then
            debugPrint("Successfully joined challenge")
        else
            debugPrint("No valid challenges found")
        end
        
        task.delay(5, clearProcessingState)
        return
    end

-- STORY
if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and State.StoryDifficultySelected then
    setProcessingState("Story Auto Join")

    debugPrint("storystage: " .. tostring(State.StoryStageSelected) .. " storyact: " .. tostring(State.StoryActSelected) .. " storydiff: " .. tostring(State.StoryDifficultySelected))

    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Create", tostring(State.StoryStageSelected), "Story", tostring(State.StoryActSelected), true, tostring(State.StoryDifficultySelected), nil)
    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Start")

    task.delay(5, clearProcessingState)
    return
end

-- LEGEND STAGE
if State.AutoJoinLegendStage and State.LegendStageSelected and State.LegendActSelected then
    setProcessingState("Legend Stage Auto Join")

    debugPrint("legendstage: " .. tostring(State.LegendStageSelected) .. " legendact: " .. tostring(State.LegendActSelected))

    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Create", tostring(State.LegendStageSelected), "Legend", tostring(State.LegendActSelected), true, "Normal", nil)
    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Start")

    task.delay(5, clearProcessingState)
    return
end

-- RAID
if State.AutoJoinRaid and State.RaidStageSelected and State.RaidActSelected then
    setProcessingState("Raid Auto Join")

    debugPrint("raidstage: " .. tostring(State.RaidStageSelected) .. " raidact: " .. tostring(State.RaidActSelected))

    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Create", tostring(State.RaidStageSelected), "Raid", tostring(State.RaidActSelected), true, "Normal", nil)
    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Start")

    task.delay(5, clearProcessingState)
    return
end

-- SIEGE
if State.AutoJoinSiege and State.SiegeStageSelected and State.SiegeActSelected then
    setProcessingState("Siege Auto Join")

    debugPrint("siegestage: " .. tostring(State.SiegeStageSelected) .. " siegeact: " .. tostring(State.SiegeActSelected))

    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Create", tostring(State.SiegeStageSelected), "Siege", tostring(State.SiegeActSelected), true, "Normal", nil)
    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Start")

    task.delay(5, clearProcessingState)
    return
end

-- CHALLENGE
if State.AutoJoinChallenge and State.ChallengeStageSelected and State.ChallengeActSelected then
    setProcessingState("Challenge Auto Join")

    debugPrint("challenge: " .. tostring(State.ChallengeStageSelected) .. " challengeact: " .. tostring(State.ChallengeActSelected) .. " challengetype: " .. tostring(State.ChallengeTypeSelected))

    -- ID = 1 is challenge id that we want to join
    -- type is the challenge type (Weekly,Daily,Regular)
    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Create","Leaf_Village","Story","5",false,"Normal",{ID = 1,Type = "Daily"})
    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Pod"):FireServer("Start")

    task.delay(5, clearProcessingState)
    return
end
end

local function loadStageData()
    local stageDataFolder = Services.ReplicatedStorage.Modules.Shared.Data.StageData
    
    if not stageDataFolder then
        warn("StageData folder not found")
        return false
    end
    
    local success, err = pcall(function()
        -- Clear cache
        for category in pairs(StageDataCache) do
            StageDataCache[category] = {}
        end
        
        -- Load all worlds
        for _, worldModule in pairs(stageDataFolder:GetChildren()) do
            if worldModule.Name == "Templates" or not worldModule:IsA("ModuleScript") then continue end
            
            -- Require the world module to get display name (StageName field)
            local worldSuccess, worldData = pcall(require, worldModule)
            if not worldSuccess then continue end
            
            -- Use StageName from module or fallback to formatted folder name
            local worldDisplayName = worldData.StageName or worldModule.Name:gsub("_", " ")
            local worldInternalName = worldModule.Name
            
            debugPrint(string.format("Found world: %s (Display: %s)", worldInternalName, worldDisplayName))
            
            -- Check each category folder within this world
            for _, categoryFolder in pairs(worldModule:GetChildren()) do
                if not categoryFolder:IsA("Folder") then continue end
                
                local category = categoryFolder.Name:lower()
                
                -- Only process if it's a valid category
                if category == "story" or category == "legend" or category == "raid" or category == "siege" or category == "challenge" then
                    local acts = {}
                    
                    -- Load acts from this category folder
                    for _, actModule in pairs(categoryFolder:GetChildren()) do
                        if actModule:IsA("ModuleScript") then
                            local success2, actData = pcall(require, actModule)
                            if success2 and actData and actData.Name then
                                table.insert(acts, {
                                    displayName = actData.Name,
                                    internalName = actModule.Name
                                })
                            end
                        end
                    end
                    
                    -- Only add this world to the category if it has acts
                    if #acts > 0 then
                        StageDataCache[category][worldInternalName] = {
                            displayName = worldDisplayName,
                            internalName = worldInternalName,
                            acts = acts
                        }
                        debugPrint(string.format("  Added %s: %s with %d acts", category, worldDisplayName, #acts))
                    end
                end
            end
        end
    end)
    
    if not success then
        warn("Error loading stage data:", err)
        return false
    end
    
    debugPrint("✓ Stage data loaded")
    return true
end

-- Function to check for new challenges (runs every hour at xx:00)
local function checkForNewChallenges()
    local currentTime = os.time()
    local currentDate = os.date("*t", currentTime)
    
    -- Check if we're at the start of a new hour (within first 2 minutes)
    if currentDate.min <= 1 and currentTime - State.LastChallengeCheckTime > 300 then
        State.LastChallengeCheckTime = currentTime
        State.NewChallengeDetected = true
        debugPrint("New hour detected - new challenges may be available")
        notify("New Challenges", "New challenges may be available!", 3)
    end
end

Button = LobbyTab:CreateButton({
   Name = "Return to lobby",
   Callback = function()
        Services.TeleportService:Teleport(76806550943352, Services.Players.LocalPlayer)
   end,
})

        LobbyTab:CreateToggle({
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

   Toggle = LobbyTab:CreateToggle({
   Name = "Disable Script Notifications",
   CurrentValue = false,
   Flag = "DisableScriptNotifications",
   Callback = function(Value)
   State.DisableNotifications = Value
   end,
})

JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoJoinStory",
    Callback = function(Value)
        State.AutoJoinStory = Value
    end,
})

local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Story - Select Stage",
    Options = {},
    CurrentOption = {},
    Flag = "StoryStageDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        
        -- Find internal name
        for _, world in pairs(StageDataCache.story) do
            if world.displayName == name then
                State.StoryStageSelected = world.internalName
            end
        end
    end,
})

local StoryActDropdown = JoinerTab:CreateDropdown({
    Name = "Story - Select Act",
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinite"},
    CurrentOption = {},
    Flag = "StoryActDropdown",
    Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            if selectedOption == "Infinite" then
                State.StoryActSelected = "Infinite"
            else
                local num = selectedOption:match("%d+")
            if num then
                State.StoryActSelected = num
            end
        end
    end,
})

local StoryDifficultyDropdown = JoinerTab:CreateDropdown({
    Name = "Story - Select Difficulty",
    Options = {"Normal", "Nightmare"},
    CurrentOption = {},
    Flag = "StoryDifficultyDropdown",
    Callback = function(selected)
        State.StoryDifficultySelected = type(selected) == "table" and selected[1] or selected
    end,
})

JoinerTab:CreateDivider()

JoinerTab:CreateToggle({
    Name = "Auto Join Legend Stage",
    CurrentValue = false,
    Flag = "AutoJoinLegendStage",
    Callback = function(Value)
        State.AutoJoinLegendStage = Value
    end,
})

local LegendStageDropdown = JoinerTab:CreateDropdown({
    Name = "Legend - Select Stage",
    Options = {},
    CurrentOption = {},
    Flag = "LegendStageDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        
        for _, world in pairs(StageDataCache.legend) do
            if world.displayName == name then
                State.LegendStageSelected = world.internalName
            end
        end
    end,
})

local LegendActDropdown = JoinerTab:CreateDropdown({
    Name = "Legend - Select Act",
    Options = {"Act 1", "Act 2", "Act 3"},
    CurrentOption = {},
    Flag = "LegendActDropdown",
    Callback = function(selected)
        local selectedOption = type(selected) == "table" and selected[1] or selected
            
            local num = selectedOption:match("%d+")
            if num then
                State.LegendStageActSelected = num
        end
    end,
})

JoinerTab:CreateDivider()

JoinerTab:CreateToggle({
    Name = "Auto Join Raid",
    CurrentValue = false,
    Flag = "AutoJoinRaid",
    Callback = function(Value)
        State.AutoJoinRaid = Value
    end,
})

local RaidStageDropdown = JoinerTab:CreateDropdown({
    Name = "Raid - Select Stage",
    Options = {},
    CurrentOption = {},
    Flag = "RaidStageDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        
        for _, world in pairs(StageDataCache.raid) do
            if world.displayName == name then
                State.RaidStageSelected = world.internalName
            end
        end
    end,
})

local RaidActDropdown = JoinerTab:CreateDropdown({
    Name = "Raid - Select Act",
    Options = {"Act 1", "Act 2", "Act 3"},
    CurrentOption = {},
    Flag = "RaidActDropdown",
    Callback = function(selected)
        local selectedOption = type(selected) == "table" and selected[1] or selected
            
            local num = selectedOption:match("%d+")
            if num then
                State.RaidActSelected = num
            end
    end,
})

JoinerTab:CreateDivider()

JoinerTab:CreateToggle({
    Name = "Auto Join Siege",
    CurrentValue = false,
    Flag = "AutoJoinSiege",
    Callback = function(Value)
        State.AutoJoinSiege = Value
    end,
})

local SiegeStageDropdown = JoinerTab:CreateDropdown({
    Name = "Siege - Select Stage",
    Options = {},
    CurrentOption = {},
    Flag = "SiegeStageDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        
        for _, world in pairs(StageDataCache.siege) do
            if world.displayName == name then
                State.SiegeStageSelected = world.internalName
            end
        end
    end,
})

local SiegeActDropdown = JoinerTab:CreateDropdown({
    Name = "Siege - Select Act",
    Options = {"Act 1"},
    CurrentOption = {},
    Flag = "SiegeActDropdown",
    Callback = function(selected)
        local selectedOption = type(selected) == "table" and selected[1] or selected
            
            local num = selectedOption:match("%d+")
            if num then
                State.SiegeActSelected = num
            end
    end,
})

JoinerTab:CreateDivider()

JoinerTab:CreateToggle({
    Name = "Auto Join Challenge",
    CurrentValue = false,
    Flag = "AutoJoinChallenge",
    Callback = function(Value)
        State.AutoJoinChallenge = Value
    end,
})

ChallengeStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Challenge Stage",
    Options = {"Regular", "Daily", "Weekly"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ChallengeStageDropdown",
    Callback = function(selected)
        State.ChallengeStageSelected = selected[1]
    end,
})

ChallengeRewardsDropdown = JoinerTab:CreateDropdown({
    Name = "Select Challenge Rewards",
    Options = {"Red Essence", "Blue Essence", "Green Essence", "Yellow Essence", "Purple Essence", "Pink Essence", "Rainbow Essence","Stat Chip","Super Stat Chip","Trait Rerolls","Gold","Gems"},
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
        State.IgnoreWorlds = {}
        
        -- Convert display names to internal names
        for _, displayName in ipairs(Options or {}) do
            -- Find the internal name from StageDataCache
            for internalName, worldData in pairs(StageDataCache.story) do
                if worldData.displayName == displayName then
                    table.insert(State.IgnoreWorlds, internalName)
                    break
                end
            end
        end
        
        debugPrint("Ignore worlds updated: " .. table.concat(State.IgnoreWorlds, ", "))
    end,
})

ReturnToLobbyOnNewChallenge = JoinerTab:CreateToggle({
    Name = "Return to Lobby on New Challenge",
    CurrentValue = false,
    Flag = "ReturnToLobbyOnNewChallenge",
    Info = "Return to lobby when new challenge appears instead of using retry/next",
    Callback = function(Value)
        State.ReturnToLobbyOnNewChallenge = Value
    end,
})

JoinerTab:CreateDivider()

     Toggle = GameTab:CreateToggle({
    Name = "Anti AFK (No kick message)",
    CurrentValue = false,
    Flag = "AntiAfkKickToggle",
    Info = "Prevents roblox kick message.",
    TextScaled = false,
    Callback = function(Value)
        State.AntiAfkKickEnabled = Value
        if Value then
            if game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("TPAFK") then
                game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("TPAFK"):Destroy()
            end
        end
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

local AutoStartGameToggle = GameTab:CreateToggle({
   Name = "Auto Start Game",
   CurrentValue = false,
   Flag = "AutoStartGame",
   Callback = function(Value)
       State.AutoStartGame = Value
   end,
})

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

local AutoSkipWavesToggle = GameTab:CreateToggle({
   Name = "Auto Skip Waves",
   CurrentValue = false,
   Flag = "AutoSkipWaves",
   Callback = function(Value)
    if not isInLobby() then
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeSetting"):FireServer("AutoSkipWaves",Value)
        end
   end,
})

local RemoveGamePopupsToggle = GameTab:CreateToggle({
   Name = "Disable game popups",
   CurrentValue = false,
   Flag = "RemoveGamePopups",
   Callback = function(Value)
        if Value then
            if not isInLobby() then
                game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("ViewNew"):Destroy()
            end
        end
   end,
})

local ReturnToLobbyFailsafeToggle = GameTab:CreateToggle({
   Name = "Return to Lobby Failsafe",
   CurrentValue = false,
   Flag = "ReturnToLobbyFailsafe",
   Info = "Teleports to lobby if game doesn't start within 1 minute after retry/next",
   Callback = function(Value)
       State.ReturnToLobbyFailsafe = Value
   end,
})

local MacroDropdown = MacroTab:CreateDropdown({
    Name = "Select Macro",
    Options = {},
    CurrentOption = {},
    Flag = "MacroDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        MacroManager.currentMacroName = name
        
        if name and MacroManager.macros[name] then
            MacroManager.currentMacro = MacroManager.macros[name]
            notify("Macro Selected", string.format("Selected macro: %s (%d actions)", name, #MacroManager.currentMacro), 2)
            updateMacroStatus(string.format("Selected: %s", name))
        end
    end,
})

local MacroInput = MacroTab:CreateInput({
    Name = "Create New Macro",
    PlaceholderText = "Enter macro name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        
        if cleanedName == "" then
            notify("Invalid Name", "Macro name cannot be empty or just spaces.", 3)
            return
        end
        
        if MacroManager.macros[cleanedName] then
            notify("Duplicate Name", "A macro with this name already exists.", 3)
            return
        end
        
        -- Create empty macro
        MacroManager.macros[cleanedName] = {}
        saveMacroToFile(cleanedName, {})
        
        -- Refresh dropdown and select new macro
        MacroDropdown:Refresh(getMacroList(), cleanedName)

        notify("Macro Created", "Created macro: " .. cleanedName, 3)
    end,
})

MacroTab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        loadAllMacros()
        MacroDropdown:Refresh(getMacroList())

        notify("Refreshed", "Macro list updated", 2)
    end,
})

MacroTab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if not MacroManager.currentMacroName or MacroManager.currentMacroName == "" then
            notify("No Selection", "Please select a macro to delete.", 3)
            return
        end

        if isfile(getMacroFilename(MacroManager.currentMacroName)) then
            delfile(getMacroFilename(MacroManager.currentMacroName))
        end

        MacroManager.macros[MacroManager.currentMacroName] = nil

        notify("Deleted", "Deleted macro: " .. MacroManager.currentMacroName, 3)

        local list = getMacroList()

        if #list == 0 then
        MacroManager.currentMacroName = nil
        MacroManager.currentMacro = nil
        MacroDropdown:Refresh(getMacroList())
        MacroDropdown:Set("")
        updateMacroStatus("Ready")
    else
        MacroManager.currentMacroName = list[1]
        MacroManager.currentMacro = MacroManager.macros[list[1]]
        MacroDropdown:Refresh(getMacroList())
        MacroDropdown:Set(list[1])
        updateMacroStatus("Selected: " .. list[1])
        end
    end,
})

RecordToggle = MacroTab:CreateToggle({
   Name = "Record Macro",
   CurrentValue = false,
   Flag = "RecordToggle",
   Callback = function(Value)
        if Value then
            -- Check if macro is selected
            if not MacroManager.currentMacroName or MacroManager.currentMacroName == "" then
                notify("Recording Error", "Please select a macro first!")
                RecordToggle:Set(false)
                return
            end

            if not waitForLoadout() then
                notify("Recording Warning", "Could not load unit data", 4)
            end
            
            -- Wait for client to be fully loaded
            if not waitForClientLoaded() then
                notify("Recording Warning", "Client data may not be fully loaded", 4)
            end
            
            local currentWave = 0
            pcall(function()
                currentWave = Services.ReplicatedStorage.GameConfig.Wave.Value
            end)
            
            debugPrint(string.format("Recording enabled - Current wave: %d", currentWave))
            
            -- Auto-skip intermission to start game
            autoStartGame()
            
            -- If mid-game, start recording immediately
            if currentWave >= 1 then
                MacroState.isRecording = true
                MacroState.recordingHasStarted = true
                MacroState.gameInProgress = true
                recordingUnitCounter = {}
                recordingInstanceToTag = {}
                MacroState.currentMacro = {}
                
                updateMacroStatus("Recording from Wave " .. currentWave)
                updateDetailedStatus("Recording in progress")
                
                notify("Recording Started", "Recording from wave " .. currentWave)
            else
                -- Wait for game to start
                MacroState.isRecording = true
                MacroState.recordingHasStarted = false
                
                updateMacroStatus("Recording enabled - Starting game...")
                updateDetailedStatus("Skipping intermission...")
                
                notify("Recording Ready", "Recording will start at wave 1")
            end
        else
            -- Stop recording
            if MacroState.recordingHasStarted then
                local actionCount = #MacroState.currentMacro
                stopRecording()
                
                notify("Recording Stopped", string.format("Saved %d actions", actionCount))
            else
                MacroState.isRecording = false
                updateMacroStatus("Ready")
                updateDetailedStatus("Recording cancelled")
            end
            
            MacroState.isRecording = false
            MacroState.recordingHasStarted = false
            
            updateMacroStatus("Ready")
            updateDetailedStatus("Ready")
        end
   end,
})

PlaybackToggle = MacroTab:CreateToggle({
   Name = "Playback Macro",
   CurrentValue = false,
   Flag = "PlaybackToggle",
   Callback = function(Value)
        if Value then
            task.wait(0.1)
            
            -- Check if macro is selected
            if not MacroManager.currentMacroName or MacroManager.currentMacroName == "" then
                notify("Playback Error", "Please select a macro first!")
                --PlaybackToggle:Set(false)
                return
            end
            
            -- Load the macro
            local loadedMacro = loadMacroFromFile(MacroManager.currentMacroName)
            
            if not loadedMacro or #loadedMacro == 0 then
                notify("Playback Error", "Macro is empty or doesn't exist")
                --PlaybackToggle:Set(false)
                return
            end

            if not waitForLoadout() then
                notify("Playback Error", "Could not load unit data", 4)
                --PlaybackToggle:Set(false)
                return
            end
            
            -- Wait for client to be fully loaded
            if not waitForClientLoaded() then
                notify("Playback Warning", "Client data may not be fully loaded", 4)
            end
            
            -- Validate macro
            local isValid, validationMessage = validateMacro(loadedMacro)
            if not isValid then
                notify("Playback Error", validationMessage, 6)
                --PlaybackToggle:Set(false)
                return
            end
            
            if MacroState.playbackLoopRunning then
                debugPrint("Playback loop already running")
                return
            end
            
            MacroState.currentMacro = loadedMacro
            MacroState.isPlaybackEnabled = true
            
            updateMacroStatus("Playback Enabled - Starting game...")
            notify("Playback Enabled", "Macro will playback: " .. MacroManager.currentMacroName)
            
            -- Auto-skip intermission to start game
            autoStartGame()
            
            -- Start the playback loop
            task.spawn(autoPlaybackLoop)
        else
            -- Stop playback
            MacroState.isPlaybackEnabled = false
            cancelAllThreads()

            if MacroState.playbackLoopThread then
    pcall(function()
        task.cancel(MacroState.playbackLoopThread)
    end)
    MacroState.playbackLoopThread = nil
end

MacroState.playbackLoopRunning = false
            
            -- Wait for loop to stop
            local timeout = 0
            while MacroState.playbackLoopRunning and timeout < 20 do
                task.wait(0.1)
                timeout = timeout + 1
            end
            
            if MacroState.playbackLoopRunning then
                warn("⚠️ Force stopping playback loop")
                MacroState.playbackLoopRunning = false
            end
            
            updateMacroStatus("Playback Disabled")
            notify("Playback Disabled", "Stopped playback loop")
        end
   end,
})

IgnoreTimingButton = MacroTab:CreateToggle({
   Name = "Ignore Timing",
   CurrentValue = false,
   Flag = "IgnoreTimingToggle",
   Callback = function(Value)
        State.ignoreTiming = Value
   end,
})

Div = MacroTab:CreateDivider()

ExportMacroJSONButton = MacroTab:CreateButton({
    Name = "Export Macro To Clipboard",
    Callback = function()
        if not MacroManager.currentMacroName or MacroManager.currentMacroName == "" then
            notify("Export Error", "No macro selected for export.", 3)
            return
        end
        exportMacroToClipboard(MacroManager.currentMacroName, "compact")
    end,
})

ExportMacroViaWebhookButton = MacroTab:CreateButton({
    Name = "Export Macro via Webhook",
    Callback = function()
        if not MacroManager.currentMacroName or MacroManager.currentMacroName == "" then
            notify("Webhook Error", "No macro selected.", 3)
            return
        end
        
        if not Config.VALID_WEBHOOK then
            notify("Webhook Error", "No webhook URL configured.", 3)
            return
        end
        
        local macroData = MacroManager.macros[MacroManager.currentMacroName]
        if not macroData or #macroData == 0 then
            notify("Webhook Error", "Selected macro is empty.", 3)
            return
        end
        
        -- Extract unique units from macro
        local unitCounts = {}
        
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit
                local baseUnitName = unitName:match("^(.+) #%d+$") or unitName
                
                if not unitCounts[baseUnitName] then
                    unitCounts[baseUnitName] = 0
                end
                unitCounts[baseUnitName] = unitCounts[baseUnitName] + 1
            end
        end
        
        -- Create units list
        local unitsList = {}
        for unitName, count in pairs(unitCounts) do
            table.insert(unitsList, unitName)
        end
        table.sort(unitsList)
        local unitsText = table.concat(unitsList, ", ")
        
        -- Create the JSON data
        local jsonData = Services.HttpService:JSONEncode(macroData)
        local fileName = MacroManager.currentMacroName .. ".json"
        
        -- Create multipart form data for file upload
        local boundary = "----WebKitFormBoundary" .. tostring(tick())
        local body = ""
        
        -- Add simple message with just units list
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. Services.HttpService:JSONEncode({
            content = "**Units:** " .. unitsText
        }) .. "\r\n"
        
        -- Add file
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. fileName .. "\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. jsonData .. "\r\n"
        body = body .. "--" .. boundary .. "--\r\n"
        
        -- Send request
        local requestFunc = (syn and syn.request) or 
                        (http and http.request) or 
                        (http_request) or 
                        request
        
        if not requestFunc then
            notify("Webhook Error", "No HTTP request function available.", 3)
            return
        end
        
        local success, result = pcall(function()
            return requestFunc({
                Url = Config.VALID_WEBHOOK,
                Method = "POST",
                Headers = { 
                    ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
                    ["User-Agent"] = "LixHub-Webhook/1.0"
                },
                Body = body
            })
        end)
        
        if success and result and result.Success and result.StatusCode and result.StatusCode >= 200 and result.StatusCode < 300 then
            notify("Webhook Success", "Macro '" .. MacroManager.currentMacroName .. "' sent!", 3)
        else
            notify("Webhook Error", "Failed to send macro.", 3)
        end
    end,
})

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
            end
            -- macroName could be nil here, import functions will handle it
            
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
                
                macroName = (jsonData and jsonData.macroName) or nil
                importMacroFromContent(text, macroName)
            else
                -- Handle TXT format - assume it's line-by-line action format
                macroName = nil -- Let TXT import use fallback
                importMacroFromTXT(text, macroName)
            end
        end
        
        -- Refresh dropdown after any import
        task.wait(0.1)
        if MacroDropdown then
            MacroDropdown:Refresh(getMacroList())
        end
    end,
})

CheckMacroUnitsButton = MacroTab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not MacroManager.currentMacroName or MacroManager.currentMacroName == "" then
            notify("No Macro Selected", "Please select a macro first", 3)
            return
        end
        
        local macro = MacroManager.macros[MacroManager.currentMacroName] or loadMacroFromFile(MacroManager.currentMacroName)
        
        if not macro or #macro == 0 then
            notify("Error", "Could not load macro", 3)
            return
        end
        
        -- Collect all unique units from macro
        local requiredUnits = {}
        for _, action in ipairs(macro) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = getUnitNameFromTag(action.Unit)
                if not requiredUnits[unitName] then
                    requiredUnits[unitName] = {
                        count = 0,
                        equipped = false,
                        slot = nil
                    }
                end
                requiredUnits[unitName].count = requiredUnits[unitName].count + 1
            end
        end
        
        if not next(requiredUnits) then
            notify("No Units", "This macro doesn't spawn any units", 3)
            return
        end
        
        -- Get equipped units with error handling
        local equipped = nil
        local success = pcall(function()
            equipped = getEquippedUnits(true)  -- Force refresh
        end)
        
        if not success or not equipped or not next(equipped) then
            notify("Error", "Could not load equipped units data", 3)
            return
        end
        
        -- Check which units are equipped
        for slot, data in pairs(equipped) do
            if data and data.Name and requiredUnits[data.Name] then
                requiredUnits[data.Name].equipped = true
                requiredUnits[data.Name].slot = slot
            end
        end
        
        -- Build result message
        local equippedList = {}
        local missingList = {}
        
        for unitName, info in pairs(requiredUnits) do
            local unitText = unitName
            if info.equipped and info.slot then
                unitText = unitText .. string.format(" (Slot %d)", info.slot)
                table.insert(equippedList, unitText)
            else
                table.insert(missingList, unitText)
            end
        end
        
        table.sort(equippedList)
        table.sort(missingList)
        
        -- Create notification message
        local message = ""
        
        if #equippedList > 0 then
            message = message .. "Equipped:\n" .. table.concat(equippedList, "\n")
        end
        
        if #missingList > 0 then
            if message ~= "" then
                message = message .. "\n\n"
            end
            message = message .. "Missing:\n" .. table.concat(missingList, "\n")
        end
        
        -- Determine title and duration
        local title = ""
        local duration = 5
        
        if #missingList > 0 then
            title = "Missing Units"
            duration = 5
        else
            title = "All Units Equipped"
            duration = 5
        end
        
        notify(title, message, duration)
    end,
})

Div2 = MacroTab:CreateDivider()

WebhookInput = WebhookTab:CreateInput({
        Name = "Input Webhook",
        CurrentValue = "",
        PlaceholderText = "Input Webhook...",
        RemoveTextAfterFocusLost = false,
        Flag = "WebhookInput",
        Callback = function(Text)
        if Text:match("^%s*(.-)%s*$") == "" then
        Config.VALID_WEBHOOK = nil
        return
        end
        if Text:match("^%s*(.-)%s*$"):match("^https://") then
        Config.VALID_WEBHOOK = Text:match("^%s*(.-)%s*$")
        else
        Config.VALID_WEBHOOK = nil
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

TestWebhookButton = WebhookTab:CreateButton({
   Name = "Test Webhook",
   Callback = function()
   if Config.VALID_WEBHOOK then
    sendWebhook("test")
   else
    notify("Webhook error", "No valid webhook URL set!")
        end
   end,
})

task.spawn(function()
    while true do
        task.wait(0.5)
        
        local success, wave = pcall(function()
            return Services.ReplicatedStorage.GameConfig.Wave.Value
        end)
        
        if not success then
            continue
        end
        
        -- Track wave changes for timing
        if wave ~= MacroState.lastWave and wave >= 1 then
            debugPrint(string.format("Wave changed: %d -> %d", MacroState.lastWave, wave))
            MacroState.currentWave = wave
            MacroState.waveStartTime = tick()
            MacroState.lastWave = wave
            
            -- Game start detection (wave 1)
            if wave == 1 and not MacroState.gameInProgress then
                MacroState.gameInProgress = true
                MacroState.gameStartTime = tick()
                MacroState.waveStartTime = tick()
                MacroState.currentWave = 1
                
                debugPrint(string.format("✓ GAME STARTED (Wave %d)", wave))
                
                -- Auto-start recording if enabled
                if MacroState.isRecording and not MacroState.recordingHasStarted then
    debugPrint("Starting recording now")
    MacroState.recordingHasStarted = true
    MacroState.recordingStartTime = tick()  -- Reset start time
    
    recordingUnitCounter = {}
    recordingInstanceToTag = {}
    MacroState.currentMacro = {}
    
    updateMacroStatus("Recording...")
    updateDetailedStatus("Recording in progress - " .. MacroManager.currentMacroName)
    
    notify("Recording Started", string.format("Wave %d - recording: %s", wave, MacroManager.currentMacroName))
end
                
                -- Playback will auto-start via the autoPlaybackLoop
                if MacroState.isPlaybackEnabled then
                    debugPrint("Game started - playback loop will start macro")
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        
        if not State.AutoStartGame then
            continue
        end

        if isInLobby() then 
            continue 
        end
        
        local success = pcall(function()
            local voteFrame = Services.Players.LocalPlayer.PlayerGui.GameHUD.VoteSkipFrame
            
            if voteFrame.Visible and voteFrame.TitleLabel.Text == "Vote Start:" then
                debugPrint("voting to start")
                autoStartGame()
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        checkAndExecuteHighestPriority()
    end
end)

task.spawn(function()
    while true do
        task.wait(1) -- Check every minute
        
        if not isInLobby() then
        if State.AutoJoinChallenge and State.ReturnToLobbyOnNewChallenge then
            checkForNewChallenges()
            end
        end
    end
end)

task.spawn(function()
    for attempt = 1, 3 do
        if loadStageData() then
            -- Populate all dropdowns
            local storyList = {}
            for _, world in pairs(StageDataCache.story) do
                table.insert(storyList, world.displayName)
            end
            table.sort(storyList)
            
            local legendList = {}
            for _, world in pairs(StageDataCache.legend) do
                table.insert(legendList, world.displayName)
            end
            table.sort(legendList)
            
            local raidList = {}
            for _, world in pairs(StageDataCache.raid) do
                table.insert(raidList, world.displayName)
            end
            table.sort(raidList)
            
            local siegeList = {}
            for _, world in pairs(StageDataCache.siege) do
                table.insert(siegeList, world.displayName)
            end
            table.sort(siegeList)
            
            StoryStageDropdown:Refresh(storyList)
            IgnoreWorldsDropdown:Refresh(storyList)
            LegendStageDropdown:Refresh(legendList)
            RaidStageDropdown:Refresh(raidList)
            SiegeStageDropdown:Refresh(siegeList)
            
            debugPrint("✓ Stage dropdowns populated")
            break
        end
        
        warn(string.format("Failed to load stages (attempt %d/3)", attempt))
        task.wait(1)
    end
end)

local success = pcall(function()
    local StageEndRemote = Services.ReplicatedStorage.Remotes.StageEnd
    
    StageEndRemote.OnClientEvent:Connect(function(eventType, stageInfo, playerStats, rewards, playerData)
        if eventType == "ShowResults" then

            if stageInfo and stageInfo.IsChallenge and stageInfo.Result == "Win" then
                State.NewChallengeDetected = true
            end

            cancelAllThreads()
            
            -- Reset game state
            MacroState.gameInProgress = false
            MacroState.gameStartTime = 0
            MacroState.waveStartTime = 0
            MacroState.currentWave = 0
            MacroState.lastWave = 0
            MacroState.scheduledAbilities = {}
            
            -- Handle recording end
            if MacroState.isRecording and MacroState.recordingHasStarted then
                local actionCount = #MacroState.currentMacro
                stopRecording()
                
                notify("Recording Stopped", string.format("Game ended - saved %d actions", actionCount))
            end
            
            if MacroState.isRecording then
                MacroState.recordingHasStarted = false
                MacroState.currentMacro = {}
                clearSpawnIdMappings()
                
                updateMacroStatus("Recording enabled - Waiting for next game...")
                updateDetailedStatus("Waiting for next game to start...")
            end
            
            -- Handle playback end
            if MacroState.isPlaybackEnabled then
                clearSpawnIdMappings()
                updateMacroStatus("Game ended - waiting for next...")
                updateDetailedStatus("Ready for next game")
                debugPrint("Game ended - playback will restart on next game")
            end
            
            -- Send webhook if enabled
            if State.SendStageCompletedWebhook and Config.VALID_WEBHOOK then
                task.spawn(function()
                    sendWebhook("game_end", stageInfo, playerStats, rewards, playerData)
                end)
            end
            
            task.spawn(function()
                task.wait(1)
                handleEndGameActions()
            end)
        end
    end)
end)

task.spawn(function()
    local InventoryRemote = Services.ReplicatedStorage.Remotes.Inventory
    
    InventoryRemote.OnClientEvent:Connect(function(eventType, unitGUID, unitData)
        if eventType == "UnitAdded" and unitData then
            -- Only send webhook if configured
            if not Config.VALID_WEBHOOK or Config.VALID_WEBHOOK == "" then
                return
            end
            
            -- Build unit display name
            local unitDisplayName = unitData.Name or "Unknown Unit"
            if unitData.Shiny then
                unitDisplayName = "[Shiny] " .. unitDisplayName
            end
            
            -- Determine rarity color based on unit
            local embedColor = unitData.Shiny and 0xFFD700 or 0x00FF00 -- Gold for shiny, green for normal
            
            -- Format unit stats
            local statsText = ""
            if unitData.Level then
                statsText = statsText .. string.format("Level: %d\n", unitData.Level)
            end
            if unitData.Trait and unitData.Trait ~= "" then
                statsText = statsText .. string.format("Trait: %s\n", unitData.Trait)
            end
            if unitData.DMG then
                statsText = statsText .. string.format("DMG: %.2f%%\n", unitData.DMG)
            end
            if unitData.HEA then
                statsText = statsText .. string.format("HEA: %.2f%%\n", unitData.HEA)
            end
            if unitData.CDR then
                statsText = statsText .. string.format("CDR: %.2f%%\n", unitData.CDR)
            end
            if unitData.RNG then
                statsText = statsText .. string.format("RNG: %.2f%%", unitData.RNG)
            end
            
            if statsText == "" then
                statsText = "No stats available"
            end
            
            -- Build webhook data
            local webhookData = {
                username = "LixHub",
                content = Config.DISCORD_USER_ID and string.format("<@%s> 🎉 **Unit Drop!**", Config.DISCORD_USER_ID) or "🎉 **Unit Drop!**",
                embeds = {{
                    title = unitDisplayName,
                    description = unitData.Shiny and "✨ You got a Shiny unit! ✨" or "New unit obtained!",
                    color = embedColor,
                    fields = {
                        { name = "Stats", value = statsText, inline = false }
                    },
                    footer = { text = "discord.gg/cYKnXE2Nf8" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            }
            
            -- Send webhook
            local payload = Services.HttpService:JSONEncode(webhookData)
            
            local requestFunc = syn and syn.request or request or http_request or 
                              (fluxus and fluxus.request) or getgenv().request
            
            if not requestFunc then
                return
            end
            
            pcall(function()
                requestFunc({
                    Url = Config.VALID_WEBHOOK,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = payload
                })
            end)
            
            debugPrint(string.format("Unit drop webhook sent: %s", unitDisplayName))
        end
    end)
end)

ensureMacroFolders()
loadAllMacros()
MacroDropdown:Refresh(getMacroList())
Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)
task.spawn(function()
    fetchPlayerLoadout()
end)

Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image = "eye-off",
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})
