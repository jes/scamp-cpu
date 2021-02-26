# Filesystem routines

include "data.sl";
include "util.sl";

var fs_read = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var readsz = 0;
    var blknum = *(fdbase+FDDATA);
    var seekpos = *(fdbase+FDDATA+1);
    var startat;
    var remain;
    var read;
    var p = buf;

    var blklength;

    while (sz) {
        # read the current block of the file
        blkread(blknum);

        # 254 words per block, so the position within the block contents is seekpos%254
        #   startat = seekpos % 254;
        divmod(seekpos, BLKSZ-2, 0, &startat);

        # blklen() is counted in bytes, so the number of words remaining is:
        #   ceil(blklen/2) - startat
        remain = half(blklen()+1) - startat;
        if (remain == 0) {
            read = 0;
            if (blknext()) blknum = blknext()
            else break; # EOF
        } else if (remain <= sz) {
            # consume the entire block
            read = remain;
            if (blknext()) blknum = blknext();
        } else {
            # don't consume the entire block
            read = sz;
        };

        # copy data to user buffer
        # "startat+2" skips over the block header
        memcpy(buf+readsz, BLKBUF+startat+2, read);

        readsz = readsz + read;
        sz = sz - read;
        seekpos = seekpos + read;
    };

    *(fdbase+FDDATA) = blknum;
    *(fdbase+FDDATA+1) = seekpos;

    return readsz;
};

var fs_write = func() unimpl("fs_write");
var fs_tell = func() unimpl("fs_tell");
var fs_seek = func() unimpl("fs_seek");

# we don't need to do anything to close the file, just forget everything
var fs_close = fdfree;
