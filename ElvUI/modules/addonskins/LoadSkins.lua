﻿--[[	
	(C)2010 Darth Android / Telroth-Black Dragonflight
]]

Mod_AddonSkins = CreateFrame("Frame")
local Mod_AddonSkins = Mod_AddonSkins
local ElvDB = ElvDB
local ElvCF = ElvCF

local elvskin = ElvDB.SetTemplate
local function skinFrame(self, frame)
	--Unfortionatly theres not a prettier way of doing this
	if frame:GetParent():GetName() == "Recount_ConfigWindow" then
		ElvDB.SetTransparentTemplate(frame)
		frame:SetFrameStrata("BACKGROUND")
		frame.SetFrameStrata = ElvDB.dummy
	elseif frame:GetName() == "OmenBarList" or 
	frame:GetName() == "OmenTitle" or 
	frame:GetName() == "DXEPane" or 
	frame:GetName() == "SkadaBG" or 
	frame:GetParent():GetName() == "Recount_MainWindow" or 
	frame:GetParent():GetName() == "Recount_GraphWindow" or 
	frame:GetParent():GetName() == "Recount_DetailWindow" then
		ElvDB.SetTransparentTemplate(frame)
		if frame:GetParent():GetName() ~= "Recount_GraphWindow" and frame:GetParent():GetName() ~= "Recount_DetailWindow" then
			frame:SetFrameStrata("MEDIUM")
		else
			frame:SetFrameStrata("BACKGROUND")
		end
	else
		elvskin(frame,frame)
	end
end
local function skinButton(self, button)
	skinFrame(self, button)
	-- Crazy hacks which only work because self = Skin *AND* self = config
	local name = button:GetName()
	local icon = _G[name.."Icon"]
	if icon then
		icon:SetTexCoord(unpack(self.buttonZoom))
		icon:SetDrawLayer("ARTWORK")
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT",button,"TOPLEFT",self.borderWidth, -self.borderWidth)
		icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-self.borderWidth, self.borderWidth)
	end
end

Mod_AddonSkins.SkinFrame = skinFrame
Mod_AddonSkins.SkinBackgroundFrame = skinFrame
Mod_AddonSkins.SkinButton = skinButton
Mod_AddonSkins.normTexture = ElvCF.media.normTex
Mod_AddonSkins.bgTexture = ElvCF.media.blank
Mod_AddonSkins.font = ElvCF.media.font
Mod_AddonSkins.smallFont = ElvCF.media.font
Mod_AddonSkins.fontSize = 12
Mod_AddonSkins.buttonSize = ElvDB.Scale(27,27)
Mod_AddonSkins.buttonSpacing = ElvDB.Scale(ElvDB.petbuttonspacing,ElvDB.petbuttonspacing)
Mod_AddonSkins.borderWidth = ElvDB.Scale(2,2)
Mod_AddonSkins.buttonZoom = {.09,.91,.09,.91}
Mod_AddonSkins.barSpacing = ElvDB.Scale(1,1)
Mod_AddonSkins.barHeight = ElvDB.Scale(20,20)
Mod_AddonSkins.skins = {}

-- Dummy function expected by some skins
function dummy() end


function Mod_AddonSkins:RegisterSkin(name, initFunc)
	self = Mod_AddonSkins -- Static function
	if type(initFunc) ~= "function" then error("initFunc must be a function!",2) end
	self.skins[name] = initFunc
end

Mod_AddonSkins:RegisterEvent("PLAYER_LOGIN")
Mod_AddonSkins:RegisterEvent("PLAYER_ENTERING_WORLD")
Mod_AddonSkins:SetScript("OnEvent",function(self, event, addon)
	if event == "PLAYER_LOGIN" then
		-- Initialize all skins
		for name, func in pairs(self.skins) do
			func(self,self,self,self,self) -- Mod_AddonSkins functions as skin, layout, and config.
		end
		self:UnregisterEvent("PLAYER_LOGIN")
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:SetScript("OnEvent",nil)
		-- Embed Right
		if ElvCF["skin"].embedright == "Skada" and IsAddOnLoaded("Skada") then
			SkadaBarWindowSkada:ClearAllPoints()
			SkadaBarWindowSkada:SetPoint("TOPRIGHT", ChatRBackground2, "TOPRIGHT", -2, -2)
			local function AdjustSkadaFrameLevels()
				SkadaBarWindowSkada:SetFrameLevel(ChatFrame3:GetFrameLevel() + 2)
				if SkadaBG then
					SkadaBG:SetFrameStrata("MEDIUM")	
					SkadaBG:ClearAllPoints()
					SkadaBG:SetAllPoints(ChatRBackground2)
					SkadaBarWindowSkada:SetFrameStrata("HIGH")
				end
			end
			
			SkadaBarWindowSkada:HookScript("OnShow", AdjustSkadaFrameLevels)
			--trick game into firing OnShow script so we can adjust the frame levels
			SkadaBarWindowSkada:Hide()
			SkadaBarWindowSkada:Show()
		end
		if ElvCF["skin"].embedright == "Recount" and IsAddOnLoaded("Recount") then
			Recount.db.profile.FrameStrata = "4-HIGH"
			Recount_MainWindow:ClearAllPoints()
			Recount_MainWindow:SetPoint("TOPLEFT", ChatRBackground2,"TOPLEFT", 0, 7)
			Recount_MainWindow:SetPoint("BOTTOMRIGHT", ChatRBackground2,"BOTTOMRIGHT", 0, 0)
			Recount.db.profile.MainWindowWidth = (ElvCF["chat"].chatwidth - 4)
		elseif IsAddOnLoaded("Recount") then
			Recount.db.profile.FrameStrata = "4-HIGH"
		end
		if ElvCF["skin"].embedright == "Omen" and IsAddOnLoaded("Omen") then
			Omen.UpdateTitleBar = function() end
			ElvDB.Kill(OmenTitle)
			if IsAddOnLoaded("Omen") then
				OmenBarList:SetFrameStrata("HIGH")
			end
			OmenBarList:ClearAllPoints()
			OmenBarList:SetAllPoints(ChatRBackground2)
		end
		
		if ElvCF["chat"].showbackdrop == true and IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and ElvCF["skin"].hookdxeright == true and ElvCF["chat"].rightchat == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, 18)			
		elseif IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and ElvCF["skin"].hookdxeright == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, -5)
		end
	end
end)