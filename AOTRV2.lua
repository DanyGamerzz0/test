if not game:IsLoaded() then
    game.Loaded:Wait()
end

getgenv().RAYFIELD_SECURE = true
getgenv().RAYFIELD_ASSET_ID = 77799463979503
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local script_version = "V0.6"

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
    autoJoinDelaySecs = 3,
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
    autoJoinMissionObj     = "",
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
-- "idle" | "swapping" | "refilling"
local ReloadState     = "idle"
local RaidReloadState = "idle"
local Util = {}
local PERK_RARITIES = {}
local ITEM_RARITIES = {}
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
local lerpCurrent    = nil
local lerpTarget     = nil
local lerpGyroTarget = nil
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
    if Movers.bodyPos  then Movers.bodyPos:Destroy();  Movers.bodyPos  = nil end
    if Movers.bodyGyro then Movers.bodyGyro:Destroy(); Movers.bodyGyro = nil end
    targetPosition = nil
    targetGyro     = nil
    if rootPart then rootPart.AssemblyLinearVelocity = Vector3.zero end
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

local function findRefillPoint()
    local tanks = workspace.Unclimbable
        and workspace.Unclimbable.Props
        and workspace.Unclimbable.Props.HQ
        and workspace.Unclimbable.Props.HQ.GasTanks
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

        local cassettesLeft, segmentsLeft = getBladeStatus()

        -- Cassette swap — spam Blades/Reload until server returns true
        if segmentsLeft <= 0 and cassettesLeft > 0 and ReloadState == "idle" then
            ReloadState = "swapping"
            print("[LixHub] Farm: Blade broken, swapping cassette —", cassettesLeft, "left")
            task.spawn(function()
                local result
                repeat
                    result = GET:InvokeServer("Blades", "Reload")
                    task.wait()
                    local c, s = getBladeStatus()
                    if s > 0 then break end
                until result == true or ReloadState ~= "swapping"
                print("[LixHub] Farm: Blade swap confirmed —", tostring(result))
                ReloadState = "idle"
            end)
            return
        end

        if segmentsLeft <= 0 and cassettesLeft <= 0 and ReloadState == "idle" then
            ReloadState = "refilling"
            print("[LixHub] Farm: Out of cassettes — refilling")
            task.spawn(function()
                local refillPoint = findRefillPoint()
                repeat
                    GET:InvokeServer("Attacks", "Reload", refillPoint)
                    task.wait()
                    local c, _ = getBladeStatus()
                    if c > 0 then break end
                until ReloadState ~= "refilling"
                -- wait for segments to replicate before releasing
                repeat task.wait() until (select(2, getBladeStatus())) > 0 or ReloadState ~= "refilling"
                print("[LixHub] Farm: Refill done")
                ReloadState = "idle"
            end)
            return
        end

        -- Block all attacks while any reload is in progress
        if ReloadState ~= "idle" then return end

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
        if horizontalDist > 75 then return end

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
                { name = "\u{200B}",   value = "\u{200B}",                   inline = true },
                { name = "Game Stats", value = statsText,                    inline = false },
                { name = "Rewards",    value = rewardsText,                  inline = false },
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
            if forceLobby then
                Util.notify("Auto Farm", "Game limit reached, returning to lobby...", 3, "house")
                while true do
                    leaveViaNavigation()
                    task.wait(3)
                end
            elseif State.autoRetry then
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
        print("[LixHub] Raids: Collider not found, falling back to player position")
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
            print("[LixHub] Raids: Opening free chest")
            clickButton(freeBtn)
            -- wait for finish button to reappear (animation done)
            waitForFinishVisible()
        end
    end

    if Raids.State.autoOpenEmperorChests then
        local premiumBtn = chests:FindFirstChild("Premium")
        if premiumBtn and premiumBtn.Visible then
            print("[LixHub] Raids: Opening emperor chest")
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
        print("[LixHub] Raids: Finish clicked")
    end)
end

function Raids.handleTitan(titan, useVulnerable)
    local titanRoot = titan:FindFirstChild("HumanoidRootPart")
    if not titanRoot then return end
    local nape = Raids.getNape(titan)
    if not nape then return end

    State.syncedPosition = titanRoot.Position + titanRoot.CFrame.LookVector * -7.5 + Vector3.new(0, 12, 0)
    local targetPos = titanRoot.Position + Vector3.new(0, State.floatHeight, 0)
    ensureBodyMovers(CFrame.lookAt(targetPos, titanRoot.Position))

    if not lerpCurrent or (lerpTarget - lerpCurrent).Magnitude > 500 then return end

    if useVulnerable then
        local vulnSpot = Raids.getVulnerableSpot(titan)
        if vulnSpot then
            Raids.registerHitVuln(vulnSpot)
        else
            Raids.registerHit(nape, nil)
        end
    else
        Raids.registerHit(nape, nil)
    end
end

local cannonImpactConnection = nil

local cannonLoopActive = false

local function stopCannonLoop()
    cannonLoopActive = false
end

function Raids.stop()
    Raids.State.stopRequested = true
    Raids.State.active        = false
    Raids.State.phase         = "defend"
    RaidReloadState           = "idle"
    stopCannonLoop()  -- add this
    if Raids.State.connection then
        Raids.State.connection:Disconnect()
        Raids.State.connection = nil
    end
    removeBodyMovers()
    disableSync()
    Util.notify("Auto Farm Raids", "Raid farm stopped.", 3, "cog")
    print("[LixHub] Raids: Stopped")
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
    print("[LixHub] Raids: Detected objective —", objective)

    if objective == "Attack Titan" then
        Raids.startEren()
    elseif objective == "Armored Titan" then
        Raids.startArmored()
    elseif objective == "Female Titan" then
        Raids.startFemale() -- no cutscene wait, QTE happens during cutscene
    else
        Util.notify("Auto Farm Raids", "Unknown raid objective: " .. tostring(objective), 5, "alert-triangle")
        print("[LixHub] Raids: Unknown objective —", objective)
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
    print("[LixHub] Raids: Starting — Phase 1: Defend Eren")
    Util.notify("Auto Farm Raids", "Phase 1: Defending Eren...", 3, "shield")

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

        local cassettesLeft, segmentsLeft = getBladeStatus()

        -- Cassette swap — spam Blades/Reload until server returns true
        if segmentsLeft <= 0 and cassettesLeft > 0 and RaidReloadState == "idle" then
            RaidReloadState = "swapping"
            print("[LixHub] Raids: Blade broken, swapping cassette —", cassettesLeft, "left")
            task.spawn(function()
                local result
                repeat
                    result = GET:InvokeServer("Blades", "Reload")
                    task.wait()
                    local c, s = getBladeStatus()
                    if s > 0 then break end
                until result == true or RaidReloadState ~= "swapping"
                print("[LixHub] Raids: Blade swap confirmed —", tostring(result))
                RaidReloadState = "idle"
            end)
            return
        end

        if segmentsLeft <= 0 and cassettesLeft <= 0 and RaidReloadState == "idle" then
            RaidReloadState = "refilling"
            print("[LixHub] Raids: Out of cassettes — refilling")
            task.spawn(function()
                local refillPoint = findRefillPoint()
                repeat
                    GET:InvokeServer("Attacks", "Reload", refillPoint)
                    task.wait()
                    local c, _ = getBladeStatus()
                    if c > 0 then break end
                until RaidReloadState ~= "refilling"
                -- wait for segments to replicate before releasing
                repeat task.wait() until (select(2, getBladeStatus())) > 0 or RaidReloadState ~= "refilling"
                print("[LixHub] Raids: Refill done")
                RaidReloadState = "idle"
            end)
            return
        end

        -- Block all attacks while any reload is in progress
        if RaidReloadState ~= "idle" then return end
        if Raids.State.phase == "cutscene" then return end

        tickAccum = tickAccum + dt
        if tickAccum < State.attackInterval then return end
        tickAccum = 0

        -- ===== PHASE 1: DEFEND EREN =====
-- ===== PHASE 1: DEFEND EREN =====
        if Raids.State.phase == "defend" then
            if Raids.getObjectiveValue("Defend_Eren") >= 1 then
                Raids.State.phase = "cutscene"
                print("[LixHub] Raids: Phase 1 done — waiting for cutscene...")
                Util.notify("Auto Farm Raids", "Cutscene... waiting for Phase 2", 3, "clock")
                
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
                        print("[LixHub] Raids: Cutscene done — Phase 2: Defeat Attack Titan")
                        Util.notify("Auto Farm Raids", "Phase 2: Defeat Attack Titan!", 3, "sword")
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
                    print("[LixHub] Raids: Attack Titan defeated — collecting chests")
                    Util.notify("Auto Farm Raids", "Raid complete! Collecting chests...", 3, "gift")
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

            Raids.handleTitan(titan, true)
        end
    end)

    Util.notify("Auto Farm Raids", "Raid Farm Started", 3, "shield")
end

    local function getColossalTitan()
        local titans = workspace:FindFirstChild("Titans")
        if not titans then return nil end
        local t = titans:FindFirstChild("Colossal_Titan")
        if not t then return nil end
        local hum = t:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        return t
    end

    local function getColossalHpPercent()
        local t = getColossalTitan()
        if not t then return 100 end
        local hum = t:FindFirstChild("Humanoid")
        if not hum then return 100 end
        return (hum.Health / hum.MaxHealth) * 100
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
    print("[LixHub] Armored Raid: Starting — Phase 1: Defend Boats")
    Util.notify("Auto Farm Raids", "Phase 1: Defending Boats...", 3, "shield")

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

        local cassettesLeft, segmentsLeft = getBladeStatus()

        if segmentsLeft <= 0 and cassettesLeft > 0 and RaidReloadState == "idle" then
            RaidReloadState = "swapping"
            print("[LixHub] Armored Raid: Blade broken, swapping cassette —", cassettesLeft, "left")
            task.spawn(function()
                local result
                repeat
                    result = GET:InvokeServer("Blades", "Reload")
                    task.wait()
                    local c, s = getBladeStatus()
                    if s > 0 then break end
                until result == true or RaidReloadState ~= "swapping"
                print("[LixHub] Armored Raid: Blade swap confirmed")
                RaidReloadState = "idle"
            end)
            return
        end

        if segmentsLeft <= 0 and cassettesLeft <= 0 and RaidReloadState == "idle" then
            RaidReloadState = "refilling"
            print("[LixHub] Armored Raid: Out of cassettes — refilling")
            task.spawn(function()
                local refillPoint = findRefillPoint()
                repeat
                    GET:InvokeServer("Attacks", "Reload", refillPoint)
                    task.wait()
                    local c, _ = getBladeStatus()
                    if c > 0 then break end
                until RaidReloadState ~= "refilling"
                repeat task.wait() until (select(2, getBladeStatus())) > 0 or RaidReloadState ~= "refilling"
                print("[LixHub] Armored Raid: Refill done")
                RaidReloadState = "idle"
            end)
            return
        end

        if RaidReloadState ~= "idle" then return end
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
                        Util.notify("Auto Farm Raids", "Phase 2: Defeat Armored Titan!", 3, "sword")
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
                    Util.notify("Auto Farm Raids", "Raid complete! Collecting chests...", 3, "gift")
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

            local nape = Raids.getNape(titan)
            if not nape then return end
            if not lerpCurrent or (lerpTarget - lerpCurrent).Magnitude > 500 then return end

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
    end)

    Util.notify("Auto Farm Raids", "Armored Raid Farm Started", 3, "shield")
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
    print("[LixHub] Female Raid: Starting — Phase 1: Defeat Female Titan")
    Util.notify("Auto Farm Raids", "Phase 1: Defeat Female Titan...", 3, "shield")

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
                print("[LixHub] Female Raid: Cutscene done —", notifyMsg)
                Util.notify("Auto Farm Raids", notifyMsg, 3, "sword")
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

    local function attackTitan(titan)
        local nape = Raids.getNape(titan)
        if not nape then return end
        if not lerpCurrent or (lerpTarget - lerpCurrent).Magnitude > 500 then return end
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
                print("[LixHub] Female Raid: Attack Titan appeared — waiting for cutscene")
                handleCutsceneTransition("attack_titan", "Phase 2: Defeat Attack Titan!")
                return
            end

            if not titan then return end
            attackTitan(titan)

        -- ===== PHASE 2: ATTACK TITAN =====
        elseif Raids.State.phase == "attack_titan" then
            local titan = getTitan("Attack_Titan")
            if titan then moveTo(titan) end

            if Raids.getObjectiveValue("Defeat_Attack_Titan") >= 1 then
                print("[LixHub] Female Raid: Attack Titan defeated — waiting for cutscene")
                handleCutsceneTransition("female_2", "Phase 3: Finish Female Titan!")
                return
            end

            if not titan then return end
            if titan:GetAttribute("State") == "Roar" then return end
            if titan:GetAttribute("State") == "Berserk_Mode" then return end
            attackTitan(titan)

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
                    print("[LixHub] Female Raid: Complete — collecting chests")
                    Util.notify("Auto Farm Raids", "Raid complete! Collecting chests...", 3, "gift")
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
            attackTitan(titan)
        end
    end)

    Util.notify("Auto Farm Raids", "Female Raid Farm Started", 3, "shield")
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
        print("[LixHub] Trying difficulty:", diff)
        local ok, result = pcall(createFn, diff)
        if ok and result then
            return true
        end
        print("[LixHub] Difficulty failed:", diff, "— trying next...")
        task.wait(0.5)
    end
    return false
end

local function joinMission()
    local function attemptCreate(diff)
        print("[LixHub] Auto Join: Creating mission —", State.autoJoinMissionMap, State.autoJoinMissionObj, diff)
        local result = GET:InvokeServer("S_Missions", "Create", {
            Difficulty = diff,
            Type       = "Missions",
            Objective  = State.autoJoinMissionObj,
            Name       = State.autoJoinMissionMap,
        })
        local expectedMission = ReplicatedStorage:FindFirstChild("Missions") and
                                ReplicatedStorage.Missions:FindFirstChild(State.autoJoinMissionMap)
        if not result or result ~= expectedMission then
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

    print("[LixHub] Auto Join: Lobby created successfully")
    for _, mod in ipairs(State.autoJoinMissionMods) do
        local modResult = GET:InvokeServer("S_Missions", "Modify", mod)
        if modResult ~= true then
            warn("[LixHub] Auto Join: Modifier failed —", mod, "got:", modResult)
        else
            print("[LixHub] Auto Join: Applied modifier —", mod)
        end
        task.wait(0.1)
    end
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

    local function attemptCreate(diff)
        print("[LixHub] Auto Join Raid:", State.autoJoinRaidType, "on", titanMap, "—", diff)

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

        local expectedMission = ReplicatedStorage:FindFirstChild("Missions") and
                                ReplicatedStorage.Missions:FindFirstChild(titanMap)

        if not result or result ~= expectedMission then
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

    print("[LixHub] Auto Join Raid: Lobby created successfully")

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

JoinerTab:CreateSlider({
    Name         = "Auto Join Delay (seconds)",
    Flag         = "AutoJoinDelay",
    Range        = {0, 60},
    Increment    = 1,
    CurrentValue = 3,
    Callback     = function(val)
        State.autoJoinDelaySecs = val
    end,
})

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
    Options      = {"Easy", "Normal", "Hard", "Severe", "Aberrant", "Hardest"},
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
    Options      = {"Hard", "Severe", "Aberrant","Hardest"},
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

FarmTab:CreateToggle({
    Name         = "Auto Farm Raids",
    Flag         = "AutoFarmRaids",
    CurrentValue = false,
    Callback     = function(val)
        if val then
            task.defer(Raids.start)
        else
            Raids.stop()
        end
    end,
})

FarmTab:CreateToggle({
    Name         = "Wait Before Killing Raid Boss",
    Flag         = "WaitBeforeRaidBoss",
    CurrentValue = false,
    Callback     = function(val) State.waitBeforeRaidBoss = val end,
})

FarmTab:CreateSlider({
    Name         = "Wait x Seconds Before Killing Raid Boss",
    Flag         = "WaitRaidBossSeconds",
    Range        = {5, 300},
    Increment    = 5,
    CurrentValue = 30,
    Callback     = function(val) State.waitRaidBossSeconds = val end,
})

FarmTab:CreateToggle({
    Name         = "Auto Open Chests",
    Flag         = "AutoOpenChests",
    CurrentValue = false,
    Callback     = function(val)
        Raids.State.autoOpenChests = val
    end,
})

FarmTab:CreateToggle({
    Name         = "Auto Open Emperor Chests",
    Flag         = "AutoOpenEmperorChests",
    CurrentValue = false,
    Callback     = function(val)
        Raids.State.autoOpenEmperorChests = val
    end,
})

FarmTab:CreateSection("Auto Farm Settings")

FarmTab:CreateSlider({
    Name         = "Auto Farm Speed",
    Flag         = "AutoFarmSpeed",
    Range        = {100, 500},
    Increment    = 1,
    CurrentValue = 300,
    Callback     = function(val)
        State.tweenSpeed = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Float Height",
    Flag         = "FloatHeight",
    Range        = {100, 300},
    Increment    = 10,
    CurrentValue = 200,
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

FarmTab:CreateToggle({
    Name         = "Return To Lobby After X Games",
    Flag         = "ReturnToLobbyGamesEnabled",
    CurrentValue = false,
    Callback     = function(val)
        State.returnToLobbyGamesEnabled = val
    end,
})

FarmTab:CreateSlider({
    Name         = "Return To Lobby After X Games",
    Flag         = "ReturnToLobbyGames",
    Range        = {1, 300},
    Increment    = 1,
    CurrentValue = State.returnToLobbyGames,
    Callback     = function(val)
        State.returnToLobbyGames = val
    end,
})

-- ===== TAB: Webhook =====
local WebhookTab = Window:CreateTab("Webhook", "link")

WebhookTab:CreateInput({
    Name                   = "Webhook URL",
    Flag                   = "WebhookUrl",
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
    Flag                     = "WebhookDiscordId",
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

-- ===== TAB: Misc =====
local MiscTab = Window:CreateTab("Misc", "settings")

MiscTab:CreateToggle({
    Name         = "Auto Upgrade Gear",
    Flag         = "AutoUpgradeGear",
    CurrentValue = false,
    Callback     = function(val)
        State.autoUpgradeGear = val
        if val then
            startAutoUpgrade()
            Util.notify("Auto Upgrade", "Auto gear upgrade enabled", 3, "arrow-up")
        else
            stopAutoUpgrade()
            Util.notify("Auto Upgrade", "Auto gear upgrade disabled", 3, "x")
        end
    end,
})

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
            local queuedScript = string.format([[
                getgenv().__LIXHUB_RUNS = %d
                loadstring(game:HttpGet("https://raw.githubusercontent.com/DanyGamerzz0/test/refs/heads/main/AOTRV2.lua"))()
            ]], State.sessionRuns)
            queue_on_teleport(queuedScript)
            Util.notify("Auto Execute", "Script will auto execute on teleport", 3, "check")
        else
            updateQueuedCounter()
            Util.notify("Auto Execute", "Auto execute disabled (run counter still persists)", 3, "x")
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
