
local new
local sayName
local preCollision

sayName = function( self )
	print( self.name )
end

new = function( world )
	local player = display.newRect( world, 0, 0, 20, 20 )
	player:setFillColor( 1,0,0 )
	player.name = 'player'
	player.sayName = sayName
	player.preCollision = preCollision
	return player
end

local public = {}
public.new = new
return public