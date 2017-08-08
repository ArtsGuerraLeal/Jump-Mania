local composer = require( "composer" )

local scene = composer.newScene()

local physics = require( "physics" )
physics.start(true)
physics.setGravity( 0, 25)


--  variables
local objectSheet

local lives = 5
local score = 0
local coins = 0
local died = false
local changeLevel = false
local enemiesTable = {}

local player
local gameLoopTimer
local gameLoopTimer2
local gameLoopTimer3
local gameLoopTimer4

local backgroundTimer
local livesText
local scoreText
local globalSpeedMod = 0

local backGroup
local mainGroup
local uiGroup
local sceneGroup

local newBush1
local newBush2
local bushCount = 0



local jumpSound
local deathSound
local musicTrack
local startTime
local distance

local grounded = true
local jumped = false
local running = true
local spinning = false
local falling = false

local koopaCount = 0
local goombaCount = 0
local coinCount = 0
local dragonCoinCount = 0
local bulletBillCount = 0
local bigBulletBillCount = 0
local oneUpCount = 0
local goombaTable = {}
local koopaTable = {}
local coinTable = {}
local dragonCoinTable = {}
local bulletBillTable = {}
local bigBulletBillTable = {}
local oneUpTable = {}


local sheetOptions =
{
    width = 40,
    height = 80,
    numFrames = 2
}

local sheetOptionsMario =
{
    width = 40,
    height = 80,
    numFrames = 1
}


local sheetOptionsGoomba =
{
    width = 30,
    height = 40,
    numFrames = 2
}

local sheetOptionsCoins = {
  
    width = 22,
    height = 32,
    numFrames = 4
  }
  
  local sheetOptionsDragonCoins = {
  
    width = 32,
    height = 50,
    numFrames = 1
  }
  
    local sheetOptionsOneUp = {
  
    width = 16 ,
    height = 16,
    numFrames = 1
  }
  
    local sheetOptionsBulletBill = {
  
    width = 16,
    height = 14,
    numFrames = 1
  }
  
    local sheetOptionsBigBulletBill = {
  
    width = 64,
    height = 64,
    numFrames = 1
  }

local sheet_mario_run = graphics.newImageSheet( "marioRun.png", sheetOptions )
local sheet_mario_jump = graphics.newImageSheet( "marioJump.png", sheetOptions )
local sheet_mario_spin = graphics.newImageSheet( "marioSpin.png", sheetOptions )
local sheet_mario_death = graphics.newImageSheet( "marioDeath.png", sheetOptionsMario )

local sheet_goomba_walk = graphics.newImageSheet( "goombaWalk.png", sheetOptionsGoomba )
local sheet_koopa_walk = graphics.newImageSheet( "koopaWalk.png", sheetOptionsGoomba )
local sheet_coin = graphics.newImageSheet( "coins.png", sheetOptionsCoins )
local sheet_dragon_coin = graphics.newImageSheet( "dragonCoin.png", sheetOptionsDragonCoins )

local sheet_OneUp = graphics.newImageSheet( "OneUp.png", sheetOptionsOneUp )
local sheet_BulletBill = graphics.newImageSheet( "BulletBill.png", sheetOptionsBulletBill )
local sheet_BigBulletBill = graphics.newImageSheet( "BigBulletBill.png", sheetOptionsBigBulletBill )
 
local sequences_OneUp = 
    -- consecutive frames sequence
    {
        name = "OneUp",
        sheet=sheet_OneUp,
        start = 1,
        count = 1,
        time = 1000,
    }
    
    local sequences_BulletBill = 
    -- consecutive frames sequence
    {
        name = "BulletBill",
        sheet=sheet_BulletBill,
        start = 1,
        count = 1,
        time = 1000,
    }
    
    local sequences_BigBulletBill = 
    -- consecutive frames sequence
    {
        name = "BigBulletBill",
        sheet=sheet_BigBulletBill,
        start = 1,
        count = 1,
        time = 1000,
    }


local sequences_DragonCoinSpin = 
    -- consecutive frames sequence
    {
        name = "DragonCoin",
        sheet=sheet_dragon_coin,
        start = 1,
        count = 1,
        time = 1000,
    }

local sequences_KoopaWalk = 
    -- consecutive frames sequence
    {
        name = "KoopaWalk",
        sheet=sheet_koopa_walk,
        start = 1,
        count = 2,
        time = 600,
    }

local sequences_CoinSpin = 
    -- consecutive frames sequence
    {
        name = "CoinSpin",
        sheet=sheet_coin,
        start = 1,
        count = 4,
        time = 800,
    }

local sequences_GoombaWalk = 
    -- consecutive frames sequence
    {
        name = "GoombaWalk",
        sheet=sheet_goomba_walk,
        start = 1,
        count = 2,
        time = 600,
    }

local sequences_MarioRun = {
    -- consecutive frames sequence
    {
        name = "normalRun",
        sheet=sheet_mario_run,
        start = 1,
        count = 2,
        time = 200,
    },
       {
        name = "normalJumpUp",
        sheet=sheet_mario_jump,
        start = 1,
        count = 1,
        time = 200,
       },
       
      {
        name = "normalJumpDown",
        sheet=sheet_mario_jump,
        start = 2,
        count = 1,
        time = 200,
       },
       {
        name = "normalDeath",
        sheet=sheet_mario_death,
        start = 1,
        count = 1,
        time = 200,
       },
      {
        name = "normalSpin",
        sheet=sheet_mario_spin,
        start = 1,
        count = 2,
        time = 100,
        
    }
}

local function endGame()
  --disposable()
	composer.setVariable( "finalScore", score )
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
 
end

local function updateValues()
	livesText.text = "mario x " .. lives
	scoreText.text = "score: " .. score
  coinsText.text = "coins: " .. coins
  score = score + 1
  if(coins >= 100)then
    lives = lives + 1
    audio.play(livesSound)
    coins = 0
  end
  
  if(score > 15000) then 
    transition.to(background1,{alpha =0})
    transition.to(background2,{alpha =0})
  end
  
  if(lives == 0)then
    --disposable()
    endGame()
    
    end
end

local function createOneUp()
if(oneUpCount < 1 and lives < 7)then
  local newOneUp = display.newSprite( screenGroup,sheet_OneUp, sequences_OneUp )
  table.insert( oneUpTable, newOneUp)
  physics.addBody( newOneUp, "static", { radius=20, bounce=0.0,density = 0} )
  newOneUp.myName = "oneup"
  newOneUp.x = math.random(1000,15000)
  newOneUp.y = 600
  newOneUp:scale(2.2,2.2)
  newOneUp.isSensor = true
  oneUpCount = oneUpCount + 1
  end
end


local function createBulletBill()  
if(bulletBillCount < 3 and score > 15000)then
  local newBill = display.newSprite( screenGroup,sheet_BulletBill, sequences_BulletBill )
  table.insert( bulletBillTable, newBill)
  physics.addBody( newBill, "static", { radius=20, bounce=0.0,density = 0} )
  newBill.myName = "bulletbill"
  newBill:scale(2,2)
  newBill.x = math.random(1000,5500)
  newBill.y = math.random(350,550)
  bulletBillCount = bulletBillCount + 1
  end
end


local function createBigBulletBill()  
if(bigBulletBillCount < 1 and score > 20000)then
  local newBigBill = display.newSprite( screenGroup,sheet_BigBulletBill, sequences_BigBulletBill )
  table.insert( bigBulletBillTable, newBigBill)
  physics.addBody( newBigBill, "static", { radius=55, bounce=0.0,density = 0} )
  newBigBill.myName = "bigbulletbill"
  newBigBill:scale(3,3)
  newBigBill.x = math.random(1000,1500)
  newBigBill.y = math.random(550,590)
  bigBulletBillCount = bigBulletBillCount + 1
  end
end


local function createCoin()  
if(coinCount < 20)then
  local newCoin = display.newSprite( screenGroup,sheet_coin, sequences_CoinSpin )
  newCoin:play()
  table.insert( coinTable, newCoin)
  physics.addBody( newCoin, "static", { radius=20, bounce=0.0,density = 0} )
  newCoin.myName = "coin"
  newCoin.x = math.random(1000,1500)
  newCoin.y = math.random(350,550)
  newCoin.isSensor = true
  coinCount = coinCount + 1
  end
end

local function createDragonCoin()
  
if(dragonCoinCount < 5)then
  local newDragonCoin = display.newSprite( screenGroup,sheet_dragon_coin, sequences_DragonCoinSpin )
  table.insert( dragonCoinTable, newDragonCoin)
  physics.addBody( newDragonCoin, "static", { radius=20, bounce=0.0,density = 0} )
  newDragonCoin.myName = "dragon"
  newDragonCoin.x = math.random(1000,10500)
  newDragonCoin.y = math.random(350,500)
  newDragonCoin.isSensor = true
  dragonCoinCount = dragonCoinCount + 1
  end
end

local function createEnemy()
  
if(goombaCount < 7)then
  goombaCount = goombaCount + 1
  local newGoomba = display.newSprite(screenGroup,sheet_goomba_walk, sequences_GoombaWalk )
  newGoomba:scale(1.4,1.4)
  newGoomba:play()
  table.insert( goombaTable, newGoomba)
  physics.addBody( newGoomba, "static", { radius=20, bounce=0.0,density = 0} )
  newGoomba.isSleepingAllowed = false
  newGoomba.myName = "goomba"
  newGoomba.x = math.random(1000,1500)
  newGoomba.y = 590
  
  end
end

local function createKoopa()
  if(koopaCount < 3 and score > 5000)then

    local newKoopa = display.newSprite(screenGroup, sheet_koopa_walk, sequences_KoopaWalk )
  newKoopa:scale(1.7,1.8)
  newKoopa:play()
  table.insert( koopaTable, newKoopa )
  physics.addBody( newKoopa, "static", { radius=20, bounce=0.0,density = .3} )
  newKoopa.myName = "koopa"
  newKoopa.x = math.random(1000,1500)
  newKoopa.y = 585
  koopaCount = koopaCount + 1
  end
  end

local function createBackground()

  newBush1 = display.newImageRect(screenGroup,"bush.png",250,80)
  newBush1.x = math.random(1500,5500)
	newBush1.y = 582
  
  newBush2 = display.newImageRect(screenGroup,"bush2.png",300,120)
  newBush2.x = math.random(1500,5500)
	newBush2.y = 582
  
  newBush3 = display.newImageRect(screenGroup,"bush.png",400,80)
  newBush3.x = math.random(1500,5500)
	newBush3.y = 582
  
  newBush4 = display.newImageRect(screenGroup,"bush2.png",350,160)
  newBush4.x = math.random(1500,5500)
	newBush4.y = 582
  
  newPlatform = display.newImageRect(screenGroup,"groundPlatformBend.png",600,143)
  newPlatform.x = math.random(1500,5500)
	newPlatform.y = 547
  end
  

local function Jump()

if(player.y > 582 )then
	audio.play( spinSound )
  player:applyLinearImpulse( 0, -55, player.x, player.y )
  player:setSequence( "normalSpin" )
  player:play()
  spinning = true
  running = false
end



end


local function dragPlayer( event )

	local player = event.target
	local phase = event.phase
  

	if ( "began" == phase ) then
		display.currentStage:setFocus( player )
    startTime = event.time

	elseif ( "moved" == phase ) then

elseif ( "ended" == phase or "cancelled" == phase ) then
  if(player.y > 582 )then
		-- Release touch focus on the player
    distance = event.y-event.yStart
    distancex = event.x-event.xStart
    print(distancex.."  ".. globalSpeedMod)
        if(system.getTimer() - startTime > 100 and distancex > 150)then
          if(globalSpeedMod>=0 and globalSpeedMod<=4 )then
        globalSpeedMod = globalSpeedMod + 1
        end
      end
              if(system.getTimer() - startTime > 100 and distancex < -150)then
                if(globalSpeedMod>0 )then
        globalSpeedMod = globalSpeedMod - 1 
end
        end
    if(system.getTimer() - startTime > 100 and distance < -400)then
    
      player:applyLinearImpulse( 0, -75, player.x, player.y )
      audio.play( jumpSound )
      print("High Jump")
        player:setSequence( "normalJumpUp" )
        player:play()
        jumped = true
        running = false
      elseif(system.getTimer() - startTime > 100 and distance < -300)then
          print("Med Jump")

      player:applyLinearImpulse( 0, -65, player.x, player.y )
      audio.play( jumpSound )
        player:setSequence( "normalJumpUp" )
        player:play()
        jumped = true
        running = false
  
      elseif(system.getTimer() - startTime > 100 and distance < -200)then
          print("Low Jump")

      player:applyLinearImpulse( 0, -55, player.x, player.y )
      audio.play( jumpSound )
        player:setSequence( "normalJumpUp" )
        player:play()
        jumped = true
        running = false
      elseif(system.getTimer() - startTime > 100 and distance < -100)then
          print("Tiny Jump")

      player:applyLinearImpulse( 0, -50, player.x, player.y )
      audio.play( jumpSound )
        player:setSequence( "normalJumpUp" )
        player:play()
        jumped = true
        running = false
    end
    end
		display.currentStage:setFocus( nil )
	end

	return true  -- Prevents touch propagation to underlying objects
end

local function enemyLoop()
  
    createEnemy()
    createKoopa()
    createCoin()
    createDragonCoin()
    createOneUp()
    createBulletBill()
    createBigBulletBill()

    for i = #bulletBillTable, 1, -1 do
        local bill = bulletBillTable[i]
        if ( bill.x < -100 or
             bill.y < -100 or
             bill.y > display.contentHeight + 100 )
        then
            display.remove( bill )
            table.remove( bulletBillTable, i )
            bulletBillCount = bulletBillCount - 1
          else
            bill.x = bill.x - 5
        end
end


    for i = #bigBulletBillTable, 1, -1 do
        local bigBill = bigBulletBillTable[i]
        if ( bigBill.x < -100 or
             bigBill.y < -100 or
             bigBill.y > display.contentHeight + 100 )
        then
            display.remove( bigBill )
            table.remove( bigBulletBillTable, i )
            bigBulletBillCount = bigBulletBillCount - 1
          else
            bigBill.x = bigBill.x - 5
        end
end

        for i = #oneUpTable, 1, -1 do
        local oneUp = oneUpTable[i]
        if ( oneUp.x < -100 or
             oneUp.y < -100 or
             oneUp.y > display.contentHeight + 100 )
        then
            display.remove( oneUp )
            table.remove( oneUpTable, i )
            oneUpCount = oneUpCount - 1
          else
            oneUp.x = oneUp.x - 5
        end
end

    
        for i = #dragonCoinTable, 1, -1 do
        local dragon = dragonCoinTable[i]
        if ( dragon.x < -100 or
             dragon.y < -100 or
             dragon.y > display.contentHeight + 100 )
        then
            display.remove( dragon )
            table.remove( dragonCoinTable, i )
            dragonCoinCount = dragonCoinCount - 1
          else
            dragon.x = dragon.x - 5
        end
end

        for i = #coinTable, 1, -1 do
        local coin = coinTable[i]
        if ( coin.x < -100 or
             coin.y < -100 or
             coin.y > display.contentHeight + 100 )
        then
            display.remove( coin )
            table.remove( coinTable, i )
            coinCount = coinCount - 1
          else
            coin.x = coin.x - 5
        end
end
    
    
    for i = #goombaTable, 1, -1 do
        local goomba = goombaTable[i]
        if ( goomba.x < -100 or
             goomba.y < -100 or
             goomba.y > display.contentHeight + 100 )
        then

            display.remove( goomba )

            table.remove( goombaTable, i )
            goombaCount = goombaCount - 1
            print(goombaCount)
          else
            goomba.x = goomba.x - 5
        end
end

    for i = #koopaTable, 1, -1 do
        local koopa = koopaTable[i]
        if ( koopa.x < -100 or
             
             koopa.y < -100 or
             koopa.y > display.contentHeight + 100 )
        then
            display.remove( koopa )
            table.remove( koopaTable, i )
            koopaCount = koopaCount - 1
          else
            koopa.x = koopa.x - 5
        end
end
end


local function gameLoop()

	scrollGround()

  end

local function restoreplayer()
  
  lives = lives - 1
  
  if(lives>0) then
  player.isSensor = false
	player.x = 120
	player.y = 582
  audio.play(musicTrack, { channel=1, loops=-1 } )   

  end
  timer.resume(gameLoopTimer)
  timer.resume(gameLoopTimer3)
  timer.resume(gameLoopTimer2) 
  timer.resume(gameLoopTimer4) 

  player:setSequence("normalRun")
  player:play()
  

              for i = #goombaTable, 1, -1 do
              local goomba = goombaTable[i]
              physics.removeBody(goomba)
               display.remove( goomba )
                table.remove( goombaTable, i )
                goombaCount = goombaCount - 1
              end
              
              for i = #koopaTable, 1, -1 do
              local koopa = koopaTable[i]
               display.remove( koopa )
                table.remove( koopaTable, i )
                koopaCount = koopaCount - 1
              end
              
              for i = #coinTable, 1, -1 do
              local coins = coinTable[i]
               display.remove( coins )
                table.remove( coinTable, i )
                coinCount = coinCount - 1
              end
              
              for i = #dragonCoinTable, 1, -1 do
              local dragon = dragonCoinTable[i]
               display.remove( dragon )
                table.remove( dragonCoinTable, i )
                dragonCoinCount = dragonCoinCount - 1
              end
              
              for i = #bigBulletBillTable, 1, -1 do
              local bigBill = bigBulletBillTable[i]
               display.remove( bigBill )
                table.remove( bigBulletBillTable, i )
                bigBulletBillCount = bigBulletBillCount - 1
              end
              
              for i = #bulletBillTable, 1, -1 do
              local bill = bulletBillTable[i]
               display.remove( bill )
                table.remove( bulletBillTable, i )
                bulletBillCount = bulletBillCount - 1
              end
end


local function onCollision( event )
        local obj1 = event.object1
        local obj2 = event.object2
        
        if (obj1.myName == "player" and obj2.myName == "dragon")then
          
          display.remove( obj2 )
          dragonCoinCount = dragonCoinCount - 1
            audio.play(coinSound)
            coins = coins + 5
            score = score + 1000
              for i = #dragonCoinTable, 1, -1 do
              if ( dragonCoinTable[i] == obj2) then
                table.remove( dragonCoinTable, i )
                break
            end

        end
 end
        
        if (  obj1.myName == "player" and obj2.myName == "coin")then
          
          display.remove( obj2 )
          coinCount = coinCount - 1
            audio.play(coinSound)
            score = score + 500
            coins = coins + 1
              for i = #coinTable, 1, -1 do
              if ( coinTable[i] == obj2) then
                table.remove( coinTable, i )
                break
            end

        end
 end

        if (  obj1.myName == "player" and obj2.myName == "oneup")then
          
          display.remove( obj2 )
          oneUpCount = oneUpCount - 1
            audio.play(livesSound)
            lives = lives + 1
              for i = #oneUpTable, 1, -1 do
              if ( oneUpTable[i] == obj2) then
                table.remove( oneUpTable, i )
                break
            end

        end
 end

         if (  obj1.myName == "player" and obj2.myName == "bulletbill")then
           if(spinning == false and falling == false) then 
          timer.pause(gameLoopTimer)
          timer.pause(gameLoopTimer2)  
          timer.pause(gameLoopTimer4)  
          audio.stop()
          audio.play(deathSound)
          player:setSequence( "normalDeath" )
          player:play()
          display.remove( obj2 )
          bulletBillCount = bulletBillCount - 1

          player:applyLinearImpulse( 0, -45, player.x, player.y )
          player.isSensor = true
        end
        
           if(spinning == true)then
            audio.play( spinningStompSound )
            player:applyLinearImpulse( 0, -75, player.x, player.y )
            player:setSequence( "normalSpin" )
            player:play()
            running = false
            display.remove( obj2 )
            bulletBillCount = bulletBillCount - 1
            score = score + 400

          end
          
          if(falling == true)then
            player:applyLinearImpulse( 0, -100, player.x, player.y )
            audio.play( stompSound )
            player:setSequence( "normalJumpUp" )
            player:play()
            jumped = true
            running = false
            display.remove( obj2 )
            bulletBillCount = bulletBillCount - 1
            score = score + 400

          end
          
           for i = #bulletBillTable, 1, -1 do
              if ( bulletBillTable[i] == obj2) then
                table.remove( bulletBillTable, i )
                break
            end
           end
 end


         if (  obj1.myName == "player" and obj2.myName == "bigbulletbill")then
           if(spinning == false and falling == false) then 
          timer.pause(gameLoopTimer)
          timer.pause(gameLoopTimer2)  
          timer.pause(gameLoopTimer4)  
          audio.stop()
          audio.play(deathSound)
          player:setSequence( "normalDeath" )
          player:play()
          display.remove( obj2 )
          bigBulletBillCount = bigBulletBillCount - 1
          player:applyLinearImpulse( 0, -45, player.x, player.y )
          player.isSensor = true
        end
        
           if(spinning == true)then
            audio.play( spinningStompSound )
            player:applyLinearImpulse( 0, -75, player.x, player.y )
            player:setSequence( "normalSpin" )
            player:play()
            running = false
            display.remove( obj2 )
            bigBulletBillCount = bigBulletBillCount - 1
            score = score + 500

          end
          
          if(falling == true)then
            player:applyLinearImpulse( 0, -100, player.x, player.y )
            audio.play( stompSound )
            player:setSequence( "normalJumpUp" )
            player:play()
            jumped = true
            running = false
            display.remove( obj2 )
            bigBulletBillCount = bigBulletBillCount - 1
            score = score + 500

          end
          
           for i = #bigBulletBillTable, 1, -1 do
              if ( bigBulletBillTable[i] == obj2) then
                table.remove( bigBulletBillTable, i )
                break
            end
           end
 end

         if (  obj1.myName == "player" and obj2.myName == "koopa")then
           if(spinning == false and falling == false) then 
          timer.pause(gameLoopTimer)
          timer.pause(gameLoopTimer2)  
          timer.pause(gameLoopTimer4)  
          audio.stop()
          audio.play(deathSound)
          player:setSequence( "normalDeath" )
          player:play()
          display.remove( obj2 )
          koopaCount = koopaCount - 1
          player:applyLinearImpulse( 0, -45, player.x, player.y )
          player.isSensor = true
        end
        
           if(spinning == true)then
            audio.play( spinningStompSound )
            player:applyLinearImpulse( 0, -75, player.x, player.y )
            player:setSequence( "normalSpin" )
            player:play()
            running = false
            display.remove( obj2 )
            koopaCount = koopaCount - 1
            score = score + 300

          end
          
          if(falling == true)then
            player:applyLinearImpulse( 0, -100, player.x, player.y )
            audio.play( stompSound )
            player:setSequence( "normalJumpUp" )
            player:play()
            jumped = true
            running = false
            display.remove( obj2 )
            koopaCount = koopaCount - 1
            score = score + 300

          end
          
           for i = #koopaTable, 1, -1 do
              if ( koopaTable[i] == obj2) then
                table.remove( koopaTable, i )
                break
            end
           end
 end
 
 
        if (  obj1.myName == "player" and obj2.myName == "goomba")then
        if(spinning == false and falling == false) then
          timer.pause(gameLoopTimer)
          timer.pause(gameLoopTimer2)
          timer.pause(gameLoopTimer4)  
          audio.stop()
          audio.play(deathSound)
          player:setSequence( "normalDeath" )
          player:play()
          display.remove( obj2 )
          goombaCount = goombaCount - 1
          player:applyLinearImpulse( 0, -45, player.x, player.y )
          player.isSensor = true
          end
        
        if(spinning == true)then
            audio.play( spinningStompSound )
            player:applyLinearImpulse( 0, -75, player.x, player.y )
            player:setSequence( "normalSpin" )
            player:play()
            running = false
            display.remove( obj2 )
            goombaCount = goombaCount - 1
            score = score + 200

          end
          
          if(falling == true)then
                player:applyLinearImpulse( 0, -100, player.x, player.y )
            audio.play( stompSound )
            player:setSequence( "normalJumpUp" )
            player:play()
            jumped = true
            running = false
            display.remove( obj2 )
            goombaCount = goombaCount - 1
            score = score + 200
          end
          
            for i = #goombaTable, 1, -1 do
              print("I is equal to: "..i)
             if ( goombaTable[i] == obj2) then
                print("removed: "..i)

                table.remove( goombaTable, i )
                break
            end
        end
    end
end




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

--composer.recycleOnSceneChange = true
 --physics.setDrawMode("hybrid")
  screenGroup = display.newGroup()
	local sceneGroup = self.view
  sceneGroup:insert(screenGroup)
  
  
	-- Load the background
  background3 = display.newImageRect(screenGroup, "backgroundPlains.png", display.contentWidth, display.contentHeight )
	background3.x = 0
	background3.y = display.contentCenterY
  background3.id = "background3"
  
  
  background4 = display.newImageRect( screenGroup, "backgroundPlains.png", display.contentWidth, display.contentHeight )
	background4.x = 1023
	background4.y = display.contentCenterY 
  background4.id = "background3"
  
  background1 = display.newImageRect( screenGroup,"backgroundForest.png", display.contentWidth, display.contentHeight )
	background1.x = 0
	background1.y = display.contentCenterY
  background1.id = "background1"
  
  
  background2 = display.newImageRect( screenGroup, "backgroundForest.png", display.contentWidth, display.contentHeight )
	background2.x = 1023
	background2.y = display.contentCenterY 
  background2.id = "background2"
  
  createBackground()
  
	player = display.newSprite(screenGroup, sheet_mario_run, sequences_MarioRun )
  player:setSequence( "normalRun" )
  player:play()

	player.x = 120
	player.y = 582
  physics.addBody( player, "dynamic", { bounce = 0.0, friction = 0.0, density = 1.0, radius = 35 })
	player.myName = "player"

	-- Display lives and score
	player:addEventListener( "tap", Jump )
	player:addEventListener( "touch", dragPlayer )

	jumpSound = audio.loadSound( "smw_jump.wav" )
  spinSound = audio.loadSound("smw_spin_jump.wav")
  stompSound = audio.loadSound("smw_stomp.wav")
  spinningStompSound = audio.loadSound("smw_yoshi_stomp.wav")
	musicTrack = audio.loadStream( "world1.wav" )
  musicTrack2 = audio.loadSound("SMW2.mp3")
  deathSound = audio.loadSound( "smw_lost_a_life.wav" )
  coinSound = audio.loadSound( "smw_coin.wav" )
  livesSound = audio.loadSound("smw_1-up.wav")
  
  ground1 = display.newImageRect(screenGroup,"ground.png", display.contentWidth, 100)
  ground1.x = 512
  ground1.y = display.contentHeight - 100
  ground1.id = "ground1"
  
  
  physics.addBody( ground1, "static", { bounce = 0.0, friction = 0.0, density = 1.0})
  ground1_image_outline = graphics.newOutline(2, "ground.png", "/" )

  ground2 = display.newImageRect(screenGroup,"ground.png", display.contentWidth, 100)
  ground2.x = 1536
  ground2.y = display.contentHeight - 100
  ground2.id = "ground2"
  
  physics.addBody( ground2, "static", { bounce = 0.0, friction = 0.0, density = 1.0})
  ground2_image_outline = graphics.newOutline(2, "ground.png", "/" )
 
scoreText = display.newText(screenGroup,"score: ", display.contentCenterX+300, display.contentCenterY-270, native.newFont( "Mario-Kart-DS.ttf", 25 ))
livesText = display.newText(screenGroup,"mario x ", display.contentCenterX-450, display.contentCenterY-270, native.newFont( "Mario-Kart-DS.ttf", 25 ))
coinsText = display.newText(screenGroup,"coins: ", display.contentCenterX+150, display.contentCenterY-270, native.newFont( "Mario-Kart-DS.ttf", 25 ))
livesText:setTextColor( 1, 0, 0 )

end




function checkDeath()
  if(player.y > 5000) then
    restoreplayer()
  end

end



function scrollGround()
  
          --if(spinning == false and falling == false  and jumped == false and player.y<582) then
          --timer.pause(gameLoopTimer)
          --timer.pause(gameLoopTimer2)
          --timer.pause(gameLoopTimer4)  
          --audio.stop()
          --audio.play(deathSound)
          --player:setSequence( "normalDeath" )
          --player:play()
          --display.remove( obj2 )
          --goombaCount = goombaCount - 1
          --player:applyLinearImpulse( 0, -45, player.x, player.y )
          --player.isSensor = true
          --end
  
  
  player.x = 120
  player.rotation = 0

if(player.y < 404 and jumped == true)then
  player:setSequence( "normalJumpDown" )
  jumped = false
  falling = true
  elseif(player.y < 448 and jumped == true)then
    player:setSequence( "normalJumpDown" )
  jumped = false
    falling = true

    elseif(player.y < 486 and jumped == true)then
    player:setSequence( "normalJumpDown" )
  jumped = false
    falling = true

    elseif(player.y < 504 and jumped == true)then
    player:setSequence( "normalJumpDown" )
  jumped = false
    falling = true

end

if(spinning == true and player.y > 582)then
  spinning=false
  end

if(running==false and player.y > 582)then
  player:setSequence( "normalRun" )
  player:play()
  falling = false
  running = true
  end

  ground1.x = ground1.x - 5 - globalSpeedMod
  ground2.x = ground2.x - 5 - globalSpeedMod
  
  background1.x = background1.x - 5
  background2.x = background2.x - 5
  background3.x = background3.x - 5
  background4.x = background4.x - 5

  newBush1.x =   newBush1.x - 5- globalSpeedMod
  newBush2.x =   newBush2.x - 5- globalSpeedMod
  newBush3.x =   newBush3.x - 5- globalSpeedMod
  newBush4.x =   newBush4.x - 5- globalSpeedMod
  newPlatform.x = newPlatform.x - 5- globalSpeedMod
  
  
if(newBush1.x < -500)then
    newBush1.x = math.random(1500,5500)
  end
  
  if(newBush2.x < -500)then
    newBush2.x = math.random(1500,5500)
  end
if(newBush3.x < -500)then
    newBush3.x = math.random(1500,5500)
  end
  
  if(newBush4.x < -500)then
    newBush4.x = math.random(1500,5500)
  end
  
  if(newPlatform.x < -500)then
    newPlatform.x = math.random(1500,5500)
    end
  
  
  
  if(background1.x < -500)then
    background1.x = 1537
  end
  
  if(background2.x < -500)then
  background2.x = 1536
  end
  
   if(background3.x < -500)then
    background3.x = 1537
  end
  
  if(background4.x < -500)then
  background4.x = 1536
  end
  
  if(ground1.x < -500)then
    ground1.x = 1537
  end
  
  if(ground2.x < -500)then
  ground2.x = 1536
  end
  
  
      for i = #goombaTable, 1, -1 do
         goomba = goombaTable[i]
         
           goomba.x = goomba.x - 6 - globalSpeedMod
        end
        
              for i = #bulletBillTable, 1, -1 do
         bill = bulletBillTable[i]

           bill.x = bill.x - 11 - globalSpeedMod
        end
        
          for i = #bigBulletBillTable, 1, -1 do
         bigBill = bigBulletBillTable[i]

           bigBill.x = bigBill.x - 10 - globalSpeedMod
        end
        
        
        for i = #koopaTable, 1, -1 do
         koopa = koopaTable[i]

           koopa.x = koopa.x - 8 - globalSpeedMod
        end
        
        for i = #coinTable, 1, -1 do
         coin = coinTable[i]

           coin.x = coin.x - 5 - globalSpeedMod
        end
        
          for i = #dragonCoinTable, 1, -1 do
         dragon = dragonCoinTable[i]

           dragon.x = dragon.x - 5 - globalSpeedMod
        end
        
        for i = #oneUpTable, 1, -1 do
         oneup = oneUpTable[i]

           oneup.x = oneup.x - 5 - globalSpeedMod
        end
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start(true)
		Runtime:addEventListener( "collision", onCollision )
     lives = 5
     score = 0
     coins = 0
		gameLoopTimer = timer.performWithDelay( 1, scrollGround, 0 )
    gameLoopTimer2 = timer.performWithDelay( 1500, enemyLoop, 0 )
    gameLoopTimer3 = timer.performWithDelay(1, checkDeath,0)
    gameLoopTimer4 = timer.performWithDelay(1, updateValues,0)
		-- Start the music
    if(math.random(1,2)==2) then
		audio.play( musicTrack, { channel=1, loops=-1 } )
  else
    		audio.play( musicTrack2, { channel=1, loops=-1 } )
    end
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel(gameLoopTimer)
    timer.cancel(gameLoopTimer2)
    timer.cancel(gameLoopTimer3)
    timer.cancel(gameLoopTimer4)
    



elseif ( phase == "did" ) then
    Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		audio.stop()
		composer.removeScene("game")
	end
end


-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view

      for i = #goombaTable, 1, -1 do
              local goomba = goombaTable[i]
               
               goomba:removeSelf()
               goomba:removeBody()
               goombaTable[i] = nil
                goombaCount = 0
              end
              
              for i = #koopaTable, 1, -1 do
              local koopa = koopaTable[i]
               display.remove( koopa )
                table.remove( koopaTable, i )
                koopaCount = 0
              end
              
              for i = #coinTable, 1, -1 do
              local coins = coinTable[i]
               display.remove( coins )
                table.remove( coinTable, i )
                coinCount = 0
              end
              
              for i = #dragonCoinTable, 1, -1 do
              local dragon = dragonCoinTable[i]
               display.remove( dragon )
                table.remove( dragonCoinTable, i )
                dragonCoinCount = 0
              end
              
              for i = #bigBulletBillTable, 1, -1 do
              local bigBill = bigBulletBillTable[i]
               display.remove( bigBill )
                table.remove( bigBulletBillTable, i )
                bigBulletBillCount = 0
              end
              
              for i = #bulletBillTable, 1, -1 do
              local bill = bulletBillTable[i]
               display.remove( bill )
                table.remove( bulletBillTable, i )
                bulletBillCount = 0
              end

  display.remove(player)
  display.remove(background1)
  display.remove(background2)
  display.remove(background3)
  display.remove(background4)
  display.remove(ground1)
  display.remove(ground2)
   
  display.remove(livesText)
  display.remove(scoreText)
  display.remove(coinsText)
 
  display.remove(newBush1)
  display.remove(newBush2)
  display.remove(newBush3)
  display.remove(newBush4)
  display.remove(newPlatform)
   
	audio.dispose( jumpSound )
	audio.dispose( musicTrack )
  audio.dispose(musicTrack2)
end

local function disposable() 
 
  display.remove(player)
  display.remove(background1)
  display.remove(background2)
  display.remove(background3)
  display.remove(background4)
  display.remove(ground1)
  display.remove(ground2)
   
  display.remove(livesText)
  display.remove(scoreText)
  display.remove(coinsText)
 
  display.remove(newBush1)
  display.remove(newBush2)
  display.remove(newBush3)
  display.remove(newBush4)
  display.remove(newPlatform)
   
	audio.dispose( jumpSound )
	audio.dispose( musicTrack )
  audio.dispose(musicTrack2)

  
  end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
