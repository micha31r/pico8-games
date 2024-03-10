pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	-- game settings
	gravity = 10
	delta = 0.15
	level = 1
	map_x = 0
	map_y = 0
	shake = 0
	death_screen_y = -40
	restart_level = false
	pop_up_delay = 8
	splash_screen = false
	start_screen = true
	end_screen = false
	circle_size = 0
	level_text = {
		"tutorial",
		"beginner friendly!",
		"easy, easy, easy.",
		"ohhhhhh, sharp!",
		"don't stab yourself",
		"lava?!",
		"getting harder :(",
		"bombs!!",
		"where is the exit?",
		"new trap!",
		"toooooooo tight!!",
		"come on :o",
		"why so easy???",
		"snake, sssss...",
		"control is the key.",
		"it's very crowded.",
		"dangerous town hall!",
		"where are the plants?",
		"split from the middle.",
		"is that a tree house?",
		"hot hot hot!!",
		"free fall?!",
		"run for your life!",
		"save the villagers!",
		"what is this???",
		"donkey kong, roaaaa!",
		"buried alive :o",
		"wait a second.",
		"living space.",
		"only ladders?",
		"farewell day :(",
		"journey's end..."
	}
	-- player things
	coin_amount = 0
	coin_change = 0
	npc_died = 0
	npc_died_change = 0
	death = 0
	p_count = 0
	-- npc things
	npc_text = {
		"hello there!",
		"hola.",
		"x grhlshs ?",
		"who are u!",
		"nice to meet you",
		"what is the time?",
		"boots and cats..",
		"bless me!!",
		"you look wonderful",
		"greetings foreigner",
		":d",
		"my name is ...",
		"do you like our village?",
		"caves, caves, caves...",
		"re fwofieiohio? eo h!!",
		"bla bla bla...",
		"bye!!!"
	}
	dialogue_length = 0
	-- coin things
	c_count = 0
	-- lava things
	l_count = 0
	-- spawn object in the first room or level(same thing)
	spawn_obj()
	music(0)
end

-- coin stuff
coin = {} -- for some reason declaring it in the _init function will raise "attempt to index a nil value" error

function coin:make(x,y)
	local coin_property = {
		x = x,
		y = y,
		sp = 17
	}
	add(coin, coin_property)
end

function coin:delete(item)
	del(coin, item)
end

function coin:clear() -- delete every item in list 
	for item in all(coin) do
		del(coin, item)
	end
end

function coin:animate()
	if c_count < 7 then
		c_count += 1
	else
		c_count = 0
		for item in all(coin) do
			if item.sp == 17 then
				item.sp = 18
			else
				item.sp = 17
			end
		end
	end
end

function coin:display()
	for item in all(coin) do
		spr(item.sp, item.x*8, item.y*8)
	end
end

-- exit/door stuff
exit = {} -- for some reason declaring it in the _init function will raise "attempt to index a nil value" error

function exit:make(x,y)
	local exit_property = {
		x = x*8,
		y = y*8,
		sp = 19
	}
	add(exit, exit_property)
end

function exit:delete()
	for item in all(exit) do
		del(exit, item)
	end
end

function exit:clear() -- delete every item in list 
	for item in all(exit) do
		del(exit, item)
	end
end

function exit:animate()
	if count(coin) == 0 then
		for item in all(exit) do
			if item.sp ~= 20 then
				sfx(1) -- door opening sound
				item.sp = 20
			end
		end
	end
end

function exit:display()
	for item in all(exit) do
		spr(item.sp, item.x, item.y)
	end
end

-- npc stuff
npc = {} -- for some reason declaring it in the _init function will raise "attempt to index a nil value" error

function npc:make(x,y,sprite,direction)
	local npc_property = {
		x = x*8,
		y = y*8,
		sp = sprite,
		n_count = 0,
		vel = 2,
		health = 3,
		solid = true,
		min_mov_dist = 8, -- minimum distance npc need to move each time is 5 pixels
		dire = direction -- 0 is right, 1 is left
	}
	add(npc, npc_property)
end

function npc:delete()
	for item in all(npc) do 
		if item.health <= 0 then -- if health is equal or below 0
			if item.solid == true then
				npc_died += 1
				npc_died_change += 1
				item.solid = false -- make npc none solid 
				item.vel = -20  -- make npc jump before falling through the floor
			end
			if item.y > 128 then
				del(npc, item) -- if npc is outside display, remove it
			end
		end
	end
end

function npc:clear() -- delete every item in list 
	for item in all(npc) do
		del(npc, item)
	end
end

function npc:move()
	for item in all(npc) do
		local change_dir = flr(rnd(2))
		if flr(rnd(5)) < 3 then -- stop npc from moving too much
			if item.min_mov_dist > 0 then
				if item.dire == 0 then
					item.x += 1
					if collide(item.x+7, item.y, 0) then
						item.x -= 1
					end
				else
					item.x -= 1
					if collide(item.x, item.y, 0) then
						item.x += 1
					end
				end
				item.min_mov_dist -= 1
			else
				item.min_mov_dist = 8+flr(rnd(5))
				item.dire = change_dir
			end
		else if flr(rnd(10)) == 1 then -- jump for npc
			if grounded(flr(item.x), item.y, 0) or grounded(flr(item.x)+7, item.y, 0) then
				for n=1,15 do
					if collide(item.x+7, item.y-n, 2) then
						item.dire = 0
					else if collide(item.x-7, item.y-n, 2) then
						item.dire = 1
					end
					end
					item.vel = -(rnd(20))
				end
			end
		end
		end
	end
end

function npc:display()
	for item in all(npc) do
		if item.dire == 0 then
			spr(item.sp, item.x, item.y)
		else
			spr(item.sp, item.x, item.y, 1, 1, true)
		end
	end
end

function npc:animate()
	for item in all(npc) do
		if item.n_count < 4 then
			item.n_count += 1
		else
			if item.sp == 22 then -- animation for npc 1
				item.sp = 23
			else if item.sp == 23 then
				item.sp = 22
			end
			end
			if item.sp == 24 then -- animation for npc 2
				item.sp = 25
			else if item.sp == 25 then
				item.sp = 24
			end
			end
			if item.sp == 26 then -- animation for npc 3
				item.sp = 27
			else if item.sp == 27 then
				item.sp = 26
			end
			end
			item.n_count = 0
		end
	end
end

function npc:fall()
	for item in all(npc) do
		item.y += item.vel*delta
		item.vel += gravity*delta
		if item.solid == true then
			if grounded(flr(item.x), item.y, 0) or grounded(flr(item.x)+7, item.y, 0) then
				item.vel = 0
				item.y = flr(flr(item.y)/8)*8
			end
			if roofed(flr(item.x), item.y, 0) or roofed(flr(item.x)+7, item.y, 0) then
				item.vel = 10
				item.y -= 1
			end
		end
	end
end

-- particle stuff
particle = {} -- for some reason declaring it in the _init function will raise "attempt to index a nil value" error

function particle:make(x,y,amount)
	for _=1,amount do
		local particle_property = {
			x = x,
			y = y,
			size = 5,
			life = 1+flr(rnd(6)),
			velx = -1 + rnd(2),
			vely = -1 + rnd(2),
			mass = 0.5 + rnd(2)
		}
		add(particle, particle_property)
	end
end

function particle:move()
	for item in all(particle) do
		if item.size < 0 then
			del(particle, item)
		else
			item.size -= 0.1*item.life
			item.x += item.velx / item.mass * rnd(4)
			item.y += item.vely / item.mass * rnd(4)
		end
	end
end

function particle:display()
	for item in all(particle) do
		local color = flr(rnd(5))
		-- display different colors of circle
		if color == 0 then
			circfill(item.x, item.y, item.size, 2)
		else if color == 1 then
			circfill(item.x, item.y, item.size, 5)
		else if color == 2 then
			circfill(item.x, item.y, item.size, 6)
		else if color == 3 then
			circfill(item.x, item.y, item.size, 7)
		else if color == 4 then
			circfill(item.x, item.y, item.size, 9)
		end
		end
		end
		end
		end
	end
end

-- bomb stuff
bomb = {}

function bomb:make(x,y)
	local bomb_property = {
		x = x,
		y = y,
		delay = 3,
		vel = 2,
		dire = flr(rnd(2)),
		sp = 32
	}
	add(bomb, bomb_property)
end

function bomb:delete(item)
	del(bomb, item)
end

function bomb:explode()
	for item in all(bomb) do
		if item.delay > 0 then
			item.delay -= 0.1
		else
			particle:make(item.x,item.y,50)
			del(bomb, item)
			if shake == 0 then
				shake += 1 -- start shake process
				-- harm all "moving" objects if too close to bomb when detonated
				if abs(player.x-item.x) < 30 and abs(player.y-item.y) < 30 then -- compare distance
					player.health -= 1
				end
				for f_item in all(ftile) do
					f_item.fall = true -- make all the special tiles fall
				end
				for npc_item in all(npc) do
					if abs(npc_item.x-item.x) < 30 and abs(npc_item.y-item.y) < 30 then -- compare distance
						npc_item.health -= 1
					end
				end
				close_to_bomb(item.x,item.y)
				sfx(0) -- exploding sound
			end
		end
	end
end

function bomb:fall()
	for item in all(bomb) do
		item.y += item.vel*delta
		item.vel += gravity*delta
		if grounded(flr(item.x), item.y, 0) or grounded(flr(item.x)+7, item.y, 0) then
			item.vel = 0
			item.y = flr(flr(item.y)/8)*8
		end
	end
end

function bomb:animate()
	for item in all(bomb) do
		if item.sp == 32 then
			item.sp = 33
		else
			item.sp = 32
		end
	end
end

function bomb:display()
	for item in all(bomb) do
		if item.dire == 0 then
			spr(item.sp, item.x, item.y)
		else
			spr(item.sp, item.x, item.y, 1, 1, true)
		end
	end
end

-- falling tile stuff
ftile = {}
replaced_tile = {}
function ftile:make(x,y) -- spawn object using tile pos, not normal pos
	local ftile_property = {
		x = x*8,
		y = y*8,
		vel = 2,
		dire = flr(rnd(2)),
		fall = false,
		sp = 34
	}
	add(ftile, ftile_property)
end

function ftile:fall()
	for item in all(ftile) do
		if item.fall == true then
			item.y += item.vel*delta
			item.vel += gravity*delta
			if grounded(flr(item.x), item.y, 0) or grounded(flr(item.x)+7, item.y, 0) then
				-- save current tile first then replace them
				add(replaced_tile, {x=flr(item.x+map_x*8)/8, y=flr(item.y+map_y*8)/8, tile=mget(flr(item.x+map_x*8)/8, flr(item.y+map_y*8)/8)}) -- keep tract which tile is modified
				mset(flr(item.x+map_x*8)/8, flr(item.y+map_y*8)/8, 34) -- replace the obj with map tiles for collision detecting
				ftile:delete(item) 
			end 
			if collide_with_spr(item.x, item.y, player.x, player.y) then -- if hit player then kill player
				player.health = 0 
			end
			for n_item in all(npc) do
				if collide_with_spr(item.x, item.y, n_item.x, n_item.y) then
					n_item.health = 0 
				end
			end
		end
	end
end

function ftile:delete(item)
	del(ftile, item)
end

function ftile:clear()
	for item in all(ftile) do
		del(ftile, item)
	end
end

function ftile:display()
	for item in all(ftile) do
		spr(item.sp, item.x, item.y)
	end
end

-- obstacles tile stuff
replaced_obstacle = {}

function close_to_bomb(x,y)
	for w=1,20 do
		for h=1,20 do
			if collide(x+w, y+h, 4) then
				add(replaced_obstacle, {x=flr(x+w+map_x*8)/8, y=flr(y+h+map_y*8)/8})
				mset(flr(x+w+map_x*8)/8, flr(y+h+map_y*8)/8, 0)
				sfx(4)
			end
			if collide(x-w, y+h, 4) then
				add(replaced_obstacle, {x=flr(x-w+map_x*8)/8, y=flr(y+h+map_y*8)/8})
				mset(flr(x-w+map_x*8)/8, flr(y+h+map_y*8)/8, 0)
				sfx(4)
			end
			if collide(x+w, y-h, 4) then
				add(replaced_obstacle, {x=flr(x+w+map_x*8)/8, y=flr(y-h+map_y*8)/8})
				mset(flr(x+w+map_x*8)/8, flr(y-h+map_y*8)/8, 0)
				sfx(4)
			end
			if collide(x-w, y-h, 4) then
				add(replaced_obstacle, {x=flr(x-w+map_x*8)/8, y=flr(y-h+map_y*8)/8})
				mset(flr(x-w+map_x*8)/8, flr(y-h+map_y*8)/8, 0)
				sfx(4)
			end
		end
	end
end

-- lava stuff
bubble = {}
function bubble:make(x, y, sp, speed)
	bubble_property = {
		x = x,
		y = y,
		sp = sp,
		speed = speed,
		life_span = 2+flr(rnd(3))
	}
	add(bubble,bubble_property)
end

function bubble:display()
	for item in all(bubble) do
		spr(item.sp, item.x, item.y)
	end
end

function bubble:move()
	for item in all(bubble) do
		if item.life_span > 0 then
			item.y -= item.speed
			item.life_span -= 1
		else
			del(bubble, item)
		end
	end
end

function lava_animate() -- loop throught the current display area to find lava blocks, this way i don't need to create a lava class
	if l_count > 1 then
		for w=0+map_x,15+map_x do -- add map_x so when map change it will not affect anything
			for h=0+map_y,15+map_y do -- add map_y so when map change it will not affect anything
				if mget(w,h) == 39 then -- lava sprite 1
					mset(w,h,40)
				else if mget(w,h) == 40 then
					mset(w,h,39)
				end
				end
				if mget(w,h) == 39 or mget(w,h) == 40 then
					if rnd(2) < 1 then -- control amount of bubble
						bubble:make((w-map_x)*8+rnd(4), (h-map_y)*8+rnd(4), 56, 1+flr(rnd(2))) -- spawn bubbles around lava
					end
				end
				l_count = 0
			end
		end
	else
		l_count += 0.1
	end
end

-- player stuff
player = {}

function player:make(x,y)
	player.x = x*8 -- position
	player.y = y*8
	player.jump = false
	player.vel = 2
	player.health = 3
	player.solid = true
	player.alive = true
	player.sp = 1 -- sprit number
	player.dire = 0 -- direction facing(0 is right)}
	player.coin = 0 -- how many coins player collected
	player.talking = false
	player.bomb = 5
end

function player:draw_player() 
	if player.dire == 0 then
		spr(player.sp, player.x, player.y)
	else
		spr(player.sp, player.x, player.y, 1, 1, true)
	end
end

function player:animate()
	if p_count < 3 then
		p_count += 1
	else
		if player.sp == 1 then
			player.sp = 2
		else
			player.sp = 1
		end
		p_count = 0
	end
end

function player:delete()
	if out_of_display(player.x, player.y) then -- kill player if out of bounds
		player.health = 0
	end
	if player.health <= 0 then -- if health is equal or below 0
		if player.solid == true then
			sfx(5)
			player.solid = false -- make player none solid 
			player.vel = -20  -- make player jump before falling through the floor
			death += 1
		end
		if player.y > 128 then
			player.vel = 0 -- if player is outside display, stop it from falling
			player.alive = false
		end
	end
end

function player:key()
	if player.health > 0 then
		if btn(❎) then
			if collide(player.x+4, player.y, 1) then
				player.vel = 0
				player.y -= 1
				if roofed(flr(player.x), player.y, 0) or roofed(flr(player.x)+7, player.y, 0) then
					player.y += 1
				end
				if collide(player.x+4, player.y, 1) == false then
					player.vel = -20
				end
			else if grounded(player.x, player.y, 0) or grounded(player.x+7, player.y, 0) then
				player.vel = -20
			end
		 end
		end
		if btnp(🅾️) then
			if player.bomb > 0 then
				if count(bomb) == 0 then
					if shake == 0 then
						bomb:make(player.x,player.y)
						player.bomb -= 1
					end
				end
			end
		end
		if btn(➡️) then
			player.dire = 0
			player.x += 1
			player:animate()
			if collide(player.x+7, player.y, 0) then
				player.x -= 1
			end
		end
		if btn(⬅️) then
			player.dire = 1
			player.x -= 1
			player:animate()
			if collide(player.x, player.y, 0) then
				player.x += 1
			end
		end
	end
end

function player:fall()
	player.y += player.vel*delta
	player.vel += gravity*delta
	if player.solid == true then
		if grounded(flr(player.x), player.y, 0) or grounded(flr(player.x)+7, player.y, 0) then
			player.vel = 0
			player.y = flr(flr(player.y)/8)*8
		end
		if roofed(flr(player.x), player.y, 0) or roofed(flr(player.x)+7, player.y, 0) then
			player.vel = 10
			player.y -= 1
		end
	end
end

function player:info()
	for health=1, player.health do -- player's health things
		spr(46, 8+10*health, 4)
	end
	for heart=1, 3 do 
		spr(48, 8+10*heart, 4)
	end
	spr(55, 60, 4) -- bomb things
	print(player.bomb, 72, 6, 7) -- bomb things
	spr(47, 88, 4) -- coins things
	print(coin_amount, 100, 6, 7) -- coins things
end

function player:collect_coin()
	for item in all(coin) do
		if collide_with_spr(player.x, player.y, item.x*8, item.y*8) then
			coin_amount += 1
			coin_change += 1
			coin:delete(item)
			sfx(3) -- coin sound
		end
	end
end

function player:talk_to_npc()
	for item in all(npc) do
		if player.talking == false then
			if collide_with_spr(player.x, player.y, item.x, item.y) then
				print("⬆️", player.x, player.y-8, 2)
				if btnp(⬆️) then
					player.talking = true
					n_text = npc_text[flr(1+rnd(count(npc_text)))] -- pick a random sentence from the npc_text array, add 1 because lua array start at 1 not 0
					dialogue_length = #n_text
					diagolue_counter = 0
				end
			end
		end
		if player.talking == true then
			rectfill(8, 104, 120, 127, 0)
			rect(8, 104, 120, 127, 8)
			print(sub(n_text,1,diagolue_counter), hcenter(n_text),112,7) -- print message in a typeing effect
			print("⬇️", 110, 120, 2)
			if btnp(⬇️) then
				player.talking = false
			end
			diagolue_counter += 0.5 -- change the delay of each character showing up
		end
	end
end

-- intro screen effect
dust = {}

function dust:make(x,y,sp,speed) 
	dust_property = {
		x = x,
		y = y,
		sp = sp,
		speed = speed
	}
	add(dust, dust_property)
end

function dust:display()
	for item in all(dust) do
		spr(item.sp, item.x, item.y)
	end
end

function dust:move()
	for item in all(dust) do
		item.y += -1+flr(rnd(3))
		item.x += item.speed
		if item.x > 127 then
			del(dust, item)
		end
	end
end

-- game menu things
function logo() -- show logo
	if splash_screen then
		-- do something here
	end
end

function begin() -- show intro screen
	if not splash_screen and start_screen then
		if count(dust) < 20 then
			if rnd(5) < 1 then -- slow down tile generation
				dust:make(0,rnd(127),53+flr(rnd(2)),1+rnd(3))
			end
		end
		-- circle animation
		if circle_size < 50 then
			circle_size += 1
		else
			circle_size = 0
		end
		circ(64,64,circle_size,8)
		-- player animation
		if p_count < 3 then
			p_count += 1
			spr(1, 60, 60)
		else	
			p_count = 0
			spr(2, 60, 60)
		end
		spr(9, 60, 68)
		-- display game name
		for n=1, 5 do
			spr(62+2*n, 8+n*16, 20+rnd(2), 2, 2)
		end
		print("press ❎", hcenter("press ❎"), 100, 7)
		print("by michaelr", hcenter("by michael"), 108, 2)
		if btnp(❎) then -- start game if x is pressed
			start_screen = false
			for item in all(dust) do
				del(dust, item)
			end
		end
	end
end

function _end() -- show intro screen
	if not splash_screen and not start_screen and end_screen then
		-- display game name
		for n=1, 5 do
			spr(62+2*n, 8+n*16, 20+rnd(2), 2, 2)
		end
		-- show score
		rectfill(24, 48, 104, 80, 2)
		print("score "..coin_amount+npc_died-death/10, 45, 52, 7) -- print(custom calculated score)
		print("deaths "..death, 31, 62, 7)
		print("villagers died "..npc_died, 31, 72, 7)
		print("congradulations!!", hcenter("congradulations!!"), 100, 7)
		print("thank you for playing", hcenter("thank you for playing"), 108, 2)
		-- player animation
		if p_count < 3 then
			p_count += 1
			spr(1, 31, 50)
		else	
			p_count = 0
			spr(2, 31, 50)
		end
	end
end

function death_screen() -- menu that shows after player had fail a level
	if player.alive == false then
		if death_screen_y <= 40 then
			death_screen_y += 4
		end
		rectfill(8,death_screen_y,120,death_screen_y+36,0) -- display texts
		rect(8,death_screen_y,120,death_screen_y+36,7)
		rect(10,death_screen_y+2,118,death_screen_y+34,8)
		print("try again!", 45, death_screen_y+10,7)
		print("press 🅾️", 47, death_screen_y+20,7)
		if restart_level == false then
			if btnp(🅾️) then -- set restart to true if pressed x
				restart_level = true
				coin_amount -= coin_change -- reset to the the amount at the beginning of current level
				npc_died -= npc_died_change
			end
		else
			if restart_level == true then --  if player is restarting the level
				if death_screen_y < 128 then -- if animation is not finished
					death_screen_y += 4 
				else
					reset_level(true)
				end
			end
		end
	end
end

function level_popup() -- show the title of each level
	if pop_up_delay > 0 then
		local text = level_text[level+map_y/16*8]
		rectfill(0,54,127,72,7)
		print(text,hcenter(text),vcenter(text),0) -- add map_y / 16 because level reset to 1 after it reaches 8
		pop_up_delay -= 0.1
	end
end

-- center texts
function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end
 
function vcenter(s)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61
end
 
-- some other things
function out_of_display(x, y)
	if x < 0 or x > 127 or y < 0 or y > 127 then
		return true
	end
end

function reset_level(spawn)
	restart_level = false -- reset variables and respawn objects
	death_screen_y = -40
	coin_change = 0 -- reset changes
	npc_died_change = 0
	coin:clear()
	npc:clear()
	ftile:clear()
	exit.clear()
	if spawn == true then
		clean_map()
		spawn_obj()
	end
end

function actor_touch_spike()
	if collide(player.x, player.y, 3) or collide(player.x+7, player.y, 3)then
		player.health = 0
	end
	for item in all(npc) do
		if collide(item.x, item.y, 3) or collide(item.x+7, item.y, 3)then
			item.health = 0
		end
	end
end

function new_level()
	if count(coin) == 0 then
		for item in all(exit) do
			if player.health >= 1 then
				if collide_with_spr(player.x, player.y, item.x, item.y) then
					for item in all(bomb) do -- delete bomb so the sand in the next level don't fall
						bomb:delete(item)
					end
					level += 1
					pop_up_delay = 8
					exit:delete()
					reset_level(false)
					spawn_obj()
				end
			end
		end
	end
end

function grounded(x,y,tile) -- add map pos because level changes
	t = mget(flr(x)/8+map_x, flr(y)/8+1+map_y)
	return fget(t, tile)
end

function roofed(x,y,tile) -- add map pos because level changes
	t = mget(flr(x)/8+map_x, flr(y)/8+map_y)
	return fget(t, tile)
end

function collide(x,y,tile) -- add map pos because level changes
	t = mget(flr(x)/8+map_x, flr(y)/8+map_y)
	return fget(t, tile)
end

function clean_map() -- restore original map
	for item in all(replaced_tile) do
		mset(item.x, item.y, item.tile)
		del(replaced_tile, item)
	end
	for item in all(replaced_obstacle) do
		mset(item.x, item.y, 36)
		del(replaced_obstacle, item)
	end
	for item in all(spawn_point) do
		mset(item.x, item.y, item.t)
		del(spawn_point, item)
	end
end

function do_shake() -- shake camera
	local shakex = 8-rnd(16) -- generate random amount of shaking
  	local shakey = 8-rnd(16)
	shakex *= shake -- times by shake
  	shakey *= shake 
	camera(shakex,shakey) -- control camera
	shake = shake*0.95 -- reduce shake
	if shake < 0.05 then -- just set shake to zero if it's too low
		shake = 0
	end
end

spawn_point = {}
function find_spawn_point()
	for w=0+map_x,15+map_x do -- add map_x so when map change it will not affect anything
		for h=0+map_y,15+map_y do -- add map_y so when map change it will not affect anything
			local onscreen_x, onscreen_y = w-map_x, h-map_y -- is related to the normal on screen pos instead of the map pos
			if mget(w,h) == 17 then -- coin
				add(spawn_point, {x=w, y=h, t=17}) -- all saved spawn points are using the pos + map pos because the onscreen pos calculation will change it when spawning and object
				coin:make(onscreen_x, onscreen_y)
				mset(w,h,127)
			end
			if mget(w,h) == 1 then -- player
				add(spawn_point, {x=w, y=h, t=1})
				player:make(onscreen_x, onscreen_y)
				mset(w,h,127)
			end
			if mget(w,h) == 19 then -- door
				add(spawn_point, {x=w, y=h, t=19})
				exit:make(onscreen_x, onscreen_y)
				mset(w,h,127)
			end
			if mget(w,h) == 22 then -- green
				add(spawn_point, {x=w, y=h, t=22})
				npc:make(onscreen_x, onscreen_y,22,0)
				mset(w,h,127)
			end
			if mget(w,h) == 24 then -- purple
				add(spawn_point, {x=w, y=h, t=24})
				npc:make(onscreen_x, onscreen_y,24,0)
				mset(w,h,127)
			end
			if mget(w,h) == 26 then -- small
				add(spawn_point, {x=w, y=h, t=26})
				npc:make(onscreen_x, onscreen_y,26,0)
				mset(w,h,127)
			end
			if mget(w,h) == 34 then -- sand
				add(spawn_point, {x=w, y=h, t=34})
				ftile:make(onscreen_x, onscreen_y)
				mset(w,h,127)
			end
		end
	end
end

function collide_with_spr(x, y, obj_x, obj_y) --  does need to add map position because their location does not change
	x, y, obj_x, obj_y = flr(x), flr(y), obj_x, obj_y
	if (x+8 >= obj_x and x <= obj_x) or (x <= obj_x+8 and x+8 >= obj_x+8) then
		if (y+8 >= obj_y and y <= obj_y) or (y <= obj_y+8 and y+7 >= obj_y+8) then
			return true
		end
	end
end

function spawn_obj()  -- call this function in every new level or room
	if level%9 == 0 then
		map_y += 16
		level = 1
	end
	map_x = 16*(level-1)
	find_spawn_point()
end

function _update() 
	dust:move()
	if not start_screen and not splash_screen and not end_screen then
		if level*map_y/16 == 24 and player.y < 16 then -- trigger end screen if level == 32 and player is at the exit
			end_screen = true
		end
		player:key()
		player:fall()
		player:delete()
		player:collect_coin()
		coin:animate()
		exit:animate()
		npc:move()
		npc:fall()
		npc:animate()
		npc:delete()
		bomb:fall()
		bomb:explode()
		bomb:animate()
		particle:move()
		ftile:fall()
		bubble:move()
		actor_touch_spike()
		lava_animate()
		new_level()
	end
end

function _draw() 
	cls(0)
	logo()
	dust:display()
	begin()
	_end()
	if not start_screen and not splash_screen and not end_screen then
		map(map_x, map_y)
		exit:display()
		npc:display()
		coin:display()
		player:draw_player()
		player:collect_coin()
		player:info()
		bomb:display()
		particle:display()
		ftile:display()
		bubble:display()
		do_shake()
		death_screen()
		level_popup()
		player:talk_to_npc()
	end
end
__gfx__
0000000007777770077777700000111100001000000010000000100011111000111110001dd1111100011dd10000000000000000000000009999494444949999
0000000007eeee7007eeee70010011dd0000d0100d0000010d00000011dd100011dd10001dd1111100011dd10111100000010000010aa0000994444444444990
0070070007e7877007e7877000d11ddd00000000000001100000001011d000d011d1100011111dd10001111110001000010010000009a1100009400000049000
00077000078888707788887000011dd1001001111110111011110000111000001111001011100d110d0111dd1001100000000000000440100000450000540000
0007700077888887788888771000011100000111111dd11111111d00111101000000000d0d100011000011d11111000000110010011450000000055005500000
0070070078888877078888870d001111000011ddd11ddd11dd1dd0001dd110000100000000001000000000110000011101010000010010000000005115000000
00000000077777700777777000001d1100101ddddd11dd11d11dd1001dd11000000d010000000000001000000000010101110000001110000000000110000000
00000000007007000070070000100dd1000011111111111111111100111100100000000000d00001000001000000011000000000000000000000000000000000
99999499000000000000000000949400009455000900004007777770077777700777777007777770000000000000000000000000000000000000000000000000
04994440000000000000000009444440094440500994944007bbbb7007bbbb7007dddd7007dddd70000000000000000000000000000000000000000000000000
00400400000aa000000aa00094010141904410050900004007b7377007b7377007d7177007d71770007777000077770000000000000000000000000000000300
05500550007aa9000007900094010141900110050994444007333370773333700711117077111170007ee700007ee70000000000000000000000000000000030
1100001100aaa4000009400094242441920110050900004077333337733333777711111771111177007e8770077e8700000000000b0000000033000000000bb0
0000000000094000000a400094444441942410050999444073333377073333377111117707111117077888700788887000a0a00003b0000000003b000000000b
000000000000000000000000944444419444100509000040077777700777777007777770077777700788870000788770000a0b003b000000000bb00000000000
00000000000000000000000009999910001115500994444000700700007007000070070000700700007777000077770000030000000000000000300000000000
00000000000000000000100000000000099999900000000066656665000000000000000098989898550000000000005500999940049990000000000000000000
00000000000000000f0000010000000091111114000000006765676500000000000000008989898966600000000007760994499449944990000000000077aaa0
000079000000970000000110000000009111111409000909677067700000000000000000888888886777700000077776009944944949490008800880079999aa
000a0070000700a01110111000700070911111149999999907000700aa00aa0000aa00aa888888886670000000000666000999400499900008888780079444a9
0008800000022000111111f10070007091111114040909090700070099aa99aaaa99aa998282828255000000000000550000400000040000008888000a9444a9
00811800002112001ff11ff1067706779111111409090403000000009999999999999999282828286660000000000766000090000009000000888800079444a9
00811800002112001ff111115676567691111114994b44440000000098989898989898988282828267777000000777760000400000040000000880000aaaaaa9
00088000000220001111111156665666044444400403040400000000898989898989898922222222666000000000066600004000000400000000000000a99990
00000000000000000000000000000000000000000000000000000000000a7a000000000000000000000000000000000000000000000000000000000000000000
77700777055555000555550005555500055555000000000000000000007000900000000000000000000000000000000000000000000000000000000000000000
70077007555005505500555055050550550005500000000000666600088880000000000009994940000000000000000000000000000000000000000000777700
700007075500055055000550555055505505055000066000006666008111180000088000999444440000000000000000000000000000000000000000007ee700
070000705550055055005550550505505500055000066000006666008111180000088000944444410000000000000000000000000000000000000000007e8770
07000070055555000555550005555500055555000000000000666600811118000000000094141111000000000000000000000000000000000000000007788870
00700700000000000000000000000000000000000000000000000000811118000000000000000000000000000000000000000000000000000000000007888700
00077000000000000000000000000000000000000000000000000000088880000000000000000000000000000000000000000000000000000000000000777700
00777777777777000077700000000777000000000000000000007777777777770007777000007777000000000000000000000000000000000000000000000000
00777777777777700077777000077777000000000000000000077777777777770007007000070007000000000000000000000000000000000000000000000000
0077eeeeeeee87770077777700777777000000000000000000777999949444770007007000700070000000000000000000000000000000000000000000000000
0077ee88888888770077a77700777977000000000000000000779999944444770007007007000700000000000000000000000000000000000000000000000000
0077ee77777888770077aa7700779977000000000000000000779997777744770007007070007000000000000000000000000000000000000000000000000000
0077ee77777788770077aa7700779977007777777777777700779977777744770007007700070000000000000000000000000000000000000000000000000000
0077ee77077788770077aa7700779977007777777777777700779477777744770007007000700000000000000000000000000000000000000000000000000000
0077e877007788770077aa77007799770077666d6ddddd7700779444444444770007000007000000000000000000000000000000000000000000000000000000
00778877007788770077aa7700779977007766dddddddd7700774944444444770007000007000000000000000000000000000000000000000000000000000000
00778877077788770077aa7700779977007777777777777700777777777777770007007000700000000000000000000000000000000000000000000000000000
0077e877777788770077aa7777779977007777777777777700777777777777770007007700070000000000000000000000000000000000000000000000000000
0077e877777888770077aa9777799977000000000000000000770000000000000007007070007000000000000000000000000000000000000000000000000000
0077e888888888770077a99999999977000000000000000000770000000000000007007007000700000000000000000000000000000000000000000000000000
007788888888877700777aa999999777000000000000000000770000000000000007007000700070000000000000000000000000000000000000000000000000
00777777777777700007777777777770000000000000000000770000000000000007007000070007000000000000000000000000000000000000000000000000
00777777777777000000777777777700000000000000000000770000000000000007777000007777000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00405050505050505050505050506000004050505050505050505050505060000040222222222250502250225050600000405050505050505050505050506000
00405050222222225050505050506000000000405050505050505050600000000000000000000000000000000000000000405050225050505050225050506000
0030006262626262626262626200700000300062626262620000000000007000003000000000004242000000000070000030000000c000000000000000007000
0030d100000000000000000000007000000000300000000010000000700000000000000000000000000000000000000000300000000000000000000000007000
0030a2004242424242424242c0b27000003000000000000000c000000000700000300011000000424200000000007000003000d00000424242000000d0007000
00300000b00000000000d0000000700000000030000000f0e000000070000000000000000000000000000000000000000030000000d00000b000d00000007000
0030a24242000000b000004242b270000030000000b000000000001100007000003000b0d0000042420000c000f1700000300000004242424242420000007000
00301111d0000000c000000000f1700000000030320000000000003270000000000000402222505050505050600000000030f000000061008100000000e07000
0030a24211c000320051006142b2700000300000000000000000b290a2007000003000000000004242000000d0007000003011004242510011114242c0f17000
0030f00100000000000000b0000070000000003090a200000000b290700000000000003000b000004200000070000000003000b0000000000000006100f17000
0030a242424242904251424242b2700000300000110000005100000000007000003000510000114242110000003170000030f0c0424210001142424200007000
00300000000000000000000000f1700000000030000000000000000070000000000000300000000062000000700000000030d10000c000e0f000000000007000
0030a242000000000051111142b27000003000b290a20000510000b000007000003000000000004242000000a1e0700000300000424242425142004200d07000
0030d10000c051000000d051d00070000000003000000000000000007000000000000030000000c00000b00070000000003000001000000000c0000000e07000
0030a24200b051000032111142b27000003051000000000011000000000070000030d1000000014242010000b000700000300000004200421142000000e07000
0030424211111111000000510000700000000030a2000000000000b2700000000000003042421100515100f1700000000030000000001111a100520011117000
0030a242424251424290424242b27000003051c0000000b290a20000000070000030110000c0424242426151001170000030000000000042514200b000007000
0030104200c200b00000d051d0f170000000003000000000000000007000000000000030104211000000d0007000000000304242904242429090904242427000
0030a242000051c00000000042b2700000301000000000000000001100007000003000000000424242420000000070000030f000d00000421142610061117000
0030f0e0f0e0f0e000000000000070000000003011000032320000117000000000000030e1420000323200317000000000300000003242000000420000007000
c030a242b010000011c0003100b270000030000011000000c000b290a20070000030f000000042111142000000e070000030d100000000425142000000e07000
003000c0c000b00042323200b0d07000000000301100b29090a2001170000000000000a090909090909090908000000000300000b09042d0000042d0b0f17000
0030a242424242424242424242b27000003000b290a2b000000000000000700000301000c00042111142008100007000003000a100c0004200420000b0007000
0000727272727272909090320000700000000030000000000000000070000000000000000000000000000000000000000030d100000042424242b00000007000
0030b032323232323232323232e170000030c030727272727000d2003100700000300000000042111142c1e1000070000030c1c1e1c1420032b03100e1c17000
000092929292929200000030a2317000000000304200000031000042700000000000000000000000000000000000000000303232525242313242c232e1327000
00a0909090909090909090909090800000a0909092929292909090909090800000a0909090909090909090909090800000a09090909090909090909090908000
0000000000000000000000a090908000000000a09090909090909090800000000000000000000000000000000000000000a09090909090909090909090908000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00405050505050505050505050506000004050505050505050505050505060000000000000000000000000000000000000405050502222222250222250226000
00405050505050505050505050506000004050505050222250505050505060000040502250505050505022505050600000000000000000000000000000000000
0030100000d000000000000000007000003000610042000000000000b00070000000000000000000000000000000000000300000000000000000000000007000
003000d00000d00000000000d00070000030d10000000000006200000000700000300000d000d000000000000000700000405050505050605140505050506000
00300000000000003200000000d07000003031000042001100d000000000700000000000405050505050506000000000003000d000d000000000c00000007000
0030004242424200b0000000000070000030310000c00000d011c00000f170000030d100c000000000000010d000700000300062626200e15100006262007000
003042009000420090004200900070000030f0010101010100005100000070000000000030424242424242700000000000300000310000000000000000f17000
0030114200814200000000320031700000304242001100001100000000007000003000000031a10000c000b0001170000030a200004242e05111424200b27000
003011000000110000001100c0f17000003000b00062000001015101010170000000000030d14242c2423170000000000030d100010000005100000000007000
00301142000042000051b29000e070000030424200000000c032c000110070000030000000f0e00000000090001170000030a2000042000051e1004200b27000
003000320000b00000000032000070000030d100005100c0001100000032700000000000304242429042e07000000000003000000000b00000000000b0007000
0030114200b0423232510000000070000030a2000051000051905100510070000030d19000000000b061000000e070000030a2000042d01151f0d042c0b27000
003000900042009000420090004270000030001100000032f042f042f0e070000000000030114242424242700000000000300000000000000000001100007000
0030f0e0f0e0f0e0905100c000f170000030a20000000000000000003200700000300000a1c0000000d051d0000070000030d100c04200a15100814200f17000
003000000011000000110000001170000030f0e0f0e0f00100c00000000070000000000030f04200421111700000000000300000c0000000000000e100007000
003000000042424242004242424270000030a24242420000110000b290a2700000301100000000a10000000000f1700000300000004200e05111004200007000
0030b0420042004200420042004270000030c000110000000000005100007000000000003042421042111170000000000030d100000000001100000100007000
0030d1b00042a10042c04200000070000030d142114200005100d00000f1700000301100d000510000f001e0000070000030a200004200005100004200b27000
003090004200900042009000420070000030f042424201010011115100c0700000000000a090909090909080000000000030d000d0000000c200c00000f17000
0030d0000042001142004200b0117000003000425142c00000320000000070000030f08100005100b08100a1810070000030a200b042d01151f0d04200b27000
0030000011000000510000001100700000300000005100000101015101e07000000000000000000000000000000000000030d100110000000100000000b07000
0030001000909090909042510011700000301042424200003290a2b000f170000030b000610000000000c0000000700000300000004200c15100004200007000
0030d0000000c000000000b00000700000300010000000d000b00000d00070000000000000000000000000000000000000301000110000000000000000007000
00300000000000000000425100b070000030000000000000900000000000700000300000e1004242424242c100c170000030d100004242e051c0424200c07000
0030310032d200003200e1e1320070000030000000320000c10000b0000070000000000000000000000000000000000000300000113232323232323232327000
0030d100b05252e10052425132e1700000300000c152523200c1e1005200700000a090909090907272729090909080000030c1103232d2005100c13232007000
00a0909090909090909090909090800000a090909090909090909090909080000000000000000000000000000000000000a09090909090909090909090908000
00a0909090909090909090909090800000a090909090909090909090909080000000000000000092929200000000000000a09090909090909090909090908000
__gff__
0000000101010101010101000000050505000000800200000000000000000000000001081100080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004050505050505050600000000000000040505050505050505050505050600000000000004050505050505050506000004050505050505050505050505060000040505050505050505050505050600
0000000000000000000000000000000000040505050505050505050505050600000004050505050505050505050506000003000000000000110700000000000000030000000000000000262600000700000000000003000026260c0c00000700000300000026000026000c000000070000030000000c00000000000000000700
00000000000000000000000000000000000300000000000000000000001f070000000300000b0000000000000000070000030d00000b0000000700000000000000030d00000000000c0d000000000700000405050500000000000000000007000003000d000b001111000000000007000003000d0000000000000000001f0700
0000000000000000000000000000000000030000000b00000000000000000700000003110000000000000000000007000003000000000000002b0505050506000003000000000b0000000000001f0700000300260d0000000011000000110700000300000000000f0e000d000000070000030013000011000d15000000000700
000000000000000000000000000000000003110000000000000c0000000007000000031e00000000000b0000001f070000031d0b0000001500000000000007000003001100000000000000000000070000032a130000000000100000000e0700000300000000000000000000001f070000030015000c11000015000b00000700
0000000033000c00000b00000000000000031d00000d000000000000001107000000030f00000000000000000000070000031d000d0000150000000000000700000300100000001e0000000c0000070000031d0000000b0000000000152b07000003000000150d000d00000b001f070000031d00000010000d15000000000700
000000310032000c000000000000000000030f000000000000001600000e070000000300000d150d000000000000070000030000000000000000000d000d070000031d00000000100e00000000110700000300000000000000000b00152b070000031d000000001323000000112b070000030000000000000023000001000700
0000000001001100002c0013000000000003000000000000000b1c000000070000000300000015000b00000000110700000300000010000000110000000007000003000d0c23000000000000001a07000003150000000d2300000000002b07000003000000000f100e000000100007000003000000000b000009000000000700
0000000009090927270909090000000000031d100b000000000f1000001f07000000031d0000111100110000000e070000031115000000000000000013000700000300000010000000001500000e07000003000b00000010001e0000001f07000003002b092a0000000000000000070000030b242424000000000000100e0700
000000000000002929000000000000000003000000111100000000000000070000000300000c090900100000001f070000030f000000010b0000000000180700000300000000000b00001500001f0700000300000f0e000000100000000007000003150000000000000d150d00000700000300241124003400000d0c00000700
0000000000000000000000000000000000030000000f0e00000000000000070000000300000000010d000d00000007000003000000000f0e0000000015000700000300160000000000001500000d07000003010000000000000c000b000007000003150000000000000c1500001f070000030b0010002300001e0023000c0700
000000000000000000000000000000000003000001000000000d000d0000070000000300131c00000000001c002d070000031a000000000000000000151f070000030000000000000100000000000700000300000000251c0c00001e2c0007000003001800000c000000150000000700000a0927272709090909090909090800
0000000000000000000000000000000000031c25001c002c000013002525070000000a09090909090909090909090800000300001c2d00000000001e1500070000030000002525000000001e00130700000a09090909090927272709090908000003010025251c00232c15002300070000000029292900000000000000000000
00000000000000000000000000000000000a090909090909090909090909080000000000000000000000000000000000000a0909090909090909090909090800000a090909090909090909090909080000000000000000002929290000000000000a090909090909090909090909080000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004050505050505050505050505060000042205052222220522052205050600000000000000000000000000000000000004050505222222222205222205060000040505050505050505050505050600000004050505050505050505050505060004222222222222222205050505060000000405220522050505050505060000
0003000024242424000000000c000700000300000000000000000000000007000000000000000000000000000000000000030c000000000000000000000007000003000000000000000d00000000070000000300000000000000000000000007000300000000000000000000000007000000030000000c000000000c00070000
00030d002424242400000d000000070000031d000000000000000000000c070000000000042222050505050600000000000300000000000000000d000b000700000300000b000000000000000b0007000000030d002424242424242424000c07000300000000000b00000000000007000000031d000000111100000000070000
000300002411112400000000001f07000003000b000d000c0000000d0000070000000000030b000000000007000000000003000000000000000000000000070000031d0d00000000111511111111070000000300001111111100001124000007000300000d00000000000d00001f07000000030d000d00000c00000000070000
00031d00240f100e0000000c001f070000031d0000000000000000000000070000000000031d000d00000d0700000000000300000d00230c00000000001f07000003000000000c00111511111111070000000300001111111100151124000007000300000000001e0000000c0000070000000300000000242400001111070000
0003000000000c002415000000000700000300000000000000000000001307000000000003010000111100070000000000030000112b092a0000001300000700000311111111110011151111111107000000030000242424242415242400000700031d00000009090000000000000700000003010b0024000024001111070000
0003000b00000000001500002424070000032424240000001100000024240700000000000300000000001f0700000000000301000900262400000d00000007000003111111111100111511111111070000000300002411110024150b00000d0700031d0b000024240000000b000d07000000031c000024111a1315111f070000
00030000000d000000150024242407000003000b240000001000000c000007000000000003240b0009092b070000000000030c000000002400000015000007000003111111111000000000000f0e07000000031c002411111524000000000007000300000011242411111100000007000000030f00150e0f090f150f0e070000
00030001002400000000002411110700000301002400000000001815001a070000000000032323242c001307000000000003150000000024000b00000000070000030f1111000000000c0d0000000700000003000d24242415242424240000070003010023002424001e000000130700000003000015000b0000150b00070000
00030f00002400002b0900241113070000030f24240000000d00001500000700000000000a0909090909090800000000000300000b1e00240000000016180700000300001101000000000000001f0700000003000000000015000000242a1f0700030f0e0f0e0f0e0f0e0f00000e07000000030d001500000000180000070000
000300000000150000000024240e0700000324242400000000000015000d07000000000000000000000000000000000000030000000e0f0e0f0e101c0000070000030b0015000d0000111111111107000000030c00010000000023232400000700032a111500150015001524242407000000030000150011180010001f070000
00031d000c001500000b0000242407000003111111000b000000000b0000070000000000000000000000000000000000000a0927272727272727270909090800000300001500000000111111111107000000030b0024242424242424242a000700032a00001500150c150015242407000000030016000b10100000001a070000
00032a1c1c00150023001e232323070000031111110025251c2d00151e25070000000000000000000000000000000000000000292929292929292900000000000003251c0025251e0011111311110700000003001e2323232323232323001307000a09092727272727272727272708000000032c001c00251c1e2c0000070000
000a0909090909090909090909090800000a09090909090909090909090908000000000000000000000000000000000000000000000000000000000000000000000a090909090909090909090909080000000a090909090909090909090909080000000029292929292929292929000000000a09090909090909090909080000
__sfx__
0005000030630306302f6302d6302c6302a630336303363033630326302e630296302c6302c6302c6302a6301e6302763025630206301c63017630216302463023630216301e6301a6301763019630156300f630
011400002363511635117003060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e0000186201a6201c6201d6401f6601c6401d6501c630186301a6101c6301d6601f6701c6701f6201c6401d6501f660216601f6301d6301c6201d6201f6501d6601d6401c6301a6101c6301d6401c6401a620
000500001854000040290401c540000400004032040345403704037040370003c0003e0003e0003e0003f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000011070130701a0702007000000260002600026000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001307012670100700e6700d0700a670060700467003070020700107001070095000950009500095001800013000100000a0000700004000037001000000000100000000010000000000c0000200001000
001e0020187300000024730000001e730000001f0341f034000001a0341a03400000000001f0351f0351f035000001d030000001c0351d0351f0301d0351d0351803000000000000c0350c035000000c0301a030
001e0000000001c15000000000000000000000000000000000000000000000000000101200000000000000000000000000000000000015070000000000000000000000c120000000000010070000001f07015070
000f00001c1200000000000000001f120000000000000000101200000000000181241810018124000000000000000000001a1251a122101001a12000000181000000000000000001f12000000000001c12300000
011e00001c02300000000001c02300000000001c02300000000001c02300000000001c02300000000001c02300000000001c02300000000001c02300000000001c023000001c0241c023000001c0241c02300000
001e00001c00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 06070809
