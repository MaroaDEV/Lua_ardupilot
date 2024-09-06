-- Ce script permet un arret d'urgence des moteurs verticaux en cas de déclenchement parachute

-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR5_CHANNEL = 5
local MOTOR6_CHANNEL = 6  
local MOTOR7_CHANNEL = 7  
local MOTOR8_CHANNEL = 8  

local last_state = 0
local SERVO_FUNCTION = 27 -- 27 est assigné au parachute

function state_init()
   gcs:send_text(6, '1.EmergencyMotorStop script initiated')
   return state_safe, 500
end

function state_safe()
   last_state = 0
   if SRV_Channels:get_output_pwm(SERVO_FUNCTION) >= 1999 and SRV_Channels:get_output_pwm(SERVO_FUNCTION) <= 2001 then
      return state_para, 500
   end
   return state_safe, 500
end

function state_para()

    -- Définir les valeurs PWM des canaux des servos pour les moteurs 5, 6, 7 et 8 à 0
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1000, 2000)  -- 2000 ms de timeout

    if last_state == 0 then
        -- Envoyer un message de confirmation
        gcs:send_text(0, 'Motors stopped after parachute released')
    end
    last_state = 1

   return state_para, 500
end

-- Démarrer avec state_safe
return state_init()