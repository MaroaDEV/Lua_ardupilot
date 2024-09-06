-- Ce script permet une limitation dynamique des niveaux de gaz

local delay_1min = 1*60*1000 
local looper = 10
local bat_v = 50
local pwm_max = 2000
local Q_M_PWM_MAX = Parameter()
Q_M_PWM_MAX:init('Q_M_PWM_MAX')       --get the physical location in parameters memory area so no future name search is done


function state_init()
   gcs:send_text(6, '2.7SLimitations script initiated')
   return state_safe, 500
end

function state_safe()
   if looper < 9 then
        looper = looper + 1 --les script proposent un delay max de return de 1 min, je veux 10 alors je rajoute un loop counter pour executer une fois sur 10
        return state_safe, delay_1min
   end
   looper = 0
   last_state = 0
   bat_v = battery:voltage(0)
   pwm_max = 2000
   if quadplane:in_vtol_mode() then 
        return state_vtol, delay_1min
   end
   if bat_v > 50.4 then 
        pwm_max = 1000 + (50.4/bat_v) * 1000
   end
   if pwm_max < 1857 then
        pwm_max = 1857
   end
   Q_M_PWM_MAX:set(pwm_max)
   gcs:send_text(6, '2.7SLimitations set '..pwm_max)
   return state_safe, delay_1min
end

function state_vtol()
   if quadplane:in_vtol_mode() then 
        return state_vtol, delay_1min
   end
   return state_safe, delay_1min
end

-- Démarrer avec state_safe
return state_init()