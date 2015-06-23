# mpv-language-tools

This repository contains several lua scripts providing language-learning aids to [mpv](https://mpv.org).

### subdelay.lua

Makes the subtitle delay parameter separate for each subtitle track. Useful when you have subtitles in two languages, one of which is not synced with the audio.

### jisho.lua

Maps Shift-K to open the currently displayed subtitle in [Jisho](http://jisho.org).

Assumes `sensible-browser` is in PATH.

### record.lua

Provides an option to record the audio being played into an MP3 file.

Press C to start recording, and again to stop. Files will be named capture###.mp3.

Assumes `avconv` is in PATH.
