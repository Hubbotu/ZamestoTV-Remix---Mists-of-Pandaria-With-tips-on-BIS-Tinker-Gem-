local L = {}
local locale = GetLocale()

-- English localization
L["enUS"] = {
    ADDON_NAME = "ZamestoTV: Remix",
    OPENING_ITEM = "Opening item - ",
    ENABLED = "Auto open Enabled",
    DISABLED = "Auto open Disabled"
}

-- Russian localization
L["ruRU"] = {
    ADDON_NAME = "ZamestoTV: Remix",
    OPENING_ITEM = "Открываем сундук - ",
    ENABLED = "Автооткрытие Включено",
    DISABLED = "Автооткрытие Выключено"
}

-- Fall back to English if the locale isn't directly supported
setmetatable(L, { __index = function(t, k) return t["enUS"] end })
local Loc = L[locale] or L["enUS"]

local openableIDs = {
    [211279] = true, -- Cache of Infinite Treasure
    [211932] = true, -- Cache of Infinite Treasure
    [223908] = true, -- Minor Bronze Cache
    [223909] = true, -- Lesser Bronze Cache
    [223910] = true, -- Bronze Cache
    [223911] = true, -- Greater Bronze Cache
}

-- Declare the saved variable
local openableScanEnabled = false
local openableScanQueued = false

local function OpenableScan()
    if not openableScanEnabled then
        return
    end
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and openableIDs[info.itemID] and not info.isLocked then
                C_Container.UseContainerItem(bag, slot)
                local itemName = C_Item.GetItemNameByID(info.itemID) or "Unknown"
                print("[" .. Loc.ADDON_NAME .. "] " .. Loc.OPENING_ITEM .. itemName)
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("VARIABLES_LOADED")

frame:SetScript("OnEvent", function(self, event)
    if event == "BAG_UPDATE_DELAYED" then
        if not InCombatLockdown() then
            OpenableScan()
        else
            openableScanQueued = true
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if openableScanQueued then
            openableScanQueued = false
            OpenableScan()
        end
    elseif event == "VARIABLES_LOADED" then
        if ZorROpenableScanEnabled ~= nil then
            openableScanEnabled = ZorROpenableScanEnabled
        end
        local status = openableScanEnabled and Loc.ENABLED or Loc.DISABLED
        print("[" .. Loc.ADDON_NAME .. "] " .. status)
    end
end)

-- Add slash command to enable or disable OpenableScan
SLASH_ZORR1 = "/zorr"
SlashCmdList["ZORR"] = function()
    openableScanEnabled = not openableScanEnabled
    ZorROpenableScanEnabled = openableScanEnabled -- Save the state
    local status = openableScanEnabled and Loc.ENABLED or Loc.DISABLED
    print("[" .. Loc.ADDON_NAME .. "] " .. status)
end
