if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 133410800847665 and game.PlaceId ~= 106402284955512 and game.PlaceId ~= 100391355714091 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local script_version = "V0.6"
getgenv().RAYFIELD_SECURE = true
getgenv().RAYFIELD_ASSET_ID = 77799463979503

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Universal Tower Defense",
   Icon = 0,
   LoadingTitle = "Loading for Universal Tower Defense",
   ScriptID = "sid_a20vo45rkxte",   
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
      FileName = "Lixhub_UTD"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = false,
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
local RagnarokTab = Window:CreateTab("Cards", "target")
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
local moddedPlacementEnabled = false
local finishedRewardData = nil
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
local pendingValkPlacement = nil
local pendingValkGUID = nil  -- for playback
local pendingValkCardList = nil
local currentShopOffers = {}

-- ============================================
-- NAMESPACE TABLES
-- ============================================
 
-- Groups utility/helper functions
local Util = {}
-- Groups macro file I/O
local MacroIO = {}
-- Groups unit tracking/GC search
local UnitTracker = {}
-- Groups playback execution
local Playback = {}
-- Groups auto-join logic
local AutoJoin = {}
-- Groups webhook logic
local Webhook = {}
-- Groups path/blessing logic
local PathSystem = {}
-- Groups loader functions (stages, modifiers, etc.)
local Loader = {}
-- Groups game/match state helpers
local GameState = {}

local RagnarokState = {
    AutoPickEnabled = false,
    CardPriorities = {
        ["Quickened Hands"]   = 5,
        ["Spoils of War"]     = 4,
        ["Silence the Gods"]  = 3,
        ["Extended Reach"]    = 2,
        ["Exposed Weakness"]  = 1,
    }
}

local cardNames = {
    "Quickened Hands",
    "Spoils of War",
    "Silence the Gods",
    "Extended Reach",
    "Exposed Weakness",
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
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
}

task.spawn(function()
    task.wait(2)
    pcall(function()
        local SendFinished = Services.ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.WaveService.RE.SendFinished
        SendFinished.OnClientEvent:Connect(function(result, rewards, gameInfo, ...)
            finishedRewardData = { result = result, rewards = rewards, gameInfo = gameInfo }
        end)
    end)
end)

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
    AutoJoinOlympusJudgement = false,
    AutoJoinShinobiAlliance = false,
    AutoJoinRagnarok = false,

    -- Raid
    AutoJoinRaid = false,
    RaidStageSelected = nil,
    RaidActSelected = nil,

    -- Winter Event
    AutoCollectPresents = false,
    AutoJoinWinterEvent = false,
    WinterActSelected = false,
    WinterStageDifficultySelected = false,
    WinterStageDifficultyMeterSelected = 100,

    ShinobiAutoGaaraZone = false,
    ShinobiAutoOpenCoffin = false,
    AutoKuramaHands = false,
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

    local maxRetries = 20
    local retryDelay = 2

local Config = {
    DISCORD_USER_ID = nil,
}

function Util.isInLobby()
    return Services.Workspace:GetAttribute("IsLobby") or false
end

local TowerService = nil
local BlessingService = nil
local RequestData = nil
local ChallengeController = nil
local PodController = nil
local DataController = nil
local PlacedTowerController = nil
local Knit = require(Services.ReplicatedStorage.Packages.knit)

task.spawn(function()
    task.wait(2)
    pcall(function()
        TowerService = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("TowerService"):WaitForChild("RF")
        BlessingService = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("BlessingService"):WaitForChild("RE")
        RequestData = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RF"):WaitForChild("RequestData")
    end)
end)

task.spawn(function()
    task.wait(2)
    ChallengeController = require(game:GetService("ReplicatedStorage").Client.Controllers.ChallengeController)
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        PodController = Knit.GetController("PodController")
    end)
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        DataController = Knit.GetController("DataController")
    end)
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        PlacedTowerController = Knit.GetController("PlacedTowerController")
    end)
end)



-- ============================================
-- LOADOUT MANAGEMENT
-- ============================================

function MacroIO.ensureFolders()
    if not isfolder("LixHub") then makefolder("LixHub") end
    if not isfolder("LixHub/Macros") then makefolder("LixHub/Macros") end
    if not isfolder("LixHub/Macros/UTD") then makefolder("LixHub/Macros/UTD") end
end

function MacroIO.getFilename(name)
    return "LixHub/Macros/UTD/" .. name .. ".json"
end

function MacroIO.save(name, macroData)
    MacroIO.ensureFolders()
    local json = game:GetService("HttpService"):JSONEncode(macroData)
    writefile(MacroIO.getFilename(name), json)
    print(string.format("✓ Saved macro: %s (%d actions)", name, #macroData))
end

function MacroIO.load(name)
    local filePath = MacroIO.getFilename(name)
    if not isfile(filePath) then return nil end
    local json = readfile(filePath)
    return game:GetService("HttpService"):JSONDecode(json)
end

function MacroIO.delete(name)
    local filePath = MacroIO.getFilename(name)
    if isfile(filePath) then delfile(filePath) end
    macroManager[name] = nil
    print(string.format("🗑️ Deleted macro: %s", name))
end

function MacroIO.loadAll()
    MacroIO.ensureFolders()
    macroManager = {}
    local files = listfiles("LixHub/Macros/UTD/")
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            local data = MacroIO.load(name)
            if data then
                macroManager[name] = data
                print(string.format("📂 Loaded macro: %s (%d actions)", name, #data))
            end
        end
    end
end

function MacroIO.getList()
    local list = {}
    for name in pairs(macroManager) do table.insert(list, name) end
    table.sort(list)
    return list
end

function Util.updateMacroStatus(message)
    StatusLabel:Set("Status: " .. message)
end

function Util.updateDetailedStatus(message)
    DetailLabel:Set(message)
end

function Util.cleanUnitName(unitName)
    return unitName:gsub(":[Ss]hiny", "")
end

function UnitTracker.getPlayerLoadout()
    local loadout = {}
    local success = pcall(function()
        local EquippedUnits = game:GetService("HttpService"):JSONDecode(game:GetService("Players").LocalPlayer:WaitForChild("Equipped").Value)

        for slot, unitGUID in pairs(EquippedUnits) do
            if unitGUID and unitGUID ~= "" then
                local inventoryData = DataController:GetUnitData(unitGUID)
                if inventoryData and inventoryData.UnitId then
                    loadout[slot] = Util.cleanUnitName(inventoryData.UnitId)
                end
            end
        end
    end)
    if not success then warn("Failed to get player loadout") end
    return loadout
end

function UnitTracker.getSlotForUnit(unitName)
    local loadout = UnitTracker.getPlayerLoadout()
    local cleanSearchName = Util.cleanUnitName(unitName)
    for slot, name in pairs(loadout) do
        if Util.cleanUnitName(name) == cleanSearchName then return slot end
    end
    return nil
end

function UnitTracker.getUnitData(unitName)
    local cleanName = Util.cleanUnitName(unitName)
    local success, result = pcall(function()
        local module = game:GetService("ReplicatedStorage").Shared.Data.Towers:FindFirstChild(cleanName)
        if not module then return nil end
        if module:IsA("ModuleScript") then
            local required = require(module)
            if type(required) == "function" then return required() end
            return required
        end
        return nil
    end)
    if success and result then return result end
    warn(string.format(" Could not find unit data for: %s", unitName))
    return nil
end

-- ============================================
-- UNIT TRACKING
-- ============================================

function UnitTracker.getByUUID(uuid)
    local unitsFolder = workspace:FindFirstChild("Ignore")
    if unitsFolder then unitsFolder = unitsFolder:FindFirstChild("Units") end
    if not unitsFolder then return nil end
    return unitsFolder:FindFirstChild(uuid)
end

function UnitTracker.findNewInGC(unitName, excludeUUIDs)
    excludeUUIDs = excludeUUIDs or {}
    local cleanedUnitName = Util.cleanUnitName(unitName)
    local candidates = {}

    local unitsFolder = workspace:FindFirstChild("Ignore") and workspace.Ignore:FindFirstChild("Units")
    if not unitsFolder then
        warn("Units folder not found")
        return nil, nil
    end

    for _, unit in pairs(unitsFolder:GetChildren()) do
        local uuid = unit.Name
        if excludeUUIDs[uuid] then continue end

        local unitClass = PlacedTowerController:GetUnitClass(uuid)
        if not unitClass then continue end

        local towerId = rawget(unitClass, "TowerID") or rawget(unitClass, "UnitId") or ""
        local unitDisplayName = rawget(unitClass, "Name") or ""
        local cleanTowerId = Util.cleanUnitName(towerId)
        local cleanDisplayName = Util.cleanUnitName(unitDisplayName)

        if cleanTowerId == cleanedUnitName or cleanDisplayName:lower() == cleanedUnitName:lower() then
            table.insert(candidates, {
                uuid = uuid,
                unitName = towerId,
                upgrade = rawget(unitClass, "Upgrade") or 1
            })
        end
    end

    if #candidates == 0 then
        warn(string.format("No new units found for: %s", unitName))
        return nil, nil
    end

    table.sort(candidates, function(a, b)
        return a.upgrade < b.upgrade
    end)

    return candidates[1].uuid, candidates[1].unitName
end

local unitChangeListeners = {}

function UnitTracker.findDataInGC(uuid)
    local success, result = pcall(function()
        local unitClass = PlacedTowerController:GetUnitClass(uuid)
        if not unitClass then return nil end

        return {
            GUID    = rawget(unitClass, "GUID"),
            UnitId  = rawget(unitClass, "TowerID") or rawget(unitClass, "UnitId"),
            Upgrade = rawget(unitClass, "Upgrade") or 1,
            Model   = rawget(unitClass, "Model")
        }
    end)

    if success and result then return result end
    warn("Could not find unit data for UUID: " .. tostring(uuid))
    return nil
end

function UnitTracker.startTracking(uuid, unitTag, unitName)
    local unit = UnitTracker.getByUUID(uuid)
    if not unit then return end
    local unitData = UnitTracker.findDataInGC(uuid)
    if unitData then
        unitChangeListeners[uuid] = { data = unitData, unitTag = unitTag, lastUpgradeLevel = unitData.Upgrade or 1 }
    else
        unitChangeListeners[uuid] = { unitTag = unitTag }
    end
end

function UnitTracker.stopTracking(uuid)
    if unitChangeListeners[uuid] then
        unitChangeListeners[uuid] = nil
    end
end

local upgradeCheckThread = nil

function UnitTracker.startUpgradePolling()
    if upgradeCheckThread then return end
    upgradeCheckThread = task.spawn(function()
        while isRecording and recordingHasStarted do
            task.wait(0.5)
            for uuid, listener in pairs(unitChangeListeners) do
                if type(listener) == "table" and listener.data then
                    local currentLevel = listener.data.Upgrade
                    local lastLevel = listener.lastUpgradeLevel
                    if currentLevel and lastLevel and currentLevel > lastLevel then
                        listener.lastUpgradeLevel = currentLevel
                    end
                end
            end
        end
        upgradeCheckThread = nil
    end)
end

function UnitTracker.stopUpgradePolling()
    if upgradeCheckThread then
        task.cancel(upgradeCheckThread)
        upgradeCheckThread = nil
    end
end

function Util.getUnitNameFromTag(unitTag)
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
    
    local results = {originalNamecall(self, table.unpack(args))}
    
    if not checkcaller() and isRecording and recordingHasStarted then
        task.spawn(function()
            local timestamp = tick()
            local gameRelativeTime = timestamp - gameStartTime

            if method == "InvokeServer" and self.Name == "PlaceUnit" then
            local result = results[1]
            local message = results[2]
            if result == true then
                local slot = args[1]
                local cframe = args[2]

                -- Try secondary slot units first (Ragnarok overrides normal loadout)
                local unitName = nil
                local success, secondaryUnits = pcall(function()
                    return TowerService:WaitForChild("GetSecondarySlotUnits"):InvokeServer()
                end)
                if success and secondaryUnits and type(secondaryUnits) == "table" and #secondaryUnits > 0 then
                    local slotData = secondaryUnits[slot]
                    if slotData and slotData.unitId then
                        unitName = Util.cleanUnitName(slotData.unitId)
                    end
                end

                -- Fall back to normal loadout if secondary slots empty or slot not found
                if not unitName then
                    local loadout = UnitTracker.getPlayerLoadout()
                    unitName = loadout[slot]
                end

                if not unitName then
                    warn("Could not determine unit name for slot", slot)
                    return
                end

                task.wait(0.5)
                local excludeUUIDs = {}
                for uuid, _ in pairs(recordingUUIDToTag) do excludeUUIDs[uuid] = true end
                local uuid, detectedName = nil, nil
                for attempt = 1, 10 do
                    uuid, detectedName = UnitTracker.findNewInGC(unitName, excludeUUIDs)
                    if uuid then break end
                    task.wait(0.3)
                end
                if uuid then
                    local cleanName = Util.cleanUnitName(unitName)
                    local unit = UnitTracker.getByUUID(uuid)
                    if not unit then
                        warn(string.format("UUID %s found in GC but not in workspace!", uuid))
                        return
                    end
                    recordingUnitCounter[cleanName] = (recordingUnitCounter[cleanName] or 0) + 1
                    local unitNumber = recordingUnitCounter[cleanName]
                    local unitTag = string.format("%s #%d", cleanName, unitNumber)
                    recordingUUIDToTag[uuid] = unitTag
                    table.insert(macro, {
                        Type = "spawn_unit", Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime),
                        Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z}
                    })
                    UnitTracker.startTracking(uuid, unitTag, unitName)
                    print(string.format("Recorded: %s (UUID=%s)", unitTag, uuid))
                else
                    warn("Failed to find placed unit in GC!")
                end
            else
                warn(string.format("Skipped placement: %s", tostring(message)))
            end

            elseif method == "InvokeServer" and self.Name == "UpgradeUnit" then
                local result = results[1]
                local message = results[2]
                local uuid = args[1]
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then warn("Upgrade detected for untracked unit:", uuid) return end
                if result == true then
                    table.insert(macro, {
                        Type = "upgrade_unit",
                        Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                    print(string.format("Recorded upgrade: %s (%s)", unitTag, tostring(message)))
                else
                    warn(string.format("Skipped upgrade for %s: %s", unitTag, tostring(message)))
                end

            elseif method == "InvokeServer" and self.Name == "SellUnit" then
                local result = results[1]
                local message = results[2]
                local uuid = args[1]
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then return end
                if result == true then
                    table.insert(macro, {
                        Type = "sell_unit",
                        Unit = unitTag,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                    UnitTracker.stopTracking(uuid)
                    recordingUUIDToTag[uuid] = nil
                else
                    warn(string.format("Skipped sell for %s: %s", unitTag, tostring(message)))
                end

            elseif method == "FireServer" and self.Name == "UseAbility" then
                local uuid = args[1]
                local abilitySlot = args[2]
                local unitTag = recordingUUIDToTag[uuid]
                if not unitTag then warn("Ability used for untracked unit:", uuid) return end
                table.insert(macro, {
                    Type = "use_ability",
                    Unit = unitTag,
                    AbilitySlot = abilitySlot,
                    Time = string.format("%.2f", gameRelativeTime)
                })
                elseif method == "InvokeServer" and self.Name == "CommitSpecialPlacement" then
                local result = results[1]
                local placementKey = args[1]  -- the GUID key
                local cframe = args[2]
                if result == true then
                    -- Find the pending valk name we stored when BeginSpecialPlacement fired
                    local valkName = pendingValkPlacement and pendingValkPlacement.valkName
                    if valkName then
                        table.insert(macro, {
                            Type = "place_valkyrie",
                            ValkName = valkName,
                            Time = string.format("%.2f", gameRelativeTime),
                            Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z}
                        })
                        print(string.format("Recorded Valkyrie placement: %s", valkName))
                        pendingValkPlacement = nil
                    end
                end
                elseif method == "FireServer" and self.Name == "VoteCard" then
            local channel = args[1]
            local cardIndex = args[2]
            if channel == "RagnarokValkyrie" and isRecording and recordingHasStarted then
                local valkName = pendingValkCardList and pendingValkCardList[cardIndex] and pendingValkCardList[cardIndex].id
                if valkName then
                    table.insert(macro, {
                        Type = "pick_valkyrie",
                        ValkName = valkName,
                        Time = string.format("%.2f", gameRelativeTime),
                    })
                    print(string.format("Recorded Valkyrie pick: %s", valkName))
                end
            end
            elseif method == "InvokeServer" and self.Name == "Purchase" then
                local result = results[1]
                local shopId = args[1]      -- "Ragnarok"
                local itemId = args[2]      -- "RShop_ValkCard_Reginleif_RangeAura"
                if result then
                    table.insert(macro, {
                        Type = "shop_purchase",
                        ShopId = shopId,
                        ItemId = itemId,
                        Time = string.format("%.2f", gameRelativeTime),
                    })
                    print(string.format("Recorded shop purchase: %s / %s", shopId, itemId))
                end
            end
        end)
    end

    return table.unpack(results)
end)

mt.__namecall = generalHook
setreadonly(mt, true)

task.spawn(function()
    task.wait(2)
    pcall(function()
        local TowerServiceRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.TowerService.RE
        local CardChoiceServiceRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CardChoiceService.RE

        -- Captures the GUID + valk name when placement begins
        TowerServiceRE.BeginSpecialPlacement.OnClientEvent:Connect(function(guid, valkId, options)
            if options and options.placementPurpose == "RagnarokValkyrie" then
                -- For recording: store pending placement info
                pendingValkPlacement = { guid = guid, valkName = valkId }
                -- For playback: store the live GUID so playback can use it
                pendingValkGUID = guid
                print(string.format("BeginSpecialPlacement: %s (GUID: %s)", valkId, guid))
            end
        end)

        TowerServiceRE.EndSpecialPlacement.OnClientEvent:Connect(function(guid, status)
            if status == "Placed" then
                pendingValkGUID = nil
            end
        end)
    end)
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        local MatchShopRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.MatchShopService.RE
        MatchShopRE.ShopStateChanged.OnClientEvent:Connect(function(shopId, shopState)
            if not shopState or not shopState.offers then return end
            for _, offer in ipairs(shopState.offers) do
                if offer.type == "ValkCard" and offer.id then
                    currentShopOffers[offer.id] = { cost = offer.cost, meta = offer.meta }
                end
            end
        end)
    end)
end)

-- ============================================
-- PLAYBACK EXECUTION
-- ============================================

function Util.getPlayerMoney()
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

function Playback.waitForMoney(requiredAmount, actionDescription)
    local currentMoney = Util.getPlayerMoney()
    if not currentMoney then return true end
    if currentMoney >= requiredAmount then return true end
    local lastUpdateTime = tick()
    while true do
        local matchFinished = workspace:GetAttribute("MatchFinished")
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            print("⚠️ Game ended while waiting for money - aborting wait")
            return false
        end
        task.wait(1)
        currentMoney = Util.getPlayerMoney()
        if not currentMoney then return true end
        if currentMoney >= requiredAmount then return true end
        if tick() - lastUpdateTime >= 1 then
            Util.updateDetailedStatus(string.format("Waiting: ¥%d / ¥%d (%s)", currentMoney, requiredAmount, actionDescription))
            lastUpdateTime = tick()
        end
    end
end

function Playback.executePlacement(action, actionIndex, totalActions)
    local unitName = Util.getUnitNameFromTag(action.Unit)
    local cleanName = Util.cleanUnitName(unitName)
    Util.updateMacroStatus(string.format("(%d/%d) Placing %s", actionIndex, totalActions, action.Unit))
    local unitData = UnitTracker.getUnitData(cleanName)
    local placementCost = 0
    if unitData and unitData.Stats and unitData.Stats.Upgrades and #unitData.Stats.Upgrades > 0 then
        placementCost = unitData.Stats.Upgrades[1].Cost or 0
    end
    if placementCost > 0 then
        local currentMoney = Util.getPlayerMoney()
        if currentMoney and currentMoney < placementCost then
            Util.updateDetailedStatus(string.format("Waiting for ¥%d to place %s", placementCost, action.Unit))
        end
        local canContinue = Playback.waitForMoney(placementCost, cleanName)
        if not canContinue then
            Util.updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    local slot = nil
    local success, secondaryUnits = pcall(function()
    return TowerService:WaitForChild("GetSecondarySlotUnits"):InvokeServer()
end)
if success and secondaryUnits and type(secondaryUnits) == "table" and #secondaryUnits > 0 then
    for i, slotData in ipairs(secondaryUnits) do
        if slotData and slotData.unitId then
            local cleanSlotUnit = Util.cleanUnitName(slotData.unitId)
            if cleanSlotUnit == cleanName then
                slot = i
                break
            end
        end
    end
end
if not slot then
    slot = UnitTracker.getSlotForUnit(cleanName)
end

if not slot then
    Util.updateDetailedStatus(string.format("Error: %s not in loadout", cleanName))
    return false
end
    Util.updateDetailedStatus(string.format("Placing %s...", action.Unit))
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    local success = pcall(function()
        TowerService:WaitForChild("PlaceUnit"):InvokeServer(slot, cframe)
    end)
    if not success then
        Util.updateDetailedStatus("Placement failed")
        return false
    end
    task.wait(0.5)
    local excludeUUIDs = {}
    for _, mappedUUID in pairs(playbackUnitTagToUUID) do excludeUUIDs[mappedUUID] = true end
    local uuid = nil
    for attempt = 1, 10 do
        uuid = UnitTracker.findNewInGC(cleanName, excludeUUIDs)
        if uuid then break end
        task.wait(0.3)
    end
    if uuid then
        local unit = UnitTracker.getByUUID(uuid)
        if not unit then
            Util.updateDetailedStatus("Unit not found in workspace")
            return false
        end
        playbackUnitTagToUUID[action.Unit] = uuid
        Util.updateDetailedStatus(string.format("Placed %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Failed to detect placed unit")
    return false
end

function Playback.executeUpgrade(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Upgrading %s", actionIndex, totalActions, action.Unit))
    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid or type(uuid) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: Invalid UUID for %s", action.Unit))
        return false
    end
    local upgradeCost = 0
    local currentLevel = 1
    local unitData = UnitTracker.findDataInGC(uuid)
    if unitData then
        currentLevel = unitData.Upgrade or 1
        local unitName = unitData.UnitId or unitData.TowerID or action.Unit
        local towerData = UnitTracker.getUnitData(unitName)
        if towerData and towerData.Stats and towerData.Stats.Upgrades then
            local nextUpgrade = towerData.Stats.Upgrades[currentLevel + 1]
            if nextUpgrade and nextUpgrade.Cost then
                upgradeCost = nextUpgrade.Cost
            end
        end
    end
    if upgradeCost > 0 then
        local currentMoney = Util.getPlayerMoney()
        if currentMoney and currentMoney < upgradeCost then
            Util.updateDetailedStatus(string.format("Waiting for ¥%d to upgrade %s", upgradeCost, action.Unit))
        end
        local canContinue = Playback.waitForMoney(upgradeCost, string.format("%s upgrade", action.Unit))
        if not canContinue then
            Util.updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end
    Util.updateDetailedStatus(string.format("Upgrading %s (Lv%d→%d)...", action.Unit, currentLevel, currentLevel + 1))
    local success = pcall(function()
        TowerService:WaitForChild("UpgradeUnit"):InvokeServer(uuid)
    end)
    if success then
        Util.updateDetailedStatus(string.format("Upgraded %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Upgrade failed")
    return false
end

function Playback.executeSell(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Selling %s", actionIndex, totalActions, action.Unit))
    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid then
        Util.updateDetailedStatus(string.format("Error: No UUID for %s", action.Unit))
        return false
    end
    Util.updateDetailedStatus(string.format("Selling %s...", action.Unit))
    local success = pcall(function()
        TowerService:WaitForChild("SellUnit"):InvokeServer(uuid)
    end)
    if success then
        playbackUnitTagToUUID[action.Unit] = nil
        Util.updateDetailedStatus(string.format("Sold %s ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Sell failed")
    return false
end
 
function Playback.executeAbility(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Using %s ability", actionIndex, totalActions, action.Unit))
    local uuid = playbackUnitTagToUUID[action.Unit]
    if not uuid or type(uuid) ~= "string" then
        Util.updateDetailedStatus(string.format("Error: Invalid UUID for %s", action.Unit))
        return false
    end
    Util.updateDetailedStatus(string.format("Using %s ability (Slot %d)...", action.Unit, action.AbilitySlot))
    local success = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0")
            :WaitForChild("knit"):WaitForChild("Services"):WaitForChild("TowerService")
            :WaitForChild("RE"):WaitForChild("UseAbility"):FireServer(uuid, action.AbilitySlot)
    end)
    if success then
        Util.updateDetailedStatus(string.format("Used %s ability ✓", action.Unit))
        return true
    end
    Util.updateDetailedStatus("Ability use failed")
    return false
end

function Playback.executePickValkyrie(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Picking Valkyrie: %s", actionIndex, totalActions, action.ValkName))
    
    -- Wait for the card event and match by name
    local CardChoiceServiceRE = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CardChoiceService.RE
    
    -- Poll for up to 15s for the card selection to appear
    local cardIndex = nil
    local deadline = tick() + 15
    local connection
    connection = CardChoiceServiceRE.GetNewCards.OnClientEvent:Connect(function(channel, cards, config)
        if channel ~= "RagnarokValkyrie" then return end
        for i, card in ipairs(cards) do
            if card.id == action.ValkName or card.name == action.ValkName then
                cardIndex = i
                break
            end
        end
    end)
    
    while not cardIndex and tick() < deadline do
        task.wait(0.5)
        if not isPlaybackEnabled or not gameInProgress then
            connection:Disconnect()
            return false
        end
    end
    connection:Disconnect()
    
    if not cardIndex then
        Util.updateDetailedStatus(string.format("Valkyrie card not found: %s", action.ValkName))
        return false
    end
    
    task.wait(0.5)
    local success = pcall(function()
        CardChoiceServiceRE.VoteCard:FireServer("RagnarokValkyrie", cardIndex)
    end)
    
    if success then
        Util.updateDetailedStatus(string.format("Picked Valkyrie: %s ✓", action.ValkName))
        Rayfield:Notify({ Title = "Valkyrie Picked", Content = action.ValkName, Duration = 3 })
        return true
    end
    Util.updateDetailedStatus("Valkyrie pick failed")
    return false
end

function Playback.executePlaceValkyrie(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Placing Valkyrie: %s", actionIndex, totalActions, action.ValkName))
    
    local TowerServiceRF = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.TowerService.RF
    
    -- Wait for BeginSpecialPlacement to give us the live GUID
    local guid = nil
    local deadline = tick() + 15
    while not pendingValkGUID and tick() < deadline do
        task.wait(0.5)
        if not isPlaybackEnabled or not gameInProgress then return false end
    end
    guid = pendingValkGUID
    
    if not guid then
        Util.updateDetailedStatus("No GUID received for Valkyrie placement")
        return false
    end
    
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    
    local success = pcall(function()
        TowerServiceRF.CommitSpecialPlacement:InvokeServer(guid, cframe)
    end)
    
    if success then
        pendingValkGUID = nil
        Util.updateDetailedStatus(string.format("Placed Valkyrie: %s ✓", action.ValkName))
        Rayfield:Notify({ Title = "Valkyrie Placed", Content = action.ValkName, Duration = 3 })
        return true
    end
    Util.updateDetailedStatus("Valkyrie placement failed")
    return false
end

function Playback.executeShopPurchase(action, actionIndex, totalActions)
    Util.updateMacroStatus(string.format("(%d/%d) Purchasing: %s", actionIndex, totalActions, action.ItemId))
    
    local offerData = currentShopOffers[action.ItemId]
    if offerData and offerData.cost and offerData.cost > 0 then
        local currentMoney = Util.getPlayerMoney()
        if currentMoney and currentMoney < offerData.cost then
            Util.updateDetailedStatus(string.format("Waiting for ¥%d to purchase %s", offerData.cost, action.ItemId))
        end
        local canContinue = Playback.waitForMoney(offerData.cost, action.ItemId)
        if not canContinue then
            Util.updateDetailedStatus("Game ended while waiting for money")
            return false
        end
    end

    local success = pcall(function()
        local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.MatchShopService.RF.Purchase
        Event:InvokeServer(action.ShopId, action.ItemId)
    end)
    if success then
        Util.updateDetailedStatus(string.format("Purchased %s ✓", action.ItemId))
        return true
    end
    Util.updateDetailedStatus("Purchase failed")
    return false
end

-- ============================================
-- CLEANUP FUNCTIONS
-- ============================================

function UnitTracker.clearSpawnIdMappings()
    playbackUnitTagToUUID = {}
    recordingUnitCounter = {}
    recordingUUIDToTag = {}
    for uuid, connection in pairs(unitChangeListeners) do
        pcall(function() connection:Disconnect() end)
    end
    unitChangeListeners = {}
end

function GameState.startRecording()
    if isRecording then return end
    macro = {}
    UnitTracker.clearSpawnIdMappings()
    isRecording = true
    recordingHasStarted = true
    gameStartTime = tick()
    UnitTracker.startUpgradePolling()
    Util.updateMacroStatus("Recording...")
end

function GameState.stopRecording()
    if not isRecording then return end
    isRecording = false
    recordingHasStarted = false
    local actionCount = #macro
    if currentMacroName and currentMacroName ~= "" then
        macroManager[currentMacroName] = macro
        MacroIO.save(currentMacroName, macro)
        Util.updateMacroStatus(string.format("Saved %d actions to %s", actionCount, currentMacroName))
    else
        Util.updateMacroStatus(string.format("Recording stopped (%d actions)", actionCount))
    end
    return macro
end

function MacroIO.savePathPriorities()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local fileName = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    local json = game:GetService("HttpService"):JSONEncode(PathState.BlessingPriorities)
    writefile(fileName, json)
end

-- Function to load path priorities from file
function MacroIO.loadPathPriorities()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local filePath = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    if not isfile(filePath) then return {} end
    local json = readfile(filePath)
    local data = game:GetService("HttpService"):JSONDecode(json)
    print("✓ Loaded path priorities")
    return data or {}
end

function PathSystem.getCardOptions()
    local cards = {}
    local success = pcall(function()
        local cardsFolder = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Paths.PathSelection.Cards
        local frameChildren = {}
        for _, child in ipairs(cardsFolder:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("^Card") then
                table.insert(frameChildren, child)
            end
        end
        table.sort(frameChildren, function(a, b)
            if a.LayoutOrder ~= b.LayoutOrder then return a.LayoutOrder < b.LayoutOrder end
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)
        for cardIndex, cardFrame in ipairs(frameChildren) do
            local titleLabel = cardFrame:FindFirstChild("Title")
            local topTitleLabel = cardFrame:FindFirstChild("TopTitle")
            if titleLabel and topTitleLabel then
                local uiBlessingName = titleLabel.Text
                local uiCleanName = uiBlessingName:gsub("[^%w]", ""):lower()
                local matchedKey = nil
                local highestPriority = 0
                for sliderKey, priority in pairs(PathState.BlessingPriorities) do
                    local cleanSliderKey = sliderKey:lower()
                    if uiCleanName:find(cleanSliderKey, 1, true) then
                        if priority > highestPriority then
                            matchedKey = sliderKey
                            highestPriority = priority
                        end
                    end
                end
                if not matchedKey then
                    matchedKey = uiBlessingName:gsub("[^%w]", "")
                    if not PathState.BlessingPriorities[matchedKey] then
                        PathState.BlessingPriorities[matchedKey] = 0
                    end
                    highestPriority = 0
                end
                table.insert(cards, { index = cardIndex, blessingName = uiBlessingName, pathName = "", sliderKey = matchedKey, priority = highestPriority })
            end
        end
    end)
    if not success then warn("Failed to get card options") return {} end
    return cards
end

function PathSystem.selectBestCard()
    if not BlessingService then warn("BlessingService not initialized") return false end
    local cards = PathSystem.getCardOptions()
    if #cards == 0 then warn("No cards found") return false end
    table.sort(cards, function(a, b) return a.priority > b.priority end)
    local bestCard = cards[1]
    local remoteName = #cards >= 5 and "GetNewPath" or "GetNewBlessing"
    local remoteType = #cards >= 5 and "Path" or "Blessing"
    local success = pcall(function()
        BlessingService:WaitForChild(remoteName):FireServer(bestCard.index)
    end)
    if success then
        Rayfield:Notify({ Title = "Auto " .. remoteType, Content = string.format("Selected: %s", bestCard.blessingName), Duration = 3 })
        return true
    end
    warn(string.format("Failed to select card via %s", remoteName))
    return false
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoSelectPath then
            if not BlessingService then
                local timeout = 0
                while not BlessingService and timeout < 20 do task.wait(0.5) timeout = timeout + 1 end
                if not BlessingService then continue end
            end
            local pathsUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("GameUI")
            if pathsUI then
                pathsUI = pathsUI:FindFirstChild("Paths")
                if pathsUI and pathsUI.Enabled then
                    task.wait(0.5)
                    PathSystem.selectBestCard()
                    task.wait(1)
                end
            end
        end
    end
end)

function Util.deepCopy(tbl, seen)
    if type(tbl) ~= "table" then return tbl end
    seen = seen or {}
    if seen[tbl] then return seen[tbl] end
    local copy = {}
    seen[tbl] = copy
    for k, v in pairs(tbl) do copy[k] = Util.deepCopy(v, seen) end
    return copy
end

function Util.isTrackedPath(path)
    return
        path:match("^Currency%.") or
        path == "Battlepass.PassEXP" or
        path == "Stats.Experience" or
        path:match("^Relics%.[^%.]+$") or
        path:match("^Units%.Inventory%.%[.+%]$") or
        path:match("^Items%.CraftingItems") or
        path:match("^Items%.UniqueItems")
end

function Webhook.getRewards(before, after, path)
    path = path or ""
    local rewards = {}
    for k, afterVal in pairs(after) do
        local beforeVal = before and before[k]
        local currentPath = path == "" and tostring(k) or path .. "." .. tostring(k)
        if not Util.isTrackedPath(currentPath) then
            if type(afterVal) == "table" and type(beforeVal) == "table" then
                local nestedRewards = Webhook.getRewards(beforeVal, afterVal, currentPath)
                for rewardKey, rewardVal in pairs(nestedRewards) do
                    rewards[rewardKey] = (rewards[rewardKey] or 0) + rewardVal
                end
            end
            continue
        end
        if beforeVal == nil then
            if type(afterVal) == "table" then
                if afterVal.ID and afterVal.Type and afterVal.Rarity then
                    local rewardKey = string.format("%s (%s) (%s)", afterVal.ID, afterVal.Type, afterVal.Rarity)
                    rewards[rewardKey] = (rewards[rewardKey] or 0) + 1
                elseif afterVal.UnitId then
                    local rewardKey = string.format("🎉 NEW UNIT: %s", afterVal.UnitId)
                    rewards[rewardKey] = (rewards[rewardKey] or 0) + 1
                    rewards["__UNIT_DROP__"] = true
                end
            end
        elseif type(afterVal) == "number" and beforeVal == nil then
            local itemName = currentPath:match("%.([^%.]+)$") or currentPath
            if currentPath:match("CraftingItems%.") then
                rewards["Crafting: " .. itemName] = (rewards["Crafting: " .. itemName] or 0) + afterVal
            elseif currentPath:match("UniqueItems%.") then
                rewards["Unique: " .. itemName] = (rewards["Unique: " .. itemName] or 0) + afterVal
            end
        elseif type(afterVal) == "number" and type(beforeVal) == "number" then
            local delta = afterVal - beforeVal
            if delta ~= 0 then
                local rewardName = currentPath:match("%.([^%.]+)$") or currentPath
                if rewardName == "PassEXP" then rewardName = "Battlepass XP"
                elseif rewardName == "Experience" then rewardName = "XP" end
                rewards[rewardName] = (rewards[rewardName] or 0) + delta
            end
        elseif type(afterVal) == "table" and type(beforeVal) == "table" then
            local nestedRewards = Webhook.getRewards(beforeVal, afterVal, currentPath)
            for rewardKey, rewardVal in pairs(nestedRewards) do
                rewards[rewardKey] = (rewards[rewardKey] or 0) + rewardVal
            end
        end
    end
    return rewards
end

function Webhook.send(messageType, gameResult, gameInfo, gameDuration, waveReached)
    if not ValidWebhook or ValidWebhook == "" then return end
    local data
    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or ""),
            embeds = {{ title = "LixHub Notification", description = "Test webhook sent successfully", color = 0x5865F2, footer = { text = "discord.gg/cYKnXE2Nf8" }, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") }}
        }
    elseif messageType == "game_end" then
        local rewards = {}
        local hasUnitDrop = false
        if finishedRewardData and finishedRewardData.rewards then
            local rewardData = finishedRewardData.rewards
            for rewardKey, rewardValue in pairs(rewardData) do
                if type(rewardValue) == "number" and rewardValue > 0 then
                    local friendlyName = rewardKey
                    if rewardKey == "Experience" then friendlyName = "XP"
                    elseif rewardKey == "SpiritSouls" then friendlyName = "Spirit Souls" end
                    rewards[friendlyName] = rewardValue
                elseif type(rewardValue) == "table" and rewardKey == "Relics" then
                    for relicKey, relicData in pairs(rewardValue) do
                        local relicName = (relicKey:match("^[^:]+:(.+)$") or relicKey):gsub("^%d+Star_", "")
                        local displayName = string.format("%s (%s)", relicName, relicData.Rarity)
                        if relicData.Stars then displayName = displayName .. string.format(" ⭐%d", relicData.Stars) end
                        rewards[displayName] = relicData.Amount or 1
                    end
                elseif type(rewardValue) == "table" and rewardKey == "Unit" then
                    if rewardValue.Unit and rewardValue.Rarity then
                        hasUnitDrop = true
                        rewards[string.format("[%s] %s", rewardValue.Rarity, rewardValue.Unit)] = 1
                    end
                end
            end
        else
            if beforeRewardData and afterRewardData then
                rewards = Webhook.getRewards(beforeRewardData, afterRewardData)
                hasUnitDrop = rewards["__UNIT_DROP__"]
                rewards["__UNIT_DROP__"] = nil
            end
        end
        finishedRewardData = nil
        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        local rewardsText = ""
        if next(rewards) then
            for rewardType, amount in pairs(rewards) do
                rewardsText = rewardsText .. string.format("+%s %s\n", amount, rewardType)
            end
            rewardsText = rewardsText:gsub("\n$", "")
        else
            rewardsText = "No rewards obtained"
        end
        local titleText = gameResult and "Stage Completed!" or "Stage Failed!"
        local embedColor = gameResult and 0x57F287 or 0xED4245
        local TitleSubText = "Unknown Stage"
        if gameInfo and gameInfo.MapName and gameInfo.Act and gameInfo.Category then
            local resultText = gameResult and "Victory" or "Defeat"
            TitleSubText = string.format("%s - %s (%s) - %s", gameInfo.MapName, gameInfo.Act, gameInfo.Category, resultText)
        end
        local currentWave = workspace:GetAttribute("Wave") or lastWave or 0
        local macroInfo = "None"
        if isPlaybackEnabled and currentMacroName and currentMacroName ~= "" then macroInfo = currentMacroName end
        data = {
            username = "LixHub",
            content = hasUnitDrop and string.format("<@%s>", Config.DISCORD_USER_ID or "") or nil,
            embeds = {{
                title = titleText, description = TitleSubText, color = embedColor,
                fields = {
                    { name = "Player", value = playerName, inline = true },
                    { name = "Duration", value = gameDuration or "Unknown", inline = true },
                    { name = "Waves Completed", value = tostring(currentWave), inline = true },
                    { name = "Macro", value = macroInfo, inline = true },
                    { name = "Rewards", value = rewardsText, inline = false },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" }, timestamp = timestamp
            }}
        }
    elseif messageType == "match_restart" then
        local rewards = {}
        if beforeRewardData and RequestData then
            local currentRewardData = Util.deepCopy(RequestData:InvokeServer())
            rewards = Webhook.getRewards(beforeRewardData, currentRewardData)
        end
        local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        local description = "Unknown Stage"
        if gameInfo and gameInfo.MapName and gameInfo.Act and gameInfo.Category then
            description = string.format("%s Act %s (%s) - Match restarted", gameInfo.MapName, gameInfo.Act, gameInfo.Category)
        end
        local currentWave = waveReached or lastWave or 0
        local timeElapsed = "Unknown"
        if gameInfo and gameInfo.StartTime then
            local duration = tick() - gameInfo.StartTime
            timeElapsed = string.format("%dm %ds", math.floor(duration / 60), math.floor(duration % 60))
        end
        local rewardsText = ""
        if next(rewards) then
            for rewardType, amount in pairs(rewards) do
                local sign = amount > 0 and "+" or ""
                rewardsText = rewardsText .. string.format("%s%s %s\n", sign, amount, rewardType)
            end
            rewardsText = rewardsText:gsub("\n$", "")
        else
            rewardsText = "No rewards obtained"
        end
        data = {
            username = "LixHub",
            embeds = {{
                title = "Stage Completed!", description = description, color = 0xFFA500,
                fields = {
                    { name = "Player", value = playerName, inline = true },
                    { name = "Time Played", value = timeElapsed, inline = true },
                    { name = "Wave Reached", value = tostring(currentWave), inline = true },
                    { name = "Rewards", value = rewardsText, inline = false },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" }, timestamp = timestamp
            }}
        }
    end
    local payload = Services.HttpService:JSONEncode(data)
    local requestFunc = syn and syn.request or request or http_request or (fluxus and fluxus.request) or getgenv().request
    if not requestFunc then warn("No HTTP function found!") return end
    local success, response = pcall(function()
        return requestFunc({ Url = ValidWebhook, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
    end)
    if success and response and (response.StatusCode == 204 or response.StatusCode == 200) then
        Rayfield:Notify({ Title = "Webhook Sent", Content = "Successfully sent to Discord!", Duration = 2 })
    else
        warn("Webhook failed:", response and response.StatusCode or "No response")
    end
end

function Util.getCurrentWorldKey()
    local category = workspace:GetAttribute("Category")
    local mapName = workspace:GetAttribute("MapName")
    local mapInternal = workspace:GetAttribute("Map")
    if not category or not mapName then return nil end
    local categoryLower = category:lower()
    if categoryLower == "story" then
        return "challenge_" .. mapName:lower():gsub("%s+", "_")
    end
    if categoryLower == "featured" then
        if mapName:lower():find("frozen") or mapName == "Frozen Stronghold" then
            return "challenge_featured"
        end
    end
    if categoryLower == "legend" then
        if mapInternal then return "legend_" .. mapInternal:lower() end
        local moduleName = UINameToModuleName[mapName]
        if moduleName then return "legend_" .. moduleName:lower() end
    end
    if categoryLower:find("virtual") then
        return "virtual_" .. mapName:lower():gsub("%s+", "_")
    end
    if categoryLower == "raid" then
        if mapInternal then return "raid_" .. mapInternal:lower() end
        local moduleName = UINameToModuleName[mapName]
        if moduleName then return "raid_" .. moduleName:lower() end
    end
    return nil
end

function Util.notify(title, content)
    Rayfield:Notify({ Title = title, Content = content, Duration = 3 })
end

function Util.canPerformAction()
    return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
end

function Util.setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()
    Util.notify(action, "Joining...")
end

function Util.clearProcessingState()
    AutoJoinState.isProcessing = false
    AutoJoinState.currentAction = nil
end

function AutoJoin.getModuleNameFromUI(uiName, category)
    if category == "Story" or category == "VirtualRealm" or category == "Raid" then
        local moduleName = UINameToModuleName[uiName]
        if moduleName then return moduleName end
        warn(string.format("⚠️ No module name found for UI name: %s", uiName))
        return uiName
    end
    if category == "LegendStage" then
        local success, moduleName = pcall(function()
            local LegendFolder = Services.ReplicatedStorage.Shared.Data.LegendStages
            for _, stageModule in ipairs(LegendFolder:GetChildren()) do
                if stageModule:IsA("ModuleScript") then
                    local stageData = require(stageModule)
                    if stageData.Information and stageData.Information.Name == uiName then
                        return stageModule.Name
                    end
                end
            end
            return nil
        end)
        if success and moduleName then return moduleName end
        warn(string.format("⚠️ No module name found for Legend stage: %s", uiName))
        return uiName
    end
    return uiName
end

function Util.convertDifficultyMeter(percentage)
    return percentage / 100
end

function AutoJoin.joinStory(mapUIName, act, difficulty, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "Story")
    local gameData = { Category = "Story", Map = mapModuleName, Act = tostring(act), Difficulty = difficulty, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinWinter(act, difficulty, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local gameData = { Category = "LimitedTimeModes", Map = "Winter", Act = tostring(act), Difficulty = difficulty, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinLegend(mapUIName, act, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "LegendStage")
    local gameData = { Category = "LegendStage", Map = mapModuleName, Act = tostring(act), Difficulty = nil, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinVirtual(mapUIName, act, difficulty, difficultyPercent)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "VirtualRealm")
    local gameData = { Category = "VirtualRealm", Map = mapModuleName, Act = tostring(act), Difficulty = difficulty, Modulation = Util.convertDifficultyMeter(difficultyPercent), FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinRaid(mapUIName, act)
    if not PodController then warn("PodController not initialized") return false end
    local mapModuleName = AutoJoin.getModuleNameFromUI(mapUIName, "Raid")
    local actValue = (act == "BossRush" or act == "Boss Rush") and "Boss Rush" or tostring(act)
    local gameData = { Category = "Raid", Map = mapModuleName, Act = actValue, Difficulty = "Nightmare", Modulation = 1.0, FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.waitForChallengeError(timeout)
    local startTime = tick()
    timeout = timeout or 3
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
                        if text:lower():find("already beaten") or text:lower():find("already completed") then
                            return true
                        end
                    end
                end
            end
            return false
        end)
        if success and errorDetected then return true end
        task.wait(0.1)
    end
    return false
end

function AutoJoin.joinChallenge(challengeType, challengeNumber)
    if not PodController or not ChallengeController then warn("Controllers not initialized") return false end
    local challenges = ChallengeController:GetCurrentChallenges()
    if not challenges or not challenges[challengeType] or not challenges[challengeType][challengeNumber] then
        warn(string.format("Challenge not found: %s #%d", challengeType, challengeNumber))
        return false
    end
    local challengeData = challenges[challengeType][challengeNumber]
    if challengeData.Completed == true then return "already_completed" end
    local gameData = { Category = "Challenge", Challenge = { Type = challengeType, Number = challengeNumber }, Map = challengeData.Map, Act = tostring(challengeData.Act), Difficulty = "Easy", Modulation = 1.0, FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    if success then
        task.wait(1)
        local errorDetected = AutoJoin.waitForChallengeError(3)
        if errorDetected then
            pcall(function()
                local LobbyUi = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
                if LobbyUi then
                    local closeButton = LobbyUi.Messages.Middle.MessageList.Error.CloseButton
                    if closeButton then
                        for _, conn in pairs(getconnections(closeButton.MouseButton1Down)) do
                            if conn.Enabled then conn:Fire() end
                        end
                    end
                end
            end)
            task.wait(0.3)
            return "already_completed"
        end
        return true
    end
    return false
end

function AutoJoin.joinFeaturedChallenge()
    if not PodController then warn("PodController not initialized") return false end
    local cfg = require(Services.ReplicatedStorage.Shared.Data.Config)
    local gameData = { Category = "Challenge", Challenge = { Type = "Special", Number = 1 }, Map = cfg.CurrentFeaturedChallenge or "Frozen Stronghold", Act = "1", Difficulty = "Easy", Modulation = 1.0, FriendsOnly = false }
    local success = pcall(function() PodController:RequestPod(gameData) end)
    return success
end

function AutoJoin.joinOlympusJudgement()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\x11\x00Olympus Judgement\x01\x01\a\x00Special\x00\x00\x80?\x01\x001\x00\x04\x00Easy\x00\x00\t\x00Challenge\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.joinShinobiAlliance()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\x0F\x00ShinobiAlliance\x00\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\x0F\x00ShinobiAlliance\x10\x00LimitedTimeModes\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.joinRagnarok()
    local Event = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
    local success = pcall(function()
        Event:FireServer(buffer.fromstring(")\b\x00Ragnarok\x00\x00\x00\x80?\x01\x001\x00\t\x00Nightmare\b\x00Ragnarok\x10\x00LimitedTimeModes\x00\x00"), nil)
    end)
    return success
end

function AutoJoin.startGameViaAPI()
    if not PodController then warn("PodController not initialized") return false end
    local success = pcall(function()
        local startButton = Services.Players.LocalPlayer.PlayerGui.LobbyUi.PartyFrame.RightFrame.Content.Buttons.Start.Hitbox
        for _, conn in pairs(getconnections(startButton.MouseButton1Up)) do
            if conn.Enabled then conn:Fire() end
        end
    end)
    return success
end

function AutoJoin.waitForJoinSuccess(timeout)
    local startTime = tick()
    timeout = timeout or 10
    while tick() - startTime < timeout do
        local success, partyFrameVisible = pcall(function()
            local partyFrame = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
            if partyFrame then
                partyFrame = partyFrame:FindFirstChild("PartyFrame")
                if partyFrame then return partyFrame.Enabled end
            end
            return false
        end)
        if success and partyFrameVisible then return true end
        task.wait(0.5)
    end
    return false
end

function AutoJoin.tryStartGameWithRetry(maxAttempts)
    maxAttempts = maxAttempts or 3
    for attempt = 1, maxAttempts do
        AutoJoin.startGameViaAPI()
        local waitStart = tick()
        while tick() - waitStart < 3 do
            if not Util.isInLobby() then return true end
            local success, partyFrameVisible = pcall(function()
                local partyFrame = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
                if partyFrame then
                    partyFrame = partyFrame:FindFirstChild("PartyFrame")
                    if partyFrame then return partyFrame.Enabled end
                end
                return false
            end)
            if success and not partyFrameVisible then return true end
            task.wait(0.3)
        end
        local success, partyFrameVisible = pcall(function()
            local partyFrame = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
            if partyFrame then
                partyFrame = partyFrame:FindFirstChild("PartyFrame")
                if partyFrame then return partyFrame.Enabled end
            end
            return false
        end)
        if not success or not partyFrameVisible then return true end
        task.wait(0.5)
    end
    warn(" Failed to start game after", maxAttempts, "attempts - clicking Leave")
    pcall(function()
        local leaveButton = Services.Players.LocalPlayer.PlayerGui.LobbyUi.PartyFrame.RightFrame.Content.Buttons.Leave.Hitbox
        for _, conn in pairs(getconnections(leaveButton.MouseButton1Up)) do
            if conn.Enabled then conn:Fire() end
        end
    end)
    task.wait(2)
    return false
end

function AutoJoin.getCurrentChallengesData()
    if not ChallengeController then warn("ChallengeController not initialized") return nil end
    local success, challenges = pcall(function() return ChallengeController:GetCurrentChallenges() end)
    if success and challenges then return challenges end
    return nil
end

function AutoJoin.challengeMatchesFilters(challengeData)
    local challengeMapModule = challengeData.Map
    local modifiers = challengeData.Modifiers or {}
    local reward = challengeData.Reward
    if #State.IgnoreWorlds > 0 then
        for _, ignoredMapUI in ipairs(State.IgnoreWorlds) do
            local ignoredMapModule = UINameToModuleName[ignoredMapUI]
            if ignoredMapModule and challengeMapModule == ignoredMapModule then return false end
        end
    end
    if #State.IgnoreModifier > 0 then
        for _, modifierName in pairs(modifiers) do
            for _, ignoredModifier in ipairs(State.IgnoreModifier) do
                if modifierName == ignoredModifier then return false end
            end
        end
    end
    if #State.SelectedChallengeRewards > 0 then
        local rewardMapping = { ["Fragments"] = "Fragments", ["Gems"] = "Gems", ["Stats"] = "Stat Rerolls", ["Rerolls"] = "Trait Rerolls" }
        local friendlyReward = rewardMapping[reward] or reward
        local rewardMatches = false
        for _, selectedReward in ipairs(State.SelectedChallengeRewards) do
            if friendlyReward == selectedReward then rewardMatches = true break end
        end
        if not rewardMatches then return false end
    else
        return false
    end
    return true
end

function AutoJoin.findAllMatchingChallenges(challengesData)
    local matchingChallenges = {}
    for challengeIndex, challengeData in pairs(challengesData) do
        if type(challengeIndex) ~= "number" then continue end
        if AutoJoin.challengeMatchesFilters(challengeData) then
            table.insert(matchingChallenges, { index = challengeIndex, data = challengeData, score = (challengeData.Act or 0) * 10 })
        end
    end
    table.sort(matchingChallenges, function(a, b) return a.score > b.score end)
    return matchingChallenges
end

function Util.isGameDataLoaded()
    local success = pcall(function()
        return Services.ReplicatedStorage:FindFirstChild("Shared") and
               Services.ReplicatedStorage.Shared:FindFirstChild("Data")
    end)
    return success
end

function AutoJoin.checkAndExecuteHighestPriority()
    if not Util.isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    if not Util.canPerformAction() then return end
    if not ChallengeController or not PodController then return end
    if not Util.isGameDataLoaded() then return end
    if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi") then
        local lobbyUi = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi")
        if (lobbyUi:FindFirstChild("PartyFrame") and lobbyUi:FindFirstChild("PartyFrame").Enabled) then return end
    end
 
    if State.AutoJoinChallenge then
        local regularChallengeOnCooldown = false
        local timeSinceLastFail = tick() - (State.LastFailedChallengeAttempt or 0)
        if State.LastFailedChallengeAttempt > 0 and timeSinceLastFail < State.ChallengeJoinCooldown then
            regularChallengeOnCooldown = true
        end
        if not regularChallengeOnCooldown then
            Util.setProcessingState("Challenge Auto Join")
            local challenges = AutoJoin.getCurrentChallengesData()
            if challenges and challenges["HalfHour"] then
                local matchingChallenges = AutoJoin.findAllMatchingChallenges(challenges["HalfHour"])
                if #matchingChallenges > 0 then
                    for attemptNum, challenge in ipairs(matchingChallenges) do
                        local success = AutoJoin.joinChallenge("HalfHour", challenge.index)
                        if success == true then
                            State.LastFailedChallengeAttempt = 0
                            if AutoJoin.waitForJoinSuccess(10) then
                                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
                            end
                        elseif success == "already_completed" then continue
                        else continue end
                    end
                    State.LastFailedChallengeAttempt = tick()
                else
                    State.LastFailedChallengeAttempt = tick()
                end
            else
                State.LastFailedChallengeAttempt = tick()
            end
            Util.clearProcessingState()
        end
    end
 
    if State.AutoJoinFeaturedChallenge then
        Util.setProcessingState("Featured Challenge Auto Join")
        local success = AutoJoin.joinFeaturedChallenge()
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        end
        Util.clearProcessingState()
    end
 
    if State.AutoJoinOlympusJudgement then
        Util.setProcessingState("Olympus Judgement Auto Join")
        local success = AutoJoin.joinOlympusJudgement()
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        end
        Util.clearProcessingState()
    end
 
    if State.AutoJoinShinobiAlliance then
        Util.setProcessingState("Shinobi Alliance Auto Join")
        local success = AutoJoin.joinShinobiAlliance()
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        end
        Util.clearProcessingState()
    end
 
    if State.AutoJoinRagnarok then
        Util.setProcessingState("Ragnarok Infinite Auto Join")
        local success = AutoJoin.joinRagnarok()
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        end
        Util.clearProcessingState()
    end
 
    if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and State.StoryDifficultySelected and State.StoryDifficultyMeterSelected then
        Util.setProcessingState("Story Auto Join")
        local success = AutoJoin.joinStory(State.StoryStageSelected, State.StoryActSelected, State.StoryDifficultySelected, State.StoryDifficultyMeterSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinLegendStage and State.LegendStageSelected and State.LegendStageActSelected and State.LegendStageDifficultyMeterSelected then
        Util.setProcessingState("Legend Stage Auto Join")
        local success = AutoJoin.joinLegend(State.LegendStageSelected, tonumber(State.LegendStageActSelected), State.LegendStageDifficultyMeterSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinVirtualStage and State.VirtualStageSelected and State.VirtualStageActSelected and State.VirtualStageDifficultySelected and State.VirtualStageDifficultyMeterSelected then
        Util.setProcessingState("Virtual Stage Auto Join")
        local success = AutoJoin.joinVirtual(State.VirtualStageSelected, tonumber(State.VirtualStageActSelected), State.VirtualStageDifficultySelected, State.VirtualStageDifficultyMeterSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinRaid and State.RaidStageSelected and State.RaidActSelected then
        Util.setProcessingState("Raid Stage Auto Join")
        local success = AutoJoin.joinRaid(State.RaidStageSelected, State.RaidActSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
 
    if State.AutoJoinWinterEvent and State.WinterActSelected and State.WinterStageDifficultySelected and State.WinterStageDifficultyMeterSelected then
        Util.setProcessingState("Winter Event Auto Join")
        local success = AutoJoin.joinWinter(State.WinterActSelected, State.WinterStageDifficultySelected, State.WinterStageDifficultyMeterSelected)
        if success then
            if AutoJoin.waitForJoinSuccess(10) then
                if AutoJoin.tryStartGameWithRetry(3) then task.wait(3) Util.clearProcessingState() return end
            end
        else Util.clearProcessingState() end
    end
end

--[[--------------------------------------------------------------]]

AutoPathTab:CreateLabel("Higher number = higher priority")

AutoPathTab:CreateToggle({
    Name = "Auto Select Path", CurrentValue = false, Flag = "AutoSelectPath",
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
        MacroIO.savePathPriorities()
    end,
})
AutoPathTab:CreateDivider()

function PathSystem.loadSliders()
    local PathsFolder = game:GetService("ReplicatedStorage").Shared.Data.Paths
    local playerName = game:GetService("Players").LocalPlayer.Name
    local configPath = string.format("LixHub/%s_PathSettings_UTD.json", playerName)
    local configExists = isfile(configPath)
    local savedPriorities = configExists and MacroIO.loadPathPriorities() or {}
    for key, value in pairs(savedPriorities) do PathState.BlessingPriorities[key] = value end
    local pathsData = {}
    for _, pathModule in ipairs(PathsFolder:GetChildren()) do
        if pathModule:IsA("ModuleScript") then
            local success, pathData = pcall(function() return require(pathModule) end)
            if success and pathData.Blessings then
                local pathName = pathModule.Name
                pathsData[pathName] = { blessings = {}, resonanceName = nil }
                if pathData.Resonance and pathData.Resonance.Name then
                    pathsData[pathName].resonanceName = pathData.Resonance.Name
                end
                for rarity, blessings in pairs(pathData.Blessings) do
                    for blessingName, blessingData in pairs(blessings) do
                        table.insert(pathsData[pathName].blessings, { name = blessingName, rarity = rarity })
                    end
                end
                table.sort(pathsData[pathName].blessings, function(a, b) return a.name < b.name end)
            end
        end
    end
    local sortedPaths = {}
    for pathName in pairs(pathsData) do table.insert(sortedPaths, pathName) end
    table.sort(sortedPaths)
    local currentPriority = nil
    if not configExists then
        local totalItems = 0
        for _, pathInfo in pairs(pathsData) do
            if pathInfo.resonanceName then totalItems = totalItems + 1 end
            totalItems = totalItems + #pathInfo.blessings
        end
        currentPriority = totalItems
    end
    for _, pathName in ipairs(sortedPaths) do
        local pathInfo = pathsData[pathName]
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
            local slider = AutoPathTab:CreateSlider({
                Name = string.format("[%s] %s", pathName, pathInfo.resonanceName),
                Range = {0, 100}, Increment = 1, CurrentValue = sliderValue,
                Flag = "PathPriority_Resonance_" .. resonanceKey,
                Callback = function(Value)
                    PathState.BlessingPriorities[resonanceKey] = Value
                    MacroIO.savePathPriorities()
                end,
            })
            table.insert(pathSliders, slider)
        end
        for _, blessing in ipairs(pathInfo.blessings) do
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
            local slider = AutoPathTab:CreateSlider({
                Name = string.format("[%s] %s", pathName, blessing.name),
                Range = {0, 100}, Increment = 1, CurrentValue = sliderValue,
                Flag = "PathPriority_" .. pathName .. "_" .. blessing.name:gsub("%s", ""),
                Callback = function(Value)
                    PathState.BlessingPriorities[sliderKey] = Value
                    MacroIO.savePathPriorities()
                end,
            })
            table.insert(pathSliders, slider)
        end
        AutoPathTab:CreateDivider()
    end
    if not configExists then MacroIO.savePathPriorities() end
end

task.spawn(function()
    task.wait(2)
    local success, err = pcall(PathSystem.loadSliders)
    if not success then
        warn("Failed to load path sliders:", err)
        AutoPathTab:CreateLabel("⚠️ Failed to load paths")
    end
end)

RagnarokTab:CreateToggle({
    Name = "Auto Pick Ragnarok Cards",
    CurrentValue = false,
    Flag = "AutoPickRagnarokCards",
    Callback = function(Value)
        RagnarokState.AutoPickEnabled = Value
    end,
})

RagnarokTab:CreateLabel("Higher number = higher priority")
RagnarokTab:CreateDivider()

RagnarokTab:CreateSlider({
    Name = "Quickened Hands",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Quickened Hands"],
    Flag = "RagnarokCard_QuickenedHands",
    Callback = function(Value) RagnarokState.CardPriorities["Quickened Hands"] = Value end,
})
RagnarokTab:CreateSlider({
    Name = "Spoils of War",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Spoils of War"],
    Flag = "RagnarokCard_SpoilsOfWar",
    Callback = function(Value) RagnarokState.CardPriorities["Spoils of War"] = Value end,
})
RagnarokTab:CreateSlider({
    Name = "Silence the Gods",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Silence the Gods"],
    Flag = "RagnarokCard_SilenceTheGods",
    Callback = function(Value) RagnarokState.CardPriorities["Silence the Gods"] = Value end,
})
RagnarokTab:CreateSlider({
    Name = "Extended Reach",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Extended Reach"],
    Flag = "RagnarokCard_ExtendedReach",
    Callback = function(Value) RagnarokState.CardPriorities["Extended Reach"] = Value end,
})
RagnarokTab:CreateSlider({
    Name = "Exposed Weakness",
    Range = {1, 5}, Increment = 1,
    CurrentValue = RagnarokState.CardPriorities["Exposed Weakness"],
    Flag = "RagnarokCard_ExposedWeakness",
    Callback = function(Value) RagnarokState.CardPriorities["Exposed Weakness"] = Value end,
})

task.spawn(function()
    task.wait(2)
    local success, CardChoiceRE = pcall(function()
        return game:GetService("ReplicatedStorage")
            .Packages._Index["sleitnick_knit@1.7.0"]
            .knit.Services.CardChoiceService.RE
    end)
    if not success or not CardChoiceRE then
        warn("Failed to find CardChoiceService RE")
        return
    end

    CardChoiceRE.GetNewCards.OnClientEvent:Connect(function(channel, cards, config)
        if channel ~= "RagnarokCard" then return end
        if not RagnarokState.AutoPickEnabled then return end

        local bestIndex = 1
        local bestPriority = -1

        for i, card in ipairs(cards) do
            local priority = RagnarokState.CardPriorities[card.name] or 0
            if priority > bestPriority then
                bestPriority = priority
                bestIndex = i
            end
        end

        task.wait(0.5)

        if workspace:GetAttribute(config.votedAttribute) then return end

        local voteSuccess = pcall(function()
            CardChoiceRE.VoteCard:FireServer(channel, bestIndex)
        end)

        if voteSuccess then
            local chosenCard = cards[bestIndex]
            Rayfield:Notify({
                Title = "Ragnarok Card Picked",
                Content = "Selected: " .. (chosenCard and chosenCard.name or "Unknown"),
                Duration = 4,
            })
        end
    end)
    CardChoiceRE.GetNewCards.OnClientEvent:Connect(function(channel, cards, config)
    if channel ~= "RagnarokValkyrie" then return end

    -- RECORDING: Save which valk was picked by listening for VoteCard
    -- We'll store the card list so we can match by index later
    if isRecording and recordingHasStarted then
        -- Store cards so we can record the pick when VoteCard fires
        pendingValkCardList = cards
    end
end)
end)

JoinerTab:CreateSection("Story Joiner")

AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story", CurrentValue = false, Flag = "AutoJoinStory",
    Callback = function(Value) State.AutoJoinStory = Value end,
})
 
local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Stage", Options = {}, CurrentOption = {}, Flag = "StoryStageSelector",
    Callback = function(Option) State.StoryStageSelected = Option[1] end,
})
 
ChapterDropdown869 = JoinerTab:CreateDropdown({
    Name = "Select Story Act", Options = {"Act 1","Act 2","Act 3","Act 4","Act 5","Act 6","Infinite"},
    CurrentOption = {}, MultipleOptions = false, Flag = "StoryActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        if selectedOption == "Infinite" then State.StoryActSelected = "Infinite"
        else local num = selectedOption:match("%d+") if num then State.StoryActSelected = num end end
    end,
})
 
ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Difficulty", Options = {"Easy","Hard","Nightmare"},
    CurrentOption = {}, MultipleOptions = false, Flag = "StoryDifficultySelector",
    Callback = function(Option)
        State.StoryDifficultySelected = Option[1]
    end,
})
 
StorySlider = JoinerTab:CreateSlider({
    Name = "Select Difficulty Meter", Range = {75, 1000}, Increment = 1,
    Suffix = "", CurrentValue = 100, Flag = "StoryDifficultyMeterSelector",
    Callback = function(Value) State.StoryDifficultyMeterSelected = Value end,
})
 
JoinerTab:CreateSection("Legend Stage Joiner")
 
AutoJoinLegendToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Legend Stage", CurrentValue = false, Flag = "AutoJoinLegendStage",
    Callback = function(Value) State.AutoJoinLegendStage = Value end,
})
 
local LegendStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage", Options = {}, CurrentOption = {}, Flag = "LegendStageSelector",
    Callback = function(Option) State.LegendStageSelected = Option[1] end,
})
 
LegendChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage Act", Options = {"Act 1","Act 2","Act 3"},
    CurrentOption = {}, MultipleOptions = false, Flag = "LegendStageActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        local num = selectedOption:match("%d+") if num then State.LegendStageActSelected = num end
    end,
})
 
LegendSlider = JoinerTab:CreateSlider({
    Name = "Select Difficulty Meter", Range = {75, 1000}, Increment = 1,
    Suffix = "", CurrentValue = 100, Flag = "LegendStageDifficultyMeterSelector",
    Callback = function(Value) State.LegendStageDifficultyMeterSelected = Value end,
})
 
JoinerTab:CreateSection("Virtual Stage Joiner")
 
AutoJoinVirtualToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Virtual Stage", CurrentValue = false, Flag = "AutoJoinVirtualStage",
    Callback = function(Value) State.AutoJoinVirtualStage = Value end,
})
 
local VirtualStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Virtual Stage", Options = {}, CurrentOption = {}, Flag = "VirtualStageSelector",
    Callback = function(Options) State.VirtualStageSelected = Options[1] end,
})
 
VirtualChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Virtual Stage Act", Options = {"Act 1","Act 2","Act 3"},
    CurrentOption = {}, MultipleOptions = false, Flag = "VirtualStageActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        local num = selectedOption:match("%d+") if num then State.VirtualStageActSelected = num end
    end,
})
 
VirtualDifficultyDropdown = JoinerTab:CreateDropdown({
    Name = "Select Virtual Difficulty", Options = {"Easy","Hard","Nightmare"},
    CurrentOption = {}, MultipleOptions = false, Flag = "VirtualStageDifficultySelector",
    Callback = function(Option) State.VirtualStageDifficultySelected = Option[1] end,
})
 
VirtualSlider = JoinerTab:CreateSlider({
    Name = "Select Difficulty Meter", Range = {75, 1000}, Increment = 1,
    Suffix = "", CurrentValue = 100, Flag = "VirtualStageDifficultyMeterSelector",
    Callback = function(Value) State.VirtualStageDifficultyMeterSelected = Value end,
})
 
JoinerTab:CreateSection("Raid Joiner")
 
AutoJoinRaidToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Raid", CurrentValue = false, Flag = "AutoJoinRaid",
    Callback = function(Value) State.AutoJoinRaid = Value end,
})
 
local RaidStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Stage", Options = {}, CurrentOption = {}, Flag = "RaidStageSelector",
    Callback = function(Option) State.RaidStageSelected = Option[1] end,
})
 
RaidChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Act", Options = {"Act 1","Act 2","Act 3","Act 4","Act 5","Boss Rush"},
    CurrentOption = {}, MultipleOptions = false, Flag = "RaidStageActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        if selectedOption == "Boss Rush" then State.RaidActSelected = "BossRush"
        else local num = selectedOption:match("%d+") if num then State.RaidActSelected = num end end
    end,
})
 
JoinerTab:CreateSection("Challenge Joiner")
 
AutoJoinFeaturedChallengeToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Featured Challenge (The Hunt)", CurrentValue = false, Flag = "AutoJoinFeaturedChallenge",
    Callback = function(Value) State.AutoJoinFeaturedChallenge = Value end,
})
 
AutoJoinOlympusToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Featured Challenge (Olympus Judgement)", CurrentValue = false, Flag = "AutoJoinOlympusJudgement",
    Callback = function(Value) State.AutoJoinOlympusJudgement = Value end,
})
 
AutoJoinChallengeToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Challenge", CurrentValue = false, Flag = "AutoJoinChallenge",
    Callback = function(Value) State.AutoJoinChallenge = Value end,
})
 
local IgnoreWorldsDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Worlds", Options = {}, CurrentOption = {}, MultipleOptions = true,
    Flag = "IgnoreWorldsSelector", Info = "Skip challenges based on these worlds",
    Callback = function(Options) State.IgnoreWorlds = Options or {} end,
})
 
local IgnoreModifierDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Modifier", Options = {}, CurrentOption = {}, MultipleOptions = true,
    Flag = "IgnoreModifierSelector", Info = "Skip challenges based on these modifiers",
    Callback = function(Options)
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
    Name = "Select Challenge Rewards", Options = {"Fragments","Gems","Stat Rerolls","Trait Rerolls"},
    CurrentOption = {}, MultipleOptions = true, Flag = "SelectedChallengeRewards",
    Info = "Only join challenges that contain one or more of these rewards",
    Callback = function(Options) State.SelectedChallengeRewards = Options or {} end,
})
 
ReturnToLobbyToggle = JoinerTab:CreateToggle({
    Name = "Return to Lobby on New Challenge", CurrentValue = false, Flag = "ReturnToLobbyOnNewChallenge",
    Info = "Return to lobby when new challenge appears instead of using retry/next",
    Callback = function(Value) State.ReturnToLobbyOnNewChallenge = Value end,
})
 
JoinerTab:CreateSection("Event Joiner")
 
AutoJoinShinobiToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Shinobi Alliance", CurrentValue = false, Flag = "AutoJoinShinobiAlliance",
    Callback = function(Value) State.AutoJoinShinobiAlliance = Value end,
})
 
AutoJoinRagnarokToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Ragnarok Infinite", CurrentValue = false, Flag = "AutoJoinRagnarok",
    Callback = function(Value) State.AutoJoinRagnarok = Value end,
})

--[[task.spawn(function()
    local isCollecting = false
    
    while true do
        task.wait(0.5)
        
        if State.AutoCollectPresents and not isCollecting then
            isCollecting = true
            
            pcall(function()
                local drops = workspace:FindFirstChild("Ignore")
                if drops then
                    drops = drops:FindFirstChild("Drops")
                end
                
                if drops then
                    local presents = {}
                    for _, child in pairs(drops:GetChildren()) do
                        if child.Name == "Present" and child:IsA("Model") then
                            table.insert(presents, child)
                        end
                    end
                    
                    for _, present in ipairs(presents) do
                        if not State.AutoCollectPresents then break end
                        
                        if present and present.Parent then
                            local character = Services.Players.LocalPlayer.Character
                            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                            
                            if humanoidRootPart then
                                -- Save original position
                                local originalCFrame = humanoidRootPart.CFrame
                                
                                -- Teleport to present
                                local presentPos = present:GetPivot().Position
                                humanoidRootPart.CFrame = CFrame.new(presentPos)
                                
                                -- Wait for present to be collected
                                local timeout = 0
                                while present and present.Parent and timeout < 20 do
                                    task.wait(0.1)
                                    timeout = timeout + 1
                                end
                                
                                -- Teleport back to original position
                                if humanoidRootPart and humanoidRootPart.Parent then
                                    humanoidRootPart.CFrame = originalCFrame
                                end
                                
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
            isCollecting = false
        end
    end
end)--]]

function Loader.buildMapLookup()
    local success, result = pcall(function()
        local WavesFolder = Services.ReplicatedStorage.Shared.Data.Waves
        if not WavesFolder then warn("Waves folder not found") return false end
        local count = 0
        for _, stageModule in ipairs(WavesFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    UINameToModuleName[stageData.Information.Name] = stageModule.Name
                    count = count + 1
                end
            end
        end
        return true
    end)
    return success and result
end

function Loader.storyStages()
    loadingRetries.story = loadingRetries.story + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.story <= maxRetries then task.wait(retryDelay) task.spawn(Loader.storyStages) end
        return
    end
    local success, result = pcall(function()
        local WavesFolder = Services.ReplicatedStorage.Shared.Data.Waves
        if not WavesFolder then error("Waves folder not found") end
        local displayNames = {}
        for _, stageModule in ipairs(WavesFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No story stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if StoryStageDropdown then StoryStageDropdown:Refresh(result) end
        if IgnoreWorldsDropdown then IgnoreWorldsDropdown:Refresh(result) end
    else
        if loadingRetries.story <= maxRetries then task.wait(retryDelay) task.spawn(Loader.storyStages) end
    end
end

-- LEGEND STAGES LOADER
function Loader.legendStages()
    loadingRetries.legend = loadingRetries.legend + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.legend <= maxRetries then task.wait(retryDelay) task.spawn(Loader.legendStages) end
        return
    end
    local success, result = pcall(function()
        local LegendFolder = Services.ReplicatedStorage.Shared.Data.LegendStages
        if not LegendFolder then error("LegendStages folder not found") end
        local displayNames = {}
        for _, stageModule in ipairs(LegendFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No legend stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if LegendStageDropdown then LegendStageDropdown:Refresh(result) end
    else
        if loadingRetries.legend <= maxRetries then task.wait(retryDelay) task.spawn(Loader.legendStages) end
    end
end

-- VIRTUAL STAGES LOADER
function Loader.virtualStages()
    loadingRetries.portal = loadingRetries.portal + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.portal <= maxRetries then task.wait(retryDelay) task.spawn(Loader.virtualStages) end
        return
    end
    local success, result = pcall(function()
        local VirtualFolder = Services.ReplicatedStorage.Shared.Data.VirtualRealm
        if not VirtualFolder then error("VirtualRealm folder not found") end
        local displayNames = {}
        for _, stageModule in ipairs(VirtualFolder:GetChildren()) do
            if stageModule:IsA("ModuleScript") then
                local stageSuccess, stageData = pcall(function() return require(stageModule) end)
                if stageSuccess and stageData and stageData.Information and stageData.Information.Name then
                    table.insert(displayNames, stageData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No virtual stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if VirtualStageDropdown then VirtualStageDropdown:Refresh(result) end
    else
        if loadingRetries.portal <= maxRetries then task.wait(retryDelay) task.spawn(Loader.virtualStages) end
    end
end

function Loader.challengeModifiers()
    loadingRetries.modifiers = (loadingRetries.modifiers or 0) + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.modifiers <= maxRetries then task.wait(retryDelay) task.spawn(Loader.challengeModifiers) end
        return
    end
    local success, result = pcall(function()
        local ChallengesFolder = Services.ReplicatedStorage.Shared.Data.Challenges
        if not ChallengesFolder then error("Challenges folder not found") end
        local challengeModifiers = {}
        local seenTags = {}
        for _, challengeModule in ipairs(ChallengesFolder:GetChildren()) do
            if challengeModule:IsA("ModuleScript") and string.find(challengeModule.Name, "HalfHour") then
                local challengeSuccess, challengeData = pcall(function() return require(challengeModule) end)
                if challengeSuccess and challengeData and challengeData.ChallengeTag then
                    if not seenTags[challengeData.ChallengeTag] then
                        table.insert(challengeModifiers, { DisplayName = challengeData.ChallengeTag, ModuleName = challengeModule.Name })
                        seenTags[challengeData.ChallengeTag] = true
                    end
                end
            end
        end
        if #challengeModifiers == 0 then error("No challenge modifiers found") end
        table.sort(challengeModifiers, function(a, b) return a.DisplayName < b.DisplayName end)
        return challengeModifiers
    end)
    if success and result and #result > 0 then
        if IgnoreModifierDropdown then
            ModifierMapping = result
            ModifierModuleToTag = {}
            for _, modifier in ipairs(result) do ModifierModuleToTag[modifier.ModuleName] = modifier.DisplayName end
            local displayNames = {}
            for _, modifier in ipairs(result) do table.insert(displayNames, modifier.DisplayName) end
            IgnoreModifierDropdown:Refresh(displayNames)
        end
    else
        if loadingRetries.modifiers <= maxRetries then task.wait(retryDelay) task.spawn(Loader.challengeModifiers) end
    end
end

function Loader.raidStages()
    loadingRetries.raid = loadingRetries.raid + 1
    if not Util.isGameDataLoaded() then
        if loadingRetries.raid <= maxRetries then task.wait(retryDelay) task.spawn(Loader.raidStages) end
        return
    end
    local success, result = pcall(function()
        local RaidFolder = Services.ReplicatedStorage.Shared.Data.Raids
        if not RaidFolder then error("Raids folder not found") end
        local displayNames = {}
        for _, raidModule in ipairs(RaidFolder:GetChildren()) do
            if raidModule:IsA("ModuleScript") then
                local raidSuccess, raidData = pcall(function() return require(raidModule) end)
                if raidSuccess and raidData and raidData.Information and raidData.Information.Name then
                    UINameToModuleName[raidData.Information.Name] = raidModule.Name
                    table.insert(displayNames, raidData.Information.Name)
                end
            end
        end
        if #displayNames == 0 then error("No raid stages found") end
        table.sort(displayNames)
        return displayNames
    end)
    if success and result and #result > 0 then
        if RaidStageDropdown then RaidStageDropdown:Refresh(result) end
    else
        if loadingRetries.raid <= maxRetries then task.wait(retryDelay) task.spawn(Loader.raidStages) end
    end
end

function MacroIO.saveWorldMappings()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local fileName = string.format("LixHub/%s_WorldMappings_UTD.json", playerName)
    local json = game:GetService("HttpService"):JSONEncode(worldMacroMappings)
    writefile(fileName, json)
    print("✓ Saved world macro mappings")
end

function MacroIO.loadWorldMappings()
    MacroIO.ensureFolders()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local filePath = string.format("LixHub/%s_WorldMappings_UTD.json", playerName)
    if not isfile(filePath) then return {} end
    local json = readfile(filePath)
    local data = game:GetService("HttpService"):JSONDecode(json)
    print("✓ Loaded world macro mappings")
    return data or {}
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
    local initialMacroOptions = {"None"}
    for macroName in pairs(macroManager) do table.insert(initialMacroOptions, macroName) end
    table.sort(initialMacroOptions)
    task.wait(1)
 
    Tab:CreateSection("Story Stage Macros")
    if StoryStageDropdown and StoryStageDropdown.Options then
        for _, stageName in ipairs(StoryStageDropdown.Options) do
            local worldKey = "story_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                end,
            })
            worldDropdowns[worldKey] = dropdown
        end
    end
 
    Tab:CreateSection("Legend Stage Macros")
    if LegendStageDropdown and LegendStageDropdown.Options then
        for _, stageName in ipairs(LegendStageDropdown.Options) do
            local success, legendModuleName = pcall(function()
                local LegendFolder = Services.ReplicatedStorage.Shared.Data.LegendStages
                for _, stageModule in ipairs(LegendFolder:GetChildren()) do
                    if stageModule:IsA("ModuleScript") then
                        local stageData = require(stageModule)
                        if stageData.Information and stageData.Information.Name == stageName then return stageModule.Name end
                    end
                end
                return nil
            end)
            if success and legendModuleName then
                local worldKey = "legend_" .. legendModuleName:lower()
                local currentMapping = worldMacroMappings[worldKey] or "None"
                local dropdown = Tab:CreateDropdown({
                    Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                    MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                    Callback = function(Option)
                        local selectedMacro = type(Option) == "table" and Option[1] or Option
                        worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                        MacroIO.saveWorldMappings()
                    end,
                })
                worldDropdowns[worldKey] = dropdown
            end
        end
    end
 
    Tab:CreateSection("Virtual Stage Macros")
    if VirtualStageDropdown and VirtualStageDropdown.Options then
        for _, stageName in ipairs(VirtualStageDropdown.Options) do
            local worldKey = "virtual_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                end,
            })
            worldDropdowns[worldKey] = dropdown
        end
    end
 
    Tab:CreateSection("Raid Stage Macros")
    if RaidStageDropdown and RaidStageDropdown.Options then
        for _, stageName in ipairs(RaidStageDropdown.Options) do
            local success, raidModuleName = pcall(function()
                local RaidFolder = Services.ReplicatedStorage.Shared.Data.Raids
                for _, stageModule in ipairs(RaidFolder:GetChildren()) do
                    if stageModule:IsA("ModuleScript") then
                        local stageData = require(stageModule)
                        if stageData.Information and stageData.Information.Name == stageName then return stageModule.Name end
                    end
                end
                return nil
            end)
            if success and raidModuleName then
                local worldKey = "raid_" .. raidModuleName:lower()
                local currentMapping = worldMacroMappings[worldKey] or "None"
                local dropdown = Tab:CreateDropdown({
                    Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                    MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                    Callback = function(Option)
                        local selectedMacro = type(Option) == "table" and Option[1] or Option
                        worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                        MacroIO.saveWorldMappings()
                    end,
                })
                worldDropdowns[worldKey] = dropdown
            end
        end
    end
 
    Tab:CreateSection("Challenge Macros")
    if StoryStageDropdown and StoryStageDropdown.Options then
        for _, stageName in ipairs(StoryStageDropdown.Options) do
            local worldKey = "challenge_" .. stageName:lower():gsub("%s+", "_")
            local currentMapping = worldMacroMappings[worldKey] or "None"
            local dropdown = Tab:CreateDropdown({
                Name = stageName, Options = initialMacroOptions, CurrentOption = {currentMapping},
                MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
                Callback = function(Option)
                    local selectedMacro = type(Option) == "table" and Option[1] or Option
                    worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                    MacroIO.saveWorldMappings()
                end,
            })
            worldDropdowns[worldKey] = dropdown
        end
    end
 
    Tab:CreateSection("Featured Challenge Macro")
    do
        local worldKey = "challenge_featured"
        local currentMapping = worldMacroMappings[worldKey] or "None"
        local dropdown = Tab:CreateDropdown({
            Name = "Frozen Stronghold", Options = initialMacroOptions, CurrentOption = {currentMapping},
            MultipleOptions = false, Flag = "WorldMacro_" .. worldKey,
            Callback = function(Option)
                local selectedMacro = type(Option) == "table" and Option[1] or Option
                worldMacroMappings[worldKey] = (selectedMacro == "None" or selectedMacro == "") and nil or selectedMacro
                MacroIO.saveWorldMappings()
            end,
        })
        worldDropdowns[worldKey] = dropdown
    end
end

GameSection = GameTab:CreateSection("👥 Player 👥")

Slider = GameTab:CreateSlider({
    Name = "Max Camera Zoom Distance", Range = {5, 100}, Increment = 1,
    Suffix = "", CurrentValue = 35, Flag = "CameraZoomDistanceSelector",
    Callback = function(Value) Services.Players.LocalPlayer.CameraMaxZoomDistance = Value end,
})
 
Toggle = GameTab:CreateToggle({
    Name = "Anti AFK (No kick message)", CurrentValue = false, Flag = "AntiAfkKickToggle",
    Info = "Prevents roblox kick message.",
    Callback = function(Value) State.AntiAfkKickEnabled = Value end,
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
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then if obj.Transparency < 1 then obj.Transparency = 1 end end
        end
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then gui.Enabled = false end
        end
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then obj.Enabled = false end
        end
        local RE = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting")
        RE:FireServer("LowGraphics",true) RE:FireServer("DamageNumbers",false) RE:FireServer("VFX",false) RE:FireServer("EnableAnimations",false) RE:FireServer("EnemyInfo",false)
    else
        local RE = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting")
        RE:FireServer("LowGraphics",false) RE:FireServer("DamageNumbers",true) RE:FireServer("VFX",true) RE:FireServer("EnableAnimations",true) RE:FireServer("EnemyInfo",true)
        Services.Lighting.Brightness = 1.51
        Services.Lighting.GlobalShadows = true
        Services.Lighting.Technology = Enum.Technology.Future
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 1
        Services.Lighting.EnvironmentSpecularScale = 1
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = true end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 0 end
        end
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then gui.Enabled = true end
        end
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then obj.Enabled = true end
        end
    end
end
 
Toggle = GameTab:CreateToggle({
    Name = "Low Performance Mode", CurrentValue = false, Flag = "enableLowPerformanceMode",
    Callback = function(Value) State.enableLowPerformanceMode = Value enableLowPerformanceMode() end,
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
        toggleButtonFrame.Size = UDim2.new(0, 170, 0, 44)
        toggleButtonFrame.Position = UDim2.new(0.5, -60, 1, -60)
        toggleButtonFrame.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
        toggleButtonFrame.BackgroundTransparency = 0.5
        toggleButtonFrame.Parent = screenGui
        toggleButtonFrame.ZIndex = 1000000
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1,0)
        uiCorner.Parent = toggleButtonFrame
        local title = Instance.new("TextLabel")
        title.ZIndex = math.huge title.AnchorPoint = Vector2.new(0.5,0.5)
        title.BackgroundTransparency = 1 title.Position = UDim2.new(0.5,0,0.5,0)
        title.Size = UDim2.new(1,0,1,0) title.Text = "Toggle Screen"
        title.TextSize = 15 title.TextColor3 = Color3.fromRGB(255,255,255)
        title.Parent = toggleButtonFrame
        local stroke = Instance.new("UIStroke") stroke.Parent = title
        local btn = Instance.new("TextButton")
        btn.AnchorPoint = Vector2.new(0.5,0.5) btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(1,0,1,0) btn.Position = UDim2.new(0.5,0,0.5,0)
        btn.Text = "" btn.ZIndex = math.huge btn.Parent = toggleButtonFrame
        btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
    else
        if existingGui then existingGui:Destroy() end
    end
end
 
Toggle = GameTab:CreateToggle({
    Name = "Black Screen", CurrentValue = false, Flag = "enableBlackScreen",
    Callback = function(Value) State.enableBlackScreen = Value enableBlackScreen() end,
})

Button = LobbyTab:CreateButton({
    Name = "Return to lobby",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
    end,
})

Toggle = LobbyTab:CreateToggle({
    Name = "Auto Execute Script", CurrentValue = false, Flag = "enableAutoExecute",
    Info = "This auto executes and persists through teleports until you disable it or leave the game.",
    Callback = function(Value)
        State.enableAutoExecute = Value
        if queue_on_teleport then
            if State.enableAutoExecute then
                queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader"))()')
            else
                queue_on_teleport("")
            end
        else
            warn("queue_on_teleport not supported by this executor")
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
    Name = "Limit FPS", CurrentValue = false, Flag = "enableLimitFPS",
    Callback = function(Value) State.enableLimitFPS = Value updateFPSLimit() end,
})
 
Slider = GameTab:CreateSlider({
    Name = "Limit FPS To", Range = {0, 240}, Increment = 1, Suffix = " FPS",
    CurrentValue = 60, Flag = "FPSSelector",
    Callback = function(Value) State.SelectedFPS = Value updateFPSLimit() end,
})

 GameTab:CreateToggle({
    Name = "Streamer Mode (hide name/level/title)", CurrentValue = false, Flag = "StreamerMode",
    Callback = function(Value) State.streamerModeEnabled = Value end,
})

local function StreamerMode()
    local head = Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local billboard = head:WaitForChild("BillboardGui")
    if not billboard then return end
    local originalNumbers
    local streamerLabel
    if not Util.isInLobby() then
        originalNumbers = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameUI"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("Level")
        streamerLabel = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameUI"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("streamerlabel")
    else
        originalNumbers = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("Level")
        streamerLabel = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("LobbyUi"):FindFirstChild("HUD"):FindFirstChild("Bottom"):FindFirstChild("Hotbar"):FindFirstChild("LevelBar"):FindFirstChild("streamerlabel")
    end
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "streamerlabel"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = originalNumbers.Parent
    end
    local playerLevel = "1"
    pcall(function()
        local levelText = originalNumbers.Text
        local levelMatch = levelText:match("Level (%d+)")
        if levelMatch then playerLevel = levelMatch end
    end)
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

task.spawn(function() while true do task.wait(0.1) StreamerMode() end end)

if State.enableLowPerformanceMode then enableLowPerformanceMode() end

GameSection = GameTab:CreateSection("🎮 Game 🎮")

AutoStartToggle = GameTab:CreateToggle({
    Name = "Auto Start Game", CurrentValue = false, Flag = "AutoStartGame",
    Callback = function(Value) State.AutoStartGame = Value end,
})
AutoRetryToggle = GameTab:CreateToggle({
    Name = "Auto Retry", CurrentValue = false, Flag = "AutoRetry",
    Callback = function(Value) State.AutoRetry = Value end,
})
AutoNextToggle = GameTab:CreateToggle({
    Name = "Auto Next", CurrentValue = false, Flag = "AutoNext",
    Callback = function(Value) State.AutoNext = Value end,
})
AutoLobbyToggle = GameTab:CreateToggle({
    Name = "Auto Lobby", CurrentValue = false, Flag = "AutoLobby",
    Callback = function(Value) State.AutoLobby = Value end,
})
 
local function enableModdedPlacement()
    if moddedPlacementEnabled then return end
    if Util.isInLobby() then return end
    local success = pcall(function()
        local TowerController = require(game:GetService("ReplicatedStorage").Client.Controllers.TowerController)
        local functionsToHook = {"StartPlace","EndPlace","CanPlace","ValidatePlacement","CheckPlacement","IsValidPlacement"}
        for _, funcName in ipairs(functionsToHook) do
            if TowerController[funcName] and type(TowerController[funcName]) == "function" then
                local original = TowerController[funcName]
                TowerController[funcName] = function(...)
                    local results = {original(...)}
                    if results[1] == false or results[1] == nil then return true end
                    return unpack(results)
                end
            end
        end
        moddedPlacementEnabled = true
    end)
    return success
end
 
local function disableModdedPlacement()
    moddedPlacementEnabled = false
    Rayfield:Notify({ Title = "Success", Content = "Rejoin to disable", Duration = 4 })
end
 
Toggle = GameTab:CreateToggle({
    Name = "Place Anywhere", CurrentValue = false, Flag = "PlaceAnywhere",
    Info = "Place units anywhere",
    Callback = function(Value)
        if Value then
            local success = enableModdedPlacement()
            if success then Rayfield:Notify({ Title = "Success", Content = "Enabled! Place anywhere", Duration = 3 })
            else Rayfield:Notify({ Title = "Error", Content = "Failed to enable", Duration = 3 }) end
        else disableModdedPlacement() end
    end,
})
 
AutoGameSpeedToggle = GameTab:CreateToggle({
    Name = "Auto Game Speed", CurrentValue = false, Flag = "AutoGameSpeed",
    Callback = function(Value) State.AutoGameSpeed = Value end,
})
 
local Dropdown = GameTab:CreateDropdown({
    Name = "Select Game Speed", Options = {"1","1.5"}, CurrentOption = {}, MultipleOptions = false, Flag = "SelectGameSpeed",
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
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("SetSpeed"):FireServer(State.SelectedGameSpeed)
            end
        end
    end
end)
 
Toggle = GameTab:CreateToggle({
    Name = "Auto Skip Waves", CurrentValue = false, Flag = "AutoSkipWaves",
    Callback = function(Value) State.AutoSkipWaves = Value end,
})
 
Slider = GameTab:CreateSlider({
    Name = "Auto Skip Until Wave", Range = {0, 300}, Increment = 1, Suffix = "wave",
    CurrentValue = 0, Flag = "Slider1", Info = "0 = disable",
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
            local shouldAutoSkip = (skipLimit == 0) or (waveNum > 0 and waveNum <= skipLimit)
            if shouldAutoSkip ~= lastAutoSkipState then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DataService"):WaitForChild("RE"):WaitForChild("SetSetting"):FireServer("AutoSkip", shouldAutoSkip)
                end)
                lastAutoSkipState = shouldAutoSkip
            end
        else
            lastAutoSkipState = nil
        end
    end
end)
 
Toggle = GameTab:CreateToggle({
    Name = "Auto Restart Match", CurrentValue = false, Flag = "AutoRestartMatch",
    Callback = function(Value) State.AutoRestartMatch = Value end,
})
Slider = GameTab:CreateSlider({
    Name = "Restart Match on Wave", Range = {0, 300}, Increment = 1, Suffix = "wave",
    CurrentValue = 0, Flag = "AutoRestartMatchWave", Info = "0 = disable",
    Callback = function(Value) State.AutoRestartMatchWave = Value end,
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
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("MidMatchVote"):FireServer()
                end)
                if success then
                    hasRestarted = true
                    Rayfield:Notify({ Title = "Auto Restart", Content = string.format("Restarted at wave %d", currentWave), Duration = 3 })
                end
            end
            if currentWave == 1 then hasRestarted = false end
        end
    end
end)
 
Toggle = GameTab:CreateToggle({
    Name = "Auto Sell All Units", CurrentValue = false, Flag = "AutoSellAllUnits",
    Callback = function(Value) State.AutoSellAllUnits = Value end,
})
Slider = GameTab:CreateSlider({
    Name = "Sell All Units on Wave", Range = {0, 300}, Increment = 1, Suffix = "wave",
    CurrentValue = 0, Flag = "AutoSellAllUnitsWave", Info = "0 = disable",
    Callback = function(Value) State.AutoSellAllUnitsWave = Value end,
})
 
task.spawn(function()
    local hasSold = false
    while true do
        task.wait(1)
        if State.AutoSellAllUnits and State.AutoSellAllUnitsWave > 0 then
            local currentWave = Services.Workspace:GetAttribute("Wave") or 0
            local matchFinished = Services.Workspace:GetAttribute("MatchFinished")
            if currentWave >= State.AutoSellAllUnitsWave and not matchFinished and not hasSold then
                local success = pcall(function()
                    local button = Services.Players.LocalPlayer.PlayerGui.GameUI.HUD.RightFrame.Manager.Actions.SellAllButton.TextButton
                    for _, conn in pairs(getconnections(button.MouseButton1Down)) do
                        if conn.Enabled then conn:Fire() end
                    end
                end)
                if success then
                    hasSold = true
                    Rayfield:Notify({ Title = "Auto Sell", Content = string.format("Sold all units at wave %d", currentWave), Duration = 3 })
                end
            end
            if currentWave == 1 then hasSold = false end
        end
    end
end)

GameTab:CreateToggle({
    Name = "Auto Gaara Zone (Shinobi Alliance)",
    CurrentValue = false,
    Flag = "AutoGaaraZone",
    Callback = function(Value)
        State_ShinobiAutoGaaraZone = Value
    end,
})

-- Auto Open Coffin
GameTab:CreateToggle({
    Name = "Auto Open Coffin (Shinobi Alliance)",
    CurrentValue = false,
    Flag = "AutoOpenCoffin",
    Callback = function(Value)
        State_ShinobiAutoOpenCoffin = Value
    end,
})

GameTab:CreateToggle({
    Name = "Auto Kurama Hands",
    CurrentValue = false,
    Flag = "AutoKuramaHands",
    Callback = function(Value)
        State.AutoKuramaHands = Value
    end,
})

task.spawn(function()
    local handLocations = {"1", "2", "3"}
    local lastFiredPrompt = nil
    local lastFiredTime = 0
    local cooldown = 3

    while true do
        task.wait(0.5)
        if not State.AutoKuramaHands then continue end

        local mapFolder = workspace:FindFirstChild("Map")
        if not mapFolder then continue end

        local handsFolder = mapFolder:FindFirstChild("Hands")
        if not handsFolder then continue end

        local locationsFolder = handsFolder:FindFirstChild("Locations")
        if not locationsFolder then continue end

        for _, locationIndex in ipairs(handLocations) do
            local locationPart = locationsFolder:FindFirstChild(locationIndex)
            if not locationPart then continue end

            -- Find ProximityPrompt inside the location
            local prompt = nil
            for _, child in ipairs(locationPart:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    prompt = child
                    break
                end
            end

            if not prompt then continue end
            if prompt == lastFiredPrompt and tick() - lastFiredTime < cooldown then continue end

            -- Teleport to the corresponding Hand part
            local handPart = handsFolder:FindFirstChild("Hand" .. locationIndex)
            if not handPart then continue end

            local character = Services.Players.LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local targetPart = handPart:IsA("BasePart") and handPart
                or handPart:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end

            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 7, 0)
            task.wait(0.3)

            -- Re-check prompt still valid after teleport
            if not prompt or not prompt.Parent then continue end

            local success = pcall(function()
                fireproximityprompt(prompt)
            end)

            if success then
                lastFiredPrompt = prompt
                lastFiredTime = tick()
                break -- Only fire one per cycle
            end
        end
    end
end)

local hasTeleported = false

task.spawn(function()
    while true do
        task.wait(1)
        if not State_ShinobiAutoGaaraZone then continue end

        local runtime = workspace:FindFirstChild("ShinobiAllianceRuntime")
        if not runtime then continue end

        local greenZone = runtime:FindFirstChild("GreenZone")

        -- Reset when zone disappears
        if not greenZone then
            hasTeleported = false
            continue
        end

        if hasTeleported then continue end

        local character = Services.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local zonePart = greenZone:IsA("BasePart") and greenZone
            or greenZone:FindFirstChildWhichIsA("BasePart")
        if not zonePart then continue end

        hrp.CFrame = zonePart.CFrame + Vector3.new(0, 5, 0)

        hasTeleported = true
    end
end)

-- Coffin loop
task.spawn(function()
    local lastTriedCoffin = nil
    local lastAttemptTime = 0

    while true do
        task.wait(1)
        if not State_ShinobiAutoOpenCoffin then
            lastTriedCoffin = nil
            continue
        end

        local runtime = workspace:FindFirstChild("ShinobiAllianceRuntime")
        if not runtime then continue end

        -- Find any coffin anchor
        local coffinAnchor = nil
        for _, child in ipairs(runtime:GetChildren()) do
            if child.Name:find("CoffinAnchor") then
                coffinAnchor = child
                break
            end
        end
        if not coffinAnchor then
            lastTriedCoffin = nil
            continue
        end

        -- Cooldown so we don't spam the same coffin
        if coffinAnchor == lastTriedCoffin and tick() - lastAttemptTime < 3 then
            continue
        end

        -- Find ProximityPrompt inside CoffinAttachment
        local prompt = nil
        local attachment = coffinAnchor:FindFirstChildWhichIsA("Attachment")
        if attachment then
            prompt = attachment:FindFirstChildOfClass("ProximityPrompt")
        end
        if not prompt then continue end

        -- Extract price from ObjectText e.g. "White Coffin (5000 Yen)"
        local objectText = prompt.ObjectText or ""
        local priceStr = objectText:match("%((%d+)%s*[Yy]en%)")
        local price = priceStr and tonumber(priceStr) or 0

        -- Teleport to coffin
        local character = Services.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local anchorPart = coffinAnchor:IsA("BasePart") and coffinAnchor
            or coffinAnchor:FindFirstChildWhichIsA("BasePart")
        if not anchorPart then continue end

        hrp.CFrame = anchorPart.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.3)

        -- Wait for enough money then fire
        if price > 0 then
            local money = Util.getPlayerMoney()
            if money and money < price then
                Util.updateDetailedStatus(string.format("Waiting ¥%d for coffin (%s)", price, coffinAnchor.Name))
                local canContinue = Playback.waitForMoney(price, coffinAnchor.Name)
                if not canContinue then continue end
            end
        end

        -- Re-check prompt still exists after waiting
        if not prompt or not prompt.Parent then
            lastTriedCoffin = nil
            continue
        end

        -- Fire the proximity prompt
        local fireSuccess = pcall(function()
            fireproximityprompt(prompt)
        end)

        if fireSuccess then
            Rayfield:Notify({
                Title = "Coffin Opened",
                Content = string.format("%s (¥%d)", coffinAnchor.Name, price),
                Duration = 3,
            })
            lastTriedCoffin = coffinAnchor
            lastAttemptTime = tick()
        end
    end
end)

local MacroDropdown = Tab:CreateDropdown({
    Name = "Select Macro", Options = {}, CurrentOption = {}, Flag = "MacroDropdown",
    Callback = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        currentMacroName = name
        if name and macroManager[name] then
            macro = macroManager[name]
            Util.updateMacroStatus(string.format("Selected: %s", name))
        end
    end,
})

function Playback.checkAndSwitchMacroForCurrentWorld()
    if not isPlaybackEnabled then return false end
    local category = workspace:GetAttribute("Category")
    local mapName = workspace:GetAttribute("MapName")
    if not category or not mapName then return false end
    local worldKey = Util.getCurrentWorldKey()
    if not worldKey then return false end
    if worldMacroMappings[worldKey] then
        local macroToLoad = worldMacroMappings[worldKey]
        if currentMacroName ~= macroToLoad then
            currentMacroName = macroToLoad
            MacroDropdown:Set(macroToLoad)
            Rayfield:Notify({ Title = "Macro Auto-Selected", Content = string.format("%s for %s", macroToLoad, mapName), Duration = 3 })
            return true
        end
        return true
    else
        if currentMacroName == "" or not currentMacroName then
            Rayfield:Notify({ Title = "No Macro Selected", Content = string.format("No macro mapped for %s", mapName), Duration = 4 })
        end
        return false
    end
end

local MacroInput = Tab:CreateInput({
    Name = "Create New Macro", PlaceholderText = "Enter macro name...", RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if cleanedName == "" then
            Rayfield:Notify({ Title = "Error", Content = "Macro name cannot be empty", Duration = 3 })
            return
        end
        if macroManager[cleanedName] then
            Rayfield:Notify({ Title = "Error", Content = "Macro already exists: " .. cleanedName, Duration = 3 })
            return
        end
        macroManager[cleanedName] = {}
        MacroIO.save(cleanedName, {})
        MacroDropdown:Refresh(MacroIO.getList(), cleanedName)
        Rayfield:Notify({ Title = "Success", Content = "Created macro: " .. cleanedName, Duration = 3 })
    end,
})

Tab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        MacroIO.loadAll()
        MacroDropdown:Refresh(MacroIO.getList())
        -- Refresh world dropdowns
        local macroList = {"None"}
        for name in pairs(macroManager) do table.insert(macroList, name) end
        table.sort(macroList)
        for worldKey, dropdown in pairs(worldDropdowns) do dropdown:Refresh(macroList) end
        Rayfield:Notify({ Title = "Refreshed", Content = "Macro list updated", Duration = 2 })
    end,
})

Tab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({ Title = "Error", Content = "No macro selected", Duration = 3 })
            return
        end
        MacroIO.delete(currentMacroName)
        Rayfield:Notify({ Title = "Deleted", Content = currentMacroName, Duration = 3 })
        currentMacroName = ""
        macro = {}
        MacroDropdown:Refresh(MacroIO.getList())
        Util.updateMacroStatus("Ready")
    end,
})

function GameState.restartMatch()
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("MidMatchVote"):FireServer()
        return true
    end)
    if not success then warn("⚠️ Failed to press restart button:", result) return false end
    return result
end

local RecordToggle = Tab:CreateToggle({
    Name = "Record Macro", CurrentValue = false, Flag = "RecordToggle",
    Callback = function(Value)
        if Value then
            if not currentMacroName or currentMacroName == "" then
                Rayfield:Notify({ Title = "Recording Error", Content = "Please select a macro first!", Duration = 3 })
                RecordToggle:Set(false)
                return
            end
            local currentWave = workspace:GetAttribute("Wave") or 0
            local matchFinished = workspace:GetAttribute("MatchFinished")
            if currentWave >= 1 and not matchFinished then
                isRecording = true
                recordingHasStarted = false
                Rayfield:Notify({ Title = "Mid-Game Detected", Content = "Attempting to restart game...", Duration = 3 })
                local restartSuccess = false
                for attempt = 1, 3 do
                    GameState.restartMatch()
                    local waitStart = tick()
                    while tick() - waitStart < 2 do
                        local wave = workspace:GetAttribute("Wave") or 0
                        if wave == 0 then restartSuccess = true break end
                        task.wait(0.2)
                    end
                    if restartSuccess then break end
                    if attempt < 3 then task.wait(0.3) end
                end
                if not restartSuccess then
                    Rayfield:Notify({ Title = "Restart Failed", Content = "Recording from current wave...", Duration = 5 })
                    recordingHasStarted = true
                    gameStartTime = tick()
                    recordingUnitCounter = {}
                    recordingUUIDToTag = {}
                    macro = {}
                    UnitTracker.startUpgradePolling()
                    Util.updateMacroStatus("Recording from Wave " .. currentWave)
                else
                    Util.updateMacroStatus("Recording enabled - Restarting game...")
                end
            elseif matchFinished then
                isRecording = true
                recordingHasStarted = false
                Util.updateMacroStatus("Recording enabled - Waiting for game to start...")
                Rayfield:Notify({ Title = "Recording Ready", Content = "Recording will start when game begins (Wave 1)", Duration = 3 })
            else
                isRecording = true
                recordingHasStarted = false
                Util.updateMacroStatus("Recording enabled - Waiting for game to start...")
                Rayfield:Notify({ Title = "Recording Ready", Content = "Recording will start when game begins (Wave 1)", Duration = 3 })
            end
        else
            if recordingHasStarted then
                local actionCount = #macro
                GameState.stopRecording()
                Rayfield:Notify({ Title = "Recording Stopped", Content = string.format("Saved %d actions", actionCount), Duration = 3 })
            else
                isRecording = false
                Util.updateMacroStatus("Ready")
            end
            isRecording = false
            recordingHasStarted = false
            UnitTracker.stopUpgradePolling()
            Util.updateMacroStatus("Ready")
            Util.updateDetailedStatus("Ready")
        end
    end,
})

function Playback.playMacro()
    if not macro or #macro == 0 then
        Util.updateDetailedStatus("No macro to play")
        return
    end
    Util.updateDetailedStatus("Starting playback...")
    UnitTracker.clearSpawnIdMappings()
    local totalActions = #macro
    local startTime = tick()
    for i, action in ipairs(macro) do
        local matchFinished = workspace:GetAttribute("MatchFinished")
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            Util.updateDetailedStatus("Game ended - stopped playback")
            UnitTracker.clearSpawnIdMappings()
            return
        end
        if not ignoreTiming then
            local actionTime = tonumber(action.Time)
            local currentElapsedTime = tick() - startTime
            local waitTime = actionTime - currentElapsedTime
            if waitTime > 1 then
                local waitStart = tick()
                while (tick() - waitStart) < waitTime do
                    matchFinished = workspace:GetAttribute("MatchFinished")
                    if not isPlaybackEnabled or not gameInProgress or matchFinished then
                        Util.updateDetailedStatus("Game ended - stopped playback")
                        UnitTracker.clearSpawnIdMappings()
                        return
                    end
                    local remaining = waitTime - (tick() - waitStart)
                    if remaining > 1 then
                        Util.updateDetailedStatus(string.format("(%d/%d) Waiting %.1fs for %s", i, totalActions, remaining, action.Unit or "next action"))
                    end
                    task.wait(0.5)
                end
            elseif waitTime > 0 then
                task.wait(waitTime)
            end
        else
            if i > 1 then
                Util.updateDetailedStatus(string.format("(%d/%d) Ready for next action", i, totalActions))
                task.wait(0.1)
            end
        end
        matchFinished = workspace:GetAttribute("MatchFinished")
        if not isPlaybackEnabled or not gameInProgress or matchFinished then
            Util.updateDetailedStatus("Game ended - stopped playback")
            UnitTracker.clearSpawnIdMappings()
            return
        end
        if action.Type == "spawn_unit" then
            Playback.executePlacement(action, i, totalActions)
        elseif action.Type == "upgrade_unit" then
            Playback.executeUpgrade(action, i, totalActions)
        elseif action.Type == "sell_unit" then
            Playback.executeSell(action, i, totalActions)
        elseif action.Type == "use_ability" then
            if ignoreTiming then
                local abilityTime = tonumber(action.Time)
                local delayTime = math.max(0, abilityTime - (tick() - startTime))
                task.spawn(function()
                    task.wait(delayTime)
                    local mf = workspace:GetAttribute("MatchFinished")
                    if isPlaybackEnabled and gameInProgress and not mf then
                        Playback.executeAbility(action, i, totalActions)
                    end
                end)
                Util.updateDetailedStatus(string.format("(%d/%d) Scheduled ability for %s", i, totalActions, action.Unit))
            else
                Playback.executeAbility(action, i, totalActions)
            end
        elseif action.Type == "pick_valkyrie" then
            Playback.executePickValkyrie(action, i, totalActions)
        elseif action.Type == "place_valkyrie" then
            Playback.executePlaceValkyrie(action, i, totalActions)
        elseif action.Type == "shop_purchase" then
            Playback.executeShopPurchase(action, i, totalActions)
        end
        task.wait(0.1)
    end
    Util.updateMacroStatus("Playback Complete")
    Util.updateDetailedStatus(string.format("Completed %d/%d actions ✓", totalActions, totalActions))
end

function Playback.autoPlaybackLoop()
    if playbackLoopRunning then return end
    playbackLoopRunning = true
    while isPlaybackEnabled do
        while not gameInProgress and isPlaybackEnabled do
            Util.updateMacroStatus("Waiting for game to start...")
            Util.updateDetailedStatus("Waiting for wave 1...")
            task.wait(0.5)
        end
        if not isPlaybackEnabled then break end
        if not gameInProgress then task.wait(0.5) continue end
        local worldKey = Util.getCurrentWorldKey()
        if worldKey and worldMacroMappings[worldKey] then
            local macroToLoad = worldMacroMappings[worldKey]
            if currentMacroName ~= macroToLoad then
                currentMacroName = macroToLoad
                Rayfield:Notify({ Title = "Auto-Switched Macro", Content = string.format("%s for %s", macroToLoad, worldKey), Duration = 3 })
                MacroDropdown:Set(macroToLoad)
            end
        end
        if not currentMacroName or currentMacroName == "" then
            Util.updateMacroStatus("Error: No macro selected")
            Util.updateDetailedStatus("Select a macro to continue")
            break
        end
        local loadedMacro = MacroIO.load(currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            Util.updateMacroStatus("Error: Failed to load macro")
            Util.updateDetailedStatus("Could not load: " .. tostring(currentMacroName))
            break
        end
        macro = loadedMacro
        UnitTracker.clearSpawnIdMappings()
        Util.updateMacroStatus(string.format("Executing: %s (%d actions)", currentMacroName, #macro))
        Util.updateDetailedStatus("Starting playback...")
        Rayfield:Notify({ Title = "Playback Started", Content = currentMacroName .. " (" .. #macro .. " actions)", Duration = 3 })
        currentPlaybackThread = coroutine.running()
        Playback.playMacro()
        currentPlaybackThread = nil
        while gameInProgress and isPlaybackEnabled do task.wait(0.5) end
        if not isPlaybackEnabled then break end
        UnitTracker.clearSpawnIdMappings()
        Util.updateMacroStatus("Game ended - waiting for next...")
        Util.updateDetailedStatus("Ready for next game")
        task.wait(2)
    end
    Util.updateMacroStatus("Playback Stopped")
    Util.updateDetailedStatus("Ready")
    playbackLoopRunning = false
end

local PlaybackToggle = Tab:CreateToggle({
    Name = "Playback Macro", CurrentValue = false, Flag = "PlaybackToggle",
    Callback = function(Value)
        if Value then
            task.wait(0.1)
            if not currentMacroName or currentMacroName == "" then
                Rayfield:Notify({ Title = "Playback Error", Content = "Please select a macro first!", Duration = 3 })
                return
            end
            local loadedMacro = macroManager[currentMacroName] or MacroIO.load(currentMacroName)
            if not loadedMacro or #loadedMacro == 0 then
                Rayfield:Notify({ Title = "Playback Error", Content = "Macro is empty or doesn't exist", Duration = 3 })
                return
            end
            if playbackLoopRunning then return end
            macro = loadedMacro
            local currentWave = workspace:GetAttribute("Wave") or 0
            if currentWave >= 1 and not workspace:GetAttribute("MatchFinished") then
                Rayfield:Notify({ Title = "Mid-Game Detected", Content = "Restarting game for accurate playback...", Duration = 4 })
                GameState.restartMatch()
                gameInProgress = false
                gameStartTime = 0
            end
            isPlaybackEnabled = true
            Util.updateMacroStatus("Playback Enabled - Waiting for game...")
            Rayfield:Notify({ Title = "Playback Enabled", Content = "Macro will playback: " .. currentMacroName, Duration = 4 })
            task.spawn(Playback.autoPlaybackLoop)
        else
            isPlaybackEnabled = false
            local timeout = 0
            while playbackLoopRunning and timeout < 20 do task.wait(0.1) timeout = timeout + 1 end
            if playbackLoopRunning then playbackLoopRunning = false end
            Util.updateMacroStatus("Playback Disabled")
            Rayfield:Notify({ Title = "Playback Disabled", Content = "Stopped playback loop", Duration = 3 })
        end
    end,
})

Tab:CreateToggle({
    Name = "Ignore Timing", CurrentValue = false, Flag = "IgnoreTimingToggle",
    Callback = function(Value) ignoreTiming = Value end,
})

Div = Tab:CreateDivider()

Button1 = Tab:CreateButton({
    Name = "Export Macro (Copy JSON)",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({ Title = "Error", Content = "No macro selected", Duration = 3 }) return
        end
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({ Title = "Error", Content = "Macro is empty", Duration = 3 }) return
        end
        local json = game:GetService("HttpService"):JSONEncode(macroData)
        if setclipboard then
            setclipboard(json)
            Rayfield:Notify({ Title = "Exported", Content = string.format("Copied %s (%d actions)", currentMacroName, #macroData), Duration = 3 })
        else
            print(json)
            Rayfield:Notify({ Title = "Exported", Content = "JSON printed to console", Duration = 3 })
        end
    end,
})

Button = Tab:CreateButton({
    Name = "Export Macro via Webhook",
    Callback = function()
        if not ValidWebhook or ValidWebhook == "" then
            Rayfield:Notify({ Title = "Error", Content = "No webhook URL set!", Duration = 3 }) return
        end
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({ Title = "Error", Content = "No macro selected", Duration = 3 }) return
        end
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({ Title = "Error", Content = "Macro is empty", Duration = 3 }) return
        end
        local unitNames = {}
        local seenUnits = {}
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                if not seenUnits[unitName] then table.insert(unitNames, unitName) seenUnits[unitName] = true end
            end
        end
        table.sort(unitNames)
        local unitsText = #unitNames > 0 and table.concat(unitNames, ", ") or "No units"
        local jsonContent = Services.HttpService:JSONEncode(macroData)
        local boundary = "----WebKitFormBoundary" .. tostring(os.time())
        local fileName = currentMacroName .. ".json"
        local body = string.format(
            "--%s\r\nContent-Disposition: form-data; name=\"payload_json\"\r\nContent-Type: application/json\r\n\r\n%s\r\n--%s\r\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"%s\"\r\nContent-Type: application/json\r\n\r\n%s\r\n--%s--\r\n",
            boundary, Services.HttpService:JSONEncode({ username = "LixHub", content = "Units: " .. unitsText }), boundary, fileName, jsonContent, boundary
        )
        local requestFunc = syn and syn.request or request or http_request or (fluxus and fluxus.request) or getgenv().request
        if not requestFunc then Rayfield:Notify({ Title = "Error", Content = "Executor doesn't support HTTP requests", Duration = 3 }) return end
        local success, response = pcall(function()
            return requestFunc({ Url = ValidWebhook, Method = "POST", Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundary }, Body = body })
        end)
        if success and response and (response.StatusCode == 204 or response.StatusCode == 200) then
            Rayfield:Notify({ Title = "Macro Sent ✓", Content = string.format("Sent %s.json", currentMacroName), Duration = 3 })
        else
            Rayfield:Notify({ Title = "Error", Content = "Failed to send webhook", Duration = 3 })
        end
    end,
})

local ImportInput = Tab:CreateInput({
    Name = "Import Macro (Paste JSON)", PlaceholderText = "Paste JSON here...", RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then return end
        local success, importData = pcall(function() return game:GetService("HttpService"):JSONDecode(text) end)
        if not success then Rayfield:Notify({ Title = "Import Error", Content = "Invalid JSON format", Duration = 3 }) return end
        if type(importData) ~= "table" or #importData == 0 then Rayfield:Notify({ Title = "Import Error", Content = "No actions found in JSON", Duration = 3 }) return end
        local macroName = "Imported_" .. os.time()
        macroManager[macroName] = importData
        MacroIO.save(macroName, importData)
        MacroDropdown:Refresh(MacroIO.getList(), macroName)
        Rayfield:Notify({ Title = "Import Success", Content = string.format("%s (%d actions)", macroName, #importData), Duration = 4 })
    end,
})

Tab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({ Title = "Error", Content = "No macro selected", Duration = 3 }) return
        end
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({ Title = "Error", Content = "Macro is empty", Duration = 3 }) return
        end
        local unitCounts = {}
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                unitCounts[unitName] = (unitCounts[unitName] or 0) + 1
            end
        end
        if next(unitCounts) == nil then
            Rayfield:Notify({ Title = "No Units", Content = "No placements found in macro", Duration = 3 }) return
        end
        local unitList = {}
        for unitName in pairs(unitCounts) do table.insert(unitList, string.format("%s", unitName)) end
        table.sort(unitList)
        for _, line in ipairs(unitList) do print("  " .. line) end
        Rayfield:Notify({ Title = "Macro Units", Content = table.concat(unitList, ", "), Duration = 5 })
    end,
})

Div2 = Tab:CreateDivider()

WebhookInput = WebhookTab:CreateInput({
    Name = "Input Webhook", CurrentValue = "", PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false, Flag = "WebhookInput",
    Callback = function(Text)
        local trimmed = Text:match("^%s*(.-)%s*$")
        if trimmed == "" then ValidWebhook = nil return end
        ValidWebhook = trimmed:match("^https://") and trimmed or nil
    end,
})

UserIDInput = WebhookTab:CreateInput({
    Name = "Input Discord ID (mention rares)", CurrentValue = "", PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false, Flag = "WebhookInputUserID",
    Callback = function(Text) Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$") end,
})

WebhookToggle = WebhookTab:CreateToggle({
    Name = "Send On Stage Finished", CurrentValue = false, Flag = "SendWebhookOnStageFinished",
    Callback = function(Value) State.SendStageCompletedWebhook = Value end,
})
 
WebhookToggle = WebhookTab:CreateToggle({
    Name = "Send On Match Restarted", CurrentValue = false, Flag = "SendWebhookOnMatchRestarted",
    Callback = function(Value) State.SendMatchRestartedWebhook = Value end,
})
 
TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then Webhook.send("test")
        else Util.notify(nil, "Error: No webhook URL set!") end
    end,
})

workspace:GetAttributeChangedSignal("Wave"):Connect(function()
    local wave = workspace:GetAttribute("Wave") or 0
    if wave < lastWave then
        if State.SendMatchRestartedWebhook and not hasRecentlyRestarted then
            Webhook.send("match_restart", nil, currentGameInfo, lastWave)
        end
        hasRecentlyRestarted = true
        if gameInProgress then gameInProgress = false gameStartTime = 0 end
        if isRecording and recordingHasStarted then
            local actionCount = #macro
            GameState.stopRecording()
            Rayfield:Notify({ Title = "Recording Stopped", Content = string.format("Game restarted - saved %d actions", actionCount), Duration = 3 })
        end
        if isRecording then
            recordingHasStarted = false
            macro = {}
            UnitTracker.clearSpawnIdMappings()
            Util.updateMacroStatus("Recording enabled - Waiting for wave 1...")
        end
        if isPlaybackEnabled and playbackLoopRunning then
            gameInProgress = false
            gameStartTime = 0
            UnitTracker.clearSpawnIdMappings()
            Util.updateMacroStatus("Game restarted - waiting for wave 1...")
        end
        lastWave = 0
        task.spawn(function() task.wait(2) hasRecentlyRestarted = false end)
        return
    end
    lastWave = wave
    if wave >= 1 and not gameInProgress then
        gameInProgress = true
        gameStartTime = tick()
        currentGameInfo = {
            MapName = workspace:GetAttribute("MapName") or "Unknown",
            Act = workspace:GetAttribute("ActName") or "Unknown",
            Category = workspace:GetAttribute("DifficultyName") or "Unknown",
            StartTime = tick()
        }
        task.spawn(function()
            local timeout = 0
            while not RequestData and timeout < 20 do task.wait(0.5) timeout = timeout + 1 end
            if RequestData then
                beforeRewardData = Util.deepCopy(RequestData:InvokeServer())
            end
        end)
        if isRecording and not recordingHasStarted then
            recordingHasStarted = true
            gameStartTime = tick()
            recordingUnitCounter = {}
            recordingUUIDToTag = {}
            macro = {}
            UnitTracker.startUpgradePolling()
            Util.updateMacroStatus("Recording...")
            Util.updateDetailedStatus("Recording in progress - " .. currentMacroName)
            Rayfield:Notify({ Title = "Recording Started", Content = string.format("Wave %d detected - recording: %s", wave, currentMacroName), Duration = 3 })
        end
    end
end)

workspace:GetAttributeChangedSignal("MatchFinished"):Connect(function()
    local matchFinished = workspace:GetAttribute("MatchFinished")
    if matchFinished and gameInProgress then
        afterRewardData = Util.deepCopy(RequestData:InvokeServer())
        if State.SendStageCompletedWebhook then
            local currentHealth = workspace:GetAttribute("Health") or 0
            local gameResult = currentHealth > 0
            local gameDuration = "Unknown"
            if currentGameInfo.StartTime then
                local duration = tick() - currentGameInfo.StartTime
                gameDuration = string.format("%dm %ds", math.floor(duration / 60), math.floor(duration % 60))
            end
            Webhook.send("game_end", gameResult, currentGameInfo, gameDuration)
        end
        gameInProgress = false
        gameStartTime = 0
        lastWave = 0
        if isPlaybackEnabled then UnitTracker.clearSpawnIdMappings() end
        if isRecording and recordingHasStarted then
            local actionCount = #macro
            GameState.stopRecording()
            Rayfield:Notify({ Title = "Recording Auto-Stopped", Content = string.format("Saved %d actions to %s", actionCount, currentMacroName), Duration = 4 })
            RecordToggle:Set(false)
            recordingHasStarted = false
        end
        if isPlaybackEnabled then
            UnitTracker.clearSpawnIdMappings()
            Util.updateMacroStatus("Game ended - waiting for next game...")
        end
        if not isRecording and not isPlaybackEnabled then
            Util.updateMacroStatus("Ready")
            Util.updateDetailedStatus("Ready")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoStartGame then
            local currentWave = workspace:GetAttribute("Wave") or 0
            if currentWave == 0 then
                if isPlaybackEnabled then Playback.checkAndSwitchMacroForCurrentWorld() task.wait(0.5) end
                task.wait(2)
                local success = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RF"):WaitForChild("Vote"):InvokeServer(true)
                    local skipButton = Services.Players.LocalPlayer.PlayerGui.GameUI.HUD.Vote.Button.TextButton
                    for _, startConn in pairs(getconnections(skipButton.MouseButton1Up)) do
                        if startConn.Enabled then startConn:Fire() end
                    end
                end)
                if success then
                    Rayfield:Notify({ Title = "Auto Start", Content = "Voting to start game...", Duration = 2 })
                    task.wait(5)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        AutoJoin.checkAndExecuteHighestPriority()
    end
end)

task.spawn(function()
    local timeout = 0
    while not Util.isGameDataLoaded() and timeout < 20 do task.wait(0.5) timeout = timeout + 1 end
    if Util.isGameDataLoaded() then Loader.buildMapLookup() end
end)

task.spawn(function()
    local lastCheckMinute = -1
    while true do
        task.wait(5)
        if State.ReturnToLobbyOnNewChallenge then
            local currentTime = os.date("*t")
            local currentMinute = currentTime.min
            if (currentMinute == 0 or currentMinute == 30) and currentMinute ~= lastCheckMinute then
                lastCheckMinute = currentMinute
                if Services.Workspace:GetAttribute("MatchFinished") then
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("WaveService"):WaitForChild("RE"):WaitForChild("ToLobby"):FireServer()
                end
                State.NewChallengesAvailable = true
                Rayfield:Notify({ Title = "New Challenges Available", Content = "Will return to lobby when game ends", Duration = 4 })
            end
            if currentMinute > 1 and currentMinute < 30 then lastCheckMinute = -1
            elseif currentMinute > 31 then lastCheckMinute = -1 end
        else
            lastCheckMinute = -1
            State.NewChallengesAvailable = false
        end
    end
end)

task.spawn(function()
    while true do
        while not workspace:GetAttribute("MatchFinished") do task.wait(0.5) end
        task.wait(1)
        if State.NewChallengesAvailable and State.ReturnToLobbyOnNewChallenge then
            local success = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5):WaitForChild("ToLobby", 5):FireServer()
            end)
            if success then
                Rayfield:Notify({ Title = "Returned to Lobby", Content = "Ready to join new challenges", Duration = 3 })
                State.NewChallengesAvailable = false
            end
        else
            local actions = {}
            if State.AutoRetry then table.insert(actions, "retry") end
            if State.AutoNext then table.insert(actions, "next") end
            if State.AutoLobby then table.insert(actions, "lobby") end
            if #actions > 0 then
                local actionWorked = false
                for _, action in ipairs(actions) do
                    if actionWorked then break end
                    local maxAttempts = 3
                    for attempt = 1, maxAttempts do
                        local success = false
                        local remoteExists = false
                        if action == "retry" then
                            success, remoteExists = pcall(function()
                                local service = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5)
                                local remote = service:FindFirstChild("VoteReplay")
                                if remote then remote:FireServer() return true else return false end
                            end)
                            if success and remoteExists then Rayfield:Notify({ Title = "Auto Retry", Content = string.format("Voting for Replay (attempt %d)...", attempt), Duration = 2 })
                            elseif not remoteExists then break end
                        elseif action == "next" then
                            success, remoteExists = pcall(function()
                                local service = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5)
                                local remote = service:FindFirstChild("NextMap")
                                if remote then remote:FireServer() return true else return false end
                            end)
                            if success and remoteExists then Rayfield:Notify({ Title = "Auto Next", Content = string.format("Voting for Next Stage (attempt %d)...", attempt), Duration = 2 })
                            elseif not remoteExists then break end
                        elseif action == "lobby" then
                            success = pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_knit@1.7.0", 5):WaitForChild("knit", 5):WaitForChild("Services", 5):WaitForChild("WaveService", 5):WaitForChild("RE", 5):WaitForChild("ToLobby", 5):FireServer()
                            end)
                            if success then Rayfield:Notify({ Title = "Auto Lobby", Content = "Returning to Lobby...", Duration = 2 }) actionWorked = true break
                            else break end
                        end
                        if remoteExists or action == "lobby" then
                            local waitStart = tick()
                            while tick() - waitStart < 10 do
                                if not workspace:GetAttribute("MatchFinished") then actionWorked = true break end
                                task.wait(0.5)
                            end
                            if actionWorked then break end
                            if attempt < maxAttempts then task.wait(1) end
                        end
                    end
                end
            end
        end
        while workspace:GetAttribute("MatchFinished") do task.wait(0.5) end
    end
end)

MacroIO.ensureFolders()
MacroIO.loadAll()
worldMacroMappings = MacroIO.loadWorldMappings()
MacroDropdown:Refresh(MacroIO.getList())

task.spawn(Loader.storyStages)
task.spawn(Loader.legendStages)
task.spawn(Loader.virtualStages)
task.spawn(Loader.challengeModifiers)
task.spawn(Loader.raidStages)

task.spawn(function()
    task.wait(2)
    createAutoSelectDropdowns()
end)

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

task.spawn(function()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RayfieldToggle"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	if gethui then
		screenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(screenGui)
		screenGui.Parent = Services.CoreGui
	elseif Services.CoreGui:FindFirstChild("RobloxGui") then
		screenGui.Parent = Services.CoreGui:FindFirstChild("RobloxGui")
	else
		screenGui.Parent = Services.CoreGui
	end

	local toggleButton = Instance.new("ImageButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Parent = screenGui
	toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	toggleButton.BorderSizePixel = 0
	toggleButton.Position = UDim2.new(0, 50, 0, 50)
	toggleButton.Size = UDim2.new(0, 50, 0, 50)
	toggleButton.Image = "rbxassetid://139436994731049"
	toggleButton.ScaleType = Enum.ScaleType.Fit
	toggleButton.ImageTransparency = 0
	toggleButton.BackgroundTransparency = 0
	toggleButton.ZIndex = 10000

	-- ✂ No `corner` local — parent via second arg, set CornerRadius in one line
	Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

	local shadow = Instance.new("ImageLabel", toggleButton) -- ✂ No separate .Parent line
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.ZIndex = toggleButton.ZIndex - 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)

	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	toggleButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = toggleButton.Position

			-- ✂ No `connection` local — disconnect inside Changed directly
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	toggleButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	-- ✂ `update()` function eliminated — logic inlined here directly
	Services.UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			toggleButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + (input.Position.X - dragStart.X),
				startPos.Y.Scale,
				startPos.Y.Offset + (input.Position.Y - dragStart.Y)
			)
		end
	end)

	local clickStartPos, clickStartTime = nil, 0

	toggleButton.MouseButton1Down:Connect(function()
		clickStartPos = toggleButton.Position
		clickStartTime = tick()
	end)

	toggleButton.MouseButton1Up:Connect(function()
		if clickStartPos then
			-- ✂ No `timeDelta`/`positionDelta`/`moveDistance` locals — all inlined
			if (tick() - clickStartTime) < 0.2 and
				math.sqrt(
					(toggleButton.Position.X.Offset - clickStartPos.X.Offset)^2 +
					(toggleButton.Position.Y.Offset - clickStartPos.Y.Offset)^2
				) < 5 then
					if Rayfield:IsVisible() then
						Rayfield:SetVisibility(false)
					else
						Rayfield:SetVisibility(true)
					end
			end
		end
		clickStartPos = nil
	end)

	toggleButton.MouseEnter:Connect(function()
		Services.TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 55, 0, 55),
			BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		}):Play()
	end)

	toggleButton.MouseLeave:Connect(function()
		Services.TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 50, 0, 50),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		}):Play()
	end)

	Rayfield.Destroying:Connect(function()
		screenGui:Destroy()
	end)
end)

task.spawn(function()
    task.wait(2)
    local savedMacroName = Rayfield.Flags["MacroDropdown"]
    if type(savedMacroName) == "table" then savedMacroName = savedMacroName[1] end
    if savedMacroName and savedMacroName ~= "" and type(savedMacroName) == "string" then
        currentMacroName = savedMacroName
        local loadedMacro = MacroIO.load(currentMacroName)
        if loadedMacro then
            macro = loadedMacro
            macroManager[currentMacroName] = loadedMacro
        end
    end
    MacroDropdown:Refresh(MacroIO.getList())
end)
