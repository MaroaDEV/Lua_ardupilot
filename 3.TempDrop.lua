-- Ce script permet d'envoyer une alerte en cas de chute rapide de température 

-- Définir les variables nécessaires
local T_old = 0
local t_list = {0,0,0,0,0,0,0,0,0}  -- 9 éléments
local delta = 0
local T_now = 0
local t_now = 0

function state_init()
   gcs:send_text(6, '3.TempDrop script initiated')
   return state_start, 10000
end

function state_start()
   T_old = airspeed:get_temperature(1)
   return state_read, 1000
end

function state_read()
   T_now = airspeed:get_temperature(1)
   t_now = millis()
   delta = T_now - T_old
   T_old = T_now
   if delta < (-0.1) then
       return append_and_fw()
   end
   if delta > 0.1 then
       return pop_last_and_fw()
   end
   return fw()
end

function append_and_fw()
    local i = 1
    while i <= 9 do
        if t_list[i] == 0 then
            t_list[i] = t_now
            i = 10
        end
        i = i + 1
    end
    return fw()
end

function pop_last_and_fw()
    local i = 2
    while i <= 9 do
        if t_list[i] == 0 then
            t_list[i-1] = 0
            i = 10
        end
        i = i + 1
    end
    if t_list[9] ~= 0 then
        t_list[9] = 0
    end
    return fw()
end

function fw()
   if t1 ~= 0 then
       if t_now - t_list[1] >= 60000 then
           return pop_first_and_check_alert()
       end
   end
   return check_alert()
end

function pop_first_and_check_alert()
    local i = 1
    while i <= 8 do
        t_list[i] = t_list[i+1]
        i = i + 1
    end
    t_list[9] = 0
    return check_alert()
end

function check_alert()
   if t_list[9] ~= 0 then
       gcs:send_text(6, 'ALERT : High Temperature Drop')
   end
   return state_read, 1000
end

-- Start with init
return state_init()