--===================================================== VARIABLES GLOBALES

local WIM = WIM

--Set up du menu d'option (Au cas ou y ai besoin mais inutile pour le moment)
local PrettyChat = LibStub("AceAddon-3.0"):NewAddon("PrettyChat", "AceConsole-3.0", "AceEvent-3.0")
local defaults = {
	profile = {
		Height = 0,
		Width = 0
	}
}

--Définition de couleurs (rgb de 0 à 1) pour chaque channel standard et pour les channels spécifiques
local channelsListColor = {}
channelsListColor["s"] = {1, 1, 1} -- blanc
channelsListColor["sh"] = {1, 0, 0} -- rouge
channelsListColor["w"] = {0.9, 0.1, 0.9} -- violet
channelsListColor["p"] = {0.65, 0.55, 1} -- bleu terne
channelsListColor["rsay"] = {0.8, 0.5, 0} -- orange
channelsListColor["rw"] = {0.9, 0.1, 0.1} -- rouge foncé
channelsListColor["g"] = {0.4, 0.8, 0.3} -- vert pétant
channelsListColor["o"] = {0.2, 0.6, 0.2} -- vert foncé
channelsListColor["spe"] = {0.7, 0.7, 0.7} -- gris

--Init variables globales
local editBox = ChatFrame1EditBox

local timer
--durée de l'animation des frames
local duration = 0.20

--Taille de la police
local fontSize = 13
local fontSpacing = 2

--Booleens pour gerer l'ouverture et la fermeture des chatframes
local isOpen = true
local isLocked = false
local isEditing = false

--Position Y des chatframes et de l'editbox
local editHeight = fontSize + fontSpacing
local initialEditHeight = editHeight
local initialMoveHeight = initialEditHeight - 8

--Offsett X et Y des chat frames
local yOffset = 0
local xOffset = 0

--Frame principale, fait la taille des chat
local mainFrame = CreateFrame("Frame", "PrettyChatFrame", UIParent)

--Frame qui bouge lors de l'animation des chatFrames, elle a toutes les chatframes docké a la chatFrame1 en enfant
local moveFrame = CreateFrame("Frame", "PrettyChatMoveFrame", UIParent)

--Frame qui bouge lors de l'amination de l'editbox, elle a l'edit box en enfant
local editFrame = CreateFrame("Frame", "PrettyChatEditFrame", UIParent)

--Frame qui contient la texture du cadenas lorsque le chat est lock
local lockFrame = CreateFrame("Frame", "PrettyChatLockFrame", mainFrame)

--Frame qui contient tous les boutons de chat (Dire, Crier, Chuchoter, etc...)
local buttonFrame = CreateFrame("Frame", "PrettyChatButtonFrame", UIParent)

--Anim de l'editbox (Pas utilisé mais ca serait cool de transferer les animtion sur se systeme)
local animationGroup = editFrame:CreateAnimationGroup()

local slideIn = animationGroup:CreateAnimation("Translation")
slideIn:SetDuration(1)
slideIn:SetOrder(1)
slideIn:SetOffset(0, editHeight)

--Initialise le parent, les dimensions et textures des frames
function InitializeFrames()
	mainFrame:SetClampedToScreen(false)
	mainFrame:SetWidth(ChatFrame1:GetWidth() + 20)
	mainFrame:SetHeight(ChatFrame1:GetHeight() + 70)
	mainFrame:SetFrameStrata("BACKGROUND")
	mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -2, -2)
	mainFrame:UnregisterAllEvents()

	--RAJOUTE CA SUR UNE FRAME SI TU VEUX VOIR A QUOI ELLE RESSEMBLE DANS L'ESPACE
	-- mainFrame.texture = mainFrame:CreateTexture(nil, "BACKGROUND")
	-- mainFrame.texture:SetAllPoints(true)
	-- mainFrame.texture:SetColorTexture(0.5, 0, 0 , 0.3)

	moveFrame:SetClampedToScreen(false)
	moveFrame:SetWidth(60)
	moveFrame:SetHeight(60)
	moveFrame:SetFrameStrata("BACKGROUND")
	moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
	moveFrame:UnregisterAllEvents()
	-- moveFrame.texture = moveFrame:CreateTexture(nil, "BACKGROUND")
	-- moveFrame.texture:SetAllPoints(true)
	-- moveFrame.texture:SetColorTexture(0, 1, 0 , 0.3)

	editFrame:SetClampedToScreen(false)
	editFrame:SetWidth(ChatFrame1:GetWidth() + (fontSize * 3))
	editFrame:SetHeight(fontSize)
	editFrame:SetFrameStrata("TOOLTIP")
	editFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -initialEditHeight)
	editFrame:UnregisterAllEvents()

	lockFrame:SetClampedToScreen(false)
	lockFrame:SetWidth(32)
	lockFrame:SetHeight(32)
	lockFrame:UnregisterAllEvents()
	lockFrame:Hide()
	lockFrame:SetFrameStrata("HIGH")
	lockFrame:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", 7, -10)
	lockFrame.texture = lockFrame:CreateTexture(nil, "BACKGROUND")
	lockFrame.texture:SetAllPoints(true)
	lockFrame.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\Lock.tga")

	buttonFrame:SetSize(100, editHeight)
	buttonFrame:SetPoint("BOTTOMLEFT", UIParent, "LEFT")
	buttonFrame:SetFrameStrata("HIGH")
	--buttonFrame:Hide()
	buttonFrame.texture = buttonFrame:CreateTexture(nil, "BACKGROUND")
	buttonFrame.texture:SetAllPoints(true)
	buttonFrame.texture:SetColorTexture(0.5, 0, 0, 0.3)
end

--===================================================== BOUTONS DE CHAT

--Concatene t2 dans t1
function TableConcat(t1, t2)
	for _, v in ipairs(t2) do
		table.insert(t1, v)
	end
end

local buttonProps = {
	"func",
	"owner",
	"keepShownOnClick",
	"tooltipTitle",
	"tooltipText",
	"arg1",
	"arg2",
	"notCheckable",
	"value"
}

local function clearButton(self)
	for i = 1, #buttonProps do
		self[buttonProps[i]] = nil
	end
end
--Création des bouton de la barre de chat
--Pas tres fonctionnel, le code est degueux car j'arrive pas a concatener chanList et chanListSpe (probablement parce que chanListSpe est multi type)
function GetJoinedChannels()
	local lastButton = nil
	-- {"/commande", "Nom", ...}
	local chanList = {"s", "Dire", "sh", "Crier", "w", "Chuchoter"}
	--Marche pas de fou ca je crois
	if IsInGroup() then
		TableConcat(chanList, {"p", "Groupe"})
	end
	if IsInRaid() then
		TableConcat(chanList, {"rsay", "Raid"})
	end
	if UnitIsGroupAssistant("player") then
		TableConcat(chanList, {"rw", "RaidLead"})
	end
	if IsInGuild() then
		TableConcat(chanList, {"g", "Guilde"})
	end
	if UnitIsRaidOfficer("player") then
		TableConcat(chanList, {"o", "Officier"})
	end

	for i = 1, #chanList, 2 do
		local channelCommand = chanList[i]
		local channelColor = channelsListColor[channelCommand]
		local s_button = CreateFrame("Button", "PrettyChatButton", buttonFrame, "UIPanelButtonTemplate")
		s_button.ClearButton = clearButton

		if lastButton == nil then
			s_button:SetPoint("BOTTOMLEFT", buttonFrame, "BOTTOMLEFT", 0, 0)
		else
			s_button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 0, 0)
		end
		s_button:SetScript(
			"OnClick",
			function()
				ChatButtonClicked("/" .. channelCommand .. " ")
			end
		)
		CreateButton(s_button, channelColor)
		lastButton = s_button
	end

	-- {int channelID, "Nom", bool actif}
	local chanListSpe = {GetChannelList()}
	for i = 1, #chanListSpe, 3 do
		if not chanListSpe[i + 2] then
			-- print(chanListSpe[i])
			-- print(chanListSpe[i+1])
			-- print(chanListSpe[i+2])
			local s_button = CreateFrame("Button", "PrettyChatButton", buttonFrame, "UIPanelButtonTemplate")
			if lastButton == nil then
				s_button:SetPoint("BOTTOMLEFT", buttonFrame, "BOTTOMLEFT", 0, 0)
			else
				s_button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 0, 0)
			end

			s_button:SetScript(
				"OnClick",
				function()
					ChatButtonClicked("/" .. chanListSpe[i] .. " ")
				end
			)
			CreateButton(s_button, channelsListColor["spe"])
			lastButton = s_button
		end
	end

	local DefaultChannels = {GetChatWindowChannels(DEFAULT_CHAT_FRAME:GetID())}
	for i = 1, #DefaultChannels, 2 do
		print(DefaultChannels[i])
		print(DefaultChannels[i + 1])
	end
	return channels
end

--Créé les boutons sur l'interface (pas utilisé avant d'avoir rendu les boutons robustes)
function CreateButton(s_button, color)
	s_button:EnableMouse(true)
	s_button:SetSize(20, 20)
	s_button:ClearDisabledTexture()
	s_button:ClearHighlightTexture()
	s_button:ClearNormalTexture()
	s_button:ClearPushedTexture()
	s_button.texture = s_button:CreateTexture(nil, "BACKGROUND")
	s_button.texture:SetAllPoints(true)
	s_button.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_BG.tga")
	s_button.Middle:SetTexture(nil)
	s_button.Left:SetTexture(nil)
	s_button.Right:SetTexture(nil)
	s_button:SetNormalTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_Center.tga")
	local normalTex = s_button:GetNormalTexture()
	normalTex:SetVertexColor(color[1], color[2], color[3])
	s_button:SetHighlightTexture("Interface\\AddOns\\PrettyChat\\Textures\\SkinGlass\\ChanButton_Glow_Alpha.tga")
	local highlightTex = s_button:GetHighlightTexture()

	highlightTex:ClearAllPoints()
	highlightTex:SetPoint("CENTER", s_button.texture, "CENTER")
	highlightTex:SetSize(16, 16)

	s_button:SetPushedTexture("Interface\\AddOns\\PrettyChat\\Textures\\NillTexture.tga")
	local puchedTex = s_button:GetPushedTexture()
end

--Evenement quand on clique sur un boutton
function ChatButtonClicked(chatMessage)
	if editBox then
		-- local folderName, _, _, _, _, _, _ = GetAddOnInfo("WIM") -- Get the folder name of the "WIM" addon

		-- -- Check if the "WIM" addon is enabled
		-- local wimPath = "Interface\\AddOns\\" .. folderName .. "\\WIM.lua" -- Adjust the path to the "WIM" Lua file as needed

		-- -- Load the "WIM" Lua filei
		-- local loaded, errorMsg = loadfile(wimPath)

		-- if loaded then
		-- 	-- Execute the CF_OpenChat function from the "WIM" addon
		-- 	loaded:CF_OpenChat()
		-- else
		-- 	-- Handle any error loading the file
		-- 	print("Error loading the WIM Lua file: " .. errorMsg)
		-- end

		-- if not ChatFrame1:IsShown() then
		-- --FCF_SelectDockFrame(ChatFrame1)
		-- end
		-- local menu = WIM
		-- if (not menu) then
		-- 	print("b")
		-- else
		-- 	print("a")
		-- end
		editBox:Show()
		editBox:SetFocus()
		editBox:Insert(chatMessage)
	end
end

--===================================================== CHAT FRAME TABS

--Determine si une chatFrame est docké a une autre chatFrame
local function isMainFrame(i)
	local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i)
	if i == 1 or docked ~= nil then
		return true
	end
end

--Initialise parent, dimensions et textures des Tabs des chatframes
local function CreateTabSkin()
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame" .. i .. "Tab"]
		if tab then
			-- tab:SetMovable(true)
			-- tab:EnableMouse(true)
			-- tab:RegisterForDrag("LeftButton")
			tab:SetScript(
				"OnDragStart",
				function(self, button)
				end
			)
			tab:SetScript(
				"OnDragStop",
				function(self)
				end
			)
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

			tab:HookScript(
				"OnEnter",
				function(self)
					self:LockHighlight()
				end
			)
			tab:HookScript(
				"OnLeave",
				function(self)
					self:UnlockHighlight()
				end
			)
		end
	end
end

--===================================================== EDIT BOX SKIN

--Créé les edits box (pas sur qu'il faille en créer 10 car j'ai l'impression qu'on utilise toujours l'editbox de la chatframe1)
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
		editBox:SetPoint("BOTTOMLEFT", editFrame, "BOTTOMLEFT", -4, 0)
		editBox:SetPoint("TOPRIGHT", editFrame, "TOPRIGHT")
		editBox:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "")
		editBox:SetJustifyH("LEFT")
		editBox:SetJustifyV("CENTER")

		editBox.texture = editBox:CreateTexture(nil, "BACKGROUND")
		editBox.texture:SetPoint("TOPLEFT", editBox, "TOPLEFT", 0, fontSize + 4)
		editBox.texture:SetWidth(editBox:GetWidth() + fontSize)
		editBox.texture:SetHeight((editBox:GetWidth()) / 2)
		editBox.texture:SetTexture("Interface\\AddOns\\PrettyChat\\Textures\\EditBox.tga")
	end
end

--===================================================== MANIPULATION CHAT FRAME ET SKIN

--Initialise la texture d'une chatFrame (pour apres redimensionnement)
local function CreateChatSkin(chatFrame)
	chatFrame:SetWidth(ChatFrame1:GetWidth())
	chatFrame:SetHeight(ChatFrame1:GetHeight())
	local widthOffset = -14 + chatFrame:GetWidth() / 15
	local heightOffset = 6 + chatFrame:GetHeight() / 16
	chatFrame.texture:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", widthOffset, heightOffset)
	chatFrame.texture:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT", widthOffset, -heightOffset)
	chatFrame.texture:SetPoint("TOPLEFT", chatFrame, "TOPLEFT", -widthOffset, heightOffset)
	chatFrame.texture:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMLEFT", -widthOffset, -heightOffset)
	chatFrame.texture:SetWidth(chatFrame:GetWidth() + 50)
	chatFrame.texture:SetHeight(chatFrame:GetHeight() + ChatFrame1Tab:GetHeight() + 200)
end

--Initialise le parent et la position d'une chatFrame (Si on redimensionne la chatFrame1 sans reset les ancres ca casse les chatFrames)
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

--Initialise la texture d'une chatFrame
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

--===================================================== MOUVEMENT DES FRAMES

--Ajoute un offset sur la position Y des chatFrame et de l'edit box (utilisé quand l'editbox doit afficher une ligne de plus)
local function AddYOffset()
	editFrame:AdjustPointsOffset(0, editHeight)
	moveFrame:AdjustPointsOffset(0, editHeight)
end

--Animation d'ouverture des chatframe (A transferer en animation simple comme l'edit box)
local function OpenChat()
	if not isOpen then
		--Position initiale
		moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
		local startTime = GetTime()
		local function OnUpdate(self)
			local elapsedTime = GetTime() - startTime
			local progress = elapsedTime / duration

			if progress < 1 then
				local newX = xOffset * (1 - progress)
				--Position animation
				moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", newX, initialMoveHeight)
			else
				--Position fin animation
				moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)
				self:SetScript("OnUpdate", nil)
			end
		end

		moveFrame:SetScript("OnUpdate", OnUpdate)
		isOpen = true
	end
end

--Animation de fermeture des chatframe
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

--Animation de l'editbox
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

--===================================================== CONTROLE DES FRAMES

--Ouvre le chat puis le ferme au bout d'un timer (utilisé quand le chat recoit un message)
local function OpenCloseAfterTimer()
	if not isOpen and not isLocked then
		OpenChat()
		C_Timer.After(4, CloseChat)
	end
end

--Lorsque le joueur est entrain de taper un message
local function OnEditFocusGained()
	OpenChat()
	OpenEdit()
	isEditing = true
end

--Verifie si la souris est sur la mainframe, sinon on ferme le chat
local function CheckMouse()
	if not mainFrame:IsMouseOver(0, 0, 0, 0) then
		if not isEditing and not isLocked then
			CloseChat()
		end
	else
		C_Timer.After(0.1, CheckMouse)
	end
end

--Evenement quand le joueur resize le chat (avec Prat notemment)
local function StartResize(button)
	for i = 1, 10 do
		if isMainFrame(i) then
			local chatFrame = _G[("ChatFrame%d"):format(i)]
			chatFrame:StartSizing("TOPRIGHT")
		end
	end
end

--Evenement quand le joueur arrete de resize le chat
local function StopResize(button)
	mainFrame:SetWidth(ChatFrame1:GetWidth() + 20)
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

--Ferme le chat 2 sec apres que le joueur a terminé d'interagir avec l'edit box
local function CloseAfterTimer()
	if isOpen and not isLocked then
		C_Timer.After(2, CheckMouse)
	end
end

--Evenement quand le joueur a terminé d'interagir avec l'edit box
local function OnEditFocusLost()
	editFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	moveFrame:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, initialMoveHeight)

	isEditing = false
	CloseAfterTimer()
end

--Evenement quand le joueur ecrit dans le chat (utilisé pour augmenter le nombre de ligne de l'editbox)
local function OnEditBoxTextChanged(self)
	--self:SetTextColor(0,0,0,1)
	local charCount = #self:GetText() -- Update the character count
	local charMax = 50
	if charCount > 0 and charCount % charMax == 0 then
		AddYOffset()
	end
end

--Verrouille le chat ouvert ou lui permet de se fermer lorsque le joueur n'a pas sa souris dessus
local function ToggleChatLock()
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

--===================================================== INITIALISATION DE L'ADDON

--Initialise les variables globales de WoW et créé toutes les composants graphiques de l'addon
local function InitializeAddon()
	InitializeFrames()

	ChatFrame1ResizeButton:Hide()
	ChatFrame1ResizeButton:ClearAllPoints()
	ChatFrame1ResizeButton:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT")
	ChatFrame1ResizeButton:SetScript(
		"OnMouseDown",
		function(self)
			StartResize(self)
		end
	)
	ChatFrame1ResizeButton:SetScript(
		"OnMouseUp",
		function(self)
			StopResize(self)
		end
	)

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

--DEGUEU !
--Regarde si le joueur entre dans le jeu
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
--Regarde si le joueur recoit un message
mainFrame:RegisterEvent("CHAT_MSG_SAY")
mainFrame:RegisterEvent("CHAT_MSG_YELL")
mainFrame:RegisterEvent("CHAT_MSG_PARTY")
mainFrame:RegisterEvent("CHAT_MSG_RAID")
mainFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
mainFrame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
mainFrame:RegisterEvent("CHAT_MSG_GUILD")
mainFrame:RegisterEvent("CHAT_MSG_OFFICER")
mainFrame:RegisterEvent("CHAT_MSG_EMOTE")

--Initialise l'addon quand le joueur entre dans le jeu et ouvre le chat lorsqu'il recois un message
mainFrame:SetScript(
	"OnEvent",
	function(_, event, arg1)
		if event == "PLAYER_ENTERING_WORLD" then
			InitializeAddon()
			mainFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		else
			if not UnitAffectingCombat("player") then
				OpenCloseAfterTimer()
			end
		end
	end
)

--Ouvre le chat quand le joueur met sa souris sur la mainFrame
mainFrame:SetScript(
	"OnEnter",
	function(self)
		if not isLocked and not isEditing then
			OpenChat()
			CheckMouse()
		end
	end
)

--Verrouille les chatFrame lorsque le joueur clique sur la chatFrame 1
ChatFrame1:SetScript(
	"OnMouseDown",
	function(self, button)
		if button == "LeftButton" and not isEditing then
			ToggleChatLock()
		end
	end
)

--Systeme de menu et sauvegarde apres deco ou reload (pas utilisé)
function PrettyChat:OnInitialize()
	-- Register the addon's database
	self.db = LibStub("AceDB-3.0"):New("PrettyChatDB", defaults, true)
	-- Register options table for configuration
	LibStub("AceConfig-3.0"):RegisterOptionsTable("PrettyChat", self:GetOptions())
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PrettyChat", "Pretty Chat")
end

--Systeme de menu et sauvegarde apres deco ou reload (pas utilisé)
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
						get = function()
							return self.db.profile.height
						end,
						set = function(_, value)
							self.db.profile.height = value
						end
					},
					width = {
						type = "range",
						name = "Width",
						desc = "Adjust the heigwidthht",
						min = 0,
						max = 100,
						step = 1,
						get = function()
							return self.db.profile.width
						end,
						set = function(_, value)
							self.db.profile.width = value
						end
					}
				}
			}
		}
	}
	return options
end

-- Créé la "/" commande de l'addon (pas utilisé)
PrettyChat:RegisterChatCommand("prettychat", "ChatCommand")

function PrettyChat:ChatCommand(input)
	if input:lower() == "toggle" then
		self.db.profile.myVariable = not self.db.profile.myVariable
		self:Print("MyVariable is now " .. tostring(self.db.profile.myVariable))
	end
end
