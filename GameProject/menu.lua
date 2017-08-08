
local composer = require( "composer" )

local scene = composer.newScene()



local musicTrack


local function gotoGame()
	composer.gotoScene( "game", { time=800, effect="crossFade" } )
  
end

local function gotoScores()
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

function scene:create( event )

	local sceneGroup = self.view

	local background = display.newImageRect( sceneGroup, "background.png", display.actualContentWidth, display.actualContentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "mania.png", 500, 80 )
	title.x = display.contentCenterX
	title.y = 200
  
	local startButton = display.newImageRect(sceneGroup,"start.png",150,50)
  startButton.x = display.contentCenterX
	startButton.y = 400
  
  
  	local HigscoresButton = display.newImageRect(sceneGroup,"highscores.png",250,75)
  HigscoresButton.x = display.contentCenterX
	HigscoresButton.y = 470

	--local playButton = display.newText( sceneGroup, "start", display.contentCenterX, 450, native.newFont( "Mario-Kart-DS.ttf", 44 ))
	--playButton:setFillColor( 1, 1, 1 )
  HigscoresButton:addEventListener( "tap", gotoScores )
	startButton:addEventListener( "tap", gotoGame )
	musicTrack = audio.loadStream( "title.mp3" )
end



function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
    
	elseif ( phase == "did" ) then
		audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end



function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		audio.stop( 1 )
	end
end



function scene:destroy( event )

	local sceneGroup = self.view
	audio.dispose( musicTrack )
  display.remove(title)
  display.remove(startButton)
  display.remove(HigscoresButton)
  display.remove(background)
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene
