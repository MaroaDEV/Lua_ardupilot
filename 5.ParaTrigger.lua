-- Script ParaTrigger.lua patch 1.1

-- Ce déclenche le parachute dans certains scénarios de vols dégradés

-- Initialisation des variables
local SERVO_FUNCTION_PARA = 27 -- 27 est assigné au parachute
local SERVO_PARA_CHANNEL = 12

local delay = 2000

local thr = -1
local cur = -1
local c_motorloss = 0

local alt = -1
local t_alt = -1
local c_alt = 0

local xt = 0
local c_xt = 0

local sinkrate = 0
local c_vtol = 0

local roll = 0
local pitch = 0
local c_ang = 0

local MOTOR5_FUN = 33
local MOTOR6_FUN = 34 
local MOTOR7_FUN = 35 
local MOTOR8_FUN = 36 
local SERVO_FUN_FORWARD = 70

local PARAM_TABLE_KEY = 0
assert(param:add_table(PARAM_TABLE_KEY, "PARA_", 11), 'could not add param table')
assert(param:add_param(PARAM_TABLE_KEY, 1,  'VTOL_SK', 5.5), 'could not add param1')
assert(param:add_param(PARAM_TABLE_KEY, 2,  'VTOL_DS', 6), 'could not add param2')
assert(param:add_param(PARAM_TABLE_KEY, 3,  'M_TH_HIGH', 95), 'could not add param3')
assert(param:add_param(PARAM_TABLE_KEY, 4,  'M_CUR_LOW', 8), 'could not add param4')
assert(param:add_param(PARAM_TABLE_KEY, 5,  'M_DS', 20), 'could not add param5')
assert(param:add_param(PARAM_TABLE_KEY, 6,  'ALT_DELTA', 60), 'could not add param6')
assert(param:add_param(PARAM_TABLE_KEY, 7,  'ALT_DS', 20), 'could not add param7')
assert(param:add_param(PARAM_TABLE_KEY, 8,  'XT_M', 2000), 'could not add param8')
assert(param:add_param(PARAM_TABLE_KEY, 9,  'XT_DS', 20), 'could not add param9')
assert(param:add_param(PARAM_TABLE_KEY, 10,  'ANG_DEG', 55), 'could not add param10')
assert(param:add_param(PARAM_TABLE_KEY, 11,  'ANG_DS', 3), 'could not add param11')

local VTOL_SK = Parameter()
VTOL_SK:init('PARA_VTOL_SK')
local i_vtol_sk = VTOL_SK:get()

local VTOL_DS = Parameter()
VTOL_DS:init('PARA_VTOL_DS')
local i_vtol_ds = VTOL_DS:get()

local M_TH_HIGH = Parameter()
M_TH_HIGH:init('PARA_M_TH_HIGH')
local i_m_th_high = M_TH_HIGH:get()

local M_CUR_LOW = Parameter()
M_CUR_LOW:init('PARA_M_CUR_LOW')
local i_m_cur_low = M_CUR_LOW:get()

local M_DS = Parameter()
M_DS:init('PARA_M_DS')
local i_m_ds = M_DS:get()

local ALT_DELTA = Parameter()
ALT_DELTA:init('PARA_ALT_DELTA')
local i_alt_delta = ALT_DELTA:get()

local ALT_DS = Parameter()
ALT_DS:init('PARA_ALT_DS')
local i_alt_ds = ALT_DS:get()

local XT_M = Parameter()
XT_M:init('PARA_XT_M')
local i_xt_m = XT_M:get()

local XT_DS = Parameter()
XT_DS:init('PARA_XT_DS')
local i_xt_ds = XT_DS:get()

local ANG_DEG = Parameter()
ANG_DEG:init('PARA_ANG_DEG')
local i_ang_deg = ANG_DEG:get()

local ANG_DS = Parameter()
ANG_DS:init('PARA_ANG_DS')
local i_ang_ds = ANG_DS:get()

-- Fonction d'initialisation
function state_init()
    gcs:send_text(6, '5. ParaTrigger script initiated')
    return state_read, 2000 -- Appel de state_read toutes les 2 secondes
end

-- Fonction pour lire les champs
function state_read()


    if SRV_Channels:get_output_pwm(SERVO_FUNCTION_PARA) == 2000 or para:released() then
        return
    end    

    local hagl = terrain:height_above_terrain(true)


    if (not vehicle:get_likely_flying()) or (not ahrs:initialised()) or (not arming:is_armed()) then
        return state_read,10000
    end

    if hagl == nil then
        gcs:send_text(0, 'invalid hagl')
        return state_read, 10000
    end

    if hagl < 30 then
        return state_read, 1000
    end

    -- State VTOL si pwm_sum > 4010 et si is_flying_vtol
    local pwm_sum = SRV_Channels:get_output_pwm(MOTOR5_FUN) + SRV_Channels:get_output_pwm(MOTOR6_FUN) + SRV_Channels:get_output_pwm(MOTOR7_FUN) + SRV_Channels:get_output_pwm(MOTOR8_FUN)
    
    if c_alt > i_alt_ds or c_motorloss > i_m_ds or c_vtol > i_vtol_ds or c_ang > i_ang_ds then
        if (hagl > 160) then
            gcs:send_text(0, 'Parachute waiting : Too high')
        else
            gcs:send_text(0, 'Parachute Triggered')
            para:release()
            return
        end    
    end

    if c_xt > i_xt_ds then
        gcs:send_text(0, 'Parachute Triggered')
        para:release()
        return 
    end

    if pwm_sum > 4010 and quadplane:in_vtol_mode() then
        c_motorloss = 0
        c_alt = 0
        c_xt = 0
        return state_vtol()
    end

    -- State CRUISE sinon
    if pwm_sum < 4010 and not quadplane:in_vtol_mode() and vehicle:get_mode() == 10 then
        c_vtol = 0
        c_ang = 0
        return state_cruise()
    end

    c_motorloss = 0
    c_alt = 0
    c_vtol = 0
    c_xt = 0
    c_ang = 0

    return state_read, 2000
end


function state_vtol()
    delay = 100
    
    local vel = ahrs:get_velocity_NED()
    pitch = 57.296*ahrs:get_pitch()
    roll = 57.296*ahrs:get_roll()

    if vel then
        sinkrate = vel:z()
    else 
        sinkrate = 0
    end

    if sinkrate > i_vtol_sk then
        c_vtol = c_vtol + 1
        delay = 100
    else 
        c_vtol = 0
    end

    if math.abs(pitch) > i_ang_deg or math.abs(roll) > i_ang_deg then
        c_ang = c_ang + 1
        delay = 100
    else 
        c_ang = 0
    end

    logger:write('PARA','state,sk,thr,cur,alt,t_alt,xt,c_mot,c_alt,c_xt,c_vtol','iffffffiiii',2,sinkrate,0,0,0,0,0,0,0,0,c_vtol)
    logger:write('PAR2','pitch,roll,c_ang','ffi',pitch,roll,c_ang)
    return state_read, delay
end

function state_cruise()
    thr = SRV_Channels:get_output_scaled(SERVO_FUN_FORWARD)
    cur = battery:current_amps(0)
    alt = vehicle:get_height()
    t_alt = vehicle:get_hdem()
    xt = vehicle:get_wp_crosstrack_error_m()

    if thr == nil or thr == -1 or cur == nil or cur == -1 or alt == nil or alt == -1 or t_alt == nil or t_alt == -1 or xt == nil then
        gcs:send_text(0, 'invalid input: ' .. ((thr == nil or thr == -1) and 'thr' or (cur == nil or cur == -1) and 'cur' or (xt == nil) and 'xt'  or (alt == nil or alt == -1) and 'alt' or 't_alt'))
        c_alt = 0
        c_motorloss = 0
        c_xt = 0
        return state_read, 10000
    end

    delay = 500

    if math.abs(alt-t_alt) > i_alt_delta then
        c_alt = c_alt+1
        delay = 100
    else 
        c_alt = 0
    end

    if thr > i_m_th_high and cur < i_m_cur_low then
        c_motorloss = c_motorloss + 1
        delay = 100
    else 
        c_motorloss = 0
    end

    if math.abs(xt) > i_xt_m then
        c_xt = c_xt+1
        delay = 100
    else
        c_xt = 0
    end

    -- logger:write('HE','thr(%),cur(A)','f,f',thr,cur)
    logger:write('PARA','state,sk,thr,cur,alt,t_alt,xt,c_mot,c_alt,c_xt,c_vtol','iffffffiiii',1,0,thr,cur,alt,t_alt,xt,c_motorloss,c_alt,c_xt,0)
    logger:write('PAR2','pitch,roll,c_ang','ffi',0,0,0)
    return state_read, delay

end

-- Démarrer avec l'état d'initialisation
return state_init()