local addonName, addon = ...
local frame = CreateFrame("Frame")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")

local function AcceptAndTurnInQuest(questID)
    if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
        if QuestGetAutoAccept() or (not QuestIsFromAreaTrigger() and not QuestIsFromAdventureMap()) then
            AcceptQuest()
        end
        if QuestFrame:IsVisible() then
            QuestFrameCompleteQuestButton:Click()
        elseif GossipFrame:IsVisible() then
            C_GossipInfo.SelectAvailableQuest(questID)
        end
    end
end

frame:SetScript("OnEvent", function(_, event)
    if event == "GOSSIP_SHOW" then
        local gossipOptions = C_GossipInfo.GetAvailableQuests()
        for i = 1, #gossipOptions do
            local questID = gossipOptions[i].questID
            if questID == 80448 or questID == 80446 or questID == 80447 then
                C_GossipInfo.SelectAvailableQuest(questID)
                break
            end
        end
    elseif event == "QUEST_DETAIL" then
        local questID = GetQuestID()
        if questID == 80448 or questID == 80446 or questID == 80447 then
            AcceptAndTurnInQuest(questID)
        end
    elseif event == "QUEST_PROGRESS" then
        local questID = GetQuestID()
        if questID == 80448 or questID == 80446 or questID == 80447 then
            CompleteQuest()
        end
    elseif event == "QUEST_COMPLETE" then
        local questID = GetQuestID()
        if questID == 80448 or questID == 80446 or questID == 80447 then
            GetQuestReward(1)
        end
    end
end)