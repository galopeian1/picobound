### picobound.p8

Earthbound implemented in [Pico-8](https://www.lexaloffle.com/pico-8.php) 
Forked and inspired by [Pico Monsters 1.11](https://www.lexaloffle.com/bbs/?pid=27211&tid=4046)

### code snippet
```lua
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

local elementalsprites = {
	bird = 22,
	alien = 13,
	reptile = 24,
	human = 15,
 canine = 36,
 evil_child = 1
}

local intypes = {}
local k = 0
for v in all(enemies) do
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

```
### example pico-8 .gif

![Image](https://github.com/galopeian1/picobound/blob/master/PICO-8_4.gif)



