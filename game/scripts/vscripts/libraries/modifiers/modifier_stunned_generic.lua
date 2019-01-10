modifier_stunned_generic = class({})

if IsServer() then
	function modifier_stunned_generic:OnCreated(kv)
		self:GetParent():Interrupt()
		self:GetParent():Stop()
		self:GetParent():StopMotionControllers(true)
		if kv.delay == nil or toboolean(kv.delay) == true and not self:GetParent():IsRoundNecessary() then
			self.delay = true
			self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		end
	end
	function modifier_stunned_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_stunned_generic:CheckState()
	return { [MODIFIER_STATE_STUNNED] = true }
end

function modifier_stunned_generic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, 
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}

	return funcs
end

function modifier_stunned_generic:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_stunned_generic:GetModifierFixedAttackRate( params )
	if self:GetParent():IsRoundNecessary() then
		return self:GetParent():GetBaseAttackTime() * 2
	end
end

function modifier_stunned_generic:GetModifierMoveSpeedOverride( params )
	if self:GetParent():IsRoundNecessary() then
		return 100
	end
end

function modifier_stunned_generic:GetMoveSpeedLimitBonus( params )
	if self:GetParent():IsRoundNecessary() then
		return -450
	end
end

function modifier_stunned_generic:GetModifierPercentageCasttime()
	return -100
end

function modifier_stunned_generic:GetModifierTurnRate_Percentage()
	return 95
end

function modifier_stunned_generic:IsPurgable()
	return true
end

function modifier_stunned_generic:IsStunDebuff()
	return true
end

function modifier_stunned_generic:IsPurgeException()
	return true
end

function modifier_stunned_generic:IsDebuff()
	return true
end

function modifier_stunned_generic:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_stunned_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stunned_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end