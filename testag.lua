--[[
    LixHub - Anime Guardians
    Full Rewrite - Clean Modular Architecture
    
    Design principles:
    - All logic lives in module tables (M.xxx), not locals → no 200 local limit
    - Single __namecall hook
    - Event-driven where possible, minimal polling
    - Centralized State table
    - Reliable unit tracking via origin attribute
--]]

-- ============================================================
-- EXECUTOR CHECK
-- ============================================================
if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller
    and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED")
    return
end

if game.PlaceId ~= 17282336195 and game.PlaceId ~= 17400753636 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

-- ============================================================
-- CORE SETUP
-- ============================================================
local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua"
))()

local SCRIPT_VERSION = "V1.0"

local Window = Rayfield:CreateWindow({
    Name             = "LixHub - Anime Guardians",
    Icon             = 0,
    LoadingTitle     = "Loading for Anime Guardians",
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
    ConfigurationSaving   = { Enabled = true, FolderName = "LixHub", FileName = "LixHub_AG_v2" },
    Discord               = { Enabled = true, Invite = "cYKnXE2Nf8", RememberJoins = true },
    KeySystem             = true,
    KeySettings = {
        Title          = "LixHub - Anime Guardians - Free",
        Subtitle       = "LixHub - Key System",
        Note           = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
        FileName       = "LixHub_Key",
        SaveKey        = true,
        GrabKeyFromSite= false,
        Key            = {"0xLIXHUB"},
    },
})

-- ============================================================
-- SERVICES  (kept as a table, not 10 separate locals)
-- ============================================================
local Svc = {
    Players          = game:GetService("Players"),
    ReplicatedStorage= game:GetService("ReplicatedStorage"),
    Workspace        = game:GetService("Workspace"),
    TeleportService  = game:GetService("TeleportService"),
    RunService       = game:GetService("RunService"),
    HttpService      = game:GetService("HttpService"),
    VirtualUser      = game:GetService("VirtualUser"),
    Lighting         = game:GetService("Lighting"),
}
local LP  = Svc.Players.LocalPlayer
local RS  = Svc.ReplicatedStorage

-- ============================================================
-- CENTRALISED STATE  (one table, never scattered)
-- ============================================================
local DEBUG = true  -- Set to true when testing to see all debug prints

local State = {
    -- system
    DisableNotifications    = false,
    -- joiner
    AutoJoinStory           = false,
    StoryStage              = nil,
    StoryAct                = nil,
    StoryDifficulty         = nil,
    AutoJoinRaid            = false,
    RaidStage               = nil,
    AutoJoinPortal          = false,
    PortalStage             = nil,
    AutoJoinChallenge       = false,
    AutoJoinEvent           = false,
    EventStage              = nil,
    AutoJoinWorldlines      = false,
    WorldlinesStage         = nil,
    AutoJoinTower           = false,
    TowerStage              = nil,
    AutoJoinGate            = false,
    AutoJoinDelay           = 0,
    -- game
    AutoStartGame           = false,
    AutoVoteRetry           = false,
    AutoVoteNext            = false,
    AutoVoteLobby           = false,
    AutoSkipWaves           = false,
    AutoSkipUntilWave       = 0,
    AutoSellEnabled         = false,
    AutoSellWave            = 10,
    AutoSellFarmEnabled     = false,
    AutoSellFarmWave        = 15,
    AutoUseAbility          = false,
    SelectedUnitsForAbility = {},
    SelectedAbilitiesToUse  = {},
    AntiAfkEnabled          = false,
    DeleteEnemies           = false,
    BlackScreen             = false,
    LowPerfMode             = false,
    LimitFPS                = false,
    SelectedFPS             = 60,
    StreamerMode            = false,
    BlockBossDamage         = false,
    AutoBreakZafkiel        = false,
    AutoCollectChests       = false,
    AutoCollectDio          = false,
    AutoPickCard            = false,
    AutoPickCardSelected    = nil,
    AutoPurchaseDio         = false,
    AutoPurchaseDioItem     = nil,
    AutoPurchaseGriffith    = false,
    AutoPurchaseGriffithItem= nil,
    AutoPurchaseRagna       = false,
    AutoPurchaseRagnaItem   = nil,
    enableAutoExecute       = false,
    -- webhook
    WebhookURL              = nil,
    DiscordUserID           = nil,
    SendWebhookOnFinish     = false,
    -- macro
    IgnoreTiming            = false,
    -- game tracking (internal)
    gameInProgress          = false,
    gameStartTime           = 0,
    gameStartRealTime       = 0,
    gameEndRealTime         = 0,
}

-- ============================================================
-- AUTOJOINER RATE-LIMIT
-- ============================================================
local Joiner = { processing = false, lastTime = 0, cooldown = 2.5 }
function Joiner.canAct()
    return not Joiner.processing and (tick() - Joiner.lastTime) >= Joiner.cooldown
end
function Joiner.begin(label)
    Joiner.processing = true
    Joiner.lastTime   = tick()
    debugPrint("[Joiner] Begin:", label)
end
function Joiner.finish()
    task.delay(4, function() Joiner.processing = false end)
end

-- ============================================================
-- UTILITY HELPERS
-- ============================================================
local Util = {}

local function debugPrint(...)
    if DEBUG then print("[DEBUG]", ...) end
end

function Util.notify(title, body, dur)
    if State.DisableNotifications then return end
    Rayfield:Notify({ Title = title or "LixHub", Content = body or "", Duration = dur or 4, Image = "info" })
end

function Util.isInLobby()
    return Svc.Workspace:FindFirstChild("RoomCreation") ~= nil
end

function Util.getWave()
    local gs = Svc.Workspace:FindFirstChild("GameSettings")
    return gs and gs.Wave and gs.Wave.Value or 0
end

function Util.getMoney()
    return tonumber(LP.GameData and LP.GameData.Yen and LP.GameData.Yen.Value) or 0
end

-- Returns "UnitDisplayName" from a server folder name like "Senko 3"
function Util.getBaseName(fullName)
    return fullName:match("^(.+)%s+%d+$") or fullName
end

-- Returns "Ai" from "Ai #1"
function Util.getDisplayFromTag(tag)
    return tag:match("^(.+)%s#%d+$") or tag
end

-- Returns 1 from "Ai #1"
function Util.getTagNumber(tag)
    return tonumber(tag:match("#(%d+)$"))
end

-- Robust request function — picks whatever the executor provides
function Util.httpRequest(opts)
    local fn = (syn and syn.request) or (http and http.request) or http_request or request
    if not fn then return nil end
    return fn(opts)
end

function Util.ensureFolders()
    if not isfolder("LixHub")            then makefolder("LixHub")            end
    if not isfolder("LixHub/Macros")     then makefolder("LixHub/Macros")     end
    if not isfolder("LixHub/Macros/AG")  then makefolder("LixHub/Macros/AG")  end
end

-- ============================================================
-- UNIT HELPERS  (all workspace interaction in one place)
-- ============================================================
local Units = {}

function Units.serverFolder()
    local us = Svc.Workspace:FindFirstChild("Ground")
            and Svc.Workspace.Ground:FindFirstChild("unitServer")
    return us and us:FindFirstChild(LP.Name .. " (UNIT)")
end

-- Upgrade level for a server unit name
function Units.getLevel(serverName)
    local folder = Units.serverFolder()
    local unit   = folder and folder:FindFirstChild(serverName)
    local upg    = unit and unit:FindFirstChild("Upgrade")
    return upg and upg.Value or 0
end

-- Max upgrade for a server unit name
function Units.getMaxLevel(serverName)
    local folder = Units.serverFolder()
    local unit   = folder and folder:FindFirstChild(serverName)
    local mx     = unit and unit:FindFirstChild("MaxUpgrade")
    return mx and mx.Value or 0
end

-- UUID from UnitsInventory for a display name
function Units.getUUID(displayName)
    local inv = LP:FindFirstChild("UnitsInventory")
    if not inv then return nil end
    for _, folder in ipairs(inv:GetChildren()) do
        if folder:IsA("Folder") then
            local uv  = folder:FindFirstChild("Unit")
            local ds  = folder:FindFirstChild("data")
            local eq  = ds and ds:FindFirstChild("setting") and ds.setting:FindFirstChild("equip")
            if uv and uv.Value == displayName and eq and eq.Value == "t" then
                return folder.Name
            end
        end
    end
end

--[[
    Find an untracked server unit matching displayName within tolerance of targetPos.
    alreadyMapped: set of server names that are already tracked.
    Returns server unit name or nil.
]]
function Units.findByPosition(displayName, targetPos, alreadyMapped, tolerance)
    tolerance    = tolerance or 6
    alreadyMapped= alreadyMapped or {}
    local folder = Units.serverFolder()
    if not folder then return nil end

    local base   = Util.getBaseName(displayName)
    local best, bestDist = nil, math.huge

    for _, unit in ipairs(folder:GetChildren()) do
        if unit.Name == "PLACEMENTFOLDER"   then continue end
        if alreadyMapped[unit.Name]         then continue end
        if Util.getBaseName(unit.Name) ~= base then continue end

        local origin = unit:GetAttribute("origin")
        if origin then
            local d = (origin.Position - targetPos).Magnitude
            if d < tolerance and d < bestDist then
                best, bestDist = unit.Name, d
            end
        end
    end
    return best
end

-- Sell a server unit
function Units.sell(serverName)
    return pcall(function()
        RS:WaitForChild("PlayMode"):WaitForChild("Events")
          :WaitForChild("ManageUnits"):InvokeServer("Selling", serverName)
    end)
end

-- Upgrade a server unit to targetLevel
function Units.upgrade(serverName, targetLevel)
    return pcall(function()
        RS:WaitForChild("PlayMode"):WaitForChild("Events")
          :WaitForChild("ManageUnits"):InvokeServer("Upgrade", serverName, targetLevel)
    end)
end

-- Place a unit via spawnunit remote
function Units.place(displayName, cframe, rotation, uuid)
    return pcall(function()
        RS:WaitForChild("PlayMode"):WaitForChild("Events")
          :WaitForChild("spawnunit"):InvokeServer({ displayName, cframe, rotation or 0 }, uuid)
    end)
end

-- Fire an ability
function Units.ability(clientName, abilityName)
    return pcall(function()
        local args = { "SkillsButton", clientName }
        if abilityName and abilityName ~= "" then args[3] = abilityName end
        RS:WaitForChild("PlayMode"):WaitForChild("Events")
          :WaitForChild("Skills"):InvokeServer(table.unpack(args))
    end)
end

-- Get the cost per upgrade level from the unit's module
function Units.getUpgradeCost(serverName, fromLevel)
    -- Level 0 → 1: read PriceUpgrade from unitServer runtime value
    local folder = Units.serverFolder()
    local unit   = folder and folder:FindFirstChild(serverName)
    if not unit then return nil end

    if fromLevel == 0 then
        for _, child in ipairs(unit:GetDescendants()) do
            if child.Name == "PriceUpgrade" and child:IsA("NumberValue") then
                return child.Value
            end
        end
        return nil
    end

    -- Level 1+ → read module
    local base    = Util.getBaseName(serverName)
    local modules = RS:FindFirstChild("PlayMode")
                 and RS.PlayMode:FindFirstChild("Modules")
                 and RS.PlayMode.Modules:FindFirstChild("UnitsSettings")
    if not modules then return nil end

    local mod = modules:FindFirstChild(base)
    if not mod then return nil end

    local ok, data = pcall(require, mod)
    if not ok or not data then return nil end

    local settings = type(data.settings) == "function" and data.settings() or nil
    if not settings or not settings.Upgrading then return nil end

    local entry = settings.Upgrading[fromLevel] -- fromLevel 1 = index 1, etc.
    return entry and entry.PriceUpgrade or nil
end

-- ============================================================
-- MACRO MODULE
-- ============================================================
local Macro = {
    -- storage
    library      = {},       -- name → action array
    currentName  = "",

    -- recording state
    isRecording  = false,
    hasStarted   = false,
    actions      = {},       -- live recording buffer
    placementCounter = {},   -- displayName → count
    serverToTag  = {},       -- serverName → "DisplayName #N"

    -- playback state
    isPlaying    = false,
    loopRunning  = false,
    unitMapping  = {},       -- "DisplayName #N" → serverName (playback)
    abilityQueue = {},       -- scheduled abilities/skips

    -- UI labels (set later)
    statusLabel  = nil,
    detailLabel  = nil,
}

function Macro.setStatus(msg)
    if Macro.statusLabel then Macro.statusLabel:Set("Status: " .. msg) end
end

function Macro.setDetail(msg)
    if Macro.detailLabel then Macro.detailLabel:Set("Detail: " .. msg) end
end

function Macro.getFilePath(name)
    return "LixHub/Macros/AG/" .. name .. ".json"
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
    for _, file in ipairs(listfiles("LixHub/Macros/AG/")) do
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
    Macro.unitMapping      = {}
    Macro.placementCounter = {}
    Macro.serverToTag      = {}
    Macro.abilityQueue     = {}
end

-- ─── RECORDING ───────────────────────────────────────────────

function Macro.startRecording()
    if not State.gameInProgress then return end
    Macro.hasStarted         = true
    Macro.actions            = {}
    Macro.clearTracking()
    Macro.setStatus("Recording in progress...")
    debugPrint("[Macro] Recording started")
end

function Macro.stopRecording(autoSave)
    Macro.isRecording = false
    Macro.hasStarted  = false
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

-- Called by the __namecall hook for placement
function Macro.onPlace(displayName, cframe, uuid)
    if not Macro.isRecording or not Macro.hasStarted then return end

    task.spawn(function()
        local t   = tick() - State.gameStartTime
        -- wait briefly for server folder to update
        task.wait(0.5)

        -- Build a set of already-tracked server names
        local tracked = {}
        for sn in pairs(Macro.serverToTag) do tracked[sn] = true end

        local serverName = Units.findByPosition(displayName, cframe.Position, tracked, 7)
        if not serverName then
            warn("[Macro.onPlace] Could not find placed unit:", displayName)
            return
        end

        -- Assign tag
        Macro.placementCounter[displayName] = (Macro.placementCounter[displayName] or 0) + 1
        local tag = displayName .. " #" .. Macro.placementCounter[displayName]
        Macro.serverToTag[serverName] = tag

        -- Get cost
        local cost = nil
        for slot = 1, 6 do
            local pkg = LP.UnitPackage and LP.UnitPackage:FindFirstChild(tostring(slot))
            if pkg and pkg.Unit and pkg.Unit.Value == displayName then
                local frame = LP.PlayerGui.Main.UnitBar.UnitsFrame.UnitsSlot
                             :FindFirstChild("unit" .. slot)
                local yen   = frame and frame:FindFirstChild(displayName, true)
                             and frame[displayName]:FindFirstChild("yen")
                cost = yen and tonumber(yen.Text:match("%d+"))
                break
            end
        end

        table.insert(Macro.actions, {
            Type         = "spawn",
            Unit         = tag,
            Time         = string.format("%.2f", t),
            Position     = { cframe.Position.X, cframe.Position.Y, cframe.Position.Z },
            Rotation     = 0,
            PlacementCost= cost,
        })
        debugPrint("[Macro] Recorded spawn:", tag, "t=" .. t)
    end)
end

function Macro.onUpgradeRemote(serverName)
    if not Macro.isRecording or not Macro.hasStarted then return end
    local tag = Macro.serverToTag[serverName]
    if not tag then 
        debugPrint("[Macro] Upgrade remote fired but unit not tracked:", serverName)
        return 
    end
    
    local t = tick() - State.gameStartTime
    table.insert(Macro.actions, {
        Type = "upgrade",
        Unit = tag,
        Time = string.format("%.2f", t),
    })
    debugPrint("[Macro] Recorded upgrade:", tag, "at", string.format("%.2f", t))
end

function Macro.onSell(serverName)
    if not Macro.isRecording or not Macro.hasStarted then return end
    local tag = Macro.serverToTag[serverName]
    if not tag then return end
    local t = tick() - State.gameStartTime
    table.insert(Macro.actions, {
        Type = "sell",
        Unit = tag,
        Time = string.format("%.2f", t),
    })
    Macro.serverToTag[serverName] = nil
    debugPrint("[Macro] Recorded sell:", tag)
end

function Macro.onAbility(clientName, abilityName)
    if not Macro.isRecording or not Macro.hasStarted then return end
    local base = clientName:match("^(.+)%s+%d+$") or clientName
    local tag  = nil
    for sn, t in pairs(Macro.serverToTag) do
        if Util.getBaseName(sn) == base then tag = t break end
    end
    if not tag then return end
    local t = tick() - State.gameStartTime
    table.insert(Macro.actions, {
        Type        = "ability",
        Unit        = tag,
        Time        = string.format("%.2f", t),
        AbilityName = abilityName or "",
    })
    debugPrint("[Macro] Recorded ability:", tag, abilityName)
end

function Macro.onSkipWave()
    if not Macro.isRecording or not Macro.hasStarted then return end
    local t = tick() - State.gameStartTime
    table.insert(Macro.actions, {
        Type = "skip_wave",
        Time = string.format("%.2f", t),
    })
    debugPrint("[Macro] Recorded skip wave at", t)
end

-- ─── PLAYBACK ────────────────────────────────────────────────

-- Wait for money, returns false if playback stopped
function Macro.waitForMoney(amount, label)
    if not amount or amount <= 0 then return true end
    while Util.getMoney() < amount and Macro.isPlaying and State.gameInProgress do
        Macro.setDetail("Waiting for money: " .. Util.getMoney() .. "/" .. amount .. " (" .. label .. ")")
        task.wait(0.5)
    end
    return Macro.isPlaying and State.gameInProgress
end

-- Execute one placement action
function Macro.execSpawn(action, idx, total)
    local tag         = action.Unit
    local displayName = Util.getDisplayFromTag(tag)
    local uuid        = Units.getUUID(displayName)

    if not uuid then
        warn("[Macro.execSpawn] Unit not equipped:", displayName)
        Macro.setDetail(displayName .. " not equipped!")
        return false
    end

    if not Macro.waitForMoney(action.PlacementCost, displayName) then return false end

    local pos    = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])

    Macro.setDetail("Placing " .. tag .. " (" .. idx .. "/" .. total .. ")")
    local ok = Units.place(displayName, cframe, action.Rotation or 0, uuid)
    if not ok then return false end

    -- Detect spawned unit
    local alreadyMapped = {}
    for _, sn in pairs(Macro.unitMapping) do alreadyMapped[sn] = true end

    local serverName = nil
    for attempt = 1, 12 do
        task.wait(0.4)
        serverName = Units.findByPosition(displayName, cframe.Position, alreadyMapped, 8)
        if serverName then break end
    end

    if serverName then
        Macro.unitMapping[tag] = serverName
        Macro.setDetail("✓ Placed " .. tag)
        debugPrint("[Macro] Placed:", tag, "→", serverName)
        return true
    end

    warn("[Macro.execSpawn] Failed to detect unit after placement:", tag)
    return false
end

-- Execute upgrade
function Macro.execUpgrade(action, idx, total)
    local tag        = action.Unit
    local serverName = Macro.unitMapping[tag]
    if not serverName then
        warn("[Macro.execUpgrade] No mapping for:", tag)
        return false
    end

    local curLevel = Units.getLevel(serverName)
    local maxLevel = Units.getMaxLevel(serverName)
    if curLevel >= maxLevel then
        debugPrint("[Macro] Already max:", tag)
        return true
    end

    local cost = Units.getUpgradeCost(serverName, curLevel)
    if not Macro.waitForMoney(cost, "upgrade " .. tag) then return false end

    Macro.setDetail("Upgrading " .. tag .. " (" .. idx .. "/" .. total .. ")")
    local ok = Units.upgrade(serverName, curLevel + 1)
    task.wait(0.4)
    if ok then
        Macro.setDetail("✓ Upgraded " .. tag)
    end
    return ok
end

-- Execute sell
function Macro.execSell(action, idx, total)
    local serverName = Macro.unitMapping[action.Unit]
    if not serverName then return false end
    Macro.setDetail("Selling " .. action.Unit .. " (" .. idx .. "/" .. total .. ")")
    local ok = Units.sell(serverName)
    if ok then 
        Macro.unitMapping[action.Unit] = nil 
        Macro.setDetail("✓ Sold " .. action.Unit)
    end
    return ok
end

-- Execute ability (shared for both direct and scheduled)
function Macro.execAbility(action)
    local serverName = Macro.unitMapping[action.Unit]
    if not serverName then return false end

    -- Find in unitClient
    local ground     = Svc.Workspace:FindFirstChild("Ground")
    local unitClient = ground and ground:FindFirstChild("unitClient")
    if not unitClient then return false end

    local base = Util.getBaseName(serverName)
    for _, model in ipairs(unitClient:GetChildren()) do
        if model:IsA("Model") then
            local mb = model.Name:match("^(.+)%s+%d+$") or model.Name
            if mb == base then
                return Units.ability(model.Name, action.AbilityName)
            end
        end
    end
    return false
end

-- Skip wave
function Macro.execSkip()
    pcall(function()
        RS:WaitForChild("PlayMode"):WaitForChild("Events")
          :WaitForChild("Vote"):FireServer("Vote2")
    end)
end

-- Schedule an ability/skip for a future game-time
function Macro.scheduleTimedAction(action, targetTime)
    table.insert(Macro.abilityQueue, { action = action, targetTime = targetTime })
end

-- Drain the scheduled queue; run in a task.spawn
function Macro.runScheduledQueue()
    while Macro.isPlaying and State.gameInProgress do
        local now = tick() - State.gameStartTime
        local i = 1
        while i <= #Macro.abilityQueue do
            local item = Macro.abilityQueue[i]
            if now >= item.targetTime then
                if item.action.Type == "skip_wave" then
                    Macro.execSkip()
                else
                    Macro.execAbility(item.action)
                end
                table.remove(Macro.abilityQueue, i)
            else
                i = i + 1
            end
        end
        task.wait(0.1)
    end
end

-- Run one full pass of the macro
function Macro.playOnce()
    if not Macro.currentName or Macro.currentName == "" then
        Macro.setStatus("No macro selected")
        return false
    end

    local actions = Macro.loadFromFile(Macro.currentName)
    if not actions or #actions == 0 then
        Macro.setStatus("Macro is empty or not found")
        return false
    end

    Macro.clearTracking()
    Macro.abilityQueue = {}

    local total = #actions
    Macro.setStatus("Playing: " .. Macro.currentName)
    Macro.setDetail("Loading " .. total .. " actions...")

    -- Start the scheduled-queue drainer
    task.spawn(Macro.runScheduledQueue)

    for i, action in ipairs(actions) do
        if not Macro.isPlaying or not State.gameInProgress then
            Macro.setStatus("Playback stopped")
            return false
        end

        local actionTime = tonumber(action.Time) or 0

        -- Abilities and wave-skips are always scheduled to preserve timing
        if action.Type == "ability" or action.Type == "skip_wave" then
            Macro.scheduleTimedAction(action, actionTime)
            continue
        end

        -- For placements/upgrades/sells: wait for timing unless IgnoreTiming
        if not State.IgnoreTiming then
            local gameTime = tick() - State.gameStartTime
            local remaining = actionTime - gameTime
            if remaining > 0.2 then
                Macro.setDetail("Waiting " .. string.format("%.1fs", remaining) .. " for next action...")
                local waited = 0
                while waited < remaining and Macro.isPlaying and State.gameInProgress do
                    task.wait(0.2)
                    waited = waited + 0.2
                end
            end
        end

        if not Macro.isPlaying or not State.gameInProgress then return false end

        if     action.Type == "spawn"   then Macro.execSpawn  (action, i, total)
        elseif action.Type == "upgrade" then Macro.execUpgrade(action, i, total)
        elseif action.Type == "sell"    then Macro.execSell   (action, i, total)
        end

        task.wait(0.1)
    end

    -- Wait for remaining scheduled actions
    while #Macro.abilityQueue > 0 and Macro.isPlaying and State.gameInProgress do
        task.wait(0.3)
    end

    Macro.setStatus("Playback complete")
    Macro.setDetail("Waiting for next game...")
    return true
end

-- The main auto-loop (one game per iteration)
function Macro.autoLoop()
    if Macro.loopRunning then return end
    Macro.loopRunning = true

    while Macro.isPlaying do
        Macro.setStatus("Waiting for game to start...")
        Macro.setDetail("Standby")

        -- Wait for game to end first if mid-game
        while Util.getWave() > 0 and Macro.isPlaying do task.wait(1) end
        -- Then wait for next game
        while Util.getWave() < 1 and Macro.isPlaying do task.wait(0.5) end

        if not Macro.isPlaying then break end

        Macro.clearTracking()
        Macro.playOnce()

        -- Wait for game to fully end before looping
        while State.gameInProgress and Macro.isPlaying do task.wait(0.5) end
        task.wait(1)
    end

    Macro.loopRunning = false
    Macro.setStatus("Playback stopped")
    Macro.setDetail("Ready")
end

-- Import from JSON string
function Macro.importJSON(jsonStr, name)
    if not jsonStr or jsonStr:match("^%s*$") then return false, "Empty content" end
    if not name or name == "" then return false, "No name given" end
    if Macro.library[name] and #Macro.library[name] > 0 then
        return false, "Macro '" .. name .. "' already exists"
    end

    local ok, decoded = pcall(function() return Svc.HttpService:JSONDecode(jsonStr) end)
    if not ok then return false, "Invalid JSON" end

    local actions = (type(decoded) == "table" and decoded.actions) or
                    (type(decoded) == "table" and #decoded > 0 and decoded) or nil
    if not actions or #actions == 0 then return false, "No actions found" end

    Macro.library[name] = actions
    Macro.saveToFile(name)
    return true, #actions
end

-- Export current macro to clipboard
function Macro.exportClipboard()
    if not Macro.currentName or Macro.currentName == "" then
        Util.notify("Export Error", "No macro selected")
        return
    end
    local data = Macro.library[Macro.currentName]
    if not data or #data == 0 then
        Util.notify("Export Error", "Macro is empty")
        return
    end
    local fn = setclipboard or toclipboard
    if not fn then Util.notify("Clipboard Error", "Not supported by your executor") return end
    fn(Svc.HttpService:JSONEncode(data))
    Util.notify("Exported", Macro.currentName .. " copied to clipboard")
end

-- Export via webhook
function Macro.exportWebhook()
    if not Macro.currentName or Macro.currentName == "" then
        Util.notify("Webhook Error", "No macro selected")
        return
    end
    
    if not State.WebhookURL then
        Util.notify("Webhook Error", "No webhook URL configured")
        return
    end
    
    local data = Macro.library[Macro.currentName]
    if not data or #data == 0 then
        Util.notify("Webhook Error", "Macro is empty")
        return
    end
    
    -- Extract units from macro
    local unitsUsed, seen = {}, {}
    for _, action in ipairs(data) do
        if action.Type == "spawn" and action.Unit then
            local baseName = Util.getDisplayFromTag(action.Unit)
            if not seen[baseName] then
                seen[baseName] = true
                unitsUsed[#unitsUsed+1] = baseName
            end
        end
    end
    table.sort(unitsUsed)
    local unitsText = #unitsUsed > 0 and table.concat(unitsUsed, ", ") or "No units"
    
    -- Create JSON
    local jsonData = Svc.HttpService:JSONEncode(data)
    local fileName = Macro.currentName .. ".json"
    
    -- Multipart form data
    local boundary = "----WebKitFormBoundary" .. tostring(tick())
    local body = ""
    
    -- Payload with units list
    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
    body = body .. "Content-Type: application/json\r\n\r\n"
    body = body .. Svc.HttpService:JSONEncode({
        content = "**Units:** " .. unitsText
    }) .. "\r\n"
    
    -- File
    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. fileName .. "\"\r\n"
    body = body .. "Content-Type: application/json\r\n\r\n"
    body = body .. jsonData .. "\r\n"
    body = body .. "--" .. boundary .. "--\r\n"
    
    local resp = Util.httpRequest({
        Url     = State.WebhookURL,
        Method  = "POST",
        Headers = { 
            ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
            ["User-Agent"] = "LixHub-Webhook/1.0"
        },
        Body    = body,
    })
    
    if resp and resp.StatusCode >= 200 and resp.StatusCode < 300 then
        Util.notify("Webhook Success", "Macro '" .. Macro.currentName .. "' sent!", 3)
    else
        Util.notify("Webhook Error", "Failed to send (HTTP " .. tostring(resp and resp.StatusCode or "?") .. ")", 3)
    end
end

-- ============================================================
-- WEBHOOK MODULE
-- ============================================================
local Webhook = {}
local _capturedRewards = nil

function Webhook.send(msgType, extraData)
    if not State.WebhookURL then return end

    local data
    if msgType == "test" then
        data = {
            username = "LixHub",
            content  = State.DiscordUserID and ("<@" .. State.DiscordUserID .. ">") or "",
            embeds   = {{ title="Webhook Test", description="Test sent!", color=0x5865F2,
                          footer={text="discord.gg/cYKnXE2Nf8"},
                          timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ") }}
        }
    elseif msgType == "stage" then
        local gs       = Svc.Workspace:FindFirstChild("GameSettings")
        local stageName= gs and gs.Stages  and gs.Stages.Value   or "?"
        local act      = gs and gs.Act     and gs.Act.Value      or "?"
        local diff     = gs and gs.Difficulty and gs.Difficulty.Value or "?"
        local base     = gs and gs.Base
        local isWin    = base and base.Health and base.Health.Value > 0 or false
        local result   = isWin and "Victory" or "Defeat"
        local plrLevel = LP.Data and LP.Data.Levels and LP.Data.Levels.Value or "?"

        local clearTime = (State.gameEndRealTime > 0 and State.gameStartRealTime > 0)
                        and (State.gameEndRealTime - State.gameStartRealTime) or 0
        local mins = math.floor(clearTime / 60)
        local secs = math.floor(clearTime % 60)
        local timeStr = string.format("%02d:%02d", mins, secs)

        -- Build rewards text
        local rewardLines = {}
        local unitGained  = {}
        if _capturedRewards then
            for _, r in ipairs(_capturedRewards) do
                local name, amt = r[1], r[2]
                -- Check if it's a unit module
                local mods = RS.PlayMode and RS.PlayMode.Modules
                            and RS.PlayMode.Modules.UnitsSettings
                local isUnit = mods and mods:FindFirstChild(name) ~= nil
                if isUnit then
                    unitGained[#unitGained+1] = name
                    rewardLines[#rewardLines+1] = "🌟 " .. name .. " x" .. amt
                else
                    rewardLines[#rewardLines+1] = "+ " .. amt .. " " .. name
                end
            end
        end
        local rewardsText = #rewardLines > 0 and table.concat(rewardLines, "\n") or "None"
        local ping        = #unitGained > 0 and State.DiscordUserID
                          and ("<@" .. State.DiscordUserID .. "> **UNIT OBTAINED**") or ""

        data = {
            username = "LixHub",
            content  = ping,
            embeds   = {{
                title       = "Stage Finished!",
                description = stageName .. " - Act " .. act .. " - " .. diff .. " - " .. result,
                color       = #unitGained > 0 and 0xFFD700 or (isWin and 0x57F287 or 0xED4245),
                fields      = {
                    { name="Player",  value="||" .. LP.Name .. " [" .. plrLevel .. "]||", inline=true },
                    { name=isWin and "Won in" or "Lost after", value=timeStr, inline=true },
                    { name="Rewards", value=rewardsText, inline=false },
                },
                footer    = { text="discord.gg/cYKnXE2Nf8" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        }
    end

    if not data then return end
    local resp = Util.httpRequest({
        Url     = State.WebhookURL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = Svc.HttpService:JSONEncode(data),
    })
    if resp and (resp.StatusCode == 200 or resp.StatusCode == 204) then
        Util.notify("Webhook", "Sent successfully", 2)
    else
        Util.notify("Webhook Error", "HTTP " .. tostring(resp and resp.StatusCode or "?"), 3)
    end
end

-- ============================================================
-- __NAMECALL HOOK  (single, clean)
-- ============================================================
do
    local mt               = getrawmetatable(game)
    setreadonly(mt, false)
    local _original        = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = { ... }

        -- Block boss damage
        if State.BlockBossDamage
            and method == "InvokeServer"
            and self.Name == "Damages"
            and args[1] == "BossDamage" then
            return nil
        end

        local result = _original(self, ...)

        if not checkcaller() then
            -- PLACEMENT
            if method == "InvokeServer" and self.Name == "spawnunit" then
                -- args[1] = { displayName, cframe, rotation }, args[2] = uuid
                local info = args[1]
                if info and type(info) == "table" then
                    Macro.onPlace(info[1], info[2], args[2])
                end

            -- UPGRADE
            elseif method == "InvokeServer" and self.Name == "ManageUnits" and args[1] == "Upgrade" then
                Macro.onUpgradeRemote(args[2])

            -- SELL
            elseif method == "InvokeServer" and self.Name == "ManageUnits" and args[1] == "Selling" then
                Macro.onSell(args[2])

            -- ABILITY  (only record if server approved, i.e. result is truthy)
            elseif method == "InvokeServer" and self.Name == "Skills" and args[1] == "SkillsButton" then
                if result then
                    Macro.onAbility(args[2], args[3])
                end

            -- WAVE SKIP
            elseif method == "FireServer" and self.Name == "Vote" and args[1] == "Vote2" then
                Macro.onSkipWave()
            end
        end

        return result
    end)

    setreadonly(mt, true)
end

-- ============================================================
-- GAME EVENT TRACKING
-- ============================================================
local function onGameStart()
    State.gameInProgress    = true
    State.gameStartTime     = tick()
    State.gameStartRealTime = tick()
    _capturedRewards        = nil

    if Macro.isRecording and not Macro.hasStarted then
        Macro.startRecording()
    end
    debugPrint("[Game] Started")
end

local function onGameEnd(rewards)
    State.gameInProgress  = false
    State.gameEndRealTime = tick()
    _capturedRewards      = rewards

    -- Stop recording if active
    if Macro.isRecording and Macro.hasStarted then
        Macro.stopRecording(true)
        if RecordToggle then RecordToggle:Set(false) end
    end

    -- Webhook
    if State.SendWebhookOnFinish then
        task.spawn(Webhook.send, "stage")
    end

    debugPrint("[Game] Ended")
end

-- Wave tracking
if not Util.isInLobby() then
    local gs = Svc.Workspace:FindFirstChild("GameSettings")
    if gs and gs:FindFirstChild("Wave") then
        gs.Wave.Changed:Connect(function(w)
            if w >= 1 and not State.gameInProgress then onGameStart()
            elseif w == 0 and State.gameInProgress then
                -- wave going to 0 means game ended
                State.gameInProgress = false
            end
        end)
        -- Check if already in game
        if gs.Wave.Value >= 1 then onGameStart() end
    end

    -- EndGame event
    local endGame = RS:FindFirstChild("EndGame")
    if endGame then
        endGame.OnClientEvent:Connect(function(_, _, rewards)
            onGameEnd(rewards)
        end)
    end
end

-- ============================================================
-- AUTO-VOTE AFTER GAME (clean, validated)
-- ============================================================
local function doAutoVote()
    -- Wait for EndGUI to appear
    local endGui = nil
    for _ = 1, 20 do
        endGui = LP.PlayerGui:FindFirstChild("EndGUI")
        if endGui and endGui.Enabled then break end
        task.wait(0.5)
    end
    if not endGui or not endGui.Enabled then return end

    local function guiClosed()
        return not endGui.Parent or not endGui.Enabled
    end

    local function tryRemote(fn, label)
        for _ = 1, 4 do
            pcall(fn)
            task.wait(1.5)
            if guiClosed() then
                debugPrint("[AutoVote] Success:", label)
                return true
            end
        end
        return false
    end

    if State.AutoVoteNext then
        if tryRemote(function()
            RS.PlayMode.Events.Control:FireServer("Next Stage Vote")
        end, "Next") then return end
    end

    if State.AutoVoteRetry then
        if tryRemote(function()
            local btn = LP.PlayerGui.EndGUI.Main.Stage.Button.Retry.Button
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
        end, "Retry") then return end
    end

    if State.AutoVoteLobby then
        task.wait(1)
        Svc.TeleportService:Teleport(17282336195, LP)
    end
end

-- Hook EndGame for auto-vote
if not Util.isInLobby() then
    local endGame = RS:FindFirstChild("EndGame")
    if endGame then
        endGame.OnClientEvent:Connect(function()
            task.spawn(function()
                task.wait(2)
                doAutoVote()
            end)
        end)
    end
end

-- ============================================================
-- AUTO-JOIN  (clean priority system)
-- ============================================================
local function firePortal(...)
    RS.PlayMode.Events.CreatingPortal:InvokeServer(...)
end

local AutoJoin = {}

AutoJoin.actions = {
    -- Each entry: { check = fn → bool, run = fn }
    {
        check = function() return State.AutoJoinGate end,
        run   = function()
            Joiner.begin("Gate")
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local sp  = Svc.Workspace:FindFirstChild("Gatespawnpoint")
                     and Svc.Workspace.Gatespawnpoint:FindFirstChild("1")
            if hrp and sp then
                hrp.CFrame = sp.CFrame
                task.wait(0.4)
                local pp = RS.CreatingRoom.Server.PortalPart:FindFirstChildOfClass("ProximityPrompt")
                if pp then pp:InputHoldBegin() task.wait(0.1) pp:InputHoldEnd() end
            end
            Joiner.finish()
        end,
    },
    {
        check = function() return State.AutoJoinChallenge end,
        run   = function()
            Joiner.begin("Challenge")
            firePortal("Challenge", {})
            task.wait(1)
            local pp = Svc.Workspace.CreatingRoom:FindFirstChild(LP.Name)
            local part = pp and pp:FindFirstChild("PortalPart")
            if part then
                firePortal("Create", { part:GetAttribute("Stages"), part:GetAttribute("Act"), "Challenge" })
            end
            Joiner.finish()
        end,
    },
    {
        check = function() return State.AutoJoinTower and State.TowerStage ~= nil end,
        run   = function()
            Joiner.begin("Tower")
            local floor = LP.Stages[State.TowerStage].Floor.Value
            firePortal("Tower Adventures", { State.TowerStage, floor, "Tower Adventures" })
            task.wait(1)
            firePortal("Create", { State.TowerStage, floor, "Tower Adventures" })
            Joiner.finish()
        end,
    },
    {
        check = function() return State.AutoJoinEvent and State.EventStage ~= nil end,
        run   = function()
            Joiner.begin("Event")
            RS.Remote.RoomFunction:InvokeServer("host", { friendOnly=false, stage=State.EventStage })
            task.wait(1)
            RS.Remote.RoomFunction:InvokeServer("start")
            Joiner.finish()
        end,
    },
    {
        check = function() return State.AutoJoinWorldlines and State.WorldlinesStage ~= nil end,
        run   = function()
            Joiner.begin("Worldlines")
            RS.Remote.RoomFunction:InvokeServer("host", { friendOnly=false, stage=State.WorldlinesStage })
            task.wait(1)
            RS.Remote.RoomFunction:InvokeServer("start")
            Joiner.finish()
        end,
    },
    {
        check = function() return State.AutoJoinPortal and State.PortalStage ~= nil end,
        run   = function()
            Joiner.begin("Portal")
            firePortal(State.PortalStage .. " (Portal)", {})
            task.wait(1)
            local pp = Svc.Workspace.CreatingRoom:FindFirstChild(LP.Name)
            local part = pp and pp:FindFirstChild("PortalPart")
            if part then
                firePortal("Create", {
                    part:GetAttribute("Stages"),
                    part:GetAttribute("Act"),
                    part:GetAttribute("Difficulty"),
                })
            end
            Joiner.finish()
        end,
    },
    {
        check = function() return State.AutoJoinRaid and State.RaidStage ~= nil end,
        run   = function()
            Joiner.begin("Raid")
            firePortal("Raid", { State.RaidStage, "1", "Raid" })
            task.wait(1)
            firePortal("Create", { State.RaidStage, "1", "Boss Rush" })
            Joiner.finish()
        end,
    },
    {
        check = function()
            return State.AutoJoinStory
               and State.StoryStage ~= nil
               and State.StoryAct ~= nil
               and State.StoryDifficulty ~= nil
        end,
        run = function()
            Joiner.begin("Story")
            firePortal("Story", { State.StoryStage, State.StoryAct, State.StoryDifficulty })
            task.wait(1)
            firePortal("Create", { State.StoryStage, State.StoryAct, State.StoryDifficulty })
            Joiner.finish()
        end,
    },
}

-- Poll loop for AutoJoin (lobby only)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Util.isInLobby() and Joiner.canAct() then
            if State.AutoJoinDelay > 0 then task.wait(State.AutoJoinDelay) end
            for _, entry in ipairs(AutoJoin.actions) do
                if entry.check() then
                    entry.run()
                    break
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO-SKIP WAVES
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoSkipWaves and not Util.isInLobby() then
            local w     = Util.getWave()
            local limit = State.AutoSkipUntilWave
            if limit == 0 or w <= limit then
                local frame = LP.PlayerGui.GUI and LP.PlayerGui.GUI:FindFirstChild("SkipwaveFrame")
                if frame and frame.Visible then
                    pcall(function()
                        RS.PlayMode.Events.Vote:FireServer("Vote2")
                    end)
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO-SELL
-- ============================================================
do
    local lastSellWave     = 0
    local lastFarmSellWave = 0

    local function sellAll()
        local folder = Units.serverFolder()
        if not folder then return end
        for _, unit in ipairs(folder:GetChildren()) do
            if unit.Name ~= "PLACEMENTFOLDER" then
                Units.sell(unit.Name)
                task.wait(0.1)
            end
        end
    end

    local function sellFarm()
        local folder = Units.serverFolder()
        if not folder then return end
        for _, unit in ipairs(folder:GetChildren()) do
            if unit.Name ~= "PLACEMENTFOLDER" then
                local pt = unit:FindFirstChild("PlaceType")
                if pt and pt.Value == "Farm" then
                    Units.sell(unit.Name)
                    task.wait(0.1)
                end
            end
        end
    end

    local gs = Svc.Workspace:FindFirstChild("GameSettings")
    if gs and gs:FindFirstChild("Wave") then
        gs.Wave.Changed:Connect(function(w)
            if State.AutoSellEnabled and w == State.AutoSellWave and w ~= lastSellWave then
                lastSellWave = w
                task.spawn(sellAll)
            end
            if State.AutoSellFarmEnabled and w == State.AutoSellFarmWave and w ~= lastFarmSellWave then
                lastFarmSellWave = w
                task.spawn(sellFarm)
            end
        end)
    end
end

-- ============================================================
-- AUTO-ABILITY
-- ============================================================
task.spawn(function()
    local lastAttempt = {}
    while true do
        task.wait(1)
        if State.AutoUseAbility and not Util.isInLobby() then
            for _, abilityDisplay in ipairs(State.SelectedAbilitiesToUse) do
                local now = tick()
                if (now - (lastAttempt[abilityDisplay] or 0)) < 2 then continue end

                local unit, ability = abilityDisplay:match("^(.+)%s*%-%s*(.+)$")
                if unit then
                    local ab  = (ability == "Ability") and nil or ability
                    local ground = Svc.Workspace:FindFirstChild("Ground")
                    local uc     = ground and ground:FindFirstChild("unitClient")
                    if uc then
                        local base = unit:gsub("^%s+",""):gsub("%s+$","")
                        for _, model in ipairs(uc:GetChildren()) do
                            if model:IsA("Model") then
                                local mb = model.Name:match("^(.+)%s+%d+$") or model.Name
                                if mb == base then
                                    local ok = Units.ability(model.Name, ab)
                                    if ok then
                                        lastAttempt[abilityDisplay] = nil
                                    else
                                        lastAttempt[abilityDisplay] = now
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
                task.wait(0.05)
            end
        end
    end
end)

-- ============================================================
-- AUTO-START GAME
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoStartGame and not Util.isInLobby() then
            pcall(function()
                local vf = LP.PlayerGui.GameEvent.VoteSkip
                if vf.Visible and vf.Button.Inset.textname.Text:lower():find("start") then
                    task.wait(2)
                    for _, c in ipairs(getconnections(vf.Button.Button.MouseButton1Click)) do
                        c:Fire()
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
LP.Idled:Connect(function()
    if State.AntiAfkEnabled then
        Svc.VirtualUser:Button2Down(Vector2.zero, Svc.Workspace.CurrentCamera.CFrame)
        task.wait(1)
        Svc.VirtualUser:Button2Up(Vector2.zero, Svc.Workspace.CurrentCamera.CFrame)
    end
end)

-- ============================================================
-- FPS CAP
-- ============================================================
local function applyFPS()
    if State.LimitFPS then
        setfpscap(State.SelectedFPS)
    else
        setfpscap(0)
    end
end

-- ============================================================
-- SHOP PURCHASERS  (consolidated, not 3 separate functions)
-- ============================================================
local ShopData = {
    OverHeaven = {
        ["Artifacts Trait Reroll"]=750, ["TraitReroll"]=500, ["SuperStatReroll"]=250, ["StatReroll"]=500,
    },
    Behelit = {
        ["Capsule Fortune Potion"]=1000, ["Festival Coin Potion"]=1000,
        ["Blessed Luck Potion"]=1000, ["Event Discount Potion"]=1000,
        ["Guts"]=100, ["Dragonslayer"]=25,
        ["Artifacts Trait Reroll"]=10, ["SuperStatReroll"]=10, ["StatReroll"]=10,
    },
    RagnaShop = {
        ["Artifacts Trait Reroll"]=5, ["Ragna Capsule"]=5, ["Dango"]=1,
        ["Mystic Coins"]=5, ["Fullsteak"]=2, ["Ramen"]=2,
        ["TraitReroll"]=5, ["Night Market Coins"]=50,
    },
}

local ShopCurrencyItem = {
    OverHeaven = "Dio Presents",
    Behelit    = "Beherit",
    RagnaShop  = "Dragonpoints",
}

local function buyFromShop(shopKey, itemName)
    local cost    = ShopData[shopKey] and ShopData[shopKey][itemName]
    local currKey = ShopCurrencyItem[shopKey]
    if not cost or not currKey then return end

    local inv  = LP:FindFirstChild("ItemsInventory")
    local curr = inv and inv:FindFirstChild(currKey)
    local amt  = curr and curr:FindFirstChild("Amount") and curr.Amount.Value or 0

    if amt < cost then return end
    pcall(function()
        RS.PlayMode.Events.EventShop:InvokeServer(math.floor(amt / cost), itemName, shopKey)
    end)
end

task.spawn(function()
    while true do
        task.wait(2)
        if Util.isInLobby() then
            if State.AutoPurchaseDio      and State.AutoPurchaseDioItem      then buyFromShop("OverHeaven", State.AutoPurchaseDioItem)      end
            if State.AutoPurchaseGriffith and State.AutoPurchaseGriffithItem then buyFromShop("Behelit",    State.AutoPurchaseGriffithItem) end
            if State.AutoPurchaseRagna    and State.AutoPurchaseRagnaItem    then buyFromShop("RagnaShop",  State.AutoPurchaseRagnaItem)    end
        end
    end
end)

-- ============================================================
-- LOW PERFORMANCE MODE
-- ============================================================
local function applyLowPerf()
    if State.LowPerfMode then
        Svc.Lighting.Brightness            = 1
        Svc.Lighting.GlobalShadows         = false
        Svc.Lighting.Technology            = Enum.Technology.Compatibility
        Svc.Lighting.EnvironmentDiffuseScale  = 0
        Svc.Lighting.EnvironmentSpecularScale = 0
        for _, v in ipairs(Svc.Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or
               v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
        for _, v in ipairs(Svc.Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or
               v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        pcall(function()
            RS.Remotes.Data.Settings:FireServer("Update", {Value="ON",  Setting="Low Mode"})
            RS.Remotes.Data.Settings:FireServer("Update", {Value="OFF", Setting="Visual Effects"})
            RS.Remotes.Data.Settings:FireServer("Update", {Value="OFF", Setting="Damage Indicator"})
            RS.Remotes.Data.Settings:FireServer("Update", {Value="ON",  Setting="InvisibleEnemy"})
        end)
    end
end

-- ============================================================
-- BLACK SCREEN TOGGLE
-- ============================================================
local function applyBlackScreen()
    local gui = LP.PlayerGui:FindFirstChild("LixHubBlackScreen")
    if State.BlackScreen then
        if gui then return end
        local sg = Instance.new("ScreenGui")
        sg.Name              = "LixHubBlackScreen"
        sg.IgnoreGuiInset    = true
        sg.DisplayOrder      = math.huge
        sg.Parent            = LP.PlayerGui
        local fr = Instance.new("Frame", sg)
        fr.Size              = UDim2.new(1,0,1,36)
        fr.Position          = UDim2.new(0,0,0,-36)
        fr.BackgroundColor3  = Color3.new(0,0,0)
        fr.BorderSizePixel   = 0
    else
        if gui then gui:Destroy() end
    end
end

-- ============================================================
-- UI  TABS
-- ============================================================
local Tabs = {
    Lobby   = Window:CreateTab("Lobby",    "tv"),
    Shop    = Window:CreateTab("Shop",     "shopping-cart"),
    Joiner  = Window:CreateTab("Joiner",   "plug-zap"),
    Game    = Window:CreateTab("Game",     "gamepad-2"),
    Macro   = Window:CreateTab("Macro",    "tv"),
    Auto    = Window:CreateTab("Autoplay",     "gamepad-2"),
    Webhook = Window:CreateTab("Webhook",  "bluetooth"),
}

-- ── Status labels ──────────────────────────────────────────
Macro.statusLabel = Tabs.Macro:CreateLabel("Status: Ready")
Macro.detailLabel = Tabs.Macro:CreateLabel("Detail: -")
Tabs.Macro:CreateDivider()

-- ============================================================
-- LOBBY TAB
-- ============================================================
Tabs.Lobby:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        for _, sv in ipairs(LP.Code:GetChildren()) do
            if sv:IsA("Folder") and sv.Name ~= "Rewards" then
                pcall(function()
                    RS.PlayMode.Events.Codes:InvokeServer(sv.Name)
                end)
                task.wait(0.1)
            end
        end
        Util.notify("Codes", "Redeemed all codes!")
    end,
})

Tabs.Lobby:CreateToggle({
    Name     = "Disable Script Notifications",
    Flag     = "DisableNotifications",
    Callback = function(v)
        State.DisableNotifications = v
    end,
})

Tabs.Lobby:CreateToggle({
    Name     = "Auto Execute Script",
    Flag     = "enableAutoExecute",
    Callback = function(v)
        State.enableAutoExecute = v
        if queue_on_teleport then
            queue_on_teleport(v
                and 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader"))()'
                or "")
        end
    end,
})

Tabs.Lobby:CreateButton({
    Name = "Return to Lobby",
    Callback = function()
        Svc.TeleportService:Teleport(17282336195, LP)
    end,
})

-- ============================================================
-- SHOP TAB
-- ============================================================
Tabs.Shop:CreateSection("Dio Shop (Over Heaven)")

Tabs.Shop:CreateToggle({ 
    Name     = "Auto Purchase", 
    Flag     = "AutoPurchaseDio", 
    Callback = function(v) State.AutoPurchaseDio=v end 
})

Tabs.Shop:CreateDropdown({ 
    Name    = "Select Item", 
    Options = {"Artifacts Trait Reroll","TraitReroll","SuperStatReroll","StatReroll"}, 
    Flag    = "DioItem", 
    Callback= function(o) State.AutoPurchaseDioItem=o[1] end 
})

Tabs.Shop:CreateSection("Griffith Shop (Beherit)")

Tabs.Shop:CreateToggle({ 
    Name     = "Auto Purchase", 
    Flag     = "AutoPurchaseGriffith", 
    Callback = function(v) State.AutoPurchaseGriffith=v end 
})

Tabs.Shop:CreateDropdown({ 
    Name    = "Select Item", 
    Options = {"Capsule Fortune Potion","Festival Coin Potion","Blessed Luck Potion","Event Discount Potion","Guts","Dragonslayer","Artifacts Trait Reroll","SuperStatReroll","StatReroll"}, 
    Flag    = "GriffithItem", 
    Callback= function(o) State.AutoPurchaseGriffithItem=o[1] end 
})

Tabs.Shop:CreateSection("Ragna Shop")

Tabs.Shop:CreateToggle({ 
    Name     = "Auto Purchase", 
    Flag     = "AutoPurchaseRagna", 
    Callback = function(v) State.AutoPurchaseRagna=v end 
})

Tabs.Shop:CreateDropdown({ 
    Name    = "Select Item", 
    Options = {"Artifacts Trait Reroll","Ragna Capsule","Dango","Mystic Coins","Fullsteak","Ramen","TraitReroll","Night Market Coins"}, 
    Flag    = "RagnaItem", 
    Callback= function(o) State.AutoPurchaseRagnaItem=o[1] end 
})

-- ============================================================
-- JOINER TAB
-- ============================================================
Tabs.Joiner:CreateSlider({ Name="Auto Join Delay", Range={0,60}, Increment=1, Suffix=" s", CurrentValue=0, Flag="AutoJoinDelay", Callback=function(v) State.AutoJoinDelay=v end })

Tabs.Joiner:CreateSection("Story")
Tabs.Joiner:CreateToggle({ Name="Auto Join Story", Flag="AutoJoinStory", Callback=function(v) State.AutoJoinStory=v end })
local StoryStageDD = Tabs.Joiner:CreateDropdown({ Name="Story Stage", Options={}, Flag="StoryStage", Callback=function(o) State.StoryStage=o[1] end })
Tabs.Joiner:CreateDropdown({ Name="Story Act", Options={"1","2","3","4","5","6","Infinity"}, Flag="StoryAct", Callback=function(o) State.StoryAct=o[1] end })
Tabs.Joiner:CreateDropdown({ Name="Story Difficulty", Options={"Normal","Nightmare"}, Flag="StoryDifficulty", Callback=function(o) State.StoryDifficulty=o[1] end })

Tabs.Joiner:CreateSection("Raid")
Tabs.Joiner:CreateToggle({ Name="Auto Join Raid", Flag="AutoJoinRaid", Callback=function(v) State.AutoJoinRaid=v end })
local RaidDD = Tabs.Joiner:CreateDropdown({ Name="Raid Stage", Options={}, Flag="RaidStage", Callback=function(o) State.RaidStage=o[1] end })

Tabs.Joiner:CreateSection("Portal")
Tabs.Joiner:CreateToggle({ Name="Auto Join Portal", Flag="AutoJoinPortal", Callback=function(v) State.AutoJoinPortal=v end })
local PortalDD = Tabs.Joiner:CreateDropdown({ Name="Portal Stage", Options={}, Flag="PortalStage", Callback=function(o) State.PortalStage=o[1] end })

Tabs.Joiner:CreateSection("Challenge")
Tabs.Joiner:CreateToggle({ Name="Auto Join Challenge",  Flag="AutoJoinChallenge",  Callback=function(v) State.AutoJoinChallenge=v end })

Tabs.Joiner:CreateSection("Gate")
Tabs.Joiner:CreateToggle({ Name="Auto Join Gate",       Flag="AutoJoinGate",       Callback=function(v) State.AutoJoinGate=v end })

Tabs.Joiner:CreateSection("Events")
Tabs.Joiner:CreateDropdown({ Name="Event Stage", Options={"Johny Joestar (JojoEvent)","Mushroom Rush (Mushroom)","Verdant Shroud (Mushroom2)","Frontline Command Post (Ragna)","Summer Beach (Summer)","Shibuya Event (Shibuya)"}, Flag="EventStage", Callback=function(o) State.EventStage=o[1]:match("%((.-)%)") end })
Tabs.Joiner:CreateToggle({ Name="Auto Join Event",      Flag="AutoJoinEvent",      Callback=function(v) State.AutoJoinEvent=v end })

Tabs.Joiner:CreateSection("Worldlines")
Tabs.Joiner:CreateDropdown({ Name="Worldlines Stage", Options={"Double Dungeon (doubledungeon)","Double Dungeon 2 (doubledungeon2)","Lingxian Academy (lingxianacademy)","Lingxian Yard (lingxianyard)"}, Flag="WorldlinesStage", Callback=function(o) State.WorldlinesStage=o[1]:match("%((.-)%)") end })
Tabs.Joiner:CreateToggle({ Name="Auto Join Worldlines", Flag="AutoJoinWorldlines", Callback=function(v) State.AutoJoinWorldlines=v end })

Tabs.Joiner:CreateSection("Tower")
Tabs.Joiner:CreateDropdown({ Name="Tower Stage", Options={"Cursed Place","The Lost Ancient World"}, Flag="TowerStage", Callback=function(o) State.TowerStage=o[1] end })
Tabs.Joiner:CreateToggle({ Name="Auto Join Tower",      Flag="AutoJoinTower",      Callback=function(v) State.AutoJoinTower=v end })

-- ============================================================
-- GAME TAB
-- ============================================================
Tabs.Game:CreateSection("Player")
Tabs.Game:CreateToggle({ Name="Anti-AFK", Flag="AntiAfk", Callback=function(v) State.AntiAfkEnabled=v end })
Tabs.Game:CreateToggle({ Name="Black Screen", Flag="BlackScreen", Callback=function(v) State.BlackScreen=v applyBlackScreen() end })
Tabs.Game:CreateToggle({ Name="Low Performance Mode", Flag="LowPerf", Callback=function(v) State.LowPerfMode=v applyLowPerf() end })
Tabs.Game:CreateToggle({ Name="Limit FPS", Flag="LimitFPS", Callback=function(v) State.LimitFPS=v applyFPS() end })
Tabs.Game:CreateSlider({ Name="FPS Cap", Range={10,240}, Increment=5, Suffix=" FPS", CurrentValue=60, Flag="SelectedFPS", Callback=function(v) State.SelectedFPS=v applyFPS() end })
Tabs.Game:CreateSlider({ Name="Camera Max Zoom", Range={5,100}, Increment=1, CurrentValue=35, Flag="CamZoom", Callback=function(v) LP.CameraMaxZoomDistance=v end })

Tabs.Game:CreateSection("Game")
Tabs.Game:CreateToggle({ Name="Auto Start Game",  Flag="AutoStartGame",  Callback=function(v) State.AutoStartGame=v  end })
Tabs.Game:CreateToggle({ Name="Auto Vote Retry",  Flag="AutoVoteRetry",  Callback=function(v) State.AutoVoteRetry=v  end })
Tabs.Game:CreateToggle({ Name="Auto Vote Next",   Flag="AutoVoteNext",   Callback=function(v) State.AutoVoteNext=v   end })
Tabs.Game:CreateToggle({ Name="Auto Vote Lobby",  Flag="AutoVoteLobby",  Callback=function(v) State.AutoVoteLobby=v  end })
Tabs.Game:CreateToggle({ Name="Auto Skip Waves",  Flag="AutoSkipWaves",  Callback=function(v) State.AutoSkipWaves=v  end })
Tabs.Game:CreateSlider({ Name="Skip Until Wave",  Range={0,200}, Increment=1, CurrentValue=0, Suffix=" wave", Flag="AutoSkipUntilWave", Callback=function(v) State.AutoSkipUntilWave=v end })
Tabs.Game:CreateToggle({ Name="Delete Enemies",   Flag="DeleteEnemies",  Callback=function(v)
    State.DeleteEnemies = v
    if v then
        local ef = Svc.Workspace.Ground and Svc.Workspace.Ground:FindFirstChild("enemyClient")
        if ef then
            for _, m in ipairs(ef:GetChildren()) do m:Destroy() end
            ef.ChildAdded:Connect(function(c) if State.DeleteEnemies then c:Destroy() end end)
        end
    end
end })
Tabs.Game:CreateToggle({ Name="Block Boss Damage to Units", Flag="BlockBossDamage", Callback=function(v) State.BlockBossDamage=v end })
Tabs.Game:CreateToggle({ Name="Auto Pick Card (Host)", Flag="AutoPickCard", Callback=function(v) State.AutoPickCard=v end })
Tabs.Game:CreateDropdown({ Name="Difficulty Card", Options={"Normal","Fast Wave","Super Faster Wave"}, Flag="AutoPickCardSel", Callback=function(o) State.AutoPickCardSelected=o[1] end })
Tabs.Game:CreateToggle({ Name="Auto Break Zafkiel's Clock", Flag="AutoBreakZafkiel", Callback=function(v) State.AutoBreakZafkiel=v end })
Tabs.Game:CreateToggle({ Name="Auto Collect Chests",        Flag="AutoCollectChests",Callback=function(v) State.AutoCollectChests=v end })
Tabs.Game:CreateToggle({ Name="Auto Collect Dio Presents",  Flag="AutoCollectDio",   Callback=function(v) State.AutoCollectDio=v end })

Tabs.Game:CreateSection("Auto Sell")
Tabs.Game:CreateToggle({ Name="Auto Sell All Units",  Flag="AutoSell",     Callback=function(v) State.AutoSellEnabled=v end })
Tabs.Game:CreateSlider({ Name="Sell on Wave",         Range={1,50}, Increment=1, CurrentValue=10, Flag="AutoSellWave",     Callback=function(v) State.AutoSellWave=v end })
Tabs.Game:CreateToggle({ Name="Auto Sell Farm Units", Flag="AutoSellFarm", Callback=function(v) State.AutoSellFarmEnabled=v end })
Tabs.Game:CreateSlider({ Name="Sell Farm on Wave",    Range={1,50}, Increment=1, CurrentValue=15, Flag="AutoSellFarmWave", Callback=function(v) State.AutoSellFarmWave=v end })

-- ============================================================
-- AUTO TAB  (abilities)
-- ============================================================
Tabs.Auto:CreateSection("Auto Ability")

local AbilityDD
local UnitDD = Tabs.Auto:CreateDropdown({
    Name           = "Select Units",
    Options        = {},
    MultipleOptions= true,
    Flag           = "UnitAbilitySelector",
    Callback       = function(opts)
        State.SelectedUnitsForAbility = opts
        -- Rebuild ability list
        local skillsMod = RS.Module and RS.Module:FindFirstChild("Skills")
        local skillsData = skillsMod and pcall(require, skillsMod) and require(skillsMod) or {}
        local abilities, seen = {}, {}
        for _, unitName in ipairs(opts) do
            local sd = skillsData[unitName]
            if sd then
                for k, v in pairs(sd) do
                    if k:match("^Skill%d+$") then
                        local name = (type(v)=="table" and v.SkillsName) or (type(v)=="string" and v) or k
                        local disp = unitName .. " - " .. name
                        if not seen[disp] then seen[disp]=true abilities[#abilities+1]=disp end
                    end
                end
                if not next(seen) and sd.SkillsName then
                    local disp = unitName .. " - " .. sd.SkillsName
                    if not seen[disp] then seen[disp]=true abilities[#abilities+1]=disp end
                end
            end
        end
        table.sort(abilities)
        if AbilityDD then AbilityDD:Refresh(abilities) end
    end,
})

AbilityDD = Tabs.Auto:CreateDropdown({
    Name           = "Select Abilities",
    Options        = {},
    MultipleOptions= true,
    Flag           = "AbilitySelector",
    Callback       = function(opts)
        State.SelectedAbilitiesToUse = opts
    end,
})

Tabs.Auto:CreateToggle({ Name="Auto Use Ability", Flag="AutoUseAbility", Callback=function(v) State.AutoUseAbility=v end })

-- Populate units dropdown
task.spawn(function()
    task.wait(1)
    local skillsMod  = RS.Module and RS.Module:FindFirstChild("Skills")
    if not skillsMod then return end
    local ok, data = pcall(require, skillsMod)
    if not ok then return end
    local names = {}
    for k in pairs(data) do names[#names+1] = k end
    table.sort(names)
    UnitDD:Refresh(names)
end)

-- ============================================================
-- MACRO TAB
-- ============================================================
local MacroDD = Tabs.Macro:CreateDropdown({
    Name     = "Select Macro",
    Options  = {},
    Flag     = "MacroDropdown",
    Callback = function(o)
        local name = type(o)=="table" and o[1] or o
        Macro.currentName = name or ""
        if name and Macro.library[name] then
            Macro.setStatus("Selected: " .. name .. " (" .. #Macro.library[name] .. " actions)")
        end
    end,
})

local function refreshMacroDD()
    MacroDD:Refresh(Macro.getNames(), Macro.currentName)
end

Tabs.Macro:CreateInput({
    Name                 = "Create New Macro",
    PlaceholderText      = "Enter name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local name = text:gsub("[<>:\"/\\|?*]",""):match("^%s*(.-)%s*$")
        if name == "" then Util.notify("Error","Name cannot be empty") return end
        if Macro.library[name] then Util.notify("Error","Macro already exists") return end
        Macro.library[name] = {}
        Macro.saveToFile(name)
        Macro.currentName = name
        refreshMacroDD()
        Util.notify("Created", name)
    end,
})

Tabs.Macro:CreateButton({ Name="Refresh Macro List", Callback=function() Macro.loadAll() refreshMacroDD() end })

Tabs.Macro:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if Macro.currentName == "" then Util.notify("Error","No macro selected") return end
        if isfile(Macro.getFilePath(Macro.currentName)) then
            delfile(Macro.getFilePath(Macro.currentName))
        end
        Macro.library[Macro.currentName] = nil
        Macro.currentName = ""
        refreshMacroDD()
        Util.notify("Deleted","Macro removed")
    end,
})

Tabs.Macro:CreateDivider()

local RecordToggle = Tabs.Macro:CreateToggle({
    Name = "Record Macro",
    Flag = "RecordMacro",
    Callback = function(v)
        Macro.isRecording = v
        if v then
            if State.gameInProgress then
                Macro.startRecording()
            else
                Macro.setStatus("Recording armed — starts with next game")
                Util.notify("Recording Armed", "Will start recording on next game start")
            end
        else
            Macro.stopRecording(true)
        end
    end,
})

Tabs.Macro:CreateToggle({
    Name = "Playback Macro",
    Flag = "PlayBackMacro",
    Callback = function(v)
        Macro.isPlaying = v
        if v then
            if Macro.currentName == "" then
                Util.notify("Error","No macro selected")
                Macro.isPlaying = false
                return
            end
            Util.notify("Playback Enabled", Macro.currentName)
            task.spawn(Macro.autoLoop)
        else
            Macro.isPlaying = false
            Util.notify("Playback Disabled","Stopped")
        end
    end,
})

Tabs.Macro:CreateToggle({
    Name = "Ignore Timing",
    Info = "Execute placements immediately; abilities/skips still respect timing",
    Flag = "IgnoreTiming",
    Callback = function(v) State.IgnoreTiming = v end,
})

Tabs.Macro:CreateDivider()

Tabs.Macro:CreateButton({ Name="Export to Clipboard", Callback=Macro.exportClipboard })

Tabs.Macro:CreateButton({ Name="Export via Webhook", Callback=Macro.exportWebhook })

Tabs.Macro:CreateInput({
    Name            = "Import (URL or JSON)",
    PlaceholderText = "Paste URL or JSON…",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then return end
        local content = text
        if text:match("^https?://") then
            local ok, resp = pcall(game.HttpGet, game, text, true)
            if not ok then Util.notify("Import Error","Failed to download URL") return end
            content = resp
            -- Derive name from URL
            local fname = text:match("/([^/?]+)%.json") or ("Import_" .. os.time())
            fname = fname:gsub("%.json.*$","")
            local success, n = Macro.importJSON(content, fname)
            if success then refreshMacroDD() Util.notify("Imported", fname .. " (" .. n .. " actions)") end
            return
        end
        local name = "Import_" .. os.time()
        local success, n = Macro.importJSON(content, name)
        if success then refreshMacroDD() Util.notify("Imported", name .. " (" .. n .. " actions)")
        else Util.notify("Import Error", tostring(n)) end
    end,
})

Tabs.Macro:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        local data = Macro.library[Macro.currentName]
        if not data or #data == 0 then Util.notify("Error","No macro or empty") return end
        local seen = {}
        for _, a in ipairs(data) do
            if a.Type == "spawn" then
                local base = Util.getDisplayFromTag(a.Unit)
                seen[base] = (seen[base] or 0) + 1
            end
        end
        local lines = {}
        for k,v in pairs(seen) do lines[#lines+1] = k .. ""..v end
        table.sort(lines)
        Util.notify("Macro Units", table.concat(lines,"\n"), 8)
    end,
})

-- ============================================================
-- WEBHOOK TAB
-- ============================================================
Tabs.Webhook:CreateInput({ Name="Webhook URL",    PlaceholderText="https://discord.com/api/webhooks/…", RemoveTextAfterFocusLost=false, Flag="WebhookURL",  Callback=function(t) State.WebhookURL=t:match("^%s*(.-)%s*$"):match("^https://") and t or nil end })
Tabs.Webhook:CreateInput({ Name="Discord User ID",PlaceholderText="Your Discord ID",                     RemoveTextAfterFocusLost=false, Flag="DiscordUID",  Callback=function(t) State.DiscordUserID=t:match("^%s*(.-)%s*$") end })
Tabs.Webhook:CreateToggle({ Name="Send on Stage Finish", Flag="SendWebhook", Callback=function(v) State.SendWebhookOnFinish=v end })
Tabs.Webhook:CreateButton({ Name="Test Webhook", Callback=function()
    if State.WebhookURL then Webhook.send("test")
    else Util.notify("Error","No webhook URL set") end
end })

-- ============================================================
-- STAGE DROPDOWNS  (story, raid, portal)
-- ============================================================
task.spawn(function()
    -- Wait for player data
    task.wait(1)

    -- Story
    local stageRewards = RS:FindFirstChild("Module") and RS.Module:FindFirstChild("StageRewards")
    local rewardsData  = stageRewards and pcall(require, stageRewards) and require(stageRewards) or {}

    local raidStages, storyStages = {}, {}

    if rewardsData.Raid then
        for name, data in pairs(rewardsData.Raid) do
            if type(data) == "table" and (data.Rewards or data.ChanceRewards) then
                raidStages[#raidStages+1] = name
            end
        end
        table.sort(raidStages)
        RaidDD:Refresh(raidStages)
    end

    -- Story = stages in LP.Stages that are NOT in rewardsData (non-raid/portal)
    if LP:FindFirstChild("Stages") then
        local excluded = {["Easter Event"] = true,["Moonbase Sci-Fi"] = true,["Nazarick Mausoleum"] = true,["Hell Devil"] = true,["Lingxian Academy"] = true,["Lingxian Yard"] = true,["The Lost Halloween"] = true}
        for cat, catData in pairs(rewardsData) do
            if cat ~= "Story" and cat ~= "Infinity" and type(catData) == "table" then
                for name in pairs(catData) do excluded[name] = true end
            end
        end
        for _, stage in ipairs(LP.Stages:GetChildren()) do
            if not excluded[stage.Name] then
                storyStages[#storyStages+1] = stage.Name
            end
        end
        table.sort(storyStages)
        StoryStageDD:Refresh(storyStages)
    end

    -- Portal = items in LP.ItemsInventory ending with "(Portal)"
    if LP:FindFirstChild("ItemsInventory") then
        local portals = {}
        for _, item in ipairs(LP.ItemsInventory:GetChildren()) do
            local name = item.Name:match("^(.+)%s+%(Portal%)$")
            if name then portals[#portals+1] = name end
        end
        table.sort(portals)
        PortalDD:Refresh(portals)
    end
end)

-- ============================================================
-- CARD PICK MONITOR
-- ============================================================
task.spawn(function()
    task.wait(1)
    if Util.isInLobby() then return end
    local gui = LP.PlayerGui:WaitForChild("StagesChallenge", 10)
    if not gui then return end
    local function tryPick()
        if State.AutoPickCard and State.AutoPickCardSelected then
            task.wait(0.1)
            pcall(function()
                RS.PlayMode.Events.StageChallenge:FireServer(State.AutoPickCardSelected)
            end)
        end
    end
    if gui.Enabled then tryPick() end
    gui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if gui.Enabled then tryPick() end
    end)
end)

-- Zafkiel + Dio Presents + Chests remain as simple polling loops
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoBreakZafkiel and not Util.isInLobby() then
            pcall(function()
                local gs = Svc.Workspace:FindFirstChild("GameStates")
                local main = Svc.Workspace:FindFirstChild("Main")
                if not gs or not main then return end
                for boolName, clockName in pairs({
                    FirstClockActive="FirstClock",
                    SecondClockActive="SecondClock",
                    ThirdClockActive="ThirdClock",
                }) do
                    local bv = gs:FindFirstChild(boolName, true)
                    if bv and bv.Value then
                        local clk = main:FindFirstChild(clockName, true)
                        if clk then
                            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            local bp  = clk:FindFirstChildWhichIsA("BasePart")
                            if hrp and bp then
                                hrp.CFrame = bp.CFrame + Vector3.new(0,5,0)
                                task.wait(1)
                                local pp = clk:FindFirstChildOfClass("ProximityPrompt", true)
                                if pp then fireproximityprompt(pp) task.wait(1) end
                            end
                        end
                    end
                end
            end)
        end

        if State.AutoCollectDio and not Util.isInLobby() then
            pcall(function()
                local dp = Svc.Workspace:FindFirstChild("DioPresents")
                if not dp then return end
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, present in ipairs(dp:GetChildren()) do
                    local av = present:FindFirstChild("Active")
                    if av and av.Value then
                        local pp = present:FindFirstChildOfClass("ProximityPrompt", true)
                        if pp then
                            local orig = hrp.CFrame
                            hrp.CFrame = present:IsA("BasePart") and present.CFrame or hrp.CFrame
                            task.wait(1)
                            fireproximityprompt(pp)
                            task.wait(0.2)
                            hrp.CFrame = orig
                        end
                    end
                end
            end)
        end

        if State.AutoCollectChests and not Util.isInLobby() then
            pcall(function()
                local cf = Svc.Workspace:FindFirstChild("ChestSpawned")
                if not cf then return end
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, chest in ipairs(cf:GetChildren()) do
                    local pp = chest:FindFirstChildOfClass("ProximityPrompt", true)
                    if pp then
                        local orig = hrp.CFrame
                        hrp.CFrame = chest:IsA("BasePart") and chest.CFrame + Vector3.new(0,5,0) or hrp.CFrame
                        task.wait(1)
                        fireproximityprompt(pp)
                        task.wait(0.3)
                        hrp.CFrame = orig
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
Util.ensureFolders()
Macro.loadAll()
refreshMacroDD()
Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

-- Restore ability dropdowns after config load
task.spawn(function()
    task.wait(1.5)
    local savedUnits = Rayfield.Flags["UnitAbilitySelector"]
    if savedUnits and #savedUnits > 0 then
        State.SelectedUnitsForAbility = savedUnits
        -- Trigger unit dropdown callback to rebuild abilities
        UnitDD.Callback(savedUnits)
        task.wait(0.3)
        local savedAbilities = Rayfield.Flags["AbilitySelector"]
        if savedAbilities then State.SelectedAbilitiesToUse = savedAbilities end
    end

    -- Restore playback state
    local savedMacro = Rayfield.Flags["MacroDropdown"]
    if type(savedMacro) == "table" then savedMacro = savedMacro[1] end
    if savedMacro and savedMacro ~= "" then
        Macro.currentName = savedMacro
        Macro.loadFromFile(savedMacro)
    end
    refreshMacroDD()

    if Rayfield.Flags["PlayBackMacro"] == true
       and Macro.currentName ~= ""
       and not Macro.loopRunning then
        Macro.isPlaying = true
        task.spawn(Macro.autoLoop)
        Macro.setStatus("Playback restored: " .. Macro.currentName)
    end
end)

-- Check if we joined mid-game
if not Util.isInLobby() then
    local gs = Svc.Workspace:FindFirstChild("GameSettings")
    if gs and gs.Wave and gs.Wave.Value >= 1 then
        onGameStart()
    end
end

Rayfield:TopNotify({
    Title    = "UI Hidden",
    Content  = "Press K to toggle the UI",
    Image    = "eye-off",
    IconColor= Color3.fromRGB(100,150,255),
    Duration = 5,
})
