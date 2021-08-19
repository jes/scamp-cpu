# Filesystem

The filesystem consists of 512-byte blocks.

The first 64 blocks (32K) on the device are ignored. They're used to store the kernel.

The next 16 blocks (8K) are a bitmap saying which of the rest of the blocks are already in use.

The next up-to-65536 blocks (32M) are the filesystem contents.

Where the device is smaller than 32M, the bitmaps should mark the unavailable blocks as "in use".

The first 4 bytes of each block are decoded as follows:

    |    type       |  length       |       next block pointer      |
    |. . . . . . . .|. . . . . . . .|. . . . . . . .|. . . . . . . .|

(Although 8 bits are currently allocated for "type", only types 0 (directory) and
1 (file) are assigned; the upper 7 bits are currently unused).

"length" is 8 bits, indicating how many words of the current block is to be used for
this node, not including the header.

"next block pointer" contains the number of the next block that forms part of this
file or directory, or 0 if this is the last block.

See below for examples.

Block 0 is the root directory of the filesystem.

## Type 0 (directory)

After the 4 byte header, the remaining 508 bytes consist of up to 15 directory entries.

The length field is ignored. The "next" block (if nonzero) contains more files for
the same directory.

Each directory entry has a filename (up to 30 bytes) and a block pointer (2 bytes). Filenames
are nul-terminated strings. The empty filename indicates a directory entry is not in use.

## Type 1 (file)

After the 4 byte header, the remainder of the block (up to the amount set in the "length"
field) are file contents. Where blocks are chained together, the current block's contents
come first, and then the next block.

A block containing a file that just contains the character "A" would look like:

    |    type       |  length       |       next block pointer      | ... data ...  |
    |0 0 0 0 0 0 0 1|0 0 0 0 0 0 0 1|0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0|0 1 0 0 0 0 0 1|

    type = 1 (file)
    length = 1
    next = 0
    data = 'A'
