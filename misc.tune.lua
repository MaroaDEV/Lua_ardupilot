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
    return state_w8_input, 20000
end

function state_w8_input()
    notify:play_tune('T120 L8 O5 C C D C F E C C D C G F C C O6 C A F E D A# A F G F')
end

-- Démarrer avec state_init

return state_init()
