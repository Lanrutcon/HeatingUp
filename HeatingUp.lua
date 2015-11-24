local Addon = CreateFrame("FRAME", "HeatingUp");

local frameAnchor;
local frameIcon;

local spellTable = {
	[133] = true,
	[11366] = true,
	[2948] = true,
	[2136] = true,
	[44614] = true,
};


local function setFrameIcon()
	frameIcon = CreateFrame("FRAME", "FrameIcon", UIParent, "SpellActivationOverlayTemplate");
	frameIcon:SetSize(32, 32);
	frameIcon:SetPoint("TOPLEFT", frameAnchor, 0, 0);

	frameIcon.icon = frameIcon:CreateTexture("IconTexture", "BACKGROUND");
	frameIcon.icon:SetPoint("CENTER", 0, 0);
	frameIcon.icon:SetTexture("TEXTURES\\SPELLACTIVATIONOVERLAYS\\HOT_STREAK.BLP");

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
	frameAnchor.icon:SetTexture("Interface\\UnitPowerBarAlt\\Generic1Target_Circular_Frame.png");

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
		if(type == "SPELL_AURA_APPLIED" and sourceName == UnitName("player") and spellID == 48108) then
			frameIcon:Hide();
		elseif(type == "SPELL_DAMAGE" and sourceName == UnitName("player") and spellTable[spellID]) then
			if(critical) then
				frameIcon:Show();
			else
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