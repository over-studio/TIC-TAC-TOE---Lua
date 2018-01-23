game = {}
game.cases = {}
game.J = 1  -- joueur courant : 1 pour joueur 1  |  2 pour joueur 2
game.over = false
game.font = require("font")

local X, Y
local delay = 0
local c = {}

game.Load = function()
    love.graphics.setBackgroundColor(20, 20, 20)
    -- on définie les fontes à utiliser
    game.mainFont = game.font.Load("fonts/StrangeShadow.ttf", 50)
    game.caseFont = game.font.Load("fonts/StrangeShadow.ttf", 80)
    game.textFont = game.font.Load("fonts/Aileron-Regular.otf", 20)
    -- remplir le tableau "cases" par des 0 (pour marquer que la case est vide)
    for i=1, NB_CASES do
        game.cases[i] = {}
        c[i] = {}
        for j=1, NB_CASES do
            game.cases[i][j] = 0
            c[i][j] = 0
        end
    end
end

game.Update = function(dt)
    local r
    if game.J == 2 and delay <= 1 then
        delay = delay + dt

        if delay >= 1 then
            --print("J2 joue")
            r = game.findCaseGagnante()
            if r ~= false and r.x ~= nil and r.y ~= nil then
                --print(r.x, r.y)
                game.cases[r.x][r.y] = game.J 
            else
                -- si ni J1 peut gagner, ni J2 peut gagner, on choisie une case aléatoire
                local vide = {}
                for i=1, NB_CASES do
                    for j=1, NB_CASES do
                        if game.cases[i][j] == 0 then
                            table.insert(vide, {x=i, y=j})
                        end
                    end
                end
                local id = math.random(1, #vide)
                game.cases[vide[id].x][vide[id].y] = game.J
            end
            -- tester si le joueur courant a gagné
            game.over = game.checkGagne()
        end
    end
end

game.Draw = function()
    for i=1, NB_CASES do
        for j=1, NB_CASES do
            love.graphics.setColor(100, 100, 100)
            love.graphics.rectangle("fill", 
                                    (i-1) * SIZE_CASE + 2, 
                                    (j-1) * SIZE_CASE + 2,
                                    SIZE_CASE - 2,
                                    SIZE_CASE - 2)
        end
    end

    for i=1, NB_CASES do
        for j=1, NB_CASES do
            if game.cases[i][j] == 1 then
                love.graphics.setColor(0, 0, 0)
                love.graphics.setFont(game.caseFont)
                love.graphics.print("X", 
                                    (i-1) * SIZE_CASE + 55, 
                                    (j-1) * SIZE_CASE + 35)
                --[[
                love.graphics.circle("line", 
                                        (i-0.5) * SIZE_CASE, 
                                        (j-0.5) * SIZE_CASE,
                                        SIZE_CASE / 3)
                --]]
            end
            if game.cases[i][j] == 2 then
                love.graphics.setColor(255, 255, 0)
                love.graphics.setFont(game.caseFont)
                love.graphics.print("0", 
                                    (i-1) * SIZE_CASE + 55, 
                                    (j-1) * SIZE_CASE + 35)
                --[[
                love.graphics.circle("line", 
                                        (i-0.5) * SIZE_CASE, 
                                        (j-0.5) * SIZE_CASE,
                                        SIZE_CASE / 3)
                --]]
            end
        end
    end

    if game.over then
        love.graphics.setColor(0, 0, 0, 200)
        love.graphics.rectangle("fill", 0, 0, 600, 600)
        love.graphics.setFont(game.mainFont)
        love.graphics.setColor(255, 255, 255)
        
        if game.over == "pn" then
            love.graphics.printf("Partie nulle", 0, 230, 600, "center")
            love.graphics.setFont(game.textFont)
            love.graphics.printf("Appuyer sur 'SPACE' pour recommencer", 0, 350, 600, "center")
        else
            love.graphics.printf("Joueur " .. game.J .. " gagne", 0, 180, 600, "center")
            love.graphics.setFont(game.textFont)
            love.graphics.printf("Appuyer sur 'SPACE' pour recommencer", 0, 380, 600, "center")
        end
    end

    -- Debug
    --[[
    for i=1, NB_CASES do
        for j=1, NB_CASES do
            love.graphics.setColor(0, 255, 0, 255)
            love.graphics.print(tostring(game.cases[i][j]), 
                                    (i-1) * SIZE_CASE + 10, 
                                    (j-1) * SIZE_CASE + 10)
            
            love.graphics.setColor(255, 0, 0, 255)
            love.graphics.print(tostring(c[i][j]), 
                                        (i-1) * SIZE_CASE + 30, 
                                        (j-1) * SIZE_CASE + 10)
        end
    end
    --]]
end

game.mousePressed = function()
    if not game.over and game.J == 1 then
        X = math.floor(love.mouse.getX() / SIZE_CASE) + 1
        Y = math.floor(love.mouse.getY() / SIZE_CASE) + 1

        if game.cases[X][Y] == 0 then
            -- affecter la case cliqué au joueur courant
            game.cases[X][Y] = game.J
            -- tester si le joueur courant a gagné
            game.over = game.checkGagne()
        end
    end
end

game.keyPressed = function(key)
    if key == "space" and game.over then
        game.over = false
        game.J = 1
        for i=1, NB_CASES do
            for j=1, NB_CASES do
                game.cases[i][j] = 0
                c[i][j] = 0
            end
        end
    end
end

game.checkGagne = function()
    local i, j

    if game.checkCases(game.cases, game.J) then return true end

    -- tester si la partie est nulle
    local counter = 0
    for i=1, NB_CASES do
        for j=1, NB_CASES do
            if game.cases[i][j] ~= 0 then
                counter = counter + 1
            end
        end
    end
    if counter == NB_CASES * NB_CASES and game.over == false then
        return "pn"
    end

    -- passer la main à l'autre joueur pour jouer
    if game.J == 1 then
        game.J = 2
        delay = 0
    elseif game.J == 2 then
        game.J = 1
    end

    -- on retourne FALSE et on continue le jeu
    return false
end

game.checkCases = function(tab, numJoueur)
    local i, j
    local counter = 0

    for i=1, NB_CASES do
        -- Pour chaque colonne, on vérifie si ses éléments sont égaux à "game.J"
        counter = 0
        for j=1, NB_CASES do
            if tab[i][j] == numJoueur then
                counter = counter + 1
            end
        end
        if counter == NB_CASES then
            --print("Joueur " .. numJoueur .. " gagne | colonne " .. i)
            return "c"
        end


        -- Pour chaque ligne, on vérifie si ses éléments sont égaux à "numJoueur"
        counter = 0
        for j=1, NB_CASES do
            if tab[j][i] == numJoueur then
                counter = counter + 1
            end
        end
        if counter == NB_CASES then
            --print("Joueur " .. numJoueur .. " gagne | ligne " .. i)
            return "l"
        end


        -- Pour chaque diagonale, on vérifie si ses éléments sont égaux à "numJoueur"
        -- diagonale 1
        if tab[1][1] == numJoueur and tab[2][2] == numJoueur and tab[3][3] == numJoueur then
            --print("Joueur " .. numJoueur .. " gagne | D1")
            return "d1"
        end
        -- diagonale 2
        if tab[1][3] == numJoueur and tab[2][2] == numJoueur and tab[3][1] == numJoueur then
            --print("Joueur " .. numJoueur .. " gagne | D2")
            return "d2"
        end
    end

    return false
end

game.findCaseGagnante = function()
    local i, j

    for i=1, NB_CASES do
        for j=1, NB_CASES do
            c[i][j] = game.cases[i][j]
        end
    end

    for i=1, NB_CASES do
        for j=1, NB_CASES do
            if c[i][j] == 0 then
                -- on affecte la case courante au joueur 2
                c[i][j] = 2
                -- on teste s'il peut gagner sur une colonne
                if game.checkCases(c, 2) == "c" then 
                    return {x=i, y=j}
                -- on teste s'il peut gagner sur une ligne
                elseif game.checkCases(c, 2) == "l" then
                    return {x=i, y=j}
                -- on teste s'il peut gagner sur une diagonale
                elseif game.checkCases(c, 2) == "d1" or game.checkCases(c, 2) == "d2" then
                    return {x=i, y=j}
                else
                    c[i][j] = 0
                end 
            end
        end
    end

    -- on teste si le joueur 1 peut gagner
    for i=1, NB_CASES do
        for j=1, NB_CASES do
            if c[i][j] == 0 then
                -- on affecte la case courante au joueur 1
                c[i][j] = 1
                -- on teste s'il peut gagner sur une colonne
                if game.checkCases(c, 1) == "c" then 
                    return {x=i, y=j}
                -- on teste s'il peut gagner sur une ligne
                elseif game.checkCases(c, 1) == "l" then
                    return {x=i, y=j}
                -- on teste s'il peut gagner sur une diagonale
                elseif game.checkCases(c, 1) == "d1" or game.checkCases(c, 1) == "d2" then
                    return {x=i, y=j}
                else
                    c[i][j] = 0
                end 
            end
        end
    end

    return false
end

return game