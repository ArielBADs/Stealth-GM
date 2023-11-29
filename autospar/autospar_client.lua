tempoRestante = 0
checkUnpause = false

-- Função para desenhar texto
function desenharTextoNoMeioDaTela()
    -- Verifica se a mensagem deve ser exibida
    if mostrarMensagem then
        local screenW, screenH = guiGetScreenSize()

        -- Define o texto e a posição
        local text = "Pause"
        local posX = screenW / 2
        local posY = screenH / 3 -- Posiciona o texto um pouco mais acima

        -- Desenha o retângulo cobrindo a tela inteira
        dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, 200))

        -- Desenha o contorno do texto
        for oX = -1, 1 do
            for oY = -1, 1 do
                dxDrawText(text, posX + oX, posY + oY, posX + oX, posY + oY, tocolor(0, 0, 0, 255), 2.5, "default", "center", "center")
            end
        end

        -- Desenha o texto no meio da tela
        dxDrawText(text, posX, posY, posX, posY, tocolor(65, 105, 225, 255), 2.5, "default", "center", "center")

        -- Desenha o temporizador abaixo do texto "Pause"
        if tempoRestante > 0 then
            if checkUnpause == false then
                playSound("audio/unpause.mp3");
                checkUnpause = true
            end
            -- Desenha o contorno do temporizador
            for oX = -1, 1 do
                for oY = -1, 1 do
                    dxDrawText(tostring(tempoRestante), posX + oX, posY + 50 + oY, posX + oX, posY + 50 + oY, tocolor(0, 0, 0), 2.0, "default", "center", "center")
                end
            end

            -- Desenha o temporizador no meio da tela
            dxDrawText(tostring(tempoRestante), posX, posY + 50, posX, posY + 50, tocolor(255, 255, 255), 2.0, "default", "center", "center")
        end
    end
end

-- Função para lidar com o evento personalizado
function handleJogoPausado(mostrar)
    -- Inicia o temporizador quando a partida é retomada
    if not mostrar then
        tempoRestante = 3
        checkUnpause = false
        setTimer(function()
            tempoRestante = tempoRestante - 1
            if tempoRestante <= 0 then 
                tempoRestante = 0 
                mostrarMensagem = false 
            end
        end,
        1000,
        3)
    else 
      mostrarMensagem = true 
    end 
end

addEvent("JogoPausado", true)
addEventHandler("JogoPausado", root, handleJogoPausado)

-- Adiciona um manipulador de evento para desenhar o texto em cada frame
addEventHandler("onClientRender", root, desenharTextoNoMeioDaTela)
