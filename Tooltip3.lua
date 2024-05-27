-- Create the addon frame
local frame = CreateFrame("Frame", "QuestStatusCheckerFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(300, 360)
frame:SetPoint("CENTER")
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlightLarge")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 5, 0)

-- Localization
local L = {}
local locale = GetLocale()

if locale == "ruRU" then
    L["Dungeon Quest"] = "Задание подземелья"
    L["Raid Quest"] = "Задание рейда"
    L["Scenario Quest"] = "Задание сценария"
    L["Sha"] = "Ша Злости"
    L["Galleon"] = "Галеон"
    L["Nalak"] = "Налак"
    L["Oondasta"] = "Ундаста"
    L["Celestials"] = "Небожители"
    L["Ordos"] = "Ордос"
    L["Done"] = "Выполнено"
    L["Not done"] = "Не выполнено"
    L["Quest Status Checker"] = "Ежедневная активность"
else
    L["Dungeon Quest"] = "Dungeon Quest"
    L["Raid Quest"] = "Raid Quest"
    L["Scenario Quest"] = "Scenario Quest"
    L["Sha"] = "Sha"
    L["Galleon"] = "Galleon"
    L["Nalak"] = "Nalak"
    L["Oondasta"] = "Oondasta"
    L["Celestials"] = "Celestials"
    L["Ordos"] = "Ordos"
    L["Done"] = "Done"
    L["Not done"] = "Not done"
    L["Quest Status Checker"] = "Daily activity"
end

frame.title:SetText(L["Quest Status Checker"])

-- Create the scroll frame
local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

-- Create the content frame
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(240, 800)
scrollFrame:SetScrollChild(content)

-- Create the font string for displaying quest status
local questStatusText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
questStatusText:SetPoint("TOPLEFT", 10, -10)
questStatusText:SetJustifyH("LEFT")
questStatusText:SetWidth(220)

-- Define the quests to be checked
local quests = {
    {id = 80446, icon = "|T397907:15|t", name = L["Dungeon Quest"]},
    {id = 80447, icon = "|T397907:15|t", name = L["Raid Quest"]},
    {id = 80448, icon = "|T397907:15|t", name = L["Scenario Quest"]},
    {id = 32099, icon = "|T627685:15|t", name = L["Sha"]},
    {id = 32098, icon = "|T646378:15|t", name = L["Galleon"]},
    {id = 32518, icon = "|T656169:15|t", name = L["Nalak"]},
    {id = 32519, icon = "|T838685:15|t", name = L["Oondasta"]},
    {id = 33117, icon = "|T877514:15|t", name = L["Celestials"]},
    {id = 33118, icon = "|T134174:15|t", name = L["Ordos"]}
}

-- Function to check quest completion status
local function IsQuestCompleted(questID)
    return C_QuestLog.IsQuestFlaggedCompleted(questID)
end

-- Function to update the quest status display
local function UpdateQuestStatus()
    local result = ""

    for index, quest in ipairs(quests) do
        local completed = IsQuestCompleted(quest.id)
        local color = completed and "00ff00" or "ff0000"
        result = result .. "|cff" .. color .. quest.icon .. quest.name .. ": " .. (completed and L["Done"] .. "\n" or L["Not done"] .. "\n") .. "|r"

        if index == 3 then
            result = result .. "\n"
        end
    end

    questStatusText:SetText(result)
    content:SetHeight(questStatusText:GetStringHeight() + 20)
end

-- Register event to update the status when the player logs in
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", UpdateQuestStatus)
frame:Hide()

-- Slash command to toggle the frame visibility
SLASH_ZANN1 = "/zann"
SlashCmdList["ZANN"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        UpdateQuestStatus()
        frame:Show()
    end
end
