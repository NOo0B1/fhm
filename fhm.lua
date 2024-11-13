---------------
-- CONSTANTS --
---------------
local fhm = CreateFrame("Frame", "fhm", GameTooltip)

fhm:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
fhm:RegisterEvent("CHAT_MSG_WHISPER")
fhm:RegisterEvent("CHAT_MSG_SYSTEM")
fhm:RegisterEvent("ADDON_LOADED")
fhm:RegisterEvent("CHAT_MSG_LOOT")
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

local isNumber=0

---------------
-- FUNCTIONS --
---------------
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



function fhm:PrintHelp()

    lrprint("This is the help message for the addon fhm from Cromsson.")

    lrprint("Type /fhm help or /fhm h to display this function")
    lrprint("Type /fhm disable to disable this addon.")
    lrprint("Type /fhm enable to activate this addon.")
    lrprint("Type /fhm config to configure this addon.")
end

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
    isNumber = getglobal('fhmConfigFrameAttributedNumberTextBox'):GetText()
    lrprint("You selected the attributed role number : " .. isNumber)
end

---------------
-- EXECUTION --
---------------
SLASH_FHM1 = "/fhm"
SlashCmdList["FHM"] = function(cmd)
    if cmd then
        if cmd == 'help' or 'h' then
            fhm:PrintHelp()
        end
        if cmd == 'enable' then
            --LootRes:PrintReserves()
        end
        if cmd == 'disable' then
            --LootRes:PrintReserves()
        end
        if cmd == 'config' then
            fhm:Configure()
        end

    end
end