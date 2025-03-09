-- Importing libraries
import("CoreLibs/object")
import("CoreLibs/graphics")
import("CoreLibs/sprites")
import("CoreLibs/ui")

-- Importing other scripts
import("scripts/applier")
import("scripts/circle")
import("scripts/drawManager")
import("scripts/golfManager")

-- Disable crank sound
playdate.setCrankSoundsDisabled(true)

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics
local _, screenHeight = playdate.display.getSize()

-- Images
local applierImage = gfx.image.new("images/circle8.png")
local bigMoonImage = gfx.image.new("images/circle64.png")
local smallMoonImage = gfx.image.new("images/circle32.png")

-- Locals
local gameState = "play"
local playState = "draw"
local effectsTable = {}

-- Applier
local applier = Applier(applierImage)

-- Moon
local moonRadius = bigMoonImage:getSize() / 2
local drawMoonX, drawMoonY = moonRadius, screenHeight - moonRadius
local moon = Circle(bigMoonImage, drawMoonX, drawMoonY, moonRadius)

-- Ball
local ballRadius = smallMoonImage:getSize() / 2
local ball = Circle(smallMoonImage, drawMoonX, drawMoonY, ballRadius)

-- Managers
local drawManager = DrawManager(applier, moon, drawMoonX, drawMoonY)
local golfManager = GolfManager(ball)

-- Init
playState = drawManager:swapToDraw(playState, ball)

-- Main update function
function playdate.update()
	gfx.sprite.update()

	if playState == "draw" then
		drawManager:update(playState, effectsTable)
	elseif playState == "golf" then
		-- golf.update()
	end

	-- Draw crank indicator if crank is docked
	if pd.isCrankDocked() then
		pd.ui.crankIndicator:draw()
	end
end

-- Handle input
function playdate.upButtonDown()
	if playState == "draw" then
		-- Swap drawState
		if drawManager.applier:getState() == "move" then
			drawManager:setApplyState()
		elseif drawManager.applier:getState() == "apply" then
			drawManager:setMoveState(effectsTable)
		end
	end
end

function playdate.downButtonDown()
	-- Swap playState
	if playState == "draw" then
		playState = golfManager:swapToGolf(playState, applier, moon)
	elseif playState == "golf" then
		playState = drawManager:swapToDraw(playState, ball)
	end
end

function playdate.leftButtonDown()
	if playState == "draw" then
		drawManager.applier:decrementCurrCondiment()
	end
end

function playdate.rightButtonDown()
	if playState == "draw" then
		drawManager.applier:incrementCurrCondiment()
	end
end
