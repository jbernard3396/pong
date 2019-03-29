pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--main_scope
function _init()
 display_menu()
end

function _update()
 if not game_state.begun then
  navigate_menu()
  change_scheme()
 else
 	move_ball()
 	move_player(player1)
 	move_player(player2)
 	check_win()
 	get_restart()
 end
end

function _draw()
 cls()
 if not game_state.begun then
  draw(menu_object)
 else
  draw(field)
  draw(scoreboard)
  draw(ball)
  draw(player1)
  draw(player2)
  draw(decorations)
  effect(decorations)
 end
 --debug()
end

	
-->8
--macro
function start_game(p2)
 game_state.begun = true
 create_field(scheme)
 create_scoreboard(scheme)
	create_ball(scheme)
	create_players(scheme, p2)
	create_decorations(scheme)
	create_coroutines()
end

function display_menu()
 choose_scheme()
 create_game_state()
 create_menu_obj()
end

-->8
--update
function navigate_menu()
 if not game_state.begun then
  if btnp(3) then
   menu_object.selector_position = lua_mod((menu_object.selector_position)+1, 5)
  end
  if btnp(2) then
   menu_object.selector_position = lua_mod((menu_object.selector_position)-1, 5)
  end
  if btnp(4) then
   p2 = function()
    
   end
   if (menu_object.optionsname[menu_object.selector_position] == 'human') then
    p2 = function()
     human(player2, 1, 0)
    end
   end
   if (menu_object.optionsname[menu_object.selector_position] == 'easy ai') then
    p2 = function()
     easy_ai(player2)
    end
   end
   if (menu_object.optionsname[menu_object.selector_position] == 'med ai') then
    p2 = function()
     med_ai(player2)
    end
   end
   if (menu_object.optionsname[menu_object.selector_position] == 'hard ai') then
    p2 = function()
     hard_ai(player2)
    end
   end
   start_game(p2)
  end
 end
end

function change_scheme()
 if btnp(5) then
  scheme+=1
 end
end

function move_ball()
 if (ball_c and costatus(ball_c)) then
  coresume(ball_c)
 end
end

function ball_coroutine()
 ball_c = cocreate(function()
  while true do
   ball.x += ball.mvx
   ball.y += ball.mvy
   if out_y(ball.y) then --cieling or floor
    ball.y = in_y(ball.y)
    ball.mvy = -ball.mvy
   end
   if hit_paddle() then
    ball_bounce = true
    if ball.mvx < 0 then
     ball.hits += 1
    end
    ball.mvy = ball.mvy + paddle_bounce(hit_paddle())/10
    ball.mvx = max(min(-ball.mvx*1.05, 10), -10)
    ball.x += abs(ball.mvx)/ball.mvx  
   end
   if out_x(ball.x) then --point
    if in_x(ball.x) == 0 then
     scoreboard.scorep2 += 1
    else
     scoreboard.scorep1 += 1
    end
    reset_ball()
   end
   yield()
  end
 end)
end

function move_player(p)
 if ball and ball.mvx < 0 then
  
 end
 if p.controls[1]() then
  p.y += p.spd
 elseif p.controls[2]() then
  p.y -= p.spd
 end
 p.y = in_y(p.y)
end

function check_win()
 if scoreboard.scorep1 >= scoreboard.goal then
  victory(player1)
 end
 if scoreboard.scorep2 >= scoreboard.goal then
  victory(player2)
 end
end

function get_restart()
 if game_state.over and btn(4) then
  game_state.over = false
  game_state.begun = false
  scoreboard.scorep1 = 0
  scoreboard.scorep2 = 0
  ball.x = 64
  ball.y = 64
  decorations.draw = {}
 end
end



-->8
--init
function create_game_state()
 game_state = {}
 game_state.begun = false
 game_state.over = false
end

function create_menu_obj()
 menu_object = {}
 menu_object.draw = {}
 menu_object.clr = 6
 menu_object.optionsy = {80, 90, 100, 110}
 menu_object.optionsname = {'human', 'easy ai', 'med ai', 'hard ai'}
 menu_object.selector_position = 1
 title = function()
  print('pong', 58, 30, menu_object.clr+scheme)
  print("press 'x' for color", 30, 40, menu_object.clr+scheme)
  print("press 'c' to begin" , 32, 50, menu_object.clr+scheme)
 end
 options = function()
  print('vs.'..menu_object.optionsname[1], 48, menu_object.optionsy[1], menu_object.clr +scheme)
  print('vs.'..menu_object.optionsname[2], 48, menu_object.optionsy[2], menu_object.clr +scheme)
  print('vs.'..menu_object.optionsname[3], 48, menu_object.optionsy[3], menu_object.clr +scheme)
  print('vs.'..menu_object.optionsname[4], 48, menu_object.optionsy[4], menu_object.clr +scheme)
 end
 selector = function()
  rect(46, menu_object.optionsy[menu_object.selector_position]-2, 94, menu_object.optionsy[menu_object.selector_position]+6, 10+scheme)
 end
 background = function() 
  rectfill(0,0,128,128,7+scheme) 
 end
 add(menu_object.draw, background)
 add(menu_object.draw, title)
 add(menu_object.draw, options)
 add(menu_object.draw, selector)

end

function choose_scheme()
 scheme = random(0,15) --default 10
end

function create_field(scheme)
	field = {}
	field.draw = {}
	field.borderclr = 7+scheme
	field.centerclr = 12+scheme
 border = function() 
  rectfill(0,0,128,128,field.borderclr) 
 end
 center_line = function() 
  line(64,0,64,128,field.centerclr)
  circ(64,64,5,field.centerclr)
 end
 add(field.draw, border)
 add(field.draw, center_line)
end

function create_players(scheme, p2)
 player1 = {}
 player2 = {}
 player1.draw = {}
 player2.draw = {}
 player1.name = "p1"
 player2.name = "p2"
 player1.x = 4
 player2.x = 123
 player1.y = 64
 player2.y = 64
 player1.spd = 2
 player2.spd = 2
 player_clr = 6+scheme
 player_half_length = 6
 player_half_width = 1
 human(player1, 3,2)
 p2()
 draw_p1 = function()
  rectfill(player1.x-player_half_width, player1.y-player_half_length, player1.x+player_half_width, player1.y+player_half_length, player_clr) 
 end
 draw_p2 = function()
  rectfill(player2.x-player_half_width, player2.y-player_half_length, player2.x+player_half_width, player2.y+player_half_length, player_clr) 
 end
 add(player1.draw, draw_p1)
 add(player2.draw, draw_p2)
end

function create_ball(scheme)
 ball = {}
 ball.draw = {}
 ball.hits = 0
 ball.grace = max(scoreboard.scorep2 - scoreboard.scorep1, 1)
 ball.clr = 4+scheme
 ball.mvx = -1
 ball.mvy = random(-100, 100)/100
 ball.x = 64
 ball.y = 64
 ball.r = 2
 ball.d = 2*ball.r
 draw_ball = function()
  circfill(ball.x,ball.y, ball.r, ball.clr)
 end
 add(ball.draw, draw_ball)
end

function create_scoreboard(scheme)
 scoreboard = {}
 scoreboard.draw = {}
 scoreboard.scorep1 = 0
 scoreboard.scorep2 = 0
 scoreboard.goal = 10
 scoreboard.gameover = false
 scoreboard.xp1 = 28
 scoreboard.yp1 = 2
 scoreboard.xp2 = 97
 scoreboard.yp2 = 2
 scoreboard.clr = 8+scheme
 p1score = function()
 	print(scoreboard.scorep1, scoreboard.xp1, scoreboard.yp1, scoreboard.clr)
 end
 p2score = function()
  print(scoreboard.scorep2, scoreboard.xp2, scoreboard.yp2, scoreboard.clr)	
 end
 add(scoreboard.draw, p1score)
 add(scoreboard.draw, p2score) 
end

function create_decorations(scheme)
 decorations = {}
 decorations.draw = {}
 decorations.effects = {}
 ball_bounce = false
 bounce_effect = function()
  if (ball_bounce) then
   explosion(ball.x, ball.y)
   ball_bounce = false
  end
 end
 add(decorations.draw, bounce_effect)
end

function create_coroutines()
 ball_coroutine()
end
-->8
--helpers
function random(low, hi)
 diff = (hi-low)+1 --we want to include both hi and low
 return flr(rnd(diff)+low)
end

function draw(list)
 for element in all(list.draw) do
  element()
 end
end

function effect(list)
 for element in all(list.effects) do
  if costatus(element) then
   coresume(element)
  end
 end
end

function out_y(y)
 return y<0 or y>128
end

function in_y(y)
 if not out_y(y) then
  return y
 elseif y < 0 then
  return 0
 else 
  return 128
 end
end

function out_x(x)
 return x<0 or x>128
end

function in_x(x)
 if not out_x(x) then
  return x
 elseif x < 0 then
  return 0
 else 
  return 128
 end
end

function hit_paddle()
 if (ball.x > player1.x-player_half_width-ball.r and ball.x < player1.x+player_half_width+ball.r) then
  if (ball.y > player1.y-player_half_length-ball.d and ball.y < player1.y+player_half_length+ball.d) then
   return player1
  end
 end
 if (ball.x < player2.x+player_half_width+ball.r and ball.x > player2.x-player_half_width-ball.r) then
  if (ball.y > player2.y-player_half_length-ball.d and ball.y < player2.y+player_half_length+ball.d) then
   return player2
  end
 end
 return false  
end

function paddle_bounce(p)
 return ball.y - p.y
end

function reset_ball()
 create_ball(scheme)
end

function victory(p)
 game_state.over = true
 background = function()
  rectfill(0,0,128,128,scheme)
 end
 reward = function ()
  print(p.name..'wins', 50, 50, 6+scheme)
  print('press "c" to restart', 30, 60, 6+scheme)
 end
 add(decorations.draw, background)
 add(decorations.draw, reward)
end

function lua_mod(num, mod)
 if num == 0 then
  return mod-1
 elseif num == mod then
  return 1
 else 
  return num
 end
end

function explosion()
 local c = cocreate(function()
  local x = ball.x
  local y = ball.y
  local size = max((abs(ball.mvy)+abs(ball.mvx))*5, 5)
  for i = 1, size do
  working = i
   --circ(x, y, i, scheme+3) --should create a function that calls this function
   yield()
  end
 end)
 add(decorations.effects, c)
end

function draw_path(p, visible)
 if not ball then
  return
 end
 local bx = ball.x
 local by = ball.y
 local p1y = player1.y
 local p2y = player2.y
 local bmvx = ball.mvx
 local bmvy = ball.mvy
 limit = 0
 if p == 0 then
  limit = abs((ball.x-player1.x-5)/ball.mvx)
 elseif p == 1 then
  limit = (player2.x-2-ball.x)/ball.mvx
 elseif p == 3 then
  limit = abs((ball.x-player1.x-5)/ball.mvx)+(((player2.x-2-ball.x))/ball.mvx)
 end
 for i = 0, limit do
  if (ball_c and costatus(ball_c)) then
   coresume(ball_c) 
   pset(ball.x, ball.y, scheme+2)
   player1.y = ball.y
   player2.y = ball.y
  end
 end
 end_y = ball.y --localize
 ball.x = bx
 ball.y = by
 ball.mvx = bmvx
 ball.mvy = bmvy
 player1.y=p1y
 player2.y=p2y
 return end_y
end
-->8
--players
function human(p, up, down)
 p.kind = 'human'
 p.controls = {}
 mv_up = function()
  return btn(up)
 end
 mv_down = function ()
  return btn(down)
 end
 add(p.controls, mv_up)
 add(p.controls, mv_down)
end

function med_ai(p)
 p.kind = 'med_ai'
 p.controls = {}
 mv_up = function()
  return ball.y > p.y + p.spd
 end
 mv_down = function()
  return ball.y < p.y - p.spd
 end
 add(p.controls, mv_up)
 add(p.controls, mv_down)
end

function easy_ai(p)
p.kind = 'easy_ai'
 p.controls = {}
 dist = 32
 mv_up = function()
  if abs(ball.x-abs(p.x)) > dist then
   return false
  end
  return ball.y > p.y + p.spd
 end
 mv_down = function()
	 if abs(ball.x-abs(p.x)) > dist then
   return false
  end
  return ball.y < p.y - p.spd
 end
 add(p.controls, mv_up)
 add(p.controls, mv_down)
end

function hard_ai(p)
 p.kind = 'hard_ai'
 p.controls = {}
 mv_up = function()
  if ball.mvx > 0 then
   prediction = draw_path(1, false)
   return prediction > p.y + p.spd
  else 
   prediction = draw_path(3, false)
   return prediction > p.y + p.spd
  end
 end
 mv_down = function()
  if ball.mvx > 0 then
   prediction = draw_path(1, false)
   return prediction < p.y - p.spd
  else 
   prediction = draw_path(3, false)
   return prediction < p.y - p.spd
  end
 end
 add(p.controls, mv_up)
 add(p.controls, mv_down)
end
-->8
--debug
function debug()
 if ball then
  print(ball.hits, 20, 20, 7)
  print(ball.grace, 20, 30, 7)
  print(ball.mvx, 20, 40, 7)
 end

end
-->8
--docs
--seperate ball from line drawing

