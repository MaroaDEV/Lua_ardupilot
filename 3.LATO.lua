-- Ce script permet une limitation dynamique des niveaux de gaz

-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8, l'argument doit être la fonction du servo et non son channel
local MOTOR5_FUN = 33
local MOTOR6_FUN = 34 
local MOTOR7_FUN = 35 
local MOTOR8_FUN = 36 

local PWM_sum = 0
local delay_1min = 1*60*1000 
local looper = 10
local bat_v = 50
local pwm_max = 2000
local Q_M_PWM_MAX = Parameter() -- Accède et modifie ce paramètre
Q_M_PWM_MAX:init('Q_M_PWM_MAX')      


function state_init()
   gcs:send_text(6, '3.Remote LATO for bidir')
   return state_safe, 500
end

function state_safe()

    if not arming:is_armed() then
        -- Définir les valeurs PWM des canaux des servos pour les moteurs 5, 6, 7 et 8 à 0
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1000, 3000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1000, 3000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1000, 3000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1000, 3000)  -- 2000 ms de timeout

        notify:play_tune('T120 L8 O5 C D E')

        return state_safe, 2000
    end



end

function state_safe0()
   if looper < 9 then
        looper = looper + 1 --les script proposent un delay max de return de 1 min, je veux 10 alors je rajoute un loop counter pour executer une fois sur 10
        return state_safe, delay_1min
   end
   looper = 0
   last_state = 0
   bat_v = battery:voltage(0)
   pwm_max = 2000
   pwm_sum = SRV_Channels:get_output_pwm(MOTOR5_FUN) + SRV_Channels:get_output_pwm(MOTOR6_FUN) + SRV_Channels:get_output_pwm(MOTOR7_FUN) + SRV_Channels:get_output_pwm(MOTOR8_FUN)
   if quadplane:in_vtol_mode() or pwm_sum > 4010 then 
        return state_vtol, delay_1min -- on ne veut pas changer la limitation pendant que l'utilisation des moteurs
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
   pwm_sum = SRV_Channels:get_output_pwm(MOTOR5_FUN) + SRV_Channels:get_output_pwm(MOTOR6_FUN) + SRV_Channels:get_output_pwm(MOTOR7_FUN) + SRV_Channels:get_output_pwm(MOTOR8_FUN)
   if quadplane:in_vtol_mode() or pwm_sum > 4010 then  
        return state_vtol, delay_1min
   end
   return state_safe, delay_1min
end

-- Démarrer avec state_safe
return state_init()