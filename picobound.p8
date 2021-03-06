pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

-- picobound 2017

-- by ian galope 2017

-- 4/18/2017

-- credits
-- fade to black effect by http://www.lexaloffle.com/bbs/?tid=2467
--notes:
--get rid of catching pokemon
--create animation for battle transition
--
--invent a logo, create a splashscreen by:http://www.lexaloffle.com/bbs/?tid=2213 
fcount = 0

logoanim=1
logostop=31
logofr=70
--draw a logo here
function logo()
	
 if(logoanim<=logostop) logoanim+=1
 if(fcount > 35) then
  print("ian",51,cy+20,9)
  print("galope",53,cy+26,8)
 end
end

function _update()
 fcount += 1
end

function _draw()
 cls()
 logo()
end

--battle sprites
local enemies = {
	"starman",
	"elite starman",
	"spiteful pigeon",
	"coilsnake",
	"hippie",
	"lost dog"
}

local miniboss = {
	"porky"
}

local finalboss = {
	"giygas"
}
-- sprite types
local elementalsprites = {
	bird = 22,
	alien = 13,
	reptile = 24,
	human = 15,
	canine = 36,
	evil_child = 1,
	final_alien = 1
	}

local kind = elementalsprites
-- 
local intypes = {}
local k = 0
for v in all(enemies, miniboss, finalboss) do
	k+=1
	intypes[v] = k
end

local newenemy = function(kind, hp, attack, defense, speed, psi, spr)
	return {
		kind = kind,
		hp = hp,
		attack = attack,
		defense = defense,
		speed = speed,
		psi = psi,
		spr = spr
	}
end

-- base stats
local enemystats = {
	elite starman = enemies(
		"alien",
			65,
			63,
			75,
			45,
			74 
	),
	starman = enemies(
		"alien",
			25,
			55,
			50,
			20,
			73
	),
	hippie = enemies(
		"human",
			60,
			55,
			50,
			20,
			75
	),
	coilsnake = enemies(
		"reptile",
			25,
			15,
			20,
			22,
			80
	),
	lost_dog = enemies(
		"canine", 
			30,
			20,
			25,
			25,
			65
	),
	porky = miniboss(
		"evil_child",
			75,
			75,
			80,
			90,
			100
	),
	giygas = finalboss(
		"final_alien",
			200,
			200,
			210,
			210,
			300
	)		
}

local items = {
	"hamburger",
	"croissant",
	"dog food",
	"skip sandwich",
	"psi butterfly",
	"psi mushroom",
	"full heal"
}

--equipped items
local specialitems {
	"bionic slingshot",
	"metal bat",
	"hard hat",
	"friendship bracelet",
	"travel charm"
}

local starter = "ness"
local lvl = 2
local ness = {
	name = starter,
	type = starter,
	level = lvl,
	maxhp = flr((enemystats[starter].hp*2*lvl/100)+lvl+10),
	curhp = flr((enemystats[starter].hp*2*lvl/100)+lvl+10),
	speed = flr((enemystats[starter].speed*2*lvl/100)+lvl+10),
	defense = flr((enemystats[starter].defense*2*lvl/100)+lvl+10),
	attack = flr((enemystats[starter].attack*2*lvl/100)+lvl+10),
	xp = 0,
	move1 = "attack",
	move2 = "defend",
	move3 = "pk rockin" ,
	move4 = nil 
}

local attack = function(target, from, done, base, name)
	if rnd() > movesstats[name].acc then
		text(from.name.."ness missed!", done)
		return
	end
	local base = base or 15
	local dmg = ((2*from.level+10)/250) * (from.attack/target.defense)*base + 2
	local eff = (effectness[enemystats[from.name].element..":"..enemystats[target.name].type] or 1)
	dmg = dmg * eff
	-- crit
	local crit
	if rnd() < from.speed/512 then
		dmg = dmg * 2
		crit = true
	end
	dmg = dmg * (0.85 + rnd(0.15))

	target.curhp -= dmg
	target.curhp = max(0, flr(target.curhp+0.5))
	sfx(38,0)
	if from == dialog.battle.enemies[1] then
		add(funcs, {
			t = 4,
			update = function(self)
				self.t-=1
				dialog.battle.p.x = rnd()*4
				dialog.battle.p.y = rnd()*4
				if self.t<= 0 then
					del(funcs, self)
				end
			end,
			draw = function() end
		})
	else
		add(funcs, {
			t = 4,
			update = function(self)
				self.t-=1
				dialog.battle.e.x = rnd()*4
				dialog.battle.e.y = rnd()*4
				if self.t<= 0 then
					del(funcs, self)
				end
			end, 
			draw = function() end
		})
	end
	if eff > 1 then
		text(from.name.." used "..name.."!", function()
			text("it's very effective!", done)


		end)
	elseif crit then
		text(from.name.." used "..name.."!", function()
			text("...critical hit!", done)
		end)
			
	else
		text(from.name.." used "..name.."!", done)
	end
end

moves = {
	pk rockin = function(target, from, done, base)
		attack(target, from, done, base,"pk rockin")
	end,
	pk thunder = function(target, from, done, base)
		attack(target, from, done, base,"pk thunder")
	end,
	pk freeze = function(target, from, done, base)
		attack(target, from, done, 40,"pk freeze")
	end,
	pk fire = function(target, from, done, base)
		attack(target, from, done, 50,"pk fire")
	end,
	taunt = function(target, from, done)
		local name = "taunt"
		text(from.name.." used "..name.."against ness!", function()
			target.defense-=1
			target.defense=max(1,target.defense)
			text("lowered "..target.name.."s def.", done)
		end)
	end,
	local name = "bite"
		text(from.name.."bit ness!", function()
			target.defense-=1
			target.defense=max(1,target.defense)
			text(..from.name.."bit"..target.name.., done)
		end)
	attack = function(target, from, done, base)
		attack(target, from, done, base, "attack")
	end,
	defend = function(target, from, done, base)
		attack(target, from, done, base, "defend")
	end,
	pk starstorm = function(target, from, done, base)
		attack(target, from, done, base, "pk starstorm")
	end
}
movenames = {
	"pk thunder", "pk fire", "pk starstorm", "attack", "defend", "taunt" , "bite", "pk rockin"
}

movesstats = {}
local i = 1
for k in all(movenames) do
	movesstats[k] = {
		id = i,
		acc = 0.95
	}
	i+=1
end
-- from:
-- http://www.lexaloffle.com/bbs/?tid=2477
function sort(a)
	for i=1,#a do
		local j = i
		while j > 1 and a[j-1] > a[j] do
			a[j],a[j-1] = a[j-1],a[j]
			j = j - 1
		end
	end
end

	for i=1,14 do
		dset(48+i-1, p.items[i] or 0)
	end

	dset(62, p.x)
	dset(63, p.y)
end

cartdata("headchant_picobound")

function gameintro()
	p.kills = 2
	p.blackscreen = true
			text("what was that crashing sound?? let's go find out..")
			p.blackscreen = false
			music(1)
		end)
	end)
end

function loadgame()
	if not dget(0) or dget(0) == 0 then
		gameintro()
	return end
	music(1,1,1)
	
	-- printh("loading game")
	local ids = {}
	for k,v in pairs(movesstats) do
		ids[v.id] = k
	end

	for i=1,4 do
		local n = (i-1)*12
		-- printh("n:"..n)
		-- printh("data:"..dget(n))
		if dget(n) and dget(n) ~= 0 then
			p.monsters[i] = {
				name = type[dget(n+0)],
				element = type[dget(n+0)],
				maxhp = dget(n+1),
				curhp = dget(n+2),
				level = dget(n+3),
				speed = dget(n+4),
				defense = dget(n+5),
				attack = dget(n+6),
				xp = dget(n+7),
				move1 = ids[dget(n+8)],
				move2 = ids[dget(n+9)],
				move3 = ids[dget(n+10)],
				move4 = ids[dget(n+11)],
			}
		end
	end
	p.items = {}
	
	
	for i=1,14 do
		if dget(48+i-1) and dget(48+i-1) ~= 0 then
			add(p.items, dget(48+i-1))
		end
	end
	if dget(62) ~= 0 then
		p.x = dget(62)
		p.y = dget(63)
		p.inside = nil
	end
	if p.enemies[1] then
		mset(47,5,11)
	else
		mset(47,5,97)
	end
end

empty = function() end

function _init()
	music(6)
	palt(0,false)
	palt(7,true)
end

function initvars()
	

	
	p = {
		escapetries = 0,
		kills = 0,
		x=36,
		y=7,
		dir = 33,
		inside = {
			x = 28,
			y = 0
		},
		items = {
			1, 2,
		},
		enemies = {
			
		}
	}
	palt(0,false)
	palt(7,true)
	funcs = {}
	time = 0
	dialog = {
		menusel = 1,
		t = 0,
		text = nil,
	}
	menus = {

	}
	loadgame()
end

-- from
-- http://pico-8.wikia.com/wiki/draw_zoomed_sprite_(zspr)
function zspr(n,w,h,dx,dy,dz)
  sx = 8 * (n % 16)
  sy = 8 * flr(n / 16)
  sw = 8 * w
  sh = 8 * h
  dw = sw * dz
  dh = sh * dz
  sspr(sx,sy,sw,sh, dx,dy,dw,dh)
end

function testteleport(x,y, fx, fy, tx, ty, inside, dir,success)
	local x,y = x - 1, y - 1
	if x == fx and y == fy then
		fade(0,-100,4)
		p.transition = true
		sfx(5)
		if not inside then
			music(1,1,6)
		else
			music(10,0,6)
		end
		if tx > 68 and ty < 22 then
			music(4,0,6)
		end
		add(funcs, {
			t = 8,
			update = function(self)
				self.t-=1
				if self.t==0 then
					
					if success then success() end
					p.transition = false
					p.x = tx+1
					p.y = ty+1
					p.inside = inside
					if dir then p.dir = dir end

					fade(-100,0,4)
				end
			end,
			draw = empty
		})
		
	end
end

function after(t, f)
	add(funcs, {
		t=t,
		update = function(self)
			self.t-=1
			if self.t == 0 then
				f()
			end
		end,
		draw = empty
		})
end



drawborder = function(x,y,w,h)
	local x, y,w,h = x, y, w or 7, h or 14
	rectfill(x,y,x+(w+1)*8,y+(h+2)*8,7)
	spr(100,x,y)
	spr(100,x+w*8,y,1,1,true)
	spr(116,x+w*8,y+(h+1)*8,1,1, true)
	spr(116,x,y+(h+1)*8,1,1)
	for i=1,w-1 do
		spr(101,x+i*8,y)
		spr(117,x+i*8,y+(h+1)*8)
	end
	for i=1,h do
		spr(102, x, y+i*8, 1,1, true)
		spr(102, x+w*8, y+i*8, 1,1)
	end
end
function lowerwindow()
	drawborder(0,96,15,2)
end

function leftmenu(w, h)
	drawborder(0,0,w,h)
end

function itemsmenu(donemenu)
	if #p.items > 10 then
		text("you have too many items. only the first 10 items will be saved...")
	end

	add(menus, {
		sel = 1,
		draw = function(self)
			leftmenu(nil, #p.items+2)
			local n = 0
			for item in all(p.items) do
				if item > 0 then
					n+=1
					if self.sel == n then
						spr(67,8, 8+n*8)
					end
					print(items[item], 16, 8+n*8,0)
				end
			end
		end,
		update = function(self)
			self.sel = handlemenu(#p.items, self.sel)
			if btnp(5) then
				del(menus, self)
			end
			if btnp(4) then
				if not p.items[self.sel] then return end
				local drop = function()
					del(p.items, p.items[self.sel])
				end
				local use = function()
					-- smokeball
					if p.items[self.sel] == 3 then
						if dialog.battle then
							text("you use the smokeball!", function()
								text("you ran away!")
								del(p.items, 3)
								menus = {}
								dialog.battle = nil
								p.transition = nil
							end)
						else
							text("this can only be used in battle!")
						end
						return
					end
					-- picoball
					if p.items[self.sel] == 2 then
						if #p.monsters == 4 then
							text("you already have 4 monsters.", function()
								text("release some monsters to catch new ones.")
							end)
						elseif dialog.battle then
							if rnd() < 0.2+((dialog.battle.monsters[1].curhp/dialog.battle.monsters[1].maxhp))*0.2 then
								text("clonk! oh no, you missed the "..dialog.battle.monsters[1].name.."!", function()
									del(p.items, 2)
									-- del(menus, self)
									donemenu()
								end)
								return
							else
								music(-1)
								sfx(37,0)
								text("you caught the "..dialog.battle.monsters[1].name.."!", function()
									dialog.battle = nil
									p.transition = nil
									if p.x > 68 and p.y < 22 then
										music(4,0,6)
									else
										music(1,1,6)
									end

								end)
								add(p.monsters, dialog.battle.monsters[1])
								
								del(p.items, 2)
							end
						else
							text("this can only be used in battle!")
						end
						return
					end
					-- potion
					if p.items[self.sel] == 1 and p.monsters[1] then
						-- select monster to heal
						add(menus, {
							sel = 1,
							draw = drawmonstermenu,
							update = function(self)
								self.sel = handlemenu(#p.monsters, self.sel)
								if btnp(5) then
									del(menus, self)
								end
								if btnp(4) then
									local mon = p.monsters[self.sel]
									if mon.curhp == 0 then
										text(mon.name.." can't be healed. he is defeated.")
										sfx(61,0)
									elseif mon.curhp < mon.maxhp then
										
										mon.curhp = flr(min(mon.maxhp, mon.curhp + 20))
										local done = function()
											del(p.items, 1)
											del(menus, self)
											if donemenu then donemenu() end
										end
										sfx(62,0)
										if flr(mon.curhp) == flr(mon.maxhp) then
											text("healing "..mon.name.." back to full hp!", done)
										else
											text("healing "..mon.name.." for 20 hp!", done)
										end
									else
										text(mon.name.." is already at fully healed!")
									end
								end
							end
						})
						return
					end
					if p.items[self.sel] == 6 then
						text("hmmm...a delicious apple!")
						return
					end
					if p.items[self.sel] == 9 then
						add(menus, {
							sel = 1,
							draw = drawmonstermenu,
							update = function(self)
								self.sel = handlemenu(#p.monsters, self.sel)
								if btnp(4) then
									del(menus, self)
									if rnd() < 0.5 then
										text(p.monsters[self.sel].name.." loves candy!", function()
											p.monsters[self.sel].doublexp = true
											del(p.items, 9)
											del(menus, self)
										end)
									else
										text(p.monsters[self.sel].name.." hates candy!", function()
											p.monsters[self.sel].doublexp = false
											del(p.items, 9)
											del(menus, self)
										end)
									end
								end
								if btnp(5) then
									del(menus, self)
								end
							end
							})
						return
					end
					text("can't use that here")
				end
				add(menus, {
					sel = 1,
					update = function(self)
						self.sel = handlemenu(2, self.sel)
						if btnp(4) and self.sel == 1 then
							use()
							del(menus,self)
						end
						if btnp(4) and self.sel == 2 then
							drop()
							del(menus,self)
						end
						if btnp(5) then
							del(menus,self)
						end
					end,
					draw = function(self)
						drawborder(32,32,5,5)
						spr(67,32+8, 32+16	+self.sel*8)
						print("use",32+16,32+24,0)
						print("drop",32+16,32+32,0)
					end
				})
			end
		end
	})
end

drawmonstermenu = function(self)
	drawborder(64,0,7,5)
	
	for i=1, #p.monsters do
		if self.sel==i then
			spr(67,64+8, 8+(i-1)*9)
		end
		spr(monstats[p.enemies[i].name].spr, 64+16-1, 8+(i-1)*9-2)
		-- print(p.monsters[i].name, 64+16+8, 8+(i-1)*9,0)
		local hp = p.monsters[i].curhp/p.monsters[i].maxhp
		local x,y,w,h = 64+16+8,8+(i-1)*9+1,28,3
		rectfill(x,y,x+flr(w*hp),y+h,8)
		rect(x,y,x+w,y+h,0)
	end

	drawborder(0,0,7,10)

	local i = self.sel
	if p.enemies[i] then

		local mon = p.monsters[i]
		print(i.." "..mon.name,8,8,0)
		print("  ("..monstats[mon.name].element..")",8,16,0)
		local n = 1
		local stats = {
			"level",
			"xp",
			"curhp",
			"speed",
			"defense",
			"attack"
		}
		local abbr = {
			level = "lvl",
			xp = "exp",
			curhp = "hp",
			speed = "spd",
			defense = "def",
			attack = "atk"
		}
		for v in all(stats) do
			local str = abbr[v].." "..mon[v]
			if v == "xp" then
				str = str.."/"..flr((mon.level*10)^1.2)
			end
			if v == "curhp" then
				str = str.."/"..mon.maxhp
			end
			print(str, 8, 16+n*8, 0)
			n+=1
		end
		print("z: options", 8, 64+16) 
		
		spr(elementalsprites[monstats[mon.name].element], 8, 14)
		drawborder(64,64,7,5)
		local ids = {}
		for k,v in pairs(movesstats) do
			ids[v.id] = k
		end
		if mon.move1 then
			print(mon.move1,64+8,64+8,0)
		end
		if mon.move2 then
			print(mon.move2,64+8,64+16,0)
		end
		if mon.move3 then
			print(mon.move3,64+8,64+24,0)
		end
		if mon.move3 then
			print(mon.move3,64+8,64+32,0)
		end
	end


end

function swapinmenu(forced, endround)
	add(menus, {
		sel = 1,
		draw = drawmonstermenu,
		update = function(self)
			self.sel = handlemenu(#p.monsters, self.sel)
			if btnp(4) then
				if p.monsters[self.sel].curhp > 0 then
					local o = p.monsters[1]
					local m = p.monsters[self.sel]
					if o == m then
						return
					end
					del(menus, self)
					text("swapping "..o.name.." for "..m.name, function()
						if not forced then endround() end
					end)

					p.monsters[1] = m
					p.monsters[self.sel] = o
					self.sel = 1
				else
					text("you can't choose him, he's down.")
				end
			end
			if btnp(5) and not forced then
				del(menus, self)
			end
		end
	})
end

function handlemenu(n, sel)
	local selector = sel or dialog.menusel
	local n = n or 4
	if btnp(0) then
		sfx(63,0)
		selector-=2
	end
	if btnp(1) then
		sfx(63,0)
		selector+=2
	end
	if btnp(2) then
		sfx(63,0)
		selector-=1
	end
	if btnp(3) then
		sfx(63,0)
		selector+=1
	end
	if selector <= 0 then selector += n end
	if selector > n then selector -= n end
	return selector
end

function enter(x, y)
	if dialog.battle then return end
	if mget(x-1,y-1) == 3 or mget(x-1,y-1) == 48 or mget(x-1,y-1) == 112 then
		if rnd() < 0.2 then
			music(-1)
			sfx(41)
			p.escapetries = 0
			menus = {}
			p.transition = true
			local n = 0
			local flash
			flash = function()
				n+=1
				if n > 4 then
					add(menus, {
						update = function()
							dialog.menusel = handlemenu()
							if btnp(4) then
								local endround = function()
									local ms = {}
									for i=1,4 do
										if p.monsters[1]["move"..i] then
											add(ms, dialog.battle.monsters[1]["move"..i])
										end
									end
									local m = ms[1+flr(rnd()*#ms)]
									moves[m](p.monsters[1], dialog.battle.monsters[1], function()
										if p.monsters[1].curhp <= 0 then
											p.monsters[1].curhp = 0
											local left
											for i=1,4 do
												if p.monsters[i] and p.monsters[i].curhp > 0 then
													left = true
												end
											end
											if left then
												swapinmenu(true)
											else
												music(-1)
												text("you were defeated!", function()
													menus = {}
													text("...you awake at your last save point.", function()
														initvars()
													end)
												end)
												
											end
											return
										else
											del(menus, self)
											dialog.menusel = 1
										end
									end)
								end
								if dialog.menusel == 3 then
									swapinmenu(nil, endround)
								end
								if dialog.menusel == 4 then
									if rnd(255) < p.monsters[1].speed*32/((dialog.battle.monsters[1].speed/4)%256) + p.escapetries*30 then
										menus = {}
										dialog.battle = nil
										p.transition = nil
										music(-1)
										text("you ran away!", function()
											music(1,1,6)
											end)
									else
										p.escapetries+=1
										text("you try to run away...but fail", function()
											endround()
										end)
										
									end
									return
								end
								if dialog.menusel == 2 then
									itemsmenu(function()
										del(menus, menus[#menus])
										endround()
									end)
								end
								if dialog.menusel == 1 then
									add(menus, {
										draw = function()
											lowerwindow()
											
											for i=1,4 do
												local m = p.monsters[1]["move"..i]
												if m then
													if dialog.menusel == i then
														spr(67, 16, 96+i*8)
													end
													--"("..(p.monsters[1][m.."pp"] or movesstats[m].pp)..")"
													print(m, 16+8, 96+i*8, 0)
												else

												end
											end
										end,
										update = function(self)
											local n = 0
											for i=1,4 do
												local m = p.monsters[1]["move"..i]
												if m then n+=1 end
											end
											dialog.menusel = handlemenu(n)
											if btnp(5) then
												del(menus, self)
											end
											if btnp(4) then
												local m = p.monsters[1]["move"..dialog.menusel]
												if m then
													moves[m](dialog.battle.monsters[1], p.monsters[1], function()
														if dialog.battle.monsters[1].curhp <= 0 then
															dialog.battle.monsters[1].curhp = 0
															menus = {}
															music(-1)
															sfx(37,0)
															text("you defeated the "..dialog.battle.monsters[1].name.."!", function()
																p.kills+=1
																local xp = flr(5*dialog.battle.monsters[1].level + rnd(5*dialog.battle.monsters[1].level))
																if p.monsters[1].doublexp then
																	xp=xp*2
																end
																p.monsters[1].xp+=xp

																text("your "..p.monsters[1].name.." earned "..xp.." xp!", function()
																	if p.monsters[1].xp >= (p.monsters[1].level*10)^1.2 then
																		-- level up
																		local mon = p.monsters[1]
																		mon.xp=0
																		mon.level+=1
																		mon.maxhp = flr((monstats[mon.name].hp*2*mon.level/100)+mon.level+10)
																		mon.curhp = mon.maxhp
																		mon.attack = flr((monstats[mon.name].attack*2*mon.level/100)+mon.level+10)
																		mon.defense = flr((monstats[mon.name].defense*2*mon.level/100)+mon.level+10)
																		mon.speed = flr((monstats[mon.name].speed*2*mon.level/100)+mon.level+10)

																		text("your "..p.monsters[1].name.." is now level "..p.monsters[1].level.."!", function()
																			dialog.battle = nil
																			p.transition = nil
																			music(1,1,6)
																		end)
																	else
																		dialog.battle = nil
																		p.transition = nil
																		music(1,1,6)
																	end
																	
																end)
															end)
														else
															endround()
															
														end
													end)
													
												end
											end
										end
									})
								end
							end
						end,
						draw = function()
							lowerwindow()							

							local x,y,w,h = 4,8,48,32-8
							rectfill(x,y,x+w,y+h,0)
							rectfill(x+1,y-1,x+w,y+h-1,7)
							print(dialog.battle.monsters[1].name, 8, 8,0)
							print(":l"..dialog.battle.monsters[1].level, 16, 16,0)
							print("hp:", 8, 23)
							local x,y,w,h = 20, 24, 24,3
							local hp = dialog.battle.monsters[1].curhp/dialog.battle.monsters[1].maxhp
							rectfill(x,y,x+flr(w*hp),y+h,8)
							rect(x,y,x+w,y+h,0)
							zspr(monstats[dialog.battle.monsters[1].name].spr,1,1, 74+dialog.battle.e.x, 4+dialog.battle.e.y,4)

							local x,y,w,h = 64+11,64,48,32-8
							rectfill(x,y,x+w,y+h,0)
							rectfill(x-1,y-1,x+w-1,y+h-1,7)
							local x = x+4
							print(p.monsters[1].name, x, y,0)
							print(":l"..p.monsters[1].level, x+8, y+8,0)
							print("hp:", x, y+15)
							local x,y,w,h = x+12, y+16, 24,3
							local hp = p.monsters[1].curhp/p.monsters[1].maxhp
							rectfill(x,y,x+flr(w*hp),y+h,8)
							rect(x,y,x+w,y+h,0)
							zspr(monstats[p.monsters[1].name].spr,1,1, 16+dialog.battle.p.x, 64+dialog.battle.p.y,4)

							if dialog.menusel == 1 then
								spr(67, 48, 96+8)
							elseif dialog.menusel == 3 then
								spr(67, 32+48, 96+8)
							elseif dialog.menusel == 2 then
								spr(67, 48, 96+8+8)
							elseif dialog.menusel == 4	 then
								spr(67, 32+48, 96+8+8)
							end

							print("fight", 48+8, 96+8, 0)
							print("monster", 32+48+8, 96+8, 0)
							print("item", 48+8, 96+8+8, 0)
							print("run", 32+48+8, 96+8+8, 0)
						end
						})
					
					dialog.menusel = 1
					local lvl = max(1, p.monsters[1].level + flr(-3+rnd(4)))
					local name = "piggy"
					local spawnmonsters = {}

					if mget(x-1,y-1) == 48 then
						-- in cave
						add(spawnmonsters, "watawamp")
						add(spawnmonsters, "pilo")
					elseif mget(x-1,y-1) == 112 then
						-- in water
						add(spawnmonsters, "flipa")
						add(spawnmonsters, "crub")
					else
						if x < 19 and y < 31 then
							add(spawnmonsters, "rowpim")
							add(spawnmonsters, "piggy")
							add(spawnmonsters, "purbirb")
						elseif x < 35 and y < 56 then
							add(spawnmonsters, "groldo")
							add(spawnmonsters, "feuxdino")
							add(spawnmonsters, "tinkerelle")
						elseif x < 35 then
							add(spawnmonsters, "limegoo")
						elseif x > 108 and y > 38 then
							add(spawnmonsters, "mogmine")
							add(spawnmonsters, "hatcell")
							add(spawnmonsters, "plaradi")
						elseif x > 60 and y > 40 then
							add(spawnmonsters, "dogshade")
							add(spawnmonsters, "buzzcor")
							add(spawnmonsters, "sneg")
						else
							spawnmonsters = montypes
						end
					end

					local a,b = flr(rnd()*#spawnmonsters), flr(rnd()*#spawnmonsters)
					local value = max(a,b)
					name = spawnmonsters[#spawnmonsters - value]
					if not name then name = "piggy" end

					local movesidx = {}
					for k,v in pairs(moves) do
						add(movesidx, k)
					end
					
					local move1, move2, move3, move4
					move1 = movesidx[flr(1+rnd()*#movesidx)]
					del(movesidx, move1)
					if rnd() < 0.5 then
						move2 = movesidx[flr(1+rnd()*#movesidx)]
						del(movesidx, move2)
						if rnd() < 0.5 and lvl > 5 then
							move3 = movesidx[flr(1+rnd()*#movesidx)]
							del(movesidx, move3)
							if rnd() < 0.5 and lvl > 10 then
								move4 = movesidx[flr(1+rnd()*#movesidx)]
								del(movesidx, move4)
							end
						end
					end
					printh(name)
					music(6,0,6)
					dialog.battle = {
						p = { x = 0, y = 0},
						e = { x = 0, y = 0},
						monsters = {
							{
								name = name,
								type = name,
								maxhp = flr((monstats[name].hp*2*lvl/100)+lvl+10),
								curhp = flr((monstats[name].hp*2*lvl/100)+lvl+10),
								level = lvl,
								speed = flr((monstats[name].speed*2*lvl/100)+lvl+10),
								defense = flr((monstats[name].defense*2*lvl/100)+lvl+10),
								attack = flr((monstats[name].attack*2*lvl/100)+lvl+10),
								xp = 0,
								move1 = move1,
								move2 = move2,
								move3 = move3,
								move4 = move4,
							}
						}
					}
					text("a wild "..dialog.battle.monsters[1].name .." appears!")
					return 
				end
				-- flashing effect
				fade(0,-100,4)
				after(4, function() 
					fade(-100,0,4) 
					after(4, flash)
				end)
			end
			flash()
		end
	else
		-- home
		testteleport(x, y, 39, 2, 54, 2, {x=28+15, y=0})
		testteleport(x, y, 54, 2, 39, 2, {x=28, y=0})
		
		-- picotown
		if not p.monsters[1] then
			if (x == 50 and y == 9) or (x==51 and y==9) then
				text("i should probably look around first.")
			end
		else
			testteleport(x, y, 49, 8, 12, 6)
			testteleport(x, y, 50, 8, 12, 6)
		end

		-- cave
		-- to picotown 
		testteleport(x, y, 124, 2, 5, 52)
		testteleport(x, y, 5,52, 124, 2)
		-- to vertebrae city
		--music(4)
		testteleport(x, y, 121,21, 87, 48)
		testteleport(x, y, 87,48, 121,21)
		-- after egg fight
		testteleport(x, y, 72,3, 74, 33)
		testteleport(x, y, 74,33, 72,3)
		
		testteleport(x, y, 12, 6, 50, 7, {x=28+15, y=0})
	end
end

function text(txt, after)
	local k = ""
	local g = false
	for i=1, #txt do
		k = k..sub(txt, i,i)
		if i%22 == 0 or g then
			g = true
			if sub(txt, i,i) == " " then
				k = k .. "\n"
				g = false
			end
		end
	end
	txt = k.."�"
	dialog.text = txt
	dialog.t = 0
	dialog.after = after
end

function walkagainst(x, y)
	if mget(x,y) == 19 and p.dir == 33 then
		p.jumping = true
		return false
	end
	return true
end

function updatemenu()
	if btnp(4) or btnp(5) then
		music(-1)
		initvars()
		_update = updategame
		_draw = drawgame
	end
end
_update = updatemenu

function updategame()
	time+=1
	sort(p.items)
	for v in all(funcs) do
		v:update()
	end
	local x,y = 0, 0
	if not p.transition and not dialog.text then
		if btn(0) then
			x-=1
		end
		if btn(1) then
			x+=1
		end
		if btn(2) then
			y-=1
		end
		if btn(3) then
			y+=1
		end
	end
	if x ~= 0 then y = 0 end

	if not p.moving and (x~=0 or y~=0) then
		if x > 0 then
			p.dir = 37
		elseif x < 0 then
			p.dir = 35	
		end
		if y > 0 then
			p.dir = 33
		elseif y < 0 then
			p.dir = 36
		else

		end
		if fget(mget(flr(p.x+x-1), flr(p.y+y-1)),1) and walkagainst(p.x+x-1, p.y+y-1) then
			
			return
		end
		p.swimming = false
		if fget(mget(flr(p.x+x-1), flr(p.y+y-1)),2) then
			local found
			for i in all(p.items) do
				if i == 5 then
					found = true
					break
				end
			end
			if not found then

				return
			else
				p.swimming = true
			end
		end
		y+=(p.jumping and y or 0)
		p.moving = true
		local movespeed = 8
		local tx, ty = p.x+x, p.y+y
		local a = add(funcs, {
			t = movespeed,
			update = function(self)
				p.x+=x/movespeed
				p.y+=y/movespeed
				self.t-=1
				if self.t == 0 then
					p.jumping = false
					p.moving = false
					del(funcs, self)
					p.x = flr(tx)
					p.y = flr(ty)
					enter(p.x, p.y)
				end
			end,
			draw = empty
		})
	end
	if(_pf>0) then --pal fade
	    if(_pf==1) then _pi=_pe
	    else _pi+=((_pe-_pi)/_pf) end
	    _pf-=1
	end
	if dialog.text then
		dialog.t+=2

		if dialog.t >= #dialog.text then
			if btnp(4) then
				dialog.text = nil
				if dialog.after then dialog.after() end
			end
		else
			sfx(24)
		end
	elseif dialog.battle then
		if menus[#menus] then
			menus[#menus]:update()
		end
	elseif dialog.menu then
		if menus[#menus] then
			menus[#menus]:update()
		end
	elseif btnp(4) then
		local right, left, up, down = 37, 35, 36, 33
		local x, y = p.x-1, p.y-1
		if p.dir == right then
			x+=1
		elseif p.dir == left then
			x-=1
		elseif p.dir == up then
			y-=1
		elseif p.dir == down then
			y+=1
		end

		-- telephone
		if mget(x, y) == 103 then
			if not p.monsters[1] then
				text("there is a message:", function()
					text("hey could you take the swooty outside for a walk?", function()
						text("it's in the picoball on the left wall.")
						end)
					end)
			else
				text(" - no new messages - ")
			end
		end

		-- book shelves
		if mget(x,y) == 85 then
			text("a buncha books")
		end

		-- picoball
		if mget(x, y) == 97 then
			
			sfx(40)
			text("you find a swooty!", function()
				savegame()
				end)
			
			mset(x,y,11)
			add(p.monsters, startermon)
		end

		-- picotown sign
		if mget(x, y) == 5 and x == 6 and y == 43 then
			text("welcome to picotown. don't throw shade at it, fam.")
		end
		if mget(x, y) == 5 and x == 10 and y == 6 then
			text("hint: press x to open the menu. save often.")
		end
		if mget(x, y) == 5 and x == 13 and y == 48 then
			text("prof corks lab")
		end
		if mget(x, y) == 5 and x == 6 and y == 52 then
			text("cave to vertebrae city")
		end
		-- postman
		if mget(x, y) == 47 and x == 11 and y == 38 then
			text("i'm kevin the postman.", function()
					text("i tried to deliver mail to prof cork.", function()
						text("but it seems he's out.", function()
							text("if you see him tell him i have something for him!")
						end)
					end)
				end)
		end
		--groldo
		if mget(x, y) == 75 and x == 13 and y == 43 then
			text("it gives you a weird look")
		end
		--groldo owner
		if mget(x, y) == 13 and x == 14 and y == 43 then
			text("my groldo is nice but a feuxdino would be lit!")
		end
		if mget(x, y) == 13 and x == 108 and y == 56 then
			if rnd() < 0.8 then
				text("don't you get lost in the city?")
			elseif rnd() < 0.5 then
				text("every street looks the same")
			else
				text("i heard that prof cork was last seen on the western lake.")
			end
		end
		-- sporty 
		if mget(x, y) == 31 and x == 121 and y == 49 then
			text("if the picostops don't pay out with new running shoes soon", function()
				text("i might have to run bare feet.")
			end)
		end
		-- obvious dude
		if mget(x, y) == 14 and x == 6 and y == 39 then
			text("where are the doors on these houses?")
		end
		-- apple dude
		if mget(x, y) == 14 and x == 106 and y == 42 then
			local foundapple, foundswimsuit
			for i in all(p.items) do
				if i == 6 then
					foundapple = true
				end
				if i == 5 then
					foundswimsuit = true
				end
			end
			if not foundapple and not foundswimsuit then
				text("i went swimming in the lake and now i'm hungry.", function()
					del(p.items, 6)
					text("man, i would really like an apple. could you get me one from the garden?")
				end)
			elseif foundapple and not foundswimsuit then
				text("thanks for the apple! here, have my swim suit!", function()
					add(p.items, 5)
				end)
			elseif foundswimsuit then
				text("there are some nice monsters to catch in the lake!")
			end
			return
		end

		-- rock
		if mget(x,y) == 83 then
			local foundhammer
			for i in all(p.items) do
				if i == 7 then
					foundhammer = true
				end
			end
			if foundhammer then
				mset(x,y,63)
			end
		end

		-- candy
		if mget(x,y) == 98 then
			add(p.items, 9)
			text("you found a candy!")
			mset(x,y,63)
		end

		-- prof cork
		if mget(x,y) == 12 and x == 49 and y == 56 then
			local foundhammer
			for i in all(p.items) do
				if i == 7 then
					foundhammer = true
				end
			end
			if not foundhammer then
				text("are you looking for me? i'm prof cork.", function()
					text("how are your monsters doing?", function()
						text("i will rate your monsters and give out prizes.", function()
							text("let me see... ..hmmm.. ....", function()
								text("your rating is...", function()
									local rating = 0
									for i=1,4 do
										if p.monsters[i] then
											rating+=p.monsters[i].level
										end
									end
									text(rating.."!", function()
										if rating > 1 then
											add(p.items, 7)
											text("that is great. here take this hammer!", function()
												text("*you get a hammer*")
											end)
										else
											text("you should come back when your monsters are stronger!")
										end
									end)
								end)
							end)
						end)	
					end)
				end)
			else
				text("you can now check out the cave!")
			end
		end
		-- garden gates
		if mget(x, y) == 21 then
			local haskey
			for i in all(p.items) do
				if i == 4 then
					haskey = true
					break
				end
			end
			if not haskey then
				text("it's locked")
			else
				text("you use the garden key to unlock the gate")
				mset(x,y,32)
			end
		end

		-- apple trees
		if mget(x,y) == 125 or mget(x,y) == 126 then
			local apples = 0
			for i in all(p.items) do
				if i == 6 then
					apples+=1
				end
			end
			if apples < 3 then
				add(p.items, 6)
				text("*you pick an apple*")
			else
				text("i should probably leave some for the others")
			end
		end
		
		-- ancap
		if mget(x, y) == 15 and x == 32 and y == 34 then
			text("we abolished capitalism for a picostop based economy.", function()
				text("works fine but i wonder where the items come from?")
			end)
		end

		-- prof corks assistant
		if mget(x, y) == 12 and x == 121 and y == 19 then
			local found
			for i in all(p.items) do
				if i == 4 then
					found = true
					break
				end
			end
			if not found then
				text("hey! i'm prof corks assistent.", function()
					text("what? there is mail for me?", function()
						text("i can't leave here yet", function()
							add(p.items, 4)
							text("but you can have this key to the garden.", function()
								text("*received garden key*")
							end)
						end)
					end)
				end)
			else
				text("i'm trying to catch a watawamp.")
			end
		end

		-- the sega
		if mget(x, y) == 30 and x == 35 and y == 5 then
			if rnd() < 0.5 then
				text("the cartridge is stuck...")
			else
				text("...")
			end
		end
		-- the tv at home
		if mget(x, y) == 29 and x == 50 and y == 2 then
			text("*...and finn the human, the fun will never end...*")
		end
		-- computer
		if mget(x, y) == 84 and x == 32 and y == 2 then
			text("it's my dusty and broken computer.")
		end
		if mget(x, y) == 115 or mget(x,y) == 99 then
			sfx(60,2)
			for i=1,4 do
				if p.monsters[i] then
					p.monsters[i].curhp = p.monsters[i].maxhp
				end
			end
			local after = function()
				savegame()
				text("your game has automatically been saved!")
			end
			text("the all your monsters are healed...", function()
				if p.kills < 1 then
					text("defeat a couple of wild monsters to get a prize from this picostop!", after)
				else
					if #p.items < 10 then
						p.kills-=1
						local item = (1+flr(rnd(2)))
						if rnd() < 0.05 then item = 3 end
						add(p.items, item)
						text("you press the button. the picostop drops a...", function()
							sfx(37,0)
							text("..."..items[item].."!", after)
							end)
					else
						text("your inventory is full!", after)
					end
				end
			end)
		end
	elseif not p.transition and btnp(5) and not p.moving then
		p.transition = true
		dialog.menu = true
		menus = {}
		-- menu
		add(menus, {
			draw = function()
				drawborder(64+8,0,6,6)
				for i=1,4 do
					if dialog.menusel == i then
						spr(67,64+16, 8+i*8)
					end
				end
				print("monster", 64+16+8, 16,0)
				print("item", 64+16+8, 24,0)
				print("save", 64+16+8, 32,0)
				print("reset", 64+16+8, 40,0)
			end,
			update = function(self)
				dialog.menusel = handlemenu(4)
				if btnp(4) then
					if dialog.menusel == 4 then
						text("caution: this will delete all your progress and reset the game!", function()
							add(menus, {
								sel = 1,
								update = function(self)
									self.sel = handlemenu(2, self.sel)
									if (btnp(4) and self.sel == 1) or btnp(5) then
										del(menus, self)
									end
									if btnp(4) and self.sel == 2 then
										del(menus, self)
										for i=0,63 do
											dset(i, nil)
										end
										music(-1)
										_init()
										_update = updatemenu
										_draw = drawmenu
									end
								end,
								draw = function(self)
									drawborder(32,32,9,5)
									spr(67,32+8, 32+16	+self.sel*8)
									print("are you sure?",32+16,32+8,0)
									print("no",32+16,32+24,0)
									print("yes",32+16,32+32,0)
								end
							})
							end)
						return
					end
					if dialog.menusel == 3 then
						savegame()
						if #p.items > 10 then
							text("you have too many items. only the first 10 items will be saved...", function()
								text("saved successfully!", function()
									p.transition = nil
									del(menus, self)
									dialog.menu = false
								end)
							end)
						else
							text("saved successfully!", function()
								p.transition = nil
								del(menus, self)
								dialog.menu = false
							end)
						end
						
						return
					end
					if dialog.menusel == 2 then
						itemsmenu()
					end
					if dialog.menusel == 1 then
						-- monster menu
						add(menus, {
							sel = 1,
							draw = drawmonstermenu,
							update = function(self)
								self.sel = handlemenu(#p.monsters, self.sel)
								if btnp(5) then
									del(menus, self)
								end
								if btnp(4) and p.monsters[1] then
									local swap = function()
										local o = p.monsters[1]
										local m = p.monsters[self.sel]
										p.monsters[1] = m
										p.monsters[self.sel] = o
										self.sel = 1
									end
									local which = self.sel
									add(menus, {
										sel = 1,
										update = function(self)
											self.sel = handlemenu(2, self.sel)
											if btnp(5) then
												del(menus, self)
											end
											if btnp(4) and self.sel == 1 then
												swap()
											end
											if btnp(4) and self.sel == 2 then
												local release = function()
													if #p.monsters > 1 then
														del(p.monsters, p.monsters[which])
														menus[#menus].sel = 1
													else
														text("you can't release your last monster.")
													end
													del(menus, self)
													
												end
												add(menus, {
													sel = 1,
													update = function(self)
														self.sel = handlemenu(2, self.sel)
														if (btnp(4) and self.sel == 1) or btnp(5) then
															del(menus, self)
														end
														if btnp(4) and self.sel == 2 then
															del(menus, self)
															release()
														end

													end,
													draw = function(self)
														drawborder(32,32,9,5)
														spr(67,32+8, 32+16	+self.sel*8)
														print("are you sure?",32+16,32+8,0)
														print("no",32+16,32+24,0)
														print("yes",32+16,32+32,0)
													end
												})
												
											end
										end,
										draw = function(self)
											drawborder(32,32,6,5)
											spr(67,32+8, 32+self.sel*8)
											print("first",32+16,32+8,0)
											print("release",32+16,32+16,0)
										end
										})
									
								end
							end
							})
					end
				end
				if btnp(5) then
					menus = {}
					p.transition = false
					dialog.menu = false
				end
			end
			})
	end
end

_shex={["0"]=0,["1"]=1,
["2"]=2,["3"]=3,["4"]=4,["5"]=5,
["6"]=6,["7"]=7,["8"]=8,["9"]=9,
["a"]=10,["b"]=11,["c"]=12,
["d"]=13,["e"]=14,["f"]=15}
_pl={[0]="00000015d67",
     [1]="0000015d677",
     [2]="0000024ef77",
     [3]="000013b7777",
     [4]="0000249a777",
     [5]="000015d6777",
     [6]="0015d677777",
     [7]="015d6777777",
     [8]="000028ef777",
     [9]="000249a7777",
    [10]="00249a77777",
    [11]="00013b77777",
    [12]="00013c77777",
    [13]="00015d67777",
    [14]="00024ef7777",
    [15]="0024ef77777"}
_pi=0-- -100=>100, remaps spal
_pe=0-- end pi val of pal fade
_pf=0-- frames of fade left
function fade(from,to,f)
    _pi=from _pe=to _pf=f
end

local td = 0
function drawmenu()
	td+=1
	cls()
	rectfill(0,0,128,128,7)
	for rmon=0,6 do
		zspr(73+rmon, 1,1,60-cos(rmon/7+(rmon+td)/300)*24,64+sin(rmon/7+(rmon+td)/300)*24,1)
	end
	for rmon=0,3 do
		zspr(121+rmon, 1,1,60+cos(rmon/4+(rmon+td)/100)*8,64+sin(rmon/4+(rmon+td)/100)*8,1)
	end
	rectfill(0,16-8,128,16+12,0)
	
	print("2016 by headchant ", 30,128-5,0)
	print("pico\nmonsters", 46,12,7)
	rectfill(0,110-8,128,110+12,0)
	local str = "z to begin"
	if dget(0) ~= 0 then
		str = "z to continue"
	end
	print(str, 64-#str*2,110,7)

end
_draw = drawmenu

function drawgame()
	camera()
	cls()
	rectfill(0,0,128,128,7)
	
	local camx, camy = flr(p.x*8)-64, flr(p.y*8)-64
	camx = max(0, camx)
	camy = max(0, camy)
	camx = min(128*8-128, camx)
	camy = min(64*8-128, camy)
	if p.inside then
		camx = p.inside.x*8
		camy = p.inside.y*8
	end
	camera(camx, camy)
	map(0,0,0,0,128,128)
	
	if p.swimming then
		spr(50, (p.x-1)*8, (p.y-1)*8 - (p.jumping and 2 or 0))
	else
	    spr(p.dir+(p.moving and flr(time/2)%2 or 0)*16, (p.x-1)*8, (p.y-1)*8 - (p.jumping and 2 or 0))
	end
	if mget(flr(p.x-1), flr(p.y-1)) == 3 then
		if p.y <= flr(p.y)+0.5 then
			spr(3, flr(p.x-1)*8, flr(p.y-1)*8)
		end
	end
	if mget(flr(p.x), flr(p.y-1)) == 3 then
		spr(3, flr(p.x)*8, flr(p.y-1)*8)
	end
	
	for v in all(funcs) do
		v:draw()
	end

	
	camera()
	if p.blackscreen then
		rectfill(0,0,128,128,0)
	end
	if dialog.battle then
		rectfill(0,0,128,128,7)
		for v in all(menus) do
			v:draw()
		end
	end
	if dialog.menu then
		for v in all(menus) do
			v:draw()
		end
	end
	
	if dialog.text then
		lowerwindow()
		if dialog.t >= #dialog.text then
			-- blink the last char
			print(sub(dialog.text,1,#dialog.text-flr(time/4)%2), 8,96+8,32)
		else
			print(sub(dialog.text,1,dialog.t), 8,96+8,32)
		end
	end
	local pix=6+flr(_pi/20+0.5)
	if(pix!=6) then
	    for x=0,15 do
	        pal(x,_shex[sub(_pl[x],pix,pix)],1)
	    end
	else 
		pal()
		palt(0,false)
		palt(7,true)
	end
end

__gfx__
00000000b6bbb888d88bbbbb444cccccccccccc44cccccccccccccc44ccccccccccccc444cccccccccccccc4ccccccccccccccc444cccccccccccc4411111111
00000000656888808088bbbb444c5555555555cc4c555555555555cc4c55555555555cc44c555555555555ccc5555555555555cc44c5555cc5555cc411111111
00000000656bb00f0f0bbbbb444c57777777756c4c5777777777756c4c577777777756c44c5777777777756cc57777777777756c44c57756c57756c411111111
00000000b6bbff1ff1ffbbbb444c57777777756c4c5777777777756c4c577777777756c44c5777777777756cc57777777777756c44c57756c57756c411111111
00000000bffbbffffffbbbbb444c5aa5555aa56c4c55555aa555556c4c5aa555555556c44c5aa555555aa56cc55aa55555aaa56c44c5aa56c5aa56c411111111
00000000b6fbbbfeefbbbbbb444c5aa5665aa56c4cc6665aa566666c4c5aa566666666c44c5aa566665aa56ccc5aa56665aaa56c44c5aa56c5aa56c411111111
00000000b6fbbbbffbbbbbbb444c59956c59956c44cccc59956ccccc4c59956cccccccc44c59956ccc59956c4c5995555599556c44c59956c59956c411111111
00000000b6ffccccccccffbb444c59955559956c44444c59956c44444c59956c444444444c59956c4c59956c4c5999999995666c44c59956c59956c411111111
00000000b6bbaaaaaaaabfbb444c58888888856c44444c58856c44444c58856c444444444c58856c4c58856c4c58888888856ccc44c58856c58856c422222222
00000000bbbbbccccccbbfbb444c58888888856c44444c58856c44444c58856c444444444c58856c4c58856c4c588555558855cc44c58856c58856c422222222
00000000bbbbbaaaaaabbffb444c5ee55555556c4ccccc5ee56cccc44c5ee56ccccccc444c5ee56ccc5ee56ccc5ee56665eee56c44c5ee56c5ee56c422222222
00000000bbbbbccccccbbbbb444c5ee56666666c4c55555ee55555cc4c5ee55555555cc44c5ee555555ee56cc55ee55555eee56c44c5ee5555ee56c422222222
00000000bbbbb555555bbbbb444c52256ccccccc4c5222222222256c4c522222222256c44c5222222222256cc52222222222256c44c52222222256c422222222
00000000b3b3b553b553b3b3444c52256c4444444c5222222222256c4c522222222256c44c5222222222256cc52222222222256c44c52222222256c422222222
000000003b3b3f3b3bfb3b3b444c55556c4444444c5555555555556c4c555555555556c44c5555555555556cc55555555555556c44c55555555556c422222222
000000003332223333222333444cc6666c4444444cc666666666666c4cc66666666666c44cc666666666666ccc6666666666666c44cc6666666666c422222222
00000000cccccc44cccccc4cccccccccccc4444444cccccccccccccc44ccccccccccccc444cccccccccccccc4ccccccccccccccc444cccccccccccc466666666
00000000c5555cc4c5555ccc5555555555cc44444444444444444444044444444444444444444444444444444444444444444444444444444444444466666666
00000000c57756c4c57756cc57777777756c44444444444444444444000000000000000000004444444000000000000000000000000000000000000066666666
00000000c57755ccc57756cc57777777775cc4444444444444444444000000000000000000000000000000000000000000000000000000000000000066666666
00000000c5aaa55cc5aa56cc55aa555aaaa5cc444444444444444444000000000000000000000000000000000000000000000000000000000000000066666666
00000000c5aaaa55c5aa56ccc5aa56555aaa5cc44444444444444444000000000000000000000000000000000000000000000000000000000000000066666666
00000000c5999995559956c4c59956c6599956c44000000044444440000000000000000000000000000000000000000000000000000000000000000066666666
00000000c5995999559956c4c59956cc559956c40000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
00000000c5885588858856c4c58856cc558856c4cc333333bbbcccccffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
00000000c5885558888856c4c58856cc588856c433333333bbbbbbbbffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
00000000c5ee5655eeee56ccc5ee56555eee56c433333333bbbbbbbbffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
00000000c5ee56c55eee56cc55ee555eeee566c433333333bbbbbbbbffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
00000000c52256cc552256cc5222222222566cc433333333bbbbbbbbffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
00000000c52256ccc52256cc522222222566cc4433333333bbbbbbbbffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
00000000c55556c4c55556cc55555555556cc44433333333bbbbbbbbffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
00000000cc6666c4cc6666ccc6666666666c444433333333bbbbbbbbffffffffeeeeeeeeddddddddccccccccaaaaaaaa99999999888888884444444477777777
cc0000004cccccc4ccccccc4cccccccccccc4444000ccccc00000000ffffffffeeeeeeeeddddddddccccccccccccccc3cccccccc000000000000000000000000
00000000444444444444444444444444444444440000000000000000ffffffffeeeeeeeeddddddddcccccccc3333333333333333000000000000000000000000
00000000000000000000000000000000000000000000000000000000ffffffffeeeeeeeeddddddddcccccccc3333333333333333000000000000000000000000
00000000000000000000000000000000000000000000000000000000ffffffffeeeeeeeeddddddddcccccccc3333333333333333000000000000000000000000
00000000000000000000000000000000000000000000000000000000ffffffffeeeeeeeeddddddddcccccccc3333333333333333000000000000000000000000
00000000000000000000000000000000000000000000000000000000ffffffffeeeeeeeeddddddddcccccccc3333333333333333000000000000000000000000
00000000000000000000000000000000000000000000000000000000ffffffffeeeeeeeeddddddddcccccccc3333333333333333000000000000000000000000
00000000000000000000000000000000000000000000000000000000ffffffffeeeeeeeeddddddddcccccccc3333333333333333000000000000000000000000
00000000bbbbbbbbbbb88bbb44b44bbbbbbbbbbb6666666aa6666666bbbbbbbbaaaaaaaa9999999988888888bccccccc66666666666666666666666666666666
00000000bbbbbbbbbb8888bbb747bbbbbbbbbbbb6666666aa6666666bbbbbbbbaaaaaaaa9999999988888888bbbbbbbb66666666666666666655866666558666
000000004bb4bbbbb87ff78bb444bbbbbbbbbbbb6666666aa6666666bbbbbbbbaaaaaaaa9999999988888888bbbbbbbb66666666666666666655888666558886
00000000b74bbbbb8ffffff8b4e4bbb44bbbbbbb6666666666666666bbbbbbbbaaaaaaaa9999999988888888bbbbbbbb66666666666666666988888969888889
00000000b44b444bb8feef8bbb4bb44ff44bbbbb6666666666666666bbbbbbbbaaaaaaaa9999999988888888bbbbbbbb66666666666666669404840490408040
00000000bbb444bbb1d88d1bbbb444ffff4444bb6666666666666666bbbbbbbbaaaaaaaa9999999988888888bbbbbbbb66666666666666666070607064746474
00000000bb4bbb4bbfd11dfbbbb4444ff444bbbb6666666aa6666666bbbbbbbbaaaaaaaa9999999988888888bbbbbbbb66666666666666666404640460406040
00000000bbbbbbbbbf2222fbbbb444444444bb556666666aa6666666bbbbbbbbaaaaaaaa9999999988888888bbbbbbbbaaaa66aaaaa66aaa6666666666666666
00000000bbbbbbbbbbfbbfbbbbb4bb4b4bb4b5666666666aa666666677777777666666665555555544444444ccccccccaaaa66aaaaa66aaa6666666666666666
00000000bbb88bbbbbb88bbbbbb4b44b4b4456666666666aa666666677777777666666665555555544444444bbbbbbbb66666666666666666668556666685566
00000000bb8888bbbb8888bb3b44b3b443b355556666666aa666666677777777666666665555555544444444bbbbbbbb66666666666666666888556668885566
00000000b87ff78bb87ff78b3333333333333333666666666666666677777777666666665555555544444444bbbbbbbb66666666666666669888889698888896
000000008ffffff88ffffff83333333333333333666666666666666677777777666666665555555544444444bbbbbbbb66666666666666664048404904080409
00000000b8feef8bb8feef8b33333333333333336666666aa666666677777777666666665555555544444444bbbbbbbb66666666666666660706070647464746
00000000b1d88d1bb1d88d1b33333333333333336666666aa666666677777777666666665555555544444444bbbbbbbb66666666666666664046404604060406
00000000ffd11dfbbfd11dfb33333333333333336666666aa666666677777777666666665555555544444444bbbbbbbb66666666666666666666666666666666
00000000bb2222bfbf2222fb00000000000000000000000000000000333333332222222211111111000000003ccccccc00000000000000000000000000000000
00000000bbfbbfbbbbfbbfbb00000000000000000000000000000000333333332222222211111111000000003333333300000000000000000000000000000000
00000000bfbbbbfbbbfbbfbb00000000000000000000000000000000333333332222222211111111000000003333333300000000000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000000000000000000000000000333333332222222211111111000000003333333300000000000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000000000000000000000000000333333332222222211111111000000003333333300000000000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000000000000000000000000000333333332222222211111111000000003333333300000000000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000000000000000000000000000333333332222222211111111000000003333333300000000000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000000000000000000000000000333333332222222211111111000000003333333300000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000007b7b0000000000000000000000007b7b74777477
6666666666666666666666666666666600000000000000000000000000000000000000000000000000000000b7b0d666666666666666666666d707b747774774
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000007b07ddddddddddddddddddddddd7d07b77777777
6666666666666666666666666666666600000000000000000000000000000000000000000000000000000000b0d7d666666666666666666666d7d70747477747
666666666666666666666666666666660000000000000000000000000000000000000000000000000000000007d7d000000000000000000000d7d7d077777777
666666666666666666666666666666660000000000000000000000000000000000000000000000000000000007d7066666666666666666666607d7d077744774
666666666666666666666666666666660000000000000000000000000000000000000000000000000000000007d7066000077777d0000dd00000d7d077777777
6666666aaaa66aaaaaa66aaaa66666660000000000000000000000000000000000000000000000000000000007d066077670777707767007767007d077747774
6666666aaaa66aaaaaa66aaaa6666666000000000000000077888877778888777778888700000000111111060000670767d077770767d00767d060007b777b7b
6666666aa66666666666666aa666666600000000000000007888888778888887778888880000000011111066b70677067dd07777067dd0067dd060b7b7b7b7bb
6666666aa66666666666666aa66666660000000000000000f880088ff880088f888f880000000000111100667b067760000d7777d0000dd0000d607b7b7b7b7b
666666666666666666666666666666660000000000000000ffffffffffffffff77ffffff0000000011106066b70611111111111111111111111660b7bbb77bb7
6666666666666666666666666666666600000000000000007f1ff1f77f1ff1f77bffff1f00000000110660667b07dddddddddddddddddddddddd707b77b7b7b7
6666666aa66666666666666aa66666660000000000000000777777777affffae7bbffffe0000000010066066b707dddddddddddddddddddddddd70b77b7bbb7b
6666666aa66666666666666aa6666666000000000000000077777777e7cccc7777ccccc700000000060660667b00000000000000000000000000007bb7bbb7b7
6666666aa66666666666666aa666666600000000000000007777777777772277777722770000000066066066b70666660666666066666666666660b7777b7b7b
6666666aa66666666666666aa66666660000000000000000788887777888877777888877000000000d7777d07b0777770dddddd0d0000dd0000d707b76777676
6666666aa66666666666666aa666666600000000000000008888887788888877788888870000000000000000b70776660d5656d0077d70077d7070b767676766
6666666666666666666666666666666600000000000000000088f8880088f888f880088f000000000d7777d07b0777770ddddd000767d00767d0707b76767676
666666666666666666666666666666660000000000000000ffffff77ffffff77ffffffff0000000000000000b70777770dddd070067dd0067dd070b766677667
6666666aa66666666666666aa66666660000000000000000f1ffffb7f1ffffb77f1ff1f7000000000d7777d07b0666660d666600d0000dd0000d707b77676767
6666666aa66666666666666aa66666660000000000000000effffab7effffab7eaffffa70000000000000000b70776660dddddd066666666666670b776766676
6666666aaaa66aaaaaa66aaaa666666600000000000000002ccccc777ccccc7777cccc7e000000000d7777d07b700000000000000000000000000b7b67666767
6666666aaaa66aaaaaa66aaaa666666600000000000000002277227777227777772277770000000000000000b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b777767676
6666666666666666666666666666666600000000000000007788887777788887778888770000000000000000b70777770dddddd0d0000dd07777777777777770
666666666666666666666666666666660000000000000000788888877788888878888887000000000d7777d07b0776660dddddd0077d70077777777770000000
666666666666666666666666666666660000000000000000f888888f888f8800f888888f0000000000000000b70777770ddddd000767d0077777777707070700
666666666666666666666666666666660000000000000000ff8888ff77ffffffff8888ff000000000d7777d07b0777770dddd07d067dd006773e777700000000
6666666666666666666666666666666600000000000000007ffbbff77bffff1f7ffbbff70000000000000000b70666660ddddd00d0000dd07777777707070700
666666666666666666666666666666660000000000000000fab33ba77baffffe7ab33baf000000000d7777d07b0dd6660dddddd07d7d7d667777777700000000
66666666666666666666666666666666000000000000000077cbbc7f77ccccc2f7cbbc770000000000000000b7b0000000000000000000007777777707070700
666666666666666666666666666666660000000000000000772277777722772277772277000000000d7777d07b7b7b7b066666607d7d7d66773e777770000000
00777777777444444444444444444444444444477777777700000000000000000000000000000000000000000000000011111111111111111111111100000000
00777777774ffffffffffffffffffffffffffff4777777770000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
0077777774ffccbff3fff3f333f33333f33333ff477777770000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
007777774ffbccbbf33ff3f3fffff3fffff3fffff47777770000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
007777774ffbbcccf3f3f3f333fff3fffff3fffff47777770000000000000000000000000000000000000000000000001dd7ccc7ccc7ccc7ccc7cdd100000000
007777774ffbbcbcf3ff33f3fffff3fffff3fffff47777770000000000000000000000000000000000000000000000001ddc7c7c7c7c7c7c7c7c7dd100000000
007777774fffcccff3fff3f333fff3fffff3fffff47777770000000000000000000000000000000000000000000000001ddcc7ccc7ccc7ccc7cccdd100000000
0077777774ffffffffffffffffffffffffffffff477777770000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
00777777774ffffffffffffffffffffffffffff4777777770000000000000000000000000000000000000000000000001ddc7ccccccc7ccccccc7dd100000000
0077777777744444444444444444444444444447777777770000000000000000000000000000000000000000000000001dd7c7c7c7c7c7c7c7c7cdd100000000
0077777767647797776797977777777777777747777777770000000000000000000000000000000000000000000000001ddccc7c7c7ccc7c7c7ccdd100000000
00777777767479a976777a777777777777777747777777770000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
0077777767647797776793977777777777777747777777770000000000000000000000000000000000000000000000001dd7ccc7ccc7ccc7ccc7cdd100000000
0077777676767733767773777777777777777777777777770000000000000000000000000000000000000000000000001ddc7c7c7c7c7c7c7c7c7dd100000000
0077777767677337776733777777777777777777777777770000000000000000000000000000000000000000000000001ddcc7ccc7ccc7ccc7cccdd100000000
0077777776767737767773777777777777777777777777770000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddc7ccccccc7ccccccc7dd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd7c7c7c7c7c7c7c7c7cdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddccc7c7c7ccc7c7c7ccdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd7ccc7ccc7ccc7ccc7cdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888ffffff882222228888888888888888888888888888888888888888888888888888888888888888228228888228822888fff8ff888888822888888228888
88888f8888f882888828888888888888888888888888888888888888888888888888888888888888882288822888222222888fff8ff888882282888888222888
88888ffffff882888828888888888888888888888888888888888888888888888888888888888888882288822888282282888fff888888228882888888288888
88888888888882888828888888888888888888888888888888888888888888888888888888888888882288822888222222888888fff888228882888822288888
88888f8f8f8882888828888888888888888888888888888888888888888888888888888888888888882288822888822228888ff8fff888882282888222288888
888888f8f8f882222228888888888888888888888888888888888888888888888888888888888888888228228888828828888ff8fff888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
00000000000000003333333311111111333333331111111133333333111111113333333311111111333333331111111133333333111111113333333311111111
0000000000000000bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333
0000000000000000bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333
0000000000000000bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333
0000000000000000bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333
0000000000000000bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333
0000000000000000bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333
0000000000000000bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333
000000000000000033333333444cccccccccccc44cccccccccccccc44ccccccccccccc444cccccccccccccc4ccccccccccccccc44cccccccccccccc444cccccc
000000000000000033333333444c5555555555cc4c555555555555cc4c55555555555cc44c555555555555ccc5555555555555cc4c555555555555cc44c5555c
000000000000000033333333444c57777777756c4c5777777777756c4c577777777756c44c5777777777756cc57777777777756c4c5777777777756c44c57756
000000000000000033333333444c57777777756c4c5777777777756c4c577777777756c44c5777777777756cc57777777777756c4c5777777777756c44c57756
000000000000000033333333444c5aa5555aa56c4c55555aa555556c4c5aa555555556c44c5aa555555aa56cc55aa55555aaa56c4c5aa555555aa56c44c5aa56
000000000000000033333333444c5aa5665aa56c4cc6665aa566666c4c5aa566666666c44c5aa566665aa56ccc5aa56665aaa56c4c5aa566665aa56c44c5aa56
000000000000000033333333444c59956c59956c44cccc59956ccccc4c59956cccccccc44c59956ccc59956c4c5995555599556c4c59956ccc59956c44c59956
000000000000000033333333444c59955559956c44444c59956c44444c59956c444444444c59956c4c59956c4c5999999995666c4c59956c4c59956c44c59956
0000000000000000bbbbbbbb444c58888888856c44444c58856c44444c58856c444444444c58856c4c58856c4c58888888856ccc4c58856c4c58856c44c58856
0000000000000000bbbbbbbb444c58888888856c44444c58856c44444c58856c444444444c58856c4c58856c4c588555558855cc4c58856c4c58856c44c58856
0000000000000000bbbbbbbb444c5ee55555556c4ccccc5ee56cccc44c5ee56ccccccc444c5ee56ccc5ee56ccc5ee56665eee56c4c5ee56ccc5ee56c44c5ee56
0000000000000000bbbbbbbb444c5ee56666666c4c55555ee55555cc4c5ee55555555cc44c5ee555555ee56cc55ee55555eee56c4c5ee555555ee56c44c5ee55
0000000000000000bbbbbbbb444c52256ccccccc4c5222222222256c4c522222222256c44c5222222222256cc52222222222256c4c5222222222256c44c52222
0000000000000000bbbbbbbb444c52256c4444444c5222222222256c4c522222222256c44c5222222222256cc52222222222256c4c5222222222256c44c52222
0000000000000000bbbbbbbb444c55556c4444444c5555555555556c4c555555555556c44c5555555555556cc55555555555556c4c5555555555556c44c55555
0000000000000000bbbbbbbb444cc6666c4444444cc666666666666c4cc66666666666c44cc666666666666ccc6666666666666c4cc666666666666c44cc6666
000000000000000033333333bbbccccccc333333bcccccccccccccccbcccccccccccccc3bbbcccccccccccccbcccccccccccccccbcccccccccccccccbbbccccc
000000000000000033333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb
000000000000000033333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb
000000000000000033333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb
000000000000000033333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb
000000000000000033333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbb1bbb33333333bbbbbbbb33333333bbbbbbbb
000000000000000033333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbb171bb33333333bbbbbbbb33333333bbbbbbbb
000000000000000033333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbb1771b33333333bbbbbbbb33333333bbbbbbbb
000000000000000088888888aaaaaaaa88888888aaaaaaaa66666666666666666666666666666666666666666661777166666666666666666666666666666666
000000000000000088888888aaaaaaaa88888888aaaaaaaa66666666666666666666666666666666666666666661777716666666666666666666666666666666
000000000000000088888888aaaaaaaa88888888aaaaaaaa66666666666666666666666666666666666666666661771166666666666666666666666666666666
000000000000000088888888aaaaaaaa88888888aaaaaaaa66666666666666666666666666666666666666666666117166666666666666666666666666666666
000000000000000088888888aaaaaaaa88888888aaaaaaaa66666666666666666666666666666666666666666666666666666666666666666666666666666666
000000000000000088888888aaaaaaaa88888888aaaaaaaa66666666666666666666666666666666666666666666666666666666666666666666666666666666
000000000000000088888888aaaaaaaa88888888aaaaaaaa66666666666666666666666666666666666666666666666666666666666666666666666666666666
000000000000000088888888aaaaaaaa88888888aaaaaaaa6666666aaaa66aaaaaaa66aaaaa66aaaaaaa66aaaaa66aaaaaaa66aaaaa66aaaaaaa66aaaaa66aaa
0000000000000000aaaaaaaab6bbb888d88bbbbb888888886666666aaaa66aaaaaaa66aaaaa66aaaaaaa66aaaaa66aaaaaaa66aaaaa66aaaaaaa66aaaaa66aaa
0000000000000000aaaaaaaa656888808088bbbb888888886666666aa66666666666666666666666666666666666666666666666666666666666666666666666
0000000000000000aaaaaaaa656bb00f0f0bbbbb888888886666666aa66666666666666666666666666666666666666666666666666666666666666666666666
0000000000000000aaaaaaaab6bbff1ff1ffbbbb8888888866666666666666666666666666666666666666666666666666666666666666666666666666666666
0000000000000000aaaaaaaabffbbffffffbbbbb8888888866666666666666666666666666666666666666666666666666666666666666666666666666666666
0000000000000000aaaaaaaab6fbbbfeefbbbbbb888888886666666aa66666666666666666666666666666666666666666666666666666666666666666666666
0000000000000000aaaaaaaab6fbbbbffbbbbbbb888888886666666aa66666666666666666666666666666666666666666666666666666666666666666666666
0000000000000000aaaaaaaab6ffccccccccffbb888888886666666aa66666666666666666666666666666666666666666666666666666666666666666666666
000000000000000088888888b6bbaaaaaaaabfbbaaaaaaaa6666666aa66666667b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b
000000000000000088888888bbbbbccccccbbfbbaaaaaaaa6666666aa6666666b7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bb
000000000000000088888888bbbbbaaaaaabbffbaaaaaaaa6666666aa66666667b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b
000000000000000088888888bbbbbccccccbbbbbaaaaaaaa6666666666666666bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7
000000000000000088888888bbbbb555555bbbbbaaaaaaaa666666666666666677b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b7
000000000000000088888888b3b3b553b553b3b3aaaaaaaa66666666666666667b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b
0000000000000000888888883b3b3f3b3bfb3b3baaaaaaaa6666666aa6666666b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7
0000000000000000888888883332223333222333aaaaaaaa6666666aa6666666777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b
0000000000000000aaaaaaaa88888888aaaaaaaa888888886666666aa66666667b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b
0000000000000000aaaaaaaa88888888aaaaaaaa888888886666666aa6666666b7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bb
0000000000000000aaaaaaaa88888888aaaaaaaa888888886666666aa66666667b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b
0000000000000000aaaaaaaa88888888aaaaaaaa888888886666666666666666bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7bbb77bb7
0000000000000000aaaaaaaa88888888aaaaaaaa88888888666666666666666677b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b7
0000000000000000aaaaaaaa88888888aaaaaaaa888888886666666aa66666667b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b
0000000000000000aaaaaaaa88888888aaaaaaaa888888886666666aa6666666b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7b7bbb7b7
0000000000000000aaaaaaaa88888888aaaaaaaa888888886666666aa6666666777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b777b7b7b
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555555555555555555555555555555555555555555555555555555555555b6bbb88855555555555555555555555555555555555555555555555555
5555555555555555555555555d555555ddd5555d5d5d5d555575755555555d555555556568888056666666666666555555555555555555555555555557777755
555555555555555555555555ddd55555ddd555555555555555757575555555d5555555656bb00f56ddd6ddd6dd66555556666655566666555666665577eee775
55555555555555555555555ddddd5555ddd5555d55555d55557575755555555d555555b6bbff1f56d6d6d6d66d66555566ddd66566dd666566ddd665777ee775
5555555555555555555555ddddd55555ddd55555555555555577777555ddddddd55555bffbbfff56d6d6d6d66d66555566d6d665666d66656666d6657777e775
555555555555555555555d5ddd5555ddddddd55d55555d55757777755d5ddddd555555b6fbbbfe56d6d6d6d66d66555566d6d665666d666566d6666577eee775
555555555555555555555d55d55555d55555d55555555555577777755d55ddd5555555b6fbbbbf56ddd6ddd6ddd6555566ddd66566ddd66566ddd66577777775
555555555555555555555ddd555555ddddddd55d5d5d5d55555777555d555d55555555b6ffcccc56666666666666555566666665666666656666666577777775
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddddddd5ddddddd5ddddddd5eeeeeee5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000555555555555555555555555555500000000000000000000000000000000000000000000000000000000011111111111111111111111100000000
0000000000566666666666666666666666666665000000000000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
000000000566ccb6696669699969999969999966500000000000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
00000000566bccbb699669696666696666696666650000000000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
00000000566bbccc696969699966696666696666650000000000000000000000000000000000000000000000000000001dd7ccc7ccc7ccc7ccc7cdd100000000
00000000566bbcbc696699696666696666696666650000000000000000000000000000000000000000000000000000001ddc7c7c7c7c7c7c7c7c7dd100000000
000000005666ccc6696669699966696666696666650000000000000000000000000000000000000000000000000000001ddcc7ccc7ccc7ccc7cccdd100000000
0000000005666666666666666666666666666666500000000000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
0000000000566666666666666666666666666665000000000000000000000000000000000000000000000000000000001ddc7ccccccc7ccccccc7dd100000000
0000000000055555555555555555555555555550000000000000000000000000000000000000000000000000000000001dd7c7c7c7c7c7c7c7c7cdd100000000
0000000000050000000000000000000000000050000000000000000000000000000000000000000000000000000000001ddccc7c7c7ccc7c7c7ccdd100000000
0000000000050000000000000000000000000050000000000000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
0000000000050000000000000000000000000050000000000000000000000000000000000000000000000000000000001dd7ccc7ccc7ccc7ccc7cdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddc7c7c7c7c7c7c7c7c7dd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddcc7ccc7ccc7ccc7cccdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddc7ccccccc7ccccccc7dd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd7c7c7c7c7c7c7c7c7cdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddccc7c7c7ccc7c7c7ccdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddccccccccccccccccccdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd7ccc7ccc7ccc7ccc7cdd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dddddddddddddddddddddd100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88282822282228282888882828888822282228222888882828888822282228228888888888888888888888888888888888888888888888888888888888888888
88282882882888282888882828828828282828882888882828828828282828828888888888888888888888888888888888888888888888888888888888888888
88282882882288282888888288888828282828822888882228888828282828828888888888888888888888888888888888888888888888888888888888888888
88222882882888222888882828828828282828882888888828828828282828828888888888888888888888888888888888888888888888888888888888888888
88828822282228222888882828888822282228222888882228888822282228222888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000c7c7c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000577757775777577757775777577757775777577700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004646000077030405060708090a0b0c090a0d0e21222324579faf9faf9faf9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004646000057131415161718191a1b1c191a1d1e3132333477afc1c2c3c4c5af000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00460000007736355b4c5b4b364c5b4c5b4c364b5b4b6b35579fd1d2d3d4af9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005a585a5880815c5d5c5d5c5d5c5d5c5d5c5d8283af9faf9faf9faf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005801025a90916c6d6c6d6c6d6c6d6c6d6c6d92939faf9faf9faf9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005a1112585556cccdcdcdcdcdcdcdcdcdcdce55568b8c8d8eaf9faf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000585a585a6566ecededededededededededee65669b9c9d9e9faf9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005556abacadaeafafaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000055569f8f9f9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000055569f9f9f9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001005000000000001e05021050210501c0501b050074500645006450180501a0501d0501e050200502105022050220501d0501e0501e0501d0501c0500875008750097500975006750000000000000000
0010000000000000001c0501c0501c0501c0501e0501e0501e0501e05020050200502005020050230502305023050230501e0501e0501e0501e0501e0501e0501e0501e0501e0501e0501e0501e0501e05000000
001000000000028050280502805028050270502705027050270502505025050250502505020050200502005020050230502305023050230502305023050230502305023050230502305023050230502305000000
00100000000001c1001c4501c4501c4501c4501c4501c4501c4501c4501c4501c4501c4501c4501c4001c4001d4001b4001b4501b4501b4501b4501b4501b4501b4501b4501b4501b4501b4501b4500000000000
001000000000000000194501945019450194501945019450194501945019450194501945019450194501945000000000001745017450174501745017450174501745017450174501745017450174501740017400
0010000025050250502505025050270502705027050270502805028050280502805023050230502305023050230502305023050230501c0501c0501c0501c0501c0501c0501c0501c0501c050000000000000000
000500000000026350263501d3501d35026350263501d3501d350000000000000000000000f3500f350103500f3500f3501035000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01034344
00 02044344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

