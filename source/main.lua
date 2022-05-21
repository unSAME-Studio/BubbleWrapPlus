import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animator"
import "CoreLibs/easing"

local gfx <const> = playdate.graphics

local bubbleNormal = gfx.image.new("sprites/bubble_normal.png")
local bubbleBroken1 = gfx.image.new("sprites/bubble_broke_1.png")
local bubbleBroken2 = gfx.image.new("sprites/bubble_broke_2.png")

local bubbles = {}
local bubblesPopped = {}
local popAnimationList = {}

local popSFX = playdate.sound.sampleplayer.new("sounds/pop.wav")
local resetSFX = playdate.sound.sampleplayer.new("sounds/reset.wav")

function initialize()
    -- set drawmode
    --gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)

    -- spawn a bunch of bubbles
    for x = 1, 12, 1 do
        for y = 1, 7, 1 do
            local bubble = gfx.sprite.new(bubbleNormal)
            
            bubble:moveTo(x * 32 + math.random(-1, 1), y * 32 - 8 + math.random(-1, 1))

            -- if odd row, shift x position
            if y % 2 == 1 then
                bubble:moveBy(-16, 0)
            end

            bubble:add()
            --bubbles[ ((x - 1) * 7) + (y - 1) + 1 ] = bubble
            table.insert(bubbles, bubble)
        end
    end

    -- invert display
    -- playdate.display.setInverted(true)

    -- add background
    local backgroundImage = gfx.image.new( "sprites/bg" )
    assert( backgroundImage )

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            backgroundImage:draw( 0, 0 )
        end
    )
end

initialize()

function playdate:update()
    gfx.sprite.update()

    -- update animations
    for i, animation in pairs(popAnimationList) do
        print("query animation " .. i)

        if not animation:ended() then
            local bubble = bubblesPopped[i]

            if bubble ~= nil then 
                bubble:setScale(animation:currentValue())
            else
                -- cancel animation
                popAnimationList[i] = nil
            end
        else
            popAnimationList[i] = nil
        end
    end
end

function popBubble()
    -- if there are no bubbles left, do nothing
    if #bubbles == 0 then
        return
    end

    -- get a random bubble
    local index = math.random(1, #bubbles)
    local bubble = table.remove(bubbles, index)

    -- set a random sprite
    if math.random(0, 1) == 1 then
        bubble:setImage(bubbleBroken1)
    else
        bubble:setImage(bubbleBroken2)
    end

    --bubble:setRotation(math.random(0, 3) * 90)

    -- set a random flipping
    local flipOptions = {"flipX", "flipY", "flipXY"}
    bubble:setImageFlip(flipOptions[math.random(1, 3)])

    table.insert(bubblesPopped, bubble)

    -- play a sound
    local volume = math.random(5, 10) / 10
    popSFX:setVolume((1 - (bubble.x / 400)) * volume, bubble.x / 400 * volume)
    popSFX:setRate(math.random(8, 11) / 10)
    popSFX:play()

    -- play animation
    --local anim = gfx.animator.new(500, 0.8, 1)
    local anim = gfx.animator.new(200, 1.3, 1, playdate.easingFunctions.outBounce)
    anim.s = 1.9
    popAnimationList[#bubblesPopped] = anim
end

function resetBubble()
    -- if there are no bubbles left, do nothing
    if #bubblesPopped == 0 then
        return
    end

    -- get the last popped bubble
    local bubble = table.remove(bubblesPopped, #bubblesPopped)

    bubble:setImage(bubbleNormal)
    bubble:setRotation(0)

    table.insert(bubbles, bubble)

    -- play a sound
    local volume = math.random(5, 10) / 10
    resetSFX:setVolume((1 - (bubble.x / 400)) * volume, bubble.x / 400 * volume)
    resetSFX:setRate(math.random(8, 11) / 10)
    resetSFX:play()
end

function playdate.cranked(change, acceleratedChange)
    if change > 10 then
        resetBubble()
    end
     
    -- move bubbles up
    -- for i, bubble in pairs(bubbles) do
    --     bubble:moveBy(0, math.min(-change / 2, 10))
    -- end
end

function playdate.crankDocked()
    
end

function playdate.AButtonDown()
    popBubble()
end

function playdate.BButtonDown()
    popBubble()
end

function playdate.downButtonDown()
    popBubble()
end

function playdate.upButtonDown()
    popBubble()
end

function playdate.leftButtonDown()
    popBubble()
end

function playdate.rightButtonDown()
    popBubble()
end
