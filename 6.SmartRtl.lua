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

    -- Récupération de la position actuelle du drone
    local pos_current = ahrs:get_position()
    if not pos_current then
        gcs:send_text(0, "Position actuelle inconnue")
        return find_and_redirect, 3000
    end

    local current_lat, current_lon = pos_current:lat(), pos_current:lng()
    local current_distance = calculate_distance(home_lat, home_lon, current_lat, current_lon)

    gcs:send_text(0, "Distance actuelle: " .. math.floor(current_distance) .. " m")

    local last_index = mission:num_commands() - 1

    gcs:send_text(0, "Last index is " .. last_index)

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


function state_end()
    gcs:send_text(0, "SmartRTL calculation over, alt calculation in progress")

    local current_index = mission:get_current_nav_index()
    local last_index = mission:num_commands() - 1

    -- Récupération de la position actuelle du drone
    local pos_current = ahrs:get_position()

    if not pos_current then
        gcs:send_text(0, "Position actuelle ou Home inconnue, altitude non ajustée")
        return
    end

    -- Altitude relative à Home
    local current_alt = vehicle:get_height()
    local max_slope = math.tan(math.rad(2.5)) -- ≈ 0.0437

    gcs:send_text(0, "Altitude actuelle (relative): " .. math.floor(current_alt) .. " m")

    -- Ajustement des altitudes des waypoints restants
    local prev_lat, prev_lon, prev_alt = pos_current:lat(), pos_current:lng(), current_alt

    for i = current_index, last_index do
        local wp = mission:get_item(i)
        if wp then
            local lat, lon, alt = wp:x(), wp:y(), wp:z() -- alt est en relatif à Home
            local distance = calculate_distance(prev_lat, prev_lon, lat, lon)
            local max_alt_change = distance * max_slope
            local target_alt = math.max(prev_alt - max_alt_change, math.min(prev_alt + max_alt_change, alt))

            -- Mise à jour du waypoint si l'altitude change
            if math.abs(target_alt - alt) > 0.1 then
                gcs:send_text(0, "Ajustement WP " .. i .. " : " .. math.floor(alt) .. " → " .. math.floor(target_alt) .. " m")

                -- Création d'un nouvel objet waypoint avec les mêmes valeurs
                local new_wp = mavlink_mission_item_int_t()
                new_wp:seq(i)
                new_wp:frame(wp:frame())
                new_wp:command(wp:command())
                new_wp:current(wp:current())
                new_wp:x(wp:x())
                new_wp:y(wp:y())
                new_wp:z(target_alt)  -- Mise à jour de l'altitude
                new_wp:param1(wp:param1())
                new_wp:param2(wp:param2())
                new_wp:param3(wp:param3())
                new_wp:param4(wp:param4())

                -- Sauvegarde du waypoint mis à jour
                mission:set_item(i, new_wp)
            end

            -- Mise à jour des valeurs pour le prochain waypoint
            prev_lat, prev_lon, prev_alt = lat, lon, target_alt
        end
    end

    gcs:send_text(0, "Ajustement des altitudes termine, drone routed")
end




-- Démarrer avec l'état d'initialisation
return state_init()