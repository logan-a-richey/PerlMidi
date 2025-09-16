#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";  # Add lib folder to @INC

use MidiWriter;

my $midi = MidiWriter->new();
$midi->set_channel(0, 1);
$midi->add_bpm(0, 0, 120);
$midi->add_time_signature(0, 0, 4, 4);
$midi->add_track_name(0, "Perl MIDI Track");

$midi->add_note(0, 0, 0, 480, 60, 100);
$midi->add_note(0, 0, 480, 480, 62, 100);
$midi->add_note(0, 0, 960, 480, 64, 100);

$midi->save("test.mid");
print "MIDI file created!\n";

