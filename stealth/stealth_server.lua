local __vote = { };
__vote.enabled = 1;
__vote.timers = { };

avaibleID = { }
timers = { }

checkWeapons = {}
team = { }
camera = { }

roundStarted = 0
roundCount = 0
renewObjects = false

local fpsLimit = tonumber( get( 'fps_limit' ) )
local timeLimit = tonumber( get( 'round_time_limit' ) )

team_1_name = get( 'team_red_name' )
team_2_name = get( 'team_blue_name' )

gadgetsAmmo = {
	[3] = get( 'armor' ),
}

glitchesEnabled = {
    [1] = get( 'quickreload' ),
	[2] = get( 'fastmove' ),
	[3] = get( 'fastfire' ),
	[4] = get( 'crouchbug' ),
	[5] = get( 'highcloserangedamage' ),
	[6] = get( 'hitanim' ),
	[7] = get( 'fastsprint' ),
}

function clientSync( clientPlayer )
	setElementData( clientPlayer, 'armor', gadgetsAmmo[3] )
end

weaponsAmmo = {
    [24] = get( 'deagle' ),   -- Desert Eagle 
	
	[30] = get( 'ak-47' ),  -- AK-47
	[31] = get( 'm4' ),  -- M4
	
	[33] = get( 'rifle' ),   -- Country Rifle
	[34] = get( 'sniper' ),   -- Sniper Rifle
	
	[16] = get( 'grenade' ),    -- Grenade 
}

function getTeamsWithFewestPlayers(t)
    if t and type(t)=="table" then 
        for i,v in ipairs(t) do
             if (not isElement(v)) or (type(v) ~= "team") then
                 return false
             end
        end
    else t = getElementsByType("team") end
    local lowestScorers, lowestCount = {}, math.huge
    for i,v in ipairs(t) do
        local count = countPlayersInTeam(v)
        if count < lowestCount then
            lowestScorers = {v}
            lowestCount = count
        elseif count == lowestCount then
            table.insert(lowestScorers, v)
        end
    end
    return lowestScorers
end

addEventHandler( 'onResourceStop', resourceRoot,
    function( sResource )
		local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
			logOut( playersTable[i] );
		end
	end
)

addEventHandler( 'onResourceStart', resourceRoot,
    function( )
	    team['RED'] = createTeam( team_1_name, 255, 0, 0 )
	    team['BLU'] = createTeam( team_2_name, 0, 0, 255 )
		team['SPC'] = createTeam( 'SPECTATORS', 255, 255, 255 )
	    call( getResourceFromName( 'scoreboard' ), 'scoreboardAddColumn', 'Score', root, 40, 'Score', 3 )
		call( getResourceFromName( 'scoreboard' ), 'scoreboardAddColumn', 'State', root, 30, 'State', 4 )
	    call( getResourceFromName( 'scoreboard' ), 'scoreboardAddColumn', 'Kills', root, 50, 'Kills', 7 )
	    call( getResourceFromName( 'scoreboard' ), 'scoreboardAddColumn', 'Deaths', root, 50, 'Deaths', 9 )
		call( getResourceFromName( 'scoreboard' ), 'scoreboardAddColumn', 'Headshots', root, 60, 'Headshots', 10 )
	    setElementData( team['RED'], 'Score', 0 )
	    setElementData( team['BLU'], 'Score', 0 )
	    setTeamFriendlyFire( team['RED'], false )
        setTeamFriendlyFire( team['BLU'], false )
		setElementData( team['RED'], 'teamType', 'Terrorists' )
		setElementData( team['BLU'], 'teamType', 'Counter-Terrorists' )
		local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
			setPlayerNametagColor( playersTable[i], 255, 255, 255 )
		end
        if ( glitchesEnabled[1] == 'false' ) then
			setGlitchEnabled( "quickreload", false )
		else
			setGlitchEnabled( "quickreload", true )
		end
        if ( glitchesEnabled[2] == 'false' ) then
			setGlitchEnabled( "fastmove", false )
		else
			setGlitchEnabled( "fastmove", true )
		end
        if ( glitchesEnabled[3] == 'false' ) then
			setGlitchEnabled( "fastfire", false )
		else
			setGlitchEnabled( "fastfire", true )
		end
        if ( glitchesEnabled[4] == 'false' ) then
			setGlitchEnabled( "crouchbug", false )
		else
			setGlitchEnabled( "crouchbug", true )
		end
        if ( glitchesEnabled[5] == 'false' ) then
			setGlitchEnabled( "highcloserangedamage", false )
		else
			setGlitchEnabled( "highcloserangedamage", true )
		end
        if ( glitchesEnabled[6] == 'false' ) then
			setGlitchEnabled( "hitanim", false )
		else
			setGlitchEnabled( "hitanim", true )
		end
        if ( glitchesEnabled[7] == 'false' ) then
			setGlitchEnabled( "fastsprint", false )
		else
			setGlitchEnabled( "fastsprint", true )
		end
		outputServerLog( '-------------------------------' )
		outputServerLog( '-    Stealth:PRO              -' )
		outputServerLog( '-    By: arielszz :/       -' )
		outputServerLog( '-------------------------------' )
		setSunSize( 0 )
    end
)

addEventHandler( 'onGamemodeMapStart', root,
    function( startedMap )
	    setFPSLimit( fpsLimit )
	    roundStarted = 0
		renewObjects = false
	    setElementData( team['RED'], 'Score', 0 )
	    setElementData( team['BLU'], 'Score', 0 )
	    mapRoot = getResourceRootElement( startedMap )
		mapName = getResourceName( startedMap )
		setGameType( 'Stealth:PRO ● '..mapName )
		mapTime = get( getResourceName( startedMap )..".#time" )
		if mapTime then
			local splitString = split( mapTime, string.byte(':') )
			setTime( tonumber( splitString[1]), tonumber( splitString[2]) )
		end
		if mapRoot then
		    camera = { }
			camera = { pos = { x = '', y = '', z = '' }, look = { x = '', y = '', z = '' }, int = '' }
			local cameraInfo = get( getResourceName( startedMap )..".camera" )
			if not cameraInfo then
			    local map_camera_data = getElementsByType( "camera", mapRoot )
				if ( map_camera_data ) then
				    for k, v in pairs( map_camera_data ) do
				        camera = { pos = { x = tonumber( getElementData( v, "posX" ) ), y = tonumber( getElementData( v, "posY" ) ), z = tonumber( getElementData( v, "posZ" ) ) }, look = { x = tonumber( getElementData( v, "targetX" ) ), y = tonumber( getElementData( v, "targetY" ) ), z = tonumber( getElementData( v, "targetZ" ) ) }, 0 }
					end
				else
			        camera = { pos = { x = 1468.8785400391, y = -919.25317382813, z = 100.153465271 }, look = { x = 1468.388671875, y = -918.42474365234, z = 99.881813049316 }, 0 }
				end
			else
				camera = { pos = { x = cameraInfo[1][1], y = cameraInfo[1][2], z = cameraInfo[1][3] }, look = { x = cameraInfo[2][1], y = cameraInfo[2][2], z = cameraInfo[2][3] }, 0 }
			end
			local spy_team_spawns_by_id = getElementByID( "spyspawns" )
			local merc_team_spawns_by_id = getElementByID( "mercspawns" )
			local spy_team_spawns_by_data = getElementsByType( "spyspawn", mapRoot )
			local merc_team_spawns_by_data = getElementsByType ( "mercenaryspawn", mapRoot )
			local team1_spawns_by_data = getElementsByType( "Team1", mapRoot )
			local team2_spawns_by_data = getElementsByType( "Team2", mapRoot )
			if ( team1_spawns_by_data[1] ~= nil ) and ( team2_spawns_by_data[1] ~= nil ) then
				spy_points = team1_spawns_by_data
				merc_points = team2_spawns_by_data
			elseif ( spy_team_spawns_by_data[1] ~= nil ) and ( merc_team_spawns_by_data[1] ~= nil ) then
			    spy_points = spy_team_spawns_by_data
				merc_points = merc_team_spawns_by_data
			else
			    spy_points = getElementsByType( "spawnpoint", spy_team_spawns_by_id )
				merc_points = getElementsByType( "spawnpoint", merc_team_spawns_by_id )  
			end
			TeamSpawns = { }
			TeamSpawns['Terrorists'] = spy_points
			TeamSpawns['Counter-Terrorists'] = merc_points
			for key, value in pairs( TeamSpawns['Terrorists'] ) do
				TeamSpawns['Terrorists'][tonumber( key )] = { skinModel = tonumber( get( 'spy_skin' ) ) or 163, posX = tonumber( getElementData( value, "posX" ) ), posY = tonumber( getElementData( value, "posY" ) ), posZ = tonumber( getElementData( value, "posZ" ) ), rot = tonumber( getElementData( value, "rot" ) ) or 0, int = tonumber( getElementData( value, "interior" ) ) or 0 }
			end
			for key, value in pairs( TeamSpawns['Counter-Terrorists'] ) do
				TeamSpawns['Counter-Terrorists'][tonumber( key )] = { skinModel = tonumber( get( 'mercenary_skin' ) ) or 285, posX = tonumber( getElementData( value, "posX" ) ), posY = tonumber( getElementData( value, "posY" ) ), posZ = tonumber( getElementData( value, "posZ" ) ), rot = tonumber( getElementData( value, "rot" ) ) or 0, int = tonumber( getElementData( value, "interior" ) ) or 0 }
			end
			setTimer( stealthRoundStart, 10000, 1 )
			local mapInterior = get( mapName..".#interior" )
			if mapInterior == false then 
				mapInterior = 0
			end
			local playersTable = getElementsByType( "player" )
			for i=1,#playersTable do
				local thePlayer = playersTable[i]
				triggerClientEvent( thePlayer, 'clientMapStart', thePlayer, { camera.pos.x, camera.pos.y, camera.pos.z, camera.look.x, camera.look.y, camera.look.z, mapName, mapInterior } )
			end
			renew_objects = { };
			local objects = getElementsByType( "object", mapRoot )
			
		end
	end
)

function table.merge( appendTo, ... )
	local appendval
	for i=1,arg.n do
		if type(arg[i]) == 'table' then
			for k,v in pairs(arg[i]) do
				if arg[i+1] and type(arg[i+1]) ~= 'table' then
					appendval = v[arg[i+1]]
				else
					appendval = v
				end
				if appendval then
					if type(k) == 'number' then
						table.insert(appendTo, appendval)
					else
						appendTo[k] = appendval
					end
				end
			end
		end
	end
	return appendTo
end

addEventHandler( 'onGamemodeMapStop', root,
    function( stopedMap )
		if ( isTimer( getTimer ) ) then
		    killTimer( getTimer )
		end
		getTimer = nil
	    mapRoot = nil
		mapName = nil
		mapTime = nil
		roundTimer = nil
		renewObjects = false
		roundStarted = 0
		if ( g_MissionTimer ) then
    	    removeEventHandler( 'onMissionTimerElapsed', g_MissionTimer, onTimeElapsed )
    	    destroyElement( g_MissionTimer )
		    g_MissionTimer = nil
		end
		local g_GameTimers = getTimers( );
		if ( g_GameTimers ) then
		    for k, t in pairs( g_GameTimers ) do
			    if t ~= __vote.timers[ 1 ] then
		            killTimer( t )
				end
		    end
		end
		local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
			local thePlayer = playersTable[i]
		    killPlayerTimer( thePlayer )
		    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
			setPlayerTeam( thePlayer, nil )
			setElementData( thePlayer, 'Kills', 0 )
			setElementData( thePlayer, 'Deaths', 0 )
			setElementData( thePlayer, 'Damage', 0 )
			setElementData( thePlayer, 'Headshots', 0 )
			setElementData( thePlayer, 'roundKills', 0 )
			setElementData( thePlayer, 'roundHead', 0 )
		end
	    setElementData( team['RED'], 'teamType', 'Terrorists' )
		setElementData( team['BLU'], 'teamType', 'Counter-Terrorists' ) 
	end
)

function stealthRoundStart( )
    if ( countPlayersInTeam( team['RED'] ) ~= 0 ) or ( countPlayersInTeam( team['BLU'] ) ~= 0 ) then
        g_MissionTimer = exports.missiontimer:createMissionTimer( timeLimit*60000, true, "%m:%s", 0.5,20, true, "bankgothic", 0.6, 255, 255, 255 )
	    addEventHandler( 'onMissionTimerElapsed', g_MissionTimer, onTimeElapsed )
	    team1Type = getElementData( team['RED'], 'teamType' )
		team2Type = getElementData( team['BLU'], 'teamType' )
		local teamRedPlayers = getPlayersInTeam( team['RED'] )
		local teamBluPlayers = getPlayersInTeam( team['BLU'] )
		local teamSpecPlayers = getPlayersInTeam( team['SPC'] )
		for i=1,#teamRedPlayers do
			local thePlayer = teamRedPlayers[i]
	        if ( thePlayer ) then
	            spawnPlayerTeam( thePlayer, team['RED'])
	    		triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
	    		triggerClientEvent( thePlayer, 'clientWeaponsMenu', thePlayer, team1Type )
				setElementData( thePlayer, 'roundKills', 0 )
				setElementData( thePlayer, 'roundHead', 0 )
            end
	    end
		for i=1,#teamBluPlayers do
			local thePlayer = teamBluPlayers[i]
	        if ( thePlayer ) then
	            spawnPlayerTeam( thePlayer, team['BLU'])
	    		triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
	    		triggerClientEvent( thePlayer, 'clientWeaponsMenu', thePlayer, team2Type )
				setElementData( thePlayer, 'roundKills', 0 )
				setElementData( thePlayer, 'roundHead', 0 )
            end
	    end
		for i=1,#teamSpecPlayers do
			local thePlayer = teamSpecPlayers[i]
	        if ( thePlayer ) then
	    	    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, true )
            end
	    end
	    setGameSpeed( 1 )
		renewObjects = true
	    if ( isTimer( getTimer ) ) then
	        killTimer( getTimer )
	    end
	    getTimer = nil
		roundStarted = 1
	else
	    if roundTimer and isTimer( roundTimer ) then
		    killTimer( roundTimer )
		end
	    roundTimer = setTimer( stealthRoundStart, 10000, 1 )
		local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
			local v = playersTable[i]
		end
	end
end

function stealthRoundStop( w )
    roundStarted = 0
    for i,pickup in pairs( getElementsByType( "pickup" ) ) do
	    destroyElement( pickup )
	end
	if getTimer and isTimer( getTimer ) then
	    killTimer( getTimer )
	end
    winTeamName = w
	local teamRedPlayers = getPlayersInTeam ( team['RED'] )
	local teamBluPlayers = getPlayersInTeam( team['BLU'] )
	local teamSpecPlayers = getPlayersInTeam( team['SPC'] )
	for i=1,#teamRedPlayers do
		local thePlayer = teamRedPlayers[i]
	    if ( thePlayer ) then
		    killPlayerTimer( thePlayer )
			takeWeapon( thePlayer, 40 )
		    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
	        triggerClientEvent( thePlayer, 'clientRoundEnd', thePlayer, { camera.pos.x, camera.pos.y, camera.pos.z, camera.look.x, camera.look.y, camera.look.z, winTeamName } )
        end
	end
	for i=1,#teamBluPlayers do
		local thePlayer = teamBluPlayers[i]
	    if ( thePlayer ) then
		    killPlayerTimer( thePlayer )
			takeWeapon( thePlayer, 40 )
		    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
	        triggerClientEvent( thePlayer, 'clientRoundEnd', thePlayer, { camera.pos.x, camera.pos.y, camera.pos.z, camera.look.x, camera.look.y, camera.look.z, winTeamName } )
        end
	end
	for i=1,#teamSpecPlayers do
		local thePlayer = teamSpecPlayers[i]
	    if ( thePlayer ) then
		    killPlayerTimer( thePlayer )
		    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
	        triggerClientEvent( thePlayer, 'clientRoundEnd', thePlayer, { camera.pos.x, camera.pos.y, camera.pos.z, camera.look.x, camera.look.y, camera.look.z, winTeamName } )
        end
	end
	changeTeamTypes( )
	if roundTimer and isTimer( roundTimer ) then
		killTimer( roundTimer )
	end
	roundTimer = setTimer( stealthRoundStart, 10000, 1 )
	if renewObjects == true then 
		local objects = getElementsByType( "object", mapRoot );
		for i,obj in pairs( objects ) do
			if ( getElementModel( obj ) == 2988 ) then
				local posX, posY, posZ = getElementPosition( obj );
				local rotX, rotY, rotZ = getElementRotation( obj );
				destroyElement( obj );
				createObject( 2988, posX, posY, posZ, rotX, rotY, rotZ, false );
			end
		end
	end
	local stuckstuff = getAttachedElements( root )
	for ElementKey, ElementValue in pairs( stuckstuff ) do
		if ( getElementData( ElementValue, "type" ) == "ashield" ) then
			local theshield = ElementValue
			if theshield then
			    destroyElement( theshield )
		    end
	    end
	end
end


addEvent( 'takeClientWeapons', true )
addEventHandler( 'takeClientWeapons', resourceRoot,
    function( )
	    killPed( client, client, 99, 99 )
	end
)

function onTimeElapsed( )
    roundStarted = 0
    getWinnerTeam( )
end

function changeTeamTypes( )
    local teamRedType = getElementData( team['RED'], 'teamType' )
	if ( teamRedType == 'Terrorists' ) then
	    setElementData( team['RED'], 'teamType', 'Counter-Terrorists' )
		setElementData( team['BLU'], 'teamType',  'Terrorists' )
	else
	    setElementData( team['RED'], 'teamType', 'Terrorists' )
		setElementData( team['BLU'], 'teamType', 'Counter-Terrorists' )   
	end
end

function killPlayerTimer( p )
    if ( timers[ p ] ) then
	    if ( isTimer( timers[ p ] ) ) then
		    killTimer( timers[ p ] )
		end
		timers[ p ] = nil
	end
end

function sprawdzCzySaGracze( )
    getTimer = nil
	local teamRedAlives = #getAlivePlayersInTeam( team['RED'] ) or 0
	local teamBlueAlives = #getAlivePlayersInTeam( team['BLU'] ) or 0
	if ( teamRedAlives == 0 ) or ( teamBlueAlives == 0 ) then
	    roundStarted = 0
    	if ( g_MissionTimer ) then
        	removeEventHandler( 'onMissionTimerElapsed', g_MissionTimer, onTimeElapsed )
            destroyElement( g_MissionTimer )
		    g_MissionTimer = nil
	    end
		local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
			local v = playersTable[i]
		end
		getWinnerTeam( )
	end
end

addEventHandler( 'onPlayerWasted', root,
    function( totalAmmo, killer, killerWeapon, bodypart )
	    if ( roundStarted == 1 ) and ( getElementData( source, 'State' ) == 'Alive' ) then
			local playerTeam = getPlayerTeam( source )
			if ( playerTeam == team['RED'] ) or ( playerTeam == team['BLU'] ) then
		    	setElementData( source, 'State', 'Dead' )
		   	    if ( bodypart == 9 ) then
					setElementData( killer, 'Headshots', getElementData( killer, 'Headshots' ) + 1 )
					setElementData( killer, 'roundHead', getElementData( killer, 'roundHead' ) + 1 )
				end
	    		local teamRedAlives = #getAlivePlayersInTeam( team['RED'] ) or 0
				local teamBlueAlives = #getAlivePlayersInTeam( team['BLU'] ) or 0
				if ( teamRedAlives == 0 ) or ( teamBlueAlives == 0 ) then
					if ( isTimer( getTimer ) ) then
	    				killTimer( getTimer )
					end
					getTimer = nil
    		    	if ( g_MissionTimer ) then
        	     	    removeEventHandler( 'onMissionTimerElapsed', g_MissionTimer, onTimeElapsed )
                	    destroyElement( g_MissionTimer )
		        	    g_MissionTimer = nil
	            	end
		    		if ( waitTimer ~= nil ) then
				 	   killTimer( waitTimer )
						waitTimer = nil
					end
					local teamRedPlayers = getPlayersInTeam ( team['RED'] )
					for i=1,#teamRedPlayers do
						local thePlayer = teamRedPlayers[i]
	  			  		if ( thePlayer ) then
						    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
     			    	end
					end
					local teamBluPlayers = getPlayersInTeam ( team['BLU'] )
					for i=1,#teamBluPlayers do
						local thePlayer = teamBluPlayers[i]
				    	if ( thePlayer ) then
						    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
   			        	end
					end
					local teamSpecPlayers = getPlayersInTeam( team['SPC'] )
					for i=1,#teamSpecPlayers do
						local thePlayer = teamSpecPlayers[i]
	    				if ( thePlayer ) then
						    triggerClientEvent( thePlayer, 'togglePlayerSpectate', thePlayer, false )
    				    end
					end
		 	    	waitTimer = setTimer( getWinnerTeam, 1000, 1 )
					if ( killer ) then
						local playersTable = getElementsByType( "player" )
						for i=1,#playersTable do
							local v = playersTable[i]
						    local playerTeam = getPlayerTeam( v )
							if ( playerTeam ) then
							    setCameraTarget( v, killer )
								triggerClientEvent( v, "Client:endCameraTarget", v, { killer, source } );
							end
						end
						setGameSpeed( 0.01 )
					end
				else
					timers[ source ] = setTimer( triggerClientEvent, 3000, 1, source, 'togglePlayerSpectate', source, true )
				end
				if ( killer ) then
					if ( killer ~= source ) then
				  	    setElementData( killer, 'Kills', getElementData( killer, 'Kills' ) + 1 )
						setElementData( killer, 'roundKills', getElementData( killer, 'roundKills' ) + 1 )
					end
				end
				setElementData( source, 'Deaths', getElementData( source, 'Deaths' ) + 1 )
			end
		end
	end
)

addEventHandler( 'onPlayerSpawn', root,
    function( )
	    setPedHeadless( source, false )
		setPedFightingStyle( source, 6 )
	end
)

addEventHandler( 'onPlayerQuit', root,
    function( )
        destroyPlayerID( source )
		killPlayerTimer( source )
		local playerTeam = getPlayerTeam( source )
		if ( playerTeam == team['RED'] ) or ( playerTeam == team['BLU'] ) then
		    if ( roundStarted == 1 ) then
			    if ( isTimer( getTimer ) ) then
	    	    	killTimer( getTimer )
		    	end
		    	getTimer = nil
		    	getTimer = setTimer( sprawdzCzySaGracze, 3000, 1 )
		    end
		end
    end
)

function getWinnerTeam( )
    roundStarted = 0
    waitTimer = nil
	winTeamName = nil
	local teamRedAlives = #getAlivePlayersInTeam( team['RED'] ) or 0
	local teamBlueAlives = #getAlivePlayersInTeam( team['BLU'] ) or 0
	if ( teamRedAlives == teamBlueAlives ) then
		winTeamName = 'tie'
	else
	    if ( teamRedAlives > teamBlueAlives ) then
			winTeamName = 'red'
			setElementData( team['RED'], 'Score', getElementData( team['RED'], 'Score' ) + 1 )
		end
		if ( teamBlueAlives > teamRedAlives ) then
		    winTeamName = 'blu'
			setElementData( team['BLU'], 'Score', getElementData( team['BLU'], 'Score' ) + 1 )
		end
	end
    if ( g_MissionTimer ) then
        removeEventHandler( 'onMissionTimerElapsed', g_MissionTimer, onTimeElapsed )
        destroyElement( g_MissionTimer )
		g_MissionTimer = nil
	end
	stealthRoundStop( winTeamName )
end

function getAlivePlayersInTeam( theTeam )
    local theTable = { }
    local players = getPlayersInTeam( theTeam )
 
    for i,v in pairs( players ) do
      if not isPedDead( v ) then
        theTable[#theTable+1]=v
      end
    end
 
    return theTable
end

addEvent( 'givePlayerWeapons', true )
addEventHandler( 'givePlayerWeapons', resourceRoot,
    function( a, b, c )
	    if ( a ) then
	        giveWeapon( client, a, weaponsAmmo[a] )
		end
		if ( b ) then
		    giveWeapon( client, b, weaponsAmmo[b] )
		end
		if ( c ) then
		    giveWeapon( client, c, weaponsAmmo[c] )
		end
	end
)

addEvent( 'givePlayerSpecialWeapon', true )
addEventHandler( 'givePlayerSpecialWeapon', resourceRoot,
    function( otherWeapon )
	    giveWeapon( client, getWeaponIDFromName( tostring( otherWeapon ) ), 1 )
	end
)

addEventHandler( 'onPlayerChat', root,
    function( message, messageType )
	    if ( messageType == 0 ) then
		    cancelEvent()
			local red, green, blue = getPlayerNametagColor( source )
			local playerName = getPlayerName( source )
			if ( playerName ) then
			    outputChatBox( '● '..playerName..': #FFFFFF'..message, root, red, green, blue, true )
			    outputServerLog( "CHAT: "..playerName..": "..message )
			end
		end
	end
)

function getOnlineAdmins( )
	local t = {}
	local playersTable = getElementsByType( "player" )
	for i=1,#playersTable do
		local v = playersTable[i]
		while true do
			local acc = getPlayerAccount( v )
			if not acc or isGuestAccount( acc ) then break end
			local accName = getAccountName( acc )
			local isAdmin = isObjectInACLGroup( "user."..accName,aclGetGroup( "Admin" ) )
			if isAdmin == true then
				table.insert( t,v )
			end
			break
		end
	end
	return t
end
    
function createPlayerID( player )
    setPlayerID( player, -1 )
end

function setPlayerID( player, id )
    local pID = id + 1
    if pID then
        if avaibleID[pID] ~= false then
            avaibleID[pID] = false
            setElementData( player, 'ID', pID )
        else
            return setPlayerID( player, pID )
        end
    end
end

function destroyPlayerID( player )
    local pID = tonumber( getElementData( player, 'ID' ) )
    if pID then
        avaibleID[pID] = nil
    end
end
 
function getPlayerID( player )
    if player then
        local pID = tonumber( getElementData( player, 'ID' ) )
        if pID then
            return tonumber( pID )
        end
    end
end

function getPlayerByID( id )
	local playersTable = getElementsByType( "player" );
	for i=1,#playersTable do
		local v = playersTable[i]
		local playerID = getElementData( v, "ID" );
		if playerID == id then return v end
	end
	return nil
end

addEvent( 'downloadEnd', true )
addEventHandler( 'downloadEnd', resourceRoot,
    function( )
	    bindKey( client, 'r', 'down', clientPlayerPickUpWeapon )
		bindKey( client, 'mouse2', 'down', cancelAnimation )
		bindKey( client, '1', 'down', pAnimStart )
		bindKey( client, '2', 'down', pAnimStart )
		bindKey( client, '3', 'down', pAnimStart )
		bindKey( client, '4', 'down', pAnimStart )
	    clientSync( client )
        createPlayerID( client )
		setPedWalkingStyle( client, 0 );
		setElementData( client, 'Kills', 0 )
		setElementData( client, 'Deaths', 0 )
		setElementData( client, 'Headshots', 0 )
		setElementData( client, 'Damage', 0 )
		setElementData( client, 'roundKills', 0 )
		setElementData( client, 'roundHead', 0 )
		setElementData( client, 'State', 'Dead' )
		triggerClientEvent( client, 'createStealthWeaponsGui', client, weaponsAmmo, gadgetsAmmo )
		if ( mapTime ) then
			local splitString = split( mapTime, string.byte(':') )
			setTime( tonumber( splitString[1]), tonumber( splitString[2]) )
		end
		if ( camera ) then
		    triggerClientEvent( client, 'clientMapStart', client, { camera.pos.x, camera.pos.y, camera.pos.z, camera.look.x, camera.look.y, camera.look.z, mapName, camera.int, team_1_name, team_2_name, statsSystem, drawLasers } )
		end
    end
)

function changeTeam( player, key, keyState )
    if ( player ) then
   	    if ( roundStarted == 0 ) or ( getElementData( player, 'State' ) == 'Dead' ) or ( getPlayerTeam( player ) == team['SPC'] ) then
		    unbindKey( player, 'f3', 'down', changeTeam )
		    setPlayerTeam( player, nil )
			setPlayerNametagColor( player, 255, 255, 255 )
			triggerClientEvent( player, 'togglePlayerSpectate', player, false )
			if ( roundStarted == 1 ) then
			    triggerClientEvent( player, 'togglePlayerSpectate', player, true )
			end
		    triggerClientEvent( player, 'clientChangeTeam', player )
		end
	end
end

addEvent( 'joinTeam', true )
addEventHandler( 'joinTeam', resourceRoot,
    function ( t )
	    local r, g, b = getTeamColor( team[ tostring( t ) ] )
		setPlayerNametagColor( client, r, g, b )
	    setPlayerTeam( client, team[tostring( t )] )
		triggerClientEvent( client, 'clientJoinTeam', client )
		local teamName = getTeamName( team[ tostring( t ) ] )
		local playerName = getPlayerName( client )          
		if ( roundStarted == 1 ) then
		    triggerClientEvent( client, 'togglePlayerSpectate', client, true )
			if ( isTimer( getTimer ) ) then
	    	    killTimer( getTimer )
		    end
		    getTimer = nil
			getTimer = setTimer( sprawdzCzySaGracze, 5000, 1 )
		end
		bindKey( client, 'f3', 'down', changeTeam )
	end
)

addEvent( 'joinSpectate', true )
addEventHandler( 'joinSpectate', resourceRoot,
    function( )
	    setPlayerTeam( client, team['SPC'] )
		setPlayerNametagColor( client, 255, 255, 255 )
		if ( roundStarted == 1 ) then
		    triggerClientEvent( client, 'togglePlayerSpectate', client, true )
		end
		triggerClientEvent( client, 'clientJoinTeam2', client )
		bindKey( client, 'f3', 'down', changeTeam )
	end
)

addEvent( 'IsClientPlayerAfk', true )
addEventHandler( 'IsClientPlayerAfk', resourceRoot,
    function( )
	    killPed( client, client )
		setElementData( client, 'State', 'Dead' )
		if ( roundStarted == 1 ) then
		    triggerClientEvent( client, 'togglePlayerSpectate', client, true )
		end
		bindKey( client, 'f3', 'down', changeTeam )
	end
)

function spawnPlayerTeam( p, team )
    if ( p ) and ( team ) then
        local teamT = getElementData( team, 'teamType' )
        if ( teamT ) then
            local to_number = math.random( 1, tonumber( #TeamSpawns[teamT] ) )
            local posX = TeamSpawns[teamT][to_number].posX + math.random(-1, 1)
            local posY = TeamSpawns[teamT][to_number].posY + math.random(-1, 1)
            local posZ = TeamSpawns[teamT][to_number].posZ
            spawnPlayer ( p, posX, posY, posZ, TeamSpawns[teamT][to_number].rot, TeamSpawns[teamT][to_number].skinModel, TeamSpawns[teamT][to_number].int, 0 )
            setElementData( p, 'State', 'Alive' )
            if ( teamT ~= 'Terrorists' ) then
            else
            end
        end
    end
end


addEventHandler( 'onVehicleStartEnter', root,
    function( enteringPlayer, seat, jacked, door )
	    cancelEvent( )
	end
)


addCommandHandler( 'rs',
    function( thePlayer, commandName )
	    setElementData( thePlayer, 'Kills', 0 )
		setElementData( thePlayer, 'Deaths', 0 )
		setElementData( thePlayer, 'Headshots', 0 )
		setElementData( thePlayer, 'Damage', 0 )
	end
)

function pAnimStart( player, key, keyState )
    if ( key == '1' ) then
        setPedAnimation( player, 'POLICE', 'CopTraf_Away', -1, false, true, false, false )
	end
    if ( key == '2' ) then
        setPedAnimation( player, 'POLICE', 'CopTraf_Come', -1, false, true, false, false )
	end
    if ( key == '3' ) then
        setPedAnimation( player, 'SWAT', 'swt_lkt', -1, false, true, false, false )
	end
    if ( key == '4' ) then
        setPedAnimation( player, 'SWAT', 'swt_sty', -1, false, true, false, false )
	end
end

function cancelAnimation( player, key, keyState )
    setPedAnimation( player, false )
end

function commitSuicide(sourcePlayer)
	killPlayer(sourcePlayer, sourcePlayer)
end
addCommandHandler("kill", commitSuicide)

-- Atualiza os gadgets, reseta os gadgets e insere colete para os players.

addEvent( 'givePlayerGadget', true )
addEventHandler( 'givePlayerGadget', resourceRoot,
    function( selectedGadget )
		addPlayerGadget( client, selectedGadget )
	end
)

function addPlayerGadget( p, g )
	triggerClientEvent( p, 'activeClientGadget', p, g )
end

addEvent( 'givePlayerArmor', true )
addEventHandler( 'givePlayerArmor', resourceRoot,
    function( )
	    setPedArmor( client, gadgetsAmmo[3] )
	end
)

addEvent( 'resetClientGadget', true )
addEventHandler( 'resetClientGadget', resourceRoot,
    function( )
	    setElementAlpha( client, 255 )
		setElementData( client, 'cloakIsActive', 0 )
	end
)

-- Modo de jogo com quantidade de players equilibrado | Chamado de SPAR

local tempoRestante = 0
local checkPausado = false

function returnTeam1()
	return team['RED'] -- Retorna as configurações do time vermelho.
end

function returnTeam2()
	return team['BLU'] -- Retorna as configurações do time azul.
end

function returnScore1()
	return getElementData( team['RED'], 'Score' ) -- Retorna o placar do time vermelho.
end

function returnScore2()
	return getElementData( team['BLU'], 'Score' ) -- Retorna o placar do time azul.
end

function hideTab()
	triggerClientEvent ( "disableTabPanel", root) -- Após ser chamado no script do auto-SPAR, desabilita no client a tela de escolher o time.
end

function stopTimer()
    if g_MissionTimer then
        -- Obtém o tempo restante no temporizador
		if checkPausado == false then
        	tempoRestante = exports.missiontimer:getMissionTimerTime(g_MissionTimer)
			checkPausado = true
		end
        -- Para o temporizador
        exports.missiontimer:setMissionTimerTime(g_MissionTimer, tempoRestante)
    end
end

function returnTimer()
    if tempoRestante > 0 then
        -- Reinicia o temporizador com o tempo restante
        exports.missiontimer:setMissionTimerTime(g_MissionTimer, tempoRestante)

        tempoRestante = 0
		checkPausado = false
    end
end

function addPlayer( p, team, isRmv) -- Adiciona um player com o comando /add
    if ( p ) and ( team ) then
		if getElementData(p, 'State') == 'Alive' then
			return false
		end
	    local teamT = getElementData( team, 'teamType' )
		if ( teamT ) and ( not isRmv ) then
			local to_number = math.random( 1, tonumber( #TeamSpawns[teamT] ) )
		    local posX = TeamSpawns[teamT][to_number].posX + math.random(-1, 1)
            local posY = TeamSpawns[teamT][to_number].posY + math.random(-1, 1)
            local posZ = TeamSpawns[teamT][to_number].posZ
            spawnPlayer ( p, posX, posY, posZ, TeamSpawns[teamT][to_number].rot, TeamSpawns[teamT][to_number].skinModel, TeamSpawns[teamT][to_number].int, 0 )
		    setElementData( p, 'State', 'Alive' )
			triggerClientEvent( p, 'togglePlayerSpectate', p, false )
	    	triggerClientEvent( p, 'clientWeaponsMenu', p, team1Type )
			setElementData( p, 'roundKills', 0 )
			setElementData( p, 'roundHead', 0 )
		end
	end
end