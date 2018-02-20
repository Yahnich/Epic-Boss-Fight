lion_death_finger = class({})
LinkLuaModifier( "modifier_lion_death_finger_root", "heroes/hero_lion/lion_death_finger.lua",LUA_MODIFIER_MOTION_NONE )

function lion_death_finger:OnSpellStart()
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()

    local radius = self:GetSpecialValueFor("radius")
    local startPos = caster:GetAbsOrigin()
    local endPos = startPos + caster:GetForwardVector()*self:GetTrueCastRange()

    EmitSoundOn("Hero_Lion.FingerOfDeath", caster)
    EmitSoundOnLocationWithCaster(point, "Hero_Lion.FingerOfDeathImpact", caster)

    local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, self:GetSpecialValueFor("radius"), {flag=DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
    if #enemies < 1 then
        self:RefundManaCost()
        self:EndCooldown()
    end

    for _,enemy in pairs(enemies) do
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_POINT, caster)
        ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(nfx, 2, enemy:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(nfx)

        self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
        local hpDamage = enemy:GetMaxHealth()*self:GetSpecialValueFor("hp")/100
        self:DealDamage(caster, enemy, hpDamage, {damage_type=DAMAGE_TYPE_PURE, damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)

        if caster:HasTalent("special_bonus_unique_lion_death_finger_2") then
            enemy:AddNewModifier(caster, self, "modifier_lion_death_finger_root", {Duration = caster:FindTalentValue("special_bonus_unique_lion_death_finger_2")})
        end
    end

    if caster:HasTalent("special_bonus_unique_lion_death_finger_1") then
        Timers:CreateTimer(caster:FindTalentValue("special_bonus_unique_lion_death_finger_1"), function()
            local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, self:GetSpecialValueFor("radius"), {flag=DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
            if #enemies > 0 then
                for _,enemy in pairs(enemies) do
                    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControl(nfx, 2, enemy:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(nfx)

                    self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
                    local hpDamage = enemy:GetMaxHealth()*self:GetSpecialValueFor("hp")/100
                    self:DealDamage(caster, enemy, hpDamage, {damage_type=DAMAGE_TYPE_PURE, damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
                end
            end
        end)
    end
end

modifier_lion_death_finger_root = class({})
function modifier_lion_death_finger_root:CheckState()
    local state = {[MODIFIER_STATE_ROOTED] = true}
    return state
end

function modifier_lion_death_finger_root:GetEffectName()
    return "particles/econ/items/warlock/warlock_staff_hellborn/warlock_upheaval_hellborn_debuff.vpcf"
end