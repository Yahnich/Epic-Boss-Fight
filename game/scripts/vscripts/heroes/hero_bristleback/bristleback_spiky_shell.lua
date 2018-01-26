bristleback_spiky_shell = class({})
LinkLuaModifier( "modifier_spiky_shell", "heroes/hero_bristleback/bristleback_spiky_shell.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_quills_enemy", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_spiky_shell:GetIntrinsicModifierName()
	return "modifier_spiky_shell"
end

modifier_spiky_shell = class({})
function modifier_spiky_shell:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_spiky_shell:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetCaster() then
			local ability = self:GetCaster():FindAbilityByName("bristleback_quills")
			if RollPercentage(self:GetTalentSpecialValueFor("chance")) and ability:IsTrained() then
				ability:Spray(true)
			end
		end
	end
end

function modifier_spiky_shell:GetModifierIncomingDamage_Percentage()
	return self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_spiky_shell:IsHidden()
	return true
end