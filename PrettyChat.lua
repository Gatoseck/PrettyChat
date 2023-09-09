local PrettyChat = LibStub("AceAddon-3.0"):NewAddon("PrettyChat", "AceConsole-3.0", "AceEvent-3.0")

-- Default settings
local defaults = {
    profile = {
        Height = 0,
        Width = 0,
    },
}

local editBox = ChatFrame1EditBox

local timer
local duration = 0.20

local fontSize = 13
local fontSpacing = 2

local isOpen = true
local isLocked = false
local isEditing = false

local editHeight = fontSize + fontSpacing
local initialEditHeight = editHeight
local initialMoveHeight = initialEditHeight - 8

local yOffset = 0
local xOffset = 0


local mainFrame = CreateFrame("Frame", "PrettyChatFrame", UIParent)

local moveFrame = CreateFrame("Frame", "PrettyChatMoveFrame", UIParent)

local editFrame = CreateFrame("Frame", "PrettyChatEditFrame", UIParent)

local lockFrame = CreateFrame("Frame", "PrettyChatLockFrame", mainFrame)

local buttonFrame = CreateFrame("Frame", "PrettyChatButtonFrame", UIParent)

local animationGroup = editFrame:CreateAnimationGroup()
local slideIn = animationGroup:CreateAnimation("Translation")
slideIn:SetDuration(1)
slideIn:SetOrder(1)
slideIn:SetOffset(0, editHeight)

function InitializeFrames()
	mainFrame:SetClampedToScreen(false)
	mainFrame:SetWidth(ChatFrame1:GetWidth() + 20)
	mainFrame:SetHeight(ChatFrame1:GetHeight() + 70)
	mainFrame:SetFrameStrata("BACKGROUND")
	mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -2, -2)
	mainFrame:UnregisterAllEvents();
	-- mainFrame.texture = mainFrame:CreateTexture(nil, "BACKGROUND")
	-- mainFrame.texture:SetAllPoints(true)
	-- mainFrame.texture:SetColorTexture(0.5, 0, 0 , 0.3)


	moveFrame:SetClampedToScreen(false)
	moveFrame:SetWidth(60)
	moveFrame:SetHeight(60)
	moveFrame:SetFrameStrata("BACKGROUND")
	moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
	moveFrame:UnregisterAllEvents();
	-- moveFrame.texture = moveFrame:CreateTexture(nil, "BACKGROUND")
	-- moveFrame.texture:SetAllPoints(true)
  	-- moveFrame.texture:SetColorTexture(0, 1, 0 , 0.3)

	editFrame:SetClampedToScreen(false)
	editFrame:SetWidth(ChatFrame1:GetWidth() + (fontSize * 3))
	editFrame:SetHeight(fontSize)
	editFrame:SetFrameStrata("TOOLTIP")
	editFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -initialEditHeight)
	editFrame:UnregisterAllEvents();

	lockFrame:SetClampedToScreen(false)
	lockFrame:SetWidth(32)
	lockFrame:SetHeight(32)
	lockFrame:UnregisterAllEvents();
	lockFrame:Hide()
	lockFrame:SetFrameStrata("HIGH")
	lockFrame:SetPoint("TOPRIGHT",ChatFrame1, "TOPRIGHT", 7, -10)
	lockFrame.texture = lockFrame:CreateTexture(nil, "BACKGROUND")
	lockFrame.texture:SetAllPoints(true)
	lockFrame.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\Lock.tga")

	buttonFrame:SetSize(100, editHeight)
	buttonFrame:SetPoint("BOTTOMLEFT", UIParent, "LEFT")
	buttonFrame:SetFrameStrata("HIGH")
	--buttonFrame:Hide()
	buttonFrame.texture = buttonFrame:CreateTexture(nil, "BACKGROUND")
	buttonFrame.texture:SetAllPoints(true)
  	buttonFrame.texture:SetColorTexture(0.5, 0, 0 , 0.3)
end

function TableConcat(t1,t2)
	for _,v in ipairs(t2) do 
		table.insert(t1, v)
	end
end


function GetJoinedChannels()
   	local lastButton = nil

	local chanList = { "s", "Dire", "sh", "Crier", "w", "Chuchoter" }
	if true then TableConcat(chanList,{"s", "Dire"}) end
	if true then TableConcat(chanList,{"s", "Dire"}) end

	if true then TableConcat(chanList,{"s", "Dire"}) end

	if IsInGroup() then TableConcat(chanList,{"p", "Groupe"}) end
	if IsInRaid() then TableConcat(chanList,{"rsay", "Raid"}) end
	if UnitIsGroupAssistant("player") then TableConcat(chanList,{"rw", "RaidLead"}) end
	if IsInGuild() then TableConcat(chanList,{"g", "Guilde"}) end
	if UnitIsRaidOfficer("player") then TableConcat(chanList,{"o", "Officier"})	end

	
	

	
    for i=1, #chanList, 2 do
		local s_button = CreateFrame("Button", "PrettyChatButton", buttonFrame, "UIPanelButtonTemplate")
		if lastButton == nil then
			s_button:SetPoint("BOTTOMLEFT", buttonFrame, "BOTTOMLEFT", 0, 0)
		else
			s_button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 0, 0)
		end

		s_button:SetScript("OnClick", function() ChatButtonClicked("/"..chanList[i].." ")  end)
		lastButton = s_button
	end

	local chanListSpe = { GetChannelList() }

    for i=1, #chanListSpe, 3 do
		if not chanListSpe[i+2] then
			print(chanListSpe[i])
			print(chanListSpe[i+1])
			print(chanListSpe[i+2])
			local s_button = CreateFrame("Button", "PrettyChatButton", buttonFrame, "UIPanelButtonTemplate")
			if lastButton == nil then
				s_button:SetPoint("BOTTOMLEFT", buttonFrame, "BOTTOMLEFT", 0, 0)
			else
				s_button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 0, 0)
			end

			s_button:SetScript("OnClick", function() ChatButtonClicked("/"..chanListSpe[i].." ")  end)
			lastButton = s_button
        end

    end
    return channels
end

function CreateButton(s_button)
	s_button:EnableMouse(true)
	s_button:SetSize(20, 20)
	s_button.texture = s_button:CreateTexture(nil, "BACKGROUND")
	s_button.texture:SetAllPoints(true)
	s_button.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_BG.tga")
	s_button.texture:SetColorTexture(0.5, 0, 0 , 0.3)
	s_button.Middle:SetTexture(nil)
	s_button.Left:SetTexture(nil)
	s_button.Right:SetTexture(nil)
	s_button:SetNormalTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_Center.tga")
	s_button:SetHighlightTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_Glow_Alpha.tga")
	s_button:SetPushedTexture("Interface\\AddOns\\PrettyChat\\Textures\\NillTexture.tga")
end

function ChatButtonClicked(chatMessage)
  if editBox then
      if not ChatFrame1:IsShown() then
          FCF_SelectDockFrame(ChatFrame1)
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

local function isMainFrame(i)
	local a, b, c, d, e, f, g, h, dockedTo = GetChatWindowInfo(i)
	if i == 1 or dockedTo ~= nil then
		return true
	end
end


local function CreateTabSkin()
    for i = 1, NUM_CHAT_WINDOWS do
        local tab = _G["ChatFrame" .. i .. "Tab"]
        if tab then
			-- tab:SetMovable(true)
			-- tab:EnableMouse(true)
			-- tab:RegisterForDrag("LeftButton")
			 tab:SetScript("OnDragStart", function(self, button)
			 end)
			 tab:SetScript("OnDragStop", function(self)
			 end)
			tab:SetMovable(false)
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




local function CreateChatSkin(chatFrame)

  chatFrame:SetWidth(ChatFrame1:GetWidth())
  chatFrame:SetHeight(ChatFrame1:GetHeight())
  local widthOffset = -14 + chatFrame:GetWidth()/15
  local heightOffset = 6 + chatFrame:GetHeight()/16
  chatFrame.texture:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", widthOffset ,heightOffset)
  chatFrame.texture:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT", widthOffset ,-heightOffset)
  chatFrame.texture:SetPoint("TOPLEFT", chatFrame, "TOPLEFT", -widthOffset ,heightOffset)
  chatFrame.texture:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMLEFT", -widthOffset ,-heightOffset)
  chatFrame.texture:SetWidth(chatFrame:GetWidth() + 50)
  chatFrame.texture:SetHeight(chatFrame:GetHeight() + ChatFrame1Tab:GetHeight() + 200 )
end

local function AnchorChatFrames()
	xOffset = -ChatFrame1:GetWidth() - 20
	for i = 1, 10 do
		if isMainFrame(i) then
			local chatFrame = _G[("ChatFrame%d"):format(i)]
			--chatFrame:SetMovable(false)
			chatFrame:SetClampedToScreen(false)
			chatFrame:ClearAllPoints()
			chatFrame:SetPoint("BOTTOMLEFT", moveFrame, "BOTTOMLEFT", 4, 30)
			chatFrame:SetFrameStrata("LOW")
			CreateChatSkin(chatFrame)
		end
	end
end

local function CreateChatFrames()
	for i = 1, 10 do
		local chatFrame = _G[("ChatFrame%d"):format(i)]
		--chatFrame:SetMovable(false)
		if isMainFrame(i) then
			chatFrame:SetClampedToScreen(false)
			chatFrame:SetFading(false)
			chatFrame:ClearAllPoints()
			chatFrame:SetPoint("BOTTOMLEFT", moveFrame, "BOTTOMLEFT", 4, 30)
			chatFrame:SetFrameStrata("LOW")
			chatFrame.texture = chatFrame:CreateTexture(nil, "BACKGROUND")
			chatFrame.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\ChatBox.tga")

		end
	end
	AnchorChatFrames()
end




local function AddYOffset()
  editFrame:AdjustPointsOffset(0, editHeight)
  moveFrame:AdjustPointsOffset(0, editHeight)
end

local function OpenChat()
  if not isOpen then
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
  if not mainFrame:IsMouseOver(0,0,0,0) then
    if not isEditing and not isLocked then
      CloseChat()
    end
  else
  	C_Timer.After(0.1, CheckMouse)
  end
end



local function StartResize(button)
	for i = 1, 10 do
		if isMainFrame(i) then
			local chatFrame = _G[("ChatFrame%d"):format(i)]
			chatFrame:StartSizing("TOPRIGHT")
		end
	end
end

local function StopResize(button)
  	mainFrame:SetWidth(ChatFrame1:GetWidth()+20)
	mainFrame:SetHeight(ChatFrame1:GetHeight() + 70)
	editFrame:SetWidth(ChatFrame1:GetWidth() + (fontSize * 3))
	moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
	for i = 1, 10 do
		if isMainFrame(i) then
			local chatFrame = _G[("ChatFrame%d"):format(i)]

			chatFrame:StopMovingOrSizing()
		end
	end

	AnchorChatFrames()
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
	local charCount = #self:GetText() -- Update the character count
	local charMax = 50
	if charCount > 0 and charCount % charMax == 0 then
		AddYOffset()
	end
end


local function InitializeAddon()

  InitializeFrames()
  ChatFrame1ResizeButton:Hide()
  ChatFrame1ResizeButton:ClearAllPoints()
  ChatFrame1ResizeButton:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT")
  ChatFrame1ResizeButton:SetScript("OnMouseDown", function(self) StartResize(self) end)
  ChatFrame1ResizeButton:SetScript("OnMouseUp", function(self) StopResize(self) end)

  editBox:SetScript("OnEditFocusGained", OnEditFocusGained)
  editBox:SetScript("OnEditFocusLost", OnEditFocusLost)
  editBox:SetScript("OnTextChanged", OnEditBoxTextChanged)


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

  CreateTabSkin()
  CreateEditBoxSkin()
  CreateChatFrames()
  GetJoinedChannels()
  CheckMouse()
end

mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

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


ChatFrame1:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not isEditing then
        isLocked = not isLocked
        if isLocked then
          	lockFrame:Show()
			ChatFrame1ResizeButton:Show()
        else
          	lockFrame:Hide()
			ChatFrame1ResizeButton:Hide()
        end
        if isOpen then
          	CheckMouse()
        end
    end
end)


mainFrame:SetScript("OnEvent", function(_, event, arg1)
  	if event == "PLAYER_ENTERING_WORLD"  then
    	InitializeAddon()
    	mainFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  	else
		if not UnitAffectingCombat("player") then
			OpenCloseAfterTimer()
		end
  	end
end)

function PrettyChat:OnInitialize()
    -- Register the addon's database
    self.db = LibStub("AceDB-3.0"):New("PrettyChatDB", defaults, true)

    -- Register options table for configuration
    LibStub("AceConfig-3.0"):RegisterOptionsTable("PrettyChat", self:GetOptions())
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PrettyChat", "Pretty Chat")

end

function PrettyChat:GetOptions()
    local options = {
        type = "group",
        name = "My Addon Settings",
        args = {
            size = {
                type = "group",
                name = "Size",
                args = {
                    height = {
                        type = "range",
                        name = "Height",
                        desc = "Adjust the height",
                        min = 0,
                        max = 100,
                        step = 1,
                        get = function() return self.db.profile.height end,
                        set = function(_, value) self.db.profile.height = value end,
                    },
                    width = {
                        type = "range",
                        name = "Width",
                        desc = "Adjust the heigwidthht",
                        min = 0,
                        max = 100,
                        step = 1,
                        get = function() return self.db.profile.width end,
                        set = function(_, value) self.db.profile.width = value end,
                    },
                },
            },
        },
    }
    return options
end

-- Your addon logic here

-- Register the addon
PrettyChat:RegisterChatCommand("prettychat", "ChatCommand")

-- Chat command function
function PrettyChat:ChatCommand(input)
    if input:lower() == "toggle" then
        self.db.profile.myVariable = not self.db.profile.myVariable
        self:Print("MyVariable is now " .. tostring(self.db.profile.myVariable))
    end
end
