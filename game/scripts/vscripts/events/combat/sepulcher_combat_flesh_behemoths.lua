local function StartEvent(self)
	self:StartCombatRound()
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_flesh_behemoth", context)
	PrecacheUnitByNameSync("npc_dota_boss3a_b", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs