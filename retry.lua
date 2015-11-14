
local composer = require "composer" 
local scene = composer.newScene()
local widget = require "widget"
local mydata = require "mydata"

local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
    	composer.removeScene('game')
    end
end

function scene:create( event )
	local sceneGroup = self.view

	local function restart()
		composer.removeScene( 'retry' )
		composer.gotoScene( 'game', {effect='fade', time=200} )
	end

	local yourScore = display.newText( {text='Your Score: ' .. mydata.score, width=screenW, height=40, x=0, y=screenH/2-90, align="center"} )
	yourScore.anchorX, yourScore.anchorY = 0,0
	sceneGroup:insert(yourScore)

	local bestScore = display.newText( {text='Best Score: ' .. mydata.getBestScore( ), width=screenW, height=40, x=0, y=screenH/2-60, align="center"} )
	bestScore.anchorX, bestScore.anchorY = 0,0
	sceneGroup:insert(bestScore)
	
	local restartBtn = widget.newButton( {label="Restart", fontSize=50, x=screenW/2, y=screenH/2 + 30, onPress=restart } )
	sceneGroup:insert( restartBtn )
end


function scene:destroy( event )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )


return scene