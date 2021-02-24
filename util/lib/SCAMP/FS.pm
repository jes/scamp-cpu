package SCAMP::FS;

use strict;
use warnings;

my $TYPE_DIR = 0;
my $TYPE_FILE = 1;

my $BLKSZ = 512;
my $SKIP_BLOCKS = 64;
my $BITMAP_BLOCKS = 16;
my $FS_SIZE = $BLKSZ * 65536;
my $ROOTBLOCK = $SKIP_BLOCKS + $BITMAP_BLOCKS;

my $DIRENT_SIZE = 32;

sub new {
    my ($pkg, $diskfile) = @_;

    my $self = bless {}, $pkg;

    $self->{file} = $diskfile;
    $self->{cwd} = '';

    $self->load($diskfile);

    return $self;
}

sub ls {
    my ($self, $path) = @_;

    $path ||= '';
    $path = $self->abspath($path);

    my $blk0 = $self->find($path);
    die "$path: does not exist\n" if !defined $blk0;
    return $self->lsblk($blk0);
}

sub lsblk {
    my ($self, $blknum) = @_;

    my @block = $self->readblock($blknum);
    die "block $blknum: not a directory\n" if $self->blktype(@block) != $TYPE_DIR;

    my @r;

    my $off = 4;
    while (($off+$DIRENT_SIZE) <= $BLKSZ) {
        my @bytes = @block[$off .. $off+$DIRENT_SIZE-1];
        my ($name, $blknum) = $self->decode_dirent(@bytes);
        push @r, $name if $name ne '';
        $off += $DIRENT_SIZE;
    }

    my $nextblock = $self->blknext(@block);
    push @r, $self->lsblk($nextblock) if $nextblock != 0;

    return @r;
}

sub abspath {
    my ($self, $file) = @_;

    my $abs;
    if ($file =~ m{^/}) {
        $abs = $file;
    } else {
        $file =~ s{/$}{};
        $abs = "$self->{cwd}/$file";
    }

    # normalise "././././"
    $abs =~ s{/\./}{/}g;
    $abs =~ s{/\.$}{};
    # TODO: normalise "/foo/../"
    return $abs;
}

sub splitpath {
    my ($self, $abs) = @_;
    my $parents = $abs;
    $parents =~ s{/.*}{};
    my $child = $abs;
    $child =~ s{.*/}{};
    return ($parents, $child);
}

sub chdir {
    my ($self, $dir) = @_;

    if ($self->type($dir) == $TYPE_DIR) {
        $self->{cwd} = $self->abspath($dir);
    } else {
        die "$dir: not a directory\n";
    }
}

sub mkdir {
    my ($self, $dir) = @_;

    # TODO: don't allow duplicate names

    my $abs = $self->abspath($dir);
    my ($parents,$child) = $self->splitpath($abs);
    die "$parents: not a directory\n" if $self->type($parents) != $TYPE_DIR;
    my $parentblk = $self->find($parents);
    my $blk0 = $self->new_directory();
    $self->add_dirent($parentblk, $child, $blk0);
    $self->add_dirent($blk0, ".", $blk0);
    $self->add_dirent($blk0, "..", $parentblk);
}

sub unlink {
    my ($self, $name) = @_;

    my $abs = $self->abspath($name);
    my ($parents,$child) = $self->splitpath($abs);
    die "parents: not a directory\n" if $self->type($parents) != $TYPE_DIR;
    my $parentblk = $self->find($parents);
    $self->unlinkblk($parentblk, $name);
}

sub unlinkblk {
    my ($self, $blknum, $rmname, $prevblk) = @_;

    my @block = $self->readblock($blknum);
    die "block $blknum: not a directory\n" if $self->blktype(@block) != $TYPE_DIR;

    my @r;

    my $off = 4;
    my $deleted = 0;
    my $nfiles = 0;
    while (($off+$DIRENT_SIZE) <= $BLKSZ) {
        my @bytes = @block[$off .. $off+$DIRENT_SIZE-1];
        my ($name, $childblk) = $self->decode_dirent(@bytes);
        if ($name eq $rmname) {
            @block[$off .. $off+$DIRENT_SIZE-1] = $self->encode_dirent("",0);
            $self->writeblock($blknum, @block);
            $self->freefile($childblk);
            $deleted = 1;
        } elsif ($name ne '') {
            $nfiles++;
        }
        $off += $DIRENT_SIZE;
    }

    if ($deleted) {
        if ($nfiles == 0 && $prevblk) {
            # make prevblk's "next" point at our "next"
            my $next = $self->blknext(@block);
            my @prevblock = $self->readblock($prevblk);
            $prevblock[2] = $next>>8;
            $prevblock[3] = $next&0xff;
            # and mark our block as free
            $self->setblkused($blknum, 0);
        }
        return;
    }

    my $nextblock = $self->blknext(@block);
    if ($nextblock != 0) {
        $self->unlinkblk($nextblock, $rmname, $blknum);
    } else {
        die "not found: $rmname\n";
    }
}

sub freedir {
    my ($self, $blk, @block) = @_;

    my $off = 4;
    while (($off+$DIRENT_SIZE) <= $BLKSZ) {
        my @bytes = @block[$off .. $off+$DIRENT_SIZE-1];
        my ($name, $childblk) = $self->decode_dirent(@bytes);
        $self->freefile($childblk) if $name ne '' && $name ne '.' && $name ne '..';
        $off += $DIRENT_SIZE;
    }
}

sub freefile {
    my ($self, $blk) = @_;

    while ($blk) {
        my @block = $self->readblock($blk);
        if ($self->blktype(@block) == $TYPE_DIR) {
            $self->freedir($blk, @block);
        }
        $self->setblkused($blk, 0);
        $blk = $self->blknext(@block);
    }
}

sub type {
    my ($self, $path) = @_;

    my $blk0 = $self->find($path);
    die "$path: no such file\n" if !defined $blk0;

    my @data = $self->readblock($blk0);
    return $self->blktype(@data);
}

sub blktype {
    my ($self, @data) = @_;
    return $data[0] >> 1;
}

sub blknext {
    my ($self, @data) = @_;
    return ($data[2]<<8)|$data[3];
}

sub find {
    my ($self, $path) = @_;

    my $abspath = $self->abspath($path);
    $abspath =~ s{^/}{};
    $abspath =~ s{/$}{};

    my $origpath = $abspath;

    my $blknum = $ROOTBLOCK;

    while ($abspath =~ s{([^/]+)/?}{}) {
        my $name = $1;
        $blknum = $self->find_name_in_dir($blknum, $name);
        return undef if !defined $blknum;
    }

    return $blknum;
}

sub find_name_in_dir {
    my ($self, $inblock, $findname) = @_;

    my @block = $self->readblock($inblock);
    die "block $inblock: not a directory\n" if $self->blktype(@block) != $TYPE_DIR;

    die "wrong block length: " . scalar(@block) . "\n" if @block != $BLKSZ;

    my $off = 4;
    while (($off+$DIRENT_SIZE) <= $BLKSZ) {
        my @bytes = @block[$off .. $off+$DIRENT_SIZE-1];
        my ($name, $blknum) = $self->decode_dirent(@bytes);
        return $blknum if $blknum != 0 && $name eq $findname;
        $off += $DIRENT_SIZE;
    }

    return undef;
}

sub decode_dirent {
    my ($self, @dirent) = @_;

    die "wrong length: " . scalar(@dirent) . "\n" if @dirent != 32;

    my $name = join('', map { chr($_) } @dirent[0..29]);
    $name =~ s/\0.*$//; # names are nul-terminated
    my $blknum = ($dirent[30] << 8) | $dirent[31];

    return ($name, $blknum);
}

sub encode_dirent {
    my ($self, $name, $blknum) = @_;

    my @de = map { ord($_) } split //, $name;
    die "$name: name too long\n" if @de >= 30;
    push @de, 0 while @de < 30;

    push @de, $blknum>>8;
    push @de, $blknum&0xff;

    return @de;
}

sub add_dirent {
    my ($self, $dirblk, $addname, $blk0) = @_;

    my @block = $self->readblock($dirblk);
    die "block $dirblk: not a directory\n" if $self->blktype(@block) != $TYPE_DIR;

    die "wrong block length: " . scalar(@block) . "\n" if @block != $BLKSZ;

    my $off = 4;
    while (($off+$DIRENT_SIZE) <= $BLKSZ) {
        my @bytes = @block[$off .. $off+$DIRENT_SIZE-1];
        my ($name, $blknum) = $self->decode_dirent(@bytes);
        if ($name eq '') {
            @block[$off .. $off+$DIRENT_SIZE-1] = $self->encode_dirent($addname, $blk0);
            $self->writeblock($dirblk, @block);
            return;
        }
        $off += $DIRENT_SIZE;
    }

    my $next = $self->blknext(@block);
    if ($next == 0) {
        $next = $self->new_directory();
        $block[2] = $next>>8;
        $block[3] = $next&0xff;
        $self->writeblock($dirblk, @block);
    }
    $self->add_dirent($next, $addname, $blk0);
}

sub blkisfree {
    my ($self, $blknum) = @_;

    my $blkblk = $SKIP_BLOCKS + int($blknum / ($BLKSZ * 8));
    my $byteinblk = int(($blknum % $BLKSZ)/8);
    my $bitinbyte = $blknum % 8;

    my @bitmapblock = $self->readblock($blkblk);
    my $byte = $bitmapblock[$byteinblk];
    my $bit = !! ($byte & (1 << $bitinbyte));
    return $bit == 0;
}

sub setblkused {
    my ($self, $blknum, $used) = @_;

    my $blkblk = $SKIP_BLOCKS + int($blknum / ($BLKSZ * 8));
    my $byteinblk = int(($blknum % $BLKSZ)/8);
    my $bitinbyte = $blknum % 8;

    my @bitmapblock = $self->readblock($blkblk);

    if ($used) {
        $bitmapblock[$byteinblk] |= (1 << $bitinbyte);
    } else {
        $bitmapblock[$byteinblk] &= ~(1 << $bitinbyte);
    }

    $self->writeblock($blkblk, @bitmapblock);
}

sub allocate_block {
    my ($self) = @_;
    for my $blknum (0 .. 65535) {
        if ($self->blkisfree($blknum)) {
            $self->setblkused($blknum, 1);
            return $blknum;
        }
    }
    die "filesystem full\n";
}

sub new_directory {
    my ($self) = @_;

    my $blknum = $self->allocate_block();

    my @data = (0)x$BLKSZ;
    $data[0] = $TYPE_DIR << 1;

    $self->writeblock($blknum, @data);

    return $blknum;
}

sub writeblock {
    my ($self, $blknum, @block) = @_;

    die "wrong block length: " . scalar(@block) . "\n" if @block != $BLKSZ;

    my $start = $BLKSZ * $blknum;

    @{ $self->{disk} }[$start .. $start+$BLKSZ-1] = @block;
}

sub readblock {
    my ($self, $blknum) = @_;

    my $start = $BLKSZ * $blknum;

    return @{ $self->{disk} }[$start .. $start+$BLKSZ-1];
}

sub cwd {
    my ($self) = @_;
    return $self->{cwd};
}

sub load {
    my ($self) = @_;

    open(my $fh, '<', $self->{file})
        or die "can't read $self->{file}: $!\n";
    my @d;
    while (<$fh>) {
        chomp;
        push @d, hex($_);
    }
    close $fh;

    $self->{disk} = \@d;
}

sub save {
    my ($self) = @_;

    open(my $fh, '>', $self->{file})
        or die "can't write $self->{file}: $!\n";
    print $fh sprintf("%02x\n", $_) for @{ $self->{disk} };
    close $fh;
}

1;
