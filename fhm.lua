---------------
-- CONSTANTS --
---------------
local fhm = CreateFrame("Frame", "fhm", GameTooltip)
fhm:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
fhm:RegisterEvent("UNIT_HEALTH")
-- fhm:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
-- fhm:RegisterEvent("CHAT_MSG_WHISPER")
-- fhm:RegisterEvent("CHAT_MSG_SYSTEM")
-- fhm:RegisterEvent("ADDON_LOADED")
-- fhm:RegisterEvent("CHAT_MSG_LOOT")
fhm.Player = ''
fhm.Item = ''
fhm.Name = ''
---------------
-- VARIABLES --
---------------

local raids = 'Naxxramas'

local is6TanksStrat=false

local isTank=false
local isHeal=false
local isDPS=false
local isExtra=false

local isRangedDPS=false

local iAmNumber=0
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

-- Configure
function fhm:Configure()
    --getglobal('LootResLoadFromTextTextBox'):SetText("")
    getglobal('fhmConfigFrameStrat'):Show()
end


function SelectedStrat6Tanks()
    getglobal('fhmConfigFrameStrat'):Hide()
    is6TanksStrat=true
    lrprint("You selected 6 tank strat.")
    getglobal('fhmConfigFrameRole'):Show()
end

function SelectedStrat8Tanks()
    getglobal('fhmConfigFrameStrat'):Hide()
    is6TanksStrat=false
    lrprint("You selected 8 tank strat.")
    getglobal('fhmConfigFrameRole'):Show()
end

function toAttributedNumber()
    --todo name of the global to set text
    getglobal('fhmConfigFrameAttributedNumberTextBox'):SetText("")
    getglobal('fhmConfigFrameAttributedNumber'):Show()
end

function SelectedRoleTank()
    getglobal('fhmConfigFrameRole'):Hide()
    isTank=true
    isHeal=false
    isDPS=false
    isExtra=false
    lrprint("You selected the role : TANK.")
    toAttributedNumber()
end

function SelectedRoleHeal()
    getglobal('fhmConfigFrameRole'):Hide()
    isTank=false
    isHeal=true
    isDPS=false
    isExtra=false
    lrprint("You selected the role : HEAL.")
    toAttributedNumber()
end

function SelectedRoleDPS()
    getglobal('fhmConfigFrameRole'):Hide()
    isTank=false
    isHeal=false
    isDPS=true
    isExtra=false
    lrprint("You selected the role : DPS.")
    getglobal('fhmConfigFrameRoleDPS'):Show()
end

function SelectedRoleRangedDPS()
    getglobal('fhmConfigFrameRoleDPS'):Hide()
    isRangedDPS = true
    lrprint("You selected the role : ranged DPS.")
    toAttributedNumber()
end

function SelectedRoleMeleeDPS()
    getglobal('fhmConfigFrameRoleDPS'):Hide()
    isRangedDPS = false
    lrprint("You selected the role : melee DPS.")
    toAttributedNumber()
end

function SelectedAttributedNumber()
    getglobal('fhmConfigFrameAttributedNumber'):Hide()
    iAmNumber = getglobal('fhmConfigFrameAttributedNumberTextBox'):GetText()
    if isNumber(iAmNumber) then
        lrprint("You selected the attributed role number : " .. iAmNumber)
        --todo : what s next
    else
        lrprint("You wrote someting else than a number : " .. iAmNumber)
        toAttributedNumber()
    end

end

---------------
-- EXECUTION --
---------------
SLASH_FHM1 = "/fhm"
SlashCmdList["FHM"] = function(cmd)
    if cmd then
        cmd = trim(cmd)
        if cmd == 'help' or cmd =='h' then
            fhm:PrintHelp()
        end
        if cmd == 'enable' then
            isDisabled=false
        end
        if cmd == 'disable' then
            isDisabled=true
        end
        if cmd == 'config' or cmd == '' then
            fhm:Configure()
        else
            lrprint("Unknown command : " .. cmd)
            fhm:PrintHelp()
        end
    end
end

-- Register event handlers
fhm:SetScript("OnEvent", function(self, event, ...)
    if isDisabled then
        -- do nothing
        lrprint("fhm is disabled.")
    else
        loadstring([[if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            OnCombatLogEvent(self, event, ...)
        elseif event == "UNIT_HEALTH" then
            local unit = ...
            OnHealthEvent(self, event, unit)
        end]])()

    end
end)