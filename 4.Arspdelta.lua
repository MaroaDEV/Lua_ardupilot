-- Ce script surveille l'écart entre les deux airspeed indiqués'

-- Initialisation des variables
local asp0 = -1
local asp1 = -1
local aspd = -1

-- Fonction d'initialisation
function state_init()
    gcs:send_text(6, '4. Airspeed script initiated')
    return state_read, 2000 -- Appel de state_read toutes les 2 secondes
end

-- Fonction pour lire les airspeed
function state_read()
    -- Lire la température actuelle
    asp0 = airspeed:get_raw_airspeed(0)
    asp1 = airspeed:get_raw_airspeed(1)
    aspd = 0.2*(asp1-asp0)+0.8*aspd

    local alt = baro:get_altitude()
    
    if math.abs(aspd) > 2 and alt > 40 and (not quadplane:in_vtol_mode()) then
        gcs:send_text(0, 'ALERT: delta airspeed a1-a0 =' .. aspd)
    end

    if math.abs(aspd) > 5 then
        gcs:send_text(0, 'ALERT: delta airspeed a1-a0 =' .. aspd)
    end

    -- Nouvelle lecture toutes les 0.5s
    return state_read, 500
end

-- Démarrer avec l'état d'initialisation
return state_init()