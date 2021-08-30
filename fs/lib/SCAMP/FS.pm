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
    $self->{lastfreeblk} = 0;

    $self->load($diskfile);

    return $self;
}

# utility functions that don't touch the disk:

sub cwd {
    my ($self) = @_;
    return $self->{cwd};
}

sub abspath {
    my ($self, $file) = @_;

    my $abs;
    if ($file =~ m{^/}) {
        $abs = $file;
    } else {
        $abs = "$self->{cwd}/$file";
    }

    # normalise "././././"
    $abs =~ s{/\./}{/}g;
    $abs =~ s{/\.$}{};
    # normalise "/foo/../"
    $abs =~ s{/[^/]+/\.\./}{/}g;
    $abs =~ s{/[^/]+/\.\.$}{}g;
    # normalise "////foo///"
    $abs =~ s{/+}{/}g;

    # strip trailing slash
    $abs =~ s{/$}{};
    # add slash back if it's root dir
    $abs = '/' if $abs eq '';
    return $abs;
}

sub splitpath {
    my ($self, $abs) = @_;
    my $parents = $abs;
    $parents =~ s{/[^/]*$}{};
    my $child = $abs;
    $child =~ s{.*/}{};
    return ($parents, $child);
}

# functions that take names:

sub nametype {
    my ($self, $path) = @_;

    my $blk0 = $self->find($path);
    die "$path: does not exist\n" if !defined $blk0;
    my @block = $self->readblock($blk0);
    return $self->blktype(@block);
}

sub namelen {
    my ($self, $path) = @_;

    my $blk0 = $self->find($path);
    die "$path: does not exist\n" if !defined $blk0;

    return $self->lenblk($blk0);
}

sub ls {
    my ($self, $path) = @_;

    my $blk0 = $self->find($path);
    die "$path: does not exist\n" if !defined $blk0;
    return $self->lsblk($blk0);
}

sub get {
    my ($self, $path) = @_;

    my $blk0 = $self->find($path);
    die "$path: does not exist\n" if !defined $blk0;
    return $self->getblk($blk0)
}

sub put {
    my ($self, $path, $str) = @_;

    my $abs = $self->abspath($path);
    die "$path: already exists\n" if $self->find($abs);
    my ($parents,$child) = $self->splitpath($abs);
    die "$parents: not a directory\n" if $self->nametype($parents) != $TYPE_DIR;
    my $parentblk = $self->find($parents);
    my $blk0 = $self->new_file;
    $self->add_dirent($parentblk, $child, $blk0);
    $self->blkadd($blk0, $str);
}

sub chdir {
    my ($self, $dir) = @_;

    if ($self->nametype($dir) == $TYPE_DIR) {
        $self->{cwd} = $self->abspath($dir);
    } else {
        die "$dir: not a directory\n";
    }
}

sub mkdir {
    my ($self, $dir) = @_;

    # TODO: don't allow duplicate names

    my $abs = $self->abspath($dir);
    die "$dir: already exists\n" if $self->find($abs);
    my ($parents,$child) = $self->splitpath($abs);
    die "$parents: not a directory\n" if $self->nametype($parents) != $TYPE_DIR;
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
    die "parents: not a directory\n" if $self->nametype($parents) != $TYPE_DIR;
    my $parentblk = $self->find($parents);
    $self->unlinkblk($parentblk, $name);
}

sub find {
    my ($self, $path) = @_;

    $path ||= '';
    my $abspath = $self->abspath($path);
    $abspath =~ s{^/}{};
    $abspath =~ s{/$}{};

    my $origpath = $abspath;

    my $blknum = $ROOTBLOCK;

    while ($abspath =~ s{([^/]+)/?}{}) {
        my $name = $1;
        $blknum = $self->find_name_in_dir($blknum, $name);
        return undef if !$blknum;
    }

    return $blknum;
}

sub find_name_in_dir {
    my ($self, $inblock, $findname) = @_;

    my @block = $self->readblock($inblock);
    die "block $inblock: not a directory\n" if $self->blktype(@block) != $TYPE_DIR;

    die "wrong block length: " . scalar(@block) . "\n" if @block != $BLKSZ;

    my $foundblk = 0;
    $self->dirwalk($inblock, sub {
        my ($name, $blknum) = @_;
        return 1 if $name ne $findname;
        $foundblk = $blknum;
        return 0;
    });

    return $foundblk;
}

# functions that take block numbers:

sub lenblk {
    my ($self, $blk) = @_;

    my $len = 0;
    my $blks = 0;

    while ($blk) {
        my @block = $self->readblock($blk);
        $len += $self->blklen(@block);
        $blks++;
        $blk = $self->blknext(@block);
    }

    return ($blks, $len);
}

sub lsblk {
    my ($self, $blknum) = @_;

    my @r;
    $self->dirwalk($blknum, sub {
        my ($name) = @_;
        push @r, $name if $name ne '';
    });
    return @r;
}

sub getblk {
    my ($self, $blknum) = @_;

    my @block = $self->readblock($blknum);
    die "block $blknum: not a file\n" if $self->blktype(@block) != $TYPE_FILE;

    my $c = '';

    my $len = $self->blklen(@block)*2;
    $c = join('', map { chr($_) } @block[4..4+$len-1]);

    my $next = $self->blknext(@block);
    if ($next) {
        return $c . $self->getblk($next);
    } else {
        return $c;
    }
}

sub blkadd {
    my ($self, $blknum, $str) = @_;

    while (1) {
        my $len = length($str) > 508 ? 508 : length($str);
        my $add = substr($str, 0, $len, '');

        my @block = $self->readblock($blknum);
        @block[4..4+$len-1] = map { ord($_) } split //, $add;

        $block[1] = int(($len+1)/2)&0xff;

        if ($str ne '') {
            my $newblk = $self->new_file;
            $block[2] = $newblk>>8;
            $block[3] = $newblk&0xff;
            $self->writeblock($blknum, @block);
            $blknum = $newblk;
        } else {
            $self->writeblock($blknum, @block);
            return;
        }
    }
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

    $self->dirwalk($blk, sub {
        my ($name, $childblk) = @_;
        $self->freefile($childblk) if $name ne '' && $name ne '.' && $name ne '..';
    });
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

sub findfreeblk {
    my ($self) = @_;
    my @block;
    my $readblk = -1;
    for my $b (0 .. 65535) {
        my $blknum = ($b+$self->{lastfreeblk}+1)&0xffff;
        my $blkblk = $SKIP_BLOCKS + int($blknum / ($BLKSZ * 8));
        my $byteinblk = int($blknum/8) % $BLKSZ;
        $byteinblk ^= 1; # swap endianness
        my $bitinbyte = $blknum % 8;

        if ($blkblk != $readblk) {
            @block = $self->readblock($blkblk);
            $readblk = $blkblk;
        }
        my $byte = $block[$byteinblk];
        my $bit = $byte & (1 << $bitinbyte);

        if ($bit == 0) {
            $self->{lastfreeblk} = $blknum;
            return $blknum;
        }
    }
    die "filesystem full\n";
}

sub blkisfree {
    my ($self, $blknum) = @_;

    my $blkblk = $SKIP_BLOCKS + int($blknum / ($BLKSZ * 8));
    my $byteinblk = int($blknum/8) % $BLKSZ;
    $byteinblk ^= 1; # swap endianness
    my $bitinbyte = $blknum % 8;

    my @bitmapblock = $self->readblock($blkblk);
    my $byte = $bitmapblock[$byteinblk];
    my $bit = $byte & (1 << $bitinbyte);
    return $bit == 0;
}

sub setblkused {
    my ($self, $blknum, $used) = @_;

    my $blkblk = $SKIP_BLOCKS + int($blknum / ($BLKSZ * 8));
    my $byteinblk = int($blknum/8) % $BLKSZ;
    $byteinblk ^= 1; # swap endianness
    my $bitinbyte = $blknum % 8;

    my @bitmapblock = $self->readblock($blkblk);

    if ($used) {
        $bitmapblock[$byteinblk] |= (1 << $bitinbyte);
    } else {
        $bitmapblock[$byteinblk] &= ~(1 << $bitinbyte);
    }

    $self->writeblock($blkblk, @bitmapblock);
}

# functions for dealing with directory entries:

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

    my $done = 0;
    my $lastdirblknum;
    my $lastdirblkdata;
    $self->dirwalk($dirblk, sub {
        my ($name, $blk, $dirblknum, $off, $dirblkdata) = @_;
        $lastdirblknum = $dirblknum;
        $lastdirblkdata = $dirblkdata;
        return 1 if $name ne ''; # continue searching until we find an empty slot

        my @block = @$dirblkdata;
        @block[$off .. $off+$DIRENT_SIZE-1] = $self->encode_dirent($addname, $blk0);
        $self->writeblock($dirblknum, @block);
        $done = 1;
        return 0;
    });

    return if $done;

    # if we didn't find an empty space in the directory, add a new block to this directory
    my $newdir = $self->new_directory();
    $lastdirblkdata->[2] = $newdir>>8;
    $lastdirblkdata->[3] = $newdir&0xff;
    $self->writeblock($lastdirblknum, @$lastdirblkdata);
    $self->add_dirent($newdir, $addname, $blk0);
}

# call $cb->($name, $blk, $dirblk, $dirent_offset, \@block) for every entry in the directory
# if the callback returns truthy, continue
# if the callback returns falsey, stop early
sub dirwalk {
    my ($self, $dirblk, $cb) = @_;

    while ($dirblk != 0) {
        my @block = $self->readblock($dirblk);
        die "block $dirblk: not a directory\n" if $self->blktype(@block) != $TYPE_DIR;

        my $off = 4;
        while (($off+$DIRENT_SIZE) <= $BLKSZ) {
            my @bytes = @block[$off .. $off+$DIRENT_SIZE-1];
            my ($name, $blknum) = $self->decode_dirent(@bytes);
            return if !$cb->($name, $blknum, $dirblk, $off, \@block);
            $off += $DIRENT_SIZE;
        }

        $dirblk = $self->blknext(@block);
    }
}

# functions that directly interact with the disk:

sub free {
    my ($self) = @_;

    my $ntotal = 65536;
    my $nfree = 0;

    for my $blk (0 .. 65535) {
        $nfree++ if $self->blkisfree($blk);
    }

    return ($nfree, $ntotal);
}

sub blktype {
    my ($self, @data) = @_;
    return $data[0];
}

sub blklen {
    my ($self, @data) = @_;
    return $data[1];
}

sub blknext {
    my ($self, @data) = @_;
    return ($data[2]<<8)|$data[3];
}

sub allocate_block {
    my ($self) = @_;
    my $blknum = $self->findfreeblk;
    $self->setblkused($blknum, 1);
    return $blknum;
}

sub new_directory {
    my ($self) = @_;

    my $blknum = $self->allocate_block();

    my @data = (0)x$BLKSZ;
    $data[0] = $TYPE_DIR;

    $self->writeblock($blknum, @data);

    return $blknum;
}

sub new_file {
    my ($self) = @_;

    my $blknum = $self->allocate_block();

    my @data = (0)x$BLKSZ;
    $data[0] = $TYPE_FILE;

    $self->writeblock($blknum, @data);

    return $blknum;
}

sub writeblock {
    my ($self, $blknum, @block) = @_;

    die "wrong block length: " . scalar(@block) . "\n" if @block != $BLKSZ;

    my $start = $BLKSZ * $blknum;

    substr($self->{disk}, $start, $BLKSZ, pack("C*", @block));
}

sub readblock {
    my ($self, $blknum) = @_;

    my $start = $BLKSZ * $blknum;

    return unpack("C*", substr($self->{disk}, $start, $BLKSZ));
}

sub load {
    my ($self) = @_;

    open(my $fh, '<', $self->{file})
        or die "can't read $self->{file}: $!\n";
    my $n = read($fh, $self->{disk}, $FS_SIZE);
    die "read: expected $FS_SIZE bytes but only got $n\n" if $n != $FS_SIZE;
    close $fh;
}

sub save {
    my ($self) = @_;

    open(my $fh, '>', $self->{file})
        or die "can't write $self->{file}: $!\n";
    print $fh $self->{disk};
    close $fh;
}

1;
