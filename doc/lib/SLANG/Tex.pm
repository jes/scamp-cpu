package SLANG::Tex;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(texescape template slurp);

sub texescape {
    my ($str) = @_;
    $str =~ s/([_&#^{}])/\\$1/g;
    return $str;
}

sub template {
    my ($tmpl, $fields) = @_;
    for my $f (keys %$fields) {
        $tmpl =~ s/$f/$fields->{$f}/g;
    }
    return $tmpl;
}

sub slurp {
    my ($name) = @_;
    open(my $fh, '<', $name)
        or die "can't read $name: $!\n";
    my $c = join('', <$fh>);
    close $fh;
    return $c;
}

1;
