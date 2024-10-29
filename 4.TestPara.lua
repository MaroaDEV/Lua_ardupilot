-- This script is a test for AP_Mission bindings

local last_mission_index = mission:get_current_nav_index()
local id, cmd, arg1, arg2, arg3, arg4 = 0,0,0,0,0,0
local SERVO_FUNCTION = 27 -- 27 est assigné au parachute

local MOTOR3_CHANNEL = 2

function init()
    gcs:send_text(0, "4.ParachuteTest ready")
    return wait, 400
end

function wait()

  local mission_index = mission:get_current_nav_index()

  if mission_index ~= last_mission_index then

    gcs:send_text(0, "LUA: New Mission Item") 

    gcs:send_text(0, string.format("Prev: %d, Current: %d",mission:get_prev_nav_cmd_id(),mission:get_current_nav_id()))
    id, cmd, arg1, arg2, arg3, arg4 = vehicle:nav_script_time()
    if id then
        return parachute_1()
    end
    last_mission_index = mission_index;
  end

  return wait, 500 -- reschedules the loop
end

function parachute_1()

    vehicle:set_mode(0)
    gcs:send_text(0, "Free fall")
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR3_CHANNEL, 1000, 6000)  -- 6s de timeout
    
    return parachute_2, 3000
end

function parachute_2()

   if SRV_Channels:get_output_pwm(SERVO_FUNCTION) < 1999 then
       gcs:send_text(0, "Script release")
       SRV_Channels:set_output_pwm(SERVO_FUNCTION, 2000)
   end

   return final()
end

function final()

    SRV_Channels:set_output_pwm_chan_timeout(MOTOR3_CHANNEL, 1000, 1000)  -- 1s de timeout

    return final, 500
end

return init() -- run immediately before starting to reschedule