if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller
    and newcclosure and writefile and readfile and isfile and getnilinstances) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED")
    return
end

getgenv().RAYFIELD_SECURE = true
getgenv().RAYFIELD_ASSET_ID = 77799463979503
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local script_version = "V0.03"
local debug = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

repeat task.wait(0.5) until
    player.Character and
    player.Character:FindFirstChild("HumanoidRootPart") and
    player.Character:FindFirstChild("Humanoid") and
    player.Character.Humanoid.Health > 0

local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function isInLobby()
    return workspace:GetAttribute("Map") == "Lobby"
end

local function isInMainMenu()
    return game.PlaceId == 13379208636
end

repeat task.wait(0.5) until
    ReplicatedStorage:FindFirstChild("Assets") and
    ReplicatedStorage.Assets:FindFirstChild("Remotes") and
    ReplicatedStorage.Assets.Remotes:FindFirstChild("POST") and
    ReplicatedStorage.Assets.Remotes:FindFirstChild("GET")

if not isInLobby() and not isInMainMenu() then
    repeat task.wait(0.5) until workspace:GetAttribute("Type") ~= nil
    repeat task.wait(0.5) until #getactors() > 0
end

local POST = ReplicatedStorage.Assets.Remotes.POST
local GET  = ReplicatedStorage.Assets.Remotes.GET

local State = {
    AntiAfkKickEnabled = false,
    autoSkillsEnabled = false,
    autoSkillSlots = {},
    autoUseBoosts = false,
    autoPurchaseBoosts = false,
    autoPurchaseBoostsCurrencySelection = "",
    autoPurchaseBoostsSelection = "",
    autoClaimAchievements = false,
    prioritizeBosses = false,
    skipCutscenesEnabled = false,
    multiHitEnabled = false,
    multiHitCount   = 3,
    autoJoinDelaySecs = 3,
    syncEnabled          = false,
    syncedPosition       = nil,
    oldIndex             = nil,
    inHook               = false,
    escapeEnabled        = false,
    waitBeforeFarming    = false,
    waitFarmSeconds      = 15,
    waitLastTitanSeconds = 30,
    floatHeight          = 200,
    attackConnection     = nil,
    farmActive           = false,
    attackInterval       = 0,
    stopRequested        = false,
    tweenSpeed           = 300,
    returnToLobbyEnabled  = false,
    returnToLobbyMinutes  = 10,
    farmStartTime         = nil,
    lobbyTimerConnection  = nil,
    autoRetry  = false,
    autoLobby  = false,
    webhookEnabled = false,
    webhookUrl     = nil,
    discordUserId  = nil,
    sessionRuns = getgenv().__LIXHUB_RUNS or 0,
    autoJoinMissions       = false,
    autoJoinMissionMap     = "",
    autoJoinMissionObj     = "Skirmish",
    autoJoinMissionDiff    = "",
    autoJoinMissionMods    = {},

    autoJoinRaids          = false,
    autoJoinRaidType       = "",
    autoJoinRaidDiff       = "",
    autoJoinRaidMods       = {},

    autoJoinWaves          = false,
    autoJoinWavesMap       = "",

    returnToLobbyGames         = 10,
    returnToLobbyGamesEnabled  = false,
    waitBeforeRaidBoss    = false,
    waitRaidBossSeconds   = 30,
}

local Raids = {}

Raids.State = {
    active = false,
    autoOpenChests = false,
    autoOpenEmperorChests = false,
    connection = nil,
    phase = "defend",
    stopRequested = false,
}

local Waves = {}

Waves.State = {
    active           = false,
    stopRequested    = false,
    connection       = nil,
    autoVote         = false,
    returnAfterWaves = false,
    returnWaveCount  = 10,
    autoUpgrade      = false,
    upgradeConnection = nil,
    autoBuyUpgrades  = false,
    buyUpgradesList  = {},
    buyConnection    = nil,
}

local ColossalState = {
    onCannon   = false,
    claimed    = false,
    stopRequested = false,
}

local Movers = {
    bodyPos  = nil,
    bodyGyro = nil,
}

local RAID_TITAN_MAP = {
    ["Attack Titan"]   = "Trost",
    ["Armored Titan"]  = "Shiganshina",
    ["Female Titan"]   = "Stohess",
    ["Colossal Titan"] = "Shiganshina",
}

local RollState = {
    active = false,
    targetFamilies = {},
    connection = nil,
}

local RARITY_COLORS = {
    Common    = 0x808080,
    Rare      = 0x3498DB,
    Epic      = 0x9B59B6,
    Legendary = 0xF1C40F,
    Mythic    = 0xE74C3C,
    Secret    = 0x010101,
}

local familyRarityMap = {}
local familyDropdownOptions = {}

-- ==================== COLLISION ====================
local noclipConnection = nil
local currentTarget = nil
-- "idle" | "swapping" | "refilling"
local ReloadState     = "idle"
local RaidReloadState = "idle"
local WaveReloadState = "idle"
local Util = {}
local PERK_RARITIES = {}
local ITEM_RARITIES = {}
local autoJoinConnection = nil
local autoJoinProcessing = false
local autoBoostConnection = nil
local skillInfoMap = {}
local skillDropdownOptions = {}
local autoSkillConnection = nil
local skillLastUsed = {}

function Util.notify(title, content, duration, image)
    Rayfield:Notify({
        Title = title or "Notification",
        Content = content or "",
        Duration = duration or 3,
        Image = image or nil,
    })
end

local function debugPrint(...)
    if not debug then return end
    print("[LixHub] ", ...)
end

local function waitForCutscene()
    while player:GetAttribute("Cutscene") == true do
        task.wait(0.5)
    end
end

local function disableCollision()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if not char then return end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end)
end

local function enableCollision()
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
end

-- ==================== BODY MOVERS + LERP ====================
local targetPosition = nil
local targetGyro     = nil

local currentVelocity = Vector3.zero

RunService.Heartbeat:Connect(function(dt)
    if not targetPosition then 
        rootPart.AssemblyLinearVelocity = Vector3.zero
        currentVelocity = Vector3.zero
        return 
    end
    
    State.inHook = true
    local current = rootPart.Position
    State.inHook = false
    
    local remaining = (targetPosition - current).Magnitude
    
    if remaining < 2 then
        rootPart.AssemblyLinearVelocity = Vector3.zero
        currentVelocity = Vector3.zero
        return
    end
    
    local direction = (targetPosition - current).Unit
    
    -- Decelerate as we get closer (smoother arrival)
    local speedMultiplier = math.min(remaining / 15, 1)  -- Start slowing at 15 studs
    local targetVelocity = direction * (State.tweenSpeed * speedMultiplier)
    
    -- Fast response when target changes significantly, smooth otherwise
    local velocityDelta = (targetVelocity - currentVelocity).Magnitude
    local lerpAlpha = velocityDelta > 100 and 0.5 or 0.25  -- 0.5 = fast switch, 0.25 = smooth movement
    
    currentVelocity = currentVelocity:Lerp(targetVelocity, lerpAlpha)
    rootPart.AssemblyLinearVelocity = currentVelocity
    
    if targetGyro and Movers.bodyGyro then
        Movers.bodyGyro.CFrame = targetGyro
    end
end)

local function ensureBodyMovers(targetCFrame)
    disableCollision()
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.AutoRotate    = false
    end
    -- keep BodyGyro for rotation only
    if not Movers.bodyGyro then
        Movers.bodyGyro           = Instance.new("BodyGyro")
        Movers.bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        Movers.bodyGyro.P         = 1e5
        Movers.bodyGyro.D         = 1000
        Movers.bodyGyro.Name      = "_FarmGyro"
        Movers.bodyGyro.Parent    = rootPart
    end
    targetPosition = targetCFrame.Position
    targetGyro     = targetCFrame
end

local function removeBodyMovers()
    targetPosition = nil   -- nil this FIRST so the heartbeat skips immediately
    targetGyro     = nil
    currentVelocity = Vector3.zero
    if Movers.bodyPos  then Movers.bodyPos:Destroy();  Movers.bodyPos  = nil end
    if Movers.bodyGyro then Movers.bodyGyro:Destroy(); Movers.bodyGyro = nil end
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
    end
    enableCollision()
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate    = true
    end
end

-- ==================== POSITION SYNC ====================
local function enableSync()
    if State.syncEnabled then return end
    State.syncEnabled = true
    local mt = getrawmetatable(game)
    State.oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if State.inHook then return State.oldIndex(self, key) end
        State.inHook = true
        local success, result = pcall(function()
            if State.syncEnabled and self == rootPart then
                if key == "Position" and State.syncedPosition then return State.syncedPosition end
                if key == "CFrame"   and State.syncedPosition then
                    return CFrame.new(State.syncedPosition) * rootPart.CFrame.Rotation
                end
            end
            return State.oldIndex(self, key)
        end)
        State.inHook = false
        return success and result or State.oldIndex(self, key)
    end)
    setreadonly(mt, true)
end

local function disableSync()
    State.syncEnabled    = false
    State.syncedPosition = nil
    if State.oldIndex then
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__index = State.oldIndex
        setreadonly(mt, true)
    end
end

-- ==================== BLADE STATUS ====================
local function getBladeStatus()
    local rig = character:FindFirstChild("Rig_" .. character.Name)
    if not rig then return 0, 0 end

    local cassettesLeft = 0
    for i = 1, 3 do
        local c = rig:FindFirstChild("Left_" .. i, true)
        if c and c:GetAttribute("Used") == nil then
            cassettesLeft += 1
        end
    end

    local segmentsLeft = 0
    local lh = rig:FindFirstChild("LeftHand")
    if lh then
        for i = 1, 7 do
            local b = lh:FindFirstChild("Blade_" .. i)
            if b and b:GetAttribute("Broken") == nil then
                segmentsLeft += 1
            end
        end
    end

    return cassettesLeft, segmentsLeft
end

local function getSpearStatus()
    local spears = character:GetAttribute("Spears") or 0
    return spears
end

local function isUsingSpears()
    return player:GetAttribute("Weapon") == "Spears"
end

local spearSlot = 8

local lastSpearFiredTime = 0
local SPEAR_COOLDOWN = 1 -- seconds between each spear fire, adjust as needed

local function spearAttackTitan(nape, titanRoot, isRaidBoss)
    local now = tick()
    if now - lastSpearFiredTime < SPEAR_COOLDOWN then return end
    lastSpearFiredTime = now

    local fired = GET:InvokeServer("Spears", "S_Fire", tostring(spearSlot))
    if not fired then return end

    task.spawn(function()
        local explodeCount = isRaidBoss and 5 or 1

        -- Always hit the main target
        for i = 1, explodeCount do
            POST:FireServer("Spears", "S_Explode", nape.Position)
        end

        -- Multi hit: also explode at other titans' napes
        if State.multiHitEnabled then
            local titans = workspace:FindFirstChild("Titans")
            if titans then
                local count = 0
                for _, titan in ipairs(titans:GetChildren()) do
                    if count >= State.multiHitCount then break end
                    local hum = titan:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local hb = titan:FindFirstChild("Hitboxes", true)
                        local otherNape = hb and hb:FindFirstChild("Hit", true) and hb.Hit:FindFirstChild("Nape")
                        if otherNape and otherNape ~= nape then
                            local otherHrp = titan:FindFirstChild("HumanoidRootPart")
                            local dist = otherHrp and (otherHrp.Position - rootPart.Position).Magnitude or math.huge
                            if dist <= 500 then
                                for i = 1, explodeCount do
                                    POST:FireServer("Spears", "S_Explode", otherNape.Position)
                                end
                                count += 1
                            end
                        end
                    end
                end
            end
        end
    end)

    spearSlot = spearSlot - 1
    if spearSlot < 1 then spearSlot = 8 end
end

-- ==================== FARM HELPERS ====================
local function getClosestNape()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil, nil end
    local bestTitan, bestNape, bestDist = nil, nil, math.huge
    for _, titan in ipairs(titans:GetChildren()) do
        local hrp = titan:FindFirstChild("HumanoidRootPart")
        local hum = titan:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local hb   = titan:FindFirstChild("Hitboxes", true)
            local nape = hb and hb:FindFirstChild("Hit", true) and hb.Hit:FindFirstChild("Nape")
            if nape then
                local dist = (hrp.Position - rootPart.Position).Magnitude
                if dist < bestDist then
                    bestDist  = dist
                    bestTitan = titan
                    bestNape  = nape
                end
            end
        end
    end
    return bestTitan, bestNape
end

local function countLiveTitans()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return 0 end
    local count = 0
    for _, titan in ipairs(titans:GetChildren()) do
        local hum = titan:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then count += 1 end
    end
    return count
end

-- ==================== MAIN FARM ====================

local function stopLobbyTimer()
    if State.lobbyTimerConnection then
        State.lobbyTimerConnection:Disconnect()
        State.lobbyTimerConnection = nil
    end
end

local function stopAutoAttack()
    State.stopRequested = true
    State.farmActive    = false
    currentTarget       = nil
    ReloadState         = "idle"
    debugPrint("[LixHub] Auto farm stopped")

    if State.attackConnection then
        State.attackConnection:Disconnect()
        State.attackConnection = nil
    end

    removeBodyMovers()
    disableSync()
    stopLobbyTimer()
end

local function teleportToLobby()
    Util.notify("Failsafe", "Time limit reached, teleporting to lobby", 5, "corner-down-left")
    game:GetService("TeleportService"):Teleport(14916516914, player)
end

local function resetLobbyTimer()
    State.farmStartTime = tick()
end

local function startLobbyTimer()
    if State.lobbyTimerConnection then
        State.lobbyTimerConnection:Disconnect()
    end
    State.farmStartTime = tick()
    debugPrint("Failsafe timer started.")
    State.lobbyTimerConnection = RunService.Heartbeat:Connect(function()
        if not State.returnToLobbyEnabled or not State.farmActive then return end
        if (tick() - State.farmStartTime) >= (State.returnToLobbyMinutes * 60) then
            teleportToLobby()
            if State.lobbyTimerConnection then
                State.lobbyTimerConnection:Disconnect()
                State.lobbyTimerConnection = nil
            end
        end
    end)
end

local function findRefillPoint()
    local function searchIn(parent)
        if not parent then return nil end
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA("Model") and v.Name == "GasTanks" then
                local refill = v:FindFirstChild("Refill")
                if refill then return refill end
            end
        end
        return nil
    end

    return searchIn(workspace.Unclimbable) or searchIn(workspace)
end

local function findWavesRefillPoint()
    local tanks = workspace.Unclimbable
        and workspace.Unclimbable.Objective
        and workspace.Unclimbable.Objective.Waves
        and workspace.Unclimbable.Objective.Waves.GasTanks
    return tanks and tanks:FindFirstChild("Refill")
end

local function startAutoAttack()
    if isInLobby() then return end
        if player:GetAttribute("Cutscene") == true then
        repeat task.wait(0.1) until player:GetAttribute("Cutscene") ~= true or State.stopRequested
        if State.stopRequested then return end
    end
    if State.attackConnection then
        State.attackConnection:Disconnect()
        State.attackConnection = nil
    end

    State.stopRequested = false
    State.farmActive    = true
    debugPrint("[LixHub] Auto farm starting...")
    disableCollision()
    local _hum = character:FindFirstChildOfClass("Humanoid")
    if _hum then _hum.PlatformStand = true; _hum.AutoRotate = false end
    enableSync()

    if State.waitBeforeFarming and State.waitFarmSeconds > 0 then
        local titan = getClosestNape()
        if titan then
            local titanRoot = titan:FindFirstChild("HumanoidRootPart")
            if titanRoot then
                local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
                ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))
                State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
            end
        end
        Util.notify("Auto Farm", "Waiting " .. State.waitFarmSeconds .. "s before farming...", State.waitFarmSeconds, "cog")
        task.wait(State.waitFarmSeconds)
        if State.stopRequested then return end
    end

    local lastTitanWaiting = false
    local lastTitanHandled = false
    local tickAccum        = 0

    State.attackConnection = RunService.Heartbeat:Connect(function(dt)
        if State.stopRequested then
            if State.attackConnection then
                State.attackConnection:Disconnect()
                State.attackConnection = nil
            end
            return
        end

        if isUsingSpears() then
            local spearCount = getSpearStatus()
            if spearCount <= 0 and ReloadState == "idle" then
                ReloadState = "refilling"
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait(0.5)
                    until (character:GetAttribute("Spears") or 0) > 0 or ReloadState ~= "refilling"
                    ReloadState = "idle"
                end)
                return
            end
            if ReloadState ~= "idle" then return end
        else
            local cassettesLeft, segmentsLeft = getBladeStatus()

            if segmentsLeft <= 0 and cassettesLeft > 0 and ReloadState == "idle" then
                ReloadState = "swapping"
                debugPrint("[LixHub] Farm: Blade broken, swapping cassette —", cassettesLeft, "left")
                task.spawn(function()
                    local result
                    repeat
                        result = GET:InvokeServer("Blades", "Reload")
                        task.wait()
                        local c, s = getBladeStatus()
                        if s > 0 then break end
                    until result == true or ReloadState ~= "swapping"
                    debugPrint("[LixHub] Farm: Blade swap confirmed —", tostring(result))
                    ReloadState = "idle"
                end)
                return
            end

            if segmentsLeft <= 0 and cassettesLeft <= 0 and ReloadState == "idle" then
                ReloadState = "refilling"
                debugPrint("[LixHub] Farm: Out of cassettes — refilling")
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait()
                        local c, _ = getBladeStatus()
                        if c > 0 then break end
                    until ReloadState ~= "refilling"
                    repeat task.wait() until (select(2, getBladeStatus())) > 0 or ReloadState ~= "refilling"
                    debugPrint("[LixHub] Farm: Refill done")
                    ReloadState = "idle"
                end)
                return
            end

            if ReloadState ~= "idle" then return end
        end

        if lastTitanWaiting then return end
        tickAccum = tickAccum + dt
        if tickAccum < State.attackInterval then return end
        tickAccum = 0

        if currentTarget then
            local hum = currentTarget:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then
                currentTarget = nil
            end
        end

        if not currentTarget then
            local t, _ = getClosestNape()
            if not t then return end
            currentTarget = t
        end

        local titan = currentTarget
        local titanRoot = titan:FindFirstChild("HumanoidRootPart")
        if not titanRoot then currentTarget = nil return end
        local hb = titan:FindFirstChild("Hitboxes", true)
        local nape = hb and hb.Hit and hb.Hit:FindFirstChild("Nape")
        if not nape then return end

        local liveCount = countLiveTitans()

        if liveCount == 1 and State.waitLastTitanSeconds > 0 and not lastTitanHandled then
            lastTitanHandled = true
            lastTitanWaiting = true
            local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
            ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))
            State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
            Util.notify("Auto Farm", "Waiting " .. State.waitLastTitanSeconds .. "s before killing last titan...", State.waitLastTitanSeconds, "cog")
            task.delay(State.waitLastTitanSeconds, function()
                if not State.stopRequested then
                    lastTitanWaiting = false
                end
            end)
            return
        end

        if liveCount == 0 then
            stopAutoAttack()
            return
        end

        if liveCount > 1 then lastTitanHandled = false end

        State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
        local targetPos      = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
        ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))

        State.inHook = true
        local actualPos = rootPart.Position
        State.inHook = false

        local horizontalDist = Vector2.new(actualPos.X - titanRoot.Position.X, actualPos.Z - titanRoot.Position.Z).Magnitude
        if horizontalDist > 150 then return end

            if isUsingSpears() then
            spearAttackTitan(nape, titanRoot)
            else
            POST:FireServer("Attacks", "Slash", true)
            local damage = 670 + math.random(55, 165)
            if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
            POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))

            if State.multiHitEnabled then
                local titans = workspace:FindFirstChild("Titans")
                if titans then
                    local count = 0
                    for _, otherTitan in ipairs(titans:GetChildren()) do
                        if count >= State.multiHitCount then break end
                        local hum = otherTitan:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            local hb2 = otherTitan:FindFirstChild("Hitboxes", true)
                            local otherNape = hb2 and hb2:FindFirstChild("Hit", true) and hb2.Hit:FindFirstChild("Nape")
                            if otherNape and otherNape ~= nape then
                                local otherHrp = otherTitan:FindFirstChild("HumanoidRootPart")
                                local dist = otherHrp and (otherHrp.Position - rootPart.Position).Magnitude or math.huge
                                if dist <= 500 then
                                    local d2 = 670 + math.random(55, 165)
                                    if math.random(1, 8) == 1 then d2 = d2 * math.random(138, 148) / 100 end
                                    POST:FireServer("Hitboxes", "Register", otherNape, math.floor(d2))
                                    count += 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    if State.returnToLobbyEnabled then
        startLobbyTimer()
    end
end

-- ==================== AUTO ESCAPE ====================
local function setupEscapeListener(buttons)
    buttons:GetPropertyChangedSignal("Visible"):Connect(function()
        if buttons.Visible and State.escapeEnabled then
            task.wait(0.05)
            POST:FireServer("Attacks", "Slash_Escape")
        end
    end)
end

local function setupAutoEscape()
    local function findButtons()
        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            local b = gui:FindFirstChild("Buttons", true)
            if b then return b end
        end
    end
    local buttons = findButtons()
    if buttons then setupEscapeListener(buttons); return end
    task.delay(5, function()
        buttons = findButtons()
        if buttons then setupEscapeListener(buttons) end
    end)
end

-- ==================== GAME END ====================

local function buildPerkRarities()
    local ok, PerkData = pcall(require, game:GetService("ReplicatedStorage").Modules.Storage.Perks)
    if not ok or type(PerkData) ~= "table" then
        warn("[LixHub] Failed to require Perks module:", PerkData)
        return
    end

    for _, rarity in ipairs({"Common", "Rare", "Epic", "Legendary", "Mythic"}) do
        local tier = PerkData[rarity]
        if tier then
            for perkName in pairs(tier) do
                PERK_RARITIES[perkName] = rarity
            end
        end
    end
end

local function buildSkills()
    local ok, SkillModule = pcall(require, ReplicatedStorage.Modules.Storage.Skill)
    if not ok or type(SkillModule) ~= "table" then
        warn("[LixHub] Failed to require Skill module:", SkillModule)
        return
    end
    for skillId, info in pairs(SkillModule.Info) do
        skillInfoMap[skillId] = info
    end
end

local function buildItemRarities()
    local ok, ItemData = pcall(require, game:GetService("ReplicatedStorage").Modules.Storage.Items)
    if not ok or type(ItemData) ~= "table" then
        warn("[LixHub] Failed to require Items module:", ItemData)
        return
    end
    for itemName, itemInfo in pairs(ItemData) do
        if type(itemInfo) == "table" and itemInfo.Rarity then
            ITEM_RARITIES[itemName] = itemInfo.Rarity
        end
    end
end

buildItemRarities()
buildPerkRarities()
if not isInLobby() and not isInMainMenu() then
buildSkills()
end

local function sendWebhook(roundData, playerData)
    if not State.webhookUrl then return end

    local r   = roundData
    local r2  = playerData

    local completed  = r.Completed == true
    local embedColor = completed and 0x57F287 or 0xED4245
    local resultText = completed and "Victory" or "Defeat"

    local missionType  = workspace:GetAttribute("Type")       or "Unknown"
    local objective    = workspace:GetAttribute("Objective")  or "Unknown"
    local difficulty   = workspace:GetAttribute("Difficulty") or "Unknown"

    local wavesCompleted = 0
        if objective == "Waves" then
            local objFolder = ReplicatedStorage:FindFirstChild("Objectives")
            if objFolder then
                local clearance = objFolder:FindFirstChild("Clearance")
                wavesCompleted = clearance and clearance.Value or 0
            end
        end

    local titleText    = string.format("Stage %s! - %d Run(s)", completed and "Completed" or "Failed", State.sessionRuns or 1)
    local subtitleText = string.format("%s - %s (%s) - %s", missionType, objective, difficulty, resultText)

    local wsSeconds = workspace:GetAttribute("Seconds") or 0
    local duration  = string.format("%02d:%02d", math.floor(wsSeconds / 60), wsSeconds % 60)

    local stats       = r.Stats       or {}
    local obtained    = r.Obtained    or {}
    local currency    = r2 and r2.Currency    or {}
    local progression = r2 and r2.Progression or {}

    local isShadowBanned = false
    pcall(function()
        local d = GET:InvokeServer("Functions", "Settings", "Blur", "Off")
        if d and d.Disabled == "Delayed Ban" then
            isShadowBanned = true
        end
    end)

    local streak = player:GetAttribute("Streak") or 0

    local statsText = string.format(
        "Titans Killed: %d\nDamage Dealt: %d\nCritical Hits: %d\nBoss Damage: %d\nLevel: %d%s\nStreak: %d\nShadow Banned: %s",
        stats.Kills        or 0,
        stats.Damage       or 0,
        stats.Crits        or 0,
        stats.Boss_Damage  or 0,
        progression.Level  or 0,
        (progression.Prestige or 0) > 0 and string.format(" (Prestige: %d)", progression.Prestige) or "",
        streak,
        isShadowBanned and "true" or "false"
    )

    local function formatBoostTime(secs)
    if not secs or secs <= 0 then return "00:00" end
    return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
    end

    local xpSecs   = (player.Boosts:FindFirstChild("XP")   and player.Boosts.XP.Value)   or 0
    local goldSecs = (player.Boosts:FindFirstChild("Gold") and player.Boosts.Gold.Value) or 0
    local luckSecs = (player.Boosts:FindFirstChild("Luck") and player.Boosts.Luck.Value) or 0

    local potionsText = string.format(
        "%s %s\n%s %s\n%s %s",
        "<:aotr_xpboost:1505209472547815535>",   formatBoostTime(xpSecs),
        "<:aotr_goldboost:1505209405648404480>", formatBoostTime(goldSecs),
        "<:aotr_luckboost:1505209436384530594>", formatBoostTime(luckSecs)
    )

    local rewardLines = {}
    local function addReward(label, amount, total)
        if (amount or 0) > 0 then
            table.insert(rewardLines, string.format("+%d %s [%d]", amount, label, total))
        end
    end
    if (obtained.XP or 0) > 0 then
        table.insert(rewardLines, string.format("+%d XP", obtained.XP))
    end
    addReward("Gold",  obtained.Gold,  currency.Gold  or 0)
    addReward("Canes", obtained.Canes, currency.Canes or 0)
    addReward("Gems",  obtained.Gems,  currency.Gems  or 0)
    local mythicPerks = {}
    for _, perk in ipairs(obtained.Perks or {}) do
        local rarity = PERK_RARITIES[perk]
        local line = rarity and string.format("+1 %s Perk [%s]", perk, rarity) or "+1 " .. perk .. " Perk"
        table.insert(rewardLines, line)
        if rarity == "Mythic" then
            table.insert(mythicPerks, perk)
        end
    end
    local specialDrops = {}
    for _, drop in ipairs(obtained.Drops or {}) do
        local dropName = tostring(drop)
        local rarity = ITEM_RARITIES[dropName]
        local line = rarity and string.format("+1 %s [%s]", dropName, rarity) or "+1 " .. dropName
        table.insert(rewardLines, line)
        if rarity == "Mythic" then
            table.insert(specialDrops, dropName)
        end
    end
    for _, chest in ipairs(obtained.Chests or {}) do
        table.insert(rewardLines, "+1 " .. tostring(chest) .. " Chest")
    end
    local rewardsText = #rewardLines > 0 and table.concat(rewardLines, "\n") or "None"

    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local pingParts = {}
    if #specialDrops > 0 then table.insert(pingParts, "Special drop!") end
    if #mythicPerks > 0 then table.insert(pingParts, "Mythic perk! " .. table.concat(mythicPerks, ", ")) end

    local data = {
        username = "LixHub",
        content = (#pingParts > 0 and State.discordUserId) and string.format("<@%s> %s", State.discordUserId, table.concat(pingParts, " | ")) or nil,
        embeds = {{
            title       = titleText,
            description = subtitleText,
            color       = embedColor,
            fields      = {
                { name = "Player",     value = "||" .. player.Name .. "||", inline = true },
                { name = "Duration",   value = duration,                     inline = true },
            },
            footer    = { text = "LixHub • discord.gg/cYKnXE2Nf8" },
            timestamp = timestamp,
        }}
    }

    if objective == "Waves" then
        table.insert(data.embeds[1].fields, { name = "Waves Completed", value = tostring(wavesCompleted), inline = true })
    end

    table.insert(data.embeds[1].fields, { name = "\u{200B}", value = "\u{200B}", inline = true })
    table.insert(data.embeds[1].fields, { name = "Game Stats", value = statsText, inline = false })
    table.insert(data.embeds[1].fields, { name = "Active Potions", value = potionsText, inline = false })
    table.insert(data.embeds[1].fields, { name = "Rewards", value = rewardsText, inline = false })

    local HttpService = game:GetService("HttpService")
    local payload     = HttpService:JSONEncode(data)
    local requestFunc = syn and syn.request or request or http_request or (fluxus and fluxus.request) or getgenv().request
    if not requestFunc then warn("No HTTP function found!") return end

    pcall(function()
        requestFunc({
            Url     = State.webhookUrl,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = payload,
        })
    end)
end

local roundEndDebounce = false

local function retryViaNavigation()
    local retry = player.PlayerGui.Interface.Rewards.Main.Info.Main.Buttons:FindFirstChild("Retry")
    if not retry then 
        debugPrint("[LixHub] Retry button not found")
        return false
    end
    GuiService.SelectedObject = retry
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    debugPrint("[LixHub] Fired retry via UI navigation")
    return true
end

local function leaveViaNavigation()
    local leaveBtn = player.PlayerGui.Interface.Rewards.Main.Info.Main.Buttons:FindFirstChild("Leave_2")
    if not leaveBtn then 
        debugPrint("[LixHub] Leave button not found")
        return false
    end
    GuiService.SelectedObject = leaveBtn
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    debugPrint("[LixHub] Fired leave via UI navigation")
    return true
end

local function updateQueuedCounter()
    if not queue_on_teleport then return end
    local queuedScript = string.format([[
        getgenv().__LIXHUB_RUNS = %d
    ]], State.sessionRuns)
    queue_on_teleport(queuedScript)
end

local function onRoundEnd(encoded)
    if roundEndDebounce then return end
    roundEndDebounce = true
    task.spawn(function()
        local ok, err = pcall(function()
            State.sessionRuns += 1
            getgenv().__LIXHUB_RUNS = State.sessionRuns
            updateQueuedCounter()
            local forceLobby = State.returnToLobbyGamesEnabled and State.sessionRuns >= State.returnToLobbyGames

            -- Retry decoding up to 10 times with 1s delay
            local roundData, playerData
            local maxAttempts = 10
            for attempt = 1, maxAttempts do
                if encoded then
                    local ok2, decoded = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(encoded)
                    end)
                    if ok2 and decoded and decoded.round and decoded.player then
                        roundData  = decoded.round
                        playerData = decoded.player
                        debugPrint("[LixHub] Round data received on attempt", attempt)
                        break
                    else
                        warn("[LixHub] Round data not ready, attempt", attempt, "of", maxAttempts)
                    end
                end
                if attempt < maxAttempts then
                    task.wait(1)
                end
            end

            if not roundData then
                warn("[LixHub] Round data never arrived after", maxAttempts, "attempts — skipping webhook")
            end

            if State.webhookEnabled and State.webhookUrl and roundData then
                sendWebhook(roundData, playerData)
            else
                warn("[LixHub] Webhook skipped — enabled:", State.webhookEnabled, "url:", State.webhookUrl ~= nil, "data:", roundData ~= nil)
            end

            debugPrint("[LixHub] Round ended — processing results")
            resetLobbyTimer()

            task.wait(5)
            if forceLobby then
                Util.notify("Auto Farm", "Game limit reached, returning to lobby...", 3)
                while true do
                    leaveViaNavigation()
                    task.wait(3)
                end
            elseif State.autoRetry then
                Util.notify("Auto Farm", "Retrying...", 3, "cog")
                while State.autoRetry do
                    debugPrint("[LixHub] Attempting retry via UI navigation...")
                    retryViaNavigation()
                    task.wait(3)
                end
            elseif State.autoLobby then
                Util.notify("Auto Farm", "Returning to lobby...", 3)
                while State.autoLobby do
                    debugPrint("[LixHub] Attempting leave via UI navigation...")
                    leaveViaNavigation()
                    task.wait(3)
                end
            end
        end)
        if not ok then
            warn("onRoundEnd error:", err)
        end
        task.wait(5)
        roundEndDebounce = false
    end)
end

-- Create bindable BEFORE running on actors
if not isInLobby() and not isInMainMenu() then
    local bridge = Instance.new("BindableEvent")
    bridge.Parent = game:GetService("ReplicatedStorage")
    bridge.Name = "__LixBridge"
    bridge.Event:Connect(onRoundEnd)
end

if not isInLobby() and not isInMainMenu() then
    for _, actor in getactors() do
        run_on_actor(actor, [[
            local GET = game:GetService("ReplicatedStorage").Assets.Remotes.GET
            local bridge = game:GetService("ReplicatedStorage"):WaitForChild("__LixBridge", 5)

            local mtHook; mtHook = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()

                if rawequal(self, GET) and method == "InvokeServer" then
                    local args = table.pack(...)
                    local result = table.pack(mtHook(self, ...))

                    if args[1] == "S_Rewards" and args[2] == "Get" then
                        local r  = result[1]
                        local r2 = result[2]
                        if bridge and type(r) == "table" and next(r) ~= nil then
                            local HttpService = game:GetService("HttpService")
                            local ok, encoded = pcall(function()
                                return HttpService:JSONEncode({round = r, player = r2})
                            end)
                            if ok then
                                bridge:Fire(encoded)
                            end
                        end
                    end

                    return table.unpack(result, 1, result.n)
                end

                return mtHook(self, ...)
            end)
        ]])
    end
end

function Raids.getNape(titan)
    local hb = titan:FindFirstChild("Hitboxes", true)
    if not hb then return nil end
    local hit = hb:FindFirstChild("Hit", true)
    if not hit then return nil end
    return hit:FindFirstChild("Nape")
end

function Raids.getVulnerableSpot(titan)
    local hb = titan:FindFirstChild("Hitboxes", true)
    if not hb then return nil end
    local hit = hb:FindFirstChild("Hit", true)
    if not hit then return nil end
    for _, part in ipairs(hit:GetChildren()) do
        if part:GetAttribute("Vulnerable") ~= nil then
            return part
        end
    end
    return nil
end

function Raids.registerHit(nape, vulnSpot)
    local damage = 670 + math.random(55, 165)
    if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
    POST:FireServer("Attacks", "Slash", true)
    POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))
end

function Raids.registerHitVuln(vulnSpot)
    task.spawn(function()
        POST:FireServer("Attacks", "Slash", true)
        for i = 1, 5 do
            local damage = 400 + math.random(50, 150)
            if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
            POST:FireServer("Hitboxes", "Register", vulnSpot, math.floor(damage))
        end
    end)
end

function Raids.getObjectiveValue(name)
    local obj = ReplicatedStorage:FindFirstChild("Objectives")
    if not obj then return 0 end
    local v = obj:FindFirstChild(name)
    return v and v.Value or 0
end

function Raids.getClosestTitanToEren()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end
    
    local collider = workspace.Unclimbable
        and workspace.Unclimbable.Objective
        and workspace.Unclimbable.Objective.Defend_Eren
        and workspace.Unclimbable.Objective.Defend_Eren:FindFirstChild("Collider")
    
    if not collider then
        debugPrint("[LixHub] Raids: Collider not found, falling back to player position")
    end
    
    local anchor = collider and collider.Position or rootPart.Position
    local bestTitan, bestDist = nil, math.huge
    
    for _, titan in ipairs(titans:GetChildren()) do
        local hrp = titan:FindFirstChild("HumanoidRootPart")
        local hum = titan:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local nape = Raids.getNape(titan)
            if nape then
                local dist = (hrp.Position - anchor).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestTitan = titan
                end
            end
        end
    end
    return bestTitan
end

function Raids.getClosestTitanToBoat()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end
    
    local boat = workspace.Unclimbable
        and workspace.Unclimbable.Objective
        and workspace.Unclimbable.Objective:FindFirstChild("Boat2")
    
    local anchor
    if boat then
        local part = boat.PrimaryPart or boat:FindFirstChildWhichIsA("BasePart")
        anchor = part and part.Position or rootPart.Position
    else
        anchor = rootPart.Position
    end

    local bestTitan, bestDist = nil, math.huge
    for _, titan in ipairs(titans:GetChildren()) do
        local hrp = titan:FindFirstChild("HumanoidRootPart")
        local hum = titan:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 and titan.Name ~= "Armored_Titan" then
            local nape = Raids.getNape(titan)
            if nape then
                local dist = (hrp.Position - anchor).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestTitan = titan
                end
            end
        end
    end
    return bestTitan
end

function Raids.getAttackTitan()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end
    local at = titans:FindFirstChild("Attack_Titan")
    if not at then return nil end
    local hum = at:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    return at
end

function Raids.getArmoredTitan()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end
    local at = titans:FindFirstChild("Armored_Titan")
    if not at then return nil end
    local hum = at:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    return at
end

local function clickButton(btn)
    GuiService.SelectedObject = btn
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
end

local function waitForFinishVisible(timeout)
    local chests = player.PlayerGui.Interface.Chests
    local start = tick()
    -- first wait for it to go invisible (animation started)
    repeat task.wait(0.2) until
        not (chests:FindFirstChild("Finish") and chests.Finish.Visible) or
        tick() - start > (timeout or 15)
    -- then wait for it to come back (animation finished)
    repeat task.wait(0.2) until
        (chests:FindFirstChild("Finish") and chests.Finish.Visible) or
        tick() - start > (timeout or 15)
end

function Raids.openChests()
    local chests = player.PlayerGui.Interface:FindFirstChild("Chests")
    if not chests or not chests.Visible then return end

    if Raids.State.autoOpenChests then
        local freeBtn = chests:FindFirstChild("Free")
        if freeBtn and freeBtn.Visible then
            debugPrint("[LixHub] Raids: Opening free chest")
            clickButton(freeBtn)
            -- wait for finish button to reappear (animation done)
            waitForFinishVisible()
        end
    end

    if Raids.State.autoOpenEmperorChests then
        local premiumBtn = chests:FindFirstChild("Premium")
        if premiumBtn and premiumBtn.Visible then
            debugPrint("[LixHub] Raids: Opening emperor chest")
            clickButton(premiumBtn)
            waitForFinishVisible()
        end
    end
end

function Raids.clickFinish()
    pcall(function()
        local finishBtn = player.PlayerGui.Interface.Chests:FindFirstChild("Finish")
        GuiService.SelectedObject = finishBtn
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        debugPrint("[LixHub] Raids: Finish clicked")
    end)
end

function Raids.handleTitan(titan, useVulnerable, isRaidBoss)
    local titanRoot = titan:FindFirstChild("HumanoidRootPart")
    if not titanRoot then return end
    local nape = Raids.getNape(titan)
    if not nape then return end

    State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
    local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
    ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))

    State.inHook = true
    local actualPos = rootPart.Position
    State.inHook = false

    local horizontalDist = Vector2.new(actualPos.X - titanRoot.Position.X, actualPos.Z - titanRoot.Position.Z).Magnitude
    if horizontalDist > 50 then return end

    if isUsingSpears() then
        spearAttackTitan(nape, titanRoot, isRaidBoss)
        return
    end

        if useVulnerable then
        local vulnSpot = Raids.getVulnerableSpot(titan)
        if vulnSpot then
            Raids.registerHitVuln(vulnSpot)
        else
            -- boss but no vuln spot yet, fire 5 fast
            task.spawn(function()
                POST:FireServer("Attacks", "Slash", true)
                for i = 1, 5 do
                    local damage = 670 + math.random(55, 165)
                    if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
                    POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))
                end
            end)
        end
    else
        -- defend phase: 1 register on main target + multi hit on nearby titans
        POST:FireServer("Attacks", "Slash", true)
        local damage = 670 + math.random(55, 165)
        if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
        POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))

        if State.multiHitEnabled then
            local titans = workspace:FindFirstChild("Titans")
            if titans then
                local count = 0
                for _, otherTitan in ipairs(titans:GetChildren()) do
                    if count >= State.multiHitCount then break end
                    local hum = otherTitan:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local hb2 = otherTitan:FindFirstChild("Hitboxes", true)
                        local otherNape = hb2 and hb2:FindFirstChild("Hit", true) and hb2.Hit:FindFirstChild("Nape")
                        if otherNape and otherNape ~= nape then
                            local otherHrp = otherTitan:FindFirstChild("HumanoidRootPart")
                            local dist = otherHrp and (otherHrp.Position - rootPart.Position).Magnitude or math.huge
                            if dist <= 500 then
                                local d2 = 670 + math.random(55, 165)
                                if math.random(1, 8) == 1 then d2 = d2 * math.random(138, 148) / 100 end
                                POST:FireServer("Hitboxes", "Register", otherNape, math.floor(d2))
                                count += 1
                            end
                        end
                    end
                end
            end
        end
    end
end

function Raids.stop()
    Raids.State.stopRequested = true
    Raids.State.active        = false
    Raids.State.phase         = "defend"
    RaidReloadState           = "idle"
    if Raids.State.connection then
        Raids.State.connection:Disconnect()
        Raids.State.connection = nil
    end
    removeBodyMovers()
    disableSync()
    debugPrint("[LixHub] Raids: Stopped")
end

local function waitBeforeKillingBoss(titanRef, stopCheck)
    if not State.waitBeforeRaidBoss or State.waitRaidBossSeconds <= 0 then return end
    Util.notify("Auto Farm Raids", "Waiting " .. State.waitRaidBossSeconds .. "s before killing raid boss...", State.waitRaidBossSeconds, "clock")
    local elapsed = 0
    while elapsed < State.waitRaidBossSeconds do
        task.wait(0.5)
        elapsed += 0.5
        if stopCheck and stopCheck() then return end
    end
end

function Raids.start()
    if isInLobby() then return end

    local objective = workspace:GetAttribute("Objective")
    debugPrint("[LixHub] Raids: Detected objective —", objective)

    if objective == "Attack Titan" then
        Raids.startEren()
    elseif objective == "Armored Titan" then
        Raids.startArmored()
    elseif objective == "Female Titan" then
        Raids.startFemale() -- no cutscene wait, QTE happens during cutscene
    elseif objective == "Colossal Titan" then
        Raids.startColossal()
    else
        Util.notify("Auto Farm Raids", "Unknown raid objective: " .. tostring(objective), 5, "alert-triangle")
        debugPrint("[LixHub] Raids: Unknown objective —", objective)
    end
end

function Raids.startEren()
    if isInLobby() then return end
        if player:GetAttribute("Cutscene") == true then
        repeat task.wait(0.1) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
        if Raids.State.stopRequested then return end
    end
    if Raids.State.connection then
        Raids.State.connection:Disconnect()
        Raids.State.connection = nil
    end

    Raids.State.stopRequested = false
    Raids.State.active        = true
    Raids.State.phase         = "defend"
    local bossWaitDone = false
    local bossWaitReady   = false
    debugPrint("[LixHub] Raids: Starting — Phase 1: Defend Eren")

    disableCollision()
    local _hum = character:FindFirstChildOfClass("Humanoid")
    if _hum then _hum.PlatformStand = true; _hum.AutoRotate = false end
    enableSync()

    local tickAccum = 0
    local chestsDone = false

    Raids.State.connection = RunService.Heartbeat:Connect(function(dt)
        if Raids.State.stopRequested then
            if Raids.State.connection then
                Raids.State.connection:Disconnect()
                Raids.State.connection = nil
            end
            return
        end
        if isUsingSpears() then
            local spearCount = getSpearStatus()
            if spearCount <= 0 and RaidReloadState == "idle" then
                RaidReloadState = "refilling"
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait(0.5)
                    until (character:GetAttribute("Spears") or 0) > 0 or RaidReloadState ~= "refilling"
                    RaidReloadState = "idle"
                end)
                return
            end
            if RaidReloadState ~= "idle" then return end
        else
            local cassettesLeft, segmentsLeft = getBladeStatus()

            if segmentsLeft <= 0 and cassettesLeft > 0 and RaidReloadState == "idle" then
                RaidReloadState = "swapping"
                debugPrint("[LixHub] Raids: Blade broken, swapping cassette —", cassettesLeft, "left")
                task.spawn(function()
                    local result
                    repeat
                        result = GET:InvokeServer("Blades", "Reload")
                        task.wait()
                        local c, s = getBladeStatus()
                        if s > 0 then break end
                    until result == true or RaidReloadState ~= "swapping"
                    debugPrint("[LixHub] Raids: Blade swap confirmed —", tostring(result))
                    RaidReloadState = "idle"
                end)
                return
            end

            if segmentsLeft <= 0 and cassettesLeft <= 0 and RaidReloadState == "idle" then
                RaidReloadState = "refilling"
                debugPrint("[LixHub] Raids: Out of cassettes — refilling")
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait()
                        local c, _ = getBladeStatus()
                        if c > 0 then break end
                    until RaidReloadState ~= "refilling"
                    repeat task.wait() until (select(2, getBladeStatus())) > 0 or RaidReloadState ~= "refilling"
                    debugPrint("[LixHub] Raids: Refill done")
                    RaidReloadState = "idle"
                end)
                return
            end

            if RaidReloadState ~= "idle" then return end
        end
        if Raids.State.phase == "cutscene" then return end

        tickAccum = tickAccum + dt
        if tickAccum < State.attackInterval then return end
        tickAccum = 0

        -- ===== PHASE 1: DEFEND EREN =====
-- ===== PHASE 1: DEFEND EREN =====
        if Raids.State.phase == "defend" then
            if Raids.getObjectiveValue("Defend_Eren") >= 1 then
                Raids.State.phase = "cutscene"
                debugPrint("[LixHub] Raids: Phase 1 done — waiting for cutscene...")
                
                -- stop movement so server can reposition us
                removeBodyMovers()
                disableSync()
                
                task.spawn(function()
                    -- wait for cutscene to start
                    repeat task.wait(0.3) until player:GetAttribute("Cutscene") == true or Raids.State.stopRequested
                    -- wait for cutscene to finish
                    repeat task.wait(0.3) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
                    
                    if not Raids.State.stopRequested then
                        -- re-enable movement for phase 2
                        disableCollision()
                        local hum = character:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand = true; hum.AutoRotate = false end
                        enableSync()
                        
                        Raids.State.phase = "defeat"
                        debugPrint("[LixHub] Raids: Cutscene done — Phase 2: Defeat Attack Titan")
                    end
                end)
                return
            end
            local titan = Raids.getClosestTitanToEren()
            if titan then
                Raids.handleTitan(titan, false)
            end

        -- ===== PHASE 2: DEFEAT ATTACK TITAN =====
        elseif Raids.State.phase == "defeat" then
            local titan = Raids.getAttackTitan()

            -- always move toward titan if he exists
            if titan then
                local titanRoot = titan:FindFirstChild("HumanoidRootPart")
                if titanRoot then
                    State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
                    local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
                    ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))
                end
            end

            if not bossWaitDone then
                bossWaitDone = true
                task.spawn(function()
                    waitBeforeKillingBoss(titan, function() return Raids.State.stopRequested end)
                    bossWaitReady = true
                end)
                return
            end
            if not bossWaitReady then return end

            -- check objective first so chest collection never gets skipped
            if Raids.getObjectiveValue("Defeat_Attack_Titan") >= 1 then
                if not chestsDone then
                    chestsDone = true
                    debugPrint("[LixHub] Raids: Attack Titan defeated — collecting chests")
                    task.spawn(function()
                        task.wait(5)
                        local start = tick()
                        repeat task.wait(0.3) until
                            (player.PlayerGui.Interface:FindFirstChild("Chests") and
                            player.PlayerGui.Interface.Chests.Visible) or
                            tick() - start > 20
                        Raids.openChests()
                        task.wait(3)
                        Raids.clickFinish()
                    end)
                end
                return
            end

            if not titan then return end
            if titan:GetAttribute("State") == "Roar" then return end
            if titan:GetAttribute("State") == "Berserk_Mode" then return end

            Raids.handleTitan(titan, true, true)
        end
    end)
end

function Raids.startArmored()
    if isInLobby() then return end
    if player:GetAttribute("Cutscene") == true then
        repeat task.wait(0.1) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
        if Raids.State.stopRequested then return end
    end
    if Raids.State.connection then
        Raids.State.connection:Disconnect()
        Raids.State.connection = nil
    end

    Raids.State.stopRequested = false
    Raids.State.active        = true
    Raids.State.phase         = "defend"
    debugPrint("[LixHub] Armored Raid: Starting — Phase 1: Defend Boats")

    disableCollision()
    local _hum = character:FindFirstChildOfClass("Humanoid")
    if _hum then _hum.PlatformStand = true; _hum.AutoRotate = false end
    enableSync()

    local tickAccum = 0
    local chestsDone = false
    local bossWaitDone  = false
    local bossWaitReady = false

    Raids.State.connection = RunService.Heartbeat:Connect(function(dt)
        if Raids.State.stopRequested then
            if Raids.State.connection then
                Raids.State.connection:Disconnect()
                Raids.State.connection = nil
            end
            return
        end

        if isUsingSpears() then
            local spearCount = getSpearStatus()
            if spearCount <= 0 and RaidReloadState == "idle" then
                RaidReloadState = "refilling"
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait(0.5)
                    until (character:GetAttribute("Spears") or 0) > 0 or RaidReloadState ~= "refilling"
                    RaidReloadState = "idle"
                end)
                return
            end
            if RaidReloadState ~= "idle" then return end
        else
            local cassettesLeft, segmentsLeft = getBladeStatus()

            if segmentsLeft <= 0 and cassettesLeft > 0 and RaidReloadState == "idle" then
                RaidReloadState = "swapping"
                debugPrint("[LixHub] Armored Raid: Blade broken, swapping cassette —", cassettesLeft, "left")
                task.spawn(function()
                    local result
                    repeat
                        result = GET:InvokeServer("Blades", "Reload")
                        task.wait()
                        local c, s = getBladeStatus()
                        if s > 0 then break end
                    until result == true or RaidReloadState ~= "swapping"
                    debugPrint("[LixHub] Armored Raid: Blade swap confirmed")
                    RaidReloadState = "idle"
                end)
                return
            end

            if segmentsLeft <= 0 and cassettesLeft <= 0 and RaidReloadState == "idle" then
                RaidReloadState = "refilling"
                debugPrint("[LixHub] Armored Raid: Out of cassettes — refilling")
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait()
                        local c, _ = getBladeStatus()
                        if c > 0 then break end
                    until RaidReloadState ~= "refilling"
                    repeat task.wait() until (select(2, getBladeStatus())) > 0 or RaidReloadState ~= "refilling"
                    debugPrint("[LixHub] Armored Raid: Refill done")
                    RaidReloadState = "idle"
                end)
                return
            end

            if RaidReloadState ~= "idle" then return end
        end
        if Raids.State.phase == "cutscene" then return end

        tickAccum = tickAccum + dt
        if tickAccum < State.attackInterval then return end
        tickAccum = 0

        if Raids.State.phase == "defend" then
            if Raids.getObjectiveValue("Defend_Boats") >= 1 then
                Raids.State.phase = "cutscene"
                removeBodyMovers()
                disableSync()
                task.spawn(function()
                    repeat task.wait(0.3) until player:GetAttribute("Cutscene") == true or Raids.State.stopRequested
                    repeat task.wait(0.3) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
                    if not Raids.State.stopRequested then
                        disableCollision()
                        local hum = character:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand = true; hum.AutoRotate = false end
                        enableSync()
                        Raids.State.phase = "defeat"
                    end
                end)
                return
            end

            local titan = Raids.getClosestTitanToBoat()
            if titan then Raids.handleTitan(titan, false) end

        elseif Raids.State.phase == "defeat" then
            local titan = Raids.getArmoredTitan()

            if titan then
                local titanRoot = titan:FindFirstChild("HumanoidRootPart")
                if titanRoot then
                    State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
                    local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
                    ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))
                end
            end

            if not bossWaitDone then
            bossWaitDone = true
            task.spawn(function()
                waitBeforeKillingBoss(titan, function() return Raids.State.stopRequested end)
                bossWaitReady = true
            end)
            return
        end
        if not bossWaitReady then return end

            if Raids.getObjectiveValue("Defeat_Armored_Titan") >= 1 then
                if not chestsDone then
                    chestsDone = true
                    task.spawn(function()
                        task.wait(5)
                        local start = tick()
                        repeat task.wait(0.3) until
                            (player.PlayerGui.Interface:FindFirstChild("Chests") and
                            player.PlayerGui.Interface.Chests.Visible) or
                            tick() - start > 20
                        Raids.openChests()
                        task.wait(3)
                        Raids.clickFinish()
                    end)
                end
                return
            end

            if not titan then return end
            if titan:GetAttribute("State") == "Roar" then return end

            Raids.handleTitan(titan, true, true)
        end
    end)
end

function Raids.startFemale()
    if isInLobby() then return end
    if player:GetAttribute("Cutscene") == true then
        repeat task.wait(0.1) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
        if Raids.State.stopRequested then return end
    end

    Raids.State.stopRequested = false
    Raids.State.active        = true
    Raids.State.phase         = "female_1"
    debugPrint("[LixHub] Female Raid: Starting — Phase 1: Defeat Female Titan")

    disableCollision()
    local _hum = character:FindFirstChildOfClass("Humanoid")
    if _hum then _hum.PlatformStand = true; _hum.AutoRotate = false end
    enableSync()

    local tickAccum = 0
    local chestsDone = false
    local bossWaitDone  = false
    local bossWaitReady = false

    local function handleCutsceneTransition(nextPhase, notifyMsg)
        Raids.State.phase = "cutscene"
        removeBodyMovers()
        disableSync()
        task.spawn(function()
            repeat task.wait(0.3) until player:GetAttribute("Cutscene") == true or Raids.State.stopRequested
            repeat task.wait(0.3) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
            if not Raids.State.stopRequested then
                disableCollision()
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true; hum.AutoRotate = false end
                enableSync()
                Raids.State.phase = nextPhase
                debugPrint("[LixHub] Female Raid: Cutscene done —", notifyMsg)
            end
        end)
    end

    local function getTitan(name)
        local titans = workspace:FindFirstChild("Titans")
        if not titans then return nil end
        local t = titans:FindFirstChild(name)
        if not t then return nil end
        local hum = t:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        return t
    end

    local function moveTo(titan)
        local titanRoot = titan:FindFirstChild("HumanoidRootPart")
        if not titanRoot then return end
        State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
        local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
        ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))
    end

local function attackTitan(titan, isRaidBoss)
    local titanRoot = titan:FindFirstChild("HumanoidRootPart")
    if not titanRoot then return end
    local nape = Raids.getNape(titan)
    if not nape then return end

    State.inHook = true
    local actualPos = rootPart.Position
    State.inHook = false

    local horizontalDist = Vector2.new(actualPos.X - titanRoot.Position.X, actualPos.Z - titanRoot.Position.Z).Magnitude
    if horizontalDist > 50 then return end

    if isUsingSpears() then
        spearAttackTitan(nape, titanRoot, isRaidBoss)
        return
    end

    local vulnSpot = Raids.getVulnerableSpot(titan)
    if vulnSpot then
        Raids.registerHitVuln(vulnSpot)
    else
        task.spawn(function()
            POST:FireServer("Attacks", "Slash", true)
            for i = 1, 5 do
                local damage = 670 + math.random(55, 165)
                if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
                POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))
            end
        end)
    end
end

    Raids.State.connection = RunService.Heartbeat:Connect(function(dt)
        if Raids.State.stopRequested then
            if Raids.State.connection then
                Raids.State.connection:Disconnect()
                Raids.State.connection = nil
            end
            return
        end

        if isUsingSpears() then
            local spearCount = getSpearStatus()
            if spearCount <= 0 and RaidReloadState == "idle" then
                RaidReloadState = "refilling"
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait(0.5)
                    until (character:GetAttribute("Spears") or 0) > 0 or RaidReloadState ~= "refilling"
                    RaidReloadState = "idle"
                end)
                return
            end
            if RaidReloadState ~= "idle" then return end
        else
            local cassettesLeft, segmentsLeft = getBladeStatus()

            if segmentsLeft <= 0 and cassettesLeft > 0 and RaidReloadState == "idle" then
                RaidReloadState = "swapping"
                task.spawn(function()
                    local result
                    repeat
                        result = GET:InvokeServer("Blades", "Reload")
                        task.wait()
                        local c, s = getBladeStatus()
                        if s > 0 then break end
                    until result == true or RaidReloadState ~= "swapping"
                    RaidReloadState = "idle"
                end)
                return
            end

            if segmentsLeft <= 0 and cassettesLeft <= 0 and RaidReloadState == "idle" then
                RaidReloadState = "refilling"
                task.spawn(function()
                    local refillPoint = findRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait()
                        local c, _ = getBladeStatus()
                        if c > 0 then break end
                    until RaidReloadState ~= "refilling"
                    repeat task.wait() until (select(2, getBladeStatus())) > 0 or RaidReloadState ~= "refilling"
                    RaidReloadState = "idle"
                end)
                return
            end

            if RaidReloadState ~= "idle" then return end
        end
        if Raids.State.phase == "cutscene" then return end

        tickAccum = tickAccum + dt
        if tickAccum < State.attackInterval then return end
        tickAccum = 0

        -- ===== PHASE 1: FEMALE TITAN =====
        if Raids.State.phase == "female_1" then
            local titan = getTitan("Female_Titan")
            if titan then moveTo(titan) end

            if titan and titan:GetAttribute("State") == "Roar" then return end

            -- mid HP cutscene triggers when Attack Titan appears
            if getTitan("Attack_Titan") ~= nil then
                debugPrint("[LixHub] Female Raid: Attack Titan appeared — waiting for cutscene")
                handleCutsceneTransition("attack_titan", "Phase 2: Defeat Attack Titan!")
                return
            end

            if not titan then return end
            attackTitan(titan, true)

        -- ===== PHASE 2: ATTACK TITAN =====
        elseif Raids.State.phase == "attack_titan" then
            local titan = getTitan("Attack_Titan")
            if titan then moveTo(titan) end

            if Raids.getObjectiveValue("Defeat_Attack_Titan") >= 1 then
                debugPrint("[LixHub] Female Raid: Attack Titan defeated — waiting for cutscene")
                handleCutsceneTransition("female_2", "Phase 3: Finish Female Titan!")
                return
            end

            if not titan then return end
            if titan:GetAttribute("State") == "Roar" then return end
            if titan:GetAttribute("State") == "Berserk_Mode" then return end
            attackTitan(titan, true)

        -- ===== PHASE 3: FINISH FEMALE TITAN =====
        elseif Raids.State.phase == "female_2" then
            local titan = getTitan("Female_Titan")
            if titan then moveTo(titan) end

                if not bossWaitDone then
                bossWaitDone = true
                task.spawn(function()
                    waitBeforeKillingBoss(titan, function() return Raids.State.stopRequested end)
                    bossWaitReady = true
                end)
                return
            end
            if not bossWaitReady then return end

            if Raids.getObjectiveValue("Defeat_Female_Titan") >= 1 then
                if not chestsDone then
                    chestsDone = true
                    debugPrint("[LixHub] Female Raid: Complete — collecting chests")
                    task.spawn(function()
                        task.wait(5)
                        local start = tick()
                        repeat task.wait(0.3) until
                            (player.PlayerGui.Interface:FindFirstChild("Chests") and
                            player.PlayerGui.Interface.Chests.Visible) or
                            tick() - start > 20
                        Raids.openChests()
                        task.wait(3)
                        Raids.clickFinish()
                    end)
                end
                return
            end

            if not titan then return end
            if titan:GetAttribute("State") == "Roar" then return end
            attackTitan(titan, true)
        end
    end)
end

-- ==================== AUTO UPGRADE GEAR ====================
local autoUpgradeConnection = nil

local function startAutoUpgrade()
    if autoUpgradeConnection then return end
    autoUpgradeConnection = task.spawn(function()
        while true do
            task.wait(2)
            if isInLobby() then
                pcall(function()
                    GET:InvokeServer("S_Equipment", "Upgrade", {
                        "Crit_Chance",
                        "Blade_Durability",
                        "ODM_Damage",
                        "Crit_Damage",
                        "ODM_Speed",
                        "ODM_Control",
                        "ODM_Range",
                        "ODM_Gas"
                    })
                end)
            end
        end
    end)
end

local function stopAutoUpgrade()
    if autoUpgradeConnection then
        task.cancel(autoUpgradeConnection)
        autoUpgradeConnection = nil
    end
end

local function getWavesBase()
    return workspace.Unclimbable
        and workspace.Unclimbable.Objective
        and workspace.Unclimbable.Objective:FindFirstChild("Waves")
end

local function getCurrentWave()
    local obj = ReplicatedStorage:FindFirstChild("Objectives")
    if not obj then return 0 end
    local v = obj:FindFirstChild("Clearance")
    return v and v.Value or 0
end

local function getClosestTitanToBase()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end

    local base = getWavesBase()
    local anchor
    if base then
        local part = base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart")
        anchor = part and part.Position or rootPart.Position
    else
        anchor = rootPart.Position
    end

    local bestTitan, bestDist = nil, math.huge
    for _, titan in ipairs(titans:GetChildren()) do
        local hrp = titan:FindFirstChild("HumanoidRootPart")
        local hum = titan:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 and titan:GetAttribute("Shifter") ~= true then
            local hb   = titan:FindFirstChild("Hitboxes", true)
            local nape = hb and hb:FindFirstChild("Hit", true) and hb.Hit:FindFirstChild("Nape")
            if nape then
                local dist = (hrp.Position - anchor).Magnitude
                if dist < bestDist then
                    bestDist  = dist
                    bestTitan = titan
                end
            end
        end
    end
    return bestTitan
end

local function tryVoteWave()
    pcall(function()
        local voteBtn = player.PlayerGui.Interface.Waves.Inner.Main:FindFirstChild("Vote")
        if voteBtn and voteBtn.Visible then
            GuiService.SelectedObject = voteBtn
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            debugPrint("[LixHub] Waves: Voted to start/skip wave")
        end
    end)
end

local function startWavesAutoVoteLoop()
    task.spawn(function()
        while Waves.State.active and not Waves.State.stopRequested do
            task.wait(2)
            if Waves.State.autoVote then
                local inner = player.PlayerGui.Interface:FindFirstChild("Waves")
                if inner and inner:FindFirstChild("Inner") and inner.Inner.Visible then
                    tryVoteWave()
                end
            end
        end
    end)
end

function Waves.startAutoUpgrade()
    if Waves.State.upgradeConnection then return end
    Waves.State.upgradeConnection = task.spawn(function()
        while Waves.State.autoUpgrade do
            task.wait(2)
            pcall(function()
                GET:InvokeServer("Equipment", "Upgrade", {
                    "Crit_Chance",
                    "Blade_Durability",
                    "ODM_Damage",
                    "Crit_Damage",
                    "ODM_Speed",
                    "ODM_Control",
                    "ODM_Range",
                    "ODM_Gas"
                })
            end)
        end
    end)
end

function Waves.stopAutoUpgrade()
    Waves.State.autoUpgrade = false
    if Waves.State.upgradeConnection then
        task.cancel(Waves.State.upgradeConnection)
        Waves.State.upgradeConnection = nil
    end
end

function Waves.startAutoBuy()
    if Waves.State.buyConnection then return end
    Waves.State.buyConnection = task.spawn(function()
        while Waves.State.autoBuyUpgrades do
            task.wait(1.5)
            if #Waves.State.buyUpgradesList > 0 then
                for _, upgrade in ipairs(Waves.State.buyUpgradesList) do
                    pcall(function()
                        GET:InvokeServer("Waves", "Upgrade", upgrade)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end)
end

function Waves.stopAutoBuy()
    Waves.State.autoBuyUpgrades = false
    if Waves.State.buyConnection then
        task.cancel(Waves.State.buyConnection)
        Waves.State.buyConnection = nil
    end
end

function Waves.stop()
    Waves.State.stopRequested = true
    Waves.State.active        = false
    WaveReloadState           = "idle"
    if Waves.State.connection then
        Waves.State.connection:Disconnect()
        Waves.State.connection = nil
    end
    removeBodyMovers()
    disableSync()
    debugPrint("[LixHub] Waves: Stopped")
end

local function getBossTitan()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end
    for _, titan in ipairs(titans:GetChildren()) do
        local hum = titan:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            if titan:GetAttribute("Shifter") == true then
                local hb = titan:FindFirstChild("Hitboxes", true)
                local nape = hb and hb:FindFirstChild("Hit", true) and hb.Hit:FindFirstChild("Nape")
                if nape then return titan end
            end
        end
    end
    return nil
end

function Waves.start()
    if isInLobby() then return end
    if player:GetAttribute("Cutscene") == true then
        repeat task.wait(0.1) until player:GetAttribute("Cutscene") ~= true or Waves.State.stopRequested
        if Waves.State.stopRequested then return end
    end

    if Waves.State.connection then
        Waves.State.connection:Disconnect()
        Waves.State.connection = nil
    end

    Waves.State.stopRequested = false
    Waves.State.active        = true
    WaveReloadState           = "idle"

    debugPrint("[LixHub] Waves: Starting farm")

    disableCollision()
    local _hum = character:FindFirstChildOfClass("Humanoid")
    if _hum then _hum.PlatformStand = true; _hum.AutoRotate = false end
    enableSync()

    startWavesAutoVoteLoop()

    local tickAccum = 0

    Waves.State.connection = RunService.Heartbeat:Connect(function(dt)
        if Waves.State.stopRequested then
            if Waves.State.connection then
                Waves.State.connection:Disconnect()
                Waves.State.connection = nil
            end
            return
        end

        -- Return to lobby after X waves
        if Waves.State.returnAfterWaves then
            local wave = getCurrentWave()
            if wave >= Waves.State.returnWaveCount then
                Waves.stop()
                Util.notify("Waves", "Wave limit reached, returning to lobby...", 4)
                task.delay(2, function()
                    game:GetService("TeleportService"):Teleport(14916516914, player)
                end)
                return
            end
        end

        if isUsingSpears() then
            local spearCount = getSpearStatus()
            if spearCount <= 0 and WaveReloadState == "idle" then
                WaveReloadState = "refilling"
                task.spawn(function()
                    local refillPoint = findWavesRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait(0.5)
                    until (character:GetAttribute("Spears") or 0) > 0 or WaveReloadState ~= "refilling"
                    WaveReloadState = "idle"
                end)
                return
            end
            if WaveReloadState ~= "idle" then return end
        else
            local cassettesLeft, segmentsLeft = getBladeStatus()

            if segmentsLeft <= 0 and cassettesLeft > 0 and WaveReloadState == "idle" then
                WaveReloadState = "swapping"
                task.spawn(function()
                    local result
                    repeat
                        result = GET:InvokeServer("Blades", "Reload")
                        task.wait()
                        local c, s = getBladeStatus()
                        if s > 0 then break end
                    until result == true or WaveReloadState ~= "swapping"
                    WaveReloadState = "idle"
                end)
                return
            end

            if segmentsLeft <= 0 and cassettesLeft <= 0 and WaveReloadState == "idle" then
                WaveReloadState = "refilling"
                task.spawn(function()
                    local refillPoint = findWavesRefillPoint()
                    repeat
                        GET:InvokeServer("Attacks", "Reload", refillPoint)
                        task.wait()
                        local c, _ = getBladeStatus()
                        if c > 0 then break end
                    until WaveReloadState ~= "refilling"
                    repeat task.wait() until (select(2, getBladeStatus())) > 0 or WaveReloadState ~= "refilling"
                    WaveReloadState = "idle"
                end)
                return
            end

            if WaveReloadState ~= "idle" then return end
        end

        tickAccum = tickAccum + dt
if tickAccum < State.attackInterval then return end
tickAccum = 0

local titan = nil
local isBoss = false
local boss = getBossTitan()

if Waves.State.prioritizeBosses then
    if boss then
        titan = boss
        isBoss = true
    else
        titan = getClosestTitanToBase()
    end
else
    titan = getClosestTitanToBase()
    -- Even in normal mode, if boss exists alongside normal titans,
    -- still flag it so it gets multi-damage when targeted
    if not titan then
        if boss then titan = boss; isBoss = true end
    elseif titan == boss then
        isBoss = true
    end
end

if titan and titan:GetAttribute("Shifter") == true then
    isBoss = true
end

if not titan then return end

local titanRoot = titan:FindFirstChild("HumanoidRootPart")
if not titanRoot then return end

local hb   = titan:FindFirstChild("Hitboxes", true)
local nape = hb and hb:FindFirstChild("Hit", true) and hb.Hit:FindFirstChild("Nape")
if not nape then return end

State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))

State.inHook = true
local actualPos = rootPart.Position
State.inHook = false

local horizontalDist = Vector2.new(
    actualPos.X - titanRoot.Position.X,
    actualPos.Z - titanRoot.Position.Z
).Magnitude
if horizontalDist > 150 then return end

if isUsingSpears() then
    spearAttackTitan(nape, titanRoot, isBoss)
else
    if isBoss then
        -- Multi-damage for bosses (same as raid boss handling)
        local vulnSpot = Raids.getVulnerableSpot(titan)
        if vulnSpot then
            Raids.registerHitVuln(vulnSpot)
        else
            task.spawn(function()
                POST:FireServer("Attacks", "Slash", true)
                for i = 1, 5 do
                    local damage = 670 + math.random(55, 165)
                    if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
                    POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))
                end
            end)
        end
    else
        -- Normal titan attack
        POST:FireServer("Attacks", "Slash", true)
        local damage = 670 + math.random(55, 165)
        if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
        POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))

        if State.multiHitEnabled then
            local titans = workspace:FindFirstChild("Titans")
            if titans then
                local count = 0
                for _, otherTitan in ipairs(titans:GetChildren()) do
                    if count >= State.multiHitCount then break end
                    local hum = otherTitan:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local hb2 = otherTitan:FindFirstChild("Hitboxes", true)
                        local otherNape = hb2 and hb2:FindFirstChild("Hit", true) and hb2.Hit:FindFirstChild("Nape")
                        if otherNape and otherNape ~= nape then
                            local otherHrp = otherTitan:FindFirstChild("HumanoidRootPart")
                            local dist = otherHrp and (otherHrp.Position - rootPart.Position).Magnitude or math.huge
                            if dist <= 500 then
                                local d2 = 670 + math.random(55, 165)
                                if math.random(1, 8) == 1 then d2 = d2 * math.random(138, 148) / 100 end
                                POST:FireServer("Hitboxes", "Register", otherNape, math.floor(d2))
                                count += 1
                            end
                        end
                    end
                end
            end
        end
    end
end
    end)
end

local function getCannonModel()
    local walls = workspace.Climbable
        and workspace.Climbable:FindFirstChild("Walls")
    if not walls then return nil end
    
    for _, wall in ipairs(walls:GetChildren()) do
        if wall.Name == "Wall" then
            local cannons = wall:FindFirstChild("Cannons")
            if cannons then
                local cannon = cannons:FindFirstChild("1")
                if cannon then
                    return cannon
                end
            end
        end
    end
    return nil
end

local function getColossalTitan()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end
    for _, t in ipairs(titans:GetChildren()) do
        if t.Name:find("Colossal") then
            local hum = t:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then return t end
        end
    end
    return nil
end

local function getErenCollider()
    return workspace.Unclimbable
        and workspace.Unclimbable.Objective
        and workspace.Unclimbable.Objective:FindFirstChild("Defend_Eren_2")
        and workspace.Unclimbable.Objective.Defend_Eren_2:FindFirstChild("Collider")
end

local function titansThreateningEren()
    local collider = getErenCollider()
    if not collider then return false end
    for _, v in ipairs(collider:GetChildren()) do
        if v.Name == "Titan_Hit" then return true end
    end
    return false
end

local function getClosestTitanToEren2()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end

    local collider = getErenCollider()
    if not collider then return nil end
    
    local anchor = collider.Position

    local bestTitan, bestDist = nil, math.huge
    for _, titan in ipairs(titans:GetChildren()) do
        if not titan.Name:find("Colossal") then
            local hrp = titan:FindFirstChild("HumanoidRootPart")
            local hum = titan:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local nape = Raids.getNape(titan)
                if nape then
                    local dist = (hrp.Position - anchor).Magnitude
                    -- Only care about titans within a reasonable range of Eren
                    if dist < bestDist and dist < 200 then
                        bestDist  = dist
                        bestTitan = titan
                    end
                end
            end
        end
    end
    return bestTitan
end

local function mountCannon(cannon)
    -- Claim once if not claimed
    if not ColossalState.claimed then
        GET:InvokeServer("Cannon", "Claim", cannon)
        ColossalState.claimed = true
        task.wait(0.1)
    end
    -- Mount
    GET:InvokeServer("Cannon", "State", cannon, true)
    ColossalState.onCannon = true
    debugPrint("[LixHub] Colossal: Mounted cannon")
end

local function dismountCannon(cannon)
    if not ColossalState.onCannon then return end
    
    local barrelWood = cannon:FindFirstChild("BarrelWood", true)
    local base = cannon:FindFirstChild("Base", true)
    
    local success = false
    local attempts = 0
    
    repeat
        attempts += 1
        local ok = pcall(function()
            GET:InvokeServer("Cannon", "State", cannon, false, {
                SFX        = {},
                Object     = cannon,
                BarrelWood = barrelWood,
                Angles     = { BarrelWood = 0, Base = 0 },
                Base       = base,
                Directions = {},
            })
        end)
        
        if ok then
            success = true
        else
            warn("[LixHub] Colossal: Dismount attempt", attempts, "failed, retrying...")
            task.wait(0.1)
        end
    until success or attempts >= 5
    
    if not success then
        warn("[LixHub] Colossal: Failed to dismount cannon after", attempts, "attempts — forcing state reset")
    end
    
    -- Force state reset regardless of remote success
    -- so the rest of the logic doesn't get stuck
    ColossalState.onCannon = false
    debugPrint("[LixHub] Colossal: Dismounted cannon (attempts: " .. attempts .. ")")
end

local CANNON_IMPACT_COUNT = 10 -- how many impact registers per shot
local cannonShooting = false

local function shootCannon(cannon, colossalTitan)
    if cannonShooting then return end
    cannonShooting = true

    GET:InvokeServer("Cannon", "Shoot", {
        BarrelWood = 20,
        Base       = 0,
    })

    -- Wait for cannonball to appear in workspace (2.5s timeout)
    local cannonBall = nil
    local startTime = tick()
    repeat
        task.wait()
        cannonBall = workspace:FindFirstChild("Cannon")
    until cannonBall or tick() - startTime > 2.5

    if cannonBall then
        -- Wait for the actual impact event before spamming
        local impactFired = false
        local conn = POST.OnClientEvent:Connect(function(a, b, obj)
            if a == "Skills" and b == "Impact" and obj == cannonBall then
                impactFired = true
            end
        end)
        local waitStart = tick()
        repeat task.wait() until impactFired or tick() - waitStart > 4
        conn:Disconnect()

        if impactFired then
            local hrp = colossalTitan and colossalTitan:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position - Vector3.new(0, 20, 0)
                for i = 1, CANNON_IMPACT_COUNT do
                    POST:FireServer("S_Skills", "Impact", cannonBall, pos)
                end
            end
        else
            debugPrint("[LixHub] Colossal: Impact event never fired, skipping")
        end
    else
        debugPrint("[LixHub] Colossal: Cannonball not found in workspace, skipping")
    end

    task.wait(1.1)
    cannonShooting = false
end

function Raids.startColossal()
    if isInLobby() then return end
    if player:GetAttribute("Cutscene") == true then
        repeat task.wait(0.1) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
        if Raids.State.stopRequested then return end
    end

    if Raids.State.connection then
        Raids.State.connection:Disconnect()
        Raids.State.connection = nil
    end

    Raids.State.stopRequested = false
    Raids.State.active        = true
    Raids.State.phase         = "colossal_defend"
    ColossalState.onCannon    = false
    ColossalState.claimed     = false
    cannonShooting            = false

    debugPrint("[LixHub] Colossal Raid: Starting — Phase 1: Defend Eren + Stall Colossal")

    local cannon = getCannonModel()
    if not cannon then
        Util.notify("Colossal Raid", "Cannon not found!", 5, "alert-triangle")
        return
    end

    -- Claim the cannon once upfront
    GET:InvokeServer("Cannon", "Claim", cannon)
    ColossalState.claimed = true
    task.wait(0.1)

    -- We handle our own movement for titan killing
    -- but when on cannon we don't need body movers
    disableCollision()
    local _hum = character:FindFirstChildOfClass("Humanoid")
    if _hum then _hum.PlatformStand = true; _hum.AutoRotate = false end
    enableSync()

    local tickAccum = 0
    local chestsDone = false
    local bossWaitDone  = false
    local bossWaitReady = false
    local phase1Done = false

    Raids.State.connection = RunService.Heartbeat:Connect(function(dt)
        if Raids.State.stopRequested then
            if Raids.State.connection then
                Raids.State.connection:Disconnect()
                Raids.State.connection = nil
            end
            dismountCannon(cannon)
            return
        end

        -- Check phase 1 complete (Stall_Colossal_Titan hits 1)
        if Raids.getObjectiveValue("Stall_Colossal_Titan") >= 1 and not phase1Done then
            phase1Done = true  -- prevents re-entry every heartbeat
            debugPrint("[LixHub] Colossal Raid: Phase 1 done — waiting for cutscene")
            Raids.State.phase = "cutscene"
            
            dismountCannon(cannon)
            removeBodyMovers()
            disableSync()

            task.spawn(function()
                repeat task.wait(0.3) until player:GetAttribute("Cutscene") == true or Raids.State.stopRequested
                repeat task.wait(0.3) until player:GetAttribute("Cutscene") ~= true or Raids.State.stopRequested
                if Raids.State.stopRequested then return end

                debugPrint("[LixHub] Colossal Raid: Cutscene done — Phase 2: Defeat Colossal Titan")

                disableCollision()
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true; hum.AutoRotate = false end
                enableSync()

                Raids.State.phase = "defeat"
            end)
            return
        end

        -- ===== PHASE 2: DEFEAT COLOSSAL TITAN =====
        if Raids.State.phase == "defeat" then
            local colossal = getColossalTitan()

            if Raids.getObjectiveValue("Defeat_Colossal_Titan") >= 1 then
                if not chestsDone then
                    chestsDone = true
                    debugPrint("[LixHub] Colossal Raid: Defeated — collecting chests")
                    task.spawn(function()
                        task.wait(5)
                        local start = tick()
                        repeat task.wait(0.3) until
                            (player.PlayerGui.Interface:FindFirstChild("Chests") and
                            player.PlayerGui.Interface.Chests.Visible) or
                            tick() - start > 20
                        Raids.openChests()
                        task.wait(3)
                        Raids.clickFinish()
                    end)
                end
                return
            end

            if colossal then
                local titanRoot = colossal:FindFirstChild("HumanoidRootPart")
                if titanRoot then
                    State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
                    local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
                    ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))
                end
            end

            if not bossWaitDone then
                bossWaitDone = true
                task.spawn(function()
                    waitBeforeKillingBoss(colossal, function() return Raids.State.stopRequested end)
                    bossWaitReady = true
                end)
                return
            end
            if not bossWaitReady then return end

            if not colossal then return end
            if colossal:GetAttribute("State") == "Roar" then return end

            Raids.handleTitan(colossal, true, true)
            return
        end

        -- ===== PRIORITY: titans near Eren =====
        local erenThreatened = titansThreateningEren()
        local closestErenTitan = getClosestTitanToEren2()

        if erenThreatened or closestErenTitan then
            -- Dismount cannon so we can move
            if ColossalState.onCannon then
                dismountCannon(cannon)
                task.wait(0.3)
                -- re-enable movement
                disableCollision()
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true; hum.AutoRotate = false end
                enableSync()
            end

            -- Kill the titan near Eren
            if closestErenTitan then
                Raids.handleTitan(closestErenTitan, false)
            end

        else
            -- ===== STALL: mount cannon and fire at Colossal =====
            local colossal = getColossalTitan()
            if colossal then
                if not ColossalState.onCannon then
                    -- Move body movers off since cannon welds us
                    removeBodyMovers()
                    mountCannon(cannon)
                end

                -- Fire cannonballs + impacts at Colossal
                task.spawn(function()
                    shootCannon(cannon, colossal)
                end)
            end
        end
    end)
end

local function autoClaimAchievements()
    for i = 1, 70 do
        pcall(function()
            GET:InvokeServer("S_Achievements", "Claim", i)
        end)
        task.wait(0.1)
    end
    Util.notify("Achievements", "Claimed all achievements!", 3, "check")
end

local function startAutoBoost()
    if autoBoostConnection then return end
    autoBoostConnection = task.spawn(function()
        while true do
            task.wait(5)

            if State.autoUseBoosts then
                for _, bType in ipairs({"XP", "Gold", "Luck"}) do
                    local boost = player.Boosts:FindFirstChild(bType)
                    if boost and boost.Value <= 0 then
                        pcall(function()
                            GET:InvokeServer("S_Inventory", "Item", "2x " .. bType .. " Boost [2h]")
                        end)
                    end
                end
            end

            if State.autoPurchaseBoosts then
                local prefix = ({["Gems"] = "1_Boosts", ["Candy Canes"] = "2_Boosts", ["Wave Coins"] = "3_Boosts"})[State.autoPurchaseBoostsCurrencySelection] or "2_Boosts"
                local ids = {XP = 3, Gold = 9, Luck = 6}
                local selected = type(State.autoPurchaseBoostsSelection) == "table" and State.autoPurchaseBoostsSelection or {State.autoPurchaseBoostsSelection}
                for _, bType in ipairs(selected) do
                    local boost = player.Boosts:FindFirstChild(bType)
                    if boost and boost.Value <= 0 then
                        pcall(function()
                            GET:InvokeServer("S_Market", "Buy", prefix, ids[bType], 1)
                        end)
                        task.wait(0.5)
                    end
                end
            end
        end
    end)
end

local function loadFamilies()
    local ok, FamilyData = pcall(require, game:GetService("ReplicatedStorage").Modules.Storage.Families)
    if not ok or type(FamilyData) ~= "table" then
        warn("[LixHub] Failed to require Families module:", FamilyData)
        return
    end

    local rarityOrder = {"Secret", "Mythic", "Legendary", "Epic", "Rare", "Common"}

    for _, rarity in ipairs(rarityOrder) do
        local tier = FamilyData[rarity]
        if tier then
            for familyName in pairs(tier) do
                familyRarityMap[familyName] = rarity
                table.insert(familyDropdownOptions, familyName .. " [" .. rarity .. "]")
            end
        end
    end

    -- Sort so higher rarities appear first
    table.sort(familyDropdownOptions, function(a, b)
        local function rarityIndex(str)
            for i, r in ipairs(rarityOrder) do
                if str:find("%[" .. r .. "%]") then return i end
            end
            return 99
        end
        local ia, ib = rarityIndex(a), rarityIndex(b)
        if ia == ib then return a < b end
        return ia < ib
    end)
end

local function sendRollWebhook(familyName, rarity)
    if not State.webhookUrl then return end

    local color = RARITY_COLORS[rarity] or 0x808080
    local HttpService = game:GetService("HttpService")
    local requestFunc = syn and syn.request or request or http_request or getgenv().request
    if not requestFunc then return end

    local data = {
        username = "LixHub",
        content  = State.discordUserId and string.format("<@%s> Rolled %s!", State.discordUserId, familyName) or nil,
        embeds = {{
            title       = "Family Rolled!",
            description = string.format("Rolled %s!", familyName),
            color       = color,
            footer      = { text = "LixHub • discord.gg/cYKnXE2Nf8" },
            timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }}
    }

    pcall(function()
        requestFunc({
            Url     = State.webhookUrl,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = HttpService:JSONEncode(data),
        })
    end)
end

local function stopAutoRoll()
    RollState.active = false
    debugPrint("[LixHub] Auto Roll: Stopped")
end

local function startAutoRoll()
    if RollState.active then return end
    if #RollState.targetFamilies == 0 then
        Util.notify("Auto Roll", "No target families selected!", 3, "alert-triangle")
        return
    end

    RollState.active = true
    debugPrint("[LixHub] Auto Roll: Starting...")

    task.spawn(function()
        while RollState.active do
            local ok, a, familyName, pityCount, familyTable = pcall(function()
                return GET:InvokeServer("Family", "Roll")
            end)

            if not ok or not familyName then
                debugPrint("[LixHub] Auto Roll: Roll failed, retrying...")
                task.wait(1)
                continue
            end

            local rarity = familyRarityMap[familyName] or "Common"
            debugPrint("[LixHub] Auto Roll: Got", familyName, "[" .. rarity .. "] —", a, "rolls left, pity:", pityCount)
            Util.notify("Auto Roll", familyName .. " [" .. rarity .. "] — " .. tostring(a) .. " rolls left", 1, "refresh-cw")

            for _, target in ipairs(RollState.targetFamilies) do
                local targetName = target:match("^(.-)%s+%[")
                if targetName == familyName then
                    RollState.active = false
                    Util.notify("Auto Roll", "Rolled " .. familyName .. " [" .. rarity .. "]!", 8, "star")
                    sendRollWebhook(familyName, rarity)
                    debugPrint("[LixHub] Auto Roll: Target family found! Stopping.")
                    return
                end
            end

            task.wait(0.1)
        end
    end)
end

local function getSkillIdForSlot(slot)
    local hotbar = player.PlayerGui.Interface.HUD.Main.Top["7"]:FindFirstChild("Hotbar")
    if not hotbar then return nil end
    local slotFolder = hotbar:FindFirstChild("Skill_" .. slot)
    if not slotFolder then return nil end
    return tostring(slotFolder:GetAttribute("Skill"))
end

local function getSkillCooldown(skillId)
    local info = skillInfoMap[skillId]
    return info and info.Cooldown or nil
end

local function startAutoSkills()
    if autoSkillConnection then return end
    autoSkillConnection = task.spawn(function()
        while State.autoSkillsEnabled do
            task.wait(0.1)
            for _, slot in ipairs(State.autoSkillSlots) do
                local skillId = getSkillIdForSlot(slot)
                if skillId then
                    local cooldown = getSkillCooldown(skillId)
                    if cooldown then
                        local last = skillLastUsed[slot] or 0
                        if tick() - last >= cooldown then
                            local result
                            pcall(function()
                                result = GET:InvokeServer("S_Skills", "Usage", slot)
                            end)

                            if result ~= nil then
                                skillLastUsed[slot] = tick()
                                local info = skillInfoMap[skillId]
                                local frames = info and info.Frames or 0
                                if frames > 0 then
                                    task.wait(frames / 60)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoSkills()
    State.autoSkillsEnabled = false
    if autoSkillConnection then
        task.cancel(autoSkillConnection)
        autoSkillConnection = nil
    end
    skillLastUsed = {}
end

-- ==================== RAYFIELD UI ====================
local Window = Rayfield:CreateWindow({
   Name = "LixHub - Attack On Titan Revolution",
   Icon = 0,
   LoadingTitle = "Loading for Attacks on Titan Revolution",
   ScriptID = "sid_cbw5dr4ixqpo",
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
      FileName = game:GetService("Players").LocalPlayer.Name .. "_AttackOnTitanRevolution"
   },

   Discord = {
      Enabled = true,
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "LixHub - Attack On Titan Revolution - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})

-- ===== TAB: Join =====

local MISSION_DIFF_ORDER = {"Aberrant", "Severe", "Hard", "Normal", "Easy"}
local RAID_DIFF_ORDER    = {"Aberrant", "Severe", "Hard"}

local function tryDifficulties(diffList, createFn)
    for _, diff in ipairs(diffList) do
        debugPrint("[LixHub] Trying difficulty:", diff)
        local ok, result = pcall(createFn, diff)
        if ok and result then
            return true
        end
        debugPrint("[LixHub] Difficulty failed:", diff, "— trying next...")
        task.wait(0.5)
    end
    return false
end

local function joinMission()
    local function attemptCreate(diff)
        local mapName = State.autoJoinMissionMap
        if mapName == "Boosted" then
            mapName = workspace:GetAttribute("Boosted_Map")
            if not mapName or mapName == "" then
                warn("[LixHub] Auto Join: Boosted map attribute not found")
                error("Boosted map not available")
            end
            debugPrint("[LixHub] Auto Join: Boosted map detected —", mapName)
        end

        debugPrint("[LixHub] Auto Join: Creating mission —", mapName, State.autoJoinMissionObj, diff)
        local result = GET:InvokeServer("S_Missions", "Create", {
            Difficulty = diff,
            Type       = "Missions",
            Objective  = State.autoJoinMissionObj,
            Name       = mapName,
        })
        debugPrint("[LixHub] Auto Join: Create result —", result, type(result))
        if not result then
            error("Create failed for diff: " .. diff)
        end
        return true
    end

    local success
    if State.autoJoinMissionDiff == "Hardest" then
        success = tryDifficulties(MISSION_DIFF_ORDER, attemptCreate)
    else
        local ok, err = pcall(attemptCreate, State.autoJoinMissionDiff)
        if not ok then
            warn("[LixHub] Auto Join: Create failed —", err)
            return false
        end
        success = true
    end

    if not success then
        warn("[LixHub] Auto Join: All difficulties failed")
        return false
    end

    debugPrint("[LixHub] Auto Join: Lobby created successfully")
    for _, mod in ipairs(State.autoJoinMissionMods) do
        local modResult = GET:InvokeServer("S_Missions", "Modify", mod)
        if modResult ~= true then
            warn("[LixHub] Auto Join: Modifier failed —", mod, "got:", modResult)
        else
            debugPrint("[LixHub] Auto Join: Applied modifier —", mod)
        end
        task.wait(0.1)
    end
    debugPrint("[LixHub] Auto Join: Starting mission...")
    task.wait(1)
    local startResult
    for attempt = 1, 5 do
        startResult = GET:InvokeServer("S_Missions", "Start")
        if startResult then break end
        warn("[LixHub] Auto Join: Start attempt", attempt, "failed, retrying...")
        task.wait(1)
    end
    if not startResult then
        warn("[LixHub] Auto Join: Start never succeeded")
        return false
    end
    return true
end

local function joinRaid()
    local titanMap = RAID_TITAN_MAP[State.autoJoinRaidType]
    if not titanMap then
        warn("[LixHub] Auto Join Raid: Unknown titan type —", State.autoJoinRaidType)
        return false
    end

    local function attemptCreate(diff)
        debugPrint("[LixHub] Auto Join Raid:", State.autoJoinRaidType, "on", titanMap, "—", diff)

        local payload = {
            Type       = "Raids",
            Objective  = State.autoJoinRaidType,
            Difficulty = diff,
            Name       = titanMap,
        }

        if State.autoJoinRaidType == "Colossal Titan" then
            payload.Minimum = 3
        end

        local result = GET:InvokeServer("S_Missions", "Create", payload)

        if not result then
            error("Create failed for diff: " .. diff)
        end

        return true
    end

    local success
    if State.autoJoinRaidDiff == "Hardest" then
        success = tryDifficulties(RAID_DIFF_ORDER, attemptCreate)
    else
        local ok, err = pcall(attemptCreate, State.autoJoinRaidDiff)
        if not ok then
            warn("[LixHub] Auto Join Raid: Create failed —", err)
            return false
        end
        success = true
    end

    if not success then
        warn("[LixHub] Auto Join Raid: All difficulties failed")
        return false
    end

    debugPrint("[LixHub] Auto Join Raid: Lobby created successfully")

    for _, mod in ipairs(State.autoJoinRaidMods) do
        local modResult = GET:InvokeServer("S_Missions", "Modify", mod)
        if modResult ~= true then
            warn("[LixHub] Auto Join Raid: Modifier failed —", mod, "got:", modResult)
        else
            debugPrint("[LixHub] Auto Join Raid: Applied modifier —", mod)
        end
        task.wait(0.1)
    end

    debugPrint("[LixHub] Auto Join Raid: Starting...")
    GET:InvokeServer("S_Missions", "Start")

    return true
end

local function joinWaves()
    debugPrint("[LixHub] Auto Join Waves:", State.autoJoinWavesMap)

    local result = GET:InvokeServer("S_Missions", "Create", {
        Difficulty = "Easy",
        Type       = "Waves",
        Name       = State.autoJoinWavesMap,
        Objective  = "Waves",
    })

    if not result then
        warn("[LixHub] Auto Join Waves: Create failed — unexpected result:", result)
        return false
    end

    debugPrint("[LixHub] Auto Join Waves: Starting...")
    GET:InvokeServer("S_Missions", "Start")

    return true
end

local function checkAndJoin()
    if not isInLobby() then return end
    if autoJoinProcessing then return end
    if not State.autoJoinMissions and not State.autoJoinRaids and not State.autoJoinWaves then return end

    autoJoinProcessing = true

    if State.autoJoinDelaySecs > 0 then
        task.wait(State.autoJoinDelaySecs)
    end

    local ok, err = pcall(function()
        local success = false
        local label = ""

        if State.autoJoinMissions then
            label = "Mission: " .. State.autoJoinMissionMap
            success = joinMission()
        elseif State.autoJoinRaids then
            label = "Raid: " .. State.autoJoinRaidType
            success = joinRaid()
        elseif State.autoJoinWaves then
            label = "Waves: " .. State.autoJoinWavesMap
            success = joinWaves()
        end

        if success then
            Util.notify("Auto Join", label .. " started", 3, "play")
            local waitStart = tick()
            repeat task.wait(0.5) until not isInLobby() or tick() - waitStart > 30
            if not isInLobby() then
                debugPrint("[LixHub] Auto Join: Successfully loaded into game")
            else
                warn("[LixHub] Auto Join: Timed out waiting to leave lobby")
            end
            task.wait(3)
        else
            Util.notify("Auto Join", label .. " failed, retrying...", 3, "alert-triangle")
            task.wait(3)
        end
    end)

    if not ok then
        warn("[LixHub] checkAndJoin error:", err)
    end

    autoJoinProcessing = false
end

local function startAutoJoinLoop()
    if autoJoinConnection then return end
    autoJoinConnection = task.spawn(function()
        while true do
            task.wait(2)
            checkAndJoin()
        end
    end)
end

local function startAutoSkipCutscenes()
    task.spawn(function()
        while true do
            task.wait(0.3)
            if State.skipCutscenesEnabled then
                pcall(function()
                    local skip = player.PlayerGui.Interface:FindFirstChild("Skip")
                    if skip and skip.Visible then
                        local interact = skip:FindFirstChild("Interact")
                        if interact then
                            GuiService.SelectedObject = interact
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    end
                end)
            end
        end
    end)
end

startAutoJoinLoop()
startAutoSkipCutscenes()
startAutoBoost()
loadFamilies()

local JoinerTab = Window:CreateTab("Auto Join", "plug-zap")

JoinerTab:CreateSlider({
    Name         = "Auto Join Delay (seconds)",
    Range        = {0, 60},
    Increment    = 1,
    CurrentValue = 3,
    Flag         = "AutoJoinDelay",
    Callback     = function(val)
        State.autoJoinDelaySecs = val
    end,
})

JoinerTab:CreateSection("Missions")

JoinerTab:CreateToggle({
    Name         = "Auto Join Missions",
    CurrentValue = false,
    Flag         = "AutoJoinMissions",
    Callback     = function(val)
        State.autoJoinMissions = val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Map",
    Options      = {"Shiganshina", "Trost", "Outskirts", "Forest", "Utgard", "Docks", "Stohess", "Chapel", "Boosted"},
    CurrentOption = {},
    Flag         = "AutoJoinMissionMap",
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinMissionMap = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Objective",
    Options      = {"Skirmish", "Breach", "Random"},
    CurrentOption = {"Skirmish"},
    Flag = "AutoJoinMissionObj",
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinMissionObj = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Difficulty",
    Options      = {"Easy", "Normal", "Hard", "Severe", "Aberrant", "Hardest"},
    CurrentOption = {"Normal"},
    Flag = "AutoJoinMissionDiff",
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinMissionDiff = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Modifiers",
    Options      = {"No Perks", "No Skills", "No Memories", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Cannon", "Time Trial", "Boring", "Simple"},
    CurrentOption = {},
    Flag         = "AutoJoinMissionMods",
    MultipleOptions = true,
    Callback     = function(val)
        State.autoJoinMissionMods = type(val) == "table" and val or {val}
    end,
})

JoinerTab:CreateSection("Raids")

JoinerTab:CreateToggle({
    Name         = "Auto Join Raids",
    CurrentValue = false,
    Flag         = "AutoJoinRaids",
    Callback     = function(val)
        State.autoJoinRaids = val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Raid",
    Options      = {"Attack Titan", "Armored Titan", "Female Titan", "Colossal Titan"},
    CurrentOption = {},
    Flag         = "AutoJoinRaidType",
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinRaidType = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Difficulty",
    Options      = {"Hard", "Severe", "Aberrant","Hardest"},
    CurrentOption = {},
    Flag         = "AutoJoinRaidDiff",
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinRaidDiff = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Modifiers",
    Options      = {"No Perks", "No Skills", "No Memories", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Cannon", "Time Trial", "Boring", "Simple"},
    CurrentOption = {},
    Flag         = "AutoJoinRaidMods",
    MultipleOptions = true,
    Callback     = function(val)
        State.autoJoinRaidMods = type(val) == "table" and val or {val}
    end,
})

JoinerTab:CreateSection("Waves")

JoinerTab:CreateToggle({
    Name         = "Auto Join Waves",
    CurrentValue = false,
    Flag         = "AutoJoinWaves",
    Callback     = function(val)
        State.autoJoinWaves = val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Map",
    Options      = {"Trost"},
    CurrentOption = {},
    Flag         = "AutoJoinWavesMap",
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinWavesMap = type(val) == "table" and val[1] or val
    end,
})

-- ===== TAB: Farm =====
local FarmTab = Window:CreateTab("Main", "play")

FarmTab:CreateSection("Missions")

FarmTab:CreateToggle({
    Name         = "Auto Farm (Missions)",
    CurrentValue = false,
    Flag         = "AutoFarm",
    Callback     = function(val)
        if val then
            task.defer(startAutoAttack)
        else
            stopAutoAttack()
        end
    end,
})

FarmTab:CreateSlider({
    Name         = "Wait x Seconds Before Killing Last Titan",
    Range        = {0, 300},
    Increment    = 1,
    CurrentValue = State.waitLastTitanSeconds,
    Flag         = "WaitLastTitanSeconds",
    Callback     = function(val) State.waitLastTitanSeconds = val end,
})

FarmTab:CreateSection("Raids")

FarmTab:CreateToggle({
    Name         = "Auto Farm (Raids)",
    CurrentValue = false,
    Flag         = "AutoFarmRaids",
    Callback     = function(val)
        if val then
            task.defer(Raids.start)
        else
            Raids.stop()
        end
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Open Chests",
    CurrentValue = false,
    Flag         = "AutoOpenChests",
    Callback     = function(val)
        Raids.State.autoOpenChests = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Open Emperor Chests",
    CurrentValue = false,
    Flag         = "AutoOpenEmperorChests",
    Callback     = function(val)
        Raids.State.autoOpenEmperorChests = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Wait Before Killing Raid Boss",
    CurrentValue = false,
    Flag         = "WaitBeforeRaidBoss",
    Callback     = function(val) State.waitBeforeRaidBoss = val end,
})

FarmTab:CreateSlider({
    Name         = "Wait x Seconds Before Killing Raid Boss",
    Range        = {5, 300},
    Increment    = 5,
    CurrentValue = 30,
    Flag         = "WaitRaidBossSeconds",
    Callback     = function(val) State.waitRaidBossSeconds = val end,
})

FarmTab:CreateSection("Waves")

FarmTab:CreateToggle({
    Name         = "Auto Farm (Waves)",
    CurrentValue = false,
    Flag         = "AutoFarmWaves",
    Callback     = function(val)
        if val then
            task.defer(Waves.start)
        else
            Waves.stop()
        end
    end,
})

FarmTab:CreateToggle({
    Name         = "Prioritize Bosses (Waves)",
    CurrentValue = false,
    Flag         = "WavesPrioritizeBosses",
    Callback     = function(val)
        Waves.State.prioritizeBosses = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Start / Skip Wave",
    CurrentValue = false,
    Flag         = "WavesAutoVote",
    Callback     = function(val)
        Waves.State.autoVote = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Upgrade Gear",
    CurrentValue = false,
    Flag         = "WavesAutoUpgradeGear",
    Callback     = function(val)
        Waves.State.autoUpgrade = val
        if val then
            Waves.startAutoUpgrade()
        else
            Waves.stopAutoUpgrade()
        end
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Buy Base Upgrades",
    CurrentValue = false,
    Flag         = "WavesAutoBuy",
    Callback     = function(val)
        Waves.State.autoBuyUpgrades = val
        if val then
            Waves.startAutoBuy()
        else
            Waves.stopAutoBuy()
        end
    end,
})

FarmTab:CreateDropdown({
    Name            = "Select Upgrades to Buy",
    Options         = {"Revive", "Regen", "Replenish", "Refills", "Max"},
    CurrentOption   = {},
    Flag            = "WavesBuyUpgradesList",
    MultipleOptions = true,
    Callback        = function(val)
        Waves.State.buyUpgradesList = type(val) == "table" and val or {val}
    end,
})

FarmTab:CreateToggle({
    Name         = "Return to Lobby After X Waves",
    CurrentValue = false,
    Flag         = "WavesReturnEnabled",
    Callback     = function(val)
        Waves.State.returnAfterWaves = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Return After X Waves",
    Range        = {1, 100},
    Increment    = 1,
    CurrentValue = 10,
    Flag         = "WavesReturnCount",
    Callback     = function(val)
        Waves.State.returnWaveCount = val
    end,
})

FarmTab:CreateSection("Settings")

FarmTab:CreateSlider({
    Name         = "Auto Farm Speed",
    Range        = {100, 500},
    Increment    = 1,
    CurrentValue = 300,
    Flag         = "AutoFarmSpeed",
    Callback     = function(val)
        State.tweenSpeed = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Float Height",
    Range        = {100, 500},
    Increment    = 10,
    CurrentValue = 200,
    Flag         = "FloatHeight",
    Callback     = function(val)
        State.floatHeight = val
    end,
})

FarmTab:CreateSection("Security")

FarmTab:CreateToggle({
    Name         = "Multi Hit Titans",
    CurrentValue = false,
    Flag         = "MultiHitEnabled",
    Callback     = function(val)
        State.multiHitEnabled = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Hit x Titans",
    Range        = {1, 10},
    Increment    = 1,
    CurrentValue = 3,
    Flag         = "MultiHitCount",
    Callback     = function(val)
        State.multiHitCount = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Wait Before Farming",
    CurrentValue = State.waitBeforeFarming,
    Flag         = "WaitBeforeFarming",
    Callback     = function(val) State.waitBeforeFarming = val end,
})

FarmTab:CreateSlider({
    Name         = "Wait x Seconds Before Starting Farming",
    Range        = {15, 600},
    Increment    = 1,
    CurrentValue = State.waitFarmSeconds,
    Flag         = "WaitFarmSeconds",
    Callback     = function(val) State.waitFarmSeconds = val end,
})

FarmTab:CreateToggle({
    Name         = "Return To Lobby After X Mins",
    CurrentValue = State.returnToLobbyEnabled,
    Flag         = "ReturnToLobbyEnabled",
    Callback     = function(val)
        State.returnToLobbyEnabled = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Return To Lobby After X Mins",
    Range        = {1, 120},
    Increment    = 1,
    CurrentValue = State.returnToLobbyMinutes,
    Flag         = "ReturnToLobbyMinutes",
    Callback     = function(val)
        State.returnToLobbyMinutes = val
    end,
})

FarmTab:CreateSection("Game")

FarmTab:CreateToggle({
    Name         = "Auto Escape Grab",
    CurrentValue = false,
    Flag         = "AutoEscapeGrab",
    Callback     = function(val) State.escapeEnabled = val end,
})

FarmTab:CreateToggle({
    Name = "Auto Use Skills",
    CurrentValue = false,
    Flag = "AutoSkills",
    Callback = function(val)
        State.autoSkillsEnabled = val
        if val then startAutoSkills() else stopAutoSkills() end
    end,
})

FarmTab:CreateDropdown({
    Name = "Select Skill Slots",
    Options = {"1", "2", "3", "4", "5"},
    CurrentOption = {},
    Flag = "AutoSkillSlots",
    MultipleOptions = true,
    Callback = function(val)
        val = type(val) == "table" and val or {val}
        State.autoSkillSlots = {}
        for _, v in ipairs(val) do
            table.insert(State.autoSkillSlots, tonumber(v))
        end
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Skip Cutscenes",
    CurrentValue = false,
    Flag         = "AutoSkipCutscenes",
    Callback     = function(val) State.skipCutscenesEnabled = val end,
})

FarmTab:CreateToggle({
    Name         = "Auto Retry",
    CurrentValue = State.autoRetry,
    Flag         = "AutoRetry",
    Callback     = function(val)
        State.autoRetry = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Lobby",
    CurrentValue = State.autoLobby,
    Flag         = "AutoLobby",
    Callback     = function(val)
        State.autoLobby = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Return To Lobby After X Games",
    CurrentValue = false,
    Flag         = "ReturnToLobbyGamesEnabled",
    Callback     = function(val)
        State.returnToLobbyGamesEnabled = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Return To Lobby After X Games",
    Range        = {1, 300},
    Increment    = 1,
    CurrentValue = State.returnToLobbyGames,
    Flag         = "ReturnToLobbyGames",
    Callback     = function(val)
        State.returnToLobbyGames = val
    end,
})

-- ===== TAB: Webhook =====
local WebhookTab = Window:CreateTab("Webhook", "link")

WebhookTab:CreateInput({
    Name                   = "Webhook URL",
    CurrentValue           = "",
    Flag                   = "WebhookUrl",
    PlaceholderText        = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback               = function(text)
        local trimmed = text:match("^%s*(.-)%s*$")
        State.webhookUrl = (trimmed ~= "" and trimmed:match("^https://")) and trimmed or nil
    end,
})

WebhookTab:CreateInput({
    Name                     = "Discord User ID (for drop/family pings)",
    CurrentValue             = "",
    Flag                     = "WebhookDiscordId",
    PlaceholderText          = "Your Discord user ID...",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(text)
        local trimmed = text:match("^%s*(.-)%s*$")
        State.discordUserId = trimmed ~= "" and trimmed or nil
    end,
})

WebhookTab:CreateToggle({
    Name         = "Send Webhook On Round End",
    CurrentValue = false,
    Flag         = "WebhookEnabled",
    Callback     = function(val) State.webhookEnabled = val end,
})

WebhookTab:CreateButton({
    Name     = "Test Webhook",
    Callback = function()
        if not State.webhookUrl then
            Util.notify("Webhook", "No webhook URL set!", 3, "alert-triangle")
            return
        end
        local HttpService = game:GetService("HttpService")
        local requestFunc = syn and syn.request or request or http_request or getgenv().request
        if not requestFunc then return end
        local payload = HttpService:JSONEncode({
            username = "LixHub",
            embeds = {{
                title       = "Test Webhook",
                description = "Webhook is working correctly!",
                color       = 0x5865F2,
                footer      = { text = "LixHub • discord.gg/cYKnXE2Nf8" },
                timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
        pcall(function()
            requestFunc({ Url = State.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
        end)
        Util.notify("Webhook", "Test sent!", 3, "check")
    end,
})

-- ===== TAB: Misc =====
local MiscTab = Window:CreateTab("Misc", "settings")

MiscTab:CreateButton({
    Name     = "Copy Discord Invite To Clipboard",
    Callback = function()
        setclipboard("https://discord.gg/cYKnXE2Nf8")
        Util.notify("Discord Invite", "Invite copied to clipboard!", 3, "check")
    end,
})

MiscTab:CreateSection("Auto Roll")

MiscTab:CreateToggle({
    Name         = "Auto Roll Family",
    CurrentValue = false,
    Flag         = "AutoRollFamily",
    Callback     = function(val)
        if val then
            startAutoRoll()
        else
            stopAutoRoll()
        end
    end,
})

MiscTab:CreateDropdown({
    Name            = "Stop Rolling On x Family",
    Options         = familyDropdownOptions,
    CurrentOption   = {},
    Flag            = "AutoRollTargetFamilies",
    MultipleOptions = true,
    Callback        = function(val)
        RollState.targetFamilies = type(val) == "table" and val or {val}
    end,
})

MiscTab:CreateSection("Auto Boosts")

MiscTab:CreateToggle({
    Name         = "Auto Use Boosts",
    CurrentValue = false,
    Flag         = "AutoUseBoosts",
    Callback     = function(val)
        State.autoUseBoosts = val
    end,
})

MiscTab:CreateToggle({
    Name         = "Auto Purchase Boosts",
    CurrentValue = false,
    Flag         = "AutoPurchaseBoosts",
    Callback     = function(val)
        State.autoPurchaseBoosts = val
    end,
})

MiscTab:CreateDropdown({
    Name            = "Select Boosts To Buy",
    Options         = {"XP", "Gold", "Luck"},
    CurrentOption   = {},
    Flag            = "autoPurchaseBoostsSelection",
    MultipleOptions = true,
    Callback        = function(val)
        State.autoPurchaseBoostsSelection = type(val) == "table" and val or {val}
    end,
})

MiscTab:CreateDropdown({
    Name            = "Select Currency To Buy Boosts",
    Options         = {"Gems", "Candy Canes", "Wave Coins"},
    CurrentOption   = {},
    Flag            = "autoPurchaseBoostsCurrencySelection",
    MultipleOptions = false,
    Callback        = function(val)
        State.autoPurchaseBoostsCurrencySelection = type(val) == "table" and val[1] or val
    end,
})

MiscTab:CreateSection("Misc")

MiscTab:CreateToggle({
    Name = "Anti AFK (No kick message)", CurrentValue = false, Flag = "AntiAfkKickToggle",
    Info = "Prevents roblox kick message.",
    Callback = function(Value) State.AntiAfkKickEnabled = Value end,
})

task.spawn(function()
    player.Idled:Connect(function()
        if State.AntiAfkKickEnabled then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end)

MiscTab:CreateToggle({
    Name         = "Auto Execute Script",
    CurrentValue = false,
    Flag         = "EnableAutoExecute",
    Callback     = function(val)
        if not queue_on_teleport then
            return
        end
        if val then
            local queuedScript = string.format([[
                getgenv().__LIXHUB_RUNS = %d
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader"))()
            ]], State.sessionRuns)
            queue_on_teleport(queuedScript)
        else
            updateQueuedCounter()
        end
    end,
})

MiscTab:CreateButton({
    Name     = "Check If Shadow Banned",
    Callback = function()
        local _, d = pcall(function() return GET:InvokeServer("Functions", "Settings", "Blur", "Off") end)
        if d and d.Disabled == "Delayed Ban" then
            Util.notify("Shadow Ban Detected", "You got shadow banned", 6, "frown")
        else
            Util.notify("Shadow Ban Not Detected", "You are not shadow banned", 6, "smile")
        end
    end,
})

MiscTab:CreateToggle({
    Name         = "Auto Upgrade Gear",
    CurrentValue = false,
    Flag         = "AutoUpgradeGear",
    Callback     = function(val)
        State.autoUpgradeGear = val
        if val then
            startAutoUpgrade()
        else
            stopAutoUpgrade()
        end
    end,
})

MiscTab:CreateToggle({
    Name         = "Auto Claim Achievements",
    CurrentValue = false,
    Flag         = "AutoClaimAchievements",
    Callback     = function(val)
        if val then
            task.spawn(autoClaimAchievements)
        end
        State.autoClaimAchievements = val
    end,
})

MiscTab:CreateButton({
    Name     = "Return To Lobby",
    Callback = function()
        Util.notify("Return To Lobby", "Returning to lobby...", 3, "corner-down-left")
        game:GetService("TeleportService"):Teleport(14916516914, player)
    end,
})

-- ==================== INIT ====================
if not isInLobby() and not isInMainMenu() then
    setupAutoEscape()
end

Rayfield:LoadConfiguration()
