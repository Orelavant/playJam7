-- Importing libraries
import("CoreLibs/graphics")
import("CoreLibs/sprites")
import("CoreLibs/ui")
import("scripts/applier")

-- Disable crank sound
playdate.setCrankSoundsDisabled(true)

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics
local screenWidth, screenHeight = playdate.display.getSize()
local state = "play"
local playState

-- Defining player variables
local applier = Applier()
local moonImage = gfx.image.new("images/circle64.png")
local smallMoonImage = gfx.image.new("images/circle32.png")
local moonRadius = moonImage:getSize() / 2
local drawMoonX, drawMoonY = moonRadius, screenHeight - moonRadius
local moonSprite = gfx.sprite.new(moonImage)

-- Helper functions
local function setToDraw()
	playState = "draw"

	-- Setup applier
	applier:setState("move")

	-- Setup moon
	moonSprite:clearCollideRect()
	moonSprite:setImage(moonImage)
	moonSprite:moveTo(drawMoonX, drawMoonY)
	moonSprite:add()
end

local function setToGolf()
	playState = "golf"

	applier:remove()
	moonSprite:setImage(smallMoonImage)
	moonSprite:setCollideRect(0, 0, smallMoonImage:getSize())
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
end

function playdate.upButtonDown()
	if playState == "draw" then
		-- Swap drawState
		if applier.state == "move" then
			applier:setState("apply")
		elseif applier.state == "apply" then
			applier:setState("move")
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
