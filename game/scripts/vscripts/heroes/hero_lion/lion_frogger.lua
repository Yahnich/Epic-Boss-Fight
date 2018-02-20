lion_frogger = class({})
LinkLuaModifier( "modifier_lion_frogger", "heroes/hero_lion/lion_frogger.lua",LUA_MODIFIER_MOTION_NONE )

function lion_frogger:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function lion_frogger:OnSpellStart()
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()
	
    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    EmitSoundOnLocationWithCaster(point, "Hero_Lion.Voodoo", caster)

    local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius"), {})
    if #enemies < 1 then
        self:RefundManaCost()
        self:EndCooldown()
    end
    
    for _,enemy in pairs(enemies) do
        ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", PATTACH_POINT, enemy, {})

        enemy:AddNewModifier(caster, self, "modifier_lion_frogger", {Duration = self:GetTalentSpecialValueFor("duration")})
        enemy:DisableHealing(self:GetTalentSpecialValueFor("duration"))
    end
end

modifier_lion_frogger = class({})
function modifier_lion_frogger:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_lion_frogger:OnIntervalThink()
    local caster = self:GetCaster()

    if caster:HasTalent("special_bonus_unique_lion_frogger_2") then
        local damage = (caster:GetIntellect()*caster:FindTalentValue("special_bonus_unique_lion_frogger_2")/100)/self:GetTalentSpecialValueFor("duration")
        self:GetAbility():DealDamage(caster, self:GetParent(), damage, {}, 0)

        self:StartIntervalThink(1.0)
    end
end

function modifier_lion_frogger:CheckState()
    local state = { [MODIFIER_STATE_SILENCED] = true,
                    [MODIFIER_STATE_MUTED] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_EVADE_DISABLED] = true,
                    [MODIFIER_STATE_PASSIVES_DISABLED] = true
                    }
    return state
end

function modifier_lion_frogger:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_lion_frogger:GetModifierMoveSpeedOverride()
    return 140
end

function modifier_lion_frogger:GetModifierModelChange()
    return "models/props_gameplay/frog.vmdl"
end

function modifier_lion_frogger:GetModifierMoveSpeed_Max()
    return 140
end

function modifier_lion_frogger:GetModifierMoveSpeed_Limit()
    return 140
end

function modifier_lion_frogger:GetModifierIncomingDamage_Percentage()
    if self:GetCaster():HasTalent("special_bonus_unique_lion_frogger_1") then
        return self:GetCaster():FindTalentValue("special_bonus_unique_lion_frogger_1")
    end

    return 0
end