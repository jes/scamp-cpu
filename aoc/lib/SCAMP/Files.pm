package SCAMP::Files;

# TODO: [nice] support changing working directory
# TODO: [bug] don't allow "../../../../../../../etc/passwd" etc. to grab arbitrary files

use strict;
use warnings;

sub new {
    my ($pkg, %args) = @_;

    my $self = bless \%args, $pkg;

    return $self;
}

sub attach {
    my ($self, $serial) = @_;

    $serial->handle(get => 'file' => sub {
        my ($path) = @_;
        open (my $fh, '<', $path)
            or die "can't read $path: $!";
        my $c = join('', <$fh>);
        close $fh;
        return $c;
    });

    $serial->handle(put => 'file' => sub {
        my ($path, $content) = @_;
        open (my $fh, '>', $path)
            or die "can't write $path: $!";
        print $fh $content;
        close $fh;
        return 'ok';
    });
}

1;
