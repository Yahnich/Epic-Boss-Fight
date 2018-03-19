item_gem_of_corruption = class({})

LinkLuaModifier( "modifier_item_gem_of_corruption", "items/item_gem_of_corruption.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_gem_of_corruption:GetIntrinsicModifierName()
	return "modifier_item_gem_of_corruption"
end

modifier_item_gem_of_corruption = class({})
function modifier_item_gem_of_corruption:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_gem_of_corruption:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gem_of_corruption_debuff", {Duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
	end
end

function modifier_item_gem_of_corruption:IsHidden()
	return true
end

LinkLuaModifier( "modifier_gem_of_corruption_debuff", "items/item_gem_of_corruption.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gem_of_corruption_debuff = class({})

function modifier_gem_of_corruption_debuff:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_gem_of_corruption_debuff:OnRefresh()
	self.armor = math.max(self.armor, self:GetAbility():GetSpecialValueFor("armor_reduction"))
end

function modifier_gem_of_corruption_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_gem_of_corruption_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end