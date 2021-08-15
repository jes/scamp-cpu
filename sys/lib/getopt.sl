# option parsing

include "string.sl";

# parse the given args list; characters included in "argstr" refer to options
# which expect an argument; call the callback function with each option;
# return the address of the remaining unparsed arguments.
#
# options which take an argument can pass it either with or without a space:
#   ["-ffile"] or ["-f", "file"]
#
# options which do not take an argument can be joined up:
#   ["-abc"] or ["-a", "-b", "-c"]
#
# these possibilties can be combined:
#   ["-abcffile"] or ["-a", "-b", "-c", "-f", "file"]
#
# the first element of the args list which is not an argument for an option,
# and does not begin with a "-", terminates option parsing; "--" can be used
# to terminate option parsing early.
#
# example:
#  var file = "default.file";
#  var more_args = getopt(cmdargs()+1, "f", func(ch, arg) {
#      if (ch == 'f') file = arg
#      else if (ch == 'h') help(0)
#      else if (ch == 'v') version()
#      else {
#          fprintf(2, "error: unrecognised option -%c", [ch]);
#          help(1);
#      };
#  });
var getopt = func(args, argstr, cb) {
    var s;
    var ch;

    while (*args) {
        s = *args;
        if (*s != '-') return args;
        if (strcmp(s, "-") == 0) return args;
        if (strcmp(s, "--") == 0) return args;
        s++;

        while (*s) {
            ch = *(s++);

            if (strchr(argstr, ch)) {
                # option takes an argument, from...
                if (*s) {
                    # ...the rest of this string: "-ffile"
                    cb(ch, s);
                    break; # and no more options in the current string
                } else if (*(args+1)) {
                    # ...the next string: ["-f", "file"]
                    cb(ch, *(args+1));
                    args++;
                };
            } else {
                # option takes no argument
                cb(ch, 0);
            };
        };

        args++;
    };

    if (*args) return args
    else return 0;
};
