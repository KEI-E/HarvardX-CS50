--[[
	Credits to Colton Ogden from HarvardX CS50

	Originally programmed by Atari in 1972. Features 2 paddles controlled by players,
	with the goal of getting  the ball pass through the opponents edge. First to 10
	points wins.

	This version is built to more closely resemble the NES than the original Pong
	machines or the Atari 2600 in terms of resolution, though in widescreen (16:9)
	so it looks nicer on modern systems.
]]

--Constants
WINDOW_WIDTH = 1280	--X
WINDOW_HEIGHT = 720	--Y

--Still modern in appearance but still has that retro look on ti
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[
	Calling the push
	Source: https://github.com/Ulydev/push
]]
push = require 'push'

function love.load()
	--Random number generator
	math.randomseed(os.time())	--Unix epoch time
	
	--Perfect pixels upscalling and downscalling, simulating a retro feel
	love.graphics.setDefaultFilter('nearest', 'nearest')

	--[[
		Loads a font file into the memory, setting it to a specific size,
		and store it to an object we can use globally
	]]
	smallFont = love.graphics.newFont('font.TTF', 8)
	scoreFont = love.graphics.newFont('font.TTF', 32)

	player1Score = 0
	player2Score = 0

	player1Y = 30
	player2Y = VIRTUAL_HEIGHT - 41

	ballX = VIRTUAL_WIDTH / 2 - 2
	ballY = VIRTUAL_HEIGHT / 2 - 2

	--[[
		Returns random number dependent on the seeded random number generator
		Can take in a single number or 2 numbers
		if 2 numbers are taken it would be math.random(min, max)
	]]
	ballDX = math.random(2) == 1 and -100 or 100
	ballDY = math.random(-50, 50)

	--Game state
	gameState = 'start' 
	
	--[[
		Runs when the game first starts up
		Initialize the  game
	]]
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, 
	{
		fullscreen = false,
		vsync = true,
		resizable = false
	})
end

function love.update(dt)	--dt or delta time allows to move things independently
	if love.keyboard.isDown('w') then	--Returns true or false if the specified key is currently held downs
		player1Y = math.max(0, player1Y - PADDLE_SPEED * dt)	--math.max returns the greater of the 2 numbers passed in
	elseif love.keyboard.isDown('s') then
		player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)	--math.min returns the lesser of the 2 numbers passed in
	end

	if love.keyboard.isDown('up') then
		player2Y = math.max(0, player2Y - PADDLE_SPEED * dt)	
	elseif love.keyboard.isDown('down') then
		player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
	end

	if gameState == 'play' then
		ballX = ballX + ballDX * dt
		ballY = ballY + ballDY * dt
	end
end


--[[
	Executes whenever a key is pressed
]]
function love.keypressed(key)

	--Keys accessed by string name
	if key == 'escape' then
		love.event.quit()	--Terminates the application
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'play'
		elseif gameState == 'play' then
			gameState = 'start'

			ballX = VIRTUAL_WIDTH / 2 - 2
			ballY = VIRTUAL_HEIGHT / 2 - 2

			ballDX = math.random(2) == 1 and -100 or 100
			ballDY = math.random(-50, 50)
		end
	end
end

--[[
	Called update by LOVE, used to draw anything on the screen, updated or otherwise
]]
function love.draw( ... )
	
	--Begin rendering at virtual resolution
	push:apply('start')

	--Sets the background color
	love.graphics.clear(38/255, 70/255, 83/255, 1)

	--[[
		Draws a rectangle choosing whatever the active color is
		Color can be set by love.graphics.setColor()
		Fill is a filled shape
		Line is a hollow shapa
	]]
	love.graphics.setColor(248/255, 249/255, 250/255, 1)
	love.graphics.rectangle('fill', ballX,	--Location X
									ballY,	--Location Y
									5, 5)	--Dimensions of the ball
	love.graphics.rectangle('fill', 5, player1Y, 5, 20)	--Paddle 1 (Left)
	love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)	--Paddle 2 (Right)
	
	love.graphics.setFont(smallFont)

	if gameState == 'start' then 
		-- All in LOVE is drawn on the top left so you need to implement the location
		love.graphics.printf("Press Enter to Start!", -- text displayed on the screen
						0,	--Starting x 
						20, --Starting y
						VIRTUAL_WIDTH,	--Number of pixels to center within the entire screen
						'center')	--alignment mode
	elseif gameState == 'play' then
		love.graphics.printf("Game on Going!", 0, 20, VIRTUAL_WIDTH, 'center')	
	end
		

	love.graphics.setFont(scoreFont)	--Active font
	love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)	--Print player 1 score
	love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)	--Print player 2 score

	--End rendering at virtual resolution
	push:apply('end')
end
