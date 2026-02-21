--[[
    LixHub - Anime Paradox
    Full Rewrite - Clean Modular Architecture
    
    Design principles:
    - All logic lives in module tables, not locals → no 200 local limit
    - Single __namecall hook
    - Event-driven where possible, minimal polling
    - Centralized State table
    - Reliable unit tracking
    - PC executor compatible
--]]

-- ============================================================
-- EXECUTOR CHECK
-- ============================================================
if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller
    and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED")
    return
end

if game.PlaceId ~= 76806550943352 and game.PlaceId ~= 85661754644506 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

-- ============================================================
-- CORE SETUP
-- ============================================================
local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua"
))()

local SCRIPT_VERSION = "V0.03"

local Window = Rayfield:CreateWindow({
    Name             = "LixHub - Anime Paradox",
    Icon             = 0,
    LoadingTitle     = "Loading for Anime Paradox",
    LoadingSubtitle  = SCRIPT_VERSION,
    ShowText         = "LixHub",
    Theme = {
        TextColor                    = Color3.fromRGB(240, 240, 240),
        Background                   = Color3.fromRGB(25, 25, 25),
        Topbar                       = Color3.fromRGB(34, 34, 34),
        Shadow                       = Color3.fromRGB(20, 20, 20),
        NotificationBackground       = Color3.fromRGB(20, 20, 20),
        NotificationActionsBackground= Color3.fromRGB(230, 230, 230),
        TabBackground                = Color3.fromRGB(80, 80, 80),
        TabStroke                    = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected        = Color3.fromRGB(210, 210, 210),
        TabTextColor                 = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor         = Color3.fromRGB(50, 50, 50),
        ElementBackground            = Color3.fromRGB(35, 35, 35),
        ElementBackgroundHover       = Color3.fromRGB(40, 40, 40),
        SecondaryElementBackground   = Color3.fromRGB(25, 25, 25),
        ElementStroke                = Color3.fromRGB(50, 50, 50),
        SecondaryElementStroke       = Color3.fromRGB(40, 40, 40),
        SliderBackground             = Color3.fromRGB(50, 138, 220),
        SliderProgress               = Color3.fromRGB(50, 138, 220),
        SliderStroke                 = Color3.fromRGB(58, 163, 255),
        ToggleBackground             = Color3.fromRGB(30, 30, 30),
        ToggleEnabled                = Color3.fromRGB(0, 146, 214),
        ToggleDisabled               = Color3.fromRGB(100, 100, 100),
        ToggleEnabledStroke          = Color3.fromRGB(0, 170, 255),
        ToggleDisabledStroke         = Color3.fromRGB(125, 125, 125),
        ToggleEnabledOuterStroke     = Color3.fromRGB(100, 100, 100),
        ToggleDisabledOuterStroke    = Color3.fromRGB(65, 65, 65),
        DropdownSelected             = Color3.fromRGB(102, 102, 102),
        DropdownUnselected           = Color3.fromRGB(30, 30, 30),
        InputBackground              = Color3.fromRGB(30, 30, 30),
        InputStroke                  = Color3.fromRGB(65, 65, 65),
        PlaceholderColor             = Color3.fromRGB(178, 178, 178),
    },
    ToggleUIKeybind       = "K",
    DisableRayfieldPrompts= true,
    DisableBuildWarnings  = true,
    ConfigurationSaving   = {
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
        Title          = "LixHub - Anime Paradox - Free",
        Subtitle       = "LixHub - Key System",
        Note           = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
        FileName       = "LixHub_Key",
        SaveKey        = true,
        GrabKeyFromSite= false,
        Key            = {"0xLIXHUB"},
    },
})

-- ============================================================
-- SERVICES
-- ============================================================
local Svc = {
    Players          = game:GetService("Players"),
    ReplicatedStorage= game:GetService("ReplicatedStorage"),
    Workspace        = game:GetService("Workspace"),
    TeleportService  = game:GetService("TeleportService"),
    RunService       = game:GetService("RunService"),
    HttpService      = game:GetService("HttpService"),
    VirtualUser      = game:GetService("VirtualUser"),
}
local LP  = Svc.Players.LocalPlayer
local RS  = Svc.ReplicatedStorage

-- ============================================================
-- DEBUG MODE
-- ============================================================
local DEBUG = true  -- Set to true for testing

local function debugPrint(...)
    if DEBUG then
        print("[DEBUG]", ...)
    end
end

-- ============================================================
-- CENTRALIZED STATE
-- ============================================================
local State = {
    -- System
    DisableNotifications = false,
    AntiAfkEnabled      = false,
    enableAutoExecute   = false,
    
    -- Joiner
    AutoJoinStory       = false,
    StoryStage          = nil,
    StoryAct            = nil,
    StoryDifficulty     = nil,
    
    AutoJoinLegend      = false,
    LegendStage         = nil,
    LegendAct           = nil,
    
    AutoJoinRaid        = false,
    RaidStage           = nil,
    RaidAct             = nil,
    
    AutoJoinSiege       = false,
    SiegeStage          = nil,
    SiegeAct            = nil,
    
    AutoJoinPortal      = false,
    PortalStage         = nil,
    AutoNextPortal      = false,
    
    AutoJoinChallenge   = false,
    ChallengeTypes      = {},
    ChallengeRewards    = {},
    IgnoreWorlds        = {},
    IgnoreModifiers     = {},
    ReturnToLobbyOnNew  = false,
    
    -- Game
    AutoStartGame       = false,
    AutoNext            = false,
    AutoRetry           = false,
    AutoLobby           = false,
    AutoSkipWaves       = false,
    
    -- Webhook
    WebhookURL          = nil,
    DiscordUserID       = nil,
    SendOnFinish        = false,
    
    -- Macro
    IgnoreTiming        = false,
    
    -- Internal tracking
    gameInProgress      = false,
    gameStartTime       = 0,
    lastChallengeCheck  = 0,
    newChallengeDetected= false,

    AutoJoinDelay = 0,
    AutoJoinDelayStart = nil,

    AutoGoldShop = false,
    GoldShopItems = {},
}

local Challenge = {
    modules = nil,
}

local Webhook = {}

local AutoSelectDropdowns = {}

local autoSelectUICreated = false

local PORTAL_MAP_NAMES = {
    ["Shibuya_Station"] = "JJK_Portal",
    -- add more here as needed
}

local PORTAL_DISPLAY_NAMES = {
    { key = "Portal_JJK_Portal", label = "JJK Portal" },
    -- add more here
}

local GoldShop = {}

local GOLD_SHOP_ITEMS = {
    { id = "StatChip",       name = "Stat Chip",      cost = 1000,  maxStock = 10 },
    { id = "SuperStatChip",  name = "Super Stat Chip", cost = 2500,  maxStock = 10 },
    { id = "TraitRerolls",   name = "Trait Rerolls",   cost = 7500,  maxStock = 3  },
    { id = "GreenEssence",   name = "Green Essence",   cost = 1000,  maxStock = 15 },
    { id = "RedEssence",     name = "Red Essence",     cost = 2500,  maxStock = 3  },
    { id = "YellowEssence",  name = "Yellow Essence",  cost = 2500,  maxStock = 3  },
    { id = "BlueEssence",    name = "Blue Essence",    cost = 2500,  maxStock = 3  },
    { id = "PurpleEssence",  name = "Purple Essence",  cost = 2500,  maxStock = 3  },
    { id = "PinkEssence",    name = "Pink Essence",    cost = 2500,  maxStock = 3  },
    { id = "RainbowEssence", name = "Rainbow Essence", cost = 15000, maxStock = 1  },
}

-- ============================================================
-- UTILITY HELPERS
-- ============================================================
local Util = {}

function Util.notify(title, body, dur)
    if State.DisableNotifications then return end
    Rayfield:Notify({
        Title = title or "LixHub",
        Content = body or "",
        Duration = dur or 4,
        Image = "info"
    })
end

function Util.isInLobby()
    return Svc.Workspace:FindFirstChild("Lobby") ~= nil
end

function Util.getWave()
    local success, wave = pcall(function()
        return RS.GameConfig.Wave.Value
    end)
    return success and wave or 0
end

function Util.getMoney()
    return LP:GetAttribute("Yen") or 0
end

function Util.httpRequest(opts)
    local fn = (syn and syn.request) or (http and http.request) or http_request or request
    if not fn then return nil end
    return fn(opts)
end

function Util.ensureFolders()
    if not isfolder("LixHub")           then makefolder("LixHub")           end
    if not isfolder("LixHub/Macros")    then makefolder("LixHub/Macros")    end
    if not isfolder("LixHub/Macros/AP") then makefolder("LixHub/Macros/AP") end
end

function Util.waitForClientLoaded(timeout)
    timeout = timeout or 60
    local startTime = tick()
    while (tick() - startTime) < timeout do
        if LP:GetAttribute("ClientIsLoaded") and LP:GetAttribute("ClientLoaded") then
            return true
        end
        task.wait(0.5)
    end
    warn("⚠️ Client load timeout after " .. timeout .. "s")
    return false
end

-- ============================================================
-- PLAYER LOADOUT MODULE
-- ============================================================
local Loadout = {
    units = {},  -- slot -> {GUID, Name, Level}
    loaded = false,
}

function Loadout.fetch()
    debugPrint("Fetching player loadout...")
    
    -- Wait for client to be loaded
    if not Util.waitForClientLoaded(60) then
    warn("Client load timeout during loadout fetch")
    return false
end
    
    -- Find player data handler in GC
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "Instance" then continue end
        if type(obj) ~= "table" then continue end
        
        local reqFunc = rawget(obj, "RequestPlayerData")
        
        if type(reqFunc) == "function" then
            local success, data = pcall(function()
                return reqFunc(obj, LP)
            end)
            
            if success and data and data.EquippedUnits and data.Inventory and data.Inventory.Units then
                local equipped = data.EquippedUnits
                local inventory = data.Inventory.Units
                
                for slot = 1, 6 do
                    local guid = equipped[tostring(slot)]
                    if guid and inventory[guid] then
                        local unit = inventory[guid]
                        if unit and unit.Name then
                            Loadout.units[slot] = {
                                GUID = guid,
                                Name = unit.Name,
                                Level = unit.Level or 1
                            }
                        end
                    end
                end
                
                if next(Loadout.units) then
                    Loadout.loaded = true
                    debugPrint("✓ Loadout cached:")
                    for slot, data in pairs(Loadout.units) do
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

function Loadout.getSlot(slot)
    return Loadout.units[slot]
end

function Loadout.findSlotByName(unitName)
    for slot, data in pairs(Loadout.units) do
        if data.Name == unitName then
            return slot
        end
    end
    return nil
end

-- ============================================================
-- STAGE DATA MODULE
-- ============================================================
local StageData = {
    story = {},
    legend = {},
    raid = {},
    siege = {},
    portal = {},
    challenge = {},
}

function StageData.load()
    debugPrint("Loading stage data...")
    
    local stageDataFolder = RS.Modules.Shared.Data.StageData
    if not stageDataFolder then
        warn("StageData folder not found")
        return false
    end
    
    local success, err = pcall(function()
        -- Clear cache
        StageData.story = {}
        StageData.legend = {}
        StageData.raid = {}
        StageData.siege = {}
        StageData.challenge = {}
        
        -- Load all worlds
        for _, worldModule in pairs(stageDataFolder:GetChildren()) do
            if worldModule.Name == "Templates" or not worldModule:IsA("ModuleScript") then continue end
            
            local worldSuccess, worldDataRaw = pcall(require, worldModule)
            if not worldSuccess then continue end
            
            local worldDisplayName = worldDataRaw.StageName or worldModule.Name:gsub("_", " ")
            local worldInternalName = worldModule.Name
            
            debugPrint(string.format("Found world: %s (Display: %s)", worldInternalName, worldDisplayName))
            
            for _, categoryFolder in pairs(worldModule:GetChildren()) do
                if not categoryFolder:IsA("Folder") then continue end
                
                local category = categoryFolder.Name:lower()
                
                if category == "story" or category == "legend" or category == "raid" or category == "siege" or category == "challenge" then
                    local acts = {}
                    
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
                    
                    if #acts > 0 then
                        StageData[category][worldInternalName] = {
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

function StageData.loadPortals()
    debugPrint("Loading portals...")

    if not Util.waitForClientLoaded(30) then
        warn("Client not loaded - cannot load portals")
        return false
    end

    local inventoryModule = nil
    local paths = {
        function()
            return require(LP.PlayerScripts
                :WaitForChild("ClientCache", 15)
                :WaitForChild("Handlers", 15)
                :WaitForChild("UIHandler", 15)
                :WaitForChild("ItemsInventory", 15))
        end,
        function()
            return require(LP.PlayerScripts.ClientCache.Handlers.UIHandler.ItemsInventory)
        end,
    }
    for _, pathFn in ipairs(paths) do
        local ok = pcall(function() inventoryModule = pathFn() end)
        if ok and inventoryModule then break end
    end

    if not inventoryModule then
        warn("Failed to load inventory module for portals")
        return false
    end

    local inventory = nil
    pcall(function() inventory = inventoryModule.getInventory() end)
    if not inventory then
        warn("Failed to get inventory")
        return false
    end

    StageData.portal = {}  -- clear before repopulating
    local addedNames = {}
    local portalCount = 0

    for itemId, itemProfile in pairs(inventory) do
        if itemProfile.BaseData and itemProfile.BaseData.Type == "Portal" then
            local displayName = (itemProfile.BaseData.DisplayName or "Unknown Portal"):match("^%s*(.-)%s*$")
            if not addedNames[displayName] then
                StageData.portal[itemId] = { displayName = displayName, internalName = itemId }
                addedNames[displayName] = true
                portalCount = portalCount + 1
            end
        end
    end

    debugPrint(string.format("✓ Loaded %d unique portals", portalCount))
    if portalCount > 0 then
        Util.notify("Portals Loaded", string.format("Found %d portals", portalCount), 3)
    end
    return true
end

-- ============================================================
-- MACRO MODULE
-- ============================================================
local Macro = {
    -- Storage
    library = {},
    currentName = "",
    
    -- Recording state
    isRecording = false,
    hasStarted = false,
    actions = {},
    unitCounter = {},      -- "UnitName" -> count
    instanceToTag = {},    -- Instance -> "UnitName #N"
    
    -- Playback state
    isPlaying = false,
    loopRunning = false,
    tagToInstance = {},    -- "UnitName #N" -> Instance (for playback)
    scheduledActions = {},
    activeThreads = {},
    
    -- UI labels
    statusLabel = nil,
    detailLabel = nil,
}

-- Status updates
function Macro.setStatus(msg)
    if Macro.statusLabel then
        Macro.statusLabel:Set("Status: (".. Macro.currentName .. ") " .. msg)
    end
end

function Macro.setDetail(msg)
    if Macro.detailLabel then
        Macro.detailLabel:Set("Detail: " .. msg)
    end
end

-- File operations
function Macro.getFilePath(name)
    return "LixHub/Macros/AP/" .. name .. ".json"
end

function Macro.saveToFile(name)
    Util.ensureFolders()
    local data = Macro.library[name]
    if not data then return end
    writefile(Macro.getFilePath(name), Svc.HttpService:JSONEncode(data))
end

function Macro.loadFromFile(name)
    local path = Macro.getFilePath(name)
    if not isfile(path) then return nil end
    local ok, data = pcall(function()
        return Svc.HttpService:JSONDecode(readfile(path))
    end)
    if ok and data then
        Macro.library[name] = data
        return data
    end
end

function Macro.loadAll()
    Util.ensureFolders()
    Macro.library = {}
    
    local files = listfiles("LixHub/Macros/AP/")
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            if name then Macro.loadFromFile(name) end
        end
    end
end

function Macro.getNames()
    local t = {}
    for k in pairs(Macro.library) do t[#t+1] = k end
    table.sort(t)
    return t
end

function Macro.clearTracking()
    Macro.tagToInstance = {}
    Macro.unitCounter = {}
    Macro.instanceToTag = {}
    Macro.scheduledActions = {}
    
    -- Cancel all active threads
    for _, thread in ipairs(Macro.activeThreads) do
        pcall(function() task.cancel(thread) end)
    end
    Macro.activeThreads = {}
end

-- ============================================================
-- MACRO RECORDING
-- ============================================================

function Macro.startRecording()
    if not State.gameInProgress then return end
    Macro.hasStarted = true
    Macro.actions = {}
    Macro.clearTracking()
    Macro.setStatus("Recording in progress...")
    debugPrint("[Macro] Recording started")
end

function Macro.stopRecording(autoSave)
    Macro.isRecording = false
    Macro.hasStarted = false
    local n = #Macro.actions
    if autoSave and Macro.currentName ~= "" then
        Macro.library[Macro.currentName] = Macro.actions
        Macro.saveToFile(Macro.currentName)
        Macro.setStatus("Saved " .. n .. " actions")
        Util.notify("Recording Saved", Macro.currentName .. " (" .. n .. " actions)")
    else
        Macro.setStatus("Recording stopped (" .. n .. " actions, not saved)")
    end
end

-- Extract unit name from tag (e.g., "Dio #1" -> "Dio")
function Macro.getUnitNameFromTag(tag)
    return tag:match("^(.+) #%d+$") or tag
end

-- Find newly placed unit in workspace
function Macro.findNewUnit(unitName, excludeInstances, targetPos)
    excludeInstances = excludeInstances or {}
    
    local candidates = {}
    
    pcall(function()
        local entitiesFolder = Svc.Workspace:FindFirstChild("Entities")
        if not entitiesFolder then return end
        
        for _, unit in pairs(entitiesFolder:GetChildren()) do
            if excludeInstances[unit] then continue end
            
            -- Extract unit name from instance (e.g., "Dio_0.30" -> "Dio")
            local instanceName = unit.Name:match("^(.+)_%d")
            
            if instanceName == unitName then
                if targetPos then
                    local unitPos = unit:GetPivot().Position
                    local distance = (unitPos - targetPos).Magnitude
                    table.insert(candidates, {instance = unit, distance = distance})
                else
                    table.insert(candidates, {instance = unit, distance = 0})
                end
            end
        end
    end)
    
    if #candidates == 0 then return nil end
    
    -- Sort by distance if we have a target position
    if targetPos then
        table.sort(candidates, function(a, b) return a.distance < b.distance end)
    end
    
    return candidates[1].instance
end

-- Record placement (called by hook)
function Macro.onPlace(unitGUID, position)
    if not Macro.isRecording or not Macro.hasStarted then return end
    
    -- Use task.defer instead of task.spawn to avoid thread capability issues on PC executors
    task.defer(function()
        local timestamp = tick() - State.gameStartTime
        
        debugPrint(string.format("[Macro] Placement detected: GUID=%s at (%.1f, %.1f, %.1f)", 
            unitGUID, position.X, position.Y, position.Z))
        
        -- Find unit name from loadout
        local unitName = nil
        local slot = nil
        
        for equipSlot, data in pairs(Loadout.units) do
            if data.GUID == unitGUID then
                unitName = data.Name
                slot = equipSlot
                break
            end
        end
        
        if not unitName then
            warn("[Macro] Could not determine unit name from GUID:", unitGUID)
            return
        end
        
        debugPrint(string.format("[Macro] Placing unit: %s (Slot %d)", unitName, slot))
        
        task.wait(0.5)
        
        -- Build exclude list
        local excludeInstances = {}
        for instance, _ in pairs(Macro.instanceToTag) do
            excludeInstances[instance] = true
        end
        
        -- Find the unit
        local unitInstance = nil
        for attempt = 1, 10 do
            unitInstance = Macro.findNewUnit(unitName, excludeInstances, position)
            if unitInstance then break end
            task.wait(0.3)
        end
        
        if unitInstance then
            -- Create tag
            Macro.unitCounter[unitName] = (Macro.unitCounter[unitName] or 0) + 1
            local unitNumber = Macro.unitCounter[unitName]
            local unitTag = string.format("%s #%d", unitName, unitNumber)
            
            Macro.instanceToTag[unitInstance] = unitTag
            
            -- Record action
            local record = {
                Type = "spawn_unit",
                Unit = unitTag,
                Time = string.format("%.2f", timestamp),
                Position = {position.X, position.Y, position.Z},
            }
            
            table.insert(Macro.actions, record)
            
            debugPrint(string.format("[Macro] Recorded: %s at %.2fs (Instance=%s)", 
                unitTag, timestamp, unitInstance.Name))
        else
            warn("[Macro] Failed to find placed unit in workspace!")
        end
    end)
end

-- Record upgrade (called by hook)
function Macro.onUpgrade(unitInstance)
    if not Macro.isRecording or not Macro.hasStarted then return end
    
    local unitTag = Macro.instanceToTag[unitInstance]
    if not unitTag then
        warn("[Macro] Upgrade detected for untracked unit:", unitInstance.Name)
        return
    end
    
    local timestamp = tick() - State.gameStartTime
    
    table.insert(Macro.actions, {
        Type = "upgrade_unit",
        Unit = unitTag,
        Time = string.format("%.2f", timestamp)
    })
    
    debugPrint(string.format("[Macro] Recorded upgrade: %s at %.2fs", unitTag, timestamp))
end

-- Record sell (called by hook)
function Macro.onSell(unitInstance)
    if not Macro.isRecording or not Macro.hasStarted then return end
    
    local unitTag = Macro.instanceToTag[unitInstance]
    if not unitTag then
        warn("[Macro] Sell detected for untracked unit:", unitInstance.Name)
        return
    end
    
    local timestamp = tick() - State.gameStartTime
    
    table.insert(Macro.actions, {
        Type = "sell_unit",
        Unit = unitTag,
        Time = string.format("%.2f", timestamp)
    })
    
    debugPrint(string.format("[Macro] Recorded sell: %s at %.2fs", unitTag, timestamp))
    
    Macro.instanceToTag[unitInstance] = nil
end

-- Record ability (called by hook)
function Macro.onAbility(unitInstance, abilitySlot)
    if not Macro.isRecording or not Macro.hasStarted then return end
    
    local unitTag = Macro.instanceToTag[unitInstance]
    if not unitTag then
        warn("[Macro] Ability detected for untracked unit:", unitInstance.Name)
        return
    end
    
    local timestamp = tick() - State.gameStartTime
    
    table.insert(Macro.actions, {
        Type = "use_ability",
        Unit = unitTag,
        AbilitySlot = abilitySlot,
        Time = string.format("%.2f", timestamp)
    })
    
    debugPrint(string.format("[Macro] Recorded ability: %s slot %s at %.2fs", 
        unitTag, abilitySlot, timestamp))
end

-- ============================================================
-- MACRO PLAYBACK
-- ============================================================

-- Wait for money
function Macro.waitForMoney(amount, description)
    if not amount or amount <= 0 then return true end
    
    while Util.getMoney() < amount and Macro.isPlaying and State.gameInProgress do
        Macro.setDetail(string.format("Waiting: $%d / $%d (%s)", Util.getMoney(), amount, description))
        task.wait(0.5)
    end
    
    return Macro.isPlaying and State.gameInProgress
end

-- Get unit data module
local UnitDataCache = {}
function Macro.getUnitData(unitName)
    if UnitDataCache[unitName] then
        return UnitDataCache[unitName]
    end
    
    local success, result = pcall(function()
        local module = RS.Modules.Shared.Data.UnitData.Units:FindFirstChild(unitName)
        if not module or not module:IsA("ModuleScript") then return nil end
        return require(module)
    end)
    
    if success and result then
        UnitDataCache[unitName] = result
    end
    
    return success and result or nil
end

-- Execute placement
function Macro.execPlacement(action, idx, total)
    local unitName = Macro.getUnitNameFromTag(action.Unit)
    
    Macro.setStatus(string.format("(%d/%d) Placing %s", idx, total, action.Unit))
    
    -- Find unit in loadout
    local slot = Loadout.findSlotByName(unitName)
    
    if not slot then
        Macro.setDetail(string.format("Error: %s not equipped!", unitName))
        warn(string.format("%s is not in loadout - skipping placement", unitName))
        return false
    end
    
    local unitInfo = Loadout.getSlot(slot)
    if not unitInfo then
        Macro.setDetail("Error: Could not get unit data")
        return false
    end
    
    debugPrint(string.format("Found %s in slot %d (GUID: %s)", unitName, slot, unitInfo.GUID))
    
    -- Get placement cost
    local unitData = Macro.getUnitData(unitName)
    local placementCost = 0
    
    if unitData and unitData.BaseStats then
        placementCost = unitData.BaseStats.Cost or 0
    end
    
    -- Wait for money
    if placementCost > 0 then
        local canContinue = Macro.waitForMoney(placementCost, unitName)
        if not canContinue then
            Macro.setDetail("Game ended while waiting for money")
            return false
        end
    end
    
    Macro.setDetail(string.format("Placing %s...", action.Unit))
    
    local pos = action.Position
    local position = Vector3.new(pos[1], pos[2], pos[3])
    
    -- Place unit
    local success = pcall(function()
        local remote = LP.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Place", unitInfo.GUID, position, slot - 1)
    end)
    
    if not success then
        Macro.setDetail("Placement failed")
        return false
    end
    
    task.wait(0.5)
    
    -- Find placed unit
    local excludeInstances = {}
    for _, mappedInstance in pairs(Macro.tagToInstance) do
        excludeInstances[mappedInstance] = true
    end
    
    local unitInstance = nil
    for attempt = 1, 10 do
        unitInstance = Macro.findNewUnit(unitName, excludeInstances, position)
        if unitInstance then break end
        task.wait(0.3)
    end
    
    if unitInstance then
        Macro.tagToInstance[action.Unit] = unitInstance
        Macro.setDetail(string.format("Placed %s", action.Unit))
        return true
    end
    
    Macro.setDetail("Failed to detect placed unit")
    return false
end

-- Execute upgrade
function Macro.execUpgrade(action, idx, total)
    Macro.setStatus(string.format("(%d/%d) Upgrading %s", idx, total, action.Unit))
    
    local unitInstance = Macro.tagToInstance[action.Unit]
    
    if not unitInstance or not unitInstance.Parent then
        Macro.setDetail(string.format("Error: Unit instance not found for %s", action.Unit))
        return false
    end
    
    local unitName = Macro.getUnitNameFromTag(action.Unit)
    local currentUpgrade = unitInstance:GetAttribute("Upgrades") or 0
    
    debugPrint(string.format("Attempting to upgrade %s (Current Level: %d)", action.Unit, currentUpgrade))
    
    -- Get upgrade cost
    local unitData = Macro.getUnitData(unitName)
    local upgradeCost = 0
    
    if unitData and unitData.UpgradeStats then
        local nextUpgradeIndex = currentUpgrade + 1
        local upgradeData = unitData.UpgradeStats[nextUpgradeIndex]
        
        if upgradeData and upgradeData.Cost then
            upgradeCost = upgradeData.Cost
        else
            Macro.setDetail(string.format("%s is max level (%d)", action.Unit, currentUpgrade))
            return true
        end
    end
    
    -- Wait for money
    if upgradeCost > 0 then
        local canContinue = Macro.waitForMoney(upgradeCost, string.format("%s upgrade to level %d", action.Unit, currentUpgrade + 1))
        if not canContinue then
            Macro.setDetail("Game ended while waiting for money")
            return false
        end
    end
    
    Macro.setDetail(string.format("Upgrading %s to level %d...", action.Unit, currentUpgrade + 1))
    
    local success = pcall(function()
        local remote = LP.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Upgrade", unitInstance, true)
    end)
    
    if success then
        task.wait(0.5)
        local newUpgrade = unitInstance:GetAttribute("Upgrades") or 0
        if newUpgrade > currentUpgrade then
            Macro.setDetail(string.format("Upgraded %s to level %d ✓", action.Unit, newUpgrade))
        else
            Macro.setDetail(string.format("Upgrade attempt for %s (level %d)", action.Unit, newUpgrade))
        end
        return true
    end
    
    Macro.setDetail("Upgrade failed")
    return false
end

-- Execute sell
function Macro.execSell(action, idx, total)
    Macro.setStatus(string.format("(%d/%d) Selling %s", idx, total, action.Unit))
    
    local unitInstance = Macro.tagToInstance[action.Unit]
    
    if not unitInstance or not unitInstance.Parent then
        Macro.setDetail(string.format("Error: Unit instance not found for %s", action.Unit))
        return false
    end
    
    Macro.setDetail(string.format("Selling %s...", action.Unit))
    
    local success = pcall(function()
        local remote = LP.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Sell", unitInstance)
    end)
    
    if success then
        Macro.tagToInstance[action.Unit] = nil
        Macro.setDetail(string.format("Sold %s", action.Unit))
        return true
    end
    
    Macro.setDetail("Sell failed")
    return false
end

-- Execute ability
function Macro.execAbility(action)
    local unitInstance = Macro.tagToInstance[action.Unit]
    
    if not unitInstance or not unitInstance.Parent then
        debugPrint(string.format("Cannot use ability - %s not found or sold", action.Unit))
        return false
    end
    
    local abilitySlot = action.AbilitySlot
    
    debugPrint(string.format("Using ability: %s slot %s", action.Unit, abilitySlot))
    
    local success = pcall(function()
        local remote = LP.Character.CharacterHandler.Remotes.UnitAction
        remote:FireServer("Active", unitInstance, abilitySlot)
    end)
    
    if success then
        debugPrint(string.format("Ability fired: %s slot %s", action.Unit, abilitySlot))
        return true
    end
    
    debugPrint(string.format("Ability failed: %s slot %s", action.Unit, abilitySlot))
    return false
end

-- Schedule ability for later
function Macro.scheduleAbility(action, targetTime)
    local schedulerId = tostring(action) .. "_" .. tostring(targetTime)
    
    if Macro.scheduledActions[schedulerId] then return end
    
    Macro.scheduledActions[schedulerId] = true
    
    local thread = task.spawn(function()
        while Macro.isPlaying and State.gameInProgress do
            local currentGameTime = tick() - State.gameStartTime
            local waitTime = targetTime - currentGameTime
            
            if waitTime <= 0 then
                Macro.execAbility(action)
                Macro.scheduledActions[schedulerId] = nil
                return
            end
            
            task.wait(0.1)
        end
        
        Macro.scheduledActions[schedulerId] = nil
    end)
    
    table.insert(Macro.activeThreads, thread)
end

-- Play macro once
function Macro.playOnce()
    if not Macro.currentName or Macro.currentName == "" then
        Macro.setDetail("No macro selected")
        return false
    end
    
    local actions = Macro.loadFromFile(Macro.currentName)
    if not actions or #actions == 0 then
        Macro.setDetail("Macro is empty or not found")
        return false
    end
    
    Macro.clearTracking()
    
    local total = #actions
    Macro.setStatus("Playing: " .. Macro.currentName)
    Macro.setDetail("Loading " .. total .. " actions...")
    
    debugPrint(string.format("Starting playback: %d actions", total))
    
    for i, action in ipairs(actions) do
        if not Macro.isPlaying or not State.gameInProgress then
            debugPrint(string.format("Stopping playback at action %d/%d", i, total))
            Macro.setDetail("Game ended - stopped playback")
            Macro.clearTracking()
            return false
        end
        
        -- Handle abilities specially - always respect timing
        if action.Type == "use_ability" then
            local actionTime = tonumber(action.Time)
            
            if actionTime then
                local currentGameTime = tick() - State.gameStartTime
                
                if currentGameTime < actionTime then
                    Macro.scheduleAbility(action, actionTime)
                    Macro.setDetail(string.format("(%d/%d) Scheduled ability for %.1fs", i, total, actionTime))
                else
                    Macro.execAbility(action)
                    Macro.setDetail(string.format("(%d/%d) Used ability (late by %.1fs)", i, total, currentGameTime - actionTime))
                end
            end
            
            task.wait(0.1)
            continue
        end
        
        -- Handle timing for non-ability actions
        if not State.IgnoreTiming then
            local actionTime = tonumber(action.Time)
            
            if actionTime then
                local currentGameTime = tick() - State.gameStartTime
                local waitTime = actionTime - currentGameTime
                
                if waitTime > 1 then
                    local waitStart = tick()
                    while (tick() - waitStart) < waitTime do
                        if not Macro.isPlaying or not State.gameInProgress then
                            debugPrint("Game ended while waiting")
                            Macro.setDetail("Game ended - stopped playback")
                            Macro.clearTracking()
                            return false
                        end
                        
                        local remaining = waitTime - (tick() - waitStart)
                        if remaining > 1 then
                            Macro.setDetail(string.format("(%d/%d) Waiting %.1fs for %s", 
                                i, total, remaining, action.Unit or "next action"))
                        end
                        
                        task.wait(0.5)
                    end
                elseif waitTime > 0 then
                    task.wait(waitTime)
                end
            end
        else
            if i > 1 then
                task.wait(0.2)
            end
        end
        
        if not Macro.isPlaying or not State.gameInProgress then
            debugPrint("Game ended before action execution")
            Macro.setDetail("Game ended - stopped playback")
            Macro.clearTracking()
            return false
        end
        
        -- Execute action
        local success = false
        
        if action.Type == "spawn_unit" then
            success = Macro.execPlacement(action, i, total)
        elseif action.Type == "upgrade_unit" then
            success = Macro.execUpgrade(action, i, total)
        elseif action.Type == "sell_unit" then
            success = Macro.execSell(action, i, total)
        end
        
        task.wait(0.2)
    end
    
    Macro.setStatus("Playback Complete")
    Macro.setDetail(string.format("Completed %d/%d actions ✓", total, total))
    
    task.wait(1)
    return true
end

-- Auto-loop playback
function Macro.autoLoop()
    if Macro.loopRunning then return end
    Macro.loopRunning = true
    
    debugPrint("🔄 Playback loop started")
    
    while Macro.isPlaying do
        -- Wait for game to start
        while not State.gameInProgress and Macro.isPlaying do
            Macro.setStatus("Waiting for game to start...")
            Macro.setDetail("Waiting for wave 1...")
            task.wait(0.5)
        end
        
        if not Macro.isPlaying then break end

        task.wait(1)
        
        -- ✅ Resolve world-specific macro RIGHT before playback, after game has started
        local resolvedMacro = Macro.currentName
        local worldMacro = Macro.getCurrentWorld()
        if worldMacro and worldMacro ~= "" then
            resolvedMacro = worldMacro
            debugPrint("Auto-select resolved macro: " .. resolvedMacro)
        else
            debugPrint("No world-specific macro found, using selected: " .. tostring(resolvedMacro))
        end
        
        -- Temporarily override currentName for this run
        local previousName = Macro.currentName
        Macro.currentName = resolvedMacro
        
        Macro.clearTracking()
        Macro.playOnce()
        
        -- Restore original selection after run
        Macro.currentName = previousName
        
        -- Wait for game to end
        while State.gameInProgress and Macro.isPlaying do
            task.wait(0.5)
        end
        
        if not Macro.isPlaying then break end
        
        Macro.clearTracking()
        Macro.setStatus("Game ended - waiting for next...")
        Macro.setDetail("Ready for next game")
        
        task.wait(2)
    end
    
    Macro.setStatus("Playback Stopped")
    Macro.setDetail("Ready")
    Macro.loopRunning = false
end

function Macro.saveWorldMappings()
    local filePath = "LixHub/" .. LP.Name .. "_WorldMappings_AP.json"
    Util.ensureFolders()
    
    local data = {
        mappings = Macro.worldMappings or {}
    }
    
    writefile(filePath, Svc.HttpService:JSONEncode(data))
    debugPrint("Saved world macro mappings")
end

function Macro.loadWorldMappings()
    local filePath = "LixHub/" .. LP.Name .. "_WorldMappings_AP.json"
    
    if not isfile(filePath) then 
        Macro.worldMappings = {}
        return 
    end
    
    local success, data = pcall(function()
        local json = readfile(filePath)
        return Svc.HttpService:JSONDecode(json)
    end)
    
    if success and data and data.mappings then
        Macro.worldMappings = data.mappings
        debugPrint("Loaded world macro mappings")
    else
        Macro.worldMappings = {}
    end
end

function Macro.getCurrentWorld()
    local success, gameConfig = pcall(function() return RS.GameConfig end)
    if not success or not gameConfig then return nil end
    local map = gameConfig:FindFirstChild("Map")
    local stageType = gameConfig:FindFirstChild("StageType")
    if not map or not stageType then return nil end

    local mapValue = map.Value
    local stageTypeValue = stageType.Value

    debugPrint(string.format("[getCurrentWorld] Map='%s' StageType='%s'", mapValue, stageTypeValue))

    local key

    if stageTypeValue == "Portal" then
        local friendlyName = PORTAL_MAP_NAMES[mapValue]
        if friendlyName then
            key = "Portal_" .. friendlyName
        else
            debugPrint("[getCurrentWorld] Unknown portal map: " .. mapValue)
            return nil
        end
    else
        key = string.format("%s_%s", mapValue, stageTypeValue)
    end

    local mapping = Macro.worldMappings[key]
    debugPrint(string.format("[getCurrentWorld] key='%s' mapping='%s'", tostring(key), tostring(mapping)))
    return mapping or nil
end

debugPrint("✓ Core modules loaded")

-- ============================================================
-- __NAMECALL HOOK (CRITICAL: PC EXECUTOR FIX)
-- ============================================================
do
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local _original = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Call original first to avoid capability issues
        local result = _original(self, ...)
        
        -- Only hook if not from our code
        if not checkcaller() and Macro.isRecording and Macro.hasStarted then
            -- CRITICAL FIX: Use task.defer instead of task.spawn
            -- This avoids "cannot access instance lacking capability plugin" error on PC executors
            
            -- PLACEMENT HOOK
            if method == "FireServer" and self.Name == "UnitAction" and args[1] == "Place" then
                local unitGUID = args[2]
                local position = args[3]
                
                task.defer(function()
                    Macro.onPlace(unitGUID, position)
                end)
                
            -- UPGRADE HOOK
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Upgrade" then
                local unitInstance = args[2]
                
                task.defer(function()
                    Macro.onUpgrade(unitInstance)
                end)
                
            -- SELL HOOK
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Sell" then
                local unitInstance = args[2]
                
                task.defer(function()
                    Macro.onSell(unitInstance)
                end)
                
            -- ABILITY HOOK
            elseif method == "FireServer" and self.Name == "UnitAction" and args[1] == "Active" then
                local unitInstance = args[2]
                local abilitySlot = args[3]
                
                task.defer(function()
                    Macro.onAbility(unitInstance, abilitySlot)
                end)
            end
        end
        
        return result
    end)
    
    setreadonly(mt, true)
    debugPrint("✓ Namecall hook installed (PC executor compatible)")
end

-- ============================================================
-- AUTO-JOINER MODULE
-- ============================================================
local AutoJoin = {
    processing = false,
    clientReady = false,
    lastAction = 0,
    cooldown = 2.5,
}

function AutoJoin.canAct()
    return not AutoJoin.processing 
       and (tick() - AutoJoin.lastAction) >= AutoJoin.cooldown
       and Util.isInLobby()
end

function AutoJoin.begin(label)
    AutoJoin.processing = true
    AutoJoin.lastAction = tick()
    debugPrint("[AutoJoin] Begin:", label)
end

function AutoJoin.finish()
    task.delay(4, function()
        AutoJoin.processing = false
    end)
end

function AutoJoin.waitForClient()
    if AutoJoin.clientReady then return true end
    AutoJoin.clientReady = Util.waitForClientLoaded(60)
    return AutoJoin.clientReady
end

-- Get highest portal from inventory
function AutoJoin.getHighestPortal()
    debugPrint("Checking for highest level portal...")
    
    -- Reload inventory
    local inventoryModule = nil
    local success = pcall(function()
        inventoryModule = require(
            LP.PlayerScripts.ClientCache.Handlers.UIHandler.ItemsInventory
        )
    end)
    
    if not success or not inventoryModule then
        warn("Failed to load inventory module")
        return nil
    end
    
    local inventory = nil
    success = pcall(function()
        inventory = inventoryModule.getInventory()
    end)
    
    if not success or not inventory then
        warn("Failed to get inventory")
        return nil
    end
    
    -- Find highest level portal
    local highestPortal = nil
    local highestLevel = 0
    
    for itemId, itemProfile in pairs(inventory) do
        if itemProfile.BaseData and itemProfile.BaseData.Type == "Portal" then
            local displayName = itemProfile.BaseData.DisplayName or ""
            local level = tonumber(displayName:match("Lv%.(%d+)"))
            
            if level and level > highestLevel then
                highestLevel = level
                local baseName = displayName:match("^(.+)%s+Lv") or displayName
                baseName = baseName:gsub(" ", "_")
                highestPortal = string.format("%s_Lv%d", baseName, level)
                
                debugPrint(string.format("  Found portal: %s (Level %d)", displayName, level))
            end
        end
    end
    
    if highestPortal then
        debugPrint(string.format("✓ Highest portal: %s (Level %d)", highestPortal, highestLevel))
    else
        debugPrint("✗ No portals found")
    end
    
    return highestPortal
end

function Challenge.init()
    if Challenge.modules then return true end
    
    local success = pcall(function()
        Challenge.modules = {
            PeriodKeys = require(LP.PlayerScripts.ClientCache.Handlers.UIHandler.Pods.PodsMapSelection.PeriodKeys),
            ReplicaHandler = require(RS.Modules.Shared.Handlers.ReplicaHandler)
        }
    end)
    
    if not success then
        warn("Failed to initialize challenge system")
        return false
    end
    
    debugPrint("✓ Challenge system initialized")
    return true
end

function Challenge.isCompleted(challengeType, challengeFolder)
    if not challengeFolder or not challengeFolder:IsA("Folder") then
        return true
    end
    
    if not Challenge.init() then
        return false
    end
    
    local challengeIndex = tonumber(challengeFolder.Name)
    if not challengeIndex then
        warn("Invalid challenge folder name:", challengeFolder.Name)
        return true
    end
    
    local success, playerData = pcall(function()
        return Challenge.modules.ReplicaHandler:RequestPlayerData(LP)
    end)
    
    if not success or not playerData or not playerData.Challenges then
        warn("Failed to get player challenge data")
        return false
    end
    
    local challenges = playerData.Challenges
    local currentKey = nil
    local challengeData = nil
    
    if challengeType == "Weekly" then
        currentKey = Challenge.modules.PeriodKeys.GetCurrentWeekKey()
        challengeData = challenges.Weekly[challengeIndex]
    elseif challengeType == "Daily" then
        currentKey = Challenge.modules.PeriodKeys.GetCurrentDayKey()
        challengeData = challenges.Daily[challengeIndex]
    elseif challengeType == "Regular" then
        currentKey = Challenge.modules.PeriodKeys.GetCurrentHourKey()
        challengeData = challenges.Regular[challengeIndex]
    else
        warn("Unknown challenge type:", challengeType)
        return false
    end
    
    local isCompleted = (type(challengeData) == "string" and challengeData == currentKey)
    
    debugPrint(string.format(
        "%s Challenge %d: %s",
        challengeType,
        challengeIndex,
        isCompleted and "COMPLETED" or "AVAILABLE"
    ))
    
    return isCompleted
end

function Challenge.passesFilters(challengeFolder, challengeType)
    if not challengeFolder or not challengeFolder:IsA("Folder") then
        return false
    end
    
    local stageNameObj = challengeFolder:FindFirstChild("StageName")
    local modifierObj = challengeFolder:FindFirstChild("Modifier")
    local rewardsFolder = challengeFolder:FindFirstChild("Rewards")
    
    if not stageNameObj then
        return false
    end
    
    -- Check challenge type filter
    if next(State.ChallengeTypes) then
    if not State.ChallengeTypes[challengeType] then
        return false
    end
end
    
    -- Check ignore worlds
    if State.IgnoreWorlds and #State.IgnoreWorlds > 0 then
        local stageName = stageNameObj.Value
        
        for _, ignoredWorld in ipairs(State.IgnoreWorlds) do
            if stageName == ignoredWorld then
                return false
            end
        end
    end
    
    -- Check ignore modifiers
    if State.IgnoreModifiers and #State.IgnoreModifiers > 0 and modifierObj then
        local modifierValue = modifierObj.Value
        if modifierValue and modifierValue ~= "" then
            for _, ignoredModifier in ipairs(State.IgnoreModifiers) do
                if modifierValue == ignoredModifier then
                    return false
                end
            end
        end
    end
    
    -- Check rewards filter
    if State.ChallengeRewards and #State.ChallengeRewards > 0 and rewardsFolder then
        local hasMatchingReward = false
        
        for _, rewardObj in pairs(rewardsFolder:GetChildren()) do
            local rewardName = rewardObj.Name
            
            for _, filteredReward in ipairs(State.ChallengeRewards) do
                local normalizedReward = filteredReward:gsub(" ", "")
                if rewardName == filteredReward or 
                   rewardName == normalizedReward or 
                   rewardName:find(filteredReward) or
                   filteredReward:find(rewardName) then
                    hasMatchingReward = true
                    break
                end
            end
            
            if hasMatchingReward then
                break
            end
        end
        
        if not hasMatchingReward then
            return false
        end
    end
    
    return true
end

function Challenge.findAndJoin()
    local challengesFolder = RS:FindFirstChild("Challenges")
    if not challengesFolder then
        warn("Challenges folder not found!")
        return false
    end
    
    for _, typeFolder in pairs(challengesFolder:GetChildren()) do
        if typeFolder:IsA("Folder") then
            local challengeType = typeFolder.Name
            
            for _, challengeFolder in pairs(typeFolder:GetChildren()) do
                if challengeFolder:IsA("Folder") and Challenge.passesFilters(challengeFolder, challengeType) then
                    
                    if Challenge.isCompleted(challengeType, challengeFolder) then
                        debugPrint(string.format("Skipping completed %s challenge", challengeType))
                        continue
                    end
                    
                    local idObj = challengeFolder:FindFirstChild("ID")
                    local stageNameObj = challengeFolder:FindFirstChild("StageName")
                    local actObj = challengeFolder:FindFirstChild("Act")
                    local stageTypeObj = challengeFolder:FindFirstChild("StageType")
                    local challengeNameObj = challengeFolder:FindFirstChild("ChallengeName")
                    
                    if not idObj or not stageNameObj or not actObj then
                        continue
                    end
                    
                    local id = idObj.Value
                    local stageName = stageNameObj.Value
                    local act = tostring(actObj.Value)
                    local stageType = stageTypeObj and stageTypeObj.Value or "Story"
                    local challengeName = challengeNameObj and challengeNameObj.Value or challengeFolder.Name
                    
                    debugPrint(string.format("Joining challenge: %s (%s)", challengeName, challengeType))
                    
                    local success = pcall(function()
                        RS.Remotes.Pod:FireServer(
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
                        RS.Remotes.Pod:FireServer("Start")
                    end)
                    
                    if success then
                        Util.notify("Challenge Started", string.format("%s: %s", challengeType, challengeName), 3)
                        State.newChallengeDetected = false
                        return true
                    end
                end
            end
        end
    end
    
    debugPrint("No valid challenges found")
    return false
end

function Challenge.checkForNew()
    local currentTime = os.time()
    local currentDate = os.date("*t", currentTime)
    
    if currentDate.min <= 1 and currentTime - State.lastChallengeCheck > 300 then
        State.lastChallengeCheck = currentTime
        State.newChallengeDetected = true
        debugPrint("New hour - new challenges may be available")
        Util.notify("New Challenges", "New challenges available!", 3)
    end
end

-- Execute highest priority auto-join
function AutoJoin.execute()
    if not AutoJoin.canAct() then return end
    if not AutoJoin.waitForClient() then return end
    
    -- Priority: Challenge > Story > Legend > Raid > Siege > Portal
    -- Delay logic
    if State.AutoJoinDelay > 0 then
        if not State.AutoJoinDelayStart then
            State.AutoJoinDelayStart = tick()
            debugPrint(string.format("[AutoJoin] Waiting %ds before joining...", State.AutoJoinDelay))
            return
        elseif (tick() - State.AutoJoinDelayStart) < State.AutoJoinDelay then
            return
        end
    end
    State.AutoJoinDelayStart = nil
    -- CHALLENGE

    if State.AutoJoinChallenge then
        AutoJoin.begin("Challenge")
        
        local success = Challenge.findAndJoin()
        
        if success then
            AutoJoin.finish()
            return
        else
            -- No valid challenges, continue to other auto-joins
            AutoJoin.processing = false
        end
    end
    
    -- STORY
    if State.AutoJoinStory and State.StoryStage and State.StoryAct and State.StoryDifficulty then
        AutoJoin.begin("Story")
        
        pcall(function()
            RS.Remotes.Pod:FireServer("Create", State.StoryStage, "Story", State.StoryAct, true, State.StoryDifficulty, nil)
            RS.Remotes.Pod:FireServer("Start")
        end)
        
        AutoJoin.finish()
        return
    end
    
    -- LEGEND
    if State.AutoJoinLegend and State.LegendStage and State.LegendAct then
        AutoJoin.begin("Legend")
        
        pcall(function()
            RS.Remotes.Pod:FireServer("Create", State.LegendStage, "Legend", State.LegendAct, true, "Normal", nil)
            RS.Remotes.Pod:FireServer("Start")
        end)
        
        AutoJoin.finish()
        return
    end
    
    -- RAID
    if State.AutoJoinRaid and State.RaidStage and State.RaidAct then
        AutoJoin.begin("Raid")
        
        pcall(function()
            RS.Remotes.Pod:FireServer("Create", State.RaidStage, "Raid", State.RaidAct, true, "Normal", nil)
            RS.Remotes.Pod:FireServer("Start")
        end)
        
        AutoJoin.finish()
        return
    end
    
    -- SIEGE
    if State.AutoJoinSiege and State.SiegeStage and State.SiegeAct then
        AutoJoin.begin("Siege")
        
        pcall(function()
            RS.Remotes.Pod:FireServer("Create", State.SiegeStage, "Siege", State.SiegeAct, true, "Normal", nil)
            RS.Remotes.Pod:FireServer("Start")
        end)
        
        AutoJoin.finish()
        return
    end
    
    -- PORTAL
    if State.AutoJoinPortal and State.PortalStage then
        AutoJoin.begin("Portal")
        
        pcall(function()
            RS.Remotes.UseItem:FireServer(State.PortalStage)
            RS.Remotes.Portal:FireServer("Start")
        end)
        
        AutoJoin.finish()
        return
    end
end

function GoldShop.getGold()
    local success, amount = pcall(function()
        local text = LP.PlayerGui.MainHUD.BottomFrame.Currency.Gold.Amount.Text
        return tonumber((text:gsub(",", ""))) or 0
    end)
    return success and amount or 0
end

function GoldShop.getShopStock()
    local success, stock = pcall(function()
        return RS.Modules.Shared.Data.ShopConfigs.Gold
    end)
    return success and stock or nil
end

function GoldShop.buyItems()
    if not State.AutoGoldShop then return end
    if not Util.isInLobby() then return end
    if not next(State.GoldShopItems) then return end

    local gold = GoldShop.getGold()
    debugPrint(string.format("[GoldShop] Current gold: %d", gold))

    for _, item in ipairs(GOLD_SHOP_ITEMS) do
        if not State.GoldShopItems[item.id] then continue end

        if gold < item.cost then
            debugPrint(string.format("[GoldShop] Not enough gold for %s (%d/%d)", item.name, gold, item.cost))
            continue
        end

        -- Calculate how many we can afford up to maxstock
        local maxAffordable = math.floor(gold / item.cost)
        local quantity = math.min(maxAffordable, item.maxStock)

        if quantity <= 0 then continue end

        local success, err = pcall(function()
            RS.Remotes.RotatingShop:FireServer("Gold", item.id, quantity)
        end)

        if success then
            local spent = item.cost * quantity
            gold = gold - spent
            debugPrint(string.format("[GoldShop] Bought %dx %s for %d gold (remaining: %d)", quantity, item.name, spent, gold))
            Util.notify("Gold Shop", string.format("Bought %dx %s", quantity, item.name), 2)
            task.wait(0.3)
        else
            debugPrint(string.format("[GoldShop] Failed to buy %s: %s", item.name, tostring(err)))
        end
    end
end

-- Auto-joiner loop
task.spawn(function()
    while true do
        task.wait(0.5)
        AutoJoin.execute()
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoGoldShop and Util.isInLobby() then
            GoldShop.buyItems()
        end
    end
end)

-- ============================================================
-- END GAME ACTIONS
-- ============================================================
local function handleEndGame()
    local endGameUI = nil
    local maxWait = 10
    local startTime = tick()
    
    -- Wait for end game UI
    while (tick() - startTime) < maxWait do
        local success = pcall(function()
            local resultsUI = LP.PlayerGui:FindFirstChild("StageEnd")
            if resultsUI and resultsUI.Enabled then
                endGameUI = resultsUI
            end
        end)
        
        if endGameUI then break end
        task.wait(0.5)
    end
    
    if not endGameUI then
        warn("End game UI not found")
        return
    end
    
    -- Check if it's a portal and we won
    if State.AutoNextPortal then
        local wasPortal = false
        local didWin = false
        
        pcall(function()
            local stageType = RS.GameConfig.StageType.Value
            wasPortal = (stageType == "Portal")
        end)
        
        pcall(function()
            local resultsFrame = endGameUI:FindFirstChild("StageEnd")
            if resultsFrame then
                local resultLabel = resultsFrame:FindFirstChild("VictoryHeader"):FindFirstChild("NameTitle")
                if resultLabel and resultLabel.Text then
                    didWin = resultLabel.Text:lower():find("victory")
                end
            end
        end)
        
        if wasPortal and didWin then
            debugPrint("Portal completed - checking for next portal...")
            
            local highestPortal = AutoJoin.getHighestPortal()
            
            if highestPortal then
                debugPrint(string.format("Starting next portal: %s", highestPortal))
                
                for attempt = 1, 5 do
                    pcall(function()
                        RS.Remotes.StageEnd:FireServer("UsePortal", highestPortal)
                    end)
                    
                    task.wait(1)
                    
                    local uiClosed = pcall(function()
                        return not endGameUI.Enabled
                    end)
                    
                    if uiClosed or not endGameUI.Parent then
                        debugPrint("Auto Next Portal successful!")
                        Util.notify("Auto Action", string.format("Started next portal: %s", highestPortal), 2)
                        return
                    end
                end
                
                warn("Failed to start next portal")
            else
                debugPrint("No portals available")
                Util.notify("Auto Portal", "No portals available", 3)
            end
        end
    end
    
    -- Normal priority: Next > Retry > Lobby
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
    
    if #actions == 0 then return end
    
    -- Try each action
    for _, action in ipairs(actions) do
        debugPrint(string.format("Attempting auto %s...", action.name))
        
        for attempt = 1, 5 do
            pcall(function()
                RS.Remotes.StageEnd:FireServer(action.remote)
            end)
            
            task.wait(1)
            
            local uiClosed = pcall(function()
                return not endGameUI.Enabled
            end)
            
            if uiClosed or not endGameUI.Parent then
                debugPrint(string.format("Auto %s successful!", action.name))
                Util.notify("Auto Action", string.format("Auto %s activated", action.name), 2)
                return
            end
        end
    end
    
    warn("All auto end game actions failed")
end

function Webhook.send(messageType, stageInfo, playerStats, rewardsData, playerData)
    if not State.WebhookURL or State.WebhookURL == "" then
        return
    end
    
    local data
    
    if messageType == "test" then
        data = {
            username = "LixHub",
            content = State.DiscordUserID and string.format("<@%s>", State.DiscordUserID) or "",
            embeds = {{
                title = "Webhook Test",
                description = "Test webhook sent successfully!",
                color = 0x5865F2,
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
    elseif messageType == "game_end" then
        local playerName = "||" .. LP.Name .. "||"
        
        local didWin = stageInfo and stageInfo.Result == "Win"
        local resultText = didWin and "Victory" or "Defeat"
        local embedColor = didWin and 0x57F287 or 0xED4245
        
        local stageName = (stageInfo and stageInfo.StageName or "Unknown"):gsub("_", " ")
        local actName = stageInfo and stageInfo.ActName or "Unknown Act"
        local difficulty = stageInfo and stageInfo.Difficulty or "Normal"
        
        local stageTitle = didWin and "Stage Completed!" or "Stage Failed"
        local stageSubtitle = string.format("%s - %s (%s) - %s", 
            stageName, actName, difficulty, resultText
        )
        
        local playTime = stageInfo and stageInfo.PlayTime or 0
        local minutes = math.floor(playTime / 60)
        local seconds = playTime % 60
        local timeText = string.format("%dm %ds", minutes, seconds)
        
        -- Get current totals
        local currentGems = 0
        local currentGold = 0
        local currentItems = {}
        
        if playerData and playerData.ClientData then
            currentGems = playerData.ClientData.Gems or 0
            currentGold = playerData.ClientData.Gold or 0
            
            for key, value in pairs(playerData.ClientData) do
                if type(value) == "number" and key ~= "Gems" and key ~= "Gold" then
                    currentItems[key] = value
                end
            end
        end
        
        if playerData and playerData.Inventory and playerData.Inventory.Items then
            for itemId, itemData in pairs(playerData.Inventory.Items) do
                if itemData.BaseDataRef and itemData.Amount then
                    if not currentItems[itemData.BaseDataRef] then
                        currentItems[itemData.BaseDataRef] = itemData.Amount
                    end
                end
            end
        end
        
        -- Check for unit drops
        local unitsDropped = {}
        local unitCounts = {}
        local shouldPingUser = false
        
        if rewardsData then
            for itemName, value in pairs(rewardsData) do
                if value == "Unit" then
                    shouldPingUser = true
                    
                    local newestUnit = nil
                    local newestCreated = 0
                    
                    if playerData and playerData.Inventory and playerData.Inventory.Units then
                        for unitGUID, unitData in pairs(playerData.Inventory.Units) do
                            if unitData.Name == itemName and unitData.Created then
                                if unitData.Created > newestCreated then
                                    newestCreated = unitData.Created
                                    newestUnit = unitData
                                end
                            end
                        end
                    end
                    
                    local unitDisplayName = itemName
                    if newestUnit and newestUnit.Shiny then
                        unitDisplayName = "[Shiny] " .. itemName
                    end
                    
                    unitCounts[unitDisplayName] = (unitCounts[unitDisplayName] or 0) + 1
                end
            end
        end
        
        for unitName, count in pairs(unitCounts) do
            table.insert(unitsDropped, {name = unitName, count = count})
        end
        
        -- Format rewards
        local rewardsText = ""
        
        if rewardsData then
            if rewardsData.Gems and rewardsData.Gems > 0 then
                rewardsText = rewardsText .. string.format("+%d Gems [%d]\n", rewardsData.Gems, currentGems)
            end
            
            if rewardsData.Gold and rewardsData.Gold > 0 then
                rewardsText = rewardsText .. string.format("+%d Gold [%d]\n", rewardsData.Gold, currentGold)
            end
            
            if #unitsDropped > 0 then
                for _, unitData in ipairs(unitsDropped) do
                    rewardsText = rewardsText .. string.format("+%d %s\n", unitData.count, unitData.name)
                end
            end
            
            for itemName, amount in pairs(rewardsData) do
                if itemName ~= "Gems" and itemName ~= "Gold" and type(amount) == "number" and amount > 0 then
                    local currentTotal = currentItems[itemName] or 0
                    rewardsText = rewardsText .. string.format("+%d %s [%d]\n", amount, itemName, currentTotal)
                end
            end
        end
        
        if rewardsText == "" then
            rewardsText = "No rewards"
        else
            rewardsText = rewardsText:gsub("\n$", "")
        end
        
        local macroText = "None"
        if Macro.isPlaying and Macro.currentName then
            macroText = Macro.currentName
        end
        
        local fields = {
            { name = "Player", value = playerName, inline = true },
            { name = "Duration", value = timeText, inline = true },
            { name = "Macro", value = macroText, inline = true },
            { name = "Rewards", value = rewardsText, inline = false },
        }
        
        local webhookContent = ""
        if shouldPingUser and State.DiscordUserID then
            webhookContent = string.format("<@%s>", State.DiscordUserID)
        end
        
        data = {
            username = "LixHub",
            content = webhookContent,
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
    
    if not data then return end
    
    local payload = Svc.HttpService:JSONEncode(data)
    
    local resp = Util.httpRequest({
        Url = State.WebhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = payload
    })
    
    if resp and (resp.StatusCode == 204 or resp.StatusCode == 200) then
        debugPrint("Webhook sent successfully")
    else
        warn("Webhook failed:", resp and resp.StatusCode or "No response")
    end
end

-- ============================================================
-- GAME TRACKING
-- ============================================================
local function onGameStart()
    State.gameInProgress = true
    State.gameStartTime = tick()
    
    if Macro.isRecording and not Macro.hasStarted then
        Macro.startRecording()
    end
    
    debugPrint("[Game] Started")
end

local function onGameEnd(stageInfo, playerStats, rewards, playerData)
    State.gameInProgress = false
    
    -- Stop recording if active
    if Macro.isRecording and Macro.hasStarted then
        Macro.stopRecording(true)
    end

    if State.SendOnFinish then
     task.spawn(function()
         
         Webhook.send("game_end", stageInfo, playerStats, rewards, playerData)
     end)
end
    
    -- Handle end game actions
    task.spawn(function()
        task.wait(1)
        handleEndGame()
    end)
    
    debugPrint("[Game] Ended")
end

-- Wave tracking
task.spawn(function()
    while true do
        task.wait(0.5)
        
        local success, wave = pcall(function()
            return RS.GameConfig.Wave.Value
        end)
        
        if not success then continue end
        
        -- Game start detection (wave 1)
        if wave == 1 and not State.gameInProgress then
            onGameStart()
        end
    end
end)

-- End game event
pcall(function()
    local stageEndRemote = RS.Remotes.StageEnd
    
    stageEndRemote.OnClientEvent:Connect(function(eventType, stageInfo, playerStats, rewards, playerData)
        if eventType == "ShowResults" then
            onGameEnd(stageInfo, playerStats, rewards, playerData)
        end
    end)
end)

debugPrint("✓ All systems initialized")
-- ============================================================
-- UI TABS
-- ============================================================
local Tabs = {
    Lobby   = Window:CreateTab("Lobby", "tv"),
    Joiner  = Window:CreateTab("Joiner", "plug-zap"),
    Game    = Window:CreateTab("Game", "gamepad-2"),
    Macro   = Window:CreateTab("Macro", "tv"),
    Webhook = Window:CreateTab("Webhook", "bluetooth"),
}

-- Status labels
Macro.statusLabel = Tabs.Macro:CreateLabel("Status: Ready")
Macro.detailLabel = Tabs.Macro:CreateLabel("Detail: -")
Tabs.Macro:CreateDivider()

-- ============================================================
-- LOBBY TAB
-- ============================================================
Tabs.Lobby:CreateButton({
    Name = "Return to Lobby",
    Callback = function()
        Svc.TeleportService:Teleport(76806550943352, LP)
    end,
})

Tabs.Lobby:CreateToggle({
    Name = "Auto Execute Script",
    Flag = "enableAutoExecute",
    Callback = function(v)
        State.enableAutoExecute = v
        if queue_on_teleport then
            queue_on_teleport(v and 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader"))()' or "")
        end
    end,
})

Tabs.Lobby:CreateToggle({
    Name = "Disable Script Notifications",
    Flag = "DisableNotifications",
    Callback = function(v)
        State.DisableNotifications = v
    end,
})

Tabs.Lobby:CreateToggle({
    Name = "Auto Buy Gold Shop",
    Flag = "AutoGoldShop",
    Callback = function(v)
        State.AutoGoldShop = v
    end,
})

local goldShopItemNames = {}
for _, item in ipairs(GOLD_SHOP_ITEMS) do
    table.insert(goldShopItemNames, item.name)
end

Tabs.Lobby:CreateDropdown({
    Name = "Gold Shop Items",
    Options = goldShopItemNames,
    MultipleOptions = true,
    Flag = "GoldShopItems",
    Info = "Items to buy when available",
    Callback = function(opts)
        State.GoldShopItems = {}
        for _, selectedName in ipairs(opts or {}) do
            for _, item in ipairs(GOLD_SHOP_ITEMS) do
                if item.name == selectedName then
                    State.GoldShopItems[item.id] = true
                    break
                end
            end
        end
    end,
})

-- ============================================================
-- JOINER TAB
-- ============================================================

Tabs.Joiner:CreateSlider({
    Name = "Auto Join Delay (seconds)",
    Range = {0, 60},
    Increment = 1,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "AutoJoinDelay",
    Callback = function(v)
        State.AutoJoinDelay = v
        State.AutoJoinDelayStart = nil -- reset if changed mid-wait
    end,
})

Tabs.Joiner:CreateToggle({
    Name = "Auto Join Story",
    Flag = "AutoJoinStory",
    Callback = function(v)
        State.AutoJoinStory = v
    end,
})

local StoryStageDD = Tabs.Joiner:CreateDropdown({
    Name = "Story - Select Stage",
    Options = {},
    Flag = "StoryStage",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        for _, world in pairs(StageData.story) do
            if world.displayName == name then
                State.StoryStage = world.internalName
                break
            end
        end
    end,
})

local StoryActDD = Tabs.Joiner:CreateDropdown({
    Name = "Story - Select Act",
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinite"},
    Flag = "StoryAct",
    Callback = function(selected)
        local opt = type(selected) == "table" and selected[1] or selected
        if opt == "Infinite" then
            State.StoryAct = "Infinite"
        else
            local num = opt:match("%d+")
            if num then State.StoryAct = num end
        end
    end,
})

local StoryDifficultyDD = Tabs.Joiner:CreateDropdown({
    Name = "Story - Select Difficulty",
    Options = {"Normal", "Nightmare"},
    Flag = "StoryDifficulty",
    Callback = function(selected)
        State.StoryDifficulty = type(selected) == "table" and selected[1] or selected
    end,
})

Tabs.Joiner:CreateDivider()

Tabs.Joiner:CreateToggle({
    Name = "Auto Join Legend",
    Flag = "AutoJoinLegend",
    Callback = function(v)
        State.AutoJoinLegend = v
    end,
})

local LegendStageDD = Tabs.Joiner:CreateDropdown({
    Name = "Legend - Select Stage",
    Options = {},
    Flag = "LegendStage",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        for _, world in pairs(StageData.legend) do
            if world.displayName == name then
                State.LegendStage = world.internalName
                break
            end
        end
    end,
})

local LegendActDD = Tabs.Joiner:CreateDropdown({
    Name = "Legend - Select Act",
    Options = {"Act 1", "Act 2", "Act 3"},
    Flag = "LegendAct",
    Callback = function(selected)
        local opt = type(selected) == "table" and selected[1] or selected
        local num = opt:match("%d+")
        if num then State.LegendAct = num end
    end,
})

Tabs.Joiner:CreateDivider()

Tabs.Joiner:CreateToggle({
    Name = "Auto Join Raid",
    Flag = "AutoJoinRaid",
    Callback = function(v)
        State.AutoJoinRaid = v
    end,
})

local RaidStageDD = Tabs.Joiner:CreateDropdown({
    Name = "Raid - Select Stage",
    Options = {},
    Flag = "RaidStage",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        for _, world in pairs(StageData.raid) do
            if world.displayName == name then
                State.RaidStage = world.internalName
                break
            end
        end
    end,
})

local RaidActDD = Tabs.Joiner:CreateDropdown({
    Name = "Raid - Select Act",
    Options = {"Act 1", "Act 2", "Act 3"},
    Flag = "RaidAct",
    Callback = function(selected)
        local opt = type(selected) == "table" and selected[1] or selected
        local num = opt:match("%d+")
        if num then State.RaidAct = num end
    end,
})

Tabs.Joiner:CreateDivider()

Tabs.Joiner:CreateToggle({
    Name = "Auto Join Siege",
    Flag = "AutoJoinSiege",
    Callback = function(v)
        State.AutoJoinSiege = v
    end,
})

local SiegeStageDD = Tabs.Joiner:CreateDropdown({
    Name = "Siege - Select Stage",
    Options = {},
    Flag = "SiegeStage",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        for _, world in pairs(StageData.siege) do
            if world.displayName == name then
                State.SiegeStage = world.internalName
                break
            end
        end
    end,
})

local SiegeActDD = Tabs.Joiner:CreateDropdown({
    Name = "Siege - Select Act",
    Options = {"Act 1"},
    Flag = "SiegeAct",
    Callback = function(selected)
        local opt = type(selected) == "table" and selected[1] or selected
        local num = opt:match("%d+")
        if num then State.SiegeAct = num end
    end,
})

Tabs.Joiner:CreateDivider()

Tabs.Joiner:CreateToggle({
    Name = "Auto Join Portal",
    Flag = "AutoJoinPortal",
    Callback = function(v)
        State.AutoJoinPortal = v
    end,
})

local PortalStageDD = Tabs.Joiner:CreateDropdown({
    Name = "Select Portal",
    Options = {},
    Flag = "PortalStage",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        
        for _, portal in pairs(StageData.portal) do
            if portal.displayName == name then
                State.PortalStage = portal.internalName
                debugPrint(string.format("✓ Selected portal: %s (ID: %s)", name, portal.internalName))
                return
            end
        end
        
        debugPrint(string.format("Portal '%s' not found yet, waiting...", name))
    end,
})

Tabs.Joiner:CreateButton({
    Name = "Refresh Portal List",
    Callback = function()
        if StageData.loadPortals() then
            local portalList = {}
            for _, portal in pairs(StageData.portal) do
                table.insert(portalList, portal.displayName)
            end
            table.sort(portalList)
            
            PortalStageDD:Refresh(portalList)
            debugPrint(string.format("✓ Portal dropdown refreshed with %d portals", #portalList))
        end
    end,
})

Tabs.Joiner:CreateToggle({
    Name = "Auto Next Portal",
    Flag = "AutoNextPortal",
    Info = "Joins the highest level portal you own after completing one",
    Callback = function(v)
        State.AutoNextPortal = v
    end,
})

Tabs.Joiner:CreateDivider()

Tabs.Joiner:CreateToggle({
    Name = "Auto Join Challenge",
    Flag = "AutoJoinChallenge",
    Callback = function(v)
        State.AutoJoinChallenge = v
    end,
})

local ChallengeTypeDD = Tabs.Joiner:CreateDropdown({
    Name = "Challenge Types",
    Options = {"Regular", "Daily", "Weekly"},
    MultipleOptions = true,
    Flag = "ChallengeTypes",
    Info = "Select one or more challenge types to join",
    Callback = function(opts)
        State.ChallengeTypes = {}
        for _, typeName in ipairs(opts or {}) do
            State.ChallengeTypes[typeName] = true
        end
    end,
})

local ChallengeRewardsDD = Tabs.Joiner:CreateDropdown({
    Name = "Filter by Rewards",
    Options = {"Red Essence", "Blue Essence", "Green Essence", "Yellow Essence", "Purple Essence", "Pink Essence", "Rainbow Essence", "Stat Chip", "Super Stat Chip", "Trait Rerolls", "Gold", "Gems"},
    MultipleOptions = true,
    Flag = "ChallengeRewards",
    Info = "Only join challenges with these rewards",
    Callback = function(opts)
        State.ChallengeRewards = opts or {}
    end,
})

local IgnoreWorldsDD = Tabs.Joiner:CreateDropdown({
    Name = "Ignore Worlds",
    Options = {},
    MultipleOptions = true,
    Flag = "IgnoreWorlds",
    Info = "Skip challenges from these worlds",
    Callback = function(opts)
        State.IgnoreWorlds = {}
        
        -- Convert display names to internal names
        for _, displayName in ipairs(opts or {}) do
            for internalName, worldData in pairs(StageData.story) do
                if worldData.displayName == displayName then
                    table.insert(State.IgnoreWorlds, internalName)
                    break
                end
            end
        end
    end,
})

Tabs.Joiner:CreateToggle({
    Name = "Return to Lobby on New Challenge",
    Flag = "ReturnToLobbyOnNew",
    Info = "Returns to lobby when new challenges appear",
    Callback = function(v)
        State.ReturnToLobbyOnNew = v
    end,
})

-- ============================================================
-- GAME TAB
-- ============================================================
Tabs.Game:CreateToggle({
    Name = "Anti-AFK",
    Flag = "AntiAfk",
    Callback = function(v)
        State.AntiAfkEnabled = v
    end,
})

Tabs.Game:CreateToggle({
    Name = "Auto Start Game",
    Flag = "AutoStartGame",
    Callback = function(v)
        State.AutoStartGame = v
    end,
})

Tabs.Game:CreateToggle({
    Name = "Auto Retry",
    Flag = "AutoRetry",
    Callback = function(v)
        State.AutoRetry = v
    end,
})

Tabs.Game:CreateToggle({
    Name = "Auto Next",
    Flag = "AutoNext",
    Callback = function(v)
        State.AutoNext = v
    end,
})

Tabs.Game:CreateToggle({
    Name = "Auto Lobby",
    Flag = "AutoLobby",
    Callback = function(v)
        State.AutoLobby = v
    end,
})

Tabs.Game:CreateToggle({
    Name = "Auto Skip Waves",
    Flag = "AutoSkipWaves",
    Callback = function(v)
        if not Util.isInLobby() then
            pcall(function()
                RS.Remotes.ChangeSetting:FireServer("AutoSkipWaves", v)
            end)
        end
    end,
})

Tabs.Game:CreateToggle({
   Name = "Disable game popups",
   CurrentValue = false,
   Flag = "RemoveGamePopups",
   Callback = function(v)
        if v then
            if not Util.isInLobby() then
                game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("ViewNew"):Destroy()
            end
        end
   end,
})

-- ============================================================
-- MACRO TAB
-- ============================================================
local MacroDD = Tabs.Macro:CreateDropdown({
    Name = "Select Macro",
    Options = {},
    Flag = "MacroDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        Macro.currentName = name
        
        if name and Macro.library[name] then
            Util.notify("Macro Selected", string.format("Selected: %s (%d actions)", name, #Macro.library[name]), 2)
            Macro.setStatus(string.format("Selected: %s", name))
        end
    end,
})

Tabs.Macro:CreateInput({
    Name = "Create New Macro",
    PlaceholderText = "Enter macro name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        
        if cleanedName == "" then
            Util.notify("Invalid Name", "Macro name cannot be empty", 3)
            return
        end
        
        if Macro.library[cleanedName] then
            Util.notify("Duplicate Name", "A macro with this name already exists", 3)
            return
        end
        
        Macro.library[cleanedName] = {}
        Macro.saveToFile(cleanedName)
        
        MacroDD:Refresh(Macro.getNames(), cleanedName)
        Util.notify("Macro Created", "Created macro: " .. cleanedName, 3)
    end,
})

Tabs.Macro:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
     Macro.loadAll()
     MacroDD:Refresh(Macro.getNames())
     
     -- Also refresh auto-select dropdowns
     local macroOptions = {"None"}
     for macroName in pairs(Macro.library) do
         table.insert(macroOptions, macroName)
     end
     table.sort(macroOptions)
     
     for key, dropdown in pairs(AutoSelectDropdowns) do
         if dropdown then
             local currentMapping = Macro.worldMappings[key] or "None"
             dropdown:Refresh(macroOptions, currentMapping)
         end
     end
     
     Util.notify("Refreshed", "Macro list updated", 2)
 end,
})

Tabs.Macro:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if not Macro.currentName or Macro.currentName == "" then
            Util.notify("No Selection", "Please select a macro to delete", 3)
            return
        end
        
        if isfile(Macro.getFilePath(Macro.currentName)) then
            delfile(Macro.getFilePath(Macro.currentName))
        end
        
        Macro.library[Macro.currentName] = nil
        Util.notify("Deleted", "Deleted macro: " .. Macro.currentName, 3)
        
        local list = Macro.getNames()
        
        if #list == 0 then
            Macro.currentName = nil
            MacroDD:Refresh({})
            MacroDD:Set("")
            Macro.setStatus("Ready")
        else
            Macro.currentName = list[1]
            MacroDD:Refresh(list)
            MacroDD:Set(list[1])
            Macro.setStatus("Selected: " .. list[1])
        end
    end,
})

Tabs.Macro:CreateDivider()

local RecordToggle = Tabs.Macro:CreateToggle({
    Name = "Record Macro",
    Flag = "RecordMacro",
    Callback = function(v)
        if v then
            if not Macro.currentName or Macro.currentName == "" then
                Util.notify("Recording Error", "Please select a macro first!")
                return
            end
            
            if not Loadout.loaded then
                Util.notify("Recording Warning", "Loadout not loaded yet", 4)
            end
            
            if not AutoJoin.waitForClient() then
                Util.notify("Recording Warning", "Client data may not be fully loaded", 4)
            end
            
            local currentWave = Util.getWave()
            
            if currentWave >= 1 then
                Macro.isRecording = true
                Macro.hasStarted = true
                State.gameInProgress = true
                Macro.clearTracking()
                Macro.actions = {}
                State.gameStartTime = tick()
                
                Macro.setStatus("Recording from Wave " .. currentWave)
                Macro.setDetail("Recording in progress")
                Util.notify("Recording Started", "Recording from wave " .. currentWave)
            else
                Macro.isRecording = true
                Macro.hasStarted = false
                
                Macro.setStatus("Recording enabled - Starting game...")
                Macro.setDetail("Recording will start at wave 1...")
                Util.notify("Recording Ready", "Recording will start at wave 1")
            end
        else
            if Macro.hasStarted then
                local actionCount = #Macro.actions
                Macro.stopRecording(true)
                Util.notify("Recording Stopped", string.format("Saved %d actions", actionCount))
            else
                Macro.isRecording = false
                Macro.setStatus("Ready")
                Macro.setDetail("Recording cancelled")
            end
        end
    end,
})

local PlaybackToggle = Tabs.Macro:CreateToggle({
    Name = "Playback Macro",
    Flag = "PlaybackMacro",
    Callback = function(v)
        if v then            
            if not Loadout.loaded then
                Util.notify("Playback Error", "Loadout not loaded", 4)
                return
            end
            
            if not AutoJoin.waitForClient() then
                Util.notify("Playback Warning", "Client data may not be fully loaded", 4)
            end
            
            if Macro.loopRunning then
                debugPrint("Playback loop already running")
                return
            end
            
            Macro.isPlaying = true
            Macro.setStatus("Playback Enabled - Starting game...")
            Util.notify("Playback Enabled", "Macro playback enabled")
            
            task.spawn(Macro.autoLoop)
        else
            Macro.isPlaying = false
            Macro.clearTracking()
            
            local timeout = 0
            while Macro.loopRunning and timeout < 20 do
                task.wait(0.1)
                timeout = timeout + 1
            end
            
            if Macro.loopRunning then
                warn("⚠️ Force stopping playback loop")
                Macro.loopRunning = false
            end
            
            Macro.setStatus("Playback Disabled")
            Util.notify("Playback Disabled", "Stopped playback loop")
        end
    end,
})

Tabs.Macro:CreateToggle({
    Name = "Ignore Timing",
    Flag = "IgnoreTiming",
    Info = "Execute placements immediately; abilities still respect timing",
    Callback = function(v)
        State.IgnoreTiming = v
    end,
})

Tabs.Macro:CreateDivider()

Tabs.Macro:CreateButton({
    Name = "Export to Clipboard",
    Callback = function()
        if not Macro.currentName or Macro.currentName == "" then
            Util.notify("Export Error", "No macro selected", 3)
            return
        end
        
        local data = Macro.library[Macro.currentName]
        if not data or #data == 0 then
            Util.notify("Export Error", "Macro is empty", 3)
            return
        end
        
        local fn = setclipboard or toclipboard
        if not fn then
            Util.notify("Clipboard Error", "Not supported by your executor", 3)
            return
        end
        
        fn(Svc.HttpService:JSONEncode(data))
        Util.notify("Exported", Macro.currentName .. " copied to clipboard", 3)
    end,
})

Tabs.Macro:CreateInput({
    Name = "Import Macro",
    PlaceholderText = "Paste JSON or URL...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then return end
        
        -- URL import
        if text:match("^https?://") then
            local requestFunc = Util.httpRequest
            if not requestFunc then
                Util.notify("HTTP Error", "Your executor doesn't support HTTP requests", 3)
                return
            end
            
            Util.notify("Importing", "Downloading from URL...", 2)
            
            local resp = requestFunc({
                Url = text,
                Method = "GET"
            })
            
            if not resp or resp.StatusCode ~= 200 then
                Util.notify("Import Error", "Failed to download from URL", 3)
                return
            end
            
            text = resp.Body
        end
        
        -- JSON import
        local success, decoded = pcall(function()
            return Svc.HttpService:JSONDecode(text)
        end)
        
        if not success then
            Util.notify("Import Error", "Invalid JSON format", 3)
            return
        end
        
        local actions = (type(decoded) == "table" and #decoded > 0) and decoded or nil
        if not actions or #actions == 0 then
            Util.notify("Import Error", "No actions found", 3)
            return
        end
        
        local name = "ImportedMacro_" .. os.time()
        
        Macro.library[name] = actions
        Macro.saveToFile(name)
        Macro.currentName = name
        
        MacroDD:Refresh(Macro.getNames(), name)
        Util.notify("Import Success", string.format("'%s' imported (%d actions)!", name, #actions), 3)
    end,
})

Tabs.Macro:CreateButton({
    Name = "Export via Webhook",
    Callback = function()
        if not Macro.currentName or Macro.currentName == "" then
        Util.notify("Webhook Error", "No macro selected.", 3)
        return
    end
    
    if not State.WebhookURL then
        Util.notify("Webhook Error", "No webhook URL configured.\nSet it in the Webhook tab.", 4)
        return
    end
    
    local macroData = Macro.library[Macro.currentName] or Macro.loadFromFile(Macro.currentName)
    if not macroData or #macroData == 0 then
        Util.notify("Webhook Error", "Selected macro is empty.", 3)
        return
    end
    
    -- Collect unique units and their counts
    local unitCounts = {}
    for _, action in ipairs(macroData) do
        if action.Type == "spawn_unit" and action.Unit then
            local baseUnitName = action.Unit:match("^(.+) #%d+$") or action.Unit
            unitCounts[baseUnitName] = (unitCounts[baseUnitName] or 0) + 1
        end
    end
    
    -- Build sorted units list string
    local unitsList = {}
    for unitName in pairs(unitCounts) do
        table.insert(unitsList, unitName)
    end
    table.sort(unitsList)
    local unitsText = #unitsList > 0 and table.concat(unitsList, ", ") or "None"
    
    -- Encode macro data
    local jsonData = Svc.HttpService:JSONEncode(macroData)
    local fileName = Macro.currentName .. ".json"
    
    -- Build multipart form body
    local boundary = "----LixHubBoundary" .. tostring(math.floor(tick()))
    local CRLF = "\r\n"
    local body = ""
    
    -- Payload JSON part (message content)
    body = body .. "--" .. boundary .. CRLF
    body = body .. "Content-Disposition: form-data; name=\"payload_json\"" .. CRLF
    body = body .. "Content-Type: application/json" .. CRLF .. CRLF
    body = body .. Svc.HttpService:JSONEncode({
        content = string.format("**Macro:** `%s` | **Actions:** %d | **Units:** %s", 
            Macro.currentName, #macroData, unitsText)
    }) .. CRLF
    
    -- File attachment part
    body = body .. "--" .. boundary .. CRLF
    body = body .. string.format("Content-Disposition: form-data; name=\"files[0]\"; filename=\"%s\"", fileName) .. CRLF
    body = body .. "Content-Type: application/json" .. CRLF .. CRLF
    body = body .. jsonData .. CRLF
    
    -- Close boundary
    body = body .. "--" .. boundary .. "--" .. CRLF
    
    -- Send request
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    if not requestFunc then
        Util.notify("Webhook Error", "No HTTP request function available.", 3)
        return
    end
    
    Util.notify("Webhook", "Sending macro...", 2)
    
    local success, result = pcall(function()
        return requestFunc({
            Url = State.WebhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
                ["User-Agent"] = "LixHub-Webhook/1.0"
            },
            Body = body
        })
    end)
    
    if success and result and result.StatusCode and result.StatusCode >= 200 and result.StatusCode < 300 then
        Util.notify("Webhook Success", string.format("'%s' sent! (%d actions)", Macro.currentName, #macroData), 4)
    else
        local code = (result and result.StatusCode) and tostring(result.StatusCode) or "unknown"
        Util.notify("Webhook Error", string.format("Failed to send macro (HTTP %s)", code), 4)
        end
    end,
})

Tabs.Macro:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not Macro.currentName or Macro.currentName == "" then
            Util.notify("No Macro Selected", "Please select a macro first", 3)
            return
        end
        
        local macro = Macro.library[Macro.currentName] or Macro.loadFromFile(Macro.currentName)
        
        if not macro or #macro == 0 then
            Util.notify("Error", "Could not load macro", 3)
            return
        end
        
        -- Collect unique units
        local units = {}
        for _, action in ipairs(macro) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = Macro.getUnitNameFromTag(action.Unit)
                units[unitName] = true
            end
        end
        
        if not next(units) then
            Util.notify("No Units", "This macro doesn't spawn any units", 3)
            return
        end
        
        local unitList = {}
        for name in pairs(units) do
            table.insert(unitList, name)
        end
        table.sort(unitList)
        
        Util.notify("Macro Units", table.concat(unitList, "\n"), 8)
    end,
})

Tabs.Macro:CreateDivider()

local function createAutoSelectUI()
    if autoSelectUICreated then
        debugPrint("Auto-select UI already created, skipping")
        return
    end
    autoSelectUICreated = true
    debugPrint("Creating auto-select UI...")

    local macroOptions = {"None"}
    for macroName in pairs(Macro.library) do
        table.insert(macroOptions, macroName)
    end
    table.sort(macroOptions)

    local collapsibles = {
        Story  = Tabs.Macro:CreateCollapsible({ Name = "Story Auto-Select",  DefaultExpanded = false, Flag = "StoryAutoSelect"  }),
        Legend = Tabs.Macro:CreateCollapsible({ Name = "Legend Auto-Select", DefaultExpanded = false, Flag = "LegendAutoSelect" }),
        Raid   = Tabs.Macro:CreateCollapsible({ Name = "Raid Auto-Select",   DefaultExpanded = false, Flag = "RaidAutoSelect"   }),
        Siege  = Tabs.Macro:CreateCollapsible({ Name = "Siege Auto-Select",  DefaultExpanded = false, Flag = "SiegeAutoSelect"  }),
        Portal = Tabs.Macro:CreateCollapsible({ Name = "Portal Auto-Select", DefaultExpanded = false, Flag = "PortalAutoSelect" }),
    }

    -- Non-portal categories
    local nonPortalCategories = {
        { key = "story",  name = "Story"  },
        { key = "legend", name = "Legend" },
        { key = "raid",   name = "Raid"   },
        { key = "siege",  name = "Siege"  },
    }

    for _, cat in ipairs(nonPortalCategories) do
        local collapsible = collapsibles[cat.name]
        if not collapsible then continue end

        local worldsSeen = {}
        local sortedWorlds = {}
        for internalName, worldData in pairs(StageData[cat.key]) do
            if not worldsSeen[internalName] then
                worldsSeen[internalName] = true
                table.insert(sortedWorlds, { internal = internalName, data = worldData })
            end
        end
        table.sort(sortedWorlds, function(a, b)
            return a.data.displayName < b.data.displayName
        end)

        for _, entry in ipairs(sortedWorlds) do
            local internalName = entry.internal
            local worldData    = entry.data
            local mapKey = string.format("%s_%s", internalName, cat.name)
            local currentMapping = Macro.worldMappings[mapKey] or "None"

            local dropdown = collapsible.Tab:CreateDropdown({
                Name          = worldData.displayName,
                Options       = macroOptions,
                CurrentOption = {currentMapping},
                Flag          = "AutoSelect_" .. mapKey,
                Callback = function(opt)
                    local selected = type(opt) == "table" and opt[1] or opt
                    Macro.worldMappings[mapKey] = (selected == "None") and nil or selected
                    Macro.saveWorldMappings()
                end,
            })

            AutoSelectDropdowns[mapKey] = dropdown
        end
    end

    -- Portal auto-select (hardcoded)
    local portalCollapsible = collapsibles.Portal
    if portalCollapsible then
        for _, portal in ipairs(PORTAL_DISPLAY_NAMES) do
            local currentMapping = Macro.worldMappings[portal.key] or "None"

            local dropdown = portalCollapsible.Tab:CreateDropdown({
                Name          = portal.label,
                Options       = macroOptions,
                CurrentOption = {currentMapping},
                Flag          = "AutoSelect_" .. portal.key,
                Callback = function(opt)
                    local selected = type(opt) == "table" and opt[1] or opt
                    Macro.worldMappings[portal.key] = (selected == "None") and nil or selected
                    Macro.saveWorldMappings()
                    debugPrint(string.format("Portal mapping saved: %s -> %s", portal.key, tostring(selected)))
                end,
            })

            AutoSelectDropdowns[portal.key] = dropdown
        end
    end

    debugPrint("✓ Auto-select UI created")
end

-- ============================================================
-- WEBHOOK TAB
-- ============================================================
Tabs.Webhook:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookURL",
    Callback = function(text)
        State.WebhookURL = text:match("^https://") and text or nil
    end,
})

Tabs.Webhook:CreateInput({
    Name = "Discord User ID",
    PlaceholderText = "Your Discord ID",
    RemoveTextAfterFocusLost = false,
    Flag = "DiscordUserID",
    Callback = function(text)
        State.DiscordUserID = text:match("^%s*(.-)%s*$")
    end,
})

Tabs.Webhook:CreateToggle({
    Name = "Send on Stage Finish",
    Flag = "SendOnFinish",
    Callback = function(v)
        State.SendOnFinish = v
    end,
})

Tabs.Webhook:CreateButton({
    Name = "Test Webhook",
    Callback = function()
     if State.WebhookURL then
         Webhook.send("test")
         Util.notify("Webhook", "Test sent!", 2)
     else
         Util.notify("Error", "No webhook URL set", 3)
     end
 end,
})

-- ============================================================
-- INITIALIZATION
-- ============================================================
Util.ensureFolders()
Macro.loadAll()
MacroDD:Refresh(Macro.getNames())
Macro.loadWorldMappings()
Challenge.init()

task.spawn(function()
    while true do
        task.wait(60)
        if State.AutoJoinChallenge then
            Challenge.checkForNew()
        end
    end
end)

-- Load stage data
task.spawn(function()
    for attempt = 1, 3 do
        if StageData.load() then
            -- Populate story dropdown
            local storyList = {}
            for _, world in pairs(StageData.story) do
                table.insert(storyList, world.displayName)
            end
            table.sort(storyList)
            
            -- Populate legend dropdown
            local legendList = {}
            for _, world in pairs(StageData.legend) do
                table.insert(legendList, world.displayName)
            end
            table.sort(legendList)
            
            -- Populate raid dropdown
            local raidList = {}
            for _, world in pairs(StageData.raid) do
                table.insert(raidList, world.displayName)
            end
            table.sort(raidList)
            
            -- Populate siege dropdown
            local siegeList = {}
            for _, world in pairs(StageData.siege) do
                table.insert(siegeList, world.displayName)
            end
            table.sort(siegeList)
            
            StoryStageDD:Refresh(storyList)
            LegendStageDD:Refresh(legendList)
            RaidStageDD:Refresh(raidList)
            SiegeStageDD:Refresh(siegeList)
            IgnoreWorldsDD:Refresh(storyList)
            
            debugPrint("✓ Stage dropdowns populated")
            
            -- Load portals async
            task.spawn(function()
                task.wait(2)
                if StageData.loadPortals() then
                    local portalList = {}
                    for _, portal in pairs(StageData.portal) do
                        table.insert(portalList, portal.displayName)
                    end
                    table.sort(portalList)
                    
                    PortalStageDD:Refresh(portalList)
                    debugPrint(string.format("✓ Portal dropdown refreshed with %d portals", #portalList))
                    createAutoSelectUI()
                end
            end)
            
            break
        end
        
        warn(string.format("Failed to load stages (attempt %d/3)", attempt))
        task.wait(1)
    end
end)

-- Fetch loadout
task.spawn(function()
    Loadout.fetch()
end)

-- Anti-AFK
LP.Idled:Connect(function()
    if State.AntiAfkEnabled then
        Svc.VirtualUser:Button2Down(Vector2.zero, Svc.Workspace.CurrentCamera.CFrame)
        task.wait(1)
        Svc.VirtualUser:Button2Up(Vector2.zero, Svc.Workspace.CurrentCamera.CFrame)
    end
end)

-- Auto-start game
task.spawn(function()
    while true do
        task.wait(0.5)
        
        if not State.AutoStartGame or Util.isInLobby() then continue end
        
        pcall(function()
            local voteFrame = LP.PlayerGui.GameHUD.VoteSkipFrame
            
            if voteFrame.Visible and voteFrame.TitleLabel.Text == "Vote Start:" then
                debugPrint("Voting to start")
                for _, connection in pairs(getconnections(voteFrame.BTNs.Yes.Activated)) do
                    connection:Fire()
                end
            end
        end)
    end
end)

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image = "eye-off",
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})
