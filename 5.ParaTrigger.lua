-- Ce déclenche le parachute dans certains scénarios de vols dégradés

-- Initialisation des variables
local delay = 2000

local thr = -1
local cur = -1
local c_motorloss = 0

local alt = -1
local t_alt = -1
local c_alt = 0

local sinkrate = 0
local c_vtol = 0

local MOTOR5_FUN = 33
local MOTOR6_FUN = 34 
local MOTOR7_FUN = 35 
local MOTOR8_FUN = 36 
local SERVO_FUN_FORWARD = 70

-- Fonction d'initialisation
function state_init()
    gcs:send_text(6, '5. ParaTrigger script initiated')
    return state_read, 2000 -- Appel de state_read toutes les 2 secondes
end

-- Fonction pour lire les champs
function state_read()

    if (not vehicle:get_likely_flying()) or (not (ahrs:get_hagl() > 30)) or (not ahrs:initialised()) then
        return state_read,2000
    end

    -- State VTOL si pwm_sum > 4010 et si is_flying_vtol
    local pwm_sum = SRV_Channels:get_output_pwm(MOTOR5_FUN) + SRV_Channels:get_output_pwm(MOTOR6_FUN) + SRV_Channels:get_output_pwm(MOTOR7_FUN) + SRV_Channels:get_output_pwm(MOTOR8_FUN)
    
    if pwm_sum > 4010 and quadplane:in_vtol_mode() then
        c_motorloss = 0
        c_alt = 0
        return state_vtol()
    end

    -- State CRUISE sinon
    if pwm_sum < 4010 and not quadplane:in_vtol_mode() and vehicle:get_mode() == 10 then
        c_vtol = 0
        return state_cruise()
    end

    c_motorloss = 0
    c_alt = 0
    c_vtol = 0

    return state_read, 2000
end


function state_vtol()

    sinkrate = vehicle:get_sinkrate()

    if sinkrate > 7 then
        c_vtol = c_vtol + 1
    end

    logger:write('PARA','state,sk,thr,cur,alt,t_alt,c_mot,c_alt,c_vtol','ifffffiii',2,sinkrate,0,0,alt,0,0,0,c_vtol)
    return state_read, 3000
end

function state_cruise()
    thr = SRV_Channels:get_output_scaled(SERVO_FUN_FORWARD)
    cur = battery:current_amps(0)
    alt = vehicle:get_height()
    t_alt = vehicle:get_hdem()
    delay = 2000

    if alt < (t_alt - 60) then
        c_alt = c_alt+1
        delay = 100
    else 
        c_alt = 0
    end

    if thr > 0.98 and cur < 8 then
        c_motorloss = c_motorloss + 1
        delay = 100
    else 
        c_motorloss = 0
    end

    -- logger:write('HE','thr(%),cur(A)','f,f',thr,cur)
    logger:write('PARA','state,sk,thr,cur,alt,t_alt,c_mot,c_alt,c_vtol','ifffffiii',1,0,thr,cur,alt,t_alt,c_motorloss,c_alt,0)
    return state_read, delay

end

-- Démarrer avec l'état d'initialisation
return state_init()