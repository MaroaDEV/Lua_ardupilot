-- Ce script automatise le QC d'un drone complet sur banc de test

-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR5_CHANNEL = 5
local MOTOR6_CHANNEL = 6  
local MOTOR7_CHANNEL = 7  
local MOTOR8_CHANNEL = 8  

local last_state = 0
local input = 0
local SERVO_FUNCTION = 27 -- 27 est assigné au parachute
local SCR_1 = 94 
local SCR_2 = 95
local SCR_3 = 96
local SCR_4 = 97

function state_init()
    gcs:send_text(6, 'g0.ground test ready on input')
    if arming:is_armed() then
        return state_w8_input, 200
    end
    return state_init, 2000
end

function state_w8_input()
    notify:play_tune('T120 O4 L4 G G A G O5C O4B P4 G G A G O5D O4C P4 G G O5G O4E C B A P4 O5F O4F E C D C')
end

-- Démarrer avec state_init

return state_init()
