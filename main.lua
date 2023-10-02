local bump = require 'libraries.bump'
local inspect = require 'libraries.inspect'
local gamera = require 'libraries.gamera'
local anim8 = require 'libraries.anim8'

player = {x=50, y=200, w=24, h=24, speed=120}
blocks = {}
transitions = {}
ladders = {}
platforms = {}

roomIndex = 1

ranR,ranG,ranB = math.random(),math.random(),math.random()

cols_len = 0
world = bump.newWorld(32)
roomLevel = 0

playerStatus = {isJump = false, standStill = true, faceLeft = true, onLadder = false}

local cam = gamera.new(0, 0, 768, 768)
local image, animation

function love.load()
	cam:setWindow(0, 0, 768, 768)
	love.window.setMode(768, 768)
	love.graphics.setDefaultFilter('nearest', 'nearest')

	image = love.graphics.newImage('player.png')
	g24 = anim8.newGrid(24, 24, image:getWidth(), image:getHeight())
	g32 = anim8.newGrid(32, 32, image:getWidth(), image:getHeight(), 0, 24)
	animation = anim8.newAnimation(g24('1-2', 1), {3, 0.2})

	player.y_velocity = 0
	player.jump_height = -10
	player.gravity = -20

	world:add(player, player.x, player.y, 24, 24)

	--room1

	--outer walls
	addBlock(0, 0, 32, 224) --left wall
	addBlock(736, 0, 32, 256) -- right wall
	addBlock(0, 224, 672, 32) -- ground
	addBlock(96, 0, 640, 32) -- ceiling

	--few platforms
	addBlock(96, 160, 64, 16)
	addBlock(192, 160, 64, 16)

	addTransition('down',672, 240, 64, 16)

	--addPlatform(32, 140, 32, 8)

	--room2

	addBlock(512, 256, 32, 256) --left wall
	addBlock(736, 256, 32, 256) -- right wall
	addBlock(576, 480, 192, 32) -- ground
	addBlock(544, 256, 128, 32) -- ceiling

	addTransition('down', 544, 496, 32, 16)

	--room3

	addBlock(512, 512, 32, 256)
	addBlock(736, 512, 32, 256)
	addBlock(544, 736, 160, 32)
	addBlock(576, 512, 160, 32)

	addTransition('down', 704, 752, 32, 16)

	--room4

	addBlock(512, 992, 1024, 32)


	addBlock(1408, 880, 64, 16)
	addBlock(1472, 960, 64, 16)
	addBlock(1472, 800, 64, 16)

	addTransition('up', 1472, 736, 64, 16)
	addPlatform(1472, 752, 64, 8)

	--addLadder(1504, 768, 32, 128)

	---room5

	addBlock(1280 , 736, 192, 32)
	addBlock(1280 , 512, 256, 32)
	addBlock(1280 , 544, 32, 192)
	addBlock(1536 , 672, 32, 80)
	addBlock(1440 , 672, 96, 16)

	--room6

	addTransition('right', 1520, 544, 16, 128)
	addTransition('stop', 1552, 544, 16, 128)

	addBlock(1536, 736, 512, 32)
	addBlock(1536 , 512, 512, 32)
	addBlock(1984, 544, 64, 32)
	addBlock(1952, 704, 32, 32)
	addBlock(1984, 672, 32, 64)
	addBlock(2016, 640, 32, 96)


	addTransition('right', 2032, 608, 16, 32)
	addTransition('stop', 2096, 576, 16, 64)
	--room7

	addBlock(2048, 736, 256, 32)
	addBlock(2048, 512, 256, 32)
	addBlock(2272, 544, 32, 192)
	addBlock(2048, 544, 32, 32)
	addBlock(2048, 640, 32, 96)


	cam:setPosition(0, 0)
	cam:setScale(3.0)

	love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
end

function love.update(dt)
	updatePlayer(dt)
	updateCamera(dt)
	animation:update(dt)
end

function updateCamera(dt)
	if roomIndex == 1 then
		cam:setWorld(0, 0, 768, 256)
	elseif roomIndex == 2 then
		cam:setWorld(512, 256, 256, 256)
	elseif roomIndex == 3 then
		cam:setWorld(512, 512, 256, 256)
	elseif roomIndex == 4 then
		cam:setWorld(512, 768, 1024, 256)
	elseif roomIndex == 5 then
		cam:setWorld(1280, 512, 256, 256)
	elseif roomIndex == 6 then
		cam:setWorld(1536, 512, 512, 256)
	elseif roomIndex == 7 then
		cam:setWorld(2048, 512, 256, 256)
	end
	cam:setPosition(player.x, roomLevel)
end	

function love.keyreleased(key)
	if key == 'a' then
		if playerStatus.isJump == false then
			animation = anim8.newAnimation(g24('1-2', 1), {3, 0.2})
		end
		playerStatus.standStill = true
	elseif key == 'd' then
		if playerStatus.isJump == false then
			animation = anim8.newAnimation(g24('1-2', 1), {3, 0.2})
		end
		animation:flipH()
		playerStatus.standStill = true
	elseif key == 'space' then
		playerStatus.standStill = true
	end
end

function updatePlayer(dt)
	local dx = 0

	if cols_len == 0 and playerStatus.isJump == false then
		if playerStatus.onLadder == false then
			player.y_velocity = player.y_velocity - player.gravity * dt
		end
	elseif cols_len == 0 and playerStatus.isJump == true then
		if playerStatus.faceLeft == true then
			animation = anim8.newAnimation(g32('1-1', 1), 0.1)
		elseif playerStatus.faceLeft == false then
			animation = anim8.newAnimation(g32('1-1', 1), 0.1)
			animation:flipH()
		end
	end

	if love.keyboard.isDown('d') then
		dx = player.speed * dt
		playerStatus.faceLeft = false
		if playerStatus.isJump == false and playerStatus.standStill == true then
			animation = anim8.newAnimation(g24('3-5', 1), 0.1)
			animation:flipH()
			playerStatus.standStill = false
		end	
	elseif love.keyboard.isDown('a') then
		dx = - (player.speed * dt)
		playerStatus.faceLeft = true
		if playerStatus.isJump == false and playerStatus.standStill == true then
			animation = anim8.newAnimation(g24('3-5', 1), 0.1)
			playerStatus.standStill = false
		end	
	end

	if love.keyboard.isDown('w') then
		if playerStatus.onLadder == true then
			playerStatus.isJump = false
			player.y_velocity = player.y_velocity - 2
		end
	end	

	if love.keyboard.isDown('space') then
		if player.y_velocity == 0 then
			playerStatus.isJump = true
			playerStatus.standStill = false
			player.y_velocity = player.jump_height
		end
	end

	if player.y_velocity ~= 0 and playerStatus.onLadder == false then
		player.y_velocity = player.y_velocity - player.gravity * dt
	end

	if dx~= 0 or player.y_velocity~=0 then
		local cols
		player.x, player.y, cols, cols_len = world:move(player, player.x + dx, player.y + player.y_velocity * 0.6, playerFilter)
		for i=1, cols_len do
			local col = cols[i]
			--print(inspect(cols[i]))
			if cols[i].other.type == 'solid' then
				if cols[i].normal.y == -1 then
					player.y_velocity = 0
					if playerStatus.isJump == true then
						animation = anim8.newAnimation(g24('1-2', 1), {3, 0.2})
						if playerStatus.faceLeft == false then
							animation:flipH()
						end	
					end
					playerStatus.isJump = false
				elseif cols[i].normal.y == 1 then
					player.y_velocity = 0 - player.gravity * dt
				end
			elseif cols[i].other.type == 'transition' then
				cols[i].other.type = 'ghost'
				if cols[i].other.direction == 'stop' then
					addBlock(cols[i].other.x-48, cols[i].other.y, cols[i].other.w, cols[i].other.y)	
				end
				if cols[i].other.direction == 'down' then
					roomLevel = roomLevel + 256
				elseif cols[i].other.direction == 'up' then
					roomLevel = roomLevel - 256
				end

				if cols[i].other.direction ~= 'stop' then
					roomIndex = roomIndex + 1
				end
				
			elseif cols[i].other.type == 'interact' then
				playerStatus.onLadder = true
			elseif cols[i].other.type == 'oneway' then
				if player.y + player.h < cols[i].other.y then
					cols[i].other.type = 'solid'
				end
			end
		end
	end

	player.onLadder = false
end

function playerFilter(item, other)
	if     other.type == 'transition' then return 'cross'
	elseif other.type == 'ghost' then return 'cross'
	elseif other.type == 'solid' then return 'slide'
	elseif other.type == 'interact' then return 'cross'
	elseif other.type == 'oneway' then return 'cross'
	end
	-- else return nil
end

function drawBlocks()
	for _,block in ipairs(blocks) do
	  drawBox(block, ranR, ranG, ranB)
	end
end

function showTransition()
	for _,transition in ipairs(transitions) do
	  drawBox(transition, 0,1,0)
	end
end

function drawLadders()
	for _,ladder in ipairs(ladders) do
	  drawBox(ladder, 255,255,0)
	end
end


function drawPlatforms()
	for _,platform in ipairs(platforms) do
	  drawBox(platform, 0,255,255)
	end
end


function drawBox(item, r,g,b)
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle('fill', item.x, item.y, item.w, item.h)
end

function addBlock(x,y,w,h)
	local block = {type='solid',x=x,y=y,w=w,h=h}
	blocks[#blocks+1] = block
	world:add(block, x,y,w,h)
end

function addLadder(x,y,w,h)
	local ladder = {type='interact',x=x,y=y,w=w,h=h}
	ladders[#ladders+1] = ladder
	world:add(ladder, x,y,w,h)
end

function addPlatform(x,y,w,h)
	local platform = {type='oneway',x=x,y=y,w=w,h=h}
	platforms[#platforms+1] = platform
	world:add(platform, x,y,w,h)
end

function addTransition(d,x,y,w,h)
	local transition = {type='transition', direction=d,x=x,y=y,w=w,h=h}
	transitions[#transitions+1] = transition
	world:add(transition, x,y,w,h)
end

function drawPlayer()
	love.graphics.setColor(1, 1, 1)

	animation:draw(image, player.x, player.y)
end	

function love.draw()
	cam:draw(function()
		drawBlocks()
		drawLadders()
		drawPlatforms()
		--showTransition()
		drawPlayer()
	end)
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end