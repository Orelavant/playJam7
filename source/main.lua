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
local moonRadius, _ = moonImage:getSize() / 2
local moonSprite = gfx.sprite.new(moonImage)

-- Defining applier variables
local applierX, applierY = halfScreenWidth, halfScreenHeight
local applierCos, applierSin = 0, 0
local applierImage = gfx.image.new("images/circle16.png")
local applierRadius, _ = applierImage:getSize() / 2
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
	-- Update towards that target
	local crankChange = pd.getCrankChange()
	applierX += crankChange * applierCos
	applierY += crankChange * applierSin

	-- Clamp within the moon
	local distance = math.sqrt((applierX - moonX) ^ 2 + (applierY - moonY) ^ 2)
	if distance > moonRadius - applierRadius then
		local cos, sin = getSourceTargetAngleComponents(moonX, moonY, applierX, applierY)
		applierX = moonX + cos * (moonRadius - applierRadius)
		applierY = moonY + sin * (moonRadius - applierRadius)
	end

	applierSprite:moveTo(applierX, applierY)
end

local function handleApplier()
	if drawState == "revolve" then
		revolveApplier()
	elseif drawState == "linear" then
		moveApplier()
	end
end

local function setToRevolve()
	drawState = "revolve"
end

local function setToLinear()
	drawState = "linear"
	applierCos, applierSin = getSourceTargetAngleComponents(applierX, applierY, moonX, moonY)
end

function playdate.upButtonDown()
	-- Swap applierState
	if drawState == "revolve" then
		setToLinear()
	elseif drawState == "linear" then
		setToRevolve()
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
