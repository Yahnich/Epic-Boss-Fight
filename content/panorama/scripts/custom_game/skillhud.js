// DEFAULT HUD INITIALIZATION
var lowerHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud")
var talentHud = lowerHud.FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var levelUp = lowerHud.FindChildTraverse("level_stats_frame")

var localID = Players.GetLocalPlayer()

lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "collapse";


lowerHud.FindChildTraverse("StatBranchDrawer").style.visibility = "visible";

talentHud.FindChildTraverse("StatBranch").SetPanelEvent("onmouseover", function(){});
talentHud.FindChildTraverse("StatBranch").SetPanelEvent("onmouseout", function(){});
talentHud.FindChildTraverse("StatBranch").SetPanelEvent("onactivate", ToggleStatsPanel);

levelUp.FindChildTraverse("LevelUpButton").SetPanelEvent("onactivate", ToggleStatsPanel);
levelUp.FindChildTraverse("LevelUpTab").SetPanelEvent("onactivate", ToggleStatsPanel);
levelUp.FindChildTraverse("LevelUpIcon").style.visibility = "collapse";
var levelLabel = $.CreatePanel("Label", $.GetContextPanel(), "LevelUpLabel");
levelLabel.SetParent( levelUp.FindChildTraverse("LevelUpButton") )
levelLabel.SetHasClass("LevelUpLabel", true)
levelLabel.text = "0"

// EVENT SUBSCRIPTION
GameEvents.Subscribe("dota_player_gained_level", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_learned_ability", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_update_query_unit", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_update_selected_unit", UpdateStatsPanel);
GameEvents.Subscribe("dota_player_upgraded_stats", UpdateStatsPanel);

// OTHER
MOVESPEED_TABLE = [0,20,40,60,80,150]
MANA_TABLE = [0,250,500,750,1000,1250,1500,1750,2000,2250,3000]
MANA_REGEN_TABLE = [0,3,6,9,12,15,18,21,24,27,50]
HEAL_AMP_TABLE = [0,10,20,30,40,80]

// OFFENSE
ATTACK_DAMAGE_TABLE = [0,20,40,60,80,100,120,140,160,180,250]
SPELL_AMP_TABLE = [0,10,15,20,25,30,35,40,45,50,75]
COOLDOWN_REDUCTION_TABLE = [0,10,12,15,18,25]
ATTACK_SPEED_TABLE = [0,20,40,60,80,100,120,140,160,180,250]
STATUS_AMP_TABLE = [0,10,15,20,35]

// DEFENSE
ARMOR_TABLE = [0,2,4,6,8,10,12,14,16,18,25]
MAGIC_RESIST_TABLE = [0,5,10,15,20,25,30,35,40,45,60]
DAMAGE_BLOCK_TABLE = [0,20,30,40,50,75]
ATTACK_RANGE_TABLE = [0,50,100,150,200,250,300,350,400,450,600]
HEALTH_TABLE = [0,150,300,450,600,750,900,1050,1200,1350,2000]
HEALTH_REGEN_TABLE = [0,3,6,9,12,15,18,21,24,27,50]
STATUS_REDUCTION_TABLE = [0,10,15,20,35]

STATS_STATE_OFFENSE = 1
STATS_STATE_DEFENSE = 2
STATS_STATE_OTHER = 3
STATS_STATE_UNIQUE = 4

LEVELS_BETWEEN_TALENT_UPGRADES = 4

var lastRememberedState = STATS_STATE_OFFENSE
var lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
var hasQueuedAction = false

$("#RootContainer").SetHasClass("IsHidden", true)

function ToggleStatsPanel()
{
	var statsPanel = $("#RootContainer");
	statsPanel.SetHasClass("IsHidden", !statsPanel.BHasClass("IsHidden") );
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	UpdateStatsPanel()
}

function RefreshStatsPanel()
{
	lastRememberedHero = Players.GetLocalPlayerPortraitUnit()
	if ( !Entities.IsRealHero( lastRememberedHero ) ){ 
		lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
	}

	if(lastRememberedState == STATS_STATE_OFFENSE){
		LoadOffenseLayout()
	} else if(lastRememberedState == STATS_STATE_DEFENSE){
		LoadDefenseLayout()
	} else if(lastRememberedState == STATS_STATE_OTHER){
		LoadOtherLayout()
	} else if(lastRememberedState == STATS_STATE_UNIQUE){
		LoadUniqueLayout()
	}
}

function UpdateStatsPanel()
{
	var selectedHero = Players.GetLocalPlayerPortraitUnit()
	if ( Entities.IsRealHero( selectedHero ) ){
		if ( selectedHero == Players.GetPlayerHeroEntityIndex( localID ) ){
			if( GetAttributePoints( selectedHero ) > 0){
				levelUp.style.visibility = "visible";
			} else {
				levelUp.style.visibility = "collapse";
			}
		} else {
			levelUp.style.visibility = "collapse";
		}
	} else {
		levelUp.style.visibility = "collapse";
	}
	// only refresh if talent panel is visible
	if( !($("#RootContainer").BHasClass("IsHidden")) ){
		RefreshStatsPanel()
	}
	levelLabel.text = GetAttributePoints( selectedHero )
	hasQueuedAction = false
}

function ClearStatsTypeContainer(){
	var statsTypeContainer = $("#StatsTypeContainer")
	for(var stat of statsTypeContainer.Children()){
		stat.style.visibility = "collapse"
		stat.RemoveAndDeleteChildren()
		stat.DeleteAsync(0)
	}
}

function UpgradeAbility(nettableString)
{
	if(hasQueuedAction == false)
	{
		hasQueuedAction = true
		GameEvents.SendCustomGameEventToServer( "send_player_upgraded_stats", {pID : localID, entindex : lastRememberedHero,  skill : nettableString} )
	}
}

function CreateAttributePanel( valueLvl, valueTable, valueSignifier, valueText, adder ){
	var statsTypeContainer = $("#StatsTypeContainer")
	var talentPanel = $.CreatePanel("Panel", statsTypeContainer, "");
	talentPanel.BLoadLayoutSnippet("StatsContainer")
	talentPanel.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#" + valueText, talentPanel) + " (+ " + valueTable[valueLvl] + adder + " )"
	talentPanel.FindChildTraverse("StatsTypeLevel").text = valueLvl + "/" + (valueTable.length - 1)
	if( GetAttributePoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || valueLvl >= valueTable.length - 1 || Entities.GetLevel( lastRememberedHero ) < (parseInt(valueLvl) + 1) * LEVELS_BETWEEN_TALENT_UPGRADES){
		talentPanel.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		talentPanel.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility(valueSignifier)});
	}
	if( Entities.GetLevel( lastRememberedHero ) < (parseInt(valueLvl) + 1) * LEVELS_BETWEEN_TALENT_UPGRADES ){ // max level
		talentPanel.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", talentPanel, "Level Requirement: " + (parseInt(valueLvl) + 1) * LEVELS_BETWEEN_TALENT_UPGRADES)});
		talentPanel.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", talentPanel);});
	} else if( valueTable[parseInt(valueLvl) + 1] == null ){
		talentPanel.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", talentPanel, "Stat maxed!")});
		talentPanel.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", talentPanel);});
	} else { // can be leveled
		talentPanel.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", talentPanel, "Next Level: +" + valueTable[parseInt(valueLvl) + 1]) + adder;});
		talentPanel.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", talentPanel);});
	}
}

function LoadOffenseLayout()
{
	lastRememberedState = STATS_STATE_OFFENSE
	var statsTypeContainer = $("#StatsTypeContainer")
	ClearStatsTypeContainer()
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", true)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", false)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", false)
	var statsNetTable = CustomNetTables.GetTableValue("stats_panel", lastRememberedHero)
	
	CreateAttributePanel( statsNetTable.ad, ATTACK_DAMAGE_TABLE, "ad", "STATS_TYPE_ATTACK_DAMAGE", "" )
	CreateAttributePanel( statsNetTable.as, ATTACK_SPEED_TABLE, "as", "STATS_TYPE_ATTACK_SPEED", "" )
	CreateAttributePanel( statsNetTable.sa, SPELL_AMP_TABLE, "sa", "STATS_TYPE_SPELL_AMP", "%" )
	CreateAttributePanel( statsNetTable.cdr, COOLDOWN_REDUCTION_TABLE, "cdr", "STATS_TYPE_COOLDOWN_REDUCTION", "%" )
	CreateAttributePanel( statsNetTable.sta, STATUS_AMP_TABLE, "sta", "STATS_TYPE_STATUS_AMP", "%" )
}

function LoadDefenseLayout()
{
	lastRememberedState = STATS_STATE_DEFENSE
	var statsTypeContainer = $("#StatsTypeContainer")
	
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", true)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", false)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", false)
	ClearStatsTypeContainer()
	
	var statsNetTable = CustomNetTables.GetTableValue("stats_panel", lastRememberedHero)
	CreateAttributePanel( statsNetTable.pr, ARMOR_TABLE, "pr", "STATS_TYPE_ARMOR", "" )
	CreateAttributePanel( statsNetTable.mr, MAGIC_RESIST_TABLE, "mr", "STATS_TYPE_MAGIC_RESIST", "%" )
	if ( Entities.IsRangedAttacker( lastRememberedHero ) ){
		CreateAttributePanel( statsNetTable.ar, ATTACK_RANGE_TABLE, "ar", "STATS_TYPE_ATTACK_RANGE", "" )
	} else {
		CreateAttributePanel( statsNetTable.db, DAMAGE_BLOCK_TABLE, "db", "STATS_TYPE_DAMAGE_BLOCK", "" )
	}
	CreateAttributePanel( statsNetTable.hp, HEALTH_TABLE, "hp", "STATS_TYPE_HEALTH", "" )
	CreateAttributePanel( statsNetTable.hpr, HEALTH_REGEN_TABLE, "hpr", "STATS_TYPE_HEALTH_REGEN", "" )
	CreateAttributePanel( statsNetTable.sr, STATUS_REDUCTION_TABLE, "sr", "STATS_TYPE_STATUS_REDUCTION", "%" )
}

function LoadOtherLayout()
{
	lastRememberedState = STATS_STATE_OTHER
	var statsTypeContainer = $("#StatsTypeContainer")
	var statsNetTable = CustomNetTables.GetTableValue("stats_panel", lastRememberedHero)
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", true)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", false)
	ClearStatsTypeContainer()
	CreateAttributePanel( statsNetTable.ms, MOVESPEED_TABLE, "ms", "STATS_TYPE_MOVE_SPEED", "" )
	CreateAttributePanel( statsNetTable.mp, MANA_TABLE, "mp", "STATS_TYPE_MANA", "" )
	CreateAttributePanel( statsNetTable.mpr, MANA_REGEN_TABLE, "mpr", "STATS_TYPE_MANA_REGEN", "" )
	CreateAttributePanel( statsNetTable.ha, HEAL_AMP_TABLE, "ha", "STATS_TYPE_HEAL_AMP", "%" )
	
	var allStats = $.CreatePanel("Panel", statsTypeContainer, "StatsTypeContainerAllStats");
	allStats.BLoadLayoutSnippet("StatsContainer")
	var bonusAll = statsNetTable["all"]
	allStats.FindChildTraverse("StatsTypeLabel").text = $.Localize( "#STATS_TYPE_ALL_STATS", allStats)
	allStats.FindChildTraverse("StatsTypeLevel").text = "+ " + bonusAll * 2

	allStats.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTextTooltip", allStats, "+2 All Stats");});
	allStats.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTextTooltip", allStats);});
	
	if( GetAttributePoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) ){
		allStats.FindChildTraverse("StatsTypeButton").SetHasClass("ButtonInactive", true)
	} else {
		allStats.FindChildTraverse("StatsTypeButton").SetPanelEvent("onactivate", function(){UpgradeAbility("all")});
	}
}

function LoadUniqueLayout()
{
	lastRememberedState = STATS_STATE_UNIQUE
	var statsTypeContainer = $("#StatsTypeContainer")
	$("#StatsOffenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsDefenseSelector").SetHasClass("SelectorSelected", false)
	$("#StatsOtherSelector").SetHasClass("SelectorSelected", false)
	$("#StatsUniqueSelector").SetHasClass("SelectorSelected", true)
	ClearStatsTypeContainer()
	
	var levelLabel = $.CreatePanel("Label", statsTypeContainer, "RequiredLevelLabel");
	levelLabel.SetHasClass("RequiredLevelLabel", true)
	levelLabel.text = "Next level requirement: 10"
	
	var talents = []
	var talentsSkilled = CustomNetTables.GetTableValue("talents", lastRememberedHero)
	var talentsSkilledCount = 0
	for(var talent in talentsSkilled){
		talentsSkilledCount++
	}
	var levelRequirement = 10 + talentsSkilledCount * 10
	for (var id = 0; id < Entities.GetAbilityCount( lastRememberedHero ); id++) {
		var abilityID = Entities.GetAbility( lastRememberedHero, id )
		var abilityName = Abilities.GetAbilityName( abilityID )
		var isTalent = (Abilities.GetAbilityType( abilityID ) & ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES) == ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES && abilityName.match(/special_bonus/g) == "special_bonus"
		if ( isTalent ){
			if(talents[id] == null) // link sister abilities
			{
				CreateTalentContainer(levelRequirement, statsTypeContainer, talentsSkilled, talents, abilityID, id) 
			}
		}
	}
	
	levelLabel.text = "Next level requirement: " + levelRequirement
}

function CreateTalentContainer(levelRequirement, statsTypeContainer, talentsSkilled, talents, abilityID, id){
	talents[id] = id + 1
	talents[id + 1] = id 
	talent1ID = abilityID
	talent2ID = Entities.GetAbility( lastRememberedHero, id + 1 )
	
	var talent1Name = Abilities.GetAbilityName( talent1ID )
	var talent2Name = Abilities.GetAbilityName( talent2ID )
	
	
	var talent = $.CreatePanel("Panel", statsTypeContainer, "Talentchoice" + id);
	talent.BLoadLayoutSnippet("TalentContainer")

	talent.FindChildTraverse("TalentLeftLabel").text = $.Localize( "#DOTA_Tooltip_Ability_" + talent1Name, talent)
	talent.FindChildTraverse("TalentRightLabel").text = $.Localize( "#DOTA_Tooltip_Ability_" + talent2Name, talent)
	
	var talentLeft = talent.FindChildTraverse("TalentSubLeft")
	var talentRight = talent.FindChildTraverse("TalentSubRight")
	
	talentLeft.nameid = talent1Name
	talentLeft.talentname = $.Localize( "#DOTA_Tooltip_Ability_" + talent1Name, talentLeft )
	talentLeft.talentdescr = $.Localize( "#DOTA_Tooltip_Ability_" + talent1Name + "_Description", talentLeft)
	
	talentRight.nameid = talent2Name
	talentRight.talentname = $.Localize( "#DOTA_Tooltip_Ability_" + talent2Name, talentRight )
	talentRight.talentdescr = $.Localize( "#DOTA_Tooltip_Ability_" + talent2Name + "_Description", talentRight)
	
	if( talentRight.talentdescr != ("DOTA_Tooltip_Ability_" + talent2Name + "_Description") ){
		talentRight.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTitleTextTooltip", talentRight, talentRight.talentname, talentRight.talentdescr);});
		talentRight.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTitleTextTooltip", talentRight);});
	}
	if ( talentLeft.talentdescr != ("DOTA_Tooltip_Ability_" + talent1Name + "_Description") ){
		talentLeft.SetPanelEvent("onmouseover", function(){$.DispatchEvent("DOTAShowTitleTextTooltip", talentLeft, talentLeft.talentname, talentLeft.talentdescr);});
		talentLeft.SetPanelEvent("onmouseout", function(){$.DispatchEvent("DOTAHideTitleTextTooltip", talentLeft);});
	}
	var talent1IsSkilled = (talentsSkilled != null && talentsSkilled[talent1Name] != null)
	var talent2IsSkilled = (talentsSkilled != null && talentsSkilled[talent2Name] != null)
	var talentIsSkilled = talent1IsSkilled || talent2IsSkilled
	if( Entities.GetAbilityPoints( lastRememberedHero ) == 0 || lastRememberedHero != Players.GetPlayerHeroEntityIndex( localID ) || Entities.GetLevel( lastRememberedHero ) < levelRequirement){
		talentLeft.SetHasClass("TalentCannotBeSkilled", !talent1IsSkilled)
		talentRight.SetHasClass("TalentCannotBeSkilled", !talent2IsSkilled)
	} else if(talentIsSkilled){
		talentLeft.SetHasClass("TalentCannotBeSkilled", talent2IsSkilled)
		talentRight.SetHasClass("TalentCannotBeSkilled", talent1IsSkilled)
	} else {
		talentLeft.SetHasClass("TalentCanBeSkilled", !talent1IsSkilled)
		talentRight.SetHasClass("TalentCanBeSkilled", !talent2IsSkilled)
	}
	if(talentIsSkilled){
		talentLeft.SetHasClass("TalentIsSkilled", talent1IsSkilled)
		talentRight.SetHasClass("TalentIsSkilled", talent2IsSkilled)
	}
	if(talentLeft.BHasClass("TalentCanBeSkilled")){
		talentLeft.SetPanelEvent("onactivate", function(){SelectTalent(talentLeft.nameid)});
	}
	if(talentRight.BHasClass("TalentCanBeSkilled")){
		talentRight.SetPanelEvent("onactivate", function(){SelectTalent(talentRight.nameid)});
	}
}

function SelectTalent(talent)
{
	if(hasQueuedAction == false)
	{
		hasQueuedAction = true
		GameEvents.SendCustomGameEventToServer( "send_player_selected_talent", {pID : localID, entindex : lastRememberedHero,  talent : talent} )
	}
}

function GetAttributePoints( entindex )
{	
	if(lastRememberedHero == -1 || lastRememberedHero == null){
		lastRememberedHero = Players.GetPlayerHeroEntityIndex( localID )
	}
	var netTable = CustomNetTables.GetTableValue("hero_properties", Entities.GetUnitName( lastRememberedHero ) + lastRememberedHero)
	if(netTable != null && netTable.attribute_points != null){
		return netTable.attribute_points
	} else {
		return 0
	}
}