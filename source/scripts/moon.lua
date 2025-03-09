local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Moon").extends(gfx.sprite)

function Moon:init(image, startX, startY, radius)
	self:setImage(image)
	self.radius = radius
	self.x, self.y = startX, startY
	self:moveTo(self.x, self.y)
	self:add()
end
