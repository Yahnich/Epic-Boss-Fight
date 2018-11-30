relic_cursed_battle_brew = class(relicBaseClass)

function relic_cursed_battle_brew:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,  MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function relic_cursed_battle_brew:Bonus_ThreatGain()
	return 50
end

function relic_cursed_battle_brew:GetModifierBonusStats_Strength()
	return 30
end

function relic_cursed_battle_brew:GetModifierAttackSpeedBonus()
	return 80
end

function relic_cursed_battle_brew:GetModifierMiss_Percentage()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return 20 end
end