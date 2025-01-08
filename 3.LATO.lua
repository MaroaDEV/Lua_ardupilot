-- This script is a test for AP_Mission bindings

local last_mission_index = mission:get_current_nav_index()
local id, cmd, arg1, arg2, arg3, arg4 = 0,0,0,0,0,0

-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR5_CHANNEL = 5
local MOTOR6_CHANNEL = 6  
local MOTOR7_CHANNEL = 7  
local MOTOR8_CHANNEL = 8  

local loop_count = 0

function init()
    gcs:send_text(0, "3.Remote LATO ready")
    return wait, 400
end

function wait() -- this is the loop which periodically runs

  -- check for scripting DO commands in the mission
  local time_ms, param1, param2, param3, param4 = mission_receive()
  if time_ms then
    id, cmd, arg1, arg2, arg3, arg4 = vehicle:nav_script_time()
  end

  local mission_index = mission:get_current_nav_index()

  -- see if we have changed since we last checked
  if mission_index ~= last_mission_index then

    gcs:send_text(0, "LUA: New Mission Item") -- we spotted a change

    -- print the current and previous nav commands
    gcs:send_text(0, string.format("Prev: %d, Current: %d",mission:get_prev_nav_cmd_id(),mission:get_current_nav_id()))
    id, cmd, arg1, arg2, arg3, arg4 = vehicle:nav_script_time()
    if time_ms then
        gcs:send_text(0, "Targetting REMOTE LATO")
        return land_assist
    end
    last_mission_index = mission_index;
  end

  return wait, 1000 -- reschedules the loop
end

function land_assist()

    local alt = ahrs:get_hagl()
    if alt < 1.5 and quadplane:in_vtol_land_descent() then
        vehicle:set_land_descent_rate(0.4)
    end

    if not arming:is_armed() then
        gcs:send_text(0, "Drone disarmed for ground ops")
        return ground_ops
    end
    return land_assist,200
end

function ground_ops()


    -- Disarm Drone
    arming:disarm()
    -- Définir les valeurs PWM des canaux des servos pour les moteurs 5, 6, 7 et 8 à 0
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1000, 2000)  -- 2000 ms de timeout

    notify:play_tune('T120 L8 O5 C D E')

    loop_count = loop_count + 1

    if loop_count == 10 then
        loop_count = 0
        return to_ready --changer la condition des que possible
    end

    return ground_ops, 1000
    
end

function to_ready()

    -- Disarm Drone
    arming:disarm()
    -- Définir les valeurs PWM des canaux des servos pour les moteurs 5, 6, 7 et 8 à 0
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1000, 2000)  -- 2000 ms de timeout

    gcs:send_text(0, "Takeoff sequence ready ...")

    notify:play_tune('T160 L6 O5 E D C E D C E D C')

    loop_count = loop_count + 1

    if loop_count == 10 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1050, 800)
    end
    if loop_count == 11 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1050, 800)
    end
    if loop_count == 12 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1050, 800)
    end
    if loop_count == 13 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1050, 800)
    end

    if loop_count == 14 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1050, 800)
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1050, 800)
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1050, 800)
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1050, 800)
    end


    if loop_count == 15 then
        return to, 3000 --changer la condition des que possible
    end

    return to_ready, 1000
    
end

function to()

    -- Disarm Drone
    arming:arm()

    local mission_index = mission:get_current_nav_index()

    if mission:get_item(mission_index+1) ~= takeoff then
        gcs:send_text(0, "Expecting missing takeoff")
    return

    mission:set_current_cmd(mission_index+1)

    gcs:send_text(0, "Takeoff started Drone goes on")

    return
    
end

return init() -- run immediately before starting to reschedule