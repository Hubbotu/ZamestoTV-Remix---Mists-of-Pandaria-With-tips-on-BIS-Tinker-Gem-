local DragonflightAddon = CreateFrame("Frame", "DragonflightAddonFrame", UIParent)
DragonflightAddon:RegisterEvent("PLAYER_LOGIN")
DragonflightAddon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DragonflightAddon:RegisterEvent("PLAYER_MONEY")
DragonflightAddon:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
DragonflightAddon:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        return self[event](self, ...)
    end
end)

-- Localization table for English
local L = {
    ["CURRENT_TIER"] = "Current Tier:",
    ["NEXT_TIER"] = "Next Tier:",
    ["BELOW_346"] = "Current Tier is below 346",
    ["BRONZE_TO_NEXT_TIER"] = "Bronze to next tier: ",
    ["NO_BRONZE_NEEDED"] = "No bronze needed for next tier",
    ["GEAR_COST_INFO_TOTAL"] = "Gear Cost Info: Total Cost = ",
    ["GEAR_COST_INFO_MIN"] = "Min Cost = ",
    ["GEAR_COST_INFO_LEVELS"] = "You can improve your equipment ",
    ["GEAR_COST_INFO_PLAYER_BRONZE"] = "Player Bronze = ",
    ["MINUSA"] = "before itemlevel "
}

-- Localization table for Russian
local L_ru = {
    ["CURRENT_TIER"] = "Текущий уровень:",
    ["NEXT_TIER"] = "Следующий уровень:",
    ["BELOW_346"] = "Текущий уровень ниже 346",
    ["BRONZE_TO_NEXT_TIER"] = "Бронзы к следующему уровню: ",
    ["NO_BRONZE_NEEDED"] = "Бронзы не требуется для следующего уровня",
    ["GEAR_COST_INFO_TOTAL"] = "Информация о стоимости экипировки: Общая стоимость = ",
    ["GEAR_COST_INFO_MIN"] = "Минимальная стоимость = ",
    ["GEAR_COST_INFO_LEVELS"] = "Можно улучшить ",
    ["GEAR_COST_INFO_PLAYER_BRONZE"] = "Всего Бронзы = ",
    ["MINUSA"] = "до уровня "
}

-- Choose the active localization table based on the game client language
local activeLocalization = GetLocale() == "ruRU" and L_ru or L

local Eqp = {
    {["slot"]="HEADSLOT",          ["cost"]=4500, ["level"]=0},
    {["slot"]="CHESTSLOT",         ["cost"]=4500, ["level"]=0},
    {["slot"]="LEGSSLOT",          ["cost"]=4500, ["level"]=0},
    {["slot"]="MAINHANDSLOT",      ["cost"]=4500, ["level"]=0},
    {["slot"]="SECONDARYHANDSLOT", ["cost"]=4500, ["level"]=0},
    {["slot"]="SHOULDERSLOT",      ["cost"]=3375, ["level"]=0},
    {["slot"]="HANDSSLOT",         ["cost"]=3375, ["level"]=0},
    {["slot"]="FEETSLOT",          ["cost"]=3375, ["level"]=0},
    {["slot"]="WAISTSLOT",         ["cost"]=3375, ["level"]=0},
    {["slot"]="WRISTSLOT",         ["cost"]=2530, ["level"]=0}
}

function DragonflightAddon:CalculateGearCosts()
    local playerBronze = C_CurrencyInfo.GetCurrencyInfo(2778).quantity
    local lvlMin, lvlMax, costMin = 1000, 0, 9000

    for i, row in ipairs(Eqp) do
        local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(row.slot))
        if itemLink then
            local _, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
            Eqp[i].level = itemLevel
            if itemEquipLoc == "INVTYPE_2HWEAPON" then
                Eqp[i].cost = 2 * Eqp[i].cost
            end
            lvlMin = math.min(lvlMin, itemLevel or lvlMin)
            lvlMax = math.max(lvlMax, itemLevel or lvlMax)
        else
            Eqp[i].cost = 0
            Eqp[i].level = 0
        end
    end

    for i, row in ipairs(Eqp) do
        if row.level == lvlMin then
            costMin = math.min(costMin, row.cost)
        end
    end

    local totalCost = 0
    if lvlMin == lvlMax then
        for _, row in ipairs(Eqp) do
            totalCost = totalCost + row.cost
        end
    else
        for _, row in ipairs(Eqp) do
            if row.level ~= lvlMax then
                totalCost = totalCost + row.cost
            end
        end
    end

    return totalCost, costMin, lvlMin, lvlMax, playerBronze
end

function DragonflightAddon:PLAYER_LOGIN()
    -- Do nothing on login for now
end

function DragonflightAddon:PLAYER_EQUIPMENT_CHANGED()
    -- Do nothing on equipment change for now
end

function DragonflightAddon:PLAYER_MONEY()
    -- Do nothing on money change for now
end

function DragonflightAddon:CURRENCY_DISPLAY_UPDATE()
    -- Do nothing on currency update for now
end

local lvls = {
    [346] = 360,
    [360] = 374,
    [374] = 388,
    [388] = 402,
    [402] = 416,
    [416] = 430,
    [430] = 444,
    [444] = 458,
    [458] = 472,
    [472] = 486,
    [486] = 500,
    [500] = 514,
    [514] = 528,
    [528] = 542,
    [542] = 556,
}

local function addCommas(input)
    local num = tonumber(input)
    local numst = tostring(num)
    local buildst = ""
    local len = #tostring(math.floor(num))
    local ncom = math.ceil(len / 3) - 1
    local offset = ((len - 1) % 3) + 1
    local st, nd, tail = 0, 0, ""
    
    if ncom > 0 then
        for n = 1, ncom do
            st = math.max(3 * n - 5 + offset, 1)
            nd = math.max(3 * n - 3 + offset, 1)
            buildst = buildst .. strsub(numst, st, nd) .. ","
        end
        tail = strsub(numst, nd + 1)
        buildst = buildst .. tail
        return buildst
    else
        return numst
    end
end

local function GetBronzeToNextTierInfo(totalCost)
    local playerBronze = C_CurrencyInfo.GetCurrencyInfo(2778).quantity
    local bronzeNeeded = totalCost - playerBronze
    if bronzeNeeded > 0 then
        return activeLocalization["BRONZE_TO_NEXT_TIER"] .. addCommas(bronzeNeeded)
    else
        return activeLocalization["NO_BRONZE_NEEDED"]
    end
end

local function DisplayGearInfo()
    local totalCost, costMin, lvlMin, lvlMax, playerBronze = DragonflightAddon:CalculateGearCosts()
    if lvlMin >= 346 then
        print(activeLocalization["CURRENT_TIER"], lvlMin)
        print(activeLocalization["NEXT_TIER"], lvls[lvlMin])
        print(GetBronzeToNextTierInfo(totalCost))
    else
        print(activeLocalization["BELOW_346"])
    end
    print(activeLocalization["GEAR_COST_INFO_TOTAL"], totalCost, activeLocalization["GEAR_COST_INFO_MIN"], costMin, activeLocalization["GEAR_COST_INFO_LEVELS"], lvlMin, activeLocalization["MINUSA"], lvlMax, activeLocalization["GEAR_COST_INFO_PLAYER_BRONZE"], playerBronze)
end

-- Register the slash command
SLASH_DRAGONFLIGHTADDON1 = "/dumm"
SlashCmdList["DRAGONFLIGHTADDON"] = function()
    DisplayGearInfo()
end
