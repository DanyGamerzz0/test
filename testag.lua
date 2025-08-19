local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Guardians",
   Icon = 0,
   LoadingTitle = "Loading for Anime Guardians",
   LoadingSubtitle = "v0.0.1",
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
      FileName = "Lixhub_AG"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "LixHub - Anime Guardians - Free",
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
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
}

local stageRewards = require(Services.ReplicatedStorage.Module.StageRewards)
local LocalPlayer = Services.Players.LocalPlayer



local Config = {
   difficulties = {"Normal", "Nightmare"},
}

local Data = {
   availableStories = nil,
   storyData = nil,
}

local Config = {
    DISCORD_USER_ID = nil
}

local State = {
   AutoJoinStory = nil,
   StoryStageSelected = nil,
   StoryActSelected = nil,
   StoryDifficultySelected = nil,
   AutoJoinRaid = nil,
   RaidStageSelected = nil,
   RaidActSelected = nil,

   AutoVoteRetry = false,
   AutoVoteNext = false,

   isGameRunning = false,

   SendStageCompletedWebhook = false,

   startingInventory = {},
}

local AutoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2
}

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

local macroManager = {}
local currentMacroName
local macro = {}
local pendingMacroName = ""
local pendingImportURL = ""

local recordingStartTime
local isRecording = false
local isPlaybacking = false
local isRecordingLoopRunning = false
local isPlayingLoopRunning = false
local recordingThread = nil
local playbackThread = nil
local pendingPlacements = {} 

local ValidWebhook = nil

local UpdateLogTab = Window:CreateTab("Update Log", "scroll")
local LobbyTab = Window:CreateTab("Lobby", "tv")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")
local MacroTab = Window:CreateTab("Macro", "tv")

local UpdateLogSection = UpdateLogTab:CreateSection("v0.01")


local Button = LobbyTab:CreateButton({
        Name = "Return to lobby",
        Callback = function()
            Services.TeleportService:Teleport(17282336195, Services.Players.LocalPlayer)
        end,
    })

    local JoinerSection = JoinerTab:CreateSection("📖 Story Joiner 📖")


    local AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoJoinStory",
    Callback = function(Value)
        State.AutoJoinStory = Value
    end,
    })

    local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryStageSelector",
    Callback = function(Option)
        State.StoryStageSelected = Option[1]
    end,
})

    local ChapterDropdown869 = JoinerTab:CreateDropdown({
    Name = "Select Story Act",
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6","Infinity"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryActSelector",
    Callback = function(Option)
    if Option[1] == "Infinity" then
        State.StoryActSelected = "Infinity"
    else
        local num = Option[1]:match("%d+")
        State.StoryActSelected = num
        end
    end,
})

    local ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Difficulty",
    Options = {"Normal","Nightmare"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector",
    Callback = function(Option)
        State.StoryDifficultySelected = Option[1]
    end,
    })

    local JoinerSection00 = JoinerTab:CreateSection("⚔️ Raid Joiner ⚔️")

    local AutoJoinRaidToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Raid",
    CurrentValue = false,
    Flag = "AutoJoinRaid",
    Callback = function(Value)
        State.AutoJoinRaid = Value
    end,
    })

    local StageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RaidStageSelector",
    Callback = function(Option)
        State.RaidStageSelected = Option[1]
    end,
})

    local ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Act",
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RaidActSelector",
    Callback = function(Option)
        State.RaidActSelected = Option[1]
    end,
    })


local function tryStartGame()
    if State.AutoStartGame then
        local mode = Services.Workspace.GameSettings.StagesChallenge.Mode.Value
        local gameStarted = Services.Workspace.GameSettings.GameStarted.Value
        local currentWave = Services.Workspace.GameSettings.Wave.Value
        
        -- Only try to start if game hasn't started, there's a mode, and we're on wave 1
        if (mode ~= nil and mode ~= "") and not gameStarted and currentWave == 0 then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Vote"):FireServer("Vote1")
            end)
        end
    end
end

local Toggle = GameTab:CreateToggle({
    Name = "Auto Start Game",
    CurrentValue = false,
    Flag = "AutoStartGame",
    Callback = function(Value)
        State.AutoStartGame = Value
        if Value then
            tryStartGame()
        end
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Auto Vote Retry",
    CurrentValue = false,
    Flag = "AutoVoteRetry",
    Callback = function(Value)
        State.AutoVoteRetry = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Control"):FireServer("RetryVote")
        end
    end,
})

local Toggle2 = GameTab:CreateToggle({
    Name = "Auto Vote Next",
    CurrentValue = false,
    Flag = "AutoVoteNext", 
    Callback = function(Value)
        State.AutoVoteNext = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Control"):FireServer("Next Stage Vote")
        end
    end,
})

local Toggle2 = GameTab:CreateToggle({
    Name = "Auto Vote Lobby",
    CurrentValue = false,
    Flag = "AutoVoteLobby",
    Callback = function(Value)
        State.AutoVoteLobby = Value
    end,
})

local function tryPickCard()
    if State.AutoPickCard and State.AutoPickCardSelected ~= nil then
        local mode = Services.Workspace.GameSettings.StagesChallenge.Mode.Value
        if mode == nil or mode == "" then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("StageChallenge"):FireServer(State.AutoPickCardSelected)
            end)
        end
    end
end

local Toggle = GameTab:CreateToggle({
    Name = "Auto Pick Card",
    CurrentValue = false,
    Flag = "AutoPickCard",
    Callback = function(Value)
        State.AutoPickCard = Value
        if Value then
            tryPickCard()
        end
    end,
})

local Dropdown = GameTab:CreateDropdown({
   Name = "Select Difficulty Card (Host Only)",
   Options = {"Normal","Fast Wave","Super Faster Wave"},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "AutoPickCardSelection",
   Callback = function(Option)
        State.AutoPickCardSelected = Option[1]
   end,
})

task.spawn(function()
    while true do
        if State.AutoPickCard and State.AutoPickCardSelected ~= nil then
            if Services.Workspace.GameSettings.StagesChallenge.Mode == nil or "" then
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("StageChallenge"):FireServer(State.AutoPickCardSelected)
            end
        end
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoStartGame then
            tryStartGame()
        end
    end
end)

    local function getCurrentWave()
        return Services.Workspace.GameSettings:FindFirstChild("Wave").Value or 0
    end

local function countPlacedUnits()
    local count = 0
    local entities = Services.Workspace:FindFirstChild("Ground") and Services.Workspace.Map:FindFirstChild("UnitClient")
    
    if entities then
        for _, model in ipairs(entities:GetChildren()) do
            if model:IsA("Model") then
                    count = count + 1
            end
        end
    end
    
    return count
end

mt.__namecall = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    if not checkcaller() then
        task.spawn(function()
            -- NEW: Detection for spawnunit remote (different structure)
            if isRecording and method == "InvokeServer" and self.Name == "spawnunit" then
                -- Get placed unit count before placement
                local unitsBefore = countPlacedUnits()
                local unitData = args[1] -- This is a table containing unit info and CFrame
                local unitName = unitData[1] -- Unit name is first element
                local unitCFrame = unitData[2] -- CFrame is second element
                local unitRotation = unitData[3] -- Rotation is third element
                local unitId = args[2] -- Unit ID is second argument
                local timestamp = tick()
                local currentWaveNum = getCurrentWave()
                
                print(string.format("📝 Recording placement attempt for %s (units before: %d)", unitName, unitsBefore))
                
                -- Wait a bit for the placement to process
                task.wait(1.5)
                
                -- Check if placement was successful
                local unitsAfter = countPlacedUnits()
                
                if unitsAfter > unitsBefore then
                    -- Placement was successful - record it
                    local placementData = {
                        action = "PlaceUnit",
                        unitName = unitName,
                        cframe = unitCFrame,
                        rotation = unitRotation,
                        unitId = unitId, -- Store the unit ID for reference
                        time = timestamp - recordingStartTime,
                        wave = currentWaveNum,
                        timestamp = timestamp
                    }
                    
                    table.insert(macro, placementData)
                    print(string.format("✅ Successfully recorded placement: %s (units: %d→%d)", 
                        unitName, unitsBefore, unitsAfter))
                else
                    print(string.format("❌ Placement failed, not recording: %s (units: %d→%d)", 
                        unitName, unitsBefore, unitsAfter))
                end
                
            -- NEW: Detection for ManageUnits remote (replaces UpgradeUnit and SellUnit)
            elseif isRecording and method == "InvokeServer" and self.Name == "ManageUnits" then
                local action = args[1] -- "Upgrade" or "Selling"
                local unitName = args[2] -- Unit name with number (e.g., "Shigeru (Gachi Fighter) 2")
                local timestamp = tick()
                local currentWaveNum = getCurrentWave()
                
                -- Wait a bit to see if action was successful
                task.wait(0.5)
                
                if action == "Upgrade" then
                    table.insert(macro, {
                        action = "UpgradeUnit", 
                        unitName = unitName,
                        time = timestamp - recordingStartTime,
                        wave = currentWaveNum
                    })
                    print(string.format("⬆️ Recorded upgrade for unit %s", unitName))
                    
                elseif action == "Selling" then
                    table.insert(macro, {
                        action = "SellUnit", 
                        unitName = unitName,
                        time = timestamp - recordingStartTime,
                        wave = currentWaveNum
                    })
                    print(string.format("💰 Recorded sell for unit %s", unitName))
                end
                
            elseif isRecording and method == "InvokeServer" and self.Name == "SkipWave" then
                local timestamp = tick()
                local currentWaveNum = getCurrentWave()
                
                table.insert(macro, {
                    action = "SkipWave",
                    time = timestamp - recordingStartTime,
                    wave = currentWaveNum
                })
                print("⏩ Recorded wave skip")
            end
        end)
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

local function executeUnitPlacement(actionData)
    local success, err = pcall(function()
        -- NEW: Construct args for spawnunit remote
        local args = {
            {
                actionData.unitName,
                actionData.cframe,
                actionData.rotation or 0
            },
            actionData.unitId -- Use the exact same ID that was recorded
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("spawnunit"):InvokeServer(unpack(args))
    end)
    
    if success then
        print(string.format("✅ Placed unit: %s", actionData.unitName))
    else
        warn(string.format("❌ Failed to place unit %s: %s", actionData.unitName, err))
    end
end

local function executeUnitUpgrade(actionData)
    local success, err = pcall(function()
        -- NEW: Use ManageUnits remote with "Upgrade" action
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits"):InvokeServer("Upgrade", actionData.unitName)
    end)
    
    if success then
        print(string.format("⬆️ Upgraded unit: %s", actionData.unitName))
    else
        warn(string.format("❌ Failed to upgrade unit %s: %s", actionData.unitName, err))
    end
end

local function executeUnitSell(actionData)
    local success, err = pcall(function()
        -- NEW: Use ManageUnits remote with "Selling" action
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits"):InvokeServer("Selling", actionData.unitName)
    end)
    
    if success then
        print(string.format("💰 Sold unit: %s", actionData.unitName))
    else
        warn(string.format("❌ Failed to sell unit %s: %s", actionData.unitName, err))
    end
end

local function playMacroLoop()
    if not macro or #macro == 0 then
        Rayfield:Notify({
            Title = "Playback Error",
            Content = "No macro data to play back.",
            Duration = 3
        })
        return
    end

    local startTime = tick()
    
    for i, actionData in ipairs(macro) do
        if not isPlaybacking then break end
        
        -- Wait for the correct time
        local targetTime = startTime + actionData.time
        local currentTime = tick()
        if currentTime < targetTime then
            task.wait(targetTime - currentTime)
        end
        
        -- Execute the action based on type
        if actionData.action == "PlaceUnit" then
            executeUnitPlacement(actionData)
        elseif actionData.action == "UpgradeUnit" then
            executeUnitUpgrade(actionData)
        elseif actionData.action == "SellUnit" then
            executeUnitSell(actionData)
        elseif actionData.action == "SkipWave" then
            -- Skip wave logic (if applicable)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                    :WaitForChild("Events"):WaitForChild("SkipWave"):InvokeServer()
            end)
        end
        
        task.wait(0.1) -- Small delay between actions
    end
    
    Rayfield:Notify({
        Title = "Playback Complete",
        Content = string.format("Executed %d actions from macro.", #macro),
        Duration = 4
    })
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
        Rayfield:Notify({
                Title = "Macro Selected",
                Content = "Selected macro '" .. selectedName .. "' with " .. #macro .. " actions.",
                Duration = 3
            })
    else
        print("Invalid selection or macro doesn't exist:", selectedName)
    end
    end,
    })

    local MacroInput = MacroTab:CreateInput({
    Name = "Input Macro Name",
    CurrentValue = "",
    PlaceholderText = "Enter macro name...",
    RemoveTextAfterFocusLost = false,
    Flag = "MacroInput",
    Callback = function(text)
        pendingMacroName = text
    end,
    })

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

    local function serializeAction(action)
    local serializedAction = table.clone(action)
    if serializedAction.cframe then
        serializedAction.cframe = serializeCFrame(serializedAction.cframe)
    end
    return serializedAction
end

    local function deserializeAction(action)
    local deserializedAction = table.clone(action)
    if deserializedAction.cframe then
        deserializedAction.cframe = deserializeCFrame(deserializedAction.cframe)
    end
    return deserializedAction
end

        local function ensureMacroFolders()
        if not isfolder("LixHub") then
            makefolder("LixHub")
        end
        if not isfolder("LixHub/Macros") then
            makefolder("LixHub/Macros")
        end
        if not isfolder("LixHub/Macros/AG") then
            makefolder("LixHub/Macros/AG")
        end
    end

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

    local function exportMacroToClipboard(macroName)
        if not macroName or macroName == "" then
            Rayfield:Notify({
                Title = "Export Error",
                Content = "No macro selected for export.",
                Duration = 3
            })
            return false
        end
        
        local macroData = macroManager[macroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Export Error", 
                Content = "Macro '" .. macroName .. "' is empty or doesn't exist.",
                Duration = 3
            })
            return false
        end
        
        -- Create export data with metadata
        local exportData = {
            version = "1.0",
            macroName = macroName,
            actionCount = #macroData,
            exportTime = os.time(),
            actions = {}
        }
        
        -- Serialize the macro data
        for _, action in ipairs(macroData) do
            local serializedAction = table.clone(action)
            if serializedAction.position then
                serializedAction.position = serializeVector3(serializedAction.position)
            end
            if serializedAction.cframe then
                serializedAction.cframe = serializeCFrame(serializedAction.cframe)
            end
            table.insert(exportData.actions, serializedAction)
        end
        
        local jsonData = Services.HttpService:JSONEncode(exportData)
        
        -- Copy to clipboard
        local success, err = pcall(function()
            setclipboard(jsonData)
        end)
        
        if success then
            Rayfield:Notify({
                Title = "Export Success",
                Content = "Macro '" .. macroName .. "' copied to clipboard! (" .. #macroData .. " actions)",
                Duration = 4
            })
            return true
        else
            Rayfield:Notify({
                Title = "Export Error",
                Content = "Failed to copy to clipboard: " .. tostring(err),
                Duration = 4
            })
            return false
        end
    end

      local function exportMacroToClipboard(macroName)
        if not macroName or macroName == "" then
            Rayfield:Notify({
                Title = "Export Error",
                Content = "No macro selected for export.",
                Duration = 3
            })
            return false
        end
        
        local macroData = macroManager[macroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Export Error", 
                Content = "Macro '" .. macroName .. "' is empty or doesn't exist.",
                Duration = 3
            })
            return false
        end
        
        -- Create export data with metadata
        local exportData = {
            version = "1.0",
            macroName = macroName,
            actionCount = #macroData,
            exportTime = os.time(),
            actions = {}
        }
        
        -- Serialize the macro data
        for _, action in ipairs(macroData) do
            local serializedAction = table.clone(action)
            if serializedAction.position then
                serializedAction.position = serializeVector3(serializedAction.position)
            end
            if serializedAction.cframe then
                serializedAction.cframe = serializeCFrame(serializedAction.cframe)
            end
            table.insert(exportData.actions, serializedAction)
        end
        
        local jsonData = Services.HttpService:JSONEncode(exportData)
        
        -- Copy to clipboard
        local success, err = pcall(function()
            setclipboard(jsonData)
        end)
        
        if success then
            Rayfield:Notify({
                Title = "Export Success",
                Content = "Macro '" .. macroName .. "' copied to clipboard! (" .. #macroData .. " actions)",
                Duration = 4
            })
            return true
        else
            Rayfield:Notify({
                Title = "Export Error",
                Content = "Failed to copy to clipboard: " .. tostring(err),
                Duration = 4
            })
            return false
        end
    end

    local function importMacroFromURL(url, targetMacroName)
        if not url or url == "" then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "No URL provided for import.",
                Duration = 3
            })
            return false
        end
        
        if not targetMacroName or targetMacroName == "" then
            Rayfield:Notify({
                Title = "Import Error", 
                Content = "No target macro name specified.",
                Duration = 3
            })
            return false
        end
        
        -- Check if target macro already exists and has data
        if macroManager[targetMacroName] and #macroManager[targetMacroName] > 0 then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Target macro '" .. targetMacroName .. "' already contains data. Use an empty macro.",
                Duration = 4
            })
            return false
        end
        
        Rayfield:Notify({
            Title = "Importing...",
            Content = "Downloading macro from URL...",
            Duration = 2
        })
        
        -- Try to fetch the URL content
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if not success then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Failed to download from URL: " .. tostring(result),
                Duration = 4
            })
            return false
        end
        
        -- Try to parse the JSON
        local importData
        success, importData = pcall(function()
            return Services.HttpService:JSONDecode(result)
        end)
        
        if not success then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Invalid JSON data in downloaded file.",
                Duration = 4
            })
            return false
        end
        
        -- Validate import data structure
        if not importData.actions or type(importData.actions) ~= "table" then
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Invalid macro format - missing actions.",
                Duration = 4
            })
            return false
        end
        
        -- Deserialize the macro data
        local deserializedActions = {}
        for _, action in ipairs(importData.actions) do
            local newAction = table.clone(action)
            if newAction.position then
                newAction.position = deserializeVector3(newAction.position)
            end
            if newAction.cframe then
                newAction.cframe = deserializeCFrame(newAction.cframe)
            end
            table.insert(deserializedActions, newAction)
        end
        
        -- Import the macro
        macroManager[targetMacroName] = deserializedActions
        
        -- Save to file manually with inline filename generation
        local success, err = pcall(function()
            -- Ensure folders exist
            if not isfolder("LixHub") then
                makefolder("LixHub")
            end
            if not isfolder("LixHub/Macros") then
                makefolder("LixHub/Macros")
            end
            if not isfolder("LixHub/Macros/AG") then
                makefolder("LixHub/Macros/AG")
            end
            
            -- Serialize the data
            local serializedData = {}
            for _, action in ipairs(deserializedActions) do
                local newAction = table.clone(action)
                if newAction.position then
                    newAction.position = serializeVector3(newAction.position)
                end
                if newAction.cframe then
                    newAction.cframe = serializeCFrame(newAction.cframe)
                end
                table.insert(serializedData, newAction)
            end
            
            -- Create filename directly
            local filename = "LixHub/Macros/AG/" .. targetMacroName .. ".json"
            local json = Services.HttpService:JSONEncode(serializedData)
            writefile(filename, json)
        end)
        
        if not success then
            warn("Failed to save imported macro to file:", err)
        end
        
        --refreshMacroDropdown()
        
        Rayfield:Notify({
            Title = "Import Success",
            Content = "Imported '" .. (importData.macroName or "Unknown") .. "' to '" .. targetMacroName .. "' (" .. #deserializedActions .. " actions)",
            Duration = 4
        })
        
        return true
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
        
        return "LixHub/Macros/AG/" .. name .. ".json"
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
        for _, file in ipairs(listfiles("LixHub/Macros/AG/")) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                loadMacroFromFile(name)
            end
        end
    end

        local function waitForGameStart()
        Rayfield:Notify({
            Title = "Waiting for Game",
            Content = "Waiting for next game to start...",
            Duration = 2,
            Image = 4483362458
        })

        repeat 
            task.wait(0.1) 
        until Services.Workspace.GameSettings.GameStarted.Value == true

        return Services.Workspace.GameSettings.GameStarted.Value
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

local CreateMacroButton = MacroTab:CreateButton({
    Name = "Create Empty Macro",
    Callback = function()
        local name = pendingMacroName
        if not name or name == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a valid macro name.",
                Duration = 3
            })
            return
        end
        if macroManager[name] then
            Rayfield:Notify({
                Title = "Error",
                Content = "Macro '" .. name .. "' already exists.",
                Duration = 3
            })
            return
        end

        macroManager[name] = {}

        saveMacroToFile(name)
        refreshMacroDropdown()
        Rayfield:Notify({
            Title = "Success",
            Content = "Created macro '" .. name .. "'.",
            Duration = 3
        })
    end,
    })

    local RefreshMacroListButton = MacroTab:CreateButton({
    Name = "Refresh Macro List",
    Callback = function()
        loadAllMacros()
        refreshMacroDropdown()
        Rayfield:Notify({
            Title = "Success",
            Content = "Macro list refreshed.",
            Duration = 3
        })
    end,
    })

    local DeleteSelectedMacroButton = MacroTab:CreateButton({
    Name = "Delete Selected Macro",
    Callback = function()
            if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "No macro selected.",
                Duration = 3
            })
            return
        end

        deleteMacroFile(currentMacroName)
        Rayfield:Notify({
            Title = "Deleted",
            Content = "Deleted macro '" .. currentMacroName .. "'.",
            Duration = 3
        })

        macroManager[currentMacroName] = nil
        macro = {}
        refreshMacroDropdown()
    end,
    })

    RecordToggle = MacroTab:CreateToggle({
        Name = "Record",
        CurrentValue = false,
        Flag = "RecordMacro",
        Callback = function(Value)
            isRecording = Value

            if Value and not isRecordingLoopRunning then
                Rayfield:Notify({
                    Title = "Macro Recording",
                    Content = "Waiting for game to start...",
                    Duration = 4
                })

                recordingThread = task.spawn(function()
                    waitForGameStart()
                    if isRecording then
                        isRecordingLoopRunning = true
                        table.clear(macro)
                        recordingStartTime = tick()

                        Rayfield:Notify({
                            Title = "Recording Started",
                            Content = "Macro recording is now active.",
                            Duration = 4
                        })
                    end
                end)

            elseif not Value then
                if isRecordingLoopRunning then
                    Rayfield:Notify({
                        Title = "Recording Stopped",
                        Content = "Recording manually stopped.",
                        Duration = 3
                    })
                end
                isRecordingLoopRunning = false

                if currentMacroName then
                macroManager[currentMacroName] = macro
                ensureMacroFolders()
                saveMacroToFile(currentMacroName)
                end
            end
        end
    })



    PlayToggle = MacroTab:CreateToggle({
        Name = "Playback",
        CurrentValue = false,
        Flag = "PlayBackMacro",
        Callback = function(Value)
            isPlaybacking = Value

            if Value and not isPlayingLoopRunning then
        Rayfield:Notify({
            Title = "Macro Playback",
            Content = "Waiting for game to start...",
            Duration = 4
        })

        playbackThread = task.spawn(function()
            waitForGameStart()
            if isPlaybacking then
                if currentMacroName then
                    ensureMacroFolders()
                    local loadedMacro = loadMacroFromFile(currentMacroName)
                    if loadedMacro then
                        macro = loadedMacro
                    else
                        Rayfield:Notify({
                            Title = "Playback Error",
                            Content = "Failed to load macro: " .. tostring(currentMacroName),
                            Duration = 5,
                        })
                        isPlaybacking = false
                        PlayToggle:Set(false)
                        return
                    end
                else
                    Rayfield:Notify({
                        Title = "Playback Error",
                        Content = "No macro selected for playback.",
                        Duration = 5,
                    })
                    isPlaybacking = false
                    PlayToggle:Set(false)
                    return
                end

                isPlayingLoopRunning = true

                Rayfield:Notify({
                    Title = "Playback Started",
                    Content = "Macro is now executing...",
                    Duration = 4
                })

                playMacroLoop()

                isPlayingLoopRunning = false
            end
        end)
    elseif not Value then
        Rayfield:Notify({
            Title = "Macro Playback",
            Content = "Playback disabled.",
            Duration = 3
        })
            end
        end,
    })

    local ExportMacroButton = MacroTab:CreateButton({
        Name = "Export Selected Macro To Clipboard",
        Callback = function()
            if not currentMacroName or currentMacroName == "" then
                Rayfield:Notify({
                    Title = "Export Error",
                    Content = "No macro selected for export.",
                    Duration = 3
                })
                return
            end
            exportMacroToClipboard(currentMacroName)
        end,
    })

    local ImportURLInput = MacroTab:CreateInput({
        Name = "Import URL",
        CurrentValue = "",
        PlaceholderText = "Paste download URL here...",
        RemoveTextAfterFocusLost = false,
        Flag = "ImportURLInput",
        Callback = function(text)
            pendingImportURL = text
        end,
    })

    local ImportFromURLButton = MacroTab:CreateButton({
        Name = "Import from URL",
        Callback = function()
            if not pendingImportURL or pendingImportURL == "" then
                Rayfield:Notify({
                    Title = "Import Error",
                    Content = "Please enter a URL first.",
                    Duration = 3
                })
                return
            end
            
            if not pendingMacroName or pendingMacroName == "" then
                Rayfield:Notify({
                    Title = "Import Error",
                    Content = "Please enter a macro name first.",
                    Duration = 3
                })
                return
            end
            
            importMacroFromURL(pendingImportURL, pendingMacroName)
        end,
    })

local Label5 = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

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
            Label5:Set("Awaiting Webhook Input...")
            return
        end

        local valid = trimmed:match("^https://discord%.com/api/webhooks/%d+/.+$")

        if valid then
            ValidWebhook = trimmed
            Label5:Set("✅ Webhook URL set!")
        else
            ValidWebhook = nil
            Label5:Set("❌ Invalid Webhook URL. Ensure it's complete and starts with 'https://discord.com/api/webhooks/'")
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

local STAGE_PRIORITY = {
    "Lawless City",
    "Temple",
    "Orc Castle",
    "Kingdom of Wandenreich",
    "Namakora Village",
    "Central Command",
    "The Crimson Eclipse",
    "Hidden Leaf Village",
}

local excludedStages = {
    ["Easter Event"] = true,
    ["Moonbase Sci-Fi"] = true,
    ["Nazarick Mausoleum"] = true,
}

local STORY_STAGE_PRIORITY = {
    "Large Village",
    "Hollow Land",
    "Monster City",
    "Academy Demon",
}

local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
    })
end

local function isInLobby()
    return workspace:FindFirstChild("RoomCreation") ~= nil
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
            "Joining %s - %s [%s]",
            State.StoryStageSelected or "?",
            State.StoryActSelected or "?",
            State.StoryDifficultySelected or "?"
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

    --RAID
    if State.AutoJoinRaid and State.RaidStageSelected ~= nil and State.RaidActSelected ~= nil then
            setProcessingState("Auto Join Raid")

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Raid",{"Lawless City","1","Raid"})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Raid",{"Lawless City","1","Raid"})

            task.delay(5, clearProcessingState)
            return
    end

    -- STORY
    if State.AutoJoinStory and State.StoryStageSelected ~= nil and State.StoryActSelected ~= nil and State.StoryDifficultySelected ~= nil then
        setProcessingState("Auto Join Story")

        print(State.AutoJoinStory)
        print(State.StoryStageSelected)
        print(State.StoryActSelected)
        print(State.StoryDifficultySelected)

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Story",{State.StoryStageSelected,State.StoryActSelected,State.StoryDifficultySelected})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{State.StoryStageSelected,State.StoryActSelected,State.StoryDifficultySelected})

            task.delay(5, clearProcessingState)
            return
        end
    end

local function extractModuleStages()
    local moduleStages = {}
    
    for categoryName, categoryData in pairs(stageRewards) do
        if categoryName ~= "Story" and categoryName ~= "Infinity" then -- Skip Story and Infinity as they don't have named stages
            if type(categoryData) == "table" then
                -- Handle regular categories
                for stageName, stageData in pairs(categoryData) do
                    if stageName ~= "Rewards" and stageName ~= "ChanceRewards" and stageName ~= "FirstRewards" and stageName ~= "FloorRewards" then
                        if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards or stageData.FloorRewards or next(stageData)) then
                            moduleStages[stageName] = categoryName
                        end
                    end
                end
                
                -- Handle nested categories (like Darkness Gate)
                for subCategoryName, subCategoryData in pairs(categoryData) do
                    if type(subCategoryData) == "table" and not subCategoryData.Amount and not subCategoryData.Percents then
                        for nestedStageName, nestedStageData in pairs(subCategoryData) do
                            if nestedStageName ~= "Rewards" and nestedStageName ~= "ChanceRewards" and nestedStageName ~= "FirstRewards" and nestedStageName ~= "FloorRewards" then
                                if type(nestedStageData) == "table" and (nestedStageData.Rewards or nestedStageData.ChanceRewards or nestedStageData.FloorRewards or next(nestedStageData)) then
                                    moduleStages[nestedStageName] = categoryName .. " -> " .. subCategoryName
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return moduleStages
end

local function getPlayerStages()
    local playerStages = {}
    
    if LocalPlayer.Stages then
        for _, stageObject in pairs(LocalPlayer.Stages:GetChildren()) do
            playerStages[stageObject.Name] = true
        end
    else
        warn("LocalPlayer.Stages folder not found!")
        return {}
    end
    
    return playerStages
end

-- Function to find story stages
local function findStoryStages()
    local moduleStages = extractModuleStages()
    local playerStages = getPlayerStages()
    
    if next(playerStages) == nil then
        warn("No stages found in LocalPlayer.Stages folder!")
        return {}
    end
    
    local storyStages = {}
    
    -- Compare player stages with module stages
    for stageName, _ in pairs(playerStages) do
        if not moduleStages[stageName] and not excludedStages[stageName] then
            table.insert(storyStages, stageName)
        end
    end
    
    return storyStages
end

local function loadRaidStages()
    local allRaidStages = {}
    local orderedStages = {}
    local unlistedStages = {}
    
    -- Check if Raid category exists
    if stageRewards.Raid and type(stageRewards.Raid) == "table" then
        -- First, collect all valid raid stage names
        for stageName, stageData in pairs(stageRewards.Raid) do
            -- Make sure it's a valid stage (has rewards or chance rewards)
            if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards) then
                allRaidStages[stageName] = true
            end
        end
        
        -- Add stages in priority order (if they exist)
        for _, stageName in ipairs(STAGE_PRIORITY) do
            if allRaidStages[stageName] then
                table.insert(orderedStages, stageName)
                allRaidStages[stageName] = nil -- Remove from remaining stages
            end
        end
        
        -- Add any remaining stages alphabetically at the bottom
        for stageName, _ in pairs(allRaidStages) do
            table.insert(unlistedStages, stageName)
        end
        table.sort(unlistedStages) -- Sort alphabetically
        
        -- Combine ordered stages with unlisted stages
        local raidStages = {}
        for _, stageName in ipairs(orderedStages) do
            table.insert(raidStages, stageName)
        end
        for _, stageName in ipairs(unlistedStages) do
            table.insert(raidStages, stageName)
        end
        
        -- Set the dropdown options
        StageDropdown:Refresh(raidStages)
        
        print("Loaded " .. #raidStages .. " Raid stages into dropdown:")
        print("Priority ordered stages:")
        for i, stageName in ipairs(orderedStages) do
            print("  " .. i .. ". " .. stageName .. " (priority)")
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end 
    else
        warn("Raid category not found in StageRewards module!")
    end
end

local function loadStoryStages()
    print("=== STORY STAGE LOADER ===")
    print("Loading story stages into dropdown...")
    
    local allStoryStages = findStoryStages()

    if not allStoryStages or type(allStoryStages) ~= "table" then
        print("No story stages found or invalid data returned!")
        StoryStageDropdown:Refresh({})
        return
    end

    local orderedStages = {}
    local unlistedStages = {}
    local storyStageSet = {}
    
    -- Convert to set for quick lookup
    for _, stageName in ipairs(allStoryStages) do
        storyStageSet[stageName] = true
    end
    
    -- Add stages in priority order (if they exist)
    for _, stageName in ipairs(STORY_STAGE_PRIORITY) do
        if storyStageSet[stageName] then
            table.insert(orderedStages, stageName)
            storyStageSet[stageName] = nil -- Remove from remaining stages
        end
    end
    
    -- Add any remaining stages alphabetically at the bottom
    for stageName, _ in pairs(storyStageSet) do
        table.insert(unlistedStages, stageName)
    end
    table.sort(unlistedStages) -- Sort alphabetically
    
    -- Combine ordered stages with unlisted stages
    local finalStoryStages = {}
    for _, stageName in ipairs(orderedStages) do
        table.insert(finalStoryStages, stageName)
    end
    for _, stageName in ipairs(unlistedStages) do
        table.insert(finalStoryStages, stageName)
    end
    
    if #finalStoryStages > 0 then
        -- Set the dropdown options
        StoryStageDropdown:Refresh(finalStoryStages)
        
        print("Loaded " .. #finalStoryStages .. " Story stages into dropdown:")
        if #orderedStages > 0 then
            print("Priority ordered stages:")
            for i, stageName in ipairs(orderedStages) do
                print("  " .. i .. ". " .. stageName .. " (priority)")
            end
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end
    else
        print("No story stages found!")
        warn("Could not find any story stages. Make sure LocalPlayer.Stages exists and contains story stages.")
    end
end

local function snapshotInventory()
    local snapshot = {}
    State.unitNameSet = {}

    snapshot.Gold = Services.Players.LocalPlayer.Data.Coins.Value
    snapshot.Gem = Services.Players.LocalPlayer.Data.Tokens.Value
    snapshot.TraitReroll = Services.Players.LocalPlayer.Data.Reroll_Tokens.Value
    snapshot.Cog = Services.Players.LocalPlayer.Data.Cog.Value
    snapshot.Heart = Services.Players.LocalPlayer.Data.Heart.Value
    snapshot.Honey = Services.Players.LocalPlayer.Data.Honey.Value
    snapshot.MagicBall = Services.Players.LocalPlayer.Data.MagicBall.Value
    snapshot.MoonNight = Services.Players.LocalPlayer.Data.MoonNight.Value
    snapshot.Mushroom = Services.Players.LocalPlayer.Data.Mushroom.Value
    snapshot.Snowflake = Services.Players.LocalPlayer.Data.Snowflake.Value
    snapshot.StatReroll = Services.Players.LocalPlayer.Data.StatReroll.Value
    snapshot.SuperStatReroll = Services.Players.LocalPlayer.Data.SuperStatReroll.Value

    local itemInventory = Services.Players.LocalPlayer:WaitForChild("ItemsInventory")
    local unitInventory = Services.Players.LocalPlayer:WaitForChild("UnitsInventory")

    for _, item in pairs(itemInventory:GetChildren()) do
        if item:IsA("Folder") then
            snapshot[item.Name] = tonumber(item.Amount.Value)
        end
    end

    local unitCounts = {}
    for _, unit in pairs(unitInventory:GetChildren()) do
        if unit:IsA("Folder") then
            unitCounts[unit.Unit.Value] = (unitCounts[unit.Unit.Value] or 0) + 1
            State.unitNameSet[unit.Unit.Value] = true
        end
    end

    for unitName, count in pairs(unitCounts) do
        snapshot[unitName] = count
    end

    return snapshot
end

local function compareInventories(startInv, endInv)
    local gained = {}
    for itemName, endValue in pairs(endInv) do
        local startValue = startInv[itemName] or 0
        if endValue > startValue then
            local isUnit = State.unitNameSet[itemName] == true
            table.insert(gained, { name = itemName, amount = endValue - startValue, isUnit = isUnit })
        end
    end
    return gained
end

local function buildRewardsText()
    local endingInventory = snapshotInventory()
    local gainedItems = compareInventories(State.startingInventory, endingInventory)
    local lines = {}
    local detectedRewards = {}
    local detectedUnits = {}

    for _, reward in ipairs(gainedItems) do
        local itemName = reward.name
        local amount = reward.amount

        print(itemName.." - "..amount)

        detectedRewards[itemName] = amount

        local totalText = ""
        if reward.isUnit then
            table.insert(detectedUnits, itemName)
            totalText = ""
            table.insert(lines, string.format("🌟 %s x%d", itemName, amount))
        elseif itemName == "Gem" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Tokens.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName.."(s)", totalText))
        elseif itemName == "Gold" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Coins.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "TraitReroll" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Reroll_Tokens.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Cog" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Cog.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Heart" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Heart.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Honey" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Honey.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "MagicBall" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.MagicBall.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "MoonNight" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.MoonNight.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Mushroom" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Mushroom.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Snowflake" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Snowflake.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "StatReroll" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.StatReroll.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "SuperStatReroll" then
            totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.SuperStatReroll.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        else
            local itemObj = Services.Players.LocalPlayer:WaitForChild("ItemsInventory"):FindFirstChild(itemName)
            local totalAmount = itemObj and itemObj:FindFirstChild("Amount") and itemObj.Amount.Value or nil
            totalText = totalAmount and string.format(" [%d total]", totalAmount) or ""
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        end
    end

    if #gainedItems == 0 then
        return "_No rewards found after match_", {}, {}
    end

    local rewardsText = table.concat(lines, "\n")
    notify("Gained rewards:", rewardsText, 2)
    return rewardsText, detectedRewards, detectedUnits
end

local function sendWebhook(messageType, rewards, clearTime, matchResult)
    if not ValidWebhook then return end

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
        local RewardsUI = Services.Workspace.GameSettings
        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stages").Value  or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Act").Value or "Unknown Act"
        local gameDif = RewardsUI and RewardsUI:FindFirstChild("Difficulty").Value  or "Unknown Difficulty"
        local isWin = Services.Workspace.GameSettings.Base.Health.Value > 0
        local resultText = isWin and "Victory" or "Defeat"
        local plrlevel = Services.Players.LocalPlayer.Data.Levels.Value or ""
        local match_time = RewardsUI.PlayTime.Value
        local formattedTime = string.format("%02d:%02d:%02d", math.floor(match_time / 3600), math.floor((match_time % 3600) / 60), match_time % 60)

        local rewardsText, detectedRewards, detectedUnits = buildRewardsText()
        local shouldPing = #detectedUnits > 0

        if #detectedUnits > 1 then return end

        local pingText = shouldPing and string.format("<@%s> 🎉 **SECRET UNIT OBTAINED!** 🎉", Config.DISCORD_USER_ID) or ""

        local stageResult = stageName.." - Act "..gameMode .. " - " .. gameDif .. " - " .. resultText
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        data = {
            username = "LixHub Bot",
            content = shouldPing and pingText or nil,
            embeds = {{
                title = shouldPing and "🌟 UNIT DROP! 🌟" or "🎯 Stage Finished!",
                description = shouldPing and (pingText .. "\n" .. stageResult) or stageResult,
                color = shouldPing and 0xFFD700 or (isWin and 0x57F287 or 0xED4245),
                fields = {
                    { name = "👤 Player", value = "||" .. Services.Players.LocalPlayer.Name .. " [" .. plrlevel .. "]||", inline = true },
                    { name = isWin and "✅ Won in:" or "❌ Lost after:", value = formattedTime, inline = true },
                    { name = "🏆 Rewards", value = rewardsText, inline = false },
                    shouldPing and { name = "🌟 Units Obtained", value = table.concat(detectedUnits, ", "), inline = false } or nil,
                    { name = "📈 Script Version", value = "v0.01", inline = true },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = timestamp
            }}
        }

        local filteredFields = {}
        for _, field in ipairs(data.embeds[1].fields) do if field then table.insert(filteredFields, field) end end
        data.embeds[1].fields = filteredFields
    else
        return
    end

    local payload = Services.HttpService:JSONEncode(data)
    local requestFunc = (syn and syn.request) or (http and http.request) or request

    if requestFunc then
        local success, result = pcall(function()
           -- notify("Webhook", "Sending webhook...")
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end)

        if success then
            notify("Webhook", "Webhook sent successfully.", 2)
        else
            warn("Webhook failed to send: " .. tostring(result))
            notify("Webhook Error", tostring(result))
        end
    else
        warn("No compatible HTTP request method found.")
        notify("Webhook Error", "No HTTP request method available.")
    end
end

local function onGameStart()
    print("-----------------------Game has started!-----------------------")
    State.startingInventory = snapshotInventory()
    State.isGameRunning = true
end

local function checkGameStarted()
    if isInLobby() then return end
    local gameStarted = Services.Workspace.GameSettings.GameStarted.Value
    if gameStarted then
        onGameStart()
    end
end
      TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
    })

loadRaidStages()
loadStoryStages()
checkGameStarted()

task.spawn(function()
    while true do
    task.wait(0.5)
    checkAndExecuteHighestPriority()
    end
end)

local isRetrying = false -- Prevent multiple retry loops
local isNexting = false

Services.ReplicatedStorage:WaitForChild("EndGame").OnClientEvent:Connect(function()
    State.isGameRunning = false
    if State.SendStageCompletedWebhook then
        sendWebhook("stage", nil, "1:50", nil)
    end
    if State.AutoVoteNext and not isNexting then
        isNexting = true
        spawn(function()
            while State.AutoVoteNext and not game.Workspace.GameSettings.GameStarted.Value do
                local success, err = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                        :WaitForChild("Events"):WaitForChild("Control"):FireServer("Next Stage Vote")
                end)
                
                if success then
                    print("Next sent!")
                else
                    print("Next failed, retrying...")
                end
                
                wait(10)
            end
            isNexting = false
        end)
    end

    if State.AutoVoteRetry and not isRetrying then
        isRetrying = true
        spawn(function()
            while State.AutoVoteRetry and not game.Workspace.GameSettings.GameStarted.Value do
                local success, err = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                        :WaitForChild("Events"):WaitForChild("Control"):FireServer("RetryVote")
                end)

                if success then
                    print("Vote sent!")
                else
                    print("Failed, retrying...")
                end
                wait(10)
            end
            isRetrying = false
        end)
    end
    if State.AutoVoteLobby then
        Services.TeleportService:Teleport(17282336195, LocalPlayer)
    end
end)

Services.Workspace.GameSettings.StagesChallenge.Mode.Changed:Connect(tryPickCard)
Services.Workspace.GameSettings.GameStarted.Changed:Connect(tryStartGame)
Services.Workspace.GameSettings.GameStarted.Changed:Connect(checkGameStarted)

Rayfield:LoadConfiguration()
