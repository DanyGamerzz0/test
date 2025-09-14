local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.01"

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Crusaders",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading for Anime Crusaders",
   LoadingSubtitle = script_version,
   ShowText = "LixHub", -- for mobile users to unhide rayfield, change if you'd like
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

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub", -- Create a custom folder for your hub/game
      FileName = "Lixhub_AC"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "cYKnXE2Nf8", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "LixHub - AC - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8", -- Use this to tell the user how to get a key
      FileName = "LixHub_Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"0xLIXHUB"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
}

local gameInProgress = false
local sessionItems = {}
local gameStartTime = 0
local lastWave = 0
local startStats = {}
local endStats = {}
local currentMapName = "Unknown Map"
local gameResult = "Unknown"
local itemNameCache = {}

--macro
local macro = {}
local macroManager = {}
local currentMacroName = ""
local isRecording = false
local isPlaybacking = false
local isRecordingLoopRunning = false
local isPlayingLoopRunning = false
local recordingStartTime = 0
local recordingHasStarted = false
local recordingPlacementCounter = 0
local playbackUnitMapping = {}
local currentWave = 0
local waveStartTime = 0
local currentPlacementOrder = 0
local playbackMode = "timing" -- "timing", "wave", or "both"
local script_version = "1.0.0" -- Update as needed
local unitMapping = {}
--

local itemAddedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("normal_item_added")
local gameFinishedRemote = Services.ReplicatedStorage:FindFirstChild("endpoints"):FindFirstChild("server_to_client"):FindFirstChild("game_finished")

local Config = {
    DISCORD_USER_ID = nil,
}

local AutoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2
}

local State = {
    SendStageCompletedWebhook = false,
    StoryStageSelected = nil,
    StoryStageMapping = nil,
    StoryActSelected = nil,
    StoryDifficultySelected = nil,
    AutoJoinStory = false,
    AutoJoinLegendStage = false,
    LegendStageSelected = nil,
    LegendActSelected = nil,
    AutoVoteRetry = false,
    AutoVoteNext = false,
    AutoVoteLobby = false,
}

local LobbyTab = Window:CreateTab("Lobby", "tv")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

section = JoinerTab:CreateSection("📖 Story Joiner 📖")

local function getItemDisplayName(itemName)
    -- Check cache first
    if itemNameCache[itemName] then
        return itemNameCache[itemName]
    end
    
    -- Try to find the item in Framework.Data.Items ModuleScripts
    local itemsPath = Services.ReplicatedStorage.Framework.Data.Items
    if itemsPath then
        -- Search through all ModuleScripts in the Items folder
        for _, moduleScript in pairs(itemsPath:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local success, itemData = pcall(require, moduleScript)
                if success and itemData then
                    -- Search through the module data for our item
                    for itemKey, data in pairs(itemData) do
                        if type(data) == "table" and data.id == itemName then
                            -- Found the item! Use the name field
                            local displayName = data.name
                            if displayName then
                                itemNameCache[itemName] = displayName
                                print("Found item mapping: " .. itemName .. " -> " .. displayName)
                                return displayName
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Fallback to formatted version if not found in ModuleScripts
    local displayName = itemName:gsub("_", " "):gsub("(%w)(%w*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    
    itemNameCache[itemName] = displayName
    return displayName
end

-- Function to get current map info
local function getMapInfo()
    local mapName = "Unknown Map"
    
    -- Try to get map data from GetLevelData
    if Services.Workspace:FindFirstChild("_MAP_CONFIG") and Services.Workspace._MAP_CONFIG:FindFirstChild("GetLevelData") then
        local success, result = pcall(function()
            return Services.Workspace._MAP_CONFIG.GetLevelData:InvokeServer()
        end)
        
        if success and result then
            -- Try different possible field names for the map name
            mapName = result.MapName or result.mapName or result.Name or result.name or 
                     result.LevelName or result.levelName or result.Map or result.map or "Unknown Map"
            
            print("📍 Map info retrieved:", mapName)
            print("📋 Full map data:", result)
        else
            print("❌ Failed to get map data:", result)
        end
    end
    
    return mapName
end

-- Function to capture current stats
local function captureStats()
    local player = Services.Players.LocalPlayer
    local stats = {}
    
    if player and player:FindFirstChild("_stats") then
        for _, statObj in pairs(player._stats:GetChildren()) do
            if statObj:IsA("IntValue") or statObj:IsA("NumberValue") then
                stats[statObj.Name] = statObj.Value
            end
        end
    end
    
    return stats
end

-- Function to calculate stat changes
local function getStatChanges()
    local changes = {}
    
    for statName, endValue in pairs(endStats) do
        -- Skip resource stat
        if statName ~= "resource" then
            local startValue = startStats[statName] or 0
            local change = endValue - startValue
            
            if change > 0 then
                changes[statName] = change
            end
        end
    end
    
    return changes
end

-- Function to format time as MM:SS
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", minutes, secs)
end

-- Function to print table contents recursively
local function printTableContents(tbl, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            print(spaces .. tostring(key) .. ": (table)")
            printTableContents(value, indent + 1)
        else
            print(spaces .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

local function getStatDisplayName(statName)
    local statMappings = {
        ["gem_amount"] = "Gems",
        ["player_xp"] = "XP"
    }
    
    return statMappings[statName] or getItemDisplayName(statName)
end

-- Enhanced webhook function based on yours
local function sendWebhook(messageType)
    if ValidWebhook == "YOUR_WEBHOOK_URL_HERE" then
        print("⚠️ Please set your Discord webhook URL first!")
        return
    end

    local data

        if messageType == "test" then
        data = {
            username = "LixHub Bot",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or "000000000000000000"),
            embeds = {{
                title = "📢 LixHub Notification",
                description = "🧪 Test webhook sent successfully",
                color = 0x5865F2,
                footer = { text = "LixHub Auto Logger" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }

    elseif messageType == "stage" then
    
local playerName = "||" .. Services.Players.LocalPlayer.Name .. "||"
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local gameDuration = tick() - gameStartTime
    local formattedTime = formatTime(gameDuration)
    
    -- Get stat changes (excluding resource)
    endStats = captureStats()
    local statChanges = getStatChanges()
    
    -- Format rewards text - NO EMOJIS
    local rewardsText = ""
    
    -- Add items if any were collected
    if next(sessionItems) then
        for itemName, quantity in pairs(sessionItems) do
            local displayName = getItemDisplayName(itemName)
            rewardsText = rewardsText .. "+" .. quantity .. " " .. displayName .. "\n"
        end
    end
    
    -- Add stat changes if any with total amounts (excluding resource)
    if next(statChanges) then
        for statName, change in pairs(statChanges) do
            local totalAmount = endStats[statName] or 0
            local displayStatName = getStatDisplayName(statName)
            rewardsText = rewardsText .. "+" .. change .. " " .. displayStatName .. " [" .. totalAmount .. "]\n"
        end
    end
    
    if rewardsText == "" then
        rewardsText = "No rewards gained this match"
    else
        rewardsText = rewardsText:gsub("\n$", "")
    end
    
    -- Custom footer
    local footerText = "discord.gg/cYKnXE2Nf8"
    
    -- Determine title and color based on game result
    local titleText = "Stage Completed!"
    local embedColor = 0x57F287
    
    if gameResult == "Victory" or gameResult == "Win" then
        titleText = "Stage Finished!"
        embedColor = 0x57F287
    elseif gameResult == "Defeat" or gameResult == "Loss" then
        titleText = "Stage Failed!"
        embedColor = 0xED4245
    end
    
     data = {
        username = "LixHub",
        embeds = {{
            title = titleText,
            description = currentMapName .. " - " .. gameResult,
            color = embedColor,
            fields = {
                { name = "Player", value = playerName, inline = true },
                { name = "Duration", value = formattedTime, inline = true },
                { name = "Waves Completed", value = tostring(currentWave), inline = true },
                { name = "Rewards", value = rewardsText, inline = false },
            },
            footer = { text = footerText },
            timestamp = timestamp
        }}
    }
end
    
    local payload = Services.HttpService:JSONEncode(data)
    
    -- Try different executor HTTP functions
    local requestFunc = nil
    
    if syn and syn.request then
        requestFunc = syn.request
    elseif request then
        requestFunc = request
    elseif http_request then
        requestFunc = http_request
    elseif fluxus and fluxus.request then
        requestFunc = fluxus.request
    elseif getgenv().request then
        requestFunc = getgenv().request
    end
    
    if not requestFunc then
        print("❌ No HTTP function found! Your executor might not support HTTP requests.")
        return
    end
    
    local success, response = pcall(function()
        return requestFunc({
            Url = ValidWebhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
    end)
    
    if success and response and (response.StatusCode == 204 or response.StatusCode == 200) then
        print("✅ Game summary webhook sent!")
    else
        print("❌ Webhook failed:", response and response.StatusCode or "No response")
        print("Response:", response)
    end
end

-- Function to start game tracking
local function startGameTracking()
    if gameInProgress then return end
    
    gameInProgress = true
    sessionItems = {}
    gameStartTime = tick()
    startStats = captureStats()
    currentMapName = getMapInfo()
    gameResult = "In Progress"
    
    print("Game tracking started at wave " .. currentWave .. "!")
    print("Map: " .. currentMapName)
    print("Captured starting stats:")
    for statName, value in pairs(startStats) do
        if statName ~= "resource" then -- Don't track resource
            print("  " .. statName .. ": " .. value)
        end
    end
end

-- Function to end game tracking
local function endGameTracking()
    if not gameInProgress then return end
    
    print("🏁 Game ended! Sending summary...")
    
    -- Send summary webhook
    sendWebhook("stage")
    
    -- Reset tracking
    gameInProgress = false
    sessionItems = {}
    gameStartTime = 0
    currentWave = 0
    lastWave = 0
    startStats = {}
    endStats = {}
    currentMapName = "Unknown Map"
    gameResult = "Unknown"
end

-- Monitor wave number for game start detection
local function monitorWaves()
    if not Services.Workspace:FindFirstChild("_wave_num") then
        print("⏳ Waiting for _wave_num...")
        Services.Workspace:WaitForChild("_wave_num")
    end
    
    local waveNum = Services.Workspace._wave_num
    
    -- Connect to value changes
    waveNum.Changed:Connect(function(newWave)
        currentWave = newWave
        
        -- Game start detection (wave 1 OR if we join mid-game)
        if newWave >= 1 and not gameInProgress then
            startGameTracking()
        -- Wave progress
        elseif newWave > lastWave and gameInProgress then
            print("Wave " .. newWave .. " started")
        end
        
        lastWave = newWave
    end)
    
    -- Check initial value - start tracking if wave is already active
    local initialWave = waveNum.Value
    if initialWave >= 1 then
        currentWave = initialWave
        lastWave = initialWave
        startGameTracking()
        print("🎮 Joined mid-game at wave " .. initialWave .. "!")
    end
    
    print("👁️ Monitoring wave changes for game start detection...")
end

local function getBackendWorldKeyFromDisplayName(selectedDisplayName)
    local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
    local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
    
    if not WorldsFolder or not WorldLevelOrder or not WorldLevelOrder.WORLD_ORDER then
        return nil
    end
    
    for _, orderedWorldKey in ipairs(WorldLevelOrder.WORLD_ORDER) do
        local worldModules = WorldsFolder:GetChildren()
        
        for _, worldModule in ipairs(worldModules) do
            if worldModule:IsA("ModuleScript") then
                local success, worldData = pcall(require, worldModule)
                
                if success and worldData and worldData[orderedWorldKey] then
                    local worldInfo = worldData[orderedWorldKey]
                    
                    if type(worldInfo) == "table" and worldInfo.name then
                        if worldInfo.name == selectedDisplayName then
                            return orderedWorldKey
                        end
                    end
                    break
                end
            end
        end
    end
    
    return nil
end

local function getBackendLegendWorldKeyFromDisplayName(selectedDisplayName)
    local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
    local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
    
    if not WorldsFolder or not WorldLevelOrder or not WorldLevelOrder.LEGEND_WORLD_ORDER then
        return nil
    end
    
    -- Only search through legend worlds that are in LEGEND_WORLD_ORDER
    for _, orderedWorldKey in ipairs(WorldLevelOrder.LEGEND_WORLD_ORDER) do
        -- Get all world modules to find the one containing this world
        local worldModules = WorldsFolder:GetChildren()
        
        for _, worldModule in ipairs(worldModules) do
            if worldModule:IsA("ModuleScript") then
                local success, worldData = pcall(require, worldModule)
                
                if success and worldData and worldData[orderedWorldKey] then
                    local worldInfo = worldData[orderedWorldKey]
                    
                    if type(worldInfo) == "table" and worldInfo.name and worldInfo.legend_stage then
                        if worldInfo.name == selectedDisplayName then
                            return orderedWorldKey -- Return the backend world key like "Shibuya_legend"
                        end
                    end
                    break -- Found the world, no need to check other modules
                end
            end
        end
    end
    
    return nil
end

local function serializeVector3(v)
    return { x = v.X, y = v.Y, z = v.Z }
end

local function serializeCFrame(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return {
        x = x, y = y, z = z,
        r00 = r00, r01 = r01, r02 = r02,
        r10 = r10, r11 = r11, r12 = r12,
        r20 = r20, r21 = r21, r22 = r22
    }
end

local function deserializeVector3(t)
    return Vector3.new(t.x, t.y, t.z)
end

local function deserializeCFrame(t)
    return CFrame.new(
        t.x, t.y, t.z,
        t.r00, t.r01, t.r02,
        t.r10, t.r11, t.r12,
        t.r20, t.r21, t.r22
    )
end

local function ensureMacroFolders()
    if not isfolder("LixHub") then
        makefolder("LixHub")
    end
    if not isfolder("LixHub/Macros") then
        makefolder("LixHub/Macros")
    end
    if not isfolder("LixHub/Macros/AC") then
        makefolder("LixHub/Macros/AC")
    end
end

local function getMacroFilename(name)
    -- Handle case where name might be a table
    if type(name) == "table" then
        name = name[1] or ""
    end
    
    -- Ensure name is a string
    if type(name) ~= "string" or name == "" then
        warn("getMacroFilename: Invalid name provided:", name)
        return nil
    end
    
    return "LixHub/Macros/AC/" .. name .. ".json"
end

local function saveMacroToFile(name)
    local data = macroManager[name]
    if not data then return end

    local serializedData = {}
    for _, action in ipairs(data) do
        local newAction = table.clone(action)
        if newAction.position then
            newAction.position = serializeVector3(newAction.position)
        end
        if newAction.cframe then
            newAction.cframe = serializeCFrame(newAction.cframe)
        end
        table.insert(serializedData, newAction)
    end

    local json = Services.HttpService:JSONEncode(serializedData)
    writefile(getMacroFilename(name), json)
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not isfile(filePath) then return end

    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)

    for _, action in ipairs(data) do
        if action.position then
            action.position = deserializeVector3(action.position)
        end
        if action.cframe then
            action.cframe = deserializeCFrame(action.cframe)
        end
    end
    macroManager[name] = data
    return data
end

local function deleteMacroFile(name)
    if isfile(getMacroFilename(name)) then
        delfile(getMacroFilename(name))
    end
    macroManager[name] = nil
end

local function loadAllMacros()
    macroManager = {}
    for _, file in ipairs(listfiles("LixHub/Macros/AC/")) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            loadMacroFromFile(name)
        end
    end
end

local function exportMacroToClipboard(macroName, format)
    format = format or "json" -- default to json
    
    if not macroName or macroName == "" then
        print("Export Error: No macro selected for export.")
        return false
    end
    
    local macroData = macroManager[macroName]
    if not macroData or #macroData == 0 then
        print("Export Error: Macro '" .. macroName .. "' is empty or doesn't exist.")
        return false
    end
    
    -- Create optimized export data
    local exportData = {
        version = script_version,
        actions = {}
    }
    
    -- Only include optional metadata if requested
    if format == "full" then
        exportData.macroName = macroName
        exportData.actionCount = #macroData
        exportData.exportTime = os.time()
    end
    
    -- Serialize the macro data with optimized structure
    for _, action in ipairs(macroData) do
        local serializedAction = {
            action = action.action,
            time = action.time,
            wave = action.wave
        }
        
        -- Add action-specific data
        if action.action == "PlaceUnit" then
            serializedAction.unitName = action.unitName
            serializedAction.cframe = serializeCFrame(action.cframe)
            serializedAction.rotation = action.rotation or 0
            serializedAction.unitId = action.unitId
            serializedAction.placementOrder = action.placementOrder
        elseif action.action == "UpgradeUnit" or action.action == "SellUnit" then
            serializedAction.targetPlacementOrder = action.targetPlacementOrder
        elseif action.action == "UltUnit" then
            serializedAction.targetPlacementOrder = action.targetPlacementOrder
            serializedAction.unitString = action.unitString
        end
        
        table.insert(exportData.actions, serializedAction)
    end
    
    local jsonData = Services.HttpService:JSONEncode(exportData)
    
    -- Format as .json file content
    local fileContent = jsonData
    local fileName = macroName .. ".json"
    
    -- Copy to clipboard
    local success, err = pcall(function()
        setclipboard(fileContent)
    end)
    
    if success then
        local sizeKB = math.floor(#fileContent / 1024 * 100) / 100
        print(string.format("Export Success: Macro '%s' exported as JSON (%d actions, %.2f KB)", 
            macroName, #macroData, sizeKB))
        return true
    else
        print("Export Error: Failed to copy to clipboard: " .. tostring(err))
        return false
    end
end

local MacroDropdown = MacroTab:CreateDropdown({
    Name = "Select Macro",
    Options = {},
    CurrentOption = currentMacroName,
    MultipleOptions = false,
    Flag = "MacroDropdown",
    Callback = function(selected)
        local selectedName
        if type(selected) == "table" then
            selectedName = selected[1]
        else
            selectedName = selected
        end

        print("User selected macro:", selectedName)
        currentMacroName = selectedName
        if selectedName and macroManager[selectedName] then
            macro = macroManager[selectedName]
            print("Selected macro '" .. selectedName .. "' with " .. #macro .. " actions.")
        else
            print("Invalid selection or macro doesn't exist:", selectedName)
        end
    end,
})

local function refreshMacroDropdown()
        local options = {}

        for name in pairs(macroManager) do
            table.insert(options, name)
        end

        table.sort(options)

        -- Handle case where currentMacroName might be a table
        if type(currentMacroName) == "table" then
            currentMacroName = currentMacroName[1] or ""
        end

        -- Only set currentMacroName to first option if it's completely empty/nil
        -- Don't override if it exists but isn't in macroManager (it might be loading from config)  
        if not currentMacroName or currentMacroName == "" then
            currentMacroName = options[1]
        end

        -- Only update macro if currentMacroName exists in macroManager
        if currentMacroName and macroManager[currentMacroName] then
            macro = macroManager[currentMacroName]
        end

        MacroDropdown:Refresh(options, currentMacroName)

        for i, opt in ipairs(options) do
            print("Option " .. i .. " = " .. tostring(opt) .. " (" .. typeof(opt) .. ")")
        end

        print("Refreshed dropdown with:", table.concat(options, ", "))
        print("Current macro is:", currentMacroName, "Type:", type(currentMacroName))
end

local function importMacroFromURL(url, targetMacroName)
    if not url or url == "" then
        print("Import Error: No URL provided for import.")
        return false
    end
    
    if not targetMacroName or targetMacroName == "" then
        print("Import Error: No target macro name specified.")
        return false
    end
    
    -- Check if target macro already exists and has data
    if macroManager[targetMacroName] and #macroManager[targetMacroName] > 0 then
        print("Import Error: Target macro '" .. targetMacroName .. "' already contains data. Use an empty macro.")
        return false
    end
    
    print("Importing... Downloading macro from URL...")
    
    -- Try to fetch the URL content
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        print("Import Error: Failed to download from URL: " .. tostring(result))
        return false
    end
    
    -- Try to parse the JSON
    local importData
    success, importData = pcall(function()
        return Services.HttpService:JSONDecode(result)
    end)
    
    if not success then
        print("Import Error: Invalid JSON data in downloaded file.")
        return false
    end
    
    -- Validate import data structure
    if not importData.actions or type(importData.actions) ~= "table" then
        print("Import Error: Invalid macro format - missing actions.")
        return false
    end
    
    -- Process and normalize the macro data (handle both compact and full formats)
    local deserializedActions = {}
    for _, action in ipairs(importData.actions) do
        local newAction = table.clone(action)
        
        -- Deserialize CFrame if present
        if newAction.cframe then
            newAction.cframe = deserializeCFrame(newAction.cframe)
        end
        
        -- Normalize action data for internal use
        if newAction.action == "PlaceUnit" then
            -- For compact format, we need to populate expected fields
            newAction.actualUnitName = newAction.actualUnitName or (newAction.unitName .. " 1")
            newAction.timestamp = newAction.timestamp or os.time()
        elseif newAction.action == "UpgradeUnit" or newAction.action == "SellUnit" then
            -- Ensure we have the target placement order
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            -- For compatibility, set unitName (will be resolved during playback)
            newAction.unitName = newAction.unitName or "TBD"
            newAction.actualUnitName = newAction.actualUnitName or "TBD"
        elseif newAction.action == "UltUnit" then
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            newAction.targetUnitName = newAction.targetUnitName or "TBD"
        end
        
        table.insert(deserializedActions, newAction)
    end
    
    -- Import the macro
    macroManager[targetMacroName] = deserializedActions
    
    -- Save to file
    local success, err = pcall(function()
        ensureMacroFolders()
        saveMacroToFile(targetMacroName)
    end)
    
    if not success then
        warn("Failed to save imported macro to file:", err)
    end

    refreshMacroDropdown()
    
    print("Import Success: Imported '" .. (importData.macroName or "Unknown") .. "' to '" .. targetMacroName .. "' (" .. #deserializedActions .. " actions)")
    return true
end

local function importMacroFromContent(jsonContent, targetMacroName)
    if not jsonContent or jsonContent:match("^%s*$") then
        print("Import Error: No JSON content provided.")
        return false
    end
    
    if not targetMacroName or targetMacroName == "" then
        print("Import Error: No target macro name specified.")
        return false
    end
    
    -- Check if target macro already exists and has data
    if macroManager[targetMacroName] and #macroManager[targetMacroName] > 0 then
        print("Import Error: Target macro '" .. targetMacroName .. "' already contains data. Use an empty macro name.")
        return false
    end
    
    -- Try to parse the JSON
    local importData
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(jsonContent)
    end)
    
    if not success then
        print("Import Error: Invalid JSON format. Please check your pasted content.")
        print("JSON Parse Error:", result)
        return false
    end
    
    importData = result
    
    -- Validate import data structure
    if not importData.actions or type(importData.actions) ~= "table" then
        print("Import Error: Invalid macro format - missing or invalid actions array.")
        return false
    end
    
    if #importData.actions == 0 then
        print("Import Error: Macro contains no actions.")
        return false
    end
    
    -- Process and normalize the macro data
    local deserializedActions = {}
    local actionCount = 0
    
    for i, action in ipairs(importData.actions) do
        local newAction = table.clone(action)
        
        -- Validate required fields
        if not newAction.action or not newAction.time or not newAction.wave then
            warn(string.format("Action #%d missing required fields (action/time/wave)", i))
            continue
        end
        
        -- Deserialize CFrame if present
        if newAction.cframe then
            newAction.cframe = deserializeCFrame(newAction.cframe)
        end
        
        -- Normalize action data for internal use
        if newAction.action == "PlaceUnit" then
            if not newAction.unitName or not newAction.cframe then
                warn(string.format("PlaceUnit action #%d missing unitName or cframe", i))
                continue
            end
            newAction.actualUnitName = newAction.actualUnitName or (newAction.unitName .. " 1")
            newAction.timestamp = newAction.timestamp or os.time()
            newAction.rotation = newAction.rotation or 0
            
        elseif newAction.action == "UpgradeUnit" or newAction.action == "SellUnit" then
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            newAction.unitName = newAction.unitName or "TBD"
            newAction.actualUnitName = newAction.actualUnitName or "TBD"
            
        elseif newAction.action == "UltUnit" then
            newAction.targetPlacementOrder = newAction.targetPlacementOrder or 0
            newAction.targetUnitName = newAction.targetUnitName or "TBD"
            
        else
            warn(string.format("Unknown action type '%s' in action #%d", newAction.action or "nil", i))
            continue
        end
        
        table.insert(deserializedActions, newAction)
        actionCount = actionCount + 1
    end
    
    if actionCount == 0 then
        print("Import Error: No valid actions found in the macro data.")
        return false
    end
    
    -- Import the macro
    macroManager[targetMacroName] = deserializedActions
    
    -- Save to file
    local saveSuccess, saveErr = pcall(function()
        ensureMacroFolders()
        saveMacroToFile(targetMacroName)
    end)
    
    if not saveSuccess then
        warn("Failed to save imported macro to file:", saveErr)
    end

    refreshMacroDropdown()
    
    -- Calculate some stats
    local placeActions = 0
    local upgradeActions = 0
    local ultActions = 0
    local sellActions = 0
    
    for _, action in ipairs(deserializedActions) do
        if action.action == "PlaceUnit" then
            placeActions = placeActions + 1
        elseif action.action == "UpgradeUnit" then
            upgradeActions = upgradeActions + 1
        elseif action.action == "UltUnit" then
            ultActions = ultActions + 1
        elseif action.action == "SellUnit" then
            sellActions = sellActions + 1
        end
    end
    
    print(string.format("Import Success! Imported '%s' with %d actions: %d Place | %d Upgrade | %d Ult | %d Sell", 
        targetMacroName, actionCount, placeActions, upgradeActions, ultActions, sellActions))
    return true
end

local AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoJoinStory",
    Callback = function(Value)
        State.AutoJoinStory = Value
    end,
})

local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StageStorySelector",
    Callback = function(Option)
        local selectedDisplayName = type(Option) == "table" and Option[1] or Option
        local backendWorldKey = getBackendWorldKeyFromDisplayName(selectedDisplayName)
        
        if backendWorldKey then
            State.StoryStageSelected = backendWorldKey
            print("Selected: " .. selectedDisplayName .. " -> Backend: " .. backendWorldKey)
        else
            warn("Could not find backend world key for: " .. tostring(selectedDisplayName))
        end
    end,
})

local ChapterDropdown869 = JoinerTab:CreateDropdown({
    Name = "Select Story Act",
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinite"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        if selectedOption == "Infinite" then
            State.StoryActSelected = "_infinite"
        else
            local num = selectedOption:match("%d+")
            if num then
                State.StoryActSelected = "_level_" .. num
            end
        end
        print("Act selected: " .. (State.StoryActSelected or "none"))
    end,
})

local ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Difficulty",
    Options = {"Normal","Hard"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector",
    Callback = function(Option)
        local selectedOption = Option[1]
        if selectedOption == "Normal" then
            State.StoryDifficultySelected = "Normal"
        elseif selectedOption == "Hard" then
            State.StoryDifficultySelected = "Hard"
        end
    end,
})

section = JoinerTab:CreateSection("🌟 Legend Stage Joiner 🌟")

local AutoJoinLegendToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Legend",
    CurrentValue = false,
    Flag = "AutoJoinLegend",
    Callback = function(Value)
        State.AutoJoinLegendStage = Value
    end,
})

local LegendStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "LegendWorldSelector",
    Callback = function(Option)
        local selectedDisplayName = type(Option) == "table" and Option[1] or Option
        local backendWorldKey = getBackendLegendWorldKeyFromDisplayName(selectedDisplayName)
        
        if backendWorldKey then
            State.LegendStageSelected = backendWorldKey
            print("Selected Legend World: " .. selectedDisplayName .. " -> Backend: " .. backendWorldKey)
        else
            warn("Could not find backend legend world key for: " .. tostring(selectedDisplayName))
        end
    end,
})

local LegendChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Legend Stage Act",
    Options = {"Act 1", "Act 2", "Act 3"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "LegendActSelector",
    Callback = function(Option)
        local selectedOption = type(Option) == "table" and Option[1] or Option
        
        local num = selectedOption:match("%d+")
        if num then
            State.LegendActSelected = "_" .. num
            print("Legend Act selected: " .. State.LegendActSelected)
        end
    end,
})

local Toggle = GameTab:CreateToggle({
   Name = "Auto Retry",
   CurrentValue = false,
   Flag = "AutoRetry",
   Callback = function(Value)
        State.AutoVoteRetry = Value
        if Services.Players.LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("replay")
        end
   end,
})

local Toggle = GameTab:CreateToggle({
   Name = "Auto Next",
   CurrentValue = false,
   Flag = "AutoNext",
   Callback = function(Value)
        State.AutoVoteNext = Value
        if Services.Players.LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_story")
        end
   end,
})

local Toggle = GameTab:CreateToggle({
   Name = "Auto Lobby",
   CurrentValue = false,
   Flag = "AutoLobby",
   Callback = function(Value)
        State.AutoVoteLobby = Value
        if Services.Players.LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("teleport_back_to_lobby"):InvokeServer()
        end
   end,
})

local MacroStatusLabel = MacroTab:CreateLabel("Macro Status: ")

local MacroInput = MacroTab:CreateInput({
    Name = "Create Macro",
    CurrentValue = "",
    PlaceholderText = "Enter macro name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        
        if cleanedName ~= "" then
            if macroManager[cleanedName] then
                print("Error: Macro '" .. cleanedName .. "' already exists.")
                return
            end

            macroManager[cleanedName] = {}
            saveMacroToFile(cleanedName)
            refreshMacroDropdown()
            
            print("Success: Created macro '" .. cleanedName .. "'.")
        elseif text ~= "" then
            print("Error: Invalid macro name. Avoid special characters.")
        end
    end,
})

local RefreshMacroListButton = MacroTab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        loadAllMacros()
        refreshMacroDropdown()
        print("Success: Macro list refreshed.")
    end,
})

local DeleteSelectedMacroButton = MacroTab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            print("Error: No macro selected.")
            return
        end

        deleteMacroFile(currentMacroName)
        print("Deleted: Deleted macro '" .. currentMacroName .. "'.")

        macroManager[currentMacroName] = nil
        macro = {}
        refreshMacroDropdown()
    end,
})

local RecordToggle = MacroTab:CreateToggle({
    Name = "Record",
    CurrentValue = false,
    Flag = "RecordMacro",
    Callback = function(Value)
        isRecording = Value

        if Value and not isRecordingLoopRunning then
            recordingHasStarted = false
            MacroStatusLabel:Set("Status: Preparing to record...")
            print("Macro Recording: Waiting for game to start...")

            local recordingThread = task.spawn(function()
                waitForGameStart()
                if isRecording then
                    recordingHasStarted = true
                    isRecordingLoopRunning = true
                    clearRecordingMapping()
                    table.clear(macro)
                    recordingStartTime = tick()
                    MacroStatusLabel:Set("Status: Recording active!")

                    print("Recording Started: Macro recording is now active.")
                end
            end)

        elseif not Value then
            if isRecordingLoopRunning then
                print("Recording Stopped: Recording manually stopped.")
            end
            isRecordingLoopRunning = false
            recordingHasStarted = false
            MacroStatusLabel:Set("Status: Recording stopped")

            if currentMacroName then
                macroManager[currentMacroName] = macro
                ensureMacroFolders()
                saveMacroToFile(currentMacroName)
            end
        end
    end
})

local PlayToggle = MacroTab:CreateToggle({
    Name = "Playback",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isPlaybacking = Value

        if Value and not isPlayingLoopRunning then
            MacroStatusLabel:Set("Status: Preparing playback...")
            print("Macro Playback: Waiting for game to start...")

            local playbackThread = task.spawn(function()
                waitForGameStart()
                if isPlaybacking then
                    if currentMacroName then
                        ensureMacroFolders()
                        local loadedMacro = loadMacroFromFile(currentMacroName)
                        if loadedMacro then
                            macro = loadedMacro
                        else
                            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
                            print("Playback Error: Failed to load macro: " .. tostring(currentMacroName))
                            isPlaybacking = false
                            PlayToggle:Set(false)
                            return
                        end
                    else
                        MacroStatusLabel:Set("Status: Error - No macro selected!")
                        print("Playback Error: No macro selected for playback.")
                        isPlaybacking = false
                        PlayToggle:Set(false)
                        return
                    end

                    isPlayingLoopRunning = true
                    print("Playback Started: Macro is now executing...")
                    playMacroLoop()
                    isPlayingLoopRunning = false
                end
            end)
        elseif not Value then
            MacroStatusLabel:Set("Status: Playback disabled")
            print("Macro Playback: Playback disabled.")
        end
    end,
})

local ImportInput = MacroTab:CreateInput({
    Name = "Import Macro (URL or JSON)",
    CurrentValue = "",
    PlaceholderText = "Paste URL or JSON content here...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then
            return
        end
        
        local macroName = nil
        
        -- Detect if it's a URL or JSON content
        if text:match("^https?://") then
            -- Extract filename from URL for macro name
            local fileName = text:match("/([^/?]+)%.json") or text:match("/([^/?]+)$")
            if fileName then
                macroName = fileName:gsub("%.json.*$", "")
            else
                macroName = "ImportedMacro_" .. os.time()
            end
        else
            -- For JSON content, try to extract macro name from content or use default
            local jsonData = nil
            pcall(function()
                jsonData = Services.HttpService:JSONDecode(text)
            end)
            
            macroName = (jsonData and jsonData.macroName) or ("ImportedMacro_" .. os.time())
        end
        
        -- Clean macro name
        macroName = macroName:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        
        if macroName == "" then
            macroName = "ImportedMacro_" .. os.time()
        end
        
        -- Check if macro already exists
        if macroManager[macroName] then
            print("Import Cancelled: '" .. macroName .. "' already exists.")
            return
        end
        
        -- Import the macro
        if text:match("^https?://") then
            importMacroFromURL(text, macroName)
        else
            importMacroFromContent(text, macroName)
        end
    end,
})

local ExportButton = MacroTab:CreateButton({
    Name = "Copy Macro JSON",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            print("Export Error: No macro selected for export.")
            return
        end
        exportMacroToClipboard(currentMacroName, "compact")
    end,
})

local CheckUnitsButton = MacroTab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            print("Error: No macro selected.")
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            print("Error: Selected macro is empty.")
            return
        end
        
        -- Extract unique units from macro
        local units = {}
        local unitCounts = {}
        
        for _, action in ipairs(macroData) do
            if action.action == "PlaceUnit" then
                local unitName = action.unitName
                if not units[unitName] then
                    units[unitName] = true
                    unitCounts[unitName] = 0
                end
                unitCounts[unitName] = unitCounts[unitName] + 1
            end
        end
        
        -- Create display text
        local unitList = {}
        for unitName, count in pairs(unitCounts) do
            table.insert(unitList, unitName .. " (Placed x" .. count .. " times)")
        end
        
        if #unitList > 0 then
            table.sort(unitList)
            local displayText = table.concat(unitList, "\n")
            print("Macro Units (" .. #unitList .. " types):")
            print(displayText)
        else
            print("No Units Found: This macro contains no unit placements.")
        end
    end,
})

Input = WebhookTab:CreateInput({
    Name = "Input Webhook",
    CurrentValue = "",
    PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInput",
    Callback = function(Text)
        local trimmed = Text:match("^%s*(.-)%s*$")

        if trimmed == "" then
            ValidWebhook = nil
            return
        end

        local valid = trimmed:match("^https://")

        if valid then
            ValidWebhook = trimmed
        else
            ValidWebhook = nil
        end
    end,
})

Input = WebhookTab:CreateInput({
    Name = "Input Discord ID (mention rares)",
    CurrentValue = "",
    PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInputUserID",
    Callback = function(Text)
        Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$")
    end,
})

Toggle = WebhookTab:CreateToggle({
    Name = "Send On Stage Finished",
    CurrentValue = false,
    Flag = "SendWebhookOnStageFinished",
    Callback = function(Value)
        State.SendStageCompletedWebhook = Value
    end,
})

TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
})

local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
    })
end

local function isInLobby()
    return Services.Workspace:FindFirstChild("_MAP_CONFIG").IsLobby.Value
end

local function canPerformAction()
    return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
end

local function setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()

    if action == "Story Auto Join" then
        notify("Auto Joiner: ", string.format(
            "Joining %s%s [%s]",
            State.StoryStageSelected or "?",
            State.StoryActSelected or "?",
            State.StoryDifficultySelected or "?"
        ))
    elseif action == "Legend Stage Auto Join" then
        notify("Auto Joiner: ", string.format(
            "Joining %s%s",
            string.lower(State.LegendStageSelected) or "?",
            State.LegendActSelected or "?"
        ))
    end
end

local function clearProcessingState()
    AutoJoinState.isProcessing = false
    AutoJoinState.currentAction = nil
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    if not canPerformAction() then return end

    -- STORY
    if State.AutoJoinStory and State.StoryStageSelected and State.StoryActSelected and State.StoryDifficultySelected then
        setProcessingState("Story Auto Join")

        -- Build the complete stage ID
        local completeStageId = State.StoryStageSelected .. State.StoryActSelected
        
        print("=== JOINING STORY STAGE ===")
        print("World: " .. State.StoryStageSelected)
        print("Act: " .. State.StoryActSelected)
        print("Complete Stage ID: " .. completeStageId)
        print("Difficulty: " .. State.StoryDifficultySelected)

        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("P1")

        local args = {
            "P1",
            completeStageId,
            false,
            State.StoryDifficultySelected
        }

        local success = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer(unpack(args))
        end)

        if success then
            print("Successfully sent story join request!")
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("P1")
        else
            warn("Failed to send story join request!")
        end

        task.delay(5, clearProcessingState)
        return
    end

    -- LEGEND STAGE
    if State.AutoJoinLegendStage and State.LegendStageSelected and State.LegendActSelected then
        setProcessingState("Legend Stage Auto Join")

        -- Build the complete legend stage ID
        local completeLegendStageId = State.LegendStageSelected .. State.LegendActSelected
        
        print("=== JOINING LEGEND STAGE ===")
        print("Legend World: " .. State.LegendStageSelected)
        print("Legend Act: " .. State.LegendActSelected)
        print("Complete Legend Stage ID: " .. string.lower(completeLegendStageId))

        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer("P1")

        local args = {
            "P1",
            string.lower(completeLegendStageId),
            false,
            "Hard"
        }

        local success = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_lock_level"):InvokeServer(unpack(args))
        end)

        if success then
            print("Successfully sent legend join request!")
	        game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_start_game"):InvokeServer("P1")
        else
            warn("Failed to send legend join request!")
        end
        task.delay(5, clearProcessingState)
        return
    end

    -- Add other game modes here later (raids, events, etc.)
end

local function loadLegendStages()
    print("=== LEGEND STAGE LOADER ===")
    print("Loading legend world names into dropdown...")
    
    -- Get the world ordering data
    local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
    local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
    
    if not WorldsFolder then
        print("Worlds folder not found!")
        LegendStageDropdown:Refresh({})
        return
    end
    
    if not WorldLevelOrder or not WorldLevelOrder.LEGEND_WORLD_ORDER then
        print("WorldLevelOrder or LEGEND_WORLD_ORDER not found!")
        LegendStageDropdown:Refresh({})
        return
    end

    local displayNames = {} -- Array of legend world names for the dropdown in proper order
    
    -- Process legend worlds in the specified order from LEGEND_WORLD_ORDER
    for _, orderedWorldKey in ipairs(WorldLevelOrder.LEGEND_WORLD_ORDER) do
        print("  Processing ordered legend world: " .. orderedWorldKey)
        
        -- Get all world modules to find the one containing this world
        local worldModules = WorldsFolder:GetChildren()
        
        for _, worldModule in ipairs(worldModules) do
            if worldModule:IsA("ModuleScript") then
                local success, worldData = pcall(require, worldModule)
                
                if success and worldData and worldData[orderedWorldKey] then
                    local worldInfo = worldData[orderedWorldKey]
                    
                    if type(worldInfo) == "table" and worldInfo.name and worldInfo.legend_stage then
                        table.insert(displayNames, worldInfo.name)
                        print("    Loaded legend world: " .. worldInfo.name .. " (" .. orderedWorldKey .. ")")
                    end
                    break -- Found the world, no need to check other modules
                end
            end
        end
    end
    
    if #displayNames > 0 then
        -- Set the dropdown options with legend world names
        LegendStageDropdown:Refresh(displayNames)
        
        print("Loaded " .. #displayNames .. " legend worlds into dropdown (in LEGEND_WORLD_ORDER):")
        for i, displayName in ipairs(displayNames) do
            print("  " .. i .. ". " .. displayName)
        end
    else
        print("No legend worlds found!")
        warn("Could not find any valid legend worlds from LEGEND_WORLD_ORDER")
        LegendStageDropdown:Refresh({})
    end
end

local function loadStoryStages()
    print("=== WORLD STAGE LOADER ===")
    print("Loading world names into dropdown...")
    
    local WorldLevelOrder = require(Services.ReplicatedStorage.Framework.Data.WorldLevelOrder)
    local WorldsFolder = Services.ReplicatedStorage.Framework.Data.Worlds
    
    if not WorldsFolder then
        print("Worlds folder not found!")
        StoryStageDropdown:Refresh({})
        return
    end
    
    if not WorldLevelOrder or not WorldLevelOrder.WORLD_ORDER then
        print("WorldLevelOrder or WORLD_ORDER not found!")
        StoryStageDropdown:Refresh({})
        return
    end

    local displayNames = {}
    
    for _, orderedWorldKey in ipairs(WorldLevelOrder.WORLD_ORDER) do
        print("  Processing ordered world: " .. orderedWorldKey)
        
        local worldModules = WorldsFolder:GetChildren()
        
        for _, worldModule in ipairs(worldModules) do
            if worldModule:IsA("ModuleScript") then
                local success, worldData = pcall(require, worldModule)
                
                if success and worldData and worldData[orderedWorldKey] then
                    local worldInfo = worldData[orderedWorldKey]
                    
                    if type(worldInfo) == "table" and worldInfo.name then
                        table.insert(displayNames, worldInfo.name)
                        print("    Loaded world: " .. worldInfo.name .. " (" .. orderedWorldKey .. ")")
                    end
                    break
                end
            end
        end
    end
    
    if #displayNames > 0 then
        StoryStageDropdown:Refresh(displayNames)
        
        print("Loaded " .. #displayNames .. " worlds into dropdown (in WORLD_ORDER):")
        for i, displayName in ipairs(displayNames) do
            print("  " .. i .. ". " .. displayName)
        end
    else
        print("No worlds found!")
        warn("Could not find any valid worlds from WORLD_ORDER")
        StoryStageDropdown:Refresh({})
    end
end

if not isInLobby() then
itemAddedRemote.OnClientEvent:Connect(function(itemName, quantity)
    if gameInProgress then
        if sessionItems[itemName] then
            sessionItems[itemName] = sessionItems[itemName] + quantity
        else
            sessionItems[itemName] = quantity
        end
        
        print("Item collected: " .. itemName .. " x" .. quantity .. " (Total: " .. sessionItems[itemName] .. ")")
    end
end)
end

if not isInLobby() then 
    gameFinishedRemote.OnClientEvent:Connect(function(...)
        local args = {...}
        print("game_finished RemoteEvent fired!")
        print("Number of arguments:", #args)
        
        -- Print detailed argument contents for debugging
        for i, arg in ipairs(args) do
            print("Arg[" .. i .. "] (" .. type(arg) .. "):")
            if type(arg) == "table" then
                printTableContents(arg, 1)
            else
                print("  " .. tostring(arg))
            end
        end
        
        -- SIMPLIFIED WIN DETECTION - Only check for victory true/false
        gameResult = "Defeat" -- Default to defeat if victory field doesn't exist
        
        -- Look for victory field in table arguments or direct boolean
        for i, arg in ipairs(args) do
            if type(arg) == "table" and arg.victory ~= nil then
                if arg.victory == true then
                    gameResult = "Victory"
                    print("Found victory field: true -> Result: Victory")
                else
                    gameResult = "Defeat"
                    print("Found victory field: false -> Result: Defeat")
                end
                break
            elseif type(arg) == "boolean" then
                if arg == true then
                    gameResult = "Victory"
                    print("Found boolean argument: true -> Result: Victory")
                else
                    gameResult = "Defeat"
                    print("Found boolean argument: false -> Result: Defeat")
                end
                break
            end
        end
        
        print("Final game result:", gameResult)
        
        -- Handle auto voting logic with priority system
        task.spawn(function()
            task.wait(1) -- Small delay to ensure game state is stable
            
            -- Priority 1: Auto Retry (highest priority)
            if State.AutoVoteRetry then
                print("🔄 Auto Retry enabled - Voting to replay...")
                local success, err = pcall(function()
                    Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("replay")
                end)
                
                if success then
                    print("✅ Successfully voted for retry!")
                    notify("Auto Vote", "Voted to retry the stage", 3)
                else
                    warn("❌ Failed to vote for retry:", err)
                end
                return -- Exit early since retry has highest priority
            end
            
            -- Priority 2: Auto Next (medium priority) - only for victories
            if State.AutoVoteNext and gameResult == "Victory" then
                print("⏭️ Auto Next enabled and game won - Voting for next stage...")
                local success, err = pcall(function()
                    Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("set_game_finished_vote"):InvokeServer("next_story")
                end)
                
                if success then
                    print("✅ Successfully voted for next stage!")
                    notify("Auto Vote", "Voted for next stage", 3)
                else
                    warn("❌ Failed to vote for next stage:", err)
                end
                return -- Exit early
            end
            
            -- Priority 3: Auto Lobby (lowest priority)
            if State.AutoVoteLobby then
                print("🏠 Auto Lobby enabled - Returning to lobby...")
                -- Small additional delay for lobby return
                task.wait(1)
                
                local success, err = pcall(function()
                    Services.ReplicatedStorage:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("teleport_back_to_lobby"):InvokeServer()
                end)
                
                if success then
                    print("✅ Successfully returned to lobby!")
                    notify("Auto Vote", "Returned to lobby", 3)
                else
                    warn("❌ Failed to return to lobby:", err)
                end
            end
        end)
        
        -- Handle webhook and tracking (existing code)
        task.spawn(function()
            task.wait(0.1)
            if gameInProgress then
                endGameTracking()
            end
        end)
    end)
end

task.spawn(function()
    while true do
    task.wait(0.5)
    checkAndExecuteHighestPriority()
    end
end)

loadStoryStages()
loadLegendStages()
if not isInLobby() then monitorWaves() end
ensureMacroFolders()
loadAllMacros()

task.delay(1, function()
        local savedMacroName = Rayfield.Flags["MacroDropdown"]
        
        if type(savedMacroName) == "table" then
            savedMacroName = savedMacroName[1]
        end
        
        if savedMacroName and savedMacroName ~= "" and type(savedMacroName) == "string" then
            currentMacroName = savedMacroName
            
            -- Load the macro data from file when restoring from config
            local loadedMacro = loadMacroFromFile(currentMacroName)
            if loadedMacro then
                macro = loadedMacro
                macroManager[currentMacroName] = loadedMacro
                print("Successfully loaded saved macro:", currentMacroName, "with", #macro, "actions")
            else
                print("Failed to load saved macro:", currentMacroName)
                currentMacroName = ""
            end
        else
            print("No valid saved macro name found. Type:", type(savedMacroName), "Value:", tostring(savedMacroName))
        end
        
        refreshMacroDropdown()
end)

Rayfield:LoadConfiguration()
