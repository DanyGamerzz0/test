local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
}

local Remotes = {}
do
    local RS = Services.ReplicatedStorage
    Remotes.GameEnd = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.Code = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("Code")
    Remotes.StartGame = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VotePlaying")
    Remotes.Merchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("Merchant")
    Remotes.PlayEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
    Remotes.SettingEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Settings"):WaitForChild("Setting_Event")
    Remotes.RetryEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteRetry")
    Remotes.GameEndedUI = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.UpgradeUnit = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Upgrade")
    Remotes.NextEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteNext")
    Remotes.SelectWay = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("SelectWay")
    Remotes.SellRemote = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Sell")
    Remotes.ApplyCurseRemote = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gambling"):WaitForChild("ApplyCurse")
end

local GameObjects = {
    challengeFolder = Services.ReplicatedStorage:WaitForChild("Gameplay"):WaitForChild("Game"):WaitForChild("Challenge"),
    AFKChamberUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AFKChamber"),
    STAGE_MODULES_FOLDER = Services.ReplicatedStorage.Shared.Info.GameWorld.Levels,
}
GameObjects.GetData = require(Services.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GetData"))
GameObjects.getUnitFolder = GameObjects.GetData.GetUnitFolder
GameObjects.itemsFolder = GameObjects.challengeFolder:WaitForChild("Items")

local Config = {
    DISCORD_USER_ID = "",
    chapters = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"},
    difficulties = {"Normal", "Hard", "Nightmare"},
    UPGRADE_COOLDOWN = 0.5,
    maxRetryAttempts = 20,
    unitLevelCaps = {9, 9, 9, 9, 9, 9},
    unitDeployLevelCaps = {0, 0, 0, 0, 0, 0},
    oldbartext = Services.Players.LocalPlayer.PlayerGui.HUD.ExpBar.Numbers.Text,
}

local State = {
    pendingChallengeReturn = false,
    hasSentWebhook = false,
    portalUsed = false,
    isAutoJoining = false,
    hasNewRewards = false,
    pendingBossTicketReturn = false,
    gameRunning = false,
    hasGameEnded = false,
    retryAttempted = false,
    NextAttempted = false,
    stageStartTime = nil,
    skipCooldownSlots = {},
    lastDeploymentTimes = {},
    startingInventory = {},
    unitNameSet = {},
    selectedPortals = {},
    selectedCurses = {},
    
    autoBossEventEnabled = false,
    autoJoinEnabled = false,
    autoStartEnabled = false,
    autoRetryEnabled = false,
    autoReturnEnabled = false,
    autoDisableEndUI = false,
    autoNextEnabled = false,
    autoChallengeEnabled = false,
    autoPortalEnabled = false,
    autoClaimBP = false,
    AutoClaimQuests = false,
    AutoClaimMilestones = false,
    AutoPurchaseMerchant = false,
    challengeAutoReturnEnabled = false,
    autoBossAttackEnabled = false,
    autoReturnBossTicketResetEnabled = false,
    autoInfinityCastleEnabled = false,
    autoUpgradeEnabled = false,
    autoAfkTeleportEnabled = false,
    AutoUltimateEnabled = false,
    AutoSellRarities = false,
    DisableSummonUI = false,
    streamerModeEnabled = false,
    enableLowPerformanceMode = false,
    SendStageCompletedWebhook = false,
    AutoCurseEnabled = false,
    enableDeleteMap = false,
    autoBossRushEnabled = false,
    autoPlayBossRushEnabled = false,
    AutoSelectSpeed = false,
    SelectedSpeedValue = {},
    bossRushTask = nil,
    currentBossPath = nil,
    BossRushPathSwitcher = false,
    SelectedRaritiesToSell = {},
    currentSlot = 1,
    slotLastFailTime = {},
    slotExists = {},
    
    matchResult = "Unknown",
    storedChallengeSerial = nil,
    selectedWorld = nil,
    selectedChapter = nil,
    selectedDifficulty = nil,
    lastBossTicketCount = 0,
    lastBossTicketResetTime = 0,
    infinityCastleTask = nil,
    currentPath = nil,
    upgradeMethod = "Left to right until max",
    upgradeTask = nil,
    ultimateTask = nil,
    currentUpgradeSlot = 1,
    currentRetryAttempt = 0
}

local Data = {
    selectedRawStages = {},
    MerchantPurchaseTable = {},
    rangerStages = {},
    wantedRewards = {},
    capturedRewards = {},
    availableStories = {},
    availableRangerStages = {},
    storyData = {},
    worldDisplayNameMap = {},
    selectedChallengeWorlds = {},
    CurrentCodes = {"SorryRaids","RAIDS","BizzareUpdate2!","Sorry4Delays","BOSSTAKEOVER","Sorry4Quest","SorryDelay!!!","SummerEvent!","2xWeekEnd!","Sorry4EvoUnits","Sorry4AutoTraitRoll","!TYBW","!MattLovesARX2","!RaitoLovesARX","!BrandonTheBest","!FixBossRushShop"},
}

local ValidWebhook

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - [🩸TYBW] Anime Rangers X",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading for Anime Rangers X",
   LoadingSubtitle = "v0.0.3",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
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
}, -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub", -- Create a custom folder for your hub/game
      FileName = "Lixhub_ARX"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "cYKnXE2Nf8", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "LixHub - ARX - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8", -- Use this to tell the user how to get a key
      FileName = "LixHub_Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"ARX_FR33"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

--//TABS\\--

local UpdateLogTab = Window:CreateTab("Update Log", "scroll")
local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

--//SECTIONS\\--

local UpdateLogSection = UpdateLogTab:CreateSection("13/07/2025")
local StatsSection = LobbyTab:CreateSection("🏢 Lobby 🏢")

--//DIVIDERS\\--
local UpdateLogDivider = UpdateLogTab:CreateDivider()

--//LABELS\\--
local Label1 = UpdateLogTab:CreateLabel("Too much to list, check it out for yourself - enjoy")
local Label2 = UpdateLogTab:CreateLabel("Also please join the discord: https://discord.gg/cYKnXE2Nf8")

--//FUNCTIONS\\--

local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
        })
    end

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function enableDeleteMap()
    if isInLobby() then return end
    if State.enableDeleteMap then
        local map = Services.Workspace:FindFirstChild("Building"):FindFirstChild("Map")

    if map then 
        map:Destroy() 
         Services.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
    end    
    end
end

local function enableLowPerformanceMode()
    if State.enableLowPerformanceMode then
        Services.Lighting.Brightness = 1
        Services.Lighting.GlobalShadows = false
        Services.Lighting.Technology = Enum.Technology.Compatibility
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 0
        Services.Lighting.EnvironmentSpecularScale = 0

        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Transparency < 1 then
                    obj.Transparency = 1
                end
            end
        end
        
        local playerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then
                gui.Enabled = false
            end
        end
        
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or
            obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end
Remotes.SettingEvent:FireServer(unpack({"Abilities VFX", false}))
Remotes.SettingEvent:FireServer(unpack({"Hide Cosmetic", true}))
Remotes.SettingEvent:FireServer(unpack({"Low Graphic Quality", true}))
Remotes.SettingEvent:FireServer(unpack({"HeadBar", false}))
Remotes.SettingEvent:FireServer(unpack({"Display Players Units", false}))
Remotes.SettingEvent:FireServer(unpack({"DisibleGachaChat", true}))
Remotes.SettingEvent:FireServer(unpack({"DisibleDamageText", true}))
    else
        Services.Lighting.Brightness = 1.51
        Services.Lighting.GlobalShadows = true
        Services.Lighting.Technology = Enum.Technology.Future
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 1
        Services.Lighting.EnvironmentSpecularScale = 1

        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = true
            end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 0
            end
        end
        
        local playerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then
                gui.Enabled = true
            end
        end
        
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or
            obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = true
            end
        end
    end
end

local function fetchStoryData()
    Data.storyData = {}
    local worldDisplayNameMap = {}    
    local folder = game.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("World")
        

        for _, moduleScript in ipairs(folder:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local success, data = pcall(function()
                    return require(moduleScript)
                end)

                if success and typeof(data) == "table" then
                    for key, storyTable in pairs(data) do
                        if typeof(storyTable) == "table" and storyTable.StoryAble == true then
                            if storyTable.Name and storyTable.Ani_Names then
                                table.insert(Data.storyData, {
                                    SeriesName = storyTable.Name,
                                    InternalName = storyTable.Ani_Names,
                                    ModuleName = moduleScript.Name,
                                    Key = key
                                })

                                worldDisplayNameMap[storyTable.Ani_Names] = storyTable.Name
                            end
                        end
                    end
                else
                    print("Error loading " .. moduleScript.Name)
                end
            end
        end
        
        return Data.storyData, Data.worldDisplayNameMap
    end

local function fetchRangerStageData(storyData)
    local folder = Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("Levels")

    local worldPriority = {
        ["OnePiece"] = 1,
        ["Namek"] = 2,
        ["DemonSlayer"] = 3,
        ["Naruto"] = 4,
        ["OPM"] = 5,
        ["TokyoGhoul"] = 6,
        ["JojoPart1"] = 7,
        ["SoulSociety"] = 8,
    }

    local worldDisplayNames = {}
    for _, story in ipairs(storyData) do
        worldDisplayNames[story.ModuleName] = story.SeriesName
    end

    local worldStages = {}

    for _, moduleScript in ipairs(folder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for seriesName, chapters in pairs(data) do
                    if typeof(chapters) == "table" then
                        for chapterKey, chapterData in pairs(chapters) do
                            if typeof(chapterData) == "table" and chapterData.Wave then
                                if string.find(chapterData.Wave, "RangerStage") then
                                    local worldName = chapterData.World or "UnknownWorld"
                                    worldStages[worldName] = worldStages[worldName] or {}
                                    local displayWorldName = worldDisplayNames[worldName] or worldName

                                    table.insert(worldStages[worldName], {
                                        Series = seriesName,
                                        Chapter = chapterKey,
                                        Wave = chapterData.Wave,
                                        LayoutOrder = chapterData.LayoutOrder or math.huge,
                                        DisplayName = displayWorldName .. " - " .. (chapterData.Wave:match("RangerStage(%d+)") or chapterData.Wave)
                                    })
                                end
                            end
                        end
                    end
                end
            else
                warn("Error loading module: " .. moduleScript.Name)
            end
        end
    end

    local worldOrder = {}
    local rangerStages = {}

    for worldName, stages in pairs(worldStages) do
        table.sort(stages, function(a, b)
            return a.LayoutOrder < b.LayoutOrder
        end)

        local priority = worldPriority[worldName] or 1e6
        table.insert(worldOrder, {World = worldName, Priority = priority, Stages = stages})
    end

    table.sort(worldOrder, function(a, b)
        return a.Priority < b.Priority
    end)

    for _, worldInfo in ipairs(worldOrder) do
        local worldName = worldInfo.World
        for _, stage in ipairs(worldInfo.Stages) do
            table.insert(rangerStages, {
                RawName = stage.Wave,
                DisplayName = stage.DisplayName,
                World = worldName,
                Series = stage.Series,
                Chapter = stage.Chapter,
                LayoutOrder = stage.LayoutOrder
            })
        end
    end

    return rangerStages
end

local function snapshotInventory()
    local snapshot = {}
    State.unitNameSet = {}

    snapshot.Gold = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gold.Value
    snapshot.Gem = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gem.Value
    snapshot["Beach Balls"] = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data["Beach Balls"].Value

    local itemInventory = Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items"):WaitForChild("Main"):WaitForChild("Base"):WaitForChild("Space"):WaitForChild("Scrolling")
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items").Enabled = true
    task.wait(1)
     Services.Players.LocalPlayer.PlayerGui:WaitForChild("Items").Enabled = false
    local unitInventory = Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection"):WaitForChild("Main"):WaitForChild("Base"):WaitForChild("Space"):WaitForChild("Unit")
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection").Enabled = true
    task.wait(1)
    Services.Players.LocalPlayer.PlayerGui:WaitForChild("Collection").Enabled = false

    for _, item in pairs(itemInventory:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            local text = item:WaitForChild("Frame"):WaitForChild("ItemFrame"):WaitForChild("Info"):WaitForChild("Amonut").Text
            local formattedtext = text:gsub("%D", "")
            snapshot[item.Name] = tonumber(formattedtext)
        end
    end

    local unitCounts = {}
    for _, unit in pairs(unitInventory:GetChildren()) do
        if unit:IsA("TextButton") or unit:IsA("ImageButton") then
            unitCounts[unit.Name] = (unitCounts[unit.Name] or 0) + 1
            State.unitNameSet[unit.Name] = true
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

local function patchRewardsFromFolder(existingGained, detectedRewards, detectedUnits, lines)
    local rewardFolder = Services.Players.LocalPlayer:FindFirstChild("RewardsShow")
    if not rewardFolder then return end

    for _, rewardEntry in pairs(rewardFolder:GetChildren()) do
        if not detectedRewards[rewardEntry.Name] and rewardEntry:FindFirstChild("Amount") then
            local amount = rewardEntry.Amount.Value

            if amount > 0 then
                detectedRewards[rewardEntry.Name] = amount
                table.insert(existingGained, { name = rewardEntry.Name, amount = amount, isUnit = false })

                local totalText = ""

                if rewardEntry.Name == "Gem" or rewardEntry.Name == "Gold" or rewardEntry.Name == "Beach Balls" or "BossRushCurrency" then
                    local dataValue = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data:FindFirstChild(rewardEntry.Name)
                    totalText = dataValue and string.format(" [%d total]", dataValue.Value) or ""
                else
                    local item = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(rewardEntry.Name)
                    local itemAmount = item and item:FindFirstChild("Amount")
                    totalText = itemAmount and string.format(" [%d total]", itemAmount.Value) or ""
                end

                table.insert(lines, string.format("+ %s %s%s", amount, rewardEntry.Name, totalText))
            end
        end
    end
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

        detectedRewards[itemName] = amount

        local totalText = ""
        if reward.isUnit then
            table.insert(detectedUnits, itemName)
            totalText = ""
            table.insert(lines, string.format("🌟 %s x%d", itemName, amount))
        elseif itemName == "Gem" then
            totalText = string.format(" [%d total]", Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gem.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName.."(s)", totalText))
        elseif itemName == "Gold" then
            totalText = string.format(" [%d total]", Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gold.Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        elseif itemName == "Beach Balls" then
            totalText = string.format(" [%d total]", Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data["Beach Balls"].Value)
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        else
            local itemObj = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(itemName)
            local totalAmount = itemObj and itemObj:FindFirstChild("Amount") and itemObj.Amount.Value or nil
            totalText = totalAmount and string.format(" [%d total]", totalAmount) or ""
            table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
        end
    end

    patchRewardsFromFolder(gainedItems, detectedRewards, detectedUnits, lines)

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
            content = string.format("<@%s>", Config.DISCORD_USER_ID),
            embeds = {{
                title = "📢 LixHub Notification",
                description = "🧪 Test webhook sent successfully",
                color = 0x5865F2,
                footer = { text = "LixHub Auto Logger" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
    elseif messageType == "stage" then
        local RewardsUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("InGame"):WaitForChild("Main"):WaitForChild("GameInfo")
        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stage") and RewardsUI.Stage.Label.Text or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Gamemode") and RewardsUI.Gamemode.Label.Text or "Unknown Time"
        local isWin = matchResult == "Victory"
        local plrlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value or ""

        local rewardsText, detectedRewards, detectedUnits = buildRewardsText()
        local shouldPing = #detectedUnits > 0
        local pingText = shouldPing and string.format("<@%s> 🎉 **SECRET UNIT OBTAINED!** 🎉", Config.DISCORD_USER_ID) or ""

        local stageResult = stageName .. " (" .. gameMode .. ")" .. " - " .. matchResult
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
                    { name = isWin and "✅ Won in:" or "❌ Lost after:", value = clearTime, inline = true },
                    { name = "🏆 Rewards", value = rewardsText, inline = false },
                    shouldPing and { name = "🌟 Units Obtained", value = table.concat(detectedUnits, ", "), inline = false } or nil,
                    { name = "📈 Script Version", value = "v1.2.0 (Enhanced)", inline = true },
                },
                footer = { text = "discord.gg/lixhub • Enhanced Tracking" },
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

local function getPathAverages()
    local avg = {}
    for i = 1, 4 do
        local folder = Services.Workspace.WayPoint:WaitForChild("P" .. i)
        local total, count = Vector3.zero, 0

        for _, part in ipairs(folder:GetChildren()) do
            if part:IsA("BasePart") then
                total = total + part.Position
                count = count + 1
            end
        end

        avg["P" .. i] = count > 0 and total / count or Vector3.zero
    end
    return avg
end

--[[local function countPartsOnPath(folder, pathFolder)
    local count = 0
    for _, part in ipairs(folder:GetChildren()) do
        if part:IsA("BasePart") and part:FindFirstChildOfClass("Humanoid") then
            local distToStart = (part.Position - pathFolder["1"].Position).Magnitude
            local distToEnd = (part.Position - pathFolder["2"].Position).Magnitude
            local totalDist = (pathFolder["1"].Position - pathFolder["2"].Position).Magnitude
            if distToStart + distToEnd <= totalDist + 15 then
                count = count + 1
            end
        end
    end
    return count
end--]]

local function countPartsOnPath(folder, pathFolder)
    local count = 0
    for _, part in ipairs(folder:GetChildren()) do
        if part:IsA("BasePart") and part:FindFirstChildOfClass("Humanoid") then
            local distToStart = (part.Position - pathFolder["1"].Position).Magnitude
            local distToEnd = (part.Position - pathFolder["2"].Position).Magnitude
            local totalDist = (pathFolder["1"].Position - pathFolder["2"].Position).Magnitude
            -- Tighter tolerance for boss rush (harder detection)
            if distToStart + distToEnd <= totalDist + 10 then
                count = count + 1
            end
        end
    end
    return count
end

local function nearestPath(pos)
    local avg = getPathAverages()
    local best, dist = nil, math.huge

    for name, center in pairs(avg) do
        local d = (pos - center).Magnitude
        if d < dist then
            dist = d
            best = name
        end
    end

    return best
end

local function getBestPath()
    local bestPath, lowestUnits = nil, math.huge
    for i = 1, 3 do
        local pathName = "P" .. i
        local pathFolder = Services.Workspace:WaitForChild("WayPoint"):FindFirstChild(pathName)
        if pathFolder then
            local unitCount = countPartsOnPath(Services.Workspace.Agent.UnitT, pathFolder)
            local enemyCount = countPartsOnPath(Services.Workspace.Agent.EnemyT, pathFolder)
            print("🔎 Path " .. pathName .. ": " .. unitCount .. " units, " .. enemyCount .. " enemies")
            if enemyCount > 0 and unitCount < lowestUnits then
                lowestUnits = unitCount
                bestPath = i
            end
        end
    end
    return bestPath
end

local function getBestBossRushPath()
  local bestPath, lowestUnits = nil, math.huge
    
    -- Check all 4 paths for boss rush
    for i = 1, 4 do
        local pathName = "P" .. i
        local pathFolder = Services.Workspace:WaitForChild("WayPoint"):FindFirstChild(pathName)
        if pathFolder then
            local unitCount = countPartsOnPath(Services.Workspace.Agent.UnitT, pathFolder)
            local enemyCount = countPartsOnPath(Services.Workspace.Agent.EnemyT, pathFolder)
            
            print("🔎 Path " .. pathName .. ": " .. unitCount .. " units, " .. enemyCount .. " enemies")
            
            -- Only switch if there are enemies on a path
            if enemyCount > 0 and unitCount < lowestUnits then
                lowestUnits = unitCount
                bestPath = i
            end
        end
    end
    
    return bestPath
end



local function startInfinityCastleLogic()
    if State.infinityCastleTask then task.cancel(State.infinityCastleTask) end
    State.infinityCastleTask = task.spawn(function()
        while State.autoInfinityCastleEnabled do
            local success, error = pcall(function()
                local bestPath = getBestPath()
                if bestPath and bestPath ~= State.currentPath then
                    notify("🚀 Switching to path: ", bestPath)
                    State.currentPath = bestPath
                    Remotes.SelectWay:FireServer(bestPath)
                else
                    print("✅ Staying on current path:", State.currentPath or "None")
                end
            end)
            if not success then warn("❌ Infinity Castle error:", error) end
            task.wait(2.5)
        end
    end)
end

local function startBossRushLogic()
    if isInLobby() then return end
    if State.bossRushTask then task.cancel(State.bossRushTask) end
    State.bossRushTask = task.spawn(function()
        local currentPath = 1
        
        while State.autoPlayBossRushEnabled do
            local success, error = pcall(function()
                -- Get the interval from the slider
                local switchInterval = State.BossRushPathSwitcher or 1
                
                -- Switch to the current path
                notify("🚀 Boss Rush switching to path: ", currentPath)
                State.currentBossPath = currentPath
                Remotes.SelectWay:FireServer(currentPath)
                
                -- Cycle to next path (1 -> 2 -> 3 -> 4 -> 1)
                currentPath = currentPath + 1
                if currentPath > 4 then
                    currentPath = 1
                end
                
                print("✅ Boss Rush on path:", State.currentBossPath, "| Next path in", switchInterval, "seconds")
            end)
            
            if not success then warn("❌ Boss Rush error:", error) end
            
            -- Wait for the user-defined interval
            task.wait(State.BossRushPathSwitcher or 1)
        end
    end)
end

local function stopInfinityCastleLogic()
    if State.infinityCastleTask then
        task.cancel(State.infinityCastleTask)
        State.infinityCastleTask = nil
    end
    State.currentPath = nil
end

local function stopBossRushLogic()
    if State.bossRushTask then
        task.cancel(State.bossRushTask)
        State.bossRushTask = nil
    end
    State.currentBossPath = nil
end

local function isWantedChallengeRewardPresent()
    for _, reward in ipairs(Data.wantedRewards) do
        local value = GameObjects.itemsFolder:FindFirstChild(reward)
        if value and value:IsA("BoolValue") then
            return true, reward
        end
    end
    return false, nil
end

local function getTierValue(name)
    if name:find("III") then return 3 end
    if name:find("II") then return 2 end
    if name:find("I") then return 1 end
    return 0
end

local function getPlayerCurrency()
    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data
    if not playerData then return {} end

    local currencies = {}
    local GoldValue = playerData:FindFirstChild("Gold")
    if GoldValue then currencies["Gold"] = GoldValue.Value end
    local gemsValue = playerData:FindFirstChild("Gem")
    if gemsValue then currencies["Gem"] = gemsValue.Value end
    return currencies
end

local function canAffordItem(itemFolder)
    local priceValue = itemFolder:FindFirstChild("CurrencyAmount")
    local currencyTypeValue = itemFolder:FindFirstChild("CurrencyType")
    if not priceValue or not currencyTypeValue then return false end

    local price = priceValue.Value
    local currencyType = currencyTypeValue.Value
    local playerCurrencies = getPlayerCurrency()

    return playerCurrencies[currencyType] and playerCurrencies[currencyType] >= price
end

local function purchaseItem(itemName, quantity)
    quantity = quantity or 1
    pcall(function()
        Remotes.Merchant:FireServer(itemName, quantity)
    end)
end

local didNotify = false

local function autoPurchaseItems()
    if not State.AutoPurchaseMerchant then return end
    if not Data.MerchantPurchaseTable or #Data.MerchantPurchaseTable == 0 then return end

    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name]
    if not playerData then return end

    local merchantFolder = playerData:FindFirstChild("Merchant")
    if not merchantFolder then return end

    for _, selectedItem in pairs(Data.MerchantPurchaseTable) do
        local itemFolder = merchantFolder:FindFirstChild(selectedItem)
        if itemFolder then
            if canAffordItem(itemFolder) then
                local quantityValue = itemFolder:FindFirstChild("Quantity")
                local currentQuantityValue = itemFolder:FindFirstChild("BuyAmount")
                local availableQuantity = quantityValue and quantityValue.Value or 1
                local currentQuantity = currentQuantityValue and currentQuantityValue.Value or 0

                if currentQuantity <= 0 then
                    purchaseItem(selectedItem, availableQuantity)
                    notify("Auto Purchase Merchant", "Purchased: " .. availableQuantity .. "x " .. selectedItem)
                    task.wait(0.5)
                end
            else
                if didNotify == false then
                    didNotify = true
                    notify("Auto Purchase Merchant", "Can't afford: " .. selectedItem)
                    task.delay(20, function()
                        didNotify = false
                    end)
                end
            end
        end
    end
end

local function autoJoinRangerStage(stageName)
    if not isInLobby() then 
        print("❌ Not in lobby, cannot join ranger stage")
        return 
    end

    print("🚀 Joining ranger stage:", stageName)

    -- 1. Create
    Remotes.PlayEvent:FireServer("Create")
    task.wait(0.3)

    -- 2. Change-Mode
    Remotes.PlayEvent:FireServer("Change-Mode", { Mode = "Ranger Stage" })
    task.wait(0.3)

    -- 3. Extract world from stage name (e.g., "Naruto_RangerStage2" → "Naruto")
    local world = stageName:match("^(.-)_RangerStage")
    if not world then
        warn("❌ Couldn't extract world from:", stageName)
        return
    end

    -- 4. Change-World
    Remotes.PlayEvent:FireServer("Change-World", { World = world })
    task.wait(0.3)

    -- 5. Change-Chapter
    Remotes.PlayEvent:FireServer("Change-Chapter", { Chapter = stageName })
    task.wait(0.3)

    -- 6. Submit
    Remotes.PlayEvent:FireServer("Submit")
    task.wait(0.3)

    -- 7. Start
    Remotes.PlayEvent:FireServer("Start")

    print("✅ Ranger stage join sequence completed for:", stageName)
end

local autoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2 
}

local function canPerformAction()
    return tick() - autoJoinState.lastActionTime >= autoJoinState.actionCooldown
end

local function setProcessingState(action)
    autoJoinState.isProcessing = true
    autoJoinState.currentAction = action
    autoJoinState.lastActionTime = tick()

    if action == "Ranger Stage Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Challenge Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Portal Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Story Auto Join" then
        notify("🔄 Processing: ", string.format(
            "Joining %s - %s [%s]",
            State.selectedWorld or "?",
            State.selectedChapter or "?",
            State.selectedDifficulty or "?"
        ))
    elseif action == "Boss Attack Auto Join" then
        notify("🔄 Processing: ", action)

        elseif action == "Boss Event Auto Join" then
           notify("🔄 Processing: ", action)

           elseif action == "Boss Rush Auto Join" then
            notify("🔄 Processing: ", action)
    end
end

local function clearProcessingState()
    autoJoinState.isProcessing = false
    autoJoinState.currentAction = nil
end

local function getBossAttackTickets()
    local success, tickets = pcall(function()
        return Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackTicket.Value
    end)
    return success and tickets or 0
end

local function getBossTicketResetTime()
    local success, resetTime = pcall(function()
        return Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackReset.Value
    end)
    return success and resetTime or 0
end

    -- Auto join boss attack function
local function autoJoinBossAttack()
    if not isInLobby() then return end
    print("🏆 [Priority 0] Attempting to join Boss Attack...")
    Remotes.PlayEvent:FireServer("Boss-Attack")
end

local function getInternalWorldName(displayName)
    for _, story in ipairs(Data.availableStories) do
        if story.SeriesName == displayName then
            return story.ModuleName
        end
    end
    return nil
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if autoJoinState.isProcessing then return end
    if not canPerformAction() then return end

    -- Priority 0: Boss Attack Auto Join
    if State.autoBossAttackEnabled then
        local currentTickets = getBossAttackTickets()
        if currentTickets > 0 then
            setProcessingState("Boss Attack Auto Join")
            print("🏆 [Priority 0] Boss Attack tickets available:", currentTickets)
            autoJoinBossAttack()
            task.delay(5, clearProcessingState)
            return
        else
            print("🎫 [Priority 0] No boss attack tickets available, checking other priorities...")
        end
    end

    -- Priority 1: Challenge Auto Join
    if State.autoChallengeEnabled then
        local skipChallenge = false
        if #Data.selectedChallengeWorlds > 0 then
             local ignoredInternalNames = {}
    for _, displayName in pairs(Data.selectedChallengeWorlds) do
        local internalName = getInternalWorldName(displayName)
        if internalName then
            table.insert(ignoredInternalNames, internalName)
        end
    end

    -- Check if the current challenge world is in the ignored list
    for _, ignoredInternal in pairs(ignoredInternalNames) do
        if ignoredInternal == Services.ReplicatedStorage.Gameplay.Game.Challenge.World.Value then
            skipChallenge = true
            break
        end
    end
        end
        if not skipChallenge then
        local foundRewardOK, foundReward = isWantedChallengeRewardPresent()
        if foundRewardOK then
            setProcessingState("Challenge Auto Join")
            print("🎯 Found wanted reward '" .. foundReward .. "' → creating challenge room")
            notify("Challenge Mode", string.format("Found %s, joining challenge...", foundReward))
            Remotes.PlayEvent:FireServer("Create", { CreateChallengeRoom = true })
            Remotes.PlayEvent:FireServer("Start")
            task.delay(5, clearProcessingState)
            return
        end
        end
    end

     -- Priority 2: Portal Auto Join
    if State.autoPortalEnabled and not State.portalUsed and State.selectedPortals and #State.selectedPortals > 0 then
        local success, result = pcall(function()
            local inventoryFrame = Services.Players.LocalPlayer:FindFirstChild("PlayerGui").Items.Main.Base.Space:FindFirstChild("Scrolling")
            if not inventoryFrame then return nil end
            for _, item in ipairs(inventoryFrame:GetChildren()) do
                if item.Name:lower():find("portal") and table.find(State.selectedPortals, item.Name) then
                return item.Name
                end
            end
    end)

        if success and result then
            setProcessingState("Portal Auto Join")

            local portalInstance = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(result)
            if portalInstance then
                Services.ReplicatedStorage.Remote.Server.Lobby.ItemUse:FireServer(portalInstance)
                State.portalUsed = true
                notify("Portal Joiner", "Using portal: " .. result)

                task.wait(1)

                print("▶️ Starting portal match...")
                Services.ReplicatedStorage.Remote.Server.Lobby.PortalEvent:FireServer("Start")

                task.delay(5, clearProcessingState)
                return
            else
                 notify("Portal Joiner", "Portal not found: " .. result)
                clearProcessingState()
                State.portalUsed = false
            end
        end
    end

    if State.autoBossRushEnabled then
        setProcessingState("Boss Rush Auto Join")
        Remotes.PlayEvent:FireServer("BossRush")
        task.wait(1)
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Start")
        task.delay(5, clearProcessingState)
        return
    end

    -- priority 3: boss event auto join
    if State.autoBossEventEnabled then
    setProcessingState("Boss Event Auto Join")
    Remotes.PlayEvent:FireServer("Summer-Event")
    task.delay(5, clearProcessingState)
        return
    end

    -- Priority 4: Ranger Stage Auto Join
    if State.isAutoJoining and Data.selectedRawStages and #Data.selectedRawStages > 0 then
        local selectedStageSet = {}
        for _, raw in ipairs(Data.selectedRawStages) do
            selectedStageSet[raw] = true
        end

        local prioritizedStageList = {}
        for _, stage in ipairs(Data.availableRangerStages) do
            if selectedStageSet[stage.RawName] then
                table.insert(prioritizedStageList, stage.RawName)
            end
        end

        if #prioritizedStageList > 0 then
            local stageName = prioritizedStageList[1]
            setProcessingState("Ranger Stage Auto Join")
            print("🌍 [Priority 3] Attempting to join Ranger Stage:", stageName)
            autoJoinRangerStage(stageName)
            task.delay(5, clearProcessingState)
            return
        end
    end
    -- Priority 5: Story Auto Join
    if State.autoJoinEnabled and State.selectedWorld and State.selectedChapter and State.selectedDifficulty then
        setProcessingState("Story Auto Join")

        local internalWorldName = getInternalWorldName(State.selectedWorld)
        if internalWorldName then
            print("📚 [Priority 4] Joining Story:", State.selectedWorld, "/", State.selectedChapter, "/", State.selectedDifficulty)

            local combinedWorld = internalWorldName .. "_" .. State.selectedChapter:gsub(" ", "")

            local function sendPlayRoomEvent(action, data)
                Remotes.PlayEvent:FireServer(action, data)
                task.wait(0.25)
            end

            sendPlayRoomEvent("Create")
            sendPlayRoomEvent("Change-World", { World = tostring(internalWorldName) })
            sendPlayRoomEvent("Change-Chapter", { Chapter = tostring(combinedWorld) })
            sendPlayRoomEvent("Change-Difficulty", { Difficulty = tostring(State.selectedDifficulty) })
            sendPlayRoomEvent("Submit")
            sendPlayRoomEvent("Start")

            task.delay(10, clearProcessingState)
            return
        else
            warn("[Story Auto Join] Invalid selection.")
            notify("⚠️ Story Join", "Selected World/Chapter/Difficulty is invalid.")
            clearProcessingState()
        end
    end
end


local function getCurrentChallengeSerial()
    local success, serial = pcall(function()
        return challengeFolder:FindFirstChild("serial_number") and challengeFolder.serial_number.Value
    end)
    return success and serial or nil
end

if not State.storedChallengeSerial then
    State.storedChallengeSerial = getCurrentChallengeSerial()
end

local function getUnitNameFromSlot(slotNumber)
    local success, unitInstance = pcall(function()
        return Services.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
end)

    if success and unitInstance then
        return typeof(unitInstance) == "Instance" and unitInstance.Name or tostring(unitInstance)
    end

    return nil
end

local function getCurrentUpgradeLevel(unitName)
    if not unitName then return 0 end

    local success, upgradeLevel = pcall(function()
        local upgradeText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].UpgradeText.Text

        if string.find(upgradeText:upper(), "MAX") then
            return "MAX"
        end

        local level = string.match(upgradeText, "Upgrade:</font>%s*(%d+)")
        return tonumber(level) or 0
    end)

    if success then
        return upgradeLevel
    else
        print("❌ Failed to get upgrade level for:", unitName)
        return 0
    end
end

local function getUpgradeCost(unitName)
    if not unitName then return 9999 end

    local success, cost = pcall(function()
        local costText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].CostText.Text
        local costValue = string.match(costText, "Cost:</font>%s*([%d,]+)")
        if costValue then
            costValue = costValue:gsub(",", "")
            return tonumber(costValue) or 9999
        end
    end)

    return success and cost or 9999
end

local function getDeploymentCost(unitName)
    if not unitName then return 5000 end

    local success, costText = pcall(function()
        return Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].Unit.Frame.UnitFrame.Info.Cost.Text
    end)

    if success and costText then
        local numericCost = tonumber(costText:match("%d+"))
        if numericCost then
            return numericCost
        else
            return 9999 -- Extraction failed, fallback cost
        end
    else
        return 9999 -- Retrieval failed, fallback cost
    end
end


local function getCurrentMoney()
    local success, money = pcall(function()
        return Services.Players.LocalPlayer.Yen.Value
    end)

    return (success and money) or 0
end

local function upgradeUnit(unitName)
    if not unitName then return false end

    local unitNameStr = typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)

    local success = pcall(function()
        local args = { Services.Players.LocalPlayer.UnitsFolder:WaitForChild(unitNameStr) }
        Remotes.UpgradeUnit:FireServer(unpack(args))
    end)

    if success then
        print("✅ Upgraded unit:", unitNameStr)
        return true
    else
        warn("❌ Failed to upgrade unit:", unitNameStr)
        return false
    end
end

local function hasEnoughMoney(slotNumber)
    local currentMoney = getCurrentMoney()
    local unitName = getUnitNameFromSlot(slotNumber)
    local unitNameStr = typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)
    local unitCost = getDeploymentCost(unitNameStr)

    
    --print("Slot " .. slotNumber .. " - Money: " .. currentMoney .. ", Cost: " .. unitCost)
    
    return currentMoney >= unitCost
end

local function leftToRightUpgrade()
    while State.autoUpgradeEnabled and State.gameRunning do
        local unitName = getUnitNameFromSlot(State.currentUpgradeSlot)
        local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
        local maxLevel = Config.unitLevelCaps[tonumber(State.currentUpgradeSlot)] or 9

        if unitName and unitNameStr ~= "" and unitNameStr ~= "nil" then
            local currentLevel = getCurrentUpgradeLevel(unitNameStr)

            if currentLevel == "MAX" or tonumber(currentLevel) >= maxLevel then
                print("🏆 Unit " .. unitNameStr .. " reached max level, moving to next slot")
                State.currentUpgradeSlot = State.currentUpgradeSlot + 1
                if State.currentUpgradeSlot > 6 then
                    State.currentUpgradeSlot = 1
                end
            else
                local currentMoney = getCurrentMoney()
                local upgradeCost = getUpgradeCost(unitNameStr)

                if currentMoney >= upgradeCost then
                    if upgradeUnit(unitNameStr) then
                        task.wait(UPGRADE_COOLDOWN)
                    else
                        warn("❌ Failed to upgrade, will retry")
                        task.wait(1)
                    end
                end
            end
        else
            print("⚠️ No valid unit in slot " .. State.currentUpgradeSlot .. ", moving to next")
            State.currentUpgradeSlot = State.currentUpgradeSlot + 1
            if State.currentUpgradeSlot > 6 then
                State.currentUpgradeSlot = 1
            end
        end

        task.wait(0.5)
    end

    print("🛑 Upgrade cycle ended")
end

local function startAutoUpgrade()
    if isInLobby() then
        print("⚠️ Cannot start auto-upgrade while in lobby.")
        return
    end

    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end

    State.upgradeTask = task.spawn(function()
        while State.autoUpgradeEnabled do
            if State.gameRunning then
                local success, err = pcall(function()
                    if State.upgradeMethod == "Left to right until max" then
                        leftToRightUpgrade()
                    elseif State.upgradeMethod == "randomize" then
                        print("🔄 Randomize method not implemented yet")
                    elseif State.upgradeMethod == "lowest level spread upgrade" then
                        print("🔄 Lowest level spread method not implemented yet")
                    end
                end)

                if not success then
                    warn("❌ Auto upgrade error:", err)
                end
            else
                --print("⏳ Waiting for game to start...")
            end

            task.wait(1)
        end
    end)
end

local function stopAutoUpgrade()
    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end
end

local function resetUpgradeOrder()
    State.currentUpgradeSlot = 1
    print("🔄 Reset upgrade order to slot 1")
end

local function getUnitsWithUltimates()
    local unitsWithUltimates = {}

    local success, result = pcall(function()
        local agentFolder = Services.Workspace:WaitForChild("Agent", 5)
        if not agentFolder then return {} end

        local unitFolder = agentFolder:WaitForChild("UnitT", 5)
        if not unitFolder then return {} end

        for _, part in pairs(unitFolder:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Part") then
                local infoFolder = part:FindFirstChild("Info")
                if infoFolder then
                    local activeAbility = infoFolder:FindFirstChild("ActiveAbility")
                    local targetObject = infoFolder:FindFirstChild("TargetObject")

                    if activeAbility and activeAbility:IsA("StringValue") and targetObject and targetObject:IsA("ObjectValue") then
                        if activeAbility.Value ~= "" and targetObject.Value ~= nil then
                            table.insert(unitsWithUltimates, {
                                part = part,
                                abilityName = activeAbility.Value
                            })
                        end
                    end
                end
            end
        end

        return unitsWithUltimates
    end)

    if success then
        return result
    else
        warn("❌ Error getting units with ultimates:", result)
        return {}
    end
end

local function fireUltimateForUnit(unitData)
    local success = pcall(function()
        Services.ReplicatedStorage.Remote.Server.Units.Ultimate:FireServer(unitData.part)
    end)

    if not success then
        warn("❌ Failed to fire ultimate for unit:", unitData.part.Name)
    end
end

local function autoUltimateLoop()
    if isInLobby() then return end

    while State.AutoUltimateEnabled do
        local unitsWithUltimates = getUnitsWithUltimates()

        if #unitsWithUltimates > 0 then
            for _, unitData in pairs(unitsWithUltimates) do
                if not State.AutoUltimateEnabled then break end
                fireUltimateForUnit(unitData)
                task.wait(0.1)
            end
        end

        task.wait(1)
    end

    print("🛑 Auto Ultimate loop stopped")
end

local function startAutoUltimate()
    if isInLobby() then return end
    if State.ultimateTask then
        task.cancel(State.ultimateTask)
        State.ultimateTask = nil
    end

    State.ultimateTask = task.spawn(function()
        local success, err = pcall(function()
            autoUltimateLoop()
        end)

        if not success then
            warn("❌ Auto Ultimate loop error:", err)
        end
    end)
end

local function stopAutoUltimate()
    if State.ultimateTask then
        task.cancel(State.ultimateTask)
        State.ultimateTask = nil
        print("🛑 Auto Ultimate task cancelled")
    end
end

local function checkSlotExists(slotNumber)
    local slotPath = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber]
    if slotPath and slotPath.Frame.UnitFrame and slotPath.Frame.UnitFrame.Info.Folder.Value ~= nil then
        State.slotExists[slotNumber] = true
        return true
    else
        State.slotExists[slotNumber] = false
        return false
    end
end

local function isSlotOnCooldown(slotNumber)
    local cooldownPath = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame:FindFirstChild("CD_Frame")
    return cooldownPath and cooldownPath.Visible or false
end

local function shouldSkipSlotTemporarily(slotNumber)
    local lastAttempt = State.lastDeploymentTimes[slotNumber]
    if lastAttempt and (tick() - lastAttempt) < 3 then
        return true
    end
    return false
end

local function IsUnitLevelReached(slotNumber)
    local unitName = getUnitNameFromSlot(slotNumber)
    local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
    local currentUnitLevel = getCurrentUpgradeLevel(unitNameStr)
    if currentUnitLevel == "MAX" then
        return false
    end
    if currentUnitLevel < Config.unitDeployLevelCaps[slotNumber] then
        return true
    end
end

local function getNextReadySlot()
    local startSlot = State.currentSlot
    local checkedSlots = 0
    
    while checkedSlots < 6 do
    task.wait(0.5)
    local slotToCheck = State.currentSlot

    local shouldSkip = false

    if not checkSlotExists(slotToCheck) then
        shouldSkip = true
    elseif isSlotOnCooldown(slotToCheck) then
        shouldSkip = true
    elseif not hasEnoughMoney(slotToCheck) then
        shouldSkip = true
    elseif shouldSkipSlotTemporarily(slotToCheck) then
        shouldSkip = true
    elseif IsUnitLevelReached(slotToCheck) then
        shouldSkip = true
    end

    if shouldSkip then
        State.currentSlot = (State.currentSlot % 6) + 1
        checkedSlots = checkedSlots + 1
    else
        return slotToCheck
    end
end
    return nil
end

local function deployUnit(slotNumber)
    if not checkSlotExists(slotNumber) then
        return false, "Slot doesn't exist"
    end
    
    if isSlotOnCooldown(slotNumber) then
        return false, "Unit is on cooldown"
    end

    if not hasEnoughMoney(slotNumber) then
        return false, "Not enough money"
    end

    if IsUnitLevelReached(slotNumber) then
        return false, "Unit can't be deployed yet because of level"
    end
    -- Get the unit folder for this slot
    local unitFolder = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
    
    if not unitFolder then
        return false, "Unit folder not found"
    end
    
    -- Try to deploy the unit
    local success, errorMessage = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Deployment"):FireServer(unitFolder)
    end)
    
    if success then
        --print("Successfully deployed unit from slot " .. slotNumber)
        -- Clear any temporary skip for this slot since it worked
        State.lastDeploymentTimes[slotNumber] = nil
        return true, "Success"
    else
        print("Failed to deploy unit from slot " .. slotNumber .. ": " .. tostring(errorMessage))
        -- Mark this slot as recently failed
        State.lastDeploymentTimes[slotNumber] = tick()
        return false, "Deployment failed"
    end
end

local function autoPlayLoop()
    task.spawn(function()
        while State.autoPlayEnabled do
            -- Find next ready slot
            local slotToDeploy = getNextReadySlot()
            
            if slotToDeploy then
                local success, message = deployUnit(slotToDeploy)
                
                if success then
                    -- Successfully deployed, move to next slot for next deployment
                    State.currentSlot = (slotToDeploy % 6) + 1
                   -- print("Deployed from slot " .. slotToDeploy .. ", next slot: " .. State.currentSlot)
                elseif not success and message == "Not enough money" then
                    State.currentSlot = (slotToDeploy % 6)
                else

                    -- Failed deployment, slot will be temporarily skipped
                    -- Move to next slot to continue the cycle
                    State.currentSlot = (slotToDeploy % 6) + 1
                    print("Failed to deploy from slot " .. slotToDeploy .. " (" .. message .. "), trying next slot")
                end
            else
                -- No ready slots found, continue cycling
                -- The getNextReadySlot function already moved currentSlot forward
                print("No ready slots found, continuing cycle...")
            end
            
            -- Wait before next attempt
            task.wait(0.1)
        end
    end)
end

local function startAutoPlay()
    if isInLobby() then 
        print("Cannot start autoplay: Player is in lobby")
        return 
    end
    
    print("Starting autoplay system...")
    
    -- Reset state
    if Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.AutoPlay.Value == true then
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("AutoPlay"):FireServer()
   end
    State.currentSlot = 1
    State.lastDeploymentTimes = {}
    State.slotExists = {}
    
    -- Check which slots have units initially
    for i = 1, 6 do
        checkSlotExists(i)
        print("Slot " .. i .. " exists: " .. tostring(State.slotExists[i]))
    end
    
    autoPlayLoop()
end

local function StreamerMode()
    local head = Services.Players.LocalPlayer.Character:WaitForChild("Head", 5)
    if not head then return end

    local billboard = head:FindFirstChild("PlayerHeadGui")
    if not billboard then return end

    local originalNumbers = Services.Players.LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("ExpBar"):FindFirstChild("Numbers")
    if not originalNumbers then return end

    local streamerLabel = Services.Players.LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("ExpBar"):FindFirstChild("Numbers_Streamer")
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "Numbers_Streamer"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = originalNumbers.Parent
    end

    if State.streamerModeEnabled then
        billboard:FindFirstChild("PlayerName").Text = "🔥 Protected By LixHub 🔥"
        billboard:FindFirstChild("Level").Text = "Level 999"
        billboard:FindFirstChild("Title").Text = "Lixhub User"

        originalNumbers.Visible = false
        streamerLabel.Visible = true
    else
        billboard:FindFirstChild("PlayerName").Text = tostring(Services.Players.LocalPlayer.Name)
        billboard:FindFirstChild("Level").Text = "Level " .. Services.ReplicatedStorage:WaitForChild("Player_Data")[Services.Players.LocalPlayer.Name].Data.Level.Value
        billboard:FindFirstChild("Title").Text = Services.ReplicatedStorage:WaitForChild("Player_Data")[Services.Players.LocalPlayer.Name].Data.Title.Value

        originalNumbers.Visible = true
        streamerLabel.Visible = false
    end
end

local function startRetryLoop()
    State.retryAttempted = true
    task.spawn(function()
        while State.retryAttempted and State.autoRetryEnabled do
            Remotes.RetryEvent:FireServer()
            task.wait(0.5) -- Retry interval (can adjust)
        end
    end)
end

local function stopRetryLoop()
    State.retryAttempted = false
end

local function startNextLoop()
    State.NextAttempted = true

    task.spawn(function()
        while State.NextAttempted and State.autoNextEnabled do
            Remotes.NextEvent:FireServer()
            task.wait(0.5) -- Retry interval (can adjust)
        end
    end)
end

local function stopNextLoop()
    State.NextAttempted = false
end

local function getunitRarity(unit)
    local success, result = pcall(function()
        local gui = Services.Players.LocalPlayer.PlayerGui.Collection.Main.Base.Space.Unit[unit.Name].Frame.UnitFrame
        for _, rarity in ipairs({ "Ranger", "Secret", "Mythic", "Legendary", "Epic", "Rare" }) do
            if gui:FindFirstChild(rarity) then return rarity end
        end
    end)
    return success and result or nil
end

local CurseImageIDs = {
    ["Ability Damage"] = "rbxassetid://129472130637846",
    ["Ability Cooldown"] = "rbxassetid://94734246361320",
    ["Health"] = "rbxassetid://132403000977312",
    ["Damage"] = "rbxassetid://128960075980851",
    ["Attack Cooldown"] = "rbxassetid://102308191455123",
    ["Range"] = "rbxassetid://105399018590765",
    ["Speed"] = "rbxassetid://131770445081586",
}

local function GetAppliedCurses()
    local main = Services.Players.LocalPlayer.PlayerGui:WaitForChild("ApplyCurse").Main.Base.Stats.Main
    local results = {}

    for _, statFrame in pairs(main:GetChildren()) do
        if statFrame.Name == "StatTemp" then
            local icon = statFrame:FindFirstChild("StatsIconic")
            local buffIcon = statFrame:FindFirstChild("BuffIconic")
            if icon and buffIcon then
                local isGreen = buffIcon.Image == "rbxassetid://73853750530888"
                print("[DEBUG] Found Curse Image:", icon.Image, "isGreen:", isGreen)
                table.insert(results, {
                    image = icon.Image,
                    isGreen = isGreen,
                })
            end
        end
    end
    return results
end

local function CursesMatch(applied, selected)
    local matched = 0
    for _, curse in ipairs(applied) do
        for _, name in ipairs(selected) do
            if curse.image == CurseImageIDs[name] and curse.isGreen then
                matched = matched + 1
                 print("[DEBUG] Matched:", name, "[", appliedId, "]")
                break
            else
                 print("[DEBUG] No Match:", name, "[", curse.image, "] vs [", CurseImageIDs[name], "]", "| Green:", curse.isGreen)
            end
        end
    end
     print("[DEBUG] Total Matched:", matched)
    return matched >= 2
end

local function StartAutoCurse(selectedCurses)
    if isInLobby() then
        task.spawn(function()
            while State.AutoCurseEnabled do
                local unit = Services.Players.LocalPlayer.PlayerGui:WaitForChild("ApplyCurse").Main.Base.Unit.Frame.UnitFrame.Info.Folder.Value

                if not unit then
                    notify("Auto Curse","Curse UI/Selected unit are not present!")
                    task.wait(3)
                else
                    Remotes.ApplyCurseRemote:FireServer("ApplyCurse - Normal", unit)
                    task.wait(1.5)

                    local applied = GetAppliedCurses()

                    if CursesMatch(applied, State.selectedCurses) then
                        print("✅ 2 green selected curses found. Done.")
                        notify("Auto Curse", "Done! You can now turn off auto curse")
                        break
                    end
                end
            end
        end)
    end
end


--//\\--

--[[task.spawn(function()
    while true do
        task.wait(0.25)
        if isInLobby() then
                local visual = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Visual")
                -- UI disabled: delete and backup
                if State.DisableSummonUI then
                    if visual and not visualBackup then
                        visualBackup = visual:Clone()
                        pcall(function()
                            visual:Destroy()
                        end)
                    end
                else
                    -- UI enabled: restore backup if missing
                    if not visual and visualBackup then
                        pcall(function()
                            visualBackup.Parent = playerGui
                            visualBackup = nil
                        end)
                    end
                end
            end
        end
end)--]]

task.spawn(function()
    while true do
        task.wait(1) -- check every 5 seconds

        if State.AutoSellRarities and typeof(State.SelectedRaritiesToSell) == "table" then
            local data = GameObjects.GetData.GetData(Services.Players.LocalPlayer)
            local collection = data.Collection:GetChildren()

            for _, unit in ipairs(collection) do
                local rarity = getunitRarity(unit)
                if table.find(State.SelectedRaritiesToSell, rarity) then
                    local realUnitFolder = GameObjects.getUnitFolder(Services.Players.LocalPlayer, unit)
                   if realUnitFolder then
    local lockedFlag = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Collection[unit.Name].Lock
    if lockedFlag.Value == false then
        local args = {{ realUnitFolder, nil }}
        Remotes.SellRemote:FireServer(unpack(args))
    end
end
end
            end
        end
    end
end)

     spawn(function()
    while true do
        if State.AutoUltimateEnabled then
            startAutoUltimate()
        end
        wait(0.5) -- Check every 0.5 seconds if we should start
    end
    end)

    task.spawn(function()
        print("🔄 Fetching story data...")
        Data.availableStories = fetchStoryData()
        
        print("🔄 Fetching ranger stage data...")
        Data.availableRangerStages = fetchRangerStageData(Data.availableStories)
        
        print("✅ Data fetching complete!")
    end)

    task.spawn(function()
        while true do
            task.wait(0.5) -- Check every 0.5 seconds
            checkAndExecuteHighestPriority()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            StreamerMode()
        end
    end)

task.spawn(function()
    while true do
        wait(0.1)
             if State.autoDisableEndUI and not isInLobby() then
     for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
    if child.Name == "GameEndedAnimationUI" then
        child.Enabled = false
    end
end
for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
    if child.Name == "RewardsUI" then
        child.Enabled = false
    end
end
for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
    if child.Name == "Visual" then
        child.Enabled = false
    end
end
end
    end
end)

    task.spawn(function()
        while true do
            task.wait(5)
            if State.autoReturnBossTicketResetEnabled then
                local currentTickets = getBossAttackTickets()
                local currentResetTime = getBossTicketResetTime()
                if currentTickets > State.lastBossTicketCount or currentResetTime ~= State.lastBossTicketResetTime then
                    if State.lastBossTicketCount == 0 and currentTickets > 0 then
                        print("🎫 Boss Attack tickets reset detected! Tickets:", currentTickets)
                        notify("Boss Tickets", string.format("Tickets reset! Now have %d tickets", currentTickets))
                        State.pendingBossTicketReturn = true
                    end
                end
                
                State.lastBossTicketCount = currentTickets
                State.lastBossTicketResetTime = currentResetTime
            end
        end
    end)

        task.spawn(function()
        while true do
            task.wait(2)
            if State.autoAfkTeleportEnabled and isInLobby() and GameObjects.AFKChamberUI.Enabled == false then
                print("🚀 Teleporting to AFK world...")
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("AFKWorldTeleport"):FireServer()
            end
        end
    end)

    task.spawn(function()
        while true do
            if State.AutoPurchaseMerchant and #Data.MerchantPurchaseTable > 0 then
                autoPurchaseItems()
            end
            task.wait(1)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(3)
           -- if isInLobby() then
            if State.autoClaimBP then
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events"):WaitForChild("ClaimBp"):FireServer("Claim All")
            end
            if State.AutoClaimQuests then
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("QuestEvent"):FireServer("ClaimAll")
            end
            if State.AutoClaimMilestones then
            local playerlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("LevelMilestone"):FireServer(tonumber(playerlevel))
               -- end
            end
        end
    end)

     task.spawn(function()
        while true do
            task.wait(1)

            if State.autoStartEnabled then
                local voteVisible = false

                pcall(function()
                    voteVisible = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
                        :WaitForChild("HUD")
                        :WaitForChild("InGame")
                        :WaitForChild("VotePlaying").Visible
                end)

                if voteVisible then
                    print("✅ Vote screen is visible — sending start signal...")
                    Remotes.StartGame:FireServer()
                    task.wait(3) -- optional cooldown between fires
                end
            end
        end
    end)

--//BUTTONS\\--

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Curse (open curse UI and select unit manually)",
    CurrentValue = false,
    Flag = "AutoCurseToggle",
    Callback = function(Value)
        State.AutoCurseEnabled = Value
        if #State.selectedCurses >= 2 and State.AutoCurseEnabled then
            StartAutoCurse(State.selectedCurses)
        end
    end,
})

local CurseSelectorDropdown = LobbyTab:CreateDropdown({
    Name = "Select Curses",
    Options = {"Ability Damage","Ability Cooldown","Health","Damage","Attack Cooldown","Range","Speed"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "CurseSelector",
    Callback = function(Options)
        State.selectedCurses = Options
    end,
})



local Button = LobbyTab:CreateButton({
        Name = "Return to lobby",
        Callback = function()
            notify("Return to lobby", "Returning to lobby!")
            Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
        end,
    })

local Button = LobbyTab:CreateButton({
        Name = "Redeem all valid codes",
        Callback = function()
            for _, code in ipairs(Data.CurrentCodes) do
                notify("Redeeming code: ", code, 2.5)
                Remotes.Code:FireServer(code)
                task.wait(0.25) -- small delay so server doesn't get flooded
            end
            notify("Redeem all valid codes", "Tried to redeem all codes!")
        end,
    })



    local Label5 = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

--//TOGGLES\\--
    local GameSection = GameTab:CreateSection("👥 Player 👥")
    local Toggle = GameTab:CreateToggle({
    Name = "Low Performance Mode",
    CurrentValue = false,
    Flag = "enableLowPerformanceMode",
    Callback = function(Value)
        State.enableLowPerformanceMode = Value
        enableLowPerformanceMode()
    end,
})

    local Toggle = GameTab:CreateToggle({
    Name = "Delete Map (Rejoin to disable)",
    CurrentValue = false,
    Flag = "enableDeleteMap",
    Callback = function(Value)
        State.enableDeleteMap = Value
        enableDeleteMap()
    end,
})

if State.enableLowPerformanceMode then
    enableLowPerformanceMode()
end

if State.enableDeleteMap then
    enableDeleteMap()
end

local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Sell Rarities",
    CurrentValue = false,
    Flag = "AutoSellRarities",
    Callback = function(Value)
        State.AutoSellRarities = Value
    end,
})

local RaritySellerDropdown = LobbyTab:CreateDropdown({
    Name = "Select Rarities To Sell",
    Options = { "Rare", "Epic", "Legendary" },
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "RaritySellerSelector",
    Callback = function(Options)
        State.SelectedRaritiesToSell = Options
       -- notify("Auto Sell Rarities", "Selected Rarities: " .. table.concat(Options, ", "), 2)
    end,
})

  --[[  local Toggle = LobbyTab:CreateToggle({
    Name = "Disable Summon UI",
    CurrentValue = false,
    Flag = "DisableSummoningUI",
    Callback = function(Value)
        State.DisableSummonUI = Value
    end,
    })--]]

local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Purchase Merchant Items",
    CurrentValue = false,
    Flag = "AutoPurchaseMerchant",
    Callback = function(Value)
        State.AutoPurchaseMerchant = Value
    end,
    })

     local MerchantSelectorDropdown = LobbyTab:CreateDropdown({
    Name = "Select Items To Purchase",
    Options = {"Dr. Megga Punk","Cursed Finger","Perfect Stats Key","Stats Key","Trait Reroll","Ranger Crystal"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "MerchantPurchaseSelector",
    Callback = function(Options)
        --notify("Auto Purcahse Merchant Items","Selected Items: " .. table.concat(Options, ", "), 2)
        Data.MerchantPurchaseTable = Options
    end,
    })

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Battlepass",
    CurrentValue = false,
    Flag = "AutoClaimBattlepass",
    Callback = function(Value)
        State.autoClaimBP = Value
    end,
    })

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Quests",
    CurrentValue = false,
    Flag = "AutoClaimQuests",
    Callback = function(Value)
        State.AutoClaimQuests = Value
    end,
    })

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Level Milestones",
    CurrentValue = false,
    Flag = "AutoClaimMilestones",
    Callback = function(Value)
        State.AutoClaimMilestones = Value
    end,
    })

    Toggle = LobbyTab:CreateToggle({
        Name = "Auto AFK Teleport",
        CurrentValue = false,
        Flag = "AutoAfkTeleportToggle",
        Callback = function(Value)
            State.autoAfkTeleportEnabled = Value
        end,
    })

     local Toggle = GameTab:CreateToggle({
    Name = "Streamer Mode",
    CurrentValue = false,
    Flag = "streamerModeEnabled",
    Callback = function(Value)
        State.streamerModeEnabled = Value
    end,
})

    local JoinerSection0 = JoinerTab:CreateSection("🤖 Boss Rush Joiner 🤖")

       local Toggle = JoinerTab:CreateToggle({
    Name = "Boss Rush Joiner",
    CurrentValue = false,
    Flag = "AutoBossRushToggle",
    Callback = function(Value)
        State.autoBossRushEnabled = Value
    end,
    })

    local Toggle = JoinerTab:CreateToggle({
    Name = "Autoplay - Boss Rush",
    CurrentValue = false,
    Flag = "AutoPlayBossRush",
    Callback = function(Value)
        State.autoPlayBossRushEnabled = Value
         if State.autoPlayBossRushEnabled then
            startBossRushLogic()
        else
            stopBossRushLogic()
        end
    end,
    })

    local BossRushSlider = Tab:CreateSlider({
   Name = "Switch paths every x (seconds)",
   Range = {0, 10},
   Increment = 0.1,
   Suffix = "Seconds",
   CurrentValue = 10,
   Flag = "BossRushPathSwitcher", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
  
   end,
})

    local JoinerSection0 = JoinerTab:CreateSection("👹 Boss Event Joiner 👹")

    local AutoJoinBossEventToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Boss Event",
    CurrentValue = false,
    Flag = "AutoBossEventToggle",
    Callback = function(Value)
        State.autoBossEventEnabled = Value
    end,
    })

    local JoinerSection = JoinerTab:CreateSection("📖 Story Joiner 📖")

      local AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoStoryToggle",
    Callback = function(Value)
        State.autoJoinEnabled = Value
    end,
    })

      local StageDropdown = JoinerTab:CreateDropdown({
    Name = "Story Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryStageSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        State.selectedWorld = Option[1]
      --  notify("Auto Join Story","Selected Stage: "..Option[1], 2)
    end,
    })

    local ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Stage Chapter",
    Options = Config.chapters,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryChapterSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        State.selectedChapter = Option[1]
       -- notify("Auto Join Story","Selected Chapter: "..Option[1], 2)
    end,
    })
    local DifficultyDropdown = JoinerTab:CreateDropdown({
    Name = "Stage Difficulty",
    Options = Config.difficulties,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        State.selectedDifficulty = Option[1]
--notify("Auto Join Story","Selected Difficulty: "..Option[1], 2)
    end,
    })

    local rewardNames = {}

    for _, reward in ipairs(GameObjects.itemsFolder:GetChildren()) do
        if reward:IsA("BoolValue") then
            table.insert(rewardNames, reward.Name)
        end
    end


    local JoinerSection2 = JoinerTab:CreateSection("🏆 Challenge Joiner 🏆")
    local rewardText = #rewardNames > 0 and table.concat(rewardNames, ", ") or "None"
    local Label3 = JoinerTab:CreateLabel("Current Challenge Rewards: " .. rewardText, "gift")

        local Toggle = JoinerTab:CreateToggle({
    Name = "Challenge Joiner",
    CurrentValue = false,
    Flag = "AutoChallengeToggle",
    Callback = function(Value)
        State.autoChallengeEnabled = Value
    end,
    })

    local IgnoreChallengeDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Challenge Worlds",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "IgnoreChallengeWorld",
    Callback = function(Options)
        Data.selectedChallengeWorlds = Options
    end,
})

    task.spawn(function()
        while #Data.availableStories == 0 do
            task.wait(0.5)
        end
        
        local storyNames = {}
        for _, story in ipairs(Data.availableStories) do
            table.insert(storyNames, story.SeriesName)
        end
        
        StageDropdown:Refresh(storyNames)
        IgnoreChallengeDropdown:Refresh(storyNames)
        print("✅ Story dropdown(s) updated with", #storyNames, "options")
    end)

 local ChallengeDropdown = JoinerTab:CreateDropdown({
    Name = "Select Challenge Rewards",
    Options = {"Dr. Megga Punk","Ranger Crystal","Stats Key","Perfect Stats Key","Trait Reroll","Cursed Finger"},
    CurrentOption = {},
    MultipleOptions = true, -- Changed back to true for multiple selection
    Flag = "ChallengeRewardSelector",
    Callback = function(options)
        Data.wantedRewards = options
    end,
    })

    local Toggle = JoinerTab:CreateToggle({
        Name = "Return to Lobby on New Challenge",
        CurrentValue = false,
        Flag = "AutoReturnChallengeToggle",
        Callback = function(Value)
            State.challengeAutoReturnEnabled = Value
        end,
    })

    local JoinerSection3 = JoinerTab:CreateSection("🌀 Portal Joiner 🌀")

     local Toggle = JoinerTab:CreateToggle({
    Name = "Portal Joiner",
    CurrentValue = false,
    Flag = "AutoPortalToggle",
    Callback = function(Value)
        State.autoPortalEnabled = Value
         if autoPortalEnabled then
            State.portalUsed = false
         end
    end,
    })

     local PortalSelectorDropdown = JoinerTab:CreateDropdown({
    Name = "Select Portals to join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PortalSelector",
    Callback = function(Options)
        State.selectedPortals = Options
    end,
})

task.spawn(function()
        local portalNames = {}

        local inventory = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items
        if inventory then
            for _, item in ipairs(inventory:GetChildren()) do
                if item:IsA("Folder") and item.Name:lower():find("portal") and item:FindFirstChild("Amount").Value > 0 then
                    table.insert(portalNames, item.Name)
                end
            end
        end
        PortalSelectorDropdown:Refresh(portalNames)
end)

    local JoinerSection4 = JoinerTab:CreateSection("🏹 Ranger Stage Joiner 🏹")

        local Toggle = JoinerTab:CreateToggle({
        Name = "Auto Join Ranger Stage",
        CurrentValue = false,
        Flag = "AutoRangerStageToggle",
        Callback = function(Value)
            State.isAutoJoining = Value
        end,
    })

    local RangerStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Ranger Stage To Join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RangerStageSelector",
    Callback = function(Options)
        Data.selectedRawStages = {}
        
        for _, selectedDisplay in ipairs(Options) do
            for _, stage in ipairs(Data.availableRangerStages) do
                if stage.DisplayName == selectedDisplay then
                table.insert(Data.selectedRawStages, stage.RawName)
               -- notify("Auto Ranger Stage","Selected Stages: " .. table.concat(Data.selectedRawStages, ", "), 2)
                break
                end
            end
        end
    end,
})

task.spawn(function()
        while #Data.availableRangerStages == 0 do
            task.wait(0.5)
        end
        
        local rangerDisplayNames = {}
        for _, stage in ipairs(Data.availableRangerStages) do
            table.insert(rangerDisplayNames, stage.DisplayName)
        end
        
        RangerStageDropdown:Refresh(rangerDisplayNames)
        print("✅ Ranger stage dropdown updated with", #rangerDisplayNames, "options")
    end)

    local JoinerSection5 = JoinerTab:CreateSection("💥 Boss Attack 💥")

    local Label2 = JoinerTab:CreateLabel("Boss Tickets: "..Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackTicket.Value, "ticket")

        local Toggle = JoinerTab:CreateToggle({
    Name = "Auto join boss attack",
    CurrentValue = false,
    Flag = "AutoJoinBossAttack",
    Callback = function(Value)
        State.autoBossAttackEnabled = Value
        if State.autoBossAttackEnabled then
            State.lastBossTicketCount = getBossAttackTickets()
            State.lastBossTicketResetTime = getBossTicketResetTime()
            print("🎫 Current boss attack tickets:", State.lastBossTicketCount)
        end
    end,
    })

        local Toggle = JoinerTab:CreateToggle({
    Name = "Return to Lobby When Boss Attack Tickets Reset",
    CurrentValue = false,
    Flag = "AutoReturnBossAttackToggle",
    Callback = function(Value)
        State.autoReturnBossTicketResetEnabled = Value
        if State.autoReturnBossTicketResetEnabled then
            State.lastBossTicketCount = getBossAttackTickets()
            State.lastBossTicketResetTime = getBossTicketResetTime()
        end
    end,
    })

    local JoinerSection6 = JoinerTab:CreateSection("🏰 Infinity Castle 🏰")

       local Toggle = JoinerTab:CreateToggle({
    Name = "Auto Infinity Castle",
    CurrentValue = false,
    Flag = "AutoInfinityCastle",
    Callback = function(Value)
        State.autoInfinityCastleEnabled = Value     
        if State.autoInfinityCastleEnabled then
            startInfinityCastleLogic()
        else
            stopInfinityCastleLogic()
        end
    end,
    })

    local GameSection = GameTab:CreateSection("🎮 Game 🎮")
    local Label4 = JoinerTab:CreateLabel("You need decently good units for infinity castle to win. Don't use any other auto joiners if you're enabling this and don't panic if it fails sometimes (unless your units are not good enough).", "badge-info")

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto 1x/2x/3x Speed",
    CurrentValue = false,
    Flag = "AutoSpeedToggle",
    Callback = function(Value)
        State.AutoSelectSpeed = Value
       
    end,
})

    local AutoSpeedDropdown = JoinerTab:CreateDropdown({
    Name = "Select Auto Speed Value",
    Options = {"1x","2x","3x"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoSpeedSelector",
    Callback = function(Options)
       State.SelectedSpeedValue = Options
    end,
})

task.spawn(function()
    while true do
        if not isInLobby() then
        if State.AutoSelectSpeed and State.SelectedSpeedValue then
            local raw = State.SelectedSpeedValue
            local value = type(raw) == "table" and raw[1] or raw
            local speedNum = tonumber(tostring(value):gsub("x", ""))
            if speedNum then
                game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("SpeedGamepass"):FireServer(speedNum)
            end
        end
        
    end
    task.wait(1)
    end
end)


     local Toggle = GameTab:CreateToggle({
    Name = "Auto Start",
    CurrentValue = false,
    Flag = "AutoStartToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        State.autoStartEnabled = Value
    end,
    })

    local Toggle = GameTab:CreateToggle({
    Name = "Auto Next",
    CurrentValue = false,
    Flag = "AutoNextToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        State.autoNextEnabled = Value
        if State.autoNextEnabled then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteNext"):FireServer()
        end
    end,
    })

    local Toggle = GameTab:CreateToggle({
    Name = "Auto Retry",
    CurrentValue = false,
    Flag = "AutoRetryToggle",
    Callback = function(Value)
        State.autoRetryEnabled = Value
        if State.autoRetryEnabled then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteRetry"):FireServer()
        end
    end,
    })

    local Toggle = GameTab:CreateToggle({
    Name = "Auto Lobby",
    CurrentValue = false,
    Flag = "AutoLobbyToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        State.autoReturnEnabled = Value
        if State.hasGameEnded and State.autoReturnEnabled then
            Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
        end
    end,
    })

    local Toggle = GameTab:CreateToggle({
    Name = "Disable End Screen UI(s)",
    CurrentValue = false,
    Flag = "AutoDisableEndUI", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        State.autoDisableEndUI = Value
    end,
    })

    local Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Play",
    CurrentValue = false,
    Flag = "AutoPlayToggle",
    Callback = function(Value)
    State.autoPlayEnabled = Value
    if State.autoPlayEnabled then
        startAutoPlay()
    end
    end,
    })

    local Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgradeToggle",
    Callback = function(Value)
        State.autoUpgradeEnabled = Value
        if State.autoUpgradeEnabled then
            State.gameRunning = true
            resetUpgradeOrder()
            startAutoUpgrade()
        else
            stopAutoUpgrade()
        end
    end,
    })

      local Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Ultimate",
    CurrentValue = false,
    Flag = "AutoUltimate",
    Callback = function(Value)
        State.AutoUltimateEnabled = Value
    end,
    })

      local AutoUpgradeDropdown = AutoPlayTab:CreateDropdown({
    Name = "Select Upgrade Method",
    Options = {"Left to right until max"},
    CurrentOption = {"Left to right until max"},
    MultipleOptions = false,
    Flag = "UpgradeMethodSelector",
    Callback = function(Options)
        State.upgradeMethod = Options[1] or "Left to right until max"
        if State.autoUpgradeEnabled then
            stopAutoUpgrade()
            resetUpgradeOrder()
            State.gameRunning = true
            task.wait(0.5)
            startAutoUpgrade()
        end
    end,
    })

    local Slider1 = AutoPlayTab:CreateSlider({
    Name = "Unit 1 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit1LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[1] = Value
    end,
    })

    local Slider1_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 1 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit1DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[1] = Value
    end,
    })

    local Slider2 = AutoPlayTab:CreateSlider({
    Name = "Unit 2 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit2LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[2] = Value
    end,
    })

     local Slider2_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 2 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit2DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[2] = Value
    end,
    })

    local Slider3 = AutoPlayTab:CreateSlider({
    Name = "Unit 3 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit3LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[3] = Value
    end,
    })

     local Slider3_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 3 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit3DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[3] = Value
    end,
    })

    local Slider4 = AutoPlayTab:CreateSlider({
    Name = "Unit 4 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit4LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[4] = Value
    end,
    })

     local Slider4_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 4 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit4DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[4] = Value
    end,
    })

    local Slider5 = AutoPlayTab:CreateSlider({
    Name = "Unit 5 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit5LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[5] = Value
    end,
    })

     local Slider5_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 5 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit5DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[5] = Value
    end,
    })

    local Slider6 = AutoPlayTab:CreateSlider({
    Name = "Unit 6 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit6LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[6] = Value
    end,
    })

     local Slider6_5 = AutoPlayTab:CreateSlider({
    Name = "Dont deploy unit 6 until level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit6DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[6] = Value
    end,
    })

    local Input = WebhookTab:CreateInput({
    Name = "Input Webhook",
    CurrentValue = "",
    PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInput",
    Callback = function(Text)
        if string.find(Text, "https://discord.com/api/webhooks/") then
            ValidWebhook = Text
            Label5:Set("✅ Webhook URL set!")
        elseif Text == "" then
            Label5:Set("Awaiting Webhook Input...")
            ValidWebhook = nil
        else
            ValidWebhook = nil
            Label5:Set("❌ Invalid Webhook URL")
        end
    end,
    })

    local Input = WebhookTab:CreateInput({
    Name = "Input Discord ID (mention rares)",
    CurrentValue = "",
    PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInputUserID",
    Callback = function(Text)
        Config.DISCORD_USER_ID = tostring(Text)
    end,
    })

     local TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
    })

    local Toggle = WebhookTab:CreateToggle({
    Name = "Send On Stage Finished",
    CurrentValue = false,
    Flag = "sendWebhookWhenStageCompleted",
    Callback = function(Value)
        State.SendStageCompletedWebhook = Value
    end,
    })

game.ReplicatedStorage.Remote.Replicate.OnClientEvent:Connect(function(...)
        local args = {...}
        if table.find(args, "Game_Start") then
            State.gameRunning = true
            State.startingInventory = snapshotInventory()
        resetUpgradeOrder()
        stopRetryLoop()
        stopNextLoop()
        

            State.retryAttempted = false
            State.NextAttempted = false
            State.hasGameEnded = false
            State.hasSentWebhook = false
            State.stageStartTime = tick()
            print("🟢 Stage started at", State.stageStartTime)
        end
    end)

Remotes.GameEndedUI.OnClientEvent:Connect(function(_, outcome)
        if typeof(outcome) == "string" then
            local l = outcome:lower()
            if l:find("defeat") then
                State.matchResult = "Defeat"
            elseif l:find("won") or l:find("win") then
                State.matchResult = "Victory"
            else
                State.matchResult = "Unknown"
            end
            print("🎯 Match result detected:", State.matchResult)
        end
    end)

Services.ReplicatedStorage.Remote.Client.UI.Challenge_Updated.OnClientEvent:Connect(function()
        if State.challengeAutoReturnEnabled and not isInLobby() then
           -- notify("Challenge Update", "New challenge detected - will return to lobby when game ends")
             State.pendingChallengeReturn = true
        end
    end)

Remotes.GameEnd.OnClientEvent:Connect(function()
    if State.hasSentWebhook then
            return
        end
        State.hasGameEnded = true
        if State.SendStageCompletedWebhook then
        State.hasSentWebhook = true
        end
        State.gameRunning = false
        resetUpgradeOrder()

        task.wait(0.5)
        local clearTimeStr = "Unknown"
        if State.stageStartTime then
            local dt = math.floor(tick() - State.stageStartTime)
            clearTimeStr = string.format("%d:%02d", dt // 60, dt % 60)
        end

        if State.SendStageCompletedWebhook then
        sendWebhook("stage", nil, clearTimeStr, State.matchResult)
        end

        State.actionTaken = false

        if State.pendingBossTicketReturn and not State.actionTaken then
            notify("Boss Tickets", "Tickets available - returning to lobby")
            State.pendingBossTicketReturn = false
            State.actionTaken = true
            task.delay(2, function()
                Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
            end)
            return
        end

        if State.pendingChallengeReturn and not State.actionTaken then
            notify("Challenge Return", "New challenge detected - returning to lobby")
            State.pendingChallengeReturn = false
            State.actionTaken = true
            task.delay(2, function()
                Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
            end)
            return
        end

    if State.autoRetryEnabled then
        startRetryLoop()
    end
    if State.autoNextEnabled then
        startNextLoop()
    end
    if State.autoReturnEnabled then
         task.delay(2, function()
                Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
            end)
    end

end)

Rayfield:LoadConfiguration()
