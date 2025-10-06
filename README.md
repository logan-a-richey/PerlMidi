# PerlMidi
* Allows for the creation of MIDI files in Perl.
* Import and instantiate `MidiWriter.pm` package to use.

# Documentation and Usage:
```perl
# ------------------------------------------------------------
# NOTE internal class created by MidiWriter
# class Track 
my $track = Track->new();

$track->add_event($tick, $event_bytes);

$track->sort_events(); # internally sort events

# ------------------------------------------------------------
# class MidiWriter 
my $midi = MidiWriter->new();

$midi->set_channel($channel, $program);

$midi->add_bpm($track_idx, $start, $bpm);

$midi->add_time_signature($track_idx, $start, $num, $denom);

$midi->add_track_name($track_idx, $name, $start);

# NOTE that start and duration are defined in terms of 1 quarter note = 480 MIDI ticks. 
$midi->add_note($track_idx, $channel, $start, $duration, $pitch, $velocity, $off_velocity);

$midi->save($filename);
```
# License

MIT License (MIT)

Copyright (c) 2025 LoganARichey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


