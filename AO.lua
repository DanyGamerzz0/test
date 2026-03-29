-- ============================================================
-- V0.42
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

local IS_LOBBY = (workspace:GetAttribute("placeId") == "lobby")

local towers, sync, playerNet, calculateClientUpgradeCostMultiplier
local selectPlayerYen, clientStore, selectEquipped

if not IS_LOBBY then
    local gameClient = ReplicatedStorage:WaitForChild("gameClient")
    local net        = gameClient:WaitForChild("net")

    towers    = require(net:WaitForChild("towers"))
    sync      = require(net:WaitForChild("sync"))
    playerNet = require(ReplicatedStorage.gameClient.net.player)

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

local heroConfigCache = {}

local function getHeroConfigById(heroId)
    if heroConfigCache[heroId] then return heroConfigCache[heroId] end
    local heroFolder = ReplicatedStorage.shared.config.items.data.hero
    for _, obj in ipairs(heroFolder:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local ok, config = pcall(require, obj)
            if ok and type(config) == "table" and config.id then
                heroConfigCache[config.id] = config
            end
        end
    end
    return heroConfigCache[heroId]
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
            local config = getHeroConfigById(hero.id)
            result[slot] = {
                uuid   = uuid,
                id     = hero.id,
                name   = config and config.name or hero.id,
                config = config,
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
local worldMacroMappings  = {}
local worldMacroDropdowns = {}
local WORLD_MAPPING_FILE = "LixHub/AO/worldMacroMappings_" .. Players.LocalPlayer.Name .. ".json"

local function saveWorldMappings()
    pcall(writefile, WORLD_MAPPING_FILE, HttpService:JSONEncode(worldMacroMappings))
end

local function loadWorldMappings()
    if not isfile(WORLD_MAPPING_FILE) then return end
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(WORLD_MAPPING_FILE))
    end)
    if ok and type(result) == "table" then worldMacroMappings = result end
end


local function getUnitLabel(name)
    unitLabelCount[name] = (unitLabelCount[name] or 0) + 1
    return name .. " #" .. unitLabelCount[name]
end

local FOLDER       = "LixHub/AO"
local MACRO_FOLDER = "LixHub/AO/Macros"

local function ensureFolders()
    if not isfolder("LixHub")              then makefolder("LixHub")              end
    if not isfolder("LixHub/AO")           then makefolder("LixHub/AO")           end
    if not isfolder("LixHub/AO/Macros")    then makefolder("LixHub/AO/Macros")    end
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
        local label    = next.unitName or "?"
        local baseName = label:match("^(.-)%s*#%d+$") or label
        local absTime  = tonumber(next.time) or 0
        local timeHint = string.format(" at %.1fs", absTime)
        if next.action == "PLACE" then
            return string.format("Next: Place [%s]%s", baseName, timeHint)
        elseif next.action == "UPGRADE" then
            local currentLevel = labelToLevel and labelToLevel[label] or 1
            return string.format("Next: Upgrade [%s] Level %d to %d%s", baseName, currentLevel, currentLevel + 1, timeHint)
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
    local baseName   = label:match("^(.-)%s*#%d+$") or label
    local actionWord = actionType == "PLACE" and "place" or "upgrade"
    while MacroSystem.isPlaying and getYen() < cost do
        local have    = getYen()
        local waitMsg = string.format("Waiting for yen to %s [%s]  (%d / %d yen)", actionWord, baseName, have, cost)
        local combinedDetail = nextLine and nextLine ~= "" and (waitMsg .. "  |  " .. nextLine) or waitMsg
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
                        local waitMsg = string.format("Waiting %.1fs before: %s [%s]", remaining, actionWord, baseName)
                        playbackLastStatus = string.format("Macro: %s  [%d/%d]  Time: %s",
                            MacroSystem.currentMacroName, i - 1, #actions, fmtElapsed())
                        playbackLastDetail = waitMsg
                        pushUI(playbackLastStatus, playbackLastDetail)
                        task.wait(0.1)
                    end
                end
            end

            if not MacroSystem.isPlaying then break end

            local label       = action.unitName or "?"
            local baseName    = label:match("^(.-)%s*#%d+$") or label
            local nextPreview = buildNextPreview(actions, i, nameToHero, labelToLevel)

            if action.action == "PLACE" then
                repeat
                    local uuid = nameToUuid[baseName]
                    if not uuid then
                        setProgress(i, #actions, "[SKIP] Hero '" .. baseName .. "' is not equipped", nextPreview)
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
                            setProgress(i, #actions, "[SUCCESS] Placed [" .. baseName .. "] at Level 1", nextPreview)
                        else
                            setProgress(i, #actions, "[SUCCESS] Placed [" .. baseName .. "] — position mapping failed, upgrades may not work", nextPreview)
                        end
                    else
                        setProgress(i, #actions, "[FAIL] Could not place [" .. baseName .. "] — server rejected the placement", nextPreview)
                    end
                until true

            elseif action.action == "UPGRADE" then
                repeat
                    local tid = labelToLiveTowerID[label]
                    if not tid then
                        setProgress(i, #actions, "[ERROR] Cannot upgrade [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
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
                        setProgress(i, #actions, "[FAIL] Upgrade failed for [" .. baseName .. "] — server rejected the request", nextPreview)
                    end
                until true

            elseif action.action == "SELL" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local success = towers.sellUnit.call(tid)
                    if success then
                        labelToLiveTowerID[label] = nil
                        labelToLevel[label]       = nil
                        setProgress(i, #actions, "[SUCCESS] Sold [" .. baseName .. "]", nextPreview)
                    else
                        setProgress(i, #actions, "[FAIL] Could not sell [" .. baseName .. "] — server rejected the request", nextPreview)
                    end
                else
                    setProgress(i, #actions, "[ERROR] Cannot sell [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
                end

            elseif action.action == "AUTO_UPGRADE" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local success = towers.changeUpgradePriority.call(tid)
                    if success then
                        setProgress(i, #actions, "[SUCCESS] Toggled auto-upgrade for [" .. baseName .. "]", nextPreview)
                    else
                        setProgress(i, #actions, "[FAIL] Auto-upgrade toggle failed for [" .. baseName .. "] — server rejected the request", nextPreview)
                    end
                else
                    setProgress(i, #actions, "[ERROR] Cannot toggle auto-upgrade for [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
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
                    setProgress(i, #actions, "[ERROR] Cannot change priority for [" .. baseName .. "] — tower was not placed or mapping failed", nextPreview)
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
    sendOnFinish  = false,
}

local State = {
    AntiAfkEnabled      = false,
    AutoStartGame       = false,
    AutoLobby           = false,
    ChallengeBug        = false,
    EnableLowPerfMode   = false,
    StreamerModeEnabled = false,
    EnableBlackScreen   = false,
    EnableLimitFPS      = false,
    SelectedFPS         = 60,
    AutoPickCards       = false,
    CardPriorities      = {},
    AutoJoin            = false,
    AutoJoinStageId     = "",
    AutoJoinStageName   = "",
    AutoJoinAct         = nil,
    AutoJoinDifficulty  = "",
    AutoJoinLegend        = false,
    AutoJoinLegendStageId = "",
    AutoJoinLegendStageName = "",
    AutoJoinLegendAct     = nil,
    AutoJoinRaid            = false,
    AutoJoinRaidStageId     = "",
    AutoJoinRaidStageName   = "",
    AutoJoinRaidAct         = nil,
    AutoJoinChallenge          = false,
    ChallengeFrequencies       = {},
    ChallengeIgnoreWorlds      = {},
    ChallengeRequiredRewards   = {},
    ChallengeAutoLobbyOnRotation = false,
    ChallengeRotationPending = false,
    ModePriorities = {
    Challenge = 100,
    Raid      = 75,
    Legend    = 50,
    Story     = 25,
 },
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
    ShowText         = "LixHub",
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
        FolderName = "LixHub/AO",
        FileName   = game:GetService("Players").LocalPlayer.Name .. "_AnimeOverload"
    },
    Discord = {
        Enabled       = true,
        Invite        = "cYKnXE2Nf8",
        RememberJoins = true
    },
})

-- ============================================================
-- AUTO JOIN TAB
-- ============================================================
local AutoJoinTab = Window:CreateTab("Auto Join", "play")

local stageList     = {}
local stageNames    = {}
local stageNameToId = {}

do
    local stagesFolder = ReplicatedStorage:WaitForChild("shared")
        :WaitForChild("config")
        :WaitForChild("stages")

    local excluded = { util = true, validate = true }

    for _, obj in ipairs(stagesFolder:GetChildren()) do
        if obj:IsA("ModuleScript") and not excluded[obj.Name] then
            local ok, config = pcall(require, obj)
            if ok and type(config) == "table"
                and config.name and config.id
                and config.acts
                and not config.raidOnly
                and not config.gamemode
            then
                table.insert(stageList, { name = config.name, id = config.id })
                table.insert(stageNames, config.name)
                stageNameToId[config.name] = config.id
            end
        end
    end

    table.sort(stageList, function(a, b) return a.name < b.name end)
    table.sort(stageNames)
end

local raidStageNames    = {}
local raidStageNameToId = {}

do
    local stagesFolder = ReplicatedStorage:WaitForChild("shared")
        :WaitForChild("config")
        :WaitForChild("stages")

    local excluded = { util = true, validate = true }

    for _, obj in ipairs(stagesFolder:GetChildren()) do
        if obj:IsA("ModuleScript") and not excluded[obj.Name] then
            local ok, config = pcall(require, obj)
            if ok and type(config) == "table" and config.name and config.id and config.acts then
                if config.raidOnly and not config.unreleased and not config.gamemode then
                    table.insert(raidStageNames, config.name)
                    raidStageNameToId[config.name] = config.id
                end
            end
        end
    end

    table.sort(raidStageNames)
end

AutoJoinTab:CreateSection("Auto Story")

AutoJoinTab:CreateToggle({
    Name         = "Auto Join Story",
    CurrentValue = false,
    Flag         = "AutoJoinStory",
    Callback     = function(v)
        State.AutoJoin = v
    end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Select World",
    Options         = stageNames,
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "AutoJoinStage",
    Callback        = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        if not name or name == "" then return end
        State.AutoJoinStageName = name
        State.AutoJoinStageId   = stageNameToId[name] or ""
    end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Select Act",
    Options         = { "1", "2", "3", "4", "5", "6", "7" },
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "AutoJoinAct",
    Callback        = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        State.AutoJoinAct = tonumber(val)
    end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Select Difficulty",
    Options         = { "Normal", "Nightmare" },
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "AutoJoinDifficulty",
    Callback        = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        State.AutoJoinDifficulty = val
    end,
})

AutoJoinTab:CreateSection("Auto Legend")

AutoJoinTab:CreateToggle({
    Name         = "Auto Join Legend",
    CurrentValue = false,
    Flag         = "AutoJoinLegend",
    Callback     = function(v)
        State.AutoJoinLegend = v
    end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Select Legend World",
    Options         = stageNames,
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "AutoJoinLegendStage",
    Callback        = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        if not name or name == "" then return end
        State.AutoJoinLegendStageName = name
        State.AutoJoinLegendStageId   = stageNameToId[name] or ""
    end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Select Legend Act",
    Options         = { "1", "2", "3" },
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "AutoJoinLegendAct",
    Callback        = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        State.AutoJoinLegendAct = tonumber(val)
    end,
})

AutoJoinTab:CreateSection("Auto Raid")

AutoJoinTab:CreateToggle({
    Name         = "Auto Join Raid",
    CurrentValue = false,
    Flag         = "AutoJoinRaid",
    Info         = "Automatically joins a raid room with the selected stage and act.",
    Callback     = function(v) State.AutoJoinRaid = v end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Select Raid",
    Options         = raidStageNames,
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "AutoJoinRaidStage",
    Callback        = function(selected)
        local name = type(selected) == "table" and selected[1] or selected
        if not name or name == "" then return end
        State.AutoJoinRaidStageName = name
        State.AutoJoinRaidStageId   = raidStageNameToId[name] or ""
    end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Select Raid Act",
    Options         = { "1", "2", "3" },
    CurrentOption   = {},
    MultipleOptions = false,
    Flag            = "AutoJoinRaidAct",
    Callback        = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        State.AutoJoinRaidAct = tonumber(val)
    end,
})

AutoJoinTab:CreateSection("Auto Challenge")

AutoJoinTab:CreateToggle({
    Name         = "Auto Join Challenge",
    CurrentValue = false,
    Flag         = "AutoJoinChallenge",
    Info         = "Automatically joins a challenge room based on selected frequency, ignoring specified worlds.",
    Callback     = function(v) State.AutoJoinChallenge = v end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Challenge Frequency",
    Options         = { "hourly", "daily", "weekly" },
    CurrentOption   = {},
    MultipleOptions = true,
    Flag            = "ChallengeFrequency",
    Info            = "Which challenge rotations to join.",
    Callback        = function(selected)
        State.ChallengeFrequencies = type(selected) == "table" and selected or { selected }
    end,
})

AutoJoinTab:CreateDropdown({
    Name            = "Ignore Worlds",
    Options         = stageNames,
    CurrentOption   = {},
    MultipleOptions = true,
    Flag            = "ChallengeIgnoreWorlds",
    Info            = "Skip challenges on these worlds.",
    Callback        = function(selected)
        local t = {}
        for _, name in ipairs(type(selected) == "table" and selected or { selected }) do
            t[stageNameToId[name] or name] = true
        end
        State.ChallengeIgnoreWorlds = t
    end,
})

local challengeRewards = {}
local rewardOptions    = {}
local rewardNameToId   = {}

do
    local ok, rewardCfg = pcall(require, ReplicatedStorage:WaitForChild("shared")
        :WaitForChild("config"):WaitForChild("gamemodes"):WaitForChild("challengeRewards"))
    if ok and type(rewardCfg) == "table" then
        local seen = {}
        for _, rewardGroups in pairs(rewardCfg) do
            for _, group in ipairs(rewardGroups) do
                for _, reward in ipairs(group) do
                    local id = reward.id
                    if id and not seen[id] then
                        seen[id] = true
                        -- resolve display name from items config
                        local itemsData = ReplicatedStorage.shared.config.items.data
                        local displayName = id
                        for _, obj in ipairs(itemsData:GetDescendants()) do
                            if obj:IsA("ModuleScript") and obj.Name == id then
                                local iok, cfg = pcall(require, obj)
                                if iok and cfg and cfg.name then
                                    displayName = cfg.name
                                    break
                                end
                            end
                        end
                        table.insert(rewardOptions, displayName)
                        rewardNameToId[displayName] = id
                    end
                end
            end
        end
        table.sort(rewardOptions)
        challengeRewards = rewardCfg
    end
end

if #rewardOptions > 0 then
    AutoJoinTab:CreateDropdown({
        Name            = "Required Rewards",
        Options         = rewardOptions,
        CurrentOption   = {},
        MultipleOptions = true,
        Flag            = "ChallengeRequiredRewards",
        Info            = "Only join challenges that offer at least one of these rewards.",
        Callback        = function(selected)
            local t = {}
            for _, name in ipairs(type(selected) == "table" and selected or { selected }) do
                local id = rewardNameToId[name]
                if id then t[id] = true end
            end
            State.ChallengeRequiredRewards = t
        end,
    })
end

AutoJoinTab:CreateToggle({
    Name         = "Auto Lobby on Rotation",
    CurrentValue = false,
    Flag         = "ChallengAutoLobbyOnRotation",
    Info         = "Teleports you to lobby at the top of the hour when challenges rotate.",
    Callback     = function(v) State.ChallengeAutoLobbyOnRotation = v end,
})

local lobbyStore
local selectChallengesByType
local challengeFrequencyEnum

local function getLobbyStore()
    if lobbyStore then return lobbyStore end
    lobbyStore = require(ReplicatedStorage:WaitForChild("lobbyClient"):WaitForChild("store"):WaitForChild("clientStore"))
    return lobbyStore
end

local function getChallengesByType(freqType)
    if not selectChallengesByType then
        selectChallengesByType = require(ReplicatedStorage:WaitForChild("lobbyShared"):WaitForChild("store"):WaitForChild("slices"):WaitForChild("challenges"):WaitForChild("selectors"):WaitForChild("selectChallengesByType"))
    end
    return getLobbyStore():getState(selectChallengesByType(freqType)) or {}
end

local function getChallengeFrequencyEnum()
    if not challengeFrequencyEnum then
        challengeFrequencyEnum = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("enums"):WaitForChild("challengeFrequency"))
    end
    return challengeFrequencyEnum
end

-- ============================================================
-- AUTO JOIN LOGIC
-- ============================================================
local function setupAutoJoin()
    local roomsNet = require(ReplicatedStorage:WaitForChild("lobbyClient"):WaitForChild("net"):WaitForChild("rooms"))

    roomsNet.roomJoinError.on(function(errMsg)
        warn("[LixHub] Room join error: " .. tostring(errMsg))
        pushNotify({ Title = "Auto Join Error", Content = tostring(errMsg), Duration = 5, Image = "x-circle" })
    end)

    roomsNet.teleportToGame.on(function(data)
        print(string.format("[LixHub] Teleporting to game: %s - %s", data.mapName, data.actName))
        pushNotify({
            Title    = "Auto Join",
            Content  = string.format("Joining %s — %s", data.mapName, data.actName),
            Duration = 4,
            Image    = "play"
        })
    end)

    local function touchStoryDoor()
        local doorsFolder = workspace:FindFirstChild("StoryDoor")
        if not doorsFolder then
            warn("[LixHub] StoryDoor folder not found in workspace")
            return false
        end
        for i = 1, 10 do
            local doorName = string.format("%03d", i)
            local door = doorsFolder:FindFirstChild(doorName)
            if not door then continue end
            local doorPart = door:FindFirstChild("Door")
            if not doorPart then continue end
            print(string.format("[LixHub] Touching story door %s", doorName))
            Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(doorPart.Position)
            task.wait(1.5)
            local ok, result = pcall(roomsNet.setConfiguring.call, true)
            if ok and result then
                print(string.format("[LixHub] Room created via door %s", doorName))
                return true
            end
            print(string.format("[LixHub] Door %s didn't work, trying next...", doorName))
        end
        warn("[LixHub] No story door worked")
        return false
    end

    local function touchRaidDoor()
        local doorsFolder = workspace:FindFirstChild("RaidDoor")
        if not doorsFolder then
            warn("[LixHub] RaidDoor folder not found in workspace")
            return false
        end
        for i = 1, 10 do
            local doorName = string.format("%03d", i)
            local door = doorsFolder:FindFirstChild(doorName)
            if not door then continue end
            local doorPart = door:FindFirstChild("Door")
            if not doorPart then continue end
            print(string.format("[LixHub] Touching raid door %s", doorName))
            Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(doorPart.Position)
            task.wait(1.5)
            local ok, result = pcall(roomsNet.setConfiguring.call, true)
            if ok and result then
                print(string.format("[LixHub] Raid room created via door %s", doorName))
                return true
            end
            print(string.format("[LixHub] Raid door %s didn't work, trying next...", doorName))
        end
        warn("[LixHub] No raid door worked")
        return false
    end

    local function touchChallengeDoor()
        local doorsFolder = workspace:FindFirstChild("ChallengeDoor")
        if not doorsFolder then
            warn("[LixHub] ChallengeDoor folder not found in workspace")
            return false
        end
        for i = 1, 10 do
            local doorName = string.format("%03d", i)
            local door = doorsFolder:FindFirstChild(doorName)
            if not door then continue end
            local doorPart = door:FindFirstChild("Door")
            if not doorPart then continue end
            print(string.format("[LixHub] Touching challenge door %s", doorName))
            Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(doorPart.Position)
            task.wait(1.5)
            local ok, result = pcall(roomsNet.setConfiguring.call, true)
            if ok and result then
                print(string.format("[LixHub] Challenge room created via door %s", doorName))
                return true
            end
            print(string.format("[LixHub] Challenge door %s didn't work, trying next...", doorName))
        end
        warn("[LixHub] No challenge door worked")
        return false
    end

    local selectHasCompletedChallengeEntry = require(
        ReplicatedStorage.shared.store.slices.data.selectors.challenges.selectHasCompletedChallengeEntry)

    local function isChallengeCompleted(entryId)
        local ok, result = pcall(function()
            return getLobbyStore():getState(selectHasCompletedChallengeEntry(nil, entryId))
        end)
        return ok and result == true
    end

    local function findBestChallenge()
        if not State.AutoJoinChallenge then return nil end
        if #State.ChallengeFrequencies == 0 then return nil end
        local freqEnum = getChallengeFrequencyEnum()
        for _, freqName in ipairs(State.ChallengeFrequencies) do
            local freqType = freqEnum[freqName]
            if not freqType then continue end
            local challenges = getChallengesByType(freqType)
            for _, entry in ipairs(challenges) do
                if isChallengeCompleted(entry.id) then continue end
                if entry.stage and State.ChallengeIgnoreWorlds[entry.stage] then continue end
                if next(State.ChallengeRequiredRewards) then
                    local freqRewards = challengeRewards[freqType] or {}
                    local rewardGroup = freqRewards[entry.rewardPool] -- use the specific pool index
                    local hasReward = false
                    if rewardGroup then
                        for _, reward in ipairs(rewardGroup) do
                            if State.ChallengeRequiredRewards[reward.id] then
                                hasReward = true
                                break
                            end
                        end
                    end
                    if not hasReward then continue end
                end
                return { entry = entry, freq = freqType }
            end
        end
        return nil
    end

    local function tryJoinChallenge(entry, freqType)
        local inRoom = touchChallengeDoor()
        if not inRoom then
            pushNotify({ Title = "Auto Challenge", Content = "Could not enter challenge room — retrying...", Duration = 3, Image = "x-circle" })
            return false
        end
        task.wait(0.2)
        local ok2, r2 = pcall(roomsNet.selectChallenge.call, freqType, entry.id)
        if not ok2 or not r2 then warn("[LixHub] selectChallenge failed: " .. tostring(r2)) return false end
        task.wait(0.2)
        local ok5, r5 = pcall(roomsNet.getReady.call)
        if not ok5 or not r5 then warn("[LixHub] Challenge getReady failed: " .. tostring(r5)) return false end
        task.wait(0.2)
        local ok6, r6 = pcall(roomsNet.setMatchStatus.call, true)
        if not ok6 or not r6 then warn("[LixHub] Challenge setMatchStatus failed: " .. tostring(r6)) return false end
        pushNotify({ Title = "Auto Challenge", Content = string.format("Joining challenge: %s (%s)", entry.stage or "?", tostring(freqType)), Duration = 4, Image = "log-in" })
        return true
    end

    local function tryJoinRaid()
        if not State.AutoJoinRaid or State.AutoJoinRaidStageId == "" or not State.AutoJoinRaidAct then return false end
        local inRoom = touchRaidDoor()
        if not inRoom then return false end
        task.wait(0.2)
        local ok2, r2 = pcall(roomsNet.selectStage.call, State.AutoJoinRaidStageId)
        if not ok2 or not r2 then warn("[LixHub] Raid selectStage failed: " .. tostring(r2)) return false end
        task.wait(0.2)
        local ok3, r3 = pcall(roomsNet.selectAct.call, State.AutoJoinRaidAct)
        if not ok3 or not r3 then warn("[LixHub] Raid selectAct failed: " .. tostring(r3)) return false end
        task.wait(0.2)
        local ok5, r5 = pcall(roomsNet.getReady.call)
        if not ok5 or not r5 then warn("[LixHub] Raid getReady failed: " .. tostring(r5)) return false end
        task.wait(0.2)
        local ok6, r6 = pcall(roomsNet.setMatchStatus.call, true)
        if not ok6 or not r6 then warn("[LixHub] Raid setMatchStatus failed: " .. tostring(r6)) return false end
        pushNotify({ Title = "Auto Raid", Content = string.format("Joining: %s Act %d", State.AutoJoinRaidStageName, State.AutoJoinRaidAct), Duration = 4, Image = "log-in" })
        return true
    end

    local function tryJoinLegend()
        if not State.AutoJoinLegend or State.AutoJoinLegendStageId == "" or not State.AutoJoinLegendAct then return false end
        local inRoom = touchStoryDoor()
        if not inRoom then return false end
        task.wait(0.2)
        local Event = ReplicatedStorage:WaitForChild("rooms"):WaitForChild("rooms_RELIABLE")
        Event:FireServer(buffer.fromstring("\x04\x02\a\x00legends"), {})
        task.wait(0.2)
        local ok2, r2 = pcall(roomsNet.selectStage.call, State.AutoJoinLegendStageId)
        if not ok2 or not r2 then warn("[LixHub] Legend selectStage failed: " .. tostring(r2)) return false end
        task.wait(0.2)
        local ok3, r3 = pcall(roomsNet.selectAct.call, State.AutoJoinLegendAct)
        if not ok3 or not r3 then warn("[LixHub] Legend selectAct failed: " .. tostring(r3)) return false end
        task.wait(0.2)
        local ok5, r5 = pcall(roomsNet.getReady.call)
        if not ok5 or not r5 then warn("[LixHub] Legend getReady failed: " .. tostring(r5)) return false end
        task.wait(0.2)
        local ok6, r6 = pcall(roomsNet.setMatchStatus.call, true)
        if not ok6 or not r6 then warn("[LixHub] Legend setMatchStatus failed: " .. tostring(r6)) return false end
        pushNotify({ Title = "Auto Legend", Content = string.format("Joining: %s Act %d", State.AutoJoinLegendStageName, State.AutoJoinLegendAct), Duration = 4, Image = "log-in" })
        return true
    end

    local function tryJoinStory()
        if not State.AutoJoin or State.AutoJoinStageId == "" or not State.AutoJoinAct or State.AutoJoinDifficulty == "" then return false end
        local inRoom = touchStoryDoor()
        if not inRoom then return false end
        task.wait(0.2)
        local ok2, r2 = pcall(roomsNet.selectStage.call, State.AutoJoinStageId)
        if not ok2 or not r2 then warn("[LixHub] Story selectStage failed: " .. tostring(r2)) return false end
        task.wait(0.2)
        local ok3, r3 = pcall(roomsNet.selectAct.call, State.AutoJoinAct)
        if not ok3 or not r3 then warn("[LixHub] Story selectAct failed: " .. tostring(r3)) return false end
        task.wait(0.2)
        local ok4, r4 = pcall(roomsNet.selectDifficulty.call, State.AutoJoinDifficulty:lower())
        if not ok4 or not r4 then warn("[LixHub] Story selectDifficulty failed: " .. tostring(r4)) return false end
        task.wait(0.2)
        local ok5, r5 = pcall(roomsNet.getReady.call)
        if not ok5 or not r5 then warn("[LixHub] Story getReady failed: " .. tostring(r5)) return false end
        task.wait(0.2)
        local ok6, r6 = pcall(roomsNet.setMatchStatus.call, true)
        if not ok6 or not r6 then warn("[LixHub] Story setMatchStatus failed: " .. tostring(r6)) return false end
        pushNotify({ Title = "Auto Story", Content = string.format("Joining: %s Act %d (%s)", State.AutoJoinStageName, State.AutoJoinAct, State.AutoJoinDifficulty), Duration = 4, Image = "log-in" })
        return true
    end

    task.spawn(function()
        while true do
            task.wait(2)
            if not IS_LOBBY then continue end

            local modes = {
                { name = "Challenge", priority = State.ModePriorities.Challenge },
                { name = "Raid",      priority = State.ModePriorities.Raid      },
                { name = "Legend",    priority = State.ModePriorities.Legend    },
                { name = "Story",     priority = State.ModePriorities.Story     },
            }
            table.sort(modes, function(a, b) return a.priority > b.priority end)

            local joined = false
            for _, mode in ipairs(modes) do
                if mode.priority <= 0 then continue end

                if mode.name == "Challenge" then
                    local best = findBestChallenge()
                    if best then
                        joined = tryJoinChallenge(best.entry, best.freq)
                        if joined then break end
                    end
                elseif mode.name == "Raid" then
                    if State.AutoJoinRaid then
                        joined = tryJoinRaid()
                        if joined then break end
                    end
                elseif mode.name == "Legend" then
                    if State.AutoJoinLegend then
                        joined = tryJoinLegend()
                        if joined then break end
                    end
                elseif mode.name == "Story" then
                    if State.AutoJoin then
                        joined = tryJoinStory()
                        if joined then break end
                    end
                end
            end

            if not joined then
                pushUI("Auto Join: Waiting", "No available mode — all challenges done or nothing configured")
                task.wait(8)
            else
                task.wait(10)
            end
        end
    end)
end

-- ============================================================
-- PRIORITY TAB
-- ============================================================
local PriorityTab = Window:CreateTab("Priority", "layers")

PriorityTab:CreateSection("Auto Join Priority")
PriorityTab:CreateLabel("Higher value = joins first. Set to 0 to disable a mode from the shared loop.")

PriorityTab:CreateSlider({
    Name         = "Challenge Stage Priority",
    Range        = { 1, 4 },
    Increment    = 1,
    CurrentValue = 4,
    Flag         = "PriorityChallenge",
    Callback     = function(v) State.ModePriorities.Challenge = v end,
})

PriorityTab:CreateSlider({
    Name         = "Raid Stage Priority",
    Range        = { 1, 4 },
    Increment    = 1,
    CurrentValue = 3,
    Flag         = "PriorityRaid",
    Callback     = function(v) State.ModePriorities.Raid = v end,
})

PriorityTab:CreateSlider({
    Name         = "Legend Stage Priority",
    Range        = { 1, 4 },
    Increment    = 1,
    CurrentValue = 2,
    Flag         = "PriorityLegend",
    Callback     = function(v) State.ModePriorities.Legend = v end,
})

PriorityTab:CreateSlider({
    Name         = "Story Stage Priority",
    Range        = { 1, 4 },
    Increment    = 1,
    CurrentValue = 1,
    Flag         = "PriorityStory",
    Callback     = function(v) State.ModePriorities.Story = v end,
})

-- ============================================================
-- CARDS TAB
-- ============================================================
local CardsTab = Window:CreateTab("Cards", "layers")

CardsTab:CreateToggle({
    Name         = "Auto Pick Cards",
    CurrentValue = false,
    Flag         = "AutoPickCards",
    Info         = "Automatically selects the highest priority card or contract.",
    Callback     = function(v)
        State.AutoPickCards = v
    end,
})

local function stripDescription(desc)
    if type(desc) ~= "string" then return "" end
    desc = desc:gsub("<[^>]+>", "")
    desc = desc:match("^%s*(.-)%s*$")
    return desc
end

local function loadCards()
    CardsTab:CreateSection("Cards")

    local cardFolder = ReplicatedStorage:WaitForChild("gameShared")
        :WaitForChild("config")
        :WaitForChild("cards")

    local cardModules = {}
    for _, obj in ipairs(cardFolder:GetChildren()) do
        if obj:IsA("ModuleScript") and obj.Name ~= "util" then
            local ok, config = pcall(require, obj)
            if ok and type(config) == "table" and config.name then
                table.insert(cardModules, config)
            end
        end
    end
    table.sort(cardModules, function(a, b) return a.name < b.name end)

    for i, config in ipairs(cardModules) do
        local id   = config.id or config.name
        local desc = stripDescription(config.description)
        State.CardPriorities[id] = i
        CardsTab:CreateSlider({
            Name         = config.name,
            Range        = { 0, 100 },
            Increment    = 1,
            Suffix       = "",
            CurrentValue = i,
            Flag         = "CardPriority_" .. id,
            Info         = desc ~= "" and desc or nil,
            TextScaled   = true,
            Callback     = function(value)
                State.CardPriorities[id] = value
            end,
        })
    end

    CardsTab:CreateDivider()
    CardsTab:CreateSection("Contracts")

    local contractFolder = ReplicatedStorage:WaitForChild("gameShared")
        :WaitForChild("config")
        :WaitForChild("contracts")

    local contractModules = {}
    for _, obj in ipairs(contractFolder:GetChildren()) do
        if obj:IsA("ModuleScript") and obj.Name ~= "util" then
            local ok, config = pcall(require, obj)
            if ok and type(config) == "table" and config.name then
                table.insert(contractModules, config)
            end
        end
    end
    table.sort(contractModules, function(a, b) return a.name < b.name end)

    for i, config in ipairs(contractModules) do
        local id   = config.id or config.name
        local desc = stripDescription(config.description)
        State.CardPriorities[id] = i
        CardsTab:CreateSlider({
            Name         = config.name,
            Range        = { 0, 100 },
            Increment    = 1,
            Suffix       = "",
            CurrentValue = i,
            Flag         = "ContractPriority_" .. id,
            Info         = desc ~= "" and desc or nil,
            TextScaled   = true,
            Callback     = function(value)
                State.CardPriorities[id] = value
            end,
        })
    end
end

if not IS_LOBBY then
    local ok, err = pcall(loadCards)
    if not ok then
        warn("[LixHub] Cards tab failed to load: " .. tostring(err))
    end
else
    CardsTab:CreateLabel("Cards are not available in the lobby.")
end

-- ============================================================
-- GAME TAB
-- ============================================================
local GameTab = Window:CreateTab("Game", "gamepad")

GameTab:CreateSection("Player")

GameTab:CreateSlider({
    Name         = "Max Camera Zoom Distance",
    Range        = { 5, 100 },
    Increment    = 1,
    Suffix       = " studs",
    CurrentValue = 35,
    Flag         = "CameraZoomDistance",
    Callback     = function(Value)
        game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = Value
    end,
})

GameTab:CreateToggle({
    Name         = "Low Performance Mode",
    CurrentValue = false,
    Flag         = "LowPerfMode",
    Callback     = function(Value)
        State.EnableLowPerfMode = Value
    end,
})

GameTab:CreateToggle({
    Name         = "Black Screen",
    CurrentValue = false,
    Flag         = "BlackScreen",
    Callback     = function(Value)
        State.EnableBlackScreen = Value
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

GameTab:CreateSection("Game")

GameTab:CreateToggle({ Name = "Auto Start Game", Flag = "AutoStartGame", Callback = function(v) State.AutoStartGame = v end })
GameTab:CreateToggle({ Name = "Auto Replay",     Flag = "AutoReplay",    Callback = function(v) playerNet.updateSettings.fire("autoReplay", v)  end })
GameTab:CreateToggle({ Name = "Auto Next",        Flag = "AutoNext",      Callback = function(v) playerNet.updateSettings.fire("autoNextAct", v) end })
GameTab:CreateToggle({ Name = "Auto Lobby",       Flag = "AutoLobby",     Callback = function(v) State.AutoLobby = v end })
GameTab:CreateToggle({ Name = "Auto Skip Waves",  Flag = "AutoSkipWaves", Callback = function(v) playerNet.updateSettings.fire("autoSkipWave", v) end })
GameTab:CreateToggle({ Name = "Challenge Bug",    Flag = "ChallengeBug",  Callback = function(v) State.ChallengeBug = v end })

task.spawn(function()
    if IS_LOBBY then return end

    local button = Players.LocalPlayer.PlayerGui:WaitForChild("hotbarGui")
        :WaitForChild("scalingFrame")
        :WaitForChild("currencyDisplay")
        :WaitForChild("startGame")

    local votingClient = require(ReplicatedStorage.gameClient.net.votingNet)

    local TARGET_X = 0.5
    local TARGET_Y = 0.349999994
    local fired    = false

    while true do
        task.wait(0.5)
        if State.AutoStartGame then
            local pos        = button.Position
            local inPosition = math.abs(pos.X.Scale - TARGET_X) < 0.001
                           and math.abs(pos.Y.Scale - TARGET_Y) < 0.001
            if inPosition and not fired then
                task.delay(1, function()
                    if State.AutoStartGame then
                        votingClient.startMatch.fire()
                    end
                end)
                fired = true
            elseif not inPosition then
                fired = false
            end
        end
    end
end)

GameTab:CreateToggle({ Name = "Anti-AFK", Flag = "AntiAfk", Callback = function(v) State.AntiAfkEnabled = v end })

Players.LocalPlayer.Idled:Connect(function()
    if State.AntiAfkEnabled then
        game:GetService("VirtualUser"):Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
    end
end)

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

local function refreshAutoSelectDropdowns()
    local opts = { "None" }
    for _, name in ipairs(MacroSystem.getList()) do
        table.insert(opts, name)
    end
    for key, dropdown in pairs(worldMacroDropdowns) do
        pcall(function()
            dropdown:Refresh(opts)
            local current = worldMacroMappings[key]
            if current and MacroSystem.library[current] then
                dropdown:Set(current)
            end
        end)
    end
end

local function refreshDropdown()
    local list = MacroSystem.getList()
    local sel  = MacroSystem.currentMacroName ~= "" and { MacroSystem.currentMacroName } or {}
    if MacroDropdown then MacroDropdown:Refresh(list, sel) end
    refreshAutoSelectDropdowns()
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
                return
            end
            if MacroSystem.currentMacroName == "" then
                pushNotify({ Title = "Error", Content = "Select a macro first", Duration = 3, Image = "x-circle" })
                return
            end
            if not MacroSystem.library[MacroSystem.currentMacroName] or
               #MacroSystem.library[MacroSystem.currentMacroName] == 0 then
                pushNotify({ Title = "Error", Content = "Macro is empty or not found", Duration = 3, Image = "x-circle" })
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
            local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
            if not requestFunc then
                return pushNotify({ Title = "Import Failed", Content = "HTTP not supported by your executor", Duration = 4, Image = "x-circle" })
            end
            local filename   = input:match("/([^/?#]+)%?") or input:match("/([^/?#]+)$") or ""
            local importName = filename:match("^(.+)%.json$") or filename
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
                local importOk, result = MacroSystem.importFromJSON(importName, response.Body)
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
            local jsonStr    = input:gsub("^```[%w]*\n?", ""):gsub("\n?```$", "")
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
        local seen, units = {}, {}
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
        pushNotify({ Title = "Units needed: " .. name, Content = table.concat(units, ", "), Duration = 10, Image = "users" })
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
        local seen, units = {}, {}
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
        local unitStr     = #units > 0 and table.concat(units, ", ") or "None"
        local jsonStr     = HttpService:JSONEncode(actions)
        local boundary    = "LixHubBoundary"
        local ping        = (Webhook.discordUserId and Webhook.discordUserId ~= "")
            and ("<@" .. Webhook.discordUserId .. "> ") or ""
        local payloadJson = HttpService:JSONEncode({ username = "LixHub", content = ping .. "Units: " .. unitStr })
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

MacroTab:CreateDivider()
MacroTab:CreateSection("Macro Maps")
MacroTab:CreateLabel("Assign a macro to each world. It will auto-play when that stage starts.")

local function buildModeCollapsible(displayName, gamemodeKey, nameList, nameToId)
    local collapsible = MacroTab:CreateCollapsible({
        Name            = displayName,
        DefaultExpanded = false,
    })
    local opts = { "None" }
    for _, name in ipairs(MacroSystem.getList()) do
        table.insert(opts, name)
    end
    for _, worldName in ipairs(nameList) do
        local stageId = nameToId[worldName]
        if not stageId then continue end
        local mapKey  = gamemodeKey .. ":" .. stageId
        local current = worldMacroMappings[mapKey] or "None"
        local dropdown = collapsible.Tab:CreateDropdown({
            Name            = worldName,
            Options         = opts,
            CurrentOption   = { current },
            MultipleOptions = false,
            Callback        = function(selected)
                local picked = type(selected) == "table" and selected[1] or selected
                if picked == "None" or picked == "" then
                    worldMacroMappings[mapKey] = nil
                else
                    worldMacroMappings[mapKey] = picked
                end
                saveWorldMappings()
            end,
        })
        worldMacroDropdowns[mapKey] = dropdown
    end
end

buildModeCollapsible("Story Stages",    "story",     stageNames,     stageNameToId)
buildModeCollapsible("Legend Stages",   "legends",   stageNames,     stageNameToId)
buildModeCollapsible("Raid Stages",     "raid",      raidStageNames, raidStageNameToId)
buildModeCollapsible("Challenge Stages","challenge", stageNames,     stageNameToId)

-- DEBUG
print("[LixHub] worldMacroDropdowns registered count:")
local count = 0
for key in pairs(worldMacroDropdowns) do
    count = count + 1
    print("  " .. key)
end
print("  TOTAL:", count)

-- ============================================================
-- WEBHOOK TAB
-- ============================================================
local WebhookTab = Window:CreateTab("Webhook", "link")

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
    Name                     = "Discord User ID (mention rares)",
    CurrentValue             = "",
    PlaceholderText          = "Your Discord user ID...",
    RemoveTextAfterFocusLost = false,
    Flag                     = "DiscordUserID",
    Callback                 = function(text)
        Webhook.discordUserId = text and text:match("^%s*(.-)%s*$") or ""
    end,
})

WebhookTab:CreateToggle({
    Name         = "Send Webhook on Stage End",
    CurrentValue = false,
    Flag         = "WebhookOnFinish",
    Callback     = function(v)
        Webhook.sendOnFinish = v
    end,
})

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
-- MATCH END WEBHOOK
-- ============================================================
local itemNameCache = {}
local function getItemName(itemId)
    if itemNameCache[itemId] then return itemNameCache[itemId] end
    local itemsData = ReplicatedStorage.shared.config.items.data
    for _, obj in ipairs(itemsData:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name == itemId then
            local ok, config = pcall(require, obj)
            if ok and config and config.name then
                itemNameCache[itemId] = config.name
                return config.name
            end
        end
    end
    local cleaned = itemId:gsub("(%u)", " %1"):gsub("^%l", string.upper)
    itemNameCache[itemId] = cleaned
    return cleaned
end

local function setupMatchEndWebhook()
    if IS_LOBBY then return end

    local matchNet    = require(ReplicatedStorage.gameClient.net.match)
    local stages      = require(ReplicatedStorage.shared.config.stages)
    local selectStage = require(ReplicatedStorage.gameShared.store.slices.gamemode.selectors.selectStage)
    local selectAct   = require(ReplicatedStorage.gameShared.store.slices.gamemode.selectors.selectAct)
    local selectDiff  = require(ReplicatedStorage.gameShared.store.slices.gamemode.selectors.selectDifficulty)
    local selectGM    = require(ReplicatedStorage.gameShared.store.slices.gamemode.selectors.selectGamemode)

    matchNet.matchEnd.on(function(won, rewardsData, heroesExp, finalTime)
        if not Webhook.sendOnFinish then return end
        if not Webhook.url or Webhook.url == "" then return end

        local stageId   = clientStore:getState(selectStage)
        local actNumber = clientStore:getState(selectAct)  or 1
        local gamemode  = clientStore:getState(selectGM)   or "story"

        local stageData = stages.get(stageId)
        local mapName   = (stageData and stageData.name) or stageId or "Unknown"

        local title = string.format("%s (Act %d - %s) - %s",
            mapName, actNumber,
            tostring(gamemode):gsub("^%l", string.upper),
            won and "Victory" or "Defeat")

        local mins    = math.floor(finalTime / 60)
        local secs    = math.floor(finalTime % 60)
        local timeStr = string.format("%d:%02d", mins, secs)

        local rewardLines = {}
        for _, r in ipairs(rewardsData or {}) do
            table.insert(rewardLines, string.format("+ %s x%d", getItemName(r.id), r.amount))
        end
        local rewardStr = #rewardLines > 0 and table.concat(rewardLines, "\n") or "None"

        local expLines = {}
        for i, h in ipairs(heroesExp or {}) do
            local hero = getHeroByUuid(h.uuid)
            local name = hero and hero.name or h.uuid
            table.insert(expLines, string.format("%d - %s +%d exp", i, name, h.exp))
        end
        local expStr = #expLines > 0 and table.concat(expLines, "\n") or "None"

        local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
        if not requestFunc then return end

        pcall(function()
            requestFunc({
                Url     = Webhook.url,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = HttpService:JSONEncode({
                    username = "LixHub",
                    content  = "",
                    embeds   = {{
                        title  = title,
                        color  = won and 0x57F287 or 0xED4245,
                        fields = {
                            { name = "Player",  value = "||" .. Players.LocalPlayer.Name .. "||", inline = true },
                            { name = "Won in",  value = timeStr,  inline = true },
                            { name = "Rewards", value = rewardStr, inline = false },
                            { name = "Hero EXP", value = expStr,  inline = false },
                        },
                        footer    = { text = "discord.gg/cYKnXE2Nf8" },
                        timestamp = DateTime.now():ToIsoDate(),
                    }},
                }),
            })
        end)
    end)
end

-- ============================================================
-- AUTO CARD SELECTION
-- ============================================================
local function setupAutoCardSelection()
    local gamemodesNet = require(ReplicatedStorage:WaitForChild("gameClient"):WaitForChild("net"):WaitForChild("gamemodesNet"))

    gamemodesNet.showInfCards.on(function(cardIds)
        if not State.AutoPickCards then return end
        if not cardIds or #cardIds == 0 then return end
        local bestId, bestScore = nil, -1
        for _, id in ipairs(cardIds) do
            local score = State.CardPriorities[id]
            if score then
                if score > bestScore then bestScore = score; bestId = id end
            else
                warn("[LixHub] Unknown card ID: " .. tostring(id))
            end
        end
        if bestId then
            print(string.format("[LixHub] Auto-selecting card: %s (priority %d)", bestId, bestScore))
            task.spawn(function()
                local ok, result = pcall(gamemodesNet.selectInfCard.call, bestId)
                if not ok then warn("[LixHub] selectInfCard failed: " .. tostring(result)) end
            end)
        else
            warn("[LixHub] No known cards in offer. IDs: " .. table.concat(cardIds, ", "))
        end
    end)

    gamemodesNet.showContracts.on(function(contractIds)
        if not State.AutoPickCards then return end
        if not contractIds or #contractIds == 0 then return end
        local bestId, bestScore = nil, -1
        for _, id in ipairs(contractIds) do
            local score = State.CardPriorities[id]
            if score then
                if score > bestScore then bestScore = score; bestId = id end
            else
                warn("[LixHub] Unknown contract ID: " .. tostring(id))
            end
        end
        if bestId then
            print(string.format("[LixHub] Auto-selecting contract: %s (priority %d)", bestId, bestScore))
            task.spawn(function()
                local ok, result = pcall(gamemodesNet.selectContract.call, bestId)
                if not ok then warn("[LixHub] selectContract failed: " .. tostring(result)) end
            end)
        else
            warn("[LixHub] No known contracts in offer. IDs: " .. table.concat(contractIds, ", "))
        end
    end)

    print("[LixHub] Auto card active.")
end

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
            if not MacroSystem.isPlaying and not MacroSystem.pendingPlayback then
                local ok1, gmSel    = pcall(require, ReplicatedStorage.gameShared.store.slices.gamemode.selectors.selectGamemode)
                local ok2, stageSel = pcall(require, ReplicatedStorage.gameShared.store.slices.gamemode.selectors.selectStage)
                if ok1 and ok2 then
                    local gm      = clientStore:getState(gmSel)    or ""
                    local stageId = clientStore:getState(stageSel) or ""
                    local mapped  = worldMacroMappings[gm .. ":" .. stageId]
                    if mapped and MacroSystem.library[mapped] and #MacroSystem.library[mapped] > 0 then
                        MacroSystem.currentMacroName = mapped
                        refreshDropdown()
                        if MacroSystem.playback(mapped) then
                            pushUI("Macro: " .. mapped .. " | Playing", "Auto-started from Macro Maps")
                            pushNotify({ Title = "Macro Maps", Content = "Auto-playing: " .. mapped, Duration = 3, Image = "play" })
                        end
                    end
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

        if State.AutoLobby then
        game:GetService("TeleportService"):Teleport(126297188712308)
    end
        if State.ChallengeBug then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("voting"):WaitForChild("voting_RELIABLE")
                local buf2 = buffer.create(2)
                buffer.writeu8(buf2, 0, 6)
                buffer.writeu8(buf2, 1, 0)
                remote:FireServer(buf2, {})
            end)
        end
        if State.ChallengeRotationPending then
    State.ChallengeRotationPending = false
    pushNotify({ Title = "Challenge Rotation", Content = "Heading to lobby for new challenges!", Duration = 4, Image = "refresh-cw" })
    game:GetService("TeleportService"):Teleport(126297188712308)
end
    end)
end

-- ============================================================
-- CHALLENGE ROTATION WATCHER
-- ============================================================
task.spawn(function()
    while true do
        task.wait(1)
        if not State.ChallengeAutoLobbyOnRotation then continue end
        local t = os.time()
        if t % 3600 == 0 then
            State.ChallengeRotationPending = true
            pushNotify({ Title = "Challenge Rotation", Content = "New challenges available — will return to lobby on game end.", Duration = 5, Image = "refresh-cw" })
            task.wait(2)
        end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
ensureFolders()
MacroSystem.loadAll()
loadWorldMappings()
refreshDropdown()
refreshAutoSelectDropdowns()
task.wait(0.5)
for mapKey, macroName in pairs(worldMacroMappings) do
    if worldMacroDropdowns[mapKey] and MacroSystem.library[macroName] then
        pcall(function() worldMacroDropdowns[mapKey]:Set(macroName) end)
    end
end

if IS_LOBBY then
    pushUI("Macro: — | Lobby", "Hooks inactive in lobby — enter a game to record or play")
    print("[LixHub] Lobby detected — running auto join.")
    setupAutoJoin()
else
    setupHooks()
    setupWaveHook()
    setupMatchEndHook()
    setupMatchEndWebhook()
    setupAutoCardSelection()
    print("[LixHub] In-game — hooks active.")
end

Rayfield:LoadConfiguration()

pushNotify({ Title = "LixHub Loaded", Content = IS_LOBBY and "Running in lobby — hooks inactive." or "Macro system ready.", Duration = 3, Image = "check-circle" })

Rayfield:TopNotify({
    Title     = "UI is hidden",
    Content   = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image     = "eye-off",
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration  = 5
})
