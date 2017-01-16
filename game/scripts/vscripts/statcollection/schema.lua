customSchema = class({})

function customSchema:init()

    -- Check the schema_examples folder for different implementations

    -- Flag Example
    -- statCollection:setFlags({version = GetVersion()})

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()

        -- Send custom stats when the game ends
        if state == DOTA_GAMERULES_STATE_POST_GAME then

            -- Build game array
            local game = BuildGameArray()

            -- Build players array
            local players = BuildPlayersArray()

            -- Print the schema data to the console
            if statCollection.TESTING then
                PrintSchema(game, players)
            end

            -- Send custom stats
            if statCollection.HAS_SCHEMA then
                statCollection:sendCustom({ game = game, players = players })
            end
        end
    end, nil)
end

-------------------------------------

-- In the statcollection/lib/utilities.lua, you'll find many useful functions to build your schema.
-- You are also encouraged to call your custom mod-specific functions

-- Returns a table with our custom game tracking.
function BuildGameArray()
    local game = {}

    -- Add game values here as game.someValue = GetSomeGameValue()
    game.M_R = GameRules._roundnumber -- max round achieved
    game.F_G = GameRules._finish -- has the game finished (win)
    game.life = GetGameDifficulty() -- how many lives left
    game.U_L = GameRules._used_live -- Used Life
    game.T_L = GetMapName() -- map

    return game
end

-- Returns a table containing data for every player in the game
function BuildPlayersArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
				
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				if not hero then return end
				local heroName = GetHeroName(playerID)
				if GameRules.gameDifficulty < 3 then heroName = "casual" end
				if GetMapName() == "epic_boss_fight_boss_master" then heroName = "boss_master" end
                table.insert(players, {
                    -- steamID32 required in here
                    steamID32 = PlayerResource:GetSteamAccountID(playerID),

                    -- Example functions for generic stats are defined in statcollection/lib/utilities.lua
                    -- Add player values here as someValue = GetSomePlayerValue(),
                    HN = heroName, -- Hero
                    P_L = hero:GetLevel(), -- Level
                    P_NW = FindDPS(hero) or 0, -- Damage
                    P_T = hero:GetTeam(), -- Team
                    P_K = GetMapName(), -- Map
                    P_D = GetGameDifficulty(), -- Deaths
                    P_H = PlayerResource:GetHealing(hero:GetPlayerOwnerID()), -- Healing
                    P_R = hero.Ressurect, -- Ressurections
                    P_GPM = math.floor(PlayerResource:GetGoldPerMin(hero:GetPlayerOwnerID())), -- GPM

                    --inventory :
                    i1 = GetItemSlot(hero, 1),
                    i2 = GetItemSlot(hero, 2),
                    i3 = GetItemSlot(hero, 3),
                    i4 = GetItemSlot(hero, 4),
                    i5 = GetItemSlot(hero, 5),
                    i6 = GetItemSlot(hero, 6),
                })
            end
        end
    end

    return players
end

function FindDPS(hero)
	GameRules.EndTime = GameRules.EndTime or GameRules:GetGameTime()
	hero.first_damage_time = hero.first_damage_time or 0
	hero.damageDone = hero.damageDone or 0
	local elapsedMinutes = (GameRules.EndTime - hero.first_damage_time)
	return math.floor( hero.damageDone / elapsedMinutes + 0.5 )
end

function FindPercentualDamage(hero)
	hero.damageDone = hero.damageDone or 0
	GameRules.TeamDamage = GameRules.TeamDamage or 1
	return math.floor( (hero.damageDone / GameRules.TeamDamage)*100 + 0.5)
end

-- Prints the custom schema, required to get an schemaID
function PrintSchema(gameArray, playerArray)
    print("-------- GAME DATA --------")
    DeepPrintTable(gameArray)
    print("\n-------- PLAYER DATA --------")
    DeepPrintTable(playerArray)
    print("-------------------------------------")
end

-- Write 'test_schema' on the console to test your current functions instead of having to end the game
if Convars:GetBool('developer') then
    Convars:RegisterCommand("test_schema", function() PrintSchema(BuildGameArray(), BuildPlayersArray()) end, "Test the custom schema arrays", 0)
end

-------------------------------------

-- If your gamemode is round-based, you can use statCollection:submitRound(bLastRound) at any point of your main game logic code to send a round
-- If you intend to send rounds, make sure your settings.kv has the 'HAS_ROUNDS' set to true. Each round will send the game and player arrays defined earlier
-- The round number is incremented internally, lastRound can be marked to notify that the game ended properly
function customSchema:submitRound(isLastRound)

    local winners = BuildRoundWinnerArray()
    local game = BuildGameArray()
    local players = BuildPlayersArray()

    statCollection:sendCustom({ game = game, players = players })

    isLastRound = isLastRound or false --If the function is passed with no parameter, default to false.
    return { winners = winners, lastRound = isLastRound }
end

-- A list of players marking who won this round
function BuildRoundWinnerArray()
    local winners = {}
    local current_winner_team = GameRules.Winner or 0 --You'll need to provide your own way of determining which team won the round
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                winners[PlayerResource:GetSteamAccountID(playerID)] = (PlayerResource:GetTeam(playerID) == current_winner_team) and 1 or 0
            end
        end
    end
    return winners
end

-------------------------------------