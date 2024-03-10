pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--------------
--game
--------------
cartdata("dshift")

function load_data(data_num)
	local data = dget(data_num)
	if data ~= 0 then
		return data
	end
end

function save_game()
	-- player 
	dset(0, player.x)
	dset(1, player.y)
	dset(2, player.health)
	dset(3, player.air)
	dset(4, player.check_point.x)
	dset(5, player.check_point.y)
	dset(7, player.inventory.bug) -- inventory
	dset(8, player.inventory.antivirus) -- inventory
	dset(9, player.inventory.key+player.system_fixed) -- inventory
	-- game things
	dset(10, game_hardness)
end

function reset_game()
	for _=0, 63 do
		dset(_, 0)
	end
end

function _init()
	game_effect=true
	gravity=10
	delta=0.15
	shake=0
	bg_color=1
	camera_x, camera_y=0, 0
	mode=1
	game_hardness=load_data(10) or 4
	game_hardness_timer=50
	transit_progress=0
	transit_speed=3
	transit_back=false
	transit_to=nil
	do_transit=false
	cloud_timer=5
	water_ani_timer=1
	lightning_pause_timer = 10
	do_lightning_timer = 0
	bolt_timer=1
	cursor_x=16
	cursor_y=36
	mountain_x=camera_x
	--------------Text things
	typed_text = {
		intro = {{content="loading...", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=7},
			{content="virus found!!", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=7},
			{content="error 0X08273", index=0,timer=0,timer_reset=0,delay=3,finish=false,color=13},
			{content="(system failure)", index=0,timer=0,timer_reset=0,delay=2,finish=false,color=7},
			{content="  :O ", index=0,timer=1,timer_reset=1,delay=1,finish=false,color=13},
			{content="" ,index=0,timer=2,timer_reset=2,delay=1,finish=false,color=7},
			{content="preparing transmission..", index=0,timer=0,timer_reset=0,delay=3,finish=false,color=7},
			{content="bypassing error", index=0,timer=0,timer_reset=0,delay=2,finish=false,color=13},
			{content="", index=0,timer=2,timer_reset=2,	delay=1,finish=false,color=7},
			{content="{", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=7},
			{content="   press x", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=15},
			{content="}", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=7,last=true},
		},
		ending = {
			{content="...", index=0,timer=2,timer_reset=2,delay=0,finish=false,color=7,},
			{content="well done", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=7,},
			{content=":D", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=13,},
			{content="", index=0,timer=2,timer_reset=2,delay=1,finish=false,color=7,},
			{content="virus has been terminated!!", index=0,timer=0,timer_reset=0,delay=2,finish=false,color=7,},
			{content="(system working)", index=0,timer=0,timer_reset=0,delay=2,finish=false,color=7,},
			{content="0X129304", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=13,},
			{content="0X385934", index=0,timer=0,timer_reset=0,delay=1,finish=false,color=13,},
			{content="{", index=0,timer=1,timer_reset=1,delay=1,finish=false,color=13,},
			{content="    shutting down..", index=0,timer=0,timer_reset=0,	delay=1,finish=false,color=7,},
			{content="    ~ bye ~", index=0,timer=1,timer_reset=1,	delay=2,finish=false,color=7,},
			{content="}", index=0,timer=0,timer_reset=0,	delay=1,finish=false,color=13,last=true},
		}
	}
	text_cursor_x, text_cursor_y=0, 0
	_introValue=false
	_blinkingCursorTimer=1
	_blinkingCursor="on"
	_doGlitch=false
	_glitchTimer=3
	_bigPortalSoundTimer=0
	_endTimer=1

	weather=0 -- 1 is night, 2 is lightning
	lightning_palatte1={{2,13},{13,5},{4,9},{7,0}}
	lightning_palatte2={{2,7},{13,6},{9,15},{7,0}}
	dark_palatte={{6,5},{13,1},{7,0}}

	function change_inventory_menu() 
		if not player.view_inventory then
			player.view_inventory=true 
			menuitem(1, "close inventory", change_inventory_menu) 
		else
			player.view_inventory=false
			menuitem(1, "open inventory", change_inventory_menu) 
		end	
		sfx(9)
	end

	menuitem(1, "open inventory", change_inventory_menu)
	menuitem(2, "-> save game <-", save_game)
	menuitem(3, "disable effects", function() game_effect=false end)
	menuitem(4, "enable effects", function() game_effect=true end)
	menuitem(5, "! delete save !", reset_game)

	water:find()
	loseTile:make()
	portal:make()
	player:make(50*8,33*8)
	enemy:find_spawn_point()
end

function intro_screen()
	rect(0,0,127,127,13)
	rect(1,1,126,126,13)
	type("intro",1,12,5,-4)
	if _introValue then
		if _blinkingCursorTimer > 0 then
			_blinkingCursorTimer -= 0.1
		else
			if _blinkingCursor == "on" then
				_blinkingCursor = "off"
			else
				_blinkingCursor = "on"
			end
			_blinkingCursorTimer = 1
		end
		if _blinkingCursor == "on" then
			rectfill(15,104,50,111,7)
		end
		if btnp(❎) then
			if not _doGlitch then
				_doGlitch = true
				sfx(2)
			end
		end
		if _doGlitch then
			if _glitchTimer > 0 then
				_glitchTimer -= 0.1
				glitch()
			else
				mode = 2
				bg_color = 7
				_doGlitch = false
				_glitchTimer = 3
				music(0,300)
			end
		end
	else
		spr(115, text_cursor_x, text_cursor_y)
	end
end

function end_screen()
	rect(0+camera_x,0+camera_y,127+camera_x,127+camera_y,13)
	rect(1+camera_x,1+camera_y,126+camera_x,126+camera_y,13)
	if _endTimer > 0 then
		_endTimer -= 0.1
	else
		if _doGlitch then
			if _glitchTimer > 0 then
				_glitchTimer -= 0.1
				glitch()
			else
				_doGlitch = false
				-- do not reset glitch timer!
			end
		else
			if _glitchTimer == 3 then
				_doGlitch = true
				sfx(2)
			end
			type("ending",1,12,5+camera_x,-4+camera_y)
		end
	end
	spr(115, text_cursor_x, text_cursor_y)
end

function _update()
	if mode == 2 then
		if not player.view_inventory then
			cloud:make()
			cloud:update()
			bubble:make()
			if game_effect then 
				if weather == 0 then
					snow:make()
					snow:update()
				else
					rain:make()
					rain:update()
				end
			end
			enemy:make()
			player:update()
			player:fall()
			blockPowerUp:update()
			enemy:update()
			trail:update()
			bullet:update()
			rectangle:update()
			bubble:update()
			portal:update()
			specialItem:update()
			spark:update()
			particle:update()
			matrix:update()
			bug:update()
			if game_effect then water:update() end
			do_shake()
			reset_game_hardness()
			center_camera()
			camera(camera_x, camera_y)
		end
	end
end

function _draw()
	cls(bg_color)
	if mode == 1 then
		intro_screen()
	else if mode == 2 then
		lightning:update()
		set_pal(weather)
		draw_mountain()
		matrix:draw()
		cloud:draw()
		map(0,0,0,0,128,128)
		loseTile:draw()
		player:draw()
		enemy:draw()
		trail:draw()
		bullet:draw()
		specialItem:draw()
		rectangle:draw()
		blockPowerUp:draw()
		bug:draw()
		particle:draw()
		spark:draw()
		if game_effect then if weather == 0 then snow:draw() else rain:draw() end end
		bubble:draw()
		set_pal(0)
		player:draw_status()
		set_pal(weather)
		if player.view_inventory then
			set_pal(0)
			player:draw_inventory()
			set_pal(weather)
		end
	else
		pal()
		end_screen()
	end
	end
	pal()
	transit()
end

-->8
--------------
--actors
--------------

-- player
player={}
function player:make(x,y)
	self.x=load_data(0) or x
	self.y=load_data(1) or y
	self.speed=2
	self.vel=0
	self.solid=true
	self.max_frame=2
	self.current_frame=0
	self.ani_delay=1
	self.dir=1 -- 1=left, 2=right
	self.health=load_data(2) or 20
	self.health_regen_timer=20
	self.alive=true
	self.spr_map={1,1}
	self.on_ground=false
	self.in_water=false
	self.air=load_data(3) or 10 -- how many oxygen is left when submerged in water
	self.air_use_timer=2
	self.air_regen_timer=5
	self.shoot_timer=0.5 -- control shooting speed
	self.portal_type=nil -- 1 is normal, 2 is special, 0 is respawn
	self.jump_high=false
	self.jump_high_timer=30
	self.check_point={x=load_data(4) or 50, y=load_data(5) or 34}
	self.view_inventory=false
	self.system_fixed=0
	self.final_teleport_timer=15
	self.idle=false
	self.inventory={
		bug=load_data(7) or 0,
		antivirus=load_data(8) or 0,
		key=load_data(9) or 0
	}
end

function player:update()
	if not self.idle then
		if btn(🅾️) then
			if not self.in_water then
				if self.on_ground then
					if self.jump_high then
						self.vel = -40
					else
						self.vel = -20
					end
				end
			else
				self.vel = -5
			end
		end
		if btn(⬅️) then
			self.x -= self.speed
			if self.on_ground then
				trail:make(self.x+7,self.y+7)
			end
			if collide(self.x,self.y,0) or border_collide(self.x,self.y) then
				self.x += self.speed
				camera_x += self.speed
			else
				mountain_x += 0.2
			end
			self.dir = 1
			self.ani_delay += 1
		end
		if btn(➡️) then
			self.x += self.speed
			if self.on_ground then
				trail:make(self.x,self.y+7)
			end
			if collide(self.x,self.y,0) or border_collide(self.x,self.y) then
				self.x -= self.speed
				camera_x -= self.speed
			else
				mountain_x -= 0.2
			end
			self.dir = 2
			self.ani_delay += 1
		end
	end
	if btnp(❎) then
		if self.shoot_timer < 0 then
			bullet:make(self.x, self.y, self.dir, "enemy")
			self.shoot_timer = 0.5
			sfx(1)
		end
	end
	if btnp(⬇️) then -- teleportation
		if collide(player.x, player.y, 2) or collide(player.x, player.y, 4) then
			local a, b
			if collide(player.x, player.y, 2) then
				self.portal_type = 1 
				a = true
			else
				if self.system_fixed >= 5 then
					self.portal_type = 2
					b = true
				end
			end
			if a or b then
				if not do_transit then
					sfx(6)
				end
				do_transit = true
				particle:make(self.x, self.y, 10+flr(rnd(10)), 2)
				shake = 1
			end
		end
		if collide(player.x, player.y, 6) then -- fix the system
			if self.inventory.key >= 1 then
				for w=-2,2 do
					for h=-2,2 do
						local x, y = flr(self.x/8)+w, flr(self.y/8)+h
						if fget(mget(x, y), 6) then 
							mset(x, y, 90) 
						else if mget(x, y) == 103 then 
							mset(x, y, 91) 
						else if mget(x, y) == 104 then 
							mset(x, y, 92) 
						else if mget(x, y) == 105 then 
							mset(x, y, 93) 
						else if mget(x, y) == 106 then 
							mset(x, y, 94) 
						else if mget(x, y) == 107 then 
							mset(x, y, 95) 
						end
						end
						end
						end
						end
						end
					end
				end
				self.inventory.key -= 1
				self.system_fixed += 1
				shake = 1
				spark:make(self.x, self.y, 20+flr(rnd(20)))
			end
		end
	end
	-- if player is on ground
	if fget(mget(flr(self.x/8), flr(self.y/8)+1), 0) then
		if not self.on_ground then
			sfx(11)
		end
		self.on_ground = true
	else
		self.on_ground = false
	end
	if fget(mget(flr(self.x/8), flr(self.y/8)+1), 1) or fget(mget(flr(self.x/8), flr(self.y/8)), 1) then
		self.in_water = true
		if self.air_use_timer < 0 then
			self.air -= 1
			 self.air_use_timer = 2
		else
			 self.air_use_timer -= 0.1
		end
	else
		self.in_water = false
	end
	-- set check point
	if collide(self.x, self.y, 5) then
		for w=-1,1 do
			for h=-1,1 do
				local x, y = flr(self.x/8)+w, flr(self.y/8)+h
				if fget(mget(x, y), 5) then 
					if self.check_point.x ~= 0 and self.check_point.x ~= 0 then
						mset(self.check_point.x, self.check_point.y, 88) -- change the tile of old check point
					end
					self.check_point.x, self.check_point.y = x, y
					mset(x, y, 89)
					break
				end
			end
		end
	end
	-- collision between with the big portal
	if collide(self.x, self.y, 7) then
		self.vel = 0
		if not self.idle then
			music(-1, 300)
			sfx(6)
		end
		if _bigPortalSoundTimer > 0 then
			_bigPortalSoundTimer -= 0.1
		else
			_bigPortalSoundTimer = 6
			sfx(10)
		end
		if self.final_teleport_timer > 0 then
			self.idle = true
			shake = 1
			particle:make(self.x, self.y, 5+flr(rnd(10)), 9)
			spark:make(self.x, self.y, 10+flr(rnd(10)))
			self.final_teleport_timer -= 0.1
		else
			do_transit = true
		end
	end
	if self.health <= 0 or self.air <= 0 then
		if not do_transit then
			sfx(7)
		end
		do_transit = true
		self.portal_type = 0
	end 
	if self.health_regen_timer < 0 then
		if self.health < 20 then
			self.health += 1
		end
		self.health_regen_timer = 20
	else
		self.health_regen_timer -= 0.1
	end
	if self.air_regen_timer < 0 then
		if self.air < 10 then
			self.air += 1
		end
		self.air_regen_timer = 5
	else
		if not self.in_water then
			self.air_regen_timer -= 0.1
		end
	end
	if self.jump_high then
		if self.jump_high_timer < 0 then
			self.jump_high = false
			self.jump_high_timer = 30
		else
			self.jump_high_timer -= 0.1
		end
	end
	self.health_regen_timer -= 0.1
	self.shoot_timer -= 0.1
end

function player:fall()
	local movement = self.vel*delta
	self.y += movement
	if self.vel < 50 then
		self.vel += gravity*delta
	end
	if self.solid == true then
		if movement >= 0 then
			if collide(self.x,self.y,0) or border_collide(self.x,self.y) then
				self.vel = 0
				self.y = flr(flr(self.y)/8)*8
			end
			if collide(self.x,self.y,1) then
				self.vel = 5
			end
		end
		if movement < 0 then
			-- if collided with tiles at the top
			if collide(self.x,self.y,0) or border_collide(self.x,self.y) then
				self.vel = 0
				self.y = (flr(flr(self.y)/8)+1)*8
			end
		end
	end
	if player.y > 63*8 then
		player.health = 0
		player.vel = 0 
	end
end

function player:draw()
	if self.ani_delay >= 4 then
		if self.current_frame < self.max_frame then
			self.current_frame += 1
		else
			self.current_frame = 0
		end
		self.ani_delay = 0
	end
	if self.dir == 1 then
		spr(self.spr_map[self.dir]+self.current_frame, self.x, self.y, 1, 1, 1)
	else 
		spr(self.spr_map[self.dir]+self.current_frame, self.x, self.y)
	end
	spr(20, self.x, self.y-6) -- mark out player
	print("PL", self.x+1, self.y-11, 2)
end

function player:draw_inventory()
	rectfill(8+camera_x,8+camera_y,88+camera_x,120+camera_y,2)
	rect(9+camera_x,9+camera_y,87+camera_x,119+camera_y,7)
	print("--inventory--",22+camera_x, 16+camera_y, 7)
	spr(114, cursor_x+camera_x, cursor_y+camera_y)
	print("bugs:"..self.inventory.bug, 30+camera_x, 28+camera_y, 7)
	print("antivirus:"..self.inventory.antivirus, 30+camera_x, 38+camera_y, 7)
	print("key:"..self.inventory.key, 30+camera_x, 48+camera_y, 7)
	print("----guide----",22+camera_x, 60+camera_y, 7)
	print("cOLLECT BUGS!", 15+camera_x, 70+camera_y, 7)
	print("cREATE ANTIVIRUS!", 15+camera_x, 77+camera_y, 7)
	print("cREATE KEYS!", 15+camera_x, 84+camera_y, 7)
	print("fIX THE SYSTEM!", 15+camera_x, 91+camera_y, 7)
	print("ANTIVIRUS=10 BUGS", 15+camera_x, 101+camera_y, 7)
	print("kEYS=2 ANTIVIRUS", 15+camera_x, 107+camera_y, 7)
	if btnp(⬆️) then
		if cursor_y ~= 36 then
			cursor_y -= 10
		end
	end
	if btnp(⬇️) then
		if cursor_y ~= 46 then
			cursor_y += 10
		end
	end
	if btnp(➡️) then
		if cursor_y == 36 then
			if self.inventory.bug >= 10 then
				self.inventory.antivirus += 1
				self.inventory.bug -= 10
			end
		else if cursor_y == 46 then
			if self.inventory.antivirus >= 2 then
				self.inventory.key += 1
				self.inventory.antivirus -= 2
			end
		end
		end
	end
end

function player:draw_status()
	-- health bar
	spr(46, 8+camera_x, 115+camera_y)
	rect(16+camera_x, 118+camera_y, 16+self.health*2+camera_x, 120+camera_y, 14) 
	line(16+camera_x+1, 119+camera_y, 16+self.health*2-1+camera_x, 119+camera_y, 7)
	line(16+camera_x, 121+camera_y, 16+self.health*2+camera_x, 121+camera_y, 2)
	-- air bar
	spr(47, 80+camera_x, 115+camera_y)
	rectfill(88+camera_x, 118+camera_y, 88+self.air*2+camera_x, 120+camera_y, 13)
	line(88+camera_x+1, 119+camera_y, 88+self.air*2-1+camera_x, 119+camera_y, 7)
	line(88+camera_x, 121+camera_y, 88+self.air*2+camera_x, 121+camera_y, 2)
end

enemy={}
enemy_spawn_point={}
function enemy:make()
	if count(enemy) < 50 then
		local rnd_location = enemy_spawn_point[flr(rnd(count(enemy_spawn_point)))+1]
		if abs(rnd_location.x-player.x) > 70 or abs(rnd_location.y-player.y) > 70 then
			local property = {
				x=rnd_location.x,
				y=rnd_location.y,
				speed=0.5+rnd(1),
				vel=0,
				solid=true,
				max_frame=3,
				current_frame=0,
				ani_delay=1,
				dir=1, -- 1=left, 2=right
				health=4,
				label=1+flr(rnd(2)), -- what kind of enemy it is
				alive=true,
				spr_map={{4,4},{8,8}}, -- access spr_map through spr_map(label)
				sleep=true,
				on_ground=false,
				in_water=false,
				air_timer=2,
				attack_timer=2,
				idle=false,
				idle_timer=2
			}
			add(enemy, property)
		end
	end
end

function enemy:find_spawn_point()
	for w=0, 100 do
		for h=0, 63 do
			if fget(mget(w,h),0) then
				if not fget(mget(w,h-1),0) and not fget(mget(w,h-1),1) then
					add(enemy_spawn_point, {x=w*8, y=(h-1)*8})
				end
			end
		end
	end
end

function enemy:update()
	for item in all(enemy) do
		if item.x-64 < player.x and item.x+64 > player.x then -- if player is close to enemy
			if item.y-64 < player.y and item.y+64 > player.y then
				item.sleep = false
			else 
				item.sleep = true
			end
		else 
			item.sleep = true
		end
		if flr(rnd(30)) == 0 then
			if not item.idle then
				item.idle = true
			end
		end
		if item.idle then
			if item.idle_timer < 0 then
				item.idle = false
				item.idle_timer = 2
			end
		end
		if not item.idle then
			if not item.sleep then
				if item.x <= player.x then
					item.x += item.speed
					item.ani_delay += 1
					item.dir = 2
					if collide(item.x,item.y,0) or border_collide(item.x,item.y) then
						item.x -= item.speed
						if not item.in_water then
							if item.on_ground then
								item.vel -= 10 -- make enemy jump 
							end
						end
					end
				end
				if item.x > player.x then
					item.x -= item.speed
					item.ani_delay += 1
					item.dir = 1
					if collide(item.x,item.y,0) or border_collide(item.x,item.y) then
						item.x += item.speed
						if not item.in_water then
							if item.on_ground then
								item.vel -= 10 -- make enemy jump 
							end
						end
					end
				end
			end
		else
			item.idle_timer -= 0.1
		end
		-- if enemy is on ground
		if fget(mget(flr(item.x/8), flr(item.y/8)+1), 0) then
			item.on_ground = true
		else
			item.on_ground = false
		end
		-- if enemy is in water
		if fget(mget(flr(item.x/8), flr(item.y/8)), 1) then
			item.in_water = true
			item.air_timer -= 0.1
		else
			item.in_water = false
		end
		-- make enemy fall
		local movement = item.vel*delta
		item.y += movement
		if item.vel < 50 then
			item.vel += gravity*delta
		end
		if item.solid == true then
			if movement >= 0 then
				if collide(item.x,item.y,0) or border_collide(item.x,item.y) then
					item.vel = 0
					item.y = flr(flr(item.y)/8)*8
				end
				if collide(item.x,item.y,1) then
					item.vel = 5
				end
			end
			if movement < 0 then
				-- if collided with tiles at the top
				if collide(item.x,item.y,0) or border_collide(item.x,item.y) then
					item.vel = 0
					item.y = (flr(flr(item.y)/8)+1)*8
				end
			end
		end
		if item.in_water then
			if item.air_timer < 0 then
				item.health -= 1
				item.air_timer = 2
			end
		end
		--collision with player
		if spr_collide(item.x, item.y, player.x, player.y) then
			if item.attack_timer < 0 then	
				player.health -= 1
				item.attack_timer = 2
			end
		end
		if item.label == 2 then
			if item.attack_timer < 0 then	
				if abs(player.y - item.y) <= 10 then
					if abs(player.x - item.x) < 64 then
						bullet:make(item.x, item.y, item.dir, "player")
						sfx(5)
					end
					item.attack_timer = 2
				end
			end
		end
		if item.attack_timer > 0 then
			item.attack_timer -= 0.1
		end	
		-- collision between enemy and blockPowerUp
		for b in all(blockPowerUp) do
			if spr_collide(item.x, item.y, b.x, b.y) then
				item.health -= rnd(1)
			end
		end
		-- if no health then remove enemy
		if item.health <= 0 or item.y > 63*8  then
			if item.label == 2 and item.y < 63*8 then
				if rnd(2) < 1 then
					bug:make(item.x,item.y)
				end
			end
			particle:make(item.x, item.y, 10+flr(rnd(10)), 2)
			del(enemy, item)
			for _=0,flr(rnd(3)) do
				matrix:make()
			end
			if item.y < 63*8 then
				sfx(8)
			end
		end
	end
end

function enemy:draw()
	for item in all(enemy) do
		spr(20, item.x, item.y-6) -- mark out enemy
		if item.ani_delay >= 5 then
			if item.current_frame < item.max_frame then
				item.current_frame += 1
			else
				item.current_frame = 0
			end
			item.ani_delay = 0
		end
		local sprite = item.spr_map[item.label]
		if item.dir == 1 then
			spr(sprite[item.dir]+item.current_frame, item.x, item.y)
		else 
			spr(sprite[item.dir]+item.current_frame, item.x, item.y, 1, 1, 1)
		end
	end
end

-->8
--------------
--game core functions
--------------
-- function change_pal(sprite, c1, c2)
-- 	local y=flr(sprite/15) -- location on sprite sheet
-- 	local x=sprite-y*15-y
-- 	for w=0, 8 do
-- 		for h=0, 8 do
-- 			if sget(x*8+w, y*8+h) == c1 then
-- 				sset(x*8+w, y*8+h, c2)
-- 			end
-- 		end
-- 	end
-- end

function set_pal(palatte,opt)
	if palatte == 0 then
		-- reload() -- don't call this function, it will undo any changes made to the game map
		pal()
		bg_color = 7
	else if palatte == 1 then
		pal() -- reset palatte before reassign palatte
		for item in all(dark_palatte) do
			pal(item[1],item[2], 0 or opt)
			bg_color = 0
		end
	else if palatte == 2 then -- random lightning palatte
		pal()
		if rnd(1) < 0.4 then
			p = lightning_palatte1
		else
			p = lightning_palatte2
		end
		for item in all(p) do
			pal(item[1],item[2], 0 or opt) 
			bg_color = 0
		end
	end
	end
	end
end

function do_shake() -- shake camera
	if shake == 1 then
		shakex = 4-rnd(8) -- generate random amount of shaking
	  	shakey = 4-rnd(8)
	end
	if shake > 0 then
		shakex *= shake -- times by shake
	  	shakey *= shake 
		camera_x = player.x - 60 + shakex
		camera_y = player.y - 60 + shakey
		shake = shake*0.5 -- reduce shake
	end
	if shake < 0.05 then -- just set shake to zero if it's too low
		shake = 0
		camera_x = player.x - 60 -- normal camera following
		camera_y = player.y - 60
	end
end

function center_camera() -- recenter camera after do_shake()
	if camera_x+60 < player.x then 
		camera_x += 1
	end
	if camera_x+60 > player.x then 
		camera_x -= 1
	end
	if camera_y+60 < player.y then 
		camera_y += 1
	end
	if camera_y+60 > player.y then 
		camera_y -= 1
	end
end

function collide(x,y,flag) -- add map pos because level changes
	local x1, y1= x/8, y/8
    local x2, y2=(x+7)/8, (y+7)/8
    local a=fget(mget(x1,y1),flag)
    local b=fget(mget(x1,y2),flag)
    local c=fget(mget(x2,y2),flag)
    local d=fget(mget(x2,y1),flag)
    collision=a or b or c or d
	return collision
end 

function border_collide(x,y) 
	if mode ~= 3 and not player.special_room then
	    if x < 0 or x > 100*8 or y < 0 then
	    	return true
	    end
	end
end

function spr_collide(x1,y1,x2,y2)
	if x1-8 < x2 and x1+8 > x2 or x1 < x2+8 and x1+8 > x2+8 then
		if y1-8 < y2 and y1+8 > y2 or y1 < y2+8 and y1+8 > y2+8 then
			return true
		end
	end
end

-->8
--------------
--effects and weapon
--------------
matrix={}
function matrix:make()
	local x, s = flr(rnd(26))*5, 3+rnd(2)
	for _=0, 4+flr(rnd(6)) do
		local property = {
			x=x,
			y=0-_*7,
			speed=s,
			char=flr(rnd(2)),
			c=3
		}
		if _ == 0 then
			property.c=11
		end
		add(matrix, property)
	end
end

function matrix:update()
	for item in all(matrix) do
		item.y += item.speed
		if item.y > 128 then
			del(matrix, item)
		end
	end
end

function matrix:draw()
	for item in all(matrix) do
		print(item.char, item.x+camera_x, item.y+camera_y, item.c)
	end
end

lightning={}
function lightning:make()
	local property={
		x=rnd(128),
		y=0
	}
	add(lightning, property)
	for i=0, 2+rnd(4) do
		local property = {
			x=lightning[#lightning].x+-10+rnd(20),
			y=lightning[#lightning].y+10+rnd(10)
		}
		add(lightning, property)
	end
end

function lightning:update()
	if lightning_pause_timer > 0 then
		lightning_pause_timer -= 0.1
	else
		if weather == 1 then
			weather = 2
			do_lightning_timer = 1+flr(rnd(3))
			lightning:make()
		end
		lightning_pause_timer = 10+flr(rnd(5))
	end
	if weather == 2 then
		if do_lightning_timer > 0 then
			do_lightning_timer -= 0.1
		else
			weather = 1
		end
		for i=1, #lightning-1 do
			line(lightning[i].x+camera_x, lightning[i].y+camera_y, lightning[i+1].x+camera_x, lightning[i+1].y+camera_y, 7)
		end
		if bolt_timer > 0 then 
			bolt_timer -= 0.1
		else
			for item in all(lightning) do
				del(lightning, item)	
			end
			lightning:make() -- create another lightning 
			sfx(43)
			sfx(44)
			bolt_timer = rnd(1)
		end
	end
end

rain={}
function rain:make()
	if count(rain) < 20 then
		local property = {
			x=-20+rnd(120),
			y=-2,
			speed=7+rnd(5)
		}
		add(rain, property)
	end
end

function rain:update()
	for item in all(rain) do
		item.x += 3
		item.y += item.speed
		if item.y > 128 or item.x > 128 then
			del(rain, item)
		end
	end
end

function rain:draw()
	for item in all(rain) do
		line(item.x+camera_x, item.y+camera_y, item.x+camera_x+2, item.y+camera_y+8, 2)
	end
end

water={}
function water:find()
	for w=0, 127 do
		for h=0, 63 do
			if fget(mget(w,h),1) then
				local property = {
					x=w,
					y=h,
					sprite=mget(w,h)
				}
				add(water, property)
			end
		end
	end
end

function water:update()
	if water_ani_timer > 0 then
		water_ani_timer -= 0.1
	else
		for item in all(water) do
			if item.sprite == 48 then
				item.sprite = 54
			else if item.sprite == 54 then
				item.sprite = 48
			else if item.sprite == 101 then
				item.sprite = 55
			else if item.sprite == 55 then
				item.sprite = 101
			else if item.sprite == 117 then
				item.sprite = 56
			else if item.sprite == 56 then
				item.sprite = 117
			end
			end
			end
			end
			end
			end
			mset(item.x, item.y, item.sprite)
		end
		water_ani_timer = 1
	end
end

function draw_mountain()
	if mountain_x < -216 or mountain_x > 216 then
		mountain_x = 0
	end
	mountain_display(0)
	mountain_display(-216)
	mountain_display(217)

end

function mountain_display(value)
	-- MT1
	line(-40+camera_x+mountain_x+value, 100+camera_y, 50+camera_x+mountain_x+value, 20+camera_y,2)
	line(50+camera_x+mountain_x+value, 20+camera_y, 120+camera_x+mountain_x+value, 82+camera_y,2)
	-- MT2
	line(90+camera_x+mountain_x+value, 56+camera_y, 108+camera_x+mountain_x+value, 40+camera_y,2)
 	line(108+camera_x+mountain_x+value, 40+camera_y, 208+camera_x+mountain_x+value, 128+camera_y,2)
end

function reset_game_hardness() -- reduce bubble overtime
	if game_hardness_timer > 0 then
		game_hardness_timer -= 0.1
	else
		game_hardness_timer = 50
		if game_hardness < 4 then
			game_hardness = game_hardness * 2
		end
	end
end

function glitch()
	local rnd_height = 1+flr(rnd(77))
	local rnd_thickness = rnd_height+flr(rnd(50))
	for w=0, 127 do -- everything is in pixels positions
		for h=rnd_height, rnd_thickness do
			if h < 128 then
				pset(w+camera_x,h+camera_y+10,flr(rnd(16)))
			end
		end
	end 

end

snow = {}
function snow:make() 
	if count(snow) < 20 then
		snow_property = {
			x = -2,
			y = 1+flr(rnd(128)),
			speed = 2+flr(rnd(2)),
			sprite = 38+flr(rnd(2))
		}
		add(snow, snow_property)
	end
end

function snow:update()
	for item in all(snow) do
		item.y += -1+flr(rnd(3))
		item.x += item.speed
		if item.x > 128 then
			del(snow, item)
		end
	end
end

function snow:draw()
	for item in all(snow) do
		spr(item.sprite, item.x+camera_x, item.y+camera_y)
	end
end

function type(t,start_i,end_i,x,y) -- typing effects on screen
	for item=start_i, end_i do
		local line_spacing = item*10
		local _table = typed_text[t]
		local text = _table[item]
		if not text.finish then
			if text.delay > 0 then
				text.delay -= 0.1
				break
			else
				if text.index < #text.content then
					if text.timer > 0 then
						text.timer -= 0.1
					else
						text.timer = text.timer_reset
						text.index += 1
						sfx(0)
					end
				else
					text.finish = true
				end
				if text.last then
					_introValue = true -- optional
				end
				print(sub(text.content,1,text.index), x, y+line_spacing, text.color)
				text_cursor_x = x+text.index*4
				text_cursor_y = y+item*10-1
				break
			end
		else
			print(text.content, x, y+line_spacing, text.color)
		end
	end
end

function transit() -- between portals
	if do_transit then
		if not transit_back then
			if transit_progress < 70 then
				transit_progress += transit_speed
			else
				transit_back = true
				-- arbituary function
				if mode == 2 then
					if player.portal_type ~= 0 and player.final_teleport_timer > 0 then
						for i=0, count(portal) do
							local rnd_indice = flr(rnd(count(portal)))+1
							local new_x, new_y = portal[rnd_indice].x*8, portal[rnd_indice].y*8
							if player.portal_type == 1 then
								if portal[rnd_indice].label == 1 then
									if abs(player.x-new_x) > 16 then
										if abs(player.y-new_y) > 16 then
											player.x, player.y = new_x, new_y
											if game_hardness > 0.5 then 
												game_hardness -= game_hardness / 2 -- increase "visible" bubbles
											end
											if weather == 0 then
												weather = 1
												music(11,300)
											else
												weather = 0
												music(0,3000)
											end
											break
										end
									end
								end
							else
								player.x, player.y = 117*8, 60*8
								player.special_room = true
								specialItem:make(123*8, 60*8, 3)
							end
						end
					else if player.portal_type == 0 and player.final_teleport_timer > 0 then
						player.special_room = false
						player.x, player.y = player.check_point.x*8, player.check_point.y*8
						player.health = 20
						player.air = 10
					else 
						mode = 3
						bg_color = 1
					end
					end
				end
			end
		else
			transit_progress -= transit_speed
		end
		if transit_progress < 0 then
			do_transit = false
			transit_back = false
		end
		rectfill(camera_x, camera_y, 128+camera_x, transit_progress+camera_y, 2)
		rectfill(camera_x, 128+camera_y, 128+camera_x, 128-transit_progress+camera_y, 2)
	end
end 

trail={}
function trail:make(x,y)
	local property = {
		x = x,
		y = y,
		size = 1+rnd(2),
		life = 5+flr(rnd(10)),
		vely = -1 + rnd(2),
		mass = 0.5 + rnd(2)
	}
	add(trail, property)
end

function trail:update()
	for item in all(trail) do
		if item.size < 0 then
			del(trail, item)
		else
			item.size -= 0.1*item.life
			item.y += item.vely / item.mass * rnd(2)
		end
	end
end

function trail:draw()
	for item in all(trail) do
		circfill(item.x, item.y, item.size, 13)
	end
end

bubble={}
function bubble:make()
	if count(bubble) < 150 then
		for i=0, 5 do
			local property = {
				x = 0,
				y = 0,
				size = 20+rnd(3),
				life = 2+flr(rnd(2)),
				mass = 0.5 + rnd(2),
				velx = 0,
				vely = 0
			}
			s = 1+flr(rnd(4))
			if s == 1 then
				property.vely = 1 + rnd(1)
				property.x = rnd(128)
				property.y = -20
			else if s == 2 then
				property.vely = -1 - rnd(1)
				property.x = rnd(128)
				property.y = 150
			else if s == 3 then
				property.velx = 1 + rnd(1)
				property.y = rnd(128)
				property.x = -20
			else
				property.velx = -1 - rnd(1)
				property.y = rnd(128)
				property.x = 150
			end
			end
			end
			add(bubble, property)
		end
	end
end

function bubble:update()
	for item in all(bubble) do
		if item.size < 0 then
			del(bubble, item)
		else
			item.size -= game_hardness*item.life
			item.y += item.vely / item.mass * rnd(2)
			item.x += item.velx / item.mass * rnd(2)
		end
	end
end

function bubble:draw()
	for item in all(bubble) do
		circfill(item.x+camera_x, item.y+camera_y, item.size, 2)
	end
end

spark={}
function spark:make(x,y,amount)
	for _=1,amount do
		local spark_property = {
			x = x,
			y = y,
			size = 3,
			life = 1+flr(rnd(6)),
			velx = -1 + rnd(2),
			vely = -1 + rnd(2),
			mass = 0.5 + rnd(2)
		}
		add(spark, spark_property)
	end
end

function spark:update()
	for item in all(spark) do
		if item.size < 0 then
			del(spark, item)
		else
			item.size -= 0.1*item.life
			item.x += item.velx / item.mass * rnd(4)
			item.y += item.vely / item.mass * rnd(4)
		end
	end
end

function spark:draw()
	for item in all(spark) do
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

bullet={}
function bullet:make(x,y,dire,target)
	local property = {
		x=x,
		y=y,
		dire=dire,
		target=target,
		explode_timer=2,
		speed=3,
		timer=1,
		spr_map=58,
		current_frame=0,
		max_frame=5
	}
	add(bullet, property)
end

function bullet:update()
	for item in all(bullet) do
		if item.dire == 1 then
			item.x -= item.speed
		else
			item.x += item.speed
		end
		item.explode_timer -= 0.1
		bullet:explode(item)
	end
end

function bullet:explode(item)
	for l in all(loseTile) do
		if spr_collide(item.x, item.y, l.x, l.y) then
			if l.life > 0 then 
				l.life -= 1
			else
				del(loseTile, l)
				-- delete tile in map
				if not fget(mget(l.x/8,l.y/8-1),1) then
					mset(l.x/8,l.y/8,0)
				else
					mset(l.x/8,l.y/8,49) -- if tile is in water then replace with water tile
				end
				if rnd(5) < 1 then
					specialItem:make(l.x, l.y)
				end
			end
			shake = 1 
			rectangle:make(item.x-4, item.y-4, 16, 13)
			del(bullet, item)
			sfx(4)
		end
	end
	if collide(item.x, item.y, 0) or item.explode_timer < 0 then
		if item.target ~= "player" then
			shake = 1 
			rectangle:make(item.x-4, item.y-4, 16, 13)
		else
			rectangle:make(item.x-4, item.y-4, 16, 14)
		end
		del(bullet, item)
		sfx(4)
	end
	-- collision with player
	if item.target == "player" then
		if spr_collide(item.x, item.y, player.x, player.y) then
			player.health -= 1
			shake = 1
			rectangle:make(item.x-4, item.y-4, 16, 14)
			del(bullet, item)
			sfx(4)
		end
	end
	-- collision with enemy
	for e in all(enemy) do
		if item.target == "enemy" then
			if spr_collide(item.x, item.y, e.x, e.y) then
				shake = 1 
				rectangle:make(item.x-4, item.y-4, 16, 13)
				del(bullet, item)
				sfx(4)
				e.health -= 1
			end
		end
	end
end

function bullet:draw()
	for item in all(bullet) do
		if item.target == "enemy" then
			if item.dire == 1 then
				spr(34, item.x, item.y)
			else
				spr(34, item.x, item.y, 1, 1, 1)
			end
		else
			if item.timer > 0 then
				item.timer -= 0.5
			else
				item.timer = 1
				if item.current_frame < item.max_frame then
					item.current_frame += 1
				else
					item.current_frame = 0
				end
			end
			spr(item.spr_map+item.current_frame, item.x, item.y)
		end
	end
end

rectangle={}
function rectangle:make(x,y,size,col)
	local property = {
		x=x,
		y=y,
		size=size,
		color=col
	}
	add(rectangle, property)
end

function rectangle:update()
	for item in all(rectangle) do
		item.size -= 2
		item.x += 1
		item.y += 1
		if item.size < 0 then
			del(rectangle, item)
		end
	end
end

function rectangle:draw()
	for item in all(rectangle) do
		rect(item.x, item.y, item.x+item.size, item.y+item.size, item.color)
	end
end

specialItem={}
function specialItem:make(x,y,f)
	local property = {
		x=x,
		y=y,
		func=f,
		timer=0,
		max_frame=1,
		current_frame=0,
		spr_map={42,44,112},
	}
	if f == nil then
		property.func=1+flr(rnd(3))
	end
	add(specialItem, property)
end

function specialItem:update()
	for item in all(specialItem) do
		if spr_collide(item.x, item.y, player.x, player.y) then
			sfx(3)
			if item.func == 1 then
				if player.health < 20 then
					player.health += 1
				end
			else if item.func == 2 then
				blockPowerUp:make(15+flr(rnd(10)),0,0,1+rnd(2))
			else
				player.jump_high = true
			end
			end
			del(specialItem, item)
		end
	end
end

function specialItem:draw()
	for item in all(specialItem) do
		if item.timer > 0 then
			item.timer -= 0.2
		else
			item.timer = 1
			if item.current_frame < item.max_frame then
				item.current_frame += 1
			else
				item.current_frame = 0
			end
		end
		spr(item.spr_map[item.func]+item.current_frame, item.x, item.y)
	end
end

blockPowerUp={}
function blockPowerUp:make(r, a, mt, s)
	local property = {
		x=0,
		y=0,
		r=r,
		angle=a,
		-- 
		max_time=mt,
		speed=s,
		timer=0,
		max_frame=1,
		current_frame=0,
		spr_map=17,
		life=10+flr(rnd(20))
	}
	add(blockPowerUp, property)
end

function blockPowerUp:update()
	for item in all(blockPowerUp) do
		if item.timer > item.max_time then 
			item.angle += item.speed
			item.timer = 0 
		end
		if item.life > 0 then
			item.life -= 0.1
		else
			del(blockPowerUp, item)
		end
		item.x, item.y = player.x+cos(item.angle/100)*item.r, player.y+sin(item.angle/100)*item.r
		item.timer += 1
	end
end

function blockPowerUp:draw()
	for item in all(blockPowerUp) do
		if item.current_frame < item.max_frame then
			item.current_frame += 1
		else
			item.current_frame = 0
		end
		spr(item.spr_map+item.current_frame, item.x, item.y)
	end
end

particle={}
function particle:make(x,y,amount,col)
	for _=1,amount do
		local particle_property = {
			x = x,
			y = y,
			timer = 2+flr(rnd(3)),
			velx = -1 + rnd(2),
			vely = -1 + rnd(2),
			mass = 0.5 + rnd(2),
			color = col
		}
		add(particle, particle_property)
	end
end

function particle:update()
	for item in all(particle) do
		if item.timer < 0 then
			del(particle, item)
		else
			item.x += item.velx / item.mass * rnd(4)
			item.y += item.vely / item.mass * rnd(4)
			item.timer -= 0.1
		end
	end
end

function particle:draw()
	for item in all(particle) do
		-- display different colors of circle
		pset(item.x, item.y, item.color)
	end
end

cloud={}
function cloud:make()
	if count(cloud) < 100 then
		if cloud_timer < 0 then
			local property = {
				x=-64,
				y=-24+flr(rnd(63*8)),
				speed=0.1+rnd(0.5)
			}
			add(cloud, property)
			cloud_timer = 5
		else
			cloud_timer -= 0.1
		end
	end
end

function cloud:update()
	for item in all(cloud) do
		item.x += item.speed
		if item.x > 100*8 then
			del(cloud, item)
		end
	end
end

function cloud:draw()
	for item in all(cloud) do
		spr(98, item.x, item.y, 2, 1)
	end
end

-->8
--------------
--other things
--------------

portal={}
function portal:make()
	for w=0, 100 do
		for h=0,63 do
			local property = {
				x=w,
				y=h,
				timer=1,
				spr_map={23,118},
				current_frame=0,
				max_frame=5,
			}
			if fget(mget(w,h), 2) then
				property.label = 1
				add(portal, property)
			end
			if fget(mget(w,h), 4) then
				property.label = 2
				add(portal, property)
			end
		end
	end
end

function portal:update()
	for item in all(portal) do
		if item.timer > 0 then
			item.timer -= 1
		else
			item.timer = 1
			if item.current_frame < item.max_frame then
				item.current_frame += 1
			else
				item.current_frame = 0
			end
		end
		mset(item.x, item.y, item.spr_map[item.label]+item.current_frame)
	end
end

bug={}
function bug:make(x,y)
	local property = {
		x=x,
		y=y,
		timer=1,
		spr_map=29,
		current_frame=0,
		max_frame=2
	}
	add(bug, property)
end

function bug:update()
	for item in all(bug) do
		if spr_collide(item.x, item.y, player.x, player.y) then
			rectangle:make(item.x-10, item.y-10, 32, 9)
			player.inventory.bug += 1
			del(bug, item)
			sfx(12)
		end
	end
end

function bug:draw()
	for item in all(bug) do
		if item.timer > 0 then
			item.timer -= 0.5
		else
			item.timer = 1
			if item.current_frame < item.max_frame then
				item.current_frame += 1
			else
				item.current_frame = 0
			end
		end
		spr(item.spr_map+item.current_frame, item.x, item.y)
	end
end

loseTile={}
function loseTile:make()
	for w=0, 128 do
		for h=0,63 do
			if fget(mget(w,h),3) then
				local property = {
					x=w*8,
					y=h*8,
					life=1
				}
				add(loseTile, property)
			end
		end
	end
end

function loseTile:draw()
	for item in all(loseTile) do
		if item.life == 1 then
			spr(16, item.x, item.y)
		else
			spr(19, item.x, item.y)
		end
	end
end

__gfx__
00000000000000000000000000000000022222220222222202222222022222220000000000000000000000000000000000000000000000000000000044404440
00000000000222000002220000022200022222200222222002222220022222200002220000022200000222000002220000022200000000000000000044444444
007007000022ff200022ff200022ff20072272200722722007227220072272200022220000222200002222000022220000222200000000000000000044404440
00077000002fff20002fff20002fff20022222200222222002222220022222200272722002727220027272200272722002727220000000000000000000000000
00077000022fff00022fff00022fff00022222200222222002222220022222200222222002222220022222200222222002222220002000000022000000000000
0070070000f888f000f888f002f888f0022222200222222000222200022222200022220000222200002222000022220000222200002022200002020000000000
00000000000888000008880000088800022222200022220000000000002222000002220000020200002202000002022000020220002020200002020000000000
00000000000200200002200000200200002222000000000000000000000000000002200000020200002002000002000000020000002020000002020000000000
72222227000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222200000000000000000022220000ddddd0022222000022222000e020000008000000e0e0000022000000eee00000822000000000000000000000000000
2277772200220200002022000200002000ddddd02222222002222222000020000080800000200000008080000020000000008000009999000009900000009000
22777722000222000022200002000020000ddd00222222200222222200e000000080800000e02000008000000000200000800000009009000009900000009000
227777220022200000022200020000200000d0000222220000222220002ee0000028000000e0e0000002800000e2000000808000009009000009900000009000
22777722002022000022020002000020000000000002000000002000000000000000000000000000000000000000000000000000009999000009900000009000
22222222000000000000000000222200000000000002000000002000002220000022200000222000002220000022200000222000000000000000000000000000
72222227000000000000000000000000000000000002000000002000022222000222220002222200022222000222220002222200000000000000000000000000
22772277722222270000000000000000222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22272227222222220000000000022222222222222222200000000000000000000000000000000000000000000000000000002000000000000000000000000000
77777777222222220000000002222222222222222222222000000000000000000000000000000000022022000000000000022000000020000000000000ddd000
22222222222222220999909022222222000000002222222200066000000600000000000022220000022222000220220000222200000220000ee0ee000dd77d00
22222222222222220999000000220020000000000200220000066000000000000000000002200000002220000222220000222200002222000eeeee000ddd7d00
222222222222222200000000002222200000000002222200000000000000000000000000000000000002000000222000000220000022220000eee0000ddddd00
2222222222222222000000000022020000000000002022000000000000000000000000000200000000000000000200000000000000022000000e000000ddd000
72222227722222270000000000222200000000000022220000000000000000000000000002000000000000000000000000000000000000000000000000000000
00000000777777777777777700220000000000000000220000000000d0000000000000d002000000000000000000000000000000000000000000000000000000
000000007777777777777777002200000000000000002200000000000d0000000000000d02000000000000000000000000000000000000000000000000000000
00000000777d7777777dd77700220000000000000000220000000000d00d00000000d0d00200000000020000000ee000002220000002e2000000220000000000
000000007777777777d77d77002200000000000000002200000000000d0000000000000d02000000000e00000020000000e0020000200e0000000e0000200000
0ddd0dd07777777777d77d77002200000000000000002200d000d00dd000d00dd000d0dd020000000002220000020000002000000000020000e00e0000e00200
d777d77d77777777777dd7770022000000000000000022007ddd7dd77ddd7dd77ddd7dd702000000000000000000200000000000000020000002200000022000
77777777777777777777777700220000000000000000220077777777777777777777777702000000000000000000000000000000000000000000000000000000
77777777777777777777777700220000000000000000220077777777777777777777777702000000000000000000000000000000000000000000000000000000
0000000000000000000002222220000000000000022222000022222000000000000000002222000000002222000000000000000dddddddddddddddddd0000000
000000000000000000002277672220000000002222222222222222222200000022000000022220000002222000000022000000ddddddddddddddddd0dd000000
00000000000000000002777277772200000002222222222222222222222000002222000022222222222222220000222200000dddddd77ddddddddd00ddd00000
0000000000000000002777777777722000002222222222222222222222220000222222222222222222222222222222220000ddddddd77dddddddd000dddd0000
000000000000000000277272767776200022222222222222222222222222220002222222222222222222222222222220000ddddddddddddddddd0000ddddd000
00000022220000000072727277776220000002222222222222222222222000000002222222222222222222222222200000ddd77ddddddd7dddd00000dddddd00
0002227272622000002222722627672000000220000200200000200002200000000222222222222222222222222220000dddd77ddddddddddd000000dd7dddd0
002277762222220000227222222622200000022222020020220020222220000000022222222222222222222222222000ddddddddddddddddd0000000dddddddd
02222662777272200002222222222200000002200222002002002220022000000222220000000000000000000000000000000000000000000000000000000000
06272777777777200000202222402000000002200000002222000000022000000022200009999900000009900500050000000000000500000000000000000000
02777777776272600000094479404000000002222200000000000022222000000002000000999000009990900595090000909900000500000005990000959500
22772777776727220000099449444000000002202000000000000002022000000000000000090000009009000509050000900000050909000500090000005000
62772777767777620000004499400000000002222000000000000002222000000000000000000000009009000500000000900500050955000905050000505000
27262727622776620000004444400000000002200000000000000000022000000002000000020000090999000505005000000000090000000900050000599090
22222222222262220000004444400000000002200000000000000000022000000022200000222000099000000005995000000000055500000000000000000000
02222272227222200000004444400000000002200000000000000000022000000222220002222200000000000000000000000000000000000000000000000000
02222222222222200000000066660000d0000000d0000000777777777777777777777777777777777777777777777777dddddddd000000000000000000000000
009040422740400000066606666660000d0000000d0000007555755775777577777777777775777777777777777777770ddddddd022288eeeee222e002222220
00994047744040000066666667776600d0000000d00d000075777757755575777757557777757777777555777755557700dd77dd0e000000000000e002000020
000044497440400006677766777776600d0000000d000000757777777575757777577777757575777577757777775777000d77dd0202eeee222e202002020020
00000099444440000667766777667766d00000000ddd0dd07777775775777777775775777575557775757577775757770000dddd020200000000202002022220
000000944440000006677777766766660d000000d777d77d75777757757577577777777775777777757775777755575700000ddd020e022ee220802002000000
00000499444000000666677777776660d000000077777777755755577775555777777777755577777777777777777777000000dd080202000020802002222220
000000944440000000666677666666000d000000777777777777777777777777777777777777777777777777777777770000000d0802020ee020e02000000000
000000000000000000000000ddddd000000000d0000000d0000000000000000000000000000000000000000000000000000000000202022e802020e000000000
000000000000000000000000ddddd0000000000d0000000d0090400000090000009090000044000000999000009440000000000008020000002080e002222220
000000000000000000770000ddddd000000000d00000d0d0000040000090900000400000009090000040000000009000000000000802eee88220e0e002000020
000200000000000000777000ddddd0000000000d0000000d009000000090900000904000009000000000400000900000000000000e000000000020e002002020
000220000002000000777700ddddd000000000d00ddd0dd0004990000049000000909000000490000094000000909000000000000222eeeeee22202002222020
000222000002200000777000ddddd0000000000dd777d77d00000000000000000000000000000000000000000000000000000000000000000000002000000020
000000000002220000770000ddddd000000000d077777777002220000022200000222000002220000022200000222000000000000282e22222ee222002222220
000000000000000000000000000000000000000d7777777702222200022222000222220002222200022222000222220000000000000000000000000000000000
12313131311212000000121323132313121212120000001212313112670000120303031200000000313131313112123131000000000000000000000000000000
0616455565750000000000000000d41212121200324252470000000000000000000000000000000000000000000000000000000616e0e01200d4d4e400000000
123131313112120000004712121313231212121212e0000012121212120000121212124600000000000000000012120000000000000000002434008500000000
120202020202e0000000000000c4d4d4d4f400003300534700000000000000000000000000000000000000000000000000001212120202120000000000000000
1212121212121200000047001212121212121212121200d000000000000000000000004600000000000000000012120000510000000000002535d00000000000
12123131121212000000313100c6d4d4d4d4000012120247e000d00000000000000000000000000000000000000000000000c6d4d4f400000000000000000000
12121200123112000000470012121212121212121212121200000000000000000000004600000031310000710000120071121212d000000012121212d0e00000
1212313131121212000031310000c6e40000000012121257121212000000000000000000000000000000000000000000000000d4d4e400000051000000310000
123112001212120000d047e0000000d4d400000000000000c4d40000000000000000003131000000000012120000121212121212120000001212121212120000
00123131313112120012123100000000000000000012121231311200000000000000000000000000000000000000000000000200c6f400000202020202020000
313112f46300120000125712c4d4d4d4d4f40000000000c4d4d400000000000000000000000000000000121200000000121212121200000012123112000000c4
121212123131121200000000000000310000000000000012121200000000000000000000000000000000000000000000000000000000000000d4121212120000
121212c6f4c4120000121246d4d4e4d4c6d400000000c6d4d4d4f400000012f01200000000000000000000000000000031121212310000000000121200c4d4d4
121212121212121200000000d0d0003100000000000000000000000000000000000000000000000000000000000000000000000002020000c4d4d41212120000
12121200d4d41200c4f40046d4d400d4243400243400324252d4d400000000000000000004140000000000000000920000311212000000000000000000d4d4d4
d412c6d4d4121212000000001212003100003131d000000000000000000000000000000000000000000000000000000000000000000000d4d4d4d4d400120000
000000c4d4d4d4d4d4e40046c6d4d4d4253500253500337153d4d400041400000000000005150085002434000000930000021212003242527100000000d4d4d4
d4d4d4d4d40000000000000000000031000031121200000000000000000000000000000000000000000000000000000000000000000000d4d4d4d4d431120000
0000c4d4d4d4d4d4d4f40046000000c60202020202020202020200000515000000000000061600d0d0253524341202020212121212020202020000d000c6d4d4
d4d4d4d4d4f400000000001212020202000000000000000000000000000000000000000000000000000000000000000000000000000000c6d4d4d4d400000000
00711212d4f4d4d4121200462434001212121212121212121212710006160000000000000202020212021225351212121212121212121212120202021200c6d4
d400003131c600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c6e400000000
0012121212d400000000004625350012121203030303030312120202020202000000000012121212121212121212000000000000121212123131123112e0d0e0
0000003131000000000000000000000000e0d0000000000000000000000000000000000000000000000000000000000000000000000000000202000000000000
0000121212d4000000000046020202121212131323131313121231311212d4f40000001212121212121200000000000000000000001212123131313112121202
00d00000000000001212000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000004140000324252121213131212122313231312121231311212d4d4d4f400001212121200000086760000e000710000000012121212313131313112
121200243400003112123100000000001200a6000004140000000000000000000000000000000000000000000000000000000012310000000000000000000000
00000000000515000033005312131323131212121212121212121212120000c6d4d4f40012121212e0519666a600000202020200000000121212123131311200
00000025350000311212310000000000120066760005150000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000061612121212121223131313121200000000c6e400000000000000c6d4d4d4e4121212121200b63131e01212121212030303031231121212121203
0303031212000000121200243400d0121286d0b6e006160000000000000000000000000000000000000000000000000000000000001212000000000012000000
000000007112121212121212131313131212120000000000000000000000000000c6d4d4d4d41212121212120202021212121212121313131212121213131212
1313131312000000000000253500021212020202020202000000000000000000000000000000000000000000000000000000000000d412120000001212000000
00000000121212121212231313131312121212000000000000000000041400000000c4d4e4001212121212311212121200000012121313131212121313131313
1313131312000000000000020202121212121212121212000000000000000000000000000000000000000000000000000000000000c6d4121200001200000000
0000000012121212121313231313131212000000000000000000000005150000c4d4e40000000000121212121212120000000000120213131312121212131313
131313131200000000000012121212313131313131121200000000000000000000000000000000000000000000000000000000324252c6d4e492000000000000
0000000012121212121313131313121200000000000000000071d000061600c4d4e4d40000000000000012121200000000000000121213131313121212130202
13131312120000710031001212121231313131311212120000000000000000000000000000000000000000000000000000000033005300000093000000000000
000000001212121212121212121212000000000000000000121212f0f0f0f0f0f002d40000000000000000000000000000000000001202131313131313131212
13121212000002f0f002001212121212123131311212120000000000000000000000000000000000000000000000000000000002020202311212313100000000
000000000000000000000000000000000000000000000000121212000000000000d4e40000000000000000000000000000000000001212121212121212121212
12121200000000000000000012121212121212121212120000000000000000000000000000000000000000000000000000000012121212313131313100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031311212121200
00000000000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000012123112d00000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121212121200000000e0e00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012121212120000000202020000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001212f40047c612121200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c4d4d400470012121200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031310092d4e400470031310000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003131310093d00051470031310000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003131020202020202570202020000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001212120000000000000000
__gff__
0000000000000000000000000000000101000009000000040404040404000000010100000000000000001010101000000202020000000202020000000000000000000000000000000000000000000000000000000000000020000000000000000000000000024000000000000080800004040000000210101010101000808000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0d00000d001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00294845464b58004243232425000000000000000000000e000000000000000000000000000000000000000000000013210f2100210f0f21000000000e000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e39545556570e0d525333003500000000002130303030210000000000000000000000000000000000000000000000212121210000004c4d4d4e00002121000000000013210000000000000000000000000000000000000000000058000000000000000000000000000000000000000000000000000000000000000000000000
20200f0f0f2020202020202020200067006800212121210000000000000000000000000000000000000000001313214c4f2121000e4c4d4d4d0000000000000000000000000000000e170d0058004041000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000
21303030303021212121212100000000666a00000000000000000000000000000040410000001700000000000000214d4e00000021214d4d4d000d00000000002113000000000e2120202020000050510000000000000021303030200d0000000000000000000000000000000000000000000000000000000000000000000000
002132313121212121212121000015690000170e000000000000000000000000005051002020202020000000000021210e0029004d4d4d4d4d00210000000000004041000000212121212121210e6061000048494a4b0e2131323121211700000000000000000000000000000000000000000000000000000000000000000000
00213131322121212121214d4e2020202020202000000000232425000000000000606174002121212121000000000000202039004d4d4d4d4d4f00000000131300505100000021212113132121202020210054555657213132313121212100000000000000000000000000000000000000000000000000000000000000000000
002121212121212121214d4d4e6c4d4d4d4e000064290d21212121000000000021212174000000002121212100000000211321006c4d4d4e00000000000000000d606100000021212113131321212121210f0f0f0f0f212131313121000000000000000000000000000000000000000000000000007f6f000000000000000000
0000000000004d4f42436c00004c4d4d4d000000643921212121212100001500004d4e740000004c00004d4d0000002121210000580000000e0d000000202020202020000000212121212121212121212100000021212174212121210000000000000000000000000000000000000000000000007f6d6e6f0000000000000000
000000000021212152531600176c4d21000000006421212113210000001313136c4d007400204c4d4e004d4d00000000000000000d17000021210000000021212121212100002121212121212121212121170000002121744c4d4d4d4f00000000000000000000000000000000000000000000007f7d7e6f0000000000000000
000000000020202020202020202020200000000064000e212121000000000000004041740000004d4f4c4d4e00000000000000002121000021130000002121211321212100000021212121212121212121210000000000744d4d4d4e4d0000000000000000000000000000000000000000000000007f6f000000000000000000
000000000021211321212121212121216c4d00006400212121000013131300000050517442434243006c4d0000000000000000001313000000004c4d4f2121212121210000000000000000004c4d4d2121210000000000744d4d4d4c4d4f00000000000000000000000000000000000000000000001313000000000000000000
00000000002113132121212121212121006c00006400000000000040410000000060610d52535253150d6c210000000e0000000000000000004c4d4d4d0021212121210000004041000000004d4f4d4d4d4e00004c4d4f746c4d4d4d4d4d00000000000000000000000000000000000000001500131313130000000000000000
000000000021212121210000000000000e000d156400000000000e5051131300002121210f0f0f212121210000210f202030200000000000004d4d4d4d004c4d4d4d00000000505100444546476c4d4e4041004c4d4d4d7400006c4d4d4e000000000000000000000000000000000000000021210f0f0f0f2100000000000000
000000000000004c4f006c4f0000002020202021653030303030216061131300006c4d4d4f00001700000000000000212131210000000000006c0000004c4d4d0e0000000000606100545556570000005051004d4d4d4d7400000000000000000000000000000000000000000000000000002121000000000000000d00000000
0000004c4f004c4d4e00004d000020212121212131313231323121212121210000006c4e000021210000000000000013212113000000000000000d0d4c4d4d2121210000000021210f0f0f0f2100000e60610d6c4d4d4e740d0d0000000000000000000000000000000000000000000000000000000000000000202000000000
004c4d4d4d4d4d4e13004c4d4d00001313212121131313313131313131212121000000000000212100000000000000001313000000000000000021214d4d4d2121210000002121210000000000000021202020213030307521210000000000000000000000000000000000000000000000000000000000134041000000000000
004d4d4d4d4d4e1358136c4d4d4f0013132121212121212121313132313121210000000000000000000040410000000000000000000d0000000021210d4d4d4d4e6c0000000021210000000000002121212121213132313121210000000000000000000000000000000000000000000000000042430013215051000000000000
0000004c4d4e17131313004d4d4d00000000000000002121213132313131212100000000000000424300505148494a4b00000000212100000000212121000000000042430000006a0067000000212121212131313131323121210000000000000000000000000000000000000000000000000e52530000006061000000000000
000000002020212120202020204d0d0021000000000000212113313131212100000000232425175253006061545556570000000021212100000000212100000042435253210000676600000000000021212131323131313131210000000000000000000000000000000000000000000000002020203030302020200000000000
000000000021212121131321212020000000000021210021212121212121210000582020202021212120202021202121210000000021210e004c4d4e00000000525320202117000d0068000000000000212121313132313131210000000000000000000000000000000000000000000000006c21213132312121002100000000
0000000000212121212113212121000000444546474243002121212121210000000d21212121212121212121212121212121000000212121004d00004c4d0d002020212121212020210000000000004c4f00742121212121312100000000000000000000000000000000000000000000000000002131312164210000000e0000
000000000000212121212121212100000d5455565752530000000000000000000021212121212121212121303030302121210000000021210d4d4f4c4d4d2121212121131321212121210000000000004d4f74002100007421210000000000000000000000000000000000000000000000000021212121216400000000200000
131300004c4d4d002121210000000000202020212121210f0f0f0f2100000000002121211300000e2121213131312121212100000000212121004c4d4e000021212121131321212121000000005800170e0074004d4f007400000000000000000000000000000000000000000000000000000021214d4e006400000020000000
1313134d4d4d4d4f0000000000000000000000000000000000404100000e1500000000001300002121212121313231212121170000002121214c4d4e000000006c21212121214e00000000000e0000212100744c4d4d0074000000000000000000000000000000000000000000000000000000000d0e000e64000d2000000000
1313134d4d4d4d4e00000000000000000000004c4f0000424350510000210f21000000001300001313131321212121212121210000000000004d4e0000000000002121212100000000000000202020212113744d4d4d007400000000000000000000000000000000000000000000000000002121212121210000212121210000
131300004d4c4d0000000000000000000000004d4d4f005253606117000000000017000e1313212113134e000000004c21212100000000000e0d0000000000000021216c2100000040410021212121211313746c4d4d0074170d0000000000000000000000000000000000000000000000002113212100000000212121210000
0013154c4d4e6c4f00000000000000004041006c4e000e21212121210000000000210f2113132121214c4d0068004c4d4d21210000000000212100000000000000212100000000005051002121131313000074006c4d4f742121000000000000000000000000000000000000000000000000212121210d000000211313210000
1720202020200d0000005800000000005051000000002121131313212100000000000000131321214d4d4e0066686c4d4d212100000000002121000000000000000000000000000060610d000000000e000d74000000007400000000000000000000000000000000000000000000000000000021212121000021211321210000
2121211321212000000000000000000060611700002121211313132121000000000000001300002100000069000e176c4e13000000000000212100000000000040410000000000002121212100000021202021000000007400000000000000000000000000000000000000000000000000000040410000004c4d212121210000
212113131321210000002130303030302121210e0000212113131321000000000000000000000013000000212121210000130000000000002121000000000000505148494a4b00000021210000004c21211321210000007400000000000000000000000000000000000000000000000000000050510000006c4d214d4e000000
__sfx__
010500001a55500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001c07300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002e6402f6402f6402e6402d6202d6202d6202e6302e630306303063031630316302f6402b6402764027640296402a6402b6302d6302d6302d6302c6302963027624286252760000000000000000000000
0105000028075300003b0653000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000029650266542763517600176001760017600176001660012600086001360013600126000e600076000b6000b6000a60006600016001d60018600126000c60000000000000000000000000000000000000
010900002104300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070000190741b0741e07400000190601b0601e06000000190501b0501e05000000190451b0451e0450000500000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001307012670100700e6700d0700a6700607004670030700207001070010700020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001007510065100651005510045000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001f0341f0751b6000d000206000d0000d0002060020600226000d0000d00020600176001d6001a600176000d0000d0001b6000d0000d00011600186000f6000d0000d0000d0000d0001c6001e6000d000
01080000336653366532665316652f6652d6652b6651d66529675266750f67523675126751f67519675256752566416664226640f6640c6641e654086541b6541065410654176540e654136540a6541065403654
010700000c15300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002906430065300650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180101f0101d0101f010180101f0101d0101f010180101f0101d0101f010180101f0101d0101f010180101f0101d0101f010180101f0101d0101f010180101f0101d0101f010180101f0101d0101f010
011000002403018030180301803000000000000000000000000000000000000000000000000000000000000024030180301803018030000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000024623000001802300000000000000000000000001801300000180130000000000000000000000000
01100000240501f0551f0551f0550000000000000001d030000001d0301c0301d0301c030000000000000000240501f0551f0551f0550000000000000001d030000001d0301c0301d0301c030000000000000000
011000002462300000183130000000000000000000000000246230000018313000001830000000183000000024623000001831300000183000000018300000002462300000183130000018300000001830000000
011000001d0501d050000001d0501d0551d0551d0551d0551d050180551805518055000000000000000000001d0501d050000001d0501d0551d0551d0551d0551d05018055180551805500000000000000000000
011000000000000000000001e033000000000000000000001d1001d1001d1001e033000000000000000000000000000000000001e033000000000000000000001f1001f100181001e03300000000000000000000
0110000000000000000000000000000000000000000000001d1351d1351d1351f1350000000000000000000000000000000000000000000000000000000000001f1351f135181351813500000000000000000000
01100000240501f0551f0501f05000000000000000000000240501f0551f0501f05000000000000000000000240501f0551f0501f050000000000000000000001d0551d0501c0501d05000000000000000000000
0110000018035180351d0301f030000001f030000001f0351f0351f0351f035000000000000000000000000018035180351d0301f030000001f030000001f0351f0351f0351f0350000000000000000000000000
011000001c0551c0501805000000000000000000000000001c0551c0551c0551c0551d0551d055180551805500000000000000000000000000000000000000001c0551c0551c0551c0551d0551d0551f0501f050
0110000018623000001c6131c6131c6131c613000000000018623000001c6131c6131c6131c613000000000018623006001c6131c6131c6131c613006000060018623006001c6131c6131c6131c6130000000000
011000001d050180501a0501f05000000000000000000000181501a1501d15018150000000000000000000001d050180501a0501f0500000000000000000000018155181551d1551d15500000000000000000000
01100000240302b030300300000000000300353003530035180301f0302403000000000002403524035240352403524035180351c0301d0301f030180301a03500000000001a0351a0341a035000000000000000
0010000000000000000000024055240550000000000000000000000000000001d0551d05500000000000000000000000000000000000000000000000000000001f0551f0550000000000000001d0551d05500000
001000001f050180501c0501f0502405018050000001a0501a0501c0501d0501c0501805018050000001d05000000000001d0641d0501c0641a06400000000001c55718050000000000018050000000000000000
001000001d04018040180400000018030180301d030000001d0401d04018040000000000018030180301d030000001a0401c0401f040000000000000000180301a0301d0300000000000000001f0301c0201a010
0010000024625000000000018625000000000000000186151d62500000000001f6250000000000000001f61524625000000000018625000000000000000186151d62500000000001f6250000000000000001f615
001000001d0501d0501c0501d0500000000000000001d050180501d0501f05000000000002405030055300551c0501c0501a0501c050000001805518055000001d0501c0501a0501c0501d050210501f05000000
0010000024050240500000018055300551805500000000001d1151c2271a3351c4271d517216251f737000001d0501d0501d0500000000000240401d02018040180201f050000001f04024020210500000000000
0010000021625006052162500605216250060521625006051f625006051f6251f625006051f62500000000001d030000001d625000001d030000001d62500000000001c030000001c625000001c030000001c635
001000001805024050210501f05000000000001f050210501f0501d050000001805518055180551805524050210501f05000000000001f0502105023050240641806400000180502406418050240641805024064
0010000021040180401d0400000000000240402303021040230301f040000001f320000000000021050180501d050000000000000000212101f1101d2201c1101a22018110000002413018120241101812024130
001000001875500700187550070018755000001875500700186350070018625000001862500700186250070018755007001875500700187550000018755007001863500600186250060018625006001862500700
0010000018050180551805018050000001a0501c0501a050180500c0501805000000240501f0551f0551f055000000000018055180551a0501805518055000001f0501f050210502105024050240500000000000
0010000024130000001f0301d0201c0101f030000001a0201c0101d0201a01000000000000000000000180301a0301c030180300000000000180301a0301c0301f03024030000000000000000180201a02018010
001000000c0500c050100500c050000000c0500e050100500c05000000000000c0500c0500e05018050000000c0550c0550c0550c05500000000000e0500e0501005011050000000000013050130500e0500c050
0010000024050230502105024050000001f055000001f050210502305024050240300000000000000000000018070170701507018070000000c070000000c0350c0450c0550c0550c0450c0350c0250c01500000
0010000000000000000c0200e050100400c05000000100500e0500c000100500e0500c0500c0500000011050100500000011050100500e0500c0500c0000c0500e0501005011050100500e0300c0500c0200c010
001000000000000000000000c6250c6250000000000000000000000000000000c6250c6250000000000000000000000000000000c6250c6250000000000000000000000000000000c6250c625000000000000000
012800002e67511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001107300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000226402165022650236402364023640226402064020640206502165022650236502465024640226401e6401e6502065021650216502165020640206401e6401d6401e6502065021650216402164021640
__music__
00 0d0e0f44
00 0d101144
00 0d121314
00 0d151644
00 0d171844
00 0d191a1b
00 0d1c1d1e
00 0d1f2021
00 0d222324
00 0d252627
02 0d28292a
03 2d424344
