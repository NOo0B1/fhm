---------------
-- CONSTANTS --
---------------
local fhm = CreateFrame("Frame", "fhm", GameTooltip)
fhm:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
fhm:RegisterEvent("UNIT_HEALTH")

---------------
-- VARIABLES --
---------------

local raids = 'Naxxramas'

local isDisabled=true

local isEncounterStarted = false

local bossNames = {
    "Thane Korth'azz",
    "Baron Rivendare",
    "Lady Blaumeux",
    "Sir Zeliek"
}

local bossSpells = {
    ["Thane Korth'azz"] = 28884,  -- Example spell ID for Meteor
    ["Baron Rivendare"] = 28863,  -- Example spell ID for Unholy Shadow
    ["Lady Blaumeux"] = 28833,    -- Example spell ID for Shadow Bolt
    ["Sir Zeliek"] = 28835        -- Example spell ID for Holy Wrath
}
---------------
-- FUNCTIONS --
---------------
-- Function to check if the input is a number
local function isNumber(input)
    return tonumber(input) ~= nil
end

-- Function to trim spaces from the start and end of a string
function trim(str)
    return str:match("^%s*(.-)%s*$")  -- Remove leading and trailing whitespace
end

function lrprint(a)
    if a == nil then
        DEFAULT_CHAT_FRAME:AddMessage('|cff69ccf0[LR]|cff0070de:' .. time() .. '|cffffffff attempt to print a nil value.')
        return false
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[LR] |cffffffff" .. a)
end

fhm:SetScript("OnEvent", function()
    -- if event == 'ADDON_LOADED' then
    --     lrprint("fhm is loaded successfully.")
    -- end
end)

local function StartEncounter()
    if not isEncounterStarted then
        isEncounterStarted = true
        lrprint("The Four Horsemen encounter has started!")
    end
end

-- Combat log handler function
local function OnCombatLogEvent(self, event, ...)
    local _, subEvent, _, sourceGUID, sourceName, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()

    -- Check if the event is a spell cast by one of the bosses
    if subEvent == "SPELL_CAST_START" and bossSpells[sourceName] == spellID then
        StartEncounter()
    end
end

-- Health check function to detect the fight start
local function OnHealthEvent(self, event, unit)
    -- Only check units that match the boss names
    for _, bossName in ipairs(bossNames) do
        if UnitName(unit) == bossName and UnitHealth(unit) < UnitHealthMax(unit) * 0.99 then
            StartEncounter()
            break
        end
    end
end

-- Print usage of the addon
function fhm:PrintHelp()
    lrprint("This is the help message for the addon fhm from Cromsson.")

    lrprint("Type /fhm help or /fhm h to display this function")
    lrprint("Type /fhm disable to disable this addon.")
    lrprint("Type /fhm enable to activate this addon.")
    lrprint("Type /fhm config to configure this addon.")
end

-- Initialize a table to store all custom frames and their initial positions
local customFrames = {}

-- Function to create a custom frame with title, size, and a toggle for dragging
local function CreateCustomFrame(name, titleText, width, height)
    -- Create the main frame
    local frame = CreateFrame("Frame", name, UIParent)
    frame:SetWidth(width)
    frame:SetHeight(height)
    -- Initial position: Center
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = 32, edgeSize = 32, 
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)

    -- Title text for the frame, if provided and not empty
    if titleText and titleText ~= "" then
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        title:SetPoint("TOP", frame, "TOP", 0, -10)
        title:SetText(titleText)
    end

    -- Enable mouse input for dragging
    frame:EnableMouse(true)
    frame:SetMovable(false)

    -- Create the toggle button to enable/disable dragging
    local toggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    toggleButton:SetWidth(20)
    toggleButton:SetHeight(20)
    toggleButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    -- Function to update button color and frame movability
    local function UpdateButtonAndFrameState()
        if frame:IsMovable() then
            toggleButton:SetBackdropColor(0, 1, 0, 1) -- Green for movable
            toggleButton:SetText("M")
            frame:RegisterForDrag("LeftButton")
        else
            toggleButton:SetBackdropColor(1, 0, 0, 1) -- Red for unmovable
            toggleButton:SetText("U")
            frame:RegisterForDrag()
        end
    end

    -- Toggle movability when the button is clicked
    toggleButton:SetScript("OnClick", function()
        frame:SetMovable(not frame:IsMovable())
        UpdateButtonAndFrameState()
    end)

    -- Set up frame dragging scripts
    frame:SetScript("OnDragStart", function()
        if frame:IsMovable() then
            frame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()

        -- Get the new point of the frame
        local point, relativeTo, relativePoint, x, y = frame:GetPoint()

        -- Update all frames to the same position
        for _, frameInfo in ipairs(customFrames) do
            if frameInfo.frame ~= frame then
                frameInfo.frame:ClearAllPoints()
                frameInfo.frame:SetPoint(point, relativeTo, relativePoint, x, y)
            end
        end
    end)

    -- Initialize button state
    UpdateButtonAndFrameState()

    -- Store the frame and its initial position
    table.insert(customFrames, {
        frame = frame,
        initialPoint = { "CENTER", UIParent, "CENTER", 0, 0 } -- initial SetPoint parameters
    })

    return frame
end



-- Function to reset all frames to their initial positions
local function ResetFramesToInitialPosition()
    for _, frameInfo in ipairs(customFrames) do
        local frame = frameInfo.frame
        local initialPoint = frameInfo.initialPoint
        frame:ClearAllPoints()
        frame:SetPoint(unpack(initialPoint))
    end
end



-------------------
-- PRE EXECUTION --
-------------------

-- Define a table with the frame configurations
local frameConfigs = {
    { name = "stratFrame", title = "Choose Your Strat", width = 300, height = 250 },
    { name = "roleFrame", title = "Choose Your Role", width = 300, height = 250 },
    { name = "numberInputFrame", title = nil, width = 300, height = 250 },
    { name = "imageFrame", title = "", width = 256, height = 256 },
}

-- Function to create and store each frame with initial position
local frames = {}
for _, config in ipairs(frameConfigs) do
    local frame = CreateCustomFrame(config.name, config.title, config.width, config.height)
    
    -- Ensure the frame is positioned before storing its initial position
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Default initial position

    -- Add the frame and its initial position to the `frames` table
    table.insert(frames, {
        frame = frame,
        initialPoint = { "CENTER", UIParent, "CENTER", 0, 0 } -- Default initial position
    })
end

-- Add the image to the image frame (example for setting up a texture)
local imageTexture = imageFrame:CreateTexture(nil, "BACKGROUND")
imageTexture:SetAllPoints(imageFrame)
imageTexture:SetTexture("Interface\\AddOns\\fhm\\fhpositions_256x256_32bit_alpha.tga")

-- Title for the number input frame
local numberInputTitle = numberInputFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

-- Title of the frame
local stratTitle = stratFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
stratTitle:SetPoint("TOP", stratFrame, "TOP", 0, -10)
stratTitle:SetText("Choose Your Strat")

-- Strat selection buttons
local strats = {"6 Tanks", "8 Tanks"}
local stratButtons = {}
local selectedStrat = nil

-- Create the strat selection buttons
for i, strat in ipairs(strats) do
    local stratName = strat  -- Create a local copy of `strat` for each loop iteration
    stratButtons[stratName] = CreateFrame("Button", nil, stratFrame, "UIPanelButtonTemplate")
    stratButtons[stratName]:SetWidth(200)
    stratButtons[stratName]:SetHeight(30)
    stratButtons[stratName]:SetPoint("TOP", stratFrame, "TOP", 0, -40 - (i-1)*40)
    stratButtons[stratName]:SetText(stratName)

    -- Set up button click event to set the selected strat
    stratButtons[stratName]:SetScript("OnClick", function()
        -- Update the selectedStrat variable
        selectedStrat = stratName
        lrprint("Strat selected: " .. selectedStrat)

        -- Hide the strat frame and show the number input frame
        stratFrame:Hide()
        roleFrame:Show()
    end)
end

-- Title of the frame
local roleTitle = roleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
roleTitle:SetPoint("TOP", roleFrame, "TOP", 0, -10)
roleTitle:SetText("Choose Your Role")

-- Role selection buttons
local roles = {"Tank", "Healer", "Melee DPS", "Ranged DPS"}
local roleButtons = {}
local selectedRole = nil

-- Create the role selection buttons
for i, role in ipairs(roles) do
    local roleName = role  -- Create a local copy of `role` for each loop iteration
    roleButtons[roleName] = CreateFrame("Button", nil, roleFrame, "UIPanelButtonTemplate")
    roleButtons[roleName]:SetWidth(200)
    roleButtons[roleName]:SetHeight(30)
    roleButtons[roleName]:SetPoint("TOP", roleFrame, "TOP", 0, -40 - (i-1)*40)
    roleButtons[roleName]:SetText(roleName)

    -- Set up button click event to set the selected role
    roleButtons[roleName]:SetScript("OnClick", function()
        -- Update the selectedRole variable
        selectedRole = roleName
        lrprint("Role selected: " .. selectedRole)

        -- Update the title of the number input frame to reflect the selected role
        numberInputTitle:SetText("Enter a number for " .. selectedRole)

        -- Hide the role frame and show the number input frame
        roleFrame:Hide()
        numberInputFrame:Show()
    end)
end

-- Define number input frame
numberInputTitle:SetPoint("TOP", numberInputFrame, "TOP", 0, -10)

-- Input field for number
local numberInputBox = CreateFrame("EditBox", nil, numberInputFrame, "InputBoxTemplate")
-- Define field for number
numberInputBox:SetWidth(200)
numberInputBox:SetHeight(30)
numberInputBox:SetPoint("TOP", numberInputFrame, "TOP", 0, -50)
numberInputBox:SetAutoFocus(false)
numberInputBox:SetMaxLetters(3)
numberInputBox:SetNumeric(true)
numberInputBox:SetText("Enter Number")

-- Set up the confirm button
local confirmButton = CreateFrame("Button", nil, numberInputFrame, "UIPanelButtonTemplate")
confirmButton:SetWidth(200)
confirmButton:SetHeight(30)
confirmButton:SetPoint("TOP", numberInputFrame, "TOP", 0, -100)
confirmButton:SetText("Confirm")

-- Function to handle the trigger action on confirm button click
confirmButton:SetScript("OnClick", function()
    local number = tonumber(numberInputBox:GetText())  -- Get the number from the input box

    -- Check if number is valid
    if number then
        print("Role: " .. selectedRole .. ", Number: " .. number)
        isDisabled=false
        numberInputFrame:Hide()
    else
        print("Please enter a valid number.")
    end
end)

stratFrame:Hide()
roleFrame:Hide()
numberInputFrame:Hide()
imageFrame:Hide()

---
--test section
-- Create the main frame
local myFrame = CreateFrame("Frame", "MyMovableFrame", UIParent)
myFrame:SetWidth(200)      -- Set the width of the frame
myFrame:SetHeight(100)     -- Set the height of the frame
myFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
myFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})

-- Enable mouse input
myFrame:EnableMouse(true)

-- Initially set the frame to be non-movable
myFrame:SetMovable(false)

-- Create a small button in the top-right corner of the frame
local toggleButton = CreateFrame("Button", "ToggleMovableButton", myFrame, "UIPanelButtonTemplate")
toggleButton:SetWidth(20)     -- Small width
toggleButton:SetHeight(20)    -- Small height
toggleButton:SetPoint("TOPRIGHT", myFrame, "TOPRIGHT", -5, -5) -- Position at top-right corner

-- Function to update button color and frame movability
local function UpdateButtonAndFrameState()
    if myFrame:IsMovable() then
        toggleButton:SetBackdropColor(0, 1, 0, 1) -- Green for movable
        toggleButton:SetText("M")
        myFrame:RegisterForDrag("LeftButton")      -- Enable dragging when movable
    else
        toggleButton:SetBackdropColor(1, 0, 0, 1) -- Red for unmovable
        toggleButton:SetText("U")
        myFrame:RegisterForDrag()                  -- Disable dragging
    end
end

-- Set up button click event to toggle movability
toggleButton:SetScript("OnClick", function()
    if myFrame:IsMovable() then
        myFrame:SetMovable(false)     -- Make the frame unmovable
    else
        myFrame:SetMovable(true)      -- Make the frame movable
    end
    UpdateButtonAndFrameState()       -- Update the button color and drag registration
end)

-- Set up frame dragging scripts
myFrame:SetScript("OnDragStart", function()
    if myFrame:IsMovable() then
        myFrame:StartMoving()
    end
end)

myFrame:SetScript("OnDragStop", function()
    myFrame:StopMovingOrSizing()
end)

-- Initial update of the button state
UpdateButtonAndFrameState()


myFrame:Hide()

---------------
-- EXECUTION --
---------------
SLASH_FHM1 = "/fhm"
SlashCmdList["FHM"] = function(cmd)
    if cmd then
        cmd = trim(cmd)
        if cmd == 'help' or cmd =='h' then
            fhm:PrintHelp()
        elseif cmd == 'enable' then
            isDisabled=false
        elseif cmd == 'disable' then
            isDisabled=true
        elseif cmd == 'reset' then
            ResetFramesToInitialPosition()
            lrprint("Frames reset to their initial positions.")
        elseif cmd == 'test' then
            imageFrame:Show()
            --myFrame:Show()
        elseif cmd == 'config' or cmd == '' then
            stratFrame:Show()
        else
            lrprint("Unknown command : " .. cmd)
            fhm:PrintHelp()
        end
    else
        roleFrame:Show()
    end
end

-- Register event handlers
fhm:SetScript("OnEvent", function(self, event, ...)
    if isDisabled then
        -- do nothing
        --lrprint("fhm is disabled.")
    else
        loadstring([[if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            OnCombatLogEvent(self, event, ...)
        elseif event == "UNIT_HEALTH" then
            local unit = ...
            OnHealthEvent(self, event, unit)
        end]])()

    end
end)


