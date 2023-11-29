local introMp3
local endRoundMp3

local timerCount
local counter = 0
local starttick
local currenttick

sX, sY = guiGetScreenSize( );

gui = { };
camdata = { };
clientdata = { };

function centerWindow( center_window )  -- Encontra o centro da tela de cada player.
    local screenW,screenH = guiGetScreenSize( )
    local windowW,windowH = guiGetSize( center_window, false )
    local x,y = ( screenW-windowW )/2,( screenH-windowH )/2
    guiSetPosition( center_window, x, y, false )
end

addEventHandler( 'onClientPlayerWasted', localPlayer, -- Após um jogador ser morto, busca players do time desse jogador que esteja vivo, para ele espectar.
    function( killer, weapon, bodypart )
	    local playerTeam = getPlayerTeam( localPlayer )
		if ( playerTeam ) and ( getElementData( localPlayer, 'State' ) == 'Alive' ) then
	        setGameSpeed( 1 )
		    setTimer( function( )
				if RoundStats.window[1] and guiGetVisible( RoundStats.window[1] ) == false then
					setGameSpeed( 1 );
				end
			end, 3000, 1 )
		end
	end
)

addEventHandler( 'onClientPlayerSpawn', localPlayer, -- Quando o player é spawnado cria um radar do tipo verde no canto inferior esquerdo do jogador.
    function( )
		setGameSpeed( 1 )
		if ( green_radar ) then
		    destroyElement( green_radar )
			green_radar = nil
		end
        local x,y,z = getElementPosition( localPlayer )
	    green_radar = createRadarArea( x-350, y-350, 700, 700, 0, 255, 0, 140 )
	end
)

addEvent( 'clientChangeTeam', true ) -- Ativa a seleção de equipes, para ser possível alterar o time.
addEventHandler( 'clientChangeTeam', localPlayer,
    function( )
	    guiSetVisible( gui.tabpanel['window'], true )
		showCursor( true )
		antiJoinTeamSpam( true )
	end
)

addEvent( 'clientJoinTeam2', true ) -- Esconde a tela de seleção de equipes e o mouse após o player selecionar a equipe.
addEventHandler( 'clientJoinTeam2', localPlayer,
    function( )
	    guiSetVisible( gui.tabpanel['window'], false )
		showCursor( false )
		attachRotatingCamera( false, localPlayer )
		setCameraInterior( 0 )
	end
)

addEvent( 'clientJoinTeam', true ) -- A mesma coisa que a função de cima, porém para a outra equipe.
addEventHandler( 'clientJoinTeam', localPlayer,
    function( )
	    guiSetVisible( gui.tabpanel['window'], false )
		showCursor( false )
		attachRotatingCamera( false, localPlayer )
		setCameraInterior( 0 )
	end
)

--[[ Armazene as posições dos jogadores quando eles morrem
local lastKillerPos = {x = 0, y = 0, z = 0}
local lastVictimPos = {x = 0, y = 0, z = 0}

addEventHandler("onClientPlayerWasted", root,
    function(killer)
        if source == localPlayer then
            -- Este é o jogador local, então ele é a vítima
            lastVictimPos.x, lastVictimPos.y, lastVictimPos.z = getElementPosition(source)
        elseif killer and killer == localPlayer then
            -- O jogador local é o assassino
            lastKillerPos.x, lastKillerPos.y, lastKillerPos.z = getElementPosition(killer)
        end
    end
)]]

addEvent( 'clientRoundEnd', true ) -- Ao finalizar o round msotra o vencedor e da kill nos players que ainda estavam vivos.
addEventHandler( 'clientRoundEnd', localPlayer,
function( table )
	local camPosX, camPosY, camPosZ, camLookX, camLookY, camLookZ, winTeamName
	camPosX = table[ 1 ]
	camPosY = table[ 2 ]
	camPosZ = table[ 3 ]
	camLookX = table[ 4 ]
	camLookY = table[ 5 ]
	camLookZ = table[ 6 ]
	winTeamName = table[ 7 ]
	w = winTeamName
	setGameSpeed( 0.02 )
	showPlayerHudComponent( 'radar', false )
	guiSetVisible( weaponsGui.window[1], false )
	guiSetVisible( weaponsGui.window[2], false )
	guiSetVisible( gui.images[ winTeamName ], true )
	fadeCamera( true )
	setElementData( localPlayer, 'State', 'Dead' )
	setTimer(
		function( )
			attachRotatingCamera( false, localPlayer )
			guiSetVisible( gui.images[ winTeamName ], false )
			fadeCamera( false, 0.01 )
			setCameraMatrix( camPosX, camPosY, camPosZ, camLookX, camLookY, camLookZ )
			setGameSpeed( 1 )
			setTimer( fadeCamera, 500, 1, true, 1.0 )
		end,
	5500,1 )
	setTimer(
		function( )
			triggerServerEvent( 'takeClientWeapons', resourceRoot )
			setGameSpeed( 1 )
		end,
	6000,1 )
	showCursor( true )
	endRoundMp3 = playSound( "audio/round_end.mp3" );
end

)

addEvent( 'clientMapStart', true ) -- Resumidamente inicializa uma troca de mapas e habilita a seleção de equipes.
addEventHandler( 'clientMapStart', localPlayer,
	function( table )
		local camPosX, camPosY, camPosZ, camLookX, camLookY, camLookZ, mapName, mapInterior, team1Name, team2Name, statsSystem, drawLasers, stealthIntro
		camPosX = table[ 1 ] or nil
		camPosY = table[ 2 ] or nil
		camPosZ = table[ 3 ] or nil
		camLookX = table[ 4 ] or nil
		camLookY = table[ 5 ] or nil
		camLookZ = table[ 6 ] or nil
		mapName = table[ 7 ] or nil
		mapInterior = table[ 8 ] or nil
		team1Name = table[ 9 ] or nil
		team2Name = table[ 10 ] or nil
		statsSystem = table[ 11 ] or nil
		drawLasers = table[ 12 ] or nil
		stealthIntro = table[ 13 ] or nil
	    attachRotatingCamera( false, localPlayer )
	    if ( team1Name ) and ( team2Name ) then
	        clientdata[1] = team1Name
		    clientdata[2] = team2Name
			if ( statsSystem ) then
				clientdata[3] = statsSystem
			end
		    guiSetText( gui.button[1], ''..team1Name..'-' )
		    guiSetText( gui.button[2], ''..team2Name..'-' )
			if ( drawLasers ) then
			    clientdata[4] = drawLasers
			end
		end
	    nazwaMapy = mapName
		local timers = getTimers( )
		if ( timers ) then
		    for k, t in pairs( timers ) do
			    if ( t ~= reduceSoundTimer ) or ( t ~= infoBox.timer ) then
		            killTimer( t )
				end
		    end
		end
		if ( w ) then
		    guiSetVisible( gui.images[ w ], false )
		end
	    showPlayerHudComponent( 'clock', false )
	    showPlayerHudComponent( 'area_name', false )
		showPlayerHudComponent( 'radar', false )
		showPlayerHudComponent( 'money', false )
	    setElementHealth( localPlayer, 0 )
		if mapInterior then setElementInterior( localPlayer, mapInterior ) end
		setElementData( localPlayer, 'State', 'Dead' )
	    fadeCamera( true, 1.0 )
	    setCameraMatrix( camPosX, camPosY, camPosZ, camLookX, camLookY, camLookZ )
		if weaponsGui.window[1] then guiSetVisible( weaponsGui.window[1], false ) end
		if weaponsGui.window[2] then guiSetVisible( weaponsGui.window[2], false ) end
		guiSetVisible( gui.tabpanel['window'], true )
		showCursor( true )
		antiJoinTeamSpam( true )
	end
)

function antiJoinTeamSpam( bool ) -- Impede floodar os botões de seleções de equipe e armas.
	guiSetEnabled( gui.button[1], bool )
	guiSetEnabled( gui.button[2], bool )
	guiSetEnabled( gui.button[3], bool )
	guiSetEnabled( gui.button[4], bool )
end

function joinRED( ) -- Insere o jogador no time vermelho caso for possível.
    setElementHealth( localPlayer, 0 )
    local teamRedCount = countPlayersInTeam( getTeamFromName( clientdata[1] ) )
	local teamBlueCount = countPlayersInTeam( getTeamFromName( clientdata[2] ) )
	if ( teamRedCount == teamBlueCount ) then
	    triggerServerEvent( 'joinTeam', resourceRoot, 'RED' )
		playSoundFrontEnd( 0 )
		antiJoinTeamSpam( false )
	elseif ( teamRedCount > teamBlueCount ) then
	    outputChatBox( "● O Time vermelho tem muito jogadores.", 222, 222, 222, true )
    elseif ( teamRedCount < teamBlueCount ) then	
        triggerServerEvent( 'joinTeam', resourceRoot, 'RED' )
		playSoundFrontEnd( 0 )
		antiJoinTeamSpam( false )
	end
	stopSound( introMp3 );
end

function joinBLU( ) -- Insere o jogador no time azul caso for possível.
    setElementHealth( localPlayer, 0 )
    local teamRedCount = countPlayersInTeam( getTeamFromName( clientdata[1] ) )
	local teamBlueCount = countPlayersInTeam( getTeamFromName( clientdata[2] ) )
	if ( teamBlueCount == teamRedCount ) then
	    triggerServerEvent( 'joinTeam', resourceRoot, 'BLU' )
		playSoundFrontEnd( 0 )
		antiJoinTeamSpam( false )
	elseif ( teamBlueCount > teamRedCount ) then
	    outputChatBox( "● O time azul tem muitos jogadores.", 222, 222, 222, true )
	elseif ( teamBlueCount < teamRedCount ) then
	    triggerServerEvent( 'joinTeam', resourceRoot, 'BLU' )
		playSoundFrontEnd( 0 )
		antiJoinTeamSpam( false )
	end
	stopSound( introMp3 );
end

function joinAA( ) -- Escolhe um time para o jogador de acordo com a necessidade da partida.
    local teamRedCount = countPlayersInTeam( getTeamFromName( clientdata[1] ) )
	local teamBlueCount = countPlayersInTeam( getTeamFromName( clientdata[2] ) )
	if ( teamRedCount == teamBlueCount ) then
	    triggerServerEvent( 'joinTeam', resourceRoot, 'RED' )
		playSoundFrontEnd( 0 )
		antiJoinTeamSpam( false )
	elseif ( teamRedCount > teamBlueCount ) then
	    triggerServerEvent( 'joinTeam', resourceRoot, 'BLU' )
		playSoundFrontEnd( 0 )
    elseif ( teamRedCount < teamBlueCount ) then	
        triggerServerEvent( 'joinTeam', resourceRoot, 'RED' )
		playSoundFrontEnd( 0 )
		antiJoinTeamSpam( false )
	end
	stopSound( introMp3 );
end

function joinSP( ) -- Insere o jogador no modo espectador.
    antiJoinTeamSpam( false )
    triggerServerEvent( 'joinSpectate', resourceRoot )
	playSoundFrontEnd( 0 )
	stopSound( introMp3 );
end

addEventHandler( 'onClientRender', root, -- Atualiza o FPS e o ping do player a cada frame.
    function( )
		if not starttick then
			starttick = getTickCount( )
		end
		counter = counter + 1
		currenttick = getTickCount( )
		if ( currenttick - starttick >= 1000 ) then
			setElementData( localPlayer, "FPS", counter )
			counter = 0
			starttick = false
		end
		dxDrawText( 'FPS: '..getElementData( localPlayer, 'FPS' )..' PING: '..getPlayerPing( localPlayer ), sX*0.5, sY*0.05, sX*0.5, sY*0.05, tocolor ( 255, 255, 255, 180 ), 1, 'default', "center", "top", false, false, true, false, false )
	    if ( guiGetVisible( gui.images['red'] ) == true ) or ( guiGetVisible( gui.images['blu'] ) == true ) or ( guiGetVisible( gui.images['tie'] ) == true ) then
		    guiSetVisible( RoundStats.window[1], true )
		end
	end
)

local rotSpeed = 1
local angle = 0
local elem
local zOff
local dist
local active = false
 
function getPointFromDistanceRotation( x, y, dist, angle ) -- Define uma distância de rotação do player.
    local a = math.rad( 90 - angle )
    local dx = math.cos( a ) * dist;
    local dy = math.sin( a ) * dist;
    return x+dx, y+dy;
end
 
function attachRotatingCamera( bool, element, Zoffset, distance ) -- Inicializa a rotação.
   if bool then
      active = true
      elem,zOff,dist=element,Zoffset,distance
      addEventHandler( "onClientRender", root, createRotRamera )
   else
      removeEventHandler( "onClientRender", root, createRotRamera )
      active = false
   end
end
 
function createRotRamera( ) -- Cria a rotação de câmera sobre um player.
   local x,y,z=getElementPosition( elem )
   local camx,camy=getPointFromDistanceRotation( x, y, dist, angle )
   setCameraMatrix( camx, camy, z + zOff, x, y, z )
   angle = ( angle + rotSpeed )%360
end

addEventHandler( 'onClientResourceStart', getResourceRootElement( getThisResource( ) ), -- Cria as janelas necessárias ao inicializar o script.
    function( )
	    gui.font = {}
		gui.images = {}
		gui.tab = {}
		gui.button = {}
		gui.tabpanel = {}
		gui.memo = {}
		gui.label = {}
	    gui.font[1] = guiCreateFont( "fonts/cs_regular.ttf", 15 )
	    gui.font[2] = guiCreateFont( "fonts/cs_regular.ttf", 9 )
		gui.font[3] = guiCreateFont( "fonts/cs_regular.ttf", 12 )
		gui.images['red'] = guiCreateStaticImage( 0.0, 0.0, 1279.0, 767.0, 'img/red.png', true )
		gui.images['blu'] = guiCreateStaticImage( 0.0, 0.0, 1279.0, 767.0, 'img/blu.png', true )
		gui.images['tie'] = guiCreateStaticImage( 0.0, 0.0, 1279.0, 767.0, 'img/tie.png', true )
		guiSetEnabled( gui.images['red'], false )
		guiSetEnabled( gui.images['blu'], false )
		guiSetEnabled( gui.images['tie'], false )
		guiSetAlpha( gui.images['red'], 0.7 )
		guiSetAlpha( gui.images['blu'], 0.7 )
		guiSetAlpha( gui.images['tie'], 0.7 )
		guiSetVisible( gui.images['red'], false )
		guiSetVisible( gui.images['blu'], false )
		guiSetVisible( gui.images['tie'], false )
	    gui.tabpanel['window'] = guiCreateTabPanel( 0.33, 0.30, 0.33, 0.40, true )
		if gui.tabpanel['window'] then
			guiSetFont( gui.tabpanel['window'], "default-bold-small" );
	    	guiSetAlpha( gui.tabpanel['window'], 0.85 );
	    	gui.tab[1] = guiCreateTab( "CHOOSE YOUR TEAM", gui.tabpanel['window'] )
	    	gui.button[1] = guiCreateButton( 0.02, 0.10, 0.47, 0.39, "RED-", true, gui.tab[1] )
	    	guiSetFont( gui.button[1], gui.font[1] )
	    	guiSetProperty( gui.button[1], "NormalTextColour", "FFF30000" )
	    	gui.button[2] = guiCreateButton(0.51, 0.10, 0.47, 0.39, "BLUE-", true, gui.tab[1] )
        	guiSetFont( gui.button[2], gui.font[1] )
        	guiSetProperty( gui.button[2], "NormalTextColour", "FF001CF3" )
        	gui.button[3] = guiCreateButton( 0.02, 0.67, 0.96, 0.13, "Auto-Assign", true, gui.tab[1] )
        	guiSetFont( gui.button[3], gui.font[2] )
        	guiSetProperty( gui.button[3], "NormalTextColour", "FF7F7F7F" )
        	gui.button[4] = guiCreateButton( 0.02, 0.83, 0.96, 0.13, "Spectate", true, gui.tab[1] )
        	guiSetFont( gui.button[4], gui.font[2] )
        	guiSetProperty( gui.button[4], "NormalTextColour", "FF7F7F7F" )
	    	guiSetVisible( gui.tabpanel['window'], false )
		end
		showCursor( true )
	    addEventHandler( 'onClientGUIClick', gui.button[1], joinRED, false )
  	    addEventHandler( 'onClientGUIClick', gui.button[2], joinBLU, false )
		addEventHandler( 'onClientGUIClick', gui.button[3], joinAA, false )
		addEventHandler( 'onClientGUIClick', gui.button[4], joinSP, false )
	    showPlayerHudComponent( 'area_name', false )
	    showPlayerHudComponent( 'clock', false )
	    showPlayerHudComponent( 'money', false )
	    showPlayerHudComponent( 'radio', false )
	    showPlayerHudComponent( 'radar', false )
		RoundStats = {
            window = { },
			gridlist = { },
			column = { }
		}
        RoundStats.window[1] = guiCreateWindow( 430/1366*sX, 410/768*sY, 513/1366*sX, 203/768*sY, "Round-Stats", true )
        guiWindowSetSizable( RoundStats.window[1], false )
        guiSetAlpha( RoundStats.window[1], 0.50 )
        RoundStats.gridlist[1] = guiCreateGridList( 0.02, 0.12, 0.96, 0.95, true, RoundStats.window[1] )
		if RoundStats.gridlist[1] then
		    guiSetFont( RoundStats.gridlist[1], 'default-small' )
		end
        RoundStats.column[1] = guiGridListAddColumn( RoundStats.gridlist[1], "Player", 0.4 )
        RoundStats.column[2] = guiGridListAddColumn( RoundStats.gridlist[1], "Kills", 0.2 )
        RoundStats.column[3] = guiGridListAddColumn( RoundStats.gridlist[1], "Headshots", 0.2 )    
		if RoundStats.window[1] then
		    guiWindowSetMovable( RoundStats.window[1], false )
			guiWindowSetSizable( RoundStats.window[1], false )
		    guiSetVisible( RoundStats.window[1], false )
		end
        setCloudsEnabled( false )
        setHeatHaze( 0 )
		setFogDistance( 0 )
		triggerServerEvent( 'downloadEnd', resourceRoot )
		outputDebugString( " " )
		introMp3 = playSound( "audio/intro.mp3" );
		setSoundVolume(introMp3, 0.3)
    end
)

addEvent( "Client:endCameraTarget", true ); -- Rotaciona a câmera sobre os dois ultimos players vivos pós-round.
addEventHandler( "Client:endCameraTarget", localPlayer,
function( table )
	local killer, source
	killer = table[ 1 ]
	source = table[ 2 ]
	if killer and getElementType( killer ) == "player" then
		attachRotatingCamera( true, killer, 0.7, 4.5 );
	end
	setTimer( function( )
		if RoundStats.window[1] and guiGetVisible( RoundStats.window[1] ) == true then
			attachRotatingCamera( false, localPlayer );
			if source and getElementType( source ) == "player" then
				attachRotatingCamera( true, source, 0.7, 4.5 );
			end
		end
	end, 4000, 1 )
end )

addEvent( "disableTabPanel", true) -- Desativa a seleção de times quando chamada no lado server.
addEventHandler( "disableTabPanel", root,
	function ()
		guiSetVisible( gui.tabpanel['window'], false )
		showCursor( false )
		stopSound( introMp3 );
	end
)

-- Parte da seleção necessária de armas e processamento de saves weapons

local weaponsCheck = {}

local weapons1 = {}
local weapons2 = {}
local weapons3 = {}

weaponsGui = {  -- Todas as janelas para a criação da "gui" weapons.
    gridlist = {},
    window = {},
    button = {},
	checkbox = {}
}

mercenariesWeapons = {
["primary"] = {
				"m4",
				"ak-47",
				"rifle",
				},
["secondary"] = {
                "deagle",
				},
["throwable"] = {
				"grenade",
				},
["spygadget"] = {
				"armor",
				}
}
spiesWeapons = {
["primary"] = {
                "m4",
				"ak-47",
				"rifle",
				},
["secondary"] = {
                "deagle",
				},
["throwable"] = {
				"grenade",
				},
["spygadget"] = {
				"armor",
				}
}

addEvent( 'clientWeaponsMenu', true ) -- Exibe a guia de seleção de armas para todos os players.
addEventHandler( 'clientWeaponsMenu', localPlayer,
    function( teamType )
		if weaponsCheck[localPlayer] == true then
			triggerServerEvent( 'givePlayerWeapons', resourceRoot, getWeaponIDFromName( weapons1[localPlayer] ), getWeaponIDFromName( weapons2[localPlayer] ), getWeaponIDFromName( weapons3[localPlayer] ) )
			triggerServerEvent( 'givePlayerGadget', resourceRoot, spygadgetWeapon )
			attachRotatingCamera( false, getLocalPlayer( ) )
			fadeCamera( false, 0.01 )
			showCursor( false )
			setCameraTarget( getLocalPlayer( ) )
			setPedWeaponSlot( getLocalPlayer( ), 2 )
			setCameraTarget( getLocalPlayer( ) )
			setTimer( fadeCamera, 300, 1, true, 1.0 )
			showPlayerHudComponent( 'radar', true )
			return
		end
		fadeCamera( false, 0.01 )
		showCursor( true )
		attachRotatingCamera( true, getLocalPlayer( ), math.random( 1.0, 2.0 ), math.random( 2.5, 4.5 ))
		setTimer(
		    function( )
			    fadeCamera( true, 1.0 )
	            if ( teamType == 'Terrorists' ) then
		            guiSetVisible( weaponsGui.window[1], true )
		        else
		            guiSetVisible( weaponsGui.window[2], true )
		        end
			end,
		700,1 )
    	if afkTimer and isTimer( afkTimer ) then
	        killTimer( afkTimer )
	    	afkTimer = nil
	    end
		afkTimer = setTimer( IsPlayerAfk, 60000, 1 )
	end
)

function IsPlayerAfk( ) -- Da kill no player que não selecionou as armas nem apertou nenhuma tecla por quase 1 minuto.
    guiSetVisible( weaponsGui.window[1], false )
	guiSetVisible( weaponsGui.window[2], false )
	attachRotatingCamera( false, getLocalPlayer( ) )
    triggerServerEvent( 'IsClientPlayerAfk', resourceRoot )
end

addEventHandler( 'onClientPlayerWasted', getLocalPlayer( ), -- Caso o player for morto antes de selecionar as armas, o painel some da tela.
    function( )
	    if weaponsGui.window[1] then guiSetVisible( weaponsGui.window[1], false ) end
		if weaponsGui.window[2] then guiSetVisible( weaponsGui.window[2], false ) end
		if ( guiGetVisible( gui.tabpanel['window'] ) == false ) then
		    showCursor( false )
		end
		attachRotatingCamera( false, getLocalPlayer( ) )
	end
)

function giveMeWeapons( button, state, absoluteX, absoluteY) -- Resumidamente pega o item selecionado em cada GridList, busca o ID do item e seta para o player.
	local player = getLocalPlayer()
    if ( afkTimer ) then
	    killTimer( afkTimer )
		afkTimer = nil
	end
    if ( source == weaponsGui.button[1] ) then
		guiSetVisible( weaponsGui.window[1], false )
		local primaryWeapon = guiGridListGetItemText( weaponsGui.gridlist[1], guiGridListGetSelectedItem ( weaponsGui.gridlist[1] ), 1 )
		local secondaryWeapon = guiGridListGetItemText( weaponsGui.gridlist[2], guiGridListGetSelectedItem ( weaponsGui.gridlist[2] ), 1 )
		local throwableWeapon = guiGridListGetItemText( weaponsGui.gridlist[3], guiGridListGetSelectedItem ( weaponsGui.gridlist[3] ), 1 )
		weapons1[player] = guiGridListGetItemText( weaponsGui.gridlist[1], guiGridListGetSelectedItem ( weaponsGui.gridlist[1] ), 1 )
		weapons2[player] = guiGridListGetItemText( weaponsGui.gridlist[2], guiGridListGetSelectedItem ( weaponsGui.gridlist[2] ), 1 )
		weapons3[player] = guiGridListGetItemText( weaponsGui.gridlist[3], guiGridListGetSelectedItem ( weaponsGui.gridlist[3] ), 1 )
		triggerServerEvent( 'givePlayerWeapons', resourceRoot, getWeaponIDFromName( primaryWeapon ), getWeaponIDFromName( secondaryWeapon ), getWeaponIDFromName( throwableWeapon ) )
		triggerServerEvent( 'givePlayerGadget', resourceRoot, spygadgetWeapon )
	end
	if ( source == weaponsGui.button[2] ) then
	    guiSetVisible( weaponsGui.window[2], false )
		local primaryWeapon = guiGridListGetItemText( weaponsGui.gridlist[4], guiGridListGetSelectedItem ( weaponsGui.gridlist[4] ), 1 )
		local secondaryWeapon = guiGridListGetItemText( weaponsGui.gridlist[5], guiGridListGetSelectedItem ( weaponsGui.gridlist[5] ), 1 )
		local throwableWeapon = guiGridListGetItemText( weaponsGui.gridlist[6], guiGridListGetSelectedItem ( weaponsGui.gridlist[6] ), 1 )
		weapons1[player] = guiGridListGetItemText( weaponsGui.gridlist[4], guiGridListGetSelectedItem ( weaponsGui.gridlist[4] ), 1 )
		weapons2[player] = guiGridListGetItemText( weaponsGui.gridlist[5], guiGridListGetSelectedItem ( weaponsGui.gridlist[5] ), 1 )
		weapons3[player] = guiGridListGetItemText( weaponsGui.gridlist[6], guiGridListGetSelectedItem ( weaponsGui.gridlist[6] ), 1 )
		triggerServerEvent( 'givePlayerWeapons', resourceRoot, getWeaponIDFromName( primaryWeapon ), getWeaponIDFromName( secondaryWeapon ), getWeaponIDFromName( throwableWeapon ) )
		triggerServerEvent( 'givePlayerGadget', resourceRoot, spygadgetWeapon )
	end
	attachRotatingCamera( false, getLocalPlayer( ) )
	fadeCamera( false, 0.01 )
	showCursor( false )
	setCameraTarget( getLocalPlayer( ) )
	setPedWeaponSlot( getLocalPlayer( ), 2 )
	setCameraTarget( getLocalPlayer( ) )
	setTimer( fadeCamera, 300, 1, true, 1.0 )
	showPlayerHudComponent( 'radar', true )
end

addEvent( 'createStealthWeaponsGui', true ) -- Cria as guias e define suas propriedades.
addEventHandler( 'createStealthWeaponsGui', localPlayer,
    function( weaponsAmmo, gadgetsAmmo )

	    cWeaponsAmmo = weaponsAmmo
		cGadgetsAmmo = gadgetsAmmo
		
		local sX, sY = guiGetScreenSize( )

        weaponsGui.window[1] = guiCreateWindow( 322/1366*sX, 365/768*sY, 741.25/1366*sX, 225/768*sY, "SPIES MENU", false )
        guiSetAlpha( weaponsGui.window[1], 0.7 )
        guiWindowSetMovable( weaponsGui.window[1], false )
        guiWindowSetSizable( weaponsGui.window[1], false )
		weaponsGui.checkbox[1] = guiCreateCheckBox( 0.02, 0.05, 0.96, 0.12, "Save weapons", false, true, weaponsGui.window[1] )
        weaponsGui.gridlist[1] = guiCreateGridList( 0.07, 0.17, 0.23, 0.62, true, weaponsGui.window[1] )
		guiSetFont(weaponsGui.gridlist[1], "fonts/Roboto-Black.ttf")
		guiGridListAddColumn ( weaponsGui.gridlist[1], "primary", 0.56 )
		guiGridListAddColumn ( weaponsGui.gridlist[1], "ammo", 0.2 )
		for key,weaponName in pairs( spiesWeapons["primary"] ) do
		    local row = guiGridListAddRow ( weaponsGui.gridlist[1] )
			guiGridListSetItemText( weaponsGui.gridlist[1], row, 1, weaponName, false, false )
			guiGridListSetItemText( weaponsGui.gridlist[1], row, 2, cWeaponsAmmo[getWeaponIDFromName( weaponName )], false, false )
		end
		guiGridListSetSelectedItem( weaponsGui.gridlist[1], 0, 1, true )
        weaponsGui.gridlist[2] = guiCreateGridList( 0.37, 0.17, 0.23, 0.62, true, weaponsGui.window[1] )
		guiSetFont(weaponsGui.gridlist[2], "fonts/Roboto-Black.ttf")
		guiGridListAddColumn ( weaponsGui.gridlist[2], "secondary", 0.56 )
		guiGridListAddColumn ( weaponsGui.gridlist[2], "ammo", 0.2 )
		for key,weaponName in pairs( spiesWeapons["secondary"] ) do
		    local row = guiGridListAddRow ( weaponsGui.gridlist[2] )
			guiGridListSetItemText( weaponsGui.gridlist[2], row, 1, weaponName, false, false )
			guiGridListSetItemText( weaponsGui.gridlist[2], row, 2, cWeaponsAmmo[getWeaponIDFromName( weaponName )], false, false )
		end
		guiGridListSetSelectedItem( weaponsGui.gridlist[2], 0, 1, true )
        weaponsGui.gridlist[3] = guiCreateGridList( 0.67, 0.17, 0.23, 0.62, true, weaponsGui.window[1] )
		guiSetFont(weaponsGui.gridlist[3], "fonts/Roboto-Black.ttf")
		guiGridListAddColumn ( weaponsGui.gridlist[3], "throwable", 0.56 )
		guiGridListAddColumn ( weaponsGui.gridlist[3], "ammo", 0.2 )
		for key,weaponName in pairs( spiesWeapons["throwable"] ) do
		    local row = guiGridListAddRow ( weaponsGui.gridlist[3] )
			guiGridListSetItemText( weaponsGui.gridlist[3], row, 1, weaponName, false, false )
			guiGridListSetItemText( weaponsGui.gridlist[3], row, 2, cWeaponsAmmo[getWeaponIDFromName( weaponName )], false, false )
		end		
		guiGridListSetSelectedItem( weaponsGui.gridlist[3], 0, 1, true )
        weaponsGui.button[1] = guiCreateButton( 0.02, 0.82, 0.96, 0.12, "OK", true, weaponsGui.window[1] )
        guiSetProperty( weaponsGui.button[1], "NormalTextColour", "FFAAAAAA" ) 
		guiSetVisible( weaponsGui.window[1], false )
		addEventHandler('onClientGUIClick', weaponsGui.button[1], clickButton1, true)
		addEventHandler( 'onClientGUIClick', weaponsGui.button[1], giveMeWeapons, false )
        weaponsGui.window[2] = guiCreateWindow( 322/1366*sX, 365/768*sY, 741.25/1366*sX, 225/768*sY, "MERCENARIES MENU", false )
		guiSetAlpha( weaponsGui.window[2], 0.7 )
        guiWindowSetMovable( weaponsGui.window[2], false )
        guiWindowSetSizable( weaponsGui.window[2], false )
        weaponsGui.checkbox[2] = guiCreateCheckBox( 0.02, 0.05, 0.96, 0.12, "Save weapons", false, true, weaponsGui.window[2] )
		weaponsGui.gridlist[4] = guiCreateGridList( 0.07, 0.17, 0.23, 0.62, true, weaponsGui.window[2] )
		guiSetFont(weaponsGui.gridlist[4], "fonts/Roboto-Black.ttf")
		guiGridListAddColumn ( weaponsGui.gridlist[4], "primary", 0.56 )
		guiGridListAddColumn ( weaponsGui.gridlist[4], "ammo", 0.2 )
		for key,weaponName in pairs( mercenariesWeapons["primary"] ) do
		    local row = guiGridListAddRow ( weaponsGui.gridlist[4] )
			guiGridListSetItemText( weaponsGui.gridlist[4], row, 1, weaponName, false, false )
			guiGridListSetItemText( weaponsGui.gridlist[4], row, 2, cWeaponsAmmo[getWeaponIDFromName( weaponName )], false, false )
		end
		guiGridListSetSelectedItem( weaponsGui.gridlist[4], 0, 1, true )
        weaponsGui.gridlist[5] = guiCreateGridList( 0.37, 0.17, 0.23, 0.62, true, weaponsGui.window[2] )
		guiSetFont(weaponsGui.gridlist[5], "fonts/Roboto-Black.ttf")
		guiGridListAddColumn ( weaponsGui.gridlist[5], "secondary", 0.56 )
		guiGridListAddColumn ( weaponsGui.gridlist[5], "ammo", 0.2 )
		for key,weaponName in pairs( mercenariesWeapons["secondary"] ) do
		    local row = guiGridListAddRow ( weaponsGui.gridlist[5] )
			guiGridListSetItemText( weaponsGui.gridlist[5], row, 1, weaponName, false, false )
			guiGridListSetItemText( weaponsGui.gridlist[5], row, 2, cWeaponsAmmo[getWeaponIDFromName( weaponName )], false, false )
		end
		guiGridListSetSelectedItem( weaponsGui.gridlist[5], 0, 1, true )
        weaponsGui.gridlist[6] = guiCreateGridList( 0.67, 0.17, 0.23, 0.62, true, weaponsGui.window[2] )
		guiSetFont(weaponsGui.gridlist[6], "fonts/Roboto-Black.ttf")
		guiGridListAddColumn ( weaponsGui.gridlist[6], "throwable", 0.56 )
		guiGridListAddColumn ( weaponsGui.gridlist[6], "ammo", 0.2 )
		for key,weaponName in pairs( mercenariesWeapons["throwable"] ) do
		    local row = guiGridListAddRow ( weaponsGui.gridlist[6] )
			guiGridListSetItemText( weaponsGui.gridlist[6], row, 1, weaponName, false, false )
			guiGridListSetItemText( weaponsGui.gridlist[6], row, 2, cWeaponsAmmo[getWeaponIDFromName( weaponName )], false, false )
		end		
		guiGridListSetSelectedItem( weaponsGui.gridlist[6], 0, 1, true )
        weaponsGui.button[2] = guiCreateButton( 0.02, 0.82, 0.96, 0.12, "OK", true, weaponsGui.window[2] )
        guiSetProperty( weaponsGui.button[2], "NormalTextColour", "FFAAAAAA" ) 
		guiSetVisible( weaponsGui.window[2], false )
		guiSetFont( weaponsGui.button[1], gui.font[2] )
		guiSetFont( weaponsGui.button[2], gui.font[2] )
		addEventHandler('onClientGUIClick', weaponsGui.button[2], clickButton2, true)
		addEventHandler( 'onClientGUIClick', weaponsGui.button[2], giveMeWeapons, false )
	end
)

function clickButton1 (button, state, absoluteX, absoluteY) -- Checa se o 'save' para as armas do team RED foi ativada.
	local player = getLocalPlayer()
	if guiCheckBoxGetSelected(weaponsGui.checkbox[1]) then
		weaponsCheck[player] = true
	end
end

function clickButton2 (button, state, absoluteX, absoluteY) -- Checa se o 'save' para as armas do team BLUE foi ativada.
	local player = getLocalPlayer()
	if guiCheckBoxGetSelected(weaponsGui.checkbox[2]) then
		weaponsCheck[player] = true
	end
end

bindKey("b", "down",  -- Desativa o save dos players, a guia de s eleção de armas volta a aparecer na tela do jogador quando ele é spawnado.
function ()
	local player = getLocalPlayer()
	if weaponsCheck[player] == true then
		weaponsCheck[player] = false
		outputChatBox("Weapon selector activated.")
		return
	end
end
)

-- Esta parte permite que outros players possam assistir os outros jogarem da mesma visão que a do jogador.

function dxSpectate( ) -- Desenha o nome de cada player (Aquele que esta sendo espectado)
	local camTarget = getCameraTarget( )
	if ( camTarget ) then
	    dxDrawText( 'Player: #FFA500'..tostring( getPlayerName( camTarget ) )..'', sX*0.5, sY*0.95, sX*0.5, sY*0.9, tocolor ( 150, 150, 150, 222 ), 0.8, 'bankgothic', "center", "top", false, false, true, true, false )
	    local teamName = getTeamName( getPlayerTeam( camTarget ) )
		local playerKills = getElementData( camTarget, 'Kills' )
		local playerDeaths = getElementData( camTarget, 'Deaths' )
		dxDrawText( '|\n|\n|\n|\n', sX*0.84, sY*0.02, sX*0.78, sY*0.02, tocolor ( 255, 150, 0, 222 ), 0.6, 'bankgothic', "left", "top", false, false, true, true, false )
		dxDrawText( '#FFA500Team: #FFFFFF'..teamName..'\n#FFA500Kills: #FFFFFF'..playerKills..'\n#FFA500Deaths: #FFFFFF'..playerDeaths..'', sX*0.86, sY*0.032, sX*0.8, sY*0.02, tocolor ( 255, 255, 255, 222 ), 0.6, 'bankgothic', "left", "top", false, false, true, true, false )
	end
end

function getAlivePlayers( ) -- Resgata todos os players vivos na hora da execução da função.
    local table = { };
    for i,v in ipairs( getElementsByType( "player" ) ) do
		if not isPedDead( v ) then
			table.insert( table, v );
		end 
    end
    return table;
end

function getAlivePlayersInTeam( theTeam ) -- Função para pegar os players que estão vivos de determinado time.
	local table = { };
	local players = getPlayersInTeam( theTeam );
	for i,v in pairs( players ) do
		if not isPedDead( v ) then
			table.insert( table, v );
		end
	end
	return table;
end

function spectateStart( ) -- Inicia o spectate
    if ( g_Players ) then
	    g_Players = nil
	end
	local localTeamName = getTeamName( getPlayerTeam( getLocalPlayer( ) ) )
	if ( localTeamName == "SPECTATORS" ) then
		g_Players = getElementsByType( "player" )
		for i,aPlayer in ipairs( g_Players ) do
			if ( aPlayer == getLocalPlayer( ) ) then
			    g_CurrentSpectated = i
				break
			end
		end
	else
		g_Players = getPlayersInTeam( getTeamFromName( localTeamName ) )
		for i,aPlayer in ipairs( g_Players ) do
			if ( aPlayer == getLocalPlayer( ) ) then
			    g_CurrentSpectated = i
				break
			end
		end
	end
	bindKey( "arrow_l", "down", spectatePrevious )
	bindKey( "arrow_r", "down", spectateNext )
	bindKey( "r", "down", spectateNext )
	showPlayerHudComponent( 'radar', false )
	spectateNext( )
	showCursor( false )
end

function spectateStop( ) -- Finaliza o spect
	unbindKey( "arrow_l", "down", spectatePrevious )
	unbindKey( "arrow_r", "down", spectateNext )
	unbindKey( "r", "down", spectateNext )
end

function spectatePrevious( ) -- Passa o spectate para trás.
    if g_CurrentSpectated == 1 then
        g_CurrentSpectated = #g_Players
    else
        g_CurrentSpectated = g_CurrentSpectated - 1
    end
    setCameraTarget( g_Players[g_CurrentSpectated] )
end
 
function spectateNext( ) -- Faz o oposto, alterna entre os jogadores vivos para frente.
    if g_CurrentSpectated == #g_Players then
        g_CurrentSpectated = 1
    else
        g_CurrentSpectated = g_CurrentSpectated + 1
    end
    setCameraTarget( g_Players[g_CurrentSpectated] )
end

addEvent( 'togglePlayerSpectate', true ) -- Verifica se o player esta vivo ou não para que possa ser espectado.
addEventHandler( 'togglePlayerSpectate', localPlayer,
    function( bool )
	    if ( bool == true ) then
		    spectateStart( )
			addEventHandler( 'onClientRender', getRootElement( ), dxSpectate )
		end
		if ( bool == false ) then
		    spectateStop( )
			removeEventHandler( 'onClientRender', getRootElement( ), dxSpectate )
		end
	end
)

-- Cria uma progressbar responsável por mostrar o player no mapa ou não (Desativado)

soundGui = {
    label = { },
    progressbar = { }
}

addEventHandler( 'onClientResourceStart', getResourceRootElement( getThisResource( ) ),
    function( startedResource )
        soundGui.progressbar[1] = guiCreateProgressBar( 0.89, 0.949666, 0.11, 0.05, false )
        guiSetAlpha( soundGui.progressbar[1], 0.56 )
        guiProgressBarSetProgress( soundGui.progressbar[1], 0 )
        soundGui.label[1] = guiCreateLabel( 0.06, 0.13, 0.89, 0.73, "SOUND", false, soundGui.progressbar[1] )
        guiLabelSetColor( soundGui.label[1], 0, 0, 0 )
        guiLabelSetHorizontalAlign( soundGui.label[1], "center", false )
        guiLabelSetVerticalAlign( soundGui.label[1], "center" )
		
		soundLevel = 100
		isPlayerMoving = 1
		
		bindKey( "forwards", "down", walkSoundStart )
		bindKey( "backwards", "down", walkSoundStart )
		bindKey( "left", "down", walkSoundStart )
		bindKey( "right", "down", walkSoundStart )
		
		bindKey( "forwards", "up", walkSoundStop )
		bindKey( "backwards", "up", walkSoundStop )
		bindKey( "left", "up", walkSoundStop )
		bindKey( "right", "up", walkSoundStop )
		
		guiSetEnabled( soundGui.progressbar[1], false )
	end
)

function walkSoundStart( player, key, keyState )
    if ( isPlayerMoving == 0 ) then
	    isPlayerMoving = 1
		movecheck = setTimer( walkcheck, 900, 0 )
	end
end

function walkSoundStop( player, key, keyState )
    if ( isPlayerMoving == 1 ) then
	if getKeyState( 'w' ) == false and getKeyState( 's' ) == false and getKeyState( 'a' ) == false and getKeyState( 'd' ) == false and getKeyState( 'arrow_l' ) == false and getKeyState( 'arrow_u' ) == false and getKeyState( 'arrow_r' ) == false and getKeyState( 'arrow_d' ) == false then
	    isPlayerMoving = 1
		if movecheck and isTimer( movecheck ) then
		    killTimer( movecheck )
		end
		end
	end
end

function walkcheck( source, key, keystate )
    if ( isPedDucked( getLocalPlayer () ) ) == false then
        if ( getControlState( "sprint" ) ) then
            soundLevel = 100
        end
        if ( getControlState( "walk" ) ) == false then
            soundLevel = 100
        end
    end
end

addEventHandler( 'onClientPlayerDamage', getLocalPlayer( ),
    function( )
	    soundLevel = 100
	end
)

addEventHandler( 'onClientPlayerWeaponFire', getLocalPlayer( ),
    function( weapon )
		if weapon == 22 then
			soundLevel = 100
		elseif weapon == 24 then
			soundLevel = 100
		elseif weapon == 25 then
			soundLevel = 100
		elseif weapon == 27 then
			soundLevel = 100
		elseif weapon == 28 then
			soundLevel = 100
		elseif weapon == 29 then
			soundLevel = 100
		elseif weapon == 30 then
			soundLevel = 100
		elseif weapon == 31 then
			soundLevel = 100
		elseif weapon == 32 then
			soundLevel = 100
		elseif weapon == 33 then
			soundLevel = 100
		elseif weapon == 34 then
			soundLevel = 100
		end   
	end
)

function reduceSoundLevel( )
	if ( soundLevel - 0.8 < 0 ) then
	    soundLevel = 100
	end
	if ( soundLevel > 0 ) then
		soundLevel = 100
	end
	if ( soundLevel > 10 ) then
		soundLevel = 100
	end
	guiProgressBarSetProgress( soundGui.progressbar[1], soundLevel*10 )
	guiSetText( soundGui.label[1], "SOUND: "..guiProgressBarGetProgress( soundGui.progressbar[1] ) )
	smoothFade = setTimer( smoothReduce, 100, 9 )
	setElementData( getLocalPlayer( ), 'soundLevelProgress', soundLevel )
end

function smoothReduce( )
	local newprobar = guiProgressBarGetProgress( soundGui.progressbar[1] )
	guiProgressBarSetProgress( soundGui.progressbar[1], newprobar - 1 )
end

addEventHandler( 'onClientPlayerSpawn', getLocalPlayer( ),
    function( )
	    isPlayerMoving = 1
		if smoothFade and isTimer( smoothFade ) then
		    killTimer( smoothFade )
		end
	    soundLevel = 100
	    guiProgressBarSetProgress( soundGui.progressbar[1], soundLevel*10 )
		if reduceSoundTimer and ( isTimer( reduceSoundTimer ) ) then
			killTimer( reduceSoundTimer )
			reduceSoundTimer = nil
		end
		reduceSoundTimer = setTimer( reduceSoundLevel, 1000, 0 )
	end
)

-- Responsável por criar uma caixa de diálogo entre o server e o jogador para informar algo sobre a partida (Desativado)

infoBox = { }

function createInfoBoxClient( x, y, text, time, textColour, boxColour, scale, font, border )
	if x and y then
		playSoundFrontEnd( 6 )
		if infoBox.timer and isTimer( infoBox.timer ) then
			killTimer( infoBox.timer )
		end
		infoBox = { }   
		if not text then text = "" end
		if not scale then scale = 2 end
		if not time then time = 3000 end
		if not font then font = "default-bold" end
		if not textColour then textColour = {r = 170, g = 168, b = 162, a = 230} end
		if not boxColour then boxColour = {r = 0, g = 0, b = 0, a = 180} end
		if not border then border = 5 end       
		text = text:gsub("  "," ")
		text = text:gsub(" ","  ")
		text = text:gsub("\\n","\n")
		text = text:gsub("\n","  ")
		text = text:gsub("\r","")
		infoBox.text = escape(text)
		if text:find('<p>',1,true) then
			local s,e = text:find('<p>',1,true)
			infoBox.pages = text:sub(e+1)
			infoBox.text = text:sub(1,s-1)
		end		
		infoBox.width = 250      
		local lines = {}   
		if type(x) == "string" then
			local calculation = tostring(string.gsub(x,"sx",tostring(sx)))
			_,x = pcall(loadstring("return "..calculation))
		end      
		if type(y) == "string" then
			local calculation = tostring(string.gsub(y,"sy",tostring(sy)))
			_,y = pcall(loadstring("return "..calculation))        
		end
		infoBox.border = border
		infoBox.height, lines = dxGetTextHeight(250,infoBox.text,scale,font,true)
		infoBox.x = x
		infoBox.y = y
		infoBox.textColour = textColour
		infoBox.boxColour = boxColour
		infoBox.scale = scale
		infoBox.font = font
		infoBox.time = time
		infoBox.text = ""
		for i,v in pairs(lines) do
			infoBox.text = infoBox.text .. v .. "\n"
		end    
		infoBox.timer = setTimer(
			function() 
				if infoBox.pages then
					createInfoBoxClient( infoBox.x, infoBox.y, infoBox.pages, infoBox.time, infoBox.textColour, infoBox.boxColour, infoBox.scale, infoBox.font, infoBox.border )
				else
					infoBox = {} 
				end
			end, 
		time, 1)
	end
end
addEvent( "createInfoBoxClient", true )
addEventHandler( "createInfoBoxClient", root, createInfoBoxClient )

addEvent( 'clientMsgBox', true )
addEventHandler( 'clientMsgBox', localPlayer,
    function( ... )
	    createInfoBoxClient(20,"(sy/3.5)*2",table.concat({...}," "),7000)	
	end
)

addEventHandler( "onClientRender", root, 
    function( )
		if infoBox.x then
			dxDrawRectangle(infoBox.x-infoBox.border,infoBox.y-infoBox.border,infoBox.width+(infoBox.border*2),infoBox.height+(infoBox.border*2),tocolor(infoBox.boxColour.r,infoBox.boxColour.g,infoBox.boxColour.b,infoBox.boxColour.a),true,false)
			dxDrawText(infoBox.text,infoBox.x,infoBox.y,infoBox.x+infoBox.width,infoBox.y+infoBox.height,tocolor(infoBox.textColour.r,infoBox.textColour.g,infoBox.textColour.b,infoBox.textColour.a),infoBox.scale,infoBox.font,"left","top",false,false,true)
		end
	end
)

function escape(text)
	text = text:gsub("%%","%%%%")
	return text
end

function dxGetTextHeight(width,text,scale,font,doubleSpaced)
	local textTable = split(text,string.byte(' '))
	local breaks = {}
	local length = 0
	local line = ""
	local space = doubleSpaced and '  ' or ' '
	for i = #textTable, 1, -1 do
		if textTable[i] == '' then table.remove(textTable,i) end
	end
	for i,word in pairs(textTable) do
		if i ~= #textTable then
			textTable[i] = word .. space
		end
	end
	for index,word in pairs(textTable) do
		if word ~= "." then
			local s,e = word:find(".",0,true)
			if s and e then
				textTable[index] = word:sub(0,s-1)
				table.insert(textTable,index+1,".")
				table.insert(textTable,index+2,word:sub(e+1))
			end
		end
	end	
	for index,word in pairs(textTable) do
		if word ~= "," then
			local s,e = word:find(",",0,true)
			if s and e then
				textTable[index] = word:sub(0,s-1)
				table.insert(textTable,index+1,",")
				table.insert(textTable,index+2,word:sub(e+1))
			end
		end
	end	
	
	for index,word in pairs(textTable) do
		if word ~= "-" then
			local s,e = word:find("-",0,true)
			if s and e then
				textTable[index] = word:sub(0,s-1)
				table.insert(textTable,index+1,"-")
				table.insert(textTable,index+2,word:sub(e+1))
			end
		end
	end
	for index,word in pairs(textTable) do
		if word ~= "|" then
			local s,e = word:find("|",0,true)
			if s and e then
				textTable[index] = word:sub(0,s-1)
				table.insert(textTable,index+1,"|")
				table.insert(textTable,index+2,word:sub(e+1))
			end
		end
	end	
	local index = 1
	while textTable[index] do
		local word = textTable[index]
		length = length + dxGetTextWidth(word,scale,font)
		if length > width then		
			if dxGetTextWidth(word,scale,font) > width then
				local currentLength = length - dxGetTextWidth(word,scale,font)
				local count = 0
				repeat
					count = count + 1
					length = currentLength + dxGetTextWidth(word:sub(0,-count),scale,font)
				until length < width
				local wordsection = word:sub(0,-count)
				textTable[index] = wordsection
				table.insert(textTable,index+1,word:sub(-count+1))
				table.insert(breaks,index)
				length = 0	
			else
				table.insert(breaks,index-1)
				length = dxGetTextWidth(word,scale,font)
			end
		end
		if index == #textTable then
			table.insert(breaks,index)
		end
		index = index + 1
	end
	local lines = {}
	for index,breakpoint in pairs(breaks) do
		lines[index] = ""
		for i = (index == 1 and 1 or breaks[index-1]+1), breakpoint do
			lines[index] = lines[index] .. textTable[i] --[[.. "@"]]
		end
		lines[index] = lines[index]:gsub("^[%s]*","")
	end
	local height = (dxGetFontHeight(scale,font) * #breaks) --[[+ (8 * #breaks-1)]]
	return height,lines
end

-- Envia a gadget que o player selecionou no guiWeaponsMenu

playerGadget = { }

addEvent( 'activeClientGadget', true )  -- Ativa o gadget
addEventHandler( 'activeClientGadget', localPlayer,
    function( selectedGadget )
	    playerGadget = { }
		playerGadget = { type = 'armor', ammo = getElementData( getLocalPlayer( ), selectedGadget ), state = true }
		triggerServerEvent( 'givePlayerArmor', resourceRoot )
	end
)

function resetPlayerGadget( ) -- Elimina o gadget ao fim da partida.
	local timers = getTimers( )
	if ( timers ) then
		for k, t in pairs( timers ) do
			if ( t ~= reduceSoundTimer ) then
		        killTimer( t )
			end
	    end
	end
    playerGadget.type = nil
	playerGadget.ammo = nil
	playerGadget = {}
	triggerServerEvent( 'resetClientGadget', resourceRoot )
end

addEventHandler( 'onClientPlayerSpawn', getLocalPlayer( ), -- Executa a função a cima quando o player spawna.
    function( )
	    resetPlayerGadget( )
	end
)

-- Insere a nametag do jogador ao entrar no servidor ou ao iniciar a resource do stealth

local nametags = { };
nametags.target = { };
nametags.alpha = { };

local function dxDrawBorderedText( text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, alpha )
    for oX = -1, 1 do
        for oY = -1, 1 do
            dxDrawText( text, left + oX, top + oY, right + oX, bottom + oY, tocolor( 50, 50, 50, alpha ), scale, font, alignX, alignY, clip, wordBreak,postGUI )
        end
    end
    dxDrawText( text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI )
end

addEventHandler( "onClientRender", root,
    function( )
        local intCamX, intCamY, intCamZ, intSourceX, intSourceY, intSourceZ, intTargetX, intTargetY, intTargetZ, intBoneX, intBoneY, intBoneZ, intDistance
        intCamX, intCamY, intCamZ = getCameraMatrix( );
		intSourceX, intSourceY, intSourceZ = getElementPosition( localPlayer );
		local playersTable = getElementsByType( "player", root, true )
		for i=1,#playersTable do
			local v = playersTable[i]
            intTargetX, intTargetY, intTargetZ = getElementPosition( v );
		    if v ~= localPlayer and not isPedDead( v ) and getElementAlpha( v ) == 255 and getElementData( v, 'soundLevelProgress' ) ~= 0 then
            intDistance = math.sqrt( ( intCamX - intTargetX ) ^ 2 + ( intCamY - intTargetY ) ^ 2 + ( intCamZ - intTargetZ ) ^ 2 )
				if intDistance < 50.0 or nametags.target[ v ] == true then
					if isLineOfSightClear( intCamX, intCamY, intCamZ, intTargetX, intTargetY, intTargetZ, true, false, false, true, false, false, false, localPlayer ) then
						intBoneX, intBoneY, intBoneZ = getPedBonePosition( v, 3 )
						local x,y = getScreenFromWorldPosition( intBoneX, intBoneY, intBoneZ )
						if x then
							if ( nametags.target[ v ] == false ) or ( nametags.target[ v ] == nil ) then
								nametags.alpha[ v ] = 170 - intDistance
							else
								nametags.alpha[ v ] = 200
							end
							local playerName = getPlayerName( v )
							local r,g,b = getPlayerNametagColor( v )
							dxDrawBorderedText( '● '..tostring( playerName ), x, y, x, y, tocolor( r, g, b, nametags.alpha[v]+50 ), 1, "clear", "center", "top", false, true, false, 	nametags.alpha[v]+50 )
							dxDrawRectangle( x - 30, y + 15, 60, 10, tocolor( 0, 0, 0, nametags.alpha[v] - 20 ) )
							local health = getElementHealth( v )
							local lineLength = 56 * ( health / 100 )
							dxDrawRectangle( x - 28, y + 17, lineLength, 6, tocolor( 200 - health * 2, health * 2, 0, nametags.alpha[v] ) )
							local armor = getPedArmor( v )
							if ( armor ) then
								local lineLength2 = 56 * ( armor / 100 )
								dxDrawRectangle( x - 28, y + 17, lineLength2, 6, tocolor( 180, 180, 180, nametags.alpha[v] ) )
							end
						end
					end
				end
            end
		end
    end
)

addEventHandler( 'onClientPlayerTarget', root,
    function( targetElement )
	    if ( targetElement ) then
	   	    local elementType = getElementType( targetElement )
			if ( elementType ) then
				if ( elementType == 'player' ) and ( targetElement ) then
				    nametags.target[ targetElement ] = true
					otherTarget = targetElement
				end
			end
			if ( otherTarget ) then
				if ( otherTarget ~= targetElement ) then
				    nametags.target[ otherTarget ] = false
				end
			end
		end
	end
)

addEventHandler( 'onClientPlayerSpawn', root,
    function( )
	    setPlayerNametagShowing( source, false )
	end
)

addEventHandler( 'onClientPlayerJoin', root,
    function( )
	    setPlayerNametagShowing( source, false )
	end
)

addEventHandler( 'onClientResourceStart', getResourceRootElement( getThisResource( ) ),
    function( )
	    local players = getElementsByType( "player" )
        for theKey,thePlayer in pairs( players ) do
		    setPlayerNametagShowing( thePlayer, false )
		end
	end
)

-- Atualiza a taxa de sound do soundLevel (Desativado)

playerBlips = { }

local refreshRate = getTickCount( ) - 2000
function updateSoundLevels( )
	if getTickCount( ) - refreshRate < 2000 then return end
	local playersTable = getElementsByType( "player" )
	for i=1,#playersTable do
		local thePlayer = playersTable[i]
	    if ( getElementData( thePlayer, 'State' ) == 'Alive' ) then
			local localTeam = getPlayerTeam( localPlayer )
			local playerTeam = getPlayerTeam( thePlayer )
			if ( localTeam ~= playerTeam ) then
			    local alpha = getElementData( thePlayer, 'soundLevelProgress' ) * 20
				if ( playerBlips[ thePlayer ] ) and ( alpha ) then
				   	local r, g, b, a = getBlipColor( playerBlips[ thePlayer ] )
					setBlipColor( playerBlips[ thePlayer ], r, g, b, alpha )
				end
			else
				local alpha = 200
				if ( playerBlips[ thePlayer ] ) and ( alpha ) then
				    local r, g, b, a = getBlipColor( playerBlips[ thePlayer ] )
					setBlipColor( playerBlips[ thePlayer ], r, g, b, alpha )
				end
			end
		end
	end
	if ( getElementData( localPlayer, 'State' ) == 'Alive' ) then
		local type = tostring( playerGadget.type )
		local ammo = tonumber( playerGadget.ammo )
	end
	local cameraEffect = getCameraGoggleEffect(  )
	if ( cameraEffect == 'thermalvision' ) then
		local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
			local thePlayer = playersTable[i]
		    local isPlayerCloacked = getElementData( thePlayer, 'cloakIsActive' )
			if ( isPlayerCloacked == 1 ) then
			    setElementAlpha( thePlayer, 255 )
			else
			    setElementAlpha( thePlayer, 255 )
			end
		end
	elseif ( cameraEffect == 'normal' ) then
		local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
			local thePlayer = playersTable[i]
		    local isPlayerCloacked = getElementData( thePlayer, 'cloakIsActive' )
			if ( isPlayerCloacked == 1 ) then
			    setElementAlpha( thePlayer, 25 )
			else
			    setElementAlpha( thePlayer, 255 )
			end
		end
	end
	refreshRate = getTickCount( )
end
addEventHandler( 'onClientRender', root, updateSoundLevels );

addEventHandler( 'onClientPlayerSpawn', root,
    function( )
	    local playerTeam = getPlayerTeam( source )
		if ( playerTeam ) then
	        local r, g, b = getTeamColor( playerTeam )
			if ( playerBlips[ source ] ) then
			    destroyElement( playerBlips[ source ] )
				playerBlips[ source ] = nil
			end
		    playerBlips[ source ] = createBlipAttachedTo( source, 0, 1.8, r, g, b, 200, 0, 99999.0 )
		end
	end
)

addEventHandler( 'onClientPlayerWasted', root,
    function( )
	    if ( playerBlips[ source ] ) then
		    destroyElement( playerBlips[ source ] )
			playerBlips[ source ] = nil
		end
	end
)

addEventHandler( 'onClientPlayerQuit', root,
    function( )
	    if ( playerBlips[ source ] ) then
		    destroyElement( playerBlips[ source ] )
			playerBlips[ source ] = nil
		end
	end
)
