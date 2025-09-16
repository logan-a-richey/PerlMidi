package MidiWriter;
use strict;
use warnings;


# Export nothing by default 
our @EXPORT_OK = ();
our $VERSION = '0.01';

# ---- Track class inside the module ----
{
    package MidiWriter::Track;
    sub new {
        my $class = shift;
        my $self = { events => [] };
        return bless $self, $class;
    }

    sub add_event {
        my ($self, $tick, $event_bytes) = @_;
        push @{$self->{events}}, [$tick, $event_bytes];
    }

    sub sort_events {
        my ($self) = @_;
        @{$self->{events}} = sort { $a->[0] <=> $b->[0] } @{$self->{events}};
    }
}

# ---- MidiWriter class ----
use constant {
    META_END_OF_TRACK          => "\xFF\x2F\x00",
    META_TEMPO_PREFIX          => "\xFF\x51\x03",
    META_TIME_SIGNATURE_PREFIX => "\xFF\x58\x04",
    TICKS_PER_QUARTER          => 480,
};

sub new {
    my $class = shift;
    my $self = {
        tracks          => [],
        channel_program => {},
    };
    return bless $self, $class;
}

sub add_track {
    my ($self) = @_;
    my $track = Track->new();
    push @{$self->{tracks}}, $track;
    return $#{$self->{tracks}};  # index of new track
}

sub _get_track {
    my ($self, $idx) = @_;
    while ($idx >= @{$self->{tracks}}) {
        $self->add_track();
    }
    return $self->{tracks}->[$idx];
}

sub set_channel {
    my ($self, $channel, $program) = @_;
    $self->{channel_program}->{$channel} = $program;
    my $event = pack("C2", 0xC0 | ($channel & 0x0F), $program & 0x7F);
    $self->_get_track(0)->add_event(0, $event);
}

sub add_bpm {
    my ($self, $track_idx, $start, $bpm) = @_;
    return if $bpm <= 0;
    my $tempo = int(60000000 / $bpm);
    my $tempo_bytes = pack("C3",
        ($tempo >> 16) & 0xFF,
        ($tempo >> 8)  & 0xFF,
        $tempo & 0xFF
    );
    my $event = META_TEMPO_PREFIX . $tempo_bytes;
    $self->_get_track($track_idx)->add_event($start, $event);
}

sub add_time_signature {
    my ($self, $track_idx, $start, $num, $denom) = @_;
    return if $num <= 0 || ($denom & ($denom - 1)) != 0;

    my $dd = 0;
    my $d  = $denom;
    while ($d > 1) { $d >>= 1; $dd++; }
    my $cc = 24;
    my $bb = 8;
    my $event = META_TIME_SIGNATURE_PREFIX . pack("C4", $num, $dd, $cc, $bb);
    $self->_get_track($track_idx)->add_event($start, $event);
}

sub add_track_name {
    my ($self, $track_idx, $name, $start) = @_;
    $start //= 0;
    my $event = pack("C3", 0xFF, 0x03, length($name)) . $name;
    $self->_get_track($track_idx)->add_event($start, $event);
}

sub add_note {
    my ($self, $track_idx, $channel, $start, $duration,
        $pitch, $velocity, $off_velocity) = @_;
    $off_velocity //= 64;

    die "Velocity out of range: $velocity"
        if $velocity <= 0 || $velocity > 127;
    die "Non-positive duration: $duration"
        if $duration <= 0;

    my $end = $start + $duration;
    my $track = $self->_get_track($track_idx);

    my $note_on  = pack("C3", 0x90 | ($channel & 0x0F), $pitch & 0x7F, $velocity & 0x7F);
    my $note_off = pack("C3", 0x80 | ($channel & 0x0F), $pitch & 0x7F, $off_velocity & 0x7F);

    $track->add_event($start, $note_on);
    $track->add_event($end,   $note_off);
}

sub encode_var_len {
    my ($self, $value) = @_;
    my @buffer = ($value & 0x7F);
    $value >>= 7;
    while ($value) {
        unshift @buffer, (($value & 0x7F) | 0x80);
        $value >>= 7;
    }
    return pack("C*", @buffer);
}

sub save {
    my ($self, $filename) = @_;

    # Sort events
    $_->sort_events() for @{$self->{tracks}};

    # MIDI header
    my $format = @{$self->{tracks}} > 1 ? 1 : 0;

    # <-- FIXED: use N (32-bit big-endian) and n (16-bit big-endian) instead of Python-style ">IHHH"
    my $header = "MThd" . pack("Nnnn", 6, $format, scalar(@{$self->{tracks}}), TICKS_PER_QUARTER);

    my $output = $header;

    for my $track (@{$self->{tracks}}) {
        my $track_data = "";
        my $last_tick = 0;

        for my $event (@{$track->{events}}) {
            my ($tick, $bytes) = @$event;
            my $delta = $tick - $last_tick;
            $last_tick = $tick;
            $track_data .= $self->encode_var_len($delta) . $bytes;
        }

        # End of track
        $track_data .= $self->encode_var_len(0) . META_END_OF_TRACK;

        # <-- FIXED: use N (big-endian 32-bit) instead of ">I"
        $output .= "MTrk" . pack("N", length($track_data)) . $track_data;
    }

    open my $fh, ">:raw", $filename
        or die "Cannot open $filename: $!";
    print $fh $output;
    close $fh;
    print "Saved MIDI file: $filename\n";
}


################################################################################
# Example usage
package main;
my $midi = MidiWriter->new();
$midi->set_channel(0, 1);
$midi->add_bpm(0, 0, 120);
$midi->add_time_signature(0, 0, 4, 4);
$midi->add_track_name(0, "Perl MIDI Track");

$midi->add_note(0, 0, 0, 480, 60, 100); # middle C, quarter note
$midi->add_note(0, 0, 480, 480, 62, 100);
$midi->add_note(0, 0, 960, 480, 64, 100);

$midi->save("test.mid");

