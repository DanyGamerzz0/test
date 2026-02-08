if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 76806550943352 and game.PlaceId ~= 85661754644506 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.03"

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

local Config = {
    DISCORD_USER_ID = nil,
    VALID_WEBHOOK = nil,
}

local MacroManager = {
    macros = {},
    currentMacroName = nil,
    currentMacro = nil,
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
}

local recordingUnitCounter = {} -- Maps "UnitName" -> count
local recordingInstanceToTag = {} -- Maps Instance -> "UnitName #N"
local playbackUnitTagToInstance = {} -- Maps "UnitName #N" -> Instance (for playback)

local function isInLobby()
    return Services.Workspace:FindFirstChild("Lobby") or false
end

local function getCurrentWave()
    local success, wave = pcall(function()
        return Services.ReplicatedStorage.GameConfig.Wave.Value
    end)
    
    return success and wave or 0
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
    
    print(string.format("Saved macro: %s (%d actions)", name, #macroData))
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
                print(string.format("Loaded macro: %s (%d actions)", name, #data))
            end
        end
    end
end

local function getEquippedUnits()
    local equippedUnits = {}
    
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "Instance" then continue end
        
        if type(obj) == "table" then
            local reqFunc = rawget(obj, "RequestPlayerData")
            
            if type(reqFunc) == "function" then
                local success, data = pcall(function()
                    return reqFunc(obj, Services.Players.LocalPlayer)
                end)
                
                if success and data and data.EquippedUnits then
                    local equipped = data.EquippedUnits
                    local inventory = data.Inventory.Units
                    
                    for slot = 1, 6 do
                        local guid = equipped[tostring(slot)]
                        
                        if guid then
                            local unit = inventory[guid]
                            if unit then
                                equippedUnits[slot] = {
                                    GUID = guid,
                                    Name = unit.Name,
                                    Level = unit.Level
                                }
                            end
                        end
                    end
                    
                    return equippedUnits
                end
            end
        end
    end
    
    return equippedUnits
end

local function getUnitFromSlot(slot)
    local equipped = getEquippedUnits()
    return equipped[slot]
end

local function getSlotFromUnitName(unitName)
    local equipped = getEquippedUnits()
    
    for slot, data in pairs(equipped) do
        if data.Name == unitName then
            return slot
        end
    end
    
    return nil
end

local function getUnitData(unitName)
    local success, result = pcall(function()
        local module = Services.ReplicatedStorage.Modules.Shared.Data.UnitData.Units:FindFirstChild(unitName)
        
        if not module then
            return nil
        end
        
        if module:IsA("ModuleScript") then
            return require(module)
        end
        
        return nil
    end)
    
    if success and result then
        return result
    end
    
    warn(string.format("❌ Could not find unit data for: %s", unitName))
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
    
    print(string.format("💰 Money: $%d | %s Placement Cost: $%d", money, unitName, placementCost))
    
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
            print("⚠️ Game ended while waiting for money - aborting wait")
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

local function clearSpawnIdMappings()
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
                
                print(string.format("📝 Placement detected: GUID=%s at (%.1f, %.1f, %.1f)", 
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
                    warn("❌ Could not determine unit name from GUID:", unitGUID)
                    return
                end
                
                print(string.format("✅ Placing unit: %s (Slot %d)", unitName, slot))
                
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
                            print(string.format("✅ Found unit at distance %.2f on attempt %d", 
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
    
    print(string.format("✓ Recorded: %s at %.2fs from game start (Instance=%s)", 
        unitTag, timeFromGameStart, unitInstance.Name))
else
    warn("❌ Failed to find placed unit in workspace!")
end
                
            -- UPGRADE HOOK
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Upgrade" then
                local unitInstance = args[2]
                
                local unitTag = recordingInstanceToTag[unitInstance]
                if not unitTag then
                    warn("⚠️ Upgrade detected for untracked unit:", unitInstance.Name)
                    return
                end
                
                table.insert(MacroState.currentMacro, {
                    Type = "upgrade_unit",
                    Unit = unitTag,
                    Time = string.format("%.2f", timeFromGameStart)
                })
                
                print(string.format("✓ Recorded upgrade: %s at %.2fs from game start (Instance=%s)", 
                    unitTag, timeFromGameStart, unitInstance.Name))
                
            -- SELL HOOK
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Sell" then
                local unitInstance = args[2]
                
                local unitTag = recordingInstanceToTag[unitInstance]
                if not unitTag then
                    warn("⚠️ Sell detected for untracked unit:", unitInstance.Name)
                    return
                end
                
                table.insert(MacroState.currentMacro, {
                    Type = "sell_unit",
                    Unit = unitTag,
                    Time = string.format("%.2f", timeFromGameStart)
                })
                
                print(string.format("✓ Recorded sell: %s at %.2fs from game start (Instance=%s)", 
                    unitTag, timeFromGameStart, unitInstance.Name))
                
                recordingInstanceToTag[unitInstance] = nil
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Active" then
    local unitInstance = args[2]
    local abilitySlot = args[3]
    
    local unitTag = recordingInstanceToTag[unitInstance]
    if not unitTag then
        warn("⚠️ Ability detected for untracked unit:", unitInstance.Name)
        return
    end
    
    local timeFromGameStart = timestamp - MacroState.gameStartTime
    
    table.insert(MacroState.currentMacro, {
        Type = "use_ability",
        Unit = unitTag,
        AbilitySlot = abilitySlot,
        Time = string.format("%.2f", timeFromGameStart)
    })
    
    print(string.format("✓ Recorded ability: %s used ability slot %s at %.2fs from game start", 
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
        warn(string.format("❌ %s is not in your loadout - skipping placement", unitName))
        return false
    end
    
    -- Get the unit info (including GUID) from the slot
    local unitInfo = getUnitFromSlot(slot)
    if not unitInfo then
        updateDetailedStatus("Error: Could not get unit data")
        return false
    end
    
    print(string.format("✓ Found %s in slot %d (GUID: %s)", unitName, slot, unitInfo.GUID))
    
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
        updateDetailedStatus(string.format("Placed %s ✓", action.Unit))
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
    
    print(string.format("🔧 Attempting to upgrade %s (Current Level: %d)", action.Unit, currentUpgrade))
    
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
            print(string.format("💰 Upgrade cost for level %d->%d: $%d", currentUpgrade, nextUpgradeIndex, upgradeCost))
        else
            print(string.format("⚠️ No upgrade data found for level %d (max level may be %d)", nextUpgradeIndex, #unitData.UpgradeStats))
            -- If no more upgrades available, skip
            updateDetailedStatus(string.format("%s is max level (%d)", action.Unit, currentUpgrade))
            return true
        end
    else
        print("⚠️ No UpgradeStats found in unit data for: " .. unitName)
        updateDetailedStatus("Could not get upgrade data")
        return false
    end
    
    -- Wait for money if needed
    local currentMoney = getPlayerMoney()
    print(string.format("💵 Current money: $%d | Need: $%d", currentMoney or 0, upgradeCost))
    
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
            print(string.format("✅ Upgrade successful: %d -> %d", currentUpgrade, newUpgrade))
            updateDetailedStatus(string.format("Upgraded %s to level %d ✓", action.Unit, newUpgrade))
        else
            print(string.format("⚠️ Upgrade may have failed: level still at %d", newUpgrade))
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
        updateDetailedStatus(string.format("Sold %s ✓", action.Unit))
        return true
    end
    
    updateDetailedStatus("Sell failed")
    return false
end

local function executeAbilityAction(action)
    local unitInstance = playbackUnitTagToInstance[action.Unit]
    
    if not unitInstance or not unitInstance.Parent then
        print(string.format("⚠️ Cannot use ability - %s not found or sold", action.Unit))
        return false
    end
    
    local abilitySlot = action.AbilitySlot
    
    print(string.format("🔥 Using ability: %s slot %s", action.Unit, abilitySlot))
    
    local success = pcall(function()
        local remote = Services.Players.LocalPlayer.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Active", unitInstance, abilitySlot)
    end)
    
    if success then
        print(string.format("✅ Ability fired: %s slot %s", action.Unit, abilitySlot))
        return true
    end
    
    print(string.format("❌ Ability failed: %s slot %s", action.Unit, abilitySlot))
    return false
end

local function autoStartGame()
    for i, connection in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.GameHUD.VoteSkipFrame.BTNs.Yes.Activated)) do
    connection:Fire()
    end
end

local function scheduleAbility(action, targetTime)
    local schedulerId = tostring(action) .. "_" .. tostring(targetTime)
    
    -- Don't schedule if already scheduled
    if MacroState.scheduledAbilities[schedulerId] then
        return
    end
    
    MacroState.scheduledAbilities[schedulerId] = true
    
    task.spawn(function()
        -- Wait until target time
        while MacroState.isPlaybackEnabled and MacroState.gameInProgress do
            local currentGameTime = tick() - MacroState.gameStartTime
            local waitTime = targetTime - currentGameTime
            
            if waitTime <= 0 then
                -- Time to fire!
                executeAbilityAction(action)
                MacroState.scheduledAbilities[schedulerId] = nil
                return
            end
            
            task.wait(0.1)
        end
        
        -- Game ended before ability fired
        MacroState.scheduledAbilities[schedulerId] = nil
        print(string.format("⚠️ Scheduled ability cancelled - game ended"))
    end)
    
    print(string.format("📅 Scheduled ability: %s slot %s for %.2fs", 
        action.Unit, action.AbilitySlot, targetTime))
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
    
    print(string.format("📼 Starting playback: %d actions", totalActions))
    print(string.format("📼 Playback starting %.2fs into game", playbackStartTime))
    
    for i, action in ipairs(MacroState.currentMacro) do
        if not MacroState.isPlaybackEnabled or not MacroState.gameInProgress then
            print(string.format("⚠️ Stopping playback at action %d/%d", i, totalActions))
            updateDetailedStatus("Game ended - stopped playback")
            clearSpawnIdMappings()
            MacroState.scheduledAbilities = {}
            return
        end
        
        print(string.format("📼 Action %d: Type=%s, Time=%s", 
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
                print("⚠️ Action missing Time, executing immediately")
            else
                local currentGameTime = tick() - MacroState.gameStartTime
                local waitTime = actionTime - currentGameTime
                
                print(string.format("📼 Game time: %.2fs | Action time: %.2fs | Wait: %.2fs", 
                    currentGameTime, actionTime, waitTime))
                
                if waitTime > 1 then
                    local waitStart = tick()
                    while (tick() - waitStart) < waitTime do
                        if not MacroState.isPlaybackEnabled or not MacroState.gameInProgress then
                            print("⚠️ Game ended while waiting - stopping playback")
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
                    print(string.format("⚠️ Action time already passed (%.2fs late), executing now", -waitTime))
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
            print("⚠️ Game ended before action execution")
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
        
        local loadedMacro = loadMacroFromFile(MacroManager.currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            updateMacroStatus("Error: Failed to load macro")
            updateDetailedStatus("Could not load: " .. tostring(MacroManager.currentMacroName))
            break
        end
        
        MacroState.currentMacro = loadedMacro
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
end

local function validateMacro(macro)
    if not macro or #macro == 0 then
        return false, "Macro is empty"
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
    print("Checking equipped units...")
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
        print("Webhook sent successfully")
        notify("Webhook Sent", "Successfully sent to Discord!", 2)
    else
        warn("Webhook failed:", response and response.StatusCode or "No response")
        notify("Webhook Failed", "Failed to send webhook", 3)
    end
end

local function waitForClientLoaded()
    local maxWait = 60
    local startTime = tick()
    
    print("Waiting for client to load...")
    
    while (tick() - startTime) < maxWait do
        local clientIsLoaded = Services.Players.LocalPlayer:GetAttribute("ClientIsLoaded")
        local clientsLoaded = Services.Players.LocalPlayer:GetAttribute("ClientLoaded")
        
        if clientIsLoaded and clientsLoaded then
            print("Client fully loaded!")
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
    
    -- Priority order: Next > Retry > Lobby
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
        print("ℹNo auto end game actions enabled")
        return
    end
    
    -- Try each action until UI closes
    for _, action in ipairs(actions) do
        print(string.format("Attempting auto %s...", action.name))
        
        for attempt = 1, 5 do
            local success = pcall(function()
                Services.ReplicatedStorage.Remotes.StageEnd:FireServer(action.remote)
            end)
            
            if success then
                print(string.format("Fired %s remote (attempt %d)", action.name, attempt))
            end
            
            -- Wait and check if UI closed (action succeeded)
            task.wait(1)
            
            local uiClosed = pcall(function()
                return not endGameUI.Enabled
            end)
            
            if uiClosed or not endGameUI.Parent then
                print(string.format("Auto %s successful!", action.name))
                notify("Auto Action", string.format("Auto %s activated", action.name), 2)
                return
            end
        end
        
        print(string.format("Auto %s failed after 5 attempts, trying next action...", action.name))
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

Button = LobbyTab:CreateButton({
   Name = "Return to lobby",
   Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StageEnd"):FireServer("Lobby")
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
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChangeSetting"):FireServer("AutoSkipWaves",Value)
   end,
})

local RemoveGamePopupsToggle = GameTab:CreateToggle({
   Name = "Remove game popups",
   CurrentValue = false,
   Flag = "RemoveGamePopups",
   Callback = function(Value)
        State.RemoveGamePopups = Value
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
            
            -- Wait for client to be fully loaded
            if not waitForClientLoaded() then
                notify("Recording Warning", "Client data may not be fully loaded", 4)
            end
            
            local currentWave = 0
            pcall(function()
                currentWave = Services.ReplicatedStorage.GameConfig.Wave.Value
            end)
            
            print(string.format("Recording enabled - Current wave: %d", currentWave))
            
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
                PlaybackToggle:Set(false)
                return
            end
            
            -- Load the macro
            local loadedMacro = MacroManager.macros[MacroManager.currentMacroName] or loadMacroFromFile(MacroManager.currentMacroName)
            
            if not loadedMacro or #loadedMacro == 0 then
                notify("Playback Error", "Macro is empty or doesn't exist")
                PlaybackToggle:Set(false)
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
                PlaybackToggle:Set(false)
                return
            end
            
            if MacroState.playbackLoopRunning then
                print("Playback loop already running")
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
        
        if not macro then
            notify("Error", "Could not load macro", 3)
            return
        end
        
        local isValid, message = validateMacro(macro)
        
        if isValid then
            notify("Macro Valid", message, 4)
        else
            notify("Macro Invalid", message, 6)
        end
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
            print(string.format("Wave changed: %d -> %d", MacroState.lastWave, wave))
            MacroState.currentWave = wave
            MacroState.waveStartTime = tick()
            MacroState.lastWave = wave
            
            -- Game start detection (wave 1)
            if wave == 1 and not MacroState.gameInProgress then
                MacroState.gameInProgress = true
                MacroState.gameStartTime = tick()
                MacroState.waveStartTime = tick()
                MacroState.currentWave = 1
                
                print(string.format("✓ GAME STARTED (Wave %d)", wave))
                
                -- Auto-start recording if enabled
                if MacroState.isRecording and not MacroState.recordingHasStarted then
    print("Starting recording now")
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
                    print("Game started - playback loop will start macro")
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
                print("voting to start")
                autoStartGame()
            end
        end)
    end
end)

local success = pcall(function()
    local StageEndRemote = Services.ReplicatedStorage.Remotes.StageEnd
    
    StageEndRemote.OnClientEvent:Connect(function(eventType, stageInfo, playerStats, rewards, playerData)
        if eventType == "ShowResults" then
            
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
                print("Game ended - playback will restart on next game")
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

ensureMacroFolders()
loadAllMacros()
MacroDropdown:Refresh(getMacroList())
Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image = "eye-off",
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})
