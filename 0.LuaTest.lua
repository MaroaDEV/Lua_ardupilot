-- Ce script permet de se rassurer sur les comportements 

-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR3_CHANNEL = 3
local SERVO_FUNCTION = 70 -- 70 est assigné au throttle

local last_state = 0

local i = 0

function state_init()
   gcs:send_text(6, '0.LuaTest script initiated')
   return state_safe, 5500
end

function state_safe()
   last_state = 0
   local a = SRV_Channels:get_emergency_stop()
   if a then
      gcs:send_text(0, 'a')
   end
   local b = SRV_Channels:get_safety_state()
   if b then
      gcs:send_text(0, 'b')
   end
   i = i+1
   if i==20 then
	return state_2()
   end 
   return state_safe, 2000
end

function state_2()
   last_state = 1
   esc_telem:update_rpm(2,300,0)
   return state_2, 60000
end

-- Start with state_safe
return state_init()