local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.01"

-- Create Window
local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Last Stand",
   Icon = 0,
   LoadingTitle = "Loading for Anime Last Stand",
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
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub",
      FileName = "Lixhub_ALS"
   },
   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },
   KeySystem = true,
      KeySettings = {
      Title = "LixHub - Anime Last Stand - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer

local State = {
    isRecording = false,
    isPlaybacking = false,
    gameInProgress = false,
    gameStartTime = 0,
}

local macro = {}
local macroManager = {}
local currentMacroName = ""

local trackedUnits = {}
local recordingPlacementCounter = {}

local playbackUnitMapping = {}

local function ensureMacroFolders()
    if not isfolder("LixHub") then makefolder("LixHub") end
    if not isfolder("LixHub/Macros") then makefolder("LixHub/Macros") end
    if not isfolder("LixHub/Macros/Game2") then makefolder("LixHub/Macros/Game2") end
end

local function getMacroFilename(name)
    if type(name) == "table" then name = name[1] or "" end
    if type(name) ~= "string" or name == "" then return nil end
    return "LixHub/Macros/Game2/" .. name .. ".json"
end

local function saveMacroToFile(name)
    local data = macroManager[name]
    if not data then return end
    
    local json = Services.HttpService:JSONEncode(data)
    writefile(getMacroFilename(name), json)
    print("Saved macro:", name)
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not isfile(filePath) then return nil end
    
    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)
    macroManager[name] = data
    return data
end

local function loadAllMacros()
    macroManager = {}
    for _, file in ipairs(listfiles("LixHub/Macros/Game2/")) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            loadMacroFromFile(name)
        end
    end
end

local function deleteMacroFile(name)
    if isfile(getMacroFilename(name)) then
        delfile(getMacroFilename(name))
    end
    macroManager[name] = nil
end

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function onGameStart()
    State.gameInProgress = true
    State.gameStartTime = tick()
    trackedUnits = {}
    playbackUnitMapping = {}
    recordingPlacementCounter = {}
    print("Game started at:", State.gameStartTime)
end

local function onGameEnd()
    State.gameInProgress = false
    
    if State.isRecording then
        State.isRecording = false
        if currentMacroName and #macro > 0 then
            macroManager[currentMacroName] = macro
            saveMacroToFile(currentMacroName)
            print("📹 Recording auto-saved:", currentMacroName, "with", #macro, "actions")
        end
    end
    
    print("🏁 Game ended")
end

local function findNewlyPlacedTower(unitName, targetPosition, tolerance)
    tolerance = tolerance or 10
    
    local towers = Services.Workspace:FindFirstChild("Towers")
    if not towers then return nil end
    
    local closestTower = nil
    local closestDistance = math.huge
    
    for _, tower in pairs(towers:GetChildren()) do
        if trackedUnits[tower] then continue end
        
        if tower.Name:find(unitName) then
            local towerPos = tower:GetPivot().Position
            local distance = (towerPos - targetPosition).Magnitude
            
            if distance < tolerance and distance < closestDistance then
                closestTower = tower
                closestDistance = distance
            end
        end
    end
    return closestTower
end

local function processPlacementAction(unitName, cframe)
    print("📝 Processing placement:", unitName, "at", cframe.Position)
    
    task.wait(0.5)
    
    local tower = findNewlyPlacedTower(unitName, cframe.Position)
    
    if not tower then
        warn("❌ Could not find placed tower:", unitName)
        return
    end
    
    -- Increment placement counter
    recordingPlacementCounter[unitName] = (recordingPlacementCounter[unitName] or 0) + 1
    local placementNumber = recordingPlacementCounter[unitName]
    local placementId = string.format("%s #%d", unitName, placementNumber)
    
    -- Record to macro
    local gameRelativeTime = tick() - State.gameStartTime
    
    local record = {
        Type = "place_tower",
        Unit = placementId,
        UnitName = unitName,
        Time = string.format("%.2f", gameRelativeTime),
        Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z},
        Rotation = {cframe:ToEulerAnglesXYZ()}
    }
    
    table.insert(macro, record)
    
    trackedUnits[tower] = placementId
    
    print(string.format("Recorded: %s → Instance: %s", placementId, tower.Name))
end

local function processUpgradeAction(towerInstance)
    local placementId = trackedUnits[towerInstance]
    
    if not placementId then
        warn("❌ Upgrade attempted on untracked tower:", towerInstance.Name)
        return
    end
    
    local gameRelativeTime = tick() - State.gameStartTime
    
    local record = {
        Type = "upgrade_tower",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime)
    }
    
    table.insert(macro, record)
    print(string.format("Recorded upgrade: %s", placementId))
end

local function processSellAction(towerInstance)
    local placementId = trackedUnits[towerInstance]
    
    if not placementId then
        warn("Sell attempted on untracked tower:", towerInstance.Name)
        return
    end
    
    local gameRelativeTime = tick() - State.gameStartTime
    
    local record = {
        Type = "sell_tower",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime)
    }
    
    table.insert(macro, record)
    
    trackedUnits[towerInstance] = nil
    
    print(string.format("Recorded sell: %s", placementId))
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local originalNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and State.isRecording and State.gameInProgress then
        task.spawn(function()
            if method == "FireServer" and self.Name == "PlaceTower" then
                local unitName = args[1]
                local cframe = args[2]
                
                if unitName and cframe then
                    processPlacementAction(unitName, cframe)
                end
            end
            
            if method == "InvokeServer" and self.Name == "Upgrade" then
                local towerInstance = args[1]
                
                if towerInstance and towerInstance:IsA("Model") then
                    processUpgradeAction(towerInstance)
                end
            end
            
            if method == "InvokeServer" and self.Name == "Sell" then
                local towerInstance = args[1]
                
                if towerInstance and towerInstance:IsA("Model") then
                    processSellAction(towerInstance)
                end
            end
        end)
    end
    
    return originalNamecall(self, ...)
end)
setreadonly(mt, true)

local function executePlacement(action)
    local unitName = action.UnitName
    local pos = action.Position
    local rot = action.Rotation
    
    -- Reconstruct CFrame
    local cframe = CFrame.new(pos[1], pos[2], pos[3]) * CFrame.Angles(rot[1], rot[2], rot[3])
    
    print(string.format("🏗️ Placing: %s at (%.1f, %.1f, %.1f)", unitName, pos[1], pos[2], pos[3]))
    
    -- Fire placement remote
    local success = pcall(function()
        Services.ReplicatedStorage.Remotes.PlaceTower:FireServer(unitName, cframe)
    end)
    
    if not success then
        warn("❌ Failed to place:", unitName)
        return false
    end
    
    -- Wait for tower to spawn and find it
    task.wait(0.5)
    
    local tower = findNewlyPlacedTower(unitName, Vector3.new(pos[1], pos[2], pos[3]))
    
    if tower then
        playbackUnitMapping[action.Unit] = tower
        print(string.format("✅ Placed and mapped: %s → %s", action.Unit, tower.Name))
        return true
    else
        warn("❌ Could not find placed tower:", action.Unit)
        return false
    end
end

local function executeUpgrade(action)
    local towerInstance = playbackUnitMapping[action.Unit]
    
    if not towerInstance or not towerInstance.Parent then
        warn("Tower not found for upgrade:", action.Unit)
        return false
    end
    
    print(string.format("Upgrading: %s", action.Unit))
    
    local success = pcall(function()
        Services.ReplicatedStorage.Remotes.Upgrade:InvokeServer(towerInstance)
    end)
    
    if success then
        print("Upgrade successful")
        return true
    else
        warn("Upgrade failed")
        return false
    end
end

local function executeSell(action)
    local towerInstance = playbackUnitMapping[action.Unit]
    
    if not towerInstance or not towerInstance.Parent then
        warn("Tower not found for sell:", action.Unit)
        return false
    end
    
    print(string.format("Selling: %s", action.Unit))
    
    local success = pcall(function()
        Services.ReplicatedStorage.Remotes.Sell:InvokeServer(towerInstance)
    end)
    
    if success then
        playbackUnitMapping[action.Unit] = nil
        print("Sell successful")
        return true
    else
        warn("Sell failed")
        return false
    end
end

local function playMacroOnce()
    if not macro or #macro == 0 then
        print("❌ No macro data to play")
        return false
    end
    
    print("▶️ Starting macro playback...")
    
    -- Clear mapping
    playbackUnitMapping = {}
    
    local playbackStartTime = State.gameStartTime
    if playbackStartTime == 0 then
        playbackStartTime = tick()
    end
    
    for i, action in ipairs(macro) do
        if not State.isPlaybacking or not State.gameInProgress then
            print("⏹️ Playback stopped")
            return false
        end
        
        local actionTime = tonumber(action.Time) or 0
        local currentTime = tick() - playbackStartTime
        
        -- Wait for correct timing
        if currentTime < actionTime then
            local waitTime = actionTime - currentTime
            print(string.format("⏳ Waiting %.1fs for action %d/%d", waitTime, i, #macro))
            
            local waitStart = tick()
            while (tick() - waitStart) < waitTime and State.isPlaybacking and State.gameInProgress do
                task.wait(0.1)
            end
        end
        
        if not State.isPlaybacking or not State.gameInProgress then break end
        
        -- Execute action
        if action.Type == "place_tower" then
            executePlacement(action)
        elseif action.Type == "upgrade_tower" then
            executeUpgrade(action)
        elseif action.Type == "sell_tower" then
            executeSell(action)
        end
        
        task.wait(0.1)
    end
    
    print("✅ Macro playback completed")
    return true
end

-- ============================================
-- PUBLIC API
-- ============================================
local MacroSystem = {}

function MacroSystem.StartRecording()
    if not State.gameInProgress then
        warn("❌ Cannot record - game not in progress")
        return false
    end
    
    State.isRecording = true
    table.clear(macro)
    trackedUnits = {}
    recordingPlacementCounter = {}
    
    print("🔴 Recording started")
    return true
end

function MacroSystem.StopRecording()
    State.isRecording = false
    
    if currentMacroName and #macro > 0 then
        macroManager[currentMacroName] = macro
        saveMacroToFile(currentMacroName)
        print(string.format("⏹️ Recording stopped - saved %d actions", #macro))
        return true
    end
    
    print("⏹️ Recording stopped - no actions recorded")
    return false
end

function MacroSystem.StartPlayback()
    if not State.gameInProgress then
        warn("❌ Cannot playback - game not in progress")
        return false
    end
    
    if not currentMacroName or not macroManager[currentMacroName] then
        warn("❌ No macro selected")
        return false
    end
    
    macro = macroManager[currentMacroName]
    State.isPlaybacking = true
    
    task.spawn(playMacroOnce)
    return true
end

function MacroSystem.StopPlayback()
    State.isPlaybacking = false
    print("⏹️ Playback stopped")
end

function MacroSystem.CreateMacro(name)
    if macroManager[name] then
        warn("❌ Macro already exists:", name)
        return false
    end
    
    macroManager[name] = {}
    saveMacroToFile(name)
    print("✅ Created macro:", name)
    return true
end

function MacroSystem.DeleteMacro(name)
    deleteMacroFile(name)
    if name == currentMacroName then
        currentMacroName = ""
        macro = {}
    end
    print("🗑️ Deleted macro:", name)
end

function MacroSystem.SelectMacro(name)
    if not macroManager[name] then
        warn("❌ Macro not found:", name)
        return false
    end
    
    currentMacroName = name
    macro = macroManager[name]
    print("✅ Selected macro:", name, "with", #macro, "actions")
    return true
end

function MacroSystem.GetMacroList()
    local list = {}
    for name in pairs(macroManager) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

function MacroSystem.GetCurrentMacro()
    return currentMacroName
end

function MacroSystem.IsRecording()
    return State.isRecording
end

function MacroSystem.IsPlaybacking()
    return State.isPlaybacking
end

-- ============================================
-- INITIALIZATION
-- ============================================
ensureMacroFolders()
loadAllMacros()

-- Game state monitoring (adjust based on actual game)
task.spawn(function()
    while true do
        task.wait(1)
        
        local towers = Services.Workspace:FindFirstChild("Towers")
        if towers then
            local hasTowers = #towers:GetChildren() > 0
            
            if hasTowers and not State.gameInProgress then
                onGameStart()
            elseif not hasTowers and State.gameInProgress then
                onGameEnd()
            end
        end
    end
end)

print("✅ Macro System initialized")
print("📁 Loaded", #MacroSystem.GetMacroList(), "macros")

return MacroSystem
