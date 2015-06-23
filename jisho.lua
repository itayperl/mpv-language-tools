require('ass')

subtitles = {}

function parse_timestamp(t)
    local h, m, s, ms = t:match("(%d+):(%d+):(%d+),(%d+)")
    return ms + s * 1000 + m * 60*1000 + h * 60*60*1000
end

function load_srt(fn)
    local subfile = io.open(fn, "r")
    local srt = subfile:read("*all"):gsub("\r", "")
    subfile:close()

    local lines = {}
    local line = nil
    local state = 0

    for s in srt:gmatch("(.-)\n") do
        if state == 0 then
            if line ~= nil then
                lines[#lines+1] = line
            end
            line = {}
            line.text = ''
            state = 1
        elseif state == 1 then
            line.start_time = parse_timestamp(s:sub(1, 12))
            line.end_time = parse_timestamp(s:sub(18))
            state = 2
        elseif state == 2 then
            if s == '' then
                state = 0
            else
                if line.text ~= '' then
                    line.text = line.text .. ' '
                end
                line.text = line.text .. s
            end
        end
    end

    lines[#lines+1] = line

    return lines
end

function timeSort(a, b)
    return a.start_time < b.start_time
end

function read_subfile(sid)
    if subtitles[sid] ~= nil then
        return subtitles[sid]
    end

    num_tracks = mp.get_property_number("track-list/count")
    for i = 1, num_tracks do
        if mp.get_property(string.format("track-list/%d/type", i)) == "sub" and
           mp.get_property_number(string.format("track-list/%d/id", i)) == sid and
           mp.get_property_bool(string.format("track-list/%d/external", i)) then
           fn = mp.get_property(string.format("track-list/%d/external-filename", i))

           if string.find(fn, '%.ass$') then
               subtitles[sid] = ass.load(fn)
           elseif string.find(fn, '%.srt$') then
               subtitles[sid] = load_srt(fn)
           else
               return nil
           end

           table.sort(subtitles[sid], timeSort)
           return subtitles[sid]
        end
    end
end

function sub_get_line(lines, time)
    prev = nil
    for id, line in ipairs(lines) do 
        if line.start_time > time*1000 and prev ~= nil then
            return prev.text
        end
        prev = line
    end
end

function shell_escape(...)
 local command = type(...) == 'table' and ... or { ... }
 for i, s in ipairs(command) do
  s = (tostring(s) or ''):gsub('"', '\\"')
  if s:find '[^A-Za-z0-9_."/-]' then
   s = '"' .. s .. '"'
  elseif s == '' then
   s = '""'
  end
  command[i] = s
 end
 return table.concat(command, ' ')
end

function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
   end
   return str    
end

function open_jisho()
    sid = mp.get_property_number("sid")
    if sid == nil then
        print("no active subtitle track")
        return
    end

    lines = read_subfile(sid)
    if lines == nil then
        print("cannot open subtitle track")
        return
    end

    mp.set_property_bool('pause', true)
    time = mp.get_property_number("time-pos")
    delay = mp.get_property_number("sub-delay")
    cur_line = sub_get_line(lines, time - delay)
    if cur_line == nil then
        print("cannot get line")
        return
    end

    os.execute(shell_escape("sensible-browser", string.format("http://jisho.org/search/%s", urlencode(cur_line))))
end
mp.add_key_binding("K", "Jisho", open_jisho)
