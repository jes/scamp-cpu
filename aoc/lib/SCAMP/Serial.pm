package SCAMP::Serial;

# TODO: [nice] better synchronisation than ping/pong
# TODO: [nice] error checking (e.g. CRC)
# TODO: [nice] some way to push multiple responses to the client? e.g. if we want to transfer a directory
# TODO: [nice] protocol documentation

use strict;
use warnings;

use IO::Handle;
use Time::HiRes qw(usleep);
use Try::Tiny;

sub new {
    my ($pkg, $readfile, $writefile) = @_;

    my $self = bless {}, $pkg;
    #open ($self->{readfh}, '<', $readfile)
    #    or die "can't read $readfile: $!\n";
    #open ($self->{writefh}, '>', $writefile)
    #    or die "can't write $writefile: $!\n";
    $self->{readfh} = $readfile;
    $self->{writefh} = $writefile;

    $self->{readfh}->autoflush(1);
    $self->{writefh}->autoflush(1);

    $self->{readbuf} = '';

    $self->{handlers} = {};

    $self->handle(get => 'ping' => sub {
        my ($path) = @_;
        return "pong:$path";
    });

    return $self;
}

sub handle {
    my ($self, $method, $type, $handler) = @_;

    $self->{handlers}{$method}{$type} = $handler;
}

sub readbytes {
    my ($self, $size) = @_;

    my $need = $size;
    my $data;
    while ($need) {
        my $n = read($self->{readfh}, $data, $need, $size-$need);
        die "error on input" if !defined $n;
        die "eof on input" if $n == 0;
        $need = $need - $n;
    }

    return $data;
}

sub writebytes {
    my ($self, $bytes) = @_;

    my $fh = $self->{writefh};
    # TODO: [perf] make serial.sl fast enough to consume the entire packet at full speed
    # print $fh $bytes;
    for my $c (split //, $bytes) {
        usleep(1000);
        print $c;
    }
}

sub readpacket {
    my ($self) = @_;

    my $soh;

    PACKET: while (1) {
        SOH: while (1) {
            $soh = $self->readbytes(1);
            # XXX: is this best? if SOH ne \x01, we're out of sync, but the other side may be expecting a NAK? should we send one? do packets need sequence ids?
            last SOH if $soh eq "\x01";
        }

        my $size = $self->readbytes(1);
        my $content = $self->readbytes(ord($size));
        my $checksum = $self->readbytes(1);

        my $sum = 0;
        for my $c (split //, $soh.$size.$content.$checksum) {
            $sum += ord($c);
        }
        $sum = $sum & 0xff;
        if ($sum != 0) {
            # checksum failed: send NAK and read packet again
            $self->writebytes("\x15"); # NAK
            next PACKET;
        }

        # checksum good: send ACK and return packet content
        $self->writebytes("\x06"); # ACK
        return $content;
    }
}

sub writepacket {
    my ($self, $content) = @_;

    die "content too long: " . length($content) if length($content) > 255;
    my $soh = "\x01";
    my $size = chr(length($content));
    my $sum = 0;
    for my $c (split //, $soh . $size . $content) {
        $sum += ord($c);
    }
    $sum = $sum & 0xff;
    my $checksum = chr(0x100 - $sum);
    my $packet = $soh . $size . $content . $checksum;

    while (1) {
        $self->writebytes($packet);
        my $response = $self->readbytes(1);
        last if $response eq "\x06"; # ACK - success
        next if $response eq "\x15"; # NAK - resend
        die "unexpected packet response: " . sprintf("0x%02x", ord($response));
    }
}

sub read {
    my ($self, $size) = @_;

    $size++; # grab trailing \n

    while (length($self->{readbuf}) < $size) {
        $self->{readbuf} .= $self->readpacket;
    }

    # grab & remove in one substr() call
    my $data = substr($self->{readbuf}, 0, $size, '');

    # remove trailing \n
    die "content did not end with \\n" if $data !~ /\n$/;
    $data =~ s/\n$//;

    return $data;
}

sub readline {
    my ($self) = @_;

    while ($self->{readbuf} !~ /\n/) {
        $self->{readbuf} .= $self->readpacket;
    }

    $self->{readbuf} =~ s/^(.*\n)//;
    return $1;
}

sub write {
    my ($self, $data) = @_;

    while (length($data) > 255) {
        my $part = substr($data, 0, 255, '');
        $self->writepacket($part);
    }
    $self->writepacket($data) if length($data);
}

sub run {
    my ($self) = @_;

    my $rfh = $self->{readfh};

    while (my $line = $self->readline) {
        $line =~ s/\r?\n?$//;

        try {
            $line =~ /^(\w+) (\w+) (\d+) (.*)$/ or die "unrecognised request\n";
            my ($method, $type, $size, $path) = ($1, $2, $3, $4);
            print STDERR "$method $type $size $path: ";
            my $content = $self->read($size);
            if ($self->{handlers}{$method}{$type}) {
                my $response = $self->{handlers}{$method}{$type}->($path, $content);
                my $size = length($response);
                print STDERR "ok $size\n";
                $self->write("ok $size\n");
                $self->write("$response\n");
            }
        } catch {
            $_ =~ s/\n/ /g;
            my $size = length($_);
            print STDERR "error $size: $_\n";
            $self->write("error $size\n");
            $self->write("$_\n");
        };
    }
}

1;
