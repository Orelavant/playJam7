function getSourceTargetAngleComponents(sourceX, sourceY, targetX, targetY)
	local angle = math.atan(targetY - sourceY, targetX - sourceX)
	return math.cos(angle), math.sin(angle)
end

function getSourceTargetAngle(sourceX, sourceY, targetX, targetY)
	local angle = math.atan(targetY - sourceY, targetX - sourceX)

	return angle
end

function shallowcopy(table)
	local copy = {}
	for k, v in pairs(table) do
		copy[k] = v
	end
	return copy
end
