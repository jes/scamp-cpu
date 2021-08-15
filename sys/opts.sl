include "getopt.sl";
include "stdio.sl";
include "sys.sl";

var message = "message";
var file = "file";

var help = func(rc) {
    printf(
"options:

    -f file       Set the filename.
    -h            Show this help text.
    -m msg        Set the message to display.
", 0);
    exit(rc);
};

var more_args = getopt(cmdargs()+1, "mf", func(ch, arg) {
    printf(" ... option %c takes argument %s\n", [ch,arg]);
    if (ch == 'm') message = arg
    else if (ch == 'f') file = arg
    else if (ch == 'h') help(0)
    else {
        fprintf(2, "error: unrecognised option -%c\n", [ch]);
        help(1);
    };
});

printf("%s\n", [message]);
printf("The file is: %s\n", [file]);

if (more_args) {
    printf("More arguments:\n", 0);
    while (*more_args) {
        printf("    %s\n", [*more_args]);
        more_args++;
    };
};
