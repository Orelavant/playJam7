-- Importing libraries
import("CoreLibs/object")
import("CoreLibs/graphics")
import("CoreLibs/sprites")
import("CoreLibs/ui")

-- Importing other scripts
import("scripts/applier")
import("scripts/moon")
import("scripts/drawManager")
import("scripts/golfManager")

-- Disable crank sound
playdate.setCrankSoundsDisabled(true)

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Game globals
local playState = "draw"
local effectsTable = {}

-- Locals
local gameState = "play"
local drawManager = DrawManager()

local function setToGolf()
	playState = "golf"

	applier:remove()
	moon:setImage(smallMoonImage)
	moon:setCollideRect(0, 0, smallMoonImage:getSize())
end

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
		-- playState = "golf"
		-- setToGolf()
	elseif playState == "golf" then
		playState = drawManager:initDrawManager(playState)
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
