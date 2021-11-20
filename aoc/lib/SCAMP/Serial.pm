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

sub read {
    my ($self, $size) = @_;

    $size++; # grab trailing \n

    my $need = $size;
    my $data;
    while ($need) {
        my $n = read($self->{readfh}, $data, $need, $size-$need);
        die "error on input" if !defined $n;
        die "eof on input" if $n == 0;
        $need = $need - $n;
    }

    # remove trailing \n
    die "content did not end with \\n" if $data !~ /\n$/;
    $data =~ s/\n$//;

    return $data;
}

sub write {
    my ($self, $data) = @_;

    my $fh = $self->{writefh};

    for my $c (split //, $data) {
        usleep(10000);
        print $fh $c;
    }
}

sub run {
    my ($self) = @_;

    my $rfh = $self->{readfh};

    while (my $line = <$rfh>) {
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
                $self->write("ok $size\n$response\n");
            }
        } catch {
            $_ =~ s/\n/ /g;
            my $size = length($_);
            print STDERR "error $size: $_\n";
            $self->write("error $size\n$_\n");
        };
    }
}

1;
