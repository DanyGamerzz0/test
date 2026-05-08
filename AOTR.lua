if not game:IsLoaded() then
    game.Loaded:Wait()
end

getgenv().RAYFIELD_SECURE = true
getgenv().RAYFIELD_ASSET_ID = 77799463979503
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local script_version = "V0.16"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

repeat task.wait(0.5) until
    ReplicatedStorage:FindFirstChild("Assets") and
    ReplicatedStorage.Assets:FindFirstChild("Remotes") and
    ReplicatedStorage.Assets.Remotes:FindFirstChild("POST") and
    ReplicatedStorage.Assets.Remotes:FindFirstChild("GET")

if not isInLobby() then
repeat task.wait(0.5) until workspace:GetAttribute("Type") ~= nil
repeat task.wait(0.5) until #getactors() > 0
end

local POST = ReplicatedStorage.Assets.Remotes.POST
local GET  = ReplicatedStorage.Assets.Remotes.GET

local State = {
    syncEnabled          = false,
    syncedPosition       = nil,
    oldIndex             = nil,
    inHook               = false,
    escapeEnabled        = false,
    waitBeforeFarming    = false,
    waitFarmSeconds      = 15,
    waitLastTitanSeconds = 30,
    floatHeight          = 520,
    attackConnection     = nil,
    farmActive           = false,
    attackInterval       = 0.3,
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
    sessionRuns = 0,
    autoJoinMissions       = false,
    autoJoinMissionMap     = "",
    autoJoinMissionObj     = "",
    autoJoinMissionDiff    = "",
    autoJoinMissionMods    = {},

    autoJoinRaids          = false,
    autoJoinRaidType       = "",
    autoJoinRaidDiff       = "",
    autoJoinRaidMods       = {},

    autoJoinWaves          = false,
    autoJoinWavesMap       = "",
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

-- ==================== COLLISION ====================
local noclipConnection = nil
local currentTarget = nil
local isReloading = false
local Util = {}
local PERK_RARITIES = {}
local autoJoinConnection = nil
local autoJoinProcessing = false

function Util.notify(title, content, duration, image)
    Rayfield:Notify({
        Title = title or "Notification",
        Content = content or "",
        Duration = duration or 3,
        Image = image or nil,

    })
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
-- The old code slammed BodyPosition.Position directly to the destination, which
-- made Roblox physics move the character as fast as it physically could regardless
-- of any P/D value. Travel time was not controllable that way.
--
-- Fix: we maintain a "lerp cursor" (lerpCurrent) that advances toward lerpTarget at
-- exactly State.tweenSpeed studs/sec every frame. BodyPosition.P is set very high so
-- the character tracks the cursor tightly. The cursor speed is now the only thing
-- that determines how fast you cross the map between titans.

local lerpCurrent    = nil
local lerpTarget     = nil
local lerpGyroTarget = nil

RunService.Heartbeat:Connect(function(dt)
    if not lerpTarget or not Movers.bodyPos then return end
    if not lerpCurrent then lerpCurrent = rootPart.Position end
    local remaining = (lerpTarget - lerpCurrent).Magnitude
    if remaining < 0.05 then
        lerpCurrent = lerpTarget
    else
        local step = math.min(State.tweenSpeed * dt, remaining)
        lerpCurrent = lerpCurrent + (lerpTarget - lerpCurrent).Unit * step
    end
    Movers.bodyPos.Position = lerpCurrent
    if lerpGyroTarget then
        Movers.bodyGyro.CFrame = lerpGyroTarget
    end
end)

local function ensureBodyMovers(targetCFrame)
    disableCollision()
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.AutoRotate    = false
    end
    if not Movers.bodyPos then
        Movers.bodyPos          = Instance.new("BodyPosition")
        Movers.bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        Movers.bodyPos.P        = 1e5  -- high so it tracks the lerp cursor precisely
        Movers.bodyPos.D        = 1000
        Movers.bodyPos.Name     = "_FarmPos"
        Movers.bodyPos.Parent   = rootPart
    end
    if not Movers.bodyGyro then
        Movers.bodyGyro            = Instance.new("BodyGyro")
        Movers.bodyGyro.MaxTorque  = Vector3.new(1e5, 1e5, 1e5)
        Movers.bodyGyro.P          = 1e5
        Movers.bodyGyro.D          = 1000
        Movers.bodyGyro.Name       = "_FarmGyro"
        Movers.bodyGyro.Parent     = rootPart
    end
    lerpTarget     = targetCFrame.Position
    lerpGyroTarget = targetCFrame
    if not lerpCurrent then lerpCurrent = rootPart.Position end
end

local function removeBodyMovers()
    if Movers.bodyPos  then Movers.bodyPos:Destroy();  Movers.bodyPos  = nil end
    if Movers.bodyGyro then Movers.bodyGyro:Destroy(); Movers.bodyGyro = nil end
    lerpCurrent    = nil
    lerpTarget     = nil
    lerpGyroTarget = nil
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
    local reloadsLeft, segmentsLeft = 0, 0
    for i = 1, 3 do
        local c = rig:FindFirstChild("Left_" .. i, true)
        if c and c:GetAttribute("Used") == nil then reloadsLeft += 1 end
    end
    local lh = rig:FindFirstChild("LeftHand")
    if lh then
        for i = 1, 7 do
            local b = lh:FindFirstChild("Blade_" .. i)
            if b and b:GetAttribute("Broken") == nil then segmentsLeft += 1 end
        end
    end
    return reloadsLeft, segmentsLeft
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
    currentTarget = nil
    isReloading = false
    print("[LixHub] Auto farm stopped")

    if State.attackConnection then
        State.attackConnection:Disconnect()
        State.attackConnection = nil
    end

    removeBodyMovers()
    disableSync()
    stopLobbyTimer()
    Util.notify("Auto Farm", "Farm stopped.", 3, "cog")
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
    print("Failsafe timer started.")
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

local function startAutoAttack()
    if isInLobby() then return end
    if State.attackConnection then
        State.attackConnection:Disconnect()
        State.attackConnection = nil
    end

    State.stopRequested = false
    State.farmActive    = true
    print("[LixHub] Auto farm starting...")
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

        -- proactive reload check runs ALWAYS, before any early returns
        local reloadsLeft, segmentsLeft = getBladeStatus()

        if segmentsLeft <= 0 and not isReloading then
            isReloading = true
            print("[LixHub] Blade fully broken — swapping blade")
            GET:InvokeServer("Blades", "Reload")
            task.delay(1, function() isReloading = false end)
        end

        if reloadsLeft <= 0 and not isReloading then
            isReloading = true
            local refillPoint = workspace:FindFirstChild("Refill", true) or
                (workspace.Unclimbable and workspace.Unclimbable.Props and
                workspace.Unclimbable.Props.HQ and workspace.Unclimbable.Props.HQ.GasTanks and
                workspace.Unclimbable.Props.HQ.GasTanks.Refill)

            if refillPoint then
                print("[LixHub] Out of blade cassettes — spoofing position to refill station")
                local titanSyncPos = State.syncedPosition
                State.syncedPosition = refillPoint.Position + Vector3.new(0, 3, 0)
                task.wait(0.5)
                GET:InvokeServer("Attacks", "Reload", refillPoint)
                task.wait(0.3)
                State.syncedPosition = titanSyncPos
                print("[LixHub] Refill done — spoofed position back to titan")
            else
                print("[LixHub] Warning: Could not find refill point!")
                GET:InvokeServer("Attacks", "Reload", nil)
            end
            task.delay(2, function() isReloading = false end)
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

        if not lerpCurrent or (lerpTarget - lerpCurrent).Magnitude > 20 then return end

        POST:FireServer("Attacks", "Slash", true)
        local damage = 670 + math.random(55, 165)
        if math.random(1, 8) == 1 then damage = damage * math.random(138, 148) / 100 end
        POST:FireServer("Hitboxes", "Register", nape, math.floor(damage))
    end)

    Util.notify("Auto Farm", "Auto Farm Started", 3, "cog")
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

buildPerkRarities()

local function sendWebhook(roundData, playerData)
    if not State.webhookUrl then return end

    local r   = roundData
    local r2  = playerData

    local completed  = r.Completed == true
    local embedColor = completed and 0x57F287 or 0xED4245
    local resultText = completed and "Victory" or "Defeat"

    -- Title
    local missionType  = workspace:GetAttribute("Type")       or "Unknown"
    local objective    = workspace:GetAttribute("Objective")  or "Unknown"
    local difficulty   = workspace:GetAttribute("Difficulty") or "Unknown"
    local titleText    = string.format("Stage %s! - %d Run(s)", completed and "Completed" or "Failed", State.sessionRuns or 1)
    local subtitleText = string.format("%s - %s (%s) - %s", missionType, objective, difficulty, resultText)

    -- Duration from workspace
    local wsSeconds = workspace:GetAttribute("Seconds") or 0
    local duration  = string.format("%02d:%02d", math.floor(wsSeconds / 60), wsSeconds % 60)

    local stats       = r.Stats       or {}
    local obtained    = r.Obtained    or {}
    local currency    = r2 and r2.Currency    or {}
    local progression = r2 and r2.Progression or {}

    -- Shadow ban check
    local isShadowBanned = false
    pcall(function()
        local d = GET:InvokeServer("Functions", "Settings", "Blur", "Off")
        if d and d.Disabled == "Delayed Ban" then
            isShadowBanned = true
        end
    end)

    -- Streak
    local streak = player:GetAttribute("Streak") or 0

    -- Stats field
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

    -- Rewards with totals
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
        table.insert(rewardLines, "+1 " .. tostring(drop))
        table.insert(specialDrops, tostring(drop))
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
                { name = "Player",   value = "||" .. player.Name .. "||", inline = true },
                { name = "Duration", value = duration,                     inline = true },
                { name = "\u{200B}", value = "\u{200B}",                   inline = true },
                { name = "Game Stats",    value = statsText,   inline = false },
                { name = "Rewards",  value = rewardsText, inline = false },
            },
            footer    = { text = "LixHub • discord.gg/cYKnXE2Nf8" },
            timestamp = timestamp,
        }}
    }

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
        print("[LixHub] Retry button not found")
        return false
    end
    GuiService.SelectedObject = retry
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    print("[LixHub] Fired retry via UI navigation")
    return true
end

local function leaveViaNavigation()
    local leaveBtn = player.PlayerGui.Interface.Rewards.Main.Info.Main.Buttons:FindFirstChild("Leave_2")
    if not leaveBtn then 
        print("[LixHub] Leave button not found")
        return false
    end
    GuiService.SelectedObject = leaveBtn
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    print("[LixHub] Fired leave via UI navigation")
    return true
end

local function onRoundEnd(encoded)
    if roundEndDebounce then return end
    roundEndDebounce = true
    task.spawn(function()
        local ok, err = pcall(function()
            State.sessionRuns += 1
            print("[LixHub] Round ended — processing results")
            resetLobbyTimer()

            local roundData, playerData
            if encoded then
                local ok2, decoded = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(encoded)
                end)
                if ok2 and decoded then
                    roundData  = decoded.round
                    playerData = decoded.player
                end
            end

            if State.webhookEnabled and State.webhookUrl and roundData then
                sendWebhook(roundData, playerData)
            end

            task.wait(5)
            if State.autoRetry then
                Util.notify("Auto Farm", "Retrying...", 3, "cog")
                while State.autoRetry do
                    print("[LixHub] Attempting retry via UI navigation...")
                    retryViaNavigation()
                    task.wait(3)
                end
            elseif State.autoLobby then
                Util.notify("Auto Farm", "Returning to lobby...", 3, "house")
                while State.autoLobby do
                    print("[LixHub] Attempting leave via UI navigation...")
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
if not isInLobby() then
local bridge = Instance.new("BindableEvent")
bridge.Parent = game:GetService("ReplicatedStorage")
bridge.Name = "__LixBridge"
bridge.Event:Connect(onRoundEnd)
end

if not isInLobby() then
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
                    if bridge then
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

local function joinMission()
    print("[LixHub] Auto Join: Creating mission —", State.autoJoinMissionMap, State.autoJoinMissionObj, State.autoJoinMissionDiff)

    -- Create the lobby, server returns the mission instance on success
    local result = GET:InvokeServer("S_Missions", "Create", {
        Difficulty = State.autoJoinMissionDiff,
        Type       = "Missions",
        Objective  = State.autoJoinMissionObj,
        Name       = State.autoJoinMissionMap,
    })

    -- Validate: server returns the ReplicatedStorage.Missions.<Map> instance
    local expectedMission = ReplicatedStorage:FindFirstChild("Missions") and
                            ReplicatedStorage.Missions:FindFirstChild(State.autoJoinMissionMap)

    if not result or result ~= expectedMission then
        warn("[LixHub] Auto Join: Create failed — unexpected result:", result)
        return false
    end

    print("[LixHub] Auto Join: Lobby created successfully")

    -- Apply modifiers, each should return true
    for _, mod in ipairs(State.autoJoinMissionMods) do
        local modResult = GET:InvokeServer("S_Missions", "Modify", mod)
        if modResult ~= true then
            warn("[LixHub] Auto Join: Modifier failed —", mod, "got:", modResult)
        else
            print("[LixHub] Auto Join: Applied modifier —", mod)
        end
        task.wait(0.1)
    end

    -- Start the game
    print("[LixHub] Auto Join: Starting mission...")
    GET:InvokeServer("S_Missions", "Start")

    return true
end

local function joinRaid()
    local titanMap = RAID_TITAN_MAP[State.autoJoinRaidType]
    if not titanMap then
        warn("[LixHub] Auto Join Raid: Unknown titan type —", State.autoJoinRaidType)
        return false
    end

    print("[LixHub] Auto Join Raid:", State.autoJoinRaidType, "on", titanMap, "—", State.autoJoinRaidDiff)

    local payload = {
        Type       = "Raids",
        Objective  = State.autoJoinRaidType,
        Difficulty = State.autoJoinRaidDiff,
        Name       = titanMap,
    }

    -- Colossal requires a minimum player count
    if State.autoJoinRaidType == "Colossal Titan" then
        payload.Minimum = 3
    end

    local result = GET:InvokeServer("S_Missions", "Create", payload)

    -- Validate: same pattern as missions
    local expectedMission = ReplicatedStorage:FindFirstChild("Missions") and
                            ReplicatedStorage.Missions:FindFirstChild(titanMap)

    if not result or result ~= expectedMission then
        warn("[LixHub] Auto Join Raid: Create failed — unexpected result:", result)
        return false
    end

    print("[LixHub] Auto Join Raid: Lobby created successfully")

    -- Apply modifiers
    for _, mod in ipairs(State.autoJoinRaidMods) do
        local modResult = GET:InvokeServer("S_Missions", "Modify", mod)
        if modResult ~= true then
            warn("[LixHub] Auto Join Raid: Modifier failed —", mod, "got:", modResult)
        else
            print("[LixHub] Auto Join Raid: Applied modifier —", mod)
        end
        task.wait(0.1)
    end

    print("[LixHub] Auto Join Raid: Starting...")
    GET:InvokeServer("S_Missions", "Start")

    return true
end

local function joinWaves()
    print("[LixHub] Auto Join Waves:", State.autoJoinWavesMap)

    local result = GET:InvokeServer("S_Missions", "Create", {
        Difficulty = "Easy",
        Type       = "Waves",
        Name       = State.autoJoinWavesMap,
        Objective  = "Waves",
    })

    local expectedMission = ReplicatedStorage:FindFirstChild("Missions") and
                            ReplicatedStorage.Missions:FindFirstChild(State.autoJoinWavesMap)

    if not result or result ~= expectedMission then
        warn("[LixHub] Auto Join Waves: Create failed — unexpected result:", result)
        return false
    end

    print("[LixHub] Auto Join Waves: Starting...")
    GET:InvokeServer("S_Missions", "Start")

    return true
end

local function checkAndJoin()
    if not isInLobby() then return end
    if autoJoinProcessing then return end
    if not State.autoJoinMissions and not State.autoJoinRaids and not State.autoJoinWaves then return end

    autoJoinProcessing = true

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
                print("[LixHub] Auto Join: Successfully loaded into game")
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

startAutoJoinLoop()

local JoinerTab = Window:CreateTab("Auto Join", "plug-zap")

JoinerTab:CreateSection("Missions")

JoinerTab:CreateToggle({
    Name         = "Auto Join Missions",
    Flag         = "AutoJoinMissions",
    CurrentValue = false,
    Callback     = function(val)
        State.autoJoinMissions = val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Map",
    Flag         = "AutoJoinMissionMap",
    Options      = {"Shiganshina", "Trost", "Outskirts", "Forest", "Utgard", "Docks", "Stohess", "Chapel"},
    CurrentOption = {},
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinMissionMap = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Objective",
    Flag         = "AutoJoinMissionObj",
    Options      = {"Skirmish", "Breach", "Random"},
    CurrentOption = {},
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinMissionObj = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Difficulty",
    Flag         = "AutoJoinMissionDiff",
    Options      = {"Easy", "Normal", "Hard", "Severe", "Aberrant"},
    CurrentOption = {},
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinMissionDiff = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Modifiers",
    Flag         = "AutoJoinMissionMods",
    Options      = {"No Perks", "No Skills", "No Memories", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Cannon", "Time Trial", "Boring", "Simple"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback     = function(val)
        State.autoJoinMissionMods = type(val) == "table" and val or {val}
    end,
})

JoinerTab:CreateSection("Raids")

JoinerTab:CreateToggle({
    Name         = "Auto Join Raids",
    Flag         = "AutoJoinRaids",
    CurrentValue = false,
    Callback     = function(val)
        State.autoJoinRaids = val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Raid",
    Flag         = "AutoJoinRaidType",
    Options      = {"Attack Titan", "Armored Titan", "Female Titan", "Colossal Titan"},
    CurrentOption = {},
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinRaidType = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Difficulty",
    Flag         = "AutoJoinRaidDiff",
    Options      = {"Hard", "Severe", "Aberrant"},
    CurrentOption = {},
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinRaidDiff = type(val) == "table" and val[1] or val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Modifiers",
    Flag         = "AutoJoinRaidMods",
    Options      = {"No Perks", "No Skills", "No Memories", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Cannon", "Time Trial", "Boring", "Simple"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback     = function(val)
        State.autoJoinRaidMods = type(val) == "table" and val or {val}
    end,
})

JoinerTab:CreateSection("Waves")

JoinerTab:CreateToggle({
    Name         = "Auto Join Waves",
    Flag         = "AutoJoinWaves",
    CurrentValue = false,
    Callback     = function(val)
        State.autoJoinWaves = val
    end,
})

JoinerTab:CreateDropdown({
    Name         = "Select Map",
    Flag         = "AutoJoinWavesMap",
    Options      = {"Trost"},
    CurrentOption = {},
    MultipleOptions = false,
    Callback     = function(val)
        State.autoJoinWavesMap = type(val) == "table" and val[1] or val
    end,
})


-- ===== TAB: Farm =====
local FarmTab = Window:CreateTab("Main", "play")

FarmTab:CreateToggle({
    Name         = "Auto Farm",
    Flag         = "AutoFarm",
    CurrentValue = false,
    Callback     = function(val)
        if val then
            task.defer(startAutoAttack)
        else
            stopAutoAttack()
        end
    end,
})

FarmTab:CreateSection("Auto Farm Settings")

FarmTab:CreateSlider({
    Name         = "Auto Farm Speed",
    Flag         = "AutoFarmSpeed",
    Range        = {100, 500},
    Increment    = 1,
    CurrentValue = State.tweenSpeed,
    Callback     = function(val)
        State.tweenSpeed = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Float Height",
    Flag         = "FloatHeight",
    Range        = {100, 300},
    Increment    = 10,
    CurrentValue = State.floatHeight,
    Callback     = function(val)
        State.floatHeight = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Wait Before Farming",
    Flag         = "WaitBeforeFarming",
    CurrentValue = State.waitBeforeFarming,
    Callback     = function(val) State.waitBeforeFarming = val end,
})

FarmTab:CreateSlider({
    Name         = "Wait x Seconds Before Starting Farming",
    Flag         = "WaitFarmSeconds",
    Range        = {15, 600},
    Increment    = 1,
    CurrentValue = State.waitFarmSeconds,
    Callback     = function(val) State.waitFarmSeconds = val end,
})

FarmTab:CreateSlider({
    Name         = "Wait x Seconds Before Killing Last Titan",
    Flag         = "WaitLastTitanSeconds",
    Range        = {30, 600},
    Increment    = 1,
    CurrentValue = State.waitLastTitanSeconds,
    Callback     = function(val) State.waitLastTitanSeconds = val end,
})

FarmTab:CreateToggle({
    Name         = "Auto Escape Grab",
    Flag         = "AutoEscapeGrab",
    CurrentValue = false,
    Callback     = function(val) State.escapeEnabled = val end,
})

FarmTab:CreateToggle({
    Name         = "Return To Lobby After X Mins",
    Flag         = "ReturnToLobbyEnabled",
    CurrentValue = State.returnToLobbyEnabled,
    Callback     = function(val)
        State.returnToLobbyEnabled = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Return To Lobby After X Mins",
    Flag         = "ReturnToLobbyMinutes",
    Range        = {1, 120},
    Increment    = 1,
    CurrentValue = State.returnToLobbyMinutes,
    Callback     = function(val)
        State.returnToLobbyMinutes = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Retry",
    Flag         = "AutoRetry",
    CurrentValue = State.autoRetry,
    Callback     = function(val)
        State.autoRetry = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Lobby",
    Flag         = "AutoLobby",
    CurrentValue = State.autoLobby,
    Callback     = function(val)
        State.autoLobby = val
    end,
})
-- ===== TAB: Webhook =====

local WebhookTab = Window:CreateTab("Webhook", "link")

WebhookTab:CreateInput({
    Name                   = "Webhook URL",
    Flag         = "WebhookUrl",
    CurrentValue           = "",
    PlaceholderText        = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback               = function(text)
        local trimmed = text:match("^%s*(.-)%s*$")
        State.webhookUrl = (trimmed ~= "" and trimmed:match("^https://")) and trimmed or nil
    end,
})

WebhookTab:CreateInput({
    Name                     = "Discord User ID (for drop pings)",
    Flag         = "WebhookDiscordId",
    CurrentValue             = "",
    PlaceholderText          = "Your Discord user ID...",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(text)
        local trimmed = text:match("^%s*(.-)%s*$")
        State.discordUserId = trimmed ~= "" and trimmed or nil
    end,
})

WebhookTab:CreateToggle({
    Name         = "Send Webhook On Round End",
    Flag         = "WebhookEnabled",
    CurrentValue = false,
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

-- ===== TAB: Utility =====
local MiscTab = Window:CreateTab("Misc", "settings")

MiscTab:CreateToggle({
    Name         = "Auto Execute Script",
    CurrentValue = false,
    Flag         = "EnableAutoExecute",
    Callback     = function(val)
        if not queue_on_teleport then
            Util.notify("Auto Execute", "Your executor does not support queue_on_teleport", 5, "alert-triangle")
            return
        end
        if val then
            queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/DanyGamerzz0/test/refs/heads/main/AOTR.lua"))()')
            Util.notify("Auto Execute", "Script will auto execute on teleport", 3, "check")
        else
            queue_on_teleport("")
            Util.notify("Auto Execute", "Auto execute disabled", 3, "x")
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

MiscTab:CreateButton({
    Name     = "Return To Lobby",
    Callback = function()
        Util.notify("Return To Lobby", "Returning to lobby...", 3, "corner-down-left")
        game:GetService("TeleportService"):Teleport(14916516914, player)
    end,
})

-- ==================== INIT ====================
if not isInLobby() then
setupAutoEscape()
end
Rayfield:LoadConfiguration()
