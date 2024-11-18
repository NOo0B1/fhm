---------------
-- CONSTANTS --
---------------
local fhm = CreateFrame("Frame", "fhm", GameTooltip)
fhm:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
fhm:RegisterEvent("UNIT_HEALTH")

---------------
-- VARIABLES --
---------------

local markNum=1
currentSpotTobeFHM=""

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

local spotTable ={"Safespot","Thane","Mograine","Zeliek","Blaumeux"}

-- Define the 2D array with additional columns "6 TANKS" and "TANK" at the start of each row
local marksTable = {
    { "6 Tanks", "Tank", 1, "Safespot", "Thane", "Safespot","Zeliek","Thane" },
    { "6 Tanks", "Tank", 2, "Mograine", "Zeliek", "Zeliek", "Zeliek", "Blaumeux", "Blaumeux", "Blaumeux", "Safespot", "Safespot", "Safespot", "Mograine", "Mograine", "Mograine" },
    { "6 Tanks", "Tank", 3, "Zeliek", "Zeliek", "Blaumeux", "Blaumeux", "Blaumeux", "Safespot", "Safespot", "Safespot", "Mograine", "Mograine", "Mograine", "Zeliek", "Zeliek" },
    { "6 Tanks", "Tank", 4, "Blaumeux", "Mograine", "Mograine", "Mograine", "Zeliek", "Zeliek", "Zeliek", "Blaumeux", "Blaumeux", "Blaumeux", "Safespot", "Safespot", "Safespot" },
    { "6 Tanks", "Tank", 5, "Safespot", "Mograine", "Mograine", "Zeliek", "Zeliek", "Zeliek", "Blaumeux", "Blaumeux", "Blaumeux", "Safespot", "Safespot", "Safespot", "Mograine" },
    { "6 Tanks", "Tank", 6, "Safespot", "Blaumeux", "Blaumeux", "Safespot", "Safespot", "Safespot", "Mograine", "Mograine", "Mograine", "Zeliek", "Zeliek", "Zeliek", "Blaumeux" }
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
function ResetFramesToInitialPosition()
    for _, frameInfo in ipairs(customFrames) do
        local frame = frameInfo.frame
        local initialPoint = frameInfo.initialPoint
        frame:ClearAllPoints()
        frame:SetPoint(unpack(initialPoint))
    end
end

-- Function to add an image texture to a frame
function AddImageToFrame(frame, texturePath)
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(texturePath)
    return texture
end

local function stopshit()
    markNum=0
    isEncounterStarted=false;
    stratFrame:Hide()
    roleFrame:Hide()
    numberInputFrame:Hide()
    imageFrameInit:Hide()
    imageFrameBlaumeux:Hide()
    imageFrameSafe:Hide()
    imageFrameMograine:Hide()
    imageFrameThane:Hide()
    imageFrameZeliek:Hide()
end

-- Function to find and return the data based on the four arguments
local function getMarkData(strat, role, attributedNumber, numberOfMarkTotal)
    local countProvider=0
    -- Iterate through the marksTable to find the matching row
    for _, row in ipairs(marksTable) do
        countProvider=countProvider+1
        -- Check if the values in the first, second, and third columns match the arguments
        if row[1] == strat and row[2] == role and row[3] == attributedNumber then
            
            -- Return the value in the column specified by the fourth argument (arg4)
            -- Make sure to check if the column number (arg4) is within bounds
            numberOfMarkTotal=numberOfMarkTotal+3
            -- Count the number of columns in the current row
            local columnCount = 0
            for _ in pairs(row) do
                columnCount = columnCount + 1
            end
            if numberOfMarkTotal >= 1 and numberOfMarkTotal <= columnCount then
                return row[numberOfMarkTotal]
            else
                stopshit()
                return "Column number out of bounds."
            end
        end
    end

    if  countProvider==0 then
        lrprint("test3")
        stopshit()
        return "No matching row found."
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
    { name = "imageFrameInit", title = "", width = 256, height = 256 },
    { name = "imageFrameBlaumeux", title = "", width = 256, height = 256 },
    { name = "imageFrameMograine", title = "", width = 256, height = 256 },
    { name = "imageFrameSafe", title = "", width = 256, height = 256 },
    { name = "imageFrameThane", title = "", width = 256, height = 256 },
    { name = "imageFrameZeliek", title = "", width = 256, height = 256 },
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

-- Add textures to frames using the function
local imageTextures = {
    { frame = imageFrameInit, texturePath = "Interface\\AddOns\\fhm\\fhpositions_256x256_32bit_alpha_Init.tga" },
    { frame = imageFrameBlaumeux, texturePath = "Interface\\AddOns\\fhm\\fhpositions_256x256_32bit_alpha_Blaumeux.tga" },
    { frame = imageFrameMograine, texturePath = "Interface\\AddOns\\fhm\\fhpositions_256x256_32bit_alpha_Mograine.tga" },
    { frame = imageFrameSafe, texturePath = "Interface\\AddOns\\fhm\\fhpositions_256x256_32bit_alpha_Safe.tga" },
    { frame = imageFrameThane, texturePath = "Interface\\AddOns\\fhm\\fhpositions_256x256_32bit_alpha_Thane.tga" },
    { frame = imageFrameZeliek, texturePath = "Interface\\AddOns\\fhm\\fhpositions_256x256_32bit_alpha_Zeliek.tga" },
}

-- Iterate through the table to set up textures
for _, config in ipairs(imageTextures) do
    AddImageToFrame(config.frame, config.texturePath)
end

-- Title for the number input frame
local numberInputTitle = numberInputFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

-- Title of the frame
local stratTitle = stratFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
stratTitle:SetPoint("TOP", stratFrame, "TOP", 0, -10)
stratTitle:SetText("Choose Your Strat")

-- Strat selection buttons
local strats = {"6 Tanks", "8 Tanks"}
local stratButtons = {}
selectedStratFHM = ""

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
        -- Update the selectedStratFHM variable
        selectedStratFHM = stratName
        lrprint("Strat selected: " .. selectedStratFHM)

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
selectedRoleFHM = ""

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
        -- Update the selectedRoleFHM variable
        selectedRoleFHM = roleName
        lrprint("Role selected: " .. selectedRoleFHM)

        -- Update the title of the number input frame to reflect the selected role
        numberInputTitle:SetText("Enter a number for " .. selectedRoleFHM)

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

numberFHM=nil
-- Function to handle the trigger action on confirm button click
confirmButton:SetScript("OnClick", function()
    numberFHM = tonumber(numberInputBox:GetText())  -- Get the number from the input box

    -- Check if number is valid
    if numberFHM then
        print("Strat: ".. selectedStratFHM.. "Role: " .. selectedRoleFHM .. ", Number: " .. numberFHM)
        isDisabled=false
        numberInputFrame:Hide()
    else
        print("Please enter a valid number.")
    end
end)

stratFrame:Hide()
roleFrame:Hide()
numberInputFrame:Hide()
imageFrameInit:Hide()
imageFrameBlaumeux:Hide()
imageFrameSafe:Hide()
imageFrameMograine:Hide()
imageFrameThane:Hide()
imageFrameZeliek:Hide()

---
--test section


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
            markNum=0
            ResetFramesToInitialPosition()
            lrprint("Frames reset to their initial positions.")
            isEncounterStarted=false;
            stratFrame:Hide()
            roleFrame:Hide()
            numberInputFrame:Hide()
            imageFrameInit:Hide()
            imageFrameBlaumeux:Hide()
            imageFrameSafe:Hide()
            imageFrameMograine:Hide()
            imageFrameThane:Hide()
            imageFrameZeliek:Hide()
        elseif cmd == 'close' then
            stopshit()
        elseif cmd == 'test' then
            lrprint("selectedRoleFHM : " .. selectedRoleFHM ..",selectedStratFHM : " .. selectedStratFHM ..",numberFHM : " .. numberFHM )
            isDisabled=false
            StartEncounter()
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
    if not isDisabled and not isEncounterStarted then
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
             loadstring([[OnCombatLogEvent(self, event, ...)]])()
        elseif event == "UNIT_HEALTH" then
             loadstring([[local unit = ...]])()
            OnHealthEvent(self, event, unit)
        end
    end
end)



local framePairs = {
    { "Blaumeux", imageFrameBlaumeux },
    { "Zeliek", imageFrameZeliek },
    { "Mograine", imageFrameMograine },
    { "Thane", imageFrameThane },
    { "Safespot", imageFrameSafe },
}

local function getBytes(s)
    local bytes = {}



    for i = 1, string.len(s) do
        table.insert(bytes, string.byte(s, i))
    end
    return table.concat(bytes, " ")
end

local countFHM=0
-- Function to print a log message for the 1-second timer
local function printLog1Sec()
 --lrprint("countFHM : " .. countFHM)
--  lrprint("printLog1Sec isEncounterStarted : " .. tostring(isEncounterStarted))
--  lrprint("print1sec : " .. selectedStratFHM .. " , ".. selectedRoleFHM.. " , "..numberFHM.. " , "..markNum)
    if currentSpotTobeFHM=="" then
        currentSpotTobeFHM=getMarkData(selectedStratFHM, selectedRoleFHM,numberFHM,markNum)
    end
    --DEFAULT_CHAT_FRAME:AddMessage("Log printed every 0.5 seconds! markNum= " .. markNum)
   -- DEFAULT_CHAT_FRAME:AddMessage("currentSpotTobeFHM = " .. currentSpotTobeFHM)
    for _, row in ipairs(framePairs) do        
        if row[1] == currentSpotTobeFHM then
            --lrprint("row 1: " .. row[1] .. "   row2: " .. row[2]:GetName())
            imageFrameInit:Hide()
            imageFrameBlaumeux:Hide()
            imageFrameSafe:Hide()
            imageFrameMograine:Hide()
            imageFrameThane:Hide()
            imageFrameZeliek:Hide()
            if countFHM==0 then
                row[2]:Show()
                countFHM=countFHM+1
            else
                imageFrameInit:Show()
                countFHM=0
            end

        end
    end

end

-- Function to print a log message for the 15-second timer
local function printLog15Sec()
    markNum=markNum+1
    -- lrprint("printLog15Sec isEncounterStarted : " .. tostring(isEncounterStarted))

    currentSpotTobeFHM=getMarkData(selectedStratFHM, selectedRoleFHM,numberFHM,markNum)
    --DEFAULT_CHAT_FRAME:AddMessage("Log printed every 15 seconds! markNum= " .. markNum .. " and currentSpotTobeFHM = " .. currentSpotTobeFHM)
    --lrprint("print15sec : " .. selectedStratFHM .. " , ".. selectedRoleFHM.. " , "..numberFHM.. " , "..markNum)
    --lrprint("currentSpotTobeFHM: "..getMarkData(selectedStratFHM, selectedRoleFHM,numberFHM,markNum))

end

-- Initialize the start times
local lastTime1Sec = GetTime()  -- For 1-second timer
local lastTime15Sec = GetTime()  -- For 15-second timer
-- local countfhm=0
-- Timer function to call the log functions every 1 and 15 seconds
fhm:SetScript("OnUpdate", function(self)
    -- if not numberFHM then
    --     numberFHM=0
    -- end
    -- if countfhm==0 then
    --     lrprint("countfhm 0 isEncounterStarted : " .. tostring(isEncounterStarted))
    -- end
    -- if countfhm==1 then
    --     lrprint("countfhm 1 isEncounterStarted : " .. tostring(isEncounterStarted))
    --     countfhm=countfhm+1
    -- end
    if isEncounterStarted and not isDisabled then
        -- countfhm=countfhm+1
        local currentTime = GetTime()  -- Get the current game time

        -- Check if 1 second has passed
        if currentTime - lastTime1Sec >= 2 then
            printLog1Sec()  -- Call the function to print the 1-second log message
            lastTime1Sec = currentTime  -- Update lastTime1Sec to the current time
        end
    
        -- Check if 15 seconds have passed
        if currentTime - lastTime15Sec >= 15 then
            printLog15Sec()  -- Call the function to print the 15-second log message
            lastTime15Sec = currentTime  -- Update lastTime15Sec to the current time
        end
    end
end)
