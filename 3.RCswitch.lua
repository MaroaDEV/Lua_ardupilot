-- Script RCswitch.lua patch 1.0
-- Ce déclenche les changements de mode de la RC

local delay = 200
local long_delay = 2000


local MAV_INFO = 6

local state_6
local state_7
local old_state_6 = -2
local old_state_7 = -2
local prev_read_6, prev_read_7 = -2, -2

-- Fonction d'initialisation
function state_init()
    gcs:send_text(6, '3. RC Switch script initiated')
    return state_read, long_delay -- Appel de state_read dans 2 secondes
end

-- Fonction pour lire les champs
function state_read()
    if not rc:has_valid_input() then
        old_state_6 = -1
        old_state_7 = -1
        gcs:send_text(MAV_INFO,"invalid")
        return state_read,long_delay
    end

    local ch7 = rc:get_pwm(7)
    local ch6 = rc:get_pwm(6)

    -- assignation des etats

    if ch6 >= 900 and ch6 < 1750 then
        state_6 = 0
    elseif ch6 >= 1750 and ch6 <= 2100 then
        state_6 = 1
    else
        state_6 = -1 -- Valeur hors plage
    end

    if ch7 >= 950 and ch7 < 1250 then
        state_7 = 0
    elseif ch7 >= 1250 and ch7 < 1750 then
        state_7 = 1
    elseif ch7 >= 1750 and ch7 <= 2100 then
        state_7 = 2
    else
        state_7 = -1 -- Valeur hors plage
    end

    local change6 = (old_state_6 ~= nil)
              and (state_6 ~= old_state_6)
              and (state_6 == prev_read_6)
              and (state_6 >= 0 and old_state_6 >= 0)

    local change7 = (old_state_7 ~= nil)
              and (state_7 ~= old_state_7)
              and (state_7 == prev_read_7)
              and (state_7 >= 0 and old_state_7 >= 0)

    -- mettre à jour les dernières lectures "brutes" pour le prochain tour
    prev_read_6, prev_read_7 = state_6, state_7

    -- changement de mode si besoin

    if change6 then
        if state_6 == 0 then
            change7 = true -- va forcer le changement de mode sur le channel 7
        end
        if state_6 == 1 then
            vehicle:set_mode(10) -- mode AUTO
            gcs:send_text(MAV_INFO,"Switch to AUTO")
        end
        old_state_6 = state_6
    end

    if change7 then
        if state_7 == 0 then
            vehicle:set_mode(17) -- mode QSTABILIZE
            gcs:send_text(MAV_INFO,"Switch to QSTABILIZE")
        end
        if state_7 == 1 then
            vehicle:set_mode(19) -- mode QLOITER
            gcs:send_text(MAV_INFO,"Switch to QLOITER")
        end
        if state_7 == 2 then
            vehicle:set_mode(20) -- mode QLAND
            gcs:send_text(MAV_INFO,"Switch to QLAND")
        end
        old_state_7 = state_7
    end

    -- Donc le old est changé que si on change de mode, ou si l'anicen old n'était pas valide et qu'on a une mesure valide

    if old_state_6 < 0 then
        old_state_6 = state_6
    end
    if old_state_7 < 0 then
        old_state_7 = state_7
    end

    return state_read, delay -- Lit la position toutes les 0.2 secondes
end

-- Démarrer avec l'état d'initialisation
return state_init()