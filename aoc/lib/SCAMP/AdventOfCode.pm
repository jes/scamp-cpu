package SCAMP::AdventOfCode;

use strict;
use warnings;

use HTML::Entities qw(decode_entities);
use Mojo::UserAgent;

my $LEADERBOARD_ID = 413619;

sub new {
    my ($pkg, %args) = @_;

    my $self = bless \%args, $pkg;

    $self->{ua} = Mojo::UserAgent->new;
    $self->{host} = "https://adventofcode.com";
    $self->{headers} = {
       'User-Agent' => 'github.com/jes/scamp-cpu by james@incoherency.co.uk',
    };

    return $self;
}

sub session {
    my ($self, $session) = @_;

    $self->{ua}->cookie_jar->add(
        Mojo::Cookie::Response->new(
            name => 'session',
            value => $session,
            domain => 'adventofcode.com',
            path => '/',
        )
    );
}

sub read_session {
    my ($self, $path) = @_;

    open (my $fh, '<', $path)
        or die "can't read $path: $!\n";
    my $session = <$fh>;
    chomp $session;
    close $fh;

    $self->session($session);
}

# https://github.com/dragosvecerdea/advent-of-code-cli/blob/main/src/utils/scrapers.js
sub get {
    my ($self, $year, $day, $break) = @_;

    my $dom = $self->{ua}->get("$self->{host}/$year/day/$day" => $self->{headers})->res->dom;

    my $html = $dom->find('.day-desc')->join("\n");
    $html =~ s/<\/h2>/\n/g;
    $html =~ s/<\/?\w+.*?>//g;
    $html = decode_entities($html);

    if ($break && $html =~ /\Q$break\E/) {
        $html =~ s/^.*\Q$break\E/$break/s;
    }

    return $html;
}

sub get_input {
    my ($self, $year, $day) = @_;

    my $input = $self->{ua}->get("$self->{host}/$year/day/$day/input" => $self->{headers})->res->body;
    return $input;
}

sub get_rank {
    my ($self, $year) = @_;

    my $dom = $self->{ua}->get("$self->{host}/$year/leaderboard/private/view/$LEADERBOARD_ID" => $self->{headers})->res->dom;

    $dom->find('.privboard-star-firstonly')->map(content => '.');
    $dom->find('.privboard-star-locked')->map(content => ' ');
    $dom->find('.privboard-star-unlocked')->map(content => ' ');
    my $text = $dom->find('article')->map('all_text')->join("\n");
    $text =~ s/^.*202122232425\n//gs;
    my @lines = split /\n/, $text;
    return join("\n", @lines[0..19]) . "\n";
}

sub submit {
    my ($self, $year, $day, $part, $answer) = @_;

    print STDERR "year $year; day $day; part $part; answer $answer\n";

    my $dom = $self->{ua}->post("$self->{host}/$year/day/$day/answer" => {} => form => {
        level => $part,
        answer => $answer,
    })->res->dom;

    my $html = $dom->find('article p')->join("\n");
    $html =~ s/<\/?\w+.*?>//g;
    $html =~ s/ \[Return to Day \d+\]//g;
    $html = decode_entities($html);
    return $html . "\n";
}

sub attach {
    my ($self, $serial) = @_;

    $serial->handle(get => 'aoc' => sub {
        my ($path) = @_;
        die "bad path" if $path !~ m!^/(\d+)/(\d+)(/input|/part2)?$!;
        my ($year, $day, $extra) = ($1, $2, $3);

        $extra ||= '';

        if ($extra eq '/input') {
            return $self->get_input($year, $day);
        } elsif ($extra eq '/part2') {
            return $self->get($year, $day, '--- Part Two ---');
        } else {
            return $self->get($year, $day);
        }
    });

    $serial->handle(get => 'aocrank' => sub {
        my ($path) = @_;
        die "bad path" if $path !~ m!^/(\d+)$!;
        my $year = $1;

        return $self->get_rank($year);
    });

    $serial->handle(put => 'aoc' => sub {
        my ($path, $content) = @_;
        die "bad path" if $path !~ m!^/(\d+)/(\d+)/([12])$!;
        my ($year, $day, $part) = ($1, $2, $3);

        $content =~ s/^\s+//gs;
        $content =~ s/\s+$//gs;
        return $self->submit($year, $day, $part, $content);
    });
}

1;
