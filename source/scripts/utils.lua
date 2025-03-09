function getSourceTargetAngleComponents(sourceX, sourceY, targetX, targetY)
	local angle = math.atan(targetY - sourceY, targetX - sourceX)
	return math.cos(angle), math.sin(angle)
end

function getSourceTargetAngle(sourceX, sourceY, targetX, targetY)
	local angle = math.atan(targetY - sourceY, targetX - sourceX)

	return angle
end
