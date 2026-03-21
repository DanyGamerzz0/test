-- ============================================================
-- ANIME TACTICAL SIMULATOR
-- Script Hub Template | Frontend v0.2
-- ============================================================

local script_version = "V0.51"
local DEBUG = true
local NOTIFICATION_ENABLED = true

-- ============================================================
-- EXECUTOR CHECK
-- ============================================================
if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure) then
    game:GetService("Players").LocalPlayer:Kick("Unsupported executor! Please use a supported executor.")
    return
end

-- ============================================================
-- SERVICES
-- ============================================================
local Services = {
    Players           = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace         = game:GetService("Workspace"),
    RunService        = game:GetService("RunService"),
    HttpService       = game:GetService("HttpService"),
    TweenService      = game:GetService("TweenService"),
}

local LocalPlayer = Services.Players.LocalPlayer

-- ============================================================
-- STATE
-- ============================================================
local State = {
    AutoFarmNearest    = false,
    AutoFarmSelected   = false,
    SelectedMobs       = {},
    SelectedWorld      = "",
    AutoQuestEnabled   = false,
    AutoClaimEnabled   = false,

    -- Auto Summon
    AutoSummonEnabled  = false,
    SummonWorld        = "",
    SummonType         = "Single",
    BlockSummonAnim    = false,

    -- Auto Raid
    AutoRaidEnabled        = false,
    AutoReplayRaid         = false,
    AutoLeaveRaid          = false,
    AutoOpenKeyChests      = false,   -- also open purple (key) chest
    RaidWorld              = "Namex Planet",
    RaidDifficulty         = "Easy",
    RaidStartDelay         = 0,       -- seconds to wait before firing RaidsEvent
    RaidWaitPlayers        = 0,       -- min extra players before starting (0 = start immediately)
    -- Join Player Raid
    JoinPlayerRaidEnabled  = false,
    JoinPlayerRaidTarget   = "",      -- player name to join

    -- Webhook
    WebhookEnabled          = false,
    WebhookURL              = "",
    DiscordID               = "",
    WebhookPingUser         = false,
    WebhookUnitObtained     = false,
    WebhookAvatarObtained   = false,
    WebhookUnitRarities     = {},
}

-- ============================================================
-- TWEEN LOCK  (prevents AutoFarm tween and AutoRaid tween fighting)
-- ============================================================
-- Any system that wants to tween the player must:
--   1. Check  TweenLock.holder == nil  OR  TweenLock.holder == "self"
--   2. Set    TweenLock.holder = "raid" / "farm"
--   3. Do the tween / anchored work
--   4. Clear  TweenLock.holder = nil
--
-- AutoFarm.farmTarget() already handles its own anchoring loop —
-- AutoRaid will simply skip its tween if AutoFarm currently owns the lock,
-- then retry after a short wait.
local TweenLock = {
    holder = nil,  -- nil | "farm" | "raid"
}

-- ============================================================
-- PLAYER STATE  (gamemode presence detection)
-- ============================================================
-- The game attaches boolean values to LocalPlayer while inside a stage.
-- They are removed (not just set false) when the player leaves.
-- We only check existence — the actual value doesn't matter.
local PlayerState = {}

function PlayerState.inRaid()
    return LocalPlayer:FindFirstChild("OnRaids") ~= nil
end

function PlayerState.inRift()
    return LocalPlayer:FindFirstChild("OnRifts") ~= nil
end

function PlayerState.inTower()
    return LocalPlayer:FindFirstChild("OnTowers") ~= nil
end

function PlayerState.inBossGate()
    return LocalPlayer:FindFirstChild("OnBossFight") ~= nil
end

-- True if the player is inside any active gamemode stage.
function PlayerState.inAnyStage()
    return PlayerState.inRaid()
        or PlayerState.inRift()
        or PlayerState.inTower()
        or PlayerState.inBossGate()
end
local Util = {}

function Util.notify(title, content, duration)
    if not NOTIFICATION_ENABLED then return end
    if _G.Rayfield then
        _G.Rayfield:Notify({
            Title    = title or "Notice",
            Content  = content or "",
            Duration = duration or 5,
            Image    = "info",
        })
    end
end

function Util.debugPrint(msg, ...)
    if DEBUG then print("[DEBUG]", msg, ...) end
end

-- ============================================================
-- WORLD / MOB LOADER
-- ============================================================
local Loader = {}

local EXCLUDED_WORLDS = {
    ["Holders"] = true,
}

local nameTranslationCache = nil

function Loader.buildNameTranslation()
    if nameTranslationCache then return nameTranslationCache end
    nameTranslationCache = {}
    pcall(function()
        local unitsFolder = Services.ReplicatedStorage.Shared.Infomations.Units
        for _, worldFolder in ipairs(unitsFolder:GetChildren()) do
            if not worldFolder:IsA("Folder") then continue end
            for _, moduleScript in ipairs(worldFolder:GetChildren()) do
                if not moduleScript:IsA("ModuleScript") then continue end
                local ok, unitData = pcall(require, moduleScript)
                if ok and type(unitData) == "table" then
                    for internalName, data in pairs(unitData) do
                        if type(data) == "table" and data.Real_Names then
                            nameTranslationCache[internalName] = data.Real_Names
                        end
                    end
                end
            end
        end
    end)
    return nameTranslationCache
end

function Loader.translateName(internalName)
    local cache = Loader.buildNameTranslation()
    return cache[internalName] or internalName
end

function Loader.getWorlds()
    local worlds = {}
    local ok, err = pcall(function()
        local enemiesFolder = Services.ReplicatedStorage.Shared.Infomations.Enemies
        for _, child in ipairs(enemiesFolder:GetChildren()) do
            if child:IsA("Folder") and not EXCLUDED_WORLDS[child.Name] then
                table.insert(worlds, child.Name)
            end
        end
    end)
    if not ok then warn("[Loader] Failed to load worlds:", err) end
    table.sort(worlds)
    return worlds
end

function Loader.getMobsForWorld(worldName)
    local mobs = {}
    if not worldName or worldName == "" then return mobs end
    local ok, err = pcall(function()
        local targetsModule = Services.ReplicatedStorage.Shared.Infomations.Enemies[worldName]:FindFirstChild("Targets")
        if not targetsModule or not targetsModule:IsA("ModuleScript") then
            warn("[Loader] No Targets ModuleScript found in world:", worldName)
            return
        end
        local data = require(targetsModule)
        if type(data) ~= "table" then return end
        for _, mobData in pairs(data) do
            if type(mobData) == "table" then
                local displayName = mobData.DisplayName
                if type(displayName) == "table" then
                    local name = displayName[1] or displayName.Name or next(displayName)
                    if type(name) == "string" and name ~= "" then
                        table.insert(mobs, name)
                    end
                elseif type(displayName) == "string" and displayName ~= "" then
                    table.insert(mobs, displayName)
                end
            end
        end
    end)
    if not ok then warn("[Loader] Failed to load mobs for world '" .. worldName .. "':", err) end
    table.sort(mobs)
    return mobs
end

-- ============================================================
-- AUTO FARM MODULE
-- ============================================================
local AutoFarm = {}

AutoFarm.isRunning = false

local TARGETS_FOLDER = function()
    return workspace:FindFirstChild("Worlds")
        and workspace.Worlds:FindFirstChild("Targets")
        and workspace.Worlds.Targets:FindFirstChild("Server")
end

-- Maximum distance the player will travel to reach a mob.
-- Prevents AutoFarm from chasing mobs that spawned outside the raid/rift zone.
local MAX_MOB_DISTANCE = 1000

local FARM_REQUEST_REMOTE = function()
    return Services.ReplicatedStorage.Remotes.Gameplays:FindFirstChild("Request")
end

local function getMobInternalName(model)
    return model.Name
end

local function getMobName(model)
    local ok, result = pcall(function()
        return model.Units_Displays.Names.Text
    end)
    if not ok or not result then return nil end
    if result == "Training Dummy" then return nil end
    return result
end

local function getMobPosition(model)
    if model.PrimaryPart then
        return model.PrimaryPart.Position
    end
    local part = model:FindFirstChildWhichIsA("BasePart")
    return part and part.Position or nil
end

function AutoFarm.findTarget()
    local folder = TARGETS_FOLDER()
    if not folder then return nil end

    local root = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local liveMobs = {}
    for _, model in ipairs(folder:GetChildren()) do
        if not model:IsA("Model") then continue end
        local mobName = getMobName(model)
        if not mobName then continue end
        -- Skip mobs whose humanoid is already at 0 health — they're dead
        -- but the model hasn't been removed from the folder yet
        local h = model:FindFirstChildOfClass("Humanoid")
        if h and h.Health <= 0 then continue end
        if not liveMobs[mobName] then liveMobs[mobName] = {} end
        table.insert(liveMobs[mobName], model)
    end

    local questMobs = (State.AutoQuestEnabled and _G.Quest and #_G.Quest.activeMobs > 0)
        and _G.Quest.activeMobs
        or nil

    local priorityList = questMobs
        or (State.AutoFarmSelected and State.SelectedMobs or nil)

    if priorityList and #priorityList > 0 then
        for _, selectedName in ipairs(priorityList) do
            local candidates = liveMobs[selectedName]
            if candidates and #candidates > 0 then
                local best, bestDist = nil, math.huge
                for _, model in ipairs(candidates) do
                    local pos = getMobPosition(model)
                    if pos then
                        local dist = (root.Position - pos).Magnitude
                        if dist < bestDist and dist <= MAX_MOB_DISTANCE then
                            bestDist = dist
                            best     = model
                        end
                    end
                end
                if best then return best end
            end
        end
        return nil
    else
        if State.AutoFarmNearest then
            local best, bestDist = nil, math.huge
            for _, models in pairs(liveMobs) do
                for _, model in ipairs(models) do
                    local pos = getMobPosition(model)
                    if pos then
                        local dist = (root.Position - pos).Magnitude
                        if dist < bestDist and dist <= MAX_MOB_DISTANCE then
                            bestDist = dist
                            best     = model
                        end
                    end
                end
            end
            return best
        else
            return nil
        end
    end
end

function AutoFarm.farmTarget(model)
    local t0 = tick()
    local internalName = getMobInternalName(model)
    Util.debugPrint("[FARM] farmTarget START", internalName, "t=0")

    -- Fire Request ONCE so units attack. Never fire again — second fire = retreat.
    local requestRemote = FARM_REQUEST_REMOTE()
    if requestRemote then
        pcall(function() requestRemote:FireServer(internalName, "Mouse") end)
        Util.debugPrint("[FARM] Request fired | dt=", tick()-t0)
    end

    local dead = false

    local conn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Util.debugPrint("[FARM] AncestryChanged fired (model removed) | dt=", tick()-t0)
            dead = true
        end
    end)

    -- Also watch humanoid health so we exit as soon as it hits 0,
    -- without waiting for the model to be fully removed (1-2s later).
    local mobHumanoid = model:FindFirstChildOfClass("Humanoid")
    Util.debugPrint("[FARM] Humanoid found:", mobHumanoid ~= nil)
    local healthConn
    if mobHumanoid then
        healthConn = mobHumanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if mobHumanoid.Health <= 0 then
                Util.debugPrint("[FARM] Health signal fired (health<=0) | dt=", tick()-t0)
                dead = true
            end
        end)
    end

    local root = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        pcall(function() conn:Disconnect() end)
        pcall(function() if healthConn then healthConn:Disconnect() end end)
        return
    end

    local pos = getMobPosition(model)
    if not pos then
        pcall(function() conn:Disconnect() end)
        pcall(function() if healthConn then healthConn:Disconnect() end end)
        return
    end

    -- Acquire tween lock for farm
    TweenLock.holder = "farm"

    local targetCFrame = CFrame.new(pos + Vector3.new(0, 0, 3))
    local dist = (root.Position - pos).Magnitude
    local duration = math.max(0.5, dist / 150)
    Util.debugPrint("[FARM] Tween start | dist=", dist, "duration=", duration, "| dt=", tick()-t0)
    local tween = Services.TweenService:Create(
        root,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { CFrame = targetCFrame }
    )
    tween:Play()
    tween.Completed:Wait()
    Util.debugPrint("[FARM] Tween done | dt=", tick()-t0)

    -- Wait for death. We poll humanoid health directly every frame as a
    -- reliable fallback since GetPropertyChangedSignal can be unreliable
    -- on replicated NPC humanoids in executors. task.wait() = next frame.
    Util.debugPrint("[FARM] Entering death wait | dead=", dead, "modelParent=", model.Parent ~= nil)
    local loopFrames = 0
    while not dead and model.Parent and AutoFarm.isRunning do
        if TweenLock.holder == "raid" then
            Util.debugPrint("[FARM] Broke out — raid lock | dt=", tick()-t0)
            break
        end

        -- Direct health poll — catches death even if the signal didn't fire
        if mobHumanoid and mobHumanoid.Parent and mobHumanoid.Health <= 0 then
            Util.debugPrint("[FARM] Health poll caught death | dt=", tick()-t0)
            dead = true
            break
        end

        loopFrames += 1
        task.wait()  -- yield one frame, not 0.2s
    end
    Util.debugPrint("[FARM] Death wait exited | frames=", loopFrames, "dead=", dead, "dt=", tick()-t0)

    TweenLock.holder = nil
    pcall(function() conn:Disconnect() end)
    pcall(function() if healthConn then healthConn:Disconnect() end end)
    Util.debugPrint("[FARM] farmTarget END | total dt=", tick()-t0)
end

function AutoFarm.start()
    if AutoFarm.isRunning then return end
    AutoFarm.isRunning = true
    Util.notify("Auto Farm", "Auto Farm started!")

    task.spawn(function()
        local lastTarget = nil
        local nextTarget = nil  -- pre-scanned while fighting current mob

        while AutoFarm.isRunning do
            local humanoid = LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                task.wait(1)
                continue
            end

            if TweenLock.holder == "raid" then
                task.wait(0.5)
                continue
            end

            -- Use pre-scanned target if we have one, otherwise scan now
            local target = nextTarget or AutoFarm.findTarget()
            nextTarget = nil

            if target == lastTarget then
                task.wait()
                continue
            end

            if target then
                lastTarget = target
                Util.debugPrint("[FARM] start() calling farmTarget | t=0")
                local tStart = tick()

                -- While farmTarget is running, pre-scan the next target
                -- in a background thread so it's ready the instant this mob dies
                task.spawn(function()
                    while AutoFarm.isRunning and lastTarget == target do
                        local candidate = AutoFarm.findTarget()
                        if candidate and candidate ~= target then
                            nextTarget = candidate
                        end
                        task.wait(0.1)
                    end
                end)

                AutoFarm.farmTarget(target)
                Util.debugPrint("[FARM] start() farmTarget returned | dt=", tick()-tStart)
                lastTarget = nil
                Util.debugPrint("[FARM] start() picking next target...")
            else
                nextTarget = nil
                lastTarget = nil
                task.wait(0.5)
            end
        end
    end)
end

function AutoFarm.stop()
    AutoFarm.isRunning = false
    pcall(function()
        local root = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
    end)
    Util.notify("Auto Farm", "Auto Farm stopped.")
end

-- ============================================================
-- AUTO RAID MODULE
-- ============================================================
local AutoRaid = {}

AutoRaid.isRunning = false
AutoRaid._thread   = nil

-- ── Remotes ──────────────────────────────────────────────────
local function getRaidLobbiesRemote()
    return Services.ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("Gameplays")
        :WaitForChild("RaidsLobbies")
end

local function getRaidStartRemote()
    return Services.ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("Systems")
        :WaitForChild("RaidsEvent")
end

local function getRaidActionRemote()
    return Services.ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("Gameplays")
        :WaitForChild("RaidAction")
end

-- ── Shared.Parties folder ────────────────────────────────────
local function getPartiesFolder()
    return Services.ReplicatedStorage
        :WaitForChild("Shared")
        :WaitForChild("Parties")
end

-- Our own party folder (named after LocalPlayer)
local function getMyPartyFolder()
    local ok, f = pcall(function()
        return getPartiesFolder():WaitForChild(LocalPlayer.Name, 5)
    end)
    return ok and f or nil
end

-- ── workspace.Raids_Entering helpers ─────────────────────────

-- Returns a free pod (one whose Holders value is empty/"") from Raids_Entering,
-- or nil if all are occupied.
local function getFreePod()
    local entering = workspace:FindFirstChild("Raids_Entering")
    if not entering then return nil end
    for _, pod in ipairs(entering:GetChildren()) do
        if pod.Name == "Specify" then continue end
        local holders = pod:FindFirstChild("Holders")
        if holders and (holders.Value == "" or holders.Value == nil) then
            return pod
        end
    end
    return nil
end

-- Returns the pod whose Holders value matches playerName, or nil.
local function findPodByPlayer(playerName)
    local entering = workspace:FindFirstChild("Raids_Entering")
    if not entering then return nil end
    for _, pod in ipairs(entering:GetChildren()) do
        local holders = pod:FindFirstChild("Holders")
        if holders and holders.Value == playerName then
            return pod
        end
    end
    return nil
end

-- Teleports HumanoidRootPart instantly to a pod's PrimaryPart (no tween — pre-lobby).
local function teleportToPod(pod)
    local root = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not pod.PrimaryPart then return false end
    root.CFrame = pod.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
    return true
end

-- ── Raid visual folder ────────────────────────────────────────
local function getRaidFolder()
    local visual = workspace:FindFirstChild("Raids_Visual")
    if not visual then return nil end
    for _, child in ipairs(visual:GetChildren()) do
        if child.Name:find(State.RaidWorld, 1, true) then
            return child
        end
    end
    return visual:GetChildren()[1]
end

-- ── Portal / chest helpers ────────────────────────────────────
local function getPortalPrompt(raidFolder)
    local ok, p = pcall(function()
        return raidFolder.Configs.Others.Portal.Travel.Attachment.ProximityPrompt
    end)
    return ok and p or nil
end

local function getChestPrompt(raidFolder, chestType)
    local ok, p = pcall(function()
        return raidFolder.Configs.Others.Rewards[chestType].Primary.ProximityPrompt
    end)
    return ok and p or nil
end

local function getChestPrimary(raidFolder, chestType)
    local ok, p = pcall(function()
        return raidFolder.Configs.Others.Rewards[chestType].Primary
    end)
    return ok and p or nil
end

-- ── Tween helper ─────────────────────────────────────────────
local function tweenToPosition(targetPos, speed)
    speed = speed or 100
    local waited = 0
    while TweenLock.holder == "farm" do
        task.wait(0.3)
        waited += 0.3
        if waited >= 10 then
            Util.debugPrint("[AutoRaid] TweenLock wait timeout — skipping")
            return false
        end
    end
    local root = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    TweenLock.holder = "raid"
    root.Anchored = false
    local dist     = (root.Position - targetPos).Magnitude
    local duration = math.max(0.3, dist / speed)
    local tween    = Services.TweenService:Create(
        root,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(targetPos) }
    )
    tween:Play()
    tween.Completed:Wait()
    TweenLock.holder = nil
    return true
end

-- ── Proximity prompt helper ───────────────────────────────────
local function fireProximityPrompt(prompt)
    pcall(function() fireproximityprompt(prompt) end)
end

-- ── Chest opener ─────────────────────────────────────────────
local function waitForChestReady(raidFolder, chestType, waitTimeout)
    waitTimeout = waitTimeout or 10
    local elapsed = 0
    while elapsed < waitTimeout do
        local prompt = getChestPrompt(raidFolder, chestType)
        if prompt and prompt.Enabled then return true end
        task.wait(0.3)
        elapsed += 0.3
    end
    Util.debugPrint("[AutoRaid] Chest never became ready:", chestType)
    return false
end

local function openChest(raidFolder, chestType, timeout)
    timeout = timeout or 8
    local prompt  = getChestPrompt(raidFolder, chestType)
    local primary = getChestPrimary(raidFolder, chestType)
    if not prompt or not primary then
        Util.debugPrint("[AutoRaid] Chest not found:", chestType)
        return false
    end
    if not prompt.Enabled then
        Util.debugPrint("[AutoRaid] Chest prompt disabled, skipping:", chestType)
        return false
    end
    local chestPos = primary:IsA("BasePart")
        and primary.Position
        or (primary.PrimaryPart and primary.PrimaryPart.Position)
    if not chestPos then return false end
    if not tweenToPosition(chestPos + Vector3.new(0, 0, 3)) then return false end
    local elapsed = 0
    while prompt.Enabled and elapsed < timeout do
        fireProximityPrompt(prompt)
        task.wait(0.3)
        elapsed += 0.3
    end
    local opened = not prompt.Enabled
    Util.debugPrint("[AutoRaid] Chest", chestType, opened and "opened" or "timed out")
    return opened
end

-- ── Lobby setup (teleport → select world → select difficulty) ─
-- Returns true when lobby is ready, false if it failed.
-- On lobby expiry (pod vanishes before we start), caller should retry.
local function setupLobby()
    -- Pause AutoFarm so it doesn't fight the teleport
    local farmWasRunning = AutoFarm.isRunning
    if farmWasRunning then
        AutoFarm.isRunning = false
        -- Unanchor immediately so the teleport isn't blocked
        pcall(function()
            local root = LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.Anchored = false end
        end)
        if TweenLock.holder == "farm" then TweenLock.holder = nil end
    end

    -- Wait for any leftover Raids GUI from a previous run to clear
    -- (avoids setupLobby thinking we're already in the lobby)
    local clearWait = 0
    while LocalPlayer.PlayerGui:FindFirstChild("Raids") and clearWait < 5 do
        task.wait(0.5)
        clearWait += 0.5
    end

    -- Step 1: wait for a free pod then teleport to it
    -- After leaving a raid the server may take a moment to clear Holders
    local pod = nil
    local podWait = 0
    repeat
        task.wait(0.5)
        podWait += 0.5
        pod = getFreePod()
    until pod or podWait >= 10 or not AutoRaid.isRunning

    if not pod then
        Util.debugPrint("[AutoRaid] No free pod found after waiting")
        if farmWasRunning then AutoFarm.start() end
        return false
    end
    teleportToPod(pod)
    Util.debugPrint("[AutoRaid] Teleported to pod:", pod.Name)

    -- Step 2: small wait for server to register our position at the pod,
    -- then fire world/difficulty directly — PlayerGui.Raids appearing is
    -- unreliable after a script-driven teleport so we don't gate on it.
    task.wait(1.5)

    if not AutoRaid.isRunning then
        if farmWasRunning then AutoFarm.start() end
        return false
    end

    -- Step 3: fire world + difficulty selection via RaidsLobbies remote
    local myParty = getMyPartyFolder()

    if not myParty then
        Util.debugPrint("[AutoRaid] Own party folder not found — cannot select stage")
        if farmWasRunning then AutoFarm.start() end
        return false
    end

    local lobbiesRemote = getRaidLobbiesRemote()

    local worldArg = "Worlds_" .. State.RaidWorld
    local ok1 = pcall(function()
        lobbiesRemote:FireServer(myParty, worldArg)
    end)
    Util.debugPrint("[AutoRaid] Select world fired:", worldArg, "| ok:", ok1)
    task.wait(0.3)

    local diffArg = "Diffculty_" .. State.RaidDifficulty
    local ok2 = pcall(function()
        lobbiesRemote:FireServer(myParty, diffArg)
    end)
    Util.debugPrint("[AutoRaid] Select difficulty fired:", diffArg, "| ok:", ok2)

    -- Restore farm now that the lobby is set up
    if farmWasRunning then AutoFarm.start() end

    return ok1 and ok2
end

-- ── Fire the actual start remote after delay + player wait ───
-- Returns true if started, false if lobby expired during the wait.
local function waitAndStartRaid()
    -- Start delay
    if State.RaidStartDelay > 0 then
        Util.debugPrint("[AutoRaid] Start delay:", State.RaidStartDelay, "s")
        local elapsed = 0
        while elapsed < State.RaidStartDelay and AutoRaid.isRunning do
            task.wait(1)
            elapsed += 1
        end
        if not AutoRaid.isRunning then return false end
    end

    -- Wait for X extra players
    -- Party folder children: 1 = owner entry always present.
    -- WaitPlayers = N means we need N+1 total children (owner + N others).
    if State.RaidWaitPlayers > 0 then
        local myParty   = getMyPartyFolder()
        local target    = State.RaidWaitPlayers + 1  -- +1 for ourselves
        local waited    = 0
        local MAX_WAIT  = 120  -- give up after 2 minutes, re-setup lobby

        Util.debugPrint("[AutoRaid] Waiting for", State.RaidWaitPlayers, "player(s) to join...")

        while AutoRaid.isRunning do
            -- Re-fetch party folder each tick in case it was recreated
            myParty = getMyPartyFolder()

            if not myParty then
                -- Party folder gone — lobby expired
                Util.debugPrint("[AutoRaid] Party folder disappeared while waiting for players — re-setting up lobby")
                return false
            end

            local count = #myParty:GetChildren()
            Util.debugPrint("[AutoRaid] Party size:", count, "/ need:", target)

            if count >= target then break end

            task.wait(1)
            waited += 1

            if waited >= MAX_WAIT then
                Util.debugPrint("[AutoRaid] Player wait timeout — re-setting up lobby")
                return false  -- caller will re-run setupLobby()
            end
        end

        if not AutoRaid.isRunning then return false end
    end

    -- Fire the actual start
    local startRemote = getRaidStartRemote()
    local ok = pcall(function()
        startRemote:FireServer(State.RaidWorld, State.RaidDifficulty)
    end)
    Util.debugPrint("[AutoRaid] Start raid fired | ok:", ok)
    return ok
end

-- ── RaidAction helper ─────────────────────────────────────────
local function sendRaidAction(action)
    local remote = getRaidActionRemote()
    if not remote then return false end
    local ok = pcall(function() remote:FireServer(action) end)
    Util.debugPrint("[AutoRaid] RaidAction:", action, "| ok:", ok)
    return ok
end

-- ── Main loop ────────────────────────────────────────────────
function AutoRaid.start()
    if AutoRaid.isRunning then return end
    AutoRaid.isRunning = true
    Util.notify("Auto Raid", "Auto Raid started! (" .. State.RaidWorld .. " | " .. State.RaidDifficulty .. ")")

    AutoRaid._thread = task.spawn(function()
        local skipLobby = false  -- set true after replay so we skip lobby setup

        while AutoRaid.isRunning do

            if not skipLobby then
                -- ── STEP 1: Set up lobby ──────────────────────────────────
                Util.debugPrint("[AutoRaid] Setting up lobby...")
                local lobbyOk = setupLobby()
                if not lobbyOk then
                    task.wait(3)
                    continue
                end

                -- ── STEP 2: Start delay + wait for players + start ────────
                local startOk = waitAndStartRaid()
                if not startOk then
                    task.wait(2)
                    continue
                end
            end

            skipLobby = false  -- reset for next iteration

            -- ── STEP 3: Wait until we're inside the raid (OnRaids flag) ───
            local joinWait = 0
            repeat
                task.wait(1)
                joinWait += 1
            until PlayerState.inRaid() or joinWait >= 30 or not AutoRaid.isRunning

            if not AutoRaid.isRunning then break end

            if not PlayerState.inRaid() then
                Util.debugPrint("[AutoRaid] Never entered raid — retrying")
                task.wait(3)
                continue
            end

            Util.debugPrint("[AutoRaid] Inside raid confirmed")

            -- ── STEP 4: Wait for Claimable signals via RaidsEvent ─────────
            -- "_Claimable"         → all enemies dead, Gold + Purple chests ready
            -- "_Claimable_Special" → special off-path enemies dead, Special chest ready
            local claimable        = false
            local claimableSpecial = false
            local raidFolder       = nil
            local stageWait        = 0
            local MAX_STAGE_WAIT   = 600

            local raidsEvent = Services.ReplicatedStorage.Remotes.Systems.RaidsEvent
            local claimConn  = raidsEvent.OnClientEvent:Connect(function(arg1)
                if type(arg1) ~= "string" then return end
                if arg1:find("_Claimable_Special") then
                    Util.debugPrint("[AutoRaid] Special claimable signal received:", arg1)
                    claimableSpecial = true
                elseif arg1:find("_Claimable") then
                    Util.debugPrint("[AutoRaid] Claimable signal received:", arg1)
                    claimable = true
                end
            end)

            repeat
                task.wait(1)
                stageWait += 1
                raidFolder = getRaidFolder()
            until claimable
                or stageWait >= MAX_STAGE_WAIT
                or not AutoRaid.isRunning

            claimConn:Disconnect()

            if not AutoRaid.isRunning then break end

            if stageWait >= MAX_STAGE_WAIT then
                Util.debugPrint("[AutoRaid] Stage timeout — force leaving")
                sendRaidAction("Leave")
                task.wait(3)
                continue
            end

            raidFolder = raidFolder or getRaidFolder()
            Util.debugPrint("[AutoRaid] Stage complete — chests claimable!")

            -- ── STEP 5: Open chests ────────────────────────────────────────
            if raidFolder then
                -- Gold (always ready with _Claimable)
                if waitForChestReady(raidFolder, "Golds", 12) then
                    openChest(raidFolder, "Golds", 8)
                end
                -- Special: wait a bit longer since it has its own signal
                -- It may already be claimable, or arrive shortly after
                if waitForChestReady(raidFolder, "Special", 10) then
                    openChest(raidFolder, "Special", 8)
                end
                -- Purple (key chest, same timing as Gold)
                if State.AutoOpenKeyChests then
                    if waitForChestReady(raidFolder, "Purple", 8) then
                        openChest(raidFolder, "Purple", 6)
                    end
                end
            else
                Util.debugPrint("[AutoRaid] No raidFolder — skipping chests")
            end

            -- ── STEP 6: Replay / Leave / Loop ─────────────────────────────
            task.wait(1)

            if State.AutoReplayRaid then
                Util.debugPrint("[AutoRaid] Replaying...")
                sendRaidAction("Replay")
                skipLobby = true  -- next iteration skips lobby, goes straight to step 3
                -- Wait for OnRaids to come back before looping
                local replayWait = 0
                repeat
                    task.wait(1)
                    replayWait += 1
                until PlayerState.inRaid() or replayWait >= 30 or not AutoRaid.isRunning
            elseif State.AutoLeaveRaid then
                Util.debugPrint("[AutoRaid] Leaving...")
                sendRaidAction("Leave")
                -- Fixed wait for the server to process the leave before next lobby setup
                task.wait(4)
                Util.notify("Auto Raid", "Raid complete — starting next run...")
                -- Loop continues → STEP 1
            else
                AutoRaid.isRunning = false
                Util.notify("Auto Raid", "Raid complete! Enable Replay or Leave to continue.")
                break
            end
        end
    end)
end

-- ── Join Player Raid ──────────────────────────────────────────
-- Polls pods until the target player's pod appears, then teleports into it.
function AutoRaid.startJoinPlayer()
    if State.JoinPlayerRaidTarget == "" then
        Util.notify("Join Player Raid", "No target player selected!")
        return
    end

    task.spawn(function()
        local target  = State.JoinPlayerRaidTarget
        local waited  = 0
        Util.notify("Join Player Raid", "Waiting for " .. target .. "'s pod...")

        while State.JoinPlayerRaidEnabled do
            local pod = findPodByPlayer(target)
            if pod then
                teleportToPod(pod)
                Util.notify("Join Player Raid", "Joined " .. target .. "'s pod!")
                State.JoinPlayerRaidEnabled = false
                break
            end
            task.wait(1)
            waited += 1
            if waited >= 60 then
                Util.notify("Join Player Raid", target .. "'s pod not found after 60s.")
                State.JoinPlayerRaidEnabled = false
                break
            end
        end
    end)
end

function AutoRaid.stop()
    AutoRaid.isRunning = false
    if TweenLock.holder == "raid" then TweenLock.holder = nil end
    Util.notify("Auto Raid", "Auto Raid stopped.")
end

-- ============================================================
-- AUTO TOWER MODULE
-- ============================================================
local AutoTower = {}

AutoTower.isRunning = false

function AutoTower.start()
    if AutoTower.isRunning then return end
    AutoTower.isRunning = true
    Util.notify("Auto Tower", "Auto Tower enabled!")

    task.spawn(function()
        while AutoTower.isRunning do
            -- Don't try to join if already inside
            if PlayerState.inTower() then
                task.wait(1)
                continue
            end

            -- Pause farm so it doesn't fight the server teleport
            local farmWasRunning = AutoFarm.isRunning
            if farmWasRunning then
                AutoFarm.isRunning = false
                pcall(function()
                    local root = LocalPlayer.Character
                        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then root.Anchored = false end
                end)
                if TweenLock.holder == "farm" then TweenLock.holder = nil end
            end

            -- Fire the remote — server handles teleport
            pcall(function()
                Services.ReplicatedStorage
                    :WaitForChild("Remotes")
                    :WaitForChild("Gameplays")
                    :WaitForChild("Towers")
                    :FireServer()
            end)

            -- Wait to confirm entry
            local enterWait = 0
            repeat
                task.wait(0.5)
                enterWait += 0.5
            until PlayerState.inTower() or enterWait >= 10 or not AutoTower.isRunning

            if farmWasRunning then AutoFarm.start() end

            if not PlayerState.inTower() then
                Util.debugPrint("[AutoTower] Join failed — retrying in 3s")
                task.wait(3)
                continue
            end

            Util.notify("Auto Tower", "Tower joined!")

            -- Wait until the tower ends
            repeat
                task.wait(1)
            until not PlayerState.inTower() or not AutoTower.isRunning

            -- Brief cooldown before rejoining to avoid double-firing
            task.wait(3)
        end
    end)
end

function AutoTower.stop()
    AutoTower.isRunning = false
end

-- Forward declaration — full implementation below.
AutoBossGate = { isRunning = false, stop = function() end }

-- ============================================================
-- AUTO BOSS GATE MODULE
-- ============================================================
do
    local _AutoBossGate = {}
    _AutoBossGate.isRunning = false

    local function findActiveBossWorld()
        local visual = workspace:FindFirstChild("BossFights_Visual")
        if not visual then return nil end
        for _, child in ipairs(visual:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                return child.Name
            end
        end
        return nil
    end

    local function teleportToStage(worldName)
        local ok, stage = pcall(function()
            return workspace.BossFights_Visual[worldName].Stage
        end)
        if not ok or not stage then
            Util.debugPrint("[AutoBossGate] Stage not found for world:", worldName)
            return false
        end
        local root = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        local pos = stage:IsA("BasePart") and stage.Position
            or (stage.PrimaryPart and stage.PrimaryPart.Position)
        if not pos then return false end
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        Util.debugPrint("[AutoBossGate] Teleported to stage:", worldName)
        return true
    end

    function _AutoBossGate.start()
        if _AutoBossGate.isRunning then return end
        _AutoBossGate.isRunning = true
        Util.notify("Auto Boss Gate", "Watching for boss fights...")

        task.spawn(function()
            while _AutoBossGate.isRunning do

                -- Already inside a boss gate — just wait it out
                if PlayerState.inBossGate() then
                    task.wait(1)
                    continue
                end

                local worldName = findActiveBossWorld()

                if worldName then
                    Util.notify("Auto Boss Gate", worldName .. " boss fight detected!")

                    -- Pause farm so it doesn't fight the teleport
                    local farmWasRunning = AutoFarm.isRunning
                    if farmWasRunning then
                        AutoFarm.isRunning = false
                        pcall(function()
                            local root = LocalPlayer.Character
                                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then root.Anchored = false end
                        end)
                        if TweenLock.holder == "farm" then TweenLock.holder = nil end
                    end

                    teleportToStage(worldName)

                    -- Wait until confirmed inside (up to 15s)
                    local enterWait = 0
                    repeat
                        task.wait(1)
                        enterWait += 1
                    until PlayerState.inBossGate() or enterWait >= 15 or not _AutoBossGate.isRunning

                    if farmWasRunning then AutoFarm.start() end

                    if not PlayerState.inBossGate() then
                        Util.debugPrint("[AutoBossGate] Failed to enter — retrying next spawn")
                    else
                        -- Wait for the boss gate to end
                        repeat
                            task.wait(1)
                        until not PlayerState.inBossGate() or not _AutoBossGate.isRunning
                        Util.debugPrint("[AutoBossGate] Boss gate ended")
                    end

                    -- Small cooldown so we don't instantly re-enter if the folder
                    -- lingers for a moment after the fight ends
                    task.wait(5)
                else
                    task.wait(1)
                end
            end
        end)
    end

    function _AutoBossGate.stop()
        _AutoBossGate.isRunning = false
        Util.notify("Auto Boss Gate", "Auto Boss Gate stopped.")
    end

    AutoBossGate = _AutoBossGate
end

-- ============================================================
-- AUTO RIFT MODULE
-- ============================================================
local AutoRift = {}

AutoRift.isRunning    = false
AutoRift.forceEnabled = false

local _seenRiftIDs = {}  -- IDs joined this session — never retry
AutoRift.pendingID  = nil

local function findNewRiftID()
    local folder = workspace:FindFirstChild("SpawnedRifts")
    if not folder then return nil end
    for _, child in ipairs(folder:GetChildren()) do
        local idVal = child:FindFirstChild("ID")
        if idVal and idVal.Value and idVal.Value ~= "" then
            local id = idVal.Value
            if not _seenRiftIDs[id] then
                return id
            end
        end
    end
    return nil
end

-- Stops everything cleanly before joining a rift
local function abortAllForRift()
    -- Stop module loops
    if AutoRaid.isRunning     then AutoRaid.stop()     end
    if AutoTower.isRunning    then AutoTower.stop()    end
    if AutoBossGate.isRunning then AutoBossGate.stop() end
    if AutoFarm.isRunning     then AutoFarm.stop()     end
    -- Release tween lock and unanchor player
    TweenLock.holder = nil
    pcall(function()
        local root = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
    end)
    task.wait(0.2)  -- brief yield so any running coroutines can clean up
end

local function doJoinRift(id)
    _seenRiftIDs[id] = true
    AutoRift.pendingID = nil

    local ok = pcall(function()
        Services.ReplicatedStorage
            :WaitForChild("Remotes")
            :WaitForChild("Gameplays")
            :WaitForChild("JoinRift")
            :FireServer(id)
    end)
    Util.debugPrint("[AutoRift] JoinRift fired | id:", id, "| ok:", ok)

    -- Confirm entry
    local enterWait = 0
    repeat
        task.wait(0.5)
        enterWait += 0.5
    until PlayerState.inRift() or enterWait >= 10

    if PlayerState.inRift() then
        Util.notify("Auto Rift", "Joined rift!")
    else
        Util.notify("Auto Rift", "Rift join unconfirmed — may have expired.")
    end
    return ok
end

function AutoRift.start()
    if AutoRift.isRunning then return end
    AutoRift.isRunning = true
    Util.notify("Auto Rift", "Auto Rift enabled — watching for rifts...")

    task.spawn(function()
        while AutoRift.isRunning do
            local id = findNewRiftID()

            if id then
                Util.debugPrint("[AutoRift] New rift spotted:", id)
                _seenRiftIDs[id] = true  -- mark immediately to avoid re-detection

                if AutoRift.forceEnabled then
                    -- Abort everything and join right now
                    abortAllForRift()
                    doJoinRift(id)

                elseif PlayerState.inRaid() or PlayerState.inBossGate() then
                    -- Polite: store and wait for the stage to end naturally
                    AutoRift.pendingID = id
                    Util.notify("Auto Rift", "Rift spotted — joining after current stage ends.")

                else
                    -- Farm/tower/nothing: stop them and join now
                    if AutoTower.isRunning then AutoTower.stop() end
                    if AutoFarm.isRunning  then
                        AutoFarm.stop()
                        TweenLock.holder = nil
                        pcall(function()
                            local root = LocalPlayer.Character
                                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then root.Anchored = false end
                        end)
                    end
                    doJoinRift(id)
                end

            elseif AutoRift.pendingID then
                -- We have a pending rift — check if we're now free to join
                if not PlayerState.inRaid() and not PlayerState.inBossGate() then
                    local pendingId = AutoRift.pendingID
                    Util.debugPrint("[AutoRift] Stage ended — joining pending rift:", pendingId)
                    abortAllForRift()
                    doJoinRift(pendingId)
                end
            end

            task.wait(1)
        end
    end)
end

function AutoRift.stop()
    AutoRift.isRunning = false
    AutoRift.pendingID = nil
    Util.notify("Auto Rift", "Auto Rift stopped.")
end

-- ============================================================
-- AUTO COLLECT MODULE  (Dragon Balls / Cursed Fingers)
-- ============================================================
local AutoCollect = {}

AutoCollect.dragonBalls   = false
AutoCollect.cursedFingers = false
AutoCollect.isRunning     = false

local VISUAL_FOLDER = function()
    return workspace:FindFirstChild("Visual")
end

-- Finds all collectible models in workspace.Visual matching the given name prefix
local function findCollectibles(namePrefix)
    local found = {}
    local visual = VISUAL_FOLDER()
    if not visual then return found end
    for _, model in ipairs(visual:GetChildren()) do
        if model.Name:find(namePrefix, 1, true) then
            table.insert(found, model)
        end
    end
    return found
end

-- Teleports to a model and fires its ProximityPrompt
local function collectModel(model)
    local primary = model:FindFirstChild("Primary")
    if not primary then return false end

    local prompt = primary:FindFirstChild("ProximityPrompt")
    if not prompt then return false end

    local root = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    -- Pause farm so no tween fights the teleport
    local farmWasRunning = AutoFarm.isRunning
    if farmWasRunning then
        AutoFarm.isRunning = false
        root.Anchored = false
        TweenLock.holder = nil
        task.wait(0.1)
    end

    -- Teleport to the collectible and anchor in place
    root.CFrame = primary.CFrame + Vector3.new(0, 0, 0)
    root.Anchored = true

    task.wait(0.1)
    pcall(function() fireproximityprompt(prompt) end)

    -- Keep firing and stay anchored until collected or timeout
    local elapsed = 0
    while model.Parent and elapsed < 5 do
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.3)
        elapsed += 0.3
    end

    root.Anchored = false
    if farmWasRunning then AutoFarm.start() end

    return model.Parent == nil
end

function AutoCollect.start()
    if AutoCollect.isRunning then return end
    AutoCollect.isRunning = true

    task.spawn(function()
        while AutoCollect.isRunning do
            local collected = false

            if AutoCollect.dragonBalls then
                for _, model in ipairs(findCollectibles("DragonBall")) do
                    if not AutoCollect.isRunning then break end
                    Util.debugPrint("[AutoCollect] Collecting Dragon Ball:", model.Name)
                    collectModel(model)
                    collected = true
                end
            end

            if AutoCollect.cursedFingers then
                for _, model in ipairs(findCollectibles("Sukuna")) do
                    if not AutoCollect.isRunning then break end
                    Util.debugPrint("[AutoCollect] Collecting Cursed Finger:", model.Name)
                    collectModel(model)
                    collected = true
                end
            end

            -- If nothing to collect, wait before scanning again
            if not collected then
                task.wait(2)
            end
        end
    end)
end

function AutoCollect.stop()
    AutoCollect.isRunning = false
end

local function updateAutoCollect()
    local shouldRun = AutoCollect.dragonBalls or AutoCollect.cursedFingers
    if shouldRun and not AutoCollect.isRunning then
        AutoCollect.start()
    elseif not shouldRun and AutoCollect.isRunning then
        AutoCollect.stop()
    end
end

-- ============================================================
-- AUTO SUMMON MODULE
-- ============================================================
local AutoSummon = {}

AutoSummon.isRunning = false
AutoSummon.animConnection = nil

local SUMMON_REMOTE = function()
    return Services.ReplicatedStorage:FindFirstChild("Remotes")
        and Services.ReplicatedStorage.Remotes:FindFirstChild("Summoners")
        and Services.ReplicatedStorage.Remotes.Summoners:FindFirstChild("RemoteEvent")
end

local SUMMON_ANIM_EVENT = function()
    return Services.ReplicatedStorage:FindFirstChild("Remotes")
        and Services.ReplicatedStorage.Remotes:FindFirstChild("Systems")
        and Services.ReplicatedStorage.Remotes.Systems:FindFirstChild("Summon_Visual")
end

function AutoSummon.doSummon()
    if not State.SummonWorld or State.SummonWorld == "" then
        Util.notify("Auto Summon", "No summon world selected!")
        return false
    end

    local summonFolder = workspace:FindFirstChild("Summoners")
    if not summonFolder then warn("[AutoSummon] Summoners folder not found") return false end

    local worldFolder = summonFolder:FindFirstChild(State.SummonWorld)
    if not worldFolder then warn("[AutoSummon] World folder not found:", State.SummonWorld) return false end

    local remote = SUMMON_REMOTE()
    if not remote then warn("[AutoSummon] Summon remote not found") return false end

    local success = pcall(function()
        remote:FireServer(worldFolder, State.SummonType)
    end)

    Util.debugPrint("[AutoSummon] Summoned:", State.SummonType, "in", State.SummonWorld)
    return success
end

function AutoSummon.start()
    if AutoSummon.isRunning then return end
    AutoSummon.isRunning = true
    Util.notify("Auto Summon", "Auto Summon started!")
    task.spawn(function()
        while AutoSummon.isRunning do
            AutoSummon.doSummon()
            task.wait(1)
        end
    end)
end

function AutoSummon.stop()
    AutoSummon.isRunning = false
    Util.notify("Auto Summon", "Auto Summon stopped.")
end

function AutoSummon.installHook()
    if AutoSummon.animBlocked then return end
    local animEvent = SUMMON_ANIM_EVENT()
    if animEvent then
        for _, Connection in getconnections(animEvent.OnClientEvent) do
            local old; old = hookfunction(Connection.Function, function(...)
                if State.BlockSummonAnim then
                    Util.debugPrint("[AutoSummon] Animation blocked")
                    return
                else
                    return old(...)
                end
            end)
        end
        AutoSummon.animBlocked = true
        Util.debugPrint("[AutoSummon] Animation hook installed")
    end
end

-- ============================================================
-- WEBHOOK MODULE
-- ============================================================
local Webhook = {}

Webhook.isHooked = false

function Webhook.send(data)
    if not State.WebhookEnabled or not State.WebhookURL or State.WebhookURL == "" then return end
    pcall(function()
        local payload = {
            username   = "ATS Hub",
            avatar_url = "https://i.imgur.com/AfFp7pu.png",
            embeds = {{
                title       = data.title or "Notification",
                description = data.description or "",
                color       = data.color or 3447003,
                fields      = data.fields or {},
                footer      = { text = "ATS Hub - " .. os.date("%I:%M:%S %p") }
            }}
        }
        if State.WebhookPingUser and State.DiscordID and State.DiscordID ~= "" then
            payload.content = "<@" .. State.DiscordID .. ">"
        end
        request({
            Url     = State.WebhookURL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = Services.HttpService:JSONEncode(payload)
        })
    end)
end

function Webhook.installHook()
    if Webhook.isHooked then return end
    local animEvent = SUMMON_ANIM_EVENT()
    if animEvent then
        for _, Connection in getconnections(animEvent.OnClientEvent) do
            local old; old = hookfunction(Connection.Function, function(...)
                local args = {...}
                local worldName  = args[1]
                local summonType = args[2]
                local units      = args[3]
                if State.WebhookEnabled and State.WebhookUnitObtained and units then
                    for _, unit in ipairs(units) do
                        local rarity   = unit.Rarity or "Unknown"
                        local unitName = unit.Real_Names or unit.Nickname or "Unknown"
                        local shiny    = unit.Shiny or false
                        local shouldPing = false
                        for _, selectedRarity in ipairs(State.WebhookUnitRarities) do
                            if rarity == selectedRarity then shouldPing = true break end
                        end
                        if shouldPing then
                            local shinyText   = shiny and " [Shiny]" or ""
                            local description = string.format(
                                "**Unit Obtained**\n+ %s [%s]%s\n\n**Player Stats**\n🔮 %s\n💰 %s",
                                unitName, rarity, shinyText,
                                worldName, State.SummonWorld or "Unknown"
                            )
                            local color = 3447003
                            if rarity == "Mythic"    then color = 15844367
                            elseif rarity == "Legendary" then color = 15105570
                            elseif rarity == "Epic"      then color = 10181046
                            elseif rarity == "Secret"    then color = 16711680
                            elseif rarity == "Exclusive" then color = 16776960
                            elseif rarity == "Limited"   then color = 16753920
                            elseif rarity == "Tactical"  then color = 65535
                            elseif rarity == "Rare"      then color = 5763719 end
                            Webhook.send({
                                title       = "ATS Hub | Anime Tacticals",
                                description = description,
                                color       = color,
                                fields      = {}
                            })
                        end
                    end
                end
                return old(...)
            end)
        end
        Webhook.isHooked = true
        Util.debugPrint("[Webhook] Unit detection hook installed")
    end
end

-- ============================================================
-- QUEST MODULE
-- ============================================================
local Quest = {}
_G.Quest = Quest

Quest.isRunning      = false
Quest.activeMobs     = {}
Quest.claimAttempted = {}

local QUEST_REMOTES = {
    Talk  = function() return Services.ReplicatedStorage.Remotes.Misc.TalkingEvent end,
    Claim = function() return Services.ReplicatedStorage.Remotes.Systems.QuestEvent end,
}

local function getQuestFolder()
    local data = Services.ReplicatedStorage:FindFirstChild("Players_Data")
    if not data then return nil end
    local pFolder = data:FindFirstChild(LocalPlayer.Name)
    if not pFolder then return nil end
    return pFolder:FindFirstChild("Quest")
end

function Quest.getAllGivers()
    local givers, seen = {}, {}
    pcall(function()
        local questInfo = Services.ReplicatedStorage.Shared.Infomations.Quest
        for _, obj in ipairs(questInfo:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                local ok, data = pcall(require, obj)
                if ok and type(data) == "table" then
                    local giver = data.Giving_Names
                    if type(giver) == "string" and giver ~= "" and not seen[giver] then
                        seen[giver] = true
                        table.insert(givers, giver)
                    end
                end
            end
        end
    end)
    return givers
end

function Quest.talkToAllGivers()
    local givers = Quest.getAllGivers()
    for _, giverName in ipairs(givers) do
        pcall(function() QUEST_REMOTES.Talk():FireServer(giverName) end)
        task.wait(0.3)
    end
    Util.debugPrint("[Quest] Talked to", #givers, "quest givers")
end

local questWorldCache = nil

local function buildQuestWorldCache()
    if questWorldCache then return questWorldCache end
    questWorldCache = {}
    pcall(function()
        local questInfo = Services.ReplicatedStorage.Shared.Infomations.Quest
        for _, obj in ipairs(questInfo:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                local ok, data = pcall(require, obj)
                if ok and type(data) == "table" and data.Names and data.Worlds then
                    questWorldCache[data.Names] = data.Worlds
                end
            end
        end
    end)
    return questWorldCache
end

function Quest.getActiveDefeatQuests()
    local active     = {}
    local folder     = getQuestFolder()
    if not folder then return active end
    local worldCache = buildQuestWorldCache()

    for _, questFolder in ipairs(folder:GetChildren()) do
        if not questFolder:IsA("Folder") then continue end
        local finishedVal = questFolder:FindFirstChild("Finished")
        if finishedVal and finishedVal.Value == true then continue end
        local defeatGroups = questFolder:FindFirstChild("Defeat_Groups")
        if not defeatGroups then continue end
        local questWorld = worldCache[questFolder.Name] or "Unknown"
        for _, group in ipairs(defeatGroups:GetChildren()) do
            local eventVal   = group:FindFirstChild("Event")
            local nameVal    = group:FindFirstChild("Defeat_Names")
            local numbersVal = group:FindFirstChild("Numbers")
            local maxVal     = group:FindFirstChild("Maximum")
            if not eventVal or eventVal.Value ~= "Defeat" then continue end
            if not nameVal  or nameVal.Value == "" or nameVal.Value == "-" then continue end
            if not numbersVal or not maxVal then continue end
            if numbersVal.Value >= maxVal.Value then continue end
            table.insert(active, { questName = questFolder.Name, mobName = nameVal.Value, world = questWorld })
        end
    end
    return active
end

function Quest.getClaimableQuests()
    local claimable = {}
    local folder    = getQuestFolder()
    if not folder then return claimable end
    for _, questFolder in ipairs(folder:GetChildren()) do
        if not questFolder:IsA("Folder") then continue end
        local finishedVal = questFolder:FindFirstChild("Finished")
        if not finishedVal or finishedVal.Value ~= true then continue end
        local defeatGroups = questFolder:FindFirstChild("Defeat_Groups")
        if not defeatGroups then
            Util.debugPrint("[Quest] Skipping claim for", questFolder.Name, "— no Defeat_Groups")
            continue
        end
        table.insert(claimable, questFolder.Name)
    end
    return claimable
end

function Quest.claimAll()
    local claimable = Quest.getClaimableQuests()
    if #claimable == 0 then return end
    local claimedCount = 0
    for _, questName in ipairs(claimable) do
        if Quest.claimAttempted[questName] then
            Util.debugPrint("[Quest] Skipping already-attempted claim:", questName)
            continue
        end
        local success = pcall(function()
            QUEST_REMOTES.Claim():FireServer("Claim", questName)
        end)
        if success then
            claimedCount += 1
        else
            Quest.claimAttempted[questName] = true
        end
        task.wait(0.3)
    end
    if claimedCount > 0 then
        Util.notify("Auto Claim", "Claimed " .. claimedCount .. " quest(s)!")
        task.wait(0.5)
        Quest.talkToAllGivers()
    end
end

WORLD_PRIORITY = {
    ["Namex Planet"]       = 1,
    ["Colosseum Kingdom"]  = 2,
    ["Demon Forest"]       = 3,
    ["Dungeons Town"]      = 4,
    ["Reaper Society"]     = 5,
    ["Jujutsu Highschool"] = 6,
}

function Quest.rebuildActiveMobs()
    local quests = Quest.getActiveDefeatQuests()
    table.sort(quests, function(a, b)
        local pa = WORLD_PRIORITY[a.world] or 999
        local pb = WORLD_PRIORITY[b.world] or 999
        return pa < pb
    end)
    local mobs, seen = {}, {}
    for _, entry in ipairs(quests) do
        local displayName = Loader.translateName(entry.mobName)
        if not seen[displayName] then
            seen[displayName] = true
            table.insert(mobs, displayName)
        end
    end
    Quest.activeMobs = mobs
    Util.debugPrint("[Quest] Target list:", #Quest.activeMobs, "unique mobs —", table.concat(mobs, ", "))
end

function Quest.start()
    if Quest.isRunning then return end
    Quest.isRunning = true
    Util.notify("Auto Quest", "Auto Quest started!")
    task.spawn(function()
        Quest.talkToAllGivers()
        task.wait(1)
        Quest.rebuildActiveMobs()
        if not AutoFarm.isRunning then AutoFarm.start() end
        local lastQuestCount = 0
        while Quest.isRunning do
            local currentQuests = Quest.getActiveDefeatQuests()
            local currentCount  = #currentQuests
            if currentCount ~= lastQuestCount then
                Quest.rebuildActiveMobs()
                lastQuestCount = currentCount
            end
            if State.AutoClaimEnabled then Quest.claimAll() end
            task.wait(15)
        end
    end)
end

function Quest.stop()
    Quest.isRunning  = false
    Quest.activeMobs = {}
    if not State.AutoFarmNearest and not State.AutoFarmSelected then AutoFarm.stop() end
    Util.notify("Auto Quest", "Auto Quest stopped.")
end

-- ============================================================
-- MAIN INITIALIZATION
-- ============================================================
local function initialize()

    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)

    if not success or not Rayfield then
        warn("[ATS] Failed to load Rayfield UI:", Rayfield)
        return
    end

    _G.Rayfield = Rayfield

    -- ── Window ───────────────────────────────────────────────
    local Window = Rayfield:CreateWindow({
        Name            = "Anime Tactical Simulator",
        Icon            = 0,
        LoadingTitle    = "Anime Tactical Simulator",
        LoadingSubtitle = "Script Hub | " .. script_version,
        ShowText        = "ATS Hub",

        Theme = {
            TextColor  = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(20, 20, 28),
            Topbar     = Color3.fromRGB(30, 30, 42),
            Shadow     = Color3.fromRGB(12, 12, 18),
        },

        ToggleUIKeybind = "K",

        DisableRayfieldPrompts = false,
        DisableBuildWarnings   = true,

        ConfigurationSaving = {
            Enabled    = true,
            FolderName = "ATSHub",
            FileName   = LocalPlayer.Name .. "_ATS",
        },

        KeySystem = false,
    })

    -- ══════════════════════════════════════════════════════════
    -- TAB: MAIN
    -- ══════════════════════════════════════════════════════════
    local MainTab = Window:CreateTab("Main", "swords")

    MainTab:CreateSection("Auto FARM")

    MainTab:CreateLabel("TOGGLE THE AUTO FARM NEAREST DOWN BELOW FOR ANY TYPE OF FARMING (Rift, Raids) any gamemodes!")

    MainTab:CreateToggle({
        Name         = "Auto Farm Nearest/Raid/Tower Mobs",
        CurrentValue = false,
        Flag         = "AutoFarmNearest",
        Callback     = function(Value)
            State.AutoFarmNearest = Value
            if Value then
                State.AutoFarmSelected = false
                AutoFarm.start()
            else
                if not State.AutoFarmSelected then AutoFarm.stop() end
            end
        end,
    })

    MainTab:CreateToggle({
        Name         = "Auto Farm Selected Mobs",
        CurrentValue = false,
        Flag         = "AutoFarmSelected",
        Callback     = function(Value)
            State.AutoFarmSelected = Value
            if Value then
                State.AutoFarmNearest = false
                AutoFarm.start()
            else
                if not State.AutoFarmNearest then AutoFarm.stop() end
            end
        end,
    })

    local MobDropdown = MainTab:CreateDropdown({
        Name            = "Select Mobs",
        Options         = {},
        CurrentOption   = {},
        MultipleOptions = true,
        Flag            = "SelectedMobs",
        Info            = "Select which mobs to target. Choose a world first to populate this list.",
        Callback        = function(selected)
            State.SelectedMobs = type(selected) == "table" and selected or { selected }
        end,
    })

    local worldOptions = Loader.getWorlds()
    local defaultWorld = "Namex Planet"

    State.SelectedWorld = defaultWorld
    MobDropdown:Refresh(Loader.getMobsForWorld(defaultWorld), {})

    MainTab:CreateDropdown({
        Name            = "Select World",
        Options         = worldOptions,
        CurrentOption   = { defaultWorld },
        MultipleOptions = false,
        Flag            = "SelectedWorld",
        Info            = "Select the world to farm in. Mob list will update automatically.",
        Callback        = function(selected)
            local worldName = type(selected) == "table" and selected[1] or selected
            if not worldName or worldName == "" then return end
            State.SelectedWorld = worldName
            State.SelectedMobs  = {}
            local mobs = Loader.getMobsForWorld(worldName)
            MobDropdown:Refresh(mobs, {})
            Util.notify("World Selected", worldName .. " — " .. #mobs .. " mob(s) loaded.")
        end,
    })

    MainTab:CreateDivider()

    MainTab:CreateToggle({
        Name         = "Auto Quest",
        CurrentValue = false,
        Flag         = "AutoQuest",
        Info         = "Automatically farms mobs required by your active quests. Higher priority than Auto Farm.",
        Callback     = function(Value)
            State.AutoQuestEnabled = Value
            if Value then Quest.start() else Quest.stop() end
        end,
    })

    MainTab:CreateToggle({
        Name         = "Auto Claim Quests",
        CurrentValue = false,
        Flag         = "AutoClaimQuests",
        Info         = "Claims completed quests and talks to all quest givers to refresh and re-accept repeatables.",
        Callback     = function(Value)
            State.AutoClaimEnabled = Value
        end,
    })

    -- ══════════════════════════════════════════════════════════
    -- TAB: GAMEMODES  (Auto Raid)
    -- ══════════════════════════════════════════════════════════
    local GamemodesTab = Window:CreateTab("Gamemodes", "sword")

    -- ── Raid Configuration ───────────────────────────────────
    GamemodesTab:CreateSection("Raid Configuration")

    local raidWorldOptions = Loader.getWorlds()
    local defaultRaidWorld = "Namex Planet"
    State.RaidWorld        = defaultRaidWorld

    GamemodesTab:CreateDropdown({
        Name            = "Select Raid",
        Options         = raidWorldOptions,
        CurrentOption   = { defaultRaidWorld },
        MultipleOptions = false,
        Flag            = "RaidWorld",
        Info            = "Select which raid world to run.",
        Callback        = function(selected)
            local worldName = type(selected) == "table" and selected[1] or selected
            State.RaidWorld = worldName or defaultRaidWorld
        end,
    })

    GamemodesTab:CreateDropdown({
        Name            = "Select Difficulty",
        Options         = { "Easy", "Normal", "Hard", "Insane", "Nightmare" },
        CurrentOption   = { "Easy" },
        MultipleOptions = false,
        Flag            = "RaidDifficulty",
        Info            = "Select the raid difficulty.",
        Callback        = function(selected)
            local diff = type(selected) == "table" and selected[1] or selected
            State.RaidDifficulty = diff or "Easy"
        end,
    })

    -- ── Raid Automation ──────────────────────────────────────
    GamemodesTab:CreateSection("Raid Automation")

    GamemodesTab:CreateToggle({
        Name         = "Auto Start Raid",
        CurrentValue = false,
        Flag         = "AutoStartRaid",
        Info         = "Teleports to a pod, selects world/difficulty, waits for players (if set), then starts the raid. Pair with Auto Farm Nearest.",
        Callback     = function(Value)
            State.AutoRaidEnabled = Value
            if Value then AutoRaid.start() else AutoRaid.stop() end
        end,
    })

    GamemodesTab:CreateToggle({
        Name         = "Auto Replay Raid",
        CurrentValue = false,
        Flag         = "AutoReplayRaid",
        Info         = "After finishing a raid, automatically replay it. Mutually exclusive with Auto Leave.",
        Callback     = function(Value)
            State.AutoReplayRaid = Value
            if Value then State.AutoLeaveRaid = false end
        end,
    })

    GamemodesTab:CreateToggle({
        Name         = "Auto Leave Raid",
        CurrentValue = false,
        Flag         = "AutoLeaveRaid",
        Info         = "After finishing a raid (and opening chests), automatically leave. Mutually exclusive with Auto Replay.",
        Callback     = function(Value)
            State.AutoLeaveRaid = Value
            if Value then State.AutoReplayRaid = false end
        end,
    })

    GamemodesTab:CreateSlider({
        Name         = "Start Time (seconds delay)",
        Range        = { 0, 60 },
        Increment    = 1,
        CurrentValue = 0,
        Flag         = "RaidStartDelay",
        Info         = "How many seconds to wait after the lobby is set up before firing the start remote.",
        Callback     = function(Value)
            State.RaidStartDelay = Value
        end,
    })

    GamemodesTab:CreateSlider({
        Name         = "Wait x Players",
        Range        = { 0, 5 },
        Increment    = 1,
        CurrentValue = 0,
        Flag         = "RaidWaitPlayers",
        Info         = "Wait for this many extra players to join the lobby before starting. 0 = start immediately.",
        Callback     = function(Value)
            State.RaidWaitPlayers = Value
        end,
    })

    GamemodesTab:CreateDivider()

    -- ── Chest Settings ───────────────────────────────────────
    GamemodesTab:CreateSection("Chest Settings")

    GamemodesTab:CreateLabel("Gold & Special chests are always opened automatically when Auto Start Raid is on.")

    GamemodesTab:CreateToggle({
        Name         = "Open Dungeon Key Chests",
        CurrentValue = false,
        Flag         = "AutoOpenKeyChests",
        Info         = "Also open the Purple (key) chest at end of raid. Requires a key. Gives up after 6s if no key.",
        Callback     = function(Value)
            State.AutoOpenKeyChests = Value
        end,
    })

    GamemodesTab:CreateDivider()

    -- ── Join Player Raid ─────────────────────────────────────
    GamemodesTab:CreateSection("Join Player Raid")

    -- Build player list (all players except self)
    local function getOtherPlayers()
        local list = {}
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        table.sort(list)
        return list
    end

    local otherPlayers = getOtherPlayers()

    local joinPlayerDropdown = GamemodesTab:CreateDropdown({
        Name            = "Join Player Raid",
        Options         = #otherPlayers > 0 and otherPlayers or { "No players in server" },
        CurrentOption   = {},
        MultipleOptions = false,
        Flag            = "JoinPlayerRaidTarget",
        Info            = "Select a player whose raid pod to jump into.",
        Callback        = function(selected)
            local name = type(selected) == "table" and selected[1] or selected
            if name == "No players in server" then name = "" end
            State.JoinPlayerRaidTarget = name or ""
        end,
    })

    -- Refresh player list when dropdown is opened (best effort)
    Services.Players.PlayerAdded:Connect(function()
        local updated = getOtherPlayers()
        joinPlayerDropdown:Refresh(#updated > 0 and updated or { "No players in server" }, {})
    end)
    Services.Players.PlayerRemoving:Connect(function(p)
        if State.JoinPlayerRaidTarget == p.Name then
            State.JoinPlayerRaidTarget = ""
        end
        local updated = getOtherPlayers()
        joinPlayerDropdown:Refresh(#updated > 0 and updated or { "No players in server" }, {})
    end)

    GamemodesTab:CreateToggle({
        Name         = "Auto Join Player Raid",
        CurrentValue = false,
        Flag         = "AutoJoinPlayerRaid",
        Info         = "Teleports you into the selected player's raid pod as soon as it appears. Turns off after one join.",
        Callback     = function(Value)
            State.JoinPlayerRaidEnabled = Value
            if Value then
                AutoRaid.startJoinPlayer()
            end
        end,
    })

    GamemodesTab:CreateDivider()

    -- ── Rift ─────────────────────────────────────────────────
    GamemodesTab:CreateSection("Rift")

    GamemodesTab:CreateToggle({
        Name         = "Auto Rift",
        CurrentValue = false,
        Flag         = "AutoRift",
        Info         = "Watches workspace.SpawnedRifts for any rift and joins it automatically using its ID.",
        Callback     = function(Value)
            if Value then AutoRift.start() else AutoRift.stop() end
        end,
    })

    GamemodesTab:CreateToggle({
        Name         = "Force Join Rift\n(Will Leave Gamemode for it)",
        CurrentValue = false,
        Flag         = "ForceJoinRift",
        Info         = "When a rift spawns, immediately stops any active Raid or Tower and joins the rift.",
        Callback     = function(Value)
            AutoRift.forceEnabled = Value
        end,
    })

    GamemodesTab:CreateDivider()

    -- ── Tower ────────────────────────────────────────────────
    GamemodesTab:CreateSection("Tower")

    GamemodesTab:CreateToggle({
        Name         = "Auto Join Tower",
        CurrentValue = false,
        Flag         = "AutoJoinTower",
        Info         = "Teleports to the Tower area, waits for the UI to load, then starts the tower automatically.",
        Callback     = function(Value)
            if Value then
                AutoTower.start()
            else
                AutoTower.stop()
            end
        end,
    })

    GamemodesTab:CreateDivider()

    -- ── Boss Gate ─────────────────────────────────────────────
    GamemodesTab:CreateSection("Boss Gate")

    GamemodesTab:CreateToggle({
        Name         = "Auto Boss Gate",
        CurrentValue = false,
        Flag         = "AutoBossGate",
        Info         = "Watches BossFights_Visual for any boss fight and teleports to its portal to enter automatically.",
        Callback     = function(Value)
            if Value then AutoBossGate.start() else AutoBossGate.stop() end
        end,
    })

    -- ══════════════════════════════════════════════════════════
    -- TAB: COLLECTIBLES
    -- ══════════════════════════════════════════════════════════
    local CollectTab = Window:CreateTab("Collectibles", "gem")

    CollectTab:CreateSection("Auto Collect")

    CollectTab:CreateToggle({
        Name         = "Auto Collect Wish Orbs (Dragon Balls)",
        CurrentValue = false,
        Flag         = "AutoCollectDragonBalls",
        Info         = "Teleports to and collects any Dragon Ball models in workspace.Visual.",
        Callback     = function(Value)
            AutoCollect.dragonBalls = Value
            updateAutoCollect()
        end,
    })

    CollectTab:CreateToggle({
        Name         = "Auto Collect Cursed Fingers",
        CurrentValue = false,
        Flag         = "AutoCollectCursedFingers",
        Info         = "Teleports to and collects any Sukuna (cursed finger) models in workspace.Visual.",
        Callback     = function(Value)
            AutoCollect.cursedFingers = Value
            updateAutoCollect()
        end,
    })

    -- ══════════════════════════════════════════════════════════
    -- TAB: AUTO SUMMON
    -- ══════════════════════════════════════════════════════════
    local SummonTab = Window:CreateTab("Auto Summon", "sparkles")

    SummonTab:CreateSection("Summon Settings")

    local summonWorldOptions = Loader.getWorlds()
    local defaultSummonWorld = summonWorldOptions[1] or ""
    State.SummonWorld = defaultSummonWorld

    SummonTab:CreateDropdown({
        Name            = "Select Summon World",
        Options         = summonWorldOptions,
        CurrentOption   = { defaultSummonWorld },
        MultipleOptions = false,
        Flag            = "SummonWorld",
        Info            = "Select which world summon banner to use",
        Callback        = function(selected)
            local worldName = type(selected) == "table" and selected[1] or selected
            State.SummonWorld = worldName or ""
            Util.notify("Summon World", "Selected: " .. (worldName or "None"))
        end,
    })

    SummonTab:CreateDropdown({
        Name            = "Select Summon Type",
        Options         = { "Single", "Multi" },
        CurrentOption   = { "Single" },
        MultipleOptions = false,
        Flag            = "SummonType",
        Callback        = function(selected)
            local summonType = type(selected) == "table" and selected[1] or selected
            State.SummonType = summonType or "Single"
        end,
    })

    SummonTab:CreateToggle({
        Name         = "Remove Summon Animation",
        CurrentValue = false,
        Flag         = "BlockSummonAnim",
        Info         = "Blocks the summon animation for faster summoning",
        Callback     = function(Value)
            State.BlockSummonAnim = Value
        end,
    })

    SummonTab:CreateDivider()

    SummonTab:CreateToggle({
        Name         = "Auto Summon",
        CurrentValue = false,
        Flag         = "AutoSummon",
        Info         = "Automatically summon units from the selected world",
        Callback     = function(Value)
            State.AutoSummonEnabled = Value
            if Value then AutoSummon.start() else AutoSummon.stop() end
        end,
    })

    -- ══════════════════════════════════════════════════════════
    -- TAB: WEBHOOK
    -- ══════════════════════════════════════════════════════════
    local WebhookTab = Window:CreateTab("Webhook", "bell")

    WebhookTab:CreateSection("Webhook Configuration")

    WebhookTab:CreateToggle({
        Name         = "Webhook",
        CurrentValue = false,
        Flag         = "WebhookEnabled",
        Info         = "Enable Discord webhook notifications",
        Callback     = function(Value) State.WebhookEnabled = Value end,
    })

    WebhookTab:CreateInput({
        Name                     = "Webhook URL",
        PlaceholderText          = "https://discord.com/api/webhooks/...",
        RemoveTextAfterFocusLost = false,
        Flag                     = "WebhookURL",
        Callback                 = function(Value) State.WebhookURL = Value end,
    })

    WebhookTab:CreateInput({
        Name                     = "Discord ID",
        PlaceholderText          = "942709395253522442",
        RemoveTextAfterFocusLost = false,
        Flag                     = "DiscordID",
        Callback                 = function(Value) State.DiscordID = Value end,
    })

    WebhookTab:CreateToggle({
        Name         = "Webhook Ping User",
        CurrentValue = false,
        Flag         = "WebhookPingUser",
        Info         = "Ping your Discord ID when sending webhooks",
        Callback     = function(Value) State.WebhookPingUser = Value end,
    })

    WebhookTab:CreateDivider()
    WebhookTab:CreateSection("Notification Settings")

    WebhookTab:CreateToggle({
        Name         = "Webhook Unit Obtained",
        CurrentValue = false,
        Flag         = "WebhookUnitObtained",
        Info         = "Send webhook when you obtain a unit from the selected rarities",
        Callback     = function(Value) State.WebhookUnitObtained = Value end,
    })

    WebhookTab:CreateDropdown({
        Name            = "Select Unit Rarities",
        Options         = { "Epic", "Exclusive", "Legendary", "Limited", "Mythic", "Rare", "Secret", "Tactical" },
        CurrentOption   = {},
        MultipleOptions = true,
        Flag            = "WebhookUnitRarities",
        Info            = "Which rarities should trigger a webhook notification",
        Callback        = function(selected)
            State.WebhookUnitRarities = type(selected) == "table" and selected or { selected }
        end,
    })

    WebhookTab:CreateToggle({
        Name         = "Webhook Avatar Obtained",
        CurrentValue = false,
        Flag         = "WebhookAvatarObtained",
        Info         = "Send webhook when you obtain an avatar (Not functional yet)",
        Callback     = function(Value) State.WebhookAvatarObtained = Value end,
    })

    -- ── Load saved config & install hooks ────────────────────
    _G.Rayfield:LoadConfiguration()
    AutoSummon.installHook()
    Webhook.installHook()

    Util.notify("ATS Hub", "Loaded! v" .. script_version)
end

-- ============================================================
-- ENTRY POINT
-- ============================================================
initialize()
