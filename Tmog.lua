local addonName, addon = ...

-- Localization table
local L = {
    enUS = {
        COLLECTION_COMPLETE = "In the collection.",
        MISSING_ITEMS = "Missing",
        ITEMS = "items."
    },
    ruRU = {
        COLLECTION_COMPLETE = "В коллекции.",
        MISSING_ITEMS = "Отсутствуют",
        ITEMS = "пред."
    }
}

-- Default to English if locale is not explicitly handled
local locale = GetLocale() or "enUS"
local localizedStrings = L[locale] or L["enUS"]

addon.GetInfo = function()
    local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
    
    local slotIDs = {}
    for slotID = 1, 19 do
        local currentSlotInfo = playerActor:GetItemTransmogInfo(slotID)
        if currentSlotInfo then
            local slotInfo = {
                appearanceID = currentSlotInfo.appearanceID,
                secondaryAppearanceID = currentSlotInfo.secondaryAppearanceID
            }
            table.insert(slotIDs, slotInfo)
        end
    end
    
    local allKnown = true
    local missingItems = {}
    
    for _, value in ipairs(slotIDs) do
        local appearanceID = value.appearanceID
        if appearanceID and appearanceID ~= 0 and appearanceID > 1 then
            local sourceInfo = { C_TransmogCollection.GetAppearanceSourceInfo(appearanceID) }
            if not sourceInfo[5] then
                allKnown = false
                local itemString = sourceInfo[6] or "Unknown Item"
                local modifiedAppearanceID = sourceInfo[2]
                local modified = sourceInfo[9]
                local modifiedString = modified and "Modified" or "Unmodified"
                table.insert(missingItems,
                    { appearanceID = modifiedAppearanceID, itemName = itemString, modified = modifiedString, modifiedAppearanceID =
                modifiedAppearanceID })
            end
        end
    end
    
    if allKnown then
        print(localizedStrings.COLLECTION_COMPLETE)
    else
        print(localizedStrings.MISSING_ITEMS .. " " .. #missingItems .. " " .. localizedStrings.ITEMS)
        -- for _, item in ipairs(missingItems) do
        --     print("Modified Appearance ID:", item.modifiedAppearanceID, "Item:", item.itemName, "Modified:", item.modified)
        -- end
    end
end

local function DressUpFrameShow(...)
    if MerchantFrame:IsVisible() then
        local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
        playerActor:Undress()
        C_Timer.After(0.2, function() addon.GetInfo() end)
    end
end

hooksecurefunc("DressUpFrame_Show", DressUpFrameShow)

