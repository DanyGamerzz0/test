if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 133410800847665 and game.PlaceId ~= 106402284955512 and game.PlaceId ~= 100391355714091 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.01"

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
local AutoPathTab = Window:CreateTab("Auto Path", "target")
local Tab = Window:CreateTab("Macro", "tv")
local GameTab = Window:CreateTab("Game", "gamepad-2")
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
}

local function isInLobby()
    return Services.Workspace:GetAttribute("IsLobby") or false
end


local TowerService = nil
local BlessingService = nil

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
        
        print("TowerService initialized")
        print("BlessingService initialized")
    end)
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
    
    print(string.format("Started tracking: %s (UUID=%s)", unitTag, uuid))
    
    -- Find unit data in garbage collection
    local unitData = findUnitDataInGC(uuid)
    
    if unitData then
        -- Store the unit data reference
        unitChangeListeners[uuid] = {
            data = unitData,
            unitTag = unitTag,
            lastUpgradeLevel = unitData.Upgrade or 1
        }
        
        print(string.format("Tracking %s - Current upgrade level: %d", 
            unitTag, unitData.Upgrade or 1))
    else
        --warn(string.format("⚠️ Could not find GC data for %s", unitTag))
        unitChangeListeners[uuid] = { unitTag = unitTag }
    end
end

local function stopTrackingUnitChanges(uuid)
    if unitChangeListeners[uuid] then
        unitChangeListeners[uuid] = nil
        print(string.format("Stopped tracking UUID: %s", uuid))
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
                        print(string.format("UPGRADE DETECTED: %s went from level %d -> %d", 
                            listener.unitTag, lastLevel, currentLevel))
                        
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
        task.wait(1)
        
        currentMoney = getPlayerMoney()
        if not currentMoney then
            return true
        end
        
        if currentMoney >= requiredAmount then
            return true
        end
        
        -- Update status every 3 seconds
        if tick() - lastUpdateTime >= 3 then
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
        waitForMoney(placementCost, unitName)
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
        waitForMoney(upgradeCost, string.format("%s upgrade", action.Unit))
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
    print("✓ Saved path priorities")
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
    
    local success = pcall(function()
        local cardsFolder = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Paths.PathSelection.Cards
        
        -- First, collect all Frame children and sort them by position or layout order
        local frameChildren = {}
        for _, child in ipairs(cardsFolder:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("^Card") then -- Only get objects named "Card..."
                table.insert(frameChildren, child)
            end
        end
        
        -- Sort by LayoutOrder or AbsolutePosition.X (depending on how the UI is arranged)
        table.sort(frameChildren, function(a, b)
            -- Try LayoutOrder first
            if a.LayoutOrder ~= b.LayoutOrder then
                return a.LayoutOrder < b.LayoutOrder
            end
            -- Fallback to position
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)
        
        -- Now assign correct indices (1, 2, 3...)
        for cardIndex, cardFrame in ipairs(frameChildren) do
            local titleLabel = cardFrame:FindFirstChild("Title")
            local topTitleLabel = cardFrame:FindFirstChild("TopTitle")
            
            if titleLabel and topTitleLabel then
                local blessingName = titleLabel.Text
                local pathName = topTitleLabel:FindFirstChild("Text") and topTitleLabel.Text.Text or "Unknown"
                
                -- Build the key to match our saved priorities
                local sliderKey = string.format("[%s] %s", pathName, blessingName)
                
                -- Get priority (default to 0 if not set)
                local priority = PathState.BlessingPriorities[sliderKey] or 0
                
                table.insert(cards, {
                    index = cardIndex, -- Use our calculated index instead of the loop variable
                    blessingName = blessingName,
                    pathName = pathName,
                    sliderKey = sliderKey,
                    priority = priority
                })
                
                print(string.format("Card %d: %s (Priority: %d)", cardIndex, sliderKey, priority))
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
        print("All cards have 0 priority - selecting first card by default")
    else
        print(string.format("selecting card: %s with priority %d", bestCard.sliderKey, bestCard.priority))
    end
    
    -- Fire the remote with the card index
    local success = pcall(function()
        BlessingService:WaitForChild("GetNewPath"):FireServer(bestCard.index)
    end)
    
    if success then
        print(string.format("✓ Selected card %d: %s", bestCard.index, bestCard.blessingName))
        
        Rayfield:Notify({
            Title = "Auto Path",
            Content = string.format("Selected: %s", bestCard.blessingName),
            Duration = 3
        })
        
        return true
    else
        warn("Failed to select card")
        return false
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        
        if State.AutoSelectPath then
            local pathsUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("GameUI")
            
            if pathsUI then
                pathsUI = pathsUI:FindFirstChild("Paths")
                
                if pathsUI and pathsUI.Enabled then
                    -- Path selection is visible
                    print("Path selection screen detected")
                    
                    -- Wait a moment for cards to fully load
                    task.wait(0.5)
                    
                    -- Select the best card
                    selectBestCard()
                    
                    -- Wait for screen to close
                    while pathsUI.Enabled do
                        task.wait(0.5)
                    end
                    
                    print("Path selection completed")
                end
            end
        end
    end
end)

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
    Name = "Reset priority to default",
    Callback = function()
        for _, slider in ipairs(pathSliders) do
            slider:Set(0)
        end
        -- Clear the stored priorities
        PathState.BlessingPriorities = {}
        savePathPriorities() -- Save the reset
    end,
})

Label = AutoPathTab:CreateLabel("tip: use the search icon")

AutoPathTab:CreateDivider()

local function loadPathSliders()
    local PathsFolder = game:GetService("ReplicatedStorage").Shared.Data.Paths
    
    -- Load saved priorities first
    local savedPriorities = loadPathPriorities()
    
    -- Store paths and their blessings
    local pathsData = {}
    
    for _, pathModule in ipairs(PathsFolder:GetChildren()) do
        if pathModule:IsA("ModuleScript") then
            local success, pathData = pcall(function()
                return require(pathModule)
            end)
            
            if success and pathData.Blessings then
                local pathName = pathModule.Name
                pathsData[pathName] = {}
                
                -- Collect all blessings from all rarities
                for rarity, blessings in pairs(pathData.Blessings) do
                    for blessingName, blessingData in pairs(blessings) do
                        table.insert(pathsData[pathName], {
                            name = blessingName,
                            rarity = rarity
                        })
                    end
                end
                
                -- Sort blessings alphabetically
                table.sort(pathsData[pathName], function(a, b)
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
    
    -- Create sections and sliders for each path
    for _, pathName in ipairs(sortedPaths) do
        local blessings = pathsData[pathName]
        
        -- Create slider for each blessing
        for _, blessing in ipairs(blessings) do
            local sliderKey = string.format("[%s] %s", pathName, blessing.name)
            
            -- Get saved value or default to 0
            local savedValue = savedPriorities[sliderKey] or 0
            
            local slider = AutoPathTab:CreateSlider({
                Name = sliderKey,
                Range = {0, 999},
                Increment = 1,
                CurrentValue = savedValue,
                Flag = "PathPriority_" .. pathName .. "_" .. blessing.name:gsub("%s", ""),
                Callback = function(Value)
                    PathState.BlessingPriorities[sliderKey] = Value
                    savePathPriorities() -- Auto-save on change
                    print(string.format("Set priority for %s: %d", sliderKey, Value))
                end,
            })
            
            -- Initialize PathState with saved value
            PathState.BlessingPriorities[sliderKey] = savedValue
            
            -- Store slider reference
            table.insert(pathSliders, slider)
        end
        
        -- Add divider between paths
        AutoPathTab:CreateDivider()
    end
    
    print("✓ Loaded path sliders successfully")
end

task.spawn(function()
    task.wait(2)
    
    local success, err = pcall(loadPathSliders)
    if not success then
        warn("Failed to load path sliders:", err)
        AutoPathTab:CreateLabel("⚠️ Failed to load paths")
    end
end)

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
        
        print("Restart button pressed")
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
                return
            end
            
            isRecording = true
            
            local currentWave = workspace:GetAttribute("Wave") or 0
            
            print(string.format("Recording enabled - Current wave: %d", currentWave))
            
            -- If we're mid-game, start recording immediately
            if currentWave >= 1 and not workspace:GetAttribute("MatchFinished") then
                Rayfield:Notify({
                    Title = "Mid-Game Detected",
                    Content = "Restarting game for accurate recording...",
                    Duration = 4
                })
                restartMatch()
                -- Reset state
                recordingHasStarted = false
                updateMacroStatus("Recording enabled - Restarting game...")
            elseif currentWave >= 1 then
                
                gameInProgress = true
                gameStartTime = tick()
                recordingHasStarted = true
                
                -- Reset tracking
                recordingUnitCounter = {}
                recordingUUIDToTag = {}
                macro = {}
                
                startUpgradePolling()
                
                updateMacroStatus("Recording... (Started mid-game)")
                updateDetailedStatus(string.format("Recording in progress - %s (Wave %d)", currentMacroName, currentWave))
                
                Rayfield:Notify({
                    Title = "Recording Started!",
                    Content = string.format("Mid-game recording: %s (Wave %d)", currentMacroName, currentWave),
                    Duration = 4
                })
            else
                -- We're in lobby - wait for wave 1
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
        if not isPlaybackEnabled then
            updateDetailedStatus("Playback cancelled")
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
                    if not isPlaybackEnabled then
                        updateDetailedStatus("Playback cancelled")
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
            if i > 1 then -- Don't show for first action
                updateDetailedStatus(string.format("(%d/%d) Ready for next action", i, totalActions))
                task.wait(0.1) -- Tiny delay to prevent spam
            end
        end
        
        if not isPlaybackEnabled then
            updateDetailedStatus("Playback cancelled")
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
        
        playMacro()
        
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
                Content = "Stopped infinite playback loop",
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
            print("=== MACRO JSON ===")
            print(json)
            print("=== END ===")
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
        
        print("=== MACRO UNITS ===")
        print(string.format("Macro: %s", currentMacroName))
        print(string.format("Total actions: %d", #macroData))
        for _, line in ipairs(unitList) do
            print("  " .. line)
        end
        print("=== END ===")
        
        Rayfield:Notify({
            Title = "Macro Units",
            Content = displayText,
            Duration = 5
        })
    end,
})

workspace:GetAttributeChangedSignal("Wave"):Connect(function()
    local wave = workspace:GetAttribute("Wave") or 0
    
    print(string.format("Wave changed: %d (lastWave: %d, gameInProgress: %s)", wave, lastWave, tostring(gameInProgress)))
    
    -- Detect restart (wave goes back to 0 or lower)
    if wave < lastWave and gameInProgress then
        print("Wave reset detected")
        
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
            recordingHasStarted = false
            
            updateMacroStatus("Recording enabled - Waiting for game to start...")
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
        return
    end
    
    lastWave = wave
    
    -- Game just started (wave 1+)
    if wave >= 1 and not gameInProgress then
        gameInProgress = true
        gameStartTime = tick()
        
        print(string.format("✓ GAME STARTED (Wave %d)", wave))
        
        -- Auto-start recording if enabled
        if isRecording and not recordingHasStarted then
            recordingHasStarted = true
            
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
        
        gameInProgress = false
        gameStartTime = 0
        lastWave = 0
        
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
        -- Wait for MatchFinished to become true
        while not workspace:GetAttribute("MatchFinished") do
            task.wait(0.5)
        end
        
        print("Match finished detected")
        task.wait(1) -- Small delay before voting
        
        if State.AutoRetry then
            print("Auto Retry enabled - Voting Replay...")
            local success = pcall(function()
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
                print("Voted for Replay stage")
            end
            
        elseif State.AutoNext then
            print("Auto Next enabled - Voting Next Map...")
            local success = pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_knit@1.7.0")
                    :WaitForChild("knit")
                    :WaitForChild("Services")
                    :WaitForChild("WaveService")
                    :WaitForChild("RE")
                    :WaitForChild("NextMap")
                    :FireServer()
            end)
            
            if success then
                Rayfield:Notify({
                    Title = "Auto Next",
                    Content = "Voting for Next Stage...",
                    Duration = 2
                })
                print("Voted for next stage")
            end
            
        elseif State.AutoLobby then
            print("Auto Lobby enabled - Returning to Lobby...")
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
                    Title = "Auto Lobby",
                    Content = "Returning to Lobby...",
                    Duration = 2
                })
                print("Returning to Lobby")
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
    end)
