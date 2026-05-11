# PICO-8 Snake Game Plan

## Overview
A classic Snake game as a PICO-8 cartridge with score tracking, high score persistence, speed scaling, and sound effects.

## Specifications
- **Grid:** 16×16 cells, each 8×8 pixels on the 128×128 screen
- **Features:** score display, high score (cartdata), speed increase, sound effects

## File Structure

Two files — all game logic lives in `snake.lua`; the cartridge only wires up PICO-8 callbacks.

### `snake.p8` (thin shell)
```
pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
#include snake.lua

function _init()   game_init()   end
function _update() game_update() end
function _draw()   game_draw()   end
__sfx__
  ... two sound effects ...
```

### `snake.lua` (all logic)
Defines `game_init()`, `game_update()`, `game_draw()`, plus helpers (`new_game`, `move_snake`, `spawn_food`, `on_snake`). No PICO-8 lifecycle hooks live here.

---

## Data Model

| Variable | Type | Purpose |
|---|---|---|
| `snake` | table of `{x,y}` | Body segments; `[1]` = head, `[#snake]` = tail |
| `dx, dy` | int | Current movement direction |
| `ndx, ndy` | int | Buffered next direction (prevents 180° reversal) |
| `food` | `{x,y}` | Current apple position |
| `score` | int | Apples eaten this game |
| `hi` | int | All-time best score (persisted in cartdata slot 0) |
| `state` | string | `"play"` or `"over"` |
| `timer` | int | Frame counter driving move cadence |
| `delay` | int | Frames between moves (controls speed) |

---

## Speed Formula
- Start: `delay = 8` (~3.75 moves/sec at 30fps)
- Every 5 apples eaten: `delay -= 1`
- Minimum: `delay = 3`

---

## Core Functions

### `game_init()`
- `cartdata("picosnake_v1")` — enables persistent storage
- Load hi score from `dget(0)`
- Call `new_game()`

### `new_game()`
- Place snake at center (positions 10,8 → 9,8 → 8,8) moving right
- Reset score, timer, delay
- Call `spawn_food()`

### `game_update()` (30fps)
- On game over: wait for btn(4) / X button → restart
- Read arrow keys → set `ndx/ndy` (block 180° reversal)
- Increment `timer`; when `timer >= delay` → call `move_snake()`, reset timer

### `move_snake()`
- Apply `ndx/ndy` → `dx/dy`
- Compute new head position
- Wall collision → game over + sfx(1)
- Self collision → game over + sfx(1)
- If new head == food: grow (keep tail), score++, update hi score, `dset(0, hi)`, `spawn_food()`, maybe decrease delay, play sfx(0)
- Else: `table.remove(snake)` (remove tail)
- `table.insert(snake, 1, newHead)` (prepend head)

### `spawn_food()`
- Pick random cell not occupied by snake (retry loop)

### `game_draw()`
- `cls(0)` — black background
- Food: `rectfill` in red (color 8), inset by 1px
- Snake: head in light green (color 11), body in dark green (color 3), full 8×8 cell
- HUD: score top-left, hi score top-right in white (color 7)
- Game over: dark box with white border, "game over" + "press x to play again"

---

## Sound Effects (in `__sfx__` section of snake.p8)

| sfx | Trigger | Style |
|---|---|---|
| sfx(0) | Eat food | Short high-pitched blip (speed 5, high pitch) |
| sfx(1) | Game over | Descending 3-note phrase (speed 15) |

---

## Controls

| Button | PICO-8 id | Action |
|---|---|---|
| ← | btn(0) | Move left |
| → | btn(1) | Move right |
| ↑ | btn(2) | Move up |
| ↓ | btn(3) | Move down |
| Z / X | btn(4) | Restart on game over |

---

## Colors Used

| Color index | Color | Usage |
|---|---|---|
| 0 | Black | Background |
| 3 | Dark green | Snake body |
| 6 | Cyan | "press x" text |
| 7 | White | HUD text, game over border |
| 8 | Red | Food |
| 11 | Light green | Snake head |

---

## Verification Checklist
1. Load `snake.p8` in PICO-8 and run (Ctrl+R)
2. Snake starts moving right; arrow keys steer; 180° turns are blocked
3. Eat food → score increments, snake grows, eat sound plays
4. Hit wall or self → game over screen + sound
5. Press X → game restarts
6. High score persists after reload
7. Speed increases noticeably every 5 apples
