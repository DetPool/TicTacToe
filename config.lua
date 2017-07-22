--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace

local Config = core.Config;
local MainFrame;

--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
	theme = {
		r = 0, 
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff"
	}
}

local playerOne = UnitName("player")
local playerTwo = ""
local myTurn = true
local playerX = true;
local multiplayer = true;
local count = 0;
local win = false;



---------------------------------
-- Main Frame
---------------------------------
function Config:CreateMenu()
	MainFrame = CreateFrame("Frame", "TicTacToe_MainFrame", UIParent, "BasicFrameTemplateWithInset");
	MainFrame:SetSize(240, 240); -- width, height
	MainFrame:SetPoint("CENTER", UIParent, "CENTER"); -- point, relativeFrame, relativePoint, xOffset, yOffset
	MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.title:SetPoint("LEFT", MainFrame.TitleBg, "LEFT", 5, 0);
	MainFrame.title:SetText("Tic Tac Toe");
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:SetScript("OnMouseDown", function(self, button)
	  if button == "LeftButton" and not self.isMoving then
	   self:StartMoving();
	   self.isMoving = true;
	  end
	end)
	MainFrame:SetScript("OnMouseUp", function(self, button)
	  if button == "LeftButton" and self.isMoving then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	  end
	end)
	MainFrame:SetScript("OnHide", function(self)
	  if ( self.isMoving ) then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	  end
	end)

	MainFrame.field = {
		self:CreateButton(1, "TOPLEFT",		MainFrame,	"TOPLEFT",		12,		-24, "");
		self:CreateButton(2, "TOP", 		MainFrame,	"TOP",			0,		-24, "");
		self:CreateButton(3, "TOPRIGHT", 	MainFrame,	"TOPRIGHT",		-12,	-24, "");
		self:CreateButton(4, "LEFT",		MainFrame,	"LEFT",			12,		-6,	"");
		self:CreateButton(5, "CENTER",		MainFrame,	"CENTER",		0,		-6, "");
		self:CreateButton(6, "RIGHT",		MainFrame,	"RIGHT",		-12,	-6, "");
		self:CreateButton(7, "BOTTOMLEFT", 	MainFrame,	"BOTTOMLEFT",	12,		12, "");
		self:CreateButton(8, "BOTTOM", 		MainFrame,	"BOTTOM",		0,		12, "");
		self:CreateButton(9, "BOTTOMRIGHT", MainFrame,	"BOTTOMRIGHT",	-12,	12, "");
	}  

	--[[
	MainFrame.field = self:CreateButton("TOPLEFT",		MainFrame,	"TOPLEFT",		12,		-24, "");
	MainFrame.field = self:CreateButton("TOP", 			MainFrame,	"TOP",			0,		-24, "");
	MainFrame.field = self:CreateButton("TOPRIGHT", 	MainFrame,	"TOPRIGHT",		-12,	-24, "");
	MainFrame.field = self:CreateButton("LEFT",			MainFrame,	"LEFT",			12,		-6,	"");
	MainFrame.field = self:CreateButton("CENTER",		MainFrame,	"CENTER",		0,		-6, "");
	MainFrame.field = self:CreateButton("RIGHT",		MainFrame,	"RIGHT",		-12,	-6, "");
	MainFrame.field = self:CreateButton("BOTTOMLEFT", 	MainFrame,	"BOTTOMLEFT",	12,		12, "");
	MainFrame.field = self:CreateButton("BOTTOM", 		MainFrame,	"BOTTOM",		0,		12, "");
	MainFrame.field = self:CreateButton("BOTTOMRIGHT", 	MainFrame,	"BOTTOMRIGHT",	-12,	12, "");
	]]

	MainFrame:Hide();
	return MainFrame;
end

function Config:Exit()
	SendChatMessage("exited the game.", "EMOTE");
	myTurn = true;
	playerX = true;
	--multiplayer = false;
	counter = 0;
	win = false;
	MainFrame:Hide();
	MainFrame = nil;
end

function Config:Reset()
	core.commands.exit();
	core.commands.start();
end

--------------------------------------
-- Config functions
--------------------------------------
function Config:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function Config:Toggle()
	local menu = MainFrame or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

local function DisableFields()
	for i = 1, #MainFrame.field do
		MainFrame.field[i]:Disable();
	end
end

local function EnableFields()
	for i = 1, #MainFrame.field do
		MainFrame.field[i]:Enable();
	end
end

function Config:CreateButton(id, point, relativeFrame, relativePoint, xOffset, yOffset, text)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetID(id);
	btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset);
	btn:SetSize(70, 70);
	btn:SetText(text);
	btn:SetNormalFontObject("GameFontNormalLarge");
	btn:SetHighlightFontObject("GameFontHighlightLarge");
	btn:SetScript("OnClick", function(self) Field_Onclick(self) end);

	--btn:SetScript("OnClick", function(self));

	return btn;
end

local function Field_Onclick(self)
	if (playerX and multiplayer == false) then
		SendChatMessage("has put an X on the field : " .. self:GetID(), "EMOTE");
	else
		SendChatMessage("has put an O on the field : " .. self:GetID(), "EMOTE");
	end

	SelectField(self:GetID());
	myTurn = false;
	
	if (multiplayer) then
		DisableFields();
	end
end

--------------------------------------
-- Functions
--------------------------------------
function SelectField(key)
	if (MainFrame.field[key].IsDisabled == false) then
		MainFrame.field[key]:Disable();
		count = count + 1;
		if (playerX == true) then
			MainFrame.field[key]:SetText("X");
			playerX = false;
		else
			MainFrame.field[key]:SetText("O");
			playerX = true;
		end

		if (count >= 5) then
			--[[
			local btnOne = MainFrame.field[1];
			local btnTwo = MainFrame.field[2];
			local btnThree = MainFrame.field[3]:LockHighlight();
			local btnFour = MainFrame.field[4]:LockHighlight();
			local btnFive = MainFrame.field[5]:LockHighlight();
			local btnSix = MainFrame.field[6]:LockHighlight();
			local btnSeven = MainFrame.field[7]:LockHighlight();
			local btnEight = MainFrame.field[8]:LockHighlight();
			local btnNine = MainFrame.field[9]:LockHighlight();
			]]

			if ((MainFrame.field[1]:GetText() == MainFrame.field[2]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[3]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[2]:LockHighlight();
				MainFrame.field[3]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[4]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[4]:GetText() == MainFrame.field[6]:GetText()) and (MainFrame.field[4]:GetText() ~= nil)) then
				MainFrame.field[4]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[6]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[7]:GetText() == MainFrame.field[8]:GetText()) and (MainFrame.field[7]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[7]:GetText() ~= nil)) then
				MainFrame.field[7]:LockHighlight();
				MainFrame.field[8]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[1]:GetText() == MainFrame.field[4]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[7]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[4]:LockHighlight();
				MainFrame.field[7]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[2]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[2]:GetText() == MainFrame.field[8]:GetText()) and (MainFrame.field[2]:GetText() ~= nil)) then
				MainFrame.field[2]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[8]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[3]:GetText() == MainFrame.field[6]:GetText()) and (MainFrame.field[3]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[3]:GetText() ~= nil)) then
				MainFrame.field[3]:LockHighlight();
				MainFrame.field[6]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[1]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[3]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[3]:GetText() == MainFrame.field[7]:GetText()) and (MainFrame.field[3]:GetText() ~= nil)) then
				MainFrame.field[3]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[7]:LockHighlight();
				SendChatMessage("won the game!", "EMOTE");
				DoEmote("dance");
				DisableFields();
				win = true;
			end
		end
	end

	if (count >= 9) and (win == false) then
		Config.Reset();
	end
end


---------------------------------
-- Buttons
---------------------------------
local function SetButtons(frame, numButtons)
	frame.numButtons = numButtons;
	
	local contents = {};
	local frameName = frame:GetName();
	
	for i = 1, numButtons do	
		local button = CreateFrame("Button", frameName.."_Button"..i, frame, "GameMenuButtonTemplate");
		
		button:SetID(i);
		button:SetText(i);
		bottom:SetSize(70, 70);
		bottom:SetNormalFontObject("GameFontNormalLarge");
		bottom:SetHighlightFontObject("GameFontHighlightLarge");

		button:SetScript("OnClick", Button_OnClick);
		
		-- just for tutorial only:
		button.content.bg = button.content:CreateTexture(nil, "BACKGROUND");
		button.content.bg:SetAllPoints(true);
		button.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);
		
		table.insert(contents);
		
		if 		(i == 1) then button:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -24);
		elseif	(i == 2) then button:SetPoint("TOP", frame, "TOP", 0, -24);
		elseif	(i == 3) then button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -24);
		elseif	(i == 4) then button:SetPoint("LEFT", frame, "LEFT", 12, -6);
		elseif	(i == 5) then button:SetPoint("CENTER", frame, "CENTER", 0, -6);
		elseif	(i == 6) then button:SetPoint("RIGHT", frame, "RIGHT", -12, -6);
		elseif	(i == 7) then button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 12);
		elseif	(i == 8) then button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12);
		elseif	(i == 9) then button:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12);
		end
	end
	
	-- Tab_OnClick(_G[frameName.."Tab1"]);
	
	return unpack(contents);
end



local function ReceiveInput(event, _, message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter)
	if (multiplayer) then
		local argsMsg = {};
		for _, arg in ipairs({ string.split(' : ', message) }) do
			if (#arg > 0) then
				table.insert(argsMsg, arg);
			end
		end
		
		local argsSnd = {};
		for _, arg in ipairs({ string.split('-', sender) }) do
			if (#arg > 0) then
				table.insert(argsSnd, arg);
			end
		end

		if (argsMsg[#argsMsg] == "at-x0g") then
			EnableFields();
		end


		if (argsSnd[1] ~= UnitName("player")) then
			if (#playerTwo > 0) then
			else
				playerTwo = argsSnd[1];
			end
			EnableFields();
			SelectField(tonumber(argsMsg[#argsMsg]));
		end
	end
end


---------------------------------
-- Events
---------------------------------
local msg = CreateFrame("Frame");
msg:RegisterEvent("CHAT_MSG_EMOTE");
msg:SetScript("OnEvent", ReceiveInput);

