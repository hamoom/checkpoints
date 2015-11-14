
local composer = require "composer" 
local scene = composer.newScene()

local physics = require "physics"
physics.start()
physics.setGravity( 0, 15 )

local mydata = require "mydata"
local gameOver = false

local player
local world = display.newGroup( )
local bottom 
local top
local timeText
local scoreText

local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local backgrounds, walls, checkpoints = {}, {}, {}

local lastUpdate = 0.0
local secondsLeft = 15

local function formatTime(seconds)
	local minutesFloat = seconds / 60
	local minutes = math.floor( minutesFloat )
	local secondsFloat = (minutesFloat - minutes) * 60
	local secs = math.floor( secondsFloat )
	local secsDec = math.floor( (secondsFloat - secs) * 100 )

	return string.format( "%02d:%02d:%02d", minutes, secs, secsDec )
end

function getDeltaTime()
	if lastUpdate == 0 then
		dt = 0
	else
		dt = (system.getTimer( ) - lastUpdate) / 1000
	end
	lastUpdate = system.getTimer( )

	return dt
end

local function screenTouched(e)
	if e.phase == 'began' then
		local vxLimit = 600
		local vx, _ = player:getLinearVelocity()
		if vx <= 75 then
			vx = vx + 350
		elseif vx <= 200 then
			vx = vx + 100
		elseif vx <= vxLimit then
			vx = vx + 80
		end
		if vx > vxLimit then vx = vxLimit end
		player:setLinearVelocity( vx, -300 )
	end
end

local function spawnObjects(objectTable, fn)
	if #objectTable == 0 then
		fn()
	end

	for k, obj in pairs(objectTable) do
		local x, _ = obj:localToContent( 0, 0 )
		if x <= -obj.contentWidth then 
			display:remove( obj )
			objectTable[k] = nil
		end
	end
end

local function spawnCheckpoint( )
	local checkpoint = display.newRect( world, 100, 0, 1, screenH )
	checkpoint.name = 'checkpoint'
	checkpoint.touched = false
	checkpoint.anchorX, checkpoint.anchorY = 0,0
	checkpoint.x = -world.x + 2000
	physics.addBody( checkpoint, 'static' )
	checkpoint.isSensor = true
	checkpoints[#checkpoints+1] = checkpoint
end

local function spawnWall( )
	local randomY = math.random( 20, screenH - 20 )
	local randomX = math.random( 600, 2000 )
	local speed = 2000
	local initialSpd = (((screenH - 20) - randomY) / (screenH - 20)) * 800
	local wall = display.newRect( world, -world.x + randomX, randomY, 30, 170 )
	physics.addBody( wall, 'static', {bounce=0.1})

	local function moveWall( )
		transition.moveTo( wall, {
			time=initialSpd,
			y=screenH - 20, 
			onComplete = function() 
				transition.moveTo( wall, 
				{ time=speed, y=20, onComplete=moveWall})
			end
		})
		initialSpd = speed
	end

	moveWall()
	walls[#walls+1] = wall
end

local function playerCollision( self, e )
	if e.phase == 'began' then 
		if e.other.name == 'checkpoint' and not e.other.touched then
			secondsLeft = secondsLeft + 5
			e.other.touched = true
			mydata.score = mydata.score + 1
			scoreText.text = 'Score: ' .. mydata.score
		end
	end
end


local function update( )

	secondsLeft = secondsLeft - getDeltaTime()
	if secondsLeft <= 0 then secondsLeft = 0 end
	timeText.text = formatTime(secondsLeft)

	if secondsLeft <= 0 and not gameOver then
		gameOver = true
		mydata.setBestScore( )
		composer.gotoScene( 'retry', {effect='fade', time=200} )
	end

	local target = -player.x + 100
	world.x = world.x + (target - world.x) * 0.1
	bottom.x = -world.x
	top.x = -world.x

	for i, background in pairs(backgrounds) do
		local other 
		if i == 0 then other = 1 else other = 0 end

		local x, _ = background:localToContent( 0, 0 )
		
		if x <= -background.contentWidth  then
			background.x = backgrounds[other].x + backgrounds[other].contentWidth
		end
	end

	spawnObjects(walls, spawnWall)
	spawnObjects(checkpoints, spawnCheckpoint)

end


function scene:create( event )
	local sceneGroup = self.view

	-- create backgrounds
	local numBackground = 6
	for i = 0, 1 do 
		backgrounds[i] = display.newGroup( )
		world:insert( backgrounds[i] )

		for j = 1, numBackground do 
			local background = display.newRect( world, (j-1)*100, 0, 100, screenH)
		
			background.anchorX, background.anchorY = 0,0
			if j % 2 == 0 then
				background:setFillColor( 60/255, 60/255, 60/255 )
			else
				background:setFillColor( 30/255, 30/255, 30/255 )
			end

			backgrounds[i]:insert( background )
		end

		backgrounds[i].x = i * backgrounds[i].contentWidth
	end

	-- create barriers
	top = display.newRect(world, 0, 0, screenW, 2 )
	top.anchorX, top.anchorY = 0,0
	top:setFillColor( 0,1,0 )
	physics.addBody( top, 'static' )

	bottom = display.newRect(world, 0, screenH - 2, screenW, 2 )
	bottom.anchorX, bottom.anchorY = 0,0
	bottom:setFillColor( 0,1,0 )
	physics.addBody( bottom, 'static' )

	-- create player
	player = require("player").new(world)
	player.x, player.y = 100, 100
	sceneGroup:insert( world )
	physics.addBody( player, 'dynamic', {friction = 1.0, density = 10.0, bounce = 0.0} )
	player.collision = playerCollision
	player:addEventListener( 'collision', player )
	player.isFixedRotation = true 
	player.isBullet = true

	-- create timer
	timeText = display.newText( {text=formatTime(secondsLeft), x=60, y=20, width=100, height=20, align="left"} )
	sceneGroup:insert( timeText )

	-- create score
	mydata.score = 0
	scoreText = display.newText( {text='Score: ' .. mydata.score, x=screenW-60, y=20, width=100, height=20, align="right"} )
	sceneGroup:insert( scoreText )
end



function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		
	elseif phase == "did" then
		Runtime:addEventListener( 'touch', screenTouched )
		Runtime:addEventListener( 'enterFrame', update )
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		physics.stop()
		Runtime:removeEventListener( 'touch', screenTouched )
		Runtime:removeEventListener( 'enterFrame', update )
		player:removeEventListener( 'preCollision', player )
	elseif phase == "did" then
	end	
	
end

function scene:destroy( event )

	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end


---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


-----------------------------------------------------------------------------------------

return scene