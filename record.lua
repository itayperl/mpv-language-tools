capture_id = 0
function gen_filename()
    local filename = nil

    repeat
        filename = string.format("capture%03d.mp3", capture_id)
        local fp = io.open(filename, "r")
        if fp ~= nil then
            fp:close()
        end

        capture_id = capture_id + 1
    until fp == nil

    return filename
end

start_time = 0
function start_capture()
    start_time = mp.get_property_number("time-pos") - 0.1
end

function stop_capture()
    local duration = mp.get_property_number('time-pos') - start_time + 0.1
    local path = mp.get_property('path')
    local fn = gen_filename()

    local which = io.popen('which ffmpeg avconv')
    local exec = which:lines()()
    which:close()
    
    if exec == nil then
        print('cannot find avconv or ffmpeg in PATH')
        return
    end

    local encoder = io.popen(string.format('%s -i "%s" -map 0:1 -ab 64k -ss %.3f -t %.3f "%s" &', exec, path, start_time, duration, fn))
    encoder:close()
end

in_capture = false
function capture()
    if in_capture then
        stop_capture()
        mp.command('show_text "Capture off"')
        in_capture = false
    else
        in_capture = true
        start_capture()
        mp.command('show_text "Capture on"')
    end
end

mp.add_key_binding("C", "Capture", capture)
