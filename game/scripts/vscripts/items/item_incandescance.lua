item_incandescance = class({})

function item_incandescance:GetIntrinsicModifierName()
	return "modifier_item_incandescance_passive"
end

function item_incandescance:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_incandescance") then
		return "radiance/incandescance_"..self:GetLevel()
	else
		return "item_radiance_inactive"
	end
end

function item_incandescance:OnToggle()
	print( self:GetToggleState(), self:GetName() )
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_incandescance")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_incandescance", {})
		print( "got got")
	end
end

item_incandescance_2 = class(item_incandescance)
item_incandescance_3 = class(item_incandescance)
item_incandescance_4 = class(item_incandescance)
item_incandescance_5 = class(item_incandescance)
item_incandescance_6 = class(item_incandescance)
item_incandescance_7 = class(item_incandescance)
item_incandescance_8 = class(item_incandescance)
item_incandescance_9 = class(item_incandescance)


LinkLuaModifier( "modifier_item_incandescance_passive", "items/item_incandescance.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_incandescance_passive = class(itemBasicBaseClass)

function modifier_item_incandescance_passive:OnCreatedSpecific()
	if IsServer() then
		self:GetAbility():OnToggle()
	end
end

function modifier_item_incandescance_passive:OnRefreshSpecific()
	if IsServer() then
		self:GetAbility():OnToggle()
	end
end

function modifier_item_incandescance_passive:OnDestroySpecific()
	if IsServer() and not self:GetCaster():HasModifier("modifier_item_incandescance_passive") then
		self:GetCaster():RemoveModifierByName("modifier_item_incandescance")
	end
end

LinkLuaModifier( "modifier_item_incandescance", "items/item_incandescance.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_incandescance = class(toggleModifierBaseClass)

function modifier_item_incandescance:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_incandescance:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_incandescance:IsAura()
	return true
end

function modifier_item_incandescance:GetModifierAura()
	return "modifier_incandescance_debuff"
end

function modifier_item_incandescance:GetAuraRadius()
	return self.radius
end

function modifier_item_incandescance:GetAuraDuration()
	return 0.5
end

function modifier_item_incandescance:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_incandescance:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_incandescance:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_incandescance:GetEffectName()
	return "particles/items2_fx/radiance_owner.vpcf"
end

function modifier_item_incandescance:IsHidden()    
	return true
end

LinkLuaModifier( "modifier_incandescance_debuff", "items/item_incandescance.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_incandescance_debuff = class({})

function modifier_incandescance_debuff:OnCreated()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self:StartIntervalThink(1)
	end
end

function modifier_incandescance_debuff:OnRefresh()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
end

function modifier_incandescance_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_incandescance_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_incandescance_debuff:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_incandescance_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_incandescance_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end