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

--Calling the push
push = require 'push'

function love.load()

	--[[
		Sets the texture scalling filter when minimizing and magnifying texture and fonts;
		default is billinear, which causes blurriness, and for our use cses we will typically
		want nearest-neighbor filtering('nearest'), which results in perfect pixels upscalling 
		and downscalling, simulating a retro feel
	]]
	love.graphics.setDefaultFilter('nearest', 'nearest')

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
	if key == 'escape' then
		love.event.quit()	--Terminates the game
	end
end

--[[
	Called update by LOVE, used to draw anything on the screen, updated or otherwise
]]
function love.draw( ... )
	--Aplly the push functions
	push:apply('start')
	
	-- All in LOVE is drawn on the top left so you need to implement the location
	love.graphics.printf("Hello Pong!", -- text displayed on the screen
						0,	--Starting x 
						VIRTUAL_HEIGHT / 2 - 6, --Starting y
						VIRTUAL_WIDTH,	--Number of pixels to center within the entire screen
						'center')	--alignment mode

	push:apply('end')
end
