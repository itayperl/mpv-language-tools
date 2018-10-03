delays = {}

init_delay = mp.get_property_number('sub-delay')

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
        num_tracks = mp.get_property_number("track-list/count")
        for i = 1, num_tracks do
            if mp.get_property(string.format("track-list/%d/type", i)) == "sub" and
               mp.get_property_number(string.format("track-list/%d/id", i)) == sid and
               mp.get_property_bool(string.format("track-list/%d/external", i)) then

               delays[sid] = init_delay
            end
        end
    end
    mp.set_property_number('sub-delay', delays[sid])
end
mp.observe_property('sid', 'number', on_sid_changed)
mp.observe_property('sub-delay', 'number', on_delay_changed)
