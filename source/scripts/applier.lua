import("scripts/utils.lua")

local pd <const> = playdate
local gfx <const> = playdate.graphics

local screenWidth, screenHeight = playdate.display.getSize()
local halfScreenWidth, halfScreenHeight = screenWidth / 2, screenHeight / 2
local condiments = { "pb", "honey" }
local effectCondiments = { pb = true }
local changeTemplate = { condiment = nil, crankChange = 0, cos = nil, sin = nil }

class("Applier").extends(gfx.sprite)

function Applier:init(image)
	self.x, self.y = halfScreenWidth, halfScreenHeight
	self.cos, self.sin = 0, 0
	self.radius = image:getSize() / 2

	-- move and apply
	self.state = "move"
	self.changeTable = shallowcopy(changeTemplate)

	-- pb and honey
	self.iCondiment = 1

	self:setImage(image)
	self:add()
end

function Applier:move(moonX, moonY, moonRadius)
	if self.state == "move" then
		self:revolve(moonX, moonY, moonRadius)
		self.targetApplied = false
	elseif self.state == "apply" then
		if self:getCurrCondiment() == "pb" then
			self:moveStraight(moonX, moonY, moonRadius)
		else
			self:revolve(moonX, moonY, moonRadius)
		end
	end
end

function Applier:revolve(moonX, moonY, moonRadius)
	local crankPosition = pd.getCrankPosition() - 90

	-- Record changes when applying
	self:recordChange()

	-- Move
	self.x = moonX + (moonRadius - self.radius) * math.cos(math.rad(crankPosition))
	self.y = moonY + (moonRadius - self.radius) * math.sin(math.rad(crankPosition))

	self:moveTo(self.x, self.y)
end

function Applier:recordChange()
	if self.state == "apply" then
		self.changeTable["crankChange"] += pd.getCrankChange()
	end
end

function Applier:moveStraight(moonX, moonY, moonRadius)
	-- Update towards that target
	local crankChange = pd.getCrankChange()
	self.x += crankChange * self.cos
	self.y += crankChange * self.sin

	-- Clamp within the moon
	local distance = math.sqrt((self.x - moonX) ^ 2 + (self.y - moonY) ^ 2)
	if distance > moonRadius - self.radius then
		local cos, sin = getSourceTargetAngleComponents(moonX, moonY, self.x, self.y)
		self.x = moonX + cos * (moonRadius - self.radius)
		self.y = moonY + sin * (moonRadius - self.radius)
	else
		self:recordChange()
	end

	self:moveTo(self.x, self.y)
end

function Applier:setLinearTarget(moonX, moonY)
	self.cos, self.sin = getSourceTargetAngleComponents(self.x, self.y, moonX, moonY)
end

function Applier:setState(state)
	self.state = state
end

function Applier:setApplyState(moonX, moonY)
	self.state = "apply"

	-- If PB, set travel angle, and record that
	if self:getCurrCondiment() == "pb" then
		self:setLinearTarget(moonX, moonY)
		self.changeTable["cos"] = self.cos
		self.changeTable["sin"] = self.sin
	end

	-- Record current condiment
	self.changeTable["condiment"] = self:getCurrCondiment()
end

function Applier:setMoveState(effectsTables)
	-- Reset state
	self.state = "move"
	self.cos, self.sin = 0, 0

	-- Insert into effectsTable if needed
	if effectCondiments[self:getCurrCondiment()] then
		table.insert(effectsTables, self.changeTable)
	end

	-- Reset recordedChange
	self.changeTable = shallowcopy(changeTemplate)
end

function Applier:getCurrCondiment()
	return condiments[self.iCondiment]
end

function Applier:setCondiment(iCondiment)
	self.iCondiment = iCondiment
end

function Applier:incrementCurrCondiment()
	self.iCondiment = (self.iCondiment % #condiments) + 1
end

function Applier:decrementCurrCondiment()
	self.iCondiment = (self.iCondiment - 2) % #condiments + 1
end

function Applier:getState()
	return self.state
end
