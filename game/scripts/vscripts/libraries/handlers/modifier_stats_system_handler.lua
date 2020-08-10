modifier_stats_system_handler = class({})

function modifier_stats_system_handler:OnCreated()
	self.statsInfo = {}
	if IsServer() then
		self.modifierFunctions = {}
		self:SetHasCustomTransmitterData( true )
		self:GetParent():CalculateStatBonus()
		self:UpdateStatValues()
	end
end

function modifier_stats_system_handler:OnRefresh(iStacks)
	if IsServer() then
		self:SetHasCustomTransmitterData( true )
		self:GetParent():CalculateStatBonus()
		self:UpdateStatValues()
	end
end

function modifier_stats_system_handler:UpdateStatValues()
	local entindex = self:GetCaster():entindex()
	if self:GetCaster():GetParentUnit() then
		entindex = self:GetCaster():GetParentUnit():entindex()
	end
	local netTable = CustomNetTables:GetTableValue("stats_panel", tostring(entindex) ) or {}
	self.statsInfo.ms = 0
	self.statsInfo.mp = 0
	self.statsInfo.mpr = 0
	self.statsInfo.ha = 0
	self.statsInfo.ad = 0
	self.statsInfo.sa = 0
	self.statsInfo.sta = 0
	-- DEFENSE
	self.statsInfo.pr = 0
	self.statsInfo.mr = 0
	
	self.statsInfo.ard = 0
	
	self.statsInfo.hp = 0
	self.statsInfo.hpr = 0
	self.statsInfo.sr = 0
	
	self.statsInfo.as = 0
	-- if self.modifierFunctions["GetModifierAttackSpeedBonus"] then
		-- for modifier, active in pairs( self.modifierFunctions["GetModifierAttackSpeedBonus"] ) do
			-- if modifier:IsNull() then
				-- self.modifierFunctions["GetModifierAttackSpeedBonus"][modifier] = nil
			-- elseif active and modifier.GetModifierAttackSpeedBonus then
				-- self.statsInfo.critChance = self.statsInfo.critChance + (modifier:GetModifierAttackSpeedBonus() or 0)
			-- end
		-- end
	-- end
	self.statsInfo.critChance = 0
	if self.modifierFunctions["GetModifierBaseCriticalChanceBonus"] then
		for modifier, active in pairs( self.modifierFunctions["GetModifierBaseCriticalChanceBonus"] ) do
			if modifier:IsNull() then
				self.modifierFunctions["GetModifierBaseCriticalChanceBonus"][modifier] = nil
			elseif active and modifier.GetModifierBaseCriticalChanceBonus then
				self.statsInfo.critChance = self.statsInfo.critChance + (modifier:GetModifierBaseCriticalChanceBonus() or 0)
			end
		end
	end
	self.statsInfo.critDamage = 0
	if self.modifierFunctions["GetModifierBaseCriticalDamageBonus"] then
		for modifier, active in pairs( self.modifierFunctions["GetModifierBaseCriticalDamageBonus"] ) do
			if modifier:IsNull() then
				self.modifierFunctions["GetModifierBaseCriticalDamageBonus"][modifier] = nil
			elseif active and modifier.GetModifierBaseCriticalDamageBonus then
				self.statsInfo.critDamage = self.statsInfo.critDamage + (modifier:GetModifierBaseCriticalDamageBonus() or 0)
			end
		end
	end
end

function modifier_stats_system_handler:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		-- MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		-- MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_TAKEDAMAGE 
	}
	return funcs
end

function modifier_stats_system_handler:GetModifierMoveSpeedBonus_Percentage() return self:GetParent():GetAgility() * 0.075 end
function modifier_stats_system_handler:GetModifierManaBonus() return 500 + (self.statsInfo.mp or 0) end
function modifier_stats_system_handler:GetModifierConstantManaRegen() return 1.5 + (self.statsInfo.mpr or 0) - self:GetParent():GetIntellect() * 0.05 end
	
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage()
	return self:GetParent():GetIntellect() * 0.25 + (self.statsInfo.sa or 0) 
end

-- function modifier_stats_system_handler:GetCooldownReduction() return self.cdr or 0 end
function modifier_stats_system_handler:GetModifierAttackSpeedBonus() return 50 end

function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage()
	return 0.15 * self:GetParent():GetStrength()
end

function modifier_stats_system_handler:GetModifierPhysicalArmorBonus()
	local bonusarmor = 0
	if not self:GetParent():IsRangedAttacker() then bonusarmor = 3 end
	return ( self.statsInfo.pr or 0 ) + bonusarmor
end

function modifier_stats_system_handler:GetModifierExtraHealthBonus() return 300 + (self.statsInfo.hp or 0) end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() return 1 + (self.statsInfo.hpr or 0) - self:GetParent():GetStrength() * 0.1 end
function modifier_stats_system_handler:GetModifierStatusResistance() return ( 1 - ( (1-(self.statsInfo.sr or 0)/100) ) ) * 100  end

function modifier_stats_system_handler:GetModifierEvasion_Constant() return 5 + (self.statsInfo.evasion or 0) + (1-(1-0.0035)^self:GetParent():GetAgility())*100 end
function modifier_stats_system_handler:GetModifierPreAttack_CriticalStrike()
	local critChance =  5 + (self.statsInfo.critChance or 0)
	local critAdded = 75 + (self.statsInfo.critDamage or 0) + self:GetParent():GetStrength()
	local critDamage = 100 + critAdded
	local crit = false
	while critChance > 100 do
		critDamage = critDamage + critAdded
		critChance = critChance - 100
		crit = true
	end
	if self:RollPRNG( critChance ) then
		crit = true
		critDamage = critDamage + critAdded
	end
	if crit then
		return critDamage
	end
end

function modifier_stats_system_handler:OnTakeDamage( params )
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local lifesteal = (1-(1-0.00125)^self:GetParent():GetIntellect())
		if params.inflictor and params.unit:IsMinion() then
				lifesteal = lifesteal / 4
		end
		if self.modifierFunctions["GetModifierLifestealBonus"] then
			for modifier, active in pairs( self.modifierFunctions["GetModifierLifestealBonus"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierLifestealBonus"][modifier] = nil
				elseif active and modifier.GetModifierLifestealBonus then
					lifesteal = lifesteal + (modifier:GetModifierLifestealBonus( params ) or 0) / 100
				end
			end
		end
		local flHeal = math.ceil(params.damage * lifesteal)
		params.attacker:HealEvent(flHeal, params.inflictor, params.attacker)
	end
end

function modifier_stats_system_handler:AddCustomTransmitterData( )
	return
	{
		statsInfo = self.statsInfo
	}
end

--------------------------------------------------------------------------------

function modifier_stats_system_handler:HandleCustomTransmitterData( data )
	self.statsInfo = table.copy( data.statsInfo )
end

function modifier_stats_system_handler:IsHidden()
	return true
end

function modifier_stats_system_handler:IsPermanent()
	return true
end

function modifier_stats_system_handler:IsPurgable()
	return false
end

function modifier_stats_system_handler:RemoveOnDeath()
	return false
end

function modifier_stats_system_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end