-- Importing libraries
import("CoreLibs/graphics")
import("CoreLibs/ui")

-- Disable crank sound
playdate.setCrankSoundsDisabled(true)

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics
local screenWidth, screenHeight = playdate.display.getSize()
local halfScreenWidth, halfScreenHeight = screenWidth / 2, screenHeight / 2
local state = "play"
local drawState = "revolve"

-- Defining player variables
local moonX, moonY = halfScreenWidth, halfScreenHeight
local moonImage = gfx.image.new("images/moon.png")
local moonMaxX, moonMaxY = moonImage:getSize()
local moonSprite = gfx.sprite.new(moonImage)

-- Defining applier variables
local applierX, applierY = halfScreenWidth, halfScreenHeight
local applierTarget = false
local applierCos, applierSin = 0, 0
local applierImage = gfx.image.new("images/circle16.png")
local applierSprite = gfx.sprite.new(applierImage)
local applierOffset = 54

-- Helper functions
local function revolveApplier()
	local crankPosition = pd.getCrankPosition() - 90
	applierX = moonX + math.cos(math.rad(crankPosition)) * applierOffset
	applierY = moonY + math.sin(math.rad(crankPosition)) * applierOffset
	applierSprite:moveTo(applierX, applierY)
end

-- Usually is in utils but having trouble importing
local function getSourceTargetAngleComponents(sourceX, sourceY, targetX, targetY)
	local angle = math.atan(targetY - sourceY, targetX - sourceX)
	return math.cos(angle), math.sin(angle)
end

local function moveApplier()
	-- Get target to move applier towards
	if not applierTarget then
		applierCos, applierSin = getSourceTargetAngleComponents(applierX, applierY, moonX, moonY)
		applierTarget = true
	end

	-- Update towards that target
	local crankChange = pd.getCrankChange()
	applierX += crankChange * applierCos
	applierY += crankChange * applierSin

	-- Constrain to inside of moon
	-- If less then start, set to start
	-- if applierX <= applierDrawStartX then
	-- 	applierX = applierDrawStartX
	-- end
	-- if applierY <= applierDrawStartY then
	-- 	applierY = applierDrawStartY
	-- end
	-- If greater then moon perimeter, set to perimeter
	-- if applierX >= moonX + moonMaxX / 2 then
	-- 	applierX = moonX + moonMaxX / 2
	-- end
	-- if applierY >= moonY + moonMaxY / 2 then
	-- 	applierY = moonY + moonMaxY / 2
	-- end

	applierSprite:moveTo(applierX, applierY)
end

local function handleApplier()
	if drawState == "revolve" then
		revolveApplier()
	elseif drawState == "linear" then
		moveApplier()
	end
end

local function init()
	applierSprite:add()
	revolveApplier()

	moonSprite:setCollideRect(0, 0, moonImage:getSize())
	moonSprite:moveTo(moonX, moonY)
	moonSprite:add()
end

init()

-- Main update function
function playdate.update()
	gfx.sprite.update()

	handleApplier()

	-- Draw crank indicator if crank is docked
	if pd.isCrankDocked() then
		pd.ui.crankIndicator:draw()
	end
end

local function resetToRevolve()
	applierTarget = false
end

function playdate.upButtonDown()
	-- Swap applierState
	if drawState == "revolve" then
		drawState = "linear"
	else
		drawState = "revolve"
		resetToRevolve()
	end
end
