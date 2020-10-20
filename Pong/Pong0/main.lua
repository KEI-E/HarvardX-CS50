--Constants
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

function love.load()
	-- Sets the window of the game size
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, 
	{
		fullscreen = false,
		vsync = true,
		resizable = false
	})
end

function love.draw( ... )
	-- All in LOVE is drawn on the top left so you need to implement the location
	love.graphics.printf("Hello Pong!", 0, WINDOW_HEIGHT / 2 - 6, WINDOW_WIDTH, 'center')
end
