local Addon = CreateFrame("FRAME", "HeatingUp");

local frameAnchor;
local frameIcon;

local spellTable = {
	Pyroblast = 1,
	Scorch = 1,
	Fireblast = 1,
	FrostfireBolt = 1,
	MindBlast = 1,
	MindSpike = 1
};


local function setFrameIcon()
	frameIcon = CreateFrame("FRAME", nil, UIParent);
	frameIcon:SetSize(32, 32);
	frameIcon:SetPoint("TOPLEFT", frameAnchor, 0, 0);

	frameIcon.icon = frameIcon:CreateTexture("IconTexture", "BACKGROUND");
	frameIcon.icon:SetWidth(64);
	frameIcon.icon:SetHeight(64);
	frameIcon.icon:SetPoint("CENTER", 0, 0);
	frameIcon.icon:SetTexture("Interface\\ICONS\\Ability_mage_hotstreak.png");

	frameIcon:Hide();

	return frameIcon;
end


local function initFrameAnchor()
	frameAnchor = CreateFrame("FRAME", "HUVanchor", UIParent);
	frameAnchor:SetSize(32, 32);
	frameAnchor:SetPoint("CENTER", UIParent, "CENTER");

	frameAnchor.icon = frameAnchor:CreateTexture("IconTexture", "BACKGROUND");
	frameAnchor.icon:SetWidth(32)
	frameAnchor.icon:SetHeight(32)
	frameAnchor.icon:SetPoint("TOPLEFT", 0, 0)
	frameAnchor.icon:SetTexture("Interface\\ICONS\\Ability_mage_hotstreak.png");


	frameAnchor:EnableMouse(true)
	frameAnchor:SetMovable(true);


	frameAnchor:SetScript("OnMouseDown", function(self, button)
		if(button == "LeftButton") then
			self:StartMoving();
		end
	end)
	frameAnchor:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing();
		local point,_,relativePoint,x,y = self:GetPoint();
		HeatingUpSV[UnitName("player")] = { point, relativePoint, x, y };
	end)

	frameAnchor:Hide();
end


SLASH_HeatingUp1, SLASH_HeatingUp2 = "/heatingup", "/hu";

function SlashCmd(cmd)
	if (cmd:match"unlock") then
		frameAnchor:Show();
	elseif (cmd:match"lock") then
		frameAnchor:Hide();
	end
end

SlashCmdList["HeatingUp"] = SlashCmd;


Addon:SetScript("OnEvent", function(self, event, ...)
	if(event == "VARIABLES_LOADED") then
		initFrameAnchor();
		setFrameIcon();
		if type(HeatingUpSV) ~= "table" then
			HeatingUpSV = {};
			local point, relativePoint, x, y = frameAnchor:GetPoint();
			HeatingUpSV[UnitName("player")] = { point, relativePoint, x, y};
		elseif(HeatingUpSV[UnitName("player")]) then
			local point, relativePoint, x, y = HeatingUpSV[UnitName("player")][1], HeatingUpSV[UnitName("player")][2], HeatingUpSV[UnitName("player")][3], HeatingUpSV[UnitName("player")][4];
			frameAnchor:SetPoint(point, UIParent, relativePoint, x, y);
		else
			local point, relativePoint, x, y = frameAnchor:GetPoint();
			HeatingUpSV[UnitName("player")] = { point, relativePoint, x, y};
		end
	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local time, type, _, _, sourceName, _, _, _, _, _, _, spellID, spellName, _, _, _, _, _, _, _, critical = ...;
		if(type == "SPELL_AURA_APPLIED" and sourceName == UnitName("player") and (spellID == 48108 or spellID == 87160)) then
			print("Hot Streak is up!");
			frameIcon:Hide();
		elseif(type == "SPELL_DAMAGE" and sourceName == UnitName("player") and spellTable[string.gsub(spellName, "%s+", "")]) then
			if(critical) then
				print("crit'ed with " .. spellName);
				frameIcon:Show();
			else
				print("missed crit with " .. spellName);
				frameIcon:Hide();
			end
		end
	else -- (event == "PLAYER_DEAD") or (event == "PLAYER_ENTERING_WORLD") then
		frameIcon:Hide();
	end
end)


Addon:RegisterEvent("VARIABLES_LOADED");
Addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
Addon:RegisterEvent("PLAYER_DEAD");
Addon:RegisterEvent("PLAYER_ENTERING_WORLD");