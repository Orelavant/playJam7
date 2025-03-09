-- Importing libraries
import("CoreLibs/graphics")
import("CoreLibs/sprites")
import("CoreLibs/ui")
import("scripts/applier")
import("scripts/moon")

-- Disable crank sound
playdate.setCrankSoundsDisabled(true)

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics
local _, screenHeight = playdate.display.getSize()

local state = "play"
local playState

-- Images
local applierImage = gfx.image.new("images/circle8.png")
local moonImage = gfx.image.new("images/circle64.png")
local smallMoonImage = gfx.image.new("images/circle32.png")

-- Game variables
local applier = Applier(applierImage)
local effectsTable = {}
local moonRadius = moonImage:getSize() / 2
local drawMoonX, drawMoonY = moonRadius, screenHeight - moonRadius
local moon = Moon(moonImage, drawMoonX, drawMoonY, moonRadius)

-- Helper functions
local function setToDraw()
	playState = "draw"

	-- Setup applier
	applier:add()
	applier:setState("move")

	-- Setup moon
	moon:clearCollideRect()
	moon:setImage(moonImage)
	moon:moveTo(drawMoonX, drawMoonY)
	moon:add()
end

local function setToGolf()
	playState = "golf"

	applier:remove()
	moon:setImage(smallMoonImage)
	moon:setCollideRect(0, 0, smallMoonImage:getSize())
end

local function init()
	setToDraw()
end

init()

-- Main update function
function playdate.update()
	gfx.sprite.update()

	if playState == "draw" then
		applier:move(drawMoonX, drawMoonY, moonRadius)
	elseif playState == "golf" then
	end

	-- Draw crank indicator if crank is docked
	if pd.isCrankDocked() then
		pd.ui.crankIndicator:draw()
	end

	-- Draw state texts
	gfx.drawText(playState, 0, 0)
	gfx.drawText(applier.state, 0, 20)
	gfx.drawText(applier:getCurrCondiment(), 0, 40)
end

function playdate.upButtonDown()
	if playState == "draw" then
		-- Swap drawState
		if applier.state == "move" then
			applier:setApplyState(moon.x, moon.y)
		elseif applier.state == "apply" then
			applier:setMoveState(effectsTable)
		end
	end
end

function playdate.leftButtonDown()
	if playState == "draw" then
		applier:decrementCurrCondiment()
	end
end

function playdate.rightButtonDown()
	if playState == "draw" then
		applier:incrementCurrCondiment()
	end
end

function playdate.downButtonDown()
	-- Swap playState
	if playState == "draw" then
		setToGolf()
	elseif playState == "golf" then
		setToDraw()
	end
end
