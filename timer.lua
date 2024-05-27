local myaddon = ...
local frame = CreateFrame("Frame", "CountdownTimerFrame", UIParent)
frame:SetSize(170, 30)
frame:SetPoint("CENTER")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Set the background texture
local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(true)
background:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")

-- Localization table for different languages
local L = {
    ["enUS"] = { ["endOfRemix"] = "End of\n Remix:", },
    ["ruRU"] = { ["endOfRemix"] = "До конца\n Ремикса:", },
}

-- Determine the client language
local locale = GetLocale()
local localizedStrings = L[locale] or L["enUS"]  -- Use English as the fallback language

-- Create font strings
local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fontString:SetPoint("LEFT", 10, 0)
local timerFontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
timerFontString:SetPoint("RIGHT", -10, 0)

-- Set the start time
local startTime = 1724086800

-- Function to update the countdown
local function UpdateCountdown()
    local currentTime = time()
    local remainingTime = startTime - currentTime
    if remainingTime <= 0 then
        frame:Hide()
        return
    end
    timerFontString:SetText(SecondsToTime(remainingTime, false, false, 2))
    C_Timer.After(1, UpdateCountdown)
end

-- Function to start the countdown
local function StartCountdown()
    frame:Show()
    UpdateCountdown()
end

-- Function to toggle frame visibility
local function ToggleFrame()
    if frame:IsShown() then
        frame:Hide()
        ZammCountdownSettings.isVisible = false
    else
        frame:Show()
        ZammCountdownSettings.isVisible = true
    end
end

-- Slash command handler
SLASH_ZAMM1 = "/zamm"
SlashCmdList["ZAMM"] = ToggleFrame

-- Event handling
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Initialize the saved variable table if it doesn't exist
        ZammCountdownSettings = ZammCountdownSettings or { isVisible = true }
        fontString:SetText(localizedStrings["endOfRemix"])
        if ZammCountdownSettings.isVisible then
            StartCountdown()
        else
            frame:Hide()
        end
    end
end)