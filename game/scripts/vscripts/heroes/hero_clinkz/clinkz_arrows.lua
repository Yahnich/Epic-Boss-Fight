clinkz_arrows = class({})
LinkLuaModifier("modifier_clinkz_arrows_caster", "heroes/hero_clinkz/clinkz_arrows", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_clinkz_arrows_line", "heroes/hero_clinkz/clinkz_arrows", LUA_MODIFIER_MOTION_NONE)

function clinkz_arrows:IsStealable()
	return false
end

function clinkz_arrows:IsHiddenWhenStolen()
	return false
end

function clinkz_arrows:GetIntrinsicModifierName()
	return "modifier_clinkz_arrows_caster"
end

function clinkz_arrows:GetCastRange(vLocation, hTarget)
	return self:GetCaster():GetAttackRange()
end

function clinkz_arrows:GetCastPoint()
	if IsServer() then 
		return self:GetCaster():GetCastPoint( true ) / self:GetCaster():GetAttackSpeed()
	end
end

function clinkz_arrows:GetManaCost(iLvl)
	if self:GetCaster():GetClassname() == "npc_dota_clinkz_skeleton_archer" then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function clinkz_arrows:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1/caster:GetSecondsPerAttack())
	return true
end

function clinkz_arrows:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	
	caster:RemoveGesture(ACT_DOTA_ATTACK)

	EmitSoundOn("Hero_Clinkz.SearingArrows", caster)
	
	self:FireTrackingProjectile("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)	

	if caster:HasTalent("special_bonus_unique_clinkz_arrows_2") then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange() + 10)
		for _,enemy in pairs(enemies) do
			if enemy ~= target then
				self:FireTrackingProjectile("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", enemy, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 50)	
				break
			end
		end
	end

	if caster:HasScepter() then
		local modifier = caster:FindModifierByName("modifier_clinkz_arrows_caster")
		if modifier.current >= modifier.max then
			local duration = 5
			local endPos = target:GetAbsOrigin()
			CreateModifierThinker(caster, self, "modifier_clinkz_arrows_line", {Duration = duration, x = endPos.x, y = endPos.y, z = endPos.z}, caster:GetAbsOrigin(), caster:GetTeam(), false)
			modifier.current = 0
		else
			modifier.current = modifier.current + 1
		end
	end
end

function clinkz_arrows:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"), {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
		local damage = self:GetTalentSpecialValueFor("damage")
		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_Clinkz.SearingArrows.Impact", enemy)
			self:DealDamage(caster, enemy, damage)
		end
	end
end

modifier_clinkz_arrows_caster = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

function modifier_clinkz_arrows_caster:OnCreated(table)
	if IsServer() then
		self.max = 5
		self.current = 0
	end
end

function modifier_clinkz_arrows_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function modifier_clinkz_arrows_caster:OnAttack(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		local attacker = keys.attacker
		local ability = self:GetAbility()

		if caster == attacker and ( ability:IsOwnersManaEnough() and ability:GetAutoCastState() or caster.forceSearingArrows ) then
			EmitSoundOn("Hero_Clinkz.SearingArrows", caster)

			ability:FireTrackingProjectile("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 50)	
			
			if caster:HasTalent("special_bonus_unique_clinkz_arrows_2") then
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange() + 10)
				for _,enemy in pairs(enemies) do
					if enemy ~= target then
						ability:FireTrackingProjectile("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", enemy, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 50)	
						break
					end
				end
			end

			if caster:HasScepter() then
				if self.current >= self.max then
					local duration = 5
					CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_clinkz_arrows_line", {Duration = duration, x = target:GetAbsOrigin().x, y = target:GetAbsOrigin().y, z = target:GetAbsOrigin().z}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeam(), false)
					self.current = 0
				else
					self.current = self.current + 1
				end
			end
			if not caster.forceSearingArrows then
				ability:UseResources(true, false, false)
			end
			caster.forceSearingArrows = false
		end
	end
end

modifier_clinkz_arrows_line = modifier_clinkz_arrows_line or class({})

function modifier_clinkz_arrows_line:OnCreated(table)
	if IsServer() then
		self.startPos = self:GetParent():GetAbsOrigin()
		self.endPos = Vector(table.x, table.y, table.z)

		self.damage = self:GetTalentSpecialValueFor("damage")*2

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_explosive_arrows_trail.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self.startPos)
					ParticleManager:SetParticleControl(nfx, 1, self.endPos)
					ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetDuration(), 0, 0))
					ParticleManager:SetParticleControl(nfx, 3, self.endPos)

		self:AttachEffect(nfx)
		
		self:StartIntervalThink(0.5)
	end
end

function modifier_clinkz_arrows_line:OnIntervalThink()
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInLine(self.startPos, self.endPos, 50, {})
	for _,enemy in pairs(enemies) do
		self:GetAbility():DealDamage(caster, enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end