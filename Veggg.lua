-- Ce script permet un arret d'urgence des moteurs verticaux en cas de d clenchement parachute

-- D finir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR5_FUN = 33
local MOTOR6_FUN = 34 
local MOTOR7_FUN = 35 
local MOTOR8_FUN = 36 


local Moy_PWM_Quad = 0


function state_init()
  gcs:send_text()
  return state_compare, 500
end

function state_compare()
  Moy_PWM_Quad = (SRV_Channels:get_output_pwm(MOTOR5_FUN) + SRV_Channels:get_output_pwm(MOTOR6_FUN) + SRV_Channels:get_output_pwm(MOTOR7_FUN) + SRV_Channels:get_output_pwm(MOTOR8_FUN))/4
  for i=0 ,  i<=4 , 1 do 
    if SRV_Channels:get_output_pwm(33+i) >= 100 + Moy_PWM_Quad then 
      local sp = (SRV_Channels:get_output_pwm(33+i)/Moy_PWM_Quad)*100
      gcs:send_text('Le moteur'..4+i.. 'consomme à'..sp..'%')
    end
  end
  return state_compare, 2000
end


-- D marrer avec state_safe
return state_init()