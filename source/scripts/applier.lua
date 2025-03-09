import("scripts/utils.lua")

local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Defining applier variables
local screenWidth, screenHeight = playdate.display.getSize()
local halfScreenWidth, halfScreenHeight = screenWidth / 2, screenHeight / 2
local applierImage = gfx.image.new("images/circle8.png")
local condiments = { "pb", "honey" }

class("Applier").extends(gfx.sprite)

function Applier:init()
	self.x, self.y = halfScreenWidth, halfScreenHeight
	self.cos, self.sin = 0, 0
	self.radius = applierImage:getSize() / 2

	-- move and apply
	self.state = "move"
	self.targetApplied = false

	-- pb and honey
	self.condiment = "pb"

	self:setImage(applierImage)
	self:add()
end

function Applier:move(moonX, moonY, moonRadius)
	if self.state == "move" then
		self:revolve(moonX, moonY, moonRadius)
		self.targetApplied = false
	elseif self.state == "apply" then
		if self.condiment == "pb" then
			self:moveStraight(moonX, moonY, moonRadius)
		end
	end
end

function Applier:revolve(moonX, moonY, moonRadius)
	local crankPosition = pd.getCrankPosition() - 90
	self.x = moonX + (moonRadius - self.radius) * math.cos(math.rad(crankPosition))
	self.y = moonY + (moonRadius - self.radius) * math.sin(math.rad(crankPosition))

	self:moveTo(self.x, self.y)
end

function Applier:moveStraight(moonX, moonY, moonRadius)
	if not self.targetApplied then
		self:setLinearTarget(moonX, moonY)
		self.targetApplied = true
	end

	-- Update towards that target
	local crankChange = pd.getCrankChange() / 4
	self.x += crankChange * self.cos
	self.y += crankChange * self.sin

	-- Clamp within the moon
	local distance = math.sqrt((self.x - moonX) ^ 2 + (self.y - moonY) ^ 2)
	if distance > moonRadius - self.radius then
		local cos, sin = getSourceTargetAngleComponents(moonX, moonY, self.x, self.y)
		self.x = moonX + cos * (moonRadius - self.radius)
		self.y = moonY + sin * (moonRadius - self.radius)
	end

	self:moveTo(self.x, self.y)
end

local function incrementCurrCondiment() end

local function decrementCurrCondiment() end

function Applier:setLinearTarget(moonX, moonY)
	self.cos, self.sin = getSourceTargetAngleComponents(self.x, self.y, moonX, moonY)
end

function Applier:setState(state)
	self.state = state
end

function Applier:setCondiment(condiment)
	self.condiment = condiment
end
