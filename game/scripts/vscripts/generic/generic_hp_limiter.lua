generic_hp_limiter = class({})

function generic_hp_limiter:GetIntrinsicModifierName()
	return "modifier_generic_hp_limiter"
end

modifier_generic_hp_limiter = class({})
LinkLuaModifier("modifier_generic_hp_limiter", "generic/generic_hp_limiter.lua", 0)

function modifier_generic_hp_limiter:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_generic_hp_limiter:GetModifierIncomingDamage_Percentage(params)
	local parent = self:GetParent()
	if params.inflictor then
		return -999
	else
		local hp = parent:GetHealth()
		local damage = 4
		if not ( params.attacker:IsRealHero() or params.attacker:IsRoundNecessary() ) then damage = 1 end
		if damage < hp and params.inflictor ~= self:GetAbility() then
			parent:SetHealth( hp - damage )
			return -999
		elseif hp <= 1 then
			self:GetParent():StartGesture(ACT_DOTA_DIE)
			parent:Kill(params.inflictor, params.attacker)
		end
	end
end

function modifier_generic_hp_limiter:GetModifierHealAmplify_Percentage( params )
	if not params.ability then
		return -999
	else
		local hp = self:GetParent():GetHealth()
		heal = math.floor( math.log10( params.heal / GameRules:GetGameDifficulty() ) + 0.5 )
		if heal > 0 then
			self:GetParent():SetHealth( hp + heal )
		end
	end
end

function modifier_generic_hp_limiter:IsHidden()
	return false
end