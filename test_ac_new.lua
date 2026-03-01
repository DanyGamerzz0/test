local DEBUG = false
local NOTIFICATION_ENABLED = true
local script_version = "V0.18"
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
    HttpService       = game:GetService("HttpService"),
    Players           = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace         = game:GetService("Workspace"),
    RunService        = game:GetService("RunService"),
    Lighting          = game:GetService("Lighting"),
    VirtualUser       = game:GetService("VirtualUser"),
}

-- ============================================================
-- GAME STATE (Game Tab)
-- ============================================================
local State = {
    -- Player / visual
    AntiAfkKickEnabled       = false,
    EnableLowPerfMode        = false,
    EnableBlackScreen        = false,
    EnableLimitFPS           = false,
    SelectedFPS              = 60,
    StreamerModeEnabled      = false,
    DeleteEntities           = false,
    childAddedConnection     = nil,

    -- Game flow votes
    AutoVoteStart            = false,
    AutoVoteRetry            = false,
    AutoVoteNext             = false,
    AutoVoteLobby            = false,

    -- Wave skip
    AutoSkipWaves            = false,
    AutoSkipUntilWave        = 0,

    -- Auto Sell
    AutoSellEnabled          = false,
    AutoSellWave             = 10,
    AutoSellFarmEnabled      = false,
    AutoSellFarmWave         = 15,

    -- Failsafes
    ReturnToLobbyAfterGames  = 0,
    ReturnToLobbyFailsafe    = false,
    ReturnToLobbyIfNeverEnds = false,
    failsafeActive           = false,

    -- Session counters
    TotalGamesPlayed         = 0,
    TotalWins                = 0,
    TotalLosses              = 0,

    -- Auto equip
    AutoEquipMacroUnits      = false,

    -- Boss Rush
    AutoSelectCardBossRush   = false,

    -- Retry config
    AutoRetryAttempts        = 3,
    AutoRetryDelay           = 2,

    AutoNextExpedition = false,
}

local Webhook = {
    url              = nil,
    discordUserId    = nil,
    sessionItems     = {},
    gameStartTime    = 0,
    lastWave         = 0,
    startStats       = {},
    endStats         = {},
    currentMapName   = "Unknown Map",
    gameResult       = "Unknown",
    newUnitsThisGame = {},
    itemNameCache    = {},
}

-- ============================================================
-- WEBHOOK MODULE
-- ============================================================

function Webhook.formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%d:%02d", m, s)
end

function Webhook.captureStats()
    local stats  = {}
    local player = Services.Players.LocalPlayer
    if player and player:FindFirstChild("_stats") then
        for _, obj in pairs(player._stats:GetChildren()) do
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                stats[obj.Name] = obj.Value
            end
        end
    end
    return stats
end

function Webhook.getStatChanges()
    local changes = {}
    for name, endVal in pairs(Webhook.endStats) do
        if name ~= "resource" then
            local startVal = Webhook.startStats[name] or 0
            local diff     = endVal - startVal
            if diff > 0 then changes[name] = diff end
        end
    end
    return changes
end

function Webhook.getItemDisplayName(id)
    if Webhook.itemNameCache[id] then return Webhook.itemNameCache[id] end
    pcall(function()
        local itemsPath = Services.ReplicatedStorage.Framework.Data.Items
        for _, ms in pairs(itemsPath:GetChildren()) do
            if ms:IsA("ModuleScript") then
                local ok, data = pcall(require, ms)
                if ok and data then
                    for _, d in pairs(data) do
                        if type(d) == "table" and d.id == id and d.name then
                            Webhook.itemNameCache[id] = d.name
                            return
                        end
                    end
                end
            end
        end
    end)
    if not Webhook.itemNameCache[id] then
        Webhook.itemNameCache[id] = id:gsub("_", " "):gsub("(%w)(%w*)", function(a, b) return a:upper() .. b:lower() end)
    end
    return Webhook.itemNameCache[id]
end

function Webhook.startTracking(mapName)
    Webhook.sessionItems     = {}
    Webhook.gameStartTime    = tick()
    Webhook.startStats       = Webhook.captureStats()
    Webhook.currentMapName   = mapName or "Unknown Map"
    Webhook.gameResult       = "Unknown"
    Webhook.newUnitsThisGame = {}
    Webhook.lastWave         = 0
end

function Webhook.onUnitAdded(displayName)
    table.insert(Webhook.newUnitsThisGame, displayName)
end

function Webhook.send()
    if not Webhook.url or Webhook.url == "" then return end
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    if not requestFunc then return end

    local duration    = tick() - Webhook.gameStartTime
    local playerName  = "||" .. Services.Players.LocalPlayer.Name .. "||"
    local timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local embedColor  = (Webhook.gameResult == "Victory") and 0x57F287 or 0xED4245
    local titleText   = (Webhook.gameResult == "Victory") and "Stage Finished!" or "Stage Failed!"

    Webhook.endStats = Webhook.captureStats()
    local statChanges = Webhook.getStatChanges()

    local rewardsText = ""
    for _, unitName in ipairs(Webhook.newUnitsThisGame) do
        rewardsText = rewardsText .. "+1 " .. unitName .. "\n"
    end
    for itemId, qty in pairs(Webhook.sessionItems) do
        rewardsText = rewardsText .. "+" .. qty .. " " .. Webhook.getItemDisplayName(itemId) .. "\n"
    end
    for statName, change in pairs(statChanges) do
        local total = Webhook.endStats[statName] or 0
        local display = statName:gsub("_", " "):gsub("(%w)(%w*)", function(a,b) return a:upper()..b:lower() end)
        rewardsText = rewardsText .. string.format("+%d %s [%d]\n", change, display, total)
    end
    rewardsText = rewardsText ~= "" and rewardsText:gsub("\n$", "") or "No rewards gained"

    local winRate = State.TotalGamesPlayed > 0
        and string.format("%.1f%%", (State.TotalWins / State.TotalGamesPlayed) * 100)
        or "0.0%"

    -- Only ping user if a new unit dropped
    local content = (#Webhook.newUnitsThisGame > 0 and Webhook.discordUserId)
        and string.format("<@%s>", Webhook.discordUserId)
        or ""

    local payload = Services.HttpService:JSONEncode({
        username = "LixHub",
        content  = content,
        embeds   = {{
            title       = titleText,
            description = Webhook.currentMapName .. " — " .. Webhook.gameResult,
            color       = embedColor,
            fields      = {
                { name = "Player",        value = playerName,                     inline = true  },
                { name = "Duration",      value = Webhook.formatTime(duration),   inline = true  },
                { name = "Waves",         value = tostring(Webhook.lastWave),     inline = true  },
                { name = "Rewards",       value = rewardsText,                    inline = false },
                { name = "Session",
                  value = string.format("Games: %d | Wins: %d | Losses: %d | Win Rate: %s",
                      State.TotalGamesPlayed, State.TotalWins, State.TotalLosses, winRate),
                  inline = false },
            },
            footer    = { text = "LixHub" },
            timestamp = timestamp,
        }}
    })

    pcall(function()
        requestFunc({
            Url     = Webhook.url,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = payload,
        })
    end)

    Webhook.newUnitsThisGame = {}
    Webhook.sessionItems     = {}
end

-- ============================================================
-- DUNGEON MODULE
-- ============================================================
local Dungeon = {}

do
    local _Loader, _DungeonServiceCore, _GUIService, _LevelNodes, _Remote

    local function getDeps()
        if _Loader then return true end
        local ok, err = pcall(function()
            _Loader             = require(Services.ReplicatedStorage.Framework.Loader)
            _DungeonServiceCore = _Loader.load_core_service(script, "DungeonServiceCore")
            _GUIService         = _Loader.load_client_service(script, "GUIService")
            _LevelNodes         = require(Services.ReplicatedStorage.Framework.Data.LevelNodes)
            _Remote             = Services.ReplicatedStorage
                :WaitForChild("endpoints")
                :WaitForChild("client_to_server")
                :WaitForChild("request_start_dungeon")
        end)
        if not ok then
            warn("[AutoDungeon] Failed to load dependencies: " .. tostring(err))
            return false
        end
        return true
    end

    Dungeon.isRunning = false
    Dungeon.stopFlag  = false

    Dungeon.config = {
        mode = "_JojosMode1",
    }

    local PATH_ORDER = {
        { path = 1, maxNodes = 2  },
        { path = 2, maxNodes = 10 },
        { path = 3, maxNodes = 10 },
        { path = 6, maxNodes = 10 },
        { path = 4, maxNodes = 1  },
        { path = 5, maxNodes = 1  },
        { path = 8, maxNodes = 1  },
        { path = 9, maxNodes = 1  },
        { path = 7, maxNodes = 1  },
    }

    local function setStatus(msg)
        print("[AutoDungeon] " .. msg)
    end

    local function getRoomType(gamemode, path, node)
        local nodeData = _LevelNodes[gamemode]
        if not nodeData or not nodeData.Nodes then return "Unknown" end
        local pathNodes = nodeData.Nodes[path]
        if not pathNodes then return "Unknown" end
        local nodeInfo = pathNodes[node]
        if not nodeInfo then return "Unknown" end
        if nodeInfo.FinalNode   then return "Boss"   end
        if nodeInfo.LinkingNode then return "Linker" end
        return nodeInfo.Type or "Normal"
    end

    local function joinRoom(gamemode, path, node)
        local ok, err = pcall(function()
            _Remote:InvokeServer(gamemode, path, node)
        end)
        if ok then
            setStatus(string.format("✓ Joined Path %d, Node %d", path, node))
        else
            warn(string.format("[AutoDungeon] ✗ Failed Path %d, Node %d: %s", path, node, tostring(err)))
        end
        return ok
    end

    function Dungeon.run()
        if Dungeon.isRunning then setStatus("Already running!") return end
        if not getDeps() then setStatus("Error: Failed to load game services") return end
        local gamemode    = Dungeon.config.mode
        Dungeon.isRunning = true
        Dungeon.stopFlag  = false
        task.spawn(function()
            setStatus("Starting — " .. (gamemode == "_JojosMode1" and "Roguelike" or "Normal"))
            local joined  = 0
            local skipped = 0
            for _, entry in PATH_ORDER do
                if Dungeon.stopFlag then break end
                local path     = entry.path
                local maxNodes = entry.maxNodes
                for node = 1, maxNodes do
                    if Dungeon.stopFlag then break end
                    local accessible, _, alreadyDone = _DungeonServiceCore.HasRoomUnlocked(
                        _GUIService.session, gamemode, path, node
                    )
                    if alreadyDone then
                        skipped += 1
                        setStatus(string.format("↷ Already done — Path %d, Node %d", path, node))
                    elseif accessible then
                        local roomType = getRoomType(gamemode, path, node)
                        setStatus(string.format("→ Entering Path %d, Node %d [%s]", path, node, roomType))
                        if joinRoom(gamemode, path, node) then joined += 1 end
                        task.wait(1)
                    else
                        setStatus(string.format("✗ Path %d, Node %d not accessible yet", path, node))
                    end
                end
            end
            Dungeon.isRunning = false
            setStatus(string.format("Done! Joined: %d | Skipped: %d", joined, skipped))
        end)
    end

    function Dungeon.stop()
        if not Dungeon.isRunning then return end
        Dungeon.stopFlag = true
        setStatus("Stopped by user")
    end

    function Dungeon.getNextUnfinishedRoom()
        if not getDeps() then return nil end
        local gamemode = Dungeon.config.mode
        for _, entry in ipairs(PATH_ORDER) do
            local path     = entry.path
            local maxNodes = entry.maxNodes
            for node = 1, maxNodes do
                local accessible, _, alreadyDone = _DungeonServiceCore.HasRoomUnlocked(
                    _GUIService.session, gamemode, path, node
                )
                if accessible and not alreadyDone then
                    return { path = path, node = node, gamemode = gamemode }
                end
            end
        end
        return nil
    end

    function Dungeon.voteNextRoom(roomInfo)
        if not roomInfo then return false end
        local ok, err = pcall(function()
            Services.ReplicatedStorage
                :WaitForChild("endpoints")
                :WaitForChild("client_to_server")
                :WaitForChild("set_game_finished_vote")
                :InvokeServer("Replay", nil, {
                    selectedNodeBranch = roomInfo.path,
                    selectedNode       = roomInfo.node,
                })
        end)
        if ok then
            print(string.format("[AutoDungeon] ✓ Voted next room: Path %d, Node %d", roomInfo.path, roomInfo.node))
        else
            warn("[AutoDungeon] Failed to vote next room: " .. tostring(err))
        end
        return ok
    end
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local Util = {}

function Util.debugPrint(message, ...)
    if DEBUG then print("[DEBUG]", message, ...) end
end

function Util.notify(title, content, duration)
    if not NOTIFICATION_ENABLED then return end
    if _G.Rayfield then
        _G.Rayfield:Notify({
            Title    = title or "Notice",
            Content  = content or "No message.",
            Duration = duration or 5,
            Image    = "info",
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
        if spawnIdValue then return spawnIdValue.Value end
    end
    local spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID")
    if spawnUUID then return spawnUUID end
    return nil
end

function Util.getInternalSpawnName(unit)
    if not unit or not unit:FindFirstChild("_stats") then return nil end
    local idValue = unit._stats:FindFirstChild("id")
    if idValue and idValue:IsA("StringValue") then return idValue.Value end
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
                    for _, unitInfo in pairs(unitData) do
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
                    for _, unitInfo in pairs(unitData) do
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
                    for _, unitInfo in pairs(data) do
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
    return math.floor(baseCost * Util.getCostScale())
end

function Util.getUpgradeCost(unitId, currentLevel)
    local unitData = Util.getUnitData(unitId)
    if not unitData or not unitData.upgrade then return 0 end
    local upgradeIndex = currentLevel + 1
    if upgradeIndex > #unitData.upgrade then return 0 end
    local baseCost = unitData.upgrade[upgradeIndex] and unitData.upgrade[upgradeIndex].cost or 0
    return math.floor(baseCost * Util.getCostScale())
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
                local equippedList = child:FindFirstChild("EquippedList")
                if equippedList then
                    local equipped = equippedList:FindFirstChild("Equipped")
                    if equipped and equipped.Visible == true then
                        local uuidValue = child:FindFirstChild("_uuid")
                        if uuidValue and uuidValue:IsA("StringValue") then
                            return uuidValue.Value
                        end
                    end
                end
            end
        end
        return nil
    end)
    if not success then
        warn("Error resolving UUID for", internalName, ":", uuid)
        return nil
    end
    return uuid
end

-- ──────────────────────────────────────────────
-- NEW: Rarity cost lookup
-- ──────────────────────────────────────────────

-- Returns the yen cost for purchasing a unit from the shop based on its rarity.
-- Rarity is read from unitData.rarity (lowercase string expected from game data).
local RARITY_PURCHASE_COSTS = {
    epic        = 500,
    legendary   = 1250,
    mythic      = 3000,
    secret      = 10000,
    crusader    = 25000,
}

local FORGE_TRAIT_COSTS = {
    superior        = 1250,
    nimble          = 1250,
    range           = 1250,
    neuroplasticity = 5000,
    golden          = 5000,
    sniper          = 5000,
    godspeed        = 5000,
    reaper          = 12500,
    ethereal        = 12500,
    divine          = 12500,
    culling         = 12500,
    unique          = 50000,
}

function Util.getPurchaseCost(unitInternalId)
    local unitData = Util.getUnitData(unitInternalId)
    if not unitData then return 0 end
    local rarity = unitData.rarity and unitData.rarity:lower() or ""
    return RARITY_PURCHASE_COSTS[rarity] or 0
end

-- ──────────────────────────────────────────────
-- Util: Game Tab helpers
-- ──────────────────────────────────────────────

function Util.setLowPerformanceMode(enabled)
    local Lighting = Services.Lighting
    if enabled then
        Lighting.Brightness               = 1
        Lighting.GlobalShadows            = false
        Lighting.Technology               = Enum.Technology.Compatibility
        Lighting.ShadowSoftness           = 0
        Lighting.EnvironmentDiffuseScale  = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire")
            or obj:IsA("Smoke")          or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Transparency < 1 then obj.Transparency = 1 end
            end
        end
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("BloomEffect")       or obj:IsA("BlurEffect")
            or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect")
            or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end
    else
        Lighting.Brightness               = 1.51
        Lighting.GlobalShadows            = true
        Lighting.Technology               = Enum.Technology.Future
        Lighting.ShadowSoftness           = 0
        Lighting.EnvironmentDiffuseScale  = 1
        Lighting.EnvironmentSpecularScale = 1
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire")
            or obj:IsA("Smoke")          or obj:IsA("Sparkles") then
                obj.Enabled = true
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0
            end
        end
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("BloomEffect")       or obj:IsA("ColorCorrectionEffect")
            or obj:IsA("SunRaysEffect")     or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = true
            end
        end
    end
end

function Util.setBlackScreen(enabled)
    local playerGui = Services.Players.LocalPlayer.PlayerGui
    local existing  = playerGui:FindFirstChild("LixHubBlackScreenGui")
    if enabled then
        if existing then return end
        local screenGui          = Instance.new("ScreenGui")
        screenGui.Name           = "LixHubBlackScreenGui"
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder   = math.huge
        screenGui.Parent         = playerGui

        local frame                  = Instance.new("Frame")
        frame.Size                   = UDim2.new(1, 0, 1, 36)
        frame.Position               = UDim2.new(0, 0, 0, -36)
        frame.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        frame.BorderSizePixel        = 0
        frame.ZIndex                 = 999999
        frame.Parent                 = screenGui

        local btnFrame               = Instance.new("Frame")
        btnFrame.Size                = UDim2.new(0, 170, 0, 44)
        btnFrame.Position            = UDim2.new(0.5, -85, 1, -60)
        btnFrame.BackgroundColor3    = Color3.fromRGB(57, 57, 57)
        btnFrame.BackgroundTransparency = 0.5
        btnFrame.ZIndex              = 1000000
        btnFrame.Parent              = screenGui
        local corner                 = Instance.new("UICorner")
        corner.CornerRadius          = UDim.new(1, 0)
        corner.Parent                = btnFrame

        local label                  = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, 0, 1, 0)
        label.AnchorPoint            = Vector2.new(0.5, 0.5)
        label.Position               = UDim2.new(0.5, 0, 0.5, 0)
        label.BackgroundTransparency = 1
        label.Text                   = "Toggle Screen"
        label.TextSize               = 15
        label.TextColor3             = Color3.fromRGB(255, 255, 255)
        label.ZIndex                 = math.huge
        label.Parent                 = btnFrame

        local btn                    = Instance.new("TextButton")
        btn.Size                     = UDim2.new(1, 0, 1, 0)
        btn.AnchorPoint              = Vector2.new(0.5, 0.5)
        btn.Position                 = UDim2.new(0.5, 0, 0.5, 0)
        btn.BackgroundTransparency   = 1
        btn.Text                     = ""
        btn.ZIndex                   = math.huge
        btn.Parent                   = btnFrame
        btn.MouseButton1Click:Connect(function()
            frame.Visible = not frame.Visible
        end)
    else
        if existing then existing:Destroy() end
    end
end

function Util.autoEquipMacroUnits(macroName, macroLibrary)
    if not Util.isInLobby() then
        Util.notify("Equip Error", "Must be in lobby to equip units!")
        return false
    end
    if not macroName or macroName == "" then return false end
    local macroData = macroLibrary[macroName]
    if not macroData or #macroData == 0 then return false end

    local required = {}
    for _, action in ipairs(macroData) do
        if action.Type == "spawn_unit" and action.Unit then
            local base = action.Unit:match("^(.+) #%d+$") or action.Unit
            required[base] = true
        end
    end

    local fxCache = Services.ReplicatedStorage:FindFirstChild("_FX_CACHE")
    if not fxCache then return false end

    local available = {}
    for _, child in pairs(fxCache:GetChildren()) do
        local itemIndex = child:GetAttribute("ITEMINDEX")
        if itemIndex then
            local displayName = Util.getDisplayNameFromUnitId(itemIndex)
            if displayName then
                local uuidValue = child:FindFirstChild("_uuid")
                if uuidValue and uuidValue:IsA("StringValue") then
                    available[displayName] = uuidValue.Value
                end
            end
        end
    end

    local missing = {}
    for unitName in pairs(required) do
        if not available[unitName] then table.insert(missing, unitName) end
    end
    if #missing > 0 then
        Util.notify("Auto Equip Failed", "Missing: " .. table.concat(missing, ", "))
        return false
    end

    local endpoints = Services.ReplicatedStorage
        :WaitForChild("endpoints")
        :WaitForChild("client_to_server")

    pcall(function() endpoints:WaitForChild("unequip_all"):InvokeServer() end)
    task.wait(0.5)

    local equipped = 0
    for unitName in pairs(required) do
        local uuid = available[unitName]
        if uuid then
            pcall(function() endpoints:WaitForChild("equip_unit"):InvokeServer(uuid) end)
            equipped += 1
            task.wait(0.2)
        end
    end

    Util.notify("Auto Equip", string.format("Equipped %d units for %s", equipped, macroName))
    return true
end

-- ============================================================
-- GAME TRACKING MODULE
-- ============================================================
local GameTracking = {
    gameInProgress = false,
    gameStartTime  = 0,
    gameHasEnded   = false,
}

function GameTracking.getMapInfo()
    local mapName = "Unknown Map"
    local challengeModifier = nil
    local portalDepth = nil

    local cfg = Services.Workspace:FindFirstChild("_MAP_CONFIG")
    if cfg and cfg:FindFirstChild("GetLevelData") then
        local success, result = pcall(function()
            return cfg.GetLevelData:InvokeServer()
        end)
        if success and result then
            mapName = result.MapName or result.mapName or result.Name or result.name or
                      result.LevelName or result.levelName or result.Map or result.map or "Unknown Map"
            challengeModifier = result.challenge
            if result.PortalItem and
               result.PortalItem._unique_item_data and
               result.PortalItem._unique_item_data._unique_portal_data then
                portalDepth = result.PortalItem._unique_item_data._unique_portal_data.portal_depth
            end
            print("Map info retrieved:", mapName, "| Full data:", result)
        else
            print("Failed to get map data:", result)
        end
    end

    return mapName, challengeModifier, portalDepth
end

function GameTracking.startGame()
    if GameTracking.gameInProgress then return end
    GameTracking.gameInProgress = true
    GameTracking.gameStartTime  = tick()
    GameTracking.gameHasEnded   = false
    Util.debugPrint("Game started at:", GameTracking.gameStartTime)
    Webhook.startTracking(GameTracking.getMapInfo())
end

function GameTracking.endGame()
    GameTracking.gameHasEnded   = true
    GameTracking.gameInProgress = false
    Util.debugPrint("Game ended")
end

function GameTracking.reset()
    GameTracking.gameInProgress = false
    GameTracking.gameStartTime  = 0
    GameTracking.gameHasEnded   = false
end

-- ============================================================
-- MACRO MODULE
-- ============================================================
local Macro = {
    isRecording              = false,
    isPlaying                = false,
    currentName              = "",
    hasPlayedThisGame        = false,
    actions                  = {},
    library                  = {},
    recordingHasStarted      = false,
    trackedUnits             = {},
    spawnIdToPlacement       = {},
    placementCounter         = {},
    unitNameToSpawnId        = {},
    playbackPlacementToSpawnId = {},
    detailedStatusLabel      = nil,
    SPAWN_REMOTE             = "spawn_unit",
    UPGRADE_REMOTE           = "upgrade_unit_ingame",
    SELL_REMOTE              = "sell_unit_ingame",
    WAVE_SKIP_REMOTE         = "vote_wave_skip",
    -- ── NEW remotes ──────────────────────────────
    PURCHASE_UNIT_REMOTE     = "purchase_unit",
    FORGE_TRAIT_REMOTE       = "forge_trait_purchase",
    -- ─────────────────────────────────────────────
    SPECIAL_ABILITY_REMOTES  = {
        "use_active_attack",
        "HestiaAssignBlade",
        "LelouchChoosePiece",
        "DioWrites",
        "FrierenMagics",
    },
    PLACEMENT_WAIT           = 0.3,
    PLACEMENT_MAX_RETRIES    = 3,
    UPGRADE_MAX_RETRIES      = 3,
    PLACEMENT_TIMEOUT        = 5.0,
    UPGRADE_TIMEOUT          = 4.0,
    VALIDATION_INTERVAL      = 0.1,
    RETRY_DELAY              = 0.5,
    NORMAL_VALIDATION        = 0.3,
    EXTENDED_VALIDATION      = 1.0,
    randomOffsetEnabled      = false,
    randomOffsetAmount       = 0.5,
    ignoreTiming             = false,
    -- All unit_added_temporary events received this game. Reset each game.
    -- Each entry = { unit_id, uuid, equipped_slot, cost }
    temporaryUnits           = {},
    equippedSlotMap          = {},  -- kept for override_equipped_units debug
}

function Macro.updateStatus(message)
    if Macro.detailedStatusLabel then
        Macro.detailedStatusLabel:Set("Macro Details: " .. message)
    end
    Util.debugPrint("Macro Status:", message)
end

function Macro.clearSpawnIdMappings()
    Macro.spawnIdToPlacement           = {}
    Macro.placementCounter             = {}
    Macro.unitNameToSpawnId            = {}
    Macro.playbackPlacementToSpawnId   = {}
    Macro.temporaryUnits               = {}
end

function Macro.takeUnitsSnapshot()
    local snapshot    = {}
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    if not unitsFolder then return snapshot end
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if Util.isOwnedByLocalPlayer(unit) then
            local unitData = {
                instance  = unit,
                name      = unit.Name,
                spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID"),
                position  = unit.PrimaryPart and unit.PrimaryPart.Position or
                            unit:FindFirstChildWhichIsA("BasePart") and unit:FindFirstChildWhichIsA("BasePart").Position,
            }
            if unitData.position and unitData.spawnUUID then
                table.insert(snapshot, unitData)
            end
        end
    end
    return snapshot
end

function Macro.findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
    local beforeUUIDs = {}
    for _, unitData in pairs(beforeSnapshot) do
        if unitData.spawnUUID then beforeUUIDs[tostring(unitData.spawnUUID)] = true end
    end
    local newUnits = {}
    for _, unitData in pairs(afterSnapshot) do
        if unitData.spawnUUID and not beforeUUIDs[tostring(unitData.spawnUUID)] then
            table.insert(newUnits, unitData)
        end
    end
    if #newUnits == 0 then return nil end
    return newUnits[1].instance
end

function Macro.findUnitBySpawnUUID(targetUUID)
    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
    if not unitsFolder then return nil end
    for _, unit in pairs(unitsFolder:GetChildren()) do
        if Util.isOwnedByLocalPlayer(unit) then
            local spawnUUID = unit:GetAttribute("_SPAWN_UNIT_UUID")
            if spawnUUID and tostring(spawnUUID) == tostring(targetUUID) then
                return unit
            end
        end
    end
    return nil
end

-- ──────────────────────────────────────────────
-- NEW: find a unit in _FX_CACHE by its inventory UUID (the arg passed to
-- purchase_unit / forge_trait_purchase).
-- Returns the display-name or nil if not found.
-- ──────────────────────────────────────────────
function Macro.getDisplayNameFromInventoryUUID(inventoryUUID)
    if not inventoryUUID then return nil end
    local fxCache = Services.ReplicatedStorage:FindFirstChild("_FX_CACHE")
    if not fxCache then return nil end
    for _, child in pairs(fxCache:GetChildren()) do
        local uuidValue = child:FindFirstChild("_uuid")
        if uuidValue and uuidValue:IsA("StringValue") and uuidValue.Value == inventoryUUID then
            local itemIndex = child:GetAttribute("ITEMINDEX")
            if itemIndex then
                return Util.getDisplayNameFromUnitId(itemIndex)
            end
        end
    end
    return nil
end

-- ──────────────────────────────────────────────
-- NEW: find inventory UUID from a purchase placement ID ("Speedwagon #1")
-- by resolving the internal id and then scanning _FX_CACHE.
-- ──────────────────────────────────────────────
function Macro.getInventoryUUIDFromPurchasePlacement(placementId)
    local displayName, _ = Util.parseUnitString(placementId)
    if not displayName then return nil end
    local internalId = Util.getUnitIdFromDisplayName(displayName)
    if not internalId then return nil end
    return Util.resolveUUIDFromInternalName(internalId)
end

function Macro.startRecording()
    table.clear(Macro.actions)
    Macro.clearSpawnIdMappings()
    Macro.trackedUnits        = {}
    Macro.isRecording         = true
    Macro.recordingHasStarted = true
    if GameTracking.gameStartTime == 0 then
        GameTracking.gameStartTime = tick()
    end
    Util.notify("Recording Started", "Macro recording is active")
end

function Macro.stopRecording()
    Macro.isRecording         = false
    Macro.recordingHasStarted = false
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
    local spawnedUnit   = Macro.findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
    if not spawnedUnit then return end
    local internalName = Util.getInternalSpawnName(spawnedUnit)
    local displayName  = Util.getDisplayNameFromUnitId(internalName)
    if not displayName then return end
    Macro.placementCounter[displayName] = (Macro.placementCounter[displayName] or 0) + 1
    local placementId = string.format("%s #%d", displayName, Macro.placementCounter[displayName])
    local stats = spawnedUnit:FindFirstChild("_stats")
    if not stats then return end
    local uuidValue = stats:FindFirstChild("uuid")
    if not uuidValue or not uuidValue:IsA("StringValue") then return end
    local actualUUID         = uuidValue.Value
    local spawnIdValue       = stats:FindFirstChild("spawn_id")
    local combinedIdentifier = spawnIdValue and (actualUUID .. spawnIdValue.Value) or actualUUID
    Macro.spawnIdToPlacement[combinedIdentifier] = placementId
    Macro.unitNameToSpawnId[spawnedUnit.Name]    = combinedIdentifier
    local raycastData      = actionInfo.args[2] or {}
    local rotation         = actionInfo.args[3] or 0
    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime

    -- Find which slot this UUID belongs to in the current equippedSlotMap.
    -- The slot is stable across sessions; the UUID is not.
    local usedUUID = actionInfo.args[1]
    local slot = nil
    for s, u in pairs(Macro.equippedSlotMap) do
        if u == usedUUID then slot = s break end
    end

    table.insert(Macro.actions, {
        Type = "spawn_unit",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime),
        Pos  = raycastData.Origin and string.format("%.17f, %.17f, %.17f",
            raycastData.Origin.X, raycastData.Origin.Y, raycastData.Origin.Z) or "",
        Dir  = raycastData.Direction and string.format("%.17f, %.17f, %.17f",
            raycastData.Direction.X, raycastData.Direction.Y, raycastData.Direction.Z) or "",
        Rot  = rotation ~= 0 and rotation or 0,
        Cost = Util.getPlacementCost(internalName),
        Slot = slot,  -- slot number from override_equipped_units; looked up at playback for live UUID
    })
    Util.notify("Macro Recorder", string.format("Recorded placement: %s (slot %s)", placementId, tostring(slot)))
    Util.debugPrint("Recorded spawn_unit:", placementId, "slot=", slot, "uuid=", usedUUID)
end

function Macro.processSellRecording(actionInfo)
    local remoteParam = actionInfo.args[1]
    local spawnId     = Macro.unitNameToSpawnId[remoteParam]
    if not spawnId then return end
    local placementId = Macro.spawnIdToPlacement[spawnId]
    if not placementId then return end
    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    table.insert(Macro.actions, {
        Type = "sell_unit_ingame",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime)
    })
    Macro.spawnIdToPlacement[spawnId]    = nil
    Macro.unitNameToSpawnId[remoteParam] = nil
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

-- ──────────────────────────────────────────────
-- NEW: purchase_unit recording
-- args[1] = inventoryUUID (the unit being purchased from the shop)
-- We resolve its display name and assign a purchase-specific counter
-- so it can be uniquely identified during playback.
-- ──────────────────────────────────────────────
function Macro.processPurchaseRecording(actionInfo)
    local inventoryUUID = actionInfo.args[1]
    if not inventoryUUID then return end

    -- unit_added_temporary fires before purchase_unit and includes the uuid.
    -- Match by UUID directly instead of assuming "last entry = this purchase".
    local unit_id = nil
    local cost    = 0

    for i, entry in ipairs(Macro.temporaryUnits) do
        if entry.unit_id == inventoryUUID then
            unit_id = entry.unit_id
            cost    = Util.getPurchaseCost(unit_id)
            table.remove(Macro.temporaryUnits, i)  -- consume so it won't match again
            Util.debugPrint("processPurchaseRecording: matched by UUID", unit_id, "cost =", cost)
            break
        end
    end

    -- If still not found, the event may not have fired yet — wait briefly and retry once
    if not unit_id then
        task.wait(0.3)
        for i, entry in ipairs(Macro.temporaryUnits) do
            if entry.unit_id == inventoryUUID then
                unit_id = entry.unit_id
                cost    = Util.getPurchaseCost(unit_id)
                table.remove(Macro.temporaryUnits, i)
                Util.debugPrint("processPurchaseRecording: delayed match", unit_id, "cost =", cost)
                break
            end
        end
    end

    if cost == 0 and unit_id then
        -- getPurchaseCost returned 0, meaning rarity wasn't in the table (e.g. Rare/Common)
        -- These aren't purchasable rarities so 0 is likely correct, but warn anyway
        warn("[Macro Recorder] purchase_unit: cost resolved to 0 for unit_id:", unit_id)
    elseif not unit_id then
        warn("[Macro Recorder] purchase_unit: could not resolve unit for UUID:", inventoryUUID)
    end

    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    table.insert(Macro.actions, {
        Type = "purchase_unit",
        UUID = inventoryUUID,
        Cost = cost,
        Time = string.format("%.2f", gameRelativeTime),
    })
    local displayName = unit_id and Util.getDisplayNameFromUnitId(unit_id) or inventoryUUID:sub(1, 8)
    Util.notify("Macro Recorder", string.format("Recorded purchase: %s (%d yen)", displayName, cost))
end

-- ──────────────────────────────────────────────
-- NEW: forge_trait_purchase recording
-- args[1] = inventoryUUID of the unit whose trait is being forged
-- args[2] = trait type string (e.g. "unique")
-- We resolve the inventory UUID to a placement ID so playback can
-- fire the remote on the correct live unit instance.
-- ──────────────────────────────────────────────
function Macro.forgeTraitRecording(actionInfo)
    local inventoryUUID    = actionInfo.args[1]
    local traitType        = actionInfo.args[2]
    if not inventoryUUID then return end

    -- Find the placement ID that owns this inventory UUID.
    -- We scan spawnIdToPlacement: the combinedIdentifier stored there
    -- starts with the unit's uuid (from _stats.uuid), which is the same
    -- identifier the server uses as the inventory/forge UUID.
    local placementId = nil
    for combinedId, pid in pairs(Macro.spawnIdToPlacement) do
        -- combinedId = uuid.Value .. spawnId.Value  OR  just uuid.Value
        -- The inventoryUUID passed to forge_trait_purchase is the _stats.uuid
        if combinedId:sub(1, #inventoryUUID) == inventoryUUID then
            placementId = pid
            break
        end
    end

    -- If the unit was purchased from the shop this game but not yet placed,
    -- it won't be in spawnIdToPlacement yet. In that case we can't resolve it —
    -- forge should only be recorded after placement anyway.
    if not placementId then
        warn("[Macro Recorder] forge_trait_purchase: could not resolve placementId for UUID:", inventoryUUID)
        return
    end

    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    table.insert(Macro.actions, {
        Type      = "forge_trait_purchase",
        Unit      = placementId,
        TraitType = traitType or "unique",
        Cost      = FORGE_TRAIT_COSTS[(traitType or "unique"):lower()] or 0,
        Time      = string.format("%.2f", gameRelativeTime),
    })
    Util.notify("Macro Recorder", string.format("Recorded forge trait (%s): %s", traitType or "unique", placementId))
end

function Macro.processAbilityRecording(actionInfo)
    local remoteName = actionInfo.remoteName
    local args       = actionInfo.args
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
                            if placementId then return placementId end
                        end
                    end
                end
            end
        end
        return nil
    end
    local gameRelativeTime = actionInfo.timestamp - GameTracking.gameStartTime
    local abilityRecord    = nil
    if remoteName == "HestiaAssignBlade" then
        local targetPlacementId = findPlacementBySpawnId(args[1])
        if not targetPlacementId then return end
        abilityRecord = { Type = "HestiaAssignBlade", Target = targetPlacementId, Time = string.format("%.2f", gameRelativeTime) }
    elseif remoteName == "LelouchChoosePiece" then
        local lelouchPlacementId = findPlacementBySpawnId(args[1])
        local targetPlacementId  = findPlacementBySpawnId(args[2])
        if not lelouchPlacementId or not targetPlacementId then return end
        abilityRecord = { Type = "LelouchChoosePiece", Lelouch = lelouchPlacementId, Target = targetPlacementId, Piece = args[3], Time = string.format("%.2f", gameRelativeTime) }
    elseif remoteName == "DioWrites" then
        local dioPlacementId = findPlacementBySpawnId(args[1])
        if not dioPlacementId then return end
        abilityRecord = { Type = "DioWrites", Dio = dioPlacementId, Ability = args[2], Time = string.format("%.2f", gameRelativeTime) }
    elseif remoteName == "use_active_attack" then
        local unitName    = args[1]
        if type(unitName) ~= "string" then return end
        local spawnId     = Macro.unitNameToSpawnId[unitName]
        if not spawnId then return end
        local placementId = Macro.spawnIdToPlacement[spawnId]
        if not placementId then return end
        abilityRecord = { Type = "use_active_attack", Unit = placementId, Time = string.format("%.2f", gameRelativeTime) }
    else
        abilityRecord = { Type = remoteName, Time = string.format("%.2f", gameRelativeTime), Args = args }
    end
    if abilityRecord then table.insert(Macro.actions, abilityRecord) end
end

function Macro.handleRemoteCall(remoteName, args, timestamp)
    if remoteName == Macro.SPAWN_REMOTE then
        task.spawn(function()
            if GameTracking.gameStartTime == 0 then GameTracking.gameStartTime = tick() end
            local preActionUnits = Macro.takeUnitsSnapshot()
            task.wait(0.3)
            Macro.processPlacementRecording({ remoteName = Macro.SPAWN_REMOTE, args = args, timestamp = timestamp, preActionUnits = preActionUnits })
        end)
    elseif remoteName == Macro.SELL_REMOTE then
        task.spawn(function()
            Macro.processSellRecording({ remoteName = Macro.SELL_REMOTE, args = args, timestamp = timestamp })
        end)
    elseif remoteName == Macro.WAVE_SKIP_REMOTE then
        task.spawn(function()
            Macro.processWaveSkipRecording({ remoteName = Macro.WAVE_SKIP_REMOTE, timestamp = timestamp })
        end)
    -- ── NEW ──────────────────────────────────────────
    elseif remoteName == Macro.PURCHASE_UNIT_REMOTE then
        task.spawn(function()
            Macro.processPurchaseRecording({ remoteName = Macro.PURCHASE_UNIT_REMOTE, args = args, timestamp = timestamp })
        end)
    elseif remoteName == Macro.FORGE_TRAIT_REMOTE then
        task.spawn(function()
            Macro.forgeTraitRecording({ remoteName = Macro.FORGE_TRAIT_REMOTE, args = args, timestamp = timestamp })
        end)
    -- ─────────────────────────────────────────────────
    else
        for _, abilityRemote in ipairs(Macro.SPECIAL_ABILITY_REMOTES) do
            if remoteName == abilityRemote then
                task.spawn(function()
                    Macro.processAbilityRecording({ remoteName = remoteName, args = args, timestamp = timestamp })
                end)
                break
            end
        end
    end
end

function Macro.setupUpgradeMonitoring()
    Services.RunService.Heartbeat:Connect(function()
        if not Macro.isRecording or not Macro.recordingHasStarted then return end
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        if not unitsFolder then return end
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if Util.isOwnedByLocalPlayer(unit) then
                local stats = unit:FindFirstChild("_stats")
                if not stats then continue end
                local uuidValue    = stats:FindFirstChild("uuid")
                local spawnIdValue = stats:FindFirstChild("spawn_id")
                if not uuidValue or not uuidValue:IsA("StringValue") then continue end
                local combinedId = uuidValue.Value
                if spawnIdValue then combinedId = combinedId .. spawnIdValue.Value end
                local placementId = Macro.spawnIdToPlacement[combinedId]
                if not placementId then
                    local internalName = Util.getInternalSpawnName(unit)
                    local displayName  = Util.getDisplayNameFromUnitId(internalName)
                    if displayName then
                        Macro.placementCounter[displayName] = (Macro.placementCounter[displayName] or 0) + 1
                        placementId = string.format("%s #%d", displayName, Macro.placementCounter[displayName])
                        Macro.spawnIdToPlacement[combinedId] = placementId
                    end
                end
                if placementId then
                    local currentLevel = Util.getUnitUpgradeLevel(unit)
                    if not Macro.trackedUnits[combinedId] then
                        Macro.trackedUnits[combinedId] = { placementId = placementId, lastLevel = currentLevel }
                    end
                    local lastLevel = Macro.trackedUnits[combinedId].lastLevel
                    if currentLevel > lastLevel then
                        local levelIncrease = currentLevel - lastLevel
                        local internalName  = Util.getInternalSpawnName(unit)
                        local upgradeCost   = levelIncrease > 1
                            and Util.getMultiUpgradeCost(internalName, lastLevel, levelIncrease)
                            or  Util.getUpgradeCost(internalName, lastLevel)
                        local record = {
                            Type = Macro.UPGRADE_REMOTE,
                            Unit = placementId,
                            Time = string.format("%.2f", tick() - GameTracking.gameStartTime),
                            Cost = upgradeCost,  -- baked at record time
                        }
                        if levelIncrease > 1 then record.Amount = levelIncrease end
                        table.insert(Macro.actions, record)
                        Macro.trackedUnits[combinedId].lastLevel = currentLevel
                    end
                end
            end
        end
    end)
end

function Macro.setupPurchaseListener()
    local stc = Services.ReplicatedStorage
        :WaitForChild("endpoints")
        :WaitForChild("server_to_client")

    -- Store every unit_added_temporary event. Reset each game via clearSpawnIdMappings.
    -- At placement time we match unit_id to find the right UUID.
    local unitAddedRemote = stc:FindFirstChild("unit_added_temporary")
        or stc:WaitForChild("unit_added_temporary", 10)
    if unitAddedRemote then
        unitAddedRemote.OnClientEvent:Connect(function(data)
            if type(data) ~= "table" then return end
            local uuid    = data.uuid
            local unit_id = data.unit_id
            if not uuid or not unit_id then return end
            local cost = Util.getPurchaseCost(unit_id)
            table.insert(Macro.temporaryUnits, {
                unit_id = unit_id,
                uuid    = uuid,
                cost    = cost,
            })
            Util.debugPrint("unit_added_temporary:", unit_id, "→", uuid)
        end)
    else
        warn("[Macro] unit_added_temporary remote not found")
    end

    -- Keep equippedSlotMap updated for reference
    local overrideRemote = stc:FindFirstChild("override_equipped_units")
        or stc:WaitForChild("override_equipped_units", 10)
    if overrideRemote then
        overrideRemote.OnClientEvent:Connect(function(slotMap)
            if type(slotMap) ~= "table" then return end
            Macro.equippedSlotMap = slotMap
        end)
    end
end

function Macro.setupHook()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args   = {...}
        local method = getnamecallmethod()
        if not checkcaller() and Macro.isRecording and self.Parent and self.Parent.Name == "client_to_server" then
            if self.Name == Macro.SPAWN_REMOTE
            or self.Name == Macro.SELL_REMOTE
            or self.Name == Macro.WAVE_SKIP_REMOTE
            -- ── NEW ──────────────────────────────────────────
            or self.Name == Macro.PURCHASE_UNIT_REMOTE
            or self.Name == Macro.FORGE_TRAIT_REMOTE
            -- ─────────────────────────────────────────────────
            then
                Macro.handleRemoteCall(self.Name, args, tick())
            else
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
    Macro.setupPurchaseListener()
end

function Macro.saveToFile(name)
    if not name or name == "" then return end
    local data = Macro.library[name]
    if not data then return end
    local json     = Services.HttpService:JSONEncode(data)
    local filePath = Util.getMacroFilename(name)
    if filePath then writefile(filePath, json) end
end

function Macro.loadFromFile(name)
    local filePath = Util.getMacroFilename(name)
    if not filePath or not isfile(filePath) then return nil end
    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)
    if type(data) == "table" and #data == 0 then return {} end
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
    local success, files = pcall(function() return listfiles("LixHub/Macros/AC/") end)
    if success then
        for _, file in ipairs(files) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                if name then
                    local data = Macro.loadFromFile(name)
                    if data then Macro.library[name] = data end
                end
            end
        end
    end
end

function Macro.delete(name)
    local filePath = Util.getMacroFilename(name)
    if filePath and isfile(filePath) then delfile(filePath) end
    Macro.library[name] = nil
end

function Macro.importFromJSON(jsonContent, macroName)
    local success, data = pcall(function() return Services.HttpService:JSONDecode(jsonContent) end)
    if not success then Util.notify("Import Error", "Invalid JSON format") return false end
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
    if #importedActions == 0 then Util.notify("Import Error", "Macro contains no actions") return false end
    for i, action in ipairs(importedActions) do
        if not action.Type then Util.notify("Import Error", string.format("Action %d missing 'Type' field", i)) return false end
    end
    Macro.library[macroName] = importedActions
    Macro.saveToFile(macroName)
    Util.notify("Import Success", string.format("Imported '%s' with %d actions", macroName, #importedActions))
    return true
end

function Macro.importFromTXT(txtContent, macroName)
    local lines = {}
    for line in txtContent:gmatch("[^\r\n]+") do table.insert(lines, line:match("^%s*(.-)%s*$")) end
    local actions = {}
    for _, line in ipairs(lines) do
        if line and line ~= "" and not line:match("^#") then
            local parts = {}
            for part in line:gmatch("[^,]+") do table.insert(parts, part:match("^%s*(.-)%s*$")) end
            if #parts >= 1 then
                local actionType = parts[1]
                if actionType == "spawn_unit" and #parts >= 10 then
                    table.insert(actions, {
                        Type = "spawn_unit", Unit = parts[2], Time = parts[3],
                        Pos  = string.format("%.17f, %.17f, %.17f", tonumber(parts[4]) or 0, tonumber(parts[5]) or 0, tonumber(parts[6]) or 0),
                        Dir  = string.format("%.17f, %.17f, %.17f", tonumber(parts[7]) or 0, tonumber(parts[8]) or 0, tonumber(parts[9]) or 0),
                        Rot  = tonumber(parts[10]) or 0
                    })
                elseif actionType == "upgrade_unit_ingame" and #parts >= 3 then
                    table.insert(actions, { Type = "upgrade_unit_ingame", Unit = parts[2], Time = parts[3] })
                elseif actionType == "sell_unit_ingame" and #parts >= 3 then
                    table.insert(actions, { Type = "sell_unit_ingame", Unit = parts[2], Time = parts[3] })
                elseif actionType == "vote_wave_skip" and #parts >= 2 then
                    table.insert(actions, { Type = "vote_wave_skip", Time = parts[2] })
                elseif actionType == "use_active_attack" and #parts >= 3 then
                    table.insert(actions, { Type = "use_active_attack", Unit = parts[2], Time = parts[3] })
                -- ── NEW TXT import lines ──────────────────────
                elseif actionType == "purchase_unit" and #parts >= 3 then
                    table.insert(actions, { Type = "purchase_unit", Unit = parts[2], Time = parts[3] })
                elseif actionType == "forge_trait_purchase" and #parts >= 4 then
                    table.insert(actions, { Type = "forge_trait_purchase", Unit = parts[2], TraitType = parts[3], Time = parts[4] })
                -- ─────────────────────────────────────────────
                end
            end
        end
    end
    if #actions == 0 then Util.notify("Import Error", "No valid actions found in TXT file") return false end
    Macro.library[macroName] = actions
    Macro.saveToFile(macroName)
    Util.notify("TXT Import Success", string.format("Imported '%s' with %d actions", macroName, #actions))
    return true
end

function Macro.importFromURL(url, macroName)
    local requestFunc = syn and syn.request or http and http.request or http_request or request
    if not requestFunc then Util.notify("Import Error", "HTTP requests not supported") return false end
    local success, response = pcall(function() return requestFunc({ Url = url, Method = "GET" }) end)
    if success and response and response.StatusCode == 200 then
        local isJSON = false
        pcall(function() Services.HttpService:JSONDecode(response.Body) isJSON = true end)
        return isJSON and Macro.importFromJSON(response.Body, macroName) or Macro.importFromTXT(response.Body, macroName)
    else
        Util.notify("Import Error", "Failed to download from URL")
        return false
    end
end

function Macro.exportToClipboard(macroName)
    if not Macro.library[macroName] or #Macro.library[macroName] == 0 then Util.notify("Export Error", "No macro data to export") return false end
    local jsonData = Services.HttpService:JSONEncode(Macro.library[macroName])
    if setclipboard then setclipboard(jsonData) Util.notify("Export Success", "Macro JSON copied to clipboard") else print(jsonData) end
    return true
end

function Macro.exportToWebhook(macroName, webhookUrl)
    if not Macro.library[macroName] or #Macro.library[macroName] == 0 then Util.notify("Export Error", "No macro data") return false end
    if not webhookUrl or webhookUrl == "" then Util.notify("Export Error", "No webhook URL") return false end
    local requestFunc = syn and syn.request or http and http.request or http_request or request
    if not requestFunc then Util.notify("Export Error", "HTTP not supported") return false end
    local jsonData  = Services.HttpService:JSONEncode(Macro.library[macroName])
    local unitsUsed = {}
    local unitOrder = {}
    for _, action in ipairs(Macro.library[macroName]) do
        if action.Type == "spawn_unit" and action.Unit then
            local baseName = action.Unit:match("^(.+) #%d+$") or action.Unit
            if not unitsUsed[baseName] then unitsUsed[baseName] = true table.insert(unitOrder, baseName) end
        end
    end
    local unitsLine = #unitOrder > 0 and ("Units: " .. table.concat(unitOrder, ", ")) or "Units: (none)"
    local boundary  = "----LixHubBoundary" .. tostring(math.random(100000, 999999))
    local function part(name, value, filename, contentType)
        local header
        if filename then
            header = string.format('--%s\r\nContent-Disposition: form-data; name="%s"; filename="%s"\r\nContent-Type: %s\r\n\r\n', boundary, name, filename, contentType or "application/octet-stream")
        else
            header = string.format('--%s\r\nContent-Disposition: form-data; name="%s"\r\n\r\n', boundary, name)
        end
        return header .. value .. "\r\n"
    end
    local payloadJson = Services.HttpService:JSONEncode({ content = unitsLine })
    local body        = part("payload_json", payloadJson) .. part("files[0]", jsonData, macroName .. ".json", "application/json") .. "--" .. boundary .. "--\r\n"
    local success, response = pcall(function()
        return requestFunc({ Url = webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundary }, Body = body })
    end)
    if success and response and (response.StatusCode == 200 or response.StatusCode == 204) then
        Util.notify("Export Success", "Macro exported to webhook!")
        return true
    else
        Util.notify("Export Error", "Failed to send to webhook")
        return false
    end
end

function Macro.waitForSufficientMoney(action, actionIndex, totalActions)
    -- Cost is baked into the action at record time for spawn, upgrade, and purchase.
    local requiredCost = action.Cost or 0

    if requiredCost > 0 then
        while Util.getPlayerMoney() < requiredCost do
            if not Macro.isPlaying or GameTracking.gameHasEnded then return false end
            local missingMoney = requiredCost - Util.getPlayerMoney()
            local suffix = ""
            if action.Type == "purchase_unit" then
                suffix = " (shop purchase)"
            elseif action.Amount and action.Amount > 1 then
                suffix = string.format(" (x%d upgrade)", action.Amount)
            end
            Macro.updateStatus(string.format("(%d/%d) Waiting for %d more yen%s", actionIndex, totalActions, missingMoney, suffix))
            task.wait(1)
        end
    end
    return true
end

function Macro.validatePlacement(action, actionIndex, totalActions)
    local endpoints   = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local placementId = action.Unit
    local displayName, _ = Util.parseUnitString(placementId)
    if not displayName then
        Macro.updateStatus(string.format("(%d/%d) FAILED: Invalid unit format: %s", actionIndex, totalActions, placementId))
        return false
    end
    for attempt = 1, Macro.PLACEMENT_MAX_RETRIES do
        if not Macro.isPlaying then return false end
        local unitId   = Util.getUnitIdFromDisplayName(displayName)
        if not unitId then Macro.updateStatus(string.format("(%d/%d) FAILED: Could not resolve unit ID", actionIndex, totalActions)) return false end

        -- Find UUID: check temporaryUnits (purchased this game) first by matching unit_id.
        -- If not found there, fall back to _FX_CACHE for permanently owned units.
        local unitUUID = nil

        for i, entry in ipairs(Macro.temporaryUnits) do
            if entry.unit_id == unitId then
                unitUUID = entry.uuid
                table.remove(Macro.temporaryUnits, i)  -- consume so next placement of same unit gets next entry
                Util.debugPrint("validatePlacement: matched temporaryUnit", unitId, "→", unitUUID)
                break
            end
        end

        if not unitUUID then
            unitUUID = Util.resolveUUIDFromInternalName(unitId)
        end

        if not unitUUID then
            Macro.updateStatus(string.format("(%d/%d) FAILED: No UUID for %s", actionIndex, totalActions, displayName))
            return false
        end
        Macro.updateStatus(string.format("(%d/%d) Attempt %d/%d: Placing %s", actionIndex, totalActions, attempt, Macro.PLACEMENT_MAX_RETRIES, placementId))
        local beforeSnapshot = Macro.takeUnitsSnapshot()
        local px, py, pz    = action.Pos:match("([%-%d%.e%-]+), ([%-%d%.e%-]+), ([%-%d%.e%-]+)")
        local dx, dy, dz    = action.Dir:match("([%-%d%.e%-]+), ([%-%d%.e%-]+), ([%-%d%.e%-]+)")
        if not (px and py and pz and dx and dy and dz) then Macro.updateStatus(string.format("(%d/%d) FAILED: Invalid position format", actionIndex, totalActions)) return false end
        local originPos = Vector3.new(tonumber(px), tonumber(py), tonumber(pz))
        if Macro.randomOffsetEnabled then
            originPos = Vector3.new(originPos.X + (math.random() - 0.5) * 2 * Macro.randomOffsetAmount, originPos.Y, originPos.Z + (math.random() - 0.5) * 2 * Macro.randomOffsetAmount)
        end
        local success = pcall(function()
            endpoints:WaitForChild(Macro.SPAWN_REMOTE):InvokeServer(unitUUID, { Origin = originPos, Direction = Vector3.new(tonumber(dx), tonumber(dy), tonumber(dz)) }, action.Rot or 0)
        end)
        if not success then
            if attempt < Macro.PLACEMENT_MAX_RETRIES then task.wait(Macro.RETRY_DELAY) continue else return false end
        end
        task.wait((attempt == 1) and Macro.NORMAL_VALIDATION or Macro.EXTENDED_VALIDATION)
        local newUnit = Macro.findNewlyPlacedUnit(beforeSnapshot, Macro.takeUnitsSnapshot())
        if newUnit and Util.isOwnedByLocalPlayer(newUnit) then
            local spawnUUID = newUnit:GetAttribute("_SPAWN_UNIT_UUID")
            if spawnUUID then
                Macro.playbackPlacementToSpawnId[placementId] = spawnUUID
                Macro.updateStatus(string.format("(%d/%d) SUCCESS: Placed %s", actionIndex, totalActions, placementId))
                return true
            end
        end
        if attempt < Macro.PLACEMENT_MAX_RETRIES then task.wait(Macro.RETRY_DELAY) end
    end
    Macro.updateStatus(string.format("(%d/%d) FAILED: Could not place %s - continuing", actionIndex, totalActions, placementId))
    return true
end

function Macro.validateUpgrade(action, actionIndex, totalActions)
    local endpoints     = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local placementId   = action.Unit
    local upgradeAmount = action.Amount or 1
    for attempt = 1, Macro.UPGRADE_MAX_RETRIES do
        if not Macro.isPlaying then return false end
        local currentUUID = Macro.playbackPlacementToSpawnId[placementId]
        local targetUnit  = currentUUID and Macro.findUnitBySpawnUUID(currentUUID) or nil
        if not targetUnit then
            if attempt < Macro.UPGRADE_MAX_RETRIES then task.wait(Macro.RETRY_DELAY) continue else return false end
        end
        local originalLevel      = Util.getUnitUpgradeLevel(targetUnit)
        local successfulUpgrades = 0
        for _ = 1, upgradeAmount do
            local success = pcall(function() endpoints:WaitForChild(Macro.UPGRADE_REMOTE):InvokeServer(targetUnit.Name) end)
            if success then
                task.wait(0.2)
                local newLevel = Util.getUnitUpgradeLevel(targetUnit)
                if newLevel > originalLevel then successfulUpgrades += 1 originalLevel = newLevel end
            end
        end
        if successfulUpgrades >= upgradeAmount then
            Macro.updateStatus(string.format("(%d/%d) SUCCESS: Upgraded %s", actionIndex, totalActions, placementId))
            return true
        end
        if attempt < Macro.UPGRADE_MAX_RETRIES then task.wait(Macro.RETRY_DELAY) end
    end
    return true
end

function Macro.validateSell(action, actionIndex, totalActions)
    local endpoints   = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local placementId = action.Unit
    local currentUUID = Macro.playbackPlacementToSpawnId[placementId]
    if not currentUUID then return false end
    local targetUnit  = Macro.findUnitBySpawnUUID(currentUUID)
    if not targetUnit then return false end
    local success = pcall(function() endpoints:WaitForChild(Macro.SELL_REMOTE):InvokeServer(targetUnit.Name) end)
    if success then
        task.wait(0.5)
        Macro.playbackPlacementToSpawnId[placementId] = nil
        return true
    end
    return true
end

-- ──────────────────────────────────────────────
-- Playback handler for purchase_unit.
-- Fires the remote with the raw UUID saved at record time.
-- No placement mapping needed here — the subsequent spawn_unit action
-- handles that when the player's recorded placement fires.
-- ──────────────────────────────────────────────
function Macro.validatePurchase(action, actionIndex, totalActions)
    local endpoints     = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local inventoryUUID = action.UUID
    if not inventoryUUID or inventoryUUID == "" then
        Macro.updateStatus(string.format("(%d/%d) FAILED: purchase_unit missing UUID", actionIndex, totalActions))
        return false
    end

    Macro.updateStatus(string.format("(%d/%d) Purchasing unit (%s)...", actionIndex, totalActions, inventoryUUID:sub(1, 8)))
    local success = pcall(function()
        endpoints:WaitForChild(Macro.PURCHASE_UNIT_REMOTE):InvokeServer(inventoryUUID)
    end)
    if success then
        -- Brief wait for unit_added_temporary to fire and populate temporaryUnits
        task.wait(0.5)
        Macro.updateStatus(string.format("(%d/%d) SUCCESS: Purchased unit", actionIndex, totalActions))
    else
        Macro.updateStatus(string.format("(%d/%d) FAILED: purchase_unit remote error", actionIndex, totalActions))
    end
    return true
end

-- ──────────────────────────────────────────────
-- NEW: playback handler for forge_trait_purchase
-- Resolves the unit's _stats.uuid from its placement ID mapping, then
-- fires forge_trait_purchase with that UUID and the saved trait type.
-- ──────────────────────────────────────────────
function Macro.validateForgeTrait(action, actionIndex, totalActions)
    local endpoints   = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local placementId = action.Unit
    local traitType   = action.TraitType or "unique"

    -- We need the _stats.uuid of the target unit (not the spawn UUID).
    -- playbackPlacementToSpawnId stores the _SPAWN_UNIT_UUID attribute.
    -- From that we get the actual unit instance and then read _stats.uuid.
    local spawnUUID  = Macro.playbackPlacementToSpawnId[placementId]
    local targetUnit = spawnUUID and Macro.findUnitBySpawnUUID(spawnUUID) or nil

    if not targetUnit then
        Macro.updateStatus(string.format("(%d/%d) FAILED: Unit not found for forge: %s", actionIndex, totalActions, placementId))
        return false
    end

    local stats     = targetUnit:FindFirstChild("_stats")
    local uuidValue = stats and stats:FindFirstChild("uuid")
    local spawnIdValue = stats and stats:FindFirstChild("spawn_id")
    if not uuidValue or not uuidValue:IsA("StringValue") then
        Macro.updateStatus(string.format("(%d/%d) FAILED: No UUID for forge target: %s", actionIndex, totalActions, placementId))
        return false
    end

    -- The forge remote expects uuid .. spawn_id combined, not just uuid
    local inventoryUUID = uuidValue.Value .. (spawnIdValue and tostring(spawnIdValue.Value) or "")
    Macro.updateStatus(string.format("(%d/%d) Forging trait (%s) on %s...", actionIndex, totalActions, traitType, placementId))
    local success = pcall(function()
        endpoints:WaitForChild(Macro.FORGE_TRAIT_REMOTE):InvokeServer(inventoryUUID, traitType)
    end)
    if success then
        Macro.updateStatus(string.format("(%d/%d) SUCCESS: Forged %s on %s", actionIndex, totalActions, traitType, placementId))
    else
        Macro.updateStatus(string.format("(%d/%d) FAILED: Forge remote error for %s", actionIndex, totalActions, placementId))
    end
    return true -- continue macro regardless
end

function Macro.executeAction(action, actionIndex, totalActions)
    if action.Type == "spawn_unit" then
        return Macro.validatePlacement(action, actionIndex, totalActions)
    elseif action.Type == "upgrade_unit_ingame" then
        return Macro.validateUpgrade(action, actionIndex, totalActions)
    elseif action.Type == "sell_unit_ingame" then
        return Macro.validateSell(action, actionIndex, totalActions)
    -- ── NEW ──────────────────────────────────────────
    elseif action.Type == "purchase_unit" then
        return Macro.validatePurchase(action, actionIndex, totalActions)
    elseif action.Type == "forge_trait_purchase" then
        return Macro.validateForgeTrait(action, actionIndex, totalActions)
    -- ─────────────────────────────────────────────────
    elseif action.Type == "vote_wave_skip" then
        task.spawn(function()
            local targetTime = tonumber(action.Time) or 0
            local waitTime   = targetTime - (tick() - GameTracking.gameStartTime)
            if waitTime > 0 and not Macro.ignoreTiming then task.wait(waitTime) end
            if not Macro.isPlaying or GameTracking.gameHasEnded then return end
            local voteSkipGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("VoteSkip")
            if not voteSkipGui or not voteSkipGui.Enabled then return end
            pcall(function()
                Services.ReplicatedStorage
                    :WaitForChild("endpoints")
                    :WaitForChild("client_to_server")
                    :WaitForChild(Macro.WAVE_SKIP_REMOTE)
                    :InvokeServer()
            end)
        end)
        return true
    else
        local isAbilityRemote = false
        for _, abilityRemote in ipairs(Macro.SPECIAL_ABILITY_REMOTES) do
            if action.Type == abilityRemote then isAbilityRemote = true break end
        end
        if isAbilityRemote then
            task.spawn(function()
                local targetTime = tonumber(action.Time) or 0
                local waitTime   = targetTime - (tick() - GameTracking.gameStartTime)
                if waitTime > 0 and not Macro.ignoreTiming then task.wait(waitTime) end
                if not Macro.isPlaying or GameTracking.gameHasEnded then return end
                local endpoints = Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server")
                if action.Type == "HestiaAssignBlade" then
                    local targetUUID = Macro.playbackPlacementToSpawnId[action.Target]
                    if targetUUID then
                        local targetUnit = Macro.findUnitBySpawnUUID(targetUUID)
                        if targetUnit then
                            local stats = targetUnit:FindFirstChild("_stats")
                            if stats then
                                local spawnIdValue = stats:FindFirstChild("spawn_id")
                                if spawnIdValue then pcall(function() endpoints:WaitForChild("HestiaAssignBlade"):InvokeServer(spawnIdValue.Value) end) end
                            end
                        end
                    end
                elseif action.Type == "LelouchChoosePiece" then
                    local lelouchUUID = Macro.playbackPlacementToSpawnId[action.Lelouch]
                    local targetUUID  = Macro.playbackPlacementToSpawnId[action.Target]
                    if lelouchUUID and targetUUID then
                        local lelouchUnit = Macro.findUnitBySpawnUUID(lelouchUUID)
                        local targetUnit  = Macro.findUnitBySpawnUUID(targetUUID)
                        if lelouchUnit and targetUnit then
                            local ls = lelouchUnit:FindFirstChild("_stats")
                            local ts = targetUnit:FindFirstChild("_stats")
                            if ls and ts then
                                local lSpawnId = ls:FindFirstChild("spawn_id")
                                local tSpawnId = ts:FindFirstChild("spawn_id")
                                if lSpawnId and tSpawnId then pcall(function() endpoints:WaitForChild("LelouchChoosePiece"):InvokeServer(lSpawnId.Value, tSpawnId.Value, action.Piece) end) end
                            end
                        end
                    end
                elseif action.Type == "DioWrites" then
                    local dioUUID = Macro.playbackPlacementToSpawnId[action.Dio]
                    if dioUUID then
                        local dioUnit = Macro.findUnitBySpawnUUID(dioUUID)
                        if dioUnit then
                            local stats = dioUnit:FindFirstChild("_stats")
                            if stats then
                                local spawnIdValue = stats:FindFirstChild("spawn_id")
                                if spawnIdValue then pcall(function() endpoints:WaitForChild("DioWrites"):InvokeServer(spawnIdValue.Value, action.Ability) end) end
                            end
                        end
                    end
                elseif action.Type == "use_active_attack" then
                    local currentUUID = Macro.playbackPlacementToSpawnId[action.Unit]
                    if currentUUID then
                        local targetUnit = Macro.findUnitBySpawnUUID(currentUUID)
                        if targetUnit then pcall(function() endpoints:WaitForChild("use_active_attack"):InvokeServer(targetUnit.Name) end) end
                    end
                else
                    if action.Args then pcall(function() endpoints:WaitForChild(action.Type):InvokeServer(unpack(action.Args)) end) end
                end
            end)
            return true
        end
    end
    return false
end

function Macro.play()
    if not Macro.actions or #Macro.actions == 0 then Macro.updateStatus("No macro data to play back") return false end
    if Macro.hasPlayedThisGame then Macro.updateStatus("Macro already played this game") return false end
    Macro.hasPlayedThisGame = true
    local totalActions      = #Macro.actions
    Macro.updateStatus(string.format("Starting playback with %d actions", totalActions))
    GameTracking.gameHasEnded = false
    Macro.clearSpawnIdMappings()
    if GameTracking.gameStartTime == 0 then GameTracking.gameStartTime = tick() end
    for i, action in ipairs(Macro.actions) do
        if not Macro.isPlaying or GameTracking.gameHasEnded then Macro.updateStatus("Macro interrupted") return false end
        -- Gate on money for any action that has a baked Cost (spawn, upgrade, purchase).
        if (action.Cost or 0) > 0 then
            if not Macro.waitForSufficientMoney(action, i, totalActions) then Macro.updateStatus("Money wait cancelled") return false end
        end
        if not Macro.ignoreTiming then
            local targetGameTime  = tonumber(action.Time) or 0
            local currentGameTime = tick() - GameTracking.gameStartTime
            local waitTime        = targetGameTime - currentGameTime
            if waitTime > 0 then
                Macro.updateStatus(string.format("(%d/%d) Waiting %.1fs for timing", i, totalActions, waitTime))
                local waitStart = tick()
                while tick() - waitStart < waitTime and Macro.isPlaying and not GameTracking.gameHasEnded do task.wait(0.1) end
            end
        else
            if i > 1 then task.wait(0.3) end
        end
        if not Macro.isPlaying or GameTracking.gameHasEnded then return false end
        Macro.executeAction(action, i, totalActions)
    end
    Macro.updateStatus("Macro playback completed")
    return true
end

-- ============================================================
-- MAIN INITIALIZATION
-- ============================================================
local function initialize()
    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()
    end)
    if not success or not Rayfield then
        warn("Failed to load Rayfield UI library:", Rayfield)
        return
    end
    _G.Rayfield = Rayfield

    local Window = Rayfield:CreateWindow({
        Name            = "LixHub - Anime Crusaders",
        Icon            = 0,
        LoadingTitle    = "Loading for Anime Crusaders",
        LoadingSubtitle = script_version,
        ShowText = "LixHub",
        Theme = {
            TextColor  = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(25, 25, 25),
            Topbar     = Color3.fromRGB(34, 34, 34),
            Shadow     = Color3.fromRGB(20, 20, 20),
        },

        ToggleUIKeybind = "K",

        DisableRayfieldPrompts = true,
        DisableBuildWarnings = true,

        ConfigurationSaving = {
            Enabled    = true,
            FolderName = "LixHub",
            FileName = game:GetService("Players").LocalPlayer.Name .. "_AnimeCrusaders",
        },
        Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },
   KeySystem = true,
    KeySettings = {
        Title = "LixHub - AC - Free",
        Subtitle = "LixHub - Key System",
        Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
        FileName = "LixHub_Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"0xLIXHUB"}
    }
    })
    local LobbyTab = Window:CreateTab("Lobby", "tv")

        LobbyTab:CreateToggle({
        Name         = "Enable Script Notifications",
        CurrentValue = true,
        Flag         = "EnableNotifications",
        Callback     = function(Value)
            NOTIFICATION_ENABLED = Value
        end,
    })
    -- ══════════════════════════════════════════════
    -- TAB: AUTO DUNGEON
    -- ══════════════════════════════════════════════
    local DungeonTab = Window:CreateTab("Expedition", "swords")

    DungeonTab:CreateSection("Expedition")

    DungeonTab:CreateDropdown({
        Name            = "Expedition Mode",
        Options         = { "Roguelike", "Normal" },
        CurrentOption   = { "Roguelike" },
        MultipleOptions = false,
        Flag            = "DungeonMode",
        Callback        = function(selected)
            local val = type(selected) == "table" and selected[1] or selected
            Dungeon.config.mode = (val == "Normal") and "_NoShopMode1" or "_JojosMode1"
        end,
    })

    DungeonTab:CreateToggle({
        Name         = "Auto Expedition",
        CurrentValue = false,
        Flag         = "AutoDungeonToggle",
        Callback     = function(value)
            if value then
                if Dungeon.isRunning then return end
                Util.notify("Auto Dungeon", "Starting expedition...")
                Dungeon.run()
            else
                Dungeon.stop()
                Util.notify("Auto Dungeon", "Stopped.")
            end
        end,
    })

    DungeonTab:CreateToggle({
        Name         = "Auto Next Expedition",
        CurrentValue = false,
        Flag         = "AutoNextExpedition",
        Callback     = function(Value)
            State.AutoNextExpedition = Value
        end,
    })

    -- ══════════════════════════════════════════════
    -- TAB: MACRO
    -- ══════════════════════════════════════════════
    local MacroTab = Window:CreateTab("Macro", "joystick")

    local MacroStatusLabel = MacroTab:CreateLabel("Status: Ready")
    Macro.detailedStatusLabel = MacroTab:CreateLabel("Details: Ready")

    MacroTab:CreateDivider()

    local MacroDropdown = MacroTab:CreateDropdown({
        Name            = "Select Macro",
        Options         = {},
        CurrentOption   = {},
        MultipleOptions = false,
        Flag            = "MacroDropdown",
        Callback        = function(selected)
            local selectedName = type(selected) == "table" and selected[1] or selected
            Macro.currentName  = selectedName
            if selectedName and Macro.library[selectedName] then
                Macro.actions = Macro.library[selectedName]
            end
        end,
    })

    local function refreshMacroDropdown()
        local options = {}
        for name in pairs(Macro.library) do table.insert(options, name) end
        table.sort(options)
        MacroDropdown:Refresh(options, Macro.currentName)
    end

    MacroTab:CreateInput({
        Name                     = "Create Macro",
        CurrentValue             = "",
        PlaceholderText          = "Enter macro name...",
        RemoveTextAfterFocusLost = true,
        Callback                 = function(text)
            local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            if cleanedName ~= "" then
                if Macro.library[cleanedName] then Util.notify("Error", "Macro already exists.") return end
                Macro.library[cleanedName] = {}
                Macro.saveToFile(cleanedName)
                refreshMacroDropdown()
                Util.notify("Success", "Created macro '" .. cleanedName .. "'.")
            end
        end,
    })

    MacroTab:CreateButton({
        Name     = "Refresh Macro List",
        Callback = function()
            Macro.loadAll()
            refreshMacroDropdown()
            Util.notify("Success", "Macro list refreshed.")
        end,
    })

    MacroTab:CreateButton({
        Name     = "Delete Selected Macro",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then Util.notify("Error", "No macro selected.") return end
            Macro.delete(Macro.currentName)
            Util.notify("Deleted", "Deleted macro '" .. Macro.currentName .. "'.")
            Macro.currentName = ""
            Macro.actions     = {}
            refreshMacroDropdown()
        end,
    })

    local RecordToggle = MacroTab:CreateToggle({
        Name         = "Record Macro",
        CurrentValue = false,
        Flag         = "RecordMacro",
        Callback     = function(Value)
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

    MacroTab:CreateToggle({
        Name         = "Playback Macro",
        CurrentValue = false,
        Flag         = "PlaybackMacro",
        Callback     = function(Value)
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
                                break
                            end
                            local loadedMacro = Macro.loadFromFile(Macro.currentName)
                            if not loadedMacro or #loadedMacro == 0 then
                                MacroStatusLabel:Set("Status: Error - Failed to load macro!")
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

    MacroTab:CreateToggle({
        Name         = "Random Offset",
        CurrentValue = false,
        Flag         = "RandomOffsetEnabled",
        Info         = "Slightly randomize placement positions",
        Callback     = function(Value) Macro.randomOffsetEnabled = Value end,
    })

    MacroTab:CreateSlider({
        Name         = "Offset Amount",
        Range        = { 0.1, 5.0 },
        Increment    = 0.1,
        Suffix       = " studs",
        CurrentValue = 0.5,
        Flag         = "RandomOffsetAmount",
        Info         = "Maximum random offset distance (recommended: 0.5)",
        Callback     = function(Value) Macro.randomOffsetAmount = Value end,
    })

    MacroTab:CreateToggle({
        Name         = "Ignore Timing",
        CurrentValue = false,
        Flag         = "IgnoreTiming",
        Info         = "Execute actions immediately without waiting for timing",
        Callback     = function(Value) Macro.ignoreTiming = Value end,
    })

    MacroTab:CreateInput({
        Name                     = "Import Macro",
        CurrentValue             = "",
        PlaceholderText          = "Paste JSON/TXT/URL here...",
        RemoveTextAfterFocusLost = true,
        Callback                 = function(text)
            if not text or text:match("^%s*$") then return end
            local macroName = "ImportedMacro_" .. os.time()
            if text:match("^https?://") then
                local fileName = text:match("/([^/?]+)%.json") or text:match("/([^/?]+)%.txt") or text:match("/([^/?]+)$")
                if fileName then macroName = fileName:gsub("%.json.*$", ""):gsub("%.txt.*$", "") end
                Macro.importFromURL(text, macroName)
            else
                local isJSON = false
                pcall(function() Services.HttpService:JSONDecode(text) isJSON = true end)
                if isJSON then Macro.importFromJSON(text, macroName) else Macro.importFromTXT(text, macroName) end
            end
            refreshMacroDropdown()
        end,
    })

    MacroTab:CreateButton({
        Name     = "Export Macro To Clipboard",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then Util.notify("Export Error", "No macro selected.") return end
            Macro.exportToClipboard(Macro.currentName)
        end,
    })

    MacroTab:CreateButton({
        Name     = "Export Macro To Webhook",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then Util.notify("Export Error", "No macro selected.") return end
            if not Webhook.url or Webhook.url == "" then Util.notify("Export Error", "Please enter a webhook URL first.") return end
            Macro.exportToWebhook(Macro.currentName, Webhook.url)
        end,
    })

    MacroTab:CreateButton({
        Name     = "Check Macro Units",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then Util.notify("Check Error", "No macro selected.") return end
            local macroData = Macro.library[Macro.currentName]
            if not macroData or #macroData == 0 then Util.notify("Check Error", "Selected macro is empty.") return end
            local unitsUsed = {}
            for _, action in ipairs(macroData) do
                if action.Type == "spawn_unit" and action.Unit then
                    local baseUnitName = action.Unit:match("^(.+) #%d+$") or action.Unit
                    unitsUsed[baseUnitName] = true
                end
            end
            local unitsList = {}
            for unitName in pairs(unitsUsed) do table.insert(unitsList, unitName) end
            if #unitsList > 0 then
                table.sort(unitsList)
                Util.notify(Macro.currentName, table.concat(unitsList, ", "))
            else
                Util.notify(Macro.currentName, "No units found in this macro.")
            end
        end,
    })

    -- ══════════════════════════════════════════════
    -- TAB: GAME
    -- ══════════════════════════════════════════════
    local GameTab = Window:CreateTab("Game", "gamepad-2")

    GameTab:CreateSection("Player")

    GameTab:CreateSlider({
        Name         = "Max Camera Zoom Distance",
        Range        = { 5, 100 },
        Increment    = 1,
        Suffix       = " studs",
        CurrentValue = 35,
        Flag         = "CameraZoomDistance",
        Callback     = function(Value)
            Services.Players.LocalPlayer.CameraMaxZoomDistance = Value
        end,
    })

    GameTab:CreateToggle({
        Name         = "Anti AFK (No Kick)",
        CurrentValue = false,
        Flag         = "AntiAfkKick",
        Info         = "Prevents the Roblox idle-kick.",
        Callback     = function(Value)
            State.AntiAfkKickEnabled = Value
        end,
    })

    Services.Players.LocalPlayer.Idled:Connect(function()
        if State.AntiAfkKickEnabled then
            Services.VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            Services.VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)

    GameTab:CreateToggle({
        Name         = "Low Performance Mode",
        CurrentValue = false,
        Flag         = "LowPerfMode",
        Callback     = function(Value)
            State.EnableLowPerfMode = Value
            Util.setLowPerformanceMode(Value)
        end,
    })

    GameTab:CreateToggle({
        Name         = "Black Screen",
        CurrentValue = false,
        Flag         = "BlackScreen",
        Callback     = function(Value)
            State.EnableBlackScreen = Value
            Util.setBlackScreen(Value)
        end,
    })

    GameTab:CreateToggle({
        Name         = "Limit FPS",
        CurrentValue = false,
        Flag         = "LimitFPS",
        Callback     = function(Value)
            State.EnableLimitFPS = Value
            if Value and State.SelectedFPS > 0 then
                setfpscap(State.SelectedFPS)
            else
                setfpscap(0)
            end
        end,
    })

    GameTab:CreateSlider({
        Name         = "Limit FPS To",
        Range        = { 10, 240 },
        Increment    = 1,
        Suffix       = " FPS",
        CurrentValue = 60,
        Flag         = "FPSLimit",
        Callback     = function(Value)
            State.SelectedFPS = Value
            if State.EnableLimitFPS then setfpscap(Value) end
        end,
    })

    GameTab:CreateToggle({
        Name         = "Streamer Mode",
        CurrentValue = false,
        Flag         = "StreamerMode",
        Info         = "Hides your name, level, and title in the overhead billboard.",
        Callback     = function(Value)
            State.StreamerModeEnabled = Value
        end,
    })

    task.spawn(function()
        while true do
            task.wait(0.1)
            if not State.StreamerModeEnabled then continue end
            pcall(function()
                local lp        = Services.Players.LocalPlayer
                local head      = lp.Character and lp.Character:FindFirstChild("Head")
                if not head then return end
                local billboard = head:FindFirstChild("overhead_player")
                if not billboard then return end
                local frame     = billboard:FindFirstChild("Frame")
                if not frame then return end
                local nameFrame  = frame:FindFirstChild("Name_Frame")
                local levelFrame = frame:FindFirstChild("Level_Frame")
                if nameFrame and nameFrame:FindFirstChild("Name_Text") then
                    nameFrame.Name_Text.Text = "🔥 PROTECTED BY LIXHUB 🔥"
                end
                if levelFrame and levelFrame:FindFirstChild("Level") then
                    levelFrame.Level.Text = "999"
                end
            end)
        end
    end)

    GameTab:CreateSection("Game")

    GameTab:CreateToggle({
        Name         = "Delete Enemies",
        CurrentValue = false,
        Flag         = "DeleteEnemies",
        Info         = "Removes enemy models from the map as they spawn.",
        Callback     = function(Value)
            State.DeleteEntities = Value
            if Value then
                task.spawn(function()
                    local function isEnemy(unit)
                        local stats = unit:FindFirstChild("_stats")
                        if not stats then return true end
                        local maxUpgrade = stats:FindFirstChild("max_upgrade")
                        if not maxUpgrade or maxUpgrade.Value == 0 then return true end
                        local playerValue = stats:FindFirstChild("player")
                        return not (playerValue and playerValue:IsA("ObjectValue"))
                    end
                    local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
                    if not unitsFolder then return end
                    for _, unit in pairs(unitsFolder:GetChildren()) do
                        if isEnemy(unit) then unit:Destroy() end
                    end
                    State.childAddedConnection = unitsFolder.ChildAdded:Connect(function(child)
                        if State.DeleteEntities then
                            task.wait(0.1)
                            if isEnemy(child) then child:Destroy() end
                        end
                    end)
                end)
            else
                if State.childAddedConnection then
                    State.childAddedConnection:Disconnect()
                    State.childAddedConnection = nil
                end
            end
        end,
    })

    GameTab:CreateToggle({
        Name         = "Auto Start Game",
        CurrentValue = false,
        Flag         = "AutoStartGame",
        Callback     = function(Value)
            State.AutoVoteStart = Value
        end,
    })

    task.spawn(function()
        while true do
            task.wait(1)
            if not State.AutoVoteStart then continue end
            if Util.isInLobby() then continue end
            local waveNum = Services.Workspace:FindFirstChild("_wave_num")
            if waveNum and waveNum.Value == 0 then
                if State.AutoEquipMacroUnits and Macro.currentName and Macro.currentName ~= "" then
                    Util.autoEquipMacroUnits(Macro.currentName, Macro.library)
                    task.wait(1)
                end
                pcall(function()
                    Services.ReplicatedStorage
                        :WaitForChild("endpoints")
                        :WaitForChild("client_to_server")
                        :WaitForChild("vote_start")
                        :InvokeServer()
                end)
            end
        end
    end)

    GameTab:CreateToggle({
        Name         = "Auto Retry",
        CurrentValue = false,
        Flag         = "AutoRetry",
        Callback     = function(Value)
            State.AutoVoteRetry = Value
        end,
    })

    GameTab:CreateToggle({
        Name         = "Auto Next",
        CurrentValue = false,
        Flag         = "AutoNext",
        Callback     = function(Value)
            State.AutoVoteNext = Value
        end,
    })

    GameTab:CreateToggle({
        Name         = "Auto Lobby",
        CurrentValue = false,
        Flag         = "AutoLobby",
        Callback     = function(Value)
            State.AutoVoteLobby = Value
        end,
    })

    GameTab:CreateToggle({
        Name         = "Auto Skip Waves",
        CurrentValue = false,
        Flag         = "AutoSkipWaves",
        Callback     = function(Value)
            State.AutoSkipWaves = Value
            Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("toggle_setting"):InvokeServer("autoskip_waves", Value)
        end,
    })

    GameTab:CreateSlider({
        Name         = "Auto Skip Until Wave",
        Range        = { 0, 30 },
        Increment    = 1,
        Suffix       = "",
        CurrentValue = 0,
        Flag         = "AutoSkipUntilWave",
        Info         = "Stop skipping waves once this wave is reached (0 = always skip).",
        Callback     = function(Value)
            State.AutoSkipUntilWave = Value
        end,
    })

task.spawn(function()
    local skipEnabled = false  -- tracks whether we've already sent the enable call
    while true do
        task.wait(1)
        if not State.AutoSkipWaves then
            if skipEnabled then
                skipEnabled = false
                pcall(function()
                    Services.ReplicatedStorage
                        :WaitForChild("endpoints")
                        :WaitForChild("client_to_server")
                        :WaitForChild("toggle_setting"):InvokeServer("autoskip_waves", false)
                end)
            end
            continue
        end
        if Util.isInLobby() then continue end
        local waveNum = Services.Workspace:FindFirstChild("_wave_num")
        if not waveNum then continue end
        local current = waveNum.Value
        local limit   = State.AutoSkipUntilWave

        if limit > 0 and current >= limit then
            State.AutoSkipWaves = false
            skipEnabled = false
            pcall(function()
                Services.ReplicatedStorage
                    :WaitForChild("endpoints")
                    :WaitForChild("client_to_server")
                    :WaitForChild("toggle_setting"):InvokeServer("autoskip_waves", false)
            end)
            Util.notify("Auto Skip Waves", string.format("Disabled — reached wave %d", limit))
        elseif not skipEnabled then
            skipEnabled = true
            pcall(function()
                Services.ReplicatedStorage
                    :WaitForChild("endpoints")
                    :WaitForChild("client_to_server")
                    :WaitForChild("toggle_setting"):InvokeServer("autoskip_waves", true)
            end)
        end
    end
end)

    GameTab:CreateSection("Boss Rush")

    local BossRushModifier = "Slot"

    GameTab:CreateToggle({
        Name         = "Auto Select Card",
        CurrentValue = false,
        Flag         = "AutoSelectCardBossRush",
        Info         = "Automatically picks a modifier card in Boss Rush.",
        Callback     = function(Value)
            State.AutoSelectCardBossRush = Value
        end,
    })

    GameTab:CreateDropdown({
        Name            = "Preferred Modifier",
        Options         = { "Unit Slot", "Damage", "Placement Limit" },
        CurrentOption   = { "Unit Slot" },
        MultipleOptions = false,
        Flag            = "BossRushModifier",
        Callback        = function(Option)
            local val = type(Option) == "table" and Option[1] or Option
            if val == "Damage" then
                BossRushModifier = "Damage"
            elseif val == "Placement Limit" then
                BossRushModifier = "Placement"
            else
                BossRushModifier = "Slot"
            end
        end,
    })

    task.spawn(function()
        while true do
            task.wait(1)
            if not State.AutoSelectCardBossRush then continue end
            local promptGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Prompt")
            if promptGui and promptGui.Enabled then
                pcall(function()
                    Services.ReplicatedStorage
                        :WaitForChild("endpoints")
                        :WaitForChild("client_to_server")
                        :WaitForChild("request_makima_sacrifice")
                        :InvokeServer(BossRushModifier)
                end)
            end
        end
    end)

    GameTab:CreateSection("Auto Sell")

    GameTab:CreateToggle({
        Name         = "Auto Sell All Units",
        CurrentValue = false,
        Flag         = "AutoSellEnabled",
        Info         = "Sell all your placed units when the target wave is reached.",
        Callback     = function(Value)
            State.AutoSellEnabled = Value
        end,
    })

    GameTab:CreateSlider({
        Name         = "Sell on Wave",
        Range        = { 1, 500 },
        Increment    = 1,
        Suffix       = "",
        CurrentValue = 10,
        Flag         = "AutoSellWave",
        Callback     = function(Value)
            State.AutoSellWave = Value
        end,
    })

    GameTab:CreateToggle({
        Name         = "Auto Sell Farm Units",
        CurrentValue = false,
        Flag         = "AutoSellFarmEnabled",
        Callback     = function(Value)
            State.AutoSellFarmEnabled = Value
        end,
    })

    GameTab:CreateSlider({
        Name         = "Sell Farm Units on Wave",
        Range        = { 1, 500 },
        Increment    = 1,
        Suffix       = "",
        CurrentValue = 15,
        Flag         = "AutoSellFarmWave",
        Callback     = function(Value)
            State.AutoSellFarmWave = Value
        end,
    })

    local _lastSellWave     = 0
    local _lastFarmSellWave = 0

    local function sellAllPlayerUnits()
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        if not unitsFolder then return end
        local toSell = {}
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if Util.isOwnedByLocalPlayer(unit) then table.insert(toSell, unit) end
        end
        local sold = 0
        for _, unit in pairs(toSell) do
            pcall(function()
                Services.ReplicatedStorage
                    :WaitForChild("endpoints")
                    :WaitForChild("client_to_server")
                    :WaitForChild("sell_unit_ingame")
                    :InvokeServer(unit.Name)
                sold += 1
            end)
            task.wait(0.1)
        end
        if sold > 0 then
            Util.notify("Auto Sell", string.format("Sold %d units on wave %d", sold, State.AutoSellWave))
        end
    end

    local function sellFarmUnits()
        local unitsFolder = Services.Workspace:FindFirstChild("_UNITS")
        if not unitsFolder then return end
        local toSell = {}
        for _, unit in pairs(unitsFolder:GetChildren()) do
            if Util.isOwnedByLocalPlayer(unit) then
                local stats      = unit:FindFirstChild("_stats")
                local farmAmount = stats and stats:FindFirstChild("farm_amount")
                if farmAmount and farmAmount.Value and farmAmount.Value > 0 then
                    table.insert(toSell, unit)
                end
            end
        end
        local sold = 0
        for _, unit in pairs(toSell) do
            pcall(function()
                Services.ReplicatedStorage
                    :WaitForChild("endpoints")
                    :WaitForChild("client_to_server")
                    :WaitForChild("sell_unit_ingame")
                    :InvokeServer(unit.Name)
                sold += 1
            end)
            task.wait(0.1)
        end
        if sold > 0 then
            Util.notify("Auto Sell Farm", string.format("Sold %d farm units on wave %d", sold, State.AutoSellFarmWave))
        end
    end

    task.spawn(function()
        if not Services.Workspace:FindFirstChild("_wave_num") then
            Services.Workspace:WaitForChild("_wave_num")
        end
        local waveNum = Services.Workspace._wave_num
        waveNum.Changed:Connect(function(newWave)
            if State.AutoSellEnabled and newWave == State.AutoSellWave and newWave ~= _lastSellWave then
                _lastSellWave = newWave
                task.wait(0.5)
                sellAllPlayerUnits()
            end
            if State.AutoSellFarmEnabled and newWave == State.AutoSellFarmWave and newWave ~= _lastFarmSellWave then
                _lastFarmSellWave = newWave
                task.wait(0.5)
                sellFarmUnits()
            end
        end)
    end)

    GameTab:CreateSection("Failsafes")

    GameTab:CreateSlider({
        Name         = "Return to Lobby After X Games",
        Range        = { 0, 100 },
        Increment    = 1,
        Suffix       = " games",
        CurrentValue = 0,
        Flag         = "ReturnToLobbyAfterGames",
        Info         = "Teleport to lobby after this many completed games (0 = disabled).",
        Callback     = function(Value)
            State.ReturnToLobbyAfterGames = Value
        end,
    })

    GameTab:CreateToggle({
        Name         = "Return to Lobby Failsafe",
        CurrentValue = false,
        Flag         = "ReturnToLobbyFailsafe",
        Info         = "Teleport to lobby if no auto-vote fires within 10s of game end.",
        Callback     = function(Value)
            State.ReturnToLobbyFailsafe = Value
        end,
    })

    GameTab:CreateToggle({
        Name         = "Return to Lobby if Game Never Ends",
        CurrentValue = false,
        Flag         = "ReturnToLobbyNeverEnds",
        Info         = "Teleport to lobby if the game runs for more than 20 minutes.",
        Callback     = function(Value)
            State.ReturnToLobbyIfNeverEnds = Value
        end,
    })

    task.spawn(function()
        while true do
            task.wait(1)
            if not State.ReturnToLobbyIfNeverEnds then continue end
            if not GameTracking.gameInProgress      then continue end
            if Util.isInLobby()                    then continue end
            local elapsed = tick() - GameTracking.gameStartTime
            if elapsed >= 1200 then
                Util.notify("20-Min Failsafe",
                    string.format("Game ran %.1f min — returning to lobby", elapsed / 60))
                GameTracking.endGame()
                Macro.isPlaying = false
                pcall(function()
                    Services.ReplicatedStorage
                        :WaitForChild("endpoints")
                        :WaitForChild("client_to_server")
                        :WaitForChild("teleport_back_to_lobby")
                        :InvokeServer()
                end)
            end
        end
    end)

    MacroTab:CreateToggle({
        Name         = "Auto Equip Macro Units",
        CurrentValue = false,
        Flag         = "AutoEquipMacroUnits",
        Info         = "Equips the correct units before the game starts (requires Auto Start Game).",
        Callback     = function(Value)
            State.AutoEquipMacroUnits = Value
        end,
    })

    MacroTab:CreateButton({
        Name     = "Equip Macro Units Now",
        Callback = function()
            if not Macro.currentName or Macro.currentName == "" then
                Util.notify("Equip Error", "No macro selected.")
                return
            end
            Util.autoEquipMacroUnits(Macro.currentName, Macro.library)
        end,
    })

    local WebhookTab = Window:CreateTab("Webhook", "link")

    WebhookTab:CreateSection("Configuration")

    WebhookTab:CreateInput({
        Name                     = "Webhook URL",
        CurrentValue             = "",
        PlaceholderText          = "https://discord.com/api/webhooks/...",
        RemoveTextAfterFocusLost = false,
        Callback                 = function(text) Webhook.url = text end,
    })

    WebhookTab:CreateInput({
        Name                     = "Discord User ID (for pings)",
        CurrentValue             = "",
        PlaceholderText          = "Your Discord user ID...",
        RemoveTextAfterFocusLost = false,
        Callback                 = function(text) Webhook.discordUserId = text end,
    })

    WebhookTab:CreateToggle({
        Name         = "Send Webhook on Stage End",
        CurrentValue = false,
        Flag         = "WebhookOnFinish",
        Callback     = function(Value) end,
    })

    WebhookTab:CreateButton({
        Name     = "Send Test Webhook",
        Callback = function()
            if not Webhook.url or Webhook.url == "" then
                Util.notify("Webhook", "Enter a URL first!")
                return
            end
            local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
            if not requestFunc then Util.notify("Webhook", "HTTP not supported by executor") return end
            pcall(function()
                requestFunc({
                    Url     = Webhook.url,
                    Method  = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body    = Services.HttpService:JSONEncode({
                        username = "LixHub",
                        embeds   = {{ title = "Test", description = "Webhook working!", color = 0x57F287 }}
                    }),
                })
            end)
            Util.notify("Webhook", "Test sent!")
        end,
    })

    -- ══════════════════════════════════════════════
    -- GAME TRACKING HOOKS
    -- ══════════════════════════════════════════════
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
        if waveNum.Value >= 1 then
            GameTracking.startGame()
            if Macro.isRecording and not Macro.recordingHasStarted then
                Macro.startRecording()
                MacroStatusLabel:Set("Status: Recording active!")
            end
        end
    end

    local function setupRemoteConnections()
        local gameFinishedRemote = Services.ReplicatedStorage
            :FindFirstChild("endpoints")
            :FindFirstChild("server_to_client")
            :FindFirstChild("game_finished")

        local endpoints_stc = Services.ReplicatedStorage
            :FindFirstChild("endpoints")
            :FindFirstChild("server_to_client")

        local normalItemRemote = endpoints_stc:FindFirstChild("normal_item_added")
        if normalItemRemote then
            normalItemRemote.OnClientEvent:Connect(function(itemId, quantity)
                Webhook.sessionItems[itemId] = (Webhook.sessionItems[itemId] or 0) + (quantity or 1)
            end)
        end

        local unitAddedRemote = endpoints_stc:FindFirstChild("unit_added")
        if unitAddedRemote then
            unitAddedRemote.OnClientEvent:Connect(function(unitData)
                local unitId      = type(unitData) == "table" and (unitData.id or unitData.unit_id) or tostring(unitData)
                local displayName = Util.getDisplayNameFromUnitId(unitId) or unitId
                Webhook.onUnitAdded(displayName)
            end)
        end

        task.spawn(function()
            local wn = Services.Workspace:WaitForChild("_wave_num")
            wn.Changed:Connect(function(v) Webhook.lastWave = v end)
        end)

        if gameFinishedRemote then
            gameFinishedRemote.OnClientEvent:Connect(function(...)
                local isVictory = false
                for _, arg in ipairs({...}) do
                    if type(arg) == "table" and arg.victory ~= nil then
                        isVictory = arg.victory == true
                        break
                    elseif type(arg) == "boolean" then
                        isVictory = arg
                        break
                    end
                end

                GameTracking.endGame()
                Macro.hasPlayedThisGame = false

                State.TotalGamesPlayed += 1
                if isVictory then
                    State.TotalWins  += 1
                else
                    State.TotalLosses += 1
                end

                Webhook.gameResult = isVictory and "Victory" or "Defeat"
                if Webhook.url and Webhook.url ~= "" then
                    task.spawn(function()
                        task.wait(0.5)
                        Webhook.send()
                    end)
                end

                if Dungeon.isRunning then Dungeon.stop() end

                if Macro.isRecording then
                    Macro.stopRecording()
                    Util.notify("Recording Stopped", "Game ended, recording saved.")
                    RecordToggle:Set(false)
                    if Macro.currentName then
                        Macro.library[Macro.currentName] = Macro.actions
                        Macro.saveToFile(Macro.currentName)
                    end
                end

                if State.ReturnToLobbyFailsafe then
                    State.failsafeActive = true
                    task.delay(10, function()
                        if State.failsafeActive and not Util.isInLobby() then
                            Util.notify("Failsafe", "No vote detected — returning to lobby")
                            pcall(function()
                                Services.ReplicatedStorage
                                    :WaitForChild("endpoints")
                                    :WaitForChild("client_to_server")
                                    :WaitForChild("teleport_back_to_lobby")
                                    :InvokeServer()
                            end)
                        end
                    end)
                end

                task.spawn(function()
                    task.wait(1)

                    local endpoints = Services.ReplicatedStorage
                        :WaitForChild("endpoints")
                        :WaitForChild("client_to_server")

                    local function tryVote(remoteCalls)
                        for attempt = 1, State.AutoRetryAttempts do
                            for _, call in ipairs(remoteCalls) do
                                pcall(call)
                            end
                            task.wait(2)
                            local resultsUI = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("ResultsUI")
                            if not resultsUI or not resultsUI.Enabled then
                                State.failsafeActive = false
                                return true
                            end
                            if attempt < State.AutoRetryAttempts then task.wait(State.AutoRetryDelay) end
                        end
                        return false
                    end

                    local function runVotes()
                        if State.AutoNextExpedition then
                            local nextRoom = Dungeon.getNextUnfinishedRoom()
                            if nextRoom then
                                local voted = false
                                for attempt = 1, State.AutoRetryAttempts do
                                    if Dungeon.voteNextRoom(nextRoom) then
                                        task.wait(2)
                                        local resultsUI = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("ResultsUI")
                                        if not resultsUI or not resultsUI.Enabled then
                                            State.failsafeActive = false
                                            voted = true
                                            break
                                        end
                                    end
                                    task.wait(State.AutoRetryDelay)
                                end
                                if voted then return end
                            else
                                Util.notify("Auto Next Expedition", "All dungeon rooms completed!")
                            end
                        end

                        if State.AutoVoteRetry then
                            if tryVote({
                                function() endpoints:WaitForChild("set_game_finished_vote"):InvokeServer("replay") end
                            }) then return end
                        end

                        if State.AutoVoteNext and isVictory then
                            if tryVote({
                                function() endpoints:WaitForChild("set_game_finished_vote"):InvokeServer("next_story") end,
                                function() endpoints:WaitForChild("set_game_finished_vote"):InvokeServer("next_raid")  end,
                            }) then return end
                        end

                        if State.AutoVoteLobby then
                            tryVote({
                                function()
                                    task.wait(1)
                                    endpoints:WaitForChild("teleport_back_to_lobby"):InvokeServer()
                                end
                            })
                        end
                    end

                    runVotes()

                    if State.ReturnToLobbyAfterGames > 0
                    and State.TotalGamesPlayed >= State.ReturnToLobbyAfterGames then
                        Util.notify("Game Counter",
                            string.format("Reached %d games — returning to lobby", State.ReturnToLobbyAfterGames))
                        task.wait(2)
                        pcall(function()
                            endpoints:WaitForChild("teleport_back_to_lobby"):InvokeServer()
                        end)
                        State.TotalGamesPlayed = 0
                        State.TotalWins        = 0
                        State.TotalLosses      = 0
                    end

                    GameTracking.reset()
                end)
            end)
        end
    end

    -- ── FINALIZE ──────────────────────────────────
    Util.ensureFolders()
    Macro.loadAll()
    refreshMacroDropdown()
    Macro.setupHook()
    setupRemoteConnections()
    if not Util.isInLobby() then monitorWaves() end
    _G.Rayfield:LoadConfiguration()
    Util.notify("LixHub", "Loaded successfully!")
end

initialize()
_G.Rayfield:SetVisibility(false)

_G.Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image = "eye-off",
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})
