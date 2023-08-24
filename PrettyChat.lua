PrettyChat = select(2, ...)



local chatFrame = ChatFrame1
local editBox = ChatFrame1EditBox

local timer
local duration = 0.20

local fontSize = 13
local fontSpacing = 2

isOpen = false
isLocked = false
isEditing = false

local mainFrame = CreateFrame("Frame", "PrettyChatFrame", UIParent)
mainFrame:SetClampedToScreen(false)

mainFrame:SetWidth(chatFrame:GetWidth()+10)
mainFrame:SetHeight(chatFrame:GetHeight() + 60)
mainFrame:SetFrameStrata("BACKGROUND")
mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -2, -2)
mainFrame:UnregisterAllEvents();
local xOffset = -mainFrame:GetWidth() -50

local initialEditHeight = 17
local initialMoveHeight = initialEditHeight - 8
local editHeight = fontSize + fontSpacing
local yOffset = 0

local moveFrame = CreateFrame("Frame", "PrettyChatMoveFrame", UIParent)
moveFrame:SetClampedToScreen(false)

moveFrame:SetWidth(10)
moveFrame:SetHeight(10)
moveFrame:SetFrameStrata("BACKGROUND")
moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
moveFrame:UnregisterAllEvents();

local editFrame = CreateFrame("Frame", "PrettyChatEditFrame", UIParent)
editFrame:SetClampedToScreen(false)
editFrame:SetWidth(chatFrame:GetWidth() + (fontSize * 3))
editFrame:SetHeight(fontSize)
editFrame:SetFrameStrata("TOOLTIP")
editFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -initialEditHeight)
editFrame:UnregisterAllEvents();

local animationGroup = editFrame:CreateAnimationGroup()
local slideIn = animationGroup:CreateAnimation("Translation")
slideIn:SetDuration(1)
slideIn:SetOrder(1)
slideIn:SetOffset(0, 50)

local lockFrame = CreateFrame("Frame", "PrettyChatLockFrame", mainFramemainFrame)
lockFrame:SetClampedToScreen(false)
lockFrame:SetWidth(32)
lockFrame:SetHeight(32)
lockFrame:UnregisterAllEvents();
lockFrame:Hide()






local buttonFrame = CreateFrame("Frame", "PrettyChatButtonFrame", UIParent)
buttonFrame:SetSize(100, editHeight)
buttonFrame:SetPoint("BOTTOMLEFT", UIParent, "LEFT")
buttonFrame:SetFrameStrata("HIGH")
buttonFrame:Hide()

buttonFrame.texture = buttonFrame:CreateTexture(nil, "BACKGROUND")
buttonFrame.texture:SetAllPoints(true)

buttonFrame.texture:SetColorTexture(0.5, 0, 0 , 0.3)


function GetJoinedChannels()
    local lastButton = nil
    local chanList = { GetChannelList() }
    EnumerateServerChannels()
    local chanLista = { GetNumDisplayChannels() }
    print( GetNumDisplayChannels() )
    for i = 1, GetNumDisplayChannels(), 1 do
      local channelName, header, collapsed, channelNumber, count, active, category = GetChannelDisplayInfo(i)

      print(channelName )
      print(channelNumber )
      print(active)
      if not header then

      end
    end



    for i=1, #chanList, 3 do
        if not chanList[i+2] then
          local s_button = CreateFrame("Button", "PrettyChatButton", buttonFrame, "UIPanelButtonTemplate")
          if lastButton == nil then
            s_button:SetPoint("BOTTOMLEFT", buttonFrame, "BOTTOMLEFT", 0, 0)
          else
            s_button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 0, 0)
          end
          s_button:EnableMouse(true)
          s_button:SetSize(20, 20)
          s_button.texture = s_button:CreateTexture(nil, "BACKGROUND")
          s_button.texture:SetAllPoints(true)
          s_button.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_BG.tga")
          s_button.Middle:SetTexture(nil)
          s_button.Left:SetTexture(nil)
          s_button.Right:SetTexture(nil)
          s_button:SetNormalTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_Center.tga")
          s_button:SetHighlightTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_Glow_Alpha.tga")
          s_button:SetPushedTexture("Interface\\AddOns\\PrettyChat\\Textures\\NillTexture.tga")
          s_button:SetScript("OnClick", function() ChatButtonClicked(chanList[i+1])  end)
          lastButton = s_button
        end

    end
    return channels
end

function ChatButtonClicked(chatMessage)
  print("a")
  if editBox then
      if not chatFrame:IsShown() then
          FCF_SelectDockFrame(chatFrame)
      end
      editBox:Show()
      editBox:SetFocus()
      editBox:Insert(chatMessage)
  end
end

function CreateChatBarButtons()
    local channels =  GetJoinedChannels()
    for i=1, #channels, 1 do


    end
end





local function CreateTabSkin()
    for i = 1, NUM_CHAT_WINDOWS do
        local tab = _G["ChatFrame" .. i .. "Tab"]
        if tab then
            tab:SetNormalTexture("Interface\\AddOns\\PrettyChat\\Textures\\ChatTab.tga")
            tab:SetHighlightTexture("Interface\\AddOns\\PrettyChat\\Textures\\ChatTabHighlight.tga")
            tab:SetPushedTexture("Interface\\AddOns\\PrettyChat\\Textures\\NillTexture.tga")
            tab:SetAlpha(0)

          	tab.noMouseAlpha = 0
          	FCFTab_UpdateAlpha(_G[("ChatFrame%d"):format(i)])

          	tab.leftSelectedTexture:SetAlpha(0)
          	tab.rightSelectedTexture:SetAlpha(0)
          	tab.middleSelectedTexture:SetAlpha(0)

          	tab.leftHighlightTexture:SetTexture(nil)
          	tab.rightHighlightTexture:SetTexture(nil)
          	tab.middleHighlightTexture:SetTexture(nil)
          	tab:SetFrameStrata("BACKGROUND")



          	tab.middleHighlightTexture.SetVertexColor = noop

            tab:HookScript("OnEnter", function(self)
                self:LockHighlight()
            end)

            tab:HookScript("OnLeave", function(self)
                self:UnlockHighlight()
            end)

        end
    end
end

local function CreateEditBoxSkin()
  for i = 1, 10 do
  	local editBox = _G[("ChatFrame%dEditBox"):format(i)]

  	_G[("ChatFrame%sEditBoxLeft"):format(i)]:SetAlpha(0)
  	_G[("ChatFrame%sEditBoxRight"):format(i)]:SetAlpha(0)
  	_G[("ChatFrame%sEditBoxMid"):format(i)]:SetAlpha(0)

    editBox:SetFrameStrata("TOOLTIP")
    editBox:SetFrameStrata("TOOLTIP")
    editBox:SetMultiLine(true)
    editBox:ClearAllPoints()
    editBox:SetSpacing(fontSpacing)
    editBox:SetPoint("BOTTOMLEFT", editFrame, "BOTTOMLEFT",-4,0)
    editBox:SetPoint("TOPRIGHT", editFrame, "TOPRIGHT")
    editBox:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "")
    editBox:SetJustifyH("LEFT")
    editBox:SetJustifyV("CENTER")

    editBox.texture = editBox:CreateTexture(nil, "BACKGROUND")
    editBox.texture:SetPoint("TOPLEFT", editBox, "TOPLEFT", 0 , fontSize + 4)
    editBox.texture:SetWidth(editBox:GetWidth() + fontSize)
    editBox.texture:SetHeight((editBox:GetWidth()) / 2 )
    editBox.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\EditBox.tga")
  end
end

local function CreateChatSkin()
  for i = 1, 10 do
  	local chatFrame = _G[("ChatFrame%d"):format(i)]

    chatFrame:SetClampedToScreen(false)

    chatFrame:SetFading(false)
    chatFrame:SetPoint("BOTTOMLEFT", moveFrame, "BOTTOMLEFT", 4, 30)
    chatFrame:SetFrameStrata("LOW")
    chatFrame.texture = chatFrame:CreateTexture(nil, "BACKGROUND")
    chatFrame.texture:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", 17 ,17)
    chatFrame.texture:SetWidth(chatFrame:GetWidth() + 50)
    chatFrame.texture:SetHeight(chatFrame:GetHeight() + ChatFrame1Tab:GetHeight() + 2 )
    chatFrame.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\ChatBox.tga")
  end
end



local function ToggleChat()
  if not isLocked and not isEditing then
    if not isOpen then
      OpenChat()
    else
      CloseChat()
    end
  end
end


local function AddYOffset()
  editFrame:AdjustPointsOffset(0, editHeight)
  moveFrame:AdjustPointsOffset(0, editHeight)
end

local function OpenChat()
  if not isOpen and not isLocked then
    moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
    local startTime = GetTime()

    local function OnUpdate(self)
        local elapsedTime = GetTime() - startTime
        local progress = elapsedTime / duration

        if progress < 1 then
            local newX =  xOffset * (1 - progress)
            moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", newX, initialMoveHeight)
        else
            moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
            self:SetScript("OnUpdate", nil)
        end
    end

    moveFrame:SetScript("OnUpdate", OnUpdate)
    isOpen = true
  end
end

local function CloseChat()
  if isOpen and not isLocked and not isEditing then

    moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", xOffset, initialMoveHeight)
    local startTime = GetTime()

    local function OnUpdate(self)
        local elapsedTime = GetTime() - startTime
        local progress = elapsedTime / duration

        if progress < 1 then
            local newX = xOffset * progress
            moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", newX, initialMoveHeight)
        else
          moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", xOffset, initialMoveHeight)
          self:SetScript("OnUpdate", nil)
        end
    end

    moveFrame:SetScript("OnUpdate", OnUpdate)
    isOpen = false
  end
end

local function OpenEdit()

      editFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
      local startTime = GetTime()

      local function OnUpdate(self)
          local elapsedTime = GetTime() - startTime
          local progress = elapsedTime / duration

          if progress < 1 then
              local newY = 1.4 * progress
              editFrame:AdjustPointsOffset(0, newY)
          else
            editFrame:AdjustPointsOffset(0, 1.4)
            self:SetScript("OnUpdate", nil)
          end
      end

      editFrame:SetScript("OnUpdate", OnUpdate)

end



local function OpenCloseAfterTimer()
  if not isOpen and not isLocked then
    OpenChat()
    C_Timer.After(4, CloseChat)
  end
end

local function OnEditFocusGained()
  OpenChat()
  OpenEdit()
  isEditing = true


end

local function CheckMouse()
  if not mainFrame:IsMouseOver() then
    if not isEditing and not isLocked then
      CloseChat()
    end
  else
  	C_Timer.After(0.1, CheckMouse)
  end
end

local function CloseAfterTimer()
  if isOpen and not isLocked then
    C_Timer.After(2, CheckMouse)
  end
end


local function OnEditFocusLost()
  editFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
  moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)

  isEditing = false
  CloseAfterTimer()

end

local function OnEditBoxTextChanged(self)
  --self:SetTextColor(0,0,0,1)
  charCount = #self:GetText() -- Update the character count
  charMax = 50
  if charCount > 0 and charCount % charMax == 0 then
    AddYOffset()
  end
end


local function InitializeAddon()
  editBox:SetScript("OnEditFocusGained", OnEditFocusGained)
  editBox:SetScript("OnEditFocusLost", OnEditFocusLost)
  editBox:SetScript("OnTextChanged", OnEditBoxTextChanged)
  lockFrame:SetFrameStrata("HIGH")
  lockFrame:SetPoint("TOPRIGHT",chatFrame, "TOPRIGHT")
  lockFrame.texture = lockFrame:CreateTexture(nil, "BACKGROUND")
  lockFrame.texture:SetPoint("TOPRIGHT", lockFrame, "TOPRIGHT",5,5)
  lockFrame.texture:SetWidth(32)
  lockFrame.texture:SetHeight(32)
  lockFrame.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\Lock.tga")




  CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 1
  CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 1
  CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

  CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1

  CHAT_FRAME_MOUSEOVER_ALPHA = 0
  CHAT_FRAME_NOMOUSE_ALPHA = 0

  CHAT_TAB_SHOW_DELAY = 0
  CHAT_TAB_HIDE_DELAY = 0
  CHAT_FRAME_FADE_TIME = 0
  CHAT_FRAME_FADE_OUT_TIME = 0

end


-- Register event handlers
mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:RegisterEvent("PLAYER_LOGOUT")

mainFrame:RegisterEvent("CHAT_MSG_SAY");
mainFrame:RegisterEvent("CHAT_MSG_YELL");
mainFrame:RegisterEvent("CHAT_MSG_PARTY");
mainFrame:RegisterEvent("CHAT_MSG_RAID");
mainFrame:RegisterEvent("CHAT_MSG_RAID_WARNING");
mainFrame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT");
mainFrame:RegisterEvent("CHAT_MSG_GUILD");
mainFrame:RegisterEvent("CHAT_MSG_OFFICER");
mainFrame:RegisterEvent("CHAT_MSG_EMOTE");


mainFrame:SetScript("OnEnter", function(self)
  if not isLocked and not isEditing then
    OpenChat()
    CheckMouse()
  end
end)


chatFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not isEditing then
        isLocked = not isLocked
        if isLocked then
          lockFrame:Show()
        else
          lockFrame:Hide()
        end
        if isOpen then
          CheckMouse()
        end
    end
end)

mainFrame:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_LOGIN"  then
    InitializeAddon()
    CreateTabSkin()
    CreateEditBoxSkin()
    CreateChatSkin()
    GetJoinedChannels()
  else
    if not UnitAffectingCombat("player") then
      OpenCloseAfterTimer()
    end
  end
end)
