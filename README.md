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
MIT License

