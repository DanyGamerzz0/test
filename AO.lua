-- ============================================================
-- LIXHUB - ANIME OVERLOAD MACRO SYSTEM WITH UI
-- ============================================================

if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller
    and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED")
    return
end

-- ============================================================
-- SERVICES & MODULES
-- ============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")

local gameClient = ReplicatedStorage:WaitForChild("gameClient")
local net        = gameClient:WaitForChild("net")

local ecs    = require(ReplicatedStorage.Packages._Index["dodoloco_feecs@5.0.4"].feecs)
local towers = require(net:WaitForChild("towers"))
local sync   = require(net:WaitForChild("sync"))

-- ── Cost utilities ───────────────────────
local getPlacementCost                     = require(ReplicatedStorage.gameShared.utilities.getPlacementCost)
local calculateClientUpgradeCostMultiplier = require(ReplicatedStorage.gameClient.utilities.calculateClientUpgradeCostMultiplier)
local selectPlayerYen                      = require(ReplicatedStorage.gameShared.store.slices.currency.selectors.selectPlayerYen)()

-- ============================================================
-- HERO HELPERS
-- ============================================================
local clientStore    = require(gameClient.store.clientStore)
local selectEquipped = require(ReplicatedStorage.shared.store.slices.data.selectors.heroes.selectPlayerEquippedHeroes)()

local function getYen()
    return clientStore:getState(selectPlayerYen) or 0
end

local function getEquippedHeroes()
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

-- ── File helpers ─────────────────────────
local FOLDER       = "LixHub"
local MACRO_FOLDER = "LixHub/Macros/AO"

local function ensureFolders()
    if not isfolder(FOLDER)               then makefolder(FOLDER)               end
    if not isfolder(FOLDER .. "/Macros")  then makefolder(FOLDER .. "/Macros")  end
    if not isfolder(MACRO_FOLDER)         then makefolder(MACRO_FOLDER)         end
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
    local s = { total = #actions, placements = 0, upgrades = 0, sells = 0, autoUpgrades = 0, duration = 0 }
    for _, a in ipairs(actions) do
        if     a.action == "PLACE"        then s.placements   = s.placements   + 1
        elseif a.action == "UPGRADE"      then s.upgrades     = s.upgrades     + 1
        elseif a.action == "SELL"         then s.sells        = s.sells        + 1
        elseif a.action == "AUTO_UPGRADE" then s.autoUpgrades = s.autoUpgrades + 1
        end
        local t = tonumber(a.time) or 0
        if t > s.duration then s.duration = t end
    end
    return s
end

-- ── Import / Export ──────────────────────
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

-- ── Recording ────────────────────────────
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

-- ── Position search ───────────────────────
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

-- ── Hooks ────────────────────────────────
local function setupHooks()

    -- PLACE
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

        recordAction("PLACE", {
            unitLabel = label,
            position  = pos,
            rotation  = { rx, ry, rz },
        })

        return success, liveTowerID
    end

    -- UPGRADE
    local oldUpgrade = towers.upgradeUnit.call
    towers.upgradeUnit.call = function(towerID)
        local success, errorMsg = oldUpgrade(towerID)
        if success and MacroSystem.isRecording then
            recordAction("UPGRADE", {
                unitLabel = liveTowerLabelMap[towerID] or "unknown",
            })
        end
        return success, errorMsg
    end

    -- SELL
    local oldSell = towers.sellUnit.call
    towers.sellUnit.call = function(towerID)
        local success, errorMsg = oldSell(towerID)
        if success and MacroSystem.isRecording then
            recordAction("SELL", {
                unitLabel = liveTowerLabelMap[towerID] or "unknown",
            })
            liveTowerLabelMap[towerID] = nil
            mappedUids[towerID]        = nil
        end
        return success, errorMsg
    end

    -- AUTO-UPGRADE
    local oldAuto = towers.changeUpgradePriority.call
    towers.changeUpgradePriority.call = function(towerID)
        local success, errorMsg = oldAuto(towerID)
        if success and MacroSystem.isRecording then
            recordAction("AUTO_UPGRADE", {
                unitLabel = liveTowerLabelMap[towerID] or "unknown",
            })
        end
        return success, errorMsg
    end
end

-- ── Playback ─────────────────────────────

-- Blocks until player can afford cost or playback is stopped.
-- Returns true if we can proceed, false if playback was stopped while waiting.
local function waitForYen(cost, label, actionType, index, total)
    if getYen() >= cost then return true end
    warn(string.format("[LixHub] [%d/%d] ⏳ %s %s waiting for %d yen (have %d)...",
        index, total, actionType, label, cost, getYen()))
    while MacroSystem.isPlaying and getYen() < cost do
        task.wait(0.1)
    end
    return MacroSystem.isPlaying
end

function MacroSystem.playback(name)
    if MacroSystem.isPlaying then return false end
    local actions = MacroSystem.library[name]
    if not actions or #actions == 0 then return false end

    MacroSystem.isPlaying = true
    mappedUids = {}
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

            -- In normal mode: wait the recorded delta between actions.
            -- In ignore timing mode: fire immediately, only blocked by yen waits
            -- and the mandatory 0.1s placement replication delay.
            if not MacroSystem.ignoreTiming and i > 1 then
                local dt = (tonumber(actions[i].time) or 0) - (tonumber(actions[i-1].time) or 0)
                if dt > 0 then task.wait(dt) end
            end

            local label    = action.unitLabel or "?"
            local baseName = label:match("^(.-)%s*#%d+$") or label

            if action.action == "PLACE" then
                local uuid = nameToUuid[baseName]
                if not uuid then
                    warn(string.format("[LixHub] [%d/%d] ❌ PLACE: no uuid for '%s'", i, #actions, baseName))
                else
                    local hero = nameToHero[baseName]

                    if hero and hero.config then
                        local cost = hero.config.cost or 0
                        if not waitForYen(cost, label, "PLACE", i, #actions) then goto continue end
                    end

                    local pos = action.position
                    local rot = action.rotation or {0, 0, 0}
                    local cf  = CFrame.new(pos[1], pos[2], pos[3])
                            * CFrame.Angles(rot[1], rot[2], rot[3])
                    local success, _ = sync.clientTowerPlacement.call(uuid, cf)
                    if success then
                        -- Mandatory replication wait regardless of timing mode
                        task.wait(0.1)
                        local uid = findPlacedTowerByPosition(pos)
                        if uid then
                            labelToLiveTowerID[label] = uid
                            labelToLevel[label]       = 1
                            print(string.format("[LixHub] [%d/%d] ✅ PLACE %s", i, #actions, label))
                        else
                            warn(string.format("[LixHub] [%d/%d] ❌ PLACE: could not find tower for %s", i, #actions, label))
                        end
                    else
                        warn(string.format("[LixHub] [%d/%d] ❌ PLACE failed: %s", i, #actions, label))
                    end
                end

            elseif action.action == "UPGRADE" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local hero         = nameToHero[baseName]
                    local currentLevel = labelToLevel[label] or 1

                    if hero and hero.config and hero.config.upgradeValues then
                        local nextData = hero.config.upgradeValues[currentLevel + 1]
                        if nextData and nextData.cost and nextData.cost > 0 then
                            local multiplier = calculateClientUpgradeCostMultiplier(currentLevel + 1)
                            local actualCost = math.floor(nextData.cost * multiplier)
                            if not waitForYen(actualCost, label, "UPGRADE", i, #actions) then goto continue end
                        end
                    end

                    local success = towers.upgradeUnit.call(tid)
                    if success then
                        labelToLevel[label] = currentLevel + 1
                        print(string.format("[LixHub] [%d/%d] ✅ UPGRADE %s (lvl %d)", i, #actions, label, labelToLevel[label]))
                    else
                        warn(string.format("[LixHub] [%d/%d] ❌ UPGRADE failed: %s", i, #actions, label))
                    end
                else
                    warn(string.format("[LixHub] [%d/%d] ❌ UPGRADE: no towerID for '%s'", i, #actions, label))
                end

            elseif action.action == "SELL" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local success = towers.sellUnit.call(tid)
                    if success then
                        labelToLiveTowerID[label] = nil
                        labelToLevel[label]       = nil
                        print(string.format("[LixHub] [%d/%d] ✅ SELL %s", i, #actions, label))
                    else
                        warn(string.format("[LixHub] [%d/%d] ❌ SELL failed: %s", i, #actions, label))
                    end
                else
                    warn(string.format("[LixHub] [%d/%d] ❌ SELL: no towerID for '%s'", i, #actions, label))
                end

            elseif action.action == "AUTO_UPGRADE" then
                local tid = labelToLiveTowerID[label]
                if tid then
                    local success = towers.changeUpgradePriority.call(tid)
                    if success then
                        print(string.format("[LixHub] [%d/%d] ✅ AUTO_UPGRADE %s", i, #actions, label))
                    else
                        warn(string.format("[LixHub] [%d/%d] ❌ AUTO_UPGRADE failed: %s", i, #actions, label))
                    end
                else
                    warn(string.format("[LixHub] [%d/%d] ❌ AUTO_UPGRADE: no towerID for '%s'", i, #actions, label))
                end
            end

            ::continue::
        end

        MacroSystem.isPlaying = false
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
-- RAYFIELD UI
-- ============================================================
local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua"
))()

local Window = Rayfield:CreateWindow({
    Name             = "LixHub - Anime Overload",
    Icon             = 0,
    LoadingTitle     = "Loading LixHub",
    LoadingSubtitle  = "Macro System",
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
        FileName   = game:GetService("Players").LocalPlayer.Name .. "_AnimeOverload_Macro"
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

local StatusLabel = MacroTab:CreateLabel("Status: Ready")
local DetailLabel = MacroTab:CreateLabel("Detail: —")

MacroTab:CreateDivider()

-- ── Helpers ──────────────────────────────
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
        StatusLabel:Set("Status: Ready")
        DetailLabel:Set("Detail: —")
        return
    end
    local s = MacroSystem.getStats(name)
    if s then
        StatusLabel:Set(string.format("Status: '%s'  (%d actions)", name, s.total))
        DetailLabel:Set(string.format(
            "Detail: %d placements  •  %d upgrades  •  %d sells  •  %d auto  •  %.1fs",
            s.placements, s.upgrades, s.sells, s.autoUpgrades, s.duration))
    else
        StatusLabel:Set("Status: '" .. name .. "'")
        DetailLabel:Set("Detail: empty")
    end
end

-- ── Dropdown ─────────────────────────────
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

-- ── Create ───────────────────────────────
MacroTab:CreateInput({
    Name                     = "Create Macro",
    PlaceholderText          = "Enter macro name...",
    RemoveTextAfterFocusLost = true,
    Flag                     = "CreateMacroInput",
    Callback                 = function(text)
        if not text or text == "" then
            return Rayfield:Notify({ Title = "Error", Content = "Name cannot be empty", Duration = 3, Image = "x-circle" })
        end
        local clean = text:gsub('[<>:"/\\|?*]', ""):match("^%s*(.-)%s*$")
        if clean == "" then
            return Rayfield:Notify({ Title = "Error", Content = "Invalid name", Duration = 3, Image = "x-circle" })
        end
        if MacroSystem.library[clean] then
            return Rayfield:Notify({ Title = "Error", Content = "'" .. clean .. "' already exists", Duration = 3, Image = "x-circle" })
        end
        MacroSystem.library[clean]   = {}
        MacroSystem.save(clean)
        MacroSystem.currentMacroName = clean
        refreshDropdown()
        StatusLabel:Set("Status: Created '" .. clean .. "'")
        DetailLabel:Set("Detail: Ready to record")
        Rayfield:Notify({ Title = "Created", Content = "'" .. clean .. "'", Duration = 3, Image = "check-circle" })
    end,
})

-- ── Refresh / Delete ─────────────────────
MacroTab:CreateButton({
    Name     = "Refresh Macro List",
    Callback = function()
        MacroSystem.loadAll()
        refreshDropdown()
        Rayfield:Notify({ Title = "Refreshed", Content = #MacroSystem.getList() .. " macro(s) loaded", Duration = 2, Image = "refresh-cw" })
    end,
})

MacroTab:CreateButton({
    Name     = "Delete Selected Macro",
    Callback = function()
        local name = MacroSystem.currentMacroName
        if name == "" then
            return Rayfield:Notify({ Title = "Error", Content = "No macro selected", Duration = 3, Image = "x-circle" })
        end
        MacroSystem.delete(name)
        MacroSystem.currentMacroName = ""
        refreshDropdown()
        StatusLabel:Set("Status: Ready")
        DetailLabel:Set("Detail: —")
        Rayfield:Notify({ Title = "Deleted", Content = "'" .. name .. "'", Duration = 3, Image = "trash-2" })
    end,
})

MacroTab:CreateDivider()

-- ── Record toggle ─────────────────────────
RecordToggle = MacroTab:CreateToggle({
    Name         = "Record Macro",
    CurrentValue = false,
    Flag         = "RecordMacro",
    Callback     = function(value)
        if value then
            if MacroSystem.currentMacroName == "" then
                Rayfield:Notify({ Title = "Error", Content = "Create or select a macro first", Duration = 3, Image = "x-circle" })
                RecordToggle:Set(false)
                return
            end

            local ok, clientStoreLocal = pcall(require, ReplicatedStorage.gameClient.store.clientStore)
            local ok2, selectWave      = pcall(require, ReplicatedStorage.gameShared.store.slices.wave.selectors.selectWave)
            local currentWave = (ok and ok2) and clientStoreLocal:getState(selectWave) or nil

            if currentWave and currentWave > 1 then
                Rayfield:Notify({ Title = "Resetting Act...", Content = "Will record from Wave 1", Duration = 3, Image = "refresh-cw" })
                StatusLabel:Set("Status: ⏳ Resetting act...")
                DetailLabel:Set("Detail: Waiting for Wave 1 after reset")
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
                StatusLabel:Set("Status: ⏳ Armed — waiting for Wave 1...")
                DetailLabel:Set("Detail: Recording will begin automatically on Wave 1")
                Rayfield:Notify({ Title = "Armed", Content = "Will record when Wave 1 starts", Duration = 3, Image = "clock" })
            end
        else
            MacroSystem.pendingRecord = false
            if MacroSystem.isRecording then
                local actions = MacroSystem.stopRecording()
                if actions then
                    local s = MacroSystem.getStats(MacroSystem.currentMacroName)
                    StatusLabel:Set(string.format("Status: Saved '%s' (%d actions)", MacroSystem.currentMacroName, #actions))
                    if s then
                        DetailLabel:Set(string.format(
                            "Detail: %d placements  •  %d upgrades  •  %d sells  •  %d auto  •  %.1fs",
                            s.placements, s.upgrades, s.sells, s.autoUpgrades, s.duration))
                    end
                    refreshDropdown()
                    Rayfield:Notify({ Title = "Saved", Content = #actions .. " actions recorded", Duration = 4, Image = "save" })
                end
            else
                StatusLabel:Set("Status: Ready")
                DetailLabel:Set("Detail: —")
            end
        end
    end,
})

-- ── Playback toggle ───────────────────────
PlaybackToggle = MacroTab:CreateToggle({
    Name         = "Playback Macro",
    CurrentValue = false,
    Flag         = "PlaybackMacro",
    Callback     = function(value)
        if value then
            if MacroSystem.currentMacroName == "" then
                Rayfield:Notify({ Title = "Error", Content = "Select a macro first", Duration = 3, Image = "x-circle" })
                PlaybackToggle:Set(false)
                return
            end
            if not MacroSystem.library[MacroSystem.currentMacroName] or
               #MacroSystem.library[MacroSystem.currentMacroName] == 0 then
                Rayfield:Notify({ Title = "Error", Content = "Macro is empty or not found", Duration = 3, Image = "x-circle" })
                PlaybackToggle:Set(false)
                return
            end

            local ok, clientStoreLocal = pcall(require, ReplicatedStorage.gameClient.store.clientStore)
            local ok2, selectWave      = pcall(require, ReplicatedStorage.gameShared.store.slices.wave.selectors.selectWave)
            local currentWave = (ok and ok2) and clientStoreLocal:getState(selectWave) or nil

            if currentWave and currentWave > 1 then
                Rayfield:Notify({ Title = "Resetting Act...", Content = "Will playback from Wave 1", Duration = 3, Image = "refresh-cw" })
                StatusLabel:Set("Status: ⏳ Resetting act...")
                DetailLabel:Set("Detail: Waiting for Wave 1 after reset")
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
                StatusLabel:Set("Status: ⏳ Armed — waiting for Wave 1...")
                DetailLabel:Set("Detail: Playback will begin automatically on Wave 1")
                Rayfield:Notify({ Title = "Armed", Content = "Will playback when Wave 1 starts", Duration = 3, Image = "clock" })
            end
        else
            MacroSystem.pendingPlayback = false
            if MacroSystem.isPlaying then
                MacroSystem.stopPlayback()
                StatusLabel:Set("Status: Stopped")
                DetailLabel:Set("Detail: Ready")
                Rayfield:Notify({ Title = "Stopped", Content = "Playback stopped", Duration = 2, Image = "square" })
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
        Rayfield:Notify({
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
            return Rayfield:Notify({ Title = "Error", Content = "No macro selected", Duration = 3, Image = "x-circle" })
        end
        if MacroSystem.exportToClipboard(MacroSystem.currentMacroName) then
            Rayfield:Notify({ Title = "Exported", Content = "'" .. MacroSystem.currentMacroName .. "' copied to clipboard", Duration = 3, Image = "clipboard" })
        else
            Rayfield:Notify({ Title = "Error", Content = "Export failed", Duration = 3, Image = "x-circle" })
        end
    end,
})

MacroTab:CreateInput({
    Name                     = "Import Macro JSON",
    PlaceholderText          = "Paste JSON here...",
    RemoveTextAfterFocusLost = true,
    Flag                     = "ImportMacroJSON",
    Callback                 = function(jsonStr)
        if not jsonStr or jsonStr:match("^%s*$") then return end
        local importName = "Import_" .. os.time()
        local ok, result = MacroSystem.importFromJSON(importName, jsonStr)
        if ok then
            refreshDropdown()
            Rayfield:Notify({ Title = "Imported", Content = importName .. "  (" .. result .. " actions)", Duration = 4, Image = "download" })
        else
            Rayfield:Notify({ Title = "Import Failed", Content = tostring(result), Duration = 3, Image = "x-circle" })
        end
    end,
})

MacroTab:CreateButton({
    Name     = "View Macro Stats",
    Callback = function()
        if MacroSystem.currentMacroName == "" then
            return Rayfield:Notify({ Title = "Error", Content = "No macro selected", Duration = 3, Image = "x-circle" })
        end
        local s = MacroSystem.getStats(MacroSystem.currentMacroName)
        if s then
            Rayfield:Notify({
                Title   = MacroSystem.currentMacroName,
                Content = string.format(
                    "Total: %d\nPlace: %d  •  Upgrade: %d\nSell: %d  •  Auto: %d\nDuration: %.1fs",
                    s.total, s.placements, s.upgrades, s.sells, s.autoUpgrades, s.duration),
                Duration = 8,
                Image    = "bar-chart-2"
            })
        end
    end,
})

-- ============================================================
-- WAVE HOOK — auto-start recording/playback on Wave 1
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
                    StatusLabel:Set("Status: 🔴 Recording '" .. MacroSystem.currentMacroName .. "' — Wave 1")
                    DetailLabel:Set("Detail: Recording live")
                    Rayfield:Notify({ Title = "Recording Started", Content = "Wave 1 began", Duration = 3, Image = "circle" })
                end
            end

            if MacroSystem.pendingPlayback then
                MacroSystem.pendingPlayback = false
                if MacroSystem.playback(MacroSystem.currentMacroName) then
                    StatusLabel:Set("Status: ▶ Playing '" .. MacroSystem.currentMacroName .. "'")
                    DetailLabel:Set("Detail: Playback in progress...")
                    Rayfield:Notify({ Title = "Playback Started", Content = "Wave 1 began", Duration = 3, Image = "play" })
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

        -- Recording
        if MacroSystem.isRecording then
            local actions = MacroSystem.stopRecording()
            if actions then
                local s = MacroSystem.getStats(MacroSystem.currentMacroName)
                StatusLabel:Set(string.format("Status: Auto-saved '%s' (%d actions)", MacroSystem.currentMacroName, #actions))
                if s then
                    DetailLabel:Set(string.format(
                        "Detail: %d placements  •  %d upgrades  •  %d sells  •  %d auto  •  %.1fs",
                        s.placements, s.upgrades, s.sells, s.autoUpgrades, s.duration))
                end
                refreshDropdown()
                RecordToggle:Set(false)
                Rayfield:Notify({
                    Title    = "Auto-Saved",
                    Content  = "Match ended — " .. #actions .. " actions saved" .. (success and " ✅" or " ❌"),
                    Duration = 5,
                    Image    = "save"
                })
            end
        end

        if MacroSystem.pendingRecord then
            MacroSystem.pendingRecord = false
            RecordToggle:Set(false)
            StatusLabel:Set("Status: Ready")
            DetailLabel:Set("Detail: —")
            Rayfield:Notify({ Title = "Cancelled", Content = "Match ended before recording started", Duration = 3, Image = "x-circle" })
        end

        -- Playback — always stop and rearm if toggle is still on
        if MacroSystem.isPlaying then
            MacroSystem.stopPlayback()
        end

        if PlaybackToggle and PlaybackToggle.CurrentValue then
            MacroSystem.pendingPlayback = true
            StatusLabel:Set("Status: ⏳ Armed — waiting for Wave 1...")
            DetailLabel:Set("Detail: Playback will begin automatically on Wave 1")
            Rayfield:Notify({ Title = "Match Ended", Content = "Rearmed — waiting for next Wave 1", Duration = 3, Image = "refresh-cw" })
        elseif not MacroSystem.isRecording then
            StatusLabel:Set("Status: Ready")
            DetailLabel:Set("Detail: —")
        end
    end)
end

-- ============================================================
-- INIT
-- ============================================================
ensureFolders()
setupHooks()
setupWaveHook()
setupMatchEndHook()
MacroSystem.loadAll()
refreshDropdown()
Rayfield:LoadConfiguration()

Rayfield:Notify({ Title = "LixHub Loaded", Content = "Macro system ready!", Duration = 3, Image = "check-circle" })
print("[LixHub] Ready.")
