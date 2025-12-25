if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 133410800847665 and game.PlaceId ~= 106402284955512 and game.PlaceId ~= 100391355714091 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.03"

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Universal Tower Defense",
   Icon = 0,
   LoadingTitle = "Loading for Universal Tower Defense",
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
      FileName = "Lixhub_UTD"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = true,
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
local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local AutoPathTab = Window:CreateTab("Auto Path", "target")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local Tab = Window:CreateTab("Macro", "tv")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

local StatusLabel = Tab:CreateLabel("Status: Ready")
local DetailLabel = Tab:CreateLabel("Waiting...")

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
local currentPlaybackThread = nil
local currentGameInfo = {
    MapName = nil,
    Act = nil,
    Category = nil,
    StartTime = nil
}
local UINameToModuleName = {}
local ModifierModuleToTag = {}
local ModifierMapping = {}
local worldMacroMappings = {}
local worldDropdowns = {}

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

local PathState = {
    AutoSelectPath = false,
    BlessingPriorities = {}
}

local pathSliders = {}

local State = {
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
}

        local loadingRetries = {
        story = 0,
        legend = 0,
        portal = 0,
        ignoreWorlds = 0,
        modifiers = 0,
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

local function isInLobby()
    return Services.Workspace:GetAttribute("IsLobby") or false
end


local TowerService = nil
local BlessingService = nil
local RequestData = nil
local ChallengeController = nil
local PodController = nil

task.spawn(function()
    -- Wait for game to load
    task.wait(2)
    
    pcall(function()
        TowerService = game:GetService("ReplicatedStorage")
            :WaitForChild("Packages", 10)
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_knit@1.7.0")
            :WaitForChild("knit")
            :WaitForChild("Services")
            :WaitForChild("TowerService")
            :WaitForChild("RF")

        BlessingService = game:GetService("ReplicatedStorage")
            :WaitForChild("Packages", 10)
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_knit@1.7.0")
            :WaitForChild("knit")
            :WaitForChild("Services")
            :WaitForChild("BlessingService")
            :WaitForChild("RE")

        RequestData = game:GetService("ReplicatedStorage")
            :WaitForChild("Packages", 10)
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_knit@1.7.0")
            :WaitForChild("knit")
            :WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RF"):WaitForChild("RequestData")

        print("TowerService initialized")
        print("BlessingService initialized")
        print("RequestData initialized")
        print("ChallengeController initialized")
    end)
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        PodController = Knit.GetController("PodController")
        print("PodController initialized")
    end)
end)

task.spawn(function()
    task.wait(2)
    local Knit = require(Services.ReplicatedStorage.Packages.knit)
    ChallengeController = Knit.GetController("ChallengeController")
    print("ChallengeController initialized")
end)

-- ============================================
-- LOADOUT MANAGEMENT
-- ============================================



local function ensureMacroFolders()
    if not isfolder("LixHub") then
        makefolder("LixHub")
    end
    if not isfolder("LixHub/Macros") then
        makefolder("LixHub/Macros")
    end
    if not isfolder("LixHub/Macros/UTD") then
        makefolder("LixHub/Macros/UTD")
    end
end

local function getMacroFilename(name)
    return "LixHub/Macros/UTD/" .. name .. ".json"
end

local function saveMacroToFile(name, macroData)
    ensureMacroFolders()
    
    local json = game:GetService("HttpService"):JSONEncode(macroData)
    writefile(getMacroFilename(name), json)
    
    print(string.format("✓ Saved macro: %s (%d actions)", name, #macroData))
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not isfile(filePath) then 
        return nil 
    end
    
    local json = readfile(filePath)
    local data = game:GetService("HttpService"):JSONDecode(json)
    
    return data
end

local function deleteMacroFile(name)
    local filePath = getMacroFilename(name)
    if isfile(filePath) then
        delfile(filePath)
    end
    macroManager[name] = nil
    
    print(string.format("🗑️ Deleted macro: %s", name))
end

local function loadAllMacros()
    ensureMacroFolders()
    macroManager = {}
    
    local files = listfiles("LixHub/Macros/UTD/")
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            local data = loadMacroFromFile(name)
            if data then
                macroManager[name] = data
                print(string.format("📂 Loaded macro: %s (%d actions)", name, #data))
            end
        end
    end
end

local function getMacroList()
    local list = {}
    for name in pairs(macroManager) do
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

local function getPlayerLoadout()
    local loadout = {}
    
    local success = pcall(function()
        local hotbar = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.HUD.Bottom.Hotbar.Units
        
        if not hotbar then
            warn("❌ Hotbar not found!")
            return
        end
        
        -- Get all ContainerBig frames
        local containers = {}
        for _, child in pairs(hotbar:GetChildren()) do
            if child.Name == "ContainerBig" and child:IsA("Frame") then
                table.insert(containers, child)
            end
        end
        
        -- Sort by ABSOLUTE position (left to right)
        table.sort(containers, function(a, b)
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)
        
        --print(string.format("Total containers found: %d", #containers))
        
        -- Extract unit names in order
        for slot, container in ipairs(containers) do
            local unitPath = container:FindFirstChild("Unit")
            if unitPath then
                unitPath = unitPath:FindFirstChild("UnitInfomation")
                if unitPath then
                    unitPath = unitPath:FindFirstChild("Unit")
                    if unitPath then
                        -- FIX: Look for the FIRST Model that is NOT "WorldModel"
                        local unitModel = nil
                        
                        -- Method 1: Find by excluding WorldModel
                        for _, child in pairs(unitPath:GetChildren()) do
                            if child:IsA("Model") and child.Name ~= "WorldModel" then
                                unitModel = child
                                break
                            end
                        end
                        
                        -- Method 2: If still not found, check descendants
                        if not unitModel then
                            for _, descendant in pairs(unitPath:GetDescendants()) do
                                if descendant:IsA("Model") and descendant.Name ~= "WorldModel" then
                                    unitModel = descendant
                                    break
                                end
                            end
                        end
                        
                        if unitModel then
                            loadout[slot] = unitModel.Name
                            --print(string.format("✅ Slot %d: %s", slot, unitModel.Name))
                        else
                            warn(string.format("⚠️ Slot %d: Could not find unit model (found WorldModel)", slot))
                        end
                    end
                end
            end
        end
    end)
    
    if not success then
        warn("❌ Failed to get player loadout")
    end
    
    return loadout
end

local function getSlotForUnit(unitName)
    -- Returns the slot number where this unit is equipped
    -- Returns nil if unit not in loadout
    local loadout = getPlayerLoadout()
    
    for slot, name in pairs(loadout) do
        if name == unitName then
            return slot
        end
    end
    
    return nil
end

local function getUnitData(unitName)
    -- Access unit data from the Towers module
    -- Path: game:GetService("ReplicatedStorage").Shared.Data.Towers[UnitName]
    local success, result = pcall(function()
        local module = game:GetService("ReplicatedStorage")
            .Shared
            .Data
            .Towers
            :FindFirstChild(unitName)
        
        if not module then
            return nil
        end
        
        -- Check if it's a ModuleScript
        if module:IsA("ModuleScript") then
            local required = require(module)
            
            -- If it's a function, call it to get the actual data
            if type(required) == "function" then
                return required()
            end
            
            -- Otherwise return the table directly
            return required
        end
        
        return nil
    end)
    
    if success and result then
        return result
    end
    
    warn(string.format("❌ Could not find unit data for: %s", unitName))
    return nil
end

-- ============================================
-- UNIT TRACKING
-- ============================================

local function getUnitByUUID(uuid)
    -- Find unit in workspace by UUID
    -- UUID is stored as the model's Name in workspace.Ignore.Units
    local unitsFolder = workspace:FindFirstChild("Ignore")
    if unitsFolder then
        unitsFolder = unitsFolder:FindFirstChild("Units")
    end
    
    if not unitsFolder then return nil end
    
    -- Direct lookup since UUID is the model name
    local unit = unitsFolder:FindFirstChild(uuid)
    return unit
end

local function findNewUnitInGC(unitName, excludeUUIDs)
    --print(string.format("🔍 Searching GC for new unit: %s", unitName))
    
    excludeUUIDs = excludeUUIDs or {}
    
    local candidates = {}
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" then
            -- Check if it has GUID field (UUID)
            local guid = rawget(obj, "GUID")
            
            if guid and type(guid) == "string" and string.find(guid, "-") then
                -- Skip if we're already tracking this UUID
                if excludeUUIDs[guid] then
                    continue
                end
                
                -- Check if it matches our unit name
                local objUnitId = rawget(obj, "UnitId") or rawget(obj, "TowerID")
                local objName = rawget(obj, "Name")
                
                if objUnitId == unitName or objName == unitName then
                    -- Verify it has other unit-specific fields
                    local hasUpgrade = rawget(obj, "Upgrade") ~= nil
                    local hasModel = rawget(obj, "Model") ~= nil
                    
                    if hasUpgrade and hasModel then
                        -- Verify the model exists in workspace
                        local model = rawget(obj, "Model")
                        local modelExists = false
                        
                        pcall(function()
                            if model and model.Parent then
                                modelExists = true
                            end
                        end)
                        
                        if modelExists then
                            table.insert(candidates, {
                                uuid = guid,
                                unitName = objUnitId or objName,
                                data = obj
                            })
                            
                            --print(string.format("✅ Found candidate: %s (UUID=%s, Level=%d)", 
                                --objUnitId or objName, guid, rawget(obj, "Upgrade") or 1))
                        end
                    end
                end
            end
        end
    end
    
    if #candidates == 0 then
        warn(string.format("❌ No new units found for: %s", unitName))
        return nil, nil
    end
    
    -- If multiple candidates, return the one with lowest upgrade level (newest)
    table.sort(candidates, function(a, b) 
        local aLevel = rawget(a.data, "Upgrade") or 1
        local bLevel = rawget(b.data, "Upgrade") or 1
        return aLevel < bLevel
    end)
    
    local best = candidates[1]
    --print(string.format("✅ Selected: %s (UUID=%s)", best.unitName, best.uuid))
    
    return best.uuid, best.unitName
end

local unitChangeListeners = {}

local function findUnitDataInGC(uuid)
    -- Search garbage collection for unit data tables
    --print(string.format("🔍 Searching GC for unit: %s", uuid))
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" then
            -- Look for tables that have GUID field (not UUID, not uuid)
            local guid = rawget(obj, "GUID")
            
            if guid == uuid then
                -- Make sure it has other unit-specific fields to confirm it's the right table
                local hasUpgrade = rawget(obj, "Upgrade") ~= nil
                local hasUnitId = rawget(obj, "UnitId") ~= nil or rawget(obj, "TowerID") ~= nil
                
                if hasUpgrade or hasUnitId then
                    --print("✅ Found unit data in GC!")
                    
                    -- Print the table contents
                    --print("=== UNIT DATA TABLE ===")
                    for key, value in pairs(obj) do
                        if type(value) ~= "table" and type(value) ~= "function" then
                            --print(string.format("  %s = %s (%s)", tostring(key), tostring(value), type(value)))
                        end
                    end
                    --print("=== END ===")
                    return obj
                end
            end
            
            -- Fallback: check Model reference
            local model = rawget(obj, "Model")
            if model and type(model) == "userdata" then
                pcall(function()
                    if model.Name == uuid then
                        local hasUpgrade = rawget(obj, "Upgrade") ~= nil
                        if hasUpgrade then
                            --print("✅ Found unit data via model reference!")
                            return obj
                        end
                    end
                end)
            end
        end
    end
    warn("❌ Could not find unit data in GC")
    return nil
end

local function startTrackingUnitChanges(uuid, unitTag, unitName)
    local unit = getUnitByUUID(uuid)
    if not unit then return end
    
    --print(string.format("Started tracking: %s (UUID=%s)", unitTag, uuid))
    
    -- Find unit data in garbage collection
    local unitData = findUnitDataInGC(uuid)
    
    if unitData then
        -- Store the unit data reference
        unitChangeListeners[uuid] = {
            data = unitData,
            unitTag = unitTag,
            lastUpgradeLevel = unitData.Upgrade or 1
        }
        
        --print(string.format("Tracking %s - Current upgrade level: %d", 
            --unitTag, unitData.Upgrade or 1))
    else
        --warn(string.format("⚠️ Could not find GC data for %s", unitTag))
        unitChangeListeners[uuid] = { unitTag = unitTag }
    end
end

local function stopTrackingUnitChanges(uuid)
    if unitChangeListeners[uuid] then
        unitChangeListeners[uuid] = nil
        --print(string.format("Stopped tracking UUID: %s", uuid))
    end
end

local upgradeCheckThread = nil

local function startUpgradePolling()
    if upgradeCheckThread then return end
    
    upgradeCheckThread = task.spawn(function()
        while isRecording and recordingHasStarted do
            task.wait(0.5) -- Check every 0.5 seconds
            
            for uuid, listener in pairs(unitChangeListeners) do
                if type(listener) == "table" and listener.data then
                    local currentLevel = listener.data.Upgrade
                    local lastLevel = listener.lastUpgradeLevel
                    
                    if currentLevel and lastLevel and currentLevel > lastLevel then
                        -- Upgrade detected!
                        --print(string.format("UPGRADE DETECTED: %s went from level %d -> %d", 
                            --listener.unitTag, lastLevel, currentLevel))
                        
                        -- Update tracked level
                        listener.lastUpgradeLevel = currentLevel
                        
                        -- This will be caught by the hook, but good to log here too
                    end
                end
            end
        end
        
        upgradeCheckThread = nil
    end)
end

local function stopUpgradePolling()
    if upgradeCheckThread then
        task.cancel(upgradeCheckThread)
        upgradeCheckThread = nil
    end
end

local function getUnitNameFromTag(unitTag)
    -- Extract "FastCart" from "FastCart #1"
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
    
    if not checkcaller() and isRecording and recordingHasStarted then
        task.spawn(function()
            local timestamp = tick()
            local gameRelativeTime = timestamp - gameStartTime
            
            -- PLACEMENT HOOK
            if method == "InvokeServer" and self.Name == "PlaceUnit" then
    local slot = args[1]
    local cframe = args[2]
    
    -- Capture immediately
    local capturedSlot = slot
    local capturedCFrame = cframe
    
    --print(string.format("📝 Placement detected: Slot %d at (%.1f, %.1f, %.1f)", 
        --slot, cframe.Position.X, cframe.Position.Y, cframe.Position.Z))
    
    -- Get unit name from loadout
    local loadout = getPlayerLoadout()
    local unitName = loadout[slot]
    
    if not unitName then
        warn("❌ Could not determine unit name for slot", slot)
        return
    end
    
    --print(string.format("✅ Unit in slot %d: %s", slot, unitName))
    
    -- Wait for unit to appear in GC
    task.wait(0.5)
    
    -- Build exclude list from already tracked units
    local excludeUUIDs = {}
    for uuid, _ in pairs(recordingUUIDToTag) do
        excludeUUIDs[uuid] = true
    end
    
    local uuid, detectedName = nil, nil
    
    -- Try to find the new unit in GC (much faster than position search!)
    for attempt = 1, 10 do
        uuid, detectedName = findNewUnitInGC(unitName, excludeUUIDs)
        
        if uuid then
            --print(string.format("✅ Found new unit in GC on attempt %d", attempt))
            break
        end
        
        task.wait(0.3)
    end
    
    if uuid then
        -- Verify the unit exists in workspace
        local unit = getUnitByUUID(uuid)
        if not unit then
            warn(string.format("⚠️ UUID %s found in GC but not in workspace!", uuid))
            return
        end
        
        -- Increment counter for this unit type
        recordingUnitCounter[unitName] = (recordingUnitCounter[unitName] or 0) + 1
        local unitNumber = recordingUnitCounter[unitName]
        local unitTag = string.format("%s #%d", unitName, unitNumber)
        
        -- Track this unit
        recordingUUIDToTag[uuid] = unitTag
        
        -- Record to macro
        local record = {
            Type = "spawn_unit",
            Unit = unitTag,
            --UnitName = unitName,
            Time = string.format("%.2f", gameRelativeTime),
            Position = {capturedCFrame.Position.X, capturedCFrame.Position.Y, capturedCFrame.Position.Z}
        }
        
        table.insert(macro, record)
        
        -- Start tracking upgrades for this unit
        startTrackingUnitChanges(uuid, unitTag, unitName)
        
        print(string.format("✓ Recorded: %s (UUID=%s)", unitTag, uuid))
    else
        warn("❌ Failed to find placed unit in GC!")
    end
                
            -- UPGRADE HOOK
            elseif method == "InvokeServer" and self.Name == "UpgradeUnit" then
    local uuid = args[1]
    
    local unitTag = recordingUUIDToTag[uuid]
    if not unitTag then
        warn("⚠️ Upgrade detected for untracked unit:", uuid)
        return
    end
    
    -- Get current level BEFORE upgrade
    local currentLevel = nil
    if unitChangeListeners[uuid] and type(unitChangeListeners[uuid]) == "table" then
        currentLevel = unitChangeListeners[uuid].lastUpgradeLevel
    end
    
    table.insert(macro, {
        Type = "upgrade_unit",
        Unit = unitTag,
        Time = string.format("%.2f", gameRelativeTime)
    })
    
    if currentLevel then
        print(string.format("✓ Recorded upgrade: %s (UUID=%s) Level %d -> %d", 
            unitTag, uuid, currentLevel, currentLevel + 1))
    else
        print(string.format("✓ Recorded upgrade: %s (UUID=%s)", unitTag, uuid))
    end
                
            -- SELL HOOK
            elseif method == "InvokeServer" and self.Name == "SellUnit" then
                local uuid = args[1]
                
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then
                    warn("⚠️ Sell detected for untracked unit:", uuid)
                    return
                end
                
                table.insert(macro, {
                    Type = "sell_unit",
                    Unit = unitTag,
                    Time = string.format("%.2f", gameRelativeTime)
                })
                
                print(string.format("✓ Recorded sell: %s (UUID=%s)", unitTag, uuid))
                
                -- Stop tracking this unit
                stopTrackingUnitChanges(uuid)
                recordingUUIDToTag[uuid] = nil
            end
        end)
    end
    
    return originalNamecall(self, ...)
end)

mt.__namecall = generalHook
setreadonly(mt, true)

-- ============================================
-- PLAYBACK EXECUTION
-- ============================================

local function getPlayerMoney()
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
        -- CRITICAL: Check game state while waiting for money
        local matchFinished = workspace:GetAttribute("MatchFinished")
        
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            print("⚠️ Game ended while waiting for money - aborting wait")
            return false -- Return false to signal we should stop
        end
        
        task.wait(1)
        
        currentMoney = getPlayerMoney()
        if not currentMoney then
            return true
        end
        
        if currentMoney >= requiredAmount then
            return true
        end
        
        -- Update status every 3 seconds
        if tick() - lastUpdateTime >= 1 then
            updateDetailedStatus(string.format("Waiting: ¥%d / ¥%d (%s)", currentMoney, requiredAmount, actionDescription))
            lastUpdateTime = tick()
        end
    end
end

local function executePlacementAction(action, actionIndex, totalActions)
    local unitName = getUnitNameFromTag(action.Unit)
    
    updateMacroStatus(string.format("(%d/%d) Placing %s", actionIndex, totalActions, action.Unit))

    local unitData = getUnitData(unitName)
    local placementCost = 0
    
    if unitData and unitData.Stats and unitData.Stats.Upgrades and #unitData.Stats.Upgrades > 0 then
        placementCost = unitData.Stats.Upgrades[1].Cost or 0
    end
    
    -- Show waiting status if we need money
    if placementCost > 0 then
        local currentMoney = getPlayerMoney()
        if currentMoney and currentMoney < placementCost then
            updateDetailedStatus(string.format("Waiting for ¥%d to place %s", placementCost, action.Unit))
        end
        
        -- CHECK IF WAIT WAS ABORTED
        local canContinue = waitForMoney(placementCost, unitName)
        if not canContinue then
            updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    
    local slot = getSlotForUnit(unitName)
    
    if not slot then
        updateDetailedStatus(string.format("Error: %s not in loadout", unitName))
        return false
    end
    
    updateDetailedStatus(string.format("Placing %s...", action.Unit))
    
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    
    local success = pcall(function()
        TowerService:WaitForChild("PlaceUnit"):InvokeServer(slot, cframe)
    end)
    
    if not success then
        updateDetailedStatus("Placement failed")
        return false
    end
    
    task.wait(0.5)
    
    local excludeUUIDs = {}
    for _, mappedUUID in pairs(playbackUnitTagToUUID) do
        excludeUUIDs[mappedUUID] = true
    end
    
    local uuid = nil
    
    for attempt = 1, 10 do
        uuid = findNewUnitInGC(unitName, excludeUUIDs)
        if uuid then break end
        task.wait(0.3)
    end
    
    if uuid then
        local unit = getUnitByUUID(uuid)
        if not unit then
            updateDetailedStatus("Unit not found in workspace")
            return false
        end
        
        playbackUnitTagToUUID[action.Unit] = uuid
        updateDetailedStatus(string.format("Placed %s ✓", action.Unit))
        return true
    end
    
    updateDetailedStatus("Failed to detect placed unit")
    return false
end

local function executeUnitUpgrade(action, actionIndex, totalActions)
    updateMacroStatus(string.format("(%d/%d) Upgrading %s", actionIndex, totalActions, action.Unit))
    
    local uuid = playbackUnitTagToUUID[action.Unit]
    
    if not uuid or type(uuid) ~= "string" then
        updateDetailedStatus(string.format("Error: Invalid UUID for %s", action.Unit))
        return false
    end

    local upgradeCost = 0
    local currentLevel = 1
    local unitData = findUnitDataInGC(uuid)
    
    if unitData then
        currentLevel = unitData.Upgrade or 1
        local unitName = unitData.UnitId or unitData.TowerID or action.Unit
        
        local towerData = getUnitData(unitName)
        if towerData and towerData.Stats and towerData.Stats.Upgrades then
            local nextUpgradeIndex = currentLevel + 1
            local nextUpgrade = towerData.Stats.Upgrades[nextUpgradeIndex]
            
            if nextUpgrade and nextUpgrade.Cost then
                upgradeCost = nextUpgrade.Cost
            end
        end
    end
    
    -- Show waiting status if we need money
    if upgradeCost > 0 then
        local currentMoney = getPlayerMoney()
        if currentMoney and currentMoney < upgradeCost then
            updateDetailedStatus(string.format("Waiting for ¥%d to upgrade %s", upgradeCost, action.Unit))
        end
        
        -- CHECK IF WAIT WAS ABORTED
        local canContinue = waitForMoney(upgradeCost, string.format("%s upgrade", action.Unit))
        if not canContinue then
            updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    
    updateDetailedStatus(string.format("Upgrading %s (Lv%d→%d)...", action.Unit, currentLevel, currentLevel + 1))
    
    local success = pcall(function()
        TowerService:WaitForChild("UpgradeUnit"):InvokeServer(uuid)
    end)
    
    if success then
        updateDetailedStatus(string.format("Upgraded %s ✓", action.Unit))
        return true
    end
    
    updateDetailedStatus("Upgrade failed")
    return false
end

local function executeUnitSell(action, actionIndex, totalActions)
    updateMacroStatus(string.format("(%d/%d) Selling %s", actionIndex, totalActions, action.Unit))
    
    local uuid = playbackUnitTagToUUID[action.Unit]
    
    if not uuid then
        updateDetailedStatus(string.format("Error: No UUID for %s", action.Unit))
        return false
    end
    
    updateDetailedStatus(string.format("Selling %s...", action.Unit))
    
    local success = pcall(function()
        TowerService:WaitForChild("SellUnit"):InvokeServer(uuid)
    end)
    
    if success then
        playbackUnitTagToUUID[action.Unit] = nil
        updateDetailedStatus(string.format("Sold %s ✓", action.Unit))
        return true
    end
    
    updateDetailedStatus("Sell failed")
    return false
end

-- ============================================
-- CLEANUP FUNCTIONS
-- ============================================

local function clearSpawnIdMappings()
    playbackUnitTagToUUID = {}
    recordingUnitCounter = {}
    recordingUUIDToTag = {}
    
    -- Clear all change listeners
    for uuid, connection in pairs(unitChangeListeners) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    unitChangeListeners = {}
end

local function startRecording()
    if isRecording then
        return
    end
    
    macro = {}
    clearSpawnIdMappings()
    
    isRecording = true
    recordingHasStarted = true
    gameStartTime = tick()
    
    startUpgradePolling()
    
    updateMacroStatus("Recording...")
end

local function stopRecording()
    if not isRecording then return end
    
    isRecording = false
    recordingHasStarted = false
    
    local actionCount = #macro
    
    if currentMacroName and currentMacroName ~= "" then
        macroManager[currentMacroName] = macro
        saveMacroToFile(currentMacroName, macro)
        updateMacroStatus(string.format("Saved %d actions to %s", actionCount, currentMacroName))
    else
        updateMacroStatus(string.format("Recording stopped (%d actions)", actionCount))
    end
    
    return macro
end

local function savePathPriorities()
    ensureMacroFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local fileName = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    
    local json = game:GetService("HttpService"):JSONEncode(PathState.BlessingPriorities)
    writefile(fileName, json)
    --print("✓ Saved path priorities")
end

-- Function to load path priorities from file
local function loadPathPriorities()
    ensureMacroFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local filePath = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    
    if not isfile(filePath) then
        return {}
    end
    
    local json = readfile(filePath)
    local data = game:GetService("HttpService"):JSONDecode(json)
    
    print("✓ Loaded path priorities")
    return data or {}
end

local function getCardOptions()
    local cards = {}

    --print("=== DEBUG: PathState.BlessingPriorities ===")
    --for key, value in pairs(PathState.BlessingPriorities) do
        --print(string.format("  %s = %d", key, value))
    --end
    --print("=== END DEBUG ===")
    
    local success = pcall(function()
        local cardsFolder = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Paths.PathSelection.Cards
        
        local frameChildren = {}
        for _, child in ipairs(cardsFolder:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("^Card") then
                table.insert(frameChildren, child)
            end
        end
        
        table.sort(frameChildren, function(a, b)
            if a.LayoutOrder ~= b.LayoutOrder then
                return a.LayoutOrder < b.LayoutOrder
            end
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)
        
        for cardIndex, cardFrame in ipairs(frameChildren) do
            local titleLabel = cardFrame:FindFirstChild("Title")
            local topTitleLabel = cardFrame:FindFirstChild("TopTitle")
            
            if titleLabel and topTitleLabel then
                local uiBlessingName = titleLabel.Text
                
                -- Remove ALL special characters and spaces from UI name
                local uiCleanName = uiBlessingName:gsub("[^%w]", ""):lower()
                
                --print(string.format("Card %d: UI='%s' -> Clean='%s'", cardIndex, uiBlessingName, uiCleanName))
                
                -- Try to find a matching slider key by checking if UI name contains the slider key
                local matchedKey = nil
                local highestPriority = 0
                
                for sliderKey, priority in pairs(PathState.BlessingPriorities) do
                    local cleanSliderKey = sliderKey:lower()
                    
                    -- Check if the UI blessing name contains this slider key
                    if uiCleanName:find(cleanSliderKey, 1, true) then
                        --print(string.format("  MATCH FOUND: '%s' contains '%s' (Priority: %d)", 
                            --uiCleanName, cleanSliderKey, priority))
                        
                        -- Use the highest priority match if multiple keys match
                        if priority > highestPriority then
                            matchedKey = sliderKey
                            highestPriority = priority
                        end
                    end
                end
                
                -- If no match found, create a new slider key from UI name
                if not matchedKey then
                    matchedKey = uiBlessingName:gsub("[^%w]", "")
                    --print(string.format("  NO MATCH - Creating new key: '%s'", matchedKey))
                    
                    -- Initialize with 0 priority
                    if not PathState.BlessingPriorities[matchedKey] then
                        PathState.BlessingPriorities[matchedKey] = 0
                    end
                    highestPriority = 0
                end
                
                table.insert(cards, {
                    index = cardIndex,
                    blessingName = uiBlessingName,
                    pathName = "",
                    sliderKey = matchedKey,
                    priority = highestPriority
                })

                --print(string.format("Card %d: %s -> %s (Priority: %d)", 
                    --cardIndex, uiBlessingName, matchedKey, highestPriority))
            end
        end
    end)
    
    if not success then
        warn("Failed to get card options")
        return {}
    end
    
    return cards
end

local function selectBestCard()
    if not BlessingService then
        warn("BlessingService not initialized")
        return false
    end
    
    local cards = getCardOptions()
    
    if #cards == 0 then
        warn("No cards found")
        return false
    end
    
    -- Sort by priority (highest first)
    table.sort(cards, function(a, b)
        return a.priority > b.priority
    end)
    
    local bestCard = cards[1]
    
    -- Check if highest priority is 0 (meaning no priorities set)
    if bestCard.priority == 0 then
        --print("All cards have 0 priority - selecting first card by default")
    else
        print(string.format("selecting card: %s with priority %d", bestCard.sliderKey, bestCard.priority))
    end
    
    -- Determine which remote to use based on card count
    -- 5+ cards = Path selection (GetNewPath)
    -- 3 or less = Blessing selection (GetNewBlessing)
    local remoteName = #cards >= 5 and "GetNewPath" or "GetNewBlessing"
    local remoteType = #cards >= 5 and "Path" or "Blessing"
    
    --print(string.format("Detected %d cards - using %s remote", #cards, remoteType))
    
    -- Fire the appropriate remote
    local success = pcall(function()
        BlessingService:WaitForChild(remoteName):FireServer(bestCard.index)
    end)
    
    if success then
        --print(string.format("✓ Selected card %d: %s (via %s)", bestCard.index, bestCard.blessingName, remoteName))
        
        Rayfield:Notify({
            Title = "Auto " .. remoteType,
            Content = string.format("Selected: %s", bestCard.blessingName),
            Duration = 3
        })
        
        return true
    else
        warn(string.format("Failed to select card via %s", remoteName))
        return false
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        
        if State.AutoSelectPath then
            -- Wait for BlessingService to be ready
            if not BlessingService then
                --print("Waiting for BlessingService to initialize...")
                local timeout = 0
                while not BlessingService and timeout < 20 do
                    task.wait(0.5)
                    timeout = timeout + 1
                end
                
                if not BlessingService then
                    warn("BlessingService failed to initialize after 10 seconds")
                    continue
                end
            end
            
            local pathsUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("GameUI")
            
            if pathsUI then
                pathsUI = pathsUI:FindFirstChild("Paths")
                
                if pathsUI and pathsUI.Enabled then
                    -- Path selection is visible
                    --print("Path selection screen detected")
                    
                    -- Wait a moment for cards to fully load
                    task.wait(0.5)
                    
                    -- Select the best card
                    selectBestCard()
                    
                    -- Don't wait for screen to close - just add a small delay
                    -- This allows follow-up blessings to be detected immediately
                    task.wait(1)
                    
                    --print("Card selected - checking for follow-ups...")
                end
            end
        end
    end
end)

local function deepCopy(tbl, seen)
    if type(tbl) ~= "table" then return tbl end
    seen = seen or {}
    if seen[tbl] then return seen[tbl] end

    local copy = {}
    seen[tbl] = copy
    for k, v in pairs(tbl) do
        copy[k] = deepCopy(v, seen)
    end
    return copy
end

local function isTrackedPath(path)
        return
            path:match("^Currency%.") or
            path == "Battlepass.PassEXP" or
            path == "Stats.Experience" or
            path:match("^Relics%.[^%.]+$") or
            path:match("^Units%.Inventory%.%[.+%]$") or
            path:match("^Items%.CraftingItems") or
            path:match("^Items%.UniqueItems")
    end

local function getRewards(before, after, path)
    path = path or ""
    local rewards = {}

    for k, afterVal in pairs(after) do
        local beforeVal = before and before[k]
        local currentPath = path == "" and tostring(k) or path .. "." .. tostring(k)

        if not isTrackedPath(currentPath) then
            if type(afterVal) == "table" and type(beforeVal) == "table" then
                local nestedRewards = getRewards(beforeVal, afterVal, currentPath)
                for rewardKey, rewardVal in pairs(nestedRewards) do
                    rewards[rewardKey] = (rewards[rewardKey] or 0) + rewardVal
                end
            end
            continue
        end

        -- NEW ITEM (Relics / Units / Crafting)
        if beforeVal == nil then
    if type(afterVal) == "table" then
        -- Relic
        if afterVal.ID and afterVal.Type and afterVal.Rarity then
            -- Use ID + Type to differentiate same relics with different types
            local relicName = afterVal.ID or "Unknown"
            local relicType = afterVal.Type or "Unknown"
            local rewardKey = string.format("%s (%s) (%s)", relicName, relicType, afterVal.Rarity)
            rewards[rewardKey] = (rewards[rewardKey] or 0) + 1
        -- Unit Drop (has UnitId)
        elseif afterVal.UnitId then
            local unitName = afterVal.UnitId or "Unknown Unit"
            local rewardKey = string.format("🎉 NEW UNIT: %s", unitName)
            rewards[rewardKey] = (rewards[rewardKey] or 0) + 1
            -- Mark that we got a unit drop for ping purposes
            rewards["__UNIT_DROP__"] = true
        end
    end
-- NEW CRAFTING/UNIQUE ITEM (number added where there was nil before)
elseif type(afterVal) == "number" and beforeVal == nil then
    local itemName = currentPath:match("%.([^%.]+)$") or currentPath
    if currentPath:match("CraftingItems%.") then
        local rewardKey = string.format("Crafting: %s", itemName)
        rewards[rewardKey] = (rewards[rewardKey] or 0) + afterVal
    elseif currentPath:match("UniqueItems%.") then
        local rewardKey = string.format("Unique: %s", itemName)
        rewards[rewardKey] = (rewards[rewardKey] or 0) + afterVal
    end

        -- NUMBER DELTA (currency / pass exp / experience)
        elseif type(afterVal) == "number" and type(beforeVal) == "number" then
            local delta = afterVal - beforeVal
            if delta ~= 0 then
                -- Extract the reward name (e.g., "Currency.Gems" -> "Gems")
                local rewardName = currentPath:match("%.([^%.]+)$") or currentPath
                
                -- Rename specific rewards for cleaner display
                if rewardName == "PassEXP" then
                    rewardName = "Battlepass XP"
                elseif rewardName == "Experience" then
                    rewardName = "XP"
                end
                
                rewards[rewardName] = (rewards[rewardName] or 0) + delta
            end

        -- Recurse
        elseif type(afterVal) == "table" and type(beforeVal) == "table" then
            local nestedRewards = getRewards(beforeVal, afterVal, currentPath)
            for rewardKey, rewardVal in pairs(nestedRewards) do
                rewards[rewardKey] = (rewards[rewardKey] or 0) + rewardVal
            end
        end
    end

    return rewards
end

local function sendWebhook(messageType, gameResult, gameInfo, gameDuration, waveReached)
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
        -- Calculate rewards
        local rewards = {}
        local hasUnitDrop = false
        if beforeRewardData and afterRewardData then
            rewards = getRewards(beforeRewardData, afterRewardData)
            hasUnitDrop = rewards["__UNIT_DROP__"]
            rewards["__UNIT_DROP__"] = nil
        end

        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        
        -- Format rewards text
        local rewardsText = ""
        
        if next(rewards) then
            for rewardType, amount in pairs(rewards) do
                local sign = amount > 0 and "+" or ""
                rewardsText = rewardsText .. string.format("%s%s %s\n", sign, amount, rewardType)
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
            if gameInfo and gameInfo.MapName and gameInfo.Act and gameInfo.Category then
            local resultText = gameResult and "Victory" or "Defeat"
            TitleSubText = string.format("%s - %s (%s) - %s", 
            gameInfo.MapName, gameInfo.Act, gameInfo.Category, resultText)
        end
        
        local currentWave = workspace:GetAttribute("Wave") or lastWave or 0

        local macroInfo = "None"
    if isPlaybackEnabled and currentMacroName and currentMacroName ~= "" then
        macroInfo = currentMacroName
    end
        
        -- Build fields array
        local fields = {
            { name = "Player", value = playerName, inline = true },
            { name = "Duration", value = gameDuration or "Unknown", inline = true },
            { name = "Waves Completed", value = tostring(currentWave), inline = true },
            { name = "Macro", value = macroInfo, inline = true },
            { name = "Rewards", value = rewardsText, inline = false },
        }
        
        data = {
            username = "LixHub",
            content = hasUnitDrop and string.format("<@%s>", Config.DISCORD_USER_ID or "") or nil,
            embeds = {{
                title = titleText,
                description = TitleSubText,
                color = embedColor,
                fields = fields,
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = timestamp
            }}
        }
    

    elseif messageType == "match_restart" then
    -- Calculate rewards up to the restart point
    local rewards = {}
    if beforeRewardData and RequestData then
        local currentRewardData = deepCopy(RequestData:InvokeServer())
        rewards = getRewards(beforeRewardData, currentRewardData)
    end
    
    local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    
    -- Build description
    local description = "Unknown Stage"
    if gameInfo and gameInfo.MapName and gameInfo.Act and gameInfo.Category then
        description = string.format("%s Act %s (%s) - Match restarted", 
            gameInfo.MapName, gameInfo.Act, gameInfo.Category)
    end
    
    local currentWave = waveReached or lastWave or 0
    
    -- Calculate time elapsed
    local timeElapsed = "Unknown"
    if gameInfo and gameInfo.StartTime then
        local duration = tick() - gameInfo.StartTime
        local minutes = math.floor(duration / 60)
        local seconds = math.floor(duration % 60)
        timeElapsed = string.format("%dm %ds", minutes, seconds)
    end
    
    -- Format rewards text
    local rewardsText = ""
    if next(rewards) then
        for rewardType, amount in pairs(rewards) do
            local sign = amount > 0 and "+" or ""
            rewardsText = rewardsText .. string.format("%s%s %s\n", sign, amount, rewardType)
        end
        rewardsText = rewardsText:gsub("\n$", "") -- Remove trailing newline
    else
        rewardsText = "No rewards obtained"
    end
    
    data = {
        username = "LixHub",
        embeds = {{
            title = "Stage Completed!",
            description = description,
            color = 0xFFA500, -- Orange color
            fields = {
                { name = "Player", value = playerName, inline = true },
                { name = "Time Played", value = timeElapsed, inline = true },
                { name = "Wave Reached", value = tostring(currentWave), inline = true },
                { name = "Rewards", value = rewardsText, inline = false },
            },
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
        Rayfield:Notify({
            Title = "Webhook Sent",
            Content = "Successfully sent to Discord!",
            Duration = 2
        })
    else
        warn("Webhook failed:", response and response.StatusCode or "No response")
    end
end

local function notify(title, content)
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = 3
        })
end

local function canPerformAction()
        return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
end

local function setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()

   notify(action, "Joining...")
end

 local function clearProcessingState()
        AutoJoinState.isProcessing = false
        AutoJoinState.currentAction = nil
end

local function convertDifficultyMeter(percentage)
    return percentage / 100
end

local function joinStoryViaAPI(mapName, act, difficulty, difficultyPercent)
    if not PodController then
        warn("PodController not initialized")
        return false
    end
    
    local gameData = {
        Category = "Story",
        Map = mapName,
        Act = tostring(act),
        Difficulty = difficulty,
        Modulation = convertDifficultyMeter(difficultyPercent),
        FriendsOnly = false
    }
    
    print(string.format("Joining Story: %s Act %s (%s) - %d%%", 
        mapName, act, difficulty, difficultyPercent))
    
    local success = pcall(function()
        PodController:RequestPod(gameData)
    end)
    
    if success then
        print("✅ Story join request sent via API")
        return true
    else
        warn("❌ Story join failed")
        return false
    end
end

local function joinLegendViaAPI(mapName, act, difficultyPercent)
    if not PodController then
        warn("PodController not initialized")
        return false
    end
    
    local gameData = {
        Category = "LegendStage",
        Map = mapName,
        Act = tostring(act),
        Difficulty = nil, -- Legend stages don't have Easy/Hard/Nightmare
        Modulation = convertDifficultyMeter(difficultyPercent),
        FriendsOnly = false
    }
    
    print(string.format("Joining Legend: %s Act %s - %d%%", 
        mapName, act, difficultyPercent))
    
    local success = pcall(function()
        PodController:RequestPod(gameData)
    end)
    
    if success then
        print("✅ Legend join request sent via API")
        return true
    else
        warn("❌ Legend join failed")
        return false
    end
end

local function joinVirtualViaAPI(mapName, act, difficulty, difficultyPercent)
    if not PodController then
        warn("PodController not initialized")
        return false
    end
    
    local gameData = {
        Category = "VirtualRealm",
        Map = mapName,
        Act = tostring(act),
        Difficulty = difficulty,
        Modulation = convertDifficultyMeter(difficultyPercent),
        FriendsOnly = false
    }
    
    print(string.format("Joining Virtual: %s Act %s (%s) - %d%%", 
        mapName, act, difficulty, difficultyPercent))
    
    local success = pcall(function()
        PodController:RequestPod(gameData)
    end)
    
    if success then
        print("✅ Virtual join request sent via API")
        return true
    else
        warn("❌ Virtual join failed")
        return false
    end
end

local function joinChallengeViaAPI(challengeType, challengeNumber)
    if not PodController or not ChallengeController then
        warn("Controllers not initialized")
        return false
    end
    
    -- Get current challenges data
    local challenges = ChallengeController:GetCurrentChallenges()
    
    if not challenges or not challenges[challengeType] or not challenges[challengeType][challengeNumber] then
        warn(string.format("Challenge not found: %s #%d", challengeType, challengeNumber))
        return false
    end
    
    local challengeData = challenges[challengeType][challengeNumber]
    
    local gameData = {
        Category = "Challenge",
        Challenge = {
            Type = challengeType,
            Number = challengeNumber
        },
        Map = challengeData.Map,
        Act = tostring(challengeData.Act),
        Difficulty = "Easy", -- Challenges default to Easy
        Modulation = 1.0, -- Challenges default to 100%
        FriendsOnly = false
    }
    
    print(string.format("Joining Challenge: %s #%d (%s Act %s)", 
        challengeType, challengeNumber, challengeData.Map, challengeData.Act))
    
    local success = pcall(function()
        PodController:RequestPod(gameData)
    end)
    
    if success then
        print("✅ Challenge join request sent via API")
        return true
    else
        warn("❌ Challenge join failed")
        return false
    end
end

local function joinFeaturedChallengeViaAPI()
    if not PodController then
        warn("PodController not initialized")
        return false
    end
    
    local Config = require(Services.ReplicatedStorage.Shared.Data.Config)
    
    local gameData = {
        Category = "Challenge",
        Challenge = {
            Type = "Special",
            Number = 1
        },
        Map = Config.CurrentFeaturedChallenge or "Frozen Stronghold",
        Act = "1",
        Difficulty = "Easy",
        Modulation = 1.0,
        FriendsOnly = false
    }
    
    print("Joining Featured Challenge:", gameData.Map)
    
    local success = pcall(function()
        PodController:RequestPod(gameData)
    end)
    
    if success then
        print("✅ Featured Challenge join request sent via API")
        return true
    else
        warn("❌ Featured Challenge join failed")
        return false
    end
end

local function activatePodUI(podName)
    -- Find the pod in workspace
    local podsFolder = workspace:FindFirstChild("Pods")
    if not podsFolder then
        warn("Pods folder not found in workspace")
        return false
    end
    
    local pod = podsFolder:FindFirstChild(podName)
    if not pod then
        warn(string.format("Pod '%s' not found", podName))
        return false
    end
    
    -- Find the TouchPart
    local touchPart = nil
    for _, child in pairs(pod:GetDescendants()) do
        if child.Name == "TouchPart" and child:IsA("BasePart") then
            touchPart = child
            break
        end
    end
    
    if not touchPart then
        warn(string.format("TouchPart not found in pod '%s'", podName))
        return false
    end
    
    -- Get player references
    local player = Services.Players.LocalPlayer
    local character = player.Character
    if not character then
        warn("Character not found")
        return false
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("HumanoidRootPart not found")
        return false
    end
    
    -- Try up to 3 times to activate the pod
    for attempt = 1, 3 do
        --print(string.format("Attempt %d: Teleporting to %s pod TouchPart...", attempt, podName))
        
        -- If this is a retry, teleport to spawn location first
        if attempt > 1 then
            local success = pcall(function()
                local teleportLocation = workspace.Zones.TeleportLocations:FindFirstChild("Story")
                if teleportLocation then
                    humanoidRootPart.CFrame = teleportLocation.CFrame
                    --print(string.format("Teleported to spawn location: %s", teleportLocationName))
                else
                    -- Fallback: teleport 10 studs away
                    local awayPosition = touchPart.CFrame * CFrame.new(0, 0, 10)
                    humanoidRootPart.CFrame = awayPosition
                    --print("Spawn location not found - using fallback position")
                end
            end)
            
            if not success then
                -- Fallback if pcall fails
                local awayPosition = touchPart.CFrame * CFrame.new(0, 0, 10)
                humanoidRootPart.CFrame = awayPosition
            end
            
            task.wait(0.5) -- Wait a moment before trying again
        end
        
        -- Teleport to TouchPart position
        humanoidRootPart.CFrame = touchPart.CFrame
        
        -- Wait for UI to activate
        task.wait(1) -- Give it a moment to register the touch
        
        local lobbyUi = player.PlayerGui:FindFirstChild("LobbyUi")
        if not lobbyUi then
            warn("LobbyUi not found")
            if attempt < 3 then
                print("Retrying...")
                continue
            end
            return false
        end
        
        local startPod = lobbyUi:FindFirstChild("StartPod")
        if not startPod then
            warn("StartPod not found")
            if attempt < 3 then
                print("Retrying...")
                continue
            end
            return false
        end
        
        -- Wait for StartPod to be enabled
        local timeout = 0
        while not startPod.Enabled and timeout < 30 do
            task.wait(0.1)
            timeout = timeout + 1
        end
        
        if startPod.Enabled then
            print(string.format("✓ Successfully activated %s pod UI on attempt %d", podName, attempt))
            return true
        else
            warn(string.format("StartPod UI did not activate on attempt %d", attempt))
            if attempt < 3 then
                print("Retrying...")
            end
        end
    end
    
    --warn(string.format("Failed to activate pod UI after 3 attempts"))
    return false
end

local function getCurrentChallengesData()
    if not ChallengeController then
        warn("ChallengeController not initialized")
        return nil
    end
    
    local success, challenges = pcall(function()
        return ChallengeController:GetCurrentChallenges()
    end)
    
    if success and challenges then
        return challenges
    end
    
    return nil
end

local function challengeMatchesFilters(challengeData)
    local challengeMapModule = challengeData.Map
    local act = challengeData.Act
    local modifiers = challengeData.Modifiers or {}
    local reward = challengeData.Reward
    
    --print(string.format("Checking challenge: Map='%s', Act=%d, Reward=%s, Modifiers=%s", 
        --challengeMapModule, act, reward, table.concat(modifiers, ", ")))

        --print("=== ModifierModuleToTag Contents ===")
    for moduleName, displayTag in pairs(ModifierModuleToTag) do
        --print(string.format("  '%s' -> '%s'", moduleName, displayTag))
    end
    --print("=== END DEBUG ===")
    
    -- STEP 1: Check if map is in ignore list (applies to ALL challenges)
    if #State.IgnoreWorlds > 0 then
        for _, ignoredMapUI in ipairs(State.IgnoreWorlds) do
            local ignoredMapModule = UINameToModuleName[ignoredMapUI]
            
            if ignoredMapModule and challengeMapModule == ignoredMapModule then
                --print(string.format("❌ Skipping - Map '%s' (UI: '%s') is in ignore list", 
                    --challengeMapModule, ignoredMapUI))
                return false
            end
        end
    end
    
    -- STEP 2: Check if any modifier is in ignore list (applies to ALL challenges)
    if #State.IgnoreModifier > 0 then
        for _, modifierName in pairs(modifiers) do
            -- modifierName here is the MODULE name (e.g., "HalfHourPlacementDecrease")
            -- We need to check against what the user selected (ChallengeTag like "Unit Place Amount Decrease")
            
            -- Convert module name to display tag for comparison
            --local modifierDisplayTag = ModifierModuleToTag[modifierName]
            
            -- If we don't have a mapping yet, skip this check (might still be loading)
            --if not modifierDisplayTag then
                --print(string.format("⚠️ No mapping found for modifier module: %s", modifierName))
                --continue
            --end
            
            --print(string.format("Checking modifier: Module='%s'", modifierName))
            
            for _, ignoredModifier in ipairs(State.IgnoreModifier) do
                -- ignoredModifier is the display name (ChallengeTag) from dropdown
                if modifierName == ignoredModifier then
                    --print(string.format("❌ Skipping - Modifier '%s' is in ignore list", modifierName))
                    return false
                end
            end
        end
    end
    
    -- STEP 3: Check reward (if we have reward filters active)
    if #State.SelectedChallengeRewards > 0 then
        
        -- For non-Daily challenges, check if the specific reward matches
        local rewardMatches = false
        
        -- Map reward values to UI-friendly names
        local rewardMapping = {
            ["Fragments"] = "Fragments",
            ["Gems"] = "Gems",
            ["Stats"] = "Stat Rerolls",
            ["Rerolls"] = "Trait Rerolls",
        }
        
        local friendlyReward = rewardMapping[reward] or reward
        
        for _, selectedReward in ipairs(State.SelectedChallengeRewards) do
            if friendlyReward == selectedReward then
                rewardMatches = true
                break
            end
        end
        
        if not rewardMatches then
            --print(string.format("❌ Skipping - Reward '%s' not in selected rewards", friendlyReward))
            return false
        end
    else
        -- NO REWARDS SELECTED - This means user doesn't want to filter by rewards at all
        -- So we should REJECT challenges unless they explicitly want to run any challenge
        -- For now, let's reject if no rewards are selected
        --print("❌ Skipping - No rewards selected (filter active but empty)")
        return false
    end
    
    --print("✓ Challenge passed all filters!")
    return true
end

local function waitForChallengeError(timeout)
    local startTime = tick()
    timeout = timeout or 3 -- Default 3 second timeout
    
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
                        
                        -- Check for "already beaten" message
                        if text:lower():find("already beaten") or text:lower():find("already completed") then
                            --print("✓ Detected challenge completion error:", text)
                            return true
                        end
                    end
                end
            end
            
            return false
        end)
        
        if success and errorDetected then
            return true
        end
        
        task.wait(0.1)
    end
    
    return false
end

local function findAllMatchingChallenges(challengesData, challengeType)
    local matchingChallenges = {}
    
    for challengeIndex, challengeData in pairs(challengesData) do
        -- Skip non-numeric indices
        if type(challengeIndex) ~= "number" then
            continue
        end
        
        -- Check if it matches our filters
        if challengeMatchesFilters(challengeData) then
            -- Score this challenge (higher = better)
            local score = 0
            
            -- Prefer higher acts (more rewards)
            score = score + (challengeData.Act or 0) * 10
            
            table.insert(matchingChallenges, {
                index = challengeIndex,
                data = challengeData,
                score = score
            })
        end
    end
    
    -- Sort by score (highest first)
    table.sort(matchingChallenges, function(a, b)
        return a.score > b.score
    end)
    
    return matchingChallenges
end

local function tryJoinChallengeByIndex(challenge, worldsFrame, LobbyUi)
    -- Find the Half Hourly challenge card in UI
    for _, challengeCard in pairs(worldsFrame:GetChildren()) do
        if challengeCard:FindFirstChild("Container") then
            local container = challengeCard.Container
            local leftInfo = container:FindFirstChild("LeftInfo")
            
            if leftInfo then
                local questName = leftInfo:FindFirstChild("QuestName")
                if not questName then continue end
                
                local challengeName = questName.Text
                
                -- Check if this is Half Hourly challenge
                if challengeName:match("Half Hourly") then
                    -- Click the challenge card
                    local hitbox = challengeCard:FindFirstChild("Hitbox")
                    if hitbox then
                        for _, conn in pairs(getconnections(hitbox.MouseButton1Down)) do
                            if conn.Enabled then conn:Fire() end
                        end
                        task.wait(0.5)
                        
                        -- Select the specific act
                        local actsContainer = LobbyUi.WorldsFrame.Worlds.Content.Acts.Container
                        if actsContainer then
                            local actButtons = {}
                            for _, actButton in pairs(actsContainer:GetChildren()) do
                                if actButton:FindFirstChild("Container") then
                                    table.insert(actButtons, actButton)
                                end
                            end
                            
                            table.sort(actButtons, function(a, b)
                                if a.LayoutOrder ~= b.LayoutOrder then
                                    return a.LayoutOrder < b.LayoutOrder
                                end
                                return a.AbsolutePosition.X < b.AbsolutePosition.X
                            end)
                            
                            local targetActButton = actButtons[challenge.index]
                            
                            if targetActButton then
                                local actHitbox = targetActButton:FindFirstChild("Hitbox")
                                if actHitbox then
                                    for _, actConn in pairs(getconnections(actHitbox.MouseButton1Down)) do
                                        if actConn.Enabled then actConn:Fire() end
                                    end
                                    task.wait(0.3)
                                end
                            end
                        end
                        
                        -- Click select button
                        local selectButton = LobbyUi.WorldsFrame.Worlds.Content.Description.Actions.Container.SelectButton.TextButton
                        for _, selectConn in pairs(getconnections(selectButton.MouseButton1Down)) do
                            if selectConn.Enabled then selectConn:Fire() end
                        end
                        
                        -- ✅ Check for "already completed" error
                        task.wait(0.5)
                        if waitForChallengeError(2) then
                            print("⚠️ Challenge already completed")
                            
                            -- Close error popup
                            pcall(function()
                                local closeButton = LobbyUi.WorldsFrame.Worlds.TopBar.CloseFrame
                                if closeButton then
                                    for _, conn in pairs(getconnections(closeButton.MouseButton1Down)) do
                                        if conn.Enabled then conn:Fire() end
                                    end
                                end
                                task.wait(0.3)
                            end)
                            
                            return "already_completed" -- ✅ Signal to try next challenge
                        end
                        
                        -- No error - continue to start
                        task.wait(0.3)
                        
                        -- Click start button
                        local startButton = LobbyUi.PartyFrame.RightFrame.Content.Buttons.Start.Hitbox
                        for _, startConn in pairs(getconnections(startButton.MouseButton1Up)) do
                            if startConn.Enabled then startConn:Fire() end
                        end
                        
                        print(string.format("✓ Successfully joined Half Hourly challenge (Map: %s, Act: %d, Reward: %s)", 
                            challenge.data.Map, challenge.data.Act, challenge.data.Reward))
                        
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

local function handleChallengeSelection()
    local PlayerGui = Services.Players.LocalPlayer.PlayerGui
    local LobbyUi = PlayerGui:WaitForChild("LobbyUi")
    
    task.wait(1)
    
    local worldsFrame = LobbyUi.WorldsFrame.Worlds.Content.Worlds.frame
    if not worldsFrame then
        warn("Worlds frame not found")
        return false, "none"
    end
    
    -- Priority 1: Regular Challenges with filtering
    if State.AutoJoinChallenge then
        print("Looking for Half Hourly challenges with filtering...")
        
        local challengesData = getCurrentChallengesData()
        
        if not challengesData then
            warn("Could not get challenges data from ChallengeController")
        else
            print("✓ Got challenges data from ChallengeController")
            
            local typeChallenges = challengesData["HalfHour"]
            if typeChallenges then
                -- ✅ NEW: Get ALL matching challenges (not just best one)
                local matchingChallenges = findAllMatchingChallenges(typeChallenges, "HalfHour")
                
                if #matchingChallenges > 0 then
                    print(string.format("Found %d matching challenges", #matchingChallenges))
                    
                    -- ✅ Try each matching challenge in order
                    for attemptNum, challenge in ipairs(matchingChallenges) do
                        print(string.format("Attempting challenge %d/%d: Index %d, Map=%s, Act=%d, Reward=%s", 
                            attemptNum, #matchingChallenges, challenge.index, 
                            challenge.data.Map, challenge.data.Act, challenge.data.Reward))
                        
                        -- Find and click this challenge in the UI
                        local success = tryJoinChallengeByIndex(challenge, worldsFrame, LobbyUi)
                        
                        if success == "already_completed" then
                            print("Challenge already completed - trying next one...")
                            continue -- ✅ Try the next matching challenge
                        elseif success == true then
                            print("✅ Successfully joined challenge!")
                            return true, "regular"
                        else
                            warn("Failed to join challenge - trying next one...")
                            continue
                        end
                    end
                    
                    -- ✅ All matching challenges exhausted
                    print("All matching Half Hourly challenges already completed")
                else
                    print("No Half Hourly challenges match the filters")
                end
            else
                print("No Half Hourly challenges found in data")
            end
        end
    end
    
    -- Priority 2: Featured Challenge (fallback)
    if State.AutoJoinFeaturedChallenge then
        print("Looking for Featured Challenge...")
        
        for _, challengeCard in pairs(worldsFrame:GetChildren()) do
            if challengeCard:FindFirstChild("Container") then
                local container = challengeCard.Container
                local leftInfo = container:FindFirstChild("LeftInfo")
                
                if leftInfo then
                    local questName = leftInfo:FindFirstChild("QuestName")
                    if questName and questName.Text == "Featured Challenge" then
                        print("✓ Found Featured Challenge!")
                        
                        local hitbox = challengeCard:FindFirstChild("Hitbox")
                        if hitbox then
                            for _, conn in pairs(getconnections(hitbox.MouseButton1Down)) do
                                if conn.Enabled then
                                    conn:Fire()
                                end
                            end
                            task.wait(0.3)
                            
                            local selectButton = LobbyUi.WorldsFrame.Worlds.Content.Description.Actions.Container.SelectButton.TextButton
                            for _, selectConn in pairs(getconnections(selectButton.MouseButton1Down)) do
                                if selectConn.Enabled then
                                    selectConn:Fire()
                                end
                            end
                            task.wait(0.3)
                            
                            local startButton = LobbyUi.PartyFrame.RightFrame.Content.Buttons.Start.Hitbox
                            for _, startConn in pairs(getconnections(startButton.MouseButton1Up)) do
                                if startConn.Enabled then
                                    startConn:Fire()
                                end
                            end
                            
                            print("✓ Successfully joined Featured Challenge")
                            return true, "featured"
                        end
                    end
                end
            end
        end
    end
    
    warn("No matching challenges found")

    pcall(function()
        local closeButton = LobbyUi.WorldsFrame.Worlds.TopBar.CloseFrame
        if closeButton then
            for _, conn in pairs(getconnections(closeButton.MouseButton1Down)) do
                if conn.Enabled then conn:Fire() end
            end
        end
        
        task.wait(0.3)
        
        local quitButton = LobbyUi.StartPod.Main.Buttons.Container.Leave.Hitbox
        if quitButton then
            for _, conn in pairs(getconnections(quitButton.MouseButton1Down)) do
                if conn.Enabled then conn:Fire() end
            end
        end
    end)
    
    warn("No matching challenges available to join")
    return false, "none"
end

local function autoJoinGameViaUI(gameMode, worldName, actNumber, difficulty, difficultyPercent)
    -- Step 0: Activate the correct pod UI based on game mode
    local podName = nil
    if gameMode == "Virtual" then
        podName = "VirtualRealm"
    elseif gameMode == "Challenge" then
        podName = "Challenge"
    elseif gameMode == "Story" then
        podName = "Story"
    elseif gameMode == "Legend" then
        podName = "Story" -- Legend stages also use Story pod
    end
    
    if podName then
        print(string.format("Activating %s pod UI...", podName))
        local activated = activatePodUI(podName)
        if not activated then
            warn("Failed to activate pod UI")
            return false
        end
        task.wait(0.5)
    end
    
    local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local LobbyUi = PlayerGui:WaitForChild("LobbyUi")
    
    -- Step 1: Open the create game menu
    local createButton = LobbyUi.StartPod.Main.Buttons.Create.Hitbox
    for _, conn in pairs(getconnections(createButton.MouseButton1Down)) do
        if conn.Enabled then
            conn:Fire()
        end
    end
    task.wait(0.5)
    
    -- Step 2: For Virtual and Challenge, skip mode selection (no mode button exists)
    -- For Story and Legend, select the game mode
    if gameMode == "Story" or gameMode == "Legend" then
        local worldMode = LobbyUi.WorldsFrame.Worlds.WorldMode
        local modeButton = nil
        
        if gameMode == "Story" then
            modeButton = worldMode:FindFirstChild("Story")
        elseif gameMode == "Legend" then
            modeButton = worldMode:FindFirstChild("Legend")
        end
        
        if modeButton and modeButton:FindFirstChild("Hitbox") then
            for _, conn in pairs(getconnections(modeButton.Hitbox.MouseButton1Down)) do
                if conn.Enabled then
                    conn:Fire()
                end
            end
            task.wait(0.5)
        else
            warn("Game mode button not found:", gameMode)
            return false
        end
    end
    
    -- For Challenge mode, handle challenge selection
    if gameMode == "Challenge" then
        print("Challenge mode selected - handling challenge selection")
        return handleChallengeSelection()
    end
    
    -- Step 3: Find and select the world (for Story/Legend/Virtual)
    local worldsFrame = LobbyUi.WorldsFrame.Worlds.Content.Worlds.frame
    local foundWorld = false
    
    for _, worldButton in pairs(worldsFrame:GetChildren()) do
        if worldButton:FindFirstChild("Container") then
            local questName = worldButton.Container.LeftInfo.QuestName
            if questName.Text == worldName then
                for _, conn in pairs(getconnections(worldButton.Hitbox.MouseButton1Down)) do
                    if conn.Enabled then
                        conn:Fire()
                    end
                end
                foundWorld = true
                break
            end
        end
    end
    
    if not foundWorld then
        warn("World not found:", worldName)
        return false
    end
    task.wait(0.3)
    
    -- Step 4: Select the act
    local actsContainer = LobbyUi.WorldsFrame.Worlds.Content.Acts.Container
    local foundAct = false
    
    if actNumber == "Infinite" or tostring(actNumber) == "Infinite" then
        print("Looking for Infinite act...")
        for _, actButton in pairs(actsContainer:GetChildren()) do
            if actButton:FindFirstChild("Container") then
                local actNum = actButton.Container.ActNumber
                if actNum.Text == "∞" or actNum.Text:lower():find("infinite") then
                    for _, conn in pairs(getconnections(actButton.Hitbox.MouseButton1Down)) do
                        if conn.Enabled then
                            conn:Fire()
                        end
                    end
                    foundAct = true
                    print("✓ Found Infinite act")
                    break
                end
            end
        end
    else
        -- Regular numbered acts
        for _, actButton in pairs(actsContainer:GetChildren()) do
            if actButton:FindFirstChild("Container") then
                local actNum = actButton.Container.ActNumber
                if actNum.Text == "Act " .. tostring(actNumber) then
                    for _, conn in pairs(getconnections(actButton.Hitbox.MouseButton1Down)) do
                        if conn.Enabled then
                            conn:Fire()
                        end
                    end
                    foundAct = true
                    break
                end
            end
        end
    end
    
    if not foundAct then
        warn("Act not found:", actNumber)
        return false
    end
    task.wait(0.3)
    
    -- Step 5: Set difficulty (if applicable - Legend stages might not have this)
    if difficulty then
        local difficultiesContainer = LobbyUi.WorldsFrame.Worlds.Content.Description.Content.Main.Container.BottomInfo.DifficultiesContainer
        local difficultyButton = difficultiesContainer:FindFirstChild(difficulty)
        
        if difficultyButton then
            for _, conn in pairs(getconnections(difficultyButton.TextButton.MouseButton1Down)) do
                if conn.Enabled then
                    conn:Fire()
                end
            end
            task.wait(0.3)
        else
            warn("Difficulty not found:", difficulty)
        end
    end
    
    -- Step 6: Set difficulty meter percentage
    local modulationFrame = LobbyUi.WorldsFrame.Worlds.Content.Description.Content.Main.Container.BottomInfo.Modulation
    
    for _, child in pairs(modulationFrame:GetDescendants()) do
        if child:IsA("TextBox") then
            child.Text = tostring(difficultyPercent)
            for _, conn in pairs(getconnections(child.FocusLost)) do
                conn:Fire()
            end
            break
        end
    end
    task.wait(0.3)
    
    -- Step 7: Create the lobby
    local selectButton = LobbyUi.WorldsFrame.Worlds.Content.Description.Actions.Container.SelectButton.TextButton
    for _, conn in pairs(getconnections(selectButton.MouseButton1Down)) do
        if conn.Enabled then
            conn:Fire()
        end
    end
    task.wait(0.3)
    
    -- Step 8: Start game
    local startButton = LobbyUi.PartyFrame.RightFrame.Content.Buttons.Start.Hitbox
    for _, conn in pairs(getconnections(startButton.MouseButton1Up)) do
        if conn.Enabled then
            conn:Fire()
        end
    end
    
    return true
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    if not canPerformAction() then return end
    
    -- Check if lobby creation UI is already open
    if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi") then
        local lobbyUi = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
        if (lobbyUi:FindFirstChild("PartyFrame") and lobbyUi:FindFirstChild("PartyFrame").Enabled) or 
           (lobbyUi:FindFirstChild("WorldsFrame") and lobbyUi:FindFirstChild("WorldsFrame").Enabled) then
            return
        end
    end

    -- Priority 1: Challenge Auto Join
    if (State.AutoJoinFeaturedChallenge or State.AutoJoinChallenge) then
        local regularChallengeOnCooldown = false

        if State.AutoJoinChallenge then
            local timeSinceLastFail = tick() - (State.LastFailedChallengeAttempt or 0)
            
            if State.LastFailedChallengeAttempt > 0 and timeSinceLastFail < State.ChallengeJoinCooldown then
                regularChallengeOnCooldown = true
            end
        end
        
        -- Try Regular Challenge (if not on cooldown)
        if State.AutoJoinChallenge and not regularChallengeOnCooldown then
            setProcessingState("Challenge Auto Join")
            
            local challenges = getCurrentChallengesData()
            
            if challenges and challenges["HalfHour"] then
                local matchingChallenges = findAllMatchingChallenges(challenges["HalfHour"], "HalfHour")
                
                if #matchingChallenges > 0 then
                    for _, challenge in ipairs(matchingChallenges) do
                        -- Use API method instead of UI
                        local success = joinChallengeViaAPI("HalfHour", challenge.index)
                        
                        if success then
                            print("✅ Successfully joined challenge via API!")
                            State.LastFailedChallengeAttempt = 0
                            task.delay(5, clearProcessingState)
                            return
                        end
                        
                        task.wait(1) -- Small delay between attempts
                    end
                    
                    -- All failed
                    State.LastFailedChallengeAttempt = tick()
                end
            end
            
            clearProcessingState()
        end
        
        -- Try Featured Challenge
        if State.AutoJoinFeaturedChallenge then
            setProcessingState("Featured Challenge Auto Join")
            
            local success = joinFeaturedChallengeViaAPI()
            
            if success then
                print("✅ Successfully joined Featured Challenge via API!")
                task.delay(5, clearProcessingState)
                return
            end
            
            clearProcessingState()
        end
    end

    -- Priority 2: Story Auto Join
    if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and 
       State.StoryDifficultySelected and State.StoryDifficultyMeterSelected then
        setProcessingState("Story Auto Join")
        
        local success = joinStoryViaAPI(
            State.StoryStageSelected,
            State.StoryActSelected,
            State.StoryDifficultySelected,
            State.StoryDifficultyMeterSelected
        )
        
        if success then
            print("✅ Successfully joined Story via API!")
            task.delay(5, clearProcessingState)
            return
        else
            clearProcessingState()
        end
    end
    
    -- Priority 3: Legend Stage Auto Join
    if State.AutoJoinLegendStage and State.LegendStageSelected and State.LegendStageActSelected and 
       State.LegendStageDifficultyMeterSelected then
        setProcessingState("Legend Stage Auto Join")
        
        local success = joinLegendViaAPI(
            State.LegendStageSelected,
            tonumber(State.LegendStageActSelected),
            State.LegendStageDifficultyMeterSelected
        )
        
        if success then
            print("✅ Successfully joined Legend Stage via API!")
            task.delay(5, clearProcessingState)
            return
        else
            clearProcessingState()
        end
    end
    
    -- Priority 4: Virtual Stage Auto Join
    if State.AutoJoinVirtualStage and State.VirtualStageSelected and State.VirtualStageActSelected and 
       State.VirtualStageDifficultySelected and State.VirtualStageDifficultyMeterSelected then
        setProcessingState("Virtual Stage Auto Join")
        
        local success = joinVirtualViaAPI(
            State.VirtualStageSelected,
            tonumber(State.VirtualStageActSelected),
            State.VirtualStageDifficultySelected,
            State.VirtualStageDifficultyMeterSelected
        )
        
        if success then
            print("✅ Successfully joined Virtual Stage via API!")
            task.delay(5, clearProcessingState)
            return
        else
            clearProcessingState()
        end
    end
end

--[[--------------------------------------------------------------]]

local AutoPathToggle = AutoPathTab:CreateToggle({
    Name = "Auto Select Path",
    CurrentValue = false,
    Flag = "AutoSelectPath",
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
        savePathPriorities()
    end,
})

Label = AutoPathTab:CreateLabel("tip: use the search icon")

AutoPathTab:CreateDivider()

local function loadPathSliders()
    local PathsFolder = game:GetService("ReplicatedStorage").Shared.Data.Paths
    
    -- Check if config file exists
    local playerName = game:GetService("Players").LocalPlayer.Name
    local configPath = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    local configExists = isfile(configPath)
    
    -- Load saved priorities (empty table if file doesn't exist)
    local savedPriorities = configExists and loadPathPriorities() or {}

    for key, value in pairs(savedPriorities) do
        PathState.BlessingPriorities[key] = value
    end
    
    -- Store paths and their blessings
    local pathsData = {}
    
    for _, pathModule in ipairs(PathsFolder:GetChildren()) do
        if pathModule:IsA("ModuleScript") then
            local success, pathData = pcall(function()
                return require(pathModule)
            end)
            
            if success and pathData.Blessings then
                local pathName = pathModule.Name
                pathsData[pathName] = {
                    blessings = {},
                    resonanceName = nil
                }
                
                -- Get Resonance name (this is "Shared Bonds", "Future Wealth", etc.)
                if pathData.Resonance and pathData.Resonance.Name then
                    pathsData[pathName].resonanceName = pathData.Resonance.Name
                    --(string.format("Found Resonance: %s -> '%s'", pathName, pathData.Resonance.Name))
                end
                
                -- Collect all blessings from all rarities
                for rarity, blessings in pairs(pathData.Blessings) do
                    for blessingName, blessingData in pairs(blessings) do
                        table.insert(pathsData[pathName].blessings, {
                            name = blessingName,
                            rarity = rarity
                        })
                    end
                end
                
                -- Sort blessings alphabetically
                table.sort(pathsData[pathName].blessings, function(a, b)
                    return a.name < b.name
                end)
            end
        end
    end
    
    -- Sort paths alphabetically
    local sortedPaths = {}
    for pathName in pairs(pathsData) do
        table.insert(sortedPaths, pathName)
    end
    table.sort(sortedPaths)
    
    -- Only calculate incremental priorities if config doesn't exist
    local currentPriority = nil
    if not configExists then
        -- Count total: resonance names + blessings
        local totalItems = 0
        for _, pathInfo in pairs(pathsData) do
            if pathInfo.resonanceName then
                totalItems = totalItems + 1 -- For resonance name
            end
            totalItems = totalItems + #pathInfo.blessings
        end
        currentPriority = totalItems
        print("generating incremental values")
    else
        print("Loading priorities from config file")
    end
    
    -- Create sections and sliders for each path
    for _, pathName in ipairs(sortedPaths) do
        local pathInfo = pathsData[pathName]
        
        -- CREATE RESONANCE SLIDER (e.g., "Shared Bonds")
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
            local displayName = string.format("[%s] %s", pathName, pathInfo.resonanceName)
            
            local slider = AutoPathTab:CreateSlider({
                Name = displayName,
                Range = {0, 100},
                Increment = 1,
                CurrentValue = sliderValue,
                Flag = "PathPriority_Resonance_" .. resonanceKey,
                Callback = function(Value)
                    PathState.BlessingPriorities[resonanceKey] = Value
                    savePathPriorities()
                end,
            })
            
            table.insert(pathSliders, slider)
        end
        
        -- CREATE BLESSING SLIDERS
        local blessings = pathInfo.blessings
        
        -- Create slider for each blessing
        for _, blessing in ipairs(blessings) do
            --print(string.format("Module blessing name: '%s'", blessing.name))
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

            local displayName = string.format("[%s] %s", pathName, blessing.name)
            
            local slider = AutoPathTab:CreateSlider({
                Name = displayName,
                Range = {0, 100},
                Increment = 1,
                CurrentValue = sliderValue,
                Flag = "PathPriority_" .. pathName .. "_" .. blessing.name:gsub("%s", ""),
                Callback = function(Value)
                    PathState.BlessingPriorities[sliderKey] = Value
                    savePathPriorities()
                end,
            })
            
            table.insert(pathSliders, slider)
        end
        
        -- Add divider between paths
        AutoPathTab:CreateDivider()
    end
    
    -- Save the incremental defaults if this was first run
    if not configExists then
        savePathPriorities()
    end
    
    --print("Loaded path sliders successfully")
end

task.spawn(function()
    task.wait(2)
    
    local success, err = pcall(loadPathSliders)
    if not success then
        warn("Failed to load path sliders:", err)
        AutoPathTab:CreateLabel("⚠️ Failed to load paths")
    end
end)

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
    Name = "Select Story Stage",
    Options = {},
    CurrentOption = {},
    Flag = "StoryStageSelector",
    Callback = function(Option)
        State.StoryStageSelected = Option[1]
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
                State.StoryActSelected = "Infinite"
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
        Options = {"Easy","Hard","Nightmare"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "StoryDifficultySelector",
        Callback = function(Option)
            if Option[1] == "Easy" then
                State.StoryDifficultySelected = "Easy"
            elseif Option[1] == "Hard" then
                State.StoryDifficultySelected = "Hard"
            elseif Option[1] == "Nightmare" then
                State.StoryDifficultySelected = "Nightmare"
            end
        end,
    })

    StorySlider = JoinerTab:CreateSlider({
   Name = "Select Difficulty Meter",
   Range = {75, 1000},
   Increment = 1,
   Suffix = "",
   CurrentValue = 100,
   Flag = "StoryDifficultyMeterSelector",
   Callback = function(Value)
    State.StoryDifficultyMeterSelected = Value
   end,
})

    section = JoinerTab:CreateSection("Legend Stage Joiner")

    AutoJoinLegendToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Legend Stage",
        CurrentValue = false,
        Flag = "AutoJoinLegendStage",
        Callback = function(Value)
            State.AutoJoinLegendStage = Value
        end,
    })

local LegendStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage",
    Options = {},
    CurrentOption = {},
    Flag = "LegendStageSelector",
    Callback = function(Option)
        State.LegendStageSelected = Option[1]
    end,
})

    LegendChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Legend Stage Act",
        Options = {"Act 1", "Act 2", "Act 3"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "LegendStageActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            
            local num = selectedOption:match("%d+")
            if num then
                State.LegendStageActSelected = num
            end
        end,
    })

     LegendSlider = JoinerTab:CreateSlider({
   Name = "Select Difficulty Meter",
   Range = {75, 1000},
   Increment = 1,
   Suffix = "",
   CurrentValue = 100,
   Flag = "LegendStageDifficultyMeterSelector",
   Callback = function(Value)
    State.LegendStageDifficultyMeterSelected = Value
   end,
})

   section = JoinerTab:CreateSection("Virtual Stage Joiner")

    AutoJoinVirtualToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Virtual Stage",
        CurrentValue = false,
        Flag = "AutoJoinVirtualStage",
        Callback = function(Value)
            State.AutoJoinVirtualStage = Value
        end,
    })

local VirtualStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Virtual Stage",
    Options = {},
    CurrentOption = {},
    Flag = "VirtualStageSelector",
    Callback = function(Options)
        State.VirtualStageSelected = Options[1]
    end,
})

    VirtualChapterDropdown = JoinerTab:CreateDropdown({
        Name = "Select Virtual Stage Act",
        Options = {"Act 1", "Act 2", "Act 3"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "VirtualStageActSelector",
        Callback = function(Option)
            local selectedOption = type(Option) == "table" and Option[1] or Option
            
            local num = selectedOption:match("%d+")
            if num then
                State.VirtualStageActSelected = num
            end
        end,
    })

    VirtualDifficultyDropdown = JoinerTab:CreateDropdown({
        Name = "Select Virtual Difficulty",
        Options = {"Easy","Hard","Nightmare"},
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "VirtualStageDifficultySelector",
        Callback = function(Option)
            if Option[1] == "Easy" then
                State.VirtualStageDifficultySelected = "Easy"
            elseif Option[1] == "Hard" then
                State.VirtualStageDifficultySelected = "Hard"
            elseif Option[1] == "Nightmare" then
                State.VirtualStageDifficultySelected = "Nightmare"
            end
        end,
    })

     VirtualSlider = JoinerTab:CreateSlider({
   Name = "Select Difficulty Meter",
   Range = {75, 1000},
   Increment = 1,
   Suffix = "",
   CurrentValue = 100,
   Flag = "VirtualStageDifficultyMeterSelector",
   Callback = function(Value)
    State.VirtualStageDifficultyMeterSelected = Value
   end,
})

section = JoinerTab:CreateSection("Challenge Joiner")

        AutoJoinFeaturedChallengeToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Featured Challenge (The Hunt)",
        CurrentValue = false,
        Flag = "AutoJoinFeaturedChallenge",
        Callback = function(Value)
            State.AutoJoinFeaturedChallenge = Value
        end,
    })

        AutoJoinChallengeToggle = JoinerTab:CreateToggle({
        Name = "Auto Join Challenge",
        CurrentValue = false,
        Flag = "AutoJoinChallenge",
        Callback = function(Value)
            State.AutoJoinChallenge = Value
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

   local IgnoreModifierDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Modifier",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "IgnoreModifierSelector",
    Info = "Skip challenges based on these modifiers",
    Callback = function(Options)
        -- Convert display names to module names
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
        Name = "Select Challenge Rewards",
        Options = {"Fragments","Gems","Stat Rerolls","Trait Rerolls"},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "SelectedChallengeRewards",
        Info = "Only join challenges that contain one or more of these rewards",
        Callback = function(Options)
            State.SelectedChallengeRewards = Options or {}
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
    local success = pcall(function()
        return Services.ReplicatedStorage:FindFirstChild("Shared") and
               Services.ReplicatedStorage.Shared:FindFirstChild("Data")
    end)
    return success
end

local function buildMapLookup()
    print("Building map name lookup...")
    
    local success, result = pcall(function()
        local WavesFolder = Services.ReplicatedStorage.Shared.Data.Waves
        
        if not WavesFolder then
            warn("Waves folder not found")
            return false
        end
        
        local count = 0
        
        -- For each module in Waves folder
        for _, stageModule in ipairs(WavesFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function()
                    return require(stageModule)
                end)
                
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    -- UI Name -> Module Name
                    -- Example: "Ninja Village" -> "FinalValley"
                    local uiName = stageData.Information.Name
                    local moduleName = stageModule.Name
                    
                    UINameToModuleName[uiName] = moduleName
                    
                    count = count + 1
                    print(string.format("  '%s' -> '%s'", uiName, moduleName))
                end
            end
        end
        
        print(string.format("✓ Built lookup with %d entries", count))
        return true
    end)
    
    return success and result
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
            if StoryStageDropdown then
                StoryStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
        return
    end
    
    local success, result = pcall(function()
        local WavesFolder = Services.ReplicatedStorage.Shared.Data.Waves
        
        if not WavesFolder then
            error("Waves folder not found")
        end

        local displayNames = {}
        
        -- Get all module scripts (stages)
        for _, stageModule in ipairs(WavesFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function()
                    return require(stageModule)
                end)
                
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        
        if #displayNames == 0 then
            error("No story stages found")
        end
        
        -- Sort alphabetically
        table.sort(displayNames)
        
        return displayNames
    end)
    
    if success and result and #result > 0 then
        if StoryStageDropdown then
            StoryStageDropdown:Refresh(result)
        end
        if IgnoreWorldsDropdown then 
            IgnoreWorldsDropdown:Refresh(result)
        end
        print(string.format("Successfully loaded %d story stages (attempt %d)", #result, loadingRetries.story))
        print(string.format("Successfully loaded %d ignore world stages (attempt %d)", #result, loadingRetries.story))
    else
        if loadingRetries.story <= maxRetries then
            print(string.format("Story stages loading failed (attempt %d/%d): %s - retrying...", loadingRetries.story, maxRetries, tostring(result)))
            task.wait(retryDelay)
            task.spawn(loadAllStoryStagesWithRetry)
        else
            warn("Failed to load story stages after", maxRetries, "attempts:", result)
            if StoryStageDropdown then
                StoryStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end
end

-- LEGEND STAGES LOADER
local function loadAllLegendStagesWithRetry()
    loadingRetries.legend = loadingRetries.legend + 1
    
    if not isGameDataLoaded() then
        if loadingRetries.legend <= maxRetries then
            print(string.format("Legend stages loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.legend, maxRetries))
            task.wait(retryDelay)
            task.spawn(loadAllLegendStagesWithRetry)
        else
            warn("Failed to load legend stages after", maxRetries, "attempts - giving up")
            if LegendStageDropdown then
                LegendStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
        return
    end
    
    local success, result = pcall(function()
        local LegendFolder = Services.ReplicatedStorage.Shared.Data.LegendStages
        
        if not LegendFolder then
            error("LegendStages folder not found")
        end

        local displayNames = {}
        
        -- Get all module scripts (stages)
        for _, stageModule in ipairs(LegendFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function()
                    return require(stageModule)
                end)
                
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        
        if #displayNames == 0 then
            error("No legend stages found")
        end
        
        -- Sort alphabetically
        table.sort(displayNames)
        
        return displayNames
    end)
    
    if success and result and #result > 0 then
        if LegendStageDropdown then
            LegendStageDropdown:Refresh(result)
        end
        print(string.format("Successfully loaded %d legend stages (attempt %d)", #result, loadingRetries.legend))
    else
        if loadingRetries.legend <= maxRetries then
            print(string.format("Legend stages loading failed (attempt %d/%d): %s - retrying...", loadingRetries.legend, maxRetries, tostring(result)))
            task.wait(retryDelay)
            task.spawn(loadAllLegendStagesWithRetry)
        else
            warn("Failed to load legend stages after", maxRetries, "attempts:", result)
            if LegendStageDropdown then
                LegendStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end
end

-- VIRTUAL STAGES LOADER
local function loadAllVirtualStagesWithRetry()
    loadingRetries.portal = loadingRetries.portal + 1
    
    if not isGameDataLoaded() then
        if loadingRetries.portal <= maxRetries then
            print(string.format("Virtual stages loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.portal, maxRetries))
            task.wait(retryDelay)
            task.spawn(loadAllVirtualStagesWithRetry)
        else
            warn("Failed to load virtual stages after", maxRetries, "attempts - giving up")
            if VirtualStageDropdown then
                VirtualStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
        return
    end
    
    local success, result = pcall(function()
        local VirtualFolder = Services.ReplicatedStorage.Shared.Data.VirtualRealm
        
        if not VirtualFolder then
            error("VirtualRealm folder not found")
        end

        local displayNames = {}
        
        -- Get all module scripts (stages)
        for _, stageModule in ipairs(VirtualFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function()
                    return require(stageModule)
                end)
                
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        
        if #displayNames == 0 then
            error("No virtual stages found")
        end
        
        -- Sort alphabetically
        table.sort(displayNames)
        
        return displayNames
    end)
    
    if success and result and #result > 0 then
        if VirtualStageDropdown then
            VirtualStageDropdown:Refresh(result)
        end
        print(string.format("Successfully loaded %d virtual stages (attempt %d)", #result, loadingRetries.portal))
    else
        if loadingRetries.portal <= maxRetries then
            print(string.format("Virtual stages loading failed (attempt %d/%d): %s - retrying...", loadingRetries.portal, maxRetries, tostring(result)))
            task.wait(retryDelay)
            task.spawn(loadAllVirtualStagesWithRetry)
        else
            warn("Failed to load virtual stages after", maxRetries, "attempts:", result)
            if VirtualStageDropdown then
                VirtualStageDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end
end

local function loadAllChallengeModifiersWithRetry()
    loadingRetries.modifiers = (loadingRetries.modifiers or 0) + 1
    
    if not isGameDataLoaded() then
        if loadingRetries.modifiers <= maxRetries then
            print(string.format("Challenge modifiers loading failed (attempt %d/%d) - game data not ready, retrying...", loadingRetries.modifiers, maxRetries))
            task.wait(retryDelay)
            task.spawn(loadAllChallengeModifiersWithRetry)
        else
            warn("Failed to load challenge modifiers after", maxRetries, "attempts - giving up")
            if IgnoreModifierDropdown then
                IgnoreModifierDropdown:Refresh({"Failed to load - check console"})
            end
        end
        return
    end
    
    local success, result = pcall(function()
        local ChallengesFolder = Services.ReplicatedStorage.Shared.Data.Challenges
        
        if not ChallengesFolder then
            error("Challenges folder not found")
        end

        local challengeModifiers = {}
        local seenTags = {}
        
        -- Get all module scripts that contain "HalfHour" in name (Half Hourly challenges only)
        for _, challengeModule in ipairs(ChallengesFolder:GetChildren()) do
            if challengeModule:IsA("ModuleScript") and string.find(challengeModule.Name, "HalfHour") then
                local challengeSuccess, challengeData = pcall(function()
                    return require(challengeModule)
                end)
                
                if challengeSuccess and challengeData and challengeData.ChallengeTag then
                    -- Only add if we haven't seen this tag before
                    if not seenTags[challengeData.ChallengeTag] then
                        table.insert(challengeModifiers, {
                            DisplayName = challengeData.ChallengeTag,
                            ModuleName = challengeModule.Name
                        })
                        seenTags[challengeData.ChallengeTag] = true
                    end
                end
            end
        end
        
        if #challengeModifiers == 0 then
            error("No challenge modifiers found")
        end
        
        -- Sort alphabetically by display name
        table.sort(challengeModifiers, function(a, b)
            return a.DisplayName < b.DisplayName
        end)
        
        return challengeModifiers
    end)
    
    if success and result and #result > 0 then
        if IgnoreModifierDropdown then
            -- Store the mapping at script level
            ModifierMapping = result

            -- Build reverse lookup table
            ModifierModuleToTag = {}
            for _, modifier in ipairs(result) do
                ModifierModuleToTag[modifier.ModuleName] = modifier.DisplayName
            end
            
            -- Extract just the display names for the dropdown
            local displayNames = {}
            for _, modifier in ipairs(result) do
                table.insert(displayNames, modifier.DisplayName)
            end
            IgnoreModifierDropdown:Refresh(displayNames)
        end
        print(string.format("Successfully loaded %d challenge modifiers (attempt %d)", #result, loadingRetries.modifiers))
    else
        if loadingRetries.modifiers <= maxRetries then
            print(string.format("Challenge modifiers loading failed (attempt %d/%d): %s - retrying...", loadingRetries.modifiers, maxRetries, tostring(result)))
            task.wait(retryDelay)
            task.spawn(loadAllChallengeModifiersWithRetry)
        else
            warn("Failed to load challenge modifiers after", maxRetries, "attempts:", result)
            if IgnoreModifierDropdown then
                IgnoreModifierDropdown:Refresh({"Failed to load - check console"})
            end
        end
    end
end

local function saveWorldMappings()
    ensureMacroFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local fileName = string.format("LixHub/%s_WorldMappings_UTD.json", playerName)
    
    local json = game:GetService("HttpService"):JSONEncode(worldMacroMappings)
    writefile(fileName, json)
    print("✓ Saved world macro mappings")
end

local function loadWorldMappings()
    ensureMacroFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local filePath = string.format("LixHub/%s_WorldMappings_UTD.json", playerName)
    
    if not isfile(filePath) then
        return {}
    end
    
    local json = readfile(filePath)
    local data = game:GetService("HttpService"):JSONDecode(json)
    
    print("✓ Loaded world macro mappings")
    return data or {}
end

local function getCurrentWorldKey()
    local category = workspace:GetAttribute("Category")
    local mapName = workspace:GetAttribute("MapName") -- UI display name
    local mapInternal = workspace:GetAttribute("Map") -- Internal module name
    
    if not category or not mapName then
        return nil
    end
    
    -- Normalize category to match our key format
    local categoryLower = category:lower()
    
    -- For Story category (which includes challenges) - use challenge_ prefix
    if categoryLower == "story" then
        -- Check if it's featured challenge (Frozen Stronghold)
        if mapName:lower():find("frozen") or mapName == "Frozen Stronghold" then
            return "challenge_featured"
        end
        
        -- Regular challenge - ALWAYS use UI mapName with underscores (to match dropdown keys)
        return "challenge_" .. mapName:lower():gsub("%s+", "_")
    end
    
    -- For Legend stages - use internal module name if available
    if categoryLower == "legend" then
        if mapInternal then
            return "legend_" .. mapInternal:lower()
        else
            -- Fallback: convert UI name to module name using our lookup
            local moduleName = UINameToModuleName[mapName]
            if moduleName then
                return "legend_" .. moduleName:lower()
            end
        end
    end
    
    -- For Virtual stages
    if categoryLower:find("virtual") then
        return "virtual_" .. mapName:lower():gsub("%s+", "_")
    end
    
    return nil
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

local function createAutoSelectDropdowns()
    print("Creating auto-select dropdowns...")
    
    -- Get initial macro options
    local initialMacroOptions = {"None"}
    for macroName in pairs(macroManager) do
        table.insert(initialMacroOptions, macroName)
    end
    table.sort(initialMacroOptions)
        
    -- Wait for story stages to load
    task.wait(1)
    
    -- Legend Stages Collapsible
    local LegendCollapsible = Tab:CreateCollapsible({
        Name = "Select Legend Stage Macro",
        DefaultExpanded = false,
        Flag = "LegendMacroCollapsible"
    })
    
    if LegendStageDropdown and LegendStageDropdown.Options then
        for _, stageName in ipairs(LegendStageDropdown.Options) do
            -- Get module name from ReplicatedStorage
            local success, legendData = pcall(function()
                local LegendFolder = Services.ReplicatedStorage.Shared.Data.LegendStages
                for _, stageModule in ipairs(LegendFolder:GetChildren()) do
                    if stageModule:IsA("ModuleScript") then
                        local stageData = require(stageModule)
                        if stageData.Information and stageData.Information.Name == stageName then
                            return stageModule.Name
                        end
                    end
                end
                return nil
            end)
            
            if success and legendData then
                local worldKey = "legend_" .. legendData:lower()
                local currentMapping = worldMacroMappings[worldKey] or "None"
                
                local dropdown = LegendCollapsible.Tab:CreateDropdown({
                    Name = stageName,
                    Options = initialMacroOptions,
                    CurrentOption = {currentMapping},
                    MultipleOptions = false,
                    Flag = "WorldMacro_" .. worldKey,
                    Callback = function(Option)
                        local selectedMacro = type(Option) == "table" and Option[1] or Option
                        
                        if selectedMacro == "None" or selectedMacro == "" then
                            worldMacroMappings[worldKey] = nil
                            print("Cleared auto-select for", stageName, "(Legend)")
                        else
                            worldMacroMappings[worldKey] = selectedMacro
                            print("Set auto-select:", stageName, "(Legend) ->", selectedMacro)
                        end
                        
                        saveWorldMappings()
                    end,
                })
                
                worldDropdowns[worldKey] = dropdown
            end
        end
    end
    
    -- Virtual Stages Collapsible
    local VirtualCollapsible = Tab:CreateCollapsible({
        Name = "Select Virtual Stage Macro",
        DefaultExpanded = false,
        Flag = "VirtualMacroCollapsible"
    })
    
    if VirtualStageDropdown and VirtualStageDropdown.Options then
        for _, stageName in ipairs(VirtualStageDropdown.Options) do
            local worldKey = "virtual_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            
            local dropdown = VirtualCollapsible.Tab:CreateDropdown({
                Name = stageName,
                Options = initialMacroOptions,
                CurrentOption = {currentMapping},
                MultipleOptions = false,
                Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    
                    if selectedMacro == "None" or selectedMacro == "" then
                        worldMacroMappings[worldKey] = nil
                        print("Cleared auto-select for", stageName, "(Virtual)")
                    else
                        worldMacroMappings[worldKey] = selectedMacro
                        print("Set auto-select:", stageName, "(Virtual) ->", selectedMacro)
                    end
                    
                    saveWorldMappings()
                end,
            })
            
            worldDropdowns[worldKey] = dropdown
        end
    end
    
    -- Featured Challenge Collapsible
    local FeaturedChallengeCollapsible = Tab:CreateCollapsible({
        Name = "Select Featured Challenge Macro",
        DefaultExpanded = false,
        Flag = "FeaturedChallengeMacroCollapsible"
    })
    
    -- Add a single dropdown for Featured Challenge (The Hunt)
    local worldKey = "challenge_featured"
    local currentMapping = worldMacroMappings[worldKey] or "None"
    
    local dropdown = FeaturedChallengeCollapsible.Tab:CreateDropdown({
        Name = "Frozen Stronghold",
        Options = initialMacroOptions,
        CurrentOption = {currentMapping},
        MultipleOptions = false,
        Flag = "WorldMacro_" .. worldKey,
        Callback = function(Option)
            local selectedMacro = type(Option) == "table" and Option[1] or Option
            
            if selectedMacro == "None" or selectedMacro == "" then
                worldMacroMappings[worldKey] = nil
                print("Cleared auto-select for Featured Challenge")
            else
                worldMacroMappings[worldKey] = selectedMacro
                print("Set auto-select: Featured Challenge ->", selectedMacro)
            end
            
            saveWorldMappings()
        end,
    })
    
    worldDropdowns[worldKey] = dropdown
    
    -- Regular Challenge Collapsible (for Half Hourly challenges with different maps)
    local ChallengeCollapsible = Tab:CreateCollapsible({
        Name = "Select Challenge Macro",
        DefaultExpanded = false,
        Flag = "ChallengeMacroCollapsible"
    })
    
    -- Get all unique challenge maps from StoryStageDropdown (challenges use story maps)
    if StoryStageDropdown and StoryStageDropdown.Options then
        for _, stageName in ipairs(StoryStageDropdown.Options) do
            local worldKey = "challenge_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            
            local dropdown = ChallengeCollapsible.Tab:CreateDropdown({
                Name = stageName,
                Options = initialMacroOptions,
                CurrentOption = {currentMapping},
                MultipleOptions = false,
                Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    
                    if selectedMacro == "None" or selectedMacro == "" then
                        worldMacroMappings[worldKey] = nil
                        print("Cleared auto-select for", stageName, "(Challenge)")
                    else
                        worldMacroMappings[worldKey] = selectedMacro
                        print("Set auto-select:", stageName, "(Challenge) ->", selectedMacro)
                    end
                    
                    saveWorldMappings()
                end,
            })
            
            worldDropdowns[worldKey] = dropdown
        end
    end
    
    print("✓ Created auto-select dropdowns")
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
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("LowGraphics",true)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("DamageNumbers",false)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("VFX",false)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("EnableAnimations",false)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("EnemyInfo",false)
    else
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("LowGraphics",false)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("DamageNumbers",true)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("VFX",true)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("EnableAnimations",true)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("EnemyInfo",true)

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

 Button = LobbyTab:CreateButton({
   Name = "Return to lobby",
   Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
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
    local head = Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end

    local billboard = head:WaitForChild("BillboardGui")
    if not billboard then print("no billboard") return end
    local originalNumbers
    local streamerLabel

    if not isInLobby() then
         originalNumbers = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameUI"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("Level")
         streamerLabel = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameUI"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("streamerlabel")
    else
        originalNumbers = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("Level")
        streamerLabel = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("streamerlabel")  -- ADDED streamerLabel =
    end
    
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
    Name = "Auto Start Game",
    CurrentValue = false,
    Flag = "AutoStartGame",
    Callback = function(Value)
        State.AutoStartGame = Value
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

        AutoGameSpeedToggle = GameTab:CreateToggle({
        Name = "Auto Game Speed",
        CurrentValue = false,
        Flag = "AutoGameSpeed",
        Callback = function(Value)
            State.AutoGameSpeed = Value
        end,
    })

    local Dropdown = GameTab:CreateDropdown({
   Name = "Select Game Speed",
   Options = {"1","1.5"},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "SelectGameSpeed",
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
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Packages")
                        :WaitForChild("_Index")
                        :WaitForChild("sleitnick_knit@1.7.0")
                        :WaitForChild("knit")
                        :WaitForChild("Services")
                        :WaitForChild("WaveService")
                        :WaitForChild("RE")
                        :WaitForChild("SetSpeed")
                        :FireServer(State.SelectedGameSpeed)
            end
        end
    end
end)

 Toggle = GameTab:CreateToggle({
    Name = "Auto Skip Waves",
    CurrentValue = false,
    Flag = "AutoSkipWaves",
    Callback = function(Value)
        State.AutoSkipWaves = Value
    end,
    })

    Slider = GameTab:CreateSlider({
    Name = "Auto Skip Until Wave",
    Range = {0, 300},
    Increment = 1,
    Suffix = "wave",
    CurrentValue = 0,
    Flag = "Slider1",
    Info = "0 = disable",
    Callback = function(Value)
        State.AutoSkipUntilWave = Value
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("AutoSkip",Value)
    end,
    })

task.spawn(function()
    local lastAutoSkipState = nil
    
    while true do
        task.wait(1)
        
        if State.AutoSkipWaves then
            local waveNum = Services.Workspace:GetAttribute("Wave") or 0
            local skipLimit = State.AutoSkipUntilWave
            
            local shouldAutoSkip = false
            
            if skipLimit == 0 then
                -- 0 = always skip
                shouldAutoSkip = true
            elseif waveNum > 0 and waveNum <= skipLimit then
                -- Skip until we reach the target wave
                shouldAutoSkip = true
            end
            
            -- Only send remote if state changed
            if shouldAutoSkip ~= lastAutoSkipState then
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Packages")
                        :WaitForChild("_Index")
                        :WaitForChild("sleitnick_knit@1.7.0")
                        :WaitForChild("knit")
                        :WaitForChild("Services")
                        :WaitForChild("DataService")
                        :WaitForChild("RE")
                        :WaitForChild("SetSetting")
                        :FireServer("AutoSkip", shouldAutoSkip)
                end)
                
                lastAutoSkipState = shouldAutoSkip
                --print(string.format("Auto Skip: %s (Wave %d / Target %d)", shouldAutoSkip and "ON" or "OFF", waveNum, skipLimit))
            end
        else
            lastAutoSkipState = nil
        end
    end
end)

 Toggle = GameTab:CreateToggle({
    Name = "Auto Restart Match",
    CurrentValue = false,
    Flag = "AutoRestartMatch",
    Callback = function(Value)
        State.AutoRestartMatch = Value
    end,
    })

    Slider = GameTab:CreateSlider({
    Name = "Restart Match on Wave",
    Range = {0, 300},
    Increment = 1,
    Suffix = "wave",
    CurrentValue = 0,
    Flag = "AutoRestartMatchWave",
    Info = "0 = disable",
    Callback = function(Value)
        State.AutoRestartMatchWave = Value
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
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Packages")
                        :WaitForChild("_Index")
                        :WaitForChild("sleitnick_knit@1.7.0")
                        :WaitForChild("knit")
                        :WaitForChild("Services")
                        :WaitForChild("WaveService")
                        :WaitForChild("RE")
                        :WaitForChild("MidMatchVote")
                        :FireServer()
                end)
                
                if success then
                    hasRestarted = true
                    --print(string.format("✅ Auto Restart: Restarted match at wave %d", currentWave))
                    
                    Rayfield:Notify({
                        Title = "Auto Restart",
                        Content = string.format("Restarted at wave %d", currentWave),
                        Duration = 3
                    })
                else
                    --warn("⚠️ Failed to restart match")
                end
            end
            if currentWave == 1 then
                hasRestarted = false
            end
        end
    end
end)

 Toggle = GameTab:CreateToggle({
    Name = "Auto Sell All Units",
    CurrentValue = false,
    Flag = "AutoSellAllUnits",
    Callback = function(Value)
        State.AutoSellAllUnits = Value
    end,
    })

    Slider = GameTab:CreateSlider({
    Name = "Sell All Units on Wave",
    Range = {0, 300},
    Increment = 1,
    Suffix = "wave",
    CurrentValue = 0,
    Flag = "AutoSellAllUnitsWave",
    Info = "0 = disable",
    Callback = function(Value)
        State.AutoSellAllUnitsWave = Value
    end,
    })

    task.spawn(function()
    local hasSold = false
    
    while true do
        task.wait(1)
        
        if State.AutoSellAllUnits and State.AutoSellAllUnitsWave > 0 then
            local currentWave = Services.Workspace:GetAttribute("Wave") or 0
            local matchFinished = Services.Workspace:GetAttribute("MatchFinished")
            
            -- Trigger sell when we reach the target wave
            if currentWave >= State.AutoSellAllUnitsWave and not matchFinished and not hasSold then
                local success = pcall(function()
                    local button = Services.Players.LocalPlayer.PlayerGui.GameUI.HUD.RightFrame.Manager.Actions.SellAllButton.TextButton
                    
                    -- Fire all MouseButton1Down connections
                    for _, conn in pairs(getconnections(button.MouseButton1Down)) do
                        if conn.Enabled then
                            conn:Fire()
                        end
                    end
                end)
                
                if success then
                    hasSold = true
                    --print(string.format("Auto Sell: Sold all units at wave %d", currentWave))
                    
                    Rayfield:Notify({
                        Title = "Auto Sell",
                        Content = string.format("Sold all units at wave %d", currentWave),
                        Duration = 3
                    })
                else
                    warn("⚠️ Failed to sell all units")
                end
            end
            
            -- Reset the flag when wave goes back to 1 (new game)
            if currentWave == 1 then
                hasSold = false
            end
        end
    end
end)

local MacroDropdown = Tab:CreateDropdown({
    Name = "Select Macro",
    Options = {},
    CurrentOption = {},
    Flag = "MacroDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        currentMacroName = name
        
        if name and macroManager[name] then
            macro = macroManager[name]
            print(string.format("✓ Selected macro: %s (%d actions)", name, #macro))
            updateMacroStatus(string.format("Selected: %s", name))
        end
    end,
})

local MacroInput = Tab:CreateInput({
    Name = "Create New Macro",
    PlaceholderText = "Enter macro name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        -- Clean the name
        local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        
        if cleanedName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Macro name cannot be empty",
                Duration = 3
            })
            return
        end
        
        if macroManager[cleanedName] then
            Rayfield:Notify({
                Title = "Error",
                Content = "Macro already exists: " .. cleanedName,
                Duration = 3
            })
            return
        end
        
        -- Create empty macro
        macroManager[cleanedName] = {}
        saveMacroToFile(cleanedName, {})
        
        -- Refresh dropdown and select new macro
        MacroDropdown:Refresh(getMacroList(), cleanedName)
        
        Rayfield:Notify({
            Title = "Success",
            Content = "Created macro: " .. cleanedName,
            Duration = 3
        })
    end,
})

Tab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        loadAllMacros()
        MacroDropdown:Refresh(getMacroList())
        refreshAllWorldDropdowns()
        
        Rayfield:Notify({
            Title = "Refreshed",
            Content = "Macro list updated",
            Duration = 2
        })
    end,
})

Tab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "No macro selected",
                Duration = 3
            })
            return
        end
        
        deleteMacroFile(currentMacroName)
        
        Rayfield:Notify({
            Title = "Deleted",
            Content = currentMacroName,
            Duration = 3
        })
        
        currentMacroName = ""
        macro = {}
        
        MacroDropdown:Refresh(getMacroList())
        updateMacroStatus("Ready")
    end,
})

local function restartMatch()
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("MidMatchVote"):FireServer()
        
        --print("Restart button pressed")
        return true
    end)
    
    if not success then
        warn("⚠️ Failed to press restart button:", result)
        return false
    end
    return result
end

local RecordToggle = Tab:CreateToggle({
   Name = "Record Macro",
   CurrentValue = false,
   Flag = "RecordToggle",
   Callback = function(Value)
        if Value then
            -- Check if macro is selected
            if not currentMacroName or currentMacroName == "" then
                Rayfield:Notify({
                    Title = "Recording Error",
                    Content = "Please select a macro first!",
                    Duration = 3
                })
                RecordToggle:Set(false) -- Turn toggle back off
                return
            end
            
            local currentWave = workspace:GetAttribute("Wave") or 0
            local matchFinished = workspace:GetAttribute("MatchFinished")
            
            print(string.format("Recording enabled - Current wave: %d", currentWave))
            
            -- If we're mid-game, restart it
            if currentWave >= 1 and not matchFinished then
                print("Mid-game detected - restarting match...")
                
                -- Set recording flag BEFORE restarting
                isRecording = true
                recordingHasStarted = false -- Will start when wave 1 begins
                
                Rayfield:Notify({
                    Title = "Mid-Game Detected",
                    Content = "Restarting game for accurate recording...",
                    Duration = 4
                })
                
                -- Restart the match
                restartMatch()
                
                updateMacroStatus("Recording enabled - Restarting game...")
                updateDetailedStatus("Waiting for restart to complete...")
                
            -- If game is over, just wait for next game
            elseif matchFinished then
                isRecording = true
                recordingHasStarted = false
                
                updateMacroStatus("Recording enabled - Waiting for game to start...")
                updateDetailedStatus("Waiting for wave 1...")
                
                Rayfield:Notify({
                    Title = "Recording Ready",
                    Content = "Recording will start when game begins (Wave 1)",
                    Duration = 3
                })
                
                print("Recording enabled - waiting for next game")
                
            -- We're in lobby (wave 0) - wait for wave 1
            else
                isRecording = true
                recordingHasStarted = false
                
                updateMacroStatus("Recording enabled - Waiting for game to start...")
                updateDetailedStatus("Waiting for wave 1...")
                
                Rayfield:Notify({
                    Title = "Recording Ready",
                    Content = "Recording will start when game begins (Wave 1)",
                    Duration = 3
                })
                
                print("Recording enabled - waiting for game to start")
            end
        else
            -- Stop recording
            if recordingHasStarted then
                local actionCount = #macro
                stopRecording()
                
                Rayfield:Notify({
                    Title = "Recording Stopped",
                    Content = string.format("Saved %d actions", actionCount),
                    Duration = 3
                })
            else
                -- Recording was enabled but never started
                isRecording = false
                updateMacroStatus("Ready")
                updateDetailedStatus("Recording cancelled")
            end
            
            isRecording = false
            recordingHasStarted = false
            stopUpgradePolling()
            
            updateMacroStatus("Ready")
            updateDetailedStatus("Ready")
        end
   end,
})

local function playMacro()
    if not macro or #macro == 0 then
        updateDetailedStatus("No macro to play")
        return
    end
    
    updateDetailedStatus("Starting playback...")
    
    clearSpawnIdMappings()
    
    local totalActions = #macro
    local startTime = tick()
    
    for i, action in ipairs(macro) do
        -- CRITICAL: Check game state BEFORE every action
        local matchFinished = workspace:GetAttribute("MatchFinished")
        
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            print(string.format("⚠️ Stopping playback at action %d/%d (playback: %s, gameInProgress: %s, matchFinished: %s)", 
                i, totalActions, tostring(isPlaybackEnabled), tostring(gameInProgress), tostring(matchFinished)))
            updateDetailedStatus("Game ended - stopped playback")
            clearSpawnIdMappings()
            return
        end
        
        -- IGNORE TIMING MODE: Skip all time-based waits
        if not ignoreTiming then
            local actionTime = tonumber(action.Time)
            local currentElapsedTime = tick() - startTime
            local waitTime = actionTime - currentElapsedTime
            
            -- Show waiting countdown if we have time to wait
            if waitTime > 1 then
                local waitStart = tick()
                while (tick() - waitStart) < waitTime do
                    -- Check game state during wait
                    matchFinished = workspace:GetAttribute("MatchFinished")
                    
                    if not isPlaybackEnabled or not gameInProgress or matchFinished then
                        print("⚠️ Game ended while waiting - stopping playback")
                        updateDetailedStatus("Game ended - stopped playback")
                        clearSpawnIdMappings()
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
            end
        else
            -- In speed mode, just show we're ready for next action
            if i > 1 then
                updateDetailedStatus(string.format("(%d/%d) Ready for next action", i, totalActions))
                task.wait(0.1)
            end
        end
        
        -- Final check before executing action
        matchFinished = workspace:GetAttribute("MatchFinished")
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            print("⚠️ Game ended before action execution - stopping playback")
            updateDetailedStatus("Game ended - stopped playback")
            clearSpawnIdMappings()
            return
        end
        
        -- Execute the action
        local success = false
        
        if action.Type == "spawn_unit" then
            success = executePlacementAction(action, i, totalActions)
            
        elseif action.Type == "upgrade_unit" then
            success = executeUnitUpgrade(action, i, totalActions)
            
        elseif action.Type == "sell_unit" then
            success = executeUnitSell(action, i, totalActions)
        end
        
        task.wait(0.1)
    end
    
    updateMacroStatus("Playback Complete")
    updateDetailedStatus(string.format("Completed %d/%d actions ✓", totalActions, totalActions))
end

local function autoPlaybackLoop()
    if playbackLoopRunning then
        return
    end
    
    playbackLoopRunning = true
    
    while isPlaybackEnabled do
        while not gameInProgress and isPlaybackEnabled do
            updateMacroStatus("Waiting for game to start...")
            updateDetailedStatus("Waiting for wave 1...")
            task.wait(0.5)
        end
        
        if not isPlaybackEnabled then break end
        
        if not gameInProgress then
            task.wait(0.5)
            continue
        end

        local worldKey = getCurrentWorldKey()

        if worldKey and worldMacroMappings[worldKey] then
            local macroToLoad = worldMacroMappings[worldKey]
            
            if currentMacroName ~= macroToLoad then
                print(string.format("🔄 Auto-switching macro: %s -> %s (worldKey: %s)", 
                    currentMacroName or "None", macroToLoad, worldKey))
                
                currentMacroName = macroToLoad
                
                Rayfield:Notify({
                    Title = "Auto-Switched Macro",
                    Content = string.format("%s for %s", macroToLoad, worldKey),
                    Duration = 3
                })
                
                -- Update the main macro dropdown selection
                MacroDropdown:Set(macroToLoad)
            else
                print(string.format("ℹ️ Using mapped macro: %s (worldKey: %s)", currentMacroName, worldKey))
            end
        else
            if worldKey then
                print(string.format("⚠️ No macro mapped for worldKey: %s - using manual selection: %s", 
                    worldKey, currentMacroName or "None"))
            else
                print("⚠️ Could not determine worldKey - using manual selection")
            end
        end
        
        if not currentMacroName or currentMacroName == "" then
            updateMacroStatus("Error: No macro selected")
            updateDetailedStatus("Select a macro to continue")
            break
        end
        
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            updateMacroStatus("Error: Failed to load macro")
            updateDetailedStatus("Could not load: " .. tostring(currentMacroName))
            break
        end
        
        macro = loadedMacro
        clearSpawnIdMappings()
        
        updateMacroStatus(string.format("Executing: %s (%d actions)", currentMacroName, #macro))
        updateDetailedStatus("Starting playback...")
        
        Rayfield:Notify({
            Title = "Playback Started",
            Content = currentMacroName .. " (" .. #macro .. " actions)",
            Duration = 3
        })
        
        -- Store the thread reference
        currentPlaybackThread = coroutine.running()
        playMacro()
        currentPlaybackThread = nil
        
        -- Wait for game to end before looping
        while gameInProgress and isPlaybackEnabled do
            task.wait(0.5)
        end
        
        if not isPlaybackEnabled then break end
        
        clearSpawnIdMappings()
        updateMacroStatus("Game ended - waiting for next...")
        updateDetailedStatus("Ready for next game")
        
        task.wait(2)
    end
    
    updateMacroStatus("Playback Stopped")
    updateDetailedStatus("Ready")
    playbackLoopRunning = false
end

local PlaybackToggle = Tab:CreateToggle({
   Name = "Playback Macro",
   CurrentValue = false,
   Flag = "PlaybackToggle",
   Callback = function(Value)
        if Value then
            -- Small delay for config loading
            task.wait(0.1)
            
            -- Check if macro is selected
            if not currentMacroName or currentMacroName == "" then
                Rayfield:Notify({
                    Title = "Playback Error",
                    Content = "Please select a macro first!",
                    Duration = 3
                })
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
                return
            end
            
            if playbackLoopRunning then
                print("⚠️ Playback loop already running")
                return
            end
            
            macro = loadedMacro
            local currentWave = workspace:GetAttribute("Wave") or 0
            if currentWave >= 1 and not workspace:GetAttribute("MatchFinished") then
                Rayfield:Notify({
                    Title = "Mid-Game Detected",
                    Content = "Restarting game for accurate playback...",
                    Duration = 4
                })
                restartMatch()
                gameInProgress = false
                gameStartTime = 0
            end

            isPlaybackEnabled = true
            
            updateMacroStatus("Playback Enabled - Waiting for game...")
            Rayfield:Notify({
                Title = "Playback Enabled",
                Content = "Macro will playback: " .. currentMacroName,
                Duration = 4
            })
            
            -- Start the playback loop
            task.spawn(autoPlaybackLoop)
        else
            -- Stop playback
            isPlaybackEnabled = false
            
            -- Wait for loop to stop
            local timeout = 0
            while playbackLoopRunning and timeout < 20 do
                task.wait(0.1)
                timeout = timeout + 1
            end
            
            if playbackLoopRunning then
                warn("⚠️ Force stopping playback loop")
                playbackLoopRunning = false
            end
            
            updateMacroStatus("Playback Disabled")
            Rayfield:Notify({
                Title = "Playback Disabled",
                Content = "Stopped playback loop",
                Duration = 3
            })
        end
   end,
})

Tab:CreateToggle({
   Name = "Ignore Timing",
   CurrentValue = false,
   Flag = "IgnoreTimingToggle",
   Callback = function(Value)
        ignoreTiming = Value
   end,
})

Div = Tab:CreateDivider()

Tab:CreateButton({
    Name = "Export Macro (Copy JSON)",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "No macro selected",
                Duration = 3
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Error",
                Content = "Macro is empty",
                Duration = 3
            })
            return
        end
        
        local json = game:GetService("HttpService"):JSONEncode(macroData)
        
        if setclipboard then
            setclipboard(json)
            Rayfield:Notify({
                Title = "Exported",
                Content = string.format("Copied %s (%d actions)", currentMacroName, #macroData),
                Duration = 3
            })
        else
            print(json)
            Rayfield:Notify({
                Title = "Exported",
                Content = "JSON printed to console",
                Duration = 3
            })
        end
    end,
})

local ImportInput = Tab:CreateInput({
    Name = "Import Macro (Paste JSON)",
    PlaceholderText = "Paste JSON here...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then
            return
        end
        
        local success, importData = pcall(function()
            return game:GetService("HttpService"):JSONDecode(text)
        end)
        
        if not success then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Invalid JSON format",
                Duration = 3
            })
            return
        end
        
        if type(importData) ~= "table" or #importData == 0 then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "No actions found in JSON",
                Duration = 3
            })
            return
        end
        
        -- Create name for imported macro
        local macroName = "Imported_" .. os.time()
        
        macroManager[macroName] = importData
        saveMacroToFile(macroName, importData)
        
        MacroDropdown:Refresh(getMacroList(), macroName)
        
        Rayfield:Notify({
            Title = "Import Success",
            Content = string.format("%s (%d actions)", macroName, #importData),
            Duration = 4
        })
    end,
})

Tab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "No macro selected",
                Duration = 3
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Error",
                Content = "Macro is empty",
                Duration = 3
            })
            return
        end
        
        -- Count units
        local unitCounts = {}
        
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                unitCounts[unitName] = (unitCounts[unitName] or 0) + 1
            end
        end
        
        if next(unitCounts) == nil then
            Rayfield:Notify({
                Title = "No Units",
                Content = "No placements found in macro",
                Duration = 3
            })
            return
        end
        
        -- Build display text
        local unitList = {}
        for unitName in pairs(unitCounts) do
            table.insert(unitList, string.format("%s", unitName))
        end
        table.sort(unitList)
        
        local displayText = table.concat(unitList, ", ")
        
        print(string.format("Macro: %s", currentMacroName))
        print(string.format("Total actions: %d", #macroData))
        for _, line in ipairs(unitList) do
            print("  " .. line)
        end
        
        Rayfield:Notify({
            Title = "Macro Units",
            Content = displayText,
            Duration = 5
        })
    end,
})

Div2 = Tab:CreateDivider()

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

    WebhookToggle = WebhookTab:CreateToggle({
        Name = "Send On Match Restarted",
        CurrentValue = false,
        Flag = "SendWebhookOnMatchRestarted",
        Callback = function(Value)
            State.SendMatchRestartedWebhook = Value
        end,
    })

     TestWebhookButton = WebhookTab:CreateButton({
        Name = "Test webhook",
        Callback = function()
            if ValidWebhook then
                sendWebhook("test")
            else
                notify(nil,"Error: No webhook URL set!")
            end
        end,
    })

workspace:GetAttributeChangedSignal("Wave"):Connect(function()
    local wave = workspace:GetAttribute("Wave") or 0
    
    --print(string.format("Wave changed: %d (lastWave: %d, gameInProgress: %s)", wave, lastWave, tostring(gameInProgress)))
    
    -- Detect restart (wave goes back to 0 or lower)
    if wave < lastWave then
        --print("Wave reset detected")

         if State.SendMatchRestartedWebhook and not hasRecentlyRestarted then
            sendWebhook("match_restart", nil, currentGameInfo, lastWave)
        end

        hasRecentlyRestarted = true

        if gameInProgress then
            print("Resetting game state due to restart")
            gameInProgress = false
            gameStartTime = 0
        end
        
        -- Handle recording restart
        if isRecording and recordingHasStarted then
    local actionCount = #macro
    stopRecording()
    
    Rayfield:Notify({
        Title = "Recording Stopped",
        Content = string.format("Game restarted - saved %d actions", actionCount),
        Duration = 3
    })
    
    print("Recording stopped and saved due to restart")
end

        if isRecording then
    recordingHasStarted = false
    macro = {}
    clearSpawnIdMappings()
    
    updateMacroStatus("Recording enabled - Waiting for wave 1...")
    updateDetailedStatus("Waiting for wave 1 to restart recording...")
end
        
        -- Handle playback restart
        if isPlaybackEnabled and playbackLoopRunning then
            gameInProgress = false
            gameStartTime = 0
            clearSpawnIdMappings()
            updateMacroStatus("Game restarted - waiting for wave 1...")
            updateDetailedStatus("Waiting for wave 1...")
            print("Playback stopped due to restart - waiting for next game")
        end
        
        lastWave = 0

        task.spawn(function()
            task.wait(2)
            hasRecentlyRestarted = false
        end)
        return
    end
    
    lastWave = wave
    
    -- Game just started (wave 1+)
    if wave >= 1 and not gameInProgress then
    gameInProgress = true
    gameStartTime = tick()

    currentGameInfo = {
        MapName = workspace:GetAttribute("MapName") or "Unknown",
        Act = workspace:GetAttribute("ActName") or "Unknown",
        Category = workspace:GetAttribute("DifficultyName") or "Unknown",
        StartTime = tick()
    }
    
    -- Wait for RequestData to initialize before capturing rewards
    task.spawn(function()
        local timeout = 0
        while not RequestData and timeout < 20 do
            task.wait(0.5)
            timeout = timeout + 1
        end
        
        if RequestData then
            beforeRewardData = deepCopy(RequestData:InvokeServer())
            --print("✅ Took BEFORE reward snapshot")
        else
            warn("⚠️ RequestData not initialized - rewards won't be tracked")
        end
    end)
        
        print(string.format("✓ GAME STARTED (Wave %d) - %s Act %s (%s)", 
        wave, currentGameInfo.MapName, currentGameInfo.Act, currentGameInfo.Category))
        
        -- Auto-start recording if enabled
        if isRecording and not recordingHasStarted then
            print("Starting recording now")
            recordingHasStarted = true
            gameStartTime = tick()
            
            -- Reset tracking
            recordingUnitCounter = {}
            recordingUUIDToTag = {}
            macro = {}
            
            startUpgradePolling()
            
            updateMacroStatus("Recording...")
            updateDetailedStatus("Recording in progress - " .. currentMacroName)
            
            print("Recording started - " .. currentMacroName)
            
            Rayfield:Notify({
                Title = "Recording Started",
                Content = string.format("Wave %d detected - recording: %s", wave, currentMacroName),
                Duration = 3
            })
        end
        
        -- Auto-start playback if enabled
        if isPlaybackEnabled and not playbackLoopRunning then
            print("Starting macro playback...")
            updateMacroStatus("Starting playback...")
            updateDetailedStatus("Starting playback...")
        end
    end
end)

workspace:GetAttributeChangedSignal("MatchFinished"):Connect(function()
    local matchFinished = workspace:GetAttribute("MatchFinished")
    
    if matchFinished and gameInProgress then
        print("Game ended")

        afterRewardData = deepCopy(RequestData:InvokeServer())
        --print("✅ Took AFTER reward snapshot")

        if State.SendStageCompletedWebhook then
        -- Determine victory or loss based on health
        local currentHealth = workspace:GetAttribute("Health") or 0
        local gameResult = currentHealth > 0
        
        -- Calculate game duration
        local gameDuration = "Unknown"
        if currentGameInfo.StartTime then
            local duration = tick() - currentGameInfo.StartTime
            local minutes = math.floor(duration / 60)
            local seconds = math.floor(duration % 60)
            gameDuration = string.format("%dm %ds", minutes, seconds)
        end
        
        sendWebhook("game_end", gameResult, currentGameInfo, gameDuration)
    end
        
        gameInProgress = false
        gameStartTime = 0
        lastWave = 0

        if isPlaybackEnabled then
            -- This will break the playMacro() loop immediately
            local wasPlaying = playbackLoopRunning
            
            -- Clear all playback state
            clearSpawnIdMappings()
            
            if wasPlaying then
                print("Game ended mid-playback - resetting for next game")
            end
        end
        
        -- Auto-stop recording
        if isRecording and recordingHasStarted then
            local actionCount = #macro
            stopRecording()
            
            Rayfield:Notify({
                Title = "Recording Auto-Stopped",
                Content = string.format("Saved %d actions to %s", actionCount, currentMacroName),
                Duration = 4
            })

            RecordToggle:Set(false)
            print(string.format("Recording stopped - saved %d actions", actionCount))
            
            -- Reset for next recording
            recordingHasStarted = false
            updateMacroStatus("Recording enabled - Waiting for game to start...")
            updateDetailedStatus("Waiting for next game...")
        end
        
        -- Playback will automatically loop via autoPlaybackLoop
        if isPlaybackEnabled then
            clearSpawnIdMappings()
            updateMacroStatus("Game ended - waiting for next game...")
            updateDetailedStatus("Waiting for next game start")
            print("Game ended - ready for next playback loop")
        end
        
        -- If neither recording nor playback, just update status
        if not isRecording and not isPlaybackEnabled then
            updateMacroStatus("Ready")
            updateDetailedStatus("Ready")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        
        -- Only run if we're in lobby and auto-start is enabled
        if State.AutoStartGame and not isInLobby() then
            -- Check if we're NOT in a game (Wave should be 0 or nil)
            local currentWave = workspace:GetAttribute("Wave") or 0
            local matchFinished = workspace:GetAttribute("MatchFinished")
            
            if currentWave == 0 and not matchFinished then
                print("Auto Start Game enabled - Voting to start...")

                task.wait(2)
                
                local success = pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Packages")
                        :WaitForChild("_Index")
                        :WaitForChild("sleitnick_knit@1.7.0")
                        :WaitForChild("knit")
                        :WaitForChild("Services")
                        :WaitForChild("WaveService")
                        :WaitForChild("RF")
                        :WaitForChild("Vote")
                        :InvokeServer(true)
                end)
                
                if success then
                    Rayfield:Notify({
                        Title = "Auto Start",
                        Content = "Voting to start game...",
                        Duration = 2
                    })
                    print("Voted to start game")
                    
                    -- Wait a bit before trying again (avoid spam)
                    task.wait(5)
                end
            end
        end
    end
end)

task.spawn(function()
        while true do
        task.wait(0.5)
        checkAndExecuteHighestPriority()
    end
end)

task.spawn(function()
    local timeout = 0
    while not isGameDataLoaded() and timeout < 20 do
        task.wait(0.5)
        timeout = timeout + 1
    end
    
    if isGameDataLoaded() then
        buildMapLookup()
    else
        warn("Game data not loaded - map filtering may not work")
    end
end)

task.spawn(function()
    local lastCheckMinute = -1
    
    while true do
        task.wait(5) -- Check every 5 seconds
        
        if State.ReturnToLobbyOnNewChallenge then
            local currentTime = os.date("*t")
            local currentMinute = currentTime.min
            
            -- Check if we just hit XX:00 or XX:30
            if (currentMinute == 0 or currentMinute == 30) and currentMinute ~= lastCheckMinute then
                lastCheckMinute = currentMinute
                
                if Services.Workspace:GetAttribute("MatchFinished") then        
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
                end

                --print(string.format("🔔 New challenges spawned at %02d:%02d", currentTime.hour, currentMinute))
                
                -- Set the flag
                State.NewChallengesAvailable = true
                
                Rayfield:Notify({
                    Title = "New Challenges Available",
                    Content = "Will return to lobby when game ends",
                    Duration = 4
                })
            end
            
            -- Reset lastCheckMinute after minute 1 or 31
            if currentMinute > 1 and currentMinute < 30 then
                lastCheckMinute = -1
            elseif currentMinute > 31 then
                lastCheckMinute = -1
            end
        else
            -- Reset when feature is disabled
            lastCheckMinute = -1
            State.NewChallengesAvailable = false
        end
    end
end)

task.spawn(function()
    while true do
        -- Wait for MatchFinished to become true
        while not workspace:GetAttribute("MatchFinished") do
            task.wait(0.5)
        end
        
        print("Match finished detected")
        task.wait(1) -- Small delay before voting

        -- Priority 1: New challenges available
        if State.NewChallengesAvailable and State.ReturnToLobbyOnNewChallenge then
            print("New challenges available - Returning to Lobby...")
            
            local success = pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_knit@1.7.0")
                    :WaitForChild("knit")
                    :WaitForChild("Services")
                    :WaitForChild("WaveService")
                    :WaitForChild("RE")
                    :WaitForChild("ToLobby")
                    :FireServer()
            end)
            
            if success then
                Rayfield:Notify({
                    Title = "Returned to Lobby",
                    Content = "Ready to join new challenges",
                    Duration = 3
                })
                print("✓ Returned to lobby for new challenges")
                State.NewChallengesAvailable = false
            end
        
        else
            -- Try enabled features in order: Retry -> Next -> Lobby
            local actionTaken = false
            
            -- Build list of enabled actions
            local actions = {}
            if State.AutoRetry then table.insert(actions, "retry") end
            if State.AutoNext then table.insert(actions, "next") end
            if State.AutoLobby then table.insert(actions, "lobby") end
            
            if #actions == 0 then
                print("No auto actions enabled")
            else
                -- Try each action in order
                for _, action in ipairs(actions) do
                    local success = false
                    
                    if action == "retry" then
                        print("Trying Auto Retry...")
                        success = pcall(function()
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Packages")
                                :WaitForChild("_Index")
                                :WaitForChild("sleitnick_knit@1.7.0")
                                :WaitForChild("knit")
                                :WaitForChild("Services")
                                :WaitForChild("WaveService")
                                :WaitForChild("RE")
                                :WaitForChild("VoteReplay")
                                :FireServer()
                        end)
                        
                        if success then
    Rayfield:Notify({
        Title = "Auto Retry",
        Content = "Voting for Replay...",
        Duration = 2
    })
    print("✓ Voted for Replay")
    
    -- Wait to see if MatchFinished becomes false (game restarted)
    local waited = 0
    while waited < 15 and workspace:GetAttribute("MatchFinished") do
        task.wait(1)
        waited = waited + 1
    end
    
    if not workspace:GetAttribute("MatchFinished") then
        print("✓ Retry worked - game restarted")
        actionTaken = true
        break
    else
        warn("⚠️ Retry vote didn't start game - trying next action")
    end
end
                        
                    if success then
    Rayfield:Notify({
        Title = "Auto Next",
        Content = "Voting for Next Stage...",
        Duration = 2
    })
    print("✓ Voted for Next")
    
    -- Wait to see if MatchFinished becomes false (game restarted)
    local waited = 0
    while waited < 15 and workspace:GetAttribute("MatchFinished") do
        task.wait(1)
        waited = waited + 1
    end
    
    if not workspace:GetAttribute("MatchFinished") then
        print("✓ Next worked - game restarted")
        actionTaken = true
        break
    else
        warn("⚠️ Next vote didn't start game - trying next action")
    end
end
                        
                    elseif action == "lobby" then
                        print("Trying Auto Lobby...")
                        success = pcall(function()
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Packages")
                                :WaitForChild("_Index")
                                :WaitForChild("sleitnick_knit@1.7.0")
                                :WaitForChild("knit")
                                :WaitForChild("Services")
                                :WaitForChild("WaveService")
                                :WaitForChild("RE")
                                :WaitForChild("ToLobby")
                                :FireServer()
                        end)
                        
                        if success then
                            Rayfield:Notify({
                                Title = "Auto Lobby",
                                Content = "Returning to Lobby...",
                                Duration = 2
                            })
                            print("✓ Returned to Lobby")
                            actionTaken = true
                            break
                        end
                    end
                end
                
                if not actionTaken then
                    warn("⚠️ All enabled actions failed")
                end
            end
        end
        
        -- Wait for MatchFinished to become false before checking again
        while workspace:GetAttribute("MatchFinished") do
            task.wait(0.5)
        end
    end
end)

ensureMacroFolders()
loadAllMacros()
worldMacroMappings = loadWorldMappings()
MacroDropdown:Refresh(getMacroList())

task.spawn(loadAllStoryStagesWithRetry)
task.spawn(loadAllLegendStagesWithRetry)
task.spawn(loadAllVirtualStagesWithRetry)
task.spawn(loadAllChallengeModifiersWithRetry)

task.spawn(function()
    task.wait(2)
    createAutoSelectDropdowns()
end)

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

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
    end)
