--[[
	Credits to Colton Ogden from HarvardX CS50 and Aditya Khanna

	Originally programmed by Atari in 1972. Features 2 paddles controlled by players,
	with the goal of getting  the ball pass through the opponents edge. First to 10
	points wins.

	This version is built to more closely resemble the NES than the original Pong
	machines or the Atari 2600 in terms of resolution, though in widescreen (16:9)
	so it looks nicer on modern systems.
]]

-- Constants
WINDOW_WIDTH = 1280	--X
WINDOW_HEIGHT = 720	--Y

-- Still modern in appearance but still has that retro look on ti
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class' -- https://github.com/vrld/hump/blob/master/class.lua
push = require 'push'	-- https://github.com/Ulydev/push

-- Global variable
require 'Ball'
require 'Paddle'

function love.load()

	-- Random number generator
	math.randomseed(os.time())	-- Unix epoch time

	love.window.setTitle('Pong')	-- Sets the title of the app
	
	love.graphics.setDefaultFilter('nearest', 'nearest')    -- Perfect pixels upscalling and downscalling, simulating a retro feel

	--[[
		Loads a font file into the memory, setting it to a specific size,
		and store it to an object we can use globally
	]]
	smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

	--[[
		Adding audio
		Type:
			Static:	preserved in memory
			Stream: from disk if needed
	]]
	sounds = {
		['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
		['point_score'] = love.audio.newSource('point_score.wav', 'static'),	
		['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
		['select'] = love.audio.newSource('select.wav', 'static'),
		['error'] = love.audio.newSource('error.wav', 'static'),
		['bgm'] = love.audio.newSource('bgm.mp3', 'stream')
	}

	player1Score = 0
	player2Score = 0

	servingPlayer = math.random(2) == 1 and 1 or 2

	winningPlayer = 0	

	paddle1 = Paddle(5, 20, 5, 20)
	paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)
	
	--[[
		Runs when the game first starts up
		Initialize the  game
	]]
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, 
	{
		fullscreen = false,
		vsync = true,
		resizable = true
	})

	--[[
		Game modes:
		1. PVP
		2. Player vs AI	-- PVC
		3. AI vs AI	-- CVC
	]]
	gameMode = ''

	-- Difficulties, sides and controls
	difficulty = ''	-- easy, difficult, imposible (to win)
	side = ''	-- Choose which side (left or right)
	controls = ''	-- 'ws' and arrow up and down

	--[[
		1. 'start' is the beginning of the game before the serve
		2. 'serve' waiting for a key to be pressed (to serve the ball)
		3. 'play' when the ball is on move
		4. 'done' someone has won 
		5. 'menu_mode' before the game starts choose mode
		6. 'menu_diff' chooseing the difficulty of a player's choice
		7. 'menu_side' select which side to play if the paired with AI
		8. 'menu_ctr1' select controls if played with AI
		9. 'pause' pause the 
	]]
	gameState = 'menu_mode'
end

function love.resize( w, h )	-- Dynamically rescale the internal canvas to fit our new window dimension
	push:resize(w,h)
end

function love.update(dt)	-- dt or delta time allows to move things independently
	if (gameState ~= 'menu_mode' and gameState ~= 'menu_diff' and gameState ~= 'menu_side' and gameState ~= 'menu_ctrl') == false then
        sounds['bgm']:setLooping(true)
        sounds['bgm']:play()
    end

    if (gameState ~= 'menu_mode' and gameState ~= 'menu_diff' and gameState ~= 'menu_side' and gameState ~= 'menu_ctrl') == true then
        sounds['bgm']:setLooping(true)
        love.audio.stop(sounds['bgm'])
    end

	if gameState == 'serve' then

		-- Initialize ball's velocity basend on the player who last scored
		if gameMode == 'pvp' then	-- pvp rules
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
                ball.dy = math.random(-50, 50)
             elseif servingPlayer == 2 then  -- changes
                ball.dx = -math.random(140, 200)
                ball.dy = math.random(-50, 50)
            end 
        end 
		
		if gameMode == 'cvc' then	-- cvc rules
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
                ball.dy = math.random(-50, 50)
                gameState = 'play'
             elseif servingPlayer == 2 then  -- changes
                ball.dx = -math.random(140, 200)
                ball.dy = math.random(-50, 50)
                gameState = 'play'
            end 
        end 

		if servingPlayer == 1 and side == 'left' and gameMode == 'pvc' then
            ball.dx = math.random(140, 200)
            ball.dy = math.random(-50, 50)
         elseif servingPlayer == 2 and side == 'left' and gameMode == 'pvc' then  --changes
            ball.dx = -math.random(140, 200)
            ball.dy = math.random(-50, 50)
            gameState = 'play'
         elseif servingPlayer == 1 and side == 'right' and gameMode == 'pvc'  then
			ball.dx = math.random(140, 200)
			ball.dy = math.random(-50, 50)
		    gameState = 'play'
         elseif servingPlayer == 2 and side == 'right' and gameMode == 'pvc' then  --changes
		    ball.dx = -math.random(140, 200)
	        ball.dy = math.random(-50, 50)
        end

	elseif gameState == 'play' then

        --[[
            Detect ball collision with paddles, reverse dx if true
            Slightly increse the dx 
            Alter the dy based on the position at which it collided
            Play Sound effects
        ]]
        if ball:collides(paddle1) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

		if ball:collides(paddle2) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end 

            sounds['paddle_hit']:play()
        end

        --[[
            Detect upper and lower screen boundary collision
            Playing a sound effect 
            Reverse dy if true
        ]]
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

		--[[
            If ball pass through the left edge of the screen, go back to serve
            Update the score
            Change serving player
        ]] 
        
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['point_score']:play()

            --[[
               if score is equal 10, the game is over
               Set the gameState to done 
               Show victory message
            ]]
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()    -- Places the ball in the middle of the screen, no velocity
            end
        end

        --[[
            If ball pass through the right edge of the screen, go back to serve
            Update the score 
            Change serving player
        ]]
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['point_score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

	 --[[
          Player 1
          Player vs Player
     ]]               
    if gameMode == 'pvp' then
        if love.keyboard.isDown('w') then
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end
     

     -- Player 2
     if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
     elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
     else
        paddle2.dy = 0
     end
    end
    
    -- Player vs Computer
    if gameMode == 'pvc' then   -- boing
        up_button = 'w' -- error
        down_button = 's'
     if controls == 'ws' then   -- set controls
        up_button = 'w'
        down_button = 's'
     elseif controls == 'ud' then
        up_button = 'up'
        down_button = 'down'
     end

     check_width = 0
     if difficulty == 'easy' then
        check_width = VIRTUAL_WIDTH/4
     elseif difficulty == 'hard' then
        check_width = VIRTUAL_WIDTH/2
     elseif difficulty == 'imp' then
        check_width = VIRTUAL_WIDTH
     end

     --[[
          Because error  
          Side
     ]]
     plr = paddle1  
     plr_n = paddle2
     if side == 'left' then
         plr = paddle1
        plr_n = paddle2
     elseif side == 'right' then
         plr = paddle2 
         plr_n = paddle1
     end

     if ((ball.x - plr_n.x)^2)^(0.5)  < check_width then 
        if (plr_n.y > (ball.y + ball.height/2))  then   -- computer
            plr_n.dy = -PADDLE_SPEED
         elseif (plr_n.y + plr_n.height < (ball.y + ball.height/2))  then
            plr_n.dy = PADDLE_SPEED
         else
            plr_n.dy = 0
        end
     end

     if love.keyboard.isDown(up_button) then    -- player
        plr.dy = -PADDLE_SPEED
      elseif love.keyboard.isDown(down_button) then
        plr.dy = PADDLE_SPEED
       else
        plr.dy = 0
      end
   
    end

    if gameMode == 'cvc' then

    --[[
        Player 1
        Make this AI controlled
        Controng -- Boing
    ]] 
     if ball.x < VIRTUAL_WIDTH/3 then 
       if (paddle1.y > (ball.y + ball.height/2))  then
          paddle1.dy = -PADDLE_SPEED
       elseif (paddle1.y + paddle1.height < (ball.y + ball.height/2))  then
          paddle1.dy = PADDLE_SPEED
       else
          paddle1.dy = 0
       end
     end
  
     -- player 2
         if ball.x > 2 * VIRTUAL_WIDTH/3 then
           if (paddle2.y > (ball.y + ball.height/2))  then
             paddle2.dy = -PADDLE_SPEED
           elseif (paddle2.y + paddle2.height < (ball.y + ball.height/2))  then
             paddle2.dy = PADDLE_SPEED
           else
            paddle2.dy = 0
           end
         end
     end

    --[[
        Update our ball based on its DX and DY only if we're in play state
        Scale the velocity by dt so movement is framerate-independent
    ]]
    if gameState == 'play' then
        ball:update(dt)
    end

	paddle1:update(dt)
	paddle2:update(dt)
end

-- Executes whenever a key is pressed
function love.keypressed(key)

	-- Keys accessed by string name
	if key == 'escape' then
        if gameState ~= 'menu_mode' then
            gameState = 'menu_mode'
            ball:reset()
            player1Score = 0
            player2Score = 0
            paddle1:reset1()
            paddle2:reset2()
        else
            love.event.quit()   -- Terminates the application
        end
    elseif key == 'enter' or key == 'return' then   -- Transition to next state if enter or return is pressed during start or serve state
         if  (gameMode == 'cvc') or (gameMode == 'pvp') or (gameMode == 'pvc' and ((side == 'left' and servingPlayer == 1) or (side == 'right' and servingPlayer == 2))) then
            if gameState == 'start' then
              gameState = 'serve'
            elseif gameState == 'serve' then
              gameState = 'play'
            elseif gameState == 'done' then

                --[[
                    Game is simply in a restart phase here, but will set the serving
                    Player to the opponent of whomever won for fairness!
                ]]
                gameState = 'serve'
                ball:reset()

                -- Reset scores 
                player1Score = 0
                player2Score = 0

                -- Decide serving Player
                if winningPlayer == 1 then
                    servingPlayer = 2
                else
                    servingPlayer = 1
                end
            end
    elseif  (gameMode == 'pvc') and ((side == 'left' and servingPlayer == 2) or (side == 'right' and servingPlayer == 1)) then
        if gameState == 'start' then
            gameState = 'serve'
        end
    end
end

    -- the menu where one can choose to play standard PvP, against AI or watch
    if gameState == 'menu_mode' then
        if key == '1'  then
            gameMode = 'pvp'
            gameState = 'start'
            sounds['select']:play()
        elseif key == '2' then
            gameMode = 'pvc'
            gameState = 'menu_diff'
            sounds['select']:play()
        elseif key == '3' then
            gameMode = 'cvc'
            gameState = 'start'
            sounds['select']:play()
        else 
            sounds['error']:play()
        end

    -- choose difficulty of AI opponent
    elseif gameState == 'menu_diff' then 
        
        -- the gamestate is mentioned twice to avoid mispresses
        if key == '1'  then
            difficulty = 'easy'
            gameState = 'menu_side'
            sounds['select']:play()
        elseif key == '2' then
            difficulty = 'hard'
            gameState = 'menu_side'
            sounds['select']:play()
        elseif key == '3' then
            difficulty = 'imp'
            gameState = 'menu_side'
            sounds['select']:play()
        else 
            sounds['error']:play()
        end

        -- to choose which side your player is on
    elseif gameState == 'menu_side' then
        if key == '1' then
            side = 'left'
            gameState = 'menu_ctrl'
            sounds['select']:play()
        elseif key == '2' then
            side = 'right'
            gameState = 'menu_ctrl'
            sounds['select']:play()
        else 
            sounds['error']:play()
        end

    -- to choose controls
    elseif gameState == 'menu_ctrl' then
    
        if key == '1' then 
            controls = 'ws'
            gameState = 'start'
            sounds['select']:play()
        elseif key == '2' then
            controls = 'ud'
            gameState = 'start'
            sounds['select']:play()
        else 
            sounds['error']:play()
        end        
    end
end

-- Called update by LOVE, used to draw anything on the screen, updated or otherwise
function love.draw()
	
	-- Begin rendering at virtual resolution
	push:apply('start')

	-- Sets the background color
	love.graphics.clear(38/255, 70/255, 83/255, 1)

	--[[
		Draws a rectangle choosing whatever the active color is
		Color can be set by love.graphics.setColor()
		Fill is a filled shape
		Line is a hollow shapa
	]]
	love.graphics.setColor(248/255, 249/255, 250/255, 1)
	
    -- render different things depending on which part of the game we're in
    if gameState == 'start' then
        
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
     elseif gameState == 'serve' then
        
        -- UI messages
        if gameMode == 'pvp' then
             love.graphics.setFont(smallFont)
             love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
             love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
         elseif gameMode == 'pvc' then
            if (side == 'left' and servingPlayer == 1) or (side == 'right' and servingPlayer == 2) then
                love.graphics.setFont(smallFont)
                love.graphics.printf("Player's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
             elseif (side == 'left' and servingPlayer == 2) or (side == 'right' and servingPlayer == 1) then
                love.graphics.setFont(smallFont)
                love.graphics.printf("Computer's serve",  0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
           end
        end
     elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        if gameMode == 'pvc' then
            love.graphics.printf('diff: '..difficulty..' side: '..side..' controls: '..controls, 0, 10, VIRTUAL_WIDTH, 'center')
        end
        
     -- no UI messages to display in play
     elseif gameState == 'done' then
        -- UI messages
        
       if gameMode == 'pvp' then
           love.graphics.setFont(largeFont)
           love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
           love.graphics.setFont(smallFont)
           love.graphics.printf('Press Enter to restart!', 0, 50, VIRTUAL_WIDTH, 'center')

       elseif gameMode == 'cvc' then
           love.graphics.setFont(largeFont)
           love.graphics.printf('Computer wins!', 0, 10, VIRTUAL_WIDTH, 'center')
           love.graphics.setFont(smallFont)
           love.graphics.printf('Press Enter to restart!', 0, 50, VIRTUAL_WIDTH, 'center')
       
        elseif gameMode == 'pvc' then
            if (side == 'left' and winningPlayer == 1) or (side == 'right' and winningPlayer == 2) then
                love.graphics.setFont(largeFont)
                love.graphics.printf("Player wins", 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.setFont(smallFont)
                love.graphics.printf('Press Enter to restart', 0, 30, VIRTUAL_WIDTH, 'center')
        elseif (side == 'left' and winningPlayer == 2) or (side == 'right' and winningPlayer == 1) then
            love.graphics.setFont(largeFont)
            love.graphics.printf("Computer wins",  0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        end
    end 
       
    elseif gameState == 'menu_mode' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a mode. Press the corresponding number on your keyboard.',0, 1, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Player vs Player \n 2. Player vs Computer \n 3. Computer vs Computer', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press escape to quit', 0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'right')
        
        
    elseif gameState == 'menu_diff' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a difficulty. Press the corresponding number on your keyboard.',0, 1, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Easy \n \n \n 2. Hard \n \n \n 3. Impossible' , 0, 50, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'menu_side' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a side. Press the corresponding number on your keyboard.',0, 1, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(largeFont)
        love.graphics.printf('\t 1. Left \t\t\t\t\t\t\t\t\t\t\t\t\t\t 2. Right', 0, 125, VIRTUAL_WIDTH, 'left')
    
    elseif gameState == 'menu_ctrl' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose your controls. Press the corresponding number on your keyboard.',0, 1, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. W-S keys \n \n 2. Arrow keys', 0, 50, VIRTUAL_WIDTH, 'center')
 end

    displayScore()  -- show the score before ball is rendered so it can move over the text
    
    if gameState ~= 'menu_mode' and gameState ~= 'menu_diff' and gameState ~= 'menu_side' and gameState ~= 'menu_ctrl' then
        paddle1:render()
        paddle2:render()
        ball:render()
    end

    displayFPS()    -- display FPS for debugging; simply comment out to remove

	push:apply('end')   -- End rendering at virtual resolution
end

function displayFPS( ... )
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.setFont(smallFont)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), -- Returns the current FPS of the app making it easier to monitor when printed
						40, 20)
	love.graphics.setColor(1, 1, 1, 1)
end

function displayScore( ... )
	
    -- score display
    if gameState ~= 'menu_mode' and gameState ~= 'menu_diff' and gameState ~= 'menu_side' and gameState ~= 'menu_ctrl' then
        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,VIRTUAL_HEIGHT / 3)
    end
end