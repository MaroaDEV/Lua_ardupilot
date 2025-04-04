-- Ce script permet une limitation dynamique des niveaux de gaz

local bat_v = 50
local thr = 100
local THR_MAX = Parameter() -- Accède et modifie ce paramètre
THR_MAX:init('THR_MAX')   

local PARAM_TABLE_KEY = 1
assert(param:add_table(PARAM_TABLE_KEY, "THRS_", 1), 'could not add param table')
assert(param:add_param(PARAM_TABLE_KEY, 1,  'LIMIT', 90), 'could not add param1')

local LIMIT = Parameter()
LIMIT:init('THRS_LIMIT')
local limit = LIMIT:get()


function state_init()
   gcs:send_text(6, '6.Thrmax script initiated')
   return state_ground, 500
end

function state_ground()
   if arming:is_armed() then
       bat_v = battery:voltage(0)
       if bat_v > 51 then
           limit = LIMIT:get()
           thr = limit
       else
           thr = 100
       end
       THR_MAX:set(thr)
       gcs:send_text(6, '6.THRMAX exit, limit is '..thr..'%')
       return
   end 
   return state_ground, 1000
end

-- Démarrer avec state_safe
return state_init()