delays = {}

function on_delay_changed(name, delay)
    sid = mp.get_property_number('sid')
    if sid == nil then
        return
    end

    delays[sid] = delay
end

function on_sid_changed(name, sid)
    if sid == nil then
        return
    end
    if delays[sid] == nil then
        delays[sid] = 0
    end
    mp.set_property_number('sub-delay', delays[sid])
end
mp.observe_property('sid', 'number', on_sid_changed)
mp.observe_property('sub-delay', 'number', on_delay_changed)
