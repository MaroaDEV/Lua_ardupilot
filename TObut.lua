-- This script is a test for AP_Mission bindings

local last_mission_index = mission:get_current_nav_index()
local id, cmd, arg1, arg2, arg3, arg4 = 0,0,0,0,0,0

-- This script is an example button functionality

local button_number = 1 -- the button numbber we want to read, as deffined in AP_Button

local button_active_state = false -- the 'pressed' state of the button

local last_button_state



-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR5_CHANNEL = 4
local MOTOR6_CHANNEL = 5  
local MOTOR7_CHANNEL = 6  
local MOTOR8_CHANNEL = 7  

local SERVO_SCR1_CHANNEL = 14 -- n°15 pour le servos utilisés dans les scripts
local script_pwm = 0

local loop_count = 0

function init()
    gcs:send_text(0, "TO Button ready")
    return noseq, 400
end

function noseq()
    script_pwm = SRV_Channels:get_output_pwm_chan(SERVO_SCR1_CHANNEL)
    if script_pwm == 1998 then
        gcs:send_text(6, "TO Seq: GROUND OPS")
        return ground_ops, 100
    end
    last_button_state = button:get_button_state(button_number)
    return noseq, 1000
end


function ground_ops()

    script_pwm = SRV_Channels:get_output_pwm_chan(SERVO_SCR1_CHANNEL)
    if script_pwm == 1996 then
        gcs:send_text(6, "TO Seq: ended")
        return noseq, 100
    end

    -- Disarm Drone
    arming:disarm()
    -- Définir les valeurs PWM des canaux des servos pour les moteurs 5, 6, 7 et 8 à 0
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1000, 2000)  -- 2000 ms de timeout
    SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1000, 2000)  -- 2000 ms de timeout

    if math.fmod(loop_count,3) == 0 then
        notify:play_tune('T120 L8 O5 C D E')
    end

    loop_count = loop_count + 1
    if loop_count > 11 then
        loop_count = 0
    end

    local button_new_state = button:get_button_state(button_number)

    -- the button has changes since the last loop
    if button_new_state ~= last_button_state then
        loop_count = 0
        last_button_state = button_new_state
        if button_new_state then
          gcs:send_text(0, "LUA: Button pressed")
          return to_ready, 1000
        else
          gcs:send_text(0, "LUA: Button released")
          return to_ready, 1000
        end
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

    

    notify:play_tune('T80 L6 O3 E D C E D C E D C')

    loop_count = loop_count + 1

    if loop_count == 10 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1020, 800)
    end
    if loop_count == 11 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1020, 800)
    end
    if loop_count == 12 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1020, 800)
    end
    if loop_count == 13 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1020, 800)
    end

    if loop_count == 14 then
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, 1050, 800)
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, 1050, 800)
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, 1050, 800)
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, 1050, 800)
    end


    if loop_count == 15 then
        return to_2, 3000 --changer la condition des que possible
    end

    return to_ready, 1000
    
end

function to_2()
    
    vehicle:set_mode(10)
    -- arm Drone
    arming:arm()


    if mission:get_item(last_mission_index+3) ~= 84 then
        gcs:send_text(0, "Expecting missing takeoff")
    end


    gcs:send_text(0, "Takeoff started Drone goes on")

    return
    
end


return init() -- run immediately before starting to reschedule