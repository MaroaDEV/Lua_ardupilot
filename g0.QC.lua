-- Ce script automatise le QC d'un drone complet sur banc de test

-- Définir les canaux des servos pour les moteurs 5, 6, 7 et 8
local MOTOR3_CHANNEL = 3
local MOTOR5_CHANNEL = 5
local MOTOR6_CHANNEL = 6  
local MOTOR7_CHANNEL = 7  
local MOTOR8_CHANNEL = 8  
local value = 0
local pwm_out = 0

local last_state = 0
local input = 0
local SERVO_FUNCTION = 27 -- 27 est assigné au parachute
local seq_seg = 0

function state_init()
    gcs:send_text(6, 'g0.ground test ready on input')
    return state_w8_input, 500
end

function state_w8_input()
    
    if not arming:is_armed() then
        return state_w8_input, 1000
    end
    value = 0
    pwm_out = 0
    seq_seg = 0
    gcs:send_text(0, 'g0.input needed on right C1/C2')

    if rc:get_pwm(1) > 1900 then
        return state_w8_input_confirm, 1000
    end
    if rc:get_pwm(1) < 1100 then
        return state_w8_input_confirm, 1000
    end
    if rc:get_pwm(2) > 1900 then
        return state_w8_input_confirm, 1000
    end
    if rc:get_pwm(2) < 1100 then
        return state_w8_input_confirm, 1000
    end
    return state_w8_input, 500 
end

function state_w8_input_confirm()
    if not arming:is_armed() then
        return state_w8_input, 1000
    end
    if rc:get_pwm(1) > 1900 then
        return state_1, 1000
    end
    if rc:get_pwm(1) < 1100 then
        return state_2, 1000
    end
    if rc:get_pwm(2) < 1100 then
        return state_3, 1000
    end
    return state_w8_input, 500 
end


function state_1() -- test mot A B C D at 60% 3 min
    if not arming:is_armed() then
        return state_w8_input, 1000
    end
    if rc:get_pwm(2) > 1900 then
        notify:play_tune('MFT240L8 G G G G C C C C')
        gcs:send_text(0, 'RC2 asked exit')
        return state_w8_input, 2500 
    end
    if seq_seg == 0 then --from 0 to 10
        gcs:send_text(0, 'Squence 1')
        notify:play_tune('MFT240L8 C C C C D E F G')
    end
    if seq_seg > 0 and seq_seg < 10 then --from 0 to 10
        notify:play_tune('MFT240L8 C')
    end
    if seq_seg > 10 and seq_seg <= 20 then --from 11 to 20
        pwm_out = (seq_seg-10)*60+1000
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg > 20 and seq_seg <= 200 then --from 21 to 200
        pwm_out = 1600
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg > 200 and seq_seg <= 210 then --from 21 to 200
        pwm_out = 1600-(seq_seg-200)*60
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR5_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR6_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR7_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR8_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg == 211 then --from 0 to 10
        gcs:send_text(0, 'End Squence 1')
        notify:play_tune('MFT240L8 C C C C G F E D')
        return state_w8_input, 500
    end

    seq_seg = seq_seg + 1


    return state_1, 1000
end

function state_2() -- test mot main at 60% 3 min
    if not arming:is_armed() then
        return state_w8_input, 1000
    end
    if rc:get_pwm(2) > 1900 then
        notify:play_tune('MFT240L8 G G G G C C C C')
        gcs:send_text(0, 'RC2 asked exit')
        return state_w8_input, 2500 
    end
    if seq_seg == 0 then --from 0 to 10
        gcs:send_text(0, 'Squence 2')
        notify:play_tune('MFT240L8 C D D C D E F G')
    end
    if seq_seg > 0 and seq_seg < 10 then --from 0 to 10
        notify:play_tune('MFT240L8 C')
    end
    if seq_seg > 10 and seq_seg <= 20 then --from 11 to 20
        pwm_out = (seq_seg-10)*60+1000
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR3_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg > 20 and seq_seg <= 200 then --from 21 to 200
        pwm_out = 1600
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR3_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg > 200 and seq_seg <= 210 then --from 21 to 200
        pwm_out = 1600-(seq_seg-200)*60
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR3_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg == 211 then --from 0 to 10
        gcs:send_text(0, 'End Squence 2')
        notify:play_tune('MFT240L8 C D D C G F E D')
        return state_w8_input, 500
    end

    seq_seg = seq_seg + 1


    return state_2, 1000
end

function state_3() --test desync
    if not arming:is_armed() then
        return state_w8_input, 1000
    end
    if rc:get_pwm(2) > 1900 then
        notify:play_tune('MFT240L8 G G G G C C C C')
        
        vehicle:set_mode(1)
        gcs:send_text(0, 'RC2 asked exit')
        return state_w8_input, 2500 
    end
    if seq_seg == 0 then --from 0 to 10
        gcs:send_text(0, 'Squence 3')
        notify:play_tune('MFT240L8 C D E C D E F G')
        vehicle:set_mode(17)
    end
    if seq_seg > 0 and seq_seg < 10 then --from 0 to 10
        notify:play_tune('MFT240L8 C')
    end
    if seq_seg > 10 and seq_seg <= 20 then --from 11 to 20
        value = (seq_seg-10)*0.06
        vehicle:set_steering_and_throttle(0,value)  -- 2000 ms de timeout
    end
    if seq_seg > 20 and seq_seg <= 200 then --from 21 to 200
        pwm_out = 1600
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR3_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg > 200 and seq_seg <= 210 then --from 21 to 200
        pwm_out = 1600-(seq_seg-200)*60
        SRV_Channels:set_output_pwm_chan_timeout(MOTOR3_CHANNEL, pwm_out, 2000)  -- 2000 ms de timeout
    end
    if seq_seg == 211 then --from 0 to 10
        gcs:send_text(0, 'End Squence 3')
        notify:play_tune('MFT240L8 C D E C G F E D')
        vehicle:set_mode(1)
        return state_w8_input, 500
    end

    seq_seg = seq_seg + 1


    return state_3, 1000
end

function state_4()

    gcs:send_text(0, 'Squence 4')
    return state_w8_input, 500
end

-- Démarrer avec state_init
return state_init()