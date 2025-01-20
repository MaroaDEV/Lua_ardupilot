-- Script pour tester la capacité mémoire du matériel
-- Remplit une liste avec un grand nombre de valeurs flottantes aléatoires entre 0 et 20

-- Définir le nombre de variables à stocker
local x = 2000 -- Vous pouvez changer cette valeur pour tester d'autres limites
local test_list = {} -- Liste pour stocker les données
local i = 1

-- Fonction pour générer un nombre flottant aléatoire entre min et max
function random_float(min, max)
    return min + math.random() * (max - min)
end

-- Fonction d'initialisation
function state_do()
    gcs:send_text(6, 'Memory Test Script Initiated')
    i = i + 1
    test_list[i] = random_float(0, 20) -- Stocker une valeur flottante aléatoire entre 0 et 20
    -- Envoyer un message indiquant que l'allocation est terminée
    gcs:send_text(6, 'Memory allocation complete. Total variables stored: ' .. i)
    
    -- Boucle infinie pour maintenir le script actif
    return state_do, 100
end

-- Fonction d'attente (ne fait rien)
function state_idle()
    -- Envoyer un message périodique pour indiquer que le script est actif
    gcs:send_text(6, 'Memory Test Script Running. Stored variables: ' .. #test_list)
    return state_idle, 1000 -- Répéter toutes les secondes
end

-- Démarrer avec l'état d'initialisation
return state_do()
