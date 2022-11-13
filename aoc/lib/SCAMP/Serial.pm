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

my $SLEEP_US = 1000;

sub new {
    my ($pkg, $readfile, $writefile) = @_;

    my $self = bless {}, $pkg;
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
        usleep($SLEEP_US);
        print $fh $c;
    }
}

sub chunked_write {
    my ($self, $data) = @_;

    while (length($data)) {
        # we expect a "!" to prompt each chunk
        my $prompt = $self->read(1);
        return if $prompt ne "!";

        my $chunk = substr($data, 0, 256, '');
        $self->write($chunk);
    }
}

sub run {
    my ($self) = @_;

    my $rfh = $self->{readfh};

    print STDERR "> ";
    while (my $line = <$rfh>) {
        $line =~ s/\r?\n?$//;
        next if $line eq '';

        print STDERR "$line: ";

        try {
            $line =~ /^(\w+) (\w+) (\d+) (.*)$/ or die "unrecognised request\n";
            my ($method, $type, $size, $path) = ($1, $2, $3, $4);
            my $content = $self->read($size);
            if ($self->{handlers}{$method}{$type}) {
                my $response = $self->{handlers}{$method}{$type}->($path, $content);
                my $size = length($response);
                print STDERR "ok $size\n";
                $self->write("ok $size\n");
                $self->chunked_write("$response\n");
            } else {
                die "no handler for '$method $type'\n";
            }
        } catch {
            $_ =~ s/\n/ /g;
            my $size = length($_);
            print STDERR "error $size: $_\n";
            try {
                $self->write("error $size\n");
                $self->chunked_write("$_\n");
            } catch {
                print STDERR "error while writing error: $_";
            };
        };

        print STDERR "> ";
    }
}

1;
