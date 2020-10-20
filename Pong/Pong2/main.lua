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

--[[
	Calling the push
	Source: https://github.com/Ulydev/push
]]
push = require 'push'

function love.load()
	
	--Perfect pixels upscalling and downscalling, simulating a retro feel
	love.graphics.setDefaultFilter('nearest', 'nearest')

	--[[
		Loads a font file into the memory, setting it to a specific size,
		and store it to an object we can use globally
	]]
	smallFont = love.graphics.newFont('font.TTF', 8)
	love.graphics.setFont(smallFont)	--Current active font
	
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

--[[
	Executes whenever a key is pressed
]]
function love.keypressed(key)

	--Keys accessed by string name
	if key == 'escape' then
		love.event.quit()	--Terminates the application
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
	love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2,	--Location X
									VIRTUAL_HEIGHT / 2 - 2,	--Location Y
									5, 5)	--Dimensions of the ball
	love.graphics.rectangle('fill', 5, 20, 5, 20)	--Paddle 1
	love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 20)
	
	-- All in LOVE is drawn on the top left so you need to implement the location
	love.graphics.printf("Hello Pong!", -- text displayed on the screen
						0,	--Starting x 
						20, --Starting y
						VIRTUAL_WIDTH,	--Number of pixels to center within the entire screen
						'center')	--alignment mode

	--End rendering at virtual resolution
	push:apply('end')
end
