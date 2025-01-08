-- Ce script permet de se rassurer sur les comportements 

-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR3_CHANNEL = 3
local SERVO_FUNCTION = 70 -- 70 est assigné au throttle

local last_state = 0

function state_init()
   gcs:send_text(6, '0.LuaTest script initiated')
   return state_safe, 10000
end

function state_safe()
   last_state = 0
   gcs:send_text(0, 'C3 PWM ='..SRV_Channels:get_output_pwm(SERVO_FUNCTION))
   gcs:send_text(0, 'asp0 ='..airspeed:get_raw_airspeed(0))
   gcs:send_text(0, 'asp1 ='..airspeed:get_raw_airspeed(1))
   gcs:send_text(0, 'temp1 ='..airspeed:get_temperature(1))
   return state_safe, 2000
end

function state_2()
   last_state = 1
   gcs:send_text(0, 'C3 (PWM) ='..SRV_Channels:get_output_pwm(SERVO_FUNCTION))
   return state_2, 60000
end

-- Start with state_safe
return state_init()
