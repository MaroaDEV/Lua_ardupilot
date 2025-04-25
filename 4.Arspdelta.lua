-- Ce script surveille l'écart entre les deux airspeed indiqués'

-- Initialisation des variables
local asp0 = -1
local asp1 = -1
local aspd = -1
local ofsd = -1

local PARAM_TABLE_KEY = 2
assert(param:add_table(PARAM_TABLE_KEY, "ASPS_", 2), 'could not add param table')
assert(param:add_param(PARAM_TABLE_KEY, 1,  'DELTA', 2), 'could not add param1')
assert(param:add_param(PARAM_TABLE_KEY, 2,  'OFST', 50), 'could not add param2')

local DELTA = Parameter()
DELTA:init('ASPS_DELTA')
local delta_tolerance = DELTA:get()

local OFST = Parameter()
OFST:init('ASPS_OFST')
local ofs_tolerance = OFST:get()

local OFS1 = Parameter()
OFS1:init('ARSPD_OFFSET')
local OFS1_old = OFS1:get()

local OFS2 = Parameter()
OFS2:init('ARSPD2_OFFSET')
local OFS2_old = OFS2:get()

-- Fonction d'initialisation
function state_init()
    gcs:send_text(6, '4. Airspeed script initiated')
    return state_read, 100 -- Appel de state_read toutes les 2 secondes
end

-- Fonction pour lire les airspeed
function state_read()

    if not arming:is_armed() then
        ofs_tolerance = OFST:get()
        if OFS1:get() ~= OFS1_old then
            ofsd = math.abs(OFS1:get() - OFS1_old)
            if  ofsd > ofs_tolerance then
                gcs:send_text(0, 'ALERT AS1 offset diff = ' .. ofsd)
            else
                gcs:send_text(6, 'Cal report :AS1 ofs diff = ' .. ofsd)
            end
        end
        if OFS2:get() ~= OFS2_old then
            ofsd = math.abs(OFS2:get() - OFS2_old)
            if  ofsd > ofs_tolerance then
                gcs:send_text(0, 'ALERT AS2 offset diff = ' .. ofsd)
            else
                gcs:send_text(6, 'Cal report :AS2 ofs diff = ' .. ofsd)
            end
        end
        OFS1_old = OFS1:get()
        OFS2_old = OFS2:get()
    end

    asp0 = airspeed:get_raw_airspeed(0)
    asp1 = airspeed:get_raw_airspeed(1)
    aspd = 0.2*(asp1-asp0)+0.8*aspd
    delta_tolerance = DELTA:get()

    local hagl = terrain:height_above_terrain(true)

    if hagl == nil and ahrs:initialised() then
        gcs:send_text(0, 'invalid hagl')
        return state_read, 10000
    end

    if not asp0 or not asp1 then
        gcs:send_text(0, 'ALERT: sensor missing')
        return state_read,2000
    end
    
    if math.abs(aspd) > delta_tolerance and hagl > 40 and (not quadplane:in_vtol_mode()) then
        gcs:send_text(0, 'ALERT: delta airspeed a2-a1 =' .. aspd)
    end

    if math.abs(aspd) > 10 then
        gcs:send_text(0, 'ALERT: delta airspeed a2-a1 =' .. aspd)
    end

    -- Nouvelle lecture toutes les 0.5s
    return state_read, 500
end

-- Démarrer avec l'état d'initialisation
return state_init()