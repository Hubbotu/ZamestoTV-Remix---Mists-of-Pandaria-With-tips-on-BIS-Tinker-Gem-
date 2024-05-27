-- Create the addon
local BronzeTracker = CreateFrame("Frame", "BronzeTrackerFrame", UIParent)

-- Initialize variables
local initialBronze = 0
local bronze = 0
local timestamps = {}
local startTime = 0
local BPH = 0
local sessionBronze = 0

-- Localization tables
local L = {
    enUS = {
        TOTAL_BRONZE = "Total bronze: ",
        BRONZE_PER_HOUR = "Bronze per hour: ",
        BRONZE_THIS_SESSION = "Bronze this session: ",
        BRONZE_TRACKER = "Bronze Tracker"
    },
    ruRU = {
        TOTAL_BRONZE = "Всего бронзы: ",
        BRONZE_PER_HOUR = "Бронзы в час: ",
        BRONZE_THIS_SESSION = "Бронзы за эту сессию: ",
        BRONZE_TRACKER = "Отслеживание бронзы"
    }
}

-- Set the default language to English
local lang = "enUS"

-- Function to set the language
local function SetLanguage(language)
    lang = language
end

-- Function to initialize variables
local function Initialize()
    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(2778)
    if currencyInfo then
        initialBronze = currencyInfo.quantity
        bronze = initialBronze
        timestamps = {}
        startTime = GetTime()
        BPH = 0
        sessionBronze = 0
    end
end

-- Function to update bronze and BPH
local function UpdateBronze()
    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(2778)
    if currencyInfo then
        bronze = currencyInfo.quantity
        sessionBronze = bronze - initialBronze

        if bronze == initialBronze then
            BPH = 0
            return
        end

        local currentTime = GetTime()
        table.insert(timestamps, currentTime)

        local cutoffTime = currentTime - 300
        while timestamps[1] and timestamps[1] < cutoffTime do
            table.remove(timestamps, 1)
        end

        local threadCount = bronze - initialBronze
        local elapsedMinutes = (currentTime - startTime) / 60
        local elapsedHours = elapsedMinutes / 60

        if elapsedHours > 0 then
            BPH = threadCount / elapsedHours
        else
            BPH = 0
        end
    end
end

-- Event handler function
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        Initialize()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        UpdateBronze()
    end
end

-- Register events
BronzeTracker:RegisterEvent("PLAYER_LOGIN")
BronzeTracker:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
BronzeTracker:SetScript("OnEvent", OnEvent)

-- Create a frame for displaying the information
local displayFrame = CreateFrame("Frame", "BronzeTrackerDisplay", UIParent, "BackdropTemplate")
displayFrame:SetSize(200, 100)
displayFrame:SetPoint("CENTER")
displayFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

-- Make the frame draggable
displayFrame:SetMovable(true)
displayFrame:EnableMouse(true)
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
displayFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Create font strings for the display
local titleText = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOP", 0, -10)
titleText:SetText(L[lang].BRONZE_TRACKER)

local totalBronzeText = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
totalBronzeText:SetPoint("TOPLEFT", 10, -30)
totalBronzeText:SetText(L[lang].TOTAL_BRONZE .. "0")

local BPHText = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
BPHText:SetPoint("TOPLEFT", 10, -50)
BPHText:SetText(L[lang].BRONZE_PER_HOUR .. "0")

local sessionBronzeText = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sessionBronzeText:SetPoint("TOPLEFT", 10, -70)
sessionBronzeText:SetText(L[lang].BRONZE_THIS_SESSION .. "0")

-- Update display function
local function UpdateDisplay()
    totalBronzeText:SetText(L[lang].TOTAL_BRONZE .. bronze)
    BPHText:SetText(L[lang].BRONZE_PER_HOUR .. string.format("%.1f", BPH))
    sessionBronzeText:SetText(L[lang].BRONZE_THIS_SESSION .. sessionBronze)
end

-- OnUpdate script to update the display regularly
displayFrame:SetScript("OnUpdate", function(self, elapsed)
    UpdateDisplay()
end)

-- Function to toggle the visibility of the frame
local function ToggleBronzeTrackerFrame()
    if displayFrame:IsShown() then
        displayFrame:Hide()
    else
        displayFrame:Show()
    end
end

-- Register the slash command
SLASH_ZAKK1 = '/zakk'
SlashCmdList["ZAKK"] = ToggleBronzeTrackerFrame
