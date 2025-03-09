local pd <const> = playdate
local gfx <const> = playdate.graphics


class("Moon").extends(gfx.sprite)

function Moon:init(image, startX, startY, radius)
	self.radius = radius
	self.x, self.y = startX, startY

	self:setImage(image)
	self:moveTo(self.x, self.y)
	self:add()
end
