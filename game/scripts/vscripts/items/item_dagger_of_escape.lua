item_dagger_of_escape = class({})
LinkLuaModifier( "modifier_item_dagger_of_escape_passive", "items/item_dagger_of_escape.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_dagger_of_escape:GetIntrinsicModifierName()
	return "modifier_item_dagger_of_escape_passive"
end

function item_dagger_of_escape:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local distance = CalculateDistance( targetPos, caster )
	local direction = CalculateDirection( targetPos, caster )
	if distance > self:GetSpecialValueFor("blink_range") then
		targetPos = caster:GetAbsOrigin() + direction * self:GetSpecialValueFor("blink_range")
	end
	caster:Blink(targetPos)
end

function item_dagger_of_escape:GetRuneSlots()
	return self:GetSpecialValueFor("rune_slots")
end

item_dagger_of_escape_2 = class(item_dagger_of_escape)
item_dagger_of_escape_3 = class(item_dagger_of_escape)
item_dagger_of_escape_4 = class(item_dagger_of_escape)
item_dagger_of_escape_5 = class(item_dagger_of_escape)
item_dagger_of_escape_6 = class(item_dagger_of_escape)
item_dagger_of_escape_7 = class(item_dagger_of_escape)
item_dagger_of_escape_8 = class(item_dagger_of_escape)
item_dagger_of_escape_9 = class(item_dagger_of_escape)

modifier_item_dagger_of_escape_passive = class(itemBasicBaseClass)