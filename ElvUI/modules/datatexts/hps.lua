local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

--------------------------------------------------------------------
-- SUPPORT FOR HPS Feed... 
--------------------------------------------------------------------

if ElvCF["datatext"].hps_text and ElvCF["datatext"].hps_text > 0 then
	local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}
	local HPS_FEED = CreateFrame("Frame")
	local player_id = UnitGUID("player")
	local actual_heals_total, cmbt_time = 0
 
	hText = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
	hText:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	hText:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	hText:SetText("HPS: "..ElvDB.ValColor.."0.0")
 
	ElvDB.PP(ElvCF["datatext"].hps_text, hText)
 
	HPS_FEED:EnableMouse(true)
	HPS_FEED:SetFrameStrata("MEDIUM")
	HPS_FEED:SetFrameLevel(3)
	HPS_FEED:SetHeight(ElvDB.Scale(20))
	HPS_FEED:SetWidth(ElvDB.Scale(100))
	HPS_FEED:SetAllPoints(hText)
 
	HPS_FEED:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	HPS_FEED:RegisterEvent("PLAYER_LOGIN")
 
	HPS_FEED:SetScript("OnUpdate", function(self, elap)
		if UnitAffectingCombat("player") then
			HPS_FEED:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmbt_time = cmbt_time + elap
		else
			HPS_FEED:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		hText:SetText(get_hps())
	end)
 
	function HPS_FEED:PLAYER_LOGIN()
		HPS_FEED:RegisterEvent("PLAYER_REGEN_ENABLED")
		HPS_FEED:RegisterEvent("PLAYER_REGEN_DISABLED")
 
		player_id = UnitGUID("player")
     
		HPS_FEED:UnregisterEvent("PLAYER_LOGIN")
	end
 
	-- handler for the combat log. used http://www.wowwiki.com/API_COMBAT_LOG_EVENT for api
	function HPS_FEED:COMBAT_LOG_EVENT_UNFILTERED(...)         
		-- filter for events we only care about. i.e heals
		if not events[select(2, ...)] then return end
		if event == "PLAYER_REGEN_DISABLED" then return end

		-- only use events from the player
		local id = select(3, ...)
		if id == player_id then
			amount_healed = select(12, ...)
			amount_over_healed = select(13, ...)
			-- add to the total the healed amount subtracting the overhealed amount
			actual_heals_total = actual_heals_total + math.max(0, amount_healed - amount_over_healed)
		end
	end
 
	function HPS_FEED:PLAYER_REGEN_ENABLED()
		hText:SetText(get_hps)
	end
   
	function HPS_FEED:PLAYER_REGEN_DISABLED()
		cmbt_time = 0
		actual_heals_total = 0
	end
     
	HPS_FEED:SetScript("OnMouseDown", function (self, button, down)
		cmbt_time = 0
		actual_heals_total = 0
	end)
 
	function get_hps()
		if (actual_heals_total == 0) then
			return ("HPS: "..ElvDB.ValColor.."0.0")
		else
			return string.format("HPS: "..ElvDB.ValColor.."%.1f", (actual_heals_total or 0) / (cmbt_time or 1))
		end
	end

end