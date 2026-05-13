pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
local food = {x=0, y=0}
local player = {{x=8, y=8}}
local dir = {x=-1, y=0}
local delay = 10
local tick = 0
local score = 0
local over = false

function spawn_food()
  food.x = flr(rnd(16))
  food.y = flr(rnd(16))
end

function _init()
  spawn_food()

  player.x = flr(rnd(16))
  player.y = flr(rnd(16))
end

function _update()
  local head = player[1]

  if over then
    return
  end

  // Handle buttons
  if btn(0) then dir = {x = -1, y = 0} end
  if btn(1) then dir = {x = 1, y = 0} end
  if btn(2) then dir = {x = 0, y = -1} end
  if btn(3) then dir = {x = 0, y = 1} end

  // Handle score increase
  if head.x == food.x and head.y == food.y then
    sfx(0)
    spawn_food()
    score += 1
    local tail = player[#player]
    add(player, {x=tail.x, y=tail.y})
    // sqrt curve: fast speedup early, levels off; floor 2 keeps game playable
    delay = max(2, flr(10 - sqrt(score)))
  end

  // Handle game over
  if head.x > 15 or head.x < 0 or head.y > 15 or head.y < 0 then
    sfx(1)
    over = true
  end

  // Handle player position change
  if tick < delay then
      tick += 1
      return
  end
  tick = 0

  for i = #player, 2, -1 do
    player[i].x = player[i-1].x
    player[i].y = player[i-1].y
  end

  head.x += dir.x
  head.y += dir.y
end

function _draw()
  cls()
  rect(0, 0, 127, 127, 5)

  // hud: drop shadow keeps text legible when snake passes underneath
  local sc_text = "score "..score
  local lvl_text = "level "..(11 - delay)
  local lvl_x = 127 - #lvl_text * 4
  print(sc_text, 3, 2, 0)
  print(sc_text, 2, 1, 7)
  print(lvl_text, lvl_x + 1, 2, 0)
  print(lvl_text, lvl_x, 1, 10)

  if over then
    print("game over", 45, 64, 7)
    return
  end

  spr(0, food.x * 8, food.y * 8)
  for i, seg in ipairs(player) do
    spr(i == 1 and 1 or 2, seg.x * 8, seg.y * 8, 1, 1, dir.x == 1, dir.y == 1)
  end
end
__gfx__
00330000333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000307333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08883880300333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88989898333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
89898988333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880888333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000500003105031030310103100031000310003100031000310003100031000310003100031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002b01014020100300c04004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
