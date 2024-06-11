local LocaleData = {
    ["enUS"] = {
        known = "already known",
        allianceOnly = "alliance only",
        hordeOnly = "horde only",
        Horos = "Horos",
        Larah_Treebender = "Larah Treebender",
        Aeonicus = "Aeonicus",
        Durus = "Durus",
        Arturos = "Arturos",
        Pythagorus = "Pythagorus"
    },
    ["ruRU"] = {
        known = "Известно",
        allianceOnly = "Только для Альянса",
        hordeOnly = "Только для Орды",
        Horos = "Горос",
        Larah_Treebender = "Лара Мощь Древа",
        Aeonicus = "Эоник",
        Durus = "Дур",
        Arturos = "Артурий",
        Pythagorus = "Пифагор"
    }
}

local function GetText(key)
    local currentLocale = GetLocale()
    return (LocaleData[currentLocale] and LocaleData[currentLocale][key]) or LocaleData["enUS"][key]
end

local transmogs = {}
transmogs.cached = transmogs.cached or {}

local DressUpTracker = CreateFrame("Frame", "DressUpTracker", UIParent)
DressUpTracker:SetSize(1, 1)
DressUpTracker:EnableMouse(false)
DressUpTracker:Hide()

local redHighlight = {}

local function HighlightButtonRed(button)
    if button then
        SetItemButtonTextureVertexColor(button, 0.9, 0, 0)
        SetItemButtonNormalTextureVertexColor(button, 0.9, 0, 0)
    end
end

local function HighlightAllRedButtons()
    for _, buttonInfo in ipairs(redHighlight) do
        if buttonInfo.page == MerchantFrame.page then
            HighlightButtonRed(buttonInfo.button)
        end
    end
end

local function IsTransmogKnown(itemLink)
    local tooltip = CreateFrame("GameTooltip", "TransmogTooltip", nil, "GameTooltipTemplate")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(itemLink)
    
    local tooltipContent = ""
    local numLines = tooltip:NumLines()
    for i = 1, numLines do
        local line = _G["TransmogTooltipTextLeft" .. i]
        if line then
            tooltipContent = tooltipContent .. line:GetText() .. "\n"
        end
    end
    
    C_Timer.After(0.1, function()
        tooltip:Hide()
    end)
    
    local knownText = GetText("known")
    local allianceText = GetText("allianceOnly")
    local hordeText = GetText("hordeOnly")
    
    if tooltipContent and (string.find(string.lower(tooltipContent), knownText) or 
                           string.find(string.lower(tooltipContent), allianceText) or 
                           string.find(string.lower(tooltipContent), hordeText)) then
        return true
    end
    
    return false
end

local function ValidateTransmog(itemLink, slot, callback)
    local itemName = C_Item.GetItemInfo(itemLink)
    local known = false
    
    if not transmogs.cached[itemName] then
        local currentTarget = UnitName("target")
        if IsTransmogKnown(itemLink) then
            transmogs.cached[itemName] = slot
            known = true
            callback(known)
            return
        elseif currentTarget == GetText("Horos") then
            known = false
            callback(known)
            return
        end
        
        local itemID = GetItemInfoInstant(itemLink)
        
        if itemID then
            DressUpFrame:Show()
            DressUpTracker:Hide()
            DressUpItemLink(itemLink)
            
            C_Timer.After(0.2, function()
                local scrollBox = DressUpFrame.SetSelectionPanel.ScrollBox.ScrollTarget
                local children = {scrollBox:GetChildren()}
                local knownCount = 0
                local unknownCount = 0
                
                for _, child in ipairs(children) do
                    local elementData = child.itemID
                    if elementData then
                        if C_TransmogCollection.PlayerHasTransmog(elementData) then
                            knownCount = knownCount + 1
                        else
                            unknownCount = unknownCount + 1
                        end
                    end
                end
                
                if knownCount > unknownCount then
                    transmogs.cached[itemName] = slot
                    known = true
                end
                
                DressUpFrame:Hide()
                callback(known)
            end)
        else
            callback(known)
        end
    else
        callback(true)
    end
end

local processedItems = {}
local function ProcessMerchantItems()
    HighlightAllRedButtons()
    C_Timer.After(0.5, function()
        local currentTarget = UnitName("target")
        if currentTarget == GetText("Larah_Treebender") or 
           currentTarget == GetText("Aeonicus") or 
           currentTarget == GetText("Horos") or 
           currentTarget == GetText("Durus") or 
           currentTarget == GetText("Arturos") or 
           currentTarget == GetText("Pythagorus") then
            for i = 1, 10 do
                local itemIndex = (((MerchantFrame.page - 1) * 10) + i)
                local itemLink = GetMerchantItemLink(itemIndex)
                if itemLink and not processedItems[itemLink] then
                    processedItems[itemLink] = true
                    ValidateTransmog(itemLink, i, function(known)
                        if known then
                            table.insert(redHighlight, {button = _G["MerchantItem"..i.."ItemButton"], page = MerchantFrame.page})
                            HighlightAllRedButtons()
                        end
                    end)
                end
            end
        end
    end)
end

local function OnMerchantEvent(self, event, ...)
    if event == "MERCHANT_SHOW" then
        ProcessMerchantItems()
    elseif event == "MERCHANT_CLOSED" then
        processedItems = {}
        redHighlight = {}
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MERCHANT_SHOW")
eventFrame:RegisterEvent("MERCHANT_CLOSED")
eventFrame:SetScript("OnEvent", OnMerchantEvent)

hooksecurefunc("MerchantFrame_Update", function()
    C_Timer.After(0.1, function()
        ProcessMerchantItems()
    end)
end)

local function MerchantMouseWheelHandler(self, delta)
    if delta > 0 then
        if MerchantPrevPageButton:IsShown() and MerchantPrevPageButton:IsEnabled() then
            MerchantPrevPageButton_OnClick()         
        end
    else
        if MerchantNextPageButton:IsShown() and MerchantNextPageButton:IsEnabled() then
            MerchantNextPageButton_OnClick()           
        end
    end
end

MerchantFrame:EnableMouseWheel(true)
MerchantFrame:SetScript("OnMouseWheel", MerchantMouseWheelHandler)