Paddle = Class{}

function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dy = 0
end

function Paddle:update(dt)
	if self.dy < 0 then
		self.y = math.max(0, self.y + self.dy * dt)
	elseif self.dy > 0 then
		self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy * dt)
	end
end

function Paddle:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

--[[
    To be called by our main function in `love.draw`, ideally. Uses
    LÖVE2D's `rectangle` function, which takes in a draw mode as the first
    argument as well as the position and dimensions for the rectangle. To
    change the color, one must call `love.graphics.setColor`. As of the
    newest version of LÖVE2D, you can even draw rounded rectangles!
]]
function Paddle:reset1()
    self.x = 10
    self.y = 30
    self.width = 5
    self.height = 20
    self.dy = 0
end

function Paddle:reset2()
    self.x = VIRTUAL_WIDTH -10
    self.y = VIRTUAL_HEIGHT - 30
    self.width = 5
    self.height = 20
    self.dy = 0
end
