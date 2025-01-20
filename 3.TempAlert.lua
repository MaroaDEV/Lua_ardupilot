-- Ce script surveille les variations de température sur une période de 80 secondes.
-- Une mesure est prise toutes les 2 secondes et une alerte est envoyée si max - min >= 2.25.

-- Initialisation des variables
local temp_list = {} -- Liste pour stocker les températures (40 mesures max)
local max_size = 40 -- Taille maximale de la liste
local T_now = 0

-- Fonction d'initialisation
function state_init()
    gcs:send_text(6, 'TempAlert Dummy Script Initiated')
    return state_read, 2000 -- Appel de state_read toutes les 2 secondes
end

-- Fonction pour lire la température et effectuer le test
function state_read()
    -- Lire la température actuelle
    T_now = airspeed:get_raw_airspeed(1)
    
    -- Ajouter la nouvelle température à la liste
    table.insert(temp_list, T_now)
    
    -- Si la liste dépasse la taille maximale, supprimer le plus ancien élément
    if #temp_list > max_size then
        table.remove(temp_list, 1)
    end
    
    -- Vérifier si la liste est pleine (40 mesures)
    if #temp_list == max_size then
        -- Calculer la température maximale et minimale dans la liste
        local T_max = math.max(table.unpack(temp_list))
        local T_min = math.min(table.unpack(temp_list))
        
        -- Vérifier si max - min >= 2.25
        if math.abs(T_max - T_min) >= 2.25 then
            gcs:send_text(6, 'ALERT: High Temperature Variation Detected')
        end
    end
    
    -- Revenir à l'état read après 2 secondes
    return state_read, 2000
end

-- Démarrer avec l'état d'initialisation
return state_init()
