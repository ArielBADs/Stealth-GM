list_spar1 = {}
list_spar2 = {}

all_connect = {}
all_jogadores = {}

count = 0
count2 = 0
count3 = 0

fun1 = 0
fun2 = 0

jogos = 0
timeRED = 0
timeBLUE = 0

checkSpar = false
checkPause = false
checkCreate = false
checkTimer = false

quantidade = 0

addEventHandler( 'onResourceStart', resourceRoot,
    function( )
        local playersTable = getElementsByType( "player" )
		for i=1,#playersTable do
            table.insert(all_connect, getPlayerName(playersTable[i]))
		end
    end
)

addEventHandler("onPlayerJoin", root,
    function()
        local name = getPlayerName(source)
        table.insert(all_connect, name)
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        local nome = getPlayerName(source)
        for i, player in ipairs(all_connect) do
            if player == nome then
                table.remove(all_connect, i)
                break
            end
        end
        if (checkSpar == false) then
            for i, player in ipairs(list_spar1) do
                if player == nome then
                    table.remove(list_spar1, i)
                    count = count - 1
                    outputChatBox(nome.." #FFFFFFsaiu e foi removido da 1º equipe - "..count.."/"..quantidade, root, 255, 0, 0, true)
                    break
                end
            end
            for i, player in ipairs(list_spar2) do
                if player == nome then
                    table.remove(list_spar2, i)
                    count2 = count2 - 1
                    outputChatBox(nome.." #FFFFFFsaiu e foi removido da 2º equipe - "..count2.."/"..quantidade, root, 255, 0, 0, true)
                    break
                end
            end
        end
    end
)

addEventHandler("onPlayerChangeNick", getRootElement(), 
    function(oldNick, newNick) 
        for i, v in ipairs(all_connect) do 
            if v == oldNick then 
                table.remove(all_connect, i) 
                table.insert(all_connect, newNick) 
                break
            end
        end
        for i, v in ipairs(list_spar1) do 
            if v == oldNick then
                table.remove(list_spar1, i) 
                table.insert(list_spar1, newNick) 
                break
            end
        end
        for i, v in ipairs(list_spar2) do 
            if v == oldNick then 
                table.remove(list_spar2, i) 
                table.insert(list_spar2, newNick) 
                break
            end
        end
        if lider1 == oldNick then 
            lider1 = newNick
        end
        if lider2 == oldNick then 
            lider2 = newNick
        end
    end
)

function criarSpar(player, cmd, num)

    local gamemode = getGameType()
    local partes = split(gamemode, " ")
    local modo = partes[1]

    num = tonumber(num)

    if modo ~= "Stealth:PRO" then
        outputChatBox("#A9A9A9Este script por enquanto só esta funcional para Stealth.", root, 255, 0, 0, true)
        return
    end

    if checkCreate == true then
        outputChatBox("#A9A9A9Uma partida já foi criada.", player, 255, 0, 0, true)
        return
    end
    if checkSpar == true then
        outputChatBox("#A9A9A9Um SPAR já esta acontecendo.", player, 255, 0, 0, true)
        return
    end
    if num and math.floor(num) == num then
        if (num < 1 or num > 5) then
            outputChatBox("#A9A9A9Insira um valor válido.", player, 255, 0, 0, true)
            return
        else
            quantidade = num
            outputChatBox("#FF0000"..getPlayerName(player).." #FFFFFFdefiniu uma quantidade de players por time para o SPAR: #FF0000"..quantidade, root, 255, 0, 0, true)
            checkCreate = true
            verificacao = setTimer(resetCreate, 1000, 0)
            return
        end
    else 
        outputChatBox("#A9A9A9Insira um valor válido.", player, 255, 0, 0, true)
        return
    end
end

addCommandHandler("criarspar", criarSpar)

addCommandHandler("rpt", 
    function(player, command, playerName)
        local isLeader1 = false
        local isLeader2 = false
        local nPlayer = getPlayerName(player)

        if nPlayer == lider1 then
            isLeader1 = true
        elseif nPlayer == lider2 then
            isLeader2 = true
        else
            outputChatBox("#A9A9A9Você não tem permissão para executar este comando.", player, 255, 0, 0, true)
            return
        end

        if isLeader1 == true and isLeader2 == false then
            local encontrado = false
            for i, p in ipairs(list_spar1) do
                if p == playerName and playerName ~= nPlayer then
                    table.remove(list_spar1, i)
                    encontrado = true
                end
            end
            if encontrado == false then
                outputChatBox("#A9A9A9O jogador #A9A9A9"..playerName.." não está na lista da equipe 1 ou é o líder.", player, 255, 0, 0, true)
                return
            end
            count = count - 1
            outputChatBox(playerName.." #FFFFFFFoi removido da 1º equipe pelo líder - "..count.."/"..quantidade, root, 255, 0, 0, true)
            return
        elseif isLeader1 == false and isLeader2 == true then
            local encontrado = false
            for i, p in ipairs(list_spar2) do
                if p == playerName and playerName ~= nPlayer then
                    table.remove(list_spar2, i)
                    encontrado = true
                end
            end
            if encontrado == false then
                outputChatBox("#A9A9A9O jogador #A9A9A9"..playerName.." não está na lista da equipe 2 ou é o líder.", player, 255, 0, 0, true)
                return
            end
            count2 = count2 - 1
            outputChatBox(playerName.." #FFFFFFFoi removido da 2º equipe pelo líder - "..count2.."/"..quantidade, root, 255, 0, 0, true)
            return
        end
    end
)



function resetCreate()
    if #all_connect == 0 then
        triggerEvent ( "reiniciarSpar", root)
    end
end

local ultimaExecucao = 0

addCommandHandler("resetCreate", 
        function (player)
            local agora = getTickCount()
            if checkSpar ~= true and not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
                local tempoPassado = agora - ultimaExecucao
                if tempoPassado < 180000 then
                    outputChatBox("#A9A9A9Este comando foi a executado a menos de 3 minutos.", player, 255, 0, 0, true)
                    return
                end
                triggerEvent ( "reiniciarSpar", root)
                outputChatBox("#FFFFFFO jogador #FF0000"..getPlayerName(player).." #FFFFFFusou o comando /resetCreate", root, 255, 0, 0, true)
                ultimaExecucao = agora
                return
            elseif isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
                if checkSpar == true then
                    killTimer(meuTimer)
                    triggerEvent ( "iniciarGame", root, "sth-fabric")
                end
                triggerEvent ( "reiniciarSpar", root)
                outputChatBox("#FFFFFFO administrador #FF0000"..getPlayerName(player).." #FFFFFFusou o comando /resetCreate", root, 255, 0, 0, true)
                return
            else
                outputChatBox("#A9A9A9Um SPAR esta acontecendo.", player, 255, 0, 0, true)
                return
            end
        end
)

function gerarSenha()
    local senha = ""
    for i = 1, 5 do
        senha = senha .. math.random(0, 9)
    end
    setServerPassword(senha)
    outputChatBox("#FFFFFFServidor trancado e senha gerada: #FF0000"..senha, root, 255, 0, 0, true)
end

function saida()
    if count3 == 0 then 
        outputChatBox(("#DCDCDCRemovendo players não registrados em [...]"), root, 255, 0, 0, true)
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 1 then
        outputChatBox(("#DCDCDC5"), root, 255, 0, 0, true)
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 2 then
        outputChatBox(("#DCDCDC4"), root, 255, 0, 0, true)
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 3 then
        outputChatBox(("#DCDCDC3"), root, 255, 0, 0, true)
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 4 then
        outputChatBox(("#DCDCDC2"), root, 255, 0, 0, true)
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 5 then
        outputChatBox(("#DCDCDC1..."), root, 255, 0, 0, true)
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 6 then
        triggerEvent ( "kickNotSpar", root)
        gerarSenha()
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 7 then
        outputChatBox(("#FFFFFF3 mapas, 10 pontos corridos. Bom SPAR a todos."), root, 255, 0, 0, true)
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 8 then
        triggerEvent ( "iniciarGame", root, "sth-fabric")
        count3 = count3 + 1
        setTimer(saida, 1000, 1)
    elseif count3 == 9 then
        triggerEvent ( "getTeam", root)
        count3 = count3 + 1
        if checkTimer == false then
            setTimer(saida, 10, 1 )
        end
        checkTimer = false
    elseif count3 == 10 then 
        meuTimer = setTimer(
            function()
                triggerEvent ( "getPlacar", root)
            end,
            1000,
            0 )
        count3 = 0 
     end 
end

function spar1(source)
    if checkCreate == false then
        outputChatBox("#FFFFFFQuantidade de players não foi definida, use: #FF0000/criarspar valor", source, 255, 0, 0, true)
        return
    end
    if checkSpar == true then
        outputChatBox("#A9A9A9Um SPAR já esta acontecendo.", source, 255, 0, 0, true)
        return
    end

    local NomePlayer = getPlayerName(source)

    if count == quantidade then
        outputChatBox("#FFFFFFO A 1º equipe esta completa #FF0000"..count.."/"..quantidade, source, 255, 0, 0, true)
        return
    else 
        if (#list_spar1 == 0 and #list_spar2 == 0) then
            lider1 = NomePlayer
            table.insert(list_spar1, NomePlayer)
            count = count + 1
            outputChatBox("#FFFFFFVocê foi registrado com sucesso!", source, 255, 0, 0, true)
            outputChatBox(NomePlayer.." #FFFFFFfoi registrado na 1º equipe! - "..count.."/"..quantidade, root, 255, 0, 0, true)
        else
            for i, v in ipairs(list_spar1) do
                if v == NomePlayer then
                    outputChatBox("Você já esta registrado na 1ª equipe!", source, 255, 0, 0, true)
                    return 
                end
            end
            for i, v in ipairs(list_spar2) do
                if v == NomePlayer then
                    outputChatBox("Você já esta registrado na 2ª equipe!", source, 255, 0, 0, true)
                    return
                end
            end
            if count == 0 then
                lider1 = NomePlayer
            end
            table.insert(list_spar1, NomePlayer)
            count = count + 1
            outputChatBox("#FFFFFFVocê foi registrado com sucesso!", source, 255, 0, 0, true)
            outputChatBox(NomePlayer.." #FFFFFFfoi registrado na 1º equipe! - "..count.."/"..quantidade, root, 255, 0, 0, true)
            if count == quantidade then
                outputChatBox("#A9A9A9A 1º equipe esta completa e pronta para o spar.", root, 255, 0, 0, true)
            end
        end
        if (count == quantidade and count2 == quantidade) then

            local gamemode = getGameType()
            local partes = split(gamemode, " ")
            local modo = partes[1]

            if modo ~= "Stealth:PRO" then
                outputChatBox("#A9A9A9Este script por enquanto só esta funcional para Stealth.", root, 255, 0, 0, true)
                return
            end

            killTimer(verificacao)
            checkSpar = true

            saida()
        end
        return
    end
end

addCommandHandler ("spar1", spar1)
  

function spar2(source)
    if checkCreate == false then
        outputChatBox("#FFFFFFQuantidade de players não foi definida, use: #FF0000/criarspar valor", source, 255, 0, 0, true)
        return
    end
    if checkSpar == true then
        outputChatBox("#A9A9A9Um SPAR já esta acontecendo.", source, 255, 0, 0, true)
        return
    end

    local NomePlayer = getPlayerName(source)

    if count2 == quantidade then
        outputChatBox("#FFFFFFA 2º equipe esta completa #FF0000"..count2.."/"..quantidade, source, 255, 0, 0, true)
        return
    else 
        if (#list_spar1 == 0 and #list_spar2 == 0) then
            lider2 = NomePlayer
            table.insert(list_spar2, NomePlayer)
            count2 = count2 + 1
            outputChatBox("#FFFFFFVocê foi registrado com sucesso!", source, 255, 0, 0, true)
            outputChatBox(NomePlayer.." #FFFFFFfoi registrado na 2º equipe! - "..count2.."/"..quantidade, root, 255, 0, 0, true)
        else
            for i, v in ipairs(list_spar1) do
                if v == NomePlayer then
                    outputChatBox("Você já esta registrado na 1ª equipe!", source, 255, 0, 0, true)
                    return
                end
            end
            for i, v in ipairs(list_spar2) do
                if v == NomePlayer then
                    outputChatBox("Você já esta registrado na 2ª equipe!", source, 255, 0, 0, true)
                    return
                end
            end
            if count2 == 0 then
                lider2 = NomePlayer
            end
            table.insert(list_spar2, NomePlayer)
            count2 = count2 + 1
            outputChatBox("#FFFFFFVocê foi registrado com sucesso!", source, 255, 0, 0, true)
            outputChatBox(NomePlayer.." #FFFFFFfoi registrado na 2º equipe! - "..count2.."/"..quantidade, root, 255, 0, 0, true)
            if count2 == quantidade then
                outputChatBox("#A9A9A9A 2º equipe esta completa e pronta para o spar.", root, 255, 0, 0, true)
            end
        end
        if (count == quantidade and count2 == quantidade) then

            local gamemode = getGameType()
            local partes = split(gamemode, " ")
            local modo = partes[1]

            if modo ~= "Stealth:PRO" then
                outputChatBox("#A9A9A9Este script por enquanto só esta funcional para Stealth.", root, 255, 0, 0, true)
                return
            end

            killTimer(verificacao)

            checkSpar = true

            saida()
        end
        return
    end
end

addCommandHandler ("spar2", spar2)

addEvent ( "kickNotSpar", true )

function valorNaLista(lista, valor)
    for i, v in ipairs(lista) do
        if v == valor then
            return true
        end
    end
    return false
end

function kickarJogadores()
    local jogadoresParaKickar = {}
    for i, v in ipairs(list_spar1) do
        table.insert(all_jogadores, v)
    end
    for i, v in ipairs(list_spar2) do
        table.insert(all_jogadores, v)
    end
    for i , v in ipairs(all_connect) do
        if (not valorNaLista(all_jogadores, v)) then
            table.insert(jogadoresParaKickar, v)
        end
    end
    for i , v in ipairs(jogadoresParaKickar) do
        kickPlayer(getPlayerFromName(v), "Spar iniciando: Não registrado")
    end
end


addEventHandler ( "kickNotSpar", root, kickarJogadores )

addEvent ( "iniciarGame", true )

function goSpar(entrada)
    local gamemode = getGameType()
    local partes = split(gamemode, " ")
    local modo = partes[1]

    if (modo == "Stealth:PRO") then
        local mapa = getResourceFromName(entrada)
        exports.mapmanager:changeGamemodeMap(mapa)
    end
end

addEventHandler ( "iniciarGame", root, goSpar )

addEvent("getTeam", true)
addEventHandler( 'getTeam', resourceRoot,
    function()
        team1 = exports.stealth:returnTeam1()
        team2 = exports.stealth:returnTeam2()
        exports.stealth:hideTab()
		for i, m1 in ipairs(list_spar1) do
			local player = getPlayerFromName(m1)
			setPlayerTeam(player, team1)
		end
		for i, m2 in ipairs(list_spar2) do
			local player = getPlayerFromName(m2)
			setPlayerTeam(player, team2)
		end
    end
)

addEvent("getPlacar", true)
addEventHandler( 'getPlacar', resourceRoot,
    function()
		local score1 = exports.stealth:returnScore1()
		local score2 = exports.stealth:returnScore2()
		if score1 == 10 then
			timeRED = timeRED + 1
			outputChatBox("#FFFFFFO time #FF0000RED #FFFFFF venceu: "..score1.."-"..score2, root, 255, 0, 0, true)
			if jogos == 0 then
				jogos = jogos + 1
                triggerEvent ( "iniciarGame", root, "sth-burrito")
                count3 = 9
                checkTimer = true
                setTimer(saida, 100, 1)
			elseif (jogos == 1 and timeRED == 1) then
                triggerEvent ( "iniciarGame", root, "sth-motor")
                count3 = 9
                checkTimer = true
                setTimer(saida, 100, 1)
			else
				outputChatBox("#FFFFFFO time #FF0000RED #FFFFFFvenceu o spar por: "..timeRED.."-"..timeBLUE, root, 255, 0, 0, true)
                triggerEvent ( "reiniciarSpar", root)
                killTimer(meuTimer)
				triggerEvent ( "iniciarGame", root, "sth-fabric")
			end
		elseif score2 == 10 then
			timeBLUE = timeBLUE + 1
			outputChatBox("#FFFFFFO time #0000FFBLUE #FFFFFFvenceu: "..score2.."-"..score1, root, 255, 0, 0, true)
			if jogos == 0 then
				jogos = jogos + 1
				triggerEvent ( "iniciarGame", root, "sth-burrito")
                count3 = 9
                checkTimer = true
                setTimer(saida, 100, 1)
			elseif (jogos == 1 and timeBLUE == 1) then
				triggerEvent ( "iniciarGame", root, "sth-motor")
                count3 = 9
                checkTimer = true
                setTimer(saida, 100, 1)
			else
				outputChatBox("#FFFFFFO time #0000FFBLUE #FFFFFFvenceu o spar por: "..timeBLUE.."-"..timeRED, root, 255, 0, 0, true)
                triggerEvent ( "reiniciarSpar", root)
                killTimer(meuTimer)
				triggerEvent ( "iniciarGame", root, "sth-fabric")
			end
		end
        if #all_connect == 0 then
            triggerEvent ( "reiniciarSpar", root)
            killTimer(meuTimer)
			triggerEvent ( "iniciarGame", root, "sth-fabric")
        end
	end
)

addCommandHandler("pause", 
    function (player)
        local gamemode = getGameType()
        local partes = split(gamemode, " ")
        local modo = partes[1]

        if modo ~= "Stealth:PRO" then
            return
        end

        local checkList = false
        local checkLive = false
        if checkSpar == true then
            for i, v in ipairs(all_jogadores) do
                if v == getPlayerName(player) then
                    checkList = true
                    if isPedDead(player) == false then
                        checkLive = true
                    end
                end
            end
        end

        if checkSpar == true or isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
            if checkList == true or isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
                if checkLive == true or isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
                    if checkPause == false then
                        pausado = setTimer(
                                        function()
                                            if #all_connect == 0 then
                                                exports.stealth:returnTimer()
                                                checkPause = false
                                                killTimer(pausado)
                                            else
                                                exports.stealth:stopTimer()
                                            end
                                        end,
                                        5,
                                        0)
                        setGameSpeed(0)
                        for i, name in ipairs(all_connect) do
                            setElementFrozen(getPlayerFromName(name), true)
                        end
                        triggerClientEvent(root, "JogoPausado", root, true)
                        outputChatBox("#FFFFFFO jogador #FF0000"..getPlayerName(player).." #FFFFFFpausou a partida.", root, 255, 0, 0,true)
                        checkPause = true
                        
                        return
                        
                    else
                        triggerClientEvent(root,"JogoPausado",root,false)
                        outputChatBox("#FFFFFFO jogador #FF0000"..getPlayerName(player).." #FFFFFFretomou a partida.", root, 255, 0, 0, true)
                        setTimer(function()
                            killTimer(pausado)
                            for i, name in ipairs(all_connect) do
                                setElementFrozen(getPlayerFromName(name), false)
                            end
                            setGameSpeed(1)
                            exports.stealth:returnTimer()
                            checkPause = false
                        end,
                        3000,
                        1)
                        
                        return

                    end
                else
                    outputChatBox("#A9A9A9Este comando não pode ser executado no momento.", player, 255, 0, 0, true)
                    return
                end
            else
                outputChatBox("#A9A9A9Acessível apenas para quem esta jogando.", player, 255, 0, 0, true)
                return
            end
        end
        outputChatBox("#A9A9A9Este comando só pode ser usado em SPAR.", player, 255, 0, 0, true)
        return
    end
)

addCommandHandler("add", 
function(player, command, playerName)

    local inServer = false

    for i, v in ipairs(all_connect) do
        if v == playerName then
            inServer = true
        end
    end

    if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
        if inServer == true then
            local targetPlayer = getPlayerFromName (playerName)
            local team = getPlayerTeam (targetPlayer)
            if exports.stealth:addPlayer(targetPlayer, team, false) == false then
                outputChatBox("#A9A9A9Este jogador já esta vivo.", player, 255, 0, 0, true)
                return
            end
            outputChatBox("#F0F0F0"..playerName.." foi #FF0000adicionado #F0F0F0por "..getPlayerName(player), root, 255, 0, 0, true)            return
        else
            outputChatBox("#A9A9A9O Jogador não foi encontrado.", player, 255, 0, 0, true)
            return
        end
    else
        outputChatBox("#A9A9A9Você não tem permissão para usar este comando.", player, 255, 0, 0, true)
        return
    end
end
)

addCommandHandler("rmv", 
function(player, command, playerName)

    local inServer = false

    for i, v in ipairs(all_connect) do
        if v == playerName then
            inServer = true
        end
    end

    if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
        if inServer == true then
            local targetPlayer = getPlayerFromName (playerName)
            local team = getPlayerTeam (targetPlayer)
            if exports.stealth:addPlayer(targetPlayer, team, true) == false then
                killPlayer(targetPlayer, targetPlayer)
                outputChatBox("#F0F0F0"..playerName.." foi #FF0000removido #F0F0F0por "..getPlayerName(player), root, 255, 0, 0, true)
                return
            end
            outputChatBox("#A9A9A9Este jogador já esta morto.", player, 255, 0, 0, true)
            return
        else
            outputChatBox("#A9A9A9O Jogador não foi encontrado.", player, 255, 0, 0, true)
            return
        end
    else
        outputChatBox("#A9A9A9Você não tem permissão para usar este comando.", player, 255, 0, 0, true)
        return
    end
end
)

addEvent( "reiniciarSpar", true)

function resetVariaveis()

    killTimer(verificacao)

    setServerPassword(nil)

    checkCreate = false
    checkSpar = false
    
    count = 0
    count2 = 0
    count3 = 0

    jogos = 0
    timeRED = 0
    timeBLUE = 0

    for i = 1, #list_spar1 do
        local item = table.remove(_G["list_spar1"])
    end
    for i = 1, #list_spar2 do
        local item2 = table.remove(_G["list_spar2"])
    end
    for i = 1, #all_jogadores do
        local item3 = table.remove(_G["all_jogadores"])
    end

    outputChatBox("#A9A9A9Auto-SPAR resetado e times desfeitos.", root, 255, 0, 0, true)
end

addEventHandler( "reiniciarSpar", root, resetVariaveis)