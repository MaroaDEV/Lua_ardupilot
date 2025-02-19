-- Ce script permet de faire un smartRTL

-- Initialisation des variables
local compteur = 0
local SERVO_FUNCTION_S1 = 94

local SERVO_SCR1_CHANNEL = 14 -- n°15 pour le servos utilisés dans les scripts
local script_pwm = 0

function state_init()
   gcs:send_text(6, '6.SmartRTL script initiated')
   return state_read, 500
end

function state_read()
    local index = mission:get_current_nav_index()
    
    if index < 0 then
        -- gcs:send_text(0, "Aucune mission en cours")
        return state_read, 3000
    end

    local item = mission:get_item(index)

    if item then
        -- gcs:send_text(0, "Index: " .. index)
        -- gcs:send_text(0, "Lat: " .. item:x() .. ", Lon: " .. item:y())
    else
       --  gcs:send_text(0, "Impossible de récupérer l'élément de mission")
    end

    if SRV_Channels:get_output_pwm_chan(14)==1994 then
        gcs:send_text(0, "Input reçu : SmartRTL")
        return find_and_redirect()
    else

    end

    return state_read, 1000 -- Vérifier toutes les secondes
end

function calculate_distance(lat1, lon1, lat2, lon2)
    local R = 6371000 -- Rayon de la Terre en mètres

    -- Conversion des coordonnées en degrés
    lat1, lon1 = lat1 / 1e7, lon1 / 1e7
    lat2, lon2 = lat2 / 1e7, lon2 / 1e7

    local dLat = math.rad(lat2 - lat1)
    local dLon = math.rad(lon2 - lon1)

    local a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) *
              math.sin(dLon / 2) * math.sin(dLon / 2)

    local c = 2 * math.atan(math.sqrt(a) / math.sqrt(1 - a)) -- atan2 remplacé par atan

    return R * c -- Distance en mètres
end

function find_and_redirect()
    local home = ahrs:get_home() -- Récupère la position Home
    if not home then
        gcs:send_text(0, "Home position inconnue")
        return find_and_redirect, 3000
    end

    local home_lat, home_lon = home:lat(), home:lng()
    local current_index = mission:get_current_nav_index()
    local current_item = mission:get_item(current_index)

    if not current_item then
        gcs:send_text(0, "Impossible de trouver l'item de mission actuel")
        return find_and_redirect, 3000
    end

    local current_lat, current_lon = current_item:x(), current_item:y()
    local current_distance = calculate_distance(home_lat, home_lon, current_lat, current_lon)

    gcs:send_text(0, "Distance actuelle: " .. math.floor(current_distance) .. " m")

    local last_index = mission:num_commands() - 1

    gcs:send_text(0, "Last index is ".. last_index)

    local prev_index = last_index
    local prev_distance = 0

    for i = last_index, 0, -1 do
        local item = mission:get_item(i)
        if item then
            local lat, lon = item:x(), item:y()
            local distance = calculate_distance(home_lat, home_lon, lat, lon)

            gcs:send_text(0, "Index: " .. i .. " - Distance: " .. math.floor(distance) .. " m")

            if distance > current_distance then
                gcs:send_text(0, "Point de depassement sur l'index " .. i)
                if prev_index ~= last_index then
                    gcs:send_text(0, "Routage vers l'index " .. prev_index)
                    mission:set_current_cmd(prev_index)
                end
                break
            end

            prev_index = i
            prev_distance = distance
        end
    end

    return state_end()
end

function do_smartrtl()

    local index = mission:get_current_nav_index()

    local item = mission:get_current_nav_index(index)

    gcs:send_text(0, 'index =' .. index)
    gcs:send_text(0, 'item =' .. item)

    return state_read, 500
end

function state_end()

    gcs:send_text(0, 'SmartRTL calculation over, drone routed')

    return 
end

-- Démarrer avec l'état d'initialisation
return state_init()