package SCAMP::AdventOfCode;

use strict;
use warnings;

use HTML::Entities qw(decode_entities);
use Mojo::UserAgent;

sub new {
    my ($pkg, %args) = @_;

    my $self = bless \%args, $pkg;

    $self->{ua} = Mojo::UserAgent->new;
    $self->{host} = "https://adventofcode.com";

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
    my ($self, $year, $day) = @_;

    my $dom = $self->{ua}->get("$self->{host}/$year/day/$day")->res->dom;

    my $html = $dom->find('.day-desc')->join("\n");
    $html =~ s/<\/h2>/\n/g;
    $html =~ s/<\/?\w+.*?>//g;
    $html = decode_entities($html);
    return $html;
}

sub submit {
    my ($self, $year, $day, $part, $answer) = @_;

    print STDERR "year $year; day $day; part $part; answer $answer\n";

    my $dom = $self->{ua}->post("$self->{host}/$year/day/$day/answer" => {} => form => {
        level => $part,
        answer => $answer,
    })->res->dom;

    my $html = $dom->find('article p')->join("\n");
    print STDERR "html = $html\n";
    $html =~ s/<\/?\w+.*?>//g;
    $html =~ s/ \[Return to Day \d+\]//g;
    $html = decode_entities($html);
    return $html;
}

1;
