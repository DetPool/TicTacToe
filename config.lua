--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace

local Config = core.Config;
local MainFrame;
local ConfigFrame;

local Title = "Tic Tac Toe"
local xPosition = 0;
local yPosition = 0;
local playerOne = UnitName("player")
local playerTwo = ""
local myTurn = true
local playerX = true;
local multiplayer = true;
local counter = 0;
local win = false;
local blackList = "";

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

---------------------------------
-- Main Frame
---------------------------------
function Config:CreateMenu()
	MainFrame = CreateFrame("Frame", "TicTacToe_MainFrame", UIParent, "BasicFrameTemplateWithInset");
	MainFrame:SetSize(240, 240); -- width, height
	MainFrame:SetPoint("CENTER", UIParent, "CENTER", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
	MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.title:SetPoint("LEFT", MainFrame.TitleBg, "LEFT", 5, 0);
	MainFrame.title:SetText(Title);
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
	   local point = self:GetPoint();
	   xPosition = point[xOffset];
	   yPosition = point[yOffset];
	  end
	end)
	MainFrame:SetScript("OnHide", function(self)
	  if ( self.isMoving ) then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	  end
	end)

	MainFrame.configBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
	MainFrame.configBtn:ClearAllPoints();
	MainFrame.configBtn:SetWidth(50); -- width, height
	MainFrame.configBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -24, 0);
	MainFrame.configBtn:SetScript("OnClick", function(self) if (ConfigFrame:IsShown()) then ConfigFrame:Hide(); else ConfigFrame:Show(); end end);
	MainFrame.configBtn.title = MainFrame.configBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.configBtn.title:SetPoint("LEFT", MainFrame.configBtn, "LEFT", 5, 0);
	MainFrame.configBtn.title:SetText("Config");

	MainFrame.resetBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
	MainFrame.resetBtn:ClearAllPoints();
	MainFrame.resetBtn:SetWidth(50); -- width, height
	MainFrame.resetBtn:SetPoint("RIGHT", MainFrame.configBtn, "LEFT", 0, 0);
	MainFrame.resetBtn:SetScript("OnClick", Config.Reset);
	MainFrame.resetBtn.title = MainFrame.resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.resetBtn.title:SetPoint("LEFT", MainFrame.resetBtn, "LEFT", 5, 0);
	MainFrame.resetBtn.title:SetText("Reset");

	MainFrame.soloCheckBox = CreateFrame("CheckButton", nil, MainFrame, "UICheckButtonTemplate");
	MainFrame.soloCheckBox:ClearAllPoints();
	MainFrame.soloCheckBox:SetSize(30, 30); -- width, height
	MainFrame.soloCheckBox:SetPoint("RIGHT", MainFrame.resetBtn, "LEFT", 0, -1);
	MainFrame.soloCheckBox:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				multiplayer = false;
			else
				multiplayer = true;
			end
		end);
	if (multiplayer) then
		MainFrame.soloCheckBox:SetChecked(false);
	else
		MainFrame.soloCheckBox:SetChecked(true);
	end



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


	ConfigFrame = CreateFrame("Frame", "TicTacToe_ConfigFrame", MainFrame, "BasicFrameTemplateWithInset");
	ConfigFrame:SetSize(MainFrame:GetWidth(), 80); -- width, height
	ConfigFrame:SetPoint("TOP", MainFrame, "BOTTOM"); -- point, relativeFrame, relativePoint, xOffset, yOffset
	ConfigFrame.title = ConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.title:SetPoint("LEFT", ConfigFrame.TitleBg, "LEFT", 5, 0);
	ConfigFrame.title:SetText("Configuration");
	ConfigFrame:Hide();

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

--------------------------------------
-- Config functions
--------------------------------------
function Config:Exit()
	SendChatMessage("has quit the game.", "EMOTE");
	myTurn = true;
	playerTwo = "";
	playerX = true;
	--multiplayer = false;
	blackList = "";
	counter = 0;
	win = false;
	MainFrame:Hide();
	ConfigFrame:Hide();
	ConfigFrame = nil;
	MainFrame.title:SetText(Title);
	MainFrame = nil;
end

function Config:Reset()
	core.commands.exit();
	core.commands.start();
end

function Config:Multiplayer()
	print("1");
	--if (MainFrame) then
		if (multiplayer) then
			MainFrame.soloCheckBox:SetChecked(false);
			multiplayer = false;
			print("2");
		else
			MainFrame.soloCheckBox:SetChecked(true);
			multiplayer = true;
			print("3");
		end
	--end
end

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

local function Field_Onclick(self)
	if (multiplayer) then
		if (playerX) then
			SendChatMessage("has put an X on the field : " .. self:GetID(), "EMOTE");
		else
			SendChatMessage("has put an O on the field : " .. self:GetID(), "EMOTE");
		end
	end

	SelectField(self:GetID());
	if (multiplayer) then
		myTurn = false;
	end

	if (multiplayer) then
		DisableFields();
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



--------------------------------------
-- Functions
--------------------------------------
function SelectField(key)
	if (string.find(blackList, tostring(key))) then
	else
		MainFrame.field[tonumber(key)]:Disable();
		counter = counter + 1;
		if (playerX == true) then
			MainFrame.field[key]:SetText("X");
			playerX = false;
		else
			MainFrame.field[key]:SetText("O");
			playerX = true;
		end

		blackList = blackList .. key;

		if (counter >= 5) then
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
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[4]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[4]:GetText() == MainFrame.field[6]:GetText()) and (MainFrame.field[4]:GetText() ~= nil)) then
				MainFrame.field[4]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[6]:LockHighlight();
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[7]:GetText() == MainFrame.field[8]:GetText()) and (MainFrame.field[7]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[7]:GetText() ~= nil)) then
				MainFrame.field[7]:LockHighlight();
				MainFrame.field[8]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[1]:GetText() == MainFrame.field[4]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[7]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[4]:LockHighlight();
				MainFrame.field[7]:LockHighlight();
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[2]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[2]:GetText() == MainFrame.field[8]:GetText()) and (MainFrame.field[2]:GetText() ~= nil)) then
				MainFrame.field[2]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[8]:LockHighlight();
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[3]:GetText() == MainFrame.field[6]:GetText()) and (MainFrame.field[3]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[3]:GetText() ~= nil)) then
				MainFrame.field[3]:LockHighlight();
				MainFrame.field[6]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[1]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[3]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[3]:GetText() == MainFrame.field[7]:GetText()) and (MainFrame.field[3]:GetText() ~= nil)) then
				MainFrame.field[3]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[7]:LockHighlight();
				if (myTurn == true) and (multiplayer) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (multiplayer) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end
		end
	end

	if (counter >= 9) and (win == false) then
		if (multiplayer) then
			DoEmote("APPLAUD");
		end
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

		if (#argsMsg[#argsMsg] ~= 1) then
			return
		end
		
		local argsSnd = {};
		for _, arg in ipairs({ string.split('-', sender) }) do
			if (#arg > 0) then
				table.insert(argsSnd, arg);
			end
		end

		if (argsMsg[#argsMsg] == "at-x0g") then
			EnableFields();
			for i = 1, #blackList do
				local c = blackList:sub(i,i)
				MainFrame.field[tonumber(c)]:Disable();
			end
		end


		if (argsSnd[1] ~= UnitName("player")) then
			if (#playerTwo > 0) then
			else
				playerTwo = argsSnd[1];
				MainFrame.title:SetText(playerOne .. " VS " .. playerTwo);
			end

			EnableFields();

			for i = 1, #blackList do
				local c = blackList:sub(i,i)
				MainFrame.field[tonumber(c)]:Disable();
			end

			
			SelectField(tonumber(argsMsg[#argsMsg]));
			myTurn = true;
		end
	end
end


---------------------------------
-- Events
---------------------------------
local msg = CreateFrame("Frame");
msg:RegisterEvent("CHAT_MSG_EMOTE");
msg:SetScript("OnEvent", ReceiveInput);





