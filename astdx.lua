local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - ASTDX",
   Icon = 0,
   LoadingTitle = "Loading for All Star Tower Defense X",
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
      FileName = "Lixhub_ASTDX"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "LixHub - ASTD:X - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})

local UpdateLogTab = Window:CreateTab("Update Log", "scroll")
local LobbyTab = Window:CreateTab("Lobby", "tv")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

local UpdateLogSection = UpdateLogTab:CreateSection("v0.01")

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
}

local State = {
   AutoJoinStory = false,
   StoryStageSelected = {},
   StoryArcSelected = {},
   StoryDifficultySelected = {},
   
}

local AutoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2
}

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
        local displayName = Option[1]
        local internalName = getgenv().WorldNameMap and getgenv().WorldNameMap[displayName]
        local changedInternalName = "World"..tostring(internalName)
        
        if internalName then
            print("Selected world:", displayName, "-> Internal name:", tostring(changedInternalName))
            State.StoryStageSelected = changedInternalName
        else
            print("Warning: Could not find internal name for:", displayName)
            State.StoryStageSelected = displayName
        end
    end,
})

local ChapterDropdown869 = JoinerTab:CreateDropdown({
   Name = "Select Story Act",
   Options = {"Arc 1", "Arc 2", "Arc 3", "Arc 4", "Arc 5", "Arc 6"},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "StoryActSelector",
   Callback = function(Option)
        local num = tostring(Option[1]:match("%d+")) -- extract the digits
        State.StoryArcSelected = num
   end,
})

    local ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Difficulty",
    Options = {"Normal","Hard"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector",
    Callback = function(Option)
        State.StoryDifficultySelected = Option[1]
    end,
    })

    game.Players.LocalPlayer.PlayerGui.MainUI.ResultFrame.Result.ExpandFrame.TopFrame.BoxFrame.InfoFrame2.InnerFrame.CanvasFrame.CanvasGroup.BottomFrame.DetailFrame.RewardFrame.Rewards.RewardScroll

local function isInLobby()
    return Services.Workspace:GetAttribute("IsLobby")
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
            State.StoryArcSelected or "?",
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

    -- STORY
    if State.AutoJoinStory and State.StoryStageSelected ~= nil and State.StoryArcSelected ~= nil and State.StoryDifficultySelected ~= nil then
        setProcessingState("Auto Join Story")

            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer({Type = "Lobby",Object = Services.Workspace:WaitForChild("Map"):WaitForChild("Buildings"):WaitForChild("Pods"):WaitForChild("StoryPod"):WaitForChild("Interact"),Mode = "Pod"})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer({Chapter = State.StoryArcSelected,Type = "Lobby",Name = State.StoryStageSelected,Difficulty = State.StoryDifficultySelected,Mode = "Pod",Friend = true,Update = true})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetFunction"):InvokeServer({Start = true,Type = "Lobby",Update = true,Mode = "Pod"})

            task.delay(5, clearProcessingState)
            return
        end
    end

local function LoadStoryStages()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local WorldMod = require(ReplicatedStorage.Mods.WorldMod)
    
    -- Get all world data from server
    local worldData = WorldMod.Get()
    
    if not worldData then
        warn("Failed to get world data from server")
        return
    end
    
    local storyWorlds = {}
    local worldNameMap = {} -- Maps display names to internal names
    
    print("=== LOADING STORY STAGES ===")
    
    -- Extract story worlds (assuming they're in a table format)
    for worldName, worldInfo in pairs(worldData) do
        -- Check if this is a story world (not challenge/tower/etc)
        if type(worldInfo) == "table" then
            -- Story worlds are typically the numbered ones or have specific properties
            if worldInfo.DisplayName and not worldInfo.SideStory then
                local displayName = worldInfo.DisplayName
                table.insert(storyWorlds, displayName)
                worldNameMap[displayName] = worldName
                print("Found story world:", displayName, "->", worldName)
            elseif worldInfo.Name and not worldInfo.SideStory then
                -- Fallback if DisplayName doesn't exist
                local displayName = worldInfo.Name
                table.insert(storyWorlds, displayName)
                worldNameMap[displayName] = worldName
                print("Found story world:", displayName, "->", worldName)
            end
        end
    end
    
    -- Alternative approach if worldData has a different structure
    if #storyWorlds == 0 then
        print("Trying alternative extraction method...")
        for i, world in ipairs(worldData) do
            if type(world) == "table" then
                if world.DisplayName and not world.SideStory then
                    local displayName = world.DisplayName
                    local worldName = world.Name or ("World" .. i)
                    table.insert(storyWorlds, displayName)
                    worldNameMap[displayName] = worldName
                    print("Found story world:", displayName, "->", worldName)
                end
            end
        end
    end
    
    -- Sort worlds if they have numbers (World1, World2, etc.)
    table.sort(storyWorlds, function(a, b)
        local numA = tonumber(string.match(worldNameMap[a] or "", "%d+"))
        local numB = tonumber(string.match(worldNameMap[b] or "", "%d+"))
        if numA and numB then
            return numA < numB
        end
        return (worldNameMap[a] or a) < (worldNameMap[b] or b)
    end)
    
    print("Final story worlds count:", #storyWorlds)
    for i, displayName in ipairs(storyWorlds) do
        print(i .. ".", displayName, "->", worldNameMap[displayName])
    end
    
    -- Update the dropdown
    StoryStageDropdown:Refresh(storyWorlds, true)
    
    -- Store the mapping for the callback to use
    getgenv().WorldNameMap = worldNameMap
    
    print("Story stages loaded successfully!")
end

LoadStoryStages()

task.spawn(function()
    while true do
    task.wait(0.5)
    checkAndExecuteHighestPriority()
    end
end)

Rayfield:LoadConfiguration()
