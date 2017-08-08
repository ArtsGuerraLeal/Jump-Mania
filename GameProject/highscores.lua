local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local scoresTable = {}
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )
local musicTrack

local function loadScores()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end


local function saveScores()

	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end


local function gotoMenu()
	composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end


function scene:create( event )

	local sceneGroup = self.view
	loadScores()


	table.insert( scoresTable, composer.getVariable( "finalScore" ) )
	composer.setVariable( "finalScore", 0 )

	local function compare( a, b )
		return a > b
	end
  
	table.sort( scoresTable, compare )
	
	saveScores()

	local background = display.newImageRect( sceneGroup, "backgroundForest.png", display.actualContentWidth, display.actualContentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local highScoresHeader = display.newText( sceneGroup, "high scores", display.contentCenterX, display.contentCenterY/2, native.newFont( "Mario-Kart-DS.ttf", 62 ))
    highScoresHeader:setTextColor(1,1,1)
	for i = 1, 11 do
		if ( scoresTable[i] ) then
			local yPos = 200 + ( i * 44 )

			local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.newFont( "Mario-Kart-DS.ttf", 36 ) )
			rankNum.anchorX = 1

			local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.newFont( "Mario-Kart-DS.ttf", 36 ) )
			thisScore.anchorX = 0
		end
	end

	local menuButton = display.newText( sceneGroup, "menu", display.contentCenterX/4, display.contentCenterY/3, native.newFont( "Mario-Kart-DS.ttf", 72 ) )
	menuButton:setFillColor(1, 1, 1 )
	menuButton:addEventListener( "tap", gotoMenu )

	musicTrack = audio.loadStream( "credits.mp3" )
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		audio.stop( 1 )
		composer.removeScene( "highscores" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
  
	audio.dispose( musicTrack )
end



scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene
