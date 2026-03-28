-- ============================================================
-- LIXHUB - ANIME OVERLOAD MACRO SYSTEM WITH UI
-- ============================================================

if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller
    and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED")
    return
end

if game.PlaceId ~= 126297188712308 and game.PlaceId ~= 80353351682367 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

-- ============================================================
-- SERVICES & MODULES
-- ============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")

-- Detect lobby vs in-game.
-- workspace:GetAttribute("placeId") returns "lobby" in the hub,
-- or nil/something else in an actual game place.
local IS_LOBBY = (workspace:GetAttribute("placeId") == "lobby")

-- Game-only modules — only loaded when in an actual game place.
local towers, sync, calculateClientUpgradeCostMultiplier
local selectPlayerYen, clientStore, selectEquipped

if not IS_LOBBY then
    local gameClient = ReplicatedStorage:WaitForChild("gameClient")
    local net        = gameClient:WaitForChild("net")

    towers = require(net:WaitForChild("towers"))
    sync   = require(net:WaitForChild("sync"))

    calculateClientUpgradeCostMultiplier = require(ReplicatedStorage.gameClient.utilities.calculateClientUpgradeCostMultiplier)
    selectPlayerYen                      = require(ReplicatedStorage.gameShared.store.slices.currency.selectors.selectPlayerYen)()
    clientStore                          = require(gameClient.store.clientStore)
    selectEquipped                       = require(ReplicatedStorage.shared.store.slices.data.selectors.heroes.selectPlayerEquippedHeroes)()
end

-- ============================================================
-- YEN / HERO HELPERS
-- ============================================================
local function getYen()
    if IS_LOBBY then return 0 end
    local ok, result = pcall(function()
        local yenFrame = Players.LocalPlayer.PlayerGui
            :WaitForChild("hotbarGui", 2)
            :WaitForChild("scalingFrame", 2)
            :WaitForChild("currencyDisplay", 2)
            :WaitForChild("currencies", 2)
            :WaitForChild("yen", 2)
        local valueLabel = yenFrame:FindFirstChild("value")
        if valueLabel and valueLabel:IsA("TextLabel") then
            local num = tonumber((valueLabel.Text:gsub(",", ""):gsub("[^%d]", "")))
            return num or 0
        end
        return 0
    end)
    if ok then return result end
    return clientStore:getState(selectPlayerYen) or 0
end

local function getEquippedHeroes()
    if IS_LOBBY then return {} end
    local uuids    = clientStore:getState(selectEquipped)
    local userId   = tostring(Players.LocalPlayer.UserId)
    local state    = clientStore:getState()
    local heroData = state.data.heroes[userId]
    local result   = {}
    for slot, uuid in ipairs(uuids) do
        local hero = heroData and heroData[uuid]
        if hero then
            local ok, config = pcall(require, ReplicatedStorage.shared.config.items.data.hero[hero.id])
            result[slot] = {
                uuid   = uuid,
                id     = hero.id,
                name   = ok and config.name or hero.id,
                config = ok and config or nil,
            }
        end
    end
    return result
end

local function getHeroByUuid(uuid)
    local heroes = getEquippedHeroes()
    for _, h in ipairs(heroes) do
        if h.uuid == uuid then return h end
    end
    return nil
end

-- ============================================================
-- MACRO SYSTEM
-- ============================================================
local MacroSystem = {}

MacroSystem.isRecording      = false
MacroSystem.isPlaying        = false
MacroSystem.currentMacroName = ""
MacroSystem.ignoreTiming     = false
MacroSystem.pendingRecord    = false
MacroSystem.pendingPlayback  = false
MacroSystem.library          = {}

local recordingActions   = {}
local recordingStartTime = 0
local unitLabelCount     = {}
local liveTowerLabelMap  = {}
local mappedUids         = {}

local function getUnitLabel(name)
    unitLabelCount[name] = (unitLabelCount[name] or 0) + 1
    return name .. " #" .. unitLabelCount[name]
end

local FOLDER       = "LixHub"
local MACRO_FOLDER = "LixHub/Macros/AO"

local function ensureFolders()
    if not isfolder(FOLDER)              then makefolder(FOLDER)              end
    if not isfolder(FOLDER .. "/Macros") then makefolder(FOLDER .. "/Macros") end
    if not isfolder(MACRO_FOLDER)        then makefolder(MACRO_FOLDER)        end
end

local function filePath(name)
    return MACRO_FOLDER .. "/" .. name .. ".json"
end

function MacroSystem.save(name)
    local actions = MacroSystem.library[name]
    if not actions then return false end
    local ok, err = pcall(writefile, filePath(name), HttpService:JSONEncode(actions))
    if not ok then warn("[LixHub] Save failed: " .. tostring(err)) end
    return ok
end

function MacroSystem.loadFromFile(name)
    local path = filePath(name)
    if not isfile(path) then return nil end
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if ok then
        MacroSystem.library[name] = result
        return result
    end
    warn("[LixHub] Load failed for '" .. name .. "': " .. tostring(result))
    return nil
end

function MacroSystem.loadAll()
    if not isfolder(MACRO_FOLDER) then return end
    for _, path in ipairs(listfiles(MACRO_FOLDER)) do
        if path:match("%.json$") then
            local name = path:match("([^/\\]+)%.json$")
            if name then MacroSystem.loadFromFile(name) end
        end
    end
end

function MacroSystem.delete(name)
    local path = filePath(name)
    if isfile(path) then
        delfile(path)
        MacroSystem.library[name] = nil
        return true
    end
    return false
end

function MacroSystem.getList()
    local list = {}
    for name in pairs(MacroSystem.library) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

function MacroSystem.getStats(name)
    local actions = MacroSystem.library[name]
    if not actions or #actions == 0 then return nil end
    local s = { total = #actions, placements = 0, upgrades = 0, sells = 0, autoUpgrades = 0, priorityChanges = 0, duration = 0 }
    for _, a in ipairs(actions) do
        if     a.action == "PLACE"           then s.placements      = s.placements      + 1
        elseif a.action == "UPGRADE"         then s.upgrades        = s.upgrades        + 1
        elseif a.action == "SELL"            then s.sells           = s.sells           + 1
        elseif a.action == "AUTO_UPGRADE"    then s.autoUpgrades    = s.autoUpgrades    + 1
        elseif a.action == "CHANGE_PRIORITY" then s.priorityChanges = s.priorityChanges + 1
        end
        local t = tonumber(a.time) or 0
        if t > s.duration then s.duration = t end
    end
    return s
end

function MacroSystem.exportToClipboard(name)
    local actions = MacroSystem.library[name]
    if not actions then return false end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, actions)
    if ok then setclipboard(encoded) end
    return ok
end

function MacroSystem.importFromJSON(name, jsonStr)
    local ok, actions = pcall(HttpService.JSONDecode, HttpService, jsonStr)
    if not ok then return false, tostring(actions) end
    MacroSystem.library[name] = actions
    MacroSystem.save(name)
    return true, #actions
end

local function recordAction(action, data)
    if not MacroSystem.isRecording then return end
    local entry = { action = action, time = string.format("%.2f", tick() - recordingStartTime) }
    for k, v in pairs(data) do entry[k] = v end
    table.insert(recordingActions, entry)
end

function MacroSystem.startRecording(name)
    if not name or name == "" then return false end
    MacroSystem.currentMacroName = name
    recordingActions             = {}
    recordingStartTime           = tick()
    MacroSystem.isRecording      = true
    unitLabelCount               = {}
    liveTowerLabelMap            = {}
    mappedUids                   = {}
    print("[LixHub] Recording started: " .. name)
    return true
end

function MacroSystem.stopRecording()
    if not MacroSystem.isRecording then return false end
    MacroSystem.isRecording = false
    liveTowerLabelMap       = {}
    mappedUids              = {}
    MacroSystem.library[MacroSystem.currentMacroName] = recordingActions
    MacroSystem.save(MacroSystem.currentMacroName)
    print(string.format("[LixHub] Stopped: '%s' — %d actions",
        MacroSystem.currentMacroName, #recordingActions))
    return recordingActions
end

local function findPlacedTowerByPosition(targetPos, tolerance)
    tolerance = tolerance or 3.0
    local placedTowers = workspace:FindFirstChild("placedTowers")
    if not placedTowers then return nil end
    local target = Vector3.new(targetPos[1], targetPos[2], targetPos[3])
    local closest, closestDist = nil, math.huge
    for _, model in ipairs(placedTowers:GetChildren()) do
        local uid = model:GetAttribute("uniqueId")
        if uid and not mappedUids[uid] then
            local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if primary then
                local dist = (primary.Position - target).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = { model = model, uid = uid }
                end
            end
        end
    end
    if closest and closestDist <= tolerance then
        mappedUids[closest.uid] = true
        return closest.uid
    end
    return nil
end

local function setupHooks()
    local oldPlace = sync.clientTowerPlacement.call
    sync.clientTowerPlacement.call = function(uuid, cframe)
        local success, liveTowerID = oldPlace(uuid, cframe)
        if not MacroSystem.isRecording then return success, liveTowerID end
        if not success then
            warn("[LixHub] Placement rejected, skipping record")
            return success, liveTowerID
        end
        local hero  = getHeroByUuid(uuid)
        local name  = hero and hero.name or uuid
        local label = getUnitLabel(name)
        local rx, ry, rz = cframe:ToEulerAnglesXYZ()
        local pos = { cframe.Position.X, cframe.Position.Y, cframe.Position.Z }
        task.defer(function()
            task.wait(0.1)
            local uid = findPlacedTowerByPosition(pos)
            if uid then
                liveTowerLabelMap[uid] = label
            else
                warn(string.format("[LixHub] Could not find placed tower for %s", label))
            end
        end)
        recordAction("PLACE", { unitName = label, position = pos, rotation = { rx, ry, rz } })
        return success, liveTowerID
    end

    local oldUpgrade = towers.upgradeUnit.call
    towers.upgradeUnit.call = function(towerID)
        local success, errorMsg = oldUpgrade(towerID)
        if success and MacroSystem.isRecording then
            recordAction("UPGRADE", { unitName = liveTowerLabelMap[towerID] or "unknown" })
        end
        return success, errorMsg
    end

    local oldSell = towers.sellUnit.call
    towers.sellUnit.call = function(towerID)
        local success, errorMsg = oldSell(towerID)
        if success and MacroSystem.isRecording then
            recordAction("SELL", { unitName = liveTowerLabelMap[towerID] or "unknown" })
            liveTowerLabelMap[towerID] = nil
            mappedUids[towerID]        = nil
        end
        return success, errorMsg
    end

    local oldAuto = towers.changeUpgradePriority.call
    towers.changeUpgradePriority.call = function(towerID)
        local success, errorMsg = oldAuto(towerID)
        if success and MacroSystem.isRecording then
            recordAction("AUTO_UPGRADE", { unitName = liveTowerLabelMap[towerID] or "unknown" })
        end
        return success, errorMsg
    end

    local oldPriority = towers.changePriority.call
    towers.changePriority.call = function(towerID, priority)
        local success, errorMsg = oldPriority(towerID, priority)
        if success and MacroSystem.isRecording then
            recordAction("CHANGE_PRIORITY", {
                unitName = liveTowerLabelMap[towerID] or "unknown",
                priority = priority,
            })
        end
        return success, errorMsg
    end
end

-- ============================================================
-- THREAD-SAFE UI QUEUE
-- ============================================================
local StatusLabel = { Set = function() end }
local DetailLabel = { Set = function() end }

local pendingStatus   = nil
local pendingDetail   = nil
local pendingNotifies = {}

RunService.Heartbeat:Connect(function()
    if pendingStatus then
        pcall(function() StatusLabel:Set(pendingStatus) end)
        pendingStatus = nil
    end
    if pendingDetail then
        pcall(function() DetailLabel:Set(pendingDetail) end)
        pendingDetail = nil
    end
    if #pendingNotifies > 0 then
        local params = table.remove(pendingNotifies, 1)
        pcall(function()
            if _G._LixRayfield then
                _G._LixRayfield:Notify(params)
            end
        end)
    end
end)

local function pushUI(statusText, detailText)
    pendingStatus = statusText
    pendingDetail = detailText
end

local function pushNotify(params)
    table.insert(pendingNotifies, params)
end

-- ============================================================
-- PLAYBACK HELPERS
-- ============================================================
local playbackStartTime  = 0
local playbackTotal      = 0
local playbackLastStatus = ""
local playbackLastDetail = ""

local function fmtElapsed()
    local s = math.floor(tick() - playbackStartTime)
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end

local function buildNextPreview(actions, currentIndex, nameToHero, labelToLevel)
    for j = currentIndex + 1, #actions do
        local next = actions[j]
        if not next then break end

        local label     = next.unitName or "?"
        local baseName  = label:match("^(.-)%s*#%d+$") or label
        local absTime   = tonumber(next.time) or 0
        local timeHint  = string.format(" at %.1fs", absTime)

        if next.action == "PLACE" then
            return string.format("Next: Place [%s]%s", baseName, timeHint)

        elseif next.action == "UPGRADE" then
            local currentLevel = labelToLevel and labelToLevel[label] or 1
            return string.format("Next: Upgrade [%s] Level %d to %d%s",
                baseName, currentLevel, currentLevel + 1, timeHint)

        elseif next.action == "SELL" then
            return string.format("Next: Sell [%s]%s", baseName, timeHint)

        elseif next.action == "AUTO_UPGRADE" then
            return string.format("Next: Toggle auto-upgrade [%s]%s", baseName, timeHint)

        elseif next.action == "CHANGE_PRIORITY" then
            local prio = next.priority or "unknown"
            return string.format("Next: Set priority '%s' on [%s]%s", prio, baseName, timeHint)
        end
    end
    return "Next: End of macro"
end

local function setProgress(i, total, statusLine, nextLine)
    playbackLastStatus = string.format("Macro: %s  [%d/%d]  Time: %s",
        MacroSystem.currentMacroName, i, total, fmtElapsed())
    if nextLine and nextLine ~= "" then
        playbackLastDetail = statusLine .. "  |  " .. nextLine
    else
        playbackLastDetail = statusLine
    end
    pushUI(playbackLastStatus, playbackLastDetail)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if MacroSystem.isPlaying and playbackLastStatus ~= "" then
            local newStatus = playbackLastStatus:gsub("Time: %d+:%d+", "Time: " .. fmtElapsed())
            pushUI(newStatus, playbackLastDetail)
            playbackLastStatus = newStatus
        end
    end
end)

local function waitForYen(cost, label, actionType, index, total, nextLine, nameToHero, labelToLevel, actions)
    if getYen() >= cost then return true end
    local baseName = label:match("^(.-)%s*#%d+$") or label
    local actionWord = actionType == "PLACE" and "place" or "upgrade"
    while MacroSystem.isPlaying and getYen() < cost do
        local have    = getYen()
        local missing = cost - have
        local waitMsg = string.format(
            "Waiting for yen to %s [%s]  (%d / %d yen)",
            actionWord, baseName, have, cost
        )
        local combinedDetail = nextLine and nextLine ~= ""
            and (waitMsg .. "  |  " .. nextLine)
            or waitMsg
        playbackLastStatus = string.format("Macro: %s  [%d/%d]  Time: %s",
            MacroSystem.currentMacroName, index, total, fmtElapsed())
        playbackLastDetail = combinedDetail
        pushUI(playbackLastStatus, playbackLastDetail)
        task.wait(0.25)
    end
    return MacroSystem.isPlaying
end

-- ============================================================
-- PLAYBACK
-- ============================================================
function MacroSystem.playback(name)
    if MacroSystem.isPlaying then return false end
    local actions = MacroSystem.library[name]
    if not actions or #actions == 0 then return false end

    MacroSystem.isPlaying   = true
    mappedUids              = {}
    playbackStartTime       = tick()
    playbackTotal           = #actions
    playbackLastStatus      = ""
    playbackLastDetail      = ""
    print(string.format("[LixHub] Playback: '%s' (%d actions)", name, #actions))

    task.spawn(function()
        local heroes     = getEquippedHeroes()
        local nameToUuid = {}
        local nameToHero = {}
        for _, h in ipairs(heroes) do
            nameToUuid[h.name] = h.uuid
            nameToHero[h.name] = h
        end

        local labelToLiveTowerID = {}
        local labelToLevel       = {}

        for i, action in ipairs(actions) do
            if not MacroSystem.isPlaying then
                print("[LixHub] Playback stopped.")
                break
            end

            if not MacroSystem.ignoreTiming and i > 1 then
                local dt = (tonumber(actions[i].time) or 0) - (tonumber(actions[i-1].time) or 0)
                if dt > 0 then
                    local deadline = tick() + dt
                    local label    = action.unitName or "?"
                    local baseName = label:match("^(.-)%s*#%d+$") or label
                    local actionWord
                    if     action.action == "PLACE"           then actionWord = "Place"
                    elseif action.action == "UPGRADE"         then actionWord = "Upgrade"
                    elseif action.action == "SELL"            then actionWord = "Sell"
                    elseif action.action == "AUTO_UPGRADE"    then actionWord = "Toggle Auto-Upgrade"
                    elseif action.action == "CHANGE_PRIORITY" then actionWord = "Change Priority"
                    else                                           actionWord = action.action
                    end
                    while MacroSystem.isPlaying and tick() < deadline do
                        local remaining = math.max(0, deadline - tick())
                        local waitMsg = string.format(
                            "Waiting %.1fs before: %s [%s]", remaining, actionWord, baseName
                        )
                        playbackLastStatus = string.format("Macro: %s  [%d/%d]  Time: %s",
                            MacroSystem.currentMacroName, i - 1, #actions, fmtElapsed())
                        playbackLastDetail = waitMsg
                        pushUI(playbackLastStatus, playbackLastDetail)
                        task.wait(0.1)
                    end
                end
            end

            if not MacroSystem.isPlaying then break end

            local label    = action.unitName or "?"
            local baseName = label:match("^(.-)%s*#%d+$") or label

            local nextPreview = buildNextPreview(actions, i, nameToHero, labelToLevel)

            if action.action == "PLACE" then
                repeat
                    local uuid = nameToUuid[baseName]
                    if not uuid then
                        setProgress(i, #actions,
                            "[SKIP] Hero '" .. baseName .. "' is not equipped", nextPreview)
                        break
                    end
                    local hero = nameToHero[baseName]
                    if hero and hero.config then
                        local cost = hero.config.cost or 0
                        if cost > 0 and not waitForYen(cost, label, "PLACE", i, #actions, nextPreview, nameToHero, labelToLevel, actions) then
                            break
                        end
                    end
                    local pos       = action.position
                    local rot       = action.rotation or {0, 0, 0}
                    local cf        = CFrame.new(pos[1], pos[2], pos[3]) * CFrame.Angles(rot[1], rot[2], rot[3])
                    local hero2     = nameToHero[baseName]
                    local cost2     = (hero2 and hero2.config and hero2.config.cost) or 0
                    local yenBefore = getYen()
                    local success, _ = sync.clientTowerPlacement.call(uuid, cf)
                    if success then
                        task.wait(0.1)
                        if MacroSystem.ignoreTiming and cost2 > 0 then
                            local timeout = 0
                            while getYen() > yenBefore - cost2 and timeout < 40 do
                                task.wait(0.05)
                                timeout = timeout + 1
                            end
                        end
                        local uid = findPlacedTowerByPosition(pos)
                        print(string.format("[LixHub] [%d/%d] PLACE %s | uid=%s | pos=(%.1f,%.1f,%.1f)",
                            i, #actions, label, tostring(uid), pos[1], pos[2], pos[3]))
                        if uid then
                            labelToLiveTowerID[label] = uid
                            labelToLevel[label]       = 1
                            setProgress(i, #actions,
                                "[SUCCESS] Placed [" .. baseName .. "] at Level 1", nextPreview)
                        else
                            setProgress(i, #actions,
                                "[SUCCESS] Placed [" .. baseName .. "] — position mapping failed, upgrades may not work", nextPreview)
                        end
                    else
                        setProgress(i, #actions,
                            "[FAIL] Could not place [" .. baseName .. "] — server rejected the placement", nextPreview)
                    end
                until true

            elseif action.action == "UPGRADE" then
                repeat
                    local tid = labelToLiveTowerID[label]
                    if not tid then
                        setProgress(i, #actions,
                            "[ERROR] Cannot upgrade [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
                        break
                    end
                    local hero         = nameToHero[baseName]
                    local currentLevel = labelToLevel[label] or 1
                    local actualCost   = 0
                    if hero and hero.config and hero.config.upgradeValues then
                        local nextData = hero.config.upgradeValues[currentLevel + 1]
                        if nextData and nextData.cost and nextData.cost > 0 then
                            local multiplier = calculateClientUpgradeCostMultiplier(currentLevel)
                            actualCost = math.floor(nextData.cost * multiplier)
                            print(string.format("[LixHub] [%d/%d] UPGRADE %s | level=%d | cost=%d | yen=%d",
                                i, #actions, label, currentLevel, actualCost, getYen()))
                            if not waitForYen(actualCost, label, "UPGRADE", i, #actions, nextPreview, nameToHero, labelToLevel, actions) then
                                break
                            end
                        end
                    end
                    local yenBeforeUpg = getYen()
                    local success = towers.upgradeUnit.call(tid)
                    if success then
                        local prevLevel = labelToLevel[label] or 1
                        labelToLevel[label] = prevLevel + 1
                        local newLevel = labelToLevel[label]
                        setProgress(i, #actions,
                            string.format("[SUCCESS] Upgraded [%s] Level %d to Level %d", baseName, prevLevel, newLevel),
                            nextPreview)
                        if MacroSystem.ignoreTiming then
                            task.wait(0.1)
                            if actualCost > 0 then
                                local timeout = 0
                                while getYen() > yenBeforeUpg - actualCost and timeout < 40 do
                                    task.wait(0.05)
                                    timeout = timeout + 1
                                end
                            end
                        end
                    else
                        setProgress(i, #actions,
                            "[FAIL] Upgrade failed for [" .. baseName .. "] — server rejected the request", nextPreview)
                    end
                until true

            elseif action.action == "SELL" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local success = towers.sellUnit.call(tid)
                    if success then
                        labelToLiveTowerID[label] = nil
                        labelToLevel[label]       = nil
                        setProgress(i, #actions,
                            "[SUCCESS] Sold [" .. baseName .. "]", nextPreview)
                    else
                        setProgress(i, #actions,
                            "[FAIL] Could not sell [" .. baseName .. "] — server rejected the request", nextPreview)
                    end
                else
                    setProgress(i, #actions,
                        "[ERROR] Cannot sell [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
                end

            elseif action.action == "AUTO_UPGRADE" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local success = towers.changeUpgradePriority.call(tid)
                    if success then
                        setProgress(i, #actions,
                            "[SUCCESS] Toggled auto-upgrade for [" .. baseName .. "]", nextPreview)
                    else
                        setProgress(i, #actions,
                            "[FAIL] Auto-upgrade toggle failed for [" .. baseName .. "] — server rejected the request", nextPreview)
                    end
                else
                    setProgress(i, #actions,
                        "[ERROR] Cannot toggle auto-upgrade for [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
                end

            elseif action.action == "CHANGE_PRIORITY" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local priority = action.priority or ""
                    local success = towers.changePriority.call(tid, priority)
                    if success then
                        setProgress(i, #actions,
                            string.format("[SUCCESS] Priority set to '%s' for [%s]", priority, baseName), nextPreview)
                    else
                        setProgress(i, #actions,
                            string.format("[FAIL] Could not set priority for [%s] — server rejected the request", baseName), nextPreview)
                    end
                else
                    setProgress(i, #actions,
                        "[ERROR] Cannot change priority for [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
                end
            end
        end

        MacroSystem.isPlaying  = false
        playbackLastStatus     = ""
        playbackLastDetail     = ""
        setProgress(playbackTotal, playbackTotal, "Macro completed.", "")
        print(string.format("[LixHub] Playback finished: '%s'", name))
    end)

    return true
end

function MacroSystem.stopPlayback()
    if not MacroSystem.isPlaying then return false end
    MacroSystem.isPlaying = false
    return true
end

-- ============================================================
-- WEBHOOK STATE
-- ============================================================
local Webhook = {
    url           = "",
    discordUserId = "",
}

local function sendWebhookRaw(body)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    if not requestFunc then return false, "HTTP not supported" end
    local ok, err = pcall(function()
        requestFunc({
            Url     = Webhook.url,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = HttpService:JSONEncode(body),
        })
    end)
    return ok, err
end

local script_version = "V0.01"

-- ============================================================
-- RAYFIELD UI
-- ============================================================
local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua"
))()

_G._LixRayfield = Rayfield

local Window = Rayfield:CreateWindow({
    Name             = "LixHub - Anime Overload",
    Icon             = 0,
    LoadingTitle     = "Loading for Anime Overload",
    LoadingSubtitle  = script_version,
    Theme = {
        TextColor                     = Color3.fromRGB(240, 240, 240),
        Background                    = Color3.fromRGB(25,  25,  25),
        Topbar                        = Color3.fromRGB(34,  34,  34),
        Shadow                        = Color3.fromRGB(20,  20,  20),
        NotificationBackground        = Color3.fromRGB(20,  20,  20),
        NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
        TabBackground                 = Color3.fromRGB(80,  80,  80),
        TabStroke                     = Color3.fromRGB(85,  85,  85),
        TabBackgroundSelected         = Color3.fromRGB(210, 210, 210),
        TabTextColor                  = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor          = Color3.fromRGB(50,  50,  50),
        ElementBackground             = Color3.fromRGB(35,  35,  35),
        ElementBackgroundHover        = Color3.fromRGB(40,  40,  40),
        SecondaryElementBackground    = Color3.fromRGB(25,  25,  25),
        ElementStroke                 = Color3.fromRGB(50,  50,  50),
        SecondaryElementStroke        = Color3.fromRGB(40,  40,  40),
        SliderBackground              = Color3.fromRGB(50,  138, 220),
        SliderProgress                = Color3.fromRGB(50,  138, 220),
        SliderStroke                  = Color3.fromRGB(58,  163, 255),
        ToggleBackground              = Color3.fromRGB(30,  30,  30),
        ToggleEnabled                 = Color3.fromRGB(0,   146, 214),
        ToggleDisabled                = Color3.fromRGB(100, 100, 100),
        ToggleEnabledStroke           = Color3.fromRGB(0,   170, 255),
        ToggleDisabledStroke          = Color3.fromRGB(125, 125, 125),
        ToggleEnabledOuterStroke      = Color3.fromRGB(100, 100, 100),
        ToggleDisabledOuterStroke     = Color3.fromRGB(65,  65,  65),
        DropdownSelected              = Color3.fromRGB(102, 102, 102),
        DropdownUnselected            = Color3.fromRGB(30,  30,  30),
        InputBackground               = Color3.fromRGB(30,  30,  30),
        InputStroke                   = Color3.fromRGB(65,  65,  65),
        PlaceholderColor              = Color3.fromRGB(178, 178, 178),
    },
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "LixHub",
        FileName   = game:GetService("Players").LocalPlayer.Name .. "_AnimeOverload"
    },
    Discord = {
        Enabled       = true,
        Invite        = "cYKnXE2Nf8",
        RememberJoins = true
    },
})

-- ============================================================
-- MACRO TAB
-- ============================================================
local MacroTab = Window:CreateTab("Macro", "joystick")

local _StatusLabel = MacroTab:CreateLabel("Macro: — | Ready")
local _DetailLabel = MacroTab:CreateLabel("Waiting for input...")
StatusLabel = _StatusLabel
DetailLabel = _DetailLabel

MacroTab:CreateDivider()

local MacroDropdown
local RecordToggle
local PlaybackToggle

local function refreshDropdown()
    local list = MacroSystem.getList()
    local sel  = MacroSystem.currentMacroName ~= "" and { MacroSystem.currentMacroName } or {}
    if MacroDropdown then MacroDropdown:Refresh(list, sel) end
end

local function updateStatus(name)
    if not name or name == "" then
        pushUI("Macro: — | Ready", "No macro selected")
        return
    end
    local s = MacroSystem.getStats(name)
    if s then
        pushUI(
            string.format("Macro: %s | %d actions", name, s.total),
            string.format("%d placements  •  %d upgrades  •  %d sells  •  %.1fs",
                s.placements, s.upgrades, s.sells, s.duration)
        )
    else
        pushUI("Macro: " .. name .. " | Empty", "No actions recorded yet")
    end
end

MacroDropdown = MacroTab:CreateDropdown({
    Name            = "Select Macro",
    Options         = {},
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "SelectedMacro",
    Callback        = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        MacroSystem.currentMacroName = name or ""
        updateStatus(MacroSystem.currentMacroName)
    end,
})

MacroTab:CreateInput({
    Name                     = "Create Macro",
    PlaceholderText          = "Enter macro name...",
    RemoveTextAfterFocusLost = true,
    Flag                     = "CreateMacroInput",
    Callback                 = function(text)
        if not text or text == "" then
            return pushNotify({ Title = "Error", Content = "Name cannot be empty", Duration = 3, Image = "x-circle" })
        end
        local clean = text:gsub('[<>:"/\\|?*]', ""):match("^%s*(.-)%s*$")
        if clean == "" then
            return pushNotify({ Title = "Error", Content = "Invalid name", Duration = 3, Image = "x-circle" })
        end
        if MacroSystem.library[clean] then
            return pushNotify({ Title = "Error", Content = "'" .. clean .. "' already exists", Duration = 3, Image = "x-circle" })
        end
        MacroSystem.library[clean]   = {}
        MacroSystem.save(clean)
        MacroSystem.currentMacroName = clean
        refreshDropdown()
        pushUI("Macro: " .. clean .. " | Created", "Ready to record")
        pushNotify({ Title = "Created", Content = "'" .. clean .. "'", Duration = 3, Image = "check-circle" })
    end,
})

MacroTab:CreateButton({
    Name     = "Refresh Macro List",
    Callback = function()
        MacroSystem.loadAll()
        refreshDropdown()
        pushNotify({ Title = "Refreshed", Content = #MacroSystem.getList() .. " macro(s) loaded", Duration = 2, Image = "refresh-cw" })
    end,
})

MacroTab:CreateButton({
    Name     = "Delete Selected Macro",
    Callback = function()
        local name = MacroSystem.currentMacroName
        if name == "" then
            return pushNotify({ Title = "Error", Content = "No macro selected", Duration = 3, Image = "x-circle" })
        end
        MacroSystem.delete(name)
        MacroSystem.currentMacroName = ""
        refreshDropdown()
        pushUI("Macro: — | Ready", "Waiting for input...")
        pushNotify({ Title = "Deleted", Content = "'" .. name .. "'", Duration = 3, Image = "trash-2" })
    end,
})

MacroTab:CreateDivider()

RecordToggle = MacroTab:CreateToggle({
    Name         = "Record Macro",
    CurrentValue = false,
    Flag         = "RecordMacro",
    Callback     = function(value)
        if value then
            if IS_LOBBY then
                pushNotify({ Title = "Lobby", Content = "Recording is not available in the lobby — join a game first", Duration = 4, Image = "x-circle" })
                RecordToggle:Set(false)
                return
            end
            if MacroSystem.currentMacroName == "" then
                pushNotify({ Title = "Error", Content = "Create or select a macro first", Duration = 3, Image = "x-circle" })
                RecordToggle:Set(false)
                return
            end
            local ok, clientStoreLocal = pcall(require, ReplicatedStorage.gameClient.store.clientStore)
            local ok2, selectWave      = pcall(require, ReplicatedStorage.gameShared.store.slices.wave.selectors.selectWave)
            local currentWave = (ok and ok2) and clientStoreLocal:getState(selectWave) or nil
            if currentWave and currentWave > 1 then
                pushNotify({ Title = "Restarting game...", Content = "The act will reset and recording will begin at Wave 1", Duration = 3, Image = "refresh-cw" })
                pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Restarting", "Waiting for the game to restart...")
                task.spawn(function()
                    local remote = ReplicatedStorage:WaitForChild("voting"):WaitForChild("voting_RELIABLE")
                    local buf = buffer.create(2)
                    buffer.writeu8(buf, 0, 6)
                    buffer.writeu8(buf, 1, 0)
                    remote:FireServer(buf, {})
                    MacroSystem.pendingRecord = true
                end)
            else
                MacroSystem.pendingRecord = true
                pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Waiting", "Waiting for the next game to start recording...")
                pushNotify({ Title = "Ready to Record", Content = "Recording will begin automatically when the next game starts", Duration = 3, Image = "clock" })
            end
        else
            MacroSystem.pendingRecord = false
            if MacroSystem.isRecording then
                local actions = MacroSystem.stopRecording()
                if actions then
                    local s = MacroSystem.getStats(MacroSystem.currentMacroName)
                    if s then
                        pushUI(
                            string.format("Macro: %s | Saved", MacroSystem.currentMacroName),
                            string.format("%d placements  •  %d upgrades  •  %d sells  •  %.1fs",
                                s.placements, s.upgrades, s.sells, s.duration)
                        )
                    end
                    refreshDropdown()
                    pushNotify({ Title = "Saved", Content = #actions .. " actions recorded", Duration = 4, Image = "save" })
                end
            else
                pushUI("Macro: — | Ready", "Waiting for input...")
            end
        end
    end,
})

PlaybackToggle = MacroTab:CreateToggle({
    Name         = "Playback Macro",
    CurrentValue = false,
    Flag         = "PlaybackMacro",
    Callback     = function(value)
        if value then
            if IS_LOBBY then
                pushNotify({ Title = "Lobby", Content = "Playback is not available in the lobby — join a game first", Duration = 4, Image = "x-circle" })
                PlaybackToggle:Set(false)
                return
            end
            if MacroSystem.currentMacroName == "" then
                pushNotify({ Title = "Error", Content = "Select a macro first", Duration = 3, Image = "x-circle" })
                PlaybackToggle:Set(false)
                return
            end
            if not MacroSystem.library[MacroSystem.currentMacroName] or
               #MacroSystem.library[MacroSystem.currentMacroName] == 0 then
                pushNotify({ Title = "Error", Content = "Macro is empty or not found", Duration = 3, Image = "x-circle" })
                PlaybackToggle:Set(false)
                return
            end
            local ok, clientStoreLocal = pcall(require, ReplicatedStorage.gameClient.store.clientStore)
            local ok2, selectWave      = pcall(require, ReplicatedStorage.gameShared.store.slices.wave.selectors.selectWave)
            local currentWave = (ok and ok2) and clientStoreLocal:getState(selectWave) or nil
            if currentWave and currentWave > 1 then
                pushNotify({ Title = "Restarting game...", Content = "The act will reset and playback will begin at Wave 1", Duration = 3, Image = "refresh-cw" })
                pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Restarting", "Waiting for the game to restart...")
                task.spawn(function()
                    local remote = ReplicatedStorage:WaitForChild("voting"):WaitForChild("voting_RELIABLE")
                    local buf = buffer.create(2)
                    buffer.writeu8(buf, 0, 6)
                    buffer.writeu8(buf, 1, 0)
                    remote:FireServer(buf, {})
                    MacroSystem.pendingPlayback = true
                end)
            else
                MacroSystem.pendingPlayback = true
                pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Waiting", "Waiting for the next game to start playback...")
                pushNotify({ Title = "Ready to Play", Content = "Playback will begin automatically when the next game starts", Duration = 3, Image = "clock" })
            end
        else
            MacroSystem.pendingPlayback = false
            if MacroSystem.isPlaying then
                MacroSystem.stopPlayback()
                pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Stopped", "Playback stopped by user")
                pushNotify({ Title = "Stopped", Content = "Playback stopped", Duration = 2, Image = "square" })
            end
        end
    end,
})

MacroTab:CreateToggle({
    Name         = "Ignore Timing",
    CurrentValue = false,
    Flag         = "IgnoreTiming",
    Callback     = function(value)
        MacroSystem.ignoreTiming = value
        pushNotify({
            Title    = value and "Timing Disabled" or "Timing Enabled",
            Content  = value and "Actions fire as soon as affordable" or "Using recorded timing",
            Duration = 2,
            Image    = "zap"
        })
    end,
})

MacroTab:CreateDivider()
MacroTab:CreateSection("Import / Export")

MacroTab:CreateButton({
    Name     = "Export to Clipboard",
    Callback = function()
        if MacroSystem.currentMacroName == "" then
            return pushNotify({ Title = "Error", Content = "No macro selected", Duration = 3, Image = "x-circle" })
        end
        if MacroSystem.exportToClipboard(MacroSystem.currentMacroName) then
            pushNotify({ Title = "Exported", Content = "'" .. MacroSystem.currentMacroName .. "' copied to clipboard", Duration = 3, Image = "clipboard" })
        else
            pushNotify({ Title = "Error", Content = "Export failed", Duration = 3, Image = "x-circle" })
        end
    end,
})

-- Import: paste a Discord CDN URL or raw JSON
-- If it looks like a URL, fetch the file and use its filename as the macro name.
-- If it's raw JSON, use Import_<timestamp> as the name.
MacroTab:CreateInput({
    Name                     = "Import Macro (URL or JSON)",
    PlaceholderText          = "Paste a download URL or raw JSON...",
    RemoveTextAfterFocusLost = true,
    Flag                     = "ImportMacroJSON",
    Callback                 = function(input)
        if not input or input:match("^%s*$") then return end
        input = input:match("^%s*(.-)%s*$")
        local isUrl = input:match("^https?://")
        if isUrl then
            -- Fetch the file from the URL
            local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
            if not requestFunc then
                return pushNotify({ Title = "Import Failed", Content = "HTTP not supported by your executor", Duration = 4, Image = "x-circle" })
            end
            -- Extract filename from URL (strip query params)
            local filename = input:match("/([^/?#]+)%?") or input:match("/([^/?#]+)$") or ""
            -- Strip .json extension for the macro name
            local importName = filename:match("^(.+)%.json$") or filename
            -- Sanitise
            importName = importName:gsub('[<>:"/\\|?*]', ""):match("^%s*(.-)%s*$")
            if importName == "" then importName = "Import_" .. os.time() end
            if MacroSystem.library[importName] then
                return pushNotify({ Title = "Error", Content = "'" .. importName .. "' already exists", Duration = 4, Image = "x-circle" })
            end
            pushNotify({ Title = "Importing...", Content = "Fetching " .. importName .. ".json", Duration = 3, Image = "download" })
            task.spawn(function()
                local ok, response = pcall(function()
                    return requestFunc({ Url = input, Method = "GET" })
                end)
                if not ok or not response or not response.Body then
                    return pushNotify({ Title = "Import Failed", Content = "Could not fetch URL", Duration = 4, Image = "x-circle" })
                end
                local jsonStr = response.Body
                local importOk, result = MacroSystem.importFromJSON(importName, jsonStr)
                if importOk then
                    MacroSystem.currentMacroName = importName
                    refreshDropdown()
                    pushUI("Macro: " .. importName .. " | Imported", result .. " actions loaded")
                    pushNotify({ Title = "Imported", Content = importName .. "  (" .. result .. " actions)", Duration = 4, Image = "download" })
                else
                    pushNotify({ Title = "Import Failed", Content = tostring(result), Duration = 4, Image = "x-circle" })
                end
            end)
        else
            -- Raw JSON — strip Discord code fences if present
            local jsonStr = input:gsub("^```[%w]*\n?", ""):gsub("\n?```$", "")
            local importName = "Import_" .. os.time()
            local ok, result = MacroSystem.importFromJSON(importName, jsonStr)
            if ok then
                MacroSystem.currentMacroName = importName
                refreshDropdown()
                pushUI("Macro: " .. importName .. " | Imported", result .. " actions loaded")
                pushNotify({ Title = "Imported", Content = importName .. "  (" .. result .. " actions)", Duration = 4, Image = "download" })
            else
                pushNotify({ Title = "Import Failed", Content = tostring(result), Duration = 4, Image = "x-circle" })
            end
        end
    end,
})

MacroTab:CreateButton({
    Name     = "Check Macro Units",
    Callback = function()
        local name = MacroSystem.currentMacroName
        if name == "" then
            return pushNotify({ Title = "Error", Content = "No macro selected", Duration = 3, Image = "x-circle" })
        end
        local actions = MacroSystem.library[name]
        if not actions or #actions == 0 then
            return pushNotify({ Title = "Error", Content = "Macro is empty", Duration = 3, Image = "x-circle" })
        end
        local seen  = {}
        local units = {}
        for _, a in ipairs(actions) do
            if a.action == "PLACE" and a.unitName then
                local baseName = a.unitName:match("^(.-)%s*#%d+$") or a.unitName
                if not seen[baseName] then
                    seen[baseName] = true
                    table.insert(units, baseName)
                end
            end
        end
        if #units == 0 then
            return pushNotify({ Title = "No Units", Content = "No PLACE actions found in this macro", Duration = 3, Image = "info" })
        end
        table.sort(units)
        pushNotify({
            Title    = "Units needed: " .. name,
            Content  = table.concat(units, ", "),
            Duration = 10,
            Image    = "users"
        })
    end,
})

MacroTab:CreateButton({
    Name     = "Export Macro via Webhook",
    Callback = function()
        local name = MacroSystem.currentMacroName
        if name == "" then
            return pushNotify({ Title = "Error", Content = "No macro selected", Duration = 3, Image = "x-circle" })
        end
        if not Webhook.url or Webhook.url == "" then
            return pushNotify({ Title = "Error", Content = "Set a Webhook URL in the Webhook tab first", Duration = 4, Image = "x-circle" })
        end
        local actions = MacroSystem.library[name]
        if not actions or #actions == 0 then
            return pushNotify({ Title = "Error", Content = "Macro is empty", Duration = 3, Image = "x-circle" })
        end
        local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
        if not requestFunc then
            return pushNotify({ Title = "Error", Content = "HTTP not supported by your executor", Duration = 4, Image = "x-circle" })
        end
        -- Collect unique unit names, supporting both unitName and unitLabel keys
        local seen  = {}
        local units = {}
        for _, a in ipairs(actions) do
            if a.action == "PLACE" and a.unitName then
                local baseName = a.unitName:match("^(.-)%s*#%d+$") or a.unitName
                if not seen[baseName] then
                    seen[baseName] = true
                    table.insert(units, baseName)
                end
            end
        end
        table.sort(units)
        local unitStr  = #units > 0 and table.concat(units, ", ") or "None"
        local jsonStr  = HttpService:JSONEncode(actions)
        local boundary = "LixHubBoundary"
        local ping = (Webhook.discordUserId and Webhook.discordUserId ~= "")
            and ("<@" .. Webhook.discordUserId .. "> ") or ""
        local textContent = ping .. "Units: " .. unitStr
        -- Payload JSON part
        local payloadJson = HttpService:JSONEncode({
            username = "LixHub",
            content  = textContent,
        })
        local body = "--" .. boundary .. "\r\n"
            .. "Content-Disposition: form-data; name=\"payload_json\"\r\n\r\n"
            .. payloadJson .. "\r\n"
            .. "--" .. boundary .. "\r\n"
            .. "Content-Disposition: form-data; name=\"file\"; filename=\"" .. name .. ".json\"\r\n"
            .. "Content-Type: application/json\r\n\r\n"
            .. jsonStr .. "\r\n"
            .. "--" .. boundary .. "--"
        pcall(function()
            requestFunc({
                Url     = Webhook.url,
                Method  = "POST",
                Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. boundary },
                Body    = body,
            })
        end)
        pushNotify({ Title = "Webhook Sent", Content = "'" .. name .. "' exported to Discord", Duration = 4, Image = "send" })
    end,
})

-- ============================================================
-- WEBHOOK TAB
-- ============================================================
local WebhookTab = Window:CreateTab("Webhook", "link")

WebhookTab:CreateSection("Configuration")

WebhookTab:CreateInput({
    Name                     = "Webhook URL",
    CurrentValue             = "",
    PlaceholderText          = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Flag                     = "WebhookURL",
    Callback                 = function(text)
        Webhook.url = text and text:match("^%s*(.-)%s*$") or ""
    end,
})

WebhookTab:CreateInput({
    Name                     = "Discord User ID (for pings)",
    CurrentValue             = "",
    PlaceholderText          = "Your Discord user ID...",
    RemoveTextAfterFocusLost = false,
    Flag                     = "DiscordUserID",
    Callback                 = function(text)
        Webhook.discordUserId = text and text:match("^%s*(.-)%s*$") or ""
    end,
})

WebhookTab:CreateDivider()
WebhookTab:CreateSection("Actions")

WebhookTab:CreateButton({
    Name     = "Send Test Webhook",
    Callback = function()
        if not Webhook.url or Webhook.url == "" then
            return pushNotify({ Title = "Webhook", Content = "Enter a URL first!", Duration = 3, Image = "x-circle" })
        end
        local ok, err = sendWebhookRaw({
            username = "LixHub",
            embeds   = {{ title = "✅ Test", description = "Webhook is working!", color = 0x57F287 }},
        })
        if ok then
            pushNotify({ Title = "Webhook", Content = "Test sent successfully!", Duration = 3, Image = "check-circle" })
        else
            pushNotify({ Title = "Webhook Failed", Content = tostring(err), Duration = 4, Image = "x-circle" })
        end
    end,
})

-- ============================================================
-- WAVE HOOK
-- ============================================================
local function setupWaveHook()
    local ok1, clientStoreLocal = pcall(require, ReplicatedStorage.gameClient.store.clientStore)
    local ok2, selectWave       = pcall(require, ReplicatedStorage.gameShared.store.slices.wave.selectors.selectWave)
    if not ok1 or not ok2 then
        warn("[LixHub] Wave hook: could not require store modules")
        return
    end
    local lastWave = 0
    clientStoreLocal:subscribe(selectWave, function(waveNumber)
        if not waveNumber then return end
        if waveNumber == 1 and lastWave ~= 1 then
            if MacroSystem.pendingRecord then
                MacroSystem.pendingRecord = false
                if MacroSystem.startRecording(MacroSystem.currentMacroName) then
                    pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Recording", "Game started — recording in progress")
                    pushNotify({ Title = "Recording Started", Content = "Game started — recording your actions now", Duration = 3, Image = "circle" })
                end
            end
            if MacroSystem.pendingPlayback then
                MacroSystem.pendingPlayback = false
                if MacroSystem.playback(MacroSystem.currentMacroName) then
                    pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Playing", "Game started — playback in progress")
                    pushNotify({ Title = "Playback Started", Content = "Game started — running macro now", Duration = 3, Image = "play" })
                end
            end
        end
        lastWave = waveNumber
    end)
end

-- ============================================================
-- MATCH END HOOK
-- ============================================================
local function setupMatchEndHook()
    local matchRemote = ReplicatedStorage:WaitForChild("match"):WaitForChild("match_RELIABLE")
    matchRemote.OnClientEvent:Connect(function(buf, refs)
        if not buf or buffer.len(buf) == 0 then return end
        local eventId = buffer.readu8(buf, 0)
        if eventId ~= 0 then return end
        local success = buffer.readu8(buf, 1) == 0

        if MacroSystem.isRecording then
            local actions = MacroSystem.stopRecording()
            if actions then
                local s = MacroSystem.getStats(MacroSystem.currentMacroName)
                if s then
                    pushUI(
                        string.format("Macro: %s | Auto-saved", MacroSystem.currentMacroName),
                        string.format("%d placements  •  %d upgrades  •  %d sells  •  %.1fs",
                            s.placements, s.upgrades, s.sells, s.duration)
                    )
                end
                refreshDropdown()
                RecordToggle:Set(false)
                pushNotify({
                    Title    = "Auto-Saved",
                    Content  = "Game ended — " .. #actions .. " actions saved" .. (success and " (Win)" or " (Loss)"),
                    Duration = 5,
                    Image    = "save"
                })
            end
        end

        if MacroSystem.pendingRecord then
            MacroSystem.pendingRecord = false
            RecordToggle:Set(false)
            pushUI("Macro: — | Ready", "Waiting for input...")
            pushNotify({ Title = "Recording Cancelled", Content = "The game ended before recording could begin", Duration = 3, Image = "x-circle" })
        end

        if MacroSystem.isPlaying then
            MacroSystem.stopPlayback()
        end

        if PlaybackToggle and PlaybackToggle.CurrentValue then
            MacroSystem.pendingPlayback = true
            pushUI("Macro: " .. MacroSystem.currentMacroName .. " | Waiting", "Game ended — waiting for the next game to start")
            pushNotify({ Title = "Game Ended", Content = "Playback will resume automatically when the next game starts", Duration = 3, Image = "refresh-cw" })
        elseif not MacroSystem.isRecording then
            pushUI("Macro: — | Ready", "Waiting for input...")
        end
    end)
end

-- ============================================================
-- INIT
-- ============================================================
ensureFolders()
MacroSystem.loadAll()
refreshDropdown()

if IS_LOBBY then
    pushUI("Macro: — | Lobby", "Hooks inactive in lobby — enter a game to record or play")
    print("[LixHub] Lobby detected — skipping game hooks.")
else
    setupHooks()
    setupWaveHook()
    setupMatchEndHook()
    print("[LixHub] In-game — hooks active.")
end

Rayfield:LoadConfiguration()

pushNotify({ Title = "LixHub Loaded", Content = IS_LOBBY and "Running in lobby — hooks inactive." or "Macro system ready.", Duration = 3, Image = "check-circle" })
